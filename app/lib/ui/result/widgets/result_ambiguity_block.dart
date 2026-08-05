import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
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
/// Set as a gazette notice, in the one order it is ever drawn in: a tracked
/// eyebrow naming what the block is, the refusal sentence as the headline, the
/// heavy rule that closes a masthead, both instruments, and the note that says
/// what the app did with them. The eyebrow and the rule are what make the
/// sentence read as the head of a notice rather than as the first line of the
/// first instrument.
///
/// Both plates take the same weight, the same styles, the same rail and the
/// same order the pack recorded. A heavier plate, a first position earned by
/// sorting, or a primary-coloured action would each be a recommendation the
/// wording refuses to make.
class ResultAmbiguityBlock extends StatelessWidget {
  /// Prints [ambiguity].
  const ResultAmbiguityBlock({required this.ambiguity, super.key});

  /// The sentence and the conflicting rules, already localised.
  final AmbiguityDisplay ambiguity;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          // Cased at the call site, never in the ARB: the transform is a
          // silent no-op on Arabic, where the eyebrow's hierarchy comes from
          // weight and from the rule below it instead.
          l10n.ambiguityEyebrow.toUpperCase(), // lonja-type: ok
          style: type.eyebrow.copyWith(color: tokens.onSurfaceMuted),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: LonjaSpace.s2),
        Text(ambiguity.sentence, style: type.subtitle, textAlign: TextAlign.start),
        const SizedBox(height: LonjaSpace.s3),
        // The masthead rule. It closes the head, so the first instrument reads
        // as the first article under it rather than as more of the headline.
        const LonjaRule.section(),
        for (final AmbiguousRuleDisplay rule in ambiguity.rules) ...<Widget>[
          const SizedBox(height: LonjaSpace.s4),
          _AmbiguityInstrument(rule: rule),
        ],
        const SizedBox(height: LonjaSpace.s4),
        Text(
          l10n.ambiguityBothInForce,
          style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}

/// One instrument, marked by a rail and nothing else.
///
/// **A rail, not a frame.** Two framed panels are two boxes, and two boxes on a
/// page invite the reader to weigh one against the other; a rail marks where an
/// instrument starts without enclosing it, the way a marginal rule does in a
/// printed gazette. The rail draws from the same slot on every instrument in
/// the block — a second hue here would separate them by ranking them, and the
/// one warm slot this system has (`verdictWarn`) already means *the pack
/// lapsed*, which would be a false statement about one of the two.
class _AmbiguityInstrument extends StatelessWidget {
  const _AmbiguityInstrument({required this.rule});

  final AmbiguousRuleDisplay rule;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: tokens.accent, width: LonjaRules.strong),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: LonjaSpace.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ResultRuleFactsTable(facts: rule.facts),
            const SizedBox(height: LonjaSpace.s2),
            Text(
              // Each statement is a quotation, so each carries its own source:
              // one citation covering both would assert that one instrument
              // said two different things. All four fields, hanging off the
              // rail rather than boxed inside a panel with the numbers.
              '${rule.citation.instrument}, ${rule.citation.article}'
              ' · published ${rule.citation.publishedOn}'
              ' · checked ${rule.citation.checkedOn}',
              style: type.citation.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
