import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../policy/repo_root.dart';

/// The banned lexicon, in the language each family is written in.
///
/// **Carried here and not imported from the skill**, because the skill's copy is
/// the law and this is a test of the shipped strings against it — a test that
/// read its expectations out of the same file the author edits would pass by
/// construction the first time somebody edited both.
const List<String> _imperatives = <String>[
  'keep it',
  'return it',
  'release it',
  'throw it back',
  'put it back',
  'toss it back',
  'land it',
  'do not keep',
  'discard',
  'retain',
];

const List<String> _secondPerson = <String>[
  'you ',
  'your ',
  'you may',
  'you can',
  'you must',
  'it is legal to',
  'allowed to',
  'permitted to',
  'feel free',
];

const List<String> _inference = <String>[
  'probably',
  'most likely',
  'appears to',
  'seems to',
  'counts as',
  'close enough',
  'we think',
];

const List<String> _softenedAbsence = <String>[
  'no restrictions',
  'nothing applies',
  'no rules apply',
  'all clear',
  'good to go',
];

const List<String> _health = <String>[
  'safe to eat',
  'edible',
  'inedible',
  'poisonous',
  'venomous',
  'ciguatera',
  'mercury level',
];

/// The Arabic imperative is one short fluent word, and no English-language
/// pattern will ever see it.
const List<String> _arabicBanned = <String>[
  'احتفظ',
  'أعِدْه',
  'أعده',
  'ارمه',
  'أطلقه',
  'يمكنك',
  'بإمكانك',
];

const List<String> _spanishBanned = <String>['devuélvalo', 'que lo devuelva', 'puede quedárselo'];
const List<String> _galicianBanned = <String>['devólvao', 'pode quedar con', 'bótao'];
const List<String> _catalanBanned = <String>['torna-la', 'pots quedar-te', 'llença'];
const List<String> _portugueseBanned = <String>['pode ficar com ele', 'devolva', 'jogue de volta'];

/// The six languages D-3 ships, and the seven files D-18 requires.
const List<String> _locales = <String>['ar', 'ca', 'en', 'es', 'gl', 'pt', 'pt_BR'];

/// Every key of the four families the contract governs.
bool _isGoverned(String key) =>
    key.startsWith('verdict') ||
    key.startsWith('finding') ||
    key.startsWith('citation') ||
    key.startsWith('disclaimer');

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File(repoFile('app/lib/l10n/app_$locale.arb').path).readAsStringSync())
        as Map<String, dynamic>;

Map<String, String> _governedValues(String locale) => <String, String>{
  for (final MapEntry<String, dynamic> e in _arb(locale).entries)
    if (!e.key.startsWith('@') && _isGoverned(e.key) && e.value is String) e.key: e.value as String,
};

void main() {
  test('the ARB directory holds the seven files D-3 and D-18 require', () {
    final List<String> found =
        Directory(repoDir('app/lib/l10n').path)
            .listSync()
            .whereType<File>()
            .map((File f) => f.uri.pathSegments.last)
            .where((String n) => n.startsWith('app_') && n.endsWith('.arb'))
            .map((String n) => n.substring(4, n.length - 4))
            .toList()
          ..sort();

    // Six languages, seven files: `pt` is the toolchain-required base D-18
    // records, and `ur` was removed by D-3.
    expect(found, _locales);
    expect(found, isNot(contains('ur')));
  });

  for (final String locale in _locales) {
    test('$locale - every governed ARB value is a statement of fact', () {
      final Map<String, String> values = _governedValues(locale);
      expect(values, isNotEmpty, reason: 'a scan over no keys is not evidence about any of them');

      for (final MapEntry<String, String> entry in values.entries) {
        final String lower = entry.value.toLowerCase();
        for (final banned in <String>[
          ..._imperatives,
          ..._secondPerson,
          ..._inference,
          ..._softenedAbsence,
          ..._health,
        ]) {
          expect(lower.contains(banned), isFalse, reason: '${entry.key}: "$banned"');
        }
      }
    });
  }

  test('ar - no Arabic imperative or second person reaches a governed value', () {
    for (final MapEntry<String, String> entry in _governedValues('ar').entries) {
      for (final String banned in _arabicBanned) {
        expect(entry.value.contains(banned), isFalse, reason: '${entry.key}: "$banned"');
      }
    }
  });

  for (final (String locale, List<String> banned) in <(String, List<String>)>[
    ('es', _spanishBanned),
    ('gl', _galicianBanned),
    ('ca', _catalanBanned),
    ('pt', _portugueseBanned),
    ('pt_BR', _portugueseBanned),
  ]) {
    test('$locale - no imperative or permission verb reaches a governed value', () {
      for (final MapEntry<String, String> entry in _governedValues(locale).entries) {
        final String lower = entry.value.toLowerCase();
        for (final token in banned) {
          expect(lower.contains(token), isFalse, reason: '${entry.key}: "$token"');
        }
      }
    });
  }

  test('the no-rule wording keeps both sentences, verbatim, in every locale', () {
    for (final String locale in _locales) {
      final String value = _governedValues(locale)['verdictNoRuleRecorded']!;
      // Losing the second sentence turns a gap in the reference database into a
      // permission, which is the failure the whole key exists to prevent.
      expect(
        value.split(RegExp(r'[.。]')).where((String s) => s.trim().isNotEmpty),
        hasLength(2),
        reason: locale,
      );
    }
  });

  test('every measurement statement names its method and both numbers', () {
    for (final key in const <String>[
      'verdictBelowMinimum',
      'verdictMeetsMinimum',
      'verdictAboveMaximum',
      'verdictWithinMaximum',
    ]) {
      for (final String locale in _locales) {
        final String value = _governedValues(locale)[key]!;
        // Kanaad is 65 cm FORK length: an unnamed method is a confident wrong
        // verdict, and a single number is one the reader cannot check.
        expect(value, contains('{measured}'), reason: '$locale/$key');
        expect(value, contains('{threshold}'), reason: '$locale/$key');
        expect(value, contains('({method})'), reason: '$locale/$key');
      }
    }
  });

  test('every governed key exists in all seven files', () {
    final Set<String> template = _governedValues('en').keys.toSet();
    expect(template, isNotEmpty);

    for (final String locale in _locales) {
      // A missing key ships English inside a legal statement, which reads as a
      // translation nobody checked rather than as a bug.
      expect(_governedValues(locale).keys.toSet(), template, reason: locale);
    }
  });

  test('every governed key in the template ships the STATEMENT OF FACT constraint', () {
    final Map<String, dynamic> template = _arb('en');
    var checked = 0;
    for (final String key in template.keys.where((String k) => !k.startsWith('@'))) {
      if (!key.startsWith('verdict') && !key.startsWith('finding')) continue;
      final meta = template['@$key'] as Map<String, dynamic>?;
      expect(meta, isNotNull, reason: key);
      // Rule 12: the constraint travels WITH the key to the translator, because
      // the description is the only defence against a fluent imperative.
      expect(meta!['description'] as String, startsWith('STATEMENT OF FACT.'), reason: key);
      checked++;
    }
    expect(checked, greaterThan(20));
  });

  test('every locale file carries the constraint for its own translator', () {
    for (final String locale in _locales.where((String l) => l != 'en')) {
      // D-19: exactly one block per locale file, and it exists to put the
      // constraint in front of the person editing that file.
      final meta = _arb(locale)['@verdictBelowMinimum'] as Map<String, dynamic>?;
      expect(meta, isNotNull, reason: locale);
      expect(meta!['description'] as String, startsWith('STATEMENT OF FACT.'), reason: locale);
    }
  });
}
