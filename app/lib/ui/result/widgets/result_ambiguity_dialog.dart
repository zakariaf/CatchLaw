import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_ambiguity_block.dart';
import 'package:catchlaw/ui/result/widgets/result_disclaimer.dart';
import 'package:flutter/material.dart';

/// What the READER did about two instruments the app refused to rank.
///
/// A sealed type rather than a `bool?`, because the null path of a `bool?` is
/// exactly where a destructive default hides: a dialog torn down by the system
/// back button must not read as either instrument having been applied.
@immutable
sealed class AmbiguityChoice {
  const AmbiguityChoice();
}

/// The reader records which instrument he worked to.
///
/// This is a record of HIS decision, not the app's. Nothing here makes the
/// other rule less applicable, and nothing is recomputed from it.
final class AppliedInstrument extends AmbiguityChoice {
  /// Names the instrument by its lineage id.
  const AppliedInstrument(this.instrumentId);

  /// The `citation.lineage_id` of the instrument he applied.
  final String instrumentId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppliedInstrument && other.instrumentId == instrumentId;

  @override
  int get hashCode => instrumentId.hashCode;
}

/// The reader records both, and picks neither.
///
/// A first-class outcome and not a cancel: "both of these apply and I am not
/// resolving it here" is the honest state, and the one the app itself is in.
final class DeferredToBoth extends AmbiguityChoice {
  /// Defers.
  const DeferredToBoth();

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeferredToBoth;

  @override
  int get hashCode => 0;
}

/// Asks the reader which instrument he applied, and offers not to choose.
///
/// `barrierDismissible: false`, no autofocus and no primary styling: a stray
/// barrier tap must not resolve a legally weighted question, and an autofocused
/// or accented action is a default — which is a recommendation, which is the
/// one thing this dialog exists not to make.
Future<AmbiguityChoice> showResultAmbiguityDialog(
  BuildContext context, {
  required AmbiguityDisplay ambiguity,
  required String deferLabel,
  required String authority,
}) async {
  // Captured before the route opens and restored after it pops, so a keyboard
  // or switch user lands back where they were.
  final FocusNode? restoreTo = FocusManager.instance.primaryFocus;

  final AmbiguityChoice? answer = await showDialog<AmbiguityChoice>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) =>
        ResultAmbiguityDialog(ambiguity: ambiguity, deferLabel: deferLabel, authority: authority),
  );

  restoreTo?.requestFocus();
  // A null result is a pop nobody chose — the system back button, or a route
  // torn down underneath us. It writes nothing and decides nothing.
  return answer ?? const DeferredToBoth();
}

/// The dialog body, exposed so a test can pump it without a route.
///
/// **One ruled sheet, in one order, top to bottom:** the notice — eyebrow,
/// headline, masthead rule, both instruments, the closing note — then the
/// standing disclaimer, then the actions. Nothing is printed twice: the refusal
/// sentence is the headline and appears once, and the actions sit at the foot
/// under everything they act on rather than above the last block of text.
///
/// The frame is the dialog's own. A `LonjaPanel` inside it would read as a
/// panel inside a sheet — two borders, two paddings and two grounds where a
/// printed notice has one of each.
class ResultAmbiguityDialog extends StatelessWidget {
  /// Prints [ambiguity] and one action per rule, plus [deferLabel].
  const ResultAmbiguityDialog({
    required this.ambiguity,
    required this.deferLabel,
    required this.authority,
    super.key,
  });

  /// The conflicting rules, in source order.
  final AmbiguityDisplay ambiguity;

  /// The wording of the defer action, already localised.
  final String deferLabel;

  /// The authority the disclaimer names, already localised.
  ///
  /// Required, and with no default: the disclaimer is unconditional on the
  /// result surface and a modal that covers the result surface is the one place
  /// it must not quietly go missing.
  final String authority;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // One padding system. The gutter is the sheet's, and every block inside
      // sets its own vertical rhythm from LonjaSpace.
      contentPadding: const EdgeInsetsDirectional.all(LonjaSpace.s4),
      // Kept, and not a divergence to fix: the notice runs to two instruments,
      // a note and a disclaimer, and at 200% text scale it is taller than any
      // phone. Legal prose wraps and the sheet scrolls; it never truncates.
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ResultAmbiguityBlock(ambiguity: ambiguity),
            const SizedBox(height: LonjaSpace.s5),
            ResultDisclaimer(authority: authority),
            const SizedBox(height: LonjaSpace.s5),
            // One action per rule and one to defer, all on the same rung:
            // N + 1 equal-weight actions, because a primary among them would
            // rank the instruments the headline above refuses to rank.
            for (final AmbiguousRuleDisplay rule in ambiguity.rules) ...<Widget>[
              LonjaButton.secondary(
                key: Key('ambiguity-choice-${rule.instrumentId}'),
                label: rule.citation.instrument,
                onPressed: () => Navigator.of(context).pop(AppliedInstrument(rule.instrumentId)),
              ),
              const SizedBox(height: LonjaSpace.s2),
            ],
            LonjaButton.secondary(
              key: const Key('ambiguity-defer'),
              label: deferLabel,
              onPressed: () => Navigator.of(context).pop(const DeferredToBoth()),
            ),
          ],
        ),
      ),
    );
  }
}
