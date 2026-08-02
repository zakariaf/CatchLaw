import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'arb_rules.dart';

Map<String, String> _fixture(String name) => loadArbDir('test/l10n/fixtures/$name');

void main() {
  test('requiredCategoriesFor returns all six ICU categories for ar', () {
    expect(requiredCategoriesFor('ar'), <String>{'zero', 'one', 'two', 'few', 'many', 'other'});
  });

  test('requiredCategoriesFor returns one, many and other for es', () {
    expect(requiredCategoriesFor('es'), <String>{'one', 'many', 'other'});
  });

  test('requiredCategoriesFor returns one, many and other for ca', () {
    expect(requiredCategoriesFor('ca'), <String>{'one', 'many', 'other'});
  });

  test('requiredCategoriesFor returns one, many and other for pt_BR', () {
    expect(requiredCategoriesFor('pt_BR'), <String>{'one', 'many', 'other'});
  });

  test('requiredCategoriesFor returns one, many and other for pt', () {
    expect(requiredCategoriesFor('pt'), <String>{'one', 'many', 'other'});
  });

  test('requiredCategoriesFor returns one and other for gl', () {
    expect(requiredCategoriesFor('gl'), <String>{'one', 'other'});
  });

  test('requiredCategoriesFor returns one and other for en', () {
    expect(requiredCategoriesFor('en'), <String>{'one', 'other'});
  });

  test('requiredCategoriesFor throws ArgumentError for an unshipped locale', () {
    expect(() => requiredCategoriesFor('ur'), throwsArgumentError);
  });

  test('missingCategories reports many when app_es.arb omits it', () {
    final List<ArbFinding> findings = missingCategories(_fixture('missing_many_es'));
    expect(findings, hasLength(1));
    expect(findings.single.locale, 'es');
    expect(findings.single.key, 'searchResultCount');
    expect(findings.single.categories, <String>{'many'});
  });

  test(
    'missingCategories reports zero, two and few when app_ar.arb carries only one, many and other',
    () {
      final List<ArbFinding> findings = missingCategories(_fixture('ar_from_es'));
      expect(findings, hasLength(1));
      expect(findings.single.locale, 'ar');
      expect(findings.single.key, 'searchResultCount');
      expect(findings.single.categories, <String>{'zero', 'two', 'few'});
    },
  );

  test('missingCategories ignores a key with no plural argument', () {
    // Every fixture carries a plain `appTitle`. A checker that reported it
    // would be switched off within a week.
    expect(
      missingCategories(_fixture('exact_zero_branch')).map((ArbFinding f) => f.key),
      isNot(contains('appTitle')),
    );
  });

  test('missingCategories accepts an =0 branch alongside the required categories', () {
    expect(missingCategories(_fixture('exact_zero_branch')), isEmpty);
  });

  test('missingCategories reports every offending locale, not only the first', () {
    final List<ArbFinding> findings = missingCategories(_fixture('two_broken'));
    expect(findings.map((ArbFinding f) => f.locale), containsAll(<String>['ar', 'es']));
  });

  test('unexpectedCategories reports few when app_gl.arb carries it', () {
    final List<ArbFinding> findings = unexpectedCategories(_fixture('gl_with_few'));
    expect(findings, hasLength(1));
    expect(findings.single.locale, 'gl');
    expect(findings.single.categories, <String>{'few'});
  });

  test('unexpectedCategories ignores an exact-value branch', () {
    expect(unexpectedCategories(_fixture('exact_zero_branch')), isEmpty);
  });

  test('loadArbDir throws StateError when it is handed a directory with no ARB files', () {
    // CONVENTIONS.md §7: a gate that scans an empty tree reports success, and
    // that is the failure mode that makes a gate worse than none. Built here
    // rather than committed, because git cannot track an empty directory — and
    // a committed `.gitkeep` would make the fixture a file the checker might
    // one day learn to read.
    final Directory empty = Directory.systemTemp.createTempSync('catchlaw_arb_empty');
    addTearDown(() => empty.deleteSync(recursive: true));
    expect(() => loadArbDir(empty.path), throwsStateError);
  });

  test('ArbFinding renders the locale, the key and the categories', () {
    // The gate's whole value at 18:00 on a Friday is that the message names
    // what to open.
    const finding = ArbFinding(
      locale: 'ar',
      key: 'searchResultCount',
      categories: <String>{'few', 'two'},
    );
    expect(finding.toString(), contains('app_ar.arb'));
    expect(finding.toString(), contains('searchResultCount'));
    expect(finding.toString(), contains('few'));
  });
}
