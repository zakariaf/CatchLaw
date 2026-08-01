// A1 — every row validates against its SPEC.md §7.1 constraint.
//
// §8 bullet 1 names one build error: a rule with `min_size_mm` and no
// `measurement_method_id`. The reason is that TL and FL differ by 6-9 cm on a
// Scomberomorus commerson, so an inferred method turns a legal fish into a fine
// and a fine into a false acquittal. Exactly the same argument covers
// water_type, zone_kind, bag_limit_period and the rest: a value outside the
// CHECK set either aborts the insert with a message about SQLite rather than
// about the row, or is silently coerced by a lenient author.
//
// Validation runs at LOAD, not at insert. SQLite would reject the row too —
// after writing every earlier one, with no line number, and naming only the
// first offender.

import 'package:content_builder/src/assert/a01_row_schema.dart';
import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/enums.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

const String kRulesPath = 'content/es-ga/rules.yaml';

ContentSource corpusOf(Map<String, String> files) => ContentSource(
  sources: <YamlSource>[
    for (final MapEntry<String, String> e in files.entries)
      YamlSource.fromString(e.value, displayPath: e.key),
  ],
  failures: const <Failure>[],
);

List<Failure> a1(Map<String, String> files) =>
    const RowSchemaAssertion().run(corpusOf(files)).toList();

List<Failure> a1Rule(String yaml) => a1(<String, String>{kRulesPath: yaml});

void main() {
  group('RowSchemaAssertion', () {
    test('reports A1 when min_size_mm has no measurement_method_id', () {
      final List<Failure> failures = a1Rule(kMinSizeWithoutMethodYaml);

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A1');
      expect(
        failures.single.render(),
        'A1 $kRulesPath:$kFixtureRowLine min_size_mm without measurement_method_id',
      );
    });

    test('reports A1 when max_size_mm has no measurement_method_id', () {
      // A slot rule's upper bound is measured by a method just as much as its
      // lower one is.
      expect(a1Rule(kMaxSizeWithoutMethodYaml), hasLength(1));
    });

    test('accepts a rule with min_size_mm and a measurement_method_id', () {
      // An assertion with no green path fails everything, which is
      // indistinguishable from an assertion nobody wrote.
      expect(a1Rule(kMinSizeWithMethodYaml), isEmpty);
    });

    test('reports A1 when max_size_mm is below min_size_mm', () {
      expect(a1Rule(kMaxBelowMinYaml), hasLength(1));
    });

    test('reports A1 when a protected row carries a size threshold', () {
      // The precedence ladder headlines `protected`, so the size would never be
      // read — and a measurement implies a threshold that does not exist.
      expect(a1Rule(kProtectedWithSizeYaml), hasLength(1));
    });

    for (final value in <String>['salt', 'fresh', 'both', 'marine']) {
      test('reports A1 when water_type is outside the §7.1 set (water_type:$value)', () {
        // `marine` is what a careful author writes and §7.1 does not accept.
        expect(a1Rule(kRuleWithWaterType(value)), value == 'marine' ? hasLength(1) : isEmpty);
      });
    }

    test('names the offending value and the legal set when water_type is wrong', () {
      final List<Failure> failures = a1Rule(kRuleWithWaterType('marine'));

      expect(failures.single.message, contains('marine'));
      expect(failures.single.message, contains('salt'));
    });

    test('reports A1 when zone_kind is outside the §7.1 set', () {
      // Six kinds drive the specificity ladder; a seventh has no rank, so the
      // resolver cannot order it against anything.
      expect(
        a1(<String, String>{'content/es-ga/zones.yaml': kZoneWithZoneKind('sector')}),
        hasLength(1),
      );
    });

    test('accepts every §7.1 zone_kind', () {
      for (final ZoneKind kind in ZoneKind.values) {
        expect(
          a1(<String, String>{'content/es-ga/zones.yaml': kZoneWithZoneKind(kind.sql)}),
          isEmpty,
          reason: kind.sql,
        );
      }
    });

    test('reports A1 when taxon_group is outside the §7.1 set', () {
      // §7.1 splits molluscs into bivalve, gastropod and cephalopod. Collapsing
      // them loses the identification key's entry point.
      expect(
        a1(<String, String>{'content/shared/species.yaml': kSpeciesWithTaxonGroup('mollusc')}),
        hasLength(1),
      );
    });

    test('reports A1 when gender is outside the §7.1 set', () {
      expect(
        a1(<String, String>{'content/shared/vernacular.yaml': kSpeciesNameWithGender('neuter')}),
        hasLength(1),
      );
    });

    test('reports A1 when a bag_limit has no unit', () {
      // "5" per what — count or kilograms?
      expect(a1Rule(kBagLimitWithoutUnitYaml), hasLength(2), reason: 'unit and period');
      expect(a1Rule(kBagLimitWithoutUnitYaml).first.message, contains('bag_limit_unit'));
    });

    test('reports A1 when a bag_limit has no period', () {
      // Per day, per trip and per season are three different limits.
      final List<Failure> failures = a1Rule(kBagLimitWithoutPeriodYaml);

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('bag_limit_period'));
    });

    test('reports A1 when a closed_season has no start or end', () {
      // A closure with no window applies for zero days or for ever, and both are
      // wrong.
      expect(
        a1(<String, String>{'content/es-ga/closed_seasons.yaml': kAnnualSeasonWithoutBoundsYaml}),
        hasLength(1),
      );
    });

    test('reports A1 when a closed_season starts on 02-29', () {
      // Three years in four there is no such date, and the engine would have to
      // invent 02-28 or 03-01 — either of which adds or removes a day of closure
      // no instrument declared.
      expect(
        a1(<String, String>{'content/es-ga/closed_seasons.yaml': kSeasonOnLeapDayYaml}),
        hasLength(1),
      );
    });

    test('reports A1 when an annual closure wraps the year without wraps_year', () {
      // A wrapping closure is legal and an inverted one is a typo, and the two
      // look identical. Declared, never inferred from end < start.
      expect(
        a1(<String, String>{'content/es-ga/closed_seasons.yaml': kWrappingSeasonYaml}),
        hasLength(1),
      );
    });

    test('accepts a wrapping closure with wraps_year true', () {
      expect(
        a1(<String, String>{'content/es-ga/closed_seasons.yaml': kWrappingSeasonDeclaredYaml}),
        isEmpty,
      );
    });

    test('reports A1 when a fixed closed_season has no dates', () {
      expect(
        a1(<String, String>{'content/es-ga/closed_seasons.yaml': kFixedSeasonWithoutDatesYaml}),
        hasLength(1),
      );
    });

    test('reports A1 when a fixed closed_season ends before it starts', () {
      expect(
        a1(<String, String>{'content/es-ga/closed_seasons.yaml': kInvertedFixedSeasonYaml}),
        hasLength(1),
      );
    });

    test('accepts a fixed closed_season spanning a year boundary', () {
      // A fixed window carries both years explicitly, so December to February
      // needs no wraps_year and must not be read as inverted.
      expect(a1(<String, String>{'content/es-ga/closed_seasons.yaml': kFixedSeasonYaml}), isEmpty);
    });

    test('reports A1 once when a closed_season names no recurrence', () {
      // The recurrence decides which pair of columns is required, so a row
      // without one cannot be checked further. One failure, not four about
      // bounds nobody could have known to author.
      final List<Failure> failures = a1(<String, String>{
        'content/es-ga/closed_seasons.yaml': kSeasonWithoutRecurrenceYaml,
      });

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('recurrence'));
    });

    test('reports A1 when a closed_season ends on 02-29', () {
      // The closing bound is a date in one year of four just as much as the
      // opening one is.
      expect(
        a1(<String, String>{'content/es-ga/closed_seasons.yaml': kSeasonEndingOnLeapDayYaml}),
        hasLength(1),
      );
    });

    test('reports A1 once when a closed_season names an unknown recurrence', () {
      // The set check has already named the value; checking bounds against a
      // recurrence nobody recognises would add a second, invented failure.
      final List<Failure> failures = a1(<String, String>{
        'content/es-ga/closed_seasons.yaml': kSeasonWithUnknownRecurrenceYaml,
      });

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('monthly'));
    });

    test('accepts a February closure bounded on the 28th', () {
      // The near miss: the leap-day check is about the 29th, not about
      // February, and a whole month of legal closures sits next to it.
      expect(
        a1(<String, String>{'content/es-ga/closed_seasons.yaml': kFebruaryClosureYaml}),
        isEmpty,
      );
    });

    test('accepts a section it holds no constraint for', () {
      // A1 owns the §7.1 CHECK constraints and nothing else. Citations are A4's,
      // and a row A1 cannot judge must pass through it rather than be guessed at.
      expect(a1(<String, String>{'content/es-ga/citations.yaml': kCitationYaml}), isEmpty);
    });

    test('reports A1 when valid_from is after valid_to', () {
      // A dead validity window is always a typo, and the engine would resolve
      // nothing at all for that citation lineage.
      expect(a1Rule(kDeadValidityWindowYaml), hasLength(1));
    });

    test('reports A1 when a finfish min_size_mm is under 100', () {
      // 45 cm typed as 45 mm. The row validates and the verdict is wrong by a
      // factor of ten.
      expect(
        a1(<String, String>{
          kRulesPath: kRuleWithMinSize(45),
          'content/shared/species.yaml': kSpeciesInGroup('finfish'),
        }),
        hasLength(1),
      );
    });

    test('accepts a bivalve min_size_mm of 38', () {
      // Venerupis corrugata is genuinely 38 mm shell length. The range check is
      // scoped by taxon_group, which §7.1 already requires.
      expect(
        a1(<String, String>{
          kRulesPath: kRuleWithMinSize(38),
          'content/shared/species.yaml': kSpeciesInGroup('bivalve'),
        }),
        isEmpty,
      );
    });

    test('accepts a finfish min_size_mm under 100 with min_size_mm_confirmed', () {
      // The audited escape. Without it the check would eventually be deleted
      // rather than answered, and there is no warning tier to put it in.
      expect(
        a1(<String, String>{
          kRulesPath: kRuleWithMinSize(90, confirmed: true),
          'content/shared/species.yaml': kSpeciesInGroup('finfish'),
        }),
        isEmpty,
      );
    });

    for (final MeasurementCode code in MeasurementCode.values) {
      test('accepts the §7.1 measurement code ${code.sql}', () {
        // The build validates against all nine. check_content_pipeline.sh
        // check 5 recognises four; the build is authoritative.
        expect(a1Rule(kRuleWithMeasurementCode(code.sql)), isEmpty, reason: code.sql);
      });
    }

    test('reports A1 when a measurement_method_id is outside the §7.1 set', () {
      expect(a1Rule(kRuleWithMeasurementCode('LENGTH')), hasLength(1));
    });

    test('reports every failure in one pass, sorted by file then line', () {
      // One build round-trip must tell the author everything wrong with the
      // corpus. SQLite would report only the first, after writing the rest.
      //
      // Through runAllAssertions, because the sort is the registry's job and not
      // each assertion's: ten assertions each sorting their own output would
      // give ten sorted blocks and one unsorted build log.
      final List<Failure> failures = runAllAssertions(
        corpusOf(<String, String>{
          'content/es-ga/zones.yaml': kZoneWithZoneKind('sector'),
          kRulesPath: kTwoBrokenRuleRowsYaml,
        }),
      );

      expect(failures.map((Failure f) => '${f.path}:${f.line}'), <String>[
        'content/es-ga/rules.yaml:4',
        'content/es-ga/rules.yaml:11',
        'content/es-ga/zones.yaml:4',
      ]);
    });

    test('reports both defects on a row that has two', () {
      // No early return. A row with two problems reports two failures, or the
      // author fixes one and runs the build again to find the other.
      final List<Failure> failures = a1Rule(
        ruleYaml('    min_size_mm: 500\n    max_size_mm: 450\n    water_type: marine'),
      );

      expect(
        failures,
        hasLength(4),
        reason: 'bad water_type, min without method, max without method, max below min',
      );
    });

    test('.id is A1', () {
      expect(const RowSchemaAssertion().id, 'A1');
    });
  });

  group('kAssertions', () {
    test('registers A1 first', () {
      expect(kAssertions.first.id, 'A1');
    });
  });
}
