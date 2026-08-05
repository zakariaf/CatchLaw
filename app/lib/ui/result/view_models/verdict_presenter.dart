import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/content_strings.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/ui/core/format/measurement_format.dart';
import 'package:catchlaw/ui/result/view_models/result_context.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:intl/intl.dart';
import 'package:rule_engine/rule_engine.dart';

/// Turns a [Resolution] into words, in one of six languages.
///
/// **This class exists because D-7 says the engine may not.**
/// `packages/rule_engine/` returns integers, enums, a required [Citation] and
/// an `isExpired` flag, and holds no user-visible sentence in any language.
/// Something has to turn a `MinimumSizeFinding` of 450 mm total length and a
/// reading of 380 mm into a sentence a fisher can check against a ruler and a
/// published article. That something is here.
///
/// **A plain class rather than a widget**, so six locales are six calls instead
/// of six widget pumps, and so every legal sentence in the app is assembled in
/// one file that `check_verdict_contract.sh` can sweep — rather than by
/// interpolation across three call sites in a `build`.
///
/// Three sources meet here and nowhere else: the ARB carries the skeleton with
/// its placeholders, `content_string` carries the bundled-content words (the
/// spelled-out measurement method, the authority named in the disclaimer), and
/// the engine carries the numbers. `SPEC.md` §9.2 draws that line, and the
/// content build already fails on a `*_key` missing from any shipped locale, so
/// a missing tier-two string is a build error upstream rather than a fallback
/// here.
///
/// No clock, no repository, no `BuildContext`. Everything that varies by place
/// rather than by resolution arrives on [ResultContext].
class VerdictPresenter {
  /// Presents in [l10n]'s language, with [content]'s words and [locale]'s digits.
  const VerdictPresenter({required this.l10n, required this.content, required this.locale});

  /// Tier one: the sentence skeletons.
  final AppLocalizations l10n;

  /// Tier two: the bundled-content words, already resolved for this locale.
  final ContentStrings content;

  /// Which locale's digits the numbers come out in.
  final Locale locale;

  /// A formatter, built fresh at every use and never retained.
  ///
  /// `applyNumeralSystem` swaps the process-wide symbol table for `ar`, and a
  /// `NumberFormat` captures its symbols at construction — so one held in a
  /// field would go on printing the digits of whenever it was built, on a
  /// screen the fisher had just changed the setting for
  /// (`FLUTTER_GUIDE.md` Part 9.1, and a policy test that greps for it).
  NumberFormat get _numbers => numberFormatFor(locale);

  /// [resolution] as the result screen draws it, in [context]'s jurisdiction.
  ///
  /// One switch over the sealed [Resolution] with no `default:` arm, so a
  /// seventh arm added to the engine fails to compile here rather than falling
  /// into a neighbour's branch and printing a confident wrong sentence.
  ///
  /// The reading is NOT a parameter. Every size finding already carries its own
  /// `measuredMm` and `measuredMethod`, put there by the evaluator that decided
  /// the outcome; a second reading passed in beside it could disagree with the
  /// one the verdict was computed from, and the sentence would then state a
  /// number the engine never compared.
  ResultDisplay present(Resolution resolution, ResultContext context) {
    final String authority = content[context.authorityKey];
    final String disclaimer = l10n.disclaimerVerdict(authority);
    // A flag beside the answer, never a filter over it: an expired ruleset is
    // still evaluated and still shown, and withholding it would be advice.
    //
    // The date is the PACK's and arrives on the context, because the engine
    // carries `isExpired` as a bool and no date at all — expiry is about the
    // instrument's currency rather than about the fish. Where the pack states
    // no end date, the sentence states the fact without one rather than
    // inventing a day.
    final String? expiredOn = context.packExpiredOn;
    final StaleDisplay? stale = resolution.isExpired
        ? StaleDisplay(
            sentence: expiredOn == null ? l10n.rulePackExpired : l10n.rulePackExpiredOn(expiredOn),
            provenance: l10n.rulePackProvenance(context.packId, expiredOn ?? ''),
          )
        : null;

    return switch (resolution) {
      Decided(:final Finding headline, :final List<Finding> secondary) => _decided(
        headline,
        secondary,
        disclaimer: disclaimer,
        authority: authority,
        stale: stale,
      ),
      Ambiguous(:final List<Rule> rules) => ResultDisplay(
        findings: const <FindingDisplay>[],
        disclaimer: disclaimer,
        authority: authority,
        stale: stale,
        ambiguity: AmbiguityDisplay(
          sentence: l10n.verdictAmbiguous,
          rules: <AmbiguousRuleDisplay>[for (final Rule rule in rules) _ambiguousRule(rule)],
        ),
      ),
      NoLimitInInstrument(:final Citation citation) => _noted(
        l10n.verdictNoLimitInInstrument,
        NoteKind.noLimitInInstrument,
        <Citation>[citation],
        disclaimer: disclaimer,
        authority: authority,
        stale: stale,
      ),
      NoRuleFound(:final List<Citation> searched) => _noted(
        l10n.verdictNoRuleRecorded,
        NoteKind.noRuleRecorded,
        searched,
        disclaimer: disclaimer,
        authority: authority,
        stale: stale,
      ),
      UnknownSpecies(:final List<Citation> searched) => _noted(
        l10n.verdictUnknownSpecies,
        NoteKind.unknownSpecies,
        searched,
        disclaimer: disclaimer,
        authority: authority,
        stale: stale,
      ),
    };
  }

  /// The stamp, or the open question that may not be stamped.
  ///
  /// An indeterminate headline gets a note and NO stamp. The four categories
  /// cannot hold an unanswered question — `.meets` would be the softened
  /// absence the whole contract bans, and the adverse set would state a failure
  /// nobody established — so the same rule that governs an absent rule governs
  /// an unanswerable one: nothing is stamped, and the question is printed.
  ResultDisplay _decided(
    Finding headline,
    List<Finding> secondary, {
    required String disclaimer,
    required String authority,
    required StaleDisplay? stale,
  }) {
    // Headline first, then the engine's own order. The engine ranks once; a
    // second sort here would be a second, untested opinion.
    final ranked = <Finding>[headline, ...secondary];
    // First-appearance order, de-duplicated: two findings from one instrument
    // share a marker, because two markers would say two instruments were read.
    final footnotes = <Citation>[];
    for (final finding in ranked) {
      if (!footnotes.contains(finding.citation)) footnotes.add(finding.citation);
    }
    final findings = <FindingDisplay>[
      for (final Finding finding in ranked)
        _finding(finding, footnotes.indexOf(finding.citation) + 1),
    ];
    final FindingDisplay head = findings.first;

    if (headline.outcome == FindingOutcome.indeterminate) {
      return ResultDisplay(
        findings: findings,
        disclaimer: disclaimer,
        authority: authority,
        stale: stale,
        note: NoteDisplay(
          sentence: head.sentence,
          kind: NoteKind.openQuestion,
          citations: <CitationDisplay>[head.citation],
        ),
      );
    }

    return ResultDisplay(
      findings: findings,
      disclaimer: disclaimer,
      authority: authority,
      stale: stale,
      stamp: VerdictStampDisplay(
        // The state alone, and the figures one register down. The whole
        // sentence is still built — it is what `findings.first` carries and
        // what the screen reader announces — but the stamp is read in a glance,
        // and a glance takes the state first.
        headline: _stampHeadlineFor(headline),
        category: _categoryFor(headline),
        kind: headline.kind,
        citation: head.citation,
        detail: _stampDetailFor(headline),
        meta: _marginFor(headline),
      ),
    );
  }

  ResultDisplay _noted(
    String sentence,
    NoteKind kind,
    List<Citation> citations, {
    required String disclaimer,
    required String authority,
    required StaleDisplay? stale,
  }) => ResultDisplay(
    findings: const <FindingDisplay>[],
    disclaimer: disclaimer,
    authority: authority,
    stale: stale,
    note: NoteDisplay(
      sentence: sentence,
      kind: kind,
      citations: <CitationDisplay>[for (final Citation c in citations) _citation(c)],
    ),
  );

  /// Which signal set the surface spends on [finding].
  ///
  /// Deliberately separate from the sentence. A seventh `FindingKind` then
  /// fails to compile in two places rather than silently inheriting a
  /// neighbour's wording: mapping `maxSize` onto the below-minimum sentence
  /// would print *Below the minimum* over a 122 cm fish that failed a slot
  /// rule — confident, wrong, and a legally distinct offence.
  VerdictCategory _categoryFor(Finding finding) => finding.outcome == FindingOutcome.passes
      ? VerdictCategory.meets
      : switch (finding.kind) {
          FindingKind.protected => VerdictCategory.protected,
          FindingKind.closedSeason => VerdictCategory.closedSeason,
          FindingKind.maxSize ||
          FindingKind.minSize ||
          FindingKind.bagLimit ||
          FindingKind.vesselLimit => VerdictCategory.belowMinimum,
        };

  /// The sentence for [finding], chosen by its type and never by its category.
  String _sentenceFor(Finding finding) => switch (finding) {
    ProtectedFinding() => l10n.verdictProtected,
    ClosedSeasonFinding() => _closedSeasonSentence(finding),
    SizeFinding() => _sizeSentence(finding),
    BagLimitFinding() => _bagLimitSentence(finding),
    VesselLimitFinding() => _vesselLimitSentence(finding),
  };

  /// The state alone, for the stamp's top register.
  ///
  /// **Chosen by the finding's type and never by its category**, the same way
  /// [_sentenceFor] is and for the same reason: four categories cannot hold six
  /// kinds, and mapping `maxSize` onto the below-minimum wording would print
  /// *Below the minimum* over a 122 cm fish that failed a slot rule.
  ///
  /// A bag or vessel limit keeps its whole sentence here. It has no short form
  /// in the corpus — *Within the bag limit* alone states neither the tally nor
  /// the period, and a season quota compared against one day passes on every
  /// day of a season it has already exhausted.
  String _stampHeadlineFor(Finding finding) => switch (finding) {
    ProtectedFinding() => l10n.verdictProtected,
    ClosedSeasonFinding() => l10n.verdictStampClosedSeason(
      _dayAndMonth(finding.startsOn),
      _dayAndMonth(finding.endsOn),
    ),
    SizeFinding() => _sizeStampHeadline(finding),
    BagLimitFinding() => _bagLimitSentence(finding),
    VesselLimitFinding() => _vesselLimitSentence(finding),
  };

  String _sizeStampHeadline(SizeFinding finding) {
    if (finding.methodMismatch && finding.measuredMethod != null) {
      return l10n.verdictStampMethodMismatch;
    }
    if (finding.measuredMm == null) return l10n.verdictStampNotMeasured;

    final fails = finding.outcome == FindingOutcome.fails;
    return switch (finding) {
      MinimumSizeFinding() => fails ? l10n.verdictStampBelowMinimum : l10n.verdictStampMeetsMinimum,
      MaximumSizeFinding() =>
        fails ? l10n.verdictStampAboveMaximum : l10n.verdictStampWithinMaximum,
    };
  }

  /// The figures line under the headline, or `null` where there are none.
  ///
  /// Null for a prohibition, and that is the category's rule rather than an
  /// omission — see [VerdictStampDisplay.detail]. A bag or vessel limit is null
  /// too: its whole sentence is already the headline, and repeating it here
  /// would read as two separate rules biting.
  String? _stampDetailFor(Finding finding) => switch (finding) {
    ProtectedFinding() => null,
    BagLimitFinding() || VesselLimitFinding() => null,
    ClosedSeasonFinding() =>
      finding.inForce
          ? l10n.verdictDetailClosedSeasonInForce(
              _numbers.format(finding.dayOfClosure),
              _numbers.format(finding.lengthInDays),
            )
          : l10n.verdictDetailClosedSeasonNotInForce,
    SizeFinding() => _sizeStampDetail(finding),
  };

  String _sizeStampDetail(SizeFinding finding) {
    final ({LengthUnit unit, String word}) unit = _instrumentUnit(finding.method);
    final String threshold = formatLengthValue(
      finding.thresholdMm,
      unit: unit.unit,
      numbers: _numbers,
    );
    final String method = _methodName(finding.method);

    // Two methods, two facts, no comparison — the same refusal the sentence
    // makes. A conversion factor bridging total length and fork length would
    // manufacture a pass at the centimetre that costs AED 3,000.
    final MeasurementMethod? measuredMethod = finding.measuredMethod;
    if (finding.methodMismatch && measuredMethod != null) {
      return l10n.verdictSizeMethodMismatch(
        _methodName(measuredMethod),
        threshold,
        unit.word,
        method,
      );
    }

    final int? measured = finding.measuredMm;
    if (measured == null) {
      return switch (finding) {
        MinimumSizeFinding() => l10n.verdictDetailMinimumUnmeasured(threshold, unit.word, method),
        MaximumSizeFinding() => l10n.verdictDetailMaximumUnmeasured(threshold, unit.word, method),
      };
    }

    final String reading = formatLengthValue(measured, unit: unit.unit, numbers: _numbers);
    return switch (finding) {
      MinimumSizeFinding() => l10n.verdictDetailMinimum(reading, unit.word, threshold, method),
      MaximumSizeFinding() => l10n.verdictDetailMaximum(reading, unit.word, threshold, method),
    };
  }

  /// The numeric margin under the stamp, or `null` where none applies.
  ///
  /// Null for a prohibition and for a closure, and that is the rule rather than
  /// an omission: a closure applies at every size, and a measurement printed
  /// beside a prohibition implies a threshold that does not exist.
  String? _marginFor(Finding finding) {
    if (finding is! SizeFinding) return null;
    final int? measured = finding.measuredMm;
    if (measured == null || finding.methodMismatch) return null;

    final ({LengthUnit unit, String word}) unit = _instrumentUnit(finding.method);
    final String margin = formatLengthValue(
      (measured - finding.thresholdMm).abs(),
      unit: unit.unit,
      numbers: _numbers,
    );
    final fails = finding.outcome == FindingOutcome.fails;
    return switch (finding) {
      MinimumSizeFinding() =>
        fails
            ? l10n.verdictMarginShortOfMinimum(margin, unit.word)
            : l10n.verdictMarginOverMinimum(margin, unit.word),
      MaximumSizeFinding() =>
        fails
            ? l10n.verdictMarginOverMaximum(margin, unit.word)
            : l10n.verdictMarginUnderMaximum(margin, unit.word),
    };
  }

  FindingDisplay _finding(Finding finding, int citationIndex) => FindingDisplay(
    sentence: _sentenceFor(finding),
    kind: finding.kind,
    outcome: finding.outcome,
    citation: _citation(finding.citation),
    citationIndex: citationIndex,
    facts: _factsFor(finding),
  );

  CitationDisplay _citation(Citation citation) => CitationDisplay(
    instrument: citation.instrument,
    article: citation.article,
    // Carried through as the stored string. ISO-8601 and unlocalised in every
    // locale, because it quotes a printed instrument and has to be comparable
    // against the gazette by eye.
    publishedOn: citation.publishedOn,
    checkedOn: citation.checkedOn,
  );

  /// The sentence for a minimum or a maximum, and the two are not one rule.
  ///
  /// One body, four messages, and the four are chosen by an exhaustive switch
  /// over the sealed type rather than by a bool: a third `SizeFinding` must fail
  /// to compile here, not be treated as a minimum because it is not a maximum.
  /// Printing *Below the minimum* over a 122 cm fish that failed a slot rule is
  /// a confident, wrong statement about a legally distinct offence.
  String _sizeSentence(SizeFinding finding) {
    final ({LengthUnit unit, String word}) unit = _instrumentUnit(finding.method);
    final String threshold = formatLengthValue(
      finding.thresholdMm,
      unit: unit.unit,
      numbers: _numbers,
    );
    final String method = _methodName(finding.method);
    final ({
      String Function(String, String, String, String) fails,
      String Function(String, String, String, String) passes,
      String Function(String, String, String) unmeasured,
    })
    say = switch (finding) {
      MinimumSizeFinding() => (
        fails: l10n.verdictBelowMinimum,
        passes: l10n.verdictMeetsMinimum,
        unmeasured: l10n.verdictMinimumNotMeasured,
      ),
      MaximumSizeFinding() => (
        fails: l10n.verdictAboveMaximum,
        passes: l10n.verdictWithinMaximum,
        unmeasured: l10n.verdictMaximumNotMeasured,
      ),
    };

    // Two methods, two facts, no comparison. A conversion factor bridging total
    // length and fork length would manufacture a pass at the centimetre that
    // costs AED 3,000.
    final MeasurementMethod? measuredMethod = finding.measuredMethod;
    if (finding.methodMismatch && measuredMethod != null) {
      return l10n.verdictSizeMethodMismatch(
        _methodName(measuredMethod),
        threshold,
        unit.word,
        method,
      );
    }

    final int? measured = finding.measuredMm;
    if (measured == null) return say.unmeasured(threshold, unit.word, method);

    final String reading = formatLengthValue(measured, unit: unit.unit, numbers: _numbers);
    return finding.outcome == FindingOutcome.fails
        ? say.fails(reading, unit.word, threshold, method)
        : say.passes(reading, unit.word, threshold, method);
  }

  String _closedSeasonSentence(ClosedSeasonFinding finding) {
    final String starts = _dayAndMonth(finding.startsOn);
    final String ends = _dayAndMonth(finding.endsOn);
    // Where today sits, never how many days remain: a countdown invites
    // planning, and this app states what the instrument says today.
    return finding.inForce
        ? l10n.verdictClosedSeasonInForce(
            starts,
            ends,
            _numbers.format(finding.dayOfClosure),
            _numbers.format(finding.lengthInDays),
          )
        : l10n.verdictClosedSeasonNotInForce(starts, ends);
  }

  String _bagLimitSentence(BagLimitFinding finding) {
    final String period = _periodWord(finding.period);
    final String limit = _limitQuantity(finding.limit, finding.unit, inGrams: false);
    final int? recorded = finding.recorded;
    if (recorded == null) return l10n.verdictBagLimitNotRecorded(limit, period);

    final String tally = _limitQuantity(recorded, finding.unit, inGrams: true);
    return finding.outcome == FindingOutcome.fails
        ? l10n.verdictAboveBagLimit(tally, limit, period)
        : l10n.verdictWithinBagLimit(tally, limit, period);
  }

  String _vesselLimitSentence(VesselLimitFinding finding) {
    final String limit = _numbers.format(finding.limit);
    final int? recorded = finding.recorded;
    if (recorded == null) return l10n.verdictVesselLimitNotRecorded(limit);

    return finding.outcome == FindingOutcome.fails
        ? l10n.verdictAboveVesselLimit(_numbers.format(recorded), limit)
        : l10n.verdictWithinVesselLimit(_numbers.format(recorded), limit);
  }

  /// The rows of the rule table for [finding].
  List<RuleFact> _factsFor(Finding finding) => switch (finding) {
    // A prohibition has no numbers, and manufacturing rows saying so would
    // state that a size rule and a season were considered and found not to
    // apply — which no instrument says.
    ProtectedFinding() => const <RuleFact>[],
    ClosedSeasonFinding() => <RuleFact>[
      RuleFact(
        label: l10n.findingFactDates,
        value: l10n.findingWindowRange(
          _dayAndMonth(finding.startsOn),
          _dayAndMonth(finding.endsOn),
        ),
      ),
      if (finding.inForce)
        RuleFact(
          label: l10n.findingFactToday,
          value: l10n.findingDayOfWindow(
            _numbers.format(finding.dayOfClosure),
            _numbers.format(finding.lengthInDays),
          ),
        ),
    ],
    SizeFinding() => _sizeFacts(finding),
    BagLimitFinding() => <RuleFact>[
      if (finding.recorded case final int recorded)
        RuleFact(
          label: l10n.findingFactRecorded,
          value: _limitQuantity(recorded, finding.unit, inGrams: true),
        ),
      RuleFact(
        label: l10n.findingFactLimit,
        value: _limitQuantity(finding.limit, finding.unit, inGrams: false),
      ),
      RuleFact(label: l10n.findingFactPeriod, value: _periodWord(finding.period)),
    ],
    VesselLimitFinding() => <RuleFact>[
      if (finding.recorded case final int recorded)
        RuleFact(label: l10n.findingFactRecorded, value: _numbers.format(recorded)),
      RuleFact(label: l10n.findingFactLimit, value: _numbers.format(finding.limit)),
    ],
  };

  /// Measured and threshold, each carrying the method it was taken by.
  ///
  /// Both rows go through [formatMeasurement], so neither number can reach the
  /// table without its method beside it — and on a mismatch the two rows name
  /// two different methods, which is the whole fact the reader needs.
  List<RuleFact> _sizeFacts(SizeFinding finding) {
    final rows = <RuleFact>[];
    final int? measured = finding.measuredMm;
    final MeasurementMethod? measuredMethod = finding.measuredMethod;
    if (measured != null && measuredMethod != null) {
      rows.add(RuleFact(label: l10n.findingFactMeasured, value: _length(measured, measuredMethod)));
    }
    rows.add(
      RuleFact(
        label: finding is MaximumSizeFinding ? l10n.findingFactMaximum : l10n.findingFactMinimum,
        value: _length(finding.thresholdMm, finding.method),
      ),
    );
    return rows;
  }

  AmbiguousRuleDisplay _ambiguousRule(Rule rule) {
    final MeasurementMethod? method = rule.measurementMethod;
    return AmbiguousRuleDisplay(
      // The lineage id rather than the row id: a reader recording which
      // instrument he applied names the instrument, and the row that carries it
      // is replaced wholesale by the next content update.
      instrumentId: rule.citationLineageId,
      citation: _citation(rule.citation),
      facts: <RuleFact>[
        // A threshold with no method is a number the reader cannot act on, so
        // a row that cannot name its method is not written at all.
        if (method != null && rule.minSizeMm != null)
          RuleFact(label: l10n.findingFactMinimum, value: _length(rule.minSizeMm!, method)),
        if (method != null && rule.maxSizeMm != null)
          RuleFact(label: l10n.findingFactMaximum, value: _length(rule.maxSizeMm!, method)),
        if (rule.bagLimit case final int limit)
          RuleFact(
            label: l10n.findingFactLimit,
            value: _limitQuantity(limit, rule.bagLimitUnit ?? LimitUnit.count, inGrams: false),
          ),
      ],
    );
  }

  /// [millimetres] as the table prints it, with its method.
  String _length(int millimetres, MeasurementMethod method) => formatMeasurement(
    millimetres,
    unit: _instrumentUnit(method).unit,
    numbers: _numbers,
    methodLabel: _methodName(method),
    patterns: (cm: l10n.measurementCm, mm: l10n.measurementMm, inch: l10n.measurementInch),
  );

  /// A bag-limit quantity, in individuals or in kilograms.
  ///
  /// [inGrams] says how the number arrives, not what it means: a recorded tally
  /// is carried in grams so the engine's comparison stays integer, while the
  /// limit beside it is authored in whole kilograms.
  String _limitQuantity(int value, LimitUnit unit, {required bool inGrams}) => switch (unit) {
    LimitUnit.count => _numbers.format(value),
    LimitUnit.kg => l10n.massKg(_numbers.format(inGrams ? value / 1000 : value)),
  };

  String _periodWord(LimitPeriod period) => switch (period) {
    LimitPeriod.day => l10n.limitPeriodDay,
    LimitPeriod.trip => l10n.limitPeriodTrip,
    LimitPeriod.season => l10n.limitPeriodSeason,
  };

  /// An ISO date as a day and a month name.
  ///
  /// Season boundaries print as day and month because an ISO date in prose is
  /// unreadable to the man holding the fish. Citation dates stay ISO for the
  /// opposite reason: they are compared against a printed instrument by eye.
  String _dayAndMonth(String iso) {
    final DateTime date = DateTime.parse(iso);
    return l10n.dateDayMonth(_numbers.format(date.day), l10n.monthName('${date.month}'));
  }

  /// The spelled-out name of [method], from `content_string`.
  ///
  /// Rendered exactly as the pack authored it, with no case folding. Lowering
  /// the first letter to fit an English sentence is a no-op in Arabic and wrong
  /// in five other places, and the value is a translated content row rather
  /// than a Dart constant.
  String _methodName(MeasurementMethod method) =>
      content[switch (method) {
        MeasurementMethod.totalLength => 'measurement.tl.name',
        MeasurementMethod.forkLength => 'measurement.fl.name',
        MeasurementMethod.standardLength => 'measurement.sl.name',
        MeasurementMethod.carapaceWidth => 'measurement.cw.name',
        MeasurementMethod.carapaceLength => 'measurement.cl.name',
        MeasurementMethod.mantleLength => 'measurement.ml.name',
        MeasurementMethod.discWidth => 'measurement.dw.name',
        MeasurementMethod.shellLength => 'measurement.shl.name',
        MeasurementMethod.custom => 'measurement.custom.name',
      }];

  /// The unit an instrument states [method] in, and the word for it.
  ///
  /// **The unit follows the instrument, never the reader.** A Galician shell
  /// length stays in millimetres on an Arabic phone, and the ruler preference
  /// of `SPEC.md` §14 governs the readout in E09 rather than the quoted rule.
  ///
  /// Derived from the method because `SPEC.md` §7.1 gives the `rule` table no
  /// unit column, and the engine states plainly that it has none to carry. This
  /// cannot change a verdict: 38 mm and 3.8 cm are one quantity and the
  /// comparison already happened in integer millimetres. It chooses only how
  /// that quantity is written — and every instrument in the corpus states a
  /// shell, carapace, mantle or disc measurement in millimetres and a finfish
  /// length in centimetres. A custom method takes the stored unit, because
  /// nothing is known about a method this build cannot name.
  ({LengthUnit unit, String word}) _instrumentUnit(MeasurementMethod method) => switch (method) {
    MeasurementMethod.totalLength ||
    MeasurementMethod.forkLength ||
    MeasurementMethod.standardLength => (unit: LengthUnit.cm, word: l10n.unitCentimetres),
    MeasurementMethod.carapaceWidth ||
    MeasurementMethod.carapaceLength ||
    MeasurementMethod.mantleLength ||
    MeasurementMethod.discWidth ||
    MeasurementMethod.shellLength ||
    MeasurementMethod.custom => (unit: LengthUnit.mm, word: l10n.unitMillimetres),
  };
}

/// The `measurement_method.name_key` for [method].
///
/// Top-level and total, because two places need it and they must not drift: the
/// presenter reads a name out of the snapshot, and the provider decides which
/// names to put in the snapshot. A second hand-kept list would go stale the
/// first time a method was added, and the failure would be a
/// [ContentStringMissing] thrown on a fisher's phone rather than a compile
/// error here.
String contentKeyForMethod(MeasurementMethod method) => switch (method) {
  MeasurementMethod.totalLength => 'measurement.tl.name',
  MeasurementMethod.forkLength => 'measurement.fl.name',
  MeasurementMethod.standardLength => 'measurement.sl.name',
  MeasurementMethod.carapaceWidth => 'measurement.cw.name',
  MeasurementMethod.carapaceLength => 'measurement.cl.name',
  MeasurementMethod.mantleLength => 'measurement.ml.name',
  MeasurementMethod.discWidth => 'measurement.dw.name',
  MeasurementMethod.shellLength => 'measurement.shl.name',
  MeasurementMethod.custom => 'measurement.custom.name',
};
