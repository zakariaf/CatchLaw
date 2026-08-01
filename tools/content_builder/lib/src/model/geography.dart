import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/content_row.dart';

/// A `jurisdiction` row: the authority that published the instruments.
class JurisdictionRow extends ContentRow {
  /// A jurisdiction read from [path] at [line].
  const JurisdictionRow({
    required super.path,
    required super.line,
    required super.id,
    required this.code,
    required this.countryIso2,
    required this.nameKey,
    required this.authorityKey,
    required this.defaultLocale,
    required this.legalTextLocales,
    required this.contentVersion,
    required this.publishedOn,
    required this.checkedOn,
    this.authorityUrl,
    this.hasFreshwater = false,
    this.hasSaltwater = true,
    this.hasZonePolygons = false,
    this.validUntil,
  });

  /// Reads a jurisdiction from [row].
  factory JurisdictionRow.fromRow(YamlRow row) => JurisdictionRow(
    path: row.path,
    line: row.line,
    id: row.id,
    code: row.string('code'),
    countryIso2: row.string('country_iso2'),
    nameKey: row.string('name_key'),
    authorityKey: row.string('authority_key'),
    authorityUrl: row.string('authority_url'),
    hasFreshwater: row.boolean('has_freshwater') ?? false,
    hasSaltwater: row.boolean('has_saltwater') ?? true,
    hasZonePolygons: row.boolean('has_zone_polygons') ?? false,
    defaultLocale: row.string('default_locale'),
    legalTextLocales: row.string('legal_text_locales'),
    contentVersion: row.string('content_version'),
    publishedOn: row.string('published_on'),
    checkedOn: row.string('checked_on'),
    validUntil: row.string('valid_until'),
  );

  /// `AE-RK`, `ES-GA`, `BR-SP`.
  final String? code;

  /// ISO 3166-1 alpha-2 of the state the authority belongs to.
  final String? countryIso2;

  /// Localised jurisdiction name, resolved through `content_string`.
  final String? nameKey;

  /// Localised name of the authority itself.
  final String? authorityKey;

  /// Selectable text only. Never launched: an `ACTION_VIEW` fetches under the
  /// browser's own permission and defeats the Android guarantee.
  final String? authorityUrl;

  /// Whether the jurisdiction regulates fresh water.
  final bool hasFreshwater;

  /// Whether the jurisdiction regulates salt water.
  final bool hasSaltwater;

  /// `false` hides the sub-zone level in S9. Where no coordinate list is printed
  /// in the instrument we do not invent boundaries.
  final bool hasZonePolygons;

  /// The locale the fallback chain drops to before `en`.
  final String? defaultLocale;

  /// CSV of the languages the authority published its law in, e.g. `gl,es`.
  final String? legalTextLocales;

  /// The pack version this jurisdiction's rows belong to.
  final String? contentVersion;

  /// When the instrument set was published.
  final String? publishedOn;

  /// When a human last checked the published text. Authored, never a clock
  /// reading: the footnote claims a person opened the gazette that day.
  final String? checkedOn;

  /// When the pack goes stale. Passing it raises the ochre bar; it never
  /// withholds a verdict.
  final String? validUntil;
}

/// A `zone` row: a geometry a rule attaches to.
class ZoneRow extends ContentRow {
  /// A zone read from [path] at [line].
  const ZoneRow({
    required super.path,
    required super.line,
    required super.id,
    required this.jurisdictionId,
    required this.code,
    required this.nameKey,
    required this.waterType,
    required this.zoneKind,
    this.parentZoneId,
    this.geometrySource,
    this.minLat,
    this.minLon,
    this.maxLat,
    this.maxLon,
  });

  /// Reads a zone from [row].
  factory ZoneRow.fromRow(YamlRow row) => ZoneRow(
    path: row.path,
    line: row.line,
    id: row.id,
    jurisdictionId: row.string('jurisdiction_id'),
    parentZoneId: row.string('parent_zone_id'),
    code: row.string('code'),
    nameKey: row.string('name_key'),
    waterType: row.string('water_type'),
    zoneKind: row.string('zone_kind'),
    geometrySource: row.string('geometry_source'),
    minLat: _double(row, 'min_lat'),
    minLon: _double(row, 'min_lon'),
    maxLat: _double(row, 'max_lat'),
    maxLon: _double(row, 'max_lon'),
  );

  /// The authority this zone belongs to.
  final String? jurisdictionId;

  /// The zone this one nests inside; `null` at the top of the tree.
  final String? parentZoneId;

  /// Unique within the jurisdiction.
  final String? code;

  /// Localised zone name.
  final String? nameKey;

  /// `salt`, `fresh` or `both`.
  final String? waterType;

  /// `region`, `subzone`, `bank`, `basin`, `reserve` or `exclusion` — the
  /// specificity ladder the resolver sorts on.
  final String? zoneKind;

  /// Attribution key for the polygon source; `null` when there is no polygon.
  final String? geometrySource;

  /// Bounding box, the prefilter E11's point-in-polygon runs behind.
  final double? minLat;

  /// Bounding box south-west longitude.
  final double? minLon;

  /// Bounding box north-east latitude.
  final double? maxLat;

  /// Bounding box north-east longitude.
  final double? maxLon;
}

/// A `zone_ring` row: one ring of a zone's polygon.
class ZoneRingRow extends ContentRow {
  /// A ring read from [path] at [line].
  const ZoneRingRow({
    required super.path,
    required super.line,
    required super.id,
    required this.zoneId,
    required this.ringIndex,
    required this.coords,
    this.isHole = false,
  });

  /// Reads a ring from [row].
  factory ZoneRingRow.fromRow(YamlRow row) => ZoneRingRow(
    path: row.path,
    line: row.line,
    id: row.id,
    zoneId: row.string('zone_id'),
    ringIndex: row.integer('ring_index'),
    isHole: row.boolean('is_hole') ?? false,
    coords: _coords(row.list('coords')),
  );

  /// The zone this ring bounds.
  final String? zoneId;

  /// Rings are ordered; ring 0 is the outer boundary.
  final int? ringIndex;

  /// Whether this ring cuts a hole out of the zone.
  final bool isHole;

  /// `[latitude, longitude]` pairs, authored in degrees.
  ///
  /// The emitter packs them little-endian `Float64`; `point_count` is derived
  /// rather than authored, because a hand-kept count and a hand-kept list
  /// disagree the first time a coordinate is added.
  final List<List<double>> coords;
}

double? _double(YamlRow row, String key) => switch (row.fields[key]) {
  final num value => value.toDouble(),
  _ => null,
};

List<List<double>> _coords(List<Object?>? raw) => <List<double>>[
  for (final Object? pair in raw ?? const <Object?>[])
    if (pair is List<Object?>)
      <double>[
        for (final Object? n in pair)
          if (n is num) n.toDouble(),
      ],
];
