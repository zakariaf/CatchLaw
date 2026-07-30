// Demonstrates the Lonja search field as a printed entry line: BorderRadius.zero over a 1.5px ink
// rule, serif value text above an italic ink-faint hint that carries no meaning, a glove-aware
// 60/72 logical-pixel minimum height read from LonjaTargets, a mono tabular-figure result count,
// and an input path that never rewrites the user's script — هامور, Sha'ri and Ameixa babosa all
// pass through byte-identical.
// Form, GlobalKey<FormState>, validators, focus traversal and TextInputFormatter policy are owned
// by forms-and-input and are deliberately absent; the controller is disposed only so the widget
// does not leak.
// LonjaTokens is inlined here for one self-contained file. In the app tree it lives in
// lib/theme/lonja_tokens.dart as a ThemeExtension owned by lonja-design-tokens.
// Conceptually compiles against flutter.

import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

/// Fixed hit-target values. NEVER inline these numbers at a call site.
abstract final class LonjaTargets {
  static const double control = 56;
  static const double gloveControl = 66;
  static const double searchField = 60;
  static const double gloveSearchField = 72;
  static const double separation = 8;
}

/// The subset of the Lonja token extension this control reads.
@immutable
class LonjaTokens extends ThemeExtension<LonjaTokens> {
  const LonjaTokens({
    required this.paperSunk,
    required this.ink,
    required this.inkFaint,
    required this.rule,
    required this.glove,
  });

  final Color paperSunk; // #DEDBD1 paper · #FFFFFF sunlight
  final Color ink; // #16201C paper · #000000 sunlight
  final Color inkFaint; // #6C7871 paper · #000000 sunlight (grey deleted)
  final Color rule; // #C2C5BB paper · #000000 sunlight
  final bool glove; // orthogonal density switch, not a theme

  static LonjaTokens of(BuildContext context) {
    final tokens = Theme.of(context).extension<LonjaTokens>();
    assert(tokens != null, 'LonjaTokens missing — attach it to every ThemeData.');
    return tokens!;
  }

  // copyWith and lerp are elided here — their contract is owned by lonja-design-tokens.
  @override
  LonjaTokens copyWith() => this;

  @override
  LonjaTokens lerp(ThemeExtension<LonjaTokens>? other, double t) =>
      other is LonjaTokens && t >= 0.5 ? other : this;
}

/// The species search field: a ruled entry line, never a filled rounded box.
class LonjaSearchField extends StatefulWidget {
  const LonjaSearchField({
    required this.onQueryChanged,
    required this.matchCount,
    required this.totalCount,
    super.key,
  });

  /// Receives the raw text. Diacritic folding and Arabic normalisation happen
  /// downstream in catchlaw-rule-engine — NEVER on the controller's text.
  final ValueChanged<String> onQueryChanged;
  final int matchCount;
  final int totalCount;

  @override
  State<LonjaSearchField> createState() => _LonjaSearchFieldState();
}

class _LonjaSearchFieldState extends State<LonjaSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = LonjaTokens.of(context);
    final height = t.glove ? LonjaTargets.gloveSearchField : LonjaTargets.searchField;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Persistent label — survives input, unlike the hint.
        Text(
          'SPECIES',
          style: TextStyle(
            fontFamilyFallback: const ['ui-sans-serif', 'Helvetica Neue', 'Roboto'],
            fontSize: 9.5,
            letterSpacing: 0.2 * 9.5,
            fontWeight: FontWeight.w600,
            color: t.inkFaint,
          ),
        ),
        const SizedBox(height: LonjaTargets.separation),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.paperSunk,
              // BorderRadius.zero: paper has no pills. No BoxShadow — the document is flat.
              border: Border.all(color: t.ink, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(Icons.search, size: 22, color: t.ink),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField( // lonja-core-ok — this file IS lib/ui/core.
                      controller: _controller,
                      onChanged: widget.onQueryChanged,
                      keyboardType: TextInputType.text,
                      // No capitalisation, no formatter: the field must not fight the script.
                      textCapitalization: TextCapitalization.none,
                      maxLines: 1,
                      style: TextStyle(fontFamily: 'Iowan Old Style', fontSize: 19, color: t.ink),
                      decoration: InputDecoration.collapsed(
                        // The hint only ILLUSTRATES. It carries no label, no unit, no method.
                        hintText: 'Search species — هامور, Hamour, grouper',
                        hintStyle: TextStyle(
                          fontFamily: 'Iowan Old Style',
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                          color: t.inkFaint,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: LonjaTargets.separation),
        // Local drift read: a count, never a spinner. There is no network to wait for.
        Text(
          '${widget.matchCount} of ${widget.totalCount}',
          style: TextStyle(
            fontFamily: 'SF Mono',
            fontSize: 11,
            color: t.inkFaint,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
