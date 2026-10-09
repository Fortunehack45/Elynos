import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/connectors/github_connector_service.dart';
import '../../../../data/services/connectors/workspace_connector_service.dart';
import '../../../../data/services/connectors/spotify_slack_connector_service.dart';
import '../../../core/theme/elynos_theme.dart';

class ConnectorsScreen extends StatefulWidget {
  const ConnectorsScreen({super.key});

  @override
  State<ConnectorsScreen> createState() => _ConnectorsScreenState();
}

class _ConnectorsScreenState extends State<ConnectorsScreen> {
  final _githubService = GitHubConnectorService();
  final _workspaceService = GoogleWorkspaceConnectorService();
  final _slackService = SlackConnectorService();
  final _spotifyService = SpotifyConnectorService();

  final _githubTokenController = TextEditingController();
  final _slackWebhookController = TextEditingController();

  bool _isOnline = false;
  bool _githubConnected = false;
  bool _workspaceConnected = false;
  bool _slackConnected = false;
  bool _spotifyConnected = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final online = await _githubService.isOnline();
    final hasGithub = await _githubService.hasToken();
    final hasWorkspace = await _workspaceService.hasToken();
    final slackHook = await _slackService.getWebhook();
    final spotifyTok = await _spotifyService.getToken();

    setState(() {
      _isOnline = online;
      _githubConnected = hasGithub;
      _workspaceConnected = hasWorkspace;
      _slackConnected = slackHook != null && slackHook.isNotEmpty;
      _spotifyConnected = spotifyTok != null && spotifyTok.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ElyonsColors.background,
        elevation: 0,
        title: const Text('App Connectors', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Network Connectivity Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isOnline ? const Color(0xFF13281E) : const Color(0xFF281E13),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isOnline ? Colors.greenAccent.withOpacity(0.5) : Colors.amberAccent.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                    color: _isOnline ? Colors.greenAccent : Colors.amberAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isOnline ? 'Internet Active' : 'Offline Mode Active',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _isOnline ? Colors.greenAccent : Colors.amberAccent,
                          ),
                        ),
                        Text(
                          _isOnline
                              ? 'App connectors are ready to sync when requested.'
                              : 'Connectors require mobile data/Wi-Fi to execute tasks.',
                          style: const TextStyle(fontSize: 12, color: ElyonsColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Available Integrations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),

            // GitHub Connector Card
            _buildConnectorCard(
              icon: Icons.code_rounded,
              title: 'GitHub',
              subtitle: 'Push generated websites/apps, create repos & PRs',
              isConnected: _githubConnected,
              onConfigure: () => _showTokenDialog('GitHub Personal Access Token', _githubTokenController, (token) async {
                await _githubService.saveToken(token);
                _checkStatus();
              }),
            ),

            // Google Workspace Card
            _buildConnectorCard(
              icon: Icons.work_outline_rounded,
              title: 'Google Workspace',
              subtitle: 'Google Calendar scheduling, Gmail drafts & Drive sync',
              isConnected: _workspaceConnected,
              onConfigure: () => _showWorkspaceDialog(),
            ),

            // Slack Card
            _buildConnectorCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Slack',
              subtitle: 'Dispatch notifications and summary reports to channels',
              isConnected: _slackConnected,
              onConfigure: () => _showTokenDialog('Slack Webhook URL', _slackWebhookController, (hook) async {
                await _slackService.saveWebhook(hook);
                _checkStatus();
              }),
            ),

            // Spotify Card
            _buildConnectorCard(
              icon: Icons.music_note_rounded,
              title: 'Spotify',
              subtitle: 'Play deep focus & study coding playlists in Study Mode',
              isConnected: _spotifyConnected,
              onConfigure: () async {
                await _spotifyService.saveToken('spotify_active');
                _checkStatus();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectorCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isConnected,
    required VoidCallback onConfigure,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141923),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ElyonsColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2533),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ElyonsColors.accent, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green.withOpacity(0.2) : const Color(0xFF262C36),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isConnected ? 'Connected' : 'Not Connected',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isConnected ? Colors.greenAccent : ElyonsColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: ElyonsColors.textSecondary)),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onConfigure,
            style: OutlinedButton.styleFrom(
              foregroundColor: ElyonsColors.accent,
              side: const BorderSide(color: ElyonsColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isConnected ? 'Edit' : 'Connect'),
          ),
        ],
      ),
    );
  }

  void _showTokenDialog(String title, TextEditingController controller, Function(String) onSave) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        content: TextField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Paste token / webhook here',
            hintStyle: TextStyle(color: ElyonsColors.textMuted, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: ElyonsColors.accent, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWorkspaceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Google Workspace Access'),
        content: const Text(
          'Connect your Google Workspace accounts locally on this device.\n\n'
          'No remote database or servers have access to your credentials.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _workspaceService.saveToken('workspace_active');
              _checkStatus();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: ElyonsColors.accent, foregroundColor: Colors.white),
            child: const Text('Connect Workspace'),
          ),
        ],
      ),
    );
  }
}
