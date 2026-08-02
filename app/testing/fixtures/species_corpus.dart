import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// `SPEC.md` §13's stated scale.
const int kCorpusSpecies = 400;

/// Six names per species, which is what six shipped locales produce.
const int kCorpusNames = kCorpusSpecies * 6;

/// An in-memory rule book at spec scale, for the latency rows.
///
/// The Galicia seed is far smaller, and a budget proved at ten species is not a
/// budget. This is the one place a schema-shaped in-memory database is the right
/// tool rather than the wrong one: the question is how the INDEX behaves at
/// scale, not whether drift's tables and the builder's DDL agree.
Future<ReferenceDatabase> buildSpeciesCorpus() async {
  final db = ReferenceDatabase.forTesting(NativeDatabase.memory());
  const locales = <String>['en', 'es', 'gl', 'ca', 'pt_BR', 'ar'];

  await db.batch((Batch batch) {
    for (var i = 0; i < kCorpusSpecies; i++) {
      batch.insert(
        db.speciesTable,
        SpeciesTableCompanion.insert(
          id: Value<int>(i + 1),
          scientificName: 'Genus species$i',
          familyId: 1 + (i % 20),
          taxonGroup: 'finfish',
          silhouetteAsset: 'assets/sil/species$i.svg',
        ),
      );
      for (var l = 0; l < locales.length; l++) {
        // Distinct folds per name, so the range scan has real work: a corpus of
        // identical strings measures the B-tree's best case and nothing else.
        final name = 'spec${i.toString().padLeft(3, '0')}${locales[l]}';
        batch.insert(
          db.speciesNames,
          SpeciesNamesCompanion.insert(
            speciesId: i + 1,
            locale: locales[l],
            name: name,
            searchNorm: name,
            isPrimary: Value<bool>(l == 0),
          ),
        );
      }
    }
  });
  return db;
}
