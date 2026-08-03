import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_section.dart';
import 'package:flutter/widgets.dart';

/// Where E09's ruler goes.
///
/// A **named, empty slot** rather than an absence. The page's shape is the one
/// that ships, so the epic that fills it does not also have to re-lay out
/// everything above and below — and a reviewer reading S2 can see that the
/// measurement was planned rather than forgotten.
class SpeciesMeasurementSlot extends StatelessWidget {
  /// Reserves the measurement row.
  const SpeciesMeasurementSlot({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Where E10's verdict goes.
///
/// Deliberately empty here. A verdict is a statement about a rule with a
/// citation under it, and inventing one on this page would put a legal sentence
/// outside `check_verdict_contract.sh`'s reach and freeze a design nobody has
/// reviewed.
class SpeciesVerdictSlot extends StatelessWidget {
  /// Draws [display], or reserves the space until there is one.
  const SpeciesVerdictSlot({this.display, super.key});

  /// The answer, already localised, or `null` before one has been asked for.
  ///
  /// Nullable because S2 is reached with a species and no reading — the fisher
  /// has picked a fish and not measured it — and because the evaluation that
  /// produces a `Resolution` is not wired to this screen yet. An empty slot is
  /// the honest rendering of both: nothing is stamped, and nothing is claimed.
  final ResultDisplay? display;

  @override
  Widget build(BuildContext context) {
    final ResultDisplay? display = this.display;
    return display == null ? const SizedBox.shrink() : ResultSection(display: display);
  }
}
