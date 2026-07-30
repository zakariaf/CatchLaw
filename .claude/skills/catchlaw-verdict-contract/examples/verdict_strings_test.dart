// Demonstrates the executable half of the CATCHLAW wording contract: ONE banned lexicon held as
// const String lists — mirrored by scripts/check_verdict_contract.sh so the two cannot drift —
// swept over three lanes. (1) The canonical verdict copy table is asserted fact-shaped. (2) Every
// app_*.arb on disk is walked — the generated AppLocalizations is compiled from exactly these
// files, so this covers all six locales without gen-l10n having run — and app_ar.arb is checked
// against the Arabic imperatives احتفظ and أعِدْه no English-language grep will ever see. (3) The
// result surface is pumped and every string that ACTUALLY reaches a Text or a Semantics label is
// re-checked, with the citation quadruple and the non-dismissable disclaimer asserted on screen.
// Copy to test/verdict_strings_test.dart. Run: flutter test test/verdict_strings_test.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// --- The lexicon. Catch-handling verbs only: the disclaimer's "Verify with the Ministry ..." is
// an instruction about checking a source, not about the fish — the one sanctioned imperative. ----
const List<String> kImperative = <String>['keep', 'kept', 'return it', 'release it', 'discard',
    'retain', 'toss', 'land it', 'put it back', 'throw it back', 'do not keep']; // contract-ok
const List<String> kSecondPerson = <String>['you', 'your', 'yours', 'allowed to', 'permitted to',
    'free to', 'it is legal to']; // verdict-contract-ok
const List<String> kInference = <String>['probably', 'likely', 'should be', 'appears to', 'seems',
    'similar to', 'counts as', 'usually', 'close enough']; // verdict-contract-ok
const List<String> kHealth = <String>['safe to eat', 'edible', 'poisonous', 'toxic', 'venomous',
    'ciguatera', 'scombroid', 'histamine', 'mercury', 'do not consume']; // verdict-contract-ok
const List<String> kSoftened = <String>['no restrictions', 'nothing applies', 'all clear',
    'good to go', 'check back later']; // verdict-contract-ok

/// Arabic imperatives and second-person forms, substring-matched: word boundaries do not survive
/// the shift out of Latin script, and every one of these is short, fluent, natural Arabic.
const List<String> kArabicBanned = <String>['احتفظ', 'أعِدْه', 'أعده', 'ارمه', 'أطلقه',
    'لا تحتفظ', 'لا تصطد', 'يمكنك', 'بإمكانك']; // verdict-contract-ok

final RegExp _latinBanned = RegExp(
    r'\b(' + <String>[...kImperative, ...kSecondPerson, ...kInference, ...kHealth, ...kSoftened]
        .join('|') + r')\b',
    caseSensitive: false);

/// The first banned token in [s], or null. Latin pass first, then the Arabic substring pass.
String? firstViolation(String s) {
  final RegExpMatch? latin = _latinBanned.firstMatch(s);
  if (latin != null) return latin.group(0);
  for (final String token in kArabicBanned) {
    if (s.contains(token)) return token;
  }
  return null;
}

void expectFactShaped(String where, String s) => expect(firstViolation(s), isNull,
    reason: '$where: banned token in "$s" — a finding states a fact; it never instructs, never '
        'addresses the reader, never infers and never mentions edibility');

// --- Minimal stand-ins so this file runs standalone; the real ones live in lib/. ----------------
class Citation {
  const Citation({required this.instrument, required this.article, required this.publishedOn,
      required this.checkedOn});
  final String instrument, article, publishedOn, checkedOn; // dates ISO-8601, unlocalised
  String get line => '$instrument, $article · published $publishedOn · checked $checkedOn';
}

const Citation kMd580 = Citation(instrument: 'Ministerial Decision 580/2015', article: 'Art. 3',
    publishedOn: '2015-11-03', checkedOn: '2026-07-14');
const String kNoRuleWording =
    'No rule recorded for this species here. This does not mean it is legal.';
const String kDisclaimer = 'CatchLaw quotes published instruments. It is not legal advice and does '
    'not authorise any catch. Verify with the Ministry of Climate Change and Environment before '
    'relying on it.';

const Map<String, String> kVerdictCopy = <String, String>{
  'verdictMeets': 'Meets the minimum — 70 cm measured, minimum 65 cm (fork length)',
  'verdictBelowMinimum': 'Below the minimum — 38 cm measured, minimum 45 cm (total length)',
  'verdictShellBelow': 'Below the minimum — 34 mm measured, minimum 38 mm (shell length)',
  'verdictClosedSeason': 'Closed season — 1 March to 30 April. In force today, day 14 of 61.',
  'verdictProtected': 'Protected species — taking prohibited.',
  'verdictNoRuleRecorded': kNoRuleWording,
  'verdictAmbiguous': 'Two rules of equal standing apply here.',
  'verdictPackExpired': 'Rule data expired 2026-06-30 — still shown, verify before relying on it',
  'disclaimerResult': kDisclaimer,
};

Widget verdictSurface(String statement, Citation citation, {String? staleNotice}) =>
    MaterialApp(home: Column(children: <Widget>[
      if (staleNotice != null) Text(staleNotice),
      Semantics(header: true, label: statement, child: Text(statement)),
      Text(citation.line),
      const Text(kDisclaimer), // structural: no flag, no dismiss path, no 'Got it'
    ]));

void main() {
  // --- Lane 1: the copy table itself. ------------------------------------------------------------
  group('verdict copy table', () {
    for (final MapEntry<String, String> e in kVerdictCopy.entries) {
      test('${e.key} is a statement of fact', () => expectFactShaped(e.key, e.value));
    }
    test('the no-rule wording keeps BOTH sentences, verbatim', () {
      expect(kVerdictCopy['verdictNoRuleRecorded'], kNoRuleWording);
      expect(kNoRuleWording, contains('This does not mean it is legal.'));
    });
    test('every measurement statement names its method and both numbers', () {
      for (final String k in <String>['verdictMeets', 'verdictBelowMinimum', 'verdictShellBelow']) {
        final String s = kVerdictCopy[k]!;
        expect(s, allOf(contains('measured'), contains('minimum')));
        expect(RegExp(r'\((total length|fork length|carapace width|shell length)\)').hasMatch(s),
            isTrue, reason: '$k names no method — 65 cm FORK length is not 65 cm TOTAL length');
      }
    });
  });

  // --- Lane 2: every ARB on disk, every locale. --------------------------------------------------
  test('every app_*.arb verdict value is fact-shaped and ships its constraint', () {
    final Directory dir = Directory('lib/l10n');
    if (!dir.existsSync()) {
      markTestSkipped('lib/l10n not present in this checkout');
      return;
    }
    final List<File> arbs = dir.listSync().whereType<File>()
        .where((File f) => f.path.endsWith('.arb')).toList();
    expect(arbs, isNotEmpty, reason: 'no ARB scanned — the gate would pass vacuously');
    for (final File f in arbs) {
      final Map<String, dynamic> arb = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      arb.forEach((String key, dynamic value) {
        if (key.startsWith('@') || value is! String) return;
        if (!RegExp(r'^(verdict|finding|citation|disclaimer)[A-Z]').hasMatch(key)) return;
        expectFactShaped('${f.path}#$key', value);
        final Object? meta = arb['@$key'];
        expect(meta is Map<String, dynamic> ? meta['description'] : null,
            startsWith('STATEMENT OF FACT.'),
            reason: '${f.path}#$key — the constraint must reach the translator with the key');
      });
    }
  });

  // --- Lane 3: what actually reaches the UI. -----------------------------------------------------
  testWidgets('nothing banned reaches the UI; the citation and disclaimer are on screen',
      (WidgetTester tester) async {
    for (final String statement in kVerdictCopy.values) {
      await tester.pumpWidget(verdictSurface(statement, kMd580,
          staleNotice: kVerdictCopy['verdictPackExpired']));
      final List<String> rendered = <String>[
        for (final Text t in tester.widgetList<Text>(find.byType(Text)))
          if (t.data != null) t.data!,
        for (final Semantics s in tester.widgetList<Semantics>(find.byType(Semantics)))
          if (s.properties.label != null) s.properties.label!,
      ];
      expect(rendered, isNotEmpty);
      for (final String s in rendered) {
        expectFactShaped('rendered', s);
      }
    }
    expect(find.textContaining('Ministerial Decision 580/2015'), findsOneWidget);
    expect(find.textContaining('checked 2026-07-14'), findsOneWidget);
    expect(find.text(kDisclaimer), findsOneWidget);
    expect(find.textContaining('Got it'), findsNothing); // no acknowledge affordance, ever
  });
}
