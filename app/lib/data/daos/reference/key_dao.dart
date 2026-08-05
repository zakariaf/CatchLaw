import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/tables/reference/key.dart';
import 'package:catchlaw/data/services/tables/reference/taxonomy.dart';
import 'package:drift/drift.dart';

part 'key_dao.g.dart';

/// S7's dichotomous key: one couplet at a time, and what each answer still
/// allows.
///
/// **Nothing here walks the whole key into memory.** A key is a tree and a
/// screen is one node of it, so every method takes a node and answers about
/// that node — which is also what makes "the pack carries no key at all" a
/// single cheap question rather than an empty traversal.
@DriftAccessor(tables: <Type>[KeyNodes, KeyOptions, KeyLeafSpecies, SpeciesTable])
class KeyDao extends DatabaseAccessor<ReferenceDatabase> with _$KeyDaoMixin {
  /// Reads the key from [db].
  KeyDao(super.db);

  /// Where the key starts, or `null` when this pack carries no key.
  ///
  /// `null` is a real answer and not an error: a jurisdiction may ship rules,
  /// species and citations and no key at all, and the screen above says so
  /// rather than showing an empty couplet.
  Future<KeyNodeRow?> rootNode() =>
      (select(keyNodes)
            ..where(($KeyNodesTable t) => t.parentNodeId.isNull())
            ..orderBy(<OrderClauseGenerator<$KeyNodesTable>>[
              ($KeyNodesTable t) => OrderingTerm.asc(t.id),
            ])
            ..limit(1))
          .getSingleOrNull();

  /// The node with this id, or `null` when the pack does not carry it.
  Future<KeyNodeRow?> nodeAt(int nodeId) =>
      (select(keyNodes)..where(($KeyNodesTable t) => t.id.equals(nodeId))).getSingleOrNull();

  /// The answers to this node's question, in the order the key sets them.
  Future<List<KeyOptionRow>> optionsAt(int nodeId) =>
      (select(keyOptions)
            ..where(($KeyOptionsTable t) => t.nodeId.equals(nodeId))
            ..orderBy(<OrderClauseGenerator<$KeyOptionsTable>>[
              ($KeyOptionsTable t) => OrderingTerm.asc(t.optionIndex),
            ]))
          .get();

  /// Every species still reachable from [nodeId], in the key's own order.
  ///
  /// **A recursive descent and not the node's own leaf list.** The count beside
  /// a couplet is "what is still possible", which at an interior node is the
  /// union of every leaf below it; reading `key_leaf_species` for the node
  /// alone would print `0 species remain` on every question in the key.
  ///
  /// `UNION` rather than `UNION ALL`: a key whose transcription accidentally
  /// pointed two answers at the same subtree would otherwise recurse until the
  /// device ran out of memory, on a boat, at 05:40.
  Future<List<SpeciesRow>> candidatesUnder(int nodeId) async {
    final List<QueryRow> rows = await customSelect(
      'WITH RECURSIVE reachable(node_id) AS ( '
      'SELECT ?1 '
      'UNION '
      'SELECT o.next_node_id FROM key_option o '
      'JOIN reachable r ON o.node_id = r.node_id '
      'WHERE o.next_node_id IS NOT NULL '
      ') '
      'SELECT s.* FROM species s '
      'WHERE s.id IN ( '
      'SELECT k.species_id FROM key_leaf_species k '
      'JOIN reachable r ON k.node_id = r.node_id '
      ') '
      'ORDER BY s.scientific_name',
      variables: <Variable<Object>>[Variable<int>(nodeId)],
      readsFrom: <ResultSetImplementation<HasResultSet, Object>>{
        keyOptions,
        keyLeafSpecies,
        speciesTable,
      },
    ).get();
    return rows.map((QueryRow r) => speciesTable.map(r.data)).toList();
  }
}
