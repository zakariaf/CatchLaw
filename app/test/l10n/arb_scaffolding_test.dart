import 'dart:convert';
import 'dart:io';

import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The six locales of D-3, in the Dart form that actually resolves.
///
/// `Locale('pt_BR')` is a language code containing an underscore. It matches
/// nothing, and it looks right — which is why the shape is asserted rather
/// than assumed.
const List<Locale> kShippedLocales = <Locale>[
  Locale('ar'),
  Locale('en'),
  Locale('es'),
  Locale('gl'),
  Locale('ca'),
  Locale('pt', 'BR'),
];

/// The base fallback `gen-l10n` refuses to build without (D-18).
///
/// Not a seventh language. `gen_l10n_types.dart:753` throws unconditionally
/// when a region locale has no base beside it, and line 662 rejects the dodge
/// of an `@@locale` that disagrees with its filename.
const Locale kPortugueseBase = Locale('pt');

/// The ARB filename suffixes, which are not the Dart locale strings: the
/// Portuguese file carries `pt_BR` with an underscore, the plist `pt-BR` with
/// a hyphen, and the `Locale` neither.
const List<String> kArbSuffixes = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt', 'pt_BR'];

Map<String, dynamic> _arb(String suffix) =>
    jsonDecode(File('lib/l10n/app_$suffix.arb').readAsStringSync()) as Map<String, dynamic>;

void main() {
  test('AppLocalizations.supportedLocales contains ar, en, es, gl, ca and pt_BR', () {
    expect(AppLocalizations.supportedLocales.toSet(), containsAll(kShippedLocales));
  });

  test(
    'AppLocalizations.supportedLocales carries pt as the base beside pt_BR and nothing else',
    () {
      expect(AppLocalizations.supportedLocales.toSet(), <Locale>{
        ...kShippedLocales,
        kPortugueseBase,
      }, reason: 'six languages, seven entries — D-18');
    },
  );

  test('AppLocalizations.supportedLocales excludes ur', () {
    expect(
      AppLocalizations.supportedLocales.map((Locale l) => l.languageCode),
      isNot(contains('ur')),
    );
  });

  test('AppLocalizations.supportedLocales carries pt_BR as language pt with country BR', () {
    // `Locale('pt_BR')` is a language code containing an underscore. It matches
    // nothing, and it looks right — so the region is asserted, not assumed.
    expect(AppLocalizations.supportedLocales, contains(const Locale('pt', 'BR')));
  });

  test('l10n.yaml sets nullable-getter to false', () {
    final String yaml = File('l10n.yaml').readAsStringSync();
    expect(yaml, contains(RegExp(r'^nullable-getter:\s*false\s*$', multiLine: true)));
  });

  for (final String suffix in kArbSuffixes) {
    test('app_$suffix.arb declares @@locale $suffix', () {
      expect(_arb(suffix)['@@locale'], suffix);
    });
  }

  test('app_en.arb is the only ARB carrying @ metadata beyond the verdict constraint', () {
    // D-19. A non-template file carries exactly one block, and only to put the
    // STATEMENT OF FACT constraint in front of the translator of that file:
    // check_verdict_contract.sh check 6b fails any ARB holding a verdict*/finding*
    // key without it, and the Arabic imperative it guards against is one fluent
    // word that no English-language grep can see. Everything else is drift, and
    // still fails here.
    for (final String suffix in kArbSuffixes) {
      final Iterable<String> metadata = _arb(
        suffix,
      ).keys.where((String k) => k.startsWith('@') && k != '@@locale');
      if (suffix == 'en') {
        expect(metadata, isNotEmpty, reason: 'the template declares every @key block');
        continue;
      }
      expect(metadata, <String>[
        '@verdictBelowMinimum',
      ], reason: 'app_$suffix.arb carries metadata that will drift');
      final block = _arb(suffix)['@verdictBelowMinimum']! as Map<String, dynamic>;
      expect(block.keys, <String>[
        'description',
      ], reason: 'a placeholder declared outside the template is a placeholder that drifts');
      expect(
        block['description'],
        startsWith('STATEMENT OF FACT.'),
        reason: 'the one block a locale file carries exists to state the constraint',
      );
    }
  });

  test('Info.plist declares CFBundleLocalizations for all six locales', () {
    final String plist = File('ios/Runner/Info.plist').readAsStringSync();
    final array = RegExp(r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>', dotAll: true);
    final RegExpMatch? match = array.firstMatch(plist);
    expect(match, isNotNull, reason: 'iOS never offers a locale the plist does not declare');
    final Iterable<String> declared = RegExp(
      r'<string>([^<]+)</string>',
    ).allMatches(match!.group(1)!).map((RegExpMatch m) => m.group(1)!);
    // BCP-47 tags here, so `pt-BR` with a hyphen — not the ARB filename.
    expect(declared.toSet(), <String>{'ar', 'en', 'es', 'gl', 'ca', 'pt-BR'});
  });

  // Invariant 2 — product-invariants.md §2, every locale, from the first key.
  test('every ARB value is free of the banned imperative lexicon', () {
    const banned = <String>[
      'keep',
      'return',
      'release',
      'discard',
      'throw it back',
      'put it back',
      'toss',
      'retain',
      'land it',
    ];
    for (final String suffix in kArbSuffixes) {
      final Map<String, dynamic> arb = _arb(suffix);
      for (final MapEntry<String, dynamic> entry in arb.entries.where(
        (MapEntry<String, dynamic> e) => !e.key.startsWith('@'),
      )) {
        final String value = (entry.value as String).toLowerCase();
        for (final word in banned) {
          expect(
            value,
            isNot(contains(word)),
            reason: 'app_$suffix.arb / ${entry.key} contains "$word"',
          );
        }
      }
    }
  });
}
