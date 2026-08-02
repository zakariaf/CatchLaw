/// The plural-category rules for the locales CatchLaw ships, and the checker
/// that holds every ARB file to them.
///
/// A helper, deliberately not named `_test.dart`: a helper with that suffix is
/// executed as a suite of zero tests and fails the run (`CONVENTIONS.md` §6).
///
/// Key and placeholder parity is **not** here. That is a general Flutter rule
/// with a maintained implementation in `i18n-rtl-l10n/scripts/check_arb_parity.sh`,
/// and `catchlaw-conventions-index` rule 10 forbids forking a general rule into
/// this repository — a fork drifts from its origin within two pull requests.
/// What lives here is the part no plugin checks: which CLDR categories each of
/// these six languages requires.
library;

import 'dart:convert';
import 'dart:io';

/// One locale's one message, and what it is short of or carrying spuriously.
class ArbFinding {
  /// Records [categories] against [key] in the ARB file for [locale].
  const ArbFinding({required this.locale, required this.key, required this.categories});

  /// The ARB suffix — `ar`, `pt_BR`, and so on.
  final String locale;

  /// The message key, as authored.
  final String key;

  /// The ICU categories at issue.
  final Set<String> categories;

  @override
  String toString() {
    final List<String> sorted = categories.toList()..sort();
    return 'app_$locale.arb / $key: ${sorted.join(", ")}';
  }
}

/// The CLDR categories a plural message must declare in [locale].
///
/// The table's only source is `SPEC.md` §9.5, twice corrected against CLDR 48:
/// `ar` carries all six; `es`, `ca` and Portuguese each carry `many`; only `gl`
/// and `en` are `one`/`other`. The argument is in the spec and is not restated
/// here.
///
/// Throws an [ArgumentError] for anything else. A silent empty set would mean
/// an unshipped locale passed every check ever run against it.
Set<String> requiredCategoriesFor(String locale) => switch (locale) {
  'ar' => const <String>{'zero', 'one', 'two', 'few', 'many', 'other'},
  'es' || 'ca' || 'pt' || 'pt_BR' => const <String>{'one', 'many', 'other'},
  'gl' || 'en' => const <String>{'one', 'other'},
  _ => throw ArgumentError.value(locale, 'locale', 'not a locale CatchLaw ships (D-3, D-18)'),
};

/// Every `app_*.arb` under [path], keyed by its locale suffix.
///
/// Throws a [StateError] when it finds none. `CONVENTIONS.md` §7: a gate that
/// scans an empty tree reports success, and a green tick meaning "I found
/// nothing" is the same pixel as one meaning "I looked at nothing".
Map<String, String> loadArbDir(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    throw StateError('no such ARB directory: $path');
  }
  final name = RegExp(r'^app_(\w+)\.arb$');
  final byLocale = <String, String>{};
  for (final FileSystemEntity e in dir.listSync()) {
    if (e is! File) continue;
    final RegExpMatch? m = name.firstMatch(e.uri.pathSegments.last);
    if (m != null) byLocale[m.group(1)!] = e.readAsStringSync();
  }
  if (byLocale.isEmpty) {
    throw StateError('no app_*.arb files under $path — nothing was checked');
  }
  return byLocale;
}

/// Categories [requiredCategoriesFor] demands that a message does not declare.
///
/// Accumulates across every locale and every key before returning. A checker
/// that stopped at the first failure would hide five locales behind one
/// message, and the fifth is the one nobody develops in.
List<ArbFinding> missingCategories(Map<String, String> arbByLocale) => _scan(
  arbByLocale,
  (Set<String> required, Set<String> declared) => required.difference(declared),
);

/// Categories a message declares that its locale has no rule for.
///
/// A `few` branch in `app_gl.arb` is inert — CLDR `gl` never selects it — and
/// it is a fingerprint: it means the file was copied from `app_ar.arb`, which
/// makes the other branches suspect too.
List<ArbFinding> unexpectedCategories(Map<String, String> arbByLocale) => _scan(
  arbByLocale,
  (Set<String> required, Set<String> declared) => declared.difference(required),
);

List<ArbFinding> _scan(
  Map<String, String> arbByLocale,
  Set<String> Function(Set<String> required, Set<String> declared) diff,
) {
  final findings = <ArbFinding>[];
  final List<String> locales = arbByLocale.keys.toList()..sort();
  for (final locale in locales) {
    final Set<String> required = requiredCategoriesFor(locale);
    final arb = jsonDecode(arbByLocale[locale]!) as Map<String, dynamic>;
    final List<String> keys = arb.keys.where((String k) => !k.startsWith('@')).toList()..sort();
    for (final key in keys) {
      final Object? value = arb[key];
      if (value is! String) continue;
      final Set<String> declared = pluralBranchesIn(value);
      // A key with no plural argument is not a plural message. Reporting one
      // is how a gate gets switched off.
      if (declared.isEmpty) continue;
      // `=0` and `=1` are exact-value matches. They win over category branches
      // and exist for special copy, so they are legal extras on any locale —
      // never a substitute for a category, never an unexpected one.
      final Set<String> categories = declared.where((String b) => !b.startsWith('=')).toSet();
      final Set<String> found = diff(required, categories);
      if (found.isNotEmpty) {
        findings.add(ArbFinding(locale: locale, key: key, categories: found));
      }
    }
  }
  return findings;
}

final RegExp _pluralStart = RegExp(r'\{\s*\w+\s*,\s*plural\s*,');

/// The branch names of every `plural` argument in [message].
///
/// Parsed rather than greped. `{count, plural, few{…} many{…} other{…}}` cannot
/// be matched by a regex without either a false positive on the word `many`
/// inside a translation or a false negative on a nested placeholder, and a
/// checker that calls a parser a grep is the small inaccuracy D-8 exists to
/// avoid.
Set<String> pluralBranchesIn(String message) {
  final branches = <String>{};
  for (final RegExpMatch start in _pluralStart.allMatches(message)) {
    int i = start.end;
    while (i < message.length) {
      i = _skipWhitespace(message, i);
      if (i >= message.length || message[i] == '}') break;
      // ICU's optional `offset:n` clause is not a branch.
      if (message.startsWith('offset:', i)) {
        i = _skipWhitespace(message, _skipToken(message, i));
        continue;
      }
      final nameStart = i;
      i = _skipToken(message, i);
      final String name = message.substring(nameStart, i);
      i = _skipWhitespace(message, i);
      if (i >= message.length || message[i] != '{') break;
      final int close = _matchingBrace(message, i);
      if (close < 0) break;
      if (name.isNotEmpty) branches.add(name);
      i = close + 1;
    }
  }
  return branches;
}

int _skipWhitespace(String s, int i) {
  while (i < s.length && s[i].trim().isEmpty) {
    i++;
  }
  return i;
}

int _skipToken(String s, int i) {
  while (i < s.length && s[i] != '{' && s[i] != '}' && s[i].trim().isNotEmpty) {
    i++;
  }
  return i;
}

int _matchingBrace(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    if (s[i] == '{') depth++;
    if (s[i] == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  return -1;
}
