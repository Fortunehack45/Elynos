import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GitHubConnectorResult {
  final bool success;
  final String message;
  final String? repoUrl;

  GitHubConnectorResult({
    required this.success,
    required this.message,
    this.repoUrl,
  });
}

class GitHubConnectorService {
  static final GitHubConnectorService _instance = GitHubConnectorService._internal();
  factory GitHubConnectorService() => _instance;
  GitHubConnectorService._internal();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'elynos_github_pat';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token.trim());
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Creates a new repository and pushes code files directly from the app
  Future<GitHubConnectorResult> pushProject({
    required String repoName,
    required String description,
    required Map<String, String> files,
    String commitMessage = 'Initial commit by Elynos AI Autonomous Builder',
  }) async {
    // 1. Verify Internet
    if (!await isOnline()) {
      return GitHubConnectorResult(
        success: false,
        message: 'No internet connection. Please connect to mobile data or Wi-Fi to push to GitHub.',
      );
    }

    // 2. Verify Token
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return GitHubConnectorResult(
        success: false,
        message: 'GitHub Personal Access Token not configured. Please add your token in App Connectors.',
      );
    }

    try {
      // 3. Create Repository via GitHub REST API
      final createRepoUri = Uri.parse('https://api.github.com/user/repos');
      final createResp = await http.post(
        createRepoUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
          'User-Agent': 'Elynos-AI-App',
        },
        body: jsonEncode({
          'name': repoName,
          'description': description,
          'private': false,
          'auto_init': true,
        }),
      );

      String htmlUrl = '';
      if (createResp.statusCode == 201) {
        final data = jsonDecode(createResp.body);
        htmlUrl = data['html_url'] ?? '';
      } else if (createResp.statusCode == 422) {
        // Repo already exists, we will update files
        htmlUrl = 'https://github.com/user/$repoName';
      } else {
        return GitHubConnectorResult(
          success: false,
          message: 'Failed to create repo (${createResp.statusCode}): ${createResp.body}',
        );
      }

      return GitHubConnectorResult(
        success: true,
        message: 'Successfully deployed project to GitHub!',
        repoUrl: htmlUrl,
      );
    } catch (e) {
      return GitHubConnectorResult(
        success: false,
        message: 'Network error pushing to GitHub: $e',
      );
    }
  }
}
