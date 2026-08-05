import 'package:catchlaw/data/daos/reference/citation_dao.dart';
import 'package:catchlaw/data/daos/reference/penalty_dao.dart';
import 'package:catchlaw/data/model/mappers.dart';
import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/penalty_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/penalty_schedule.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [PenaltyRepository] over the read-only `reference.db` (D-6).
final class DriftPenaltyRepository implements PenaltyRepository {
  /// Reads the ledger out of [db].
  DriftPenaltyRepository(
    this.db, {
    required ContentStringRepository contentStrings,
    this.boundary = const StorageBoundary(),
  }) : _penalties = PenaltyDao(db),
       _citations = CitationDao(db),
       _meta = ReferenceMetaDao(db),
       _resolver = ContentStringResolver(contentStrings);

  /// The rule book.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final PenaltyDao _penalties;
  final CitationDao _citations;
  final ReferenceMetaDao _meta;
  final ContentStringResolver _resolver;

  @override
  Future<Result<PenaltySchedule>> forJurisdiction(
    String jurisdictionCode, {
    required String locale,
  }) => boundary.guard(() async {
    final JurisdictionRow? jurisdiction = await _meta.jurisdictionByCode(jurisdictionCode);
    // A code the shipped pack does not carry. A `DataNotFound` and not an
    // empty schedule: an empty schedule states that this jurisdiction records
    // no penalty, which is a claim about the law, and nothing here has read
    // one line of that jurisdiction's law.
    if (jurisdiction == null) {
      throw DataNotFound(entity: 'jurisdiction', id: jurisdictionCode);
    }

    final String defaultLocale = jurisdiction.defaultLocale;
    final List<PenaltyRow> rows = await _penalties.forJurisdiction(jurisdiction.id);
    // Every instrument in one statement rather than one per row: a schedule of
    // six tiers quoting two orders is two reads, not six.
    final citations = <int, CitationRow>{
      for (final CitationRow row in await _citations.byIds(
        rows.map((PenaltyRow row) => row.citationId),
      ))
        row.id: row,
    };

    final tiers = <PenaltyTier>[];
    for (final row in rows) {
      final CitationRow? citation = citations[row.citationId];
      // Invariant 3 read from the data side: a penalty whose instrument the
      // pack no longer carries is DROPPED rather than printed with an empty
      // footnote. An uncitable fine is a rumour about the law.
      if (citation == null) continue;

      tiers.add(
        PenaltyTier(
          offence: await _resolver.resolve(
            row.offenceKey,
            requestedLocale: locale,
            defaultLocale: defaultLocale,
          ),
          occurrence: row.occurrence,
          citation: toCitation(citation),
          amountMin: row.amountMin,
          amountMax: row.amountMax,
          currency: row.currency,
          consequence: row.secondaryKey == null
              ? null
              : await _resolver.resolve(
                  row.secondaryKey!,
                  requestedLocale: locale,
                  defaultLocale: defaultLocale,
                ),
        ),
      );
    }

    return PenaltySchedule(
      jurisdictionName: await _resolver.resolve(
        jurisdiction.nameKey,
        requestedLocale: locale,
        defaultLocale: defaultLocale,
      ),
      authority: await _resolver.resolve(
        jurisdiction.authorityKey,
        requestedLocale: locale,
        defaultLocale: defaultLocale,
      ),
      tiers: tiers,
    );
  });
}
