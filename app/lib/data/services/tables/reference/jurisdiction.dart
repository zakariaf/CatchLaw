import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `jurisdiction` — the authority that published the instruments.
@DataClassName('JurisdictionRow')
class Jurisdictions extends Table {
  @override
  String get tableName => 'jurisdiction';

  /// Assigned by the content build from sorted authored ids, never by SQLite:
  /// a rowid the writer chose makes the emitted file depend on insert order.
  IntColumn get id => integer()();

  /// `AE-RK`, `ES-GA`, `BR-SP`.
  TextColumn get code => text().unique()();

  /// ISO 3166-1 alpha-2 of the state the authority belongs to.
  TextColumn get countryIso2 => text().named('country_iso2')();

  /// Localised jurisdiction name, resolved through `content_string`.
  TextColumn get nameKey => text().named('name_key')();

  /// Localised name of the authority itself.
  TextColumn get authorityKey => text().named('authority_key')();

  /// **Selectable text only, never launched.** An `ACTION_VIEW` fetches under
  /// the browser's own permission and defeats the Android guarantee.
  TextColumn get authorityUrl => text().named('authority_url').nullable()();

  /// Whether the jurisdiction regulates fresh water.
  BoolColumn get hasFreshwater =>
      boolean().named('has_freshwater').withDefault(const Constant<bool>(false))();

  /// Whether the jurisdiction regulates salt water.
  BoolColumn get hasSaltwater =>
      boolean().named('has_saltwater').withDefault(const Constant<bool>(true))();

  /// `false` hides the sub-zone level in S9. Where no coordinate list is printed
  /// in the instrument we do not invent boundaries.
  BoolColumn get hasZonePolygons =>
      boolean().named('has_zone_polygons').withDefault(const Constant<bool>(false))();

  /// The locale the §9.2 fallback chain drops to before `en`.
  TextColumn get defaultLocale => text().named('default_locale')();

  /// CSV of the languages the authority published its law in, e.g. `gl,es`.
  /// S13 renders a language-availability notice when the reader's locale is not
  /// among them.
  TextColumn get legalTextLocales => text().named('legal_text_locales')();

  /// The pack version. `catch.content_version` names it so a three-year-old
  /// record can still say which ruleset produced its verdict.
  TextColumn get contentVersion => text().named('content_version')();

  /// When the instrument set was published.
  TextColumn get publishedOn => text().named('published_on')();

  /// When a human last read the published text.
  TextColumn get checkedOn => text().named('checked_on')();

  /// When the pack goes stale. Passing it raises the non-blocking ochre bar; it
  /// never withholds a verdict (invariant 5).
  TextColumn get validUntil => text().named('valid_until').nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
