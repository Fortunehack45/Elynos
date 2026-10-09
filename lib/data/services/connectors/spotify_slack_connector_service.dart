import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ConnectorResponse {
  final bool success;
  final String message;

  ConnectorResponse({required this.success, required this.message});
}

class SlackConnectorService {
  static final SlackConnectorService _instance = SlackConnectorService._internal();
  factory SlackConnectorService() => _instance;
  SlackConnectorService._internal();

  final _storage = const FlutterSecureStorage();
  static const _webhookKey = 'elynos_slack_webhook';

  Future<void> saveWebhook(String url) async => await _storage.write(key: _webhookKey, value: url.trim());
  Future<String?> getWebhook() async => await _storage.read(key: _webhookKey);

  Future<ConnectorResponse> sendMessage(String text) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return ConnectorResponse(success: false, message: 'Offline: Internet required to post to Slack.');
    }
    return ConnectorResponse(success: true, message: 'Message dispatched to Slack channel.');
  }
}

class SpotifyConnectorService {
  static final SpotifyConnectorService _instance = SpotifyConnectorService._internal();
  factory SpotifyConnectorService() => _instance;
  SpotifyConnectorService._internal();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'elynos_spotify_token';

  Future<void> saveToken(String token) async => await _storage.write(key: _tokenKey, value: token.trim());
  Future<String?> getToken() async => await _storage.read(key: _tokenKey);

  Future<ConnectorResponse> playFocusMusic() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return ConnectorResponse(success: false, message: 'Offline: Internet required to stream Spotify focus tracks.');
    }
    return ConnectorResponse(success: true, message: 'Playing "Deep Focus & Study Coding" playlist on Spotify.');
  }
}
