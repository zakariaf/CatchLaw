// Demonstrates the executable half of the CATCHLAW wording contract in three lanes: (1) a sweep of
// the canonical verdict copy table, (2) a widget lane that pumps the result surface for every state
// and harvests every string that ACTUALLY reaches the UI — Text data and Semantics labels alike —
// asserting no imperative (English OR Arabic), second person, inference hedge or edibility claim
// survives, and (3) an on-disk sweep of every app_*.arb. Also asserts the citation quadruple and
// the verbatim no-rule wording. Wire as a blocking CI gate beside check_verdict_contract.sh.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// --- The lexicon, kept here so the test and check_verdict_contract.sh cannot drift apart. -------
// Catch-handling verbs only: the disclaimer's "Verify with ..." instructs about checking a source,
// not about the fish, and is the one sanctioned imperative anywhere on the surface.

final RegExp _imperative = RegExp(
    r'\b(keep|kept|return|release|discard|retain|toss|land it|put it back|throw it back)\b',
    caseSensitive: false); // verdict-contract-ok — this file exists to assert the ban
final RegExp _secondPerson =
    RegExp(r'\b(you|your|yours|allowed to|permitted to)\b', caseSensitive: false); // ok
final RegExp _inference = RegExp(
    r'\b(probably|likely|should be|appears to|seems|counts as|usually|close enough)\b',
    caseSensitive: false); // verdict-contract-ok
final RegExp _health = RegExp(
    r'\b(safe to eat|edible|poisonous|venomous|ciguatera|scombroid|histamine|mercury)\b',
    caseSensitive: false); // verdict-contract-ok
final RegExp _softened =
    RegExp(r'(no restrictions|nothing applies|all clear|good to go)', caseSensitive: false); // ok
// The Arabic imperative is one fluent word and no English-language grep will ever see it.
final RegExp _arabicImperative =
    RegExp('احتفظ|أعده|أعِدْه|أطلقه|يمكنك|لا تصطد'); // verdict-contract-ok

void expectFactShaped(String where, String s) {
  expect(_imperative.hasMatch(s), isFalse, reason: '$where: imperative verb in "$s"');
  expect(_arabicImperative.hasMatch(s), isFalse, reason: '$where: Arabic imperative in "$s"');
  expect(_secondPerson.hasMatch(s), isFalse, reason: '$where: second person in "$s"');
  expect(_inference.hasMatch(s), isFalse, reason: '$where: inference hedge in "$s"');
  expect(_health.hasMatch(s), isFalse, reason: '$where: edibility/health claim in "$s"');
  expect(_softened.hasMatch(s), isFalse, reason: '$where: softened absence in "$s"');
}

// --- Minimal stand-ins so this file runs standalone; the real ones live in lib/. ----------------

class Citation {
  const Citation({required this.instrument, required this.article, required this.publishedOn,
      required this.checkedOn});
  final String instrument;
  final String article;
  final String publishedOn; // ISO-8601, unlocalised, comparable to the printed instrument by eye
  final String checkedOn;

  String get line => '$instrument, $article · published $publishedOn · checked $checkedOn';
}

const Citation kMd580 = Citation(
    instrument: 'Ministerial Decision 580/2015', article: 'Art. 3',
    publishedOn: '2015-11-03', checkedOn: '2026-07-14');

const String kNoRule = 'No rule recorded for this species here. This does not mean it is legal.';
const String kDisclaimer = 'CatchLaw quotes published instruments. It is not legal advice and does '
    'not authorise any catch. Verify with the Ministry of Climate Change and Environment before '
    'relying on it.';

/// Every statement the result surface is allowed to print, in one place.
const Map<String, String> kVerdictCopy = <String, String>{
  'verdictMeets': 'Meets the minimum — 70 cm measured, minimum 65 cm (fork length)',
  'verdictBelowMinimum': 'Below the minimum — 38 cm measured, minimum 45 cm (total length)',
  'verdictShellBelow': 'Below the minimum — 34 mm measured, minimum 38 mm (shell length)',
  'verdictClosedSeason': 'Closed season — 1 March to 30 April. In force today, day 14 of 61.',
  'verdictProtected': 'Protected species — taking prohibited.',
  'verdictNoRuleRecorded': kNoRule,
  'verdictAmbiguous': 'Two rules of equal standing apply here.',
  'verdictPackExpired': 'Rule data expired 2026-06-30 — still shown, verify before relying on it',
  'disclaimerResult': kDisclaimer,
};

class VerdictSurface extends StatelessWidget {
  const VerdictSurface({required this.statement, required this.citation, this.staleNotice,
      super.key});
  final String statement;
  final Citation citation; // required, non-null: an uncited finding is an opinion
  final String? staleNotice;

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        if (staleNotice != null) Text(staleNotice!),
        Semantics(header: true, label: statement, child: Text(statement)),
        Text(citation.line),
        const Text(kDisclaimer), // structural: no flag, no dismiss, no 'Got it'
      ]);
}

void main() {
  // --- Lane 1: the copy table itself. -----------------------------------------------------------

  group('verdict copy table', () {
    for (final MapEntry<String, String> e in kVerdictCopy.entries) {
      test('${e.key} is a statement of fact', () => expectFactShaped(e.key, e.value));
    }

    test('the no-rule wording keeps BOTH sentences, verbatim', () {
      expect(kVerdictCopy['verdictNoRuleRecorded'], kNoRule);
      expect(kNoRule, contains('This does not mean it is legal.'));
    });

    test('every measurement statement names its method and both numbers', () {
      for (final String k in <String>['verdictMeets', 'verdictBelowMinimum', 'verdictShellBelow']) {
        final String s = kVerdictCopy[k]!;
        expect(s, contains('measured'));
        expect(s, contains('minimum'));
        expect(RegExp(r'\((total length|fork length|carapace width|shell length)\)').hasMatch(s),
            isTrue, reason: '$k names no measurement method');
      }
    });
  });

  // --- Lane 2: what actually reaches the UI. ----------------------------------------------------

  group('rendered result surface', () {
    Iterable<String> rendered(WidgetTester tester) sync* {
      for (final Text t in tester.widgetList<Text>(find.byType(Text))) {
        if (t.data != null) yield t.data!;
      }
      for (final Semantics s in tester.widgetList<Semantics>(find.byType(Semantics))) {
        if (s.properties.label != null) yield s.properties.label!;
      }
    }

    testWidgets('no imperative reaches the UI in any verdict state', (WidgetTester tester) async {
      for (final String statement in kVerdictCopy.values) {
        await tester.pumpWidget(MaterialApp(
            home: VerdictSurface(statement: statement, citation: kMd580,
                staleNotice: kVerdictCopy['verdictPackExpired'])));
        final List<String> strings = rendered(tester).toList();
        expect(strings, isNotEmpty);
        for (final String s in strings) {
          expectFactShaped('rendered', s);
        }
      }
    });

    testWidgets('the citation and the disclaimer are both on screen', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: VerdictSurface(statement: kVerdictCopy['verdictBelowMinimum']!, citation: kMd580)));
      expect(find.textContaining('Ministerial Decision 580/2015'), findsOneWidget);
      expect(find.textContaining('checked 2026-07-14'), findsOneWidget);
      expect(find.text(kDisclaimer), findsOneWidget);
      expect(find.textContaining('Got it'), findsNothing); // no acknowledge affordance
    });
  });

  // --- Lane 3: every app_*.arb on disk, every locale, including app_ar.arb. ----------------------

  test('every ARB verdict value is fact-shaped and carries its constraint', () {
    final Directory dir = Directory('lib/l10n');
    if (!dir.existsSync()) {
      markTestSkipped('lib/l10n not present in this checkout');
      return;
    }
    final Iterable<File> arbs =
        dir.listSync().whereType<File>().where((File f) => f.path.endsWith('.arb'));
    for (final File f in arbs) {
      final Map<String, dynamic> arb = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      arb.forEach((String key, dynamic value) {
        if (key.startsWith('@') || value is! String) return;
        if (!RegExp(r'^(verdict|finding|citation)').hasMatch(key)) return;
        expectFactShaped('${f.path}#$key', value);
        final Object? meta = arb['@$key'];
        expect(meta, isNotNull, reason: '${f.path}#$key has no @description');
        expect(jsonEncode(meta), contains('STATEMENT OF FACT'),
            reason: '${f.path}#$key ships without the wording constraint');
      });
    }
  });
}
