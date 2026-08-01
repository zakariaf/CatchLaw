// The settings singleton, read as a stream and written through typed setters.

import 'dart:async';

import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/settings_repository_drift.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

void main() {
  late UserDatabase db;
  late DriftSettingsRepository repository;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    repository = DriftSettingsRepository(db);
  });

  test('DriftSettingsRepository.watchProfile emits the singleton on subscription', () async {
    // Every screen reads this before it can render a number. An empty first
    // emission is a frame drawn in the wrong unit, and a length in the wrong
    // unit is a legal fish that reads as illegal.
    final UserProfile profile = await repository.watchProfile().first;

    expect(profile.numeralSystem, NumeralSystem.auto);
    expect(profile.lengthUnit, LengthUnit.cm);
    expect(profile.localeOverride, isNull);
  });

  test('DriftSettingsRepository.setLengthUnit re-emits the profile with the new unit', () async {
    final seen = <LengthUnit>[];
    final StreamSubscription<UserProfile> sub = repository.watchProfile().listen(
      (UserProfile p) => seen.add(p.lengthUnit),
    );
    addTearDown(sub.cancel);
    // The first emission has to LAND before the write. Subscribing and writing
    // in the same turn races drift's initial query, and the test then passes or
    // fails on scheduling rather than on behaviour.
    await pumpEventQueue();

    await repository.setLengthUnit(LengthUnit.mm);
    await pumpEventQueue();

    expect(seen, <LengthUnit>[LengthUnit.cm, LengthUnit.mm]);
  });

  test('DriftSettingsRepository.setLengthUnit rejects a unit outside cm, mm and in', () async {
    // The schema CHECK surfaced as a typed failure rather than an uncaught
    // exception. LengthUnit cannot express 'ft', so the violation is written
    // the only way it can still happen — from a build that added a member and
    // not the constraint.
    final Result<void> result = await repository.writeRawLengthUnitForTesting('ft');

    expect(
      result,
      isA<Failure<void>>().having(
        (Failure<void> f) => f.exception,
        'exception',
        isA<DataConstraintViolated>(),
      ),
    );
  });

  test('DriftSettingsRepository.saveZone relabels a place already saved', () async {
    await repository.saveZone(jurisdictionCode: 'ES-GA', zoneCode: 'RIA-AROUSA', label: 'A boia');
    final Result<int> again = await repository.saveZone(
      jurisdictionCode: 'ES-GA',
      zoneCode: 'RIA-AROUSA',
      label: 'A boia grande',
    );

    // Tapping the star twice must not be an error, and must not be a duplicate.
    expect(again, isA<Ok<int>>());
    final List<SavedZone> saved = await repository.watchSavedZones().first;
    expect(saved, hasLength(1));
    expect(saved.single.label, 'A boia grande');
  });

  test('DriftSettingsRepository.setActivePlace stores codes, never ids', () async {
    await repository.setActivePlace(jurisdictionCode: 'ES-GA', zoneCode: 'RIA-AROUSA');

    final UserProfile profile = (await repository.read() as Ok<UserProfile>).value;
    expect(profile.activeJurisdiction, 'ES-GA');
    expect(
      profile.activeZoneCode,
      'RIA-AROUSA',
      reason: 'reference.db is a separate file, and a content update renumbers it',
    );
  });
}
