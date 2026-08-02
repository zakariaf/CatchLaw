import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart' show LonjaButtonVariant;
import 'package:flutter/material.dart';

/// The `ButtonStyle` for each rung.
///
/// **Authored in `lib/theme/` and not beside the widget, and the gates decide
/// that.** `check_lonja_tokens.sh` fails a `RoundedRectangleBorder` (check 4),
/// a numeric `EdgeInsets` (check 5), a literal stroke width (check 6), a
/// `fontSize:` (check 7) and a `Colors.` reference (check 1) anywhere outside
/// `/theme/` — and a `ButtonStyle` is made of exactly those constructs. So the
/// values and the shapes live here and the widget is a thin thing that names a
/// variant. D-2's rule of thumb: where prose and an executable gate disagree
/// about a path, the gate wins.
abstract final class LonjaButtonStyles {
  /// The style for [variant], resolved against the palette and ramp in scope.
  ///
  /// Every cell is a `WidgetStateProperty`, because a rung's disabled and
  /// pressed appearance is part of its definition rather than something a call
  /// site arranges.
  static ButtonStyle resolve({
    required LonjaTokens tokens,
    required LonjaTypeScale type,
    required LonjaButtonVariant variant,
  }) {
    final bool gloved = tokens.density.tapMin >= LonjaDensity.glove.tapMin;
    final TextStyle label = gloved ? type.uiLarge : type.ui;

    final Color field = switch (variant) {
      // The rungs are graded by FIELD, OUTLINE and RULE WEIGHT, never by hue —
      // because in greyscale harbour30 (L* 30.28) and oxblood28 (L* 27.96) are
      // 2.3 L* apart, which is visually the same box.
      LonjaButtonVariant.primary => tokens.accent,
      LonjaButtonVariant.secondary => const Color(0x00000000),
      LonjaButtonVariant.destructive => tokens.verdictFail,
    };
    final Color ink = switch (variant) {
      LonjaButtonVariant.primary || LonjaButtonVariant.destructive => tokens.onAccent,
      LonjaButtonVariant.secondary => tokens.onSurface,
    };
    final BorderSide side = switch (variant) {
      LonjaButtonVariant.primary => BorderSide(color: tokens.accent, width: LonjaRules.rule),
      LonjaButtonVariant.secondary => BorderSide(color: tokens.ruleBearing, width: LonjaRules.rule),
      // strong, not stamp: LonjaRules.stamp is the verdict frame's and nothing
      // else's (token-tables.md).
      LonjaButtonVariant.destructive => BorderSide(
        color: tokens.ruleBearing,
        width: LonjaRules.strong,
      ),
    };

    return ButtonStyle(
      backgroundColor: WidgetStatePropertyAll<Color>(field),
      foregroundColor: WidgetStatePropertyAll<Color>(ink),
      side: WidgetStatePropertyAll<BorderSide>(side),
      // Paper does not ripple and does not float.
      overlayColor: const WidgetStatePropertyAll<Color>(Color(0x00000000)),
      elevation: const WidgetStatePropertyAll<double>(0),
      shadowColor: const WidgetStatePropertyAll<Color>(Color(0x00000000)),
      splashFactory: NoSplash.splashFactory,
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: LonjaRadii.none),
      ),
      minimumSize: WidgetStatePropertyAll<Size>(Size.fromHeight(tokens.density.tapMin)),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsetsDirectional.symmetric(horizontal: LonjaSpace.s4),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle>(label),
    );
  }
}
