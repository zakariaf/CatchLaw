// The write boundary. The one thing in this app that exists nowhere else is
// the fisher's own record, so "persisted, or a typed failure" is the whole
// contract — there is no third outcome, and silence is not one of the two.

import 'dart:async';

import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/measurement_repository_drift.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

import '../../../testing/models/user_fixtures.dart';

void main() {
  late UserDatabase db;
  late DriftMeasurementRepository repository;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    repository = DriftMeasurementRepository(db);
  });

  test(
    'DriftMeasurementRepository.recordCatch returns Ok and the watched stream re-emits',
    () async {
      final emissions = <int>[];
      await repository.startTrip(
        startedAt: '2026-08-01T05:40:00Z',
        jurisdictionCode: 'ES-GA',
        zoneCode: 'RIA-AROUSA',
      );
      final StreamSubscription<List<CatchRecord>> sub = repository
          .watchForTrip(1)
          .listen((List<CatchRecord> rows) => emissions.add(rows.length));
      addTearDown(sub.cancel);
      await pumpEventQueue();

      final Result<CatchRecord> result = await repository.recordCatch(
        kCatchDraftAmeixa.copyWith(tripId: 1),
      );
      await pumpEventQueue();

      expect(result, isA<Ok<CatchRecord>>());
      expect(emissions, <int>[
        0,
        1,
      ], reason: 'persist-before-publish: the commit is what makes the stream emit');
    },
  );

  test('DriftMeasurementRepository.recordCatch returns the row it wrote, with its id', () async {
    final Result<CatchRecord> result = await repository.recordCatch(kCatchDraftAmeixa);

    // Returning the id alone would make the caller re-read to render what it
    // just wrote, and a re-read is a second chance for the two to disagree.
    final CatchRecord saved = (result as Ok<CatchRecord>).value;
    expect(saved.id, isPositive);
    expect(saved.outcomeDetail, kHostileOutcomeDetail);
    expect(saved.outcome, CatchOutcome.fails);
  });

  test(
    'DriftMeasurementRepository.recordCatch returns DataConstraintViolated for an unknown trip',
    () async {
      // A foreign key that does not resolve. `outcome` cannot be violated from
      // here at all — CatchOutcome makes an out-of-range value unrepresentable,
      // which is a stronger guarantee than catching it — so the constraint under
      // test is one the type system genuinely cannot hold.
      await db.customStatement('PRAGMA foreign_keys = ON');

      final Result<CatchRecord> result = await repository.recordCatch(
        kCatchDraftAmeixa.copyWith(tripId: 999999),
      );

      expect(
        result,
        isA<Failure<CatchRecord>>().having(
          (Failure<CatchRecord> f) => f.exception,
          'exception',
          isA<DataConstraintViolated>(),
        ),
      );
    },
  );

  test('offendingColumn recovers the column from a CHECK constraint message', () {
    // The documented best-effort: SqliteException has no column field, so the
    // name comes out of the message or it does not come at all. Both shapes
    // SQLite emits are here, with the fallback that keeps this honest.
    expect(offendingColumn('CHECK constraint failed: outcome'), 'outcome');
    // The shape SQLite actually emits, trailing noise and all.
    expect(
      offendingColumn(
        "CHECK constraint failed: length_unit IN ('cm','mm','in'), "
        'constraint failed (code 275)',
      ),
      'length_unit',
    );
    expect(offendingColumn('FOREIGN KEY constraint failed'), kUnknownColumn);
    expect(
      offendingColumn('UNIQUE constraint failed: saved_zone.zone_code'),
      'saved_zone.zone_code',
    );
    expect(offendingColumn('NOT NULL constraint failed: catch.created_at'), 'catch.created_at');
    expect(offendingColumn('disk I/O error'), kUnknownColumn);
  });

  test(
    'DriftMeasurementRepository.watchTallyForDay returns a Stream that is not of Result',
    () async {
      await repository.recordCatch(kCatchDraftAmeixa);

      final Stream<List<SpeciesTallyEntry>> tally = repository.watchTallyForDay(
        '2026-08-01',
        jurisdictionCode: 'ES-GA',
        zoneCode: 'RIA-AROUSA',
      );

      // A Stream<Result<T>> inside an AsyncValue is four states where two are
      // meaningful. A stream that fails does so through AsyncError.
      expect(tally, isA<Stream<List<SpeciesTallyEntry>>>());
      expect(await tally.first, hasLength(1));
    },
  );

  test(
    'DriftMeasurementRepository.recordCatch bumps the species recency in the same transaction',
    () async {
      await repository.recordCatch(kCatchDraftAmeixa);

      final List<dynamic> recents = await repository
          .watchRecentSpecies(jurisdictionCode: 'ES-GA', zoneCode: 'RIA-AROUSA')
          .first;

      // The half-committed pair is a tally that disagrees with the log it was
      // counted from — which is the log the fisher shows an inspector.
      expect(recents, hasLength(1));
    },
  );

  test(
    'DriftMeasurementRepository.deleteCatch reports DataNotFound when nothing matched',
    () async {
      final Result<void> result = await repository.deleteCatch(999999);

      expect(
        result,
        isA<Failure<void>>().having(
          (Failure<void> f) => f.exception,
          'exception',
          isA<DataNotFound>(),
        ),
      );
    },
  );
}
