import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';

/// Ten digits and a delete, laid out as a keypad rather than as a paragraph of
/// buttons.
///
/// **A grid, because a keypad is a shape before it is a set of controls.** A
/// `Wrap` of ten tiles reflows with the text scale and the locale, so the key
/// under a thumb moves between two phones and between two settings — and a
/// fisher entering 450 with wet hands is typing by position, not by reading.
/// Three columns in the order 1-2-3 / 4-5-6 / 7-8-9 / delete-0 is the layout
/// every telephone and every till in the six countries this ships to already
/// uses.
///
/// **The digits are drawn by the locale's own formatter, never by a Latin
/// literal.** An Arabic reader who has asked for Arabic-Indic figures must find
/// `٤` on the key and `٤` in the readout above it; a keypad that shipped `4`
/// beside an Arabic total is the machine-translated register this app cannot
/// afford.
///
/// The keys are set in the mono ramp with tabular figures, so every key is the
/// same width of ink and the pad does not shimmer as the digits change.
class LonjaKeypad extends StatelessWidget {
  /// A pad that reports [onDigit] and [onBackspace].
  const LonjaKeypad({
    required this.onDigit,
    required this.onBackspace,
    required this.backspaceLabel,
    super.key,
  });

  /// Called with the digit pressed, 0 to 9.
  final ValueChanged<int> onDigit;

  /// Called when the last digit is to be removed.
  final VoidCallback onBackspace;

  /// The delete key's word, already localised.
  ///
  /// A word rather than a glyph: an arrow from an icon font is one missing
  /// family away from a tofu box on the one control that undoes a mistyped
  /// length.
  final String backspaceLabel;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final List<int?> row in const <List<int?>>[
          <int?>[1, 2, 3],
          <int?>[4, 5, 6],
          <int?>[7, 8, 9],
          <int?>[null, 0, null],
        ]) ...<Widget>[
          Row(
            children: <Widget>[
              for (var column = 0; column < row.length; column++) ...<Widget>[
                if (column > 0) SizedBox(width: tokens.density.tapGap),
                Expanded(
                  child: switch ((row[column], column)) {
                    (final int digit, _) => _DigitKey(digit: digit, onPressed: onDigit),
                    // The delete key takes the leading cell and the trailing
                    // cell stays empty, so the zero sits under the 8 where a
                    // thumb reaching for it expects to find it.
                    (null, 0) => _BackspaceKey(label: backspaceLabel, onPressed: onBackspace),
                    (null, _) => const SizedBox.shrink(),
                  },
                ),
              ],
            ],
          ),
          SizedBox(height: tokens.density.tapGap),
        ],
      ],
    );
  }
}

/// One digit.
class _DigitKey extends StatelessWidget {
  const _DigitKey({required this.digit, required this.onPressed});

  final int digit;

  final ValueChanged<int> onPressed;

  @override
  Widget build(BuildContext context) {
    final LonjaTypeScale type = LonjaType.of(context);
    // The one formatter the whole app uses, so a key and the readout above it
    // can never disagree about which digits to draw.
    final String glyph = numberFormatFor(Localizations.localeOf(context)).format(digit);

    return _Key(
      semanticLabel: glyph,
      onPressed: () => onPressed(digit),
      child: Text(glyph, style: type.measure, textAlign: TextAlign.center),
    );
  }
}

/// The delete key.
class _BackspaceKey extends StatelessWidget {
  const _BackspaceKey({required this.label, required this.onPressed});

  final String label;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return _Key(
      semanticLabel: label,
      onPressed: onPressed,
      child: Text(
        label,
        style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// The printed cell every key is struck on.
///
/// A widget class rather than a `Widget _buildKey()` helper: a helper has no
/// `BuildContext` of its own, so the `LonjaTokens.of(context)` inside it would
/// register the pad's element as the dependent and rebuild all eleven keys on a
/// theme change, a density toggle or an RTL flip (`FLUTTER_GUIDE.md` §8.1
/// mechanism 2).
class _Key extends StatelessWidget {
  const _Key({required this.child, required this.semanticLabel, required this.onPressed});

  final Widget child;

  final String semanticLabel;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Material(
          color: tokens.surface,
          shape: Border.all(color: tokens.ruleBearing, width: LonjaRules.rule),
          child: InkWell(
            onTap: onPressed,
            // Paper does not ripple. The press state is the field inverting
            // under the highlight, and nothing travels.
            splashFactory: NoSplash.splashFactory,
            child: SizedBox(
              height: tokens.density.rowHeight,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
