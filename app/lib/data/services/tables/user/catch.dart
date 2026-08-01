import 'package:drift/drift.dart';

/// `SPEC.md` §7.2 `catch` — one recorded fish.
///
/// **Literals, not foreign keys into `reference.db`.** §7.2 is categorical: a
/// content update can renumber or retire a rule, and a three-year-old record
/// must still say what it said when it was recorded.
///
/// The case that makes it concrete: شعري Sha'ri carries a closed season of
/// 1 March to 30 April. If a later pack moves that window, a live join would
/// retroactively declare a lawful March 2025 catch an offence.
///
/// [speciesId] is a **soft hint** for "show me this species again". Nothing on
/// the record screen may read through it; if it no longer resolves, the row
/// still renders completely.
@DataClassName('CatchRow')
class Catches extends Table {
  @override
  String get tableName => 'catch';

  IntColumn get id => integer().autoIncrement()();

  IntColumn get tripId => integer()
      .named('trip_id')
      .nullable()
      .customConstraint('REFERENCES trip(id) ON DELETE SET NULL')();

  /// On the catch, so zone filtering works for a quick-add with no trip.
  TextColumn get jurisdictionCode => text().named('jurisdiction_code')();

  TextColumn get zoneCode => text().named('zone_code')();

  /// A soft reference. See the class doc.
  IntColumn get speciesId => integer().named('species_id')();

  /// Denormalised: history survives a content update.
  TextColumn get scientificName => text().named('scientific_name')();

  /// Integer millimetres, always. Conversion is display-only.
  IntColumn get lengthMm => integer().named('length_mm').nullable()();

  /// `TL`, `FL`, `SHL` — the method the length was measured by, without which
  /// the number means nothing.
  TextColumn get measurementCode => text().named('measurement_code').nullable()();

  TextColumn get outcome => text().customConstraint(
    "NOT NULL CHECK (outcome IN ('meets','fails','attention','unknown'))",
  )();

  /// The factual finding **as shown**. Not regenerated: the sentence the fisher
  /// read is the sentence the record keeps.
  TextColumn get outcomeDetail => text().named('outcome_detail').nullable()();

  TextColumn get ruleCitationRef => text().named('rule_citation_ref').nullable()();

  /// Which pack produced the verdict.
  TextColumn get contentVersion => text().named('content_version').nullable()();

  BoolColumn get wasKept => boolean().named('was_kept').customConstraint('NOT NULL DEFAULT 0')();

  /// In-app camera only (E13), so photos never enter the shared camera roll.
  TextColumn get photoPath => text().named('photo_path').nullable()();

  /// `null` unless the fisher opted in.
  RealColumn get latitude => real().nullable()();

  /// `null` unless the fisher opted in.
  RealColumn get longitude => real().nullable()();

  TextColumn get createdAt => text().named('created_at')();

  TextColumn get updatedAt => text().named('updated_at')();

  @override
  bool get isStrict => true;
}
