import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/connectors/github_connector_service.dart';
import '../../../core/theme/elynos_theme.dart';

class BuildModeView extends StatefulWidget {
  const BuildModeView({super.key});

  @override
  State<BuildModeView> createState() => _BuildModeViewState();
}

class _BuildModeViewState extends State<BuildModeView> {
  final _promptController = TextEditingController();
  final _githubService = GitHubConnectorService();

  bool _isBuilding = false;
  bool _isPushing = false;
  String? _generatedCode;
  String? _statusMessage;

  final Map<String, String> _templates = {
    'Portfolio Website': '''<!DOCTYPE html>
<html>
<head>
  <title>Elynos Developer Portfolio</title>
  <style>
    body { background: #0b0e14; color: #fff; font-family: sans-serif; padding: 2rem; }
    .hero { max-width: 600px; margin: 0 auto; text-align: center; }
    h1 { color: #38bdf8; }
    .badge { background: #1f2937; padding: 4px 10px; border-radius: 12px; font-size: 12px; }
  </style>
</head>
<body>
  <div class="hero">
    <span class="badge">Elynos Autonomous Build</span>
    <h1>Creative Engineer</h1>
    <p>Offline-first developer building next-gen autonomous apps.</p>
  </div>
</body>
</html>''',
    'Interactive Calculator': '''<!DOCTYPE html>
<html>
<head>
  <title>Elynos Smart Calculator</title>
  <style>
    body { background: #0f131a; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
    .calc { background: #161c26; padding: 20px; border-radius: 16px; border: 1px solid #262c36; }
    .display { background: #0b0e14; color: #38bdf8; font-size: 24px; padding: 12px; border-radius: 8px; text-align: right; margin-bottom: 12px; }
    .grid { display: grid; grid-template-columns: repeat(4, 50px); gap: 8px; }
    button { height: 50px; background: #222938; color: #fff; border: none; border-radius: 8px; font-size: 18px; cursor: pointer; }
    button.op { background: #38bdf8; color: #000; font-weight: bold; }
  </style>
</head>
<body>
  <div class="calc">
    <div class="display">0</div>
    <div class="grid">
      <button>7</button><button>8</button><button>9</button><button class="op">/</button>
      <button>4</button><button>5</button><button>6</button><button class="op">*</button>
      <button>1</button><button>2</button><button>3</button><button class="op">-</button>
      <button>0</button><button>.</button><button>=</button><button class="op">+</button>
    </div>
  </div>
</body>
</html>''',
  };

  void _buildApp(String templateName, String code) {
    setState(() {
      _isBuilding = true;
      _statusMessage = null;
    });
    HapticFeedback.mediumImpact();

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _generatedCode = code;
        _isBuilding = false;
      });
    });
  }

  Future<void> _pushToGitHub() async {
    if (_generatedCode == null) return;

    setState(() {
      _isPushing = true;
      _statusMessage = null;
    });

    final result = await _githubService.pushProject(
      repoName: 'elynos-build-${DateTime.now().millisecondsSinceEpoch}',
      description: 'App built autonomously by Elynos Build Agent',
      files: {'index.html': _generatedCode!},
    );

    setState(() {
      _isPushing = false;
      _statusMessage = result.message;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF131822),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ElyonsColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.handyman_outlined, color: ElyonsColors.accent, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Elynos Build Agent',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262C36),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Agentic', style: TextStyle(fontSize: 10, color: ElyonsColors.accent)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Describe a website or app. Elynos generates the code offline and pushes to GitHub.',
                  style: TextStyle(fontSize: 13, color: ElyonsColors.textSecondary),
                ),
                const SizedBox(height: 14),
                // Templates Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _templates.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          avatar: const Icon(Icons.flash_on_rounded, size: 14, color: ElyonsColors.accent),
                          label: Text(entry.key),
                          onPressed: () => _buildApp(entry.key, entry.value),
                          backgroundColor: const Color(0xFF1C222E),
                          side: const BorderSide(color: ElyonsColors.border),
                          labelStyle: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Code Sandbox & Action View
          if (_generatedCode != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF141A24),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ElyonsColors.accent.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Generated Code Sandbox',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18, color: ElyonsColors.accent),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _generatedCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F131A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _generatedCode!,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: ElyonsColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _isPushing ? null : _pushToGitHub,
                    icon: _isPushing
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: Text(_isPushing ? 'Pushing to GitHub...' : 'Push to GitHub'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ElyonsColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: _statusMessage!.contains('Success') ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: const [
                    Icon(Icons.terminal_rounded, size: 48, color: ElyonsColors.textMuted),
                    SizedBox(height: 10),
                    Text('Select a template or describe an app to build', style: TextStyle(color: ElyonsColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
