import 'package:catchlaw/data/daos/reference/key_dao.dart';
import 'package:catchlaw/data/daos/reference/species_dao.dart';
import 'package:catchlaw/data/repositories/content_string_repository.dart';
import 'package:catchlaw/data/repositories/identification_key_repository.dart';
import 'package:catchlaw/data/repositories/storage_boundary.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/domain/models/key_step.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// [IdentificationKeyRepository] over the read-only `reference.db` (D-6).
final class DriftIdentificationKeyRepository implements IdentificationKeyRepository {
  /// Walks the key in [db].
  DriftIdentificationKeyRepository(
    this.db, {
    required ContentStringRepository contentStrings,
    this.boundary = const StorageBoundary(),
  }) : _key = KeyDao(db),
       _species = SpeciesDao(db),
       _resolver = ContentStringResolver(contentStrings);

  /// The rule book.
  final ReferenceDatabase db;

  /// Where a storage exception becomes a `DataFailure`.
  final StorageBoundary boundary;

  final KeyDao _key;
  final SpeciesDao _species;
  final ContentStringResolver _resolver;

  @override
  Future<Result<KeyStep?>> firstStep({required String locale}) => boundary.guard(() async {
    final KeyNodeRow? root = await _key.rootNode();
    if (root == null) return null;
    return _step(root, locale);
  });

  @override
  Future<Result<KeyStep?>> stepAt(int nodeId, {required String locale}) => boundary.guard(() async {
    final KeyNodeRow? node = await _key.nodeAt(nodeId);
    if (node == null) return null;
    return _step(node, locale);
  });

  /// One node, with its question, its answers and what each still allows.
  Future<KeyStep> _step(KeyNodeRow node, String locale) async {
    // Built once for the whole node and shared with every lead below it. A
    // lead's candidates are a subset of the node's, so resolving a name per
    // lead would read the same rows twice at every couplet — and the root of a
    // key covers the whole pack.
    final known = <int, KeyCandidate>{};
    final List<KeyCandidate> candidates = await _candidates(node.id, locale, known);

    final List<KeyOptionRow> options = await _key.optionsAt(node.id);
    final leads = <KeyLead>[];
    for (final (int index, KeyOptionRow option) in options.indexed) {
      final int? next = option.nextNodeId;
      leads.add(
        KeyLead(
          optionId: option.id,
          // Counting from one, as a printed key marks its leads. The stored
          // `option_index` is a transcription ordinal and may start anywhere.
          mark: index + 1,
          label: await _resolver.resolve(
            option.labelKey,
            requestedLocale: locale,
            defaultLocale: locale,
          ),
          figureAsset: option.figureAsset,
          nextNodeId: next,
          // A null `next_node_id` is the key's terminal state (§7.1), so an
          // answer with nothing under it carries an empty list rather than
          // failing the read.
          candidates: next == null
              ? const <KeyCandidate>[]
              : await _candidates(next, locale, known),
        ),
      );
    }

    final String? questionKey = node.questionKey;
    return KeyStep(
      nodeId: node.id,
      question: questionKey == null
          ? null
          : await _resolver.resolve(questionKey, requestedLocale: locale, defaultLocale: locale),
      leads: leads,
      candidates: candidates,
    );
  }

  /// Every species reachable from [nodeId], resolved into [locale].
  Future<List<KeyCandidate>> _candidates(
    int nodeId,
    String locale,
    Map<int, KeyCandidate> known,
  ) async {
    final List<SpeciesRow> rows = await _key.candidatesUnder(nodeId);
    final resolved = <KeyCandidate>[];
    for (final row in rows) {
      resolved.add(
        known[row.id] ??= KeyCandidate(
          speciesId: row.id,
          displayName: await _displayName(row, locale),
          scientificName: row.scientificName,
          silhouetteAsset: row.silhouetteAsset,
        ),
      );
    }
    // Sorted in Dart, not in SQL: SQLite's ORDER BY collates bytes, and `Ñ`
    // would sort after `Z` in a Galician candidate list.
    resolved.sort((KeyCandidate a, KeyCandidate b) => a.displayName.compareTo(b.displayName));
    return resolved;
  }

  /// The species' name in [locale], falling back to its binomial.
  Future<String> _displayName(SpeciesRow row, String locale) async {
    final List<SpeciesNameRow> names = await _species.namesFor(row.id);
    for (final name in names) {
      if (name.locale == locale && name.isPrimary) return name.name;
    }
    for (final name in names) {
      if (name.locale == locale) return name.name;
    }
    // Latin is present in every locale and is never wrong — §9.2's fourth step.
    return row.scientificName;
  }
}
