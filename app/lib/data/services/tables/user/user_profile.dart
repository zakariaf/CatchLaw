import 'package:drift/drift.dart';

/// `SPEC.md` §7.2 `user_profile` — the settings singleton.
///
/// **The singleton is enforced by the schema, not by the code that writes it.**
/// `CHECK (id = 1)` means a second settings row is not merely discouraged, it
/// cannot be written — and a corrupt row that is unrepresentable at the storage
/// layer needs no policing that is one forgotten call site away from being
/// absent.
@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  @override
  String get tableName => 'user_profile';

  IntColumn get id => integer().customConstraint('NOT NULL CHECK (id = 1)')();

  /// One of D-3's six locale tags. Never `ur`, never bare `pt`.
  TextColumn get localeOverride => text().named('locale_override').nullable()();

  /// `auto`, `latn` or `arab`. Implemented by swapping `numberFormatSymbols`
  /// at bootstrap, not by a locale extension — `intl` accepts `-u-nu-` as a
  /// string and silently discards it (§9.3).
  TextColumn get numeralSystem => text()
      .named('numeral_system')
      .withDefault(const Constant<String>('auto'))
      .customConstraint(
        "NOT NULL DEFAULT 'auto' CHECK (numeral_system IN ('auto','latn','arab'))",
      )();

  /// The **unit a length is displayed in**, not a length. `SPEC.md` §7.2 types
  /// it `TEXT` because it holds `cm`, `mm` or `in`; every length in this
  /// database is an integer millimetre count, and conversion is display-only.
  ///
  /// `check_measurement.sh` matches the identifier `length` against a `String`
  /// column and cannot tell a unit code from a measurement, so the declaration
  /// carries the gate's one documented hatch.
  TextColumn get lengthUnit => // measurement-ok
  text()
      .named('length_unit')
      .customConstraint("NOT NULL DEFAULT 'cm' CHECK (length_unit IN ('cm','mm','in'))")();

  /// The jurisdiction code, not an id: `reference.db` is a separate file and a
  /// content update renumbers it.
  TextColumn get activeJurisdiction => text().named('active_jurisdiction').nullable()();

  /// The zone code, for the same reason.
  TextColumn get activeZoneCode => text().named('active_zone_code').nullable()();

  /// The calibration S4 measured. `null` until the fisher has calibrated, and
  /// manual entry works before that (E09).
  RealColumn get rulerPxPerMm => real().named('ruler_px_per_mm').nullable()();

  /// When they calibrated. A stale calibration is shown, never silently reused.
  TextColumn get rulerCalibratedAt => text().named('ruler_calibrated_at').nullable()();

  /// Opt-in. A catch carries no coordinates unless this is set.
  BoolColumn get captureCoordinates =>
      boolean().named('capture_coordinates').customConstraint('NOT NULL DEFAULT 0')();

  /// The §4.9 high-contrast lane.
  BoolColumn get sunlightMode =>
      boolean().named('sunlight_mode').customConstraint('NOT NULL DEFAULT 0')();

  /// The §4.9 larger-target lane.
  BoolColumn get gloveMode =>
      boolean().named('glove_mode').customConstraint('NOT NULL DEFAULT 0')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  bool get isStrict => true;
}
