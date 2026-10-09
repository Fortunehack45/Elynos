import 'dart:convert';

class BuildProject {
  final String id;
  String name;
  String description;
  Map<String, String> files;
  String? githubRepoUrl;
  final DateTime createdAt;
  DateTime updatedAt;

  BuildProject({
    required this.id,
    required this.name,
    required this.description,
    required this.files,
    this.githubRepoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'filesJson': jsonEncode(files),
      'githubRepoUrl': githubRepoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BuildProject.fromMap(Map<String, dynamic> map) {
    Map<String, String> parsedFiles = {};
    if (map['filesJson'] != null) {
      try {
        final decoded = jsonDecode(map['filesJson'] as String) as Map<String, dynamic>;
        parsedFiles = decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {}
    }

    return BuildProject(
      id: map['id'] as String,
      name: map['name'] as String,
      description: (map['description'] ?? '') as String,
      files: parsedFiles,
      githubRepoUrl: map['githubRepoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
