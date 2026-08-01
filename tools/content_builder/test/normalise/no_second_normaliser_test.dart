// The grep the gate cannot reliably do, run over our own source, in our own
// suite.
//
// check_content_pipeline.sh check 4 exempts `packages/shared/` and
// `/catchlaw_shared/`. D-1's workspace has neither, and the normaliser lives in
// packages/rule_engine — OUTSIDE that exemption. So a green check 4 here means
// the grep found nothing it recognises, not that no second normaliser exists.
// This test is what proves it.

import 'dart:io';

import 'package:test/test.dart';

/// Every Dart file of this package's `lib/`.
List<File> get libSources => Directory(
  'lib',
).listSync(recursive: true).whereType<File>().where((File f) => f.path.endsWith('.dart')).toList();

/// [file]'s source with every comment line removed.
String codeOf(File file) =>
    file.readAsLinesSync().where((String line) => !line.trimLeft().startsWith('//')).join('\n');

void main() {
  group('content_builder', () {
    test('declares no normalisation function of its own', () {
      // The same names check 4 looks for, plus the assignment shape. A second
      // implementation drifts by one codepoint and the Arabic search silently
      // returns nothing — there is no error state for it, because "no such
      // species" is a valid answer.
      final declaration = RegExp(
        r'String\s+(normalise|normalize|normalizeForSearch|stripDiacritics|foldArabic)\s*\(',
      );
      final handRolled = RegExp(r'searchNorm\s*=\s*[a-zA-Z_.]*\.(toLowerCase|replaceAll)\(');

      expect(libSources, isNotEmpty, reason: 'a scan of nothing is not a proof');
      for (final File file in libSources) {
        final String source = codeOf(file);
        expect(declaration.hasMatch(source), isFalse, reason: '${file.path} declares a normaliser');
        expect(handRolled.hasMatch(source), isFalse, reason: '${file.path} rolls its own fold');
      }
    });

    test('imports normaliseSpeciesTerm from package:rule_engine', () {
      // Positive proof to go with the negative. An absent import and an absent
      // second normaliser look identical to a grep.
      final String source = File('lib/src/normalise/norm_columns.dart').readAsStringSync();

      expect(source, contains("import 'package:rule_engine/rule_engine.dart'"));
      expect(source, contains('normaliseSpeciesTerm'));
      expect(source, contains('indexKeys'));
    });

    test('routes every *_norm column through NormColumns', () {
      // One caller, one function. A column populated somewhere else is a second
      // normaliser wearing an import.
      //
      // Comments stripped before matching. model/taxon.dart and
      // a07_norm_parity.dart both NAME the function in prose — one to say
      // search_norm is computed rather than authored, the other to explain why
      // parity accepts two keys — and those notes are exactly what should be
      // there. The test is about code.
      final call = RegExp(r'normaliseSpeciesTerm\s*\(');
      final Iterable<File> offenders = libSources.where((File f) {
        if (f.path.endsWith('norm_columns.dart')) return false;
        return call.hasMatch(codeOf(f));
      });

      expect(offenders.map((File f) => f.path), isEmpty);
    });
  });
}
