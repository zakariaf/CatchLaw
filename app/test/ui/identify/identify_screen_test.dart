import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/key_step.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/identify/widgets/identify_screen.dart';
import 'package:catchlaw/ui/identify/widgets/key_lead_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_identification_key_repository.dart';

KeyCandidate _candidate(int id, String name) => KeyCandidate(
  speciesId: id,
  displayName: name,
  scientificName: 'Genus species$id',
  silhouetteAsset: 'sil/species-$id.svg',
);

KeyLead _lead({
  required int optionId,
  required int mark,
  required String label,
  int? nextNodeId,
  List<KeyCandidate> candidates = const <KeyCandidate>[],
  String? figureAsset,
}) => KeyLead(
  optionId: optionId,
  mark: mark,
  label: label,
  figureAsset: figureAsset,
  nextNodeId: nextNodeId,
  candidates: candidates,
);

/// The two-couplet key every traversal row below walks.
///
/// Node 1 asks about the tail and both answers lead on; node 2 asks about the
/// mouth; node 3 is a leaf with two candidates; node 4 is a leaf with one.
Map<int, KeyStep> _key() {
  final forked = <KeyCandidate>[_candidate(1, 'Kanaad'), _candidate(2, 'Zubaidi')];
  final rounded = <KeyCandidate>[_candidate(3, 'Hamour')];
  return <int, KeyStep>{
    1: KeyStep(
      nodeId: 1,
      question: 'Look at the tail fin only.',
      leads: <KeyLead>[
        _lead(
          optionId: 11,
          mark: 1,
          label: 'Deeply forked',
          nextNodeId: 3,
          candidates: forked,
          figureAsset: 'sil/species-1.svg',
        ),
        _lead(
          optionId: 12,
          mark: 2,
          label: 'Rounded or square',
          nextNodeId: 4,
          candidates: rounded,
        ),
      ],
      candidates: <KeyCandidate>[...forked, ...rounded],
    ),
    3: KeyStep(nodeId: 3, question: null, leads: const <KeyLead>[], candidates: forked),
    4: KeyStep(nodeId: 4, question: null, leads: const <KeyLead>[], candidates: rounded),
  };
}

Future<List<int>> _pump(
  WidgetTester tester, {
  Map<int, KeyStep> nodes = const <int, KeyStep>{},
  int? rootNodeId,
  Exception? failure,
  Locale locale = const Locale('en'),
}) async {
  final chosen = <int>[];
  await tester.pumpWidget(
    ProviderScope(
      // Mirrors main(). Without it Riverpod 3 RETRIES a provider whose build
      // threw, with backoff — so a failing read never reaches AsyncError and
      // the screen sits in `loading` forever.
      retry: noRetry,
      overrides: <Override>[
        identificationKeyRepositoryProvider.overrideWithValue(
          FakeIdentificationKeyRepository(nodes: nodes, rootNodeId: rootNodeId, failure: failure),
        ),
      ],
      child: MaterialApp(
        theme: LonjaTheme.paper(),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: IdentifyScreen(onSpeciesChosen: chosen.add),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return chosen;
}

void main() {
  testWidgets('IdentifyScreen asks the first couplet when the pack carries a key', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    expect(find.text('Look at the tail fin only.'), findsOneWidget);
    expect(find.byType(KeyLeadTile), findsNWidgets(2));
  });

  testWidgets('IdentifyScreen stamps its bar with the couplet that is open', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    expect(
      find.descendant(of: find.byType(LonjaScreenBar), matching: find.text('Key · couplet 1')),
      findsOneWidget,
    );
  });

  testWidgets('IdentifyScreen counts what the answers so far still allow', (
    WidgetTester tester,
  ) async {
    // The live count is the whole argument for walking a key rather than
    // scrolling a list: three species at the root, two after one answer.
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    expect(find.text('3 species remain'), findsOneWidget);
  });

  testWidgets('IdentifyScreen states what each answer leads to', (WidgetTester tester) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    expect(find.textContaining('Leads to 2 species'), findsOneWidget);
    expect(find.textContaining('Kanaad · Zubaidi'), findsOneWidget);
  });

  testWidgets('IdentifyScreen marks each answer with its couplet and its place', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    expect(find.text('1 · 1'), findsOneWidget);
    expect(find.text('1 · 2'), findsOneWidget);
  });

  testWidgets('IdentifyScreen lists the candidates when an answer reaches a leaf', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    await tester.tap(find.text('Deeply forked'));
    await tester.pumpAndSettle();

    expect(find.text('Species the key still allows'), findsOneWidget);
    expect(find.text('Kanaad'), findsOneWidget);
    expect(find.text('Zubaidi'), findsOneWidget);
    expect(find.text('Hamour'), findsNothing);
  });

  testWidgets('IdentifyScreen keeps the answers already given as a trail', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    expect(find.text('Answers so far'), findsNothing);

    await tester.tap(find.text('Rounded or square'));
    await tester.pumpAndSettle();

    expect(find.text('Answers so far'), findsOneWidget);
    expect(find.text('Rounded or square'), findsOneWidget);
  });

  testWidgets('IdentifyScreen opens the species a candidate names', (WidgetTester tester) async {
    final List<int> chosen = await _pump(tester, nodes: _key(), rootNodeId: 1);
    await tester.tap(find.text('Rounded or square'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hamour'));
    await tester.pumpAndSettle();

    expect(chosen, <int>[3]);
  });

  testWidgets('IdentifyScreen returns to the couplet before when a step is taken back', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    await tester.tap(find.text('Deeply forked'));
    await tester.pumpAndSettle();
    expect(find.text('Look at the tail fin only.'), findsNothing);

    await tester.tap(find.text('Back one step'));
    await tester.pumpAndSettle();

    expect(find.text('Look at the tail fin only.'), findsOneWidget);
    expect(find.text('Answers so far'), findsNothing);
  });

  testWidgets('IdentifyScreen lists what remains when the character cannot be seen', (
    WidgetTester tester,
  ) async {
    // A damaged tail is the case a printed key answers with an alternate
    // route. Nothing is invented here: the candidate set of the standing
    // couplet is what the answers so far already establish.
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    expect(find.text('If the character cannot be seen'), findsOneWidget);

    await tester.tap(find.text('List what remains'));
    await tester.pumpAndSettle();

    expect(find.text('Species the key still allows'), findsOneWidget);
    for (final name in <String>['Kanaad', 'Zubaidi', 'Hamour']) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
  });

  testWidgets('IdentifyScreen restores the question when a listing is taken back', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    await tester.tap(find.text('List what remains'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Back one step'));
    await tester.pumpAndSettle();

    expect(find.text('Look at the tail fin only.'), findsOneWidget);
  });

  testWidgets('IdentifyScreen stops on the standing couplet when an answer leads nowhere', (
    WidgetTester tester,
  ) async {
    // A null `next_node_id` is §7.1's terminal state — a transcribed answer,
    // not a fault — so the walk lists what that answer allows rather than
    // reading a node the pack does not carry.
    final nodes = <int, KeyStep>{
      1: KeyStep(
        nodeId: 1,
        question: 'Look at the tail fin only.',
        leads: <KeyLead>[
          _lead(
            optionId: 11,
            mark: 1,
            label: 'Deeply forked',
            candidates: <KeyCandidate>[_candidate(1, 'Kanaad')],
          ),
        ],
        candidates: <KeyCandidate>[_candidate(1, 'Kanaad')],
      ),
    };
    await _pump(tester, nodes: nodes, rootNodeId: 1);
    await tester.tap(find.text('Deeply forked'));
    await tester.pumpAndSettle();

    expect(find.text('Kanaad'), findsOneWidget);
    expect(find.text('Look at the tail fin only.'), findsNothing);
  });

  testWidgets('IdentifyScreen offers the search when the pack carries no key', (
    WidgetTester tester,
  ) async {
    await _pump(tester);
    expect(find.text('No key in this pack'), findsOneWidget);
    expect(find.byType(LonjaEmptyState), findsOneWidget);
    expect(
      find.descendant(of: find.byType(LonjaButton), matching: find.text('Search by name')),
      findsOneWidget,
    );
  });

  testWidgets('IdentifyScreen does not claim an empty key when the read failed', (
    WidgetTester tester,
  ) async {
    // "This pack carries no key" is a statement about the TRANSCRIPTION.
    // Saying it when the device could not read the file is the app lying about
    // the rule book, so the two states never merge.
    await _pump(tester, failure: const FormatException('reference.db is unreadable'));
    expect(find.text('The key could not be read'), findsOneWidget);
    expect(find.text('No key in this pack'), findsNothing);
  });

  testWidgets('IdentifyScreen states the pack holds nothing when an answer reaches no species', (
    WidgetTester tester,
  ) async {
    final nodes = <int, KeyStep>{
      1: const KeyStep(nodeId: 1, question: null, leads: <KeyLead>[], candidates: <KeyCandidate>[]),
    };
    await _pump(tester, nodes: nodes, rootNodeId: 1);
    expect(find.text('No species recorded here'), findsOneWidget);
  });

  testWidgets('IdentifyScreen says no photograph is taken and nothing leaves the device', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    // Scrolled to, and not merely found: the note closes a lazily built
    // CustomScrollView, so on a page whose leads fill the viewport it is not
    // built until it is reached — and a `findsOneWidget` against an unbuilt
    // sliver asserts the size of the phone, not the content of the screen.
    final Finder note = find.textContaining('No photograph is taken');
    await tester.scrollUntilVisible(note, 200, scrollable: find.byType(Scrollable).first);
    expect(note, findsOneWidget);
  });

  testWidgets('IdentifyScreen gives every answer a target that meets the floor', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1);
    expect(tester.getSize(find.byType(KeyLeadTile).first).height, greaterThanOrEqualTo(48));
  });

  testWidgets('ar - IdentifyScreen lays the couplet out right to left', (
    WidgetTester tester,
  ) async {
    await _pump(tester, nodes: _key(), rootNodeId: 1, locale: const Locale('ar'));
    expect(find.text('Deeply forked'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('Deeply forked'))), TextDirection.rtl);
  });
}
