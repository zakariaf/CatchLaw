import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_ambiguity_block.dart';
import 'package:catchlaw/ui/result/widgets/result_citation_footnote.dart';
import 'package:catchlaw/ui/result/widgets/result_disclaimer.dart';
import 'package:catchlaw/ui/result/widgets/result_findings_list.dart';
import 'package:catchlaw/ui/result/widgets/result_haptics.dart';
import 'package:catchlaw/ui/result/widgets/result_note.dart';
import 'package:catchlaw/ui/result/widgets/result_rule_facts_table.dart';
import 'package:catchlaw/ui/result/widgets/result_verdict_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// The result half of S2, in the one order it is ever drawn in.
///
/// The vertical order is fixed here rather than at each call site, because it
/// is the argument the screen makes: the stale bar states what is known about
/// the data before the answer, the stamp answers, the table shows the numbers
/// the answer rests on, and the citation and the disclaimer say who said so.
/// A screen that reorders that is a different argument.
///
/// Slots later tasks fill are **absent** from this tree rather than stubbed. A
/// placeholder is a thing a user can see, and a user seeing "coming soon" on a
/// legal screen learns that the screen is unfinished — which is a fact about
/// the project, not about the law.
class ResultSection extends StatefulWidget {
  /// Draws [display], footnoted for [jurisdiction].
  const ResultSection({
    required this.display,
    required this.jurisdiction,
    required this.onOpenRuleText,
    this.citationIds = const <int>[],
    this.sourceUrls = const <String?>[],
    super.key,
  });

  /// The answer, already localised.
  final ResultDisplay display;

  /// The authority that published the instruments, already localised.
  final String jurisdiction;

  /// The `citation.id` behind each footnote, in footnote order.
  ///
  /// Parallel to the footnotes rather than carried on `CitationDisplay`,
  /// because a display type that held a database id would put a storage detail
  /// on the value the presenter builds — and the presenter is the one thing on
  /// this screen that must stay pure over its inputs.
  final List<int> citationIds;

  /// The `source_url` of each footnote, in the same order. Nullable per §7.1.
  final List<String?> sourceUrls;

  /// Opens the bundled verbatim article for a citation id.
  final void Function(int citationId) onOpenRuleText;

  @override
  State<ResultSection> createState() => _ResultSectionState();
}

class _ResultSectionState extends State<ResultSection> {
  @override
  void initState() {
    super.initState();
    _announce(null, widget.display.stamp);
  }

  @override
  void didUpdateWidget(ResultSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _announce(oldWidget.display.stamp, widget.display.stamp);
  }

  /// Fires the haptic only when the stamp actually changed.
  ///
  /// Never from `build`: the ruler emits several times a second, and a buzz per
  /// relayout is a phone nobody can hold. Nothing fires for a display with no
  /// stamp — a buzz for "no rule recorded" would itself read as a verdict.
  ///
  /// Deferred to after the frame and awaited there, rather than abandoned with
  /// `unawaited`: the adverse pattern is two impacts 120 ms apart, and a
  /// lifecycle callback that awaited them inline would hold the frame the
  /// verdict is drawn on.
  void _announce(VerdictStampDisplay? was, VerdictStampDisplay? now) {
    if (now == null || was == now) return;
    SchedulerBinding.instance.addPostFrameCallback((Duration _) async {
      await ResultHaptics.announce(now.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ResultDisplay display = widget.display;
    final VerdictStampDisplay? stamp = display.stamp;
    // The numbers behind the answer, from the finding the stamp states. The
    // secondary findings carry their own facts, and T04's table is per finding
    // rather than per page — the slot below states the headline's.
    final List<RuleFact> headlineFacts = display.findings.isEmpty
        ? const <RuleFact>[]
        : display.findings.first.facts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (stamp != null) ResultVerdictPanel(stamp: stamp, citation: stamp.citation),
        // Both stand where the stamp would be struck rather than beneath it.
        // Exactly one of stamp, note and ambiguity is ever non-null, and each
        // of the three is the whole answer in its own state.
        if (display.note case final NoteDisplay note) ResultNote(note: note),
        if (display.ambiguity case final AmbiguityDisplay ambiguity)
          ResultAmbiguityBlock(ambiguity: ambiguity),
        if (display.secondary.isNotEmpty) const SizedBox(height: LonjaSpace.s5),
        ResultFindingsList(findings: display.secondary),
        if (headlineFacts.isNotEmpty) ...<Widget>[
          const SizedBox(height: LonjaSpace.s5),
          ResultRuleFactsTable(facts: headlineFacts),
        ],
        // The citation is the LAST block and is never behind a tap: printed
        // unconditionally, and additionally a button onto the verbatim text.
        for (final (int index, CitationDisplay citation) in _footnotes(
          display,
        ).indexed) ...<Widget>[
          const SizedBox(height: LonjaSpace.s5),
          ResultCitationFootnote(
            citation: citation,
            citationId: index < widget.citationIds.length ? widget.citationIds[index] : 0,
            jurisdiction: widget.jurisdiction,
            marker: index + 1,
            sourceUrl: index < widget.sourceUrls.length ? widget.sourceUrls[index] : null,
            // The pack provenance rides on the FIRST footnote only: it is one
            // fact about the bundle, and repeating it under every instrument
            // would read as several packs having lapsed.
            provenance: index == 0 ? display.stale?.provenance : null,
            onOpenRuleText: widget.onOpenRuleText,
          ),
        ],
        // Unconditional, and last. Not behind an `if`, not behind a flag, and
        // not behind a slot that a later task could leave empty: every one of
        // the nine result states ends here.
        const SizedBox(height: LonjaSpace.s5),
        ResultDisclaimer(authority: widget.jurisdiction),
      ],
    );
  }
}

/// The instruments behind [display], de-duplicated in first-appearance order.
///
/// The same order the presenter numbered the finding markers with, and derived
/// the same way — first appearance, no re-sorting — so a marker on a row and
/// the footnote it points at cannot come out in different orders.
List<CitationDisplay> _footnotes(ResultDisplay display) {
  final out = <CitationDisplay>[];
  for (final citation in <CitationDisplay>[
    for (final FindingDisplay finding in display.findings) finding.citation,
    ...?display.note?.citations,
    ...?display.ambiguity?.rules.map((AmbiguousRuleDisplay r) => r.citation),
  ]) {
    if (!out.contains(citation)) out.add(citation);
  }
  return out;
}
