import 'package:catchlaw/theme/lonja_button_style.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';

/// The three rungs of the action ladder.
///
/// **Graded by field, outline and rule weight — never by hue.** Primary is the
/// only *filled* box; secondary is the only *outlined* box; destructive is
/// filled and framed at [LonjaRules.strong]. That grading survives the two
/// places hue does not: sunlight, where `accent` collapses to `black00` and
/// only the verdict pigments keep a colour, and greyscale, where the primary
/// field (`harbour30`, L\* 30.28) and the destructive field (`oxblood28`,
/// L\* 27.96) are **2.3 L\* apart** — visually the same box.
enum LonjaButtonVariant {
  /// One per screen. The only filled box at [LonjaRules.rule].
  primary,

  /// The only outlined box.
  secondary,

  /// Filled and framed at [LonjaRules.strong]. Always confirms.
  destructive,
}

/// One rung of the ladder.
///
/// A widget class and never a `Widget _buildButton()` helper: a helper has no
/// `BuildContext` of its own, so a `LonjaTokens.of(context)` inside it
/// registers the **caller's** element as the dependent and the whole screen
/// rebuilds on a theme change, a density toggle, a locale change or an RTL flip
/// (`FLUTTER_GUIDE.md` §8.1 mechanism 2).
class LonjaButton extends StatelessWidget {
  const LonjaButton._({
    required this.label,
    required this.onPressed,
    required this.variant,
    this.leading,
    this.busy = false,
    this.disabledReason,
    this.onConfirmed,
    super.key,
  });

  /// The one primary action on a screen.
  const LonjaButton.primary({
    required String label,
    required VoidCallback? onPressed,
    Widget? leading,
    bool busy = false,
    String? disabledReason,
    Key? key,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: LonjaButtonVariant.primary,
         leading: leading,
         busy: busy,
         disabledReason: disabledReason,
         key: key,
       );

  /// Everything else.
  const LonjaButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    Widget? leading,
    bool busy = false,
    String? disabledReason,
    Key? key,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: LonjaButtonVariant.secondary,
         leading: leading,
         busy: busy,
         disabledReason: disabledReason,
         key: key,
       );

  /// Deletes or replaces something. **Always confirms.**
  ///
  /// [onConfirmed] runs only after a confirmation returns
  /// `LonjaConfirmOutcome.confirmed`; there is no `onPressed`, so a call site
  /// physically cannot wire a destructive action straight to a handler.
  const LonjaButton.destructive({
    required String label,
    required Future<void> Function() onConfirmed,
    Widget? leading,
    bool busy = false,
    String? disabledReason,
    Key? key,
  }) : this._(
         label: label,
         onPressed: null,
         variant: LonjaButtonVariant.destructive,
         leading: leading,
         busy: busy,
         disabledReason: disabledReason,
         onConfirmed: onConfirmed,
         key: key,
       );

  /// Already localised. This widget never reaches for an ARB key.
  final String label;

  /// `null` disables the rung.
  final VoidCallback? onPressed;

  /// Which rung.
  final LonjaButtonVariant variant;

  /// A leading glyph slot, empty until the icon family lands.
  ///
  /// E07 ships no icon. `lonja-icons-and-plates` rule 1 bans the Material icon
  /// namespace outright, its per-theme stroke width has no row in
  /// `token-tables.md` yet, and no epic owns the authored family — E08 is its
  /// first consumer.
  final Widget? leading;

  /// Latched by the caller while the action runs.
  final bool busy;

  /// Why the rung is disabled, for the semantics layer.
  ///
  /// A disabled control with no stated reason is a dead end: the fisher taps,
  /// nothing happens, and there is nothing on screen that says why.
  final String? disabledReason;

  /// Runs after a confirmation is confirmed. Destructive only.
  final Future<void> Function()? onConfirmed;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final bool enabled = !busy && (onPressed != null || onConfirmed != null);

    return Semantics(
      button: true,
      enabled: enabled,
      hint: enabled ? null : disabledReason,
      child: ConstrainedBox(
        // The ACTION class, not the generic floor: a full-width box aimed at
        // without looking is 66 dp in glove mode, where a chip is 56.
        constraints: BoxConstraints(minHeight: tokens.density.actionHeight),
        child: TextButton(
          onPressed: enabled ? (onPressed ?? () => onConfirmed!()) : null,
          style: LonjaButtonStyles.resolve(tokens: tokens, type: type, variant: variant),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (leading != null) ...<Widget>[leading!, const SizedBox(width: LonjaSpace.s2)],
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
