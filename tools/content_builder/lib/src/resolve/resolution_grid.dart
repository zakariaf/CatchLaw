import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/model/geography.dart';
import 'package:content_builder/src/model/taxon.dart';
import 'package:content_builder/src/resolve/rule_set_adapter.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Species, WaterType, Zone;

/// One cell of the authored grid: a species, a place, a month and a water type.
@immutable
class GridCell {
  /// A cell for [speciesId] in [zoneId] during [month].
  const GridCell({
    required this.speciesId,
    required this.jurisdictionId,
    required this.zoneId,
    required this.zonePath,
    required this.month,
    required this.waterType,
  });

  /// The authored species id.
  final String speciesId;

  /// The authored jurisdiction id.
  final String jurisdictionId;

  /// The authored zone id, or `null` for the jurisdiction as a whole.
  final String? zoneId;

  /// The zone's ancestry, nearest first, materialised once per zone.
  final List<Zone> zonePath;

  /// 1–12. A closure that is in force for one month of the year is missed by a
  /// grid that samples the year once.
  final int month;

  /// `salt` or `fresh`. Never `both`: that is a property of a rule, and a
  /// `both` request would make the fresh-drops-in-salt guard meaningless.
  final WaterType waterType;

  /// The ISO date this cell is evaluated on: the 15th, so no cell lands on a
  /// month boundary where a closure opens or closes.
  String isoDate(int year) => '$year-${month.toString().padLeft(2, '0')}-15';

  @override
  String toString() =>
      '($speciesId, ${zoneId ?? jurisdictionId}, '
      '${month.toString().padLeft(2, '0')}, ${waterType.name})';
}

/// The (species × zone × month × water type) sweep A8 resolves.
abstract final class ResolutionGrid {
  /// Every cell of [source], grouped by `(species, water type)`.
  ///
  /// Grouped rather than flat because the candidate fetch happens **once per
  /// group**: `SPEC.md` §13 budgets one evaluation at under 10 ms over at most
  /// twenty candidate rows, and that budget includes the device's row read.
  /// Re-collecting per cell would multiply the expensive half by the whole grid.
  static Map<({Species species, WaterType waterType}), List<GridCell>> of(
    ContentSource source,
    RuleSetAdapter adapter,
  ) {
    final List<SpeciesRow> species = source.typedRows.whereType<SpeciesRow>().toList();
    final List<JurisdictionRow> jurisdictions = source.typedRows
        .whereType<JurisdictionRow>()
        .toList();
    final List<ZoneRow> zones = source.typedRows.whereType<ZoneRow>().toList();

    final grid = <({Species species, WaterType waterType}), List<GridCell>>{};

    for (final jurisdiction in jurisdictions) {
      // Only the water types the jurisdiction declares. Galicia regulates salt
      // water; generating freshwater cells would report NoRuleFound for every
      // one of them and bury the real failures.
      final waterTypes = <WaterType>[
        if (jurisdiction.hasSaltwater) WaterType.salt,
        if (jurisdiction.hasFreshwater) WaterType.fresh,
      ];

      final List<ZoneRow> own = zones
          .where((ZoneRow z) => z.jurisdictionId == jurisdiction.id)
          .toList();
      // `null` is the jurisdiction as a whole — where no coordinate list is
      // printed in the instrument, rules apply jurisdiction-wide and we do not
      // invent boundaries.
      final places = <String?>[null, ...own.map((ZoneRow z) => z.id)];

      for (final s in species) {
        // Total by construction: the adapter's species map is built from these
        // same rows. A null guard here would be a branch nothing can take, and
        // an unreachable branch cannot be proved exercised.
        final Species engineSpecies = adapter.species[s.id]!;
        for (final waterType in waterTypes) {
          final List<GridCell> cells = grid[(species: engineSpecies, waterType: waterType)] ??=
              <GridCell>[];
          for (final place in places) {
            final List<Zone> path = adapter.zonePathOf(place);
            for (var month = 1; month <= 12; month++) {
              cells.add(
                GridCell(
                  speciesId: s.id,
                  jurisdictionId: jurisdiction.id,
                  zoneId: place,
                  zonePath: path,
                  month: month,
                  waterType: waterType,
                ),
              );
            }
          }
        }
      }
    }

    return grid;
  }
}
