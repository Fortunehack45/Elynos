import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../core/theme/elynos_theme.dart';

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
            // LaTeX Formula Block
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Math.tex(
                    parts[index].trim(),
                    textStyle: const TextStyle(fontSize: 18, color: ElyonsColors.accent),
                    onErrorFallback: (err) => Text(
                      parts[index],
                      style: const TextStyle(color: Colors.redAccent, fontFamily: 'monospace'),
                    ),
                  ),
                ),
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
        p: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15, height: 1.5),
        h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ElyonsColors.accent),
        code: const TextStyle(
          backgroundColor: Color(0xFF1E242E),
          color: Color(0xFF38BDF8),
          fontFamily: 'monospace',
          fontSize: 13,
        ),
        codeblockPadding: const EdgeInsets.all(0),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ElyonsColors.border),
        ),
        blockquote: const TextStyle(color: ElyonsColors.textSecondary, fontStyle: FontStyle.italic),
        blockquoteDecoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: const Border(left: BorderSide(color: ElyonsColors.accent, width: 4)),
          borderRadius: BorderRadius.circular(4),
        ),
        tableBorder: TableBorder.all(color: ElyonsColors.border, width: 1),
        tableHead: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        tableBody: const TextStyle(color: ElyonsColors.textPrimary),
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
      return null; // Inline code
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ElyonsColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  style: TextStyle(fontSize: 12, color: ElyonsColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                Builder(
                  builder: (ctx) => InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.copy_rounded, size: 14, color: ElyonsColors.accent),
                        SizedBox(width: 4),
                        Text('Copy', style: TextStyle(fontSize: 12, color: ElyonsColors.accent)),
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
