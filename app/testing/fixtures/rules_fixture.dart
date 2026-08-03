import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// A synthetic pack with rules in it.
///
/// **E04's Galicia seed carries zero `rule` rows** — it is a structural seed,
/// and the authored content is E22's whole epic. So the built `reference.db`
/// cannot exercise the §7.3 predicates at all, and a test that ran against it
/// would pass over an empty table: the same silent-green failure
/// `CONVENTIONS.md` §7 records for gates.
///
/// A drift-created schema is the right tool here and the wrong one elsewhere.
/// The question these rows ask is about the PREDICATE — which rules reach this
/// zone, what expiry does, which hint outranks which — not about whether
/// drift's `Table` classes and the content builder's DDL agree. That second
/// question is what `openBuiltReference()` exists for, and the DAO tests that
/// ask it still do.
Future<ReferenceDatabase> buildRulesFixture() async {
  final db = ReferenceDatabase.forTesting(NativeDatabase.memory());

  await db.batch((Batch batch) {
    batch
      // Seeded with ids that do NOT match the enum's declaration order, on
      // purpose. The content build numbers this table by insertion order, and
      // a fixture that numbered TL as 1 would agree with the id-to-enum map
      // that shipped the shell-length-as-total-length defect — and would go on
      // agreeing with it after the fix.
      ..insert(
        db.measurementMethods,
        MeasurementMethodsCompanion.insert(
          id: const Value<int>(1),
          code: 'SHL',
          nameKey: 'measurement.shl.name',
          definitionKey: 'measurement.shl.definition',
          diagramAsset: 'method/shl.svg',
        ),
      )
      ..insert(
        db.measurementMethods,
        MeasurementMethodsCompanion.insert(
          id: const Value<int>(2),
          code: 'FL',
          nameKey: 'measurement.fl.name',
          definitionKey: 'measurement.fl.definition',
          diagramAsset: 'method/fl.svg',
        ),
      )
      ..insert(
        db.measurementMethods,
        MeasurementMethodsCompanion.insert(
          id: const Value<int>(3),
          code: 'TL',
          nameKey: 'measurement.tl.name',
          definitionKey: 'measurement.tl.definition',
          diagramAsset: 'method/tl.svg',
        ),
      )
      ..insert(
        db.jurisdictions,
        JurisdictionsCompanion.insert(
          id: const Value<int>(1),
          code: 'ES-GA',
          countryIso2: 'ES',
          nameKey: 'jurisdiction.es_ga.name',
          authorityKey: 'jurisdiction.es_ga.authority',
          defaultLocale: 'gl',
          legalTextLocales: 'gl,es',
          contentVersion: '2026.08.0',
          publishedOn: '2026-01-01',
          checkedOn: '2026-07-14',
        ),
      )
      // A two-level chain: the ría sits inside the region.
      ..insert(
        db.zones,
        ZonesCompanion.insert(
          id: const Value<int>(10),
          jurisdictionId: 1,
          code: 'ES-GA-RIAS',
          nameKey: 'zone.rias.name',
          zoneKind: 'region',
          waterType: 'salt',
        ),
      )
      ..insert(
        db.zones,
        ZonesCompanion.insert(
          id: const Value<int>(11),
          jurisdictionId: 1,
          parentZoneId: const Value<int>(10),
          code: 'ES-GA-CAMBADOS',
          nameKey: 'zone.cambados.name',
          zoneKind: 'subzone',
          waterType: 'salt',
        ),
      )
      ..insert(
        db.zones,
        ZonesCompanion.insert(
          id: const Value<int>(20),
          jurisdictionId: 1,
          code: 'ES-GA-OTHER',
          nameKey: 'zone.other.name',
          zoneKind: 'region',
          waterType: 'salt',
        ),
      );

    for (var i = 1; i <= 6; i++) {
      batch.insert(
        db.speciesTable,
        SpeciesTableCompanion.insert(
          id: Value<int>(i),
          scientificName: 'Genus species$i',
          familyId: 1,
          taxonGroup: 'finfish',
          silhouetteAsset: 'assets/sil/$i.svg',
        ),
      );
      batch.insert(
        db.citations,
        CitationsCompanion.insert(
          id: Value<int>(i),
          jurisdictionId: 1,
          instrumentTypeKey: 'instrument.orde',
          instrumentRef: 'Orde do 1 de xaneiro de 2026',
          articleRef: Value<String>('Art. $i'),
          publishedOn: '2026-01-01',
          retrievedOn: '2026-07-14',
        ),
      );
    }
  });

  await db.batch((Batch batch) {
    batch
      // 1 — jurisdiction-wide minimum. Reaches every zone.
      ..insert(
        db.rules,
        RulesCompanion.insert(
          id: const Value<int>(1),
          jurisdictionId: 1,
          speciesId: 1,
          waterType: 'salt',
          minSizeMm: const Value<int>(450),
          measurementMethodId: const Value<int>(1),
          citationId: 1,
          validFrom: '2026-01-01',
        ),
      )
      // 2 — pinned to the subzone.
      ..insert(
        db.rules,
        RulesCompanion.insert(
          id: const Value<int>(2),
          jurisdictionId: 1,
          zoneId: const Value<int>(11),
          speciesId: 2,
          waterType: 'salt',
          minSizeMm: const Value<int>(650),
          measurementMethodId: const Value<int>(2),
          citationId: 2,
          validFrom: '2026-01-01',
          specificity: const Value<int>(2),
        ),
      )
      // 3 — pinned to a zone the fisher is NOT in.
      ..insert(
        db.rules,
        RulesCompanion.insert(
          id: const Value<int>(3),
          jurisdictionId: 1,
          zoneId: const Value<int>(20),
          speciesId: 3,
          waterType: 'salt',
          minSizeMm: const Value<int>(300),
          measurementMethodId: const Value<int>(1),
          citationId: 3,
          validFrom: '2026-01-01',
        ),
      )
      // 4 — protected. Outranks everything.
      ..insert(
        db.rules,
        RulesCompanion.insert(
          id: const Value<int>(4),
          jurisdictionId: 1,
          speciesId: 4,
          waterType: 'salt',
          minSizeMm: const Value<int>(400),
          measurementMethodId: const Value<int>(1),
          isProtected: const Value<bool>(true),
          citationId: 4,
          validFrom: '2026-01-01',
        ),
      )
      // 5 — closed season. Outranks a size.
      ..insert(
        db.rules,
        RulesCompanion.insert(
          id: const Value<int>(5),
          jurisdictionId: 1,
          speciesId: 5,
          waterType: 'salt',
          minSizeMm: const Value<int>(200),
          measurementMethodId: const Value<int>(1),
          citationId: 5,
          validFrom: '2026-01-01',
        ),
      )
      // 6 — EXPIRED last season, and still shown (invariant 5).
      ..insert(
        db.rules,
        RulesCompanion.insert(
          id: const Value<int>(6),
          jurisdictionId: 1,
          speciesId: 6,
          waterType: 'salt',
          minSizeMm: const Value<int>(500),
          measurementMethodId: const Value<int>(3),
          citationId: 6,
          validFrom: '2020-01-01',
          validTo: const Value<String>('2021-12-31'),
        ),
      )
      ..insert(
        db.closedSeasons,
        ClosedSeasonsCompanion.insert(
          id: const Value<int>(1),
          ruleId: 5,
          recurrence: 'annual',
          startMonth: const Value<int>(3),
          startDay: const Value<int>(1),
          endMonth: const Value<int>(4),
          endDay: const Value<int>(30),
        ),
      );
  });

  return db;
}
