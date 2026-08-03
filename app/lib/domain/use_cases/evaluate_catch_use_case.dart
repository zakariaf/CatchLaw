import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/repositories/reference_repository.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart' as domain;
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart';

/// The place, the fish and the reading, as one question.
///
/// A value type and not a record of live objects, because it is a Riverpod
/// family key: a key with identity `==` re-creates its provider on every
/// rebuild, and for this family that means re-reading `reference.db` on every
/// frame of a ruler drag. Four values, structural equality, and a drag that
/// does not move the millimetre asks nothing.
@immutable
class CatchQuestion {
  /// One question.
  const CatchQuestion({
    required this.scope,
    required this.speciesId,
    required this.on,
    this.lengthMm,
    this.method,
  });

  /// Where he is.
  final EvaluationScope scope;

  /// Which fish.
  final int speciesId;

  /// The landing date, ISO-8601. Passed in, so nothing here reads a clock.
  final String on;

  /// What the ruler said, or `null` if he has not measured.
  final int? lengthMm;

  /// How he measured it.
  final MeasurementMethod? method;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatchQuestion &&
          other.scope == scope &&
          other.speciesId == speciesId &&
          other.on == on &&
          other.lengthMm == lengthMm &&
          other.method == method;

  @override
  int get hashCode => Object.hash(scope, speciesId, on, lengthMm, method);
}

/// A place whose water the pack never resolved to salt or fresh.
///
/// The engine refuses a `both` request by assert, and correctly: `both` is a
/// property of a RULE, and a `both` request would make the
/// fresh-drops-in-salt guard meaningless. It can only be reached through a zone
/// row this build did not produce, so it is a defect and is reported as one —
/// never rendered as an absence of rules.
final class UnresolvedWater implements Exception {
  /// Records that [zoneCode] left the water open.
  const UnresolvedWater(this.zoneCode);

  /// The zone whose `water_type` never narrowed.
  final String zoneCode;

  @override
  String toString() => 'UnresolvedWater: $zoneCode is neither salt nor fresh';
}

/// Turns a species, a place and a reading into a [Resolution].
///
/// **This is the seam ten merged epics assumed and none of them built.** E03
/// returns sealed types from plain values, E05 can read every one of those
/// values, and E10 turns the result into six languages — and until this file
/// existed nothing called any of it.
///
/// A use case rather than a repository method: it joins the rule rows and the
/// zone chain from `reference.db` with the tally from `user.db` and the reading
/// from E09, and `FLUTTER_GUIDE.md` §1.9 puts every cross-repository join here.
/// A repository reaching into the other database would also be the first thing
/// in the app holding both handles at once, which is what D-6's `ATTACH` ban
/// exists to prevent.
///
/// **It returns numbers and never a sentence.** D-7 keeps wording out of the
/// engine; this keeps it out of the domain layer for the same reason. E10's
/// presenter is the one place words are made.
final class EvaluateCatchUseCase {
  /// Reads through [reference].
  const EvaluateCatchUseCase({required this.reference});

  /// The rule book.
  final ReferenceRepository reference;

  /// The answer for [question], or the failure that stopped it.
  ///
  /// **A broken read is a `Failure`, never `NoRuleFound`.** "No rule recorded
  /// for this species here" is a legal statement; a file that would not open is
  /// not one, and rendering the second as the first puts a claim about the law
  /// on screen because a disk was busy.
  Future<Result<Resolution>> call(CatchQuestion question) async {
    final EvaluationScope scope = question.scope;

    final Result<List<Jurisdiction>> jurisdictions = await reference.jurisdictions();
    if (jurisdictions case Failure<List<Jurisdiction>>(:final Exception exception)) {
      return Result<Resolution>.error(exception);
    }
    Jurisdiction? jurisdiction;
    for (final Jurisdiction j in (jurisdictions as Ok<List<Jurisdiction>>).value) {
      if (j.code == scope.jurisdictionCode) jurisdiction = j;
    }
    if (jurisdiction == null) {
      return Result<Resolution>.error(UnresolvedWater(scope.zoneCode));
    }

    final WaterType? water = _waterFor(scope.water);
    if (water == null) return Result<Resolution>.error(UnresolvedWater(scope.zoneCode));

    // The species FIRST, because "we have never heard of this fish" and "nobody
    // has transcribed this zone yet" are different answers, and the engine can
    // only tell them apart if it is handed the species rather than left to
    // infer it from an empty candidate list.
    final Result<domain.Species> speciesRead = await reference.speciesById(question.speciesId);
    final domain.Species? found = speciesRead is Ok<domain.Species> ? speciesRead.value : null;

    final Result<List<Rule>> rulesRead = await reference.candidateRules(
      jurisdictionId: jurisdiction.id,
      speciesId: question.speciesId,
      waterType: water.name,
      onDate: question.on,
    );
    if (rulesRead case Failure<List<Rule>>(:final Exception exception)) {
      return Result<Resolution>.error(exception);
    }
    final List<Rule> rules = (rulesRead as Ok<List<Rule>>).value;

    final Result<List<domain.Zone>> zonesRead = await reference.zones(jurisdiction.id);
    if (zonesRead case Failure<List<domain.Zone>>(:final Exception exception)) {
      return Result<Resolution>.error(exception);
    }

    return evaluate(
      EvaluationRequest(
        jurisdictionId: jurisdiction.id,
        speciesId: question.speciesId,
        species: _engineSpecies(found),
        waterType: water,
        zonePath: _zonePath(scope, (zonesRead as Ok<List<domain.Zone>>).value),
        on: question.on,
        contentCheckedOn: jurisdiction.checkedOn,
        // Carried straight through. A reading altered between the ruler and the
        // engine is a wrong verdict with a plausible number on it.
        landing: Landing(lengthMm: question.lengthMm, method: question.method),
        // Empty until E13 keeps a catch log. A bag limit then reads as
        // indeterminate — "nothing recorded for this period" — which is true,
        // and is never a pass.
        tally: const CatchTally(),
        searched: _searched(rules, jurisdiction),
      ),
      rules,
    );
  }

  /// The engine's water, or `null` where the place never narrowed.
  WaterType? _waterFor(WaterKind kind) => switch (kind) {
    WaterKind.salt => WaterType.salt,
    WaterKind.fresh => WaterType.fresh,
    WaterKind.both || WaterKind.unknown => null,
  };

  /// The zone rows of the chain the scope resolved, outermost first.
  ///
  /// Mapped into the ENGINE's `Zone`, which carries only what resolution needs:
  /// the app's own type also holds a bounding box and a name key, and handing
  /// the engine a geometry it has no business reading is how a pure package
  /// grows a dependency on the shape of a table.
  List<Zone> _zonePath(EvaluationScope scope, List<domain.Zone> all) => <Zone>[
    for (final String code in scope.zonePath)
      for (final domain.Zone z in all)
        if (z.code == code)
          Zone(
            id: z.id,
            jurisdictionId: z.jurisdictionId,
            parentZoneId: z.parentZoneId,
            code: z.code,
            waterType: _engineWater(z.waterType),
            zoneKind: z.zoneKind,
          ),
  ];

  /// A zone's own water, in the engine's enum.
  ///
  /// A zone that says `both` is legitimate — it is a place that publishes for
  /// both waters — and it reaches the engine as `both` unchanged. Only the
  /// REQUEST may not be `both`, and that is checked once, above.
  WaterType _engineWater(WaterKind kind) => switch (kind) {
    WaterKind.salt => WaterType.salt,
    WaterKind.fresh => WaterType.fresh,
    WaterKind.both || WaterKind.unknown => WaterType.both,
  };

  /// The instruments consulted, so an absence can still say what was looked in.
  ///
  /// Never empty: the engine asserts it, and the assert is invariant 3 for the
  /// two absence arms. Where no rule was found there is still the jurisdiction's
  /// own transcription date to answer with.
  List<Citation> _searched(List<Rule> rules, Jurisdiction jurisdiction) {
    final cited = <Citation>[for (final Rule r in rules) r.citation];
    if (cited.isNotEmpty) return cited;
    // A jurisdiction with no candidate rule for this species still has a pack
    // and a checked-on date, and saying so is what stops an absence being
    // uncited.
    return <Citation>[
      Citation(
        instrument: jurisdiction.code,
        article: jurisdiction.contentVersion,
        publishedOn: jurisdiction.checkedOn,
        checkedOn: jurisdiction.checkedOn,
      ),
    ];
  }

  Species? _engineSpecies(domain.Species? species) => species == null
      ? null
      : Species(
          id: species.id,
          scientificName: species.scientificName,
          taxonGroup: species.taxonGroup,
        );
}
