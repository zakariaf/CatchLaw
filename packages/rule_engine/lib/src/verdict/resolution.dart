import 'package:meta/meta.dart';
import 'package:rule_engine/src/findings/finding.dart';
import 'package:rule_engine/src/findings/precedence.dart';
import 'package:rule_engine/src/models/citation.dart';
import 'package:rule_engine/src/models/rule.dart';

/// The whole answer for one fish, as numbers, enums and citations.
///
/// **No user-visible sentence lives here, in any language** (D-7). Everything in
/// this file and in `lib/src/findings/` is an integer, an enum, a bool or a
/// [Citation]; E06 and E10 turn those into words in six locales. A test asserts
/// the absence mechanically, because no shipped gate scans this package for
/// text — `check_verdict_contract.sh` reads `app/lib`.
///
/// Every arm carries a NON-EMPTY [citations] list. That is invariant 3 without a
/// nullable citation anywhere: an arm genuinely involving several instruments
/// answers with all of them, and an empty list would be the nullable citation
/// wearing a different type.
///
/// **There is no `unavailable` arm and no expiry arm.** An expired ruleset is
/// still evaluated and still shown (invariant 5); withholding is itself advice —
/// deciding the fisher is better off with nothing — and there is no network to
/// recover from. Expiry is a `bool` on [Finding], not a branch here.
///
/// **There is no `Meets` arm.** A fish that passes everything is a [Decided]
/// whose headline has `outcome == passes`. A separate arm would let a caller
/// switch on the arm instead of on the finding and lose the numbers, and
/// `catchlaw-verdict-contract` rule 3 requires the margin to be printed even
/// when the fish is legal.
@immutable
sealed class Resolution {
  const Resolution();

  /// Every instrument this answer rests on. Never empty.
  List<Citation> get citations;

  /// Whether any instrument behind this answer had lapsed on the evaluation
  /// date.
  bool get isExpired;
}

/// The instruments state something, and one finding headlines it.
final class Decided extends Resolution {
  /// Built by `evaluate` from [rankFindings]'s output.
  const Decided({required this.headline, required this.secondary});

  /// The one thing at the top of the screen.
  final Finding headline;

  /// Everything else, ranked — passes and open questions included.
  final List<Finding> secondary;

  /// The instrument the headline rests on.
  Citation get citation => headline.citation;

  @override
  List<Citation> get citations => <Citation>[
    headline.citation,
    for (final Finding f in secondary) f.citation,
  ];

  @override
  bool get isExpired => headline.isExpired || secondary.any((Finding f) => f.isExpired);
}

/// Two or more equally specific rules disagree, and the engine chooses neither.
///
/// The refusal is the answer. `SPEC.md` §5.1's third structural commitment is
/// stated as a contrast — *an advice product would pick one* — and
/// `the-five-part-carve-out.md` makes any silent resolution of a genuine legal
/// conflict one of the three things that void the carve-out outright.
final class Ambiguous extends Resolution {
  /// [rules] arrive in SOURCE order and are not re-sorted here or anywhere
  /// downstream.
  const Ambiguous({required this.rules, required this.isExpired});

  /// The conflicting rules, in source order, all of them.
  final List<Rule> rules;

  @override
  final bool isExpired;

  @override
  List<Citation> get citations => <Citation>[for (final Rule r in rules) r.citation];
}

/// The instrument was searched and positively records no limit.
///
/// Distinct from the absences E03/T11 handles: this is a CITED, POSITIVE
/// statement. In `SPEC.md` §7.1 a rule row with no size columns, no bag limit,
/// no vessel limit, `is_protected = 0` and no `closed_season` children is
/// exactly *an instrument that covers this species here and records no limit*,
/// so it needs no new column — only the citation of the rule that made it.
final class NoLimitInInstrument extends Resolution {
  /// [citation] is the rule that was searched and found silent.
  const NoLimitInInstrument({required this.citation, required this.isExpired});

  /// The instrument searched.
  final Citation citation;

  @override
  final bool isExpired;

  @override
  List<Citation> get citations => <Citation>[citation];
}
