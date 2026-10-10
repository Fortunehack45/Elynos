import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../../../domain/models/intelligence_mode.dart';
import '../theme/elynos_theme.dart';

class ElyonsBottomBar extends StatefulWidget {
  final IntelligenceMode currentMode;
  final VoidCallback onOpenModeSheet;
  final Function(String, {List<String> attachedFiles}) onSend;
  final bool isPrivateMode;
  final bool isLoading;
  final String? hintText;

  const ElyonsBottomBar({
    super.key,
    required this.currentMode,
    required this.onOpenModeSheet,
    required this.onSend,
    required this.isPrivateMode,
    required this.isLoading,
    this.hintText,
  });

  @override
  State<ElyonsBottomBar> createState() => _ElyonsBottomBarState();
}

class _ElyonsBottomBarState extends State<ElyonsBottomBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _attachedFilePaths = [];
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() {
          _hasText = has;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty && _attachedFilePaths.isEmpty) return;
    if (widget.isLoading) return;

    HapticFeedback.mediumImpact();
    widget.onSend(text, attachedFiles: List.from(_attachedFilePaths));
    _controller.clear();
    setState(() {
      _attachedFilePaths.clear();
      _hasText = false;
    });
  }

  Future<void> _pickRealFiles(BuildContext context, FileType type, {List<String>? allowedExtensions}) async {
    Navigator.of(context).pop(); // Close bottom sheet
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.paths.isNotEmpty) {
        final validPaths = result.paths.whereType<String>().toList();
        if (validPaths.isNotEmpty) {
          setState(() {
            _attachedFilePaths.addAll(validPaths);
          });
          HapticFeedback.lightImpact();
        }
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
  }

  void _showFileAttachmentSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Attach Real Files',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.image_outlined, color: Colors.black, size: 20),
                ),
                title: const Text('Photos & Images (Axiom Lens)', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                subtitle: const Text('Real camera & gallery images for visual inspection', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                onTap: () => _pickRealFiles(ctx, FileType.image),
              ),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.folder_zip_outlined, color: Colors.black, size: 20),
                ),
                title: const Text('ZIP Archives (Full Codebases)', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                subtitle: const Text('Unzips on-device & indexes into 100k context', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                onTap: () => _pickRealFiles(ctx, FileType.custom, allowedExtensions: ['zip', 'tar', 'gz']),
              ),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description_outlined, color: Colors.black, size: 20),
                ),
                title: const Text('Documents & Source Code', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                subtitle: const Text('PDF, TXT, Dart, Python, JSON, Markdown', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                onTap: () => _pickRealFiles(ctx, FileType.custom, allowedExtensions: ['pdf', 'txt', 'md', 'json', 'dart', 'py', 'csv', 'docx']),
              ),
              ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F2F4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.file_present_outlined, color: Colors.black, size: 20),
                ),
                title: const Text('Any File From Device', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                subtitle: const Text('Browse all formats on your device storage', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                onTap: () => _pickRealFiles(ctx, FileType.any),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modeLabel = _getModeLabel(widget.currentMode);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _focusNode.requestFocus();
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F8),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Attached Files Chips
              if (_attachedFilePaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _attachedFilePaths.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final path = _attachedFilePaths[index];
                        final name = path.split('/').last.split(r'\').last;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAEAEB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.attach_file, size: 14, color: Colors.black87),
                              const SizedBox(width: 4),
                              Text(
                                name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black87),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _attachedFilePaths.removeAt(index);
                                  });
                                },
                                child: const Icon(Icons.close, size: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Top Input Field (Grok "Ask anything")
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                cursorColor: Colors.black,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? 'Ask anything',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(top: 2, bottom: 8),
                ),
              ),

            // Bottom Action Row (Grok 1:1 match)
            Row(
              children: [
                // Plus Attachment Button
                InkWell(
                  onTap: _showFileAttachmentSheet,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAEAEB),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.add, size: 20, color: Color(0xFF1F2937)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Fast / Mode Selector Pill (Grok ⚡ Fast v)
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onOpenModeSheet();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, size: 16, color: Colors.black),
                        const SizedBox(width: 3),
                        Text(
                          modeLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Right: Speak Pill & Mic OR Circular Send Button
                if (!_hasText && _attachedFilePaths.isEmpty) ...[
                  // Mic Icon Button
                  IconButton(
                    icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF4B5563), size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Elynos Audio: Speak directly or type your prompt.', style: TextStyle(fontWeight: FontWeight.w600)),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),

                  // Grok "||| Speak" Pill Button
                  InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Voice Mode: Ready to capture voice note.', style: TextStyle(fontWeight: FontWeight.w600)),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.graphic_eq, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Speak',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Grok Upward Arrow Send Button (Black Circle with White Up Arrow)
                  InkWell(
                    onTap: widget.isLoading ? null : _handleSend,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: widget.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }

  String _getModeLabel(IntelligenceMode mode) {
    switch (mode) {
      case IntelligenceMode.fast:
        return 'Fast';
      case IntelligenceMode.expert:
        return 'Think Deep';
      case IntelligenceMode.build:
        return 'Build';
      case IntelligenceMode.goal:
        return 'Goal';
      case IntelligenceMode.study:
        return 'Study';
      case IntelligenceMode.research:
        return 'Research';
      case IntelligenceMode.heavy:
        return 'Heavy';
      case IntelligenceMode.auto:
      default:
        return 'Fast';
    }
  }
}
