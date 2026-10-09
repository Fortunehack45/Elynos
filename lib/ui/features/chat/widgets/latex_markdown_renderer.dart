import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

class LatexMarkdownRenderer extends StatelessWidget {
  final String content;

  const LatexMarkdownRenderer({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // Check if content contains block math ($$...$$)
    if (content.contains('\$\$')) {
      final parts = content.split('\$\$');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(parts.length, (index) {
          if (index.isOdd) {
            // LaTeX Formula Block - Clean styled formula block
            final formula = parts[index].trim();
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEAEB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LaTeX / Math',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText(
                      formula,
                      style: const TextStyle(
                        fontSize: 15,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Standard Markdown
            if (parts[index].trim().isEmpty) return const SizedBox.shrink();
            return _buildMarkdown(context, parts[index]);
          }
        }),
      );
    }

    return _buildMarkdown(context, content);
  }

  Widget _buildMarkdown(BuildContext context, String markdownText) {
    return MarkdownBody(
      data: markdownText,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          height: 1.4,
          letterSpacing: -0.2,
        ),
        h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -0.4),
        h2: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: -0.3),
        h3: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: -0.2),
        code: const TextStyle(
          backgroundColor: Color(0xFFF2F2F4),
          color: Colors.black,
          fontFamily: 'monospace',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        codeblockPadding: const EdgeInsets.all(0),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF1E242E),
          borderRadius: BorderRadius.circular(12),
        ),
        blockquote: const TextStyle(color: Color(0xFF4B5563), fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFFF7F7F8),
          border: const Border(left: BorderSide(color: Colors.black, width: 3)),
          borderRadius: BorderRadius.circular(4),
        ),
        tableBorder: TableBorder.all(color: const Color(0xFFE5E7EB), width: 1),
        tableHead: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
        tableBody: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        listBullet: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      builders: {
        'code': CodeBlockCustomBuilder(),
      },
    );
  }
}

class CodeBlockCustomBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(mdElement, TextStyle? preferredStyle) {
    final code = mdElement.textContent;
    if (!code.contains('\n')) {
      return null; // Inline code handled by default style
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF262C36)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: const BoxDecoration(
              color: Color(0xFF1E242E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Code Snippet',
                  style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                Builder(
                  builder: (ctx) => InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Copy', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          HighlightView(
            code,
            language: 'dart',
            theme: atomOneDarkTheme,
            padding: const EdgeInsets.all(12),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
