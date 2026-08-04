// A `watch*` method must actually watch.
//
// `watchRecentTrips` was `(select(trips)...).get().asStream()`. That compiles,
// satisfies `Stream<List<TripRow>>`, passes any test that reads the first
// event — and emits exactly ONCE. The trips screen rendered whatever existed
// when it opened and never moved again.
//
// The symptom on a device was precise and misleading: tapping "Start a trip"
// flipped the button, because `watchOpenTrip` is a real `.watch()`, and the
// list below it stayed empty. The feature looked broken while the database was
// perfectly correct, which is the worst shape a bug can take — the evidence
// points at the wrong layer.
//
// Every test here subscribes FIRST and mutates AFTER, because that is the only
// ordering that can tell a live query from a one-shot read.

import 'dart:async';

import 'package:catchlaw/data/daos/user/trip_dao.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late UserDatabase db;
  late TripDao dao;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    dao = TripDao(db);
    addTearDown(db.close);
  });

  test('watchRecentTrips emits again when a trip is started', () async {
    // Subscribed with listen() and not `.skip(1).first`: a Future-backed
    // subscription is established asynchronously, so a write issued in the same
    // microtask can land before the listener exists and the test then hangs for
    // a reason that has nothing to do with the defect.
    final seen = <List<TripRow>>[];
    final StreamSubscription<List<TripRow>> sub = dao.watchRecentTrips().listen(seen.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();

    await dao.startTrip(
      startedAt: '2026-08-04T05:40:00Z',
      jurisdictionCode: 'ES-GA',
      zoneCode: 'rias-baixas',
    );
    await pumpEventQueue();

    expect(
      seen.last,
      hasLength(1),
      reason: 'a one-shot .get().asStream() never delivers this event',
    );
  });

  test('watchRecentTrips emits again when a trip is ended', () async {
    final int id = await dao.startTrip(
      startedAt: '2026-08-04T05:40:00Z',
      jurisdictionCode: 'ES-GA',
      zoneCode: 'rias-baixas',
    );
    final seen = <List<TripRow>>[];
    final StreamSubscription<List<TripRow>> sub = dao.watchRecentTrips().listen(seen.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();

    await dao.endTrip(id, '2026-08-04T11:20:00Z');
    await pumpEventQueue();

    expect(seen.last.single.endedAt, '2026-08-04T11:20:00Z');
  });

  test('watchOpenTrip closes the previous trip when a second one starts', () async {
    await dao.startTrip(
      startedAt: '2026-08-03T05:00:00Z',
      jurisdictionCode: 'ES-GA',
      zoneCode: 'rias-baixas',
    );
    await dao.startTrip(
      startedAt: '2026-08-04T05:00:00Z',
      jurisdictionCode: 'ES-GA',
      zoneCode: 'rias-baixas',
    );

    // Two open trips is a state with no correct answer for "which one does this
    // catch belong to", so startTrip closes the old one in the same
    // transaction. Asserted because the phone that reaches that state is the
    // one whose owner forgot to close yesterday's.
    final List<TripRow> all = await dao.watchRecentTrips().first;
    expect(all.where((TripRow t) => t.endedAt == null), hasLength(1));
    expect((await dao.watchOpenTrip().first)!.startedAt, '2026-08-04T05:00:00Z');
  });
}
