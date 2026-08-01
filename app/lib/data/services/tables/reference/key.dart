import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `key_node` — one question in the dichotomous key, or a leaf.
///
/// A leaf is a node with no `question_key` and at least one candidate species.
@DataClassName('KeyNodeRow')
class KeyNodes extends Table {
  @override
  String get tableName => 'key_node';

  IntColumn get id => integer()();

  TextColumn get taxonGroup => text().named('taxon_group')();

  /// Self-referential, so a custom constraint rather than `references`.
  IntColumn get parentNodeId =>
      integer().named('parent_node_id').nullable().customConstraint('REFERENCES key_node(id)')();

  /// `null` on a leaf.
  TextColumn get questionKey => text().named('question_key').nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// `SPEC.md` §7.1 `key_leaf_species` — one candidate at a leaf.
///
/// `WITHOUT ROWID` with a composite primary key, which is the shape S7's
/// candidate lists depend on.
@DataClassName('KeyLeafSpeciesRow')
class KeyLeafSpecies extends Table {
  @override
  String get tableName => 'key_leaf_species';

  IntColumn get nodeId => integer()
      .named('node_id')
      .customConstraint('NOT NULL REFERENCES key_node(id) ON DELETE CASCADE')();

  IntColumn get speciesId =>
      integer().named('species_id').customConstraint('NOT NULL REFERENCES species(id)')();

  /// A leaf with several candidates is an honest outcome, not a failure of the
  /// key.
  IntColumn get rank => integer().withDefault(const Constant<int>(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{nodeId, speciesId};

  @override
  bool get withoutRowId => true;
}

/// `SPEC.md` §7.1 `key_option` — one answer to a node's question.
@DataClassName('KeyOptionRow')
class KeyOptions extends Table {
  @override
  String get tableName => 'key_option';

  IntColumn get id => integer()();

  IntColumn get nodeId => integer()
      .named('node_id')
      .customConstraint('NOT NULL REFERENCES key_node(id) ON DELETE CASCADE')();

  IntColumn get optionIndex => integer().named('option_index')();

  TextColumn get labelKey => text().named('label_key')();

  TextColumn get figureAsset => text().named('figure_asset').nullable()();

  /// `null` is a dead end — S7's terminal state, and a real answer rather than
  /// an error.
  IntColumn get nextNodeId =>
      integer().named('next_node_id').nullable().customConstraint('REFERENCES key_node(id)')();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};

  @override
  List<String> get customConstraints => <String>['UNIQUE (node_id, option_index)'];
}
