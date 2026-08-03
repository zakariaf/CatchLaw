import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_panel.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_rule_facts_table.dart';
import 'package:flutter/material.dart';

/// Two instruments of equal standing, printed side by side, ranked by nothing.
///
/// **No stamp is struck here at all.** A stamp states one category, and there
/// is no one category: the refusal to choose IS the answer, and an advice
/// product would pick one. Silently resolving a genuine legal conflict is one
/// of the three things that void the carve-out outright.
///
/// Both plates take the same weight, the same styles and the same order the
/// pack recorded. A heavier plate, a first position earned by sorting, or a
/// primary-coloured action would each be a recommendation the wording refuses
/// to make.
class ResultAmbiguityBlock extends StatelessWidget {
  /// Prints [ambiguity].
  const ResultAmbiguityBlock({required this.ambiguity, super.key});

  /// The sentence and the conflicting rules, already localised.
  final AmbiguityDisplay ambiguity;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(ambiguity.sentence, style: type.subtitle, textAlign: TextAlign.start),
        const SizedBox(height: LonjaSpace.s3),
        for (final AmbiguousRuleDisplay rule in ambiguity.rules) ...<Widget>[
          LonjaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ResultRuleFactsTable(facts: rule.facts),
                const SizedBox(height: LonjaSpace.s2),
                Text(
                  // Each statement is a quotation, so each carries its own
                  // source: one citation covering both would assert that one
                  // instrument said two different things.
                  '${rule.citation.instrument}, ${rule.citation.article}'
                  ' · published ${rule.citation.publishedOn}'
                  ' · checked ${rule.citation.checkedOn}',
                  style: type.citation.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          const SizedBox(height: LonjaSpace.s3),
        ],
      ],
    );
  }
}
