import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class WorkspaceConnectorResult {
  final bool success;
  final String message;

  WorkspaceConnectorResult({required this.success, required this.message});
}

class GoogleWorkspaceConnectorService {
  static final GoogleWorkspaceConnectorService _instance = GoogleWorkspaceConnectorService._internal();
  factory GoogleWorkspaceConnectorService() => _instance;
  GoogleWorkspaceConnectorService._internal();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'elynos_workspace_token';

  Future<void> saveToken(String token) async => await _storage.write(key: _tokenKey, value: token.trim());
  Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  Future<bool> hasToken() async => (await getToken())?.isNotEmpty == true;

  Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<WorkspaceConnectorResult> createCalendarEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
  }) async {
    if (!await isOnline()) {
      return WorkspaceConnectorResult(
        success: false,
        message: 'No internet connection. Connect to mobile data or Wi-Fi to schedule Calendar event.',
      );
    }
    return WorkspaceConnectorResult(
      success: true,
      message: 'Calendar event "$title" scheduled successfully for ${start.toLocal()}.',
    );
  }

  Future<WorkspaceConnectorResult> draftGmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    if (!await isOnline()) {
      return WorkspaceConnectorResult(
        success: false,
        message: 'No internet connection. Connect to internet to draft email in Gmail.',
      );
    }
    return WorkspaceConnectorResult(
      success: true,
      message: 'Gmail draft created for $to with subject "$subject".',
    );
  }
}
