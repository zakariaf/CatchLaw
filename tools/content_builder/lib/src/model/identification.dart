import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/content_row.dart';

/// A `key_node` row: one question in the dichotomous key, or a leaf.
///
/// A leaf is a node with no `question_key` and at least one candidate species.
class KeyNodeRow extends ContentRow {
  /// A node read from [path] at [line].
  const KeyNodeRow({
    required super.path,
    required super.line,
    required super.id,
    required this.taxonGroup,
    this.parentNodeId,
    this.questionKey,
  });

  /// Reads a node from [row].
  factory KeyNodeRow.fromRow(YamlRow row) => KeyNodeRow(
    path: row.path,
    line: row.line,
    id: row.id,
    taxonGroup: row.string('taxon_group'),
    parentNodeId: row.string('parent_node_id'),
    questionKey: row.string('question_key'),
  );

  /// The group this branch of the key covers.
  final String? taxonGroup;

  /// `null` at the root of the group's key.
  final String? parentNodeId;

  /// Localised question. `null` on a leaf.
  final String? questionKey;
}

/// A `key_option` row: one answer to a node's question.
class KeyOptionRow extends ContentRow {
  /// An option read from [path] at [line].
  const KeyOptionRow({
    required super.path,
    required super.line,
    required super.id,
    required this.nodeId,
    required this.optionIndex,
    required this.labelKey,
    this.figureAsset,
    this.nextNodeId,
  });

  /// Reads an option from [row].
  factory KeyOptionRow.fromRow(YamlRow row) => KeyOptionRow(
    path: row.path,
    line: row.line,
    id: row.id,
    nodeId: row.string('node_id'),
    optionIndex: row.integer('option_index'),
    labelKey: row.string('label_key'),
    figureAsset: row.string('figure_asset'),
    nextNodeId: row.string('next_node_id'),
  );

  /// The node this option answers.
  final String? nodeId;

  /// Display order, unique within the node.
  final int? optionIndex;

  /// Localised answer.
  final String? labelKey;

  /// Originated SVG illustrating the answer.
  final String? figureAsset;

  /// `null` is a dead end — S7's terminal state, and a real answer rather than
  /// an error.
  final String? nextNodeId;
}

/// A `key_leaf_species` row: one candidate at a leaf.
class KeyLeafSpeciesRow extends ContentRow {
  /// A candidate read from [path] at [line].
  const KeyLeafSpeciesRow({
    required super.path,
    required super.line,
    required super.id,
    required this.nodeId,
    required this.speciesId,
    this.rank = 0,
  });

  /// Reads a candidate from [row].
  factory KeyLeafSpeciesRow.fromRow(YamlRow row) => KeyLeafSpeciesRow(
    path: row.path,
    line: row.line,
    id: row.id,
    nodeId: row.string('node_id'),
    speciesId: row.string('species_id'),
    rank: row.integer('rank') ?? 0,
  );

  /// The leaf.
  final String? nodeId;

  /// A species the key cannot separate further.
  final String? speciesId;

  /// Display order. A leaf with several candidates is an honest outcome, not a
  /// failure of the key.
  final int rank;
}
