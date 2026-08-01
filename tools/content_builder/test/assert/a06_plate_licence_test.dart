// A6 — a plate is cleared on the illustrator's death year, never on a
// publication date.
//
// SPEC.md §8 corrects the first draft in one line: "pre-1930 = public domain" is
// the US rule and is the wrong test for every market this app ships to. The term
// is the longest in the bundle — Spain's TRLPI transitional regime gives 80
// years pma to authors who died before 7 December 1987, outliving the EU's and
// Brazil's 70 and the UAE's 50.
//
// The boundary matters more than the rule. For a 2026 build, 1945 clears and
// 1946 does not, and a `>=` in place of `>` ships every plate a year early.

import 'dart:io';

import 'package:content_builder/src/assert/a06_plate_licence.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/plate_spec.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

const String kPlatesPath = 'content/shared/plates.yaml';

/// [relative] resolved against the repository root.
///
/// `dart test` runs with the package directory as its working directory, so the
/// root is two levels up from `tools/content_builder`.
String repoPath(String relative) => '../../$relative';
const String kSpeciesPath = 'content/shared/species.yaml';

ContentSource corpusOf(Map<String, String> files) => ContentSource(
  sources: <YamlSource>[
    for (final MapEntry<String, String> e in files.entries)
      YamlSource.fromString(e.value, displayPath: e.key),
  ],
  failures: const <Failure>[],
);

List<Failure> a6(Map<String, String> files, {int buildYear = 2026}) =>
    PlateLicenceAssertion(buildYear: buildYear).run(corpusOf(files)).toList();

List<Failure> a6Plate(String yaml, {int buildYear = 2026}) =>
    a6(<String, String>{kPlatesPath: yaml}, buildYear: buildYear);

/// A plate whose illustrator died in [deathYear].
PlateSpec plateDied(int? deathYear) => PlateSpec(
  path: kPlatesPath,
  line: 2,
  id: 'bloch-epinephelus',
  speciesId: 'venerupis-corrugata',
  asset: 'plate/bloch-epinephelus.webp',
  origin: 'public_domain',
  illustrator: 'Marcus Elieser Bloch',
  illustratorDeathYear: deathYear,
);

void main() {
  group('termFor', () {
    test('returns 80 for a death year of 1987', () {
      // The TRLPI transitional boundary, on the boundary.
      expect(termFor(1987), 80);
    });

    test('returns 70 for a death year of 1988', () {
      expect(termFor(1988), 70);
    });
  });

  group('clearToBundle', () {
    test('clears an illustrator who died in 1945 for a 2026 build', () {
      // 1945 + 80 = 2025, and 2026 > 2025. The last year that clears.
      expect(clearToBundle(plateDied(1945), 2026), isTrue);
    });

    test('rejects an illustrator who died in 1946 for a 2026 build', () {
      // 1946 + 80 = 2026, and 2026 > 2026 is false. The off-by-one that would
      // ship a plate a year early.
      expect(clearToBundle(plateDied(1946), 2026), isFalse);
    });

    test('clears an illustrator who died in 1946 for a 2027 build', () {
      // The ratchet works, and it works because the year is input.
      expect(clearToBundle(plateDied(1946), 2027), isTrue);
    });

    test('clears Bloch, died 1799', () {
      // licence-provenance.md's worked bundled decision: 1799 + 80 = 1879.
      expect(clearToBundle(plateDied(1799), 2026), isTrue);
    });

    test('rejects an illustrator who died in 1958', () {
      // The worked rejected decision: 1958 + 70 = 2028, still in copyright in
      // the EU and Brazil.
      expect(clearToBundle(plateDied(1958), 2026), isFalse);
    });

    test('rejects a plate with no death year at all', () {
      // An unknown death year is not an early one.
      expect(clearToBundle(plateDied(null), 2026), isFalse);
    });
  });

  group('PlateLicenceAssertion', () {
    test('reports A6 when illustrator is absent', () {
      final List<Failure> failures = a6Plate(plateYaml(illustrator: null));

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A6');
      expect(failures.single.render(), endsWith('illustrator unidentified — DROP the plate'));
    });

    for (final value in const <String>['unknown', 'unidentified', 'TBD']) {
      test('reports A6 when illustrator is $value', () {
        // The three strings check_content_pipeline.sh check 3 looks for. The
        // build must not be laxer than the grep.
        final List<Failure> failures = a6Plate(plateYaml(illustrator: value));

        expect(failures, hasLength(1), reason: value);
        expect(failures.single.render(), endsWith('illustrator unidentified — DROP the plate'));
      });
    }

    test('reports A6 when illustrator_death_year is absent', () {
      final List<Failure> failures = a6Plate(plateYaml(deathYear: null));

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('death year'));
    });

    test('reports A6 when a public_domain plate is still in term', () {
      // The commonest real rejection: a credited 20th-century artist.
      final List<Failure> failures = a6Plate(
        plateYaml(illustrator: 'A credited artist', deathYear: 1958),
      );

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('1958'));
    });

    test('accepts a cleared plate', () {
      expect(a6Plate(plateYaml()), isEmpty);
    });

    test('accepts a corpus with no plates at all', () {
      // The Galicia seed ships zero cleared plates and must still build.
      expect(a6Plate(kEmptyPlatesYaml), isEmpty);
    });

    test('skips the death-year test for origin originated', () {
      // Commissioned art has no death year to test — and every diagram for a
      // Brazilian rule is originated, because Lei 9.610 art. 8 IV covers only
      // os textos.
      expect(
        a6Plate(plateYaml(origin: 'originated', illustrator: 'In-house', deathYear: null)),
        isEmpty,
      );
    });

    test('reports A6 when an originated plate has no licence id', () {
      // The ledger row is mandatory for originated art too: S17 renders it, and
      // the licence is the work-for-hire agreement id.
      final List<Failure> failures = a6Plate(
        plateYaml(origin: 'originated', illustrator: 'In-house', deathYear: null, omit: 'licence'),
      );

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('licence'));
    });

    test('reports A6 when origin is outside the two the ledger declares', () {
      final List<Failure> failures = a6Plate(plateYaml(origin: 'public'));

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('public'));
    });

    for (final field in const <String>[
      'species_id',
      'source_work',
      'source_year',
      'source_url',
      'cleared_on',
      'cleared_by',
    ]) {
      test('reports A6 when the ledger field $field is missing', () {
        // An incomplete ledger is an unanswerable S17 row.
        final List<Failure> failures = a6Plate(plateYaml(omit: field));

        expect(failures, hasLength(1), reason: field);
        expect(failures.single.message, contains(field));
      });
    }

    test('reports one failure per missing ledger field, not one per block', () {
      // The author is going to fix all six.
      final List<Failure> failures = a6Plate(
        'plates:\n  - id: bloch-epinephelus\n    origin: public_domain\n'
        '    illustrator: Marcus Elieser Bloch\n    illustrator_death_year: 1799\n',
      );

      expect(failures.length, greaterThanOrEqualTo(6));
    });

    test('reports A6 when a species names a plate_asset with no cleared block', () {
      // The dangling reference a drop leaves behind.
      final List<Failure> failures = a6(<String, String>{
        kPlatesPath: kEmptyPlatesYaml,
        kSpeciesPath: speciesWithPlate('plate/bloch-epinephelus.webp'),
      });

      expect(failures, hasLength(1));
      expect(failures.single.path, kSpeciesPath);
      expect(failures.single.message, contains('plate/bloch-epinephelus.webp'));
    });

    test('accepts a species with a null plate_asset', () {
      // §7.1 makes the column optional, and the Galicia seed relies on that.
      expect(
        a6(<String, String>{kPlatesPath: kEmptyPlatesYaml, kSpeciesPath: speciesWithPlate(null)}),
        isEmpty,
      );
    });

    test('accepts a species whose plate_asset names a cleared block', () {
      expect(
        a6(<String, String>{
          kPlatesPath: plateYaml(),
          kSpeciesPath: speciesWithPlate('plate/bloch-epinephelus.webp'),
        }),
        isEmpty,
      );
    });

    test('reports A6 when there is no build year to test against', () {
      // A licence check that silently skips is worse than one that fails. The
      // corpus can be loaded outside a build; A6 cannot run there.
      final List<Failure> failures = const PlateLicenceAssertion()
          .run(corpusOf(<String, String>{kPlatesPath: plateYaml()}))
          .toList();

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('build year'));
    });

    test('takes the build year from the corpus when none was given', () {
      final source = ContentSource(
        sources: <YamlSource>[
          YamlSource.fromString(
            plateYaml(illustrator: 'A credited artist', deathYear: 1946),
            displayPath: kPlatesPath,
          ),
        ],
        failures: const <Failure>[],
        buildDate: DateTime.utc(2027, 1, 1),
      );

      expect(const PlateLicenceAssertion().run(source), isEmpty, reason: '2027 clears 1946');
    });

    test('.id is A6', () {
      expect(const PlateLicenceAssertion().id, 'A6');
    });
  });

  group('the publication-date test', () {
    test('appears nowhere in content_builder or in the corpus', () {
      // check_content_pipeline.sh check 7 greps for a publication year compared
      // against a 1930 threshold, and its variants. Proved by the suite as well
      // as by the gate, because a gate that is not run is a gate that is not
      // there — and this one is the difference between a bundled plate and an
      // infringement claim.
      //
      // The phrasing above is deliberate: writing the banned comparison out in
      // full, even in a comment, trips check 7 on this very file. Reworded
      // rather than exempted — an escape hatch on the test that proves the ban
      // would be the ban proving itself.
      //
      // source_year stays in the ledger as EVIDENCE about the artist and is
      // never compared to a threshold.
      final usRule = RegExp(
        r'(published_?[Yy]ear|publication_?year|pub_?year|source_?[Yy]ear)'
        r'[^A-Za-z0-9]{0,4}[<>][^=]?\s*(19|20)\d{2}',
      );
      final scanned = <File>[
        for (final String dir in <String>['tools/content_builder/lib', 'content'])
          ...Directory(repoPath(dir))
              .listSync(recursive: true)
              .whereType<File>()
              .where((File f) => f.path.endsWith('.dart') || f.path.endsWith('.yaml')),
      ];

      expect(scanned, isNotEmpty, reason: 'a scan of nothing is not a proof');
      for (final file in scanned) {
        expect(
          usRule.hasMatch(file.readAsStringSync()),
          isFalse,
          reason: '${file.path} compares a publication year to a threshold',
        );
      }
    });
  });

  group('renderPlateLedger', () {
    test('lists every cleared plate with its illustrator and death year', () {
      // SPEC.md §8: every plate's illustrator and death year is recorded and
      // rendered in S17. Generated, so it cannot drift from the data.
      final String ledger = renderPlateLedger(corpusOf(<String, String>{kPlatesPath: plateYaml()}));

      expect(ledger, contains('bloch-epinephelus'));
      expect(ledger, contains('Marcus Elieser Bloch'));
      expect(ledger, contains('1799'));
      expect(ledger, contains('venerupis-corrugata'));
    });

    test('renders an empty ledger without pretending there are plates', () {
      final String ledger = renderPlateLedger(
        corpusOf(<String, String>{kPlatesPath: kEmptyPlatesYaml}),
      );

      expect(ledger, contains('No plates'));
    });

    test('sorts by species then plate id', () {
      // Two renders of one corpus must be byte-identical, and directory walk
      // order is not a sort. The ledger is part of what T10's rebuild produces.
      const twoPlates = '''
plates:
  - id: zz-second
    species_id: aaa-first-species
    asset: plate/zz.webp
    origin: public_domain
    illustrator: Bloch
    illustrator_death_year: 1799
    source_work: Ichthyologie
    source_year: 1795
    source_url: https://example.org/zz
    licence: public-domain-pma-80
    cleared_on: '2026-08-12'
    cleared_by: Z. Fatahi
  - id: aa-first
    species_id: zzz-last-species
    asset: plate/aa.webp
    origin: public_domain
    illustrator: Cuvier
    illustrator_death_year: 1832
    source_work: Histoire naturelle des poissons
    source_year: 1828
    source_url: https://example.org/aa
    licence: public-domain-pma-80
    cleared_on: '2026-08-12'
    cleared_by: Z. Fatahi
''';
      final String ledger = renderPlateLedger(corpusOf(<String, String>{kPlatesPath: twoPlates}));

      expect(ledger.indexOf('aaa-first-species'), lessThan(ledger.indexOf('zzz-last-species')));
      expect(ledger, contains('Cuvier'));
      expect(ledger, contains('1832'));
    });

    test('is deterministic across two renders of the same corpus', () {
      // T10 requires a byte-identical rebuild; the ledger is part of what a
      // rebuild produces.
      final ContentSource source = corpusOf(<String, String>{kPlatesPath: plateYaml()});

      expect(renderPlateLedger(source), renderPlateLedger(source));
    });
  });
}
