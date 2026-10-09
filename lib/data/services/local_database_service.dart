import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../domain/models/conversation.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/training_memory.dart';
import '../../domain/models/build_project.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'elynos_local.db');

    return await openDatabase(
      path,
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) async {
        try {
          await db.execute('ALTER TABLE messages ADD COLUMN visualAuditJson TEXT;');
        } catch (_) {}
        try {
          await db.execute('ALTER TABLE messages ADD COLUMN attachedFilesJson TEXT;');
        } catch (_) {}
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE conversations (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            lastMessageSnippet TEXT,
            isPinned INTEGER DEFAULT 0,
            isPrivate INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE messages (
            id TEXT PRIMARY KEY,
            conversationId TEXT NOT NULL,
            sender TEXT NOT NULL,
            text TEXT NOT NULL,
            thinkingProcess TEXT,
            mode TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            imageUrl TEXT,
            codeArtifact TEXT,
            goalMilestonesJson TEXT,
            visualAuditJson TEXT,
            attachedFilesJson TEXT,
            isTemporary INTEGER DEFAULT 0,
            FOREIGN KEY (conversationId) REFERENCES conversations (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE training_memories (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            learnedFact TEXT NOT NULL,
            promptTrigger TEXT,
            targetResponse TEXT,
            confidence REAL DEFAULT 1.0,
            createdAt TEXT NOT NULL,
            isActive INTEGER DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE build_projects (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            filesJson TEXT,
            githubRepoUrl TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE context_chunks (
            id TEXT PRIMARY KEY,
            conversationId TEXT NOT NULL,
            chunkIndex INTEGER NOT NULL,
            content TEXT NOT NULL,
            tokenCount INTEGER NOT NULL,
            keywords TEXT,
            FOREIGN KEY (conversationId) REFERENCES conversations (id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  // --- Conversations ---
  Future<List<Conversation>> getConversations() async {
    final db = await database;
    final maps = await db.query(
      'conversations',
      where: 'isPrivate = 0',
      orderBy: 'isPinned DESC, updatedAt DESC',
    );
    return maps.map((m) => Conversation.fromMap(m)).toList();
  }

  Future<void> saveConversation(Conversation conversation) async {
    if (conversation.isPrivate) return; // Never persist private chats
    final db = await database;
    await db.insert(
      'conversations',
      conversation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteConversation(String id) async {
    final db = await database;
    await db.delete('messages', where: 'conversationId = ?', whereArgs: [id]);
    await db.delete('conversations', where: 'id = ?', whereArgs: [id]);
  }

  // --- Messages ---
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'conversationId = ? AND isTemporary = 0',
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) {
      final map = Map<String, dynamic>.from(m);
      if (map['goalMilestonesJson'] != null) {
        try {
          map['goalMilestones'] = jsonDecode(map['goalMilestonesJson'] as String);
        } catch (_) {}
      }
      if (map['visualAuditJson'] != null) {
        try {
          map['visualAudit'] = jsonDecode(map['visualAuditJson'] as String);
        } catch (_) {}
      }
      if (map['attachedFilesJson'] != null) {
        try {
          map['attachedFiles'] = jsonDecode(map['attachedFilesJson'] as String);
        } catch (_) {}
      }
      return ChatMessage.fromMap(map);
    }).toList();
  }

  Future<void> saveMessage(ChatMessage message) async {
    if (message.isTemporary) return; // Never persist private messages
    final db = await database;

    // 1. Ensure conversation exists in conversations table to avoid Foreign Key violations
    try {
      final convCheck = await db.query('conversations', where: 'id = ?', whereArgs: [message.conversationId]);
      if (convCheck.isEmpty) {
        final convTitle = message.text.trim().isNotEmpty
            ? (message.text.trim().length > 28 ? '${message.text.trim().substring(0, 28)}...' : message.text.trim())
            : 'New Chat';
        await db.insert('conversations', {
          'id': message.conversationId,
          'title': convTitle,
          'createdAt': message.timestamp.toIso8601String(),
          'updatedAt': message.timestamp.toIso8601String(),
          'lastMessageSnippet': message.text,
          'isPinned': 0,
          'isPrivate': 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } catch (_) {}

    // 2. Build strictly typed insert map matching SQLite schema
    final insertMap = <String, dynamic>{
      'id': message.id,
      'conversationId': message.conversationId,
      'sender': message.sender,
      'text': message.text,
      'thinkingProcess': message.thinkingProcess,
      'mode': message.mode.name,
      'timestamp': message.timestamp.toIso8601String(),
      'imageUrl': message.imageUrl,
      'codeArtifact': message.codeArtifact,
      'goalMilestonesJson': message.goalMilestones != null
          ? jsonEncode(message.goalMilestones!.map((g) => g.toMap()).toList())
          : null,
      'visualAuditJson': message.visualAudit != null
          ? jsonEncode(message.visualAudit)
          : null,
      'attachedFilesJson': message.attachedFiles != null
          ? jsonEncode(message.attachedFiles)
          : null,
      'isTemporary': message.isTemporary ? 1 : 0,
    };

    await db.insert('messages', insertMap, conflictAlgorithm: ConflictAlgorithm.replace);

    // 3. Update conversation timestamp & snippet
    try {
      await db.update(
        'conversations',
        {
          'updatedAt': message.timestamp.toIso8601String(),
          'lastMessageSnippet': message.text.length > 60 ? '${message.text.substring(0, 60)}...' : message.text,
        },
        where: 'id = ?',
        whereArgs: [message.conversationId],
      );
    } catch (_) {}
  }

  // --- Training Memories ---
  Future<List<TrainingMemory>> getMemories() async {
    final db = await database;
    final maps = await db.query('training_memories', orderBy: 'createdAt DESC');
    return maps.map((m) => TrainingMemory.fromMap(m)).toList();
  }

  Future<void> saveMemory(TrainingMemory memory) async {
    final db = await database;
    await db.insert(
      'training_memories',
      memory.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMemory(String id) async {
    final db = await database;
    await db.delete('training_memories', where: 'id = ?', whereArgs: [id]);
  }

  // --- Build Projects ---
  Future<List<BuildProject>> getProjects() async {
    final db = await database;
    final maps = await db.query('build_projects', orderBy: 'updatedAt DESC');
    return maps.map((m) => BuildProject.fromMap(m)).toList();
  }

  Future<void> saveProject(BuildProject project) async {
    final db = await database;
    await db.insert('build_projects', project.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- 100k Paged Context (Low-RAM Virtual Window) ---
  Future<void> saveContextChunks(String conversationId, List<Map<String, dynamic>> chunks) async {
    final db = await database;
    final batch = db.batch();
    for (final chunk in chunks) {
      batch.insert('context_chunks', chunk, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<String>> queryContextChunks(String conversationId, String query, {int limit = 4}) async {
    final db = await database;
    final lower = query.toLowerCase();
    final words = lower.split(RegExp(r'\s+')).where((w) => w.length > 3).toList();

    if (words.isEmpty) {
      final maps = await db.query(
        'context_chunks',
        where: 'conversationId = ?',
        orderBy: 'chunkIndex ASC',
        limit: limit,
      );
      return maps.map((m) => m['content'] as String).toList();
    }

    // Keyword match across keywords/content
    final whereClauses = words.map((_) => '(keywords LIKE ? OR content LIKE ?)').join(' OR ');
    final whereArgs = <dynamic>[conversationId];
    for (final w in words) {
      whereArgs.add('%$w%');
      whereArgs.add('%$w%');
    }

    final maps = await db.query(
      'context_chunks',
      where: 'conversationId = ? AND ($whereClauses)',
      whereArgs: whereArgs,
      orderBy: 'chunkIndex ASC',
      limit: limit,
    );

    return maps.map((m) => m['content'] as String).toList();
  }

  Future<void> clearContextChunks(String conversationId) async {
    final db = await database;
    await db.delete('context_chunks', where: 'conversationId = ?', whereArgs: [conversationId]);
  }
}
