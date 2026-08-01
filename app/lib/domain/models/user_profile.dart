import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:meta/meta.dart';

/// The settings singleton, as the app reasons about it.
///
/// Every `CHECK`ed column arrives as an **enum**, decoded totally: a string the
/// build does not recognise becomes the enum's documented fallback rather than
/// an exception on a fisher's phone.
@immutable
class UserProfile {
  /// The fisher's settings.
  const UserProfile({
    this.numeralSystem = NumeralSystem.auto,
    this.lengthUnit = LengthUnit.cm,
    this.localeOverride,
    this.activeJurisdiction,
    this.activeZoneCode,
    this.rulerPxPerMm,
    this.rulerCalibratedAt,
    this.captureCoordinates = false,
    this.sunlightMode = false,
    this.gloveMode = false,
  });

  /// One of D-3's six locale tags, or `null` to follow the device.
  final String? localeOverride;

  /// Which digits to render.
  final NumeralSystem numeralSystem;

  /// Which unit to display a length in. Storage is always millimetres.
  final LengthUnit lengthUnit;

  /// The jurisdiction the fisher is working in.
  final String? activeJurisdiction;

  /// The zone within it.
  final String? activeZoneCode;

  /// What S4 measured. `null` until they calibrate, and manual entry works
  /// before that.
  final double? rulerPxPerMm;

  /// When they calibrated. A stale calibration is shown, never silently reused.
  final String? rulerCalibratedAt;

  /// Opt-in. A catch carries no coordinates unless this is set.
  final bool captureCoordinates;

  /// The §4.9 high-contrast lane.
  final bool sunlightMode;

  /// The §4.9 larger-target lane.
  final bool gloveMode;

  /// Whether the ruler has ever been calibrated on this device.
  bool get isRulerCalibrated => rulerPxPerMm != null;

  /// This profile with the named settings replaced.
  ///
  /// A `null` argument means "leave it alone", which makes clearing a nullable
  /// setting — the locale override, the active place — impossible through here.
  /// That is deliberate: the repository writes those columns directly, and a
  /// `copyWith` that could not tell "unchanged" from "cleared" would be a
  /// silent way to un-set the fisher's jurisdiction.
  UserProfile copyWith({
    String? localeOverride,
    NumeralSystem? numeralSystem,
    LengthUnit? lengthUnit,
    String? activeJurisdiction,
    String? activeZoneCode,
    double? rulerPxPerMm,
    String? rulerCalibratedAt,
    bool? captureCoordinates,
    bool? sunlightMode,
    bool? gloveMode,
  }) => UserProfile(
    localeOverride: localeOverride ?? this.localeOverride,
    numeralSystem: numeralSystem ?? this.numeralSystem,
    lengthUnit: lengthUnit ?? this.lengthUnit,
    activeJurisdiction: activeJurisdiction ?? this.activeJurisdiction,
    activeZoneCode: activeZoneCode ?? this.activeZoneCode,
    rulerPxPerMm: rulerPxPerMm ?? this.rulerPxPerMm,
    rulerCalibratedAt: rulerCalibratedAt ?? this.rulerCalibratedAt,
    captureCoordinates: captureCoordinates ?? this.captureCoordinates,
    sunlightMode: sunlightMode ?? this.sunlightMode,
    gloveMode: gloveMode ?? this.gloveMode,
  );
}
