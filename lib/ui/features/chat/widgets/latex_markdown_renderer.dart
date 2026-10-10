import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../../data/services/math_formula_processor.dart';

class LatexMarkdownRenderer extends StatelessWidget {
  final String content;

  const LatexMarkdownRenderer({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // 1. Normalize LaTeX delimiters: \[...\] -> $$...$$ and \(...\) -> $...$
    String normalized = content;
    normalized = normalized.replaceAllMapped(RegExp(r'\\\[([\s\S]*?)\\\]'), (m) => '\n\n\$\$${m.group(1)?.trim()}\$\$\n\n');
    normalized = normalized.replaceAllMapped(RegExp(r'\\\(([\s\S]*?)\\\)'), (m) => '\$${m.group(1)?.trim()}\$');

    // 2. Check if content contains block math ($$...$$)
    if (normalized.contains('\$\$')) {
      final parts = normalized.split('\$\$');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(parts.length, (index) {
          if (index.isOdd) {
            final rawFormula = parts[index].trim();
            final processedFormula = MathFormulaProcessor.processLatex(rawFormula);
            if (processedFormula.isEmpty) return const SizedBox.shrink();

            // Clean, clear LaTeX rendering WITHOUT heavy container box
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SelectableText(
                    processedFormula,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 0.5,
                      height: 1.45,
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

    return _buildMarkdown(context, normalized);
  }

  Widget _buildMarkdown(BuildContext context, String markdownText) {
    // Process inline single $...$ math expressions into clean readable unicode
    String cleanMarkdown = markdownText;
    if (cleanMarkdown.contains('\$')) {
      cleanMarkdown = cleanMarkdown.replaceAllMapped(
        RegExp(r'(?<!\$)\$(?!\$)(.*?)(?<!\$)\$(?!\$)'),
        (match) {
          final rawInline = match.group(1) ?? '';
          if (rawInline.trim().isEmpty) return match.group(0)!;
          final processed = MathFormulaProcessor.processLatex(rawInline);
          return '**$processed**';
        },
      );
    }

    return MarkdownBody(
      data: cleanMarkdown,
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
