import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/zone.dart';
import 'package:drift/drift.dart';

part 'zone_dao.g.dart';

/// Reads zones and their geometry.
@DriftAccessor(tables: <Type>[Zones, ZoneRings])
class ZoneDao extends DatabaseAccessor<ReferenceDatabase> with _$ZoneDaoMixin {
  /// Reads zones from [db].
  ZoneDao(super.db);

  /// Every zone of one jurisdiction.
  Future<List<ZoneRow>> byJurisdiction(int jurisdictionId) =>
      (select(zones)..where(($ZonesTable t) => t.jurisdictionId.equals(jurisdictionId))).get();

  /// One zone by its authored code, or `null`.
  Future<ZoneRow?> byCode(int jurisdictionId, String code) =>
      (select(zones)..where(
            ($ZonesTable t) => t.jurisdictionId.equals(jurisdictionId) & t.code.equals(code),
          ))
          .getSingleOrNull();

  /// Zones whose bounding box contains ([lat], [lon]).
  ///
  /// **The prefilter, not the answer.** `idx_zone_bbox` turns a point-in-polygon
  /// sweep over every ring in the pack into a handful of candidates; E11 then
  /// runs the ray cast over those. Without it a GPS fix unpacks every
  /// coordinate the jurisdiction has.
  Future<List<ZoneRow>> bboxCandidates(double lat, double lon) =>
      (select(zones)..where(
            ($ZonesTable t) =>
                t.minLat.isSmallerOrEqualValue(lat) &
                t.maxLat.isBiggerOrEqualValue(lat) &
                t.minLon.isSmallerOrEqualValue(lon) &
                t.maxLon.isBiggerOrEqualValue(lon),
          ))
          .get();

  /// One zone's rings, in ring order.
  ///
  /// Ring 0 is the outer boundary and the holes follow it, so E11 can subtract
  /// them in the order it reads them.
  Future<List<ZoneRingRow>> ringsFor(int zoneId) =>
      (select(zoneRings)
            ..where(($ZoneRingsTable t) => t.zoneId.equals(zoneId))
            ..orderBy(<OrderClauseGenerator<$ZoneRingsTable>>[
              ($ZoneRingsTable t) => OrderingTerm(expression: t.ringIndex),
            ]))
          .get();
}
