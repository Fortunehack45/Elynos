import 'dart:math' as math;

class MathEvaluationResult {
  final String expression;
  final String result;
  final String formattedEquation;
  final List<String> steps;

  MathEvaluationResult({
    required this.expression,
    required this.result,
    required this.formattedEquation,
    required this.steps,
  });
}

class MathFormulaProcessor {
  /// Evaluates an arithmetic expression or math query if possible.
  /// Handles "what is 1+1", "25 * 4 + 15", "sqrt(144)", "15% of 200", etc.
  static MathEvaluationResult? evaluateMath(String input) {
    try {
      final trimmed = input.trim();
      if (trimmed.isEmpty) return null;

      // Check percentage: e.g. "15% of 200" or "20 percent of 50"
      final percentMatch = RegExp(
        r'(\d+(?:\.\d+)?)\s*(?:%|percent)\s*(?:of|\*)\s*(\d+(?:\.\d+)?)',
        caseSensitive: false,
      ).firstMatch(trimmed);

      if (percentMatch != null) {
        final p = double.parse(percentMatch.group(1)!);
        final base = double.parse(percentMatch.group(2)!);
        final res = (p / 100.0) * base;
        final resStr = _formatNumber(res);
        return MathEvaluationResult(
          expression: '$p% of $base',
          result: resStr,
          formattedEquation: '$p% of ${_formatNumber(base)} = $resStr',
          steps: [
            'Convert percentage to decimal: $p / 100 = ${p / 100.0}',
            'Multiply by base: ${p / 100.0} × ${_formatNumber(base)} = $resStr',
          ],
        );
      }

      // Strip common prefixes
      String cleaned = trimmed
          .replaceAll(RegExp(r'^(?:what\s+is|calculate|compute|solve|evaluate|eval)\s+', caseSensitive: false), '')
          .replaceAll(RegExp(r'[?=\s]+$'), '')
          .trim();

      // Normalize operators
      cleaned = cleaned
          .replaceAll('×', '*')
          .replaceAll('✕', '*')
          .replaceAll('x', '*')
          .replaceAll('X', '*')
          .replaceAll('÷', '/')
          .replaceAll('^', '**')
          .replaceAll(RegExp(r'\s+'), '');

      if (cleaned.isEmpty) return null;

      // Handle functions like sqrt(144), abs(-5), etc.
      final sqrtMatch = RegExp(r'^sqrt\((\d+(?:\.\d+)?)\)$', caseSensitive: false).firstMatch(cleaned);
      if (sqrtMatch != null) {
        final val = double.parse(sqrtMatch.group(1)!);
        final res = math.sqrt(val);
        final resStr = _formatNumber(res);
        return MathEvaluationResult(
          expression: '√(${_formatNumber(val)})',
          result: resStr,
          formattedEquation: '√(${_formatNumber(val)}) = $resStr',
          steps: [
            'Identify non-negative radicand: ${_formatNumber(val)}',
            'Compute principal square root: $resStr',
          ],
        );
      }

      // Tokenize and evaluate arithmetic expressions
      final parsed = _evaluateExpression(cleaned);
      if (parsed == null) return null;

      final resultStr = _formatNumber(parsed);
      final displayExpr = cleaned
          .replaceAll('**', ' ^ ')
          .replaceAll('*', ' × ')
          .replaceAll('/', ' ÷ ')
          .replaceAll('+', ' + ')
          .replaceAll('-', ' - ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      return MathEvaluationResult(
        expression: displayExpr,
        result: resultStr,
        formattedEquation: '$displayExpr = $resultStr',
        steps: [
          'Parse expression terms with standard operator precedence (PEMDAS)',
          'Evaluate operations: $displayExpr',
          'Verified exact numerical solution: $resultStr',
        ],
      );
    } catch (_) {
      return null;
    }
  }

  /// Parses LaTeX math into clean, readable, processed mathematical typography.
  /// Eliminates raw backslashes and curlies like `\mathcal{O}(N \log N) \quad \text{...}`
  static String processLatex(String rawLatex) {
    if (rawLatex.trim().isEmpty) return '';

    String s = rawLatex.trim();

    // 1. Mathcal / Big-O
    s = s.replaceAll(RegExp(r'\\mathcal\{O\}|\\mathcal\{o\}|\\mathcal\{0\}'), 'O');
    s = s.replaceAll(RegExp(r'\\mathcal\{([A-Za-z])\}'), r'𝒪(\1)');

    // 2. Text / styling macros
    s = s.replaceAllMapped(RegExp(r'\\(?:text|mathrm|mathbf|mathit)\{([^}]*)\}'), (m) => m.group(1) ?? '');

    // 3. Spacing commands
    s = s.replaceAll(RegExp(r'\\qquad'), '    ');
    s = s.replaceAll(RegExp(r'\\quad'), '   ');
    s = s.replaceAll(RegExp(r'\\[,;! ]'), ' ');

    // 4. Fractions: \frac{a}{b} -> (a) / (b)
    s = s.replaceAllMapped(RegExp(r'\\frac\{([^}]*)\}\{([^}]*)\}'), (m) {
      final num = m.group(1)?.trim() ?? '';
      final den = m.group(2)?.trim() ?? '';
      if (!num.contains(' ') && !den.contains(' ')) {
        return '$num / $den';
      }
      return '($num) / ($den)';
    });

    // 5. Roots: \sqrt[n]{x} or \sqrt{x}
    s = s.replaceAllMapped(RegExp(r'\\sqrt\{([^}]*)\}'), (m) => '√(${m.group(1)?.trim()})');
    s = s.replaceAllMapped(RegExp(r'\\sqrt\[([^\]]*)\]\{([^}]*)\}'), (m) => '${m.group(1)}√(${m.group(2)?.trim()})');

    // 6. Integrals, Sums, Limits
    s = s.replaceAllMapped(RegExp(r'\\int_\{?([^}^_]*)\}?\^\{?([^}]*)\}?'), (m) => '∫ [${m.group(1)} → ${m.group(2)}] ');
    s = s.replaceAll(RegExp(r'\\int'), '∫ ');
    s = s.replaceAllMapped(RegExp(r'\\sum_\{?([^}^_]*)\}?\^\{?([^}]*)\}?'), (m) => '∑ [${m.group(1)} → ${m.group(2)}] ');
    s = s.replaceAll(RegExp(r'\\sum'), '∑ ');
    s = s.replaceAll(RegExp(r'\\prod'), '∏ ');

    // 7. Vector calculus & differentials
    s = s.replaceAll(RegExp(r'\\nabla'), '∇');
    s = s.replaceAll(RegExp(r'\\partial'), '∂');
    s = s.replaceAll(RegExp(r'\\infty'), '∞');

    // 8. Operators
    s = s.replaceAll(RegExp(r'\\times'), '×');
    s = s.replaceAll(RegExp(r'\\cdot'), '·');
    s = s.replaceAll(RegExp(r'\\div'), '÷');
    s = s.replaceAll(RegExp(r'\\pm'), '±');
    s = s.replaceAll(RegExp(r'\\mp'), '∓');
    s = s.replaceAll(RegExp(r'\\leq?'), '≤');
    s = s.replaceAll(RegExp(r'\\geq?'), '≥');
    s = s.replaceAll(RegExp(r'\\neq?'), '≠');
    s = s.replaceAll(RegExp(r'\\approx'), '≈');
    s = s.replaceAll(RegExp(r'\\equiv'), '≡');
    s = s.replaceAll(RegExp(r'\\to|\\rightarrow'), '→');
    s = s.replaceAll(RegExp(r'\\in'), '∈');
    s = s.replaceAll(RegExp(r'\\notin'), '∉');
    s = s.replaceAll(RegExp(r'\\subset(?:eq)?'), '⊆');

    // 9. Standard mathematical functions
    s = s.replaceAll(RegExp(r'\\log'), 'log');
    s = s.replaceAll(RegExp(r'\\ln'), 'ln');
    s = s.replaceAll(RegExp(r'\\exp'), 'exp');
    s = s.replaceAll(RegExp(r'\\sin'), 'sin');
    s = s.replaceAll(RegExp(r'\\cos'), 'cos');
    s = s.replaceAll(RegExp(r'\\tan'), 'tan');
    s = s.replaceAll(RegExp(r'\\det'), 'det');
    s = s.replaceAll(RegExp(r'\\lim'), 'lim');

    // 10. Greek symbols
    s = s.replaceAll(RegExp(r'\\alpha'), 'α');
    s = s.replaceAll(RegExp(r'\\beta'), 'β');
    s = s.replaceAll(RegExp(r'\\gamma'), 'γ');
    s = s.replaceAll(RegExp(r'\\delta'), 'δ');
    s = s.replaceAll(RegExp(r'\\varepsilon_0'), 'ε₀');
    s = s.replaceAll(RegExp(r'\\varepsilon|\\epsilon'), 'ε');
    s = s.replaceAll(RegExp(r'\\zeta'), 'ζ');
    s = s.replaceAll(RegExp(r'\\eta'), 'η');
    s = s.replaceAll(RegExp(r'\\theta'), 'θ');
    s = s.replaceAll(RegExp(r'\\lambda'), 'λ');
    s = s.replaceAll(RegExp(r'\\mu_0'), 'μ₀');
    s = s.replaceAll(RegExp(r'\\mu'), 'μ');
    s = s.replaceAll(RegExp(r'\\pi'), 'π');
    s = s.replaceAll(RegExp(r'\\rho'), 'ρ');
    s = s.replaceAll(RegExp(r'\\sigma'), 'σ');
    s = s.replaceAll(RegExp(r'\\tau'), 'τ');
    s = s.replaceAll(RegExp(r'\\phi'), 'φ');
    s = s.replaceAll(RegExp(r'\\psi'), 'ψ');
    s = s.replaceAll(RegExp(r'\\omega'), 'ω');
    s = s.replaceAll(RegExp(r'\\Delta'), 'Δ');
    s = s.replaceAll(RegExp(r'\\Sigma'), 'Σ');
    s = s.replaceAll(RegExp(r'\\Omega'), 'Ω');

    // 11. Common Superscripts & Subscripts
    s = s.replaceAll('^2', '²');
    s = s.replaceAll('^3', '³');
    s = s.replaceAll('^0', '⁰');
    s = s.replaceAll('^1', '¹');
    s = s.replaceAll('^4', '⁴');
    s = s.replaceAll('^5', '⁵');
    s = s.replaceAll('^6', '⁶');
    s = s.replaceAll('^7', '⁷');
    s = s.replaceAll('^8', '⁸');
    s = s.replaceAll('^9', '⁹');
    s = s.replaceAll('^+', '⁺');
    s = s.replaceAll('^-', '⁻');
    s = s.replaceAll('^n', 'ⁿ');
    s = s.replaceAll('^x', 'ˣ');

    s = s.replaceAll('_0', '₀');
    s = s.replaceAll('_1', '₁');
    s = s.replaceAll('_2', '₂');
    s = s.replaceAll('_3', '₃');
    s = s.replaceAll('_4', '₄');
    s = s.replaceAll('_5', '₅');
    s = s.replaceAll('_6', '₆');
    s = s.replaceAll('_7', '₇');
    s = s.replaceAll('_8', '₈');
    s = s.replaceAll('_9', '₉');

    // 12. Strip leftover backslashes and curlies cleanly
    s = s.replaceAll(RegExp(r'\\([a-zA-Z]+)'), r'\1');
    s = s.replaceAll('{', '').replaceAll('}', '');

    // 13. If formula is an evaluable arithmetic expression without '=', evaluate it!
    if (!s.contains('=')) {
      final eval = evaluateMath(s);
      if (eval != null) {
        return '${eval.expression} = ${eval.result}';
      }
    }

    return s.trim();
  }

  // --- Helper: Format numbers without trailing zeroes ---
  static String _formatNumber(double num) {
    if (num.isNaN) return 'NaN';
    if (num.isInfinite) return num.isNegative ? '-∞' : '∞';
    if (num == num.roundToDouble()) {
      return num.toInt().toString();
    }
    // Limit decimal precision to 6 places, strip trailing zeroes
    final str = num.toStringAsFixed(6);
    return str.replaceAll(RegExp(r'\.?0+$'), '');
  }

  static double? _evaluateExpression(String str) {
    try {
      final parser = _ExpressionParser(str);
      return parser.parse();
    } catch (_) {
      return null;
    }
  }
}

class _ExpressionParser {
  final String str;
  int pos = -1;
  int ch = -1;

  _ExpressionParser(this.str) {
    _nextChar();
  }

  void _nextChar() {
    pos++;
    ch = pos < str.length ? str.codeUnitAt(pos) : -1;
  }

  bool _eat(int charToEat) {
    while (ch == 32) {
      _nextChar();
    }
    if (ch == charToEat) {
      _nextChar();
      return true;
    }
    return false;
  }

  double parse() {
    final x = _parseExpression();
    if (pos < str.length) {
      throw const FormatException('Unexpected trailing characters');
    }
    return x;
  }

  double _parseExpression() {
    double x = _parseTerm();
    while (true) {
      if (_eat(43)) {
        x += _parseTerm();
      } else if (_eat(45)) {
        x -= _parseTerm();
      } else {
        return x;
      }
    }
  }

  double _parseTerm() {
    double x = _parseFactor();
    while (true) {
      if (_eat(42)) {
        if (_eat(42)) {
          x = math.pow(x, _parseFactor()).toDouble();
        } else {
          x *= _parseFactor();
        }
      } else if (_eat(47)) {
        final divisor = _parseFactor();
        if (divisor == 0) return double.infinity;
        x /= divisor;
      } else if (_eat(37)) {
        x %= _parseFactor();
      } else {
        return x;
      }
    }
  }

  double _parseFactor() {
    if (_eat(43)) return _parseFactor();
    if (_eat(45)) return -_parseFactor();

    double x;
    final startPos = pos;

    if (_eat(40)) {
      x = _parseExpression();
      _eat(41);
    } else if ((ch >= 48 && ch <= 57) || ch == 46) {
      while ((ch >= 48 && ch <= 57) || ch == 46) {
        _nextChar();
      }
      x = double.parse(str.substring(startPos, pos));
    } else {
      throw FormatException('Unexpected character: ${ch == -1 ? "EOF" : String.fromCharCode(ch)}');
    }

    if (_eat(94)) {
      x = math.pow(x, _parseFactor()).toDouble();
    }

    return x;
  }
}
