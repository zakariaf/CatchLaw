// A3 — a vernacular name in a gendered locale carries its gender, and exactly
// one name per (species, locale) is the primary one.
//
// SPEC.md §9.5 records the first draft's defect precisely: ICU `select` was
// specified on a gender field that existed nowhere in the schema. The correction
// is that the column exists AND is guaranteed populated — a `select` on a null
// argument renders the `other` branch, which in Spanish is one of the two
// genders and is therefore wrong half the time.

import 'package:content_builder/src/assert/a03_gender.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/locales.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

const String kVernacularPath = 'content/shared/vernacular.yaml';

List<Failure> a3(List<NameSpec> names) => const GenderAssertion()
    .run(
      ContentSource(
        sources: <YamlSource>[
          YamlSource.fromString(vernacularYaml(names), displayPath: kVernacularPath),
        ],
        failures: const <Failure>[],
      ),
    )
    .toList();

void main() {
  group('GenderAssertion', () {
    for (final String locale in kGenderedLocales) {
      test('reports A3 when gender is null for $locale', () {
        // Five locales, five chances to be wrong. A loop naming only `es`
        // proves nothing at all about `ca`.
        final List<Failure> failures = a3(<NameSpec>[name(locale, gender: null)]);

        expect(failures, hasLength(1));
        expect(failures.single.id, 'A3');
        expect(failures.single.message, 'gender null for locale $locale');
      });
    }

    test('accepts a null gender for en', () {
      // The Catalogue of Life vernacular extension is the sole source for
      // English and supplies no gender. Forcing one would mean inventing it.
      expect(a3(<NameSpec>[name('en', gender: null)]), isEmpty);
    });

    for (final value in <String>['m', 'f', 'n']) {
      test('accepts gender $value', () {
        // SPEC.md §7.1's CHECK set, not the skill's narrower m|f. The schema is
        // authoritative, and a locale added later may need the neuter.
        expect(a3(<NameSpec>[name('es', gender: value)]), isEmpty, reason: value);
      });
    }

    test('reports A3 when gender is outside the §7.1 set', () {
      // The value an author writes when copying from a dictionary.
      final List<Failure> failures = a3(<NameSpec>[name('es', gender: 'fem')]);

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('fem'));
    });

    for (final String locale in kShippedLocales) {
      test('reports A3 when a species has no is_primary name for $locale', () {
        // S5's result row has no name to print, in a locale nobody tested.
        final List<Failure> failures = a3(<NameSpec>[
          name(locale, isPrimary: false),
          name(locale, isPrimary: false),
        ]);

        expect(failures.where((Failure f) => f.message.contains('is_primary')), hasLength(1));
      });
    }

    test('reports A3 when a species has two is_primary names for one locale', () {
      // The result screen prints one and the species list prints the other, and
      // the fisher sees two fish.
      final List<Failure> failures = a3(<NameSpec>[name('gl'), name('gl')]);

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('is_primary'));
      expect(failures.single.message, contains('2'), reason: 'names the second line');
    });

    test('accepts exactly one is_primary name per species and locale', () {
      expect(
        a3(<NameSpec>[name('gl'), name('gl', isPrimary: false), name('gl', isPrimary: false)]),
        isEmpty,
      );
    });

    test('counts is_primary per locale and not per species', () {
      // One primary in each of two locales is correct and must not read as two
      // primaries for the species.
      expect(a3(<NameSpec>[name('gl'), name('es')]), isEmpty);
    });

    test('reports one failure per offending row, not per species', () {
      // An author fixing a paste of thirty names needs all thirty lines.
      final List<Failure> failures = a3(<NameSpec>[
        name('gl', gender: null),
        name('es', gender: null),
        name('ca', gender: null),
      ]);

      expect(failures.where((Failure f) => f.message.startsWith('gender null')), hasLength(3));
    });

    test('reports the line of the offending row', () {
      // The first row opens on line 2; each row is six lines with a gender and
      // five without.
      final List<Failure> failures = a3(<NameSpec>[name('gl', gender: null)]);

      expect(failures.single.path, kVernacularPath);
      expect(failures.single.line, 2);
    });

    test('.id is A3', () {
      expect(const GenderAssertion().id, 'A3');
    });
  });

  group('kGenderedLocales', () {
    test('holds exactly ar, ca, es, gl and pt_BR', () {
      // Written out rather than derived as kShippedLocales minus en: a set
      // built by subtraction silently absorbs whatever the seventh locale turns
      // out to be, and a new locale should force a decision about its grammar
      // rather than inherit one.
      expect(kGenderedLocales, <String>{'ar', 'ca', 'es', 'gl', 'pt_BR'});
    });

    test('is every shipped locale but en', () {
      expect(kGenderedLocales, kShippedLocales.toSet().difference(<String>{'en'}));
    });
  });
}
