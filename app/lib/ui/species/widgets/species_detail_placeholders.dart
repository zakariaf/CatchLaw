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
  const SpeciesVerdictSlot({
    this.display,
    this.jurisdiction = '',
    this.citationIds = const <int>[],
    this.sourceUrls = const <String?>[],
    this.onOpenRuleText,
    super.key,
  });

  /// The answer, already localised, or `null` before one has been asked for.
  ///
  /// Nullable because S2 is reached with a species and no reading — the fisher
  /// has picked a fish and not measured it — and because the evaluation that
  /// produces a `Resolution` is not wired to this screen yet. An empty slot is
  /// the honest rendering of both: nothing is stamped, and nothing is claimed.
  final ResultDisplay? display;

  /// The authority named in the footnote, already localised.
  final String jurisdiction;

  /// The `citation.id` behind each footnote, in footnote order.
  final List<int> citationIds;

  /// Each footnote's `source_url`, in the same order.
  final List<String?> sourceUrls;

  /// Opens the verbatim article. E12 owns the route; until then the caller
  /// supplies the destination and this widget holds no navigation knowledge.
  final void Function(int citationId, CitationDisplay citation)? onOpenRuleText;

  @override
  Widget build(BuildContext context) {
    final ResultDisplay? display = this.display;
    if (display == null) return const SizedBox.shrink();
    return ResultSection(
      display: display,
      jurisdiction: jurisdiction,
      citationIds: citationIds,
      sourceUrls: sourceUrls,
      onOpenRuleText: onOpenRuleText ?? (int _, CitationDisplay _) {},
    );
  }
}
