// The day tally, end to end through the provider the screen actually watches.
//
// Six catches were written to a real device, all on the right day and in the
// right place, and the query returned three grouped rows when run by hand — and
// the Today screen showed nothing. So the data was right, the SQL was right,
// and the defect was somewhere between the repository and the widget. That gap
// is exactly what this test covers: it exercises `dayTallyProvider` itself,
// which no test did.

import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/catch_log_repository.dart';
import 'package:catchlaw/data/repositories/catch_log_repository_drift.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/ui/log/view_models/catch_log_providers.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok, Result;

const String kDay = '2026-08-04';

/// The place, as `WatchEvaluationScope` would emit it.
EvaluationScope scopeFor() => const EvaluationScope(
  jurisdictionCode: 'ES-GA',
  zoneCode: 'rias-baixas',
  authorityKey: 'jurisdiction.es_ga.authority',
  defaultLocale: 'gl',
  packVersion: '2026.08.2',
  checkedOn: kDay,
  water: WaterKind.salt,
  zonePath: <String>['ES-GA', 'rias-baixas'],
);

void main() {
  late UserDatabase db;
  late ProviderContainer container;

  /// The tally as the SCREEN sees it: subscribed, then pumped.
  ///
  /// Not `container.read(dayTallyProvider.future)`. That future never completes
  /// here, and the reason is the defect itself: the provider is rebuilt when the
  /// scope stream flips from loading to data, and `.future` on a StreamProvider
  /// that is rebuilt before its first event never resolves. A widget watching it
  /// sees the same thing — a permanent loading state, which renders as a blank
  /// page whatever rows are in the database.
  Future<List<SpeciesTallyEntry>> tally() async {
    final List<List<SpeciesTallyEntry>> seen = <List<SpeciesTallyEntry>>[];
    final ProviderSubscription<AsyncValue<List<SpeciesTallyEntry>>> sub = container.listen(
      dayTallyProvider,
      (AsyncValue<List<SpeciesTallyEntry>>? _, AsyncValue<List<SpeciesTallyEntry>> next) {
        if (next.hasValue) seen.add(next.requireValue);
      },
      fireImmediately: true,
    );
    addTearDown(sub.close);
    await pumpEventQueue();
    return seen.isEmpty ? const <SpeciesTallyEntry>[] : seen.last;
  }

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      retry: (int _, Object _) => null,
      overrides: <Override>[
        userDatabaseProvider.overrideWithValue(db),
        catchLogRepositoryProvider.overrideWithValue(DriftCatchLogRepository(db)),
        todayIsoProvider.overrideWithValue(kDay),
        evaluationScopeProvider.overrideWith(
          (Ref ref) => Stream<EvaluationScope?>.value(scopeFor()),
        ),
      ],
    );
    addTearDown(() {
      container.dispose();
      db.close();
    });
  });

  Future<void> record(String scientific, int speciesId) async {
    final Result<int> written = await container
        .read(catchLogRepositoryProvider)
        .record(
          CatchDraft(
            jurisdictionCode: 'ES-GA',
            zoneCode: 'rias-baixas',
            speciesId: speciesId,
            scientificName: scientific,
            outcome: CatchOutcome.unknown,
            createdAt: '${kDay}T05:40:00.000',
          ),
        );
    expect(written, isA<Ok<int>>());
  }

  test('dayTallyProvider groups today\'s catches for the active place', () async {
    await record('Pollachius pollachius', 12);
    await record('Pollachius pollachius', 12);
    await record('Belone belone', 1);

    final List<SpeciesTallyEntry> rows = await tally();

    expect(rows, hasLength(2));
    expect(rows.first.scientificName, 'Pollachius pollachius');
    expect(rows.first.count, 2);
  });

  test('dayTallyProvider emits again when a catch is recorded', () async {
    // The screen's actual complaint: rows exist in the database and the page
    // shows nothing. Subscribed first, written after.
    final List<List<SpeciesTallyEntry>> seen = <List<SpeciesTallyEntry>>[];
    final ProviderSubscription<AsyncValue<List<SpeciesTallyEntry>>> sub = container.listen(
      dayTallyProvider,
      (AsyncValue<List<SpeciesTallyEntry>>? _, AsyncValue<List<SpeciesTallyEntry>> next) {
        if (next.hasValue) seen.add(next.requireValue);
      },
      fireImmediately: true,
    );
    addTearDown(sub.close);
    await pumpEventQueue();

    await record('Belone belone', 1);
    await pumpEventQueue();

    expect(seen.last, hasLength(1));
    expect(seen.last.single.count, 1);
  });

  test('dayTallyProvider counts kept separately from recorded', () async {
    await record('Belone belone', 1);
    await record('Belone belone', 1);
    await container
        .read(catchLogRepositoryProvider)
        .setLatestKept(
          speciesId: 1,
          isoDay: kDay,
          jurisdictionCode: 'ES-GA',
          zoneCode: 'rias-baixas',
          kept: true,
        );

    final List<SpeciesTallyEntry> rows = await tally();

    expect(rows.single.count, 2);
    expect(rows.single.kept, 1, reason: 'kept is authored, and only one was marked');
  });

  test('removeLatest takes one row and leaves the rest', () async {
    await record('Belone belone', 1);
    await record('Belone belone', 1);

    await container
        .read(catchLogRepositoryProvider)
        .removeLatest(
          speciesId: 1,
          isoDay: kDay,
          jurisdictionCode: 'ES-GA',
          zoneCode: 'rias-baixas',
        );

    final List<SpeciesTallyEntry> rows = await tally();
    expect(rows.single.count, 1, reason: 'one tap undone, not the whole species');
  });
}
