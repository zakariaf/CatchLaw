import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/species_recent_repository.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:catchlaw/ui/check/widgets/recents_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

import '../../../testing/theme/pump_lonja.dart';

const EvaluationScope _cambados = EvaluationScope(
  jurisdictionCode: 'ES-GA',
  zoneCode: 'cambados',
  zonePath: <String>['ES-GA', 'cambados'],
  water: WaterKind.salt,
  authorityKey: 'jurisdiction.es_ga.authority',
  defaultLocale: 'gl',
  packVersion: '2026.08.0',
  checkedOn: '2026-08-12',
);

RecentSpeciesEntry _entry(int id, String name) => RecentSpeciesEntry(
  speciesId: id,
  useCount: 1,
  lastUsedAt: '2026-08-03',
  displayName: name,
  silhouetteAsset: 'assets/silhouette/$id.svg',
);

/// A recents repository that answers per place, so "here" can be asserted.
final class _FakeRecents implements SpeciesRecentRepository {
  _FakeRecents(this.byZone);

  final Map<String, List<RecentSpeciesEntry>> byZone;

  @override
  Stream<List<RecentSpeciesEntry>> watchRecents({
    required String jurisdictionCode,
    required String zoneCode,
    int limit = 6,
  }) => Stream<List<RecentSpeciesEntry>>.value(
    (byZone[zoneCode] ?? const <RecentSpeciesEntry>[]).take(limit).toList(),
  );

  @override
  Future<Result<void>> recordUse(
    int speciesId, {
    required String jurisdictionCode,
    required String zoneCode,
    required String at,
  }) async => const Result<void>.ok(null);
}

Future<void> _pumpStrip(
  WidgetTester tester, {
  required Map<String, List<RecentSpeciesEntry>> byZone,
  void Function(int)? onChosen,
}) async {
  await pumpLonja(
    tester,
    ProviderScope(
      retry: noRetry,
      overrides: <Override>[
        speciesRecentRepositoryProvider.overrideWithValue(_FakeRecents(byZone)),
      ],
      child: RecentsStrip(place: _cambados, onSpeciesChosen: onChosen ?? (int _) {}),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('RecentsStrip', () {
    testWidgets('renders nothing when he has opened nothing here', (WidgetTester tester) async {
      await _pumpStrip(tester, byZone: const <String, List<RecentSpeciesEntry>>{});

      // A labelled empty strip is chrome that teaches him a feature exists
      // before he has any use for it, and it costs the search box its space.
      expect(find.byType(InkWell), findsNothing);
      expect(find.text('Recent here'), findsNothing);
    });

    testWidgets('lists what he opened in THIS zone', (WidgetTester tester) async {
      await _pumpStrip(
        tester,
        byZone: <String, List<RecentSpeciesEntry>>{
          'cambados': <RecentSpeciesEntry>[_entry(1, 'Ameixa babosa')],
          'other-bank': <RecentSpeciesEntry>[_entry(2, 'Berberecho')],
        },
      );

      // Recency is per zone: the fish he looked up on another bank does not
      // reshuffle this one.
      expect(find.text('Ameixa babosa'), findsOneWidget);
      expect(find.text('Berberecho'), findsNothing);
    });

    testWidgets('caps the strip at six', (WidgetTester tester) async {
      await _pumpStrip(
        tester,
        byZone: <String, List<RecentSpeciesEntry>>{
          'cambados': <RecentSpeciesEntry>[for (var i = 0; i < 12; i++) _entry(i, 'Species $i')],
        },
      );

      expect(find.text('Species 6'), findsNothing);
      expect(find.text('Species 0'), findsOneWidget);
    });

    testWidgets('opens a species in one tap', (WidgetTester tester) async {
      final opened = <int>[];
      await _pumpStrip(
        tester,
        byZone: <String, List<RecentSpeciesEntry>>{
          'cambados': <RecentSpeciesEntry>[_entry(7, 'Ameixa babosa')],
        },
        onChosen: opened.add,
      );

      await tester.tap(find.text('Ameixa babosa'));
      await tester.pumpAndSettle();

      // The fastest path to a verdict, and the one most likely to be taken
      // with a wet glove.
      expect(opened, <int>[7]);
    });
  });
}
