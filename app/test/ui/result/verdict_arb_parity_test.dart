import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../l10n/arb_rules.dart';
import '../../policy/repo_root.dart';

/// Placeholder names declared for [key] in the template.
Set<String> _placeholders(Map<String, dynamic> arb, String key) {
  final meta = arb['@$key'] as Map<String, dynamic>?;
  final ph = meta?['placeholders'] as Map<String, dynamic>?;
  return ph?.keys.toSet() ?? const <String>{};
}

/// Placeholder names actually USED in a message, `{like}` `{this}`.
Set<String> _used(String message) => RegExp(r'\{(\w+)')
    .allMatches(message)
    .map((RegExpMatch m) => m.group(1)!)
    // ICU branch bodies re-use the argument name; select/plural keywords are not
    // placeholders.
    .where((String name) => name != 'select' && name != 'plural')
    .toSet();

bool _isGoverned(String key) =>
    key.startsWith('verdict') ||
    key.startsWith('finding') ||
    key.startsWith('citation') ||
    key.startsWith('disclaimer');

void main() {
  final Map<String, String> byLocale = loadArbDir(repoDir('app/lib/l10n').path);
  final parsed = <String, Map<String, dynamic>>{
    for (final MapEntry<String, String> e in byLocale.entries)
      e.key: jsonDecode(e.value) as Map<String, dynamic>,
  };
  final Map<String, dynamic> template = parsed['en']!;

  test('the ARB scan covers every shipped locale', () {
    // A gate that scans an empty tree reports success, and a green tick meaning
    // "I found nothing" is the same pixel as one meaning "I looked at nothing".
    expect(parsed.keys.toSet(), <String>{'ar', 'ca', 'en', 'es', 'gl', 'pt', 'pt_BR'});
  });

  for (final String locale in parsed.keys.where((String l) => l != 'en')) {
    test('$locale - every governed message uses the template placeholders', () {
      final Map<String, dynamic> arb = parsed[locale]!;
      var checked = 0;

      for (final String key in template.keys) {
        if (key.startsWith('@') || !_isGoverned(key)) continue;
        final Object? value = arb[key];
        expect(value, isA<String>(), reason: '$locale is missing $key');

        // A renamed placeholder breaks that translation at RUNTIME, in the one
        // locale nobody develops in, inside a sentence about the law.
        expect(_used(value! as String), _placeholders(template, key), reason: '$locale/$key');
        checked++;
      }
      expect(checked, greaterThan(20), reason: 'the governed family is not empty');
    });
  }

  test('no governed message declares a plural branch its locale has no rule for', () {
    // The ar/es/ca/pt category sets are `arb_rules.dart`'s, from SPEC.md §9.5
    // against CLDR 48. A `few` branch in app_gl.arb is inert and is a
    // fingerprint: it means the file was copied from app_ar.arb.
    expect(unexpectedCategories(byLocale), isEmpty);
  });

  test('every plural message declares every category its locale requires', () {
    expect(missingCategories(byLocale), isEmpty);
  });
}
