import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `citation` — the instrument a finding quotes.
///
/// Invariant 3: every result carries one. The engine makes that unrepresentable
/// with a non-nullable field; A4 makes it unshippable in the data.
@DataClassName('CitationRow')
class Citations extends Table {
  @override
  String get tableName => 'citation';

  IntColumn get id => integer()();

  IntColumn get jurisdictionId =>
      integer().named('jurisdiction_id').customConstraint('NOT NULL REFERENCES jurisdiction(id)')();

  /// Localised label for the kind of instrument — decision, orde, portaria.
  TextColumn get instrumentTypeKey => text().named('instrument_type_key')();

  /// `MD 580/2015`, `Orde 27/07/2012`.
  TextColumn get instrumentRef => text().named('instrument_ref')();

  /// `Art. 3`, `Anexo II`.
  TextColumn get articleRef => text().named('article_ref').nullable()();

  TextColumn get publishedOn => text().named('published_on')();

  /// **Selectable text only**, and always an official gazette.
  TextColumn get sourceUrl => text().named('source_url').nullable()();

  /// The day a human opened the gazette. The footnote claims exactly that, so
  /// it is authored and never a clock reading.
  TextColumn get retrievedOn => text().named('retrieved_on')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
