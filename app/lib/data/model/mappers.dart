/// Drift rows in, domain types out.
///
/// **This is the only file that knows both.** `FLUTTER_GUIDE.md` rule 6: a drift
/// row never escapes `data/`. A row carries drift's `Value` wrappers, its
/// companion machinery and its knowledge of a table — a view model holding one
/// is a view model that cannot be constructed in a test without a database, and
/// a renamed column ripples into `app/lib/ui/`.
///
/// Top-level functions rather than methods on the row classes: the row classes
/// are **generated**, and an extension on generated code is one `build_runner`
/// run away from being silently replaced.
library;

import 'package:catchlaw/data/daos/user/catch_dao.dart';
import 'package:catchlaw/data/model/enum_codecs.dart' as codecs;
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart' as domain;
import 'package:catchlaw/domain/models/trip.dart' as domain;
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:drift/drift.dart' show Value;
import 'package:rule_engine/rule_engine.dart' as engine;

/// A `species` row as the app shows it.
domain.Species toSpecies(SpeciesRow row) => domain.Species(
  id: row.id,
  scientificName: row.scientificName,
  familyId: row.familyId,
  taxonGroup: _taxonGroup(row.taxonGroup),
  silhouetteAsset: row.silhouetteAsset,
  colId: row.colId,
  plateAsset: row.plateAsset,
);

/// A `species_name` row as the app shows it.
domain.SpeciesName toSpeciesName(SpeciesNameRow row) => domain.SpeciesName(
  speciesId: row.speciesId,
  locale: row.locale,
  name: row.name,
  gender: codecs.nameGenderOf(row.gender),
  isPrimary: row.isPrimary,
  regionHint: row.regionHint,
);

/// A `zone` row as the app shows it.
domain.Zone toZone(ZoneRow row) => domain.Zone(
  id: row.id,
  jurisdictionId: row.jurisdictionId,
  parentZoneId: row.parentZoneId,
  code: row.code,
  nameKey: row.nameKey,
  waterType: codecs.waterKindOf(row.waterType),
  zoneKind: _zoneKind(row.zoneKind),
  minLat: row.minLat,
  minLon: row.minLon,
  maxLat: row.maxLat,
  maxLon: row.maxLon,
);

/// A `citation` row as the **engine's** [engine.Citation].
/// The engine already owns this type and its four fields are exactly §7.1's;
/// mapping into a second one would give the app two citations and one of them
/// would eventually be the one that prints.
engine.Citation toCitation(CitationRow row) => engine.Citation(
  instrument: row.instrumentRef,
  article: row.articleRef ?? '',
  publishedOn: row.publishedOn,
  checkedOn: row.retrievedOn,
);

/// A `rule` row and its closures as the engine's [engine.Rule].
///
/// **[citation] is required and is not defaulted.** Invariant 3 makes a
/// `Citation` non-nullable on every engine type precisely so it cannot be
/// forgotten; a mapper that supplied an empty placeholder would satisfy the
/// type and print a footnote that cites nothing, which is the defect the
/// invariant exists to make unrepresentable.
///
/// **[method] is required, and is passed IN rather than derived.** It is
/// resolved by the caller from `measurement_method.code`, never from
/// `measurement_method_id`. The build assigns those integers by insertion
/// order, so a pack declaring one method gives it id 1 — and an id-to-enum map
/// reads id 1 as total length, printing a shell-length rule as a total-length
/// rule. That is `catchlaw-rule-engine` rule 12's failure, the one priced at
/// 6-9 cm between FL and TL on a Kanaad. The code is the stable key, and §7.1
/// makes it `UNIQUE` for exactly that reason. Required rather than optional so
/// the shortcut is unwritable rather than merely discouraged.
///
/// `citationLineageId` is the citation's id as a string: §7.1 has no lineage
/// column, and E04 collapses an amending order onto the order it amends by
/// giving them one lineage. Until §7.1 grows the column, one citation is one
/// lineage — which is correct for every pack that ships today and is what
/// E04/T08's `supersedes:` already assumes.
engine.Rule toRule(
  RuleRow row, {
  required engine.Citation citation,
  required engine.MeasurementMethod? method,
  List<engine.ClosedSeason> closedSeasons = const <engine.ClosedSeason>[],
}) => engine.Rule(
  id: row.id,
  jurisdictionId: row.jurisdictionId,
  zoneId: row.zoneId,
  speciesId: row.speciesId,
  waterType: _waterType(row.waterType),
  citation: citation,
  citationLineageId: '${row.citationId}',
  validFrom: row.validFrom,
  validTo: row.validTo,
  minSizeMm: row.minSizeMm,
  maxSizeMm: row.maxSizeMm,
  measurementMethod: method,
  bagLimit: row.bagLimit,
  bagLimitUnit: _limitUnit(row.bagLimitUnit),
  bagLimitPeriod: _limitPeriod(row.bagLimitPeriod),
  vesselLimit: row.vesselLimit,
  isProtected: row.isProtected,
  closedSeasons: closedSeasons,
);

/// A `closed_season` row as the engine's [engine.ClosedSeason].
/// [citation] is required for the same reason it is on [toRule]: a closure is
/// the finding most likely to be argued with on the quay, and the instrument
/// behind it is the only thing that ends the argument.
engine.ClosedSeason toClosedSeason(ClosedSeasonRow row, {required engine.Citation citation}) =>
    engine.ClosedSeason(
      recurrence: row.recurrence == 'fixed' ? engine.Recurrence.fixed : engine.Recurrence.annual,
      citation: citation,
      startMonth: row.startMonth,
      startDay: row.startDay,
      endMonth: row.endMonth,
      endDay: row.endDay,
      startDate: row.startDate,
      endDate: row.endDate,
    );

/// A `catch` row as the app reasons about it.
CatchRecord toCatchRecord(CatchRow row) => CatchRecord(
  id: row.id,
  tripId: row.tripId,
  jurisdictionCode: row.jurisdictionCode,
  zoneCode: row.zoneCode,
  speciesId: row.speciesId,
  scientificName: row.scientificName,
  lengthMm: row.lengthMm,
  measurementCode: row.measurementCode,
  outcome: codecs.catchOutcomeOf(row.outcome),
  outcomeDetail: row.outcomeDetail,
  ruleCitationRef: row.ruleCitationRef,
  contentVersion: row.contentVersion,
  wasKept: row.wasKept,
  photoPath: row.photoPath,
  latitude: row.latitude,
  longitude: row.longitude,
  createdAt: row.createdAt,
  updatedAt: row.updatedAt,
);

/// A DAO tally row as the app reasons about it.
SpeciesTallyEntry toTallyEntry(SpeciesTally tally) => SpeciesTallyEntry(
  speciesId: tally.speciesId,
  scientificName: tally.scientificName,
  count: tally.count,
  kept: tally.kept,
);

/// A `trip` row as the app reasons about it.
domain.Trip toTrip(TripRow row) => domain.Trip(
  id: row.id,
  startedAt: row.startedAt,
  endedAt: row.endedAt,
  jurisdictionCode: row.jurisdictionCode,
  zoneCode: row.zoneCode,
  label: row.label,
  notes: row.notes,
);

/// A `saved_zone` row as the app reasons about it.
domain.SavedZone toSavedZone(SavedZoneRow row) => domain.SavedZone(
  id: row.id,
  jurisdictionCode: row.jurisdictionCode,
  zoneCode: row.zoneCode,
  label: row.label,
  sortOrder: row.sortOrder,
);

/// A `species_recent` row as the app reasons about it.
domain.RecentSpecies toRecentSpecies(SpeciesRecentRow row) => domain.RecentSpecies(
  speciesId: row.speciesId,
  jurisdictionCode: row.jurisdictionCode,
  zoneCode: row.zoneCode,
  useCount: row.useCount,
  lastUsedAt: row.lastUsedAt,
);

/// A `user_profile` row as the app reasons about it.
UserProfile toUserProfile(UserProfileRow row) => UserProfile(
  localeOverride: row.localeOverride,
  numeralSystem: codecs.numeralSystemOf(row.numeralSystem),
  lengthUnit: codecs.lengthUnitOf(row.lengthUnit),
  activeJurisdiction: row.activeJurisdiction,
  activeZoneCode: row.activeZoneCode,
  rulerPxPerMm: row.rulerPxPerMm,
  rulerCalibratedAt: row.rulerCalibratedAt,
  captureCoordinates: row.captureCoordinates,
  sunlightMode: row.sunlightMode,
  gloveMode: row.gloveMode,
);
engine.TaxonGroup _taxonGroup(String sql) {
  for (final engine.TaxonGroup g in engine.TaxonGroup.values) {
    if (g.name == sql) return g;
  }
  return engine.TaxonGroup.other;
}

engine.ZoneKind _zoneKind(String sql) {
  for (final engine.ZoneKind k in engine.ZoneKind.values) {
    if (k.name == sql) return k;
  }
  return engine.ZoneKind.region;
}

engine.WaterType _waterType(String sql) => switch (sql) {
  'fresh' => engine.WaterType.fresh,
  'both' => engine.WaterType.both,
  // An unrecognised water type is treated as salt rather than thrown on: the
  // string comes out of a file a content update replaces wholesale, and A1 is
  // what makes an unrecognised one unshippable in the first place.
  _ => engine.WaterType.salt,
};
engine.LimitUnit? _limitUnit(String? sql) => switch (sql) {
  'count' => engine.LimitUnit.count,
  'kg' => engine.LimitUnit.kg,
  _ => null,
};
engine.LimitPeriod? _limitPeriod(String? sql) => switch (sql) {
  'day' => engine.LimitPeriod.day,
  'trip' => engine.LimitPeriod.trip,
  'season' => engine.LimitPeriod.season,
  _ => null,
};

/// A [CatchDraft] as the row drift will insert.
/// An extension rather than a method on the draft: `CatchesCompanion` is a
/// generated drift type, and `FLUTTER_GUIDE.md` rule 6 keeps it out of
/// `domain/` — which is exactly where the draft lives.
extension CatchDraftRow on CatchDraft {
  /// This draft as a `catch` companion, stamped [updatedAt] (defaulting to
  /// `createdAt`, because a row that has never been edited was last written
  /// when it was written).
  CatchesCompanion toCompanion({int? tripId, String? updatedAt}) => CatchesCompanion.insert(
    tripId: Value<int?>(tripId ?? this.tripId),
    jurisdictionCode: jurisdictionCode,
    zoneCode: zoneCode,
    speciesId: speciesId,
    scientificName: scientificName,
    lengthMm: Value<int?>(lengthMm),
    measurementCode: Value<String?>(measurementCode),
    outcome: outcome.sql,
    outcomeDetail: Value<String?>(outcomeDetail),
    ruleCitationRef: Value<String?>(ruleCitationRef),
    contentVersion: Value<String?>(contentVersion),
    wasKept: Value<bool>(wasKept),
    photoPath: Value<String?>(photoPath),
    latitude: Value<double?>(latitude),
    longitude: Value<double?>(longitude),
    createdAt: createdAt,
    updatedAt: updatedAt ?? createdAt,
  );
}

/// A `jurisdiction` row as the picker's region rung.
/// `has_zone_polygons` is carried through rather than derived from whether any
/// ring exists: the pack states the fact, and a jurisdiction that printed no
/// coordinate list is a different thing from one whose rings failed to load.
Jurisdiction toJurisdiction(JurisdictionRow row) => Jurisdiction(
  id: row.id,
  code: row.code,
  countryIso2: row.countryIso2,
  nameKey: row.nameKey,
  authorityKey: row.authorityKey,
  defaultLocale: row.defaultLocale,
  hasSaltwater: row.hasSaltwater,
  hasFreshwater: row.hasFreshwater,
  hasZonePolygons: row.hasZonePolygons,
  contentVersion: row.contentVersion,
  checkedOn: row.checkedOn,
  validUntil: row.validUntil,
);
