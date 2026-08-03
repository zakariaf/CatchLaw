import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:flutter/material.dart';

/// The numbers a finding rests on, as a ruled two-column sheet.
///
/// **The stamp states one line of this; the table is the whole picture.** A
/// closed-season stamp prints no size number, so this is where *Minimum — 45 cm
/// (total length)* is stated, and a reader who wants to know what else was
/// checked can see it without a tap.
///
/// A `Column` of private line widgets rather than a Material `DataTable`: the
/// table brings physical, non-directional padding, a fixed line height that
/// breaks at 200% text scale, and a horizontal-scroll behaviour a ruled sheet
/// does not want.
class ResultRuleFactsTable extends StatelessWidget {
  /// Renders [facts] in the order the presenter built them.
  const ResultRuleFactsTable({required this.facts, super.key});

  /// Label and value pairs, already localised and already formatted.
  final List<RuleFact> facts;

  @override
  Widget build(BuildContext context) {
    // Absent rather than empty: an empty ruled frame reads as content that
    // failed to load, which on this screen is a claim about the law.
    if (facts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final RuleFact fact in facts) ...<Widget>[
          const Divider(height: LonjaRules.rule),
          _FactLine(fact: fact),
        ],
      ],
    );
  }
}

/// One label, one value.
class _FactLine extends StatelessWidget {
  const _FactLine({required this.fact});

  final RuleFact fact;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              fact.label,
              style: type.eyebrow.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: LonjaSpace.s2),
          Expanded(
            flex: 2,
            child: Text(
              fact.value,
              // Tabular figures, from the ramp: 38 cm, 45 cm and 188 cm only
              // align on a decimal spine, and a column that does not align is
              // read at arm-length in sunlight as noise.
              style: type.datum.copyWith(
                color: fact.isOutcome ? tokens.verdictFail : tokens.onSurface,
                fontWeight: fact.isOutcome ? FontWeight.w600 : null,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
