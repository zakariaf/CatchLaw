import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:flutter/material.dart';
import 'package:rule_engine/rule_engine.dart' show FindingOutcome;

/// Every rule that fired and is not already on the stamp.
///
/// **The stamp states one thing; the page states everything.** A closed-season
/// stamp still prints the size rule beneath it, satisfied, so the fisher sees
/// the whole picture without the stamp equivocating — and so a page carrying
/// one closure cannot be mistaken for a page where no size rule was ever
/// transcribed.
///
/// **The order arrives correct and is never touched.** Precedence is fixed,
/// total and applied exactly once, in the engine. A `sort` here would be a
/// second opinion about legal precedence held in the layer with the weakest
/// tests, so this file contains none — nor a `where` that drops a finding.
class ResultFindingsList extends StatelessWidget {
  /// Renders [findings] in the order they arrive.
  const ResultFindingsList({required this.findings, super.key});

  /// The secondary findings, ranked by the engine.
  final List<FindingDisplay> findings;

  @override
  Widget build(BuildContext context) {
    // Absent rather than empty: a ruled block with nothing in it reads as
    // content that failed to load.
    if (findings.isEmpty) return const SizedBox.shrink();

    // A Column and not a builder: the list is bounded by the six FindingKinds,
    // so there is nothing to virtualise, and a builder inside the scrolling
    // section buys a nested viewport for zero rows saved.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final FindingDisplay finding in findings) _FindingLine(finding: finding),
      ],
    );
  }
}

/// One rule, its outcome, and the instrument it comes from.
///
/// `_FindingLine` rather than the `_FindingRow` E10/T03 names, because
/// `layering_test.dart` bans every `*Row` identifier outside `lib/data`: drift
/// names its generated row classes that way, and a boundary that has to tell a
/// real one from a lookalike is not a boundary. The same rename `RuleFact`
/// took in T01.
class _FindingLine extends StatelessWidget {
  const _FindingLine({required this.finding});

  final FindingDisplay finding;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    // Three channels on every row: a glyph, the words of the sentence itself,
    // and the ink. A coloured dot alone is one channel, and it is the one that
    // survives neither greyscale nor eight percent of the men reading this.
    final (LonjaGlyph glyph, Color ink) = switch (finding.outcome) {
      FindingOutcome.passes => (LonjaIcons.tick, tokens.verdictPass),
      FindingOutcome.fails => (LonjaIcons.cross, tokens.verdictFail),
      // Muted, and never verdant: an open question printed as a pass states
      // that a rule was checked when nothing was.
      FindingOutcome.indeterminate => (LonjaIcons.openQuestion, tokens.onSurfaceMuted),
    };

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: LonjaSpace.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // The marker walks the reader from this row to its footnote without a
          // tap, which is the difference between an assertion and a quotation.
          Padding(
            padding: const EdgeInsetsDirectional.only(end: LonjaSpace.s1),
            child: Text(
              '${finding.citationIndex}',
              style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
          ExcludeSemantics(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: LonjaSpace.s2),
              child: LonjaIcon(glyph, size: LonjaIconSize.caption, color: ink),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  finding.sentence,
                  style: type.legal.copyWith(color: ink),
                  textAlign: TextAlign.start,
                ),
                Text(
                  '${finding.citation.instrument} · ${finding.citation.article}',
                  style: type.citation.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
