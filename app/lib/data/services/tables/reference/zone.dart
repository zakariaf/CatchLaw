import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `zone` — a geometry a rule attaches to.
///
/// Both §7.1 indexes are declared here. `idx_zone_bbox` is the prefilter E11's
/// point-in-polygon runs behind: without it every zone's rings are unpacked for
/// every fix.
@TableIndex(name: 'idx_zone_juris', columns: <Symbol>{#jurisdictionId})
@TableIndex(name: 'idx_zone_bbox', columns: <Symbol>{#minLat, #maxLat, #minLon, #maxLon})
@DataClassName('ZoneRow')
class Zones extends Table {
  @override
  String get tableName => 'zone';

  IntColumn get id => integer()();

  IntColumn get jurisdictionId =>
      integer().named('jurisdiction_id').customConstraint('NOT NULL REFERENCES jurisdiction(id)')();

  /// A self-reference, expressed as a custom constraint rather than
  /// `references(Zones, #id)`: the latter asks the generator to order a table
  /// against itself.
  IntColumn get parentZoneId =>
      integer().named('parent_zone_id').nullable().customConstraint('REFERENCES zone(id)')();

  TextColumn get code => text()();

  TextColumn get nameKey => text().named('name_key')();

  /// `salt`, `fresh` or `both`. The `CHECK` is what keeps §7.3's resolution from
  /// matching nothing.
  TextColumn get waterType => text()
      .named('water_type')
      .customConstraint("NOT NULL CHECK (water_type IN ('salt','fresh','both'))")();

  /// The specificity ladder §7.3 step 3 sorts on: exclusion 40, reserve 30,
  /// bank/basin 20, subzone 10, region 0.
  TextColumn get zoneKind => text()
      .named('zone_kind')
      .customConstraint(
        "NOT NULL CHECK (zone_kind IN ('region','subzone','bank','basin', "
        "'reserve','exclusion'))",
      )();

  /// Attribution key for the polygon source; `null` when there is no polygon.
  TextColumn get geometrySource => text().named('geometry_source').nullable()();

  /// The bounding box E11's point-in-polygon runs behind.
  RealColumn get minLat => real().named('min_lat').nullable()();

  /// Bounding box south-west longitude.
  RealColumn get minLon => real().named('min_lon').nullable()();

  /// Bounding box north-east latitude.
  RealColumn get maxLat => real().named('max_lat').nullable()();

  /// Bounding box north-east longitude.
  RealColumn get maxLon => real().named('max_lon').nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>['UNIQUE (jurisdiction_id, code)'];
}

/// `SPEC.md` §7.1 `zone_ring` — packed little-endian `Float64` `[lat, lon]`
/// pairs.
///
/// `ON DELETE CASCADE` only fires with `PRAGMA foreign_keys = ON`, which is why
/// a test deletes a zone and looks for the rings.
@DataClassName('ZoneRingRow')
class ZoneRings extends Table {
  @override
  String get tableName => 'zone_ring';

  IntColumn get id => integer()();

  IntColumn get zoneId => integer()
      .named('zone_id')
      .customConstraint('NOT NULL REFERENCES zone(id) ON DELETE CASCADE')();

  /// Rings are ordered; ring 0 is the outer boundary.
  IntColumn get ringIndex => integer().named('ring_index')();

  /// Whether this ring cuts a hole out of the zone.
  BoolColumn get isHole => boolean().named('is_hole').withDefault(const Constant<bool>(false))();

  /// Derived by the build from `coords`. A hand-kept count and a hand-kept list
  /// disagree the first time a coordinate is added.
  IntColumn get pointCount => integer().named('point_count')();

  BlobColumn get coords => blob()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>['UNIQUE (zone_id, ring_index)'];
}
