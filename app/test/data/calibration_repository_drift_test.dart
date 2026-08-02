import 'package:catchlaw/data/repositories/calibration_repository.dart';
import 'package:catchlaw/data/repositories/calibration_repository_drift.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late UserDatabase db;
  late CalibrationRepository repo;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    repo = DriftCalibrationRepository(db);
  });

  test('DriftCalibrationRepository.read returns null before any calibration', () async {
    // A real state, not an error: manual entry works before any calibration, so
    // a fisher can measure on the first launch of a wet morning without lining
    // a card up first.
    expect(await repo.read(), isNull);
  });

  test('DriftCalibrationRepository round-trips a calibration through user.db', () async {
    final RulerCalibration written = RulerCalibration(
      pxPerMm: 6.299,
      capturedOn: DateTime.utc(2026, 8, 1, 5, 40),
    );
    await repo.save(written);
    expect(await repo.read(), written);
  });

  test('DriftCalibrationRepository stores the stamp in UTC', () async {
    // So S4 can say how old the calibration is, and so a device that crossed a
    // time zone does not report a calibration from the future.
    await repo.save(RulerCalibration(pxPerMm: 6.299, capturedOn: DateTime.utc(2026, 8, 1, 5, 40)));
    expect((await repo.read())!.capturedOn.isUtc, isTrue);
  });

  test('DriftCalibrationRepository.clear forgets both columns', () async {
    await repo.save(RulerCalibration(pxPerMm: 6.299, capturedOn: DateTime.utc(2026, 8, 1)));
    await repo.clear();
    expect(await repo.read(), isNull);
  });

  test('DriftCalibrationRepository touches no other column', () async {
    // A repository that took the whole profile would let a calibration write
    // clear the fisher's jurisdiction on a partial object.
    await db.customStatement("UPDATE user_profile SET active_jurisdiction = 'ES-GA' WHERE id = 1");
    await repo.save(RulerCalibration(pxPerMm: 6.299, capturedOn: DateTime.utc(2026, 8, 1)));

    final List<QueryRow> rows = await db
        .customSelect('SELECT active_jurisdiction FROM user_profile WHERE id = 1')
        .get();
    expect(rows.single.read<String?>('active_jurisdiction'), 'ES-GA');
  });

  test('DriftCalibrationRepository reports null when only one of the two columns is set', () async {
    // Both or neither. A scale with no date could not be aged, and a date with
    // no scale is a claim that a calibration happened which cannot be used.
    await db.customStatement('UPDATE user_profile SET ruler_px_per_mm = 6.299 WHERE id = 1');
    expect(await repo.read(), isNull);
  });
}
