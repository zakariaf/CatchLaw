import 'dart:convert';
import 'dart:io';

import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const List<Locale> _locales = <Locale>[
  Locale('ar'),
  Locale('en'),
  Locale('es'),
  Locale('gl'),
  Locale('ca'),
  Locale('pt'),
  Locale('pt', 'BR'),
];

/// The `select` branch keys. ICU keys are canonical lowercase identifiers, so
/// the Brazilian one is `ptBR` rather than the ARB filename's `pt_BR`.
const List<String> _codes = <String>['ar', 'en', 'es', 'gl', 'ca', 'ptBR'];

String _tag(Locale l) =>
    l.countryCode == null ? l.languageCode : '${l.languageCode}_${l.countryCode}';

void main() {
  for (final Locale locale in _locales) {
    final String tag = _tag(locale);

    test('$tag - languageName resolves all six shipped language codes', () async {
      // 36 cells across six files. A missing `select` branch renders the ICU
      // `other` fallback, which reads as a bug in exactly one language pair —
      // the one nobody develops in.
      final AppLocalizations l10n = await AppLocalizations.delegate.load(locale);
      final names = <String>[for (final code in _codes) l10n.languageName(code)];
      expect(names.toSet(), hasLength(6), reason: 'names=$names');
      expect(
        names.any(_codes.contains),
        isFalse,
        reason: 'a raw code means a missing select branch: $names',
      );
    });

    test('$tag - legalTextLanguageNotice contains no imperative', () async {
      // Invariant 2 has no exemption for a helpful notice
      // (product-invariants.md §2). A translator writing natural Spanish will
      // reach for an imperative unless the @description says not to.
      const banned = <String>['keep', 'return', 'release', 'switch to', 'change your'];
      final AppLocalizations l10n = await AppLocalizations.delegate.load(locale);
      final String notice = l10n.legalTextLanguageNotice(l10n.languageName('ar')).toLowerCase();
      for (final word in banned) {
        expect(notice, isNot(contains(word)), reason: '$tag: "$word"');
      }
    });
  }

  test('ar - legalTextLanguageNotice names Galician in Arabic', () async {
    // The concrete cell that proves the select is wired end to end rather than
    // passing the raw code through.
    final AppLocalizations ar = await AppLocalizations.delegate.load(const Locale('ar'));
    final String notice = ar.legalTextLanguageNotice(ar.languageName('gl'));
    expect(notice, isNot(contains('gl')));
    expect(notice, contains(ar.languageName('gl')));
    expect(ar.languageName('gl'), isNot(equals('Galego')));
  });

  test('legalTextLanguageNotice declares language as a typed String placeholder', () {
    // An untyped placeholder generates `Object`, which lets a raw Locale be
    // spliced in — and that prints `gl`.
    final template =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync()) as Map<String, dynamic>;
    final meta = template['@legalTextLanguageNotice'] as Map<String, dynamic>;
    final placeholders = meta['placeholders'] as Map<String, dynamic>;
    expect((placeholders['language'] as Map<String, dynamic>)['type'], 'String');
  });
}
