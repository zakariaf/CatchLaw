import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:flutter/services.dart';

/// The two patterns a verdict is felt as, through a wet glove.
///
/// `SPEC.md` §4.9 requires distinct patterns for pass and fail and gives no
/// numbers, so the pattern is fixed here: one light impact for a pass, two
/// heavy impacts 120 ms apart for anything adverse. **The distinction is count
/// and weight, not duration** — a single long buzz is indistinguishable from a
/// notification through a glove, which is the failure this exists to avoid.
///
/// A design choice rather than a measurement. E19 owns confirming it on a
/// device, and the epic's Risks say so.
abstract final class ResultHaptics {
  /// The gap between the two adverse impacts.
  static const Duration betweenImpacts = LonjaMotion.haptic;

  /// Announces [category] through the vibrator.
  ///
  /// Returns a `Future` the caller awaits rather than fires and forgets: the
  /// second impact is 120 ms after the first, and an un-awaited call that the
  /// widget outlives is a buzz arriving after the screen changed.
  ///
  /// Called from a `ref.listen` on the stamp and never from `build()`, because
  /// `build` runs on every relayout and the ruler relayouts several times a
  /// second.
  static Future<void> announce(VerdictCategory category) async {
    if (category == VerdictCategory.meets) {
      await HapticFeedback.lightImpact();
      return;
    }
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(betweenImpacts);
    await HapticFeedback.heavyImpact();
  }
}
