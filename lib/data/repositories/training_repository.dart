import '../../domain/models/training_memory.dart';
import '../services/local_database_service.dart';

class TrainingRepository {
  final LocalDatabaseService _dbService;

  TrainingRepository({LocalDatabaseService? dbService})
      : _dbService = dbService ?? LocalDatabaseService();

  Future<List<TrainingMemory>> getMemories() async {
    return await _dbService.getMemories();
  }

  Future<void> addMemory(TrainingMemory memory) async {
    await _dbService.saveMemory(memory);
  }

  Future<void> deleteMemory(String id) async {
    await _dbService.deleteMemory(id);
  }

  Future<void> toggleMemory(TrainingMemory memory) async {
    memory.isActive = !memory.isActive;
    await _dbService.saveMemory(memory);
  }
}
