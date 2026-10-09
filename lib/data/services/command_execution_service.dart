import 'dart:io';
import 'dart:async';

class CommandExecutionResult {
  final String command;
  final int exitCode;
  final String stdout;
  final String stderr;
  final double durationMs;
  final bool success;

  CommandExecutionResult({
    required this.command,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    required this.durationMs,
    required this.success,
  });
}

class CommandExecutionService {
  static final CommandExecutionService _instance = CommandExecutionService._internal();
  factory CommandExecutionService() => _instance;
  CommandExecutionService._internal();

  /// Runs commands autonomously on its own in a safe edge environment
  Future<CommandExecutionResult> executeCommand(String commandLine, {String? workingDir}) async {
    final start = DateTime.now();
    final trimmed = commandLine.trim();

    if (trimmed.isEmpty) {
      return CommandExecutionResult(
        command: commandLine,
        exitCode: 1,
        stdout: '',
        stderr: 'Error: Empty command.',
        durationMs: 0,
        success: false,
      );
    }

    try {
      final parts = trimmed.split(RegExp(r'\s+'));
      final executable = parts.first;
      final args = parts.skip(1).toList();

      // Built-in safe command handlers for edge execution
      if (executable == 'echo') {
        final text = args.join(' ');
        final ms = DateTime.now().difference(start).inMicroseconds / 1000.0;
        return CommandExecutionResult(
          command: commandLine,
          exitCode: 0,
          stdout: text,
          stderr: '',
          durationMs: ms,
          success: true,
        );
      }

      if (executable == 'pwd') {
        final ms = DateTime.now().difference(start).inMicroseconds / 1000.0;
        return CommandExecutionResult(
          command: commandLine,
          exitCode: 0,
          stdout: workingDir ?? Directory.current.path,
          stderr: '',
          durationMs: ms,
          success: true,
        );
      }

      // Execute via standard Process
      final processResult = await Process.run(
        executable,
        args,
        workingDirectory: workingDir,
        runInShell: true,
      );

      final ms = DateTime.now().difference(start).inMicroseconds / 1000.0;
      return CommandExecutionResult(
        command: commandLine,
        exitCode: processResult.exitCode,
        stdout: processResult.stdout.toString(),
        stderr: processResult.stderr.toString(),
        durationMs: ms,
        success: processResult.exitCode == 0,
      );
    } catch (e) {
      final ms = DateTime.now().difference(start).inMicroseconds / 1000.0;
      return CommandExecutionResult(
        command: commandLine,
        exitCode: 1,
        stdout: '',
        stderr: 'Execution exception: $e',
        durationMs: ms,
        success: false,
      );
    }
  }
}
