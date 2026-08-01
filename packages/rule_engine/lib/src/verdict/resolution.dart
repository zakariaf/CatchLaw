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

/// The species is in the reference database, and no rule row covers it here.
///
/// **This does not mean it is legal.** The wording is
/// `catchlaw-verdict-contract` rule 7's, fixed in all six locales, never
/// softened into a reassurance and never an empty screen — but D-7 puts
/// every one of those words in E06's ARB files, so this type's contribution is
/// narrower and more durable: **there is no way to reach a permissive outcome
/// from an absence.** [Decided] requires a headline [Finding], a [Finding]
/// requires a rule to have been found, and this arm cannot produce one. The
/// `findings.isEmpty ? meets` shape is not merely avoided here; it is
/// unrepresentable, because there is no `meets` constructor to reach for.
///
/// Carries what was SEARCHED, so the fisher can say what was looked in.
final class NoRuleFound extends Resolution {
  /// [searched] is the instruments consulted; [checkedOn] is when the
  /// transcription was last verified.
  const NoRuleFound({required this.searched, required this.checkedOn, required this.isExpired});

  /// The instruments consulted. Never empty.
  final List<Citation> searched;

  /// When the bundled content was last verified, ISO-8601.
  final String checkedOn;

  @override
  final bool isExpired;

  /// The sources consulted, which is how an absence stays cited.
  ///
  /// This does not weaken invariant 3. Read literally against an arm describing
  /// the absence of any rule, "every result carries a required, non-nullable
  /// Citation" would require the engine to NAME AN INSTRUMENT FOR A RULE THAT
  /// DOES NOT EXIST — which is `catchlaw-verdict-contract`'s banned
  /// `?? 'Local fisheries rules'` fallback. The reading that holds the
  /// invariant's purpose is this one: the result is never uncited, and where
  /// there is no single source there is a non-empty list of the sources
  /// consulted.
  @override
  List<Citation> get citations => searched;
}

/// The species id is not in this jurisdiction's list at all.
///
/// A different thing from [NoRuleFound], and collapsing the two is the failure
/// `catchlaw-rule-engine` rule 8 names: *absence of evidence stamped as
/// permission fails silently in exactly the zones with the thinnest content* —
/// which are the zones E22 has not reached yet, and therefore most of them for
/// most of this product's life. `SPEC.md` §4.1 requires two visually distinct
/// states, which the app can only render if the engine returns two types.
final class UnknownSpecies extends Resolution {
  /// [speciesId] is the id that was not found.
  const UnknownSpecies({required this.speciesId, required this.searched, required this.checkedOn});

  /// The id the reference database did not recognise here.
  final int speciesId;

  /// The instruments consulted. Never empty.
  final List<Citation> searched;

  /// When the bundled content was last verified, ISO-8601.
  final String checkedOn;

  /// Nothing was evaluated, so nothing could have lapsed.
  @override
  bool get isExpired => false;

  @override
  List<Citation> get citations => searched;
}
