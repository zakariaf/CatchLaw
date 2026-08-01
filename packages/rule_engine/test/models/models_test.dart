// The domain models of SPEC.md §7.1, as VALUE types rather than row types.
//
// FLUTTER_GUIDE.md §2.5 rule 6 keeps drift rows inside data/, and
// catchlaw-rule-engine names "passing a drift RuleData row into resolve()" as
// an anti-pattern with a concrete cost: tools/content_builder is a plain
// `dart run` binary and could no longer build a fixture without opening SQLite.
// Every model here is constructible from three literals.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/fixtures.dart';

void main() {
  group('Citation', () {
    test('requires an instrument, an article, a published date and a checked date', () {
      const c = Citation(
        instrument: 'Ministerial Decision 580/2015',
        article: 'Art. 3',
        publishedOn: '2015-11-03',
        checkedOn: '2026-07-14',
      );
      expect(c.instrument, 'Ministerial Decision 580/2015');
      expect(c.article, 'Art. 3');
      expect(c.publishedOn, '2015-11-03');
      expect(c.checkedOn, '2026-07-14');
    });

    test('compares equal to a separately built identical citation', () {
      // T05's outcomeEquals must be able to exclude citation identity from a
      // comparison, which needs == to mean value equality.
      //
      // BUILT AT RUNTIME, NOT const. Dart canonicalises identical const
      // expressions to one object, so comparing two const fixtures compares an
      // object with itself: identical() short-circuits and the == override is
      // never reached. The assertion below would pass on a class with no ==
      // at all. Hence the explicit isNot(same(...)) first.
      final built = Citation(
        instrument: kCitationMd580.instrument,
        article: kCitationMd580.article,
        publishedOn: kCitationMd580.publishedOn,
        checkedOn: kCitationMd580.checkedOn,
      );
      expect(built, isNot(same(kCitationMd580)), reason: 'must be two objects');
      expect(built, equals(kCitationMd580));
      expect(built.hashCode, kCitationMd580.hashCode);
    });

    test('is a compile-time constant', () {
      // A fixture in testing/models/ is const; a non-const constructor breaks
      // every one of them.
      const pair = <Citation>[kCitationMd580, kCitationMd580Copy];
      expect(pair, hasLength(2));
    });
  });

  group('MeasurementMethod', () {
    test('exposes the nine SPEC 7.1 codes', () {
      // The mapper round-trips measurement_method.code; a tenth member or a
      // missing one is a silent join failure in E05.
      expect(MeasurementMethod.values.map((m) => m.code).toList(), <String>[
        'TL',
        'FL',
        'SL',
        'CW',
        'CL',
        'ML',
        'DW',
        'SHL',
        'CUSTOM',
      ]);
    });

    test('fromCode returns the member for a known code', () {
      expect(MeasurementMethod.fromCode('FL'), MeasurementMethod.forkLength);
      expect(MeasurementMethod.fromCode('SHL'), MeasurementMethod.shellLength);
    });

    test('fromCode returns null for an unknown code', () {
      // A content typo must reach T02's failure channel, not throw out of a
      // mapper.
      expect(MeasurementMethod.fromCode('XX'), isNull);
    });
  });

  group('WaterType', () {
    test('exposes salt, fresh and both', () {
      // `both` is the member the skill's example forgets and T03's filter
      // turns on.
      expect(WaterType.values, <WaterType>[WaterType.salt, WaterType.fresh, WaterType.both]);
    });
  });

  group('ZoneKind', () {
    test('exposes the six SPEC 7.1 kinds', () {
      // basin is absent from the skill's ladder table and present in §7.1 and
      // §7.3. This test is what stops it being dropped again.
      expect(ZoneKind.values, <ZoneKind>[
        ZoneKind.region,
        ZoneKind.subzone,
        ZoneKind.bank,
        ZoneKind.basin,
        ZoneKind.reserve,
        ZoneKind.exclusion,
      ]);
    });
  });

  group('Zone', () {
    test('accepts a null parent for a root zone', () {
      // The jurisdiction-level zone has no parent.
      const z = Zone(
        id: 1,
        jurisdictionId: 7,
        parentZoneId: null,
        code: 'ae-rak',
        waterType: WaterType.salt,
        zoneKind: ZoneKind.region,
      );
      expect(z.parentZoneId, isNull);
    });
  });

  group('Species', () {
    test('carries a scientific name and a taxon group', () {
      expect(kSpeciesHamour.scientificName, 'Epinephelus coioides');
      expect(kSpeciesHamour.taxonGroup, TaxonGroup.finfish);
    });

    test('TaxonGroup exposes the eight SPEC 7.1 groups', () {
      expect(TaxonGroup.values, hasLength(8));
    });
  });

  group('Rule', () {
    test('accepts a null zone id meaning the whole jurisdiction', () {
      // SPEC.md §7.1: `-- NULL = whole jurisdiction`. T04 ranks it at 0.
      expect(kRuleWholeJurisdiction.zoneId, isNull);
    });

    test('accepts a null valid_to meaning no expiry', () {
      // product-invariants.md §5: a pack with no validUntil is valid, never
      // expired.
      expect(kRuleHamourMinSize.validTo, isNull);
    });

    test('carries its closed seasons', () {
      // The ON DELETE CASCADE relationship is modelled as containment so T09
      // cannot cite the wrong instrument for a closure.
      expect(kRuleShariClosedSeason.closedSeasons, hasLength(1));
      expect(kRuleShariClosedSeason.closedSeasons.single.citation, isNotNull);
    });

    test('compares equal to a separately built identical rule', () {
      // T03's lineage collapse and T05's conflict detection both put rules in
      // collections; identity equality would make a map key useless.
      //
      // copyWith with no arguments builds a NEW object with every field
      // copied, which is the cheapest way to get two structurally identical
      // rules that const canonicalisation has not merged into one.
      final Rule built = kRuleHamourMinSize.copyWith();
      expect(built, isNot(same(kRuleHamourMinSize)), reason: 'must be two objects');
      expect(built, equals(kRuleHamourMinSize));
      expect(built.hashCode, kRuleHamourMinSize.hashCode);
      expect(<Rule>{built, kRuleHamourMinSize}, hasLength(1));
    });

    test('compares unequal when one closed season differs', () {
      // The list field is the one == is most likely to get wrong, because the
      // default List == is identity and would report two different seasons as
      // the same rule.
      final Rule other = kRuleShariClosedSeason.copyWith(
        closedSeasons: const <ClosedSeason>[
          ClosedSeason(
            recurrence: Recurrence.annual,
            startMonth: 5, // was 3
            startDay: 1,
            endMonth: 4,
            endDay: 30,
            citation: kCitationMd580,
          ),
        ],
      );
      expect(other, isNot(equals(kRuleShariClosedSeason)));
    });

    test('copyWith replaces valid_to and leaves every other field alone', () {
      // T03 through T09 vary one field of one fixture per test; without this,
      // each of those tests restates twenty arguments and stops saying which
      // one it is about.
      final Rule expired = kRuleHamourMinSize.copyWith(validTo: '2024-06-30');
      expect(expired.validTo, '2024-06-30');
      expect(expired.copyWith(validTo: null), kRuleHamourMinSize);
      expect(expired.id, kRuleHamourMinSize.id);
      expect(expired.minSizeMm, kRuleHamourMinSize.minSizeMm);
      expect(expired.citation, kRuleHamourMinSize.citation);
    });

    test('LimitUnit and LimitPeriod mirror the SPEC 7.1 CHECK lists', () {
      expect(LimitUnit.values, <LimitUnit>[LimitUnit.count, LimitUnit.kg]);
      expect(LimitPeriod.values, <LimitPeriod>[
        LimitPeriod.day,
        LimitPeriod.trip,
        LimitPeriod.season,
      ]);
    });
  });

  group('ClosedSeason', () {
    test('accepts an annual recurrence with month and day bounds only', () {
      // SPEC.md §7.1 makes all six bound columns nullable because the two
      // recurrence kinds use different pairs.
      const s = ClosedSeason(
        recurrence: Recurrence.annual,
        startMonth: 3,
        startDay: 1,
        endMonth: 4,
        endDay: 30,
        citation: kCitationMd580,
      );
      expect(s.startDate, isNull);
      expect(s.endDate, isNull);
    });

    test('accepts a fixed recurrence with start and end dates only', () {
      // T06 branches on `recurrence`, never on which fields happen to be null.
      const s = ClosedSeason(
        recurrence: Recurrence.fixed,
        startDate: '2026-03-01',
        endDate: '2026-04-30',
        citation: kCitationMd580,
      );
      expect(s.startMonth, isNull);
      expect(s.endMonth, isNull);
    });

    test('requires a non-nullable citation', () {
      // SPEC.md §7.1 makes closed_season.citation_id nullable and
      // rule.citation_id NOT NULL. Invariant 3 wins on the engine side: E05's
      // mapper substitutes the parent rule's citation when the column is null,
      // so no Citation? exists in this package and check 4 stays clean with
      // zero escape hatches.
      expect(kRuleShariClosedSeason.closedSeasons.single.citation, kCitationMd580);
    });
  });

  group('Landing', () {
    test('carries a length in millimetres and the method it was taken by', () {
      // SPEC.md §4.2: the method comes from the active rule row, so a reading
      // without one cannot be compared.
      const l = Landing(lengthMm: 380, method: MeasurementMethod.totalLength);
      expect(l.lengthMm, 380);
      expect(l.method, MeasurementMethod.totalLength);
    });

    test('carries a null length when the fish was not measured', () {
      const l = Landing(lengthMm: null, method: null);
      expect(l.lengthMm, isNull);
    });
  });

  test('rule_engine barrel exports every model', () {
    // FLUTTER_GUIDE.md §2.6 allows exactly one barrel and the app imports only
    // through it. A model reachable only by an src/ path is a private type the
    // mapper cannot use. Naming all seven here is the assertion.
    expect(<Object?>[
      kCitationMd580,
      MeasurementMethod.totalLength,
      kSpeciesHamour,
      kZoneRasAlKhaimah,
      kRuleShariClosedSeason.closedSeasons.single,
      kRuleHamourMinSize,
      const Landing(lengthMm: 1, method: null),
    ], hasLength(7));
  });
}
