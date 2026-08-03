import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// The settings singleton and the fisher's saved places.
///
/// [watchProfile] is non-nullable: `CHECK (id = 1)` and the `beforeOpen` seed
/// together mean the row always exists, and a nullable stream here would push a
/// `?` into every screen that reads a setting — including the one that decides
/// whether a length renders in centimetres or inches.
abstract interface class SettingsRepository {
  /// The settings, as a live stream.
  Stream<UserProfile> watchProfile();

  /// The settings, once.
  @useResult
  Future<Result<UserProfile>> read();

  /// Which locale to render in, or `null` to follow the device.
  @useResult
  Future<Result<void>> setLocaleOverride(String? locale);

  /// Which digits to render.
  @useResult
  Future<Result<void>> setNumeralSystem(NumeralSystem system);

  /// Which unit to **display** a length in. Storage stays integer millimetres.
  @useResult
  Future<Result<void>> setLengthUnit(LengthUnit unit);

  /// Where the fisher is working. Codes, never ids: `reference.db` is a
  /// separate file and a content update renumbers it.
  @useResult
  Future<Result<void>> setActivePlace({String? jurisdictionCode, String? zoneCode});

  /// Which water he is asking about, where the ZONE leaves it open.
  ///
  /// Reachable only for a zone whose own `water_type` is `both`. It is not a
  /// preference that overrides the pack: water type is a property of the place,
  /// and this answers the one question the pack declined to answer.
  ///
  /// **In `app_meta`, not on `user_profile`.** A new column is a schema change,
  /// and a schema change is irreversible after the first shipped pack — for one
  /// nullable enum answered by one jurisdiction in the corpus, the key-value
  /// table is the proportionate place.
  @useResult
  Future<Result<void>> setActiveWater(WaterKind water);

  /// The stored water choice, or `null` if he has not made one.
  @useResult
  Future<Result<WaterKind?>> readActiveWater();

  /// What S4 measured, and when. A stale calibration is shown, never silently
  /// reused as if it were fresh.
  @useResult
  Future<Result<void>> setRulerCalibration({required double pxPerMm, required String calibratedAt});

  /// The §4.9 lanes and the coordinate opt-in.
  @useResult
  Future<Result<void>> setFlags({bool? captureCoordinates, bool? sunlightMode, bool? gloveMode});

  /// The fisher's saved places, in their own order.
  Stream<List<SavedZone>> watchSavedZones();

  /// Saves a place, or relabels the one already saved for that code pair.
  @useResult
  Future<Result<int>> saveZone({
    required String jurisdictionCode,
    required String zoneCode,
    String? label,
  });

  /// Removes one.
  @useResult
  Future<Result<void>> removeZone(int id);

  /// Rewrites the order.
  @useResult
  Future<Result<void>> reorderZones(List<int> idsInOrder);
}
