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
  /// Reserves the verdict panel.
  const SpeciesVerdictSlot({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
