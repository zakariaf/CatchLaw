// Every parsed row keeps the file it came from and its 1-based line.
//
// The failure format in build-assertions.md is
// `A1 content/rules.yaml:118 min_size without measurement_method`. An author
// fixes that in seconds and fixes `A1: invalid rule` in an afternoon. An
// off-by-one is worse than no line at all: it sends them to the row above,
// which is usually fine, and they conclude the tool is wrong.

import 'dart:io';

import 'package:content_builder/src/load/yaml_source.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

YamlSource sourceOf(String yaml) =>
    YamlSource.fromString(yaml, displayPath: 'content/es-ga/rules.yaml');

void main() {
  group('YamlSource', () {
    test('.fromString records the 1-based line of every row', () {
      expect(sourceOf(kThreeRuleRowsYaml).rows.map((YamlRow r) => r.line), <int>[2, 5, 8]);
    });

    test('.fromString reports the display path it was given', () {
      // An inline fixture must render a failure identically to a file-backed
      // row, or the fixtures prove the message and not the build.
      expect(sourceOf(kThreeRuleRowsYaml).rows.first.path, 'content/es-ga/rules.yaml');
    });

    test('.fromString tags every row with its section', () {
      expect(
        sourceOf(kThreeRuleRowsYaml).rows.map((YamlRow r) => r.section),
        everyElement('rules'),
      );
    });

    test('.fromString reads a row field by its SQL column name', () {
      final YamlRow row = sourceOf(kGaliciaRulesYaml).rows.single;

      expect(row.string('species_id'), 'venerupis-corrugata');
      expect(row.integer('min_size_mm'), 38);
      expect(row.has('measurement_method_id'), isTrue);
      expect(row.has('bag_limit'), isFalse);
    });

    test('.fromString parses a clean document with no failures', () {
      expect(sourceOf(kThreeRuleRowsYaml).failures, isEmpty);
    });

    test('.fromString reports a section holding a scalar instead of rows', () {
      final YamlSource source = sourceOf(kSectionIsNotAListYaml);

      expect(source.rows, isEmpty);
      expect(source.failures.single.line, 1);
    });

    test('.fromString reports a row that is not a mapping', () {
      expect(sourceOf(kRowIsNotAMappingYaml).failures.single.line, 2);
    });

    test('.fromString reports a row carrying no id', () {
      // Every downstream reference — citation_id, species_id, the changelog
      // diff — resolves through the id. A row without one cannot be named in
      // any later failure message either.
      expect(sourceOf(kRowWithoutIdYaml).failures.single.message, contains('id'));
    });

    test('.fromFile reports a parse error with file and line', () {
      // A YamlException reaching the top level prints a stack trace naming the
      // loader, which tells the author nothing about their document.
      final Directory dir = Directory.systemTemp.createTempSync('content_builder_yaml_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/rules.yaml')..writeAsStringSync(kMalformedYaml);

      final source = YamlSource.fromFile(file, displayPath: 'content/es-ga/rules.yaml');

      expect(source.rows, isEmpty);
      expect(source.failures.single.path, 'content/es-ga/rules.yaml');
      expect(source.failures.single.line, 3);
    });

    test('.fromFile reads the rows of a well-formed file', () {
      final Directory dir = Directory.systemTemp.createTempSync('content_builder_yaml_');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/rules.yaml')..writeAsStringSync(kThreeRuleRowsYaml);

      expect(YamlSource.fromFile(file, displayPath: 'content/es-ga/rules.yaml').rows, hasLength(3));
    });
  });
}
