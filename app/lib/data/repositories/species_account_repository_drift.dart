import 'package:catchlaw/data/daos/reference/species_browse_dao.dart';
import 'package:catchlaw/data/daos/reference/species_dao.dart';
import 'package:catchlaw/data/model/mappers.dart';
import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/species_account_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/species_account.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:drift/drift.dart' show QueryRow, Variable;
import 'package:rule_engine/rule_engine.dart' show Result;

/// [SpeciesAccountRepository] over the read-only `reference.db` (D-6).
final class DriftSpeciesAccountRepository implements SpeciesAccountRepository {
  /// Reads accounts out of [db].
  DriftSpeciesAccountRepository(
    this.db, {
    required ContentStringRepository contentStrings,
    this.boundary = const StorageBoundary(),
  }) : _species = SpeciesDao(db),
       _browse = SpeciesBrowseDao(db),
       _resolver = ContentStringResolver(contentStrings);

  /// The rule book.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final SpeciesDao _species;
  final SpeciesBrowseDao _browse;
  final ContentStringResolver _resolver;

  @override
  Future<Result<SpeciesAccount>> accountFor(int speciesId, {required String locale}) =>
      boundary.guard(() async {
        final SpeciesRow? row = await _species.byId(speciesId);
        if (row == null) {
          throw DataNotFound(entity: 'species', id: '$speciesId');
        }

        final List<SpeciesNameRow> names = await _species.namesFor(speciesId);
        final List<SpeciesName> all = names.map(toSpeciesName).toList();

        // The reader's own primary name, then any name in their locale, then
        // the binomial. §9.2's chain, applied to a name list.
        final SpeciesName? own =
            all.where((SpeciesName n) => n.locale == locale && n.isPrimary).firstOrNull ??
            all.where((SpeciesName n) => n.locale == locale).firstOrNull;

        return SpeciesAccount(
          species: toSpecies(row),
          familyName: await _familyName(row.familyId, locale),
          // Latin is present in every locale and is never wrong.
          primaryName: own?.name ?? row.scientificName,
          otherNames: all.where((SpeciesName n) => n.name != own?.name).toList(),
          isProtectedAnywhere: (await _browse.protectedSpeciesIds()).contains(speciesId),
        );
      });

  Future<String> _familyName(int familyId, String locale) async {
    final List<QueryRow> rows = await db
        .customSelect(
          'SELECT name_key, scientific FROM family WHERE id = ?1',
          variables: <Variable<Object>>[Variable<int>(familyId)],
        )
        .get();
    if (rows.isEmpty) return '';
    return _resolver.resolve(
      rows.single.read<String>('name_key'),
      requestedLocale: locale,
      defaultLocale: locale,
      scientificName: rows.single.read<String>('scientific'),
    );
  }
}
