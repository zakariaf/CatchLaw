import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_findings_list.dart';
import 'package:catchlaw/ui/result/widgets/result_haptics.dart';
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
  /// Draws [display].
  const ResultSection({required this.display, super.key});

  /// The answer, already localised.
  final ResultDisplay display;

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
        if (display.secondary.isNotEmpty) const SizedBox(height: LonjaSpace.s5),
        ResultFindingsList(findings: display.secondary),
        if (headlineFacts.isNotEmpty) ...<Widget>[
          const SizedBox(height: LonjaSpace.s5),
          ResultRuleFactsTable(facts: headlineFacts),
        ],
      ],
    );
  }
}
