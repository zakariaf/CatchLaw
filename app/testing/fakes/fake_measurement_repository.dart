import 'dart:async';

import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/measurement_repository.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

import 'store_env.dart';

/// A [MeasurementRepository] with no database behind it.
///
/// The spy lists are the point: a test asserts **what** was recorded — the
/// length, the outcome, the citation reference — rather than that recording
/// happened. A catch stored with the wrong outcome passes a call-count
/// assertion and fails an inspector.
final class FakeMeasurementRepository implements MeasurementRepository {
  /// A log in [env].
  FakeMeasurementRepository({this.env = StoreEnv.healthy});

  /// Which world this store is in.
  final StoreEnv env;

  /// Everything [recordCatch] actually stored, in order.
  final List<CatchRecord> recorded = <CatchRecord>[];

  /// Every draft [recordCatch] was handed, whether or not it stored it.
  ///
  /// Separate from [recorded] on purpose: in
  /// [StoreEnv.corruptButReportsOk] the two disagree, and that disagreement is
  /// the only trace of the failure this suite cannot otherwise see.
  final List<CatchDraft> attempted = <CatchDraft>[];

  final StreamController<List<CatchRecord>> _catches =
      StreamController<List<CatchRecord>>.broadcast();
  final StreamController<Trip?> _openTrip = StreamController<Trip?>.broadcast();
  int _nextId = 1;
  Trip? _open;

  @override
  Stream<List<CatchRecord>> watchForTrip(int tripId) async* {
    yield recorded.where((CatchRecord c) => c.tripId == tripId).toList();
    yield* _catches.stream.map(
      (List<CatchRecord> all) => all.where((CatchRecord c) => c.tripId == tripId).toList(),
    );
  }

  /// One entry per catch, **not** grouped by species.
  ///
  /// The drift implementation groups in SQL. A fake that reimplemented the
  /// grouping would be a second implementation of the thing under test, and a
  /// test that passed against it would prove the fake right rather than the
  /// query right — so this deliberately does less, and the grouping is asserted
  /// against the real database in `measurement_repository_test.dart`.
  @override
  Stream<List<SpeciesTallyEntry>> watchTallyForDay(
    String isoDay, {
    required String jurisdictionCode,
    required String zoneCode,
  }) => Stream<List<SpeciesTallyEntry>>.value(<SpeciesTallyEntry>[
    for (final CatchRecord c in recorded.where(
      (CatchRecord c) =>
          c.createdAt.startsWith(isoDay) &&
          c.jurisdictionCode == jurisdictionCode &&
          c.zoneCode == zoneCode,
    ))
      SpeciesTallyEntry(
        speciesId: c.speciesId,
        scientificName: c.scientificName,
        count: 1,
        kept: c.wasKept ? 1 : 0,
      ),
  ]);

  @override
  Future<Result<List<CatchRecord>>> pageBefore(String cursorCreatedAt, {int limit = 30}) async =>
      _read(
        recorded
            .where((CatchRecord c) => c.createdAt.compareTo(cursorCreatedAt) < 0)
            .take(limit)
            .toList(),
      );

  @override
  Future<Result<CatchRecord>> recordCatch(CatchDraft draft, {String? updatedAt}) async {
    attempted.add(draft);
    final DataFailure? failure = env.writeFailure;
    if (failure != null) return Result<CatchRecord>.error(failure);

    final record = CatchRecord(
      id: _nextId++,
      tripId: draft.tripId,
      jurisdictionCode: draft.jurisdictionCode,
      zoneCode: draft.zoneCode,
      speciesId: draft.speciesId,
      scientificName: draft.scientificName,
      lengthMm: draft.lengthMm,
      measurementCode: draft.measurementCode,
      outcome: draft.outcome,
      outcomeDetail: draft.outcomeDetail,
      ruleCitationRef: draft.ruleCitationRef,
      contentVersion: draft.contentVersion,
      wasKept: draft.wasKept,
      photoPath: draft.photoPath,
      latitude: draft.latitude,
      longitude: draft.longitude,
      createdAt: draft.createdAt,
      updatedAt: updatedAt ?? draft.createdAt,
    );
    if (env.writePersists) {
      recorded.add(record);
      _catches.add(List<CatchRecord>.unmodifiable(recorded));
    }
    return Result<CatchRecord>.ok(record);
  }

  @override
  Future<Result<void>> deleteCatch(int id) async {
    final DataFailure? failure = env.writeFailure;
    if (failure != null) return Result<void>.error(failure);
    final int before = recorded.length;
    recorded.removeWhere((CatchRecord c) => c.id == id);
    if (recorded.length == before) {
      return Result<void>.error(DataNotFound(entity: 'catch', id: '$id'));
    }
    _catches.add(List<CatchRecord>.unmodifiable(recorded));
    return const Result<void>.ok(null);
  }

  @override
  Stream<Trip?> watchOpenTrip() async* {
    yield _open;
    yield* _openTrip.stream;
  }

  @override
  Future<Result<int>> startTrip({
    required String startedAt,
    required String jurisdictionCode,
    required String zoneCode,
    String? label,
  }) async {
    final DataFailure? failure = env.writeFailure;
    if (failure != null) return Result<int>.error(failure);
    _open = Trip(
      id: _nextId++,
      startedAt: startedAt,
      jurisdictionCode: jurisdictionCode,
      zoneCode: zoneCode,
      label: label,
    );
    _openTrip.add(_open);
    return Result<int>.ok(_open!.id);
  }

  @override
  Future<Result<void>> endTrip(int id, String endedAt) async {
    final DataFailure? failure = env.writeFailure;
    if (failure != null) return Result<void>.error(failure);
    if (_open?.id != id) return Result<void>.error(DataNotFound(entity: 'trip', id: '$id'));
    _open = null;
    _openTrip.add(null);
    return const Result<void>.ok(null);
  }

  @override
  Stream<List<RecentSpecies>> watchRecentSpecies({
    required String jurisdictionCode,
    required String zoneCode,
    int limit = 12,
  }) => Stream<List<RecentSpecies>>.value(<RecentSpecies>[
    for (final CatchRecord c in recorded)
      RecentSpecies(
        speciesId: c.speciesId,
        jurisdictionCode: c.jurisdictionCode,
        zoneCode: c.zoneCode,
        useCount: 1,
        lastUsedAt: c.createdAt,
      ),
  ]);

  /// Releases the controllers. Call from `addTearDown`.
  Future<void> dispose() async {
    await _catches.close();
    await _openTrip.close();
  }

  Result<T> _read<T>(T value) {
    final DataFailure? failure = env.readFailure;
    return failure == null ? Result<T>.ok(value) : Result<T>.error(failure);
  }
}
