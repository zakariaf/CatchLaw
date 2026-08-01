// A2 — every `*_key` resolves in all six locales, or the build dies.
//
// There is no build-time fallback, and that does not contradict SPEC.md §9.2's
// runtime chain. The chain — requested locale, jurisdiction default, en,
// scientific name — exists for locale SELECTION, not for gaps in the corpus. If
// the build let en stand in for ca, a Catalan speaker would be served Spanish
// law in English and nobody would ever see a defect.

import 'package:content_builder/src/assert/a02_locale_coverage.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/locales.dart';
import 'package:content_builder/src/model/content_row.dart';
import 'package:content_builder/src/model/regulation.dart';
import 'package:content_builder/src/model/rows.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

const String kSharedStrings = 'content/shared/strings.yaml';
const String kZonesPath = 'content/es-ga/zones.yaml';

ContentSource corpusOf(Map<String, String> files) => ContentSource(
  sources: <YamlSource>[
    for (final MapEntry<String, String> e in files.entries)
      YamlSource.fromString(e.value, displayPath: e.key),
  ],
  failures: const <Failure>[],
);

List<Failure> a2(Map<String, String> files) =>
    const LocaleCoverageAssertion().run(corpusOf(files)).toList();

/// A corpus whose one zone references `zone.rias_baixas`, defined by [strings].
Map<String, String> referencedBy(String strings) => <String, String>{
  kSharedStrings: strings,
  kZonesPath: zoneReferencing('zone.rias_baixas'),
};

void main() {
  group('LocaleCoverageAssertion', () {
    for (final String locale in kShippedLocales) {
      test('reports A2 when a key is missing for $locale', () {
        // Every locale is load-bearing. A loop that named only the first would
        // prove nothing at all about pt_BR.
        final List<Failure> failures = a2(
          referencedBy(stringsMissingLocale('zone.rias_baixas', locale)),
        );

        expect(failures, hasLength(1));
        expect(failures.single.id, 'A2');
        expect(failures.single.message, contains(locale));
      });
    }

    test('names every missing locale in one failure', () {
      // Five failures for one key buries the twenty other keys.
      final List<Failure> failures = a2(
        referencedBy(
          stringsYaml(<String, Map<String, String>>{
            'zone.rias_baixas': <String, String>{'en': 'Rías Baixas'},
          }),
        ),
      );

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('ar, ca, es, gl, pt_BR'));
    });

    test('accepts a key defined in all six locales', () {
      expect(a2(referencedBy(completeStringsYaml('zone.rias_baixas'))), isEmpty);
    });

    test('reports A2 at the referencing row when a key is defined nowhere', () {
      // The author fixes the reference or adds the key, and needs to see which
      // row asked. Pointing at strings.yaml would name the file that is
      // correct.
      final List<Failure> failures = a2(<String, String>{
        kSharedStrings: completeStringsYaml('zone.rias_baixas'),
        kZonesPath: zoneReferencing('family.ghost'),
      });

      expect(failures, hasLength(1));
      expect(failures.single.path, kZonesPath);
      expect(failures.single.message, contains('family.ghost'));
    });

    test('reports A2 when a value is the empty string', () {
      // An empty value resolves, renders, and puts a blank line under the
      // verdict stamp. Blank is not a verdict.
      expect(a2(referencedBy(stringsWithValue('zone.rias_baixas', 'ca', ''))), hasLength(1));
    });

    test('reports A2 when a value is whitespace only', () {
      expect(a2(referencedBy(stringsWithValue('zone.rias_baixas', 'ca', '   '))), hasLength(1));
    });

    test('reports A2 when a value equals its own key', () {
      // The placeholder that looks like a translation: `ca: gear.trawl`
      // resolves, renders, and reads as a Catalan gear name to a build.
      expect(
        a2(referencedBy(stringsWithValue('zone.rias_baixas', 'ca', 'zone.rias_baixas'))),
        hasLength(1),
      );
    });

    test('reports A2 when a content_string key begins legal_text.', () {
      // SPEC.md §9.6: verbatim law is bundled in the language the authority
      // published it in. An unofficial translation of a penal instrument is a
      // liability and falls outside Spain's Art. 13 LPI carve-out, which covers
      // OFFICIAL translations only.
      final List<Failure> failures = a2(<String, String>{
        kSharedStrings: completeStringsYaml('legal_text.dog_2012_art4'),
      });

      expect(failures.single.message, contains('legal_text'));
    });

    for (final MapEntry<String, String> nullable in const <String, String>{
      'notes_key': 'rules',
      'constraint_key': 'gear_rules',
      'secondary_key': 'penalties',
      'detail_key': 'changes',
    }.entries) {
      test('covers ${nullable.value}.${nullable.key} when it is present', () {
        // Nullable does not mean unchecked. These four are the columns an
        // author sets last and translates never.
        final String yaml = switch (nullable.value) {
          'rules' => ruleReferencing(nullable.key, 'ghost.key'),
          'gear_rules' => gearRuleReferencing(nullable.key, 'ghost.key'),
          'penalties' => penaltyReferencing(nullable.key, 'ghost.key'),
          _ => changeReferencing(nullable.key, 'ghost.key'),
        };
        final List<Failure> failures = a2(<String, String>{
          'content/es-ga/${nullable.value}.yaml': yaml,
          kSharedStrings: stringsYaml(<String, Map<String, String>>{
            for (final String k in <String>[
              'gear.rasco',
              'penalty.undersize',
              'change.es_ga.2026_08',
            ])
              k: allSixValues(k),
          }),
        });

        expect(failures.where((Failure f) => f.message.contains('ghost.key')), hasLength(1));
      });
    }

    test('ignores a nullable *_key column that is absent', () {
      expect(a2(<String, String>{'content/es-ga/rules.yaml': kRuleWithoutNotesKeyYaml}), isEmpty);
    });

    test('reports an unreferenced key as a count and not a failure', () {
      // E22 authors shared glossary and family strings ahead of the rows that
      // use them. Failing here would force a rule and its strings into one
      // commit, which is the opposite of the parallel authoring SPEC.md §15
      // step 19 asks for.
      final ContentSource source = corpusOf(<String, String>{
        kSharedStrings: stringsYaml(<String, Map<String, String>>{
          'zone.rias_baixas': allSixValues('zone.rias_baixas'),
          'family.veneridae': allSixValues('family.veneridae'),
        }),
        kZonesPath: zoneReferencing('zone.rias_baixas'),
      });

      expect(const LocaleCoverageAssertion().run(source), isEmpty);
      expect(unreferencedKeys(source), <String>['family.veneridae']);
    });

    test('reports A2 when the same key is defined in two files', () {
      // Two definitions means the winner depends on directory walk order, which
      // is not a translation decision anybody made.
      final List<Failure> failures = a2(<String, String>{
        kSharedStrings: completeStringsYaml('zone.rias_baixas'),
        'content/es-ga/strings.yaml': completeStringsYaml('zone.rias_baixas'),
      });

      expect(failures, hasLength(1));
      expect(failures.single.message, contains(kSharedStrings));
    });

    test('reports A2 when a key carries an unknown locale', () {
      // D-3 removed Urdu. A leftover `ur` block would sit in the corpus looking
      // translated and be served to nobody.
      final List<Failure> failures = a2(
        referencedBy(
          stringsYaml(<String, Map<String, String>>{
            'zone.rias_baixas': <String, String>{
              ...allSixValues('zone.rias_baixas'),
              'ur': 'ریاس بائشاس',
            },
          }),
        ),
      );

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('ur'));
    });

    test('.id is A2', () {
      expect(const LocaleCoverageAssertion().id, 'A2');
    });
  });

  group('KeyReference emission', () {
    test('covers every *_key column SPEC.md §7.1 declares', () {
      // Twenty-two columns, named by the authoring SECTION rather than the
      // table, because that is the word an author reads. Emitted by walking the
      // typed rows: ContentRow.keyColumns is abstract, so a column added later
      // is a compile error in the model rather than a reference nobody checks.
      const declared = <String>{
        'jurisdiction.name_key',
        'jurisdiction.authority_key',
        'zones.name_key',
        'families.name_key',
        'measurement_methods.name_key',
        'measurement_methods.definition_key',
        'citations.instrument_type_key',
        'rules.notes_key',
        'closed_seasons.notes_key',
        'licence_types.name_key',
        'licence_types.description_key',
        'gear_rules.gear_name_key',
        'gear_rules.constraint_key',
        'penalties.offence_key',
        'penalties.secondary_key',
        'lookalikes.difference_key',
        'glossary_terms.term_key',
        'glossary_terms.definition_key',
        'changes.summary_key',
        'changes.detail_key',
        'key_nodes.question_key',
        'key_options.label_key',
      };
      final YamlRow bare = YamlSource.fromString(
        'rules:\n  - id: es-ga-r-001\n',
        displayPath: 'content/es-ga/rules.yaml',
      ).rows.single;

      final emitted = <String>{
        for (final MapEntry<String, RowBuilder> entry in kRowBuilders.entries)
          for (final String column in entry.value(bare).keyColumns.keys) '${entry.key}.$column',
      };

      expect(emitted, declared);
    });

    test('skips a nullable *_key column that was not authored', () {
      final YamlRow bare = YamlSource.fromString(
        'rules:\n  - id: es-ga-r-001\n',
        displayPath: 'content/es-ga/rules.yaml',
      ).rows.single;

      expect(RuleRow.fromRow(bare).keyReferences, isEmpty);
    });
  });

  group('the authored strings.yaml shape', () {
    test('matches the definition pattern check 1 greps for', () {
      // check_content_pipeline.sh builds its DEFS set from lines matching
      // `^\s*(- )?key:`. A tidier mapping — `family.veneridae: {ar: …}` — would
      // leave DEFS empty and make check 1 report every reference in the corpus
      // as undefined. D-2's rule of thumb: the gate script beats the prose.
      final definition = RegExp(r'''^[ \t]*(- )?key:[ \t]*["']?[A-Za-z0-9_.-]+''', multiLine: true);

      expect(definition.allMatches(completeStringsYaml('family.veneridae')), hasLength(1));
    });
  });

  group('kShippedLocales', () {
    test('holds exactly ar, ca, en, es, gl and pt_BR', () {
      // D-3. catchlaw-content-pipeline rule 4 and build-assertions.md both list
      // `ur`; Urdu appears nowhere in SPEC.md and has no bundled instrument,
      // and Catalan ships because Catalonia, Valencia and the Balearics publish
      // their fishing orders in Catalan.
      expect(kShippedLocales, <String>['ar', 'ca', 'en', 'es', 'gl', 'pt_BR']);
    });

    test('is sorted, so a missing-locale message reads the same every run', () {
      expect(kShippedLocales, orderedEquals(<String>[...kShippedLocales]..sort()));
    });
  });
}
