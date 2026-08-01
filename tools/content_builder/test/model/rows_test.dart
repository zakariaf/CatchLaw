// The seam between the authoring format and SPEC.md §7.1.
//
// A section with no builder is the quietest defect this package can have: the
// rows parse, they carry a file and a line, they satisfy every assertion, and
// the emitter simply does not write them. A whole jurisdiction's gear rules can
// go missing without one failure line. So the correspondence is asserted, in
// both directions, rather than maintained by eye.

import 'package:content_builder/src/load/authoring_format.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/content_row.dart';
import 'package:content_builder/src/model/regulation.dart';
import 'package:content_builder/src/model/rows.dart';
import 'package:content_builder/src/model/taxon.dart';
import 'package:content_builder/src/model/text.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

Set<String> get declaredSections => <String>{
  for (final Set<String> s in kSharedFiles.values) ...s,
  for (final Set<String> s in kJurisdictionFiles.values) ...s,
};

YamlRow rowOf(String yaml) =>
    YamlSource.fromString(yaml, displayPath: 'content/es-ga/rules.yaml').rows.first;

void main() {
  group('kRowBuilders', () {
    test('covers every section the authoring format declares', () {
      expect(declaredSections.difference(kRowBuilders.keys.toSet()), isEmpty);
    });

    test('declares no builder for a section no file may hold', () {
      // The other direction, and the one that rots quietly: a builder for a
      // section nobody can author reads as support for a feature that does not
      // exist.
      expect(kRowBuilders.keys.toSet().difference(declaredSections), isEmpty);
    });

    test('has no entry for content_meta', () {
      // Its three rows come from --build-date and --generator-commit. Authoring
      // them would let the file disagree with the run that produced it.
      expect(kRowBuilders.containsKey('content_meta'), isFalse);
    });
  });

  group('RuleRow', () {
    test('.fromRow reads the §7.1 columns by their SQL names', () {
      final rule = RuleRow.fromRow(rowOf(kGaliciaRulesYaml));

      expect(rule.id, 'es-ga-r-001');
      expect(rule.speciesId, 'venerupis-corrugata');
      expect(rule.zoneId, 'es-ga-rias-baixas');
      expect(rule.waterType, 'salt');
      expect(rule.minSizeMm, 38);
      expect(rule.measurementMethodId, 'SHL');
      expect(rule.citationId, 'es-ga-orde-2012-07-27-anexo-ii');
      expect(rule.validFrom, '2012-08-01');
    });

    test('.fromRow keeps the file and line the row was authored on', () {
      final rule = RuleRow.fromRow(rowOf(kGaliciaRulesYaml));

      expect(rule.path, 'content/es-ga/rules.yaml');
      expect(rule.line, 2);
    });

    test('.fromRow leaves an unauthored column null rather than defaulting it', () {
      // A1 decides what a missing column means, at load, where the message can
      // carry the line. A default here would answer the question before the
      // assertion got to ask it.
      final rule = RuleRow.fromRow(rowOf(kGaliciaRulesYaml));

      expect(rule.maxSizeMm, isNull);
      expect(rule.bagLimit, isNull);
      expect(rule.validTo, isNull, reason: 'expiry tags; it is not a default');
    });

    test('.fromRow does not validate', () {
      // The constructor must never throw. A row with two defects reports two
      // failures, and a throwing constructor reports the first and hides the
      // rest.
      expect(() => RuleRow.fromRow(rowOf(kThreeRuleRowsYaml)), returnsNormally);
    });
  });

  group('SpeciesRow', () {
    test('.fromRow reads the §7.1 columns by their SQL names', () {
      final YamlRow row = YamlSource.fromString(
        kSharedSpeciesYaml,
        displayPath: 'content/shared/species.yaml',
      ).rows.single;
      final species = SpeciesRow.fromRow(row);

      expect(species.scientificName, 'Venerupis corrugata');
      expect(species.familyId, 'veneridae');
      expect(species.taxonGroup, 'bivalve');
      expect(species.silhouetteAsset, 'sil/venerupis-corrugata.svg');
      expect(species.plateAsset, isNull);
    });
  });

  group('ContentStringRow', () {
    test('.fromRow collects one locale per authored field', () {
      // One row per key carrying all six locales, so a key missing one is
      // visible in the diff and not only in A2's output.
      const yaml = '''
strings:
  - id: closure.venerupis.spring
    ar: موسم مغلق
    en: Closed season
    es: Veda
    gl: Veda
    ca: Veda
    pt_BR: Defeso
''';
      final YamlRow row = YamlSource.fromString(
        yaml,
        displayPath: 'content/es-ga/strings.yaml',
      ).rows.single;
      final string = ContentStringRow.fromRow(row);

      expect(string.key, 'closure.venerupis.spring');
      expect(string.values.keys, <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR']);
      expect(string.values['gl'], 'Veda');
    });
  });

  group('ContentRow', () {
    test('every builder produces a row carrying its own file and line', () {
      // Provenance is not per-model courtesy; it is the failure format. A
      // builder that dropped it would print `A1 :0` and send nobody anywhere.
      final YamlRow row = rowOf(kGaliciaRulesYaml);

      for (final MapEntry<String, RowBuilder> entry in kRowBuilders.entries) {
        final ContentRow built = entry.value(row);
        expect(built.path, row.path, reason: entry.key);
        expect(built.line, row.line, reason: entry.key);
      }
    });
  });
}
