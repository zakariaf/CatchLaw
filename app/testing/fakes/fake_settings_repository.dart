import 'dart:async';

import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/settings_repository.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

import 'store_env.dart';

/// A [SettingsRepository] with no database behind it.
final class FakeSettingsRepository implements SettingsRepository {
  /// Settings in [env], starting from [profile].
  FakeSettingsRepository({this.env = StoreEnv.healthy, UserProfile? profile})
    : _profile = profile ?? const UserProfile();

  /// Which world this store is in.
  final StoreEnv env;

  /// The columns a setter actually wrote, in order.
  ///
  /// Column names rather than method names: the test that matters is "did
  /// `length_unit` change", and a method-name spy passes when the setter writes
  /// the wrong column.
  final List<String> writes = <String>[];

  UserProfile _profile;
  final List<SavedZone> _zones = <SavedZone>[];
  final StreamController<UserProfile> _profiles = StreamController<UserProfile>.broadcast();
  final StreamController<List<SavedZone>> _saved = StreamController<List<SavedZone>>.broadcast();
  int _nextId = 1;

  @override
  Stream<UserProfile> watchProfile() async* {
    yield _profile;
    yield* _profiles.stream;
  }

  @override
  Future<Result<UserProfile>> read() async => _read(_profile);

  @override
  Future<Result<void>> setLocaleOverride(String? locale) =>
      _write('locale_override', (UserProfile p) => p.copyWith(localeOverride: locale));

  @override
  Future<Result<void>> setNumeralSystem(NumeralSystem system) =>
      _write('numeral_system', (UserProfile p) => p.copyWith(numeralSystem: system));

  @override
  Future<Result<void>> setLengthUnit(LengthUnit unit) =>
      _write('length_unit', (UserProfile p) => p.copyWith(lengthUnit: unit));

  @override
  Future<Result<void>> setActivePlace({String? jurisdictionCode, String? zoneCode}) => _write(
    'active_jurisdiction',
    (UserProfile p) => p.copyWith(activeJurisdiction: jurisdictionCode, activeZoneCode: zoneCode),
  );

  @override
  Future<Result<void>> setRulerCalibration({
    required double pxPerMm,
    required String calibratedAt,
  }) => _write(
    'ruler_px_per_mm',
    (UserProfile p) => p.copyWith(rulerPxPerMm: pxPerMm, rulerCalibratedAt: calibratedAt),
  );

  @override
  Future<Result<void>> setFlags({bool? captureCoordinates, bool? sunlightMode, bool? gloveMode}) =>
      _write(
        'flags',
        (UserProfile p) => p.copyWith(
          captureCoordinates: captureCoordinates,
          sunlightMode: sunlightMode,
          gloveMode: gloveMode,
        ),
      );

  @override
  Stream<List<SavedZone>> watchSavedZones() async* {
    yield List<SavedZone>.unmodifiable(_zones);
    yield* _saved.stream;
  }

  @override
  Future<Result<int>> saveZone({
    required String jurisdictionCode,
    required String zoneCode,
    String? label,
  }) async {
    final DataFailure? failure = env.writeFailure;
    if (failure != null) return Result<int>.error(failure);

    final int existing = _zones.indexWhere(
      (SavedZone z) => z.jurisdictionCode == jurisdictionCode && z.zoneCode == zoneCode,
    );
    final zone = SavedZone(
      id: existing >= 0 ? _zones[existing].id : _nextId++,
      jurisdictionCode: jurisdictionCode,
      zoneCode: zoneCode,
      label: label,
      sortOrder: existing >= 0 ? _zones[existing].sortOrder : _zones.length,
    );
    if (env.writePersists) {
      if (existing >= 0) {
        _zones[existing] = zone;
      } else {
        _zones.add(zone);
      }
      _saved.add(List<SavedZone>.unmodifiable(_zones));
    }
    writes.add('saved_zone');
    return Result<int>.ok(zone.id);
  }

  @override
  Future<Result<void>> removeZone(int id) async {
    final DataFailure? failure = env.writeFailure;
    if (failure != null) return Result<void>.error(failure);
    final int before = _zones.length;
    _zones.removeWhere((SavedZone z) => z.id == id);
    if (_zones.length == before) {
      return Result<void>.error(DataNotFound(entity: 'saved_zone', id: '$id'));
    }
    _saved.add(List<SavedZone>.unmodifiable(_zones));
    return const Result<void>.ok(null);
  }

  @override
  Future<Result<void>> reorderZones(List<int> idsInOrder) async {
    final DataFailure? failure = env.writeFailure;
    if (failure != null) return Result<void>.error(failure);
    _zones.sort(
      (SavedZone a, SavedZone b) => idsInOrder.indexOf(a.id).compareTo(idsInOrder.indexOf(b.id)),
    );
    _saved.add(List<SavedZone>.unmodifiable(_zones));
    writes.add('sort_order');
    return const Result<void>.ok(null);
  }

  /// Releases the controllers. Call from `addTearDown`.
  Future<void> dispose() async {
    await _profiles.close();
    await _saved.close();
  }

  Future<Result<void>> _write(String column, UserProfile Function(UserProfile) change) async {
    final DataFailure? failure = env.writeFailure;
    if (failure != null) return Result<void>.error(failure);
    if (env.writePersists) {
      _profile = change(_profile);
      _profiles.add(_profile);
    }
    writes.add(column);
    return const Result<void>.ok(null);
  }

  Result<T> _read<T>(T value) {
    final DataFailure? failure = env.readFailure;
    return failure == null ? Result<T>.ok(value) : Result<T>.error(failure);
  }
}
