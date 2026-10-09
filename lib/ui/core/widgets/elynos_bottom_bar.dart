import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../domain/models/intelligence_mode.dart';
import '../theme/elynos_theme.dart';

class ElyonsBottomBar extends StatefulWidget {
  final IntelligenceMode currentMode;
  final VoidCallback onOpenModeSheet;
  final void Function(String text, {List<String> attachedFiles}) onSend;
  final bool isPrivateMode;
  final bool isLoading;

  const ElyonsBottomBar({
    super.key,
    required this.currentMode,
    required this.onOpenModeSheet,
    required this.onSend,
    required this.isPrivateMode,
    required this.isLoading,
  });

  @override
  State<ElyonsBottomBar> createState() => _ElyonsBottomBarState();
}

class _ElyonsBottomBarState extends State<ElyonsBottomBar> {
  final _controller = TextEditingController();
  final List<String> _attachedFiles = [];
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) {
        setState(() => _hasText = has);
      }
    });
  }

  void _submit() {
    final text = _controller.text.trim();
    if ((text.isEmpty && _attachedFiles.isEmpty) || widget.isLoading) return;
    HapticFeedback.lightImpact();
    widget.onSend(text, attachedFiles: List.from(_attachedFiles));
    _controller.clear();
    setState(() {
      _attachedFiles.clear();
    });
  }

  void _showAttachSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF13171F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attach to Elynos 1 Axiom',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                'Attach images, zips, or docs. Elynos will inspect and visualize them on-device.',
                style: TextStyle(fontSize: 12, color: ElyonsColors.textSecondary),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.image_rounded, color: Color(0xFF00E676)),
                title: const Text('Attach Image / Photo (Visual Perception)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Inspect dimensions, layout, and visual contents', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _attachedFiles.add('ui_wireframe_mockup.png'));
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder_zip_rounded, color: Color(0xFFFFD54F)),
                title: const Text('Attach ZIP Archive (Auto-Unzip)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Unpack and index code into 100k local context', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _attachedFiles.add('project_source.zip'));
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFFF5252)),
                title: const Text('Attach PDF Document', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Inspect document layout, margins, and typography', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _attachedFiles.add('technical_spec.pdf'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      color: ElyonsColors.background,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Temporary Conversation Badge in Private Mode
            if (widget.isPrivateMode)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E242E),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Temporary conversation',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ElyonsColors.textSecondary,
                  ),
                ),
              ),

            // Main Input Container
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF151922),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: ElyonsColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Attachment Preview Chips
                  if (_attachedFiles.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4, right: 4, bottom: 2),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _attachedFiles.map((file) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2634),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2A3648)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                file.endsWith('.zip')
                                    ? Icons.folder_zip_rounded
                                    : (file.endsWith('.png') || file.endsWith('.jpg'))
                                        ? Icons.image_rounded
                                        : Icons.description_rounded,
                                size: 14,
                                color: ElyonsColors.accent,
                              ),
                              const SizedBox(width: 4),
                              Text(file, style: const TextStyle(fontSize: 11, color: Colors.white)),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => setState(() => _attachedFiles.remove(file)),
                                child: const Icon(Icons.close, size: 13, color: Colors.white70),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),

                  // Text Input Field
                  TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: widget.isPrivateMode ? 'Ask privately...' : 'Ask anything, attach or visualize',
                      hintStyle: const TextStyle(color: ElyonsColors.textMuted, fontSize: 15),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                    ),
                  ),

                  // Bottom Action Strip
                  Row(
                    children: [
                      // Attachment / Plus Button
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white70, size: 22),
                        onPressed: _showAttachSheet,
                      ),

                      // Mode Dropdown Pill (e.g. ⚡ Fast ˅)
                      InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onOpenModeSheet();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF202734),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(widget.currentMode.icon, size: 14, color: ElyonsColors.accent),
                              const SizedBox(width: 5),
                              Text(
                                widget.currentMode.displayName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Mic Button
                      IconButton(
                        icon: const Icon(Icons.mic_none_rounded, color: Colors.white70, size: 22),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Voice input ready')),
                          );
                        },
                      ),

                      // Send / Speak Pill Button
                      if (_hasText || _attachedFiles.isNotEmpty)
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: widget.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : const Icon(Icons.arrow_upward_rounded, color: Colors.black, size: 20),
                            onPressed: widget.isLoading ? null : _submit,
                          ),
                        )
                      else
                        // Speak Pill Button (Black pill with wave icon)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.graphic_eq_rounded, color: Colors.black, size: 16),
                              SizedBox(width: 5),
                              Text(
                                'Speak',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
