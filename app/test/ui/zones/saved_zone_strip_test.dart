import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/ui/zones/widgets/saved_zone_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_settings_repository.dart';
import '../../../testing/theme/pump_lonja.dart';

Future<FakeSettingsRepository> _pumpStrip(
  WidgetTester tester, {
  required List<SavedZone> saved,
  void Function(SavedZone)? onSelected,
}) async {
  final settings = FakeSettingsRepository();
  for (final z in saved) {
    await settings.saveZone(
      jurisdictionCode: z.jurisdictionCode,
      zoneCode: z.zoneCode,
      label: z.label,
    );
  }
  await pumpLonja(
    tester,
    ProviderScope(
      overrides: <Override>[settingsRepositoryProvider.overrideWithValue(settings)],
      child: SavedZoneStrip(onSelected: onSelected ?? (SavedZone _) {}),
    ),
  );
  await tester.pumpAndSettle();
  return settings;
}

void main() {
  group('SavedZoneStrip', () {
    testWidgets('renders nothing when he has saved no place', (WidgetTester tester) async {
      await _pumpStrip(tester, saved: const <SavedZone>[]);

      // An empty strip is chrome that teaches him a feature exists before he
      // has any use for it.
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('renders his own name for a place when he gave one', (WidgetTester tester) async {
      await _pumpStrip(
        tester,
        saved: const <SavedZone>[
          SavedZone(
            id: 1,
            jurisdictionCode: 'ES-GA',
            zoneCode: 'cambados',
            sortOrder: 0,
            label: 'Banco de casa',
          ),
        ],
      );

      // A generated label would be the app naming a place it has never been.
      expect(find.text('Banco de casa'), findsOneWidget);
    });

    testWidgets('falls back to the zone code when he named nothing', (WidgetTester tester) async {
      await _pumpStrip(
        tester,
        saved: const <SavedZone>[
          SavedZone(id: 1, jurisdictionCode: 'ES-GA', zoneCode: 'cambados', sortOrder: 0),
        ],
      );

      expect(find.text('cambados'), findsOneWidget);
    });

    testWidgets('hands the whole saved place back in one tap', (WidgetTester tester) async {
      final chosen = <SavedZone>[];
      await _pumpStrip(
        tester,
        saved: const <SavedZone>[
          SavedZone(id: 1, jurisdictionCode: 'ES-GA', zoneCode: 'cambados', sortOrder: 0),
        ],
        onSelected: chosen.add,
      );

      await tester.tap(find.text('cambados'));
      await tester.pumpAndSettle();

      // One tap, and the verdict behind it changes. Nothing navigates.
      expect(chosen.single.zoneCode, 'cambados');
      expect(chosen.single.jurisdictionCode, 'ES-GA');
    });
  });
}
