import 'dart:io';
import 'dart:typed_data';

import 'package:content_builder/src/assert/a07_norm_parity.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/cli/options.dart';
import 'package:content_builder/src/emit/schema.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/taxon.dart';
import 'package:content_builder/src/normalise/norm_columns.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// The `SPEC.md` §7.1 tables, in insert order.
///
/// Order is dependency order, so `PRAGMA foreign_keys = ON` catches a mistake at
/// the insert that made it rather than at the end of the build.
const List<TableSpec> kTables = <TableSpec>[
  (
    table: 'jurisdiction',
    section: 'jurisdiction',
    columns: <String>[
      'code',
      'country_iso2',
      'name_key',
      'authority_key',
      'authority_url',
      'has_freshwater',
      'has_saltwater',
      'has_zone_polygons',
      'default_locale',
      'legal_text_locales',
      'content_version',
      'published_on',
      'checked_on',
      'valid_until',
    ],
    references: <String, String>{},
  ),
  (
    table: 'zone',
    section: 'zones',
    columns: <String>[
      'jurisdiction_id',
      'parent_zone_id',
      'code',
      'name_key',
      'water_type',
      'zone_kind',
      'geometry_source',
      'min_lat',
      'min_lon',
      'max_lat',
      'max_lon',
    ],
    references: <String, String>{'jurisdiction_id': 'jurisdiction', 'parent_zone_id': 'zones'},
  ),
  (
    table: 'family',
    section: 'families',
    columns: <String>['scientific', 'name_key'],
    references: <String, String>{},
  ),
  (
    table: 'species',
    section: 'species',
    columns: <String>[
      'scientific_name',
      'col_id',
      'family_id',
      'taxon_group',
      'silhouette_asset',
      'plate_asset',
    ],
    references: <String, String>{'family_id': 'families'},
  ),
  (
    table: 'measurement_method',
    section: 'measurement_methods',
    columns: <String>['code', 'name_key', 'definition_key', 'diagram_asset'],
    references: <String, String>{},
  ),
  (
    table: 'citation',
    section: 'citations',
    columns: <String>[
      'jurisdiction_id',
      'instrument_type_key',
      'instrument_ref',
      'article_ref',
      'published_on',
      'source_url',
      'retrieved_on',
    ],
    references: <String, String>{'jurisdiction_id': 'jurisdiction'},
  ),
  (
    table: 'licence_type',
    section: 'licence_types',
    columns: <String>[
      'jurisdiction_id',
      'zone_id',
      'water_type',
      'code',
      'name_key',
      'description_key',
      'citation_id',
    ],
    references: <String, String>{
      'jurisdiction_id': 'jurisdiction',
      'zone_id': 'zones',
      'citation_id': 'citations',
    },
  ),
  (
    table: 'rule',
    section: 'rules',
    columns: <String>[
      'jurisdiction_id',
      'zone_id',
      'species_id',
      'water_type',
      'min_size_mm',
      'max_size_mm',
      'measurement_method_id',
      'bag_limit',
      'bag_limit_unit',
      'bag_limit_period',
      'vessel_limit',
      'is_protected',
      'licence_type_id',
      'notes_key',
      'citation_id',
      'valid_from',
      'valid_to',
      'specificity',
    ],
    references: <String, String>{
      'jurisdiction_id': 'jurisdiction',
      'zone_id': 'zones',
      'species_id': 'species',
      'measurement_method_id': 'measurement_methods',
      'licence_type_id': 'licence_types',
      'citation_id': 'citations',
    },
  ),
  (
    table: 'closed_season',
    section: 'closed_seasons',
    columns: <String>[
      'rule_id',
      'recurrence',
      'start_month',
      'start_day',
      'end_month',
      'end_day',
      'start_date',
      'end_date',
      'notes_key',
      'citation_id',
    ],
    references: <String, String>{'rule_id': 'rules', 'citation_id': 'citations'},
  ),
  (
    table: 'gear_rule',
    section: 'gear_rules',
    columns: <String>[
      'jurisdiction_id',
      'zone_id',
      'species_id',
      'gear_code',
      'gear_name_key',
      'is_allowed',
      'constraint_key',
      'citation_id',
    ],
    references: <String, String>{
      'jurisdiction_id': 'jurisdiction',
      'zone_id': 'zones',
      'species_id': 'species',
      'citation_id': 'citations',
    },
  ),
  (
    table: 'penalty',
    section: 'penalties',
    columns: <String>[
      'jurisdiction_id',
      'offence_key',
      'occurrence',
      'amount_min',
      'amount_max',
      'currency',
      'secondary_key',
      'citation_id',
    ],
    references: <String, String>{'jurisdiction_id': 'jurisdiction', 'citation_id': 'citations'},
  ),
  (
    table: 'lookalike',
    section: 'lookalikes',
    columns: <String>['species_id', 'confused_with', 'difference_key'],
    references: <String, String>{'species_id': 'species', 'confused_with': 'species'},
  ),
  (
    table: 'glossary_term',
    section: 'glossary_terms',
    columns: <String>['jurisdiction_id', 'term_key', 'definition_key', 'sort_order'],
    references: <String, String>{'jurisdiction_id': 'jurisdiction'},
  ),
  (
    table: 'content_change',
    section: 'changes',
    columns: <String>[
      'jurisdiction_id',
      'from_version',
      'to_version',
      'summary_key',
      'detail_key',
      'changed_on',
    ],
    references: <String, String>{'jurisdiction_id': 'jurisdiction'},
  ),
  (
    table: 'key_node',
    section: 'key_nodes',
    columns: <String>['taxon_group', 'parent_node_id', 'question_key'],
    references: <String, String>{'parent_node_id': 'key_nodes'},
  ),
  (
    table: 'key_option',
    section: 'key_options',
    columns: <String>['node_id', 'option_index', 'label_key', 'figure_asset', 'next_node_id'],
    references: <String, String>{'node_id': 'key_nodes', 'next_node_id': 'key_nodes'},
  ),
  (
    table: 'legal_text',
    section: 'legal_texts',
    columns: <String>[
      'jurisdiction_id',
      'citation_id',
      'locale',
      'article_ref',
      'body',
      'body_norm',
      'sort_order',
    ],
    references: <String, String>{'jurisdiction_id': 'jurisdiction', 'citation_id': 'citations'},
  ),
];

/// One §7.1 table, the authoring section it comes from, and its columns.
typedef TableSpec = ({
  String table,
  String section,
  List<String> columns,
  Map<String, String> references,
});

/// Emits [source] to `options.outFile`, its gzip and its sidecar.
///
/// **Byte-identical from identical input**, which the sidecar's digest depends
/// on. Four things make it so:
///
/// 1. **No clock.** `build_date` and `generator_commit` come from the CLI.
/// 2. **Explicit primary keys, assigned from sorted authored ids.** Letting
///    SQLite assign rowids makes the file depend on insert order, which depends
///    on directory-walk order, which depends on the filesystem.
/// 3. **Fixed page geometry** — `page_size = 4096`, `auto_vacuum = NONE`,
///    `journal_mode = DELETE`, so no `-wal` is left beside the file. A stray
///    `-wal` breaks every later sha256 check.
/// 4. **`VACUUM INTO`** the final path, so freelist churn and page fragmentation
///    from the build cannot reach the shipped file.
///
/// The residual, stated honestly: byte-identity holds **for a fixed SQLite
/// library version**. The header records the writing library, and a page-layout
/// change between releases would move bytes. That is why the determinism test
/// compares two builds inside one run rather than a build against a checked-in
/// hash.
List<Failure> emitReferenceDb(ContentSource source, ContentBuildOptions options) {
  final Directory work = Directory.systemTemp.createTempSync('content_builder_emit_');
  final staging = File(p.join(work.path, 'staging.db'));

  try {
    final Database db = sqlite3.open(staging.path);
    try {
      _configure(db);
      db.execute(kSchemaSql);
      _insert(db, source, options);
    } on SqliteException catch (e) {
      // Never a stack trace. SQLite's own message names the constraint and the
      // table — more than the assertions can say about a row none of them
      // covers — but it arrives as one line on stderr, like every other
      // failure.
      return <Failure>[
        Failure('A0', options.outFile.path, 0, 'the emitted schema rejected a row: ${e.message}'),
      ];
    } finally {
      db.dispose();
    }

    final File out = options.outFile..parent.createSync(recursive: true);
    if (out.existsSync()) out.deleteSync();
    // VACUUM INTO writes the destination fresh. Copying the staging file would
    // carry its freelist, and a freelist depends on the order rows were
    // inserted and deleted rather than on what the corpus says.
    final Database staged = sqlite3.open(staging.path);
    try {
      staged.execute('VACUUM INTO ?', <Object?>[out.path]);
    } finally {
      staged.dispose();
    }

    // A7 runs against the EMITTED bytes, read-only. A writable verification
    // open is how a `-wal` appears after the digest was taken.
    final Database emitted = sqlite3.open(out.path, mode: OpenMode.readOnly);
    final List<Failure> problems;
    try {
      problems = <Failure>[
        ..._verify(emitted, out.path),
        ...const NormParityAssertion().verify(emitted, path: out.path),
      ];
    } finally {
      emitted.dispose();
    }

    if (problems.isNotEmpty) {
      // An unindexed or inconsistent database is worse than none: the app would
      // open it, answer, and be wrong.
      out.deleteSync();
      return problems;
    }

    return const <Failure>[];
  } finally {
    work.deleteSync(recursive: true);
  }
}

void _configure(Database db) {
  db
    ..execute('PRAGMA page_size = 4096')
    ..execute('PRAGMA auto_vacuum = NONE')
    // DELETE, not WAL: catchlaw-reference-database rule 3 — a `-wal` left
    // beside the file breaks every later sha256 check.
    ..execute('PRAGMA journal_mode = DELETE')
    ..execute('PRAGMA foreign_keys = ON');
}

void _insert(Database db, ContentSource source, ContentBuildOptions options) {
  final ids = <String, Map<String, int>>{};
  for (final TableSpec spec in kTables) {
    ids[spec.section] = _numbered(source.section(spec.section).map((YamlRow r) => r.id));
  }

  for (final TableSpec spec in kTables) {
    final List<YamlRow> rows = source.section(spec.section).toList()
      ..sort((YamlRow a, YamlRow b) => a.id.compareTo(b.id));
    for (final row in rows) {
      // Unauthored columns are OMITTED rather than written as NULL, so §7.1's
      // own DEFAULT applies. Writing NULL into `has_saltwater INTEGER NOT NULL
      // DEFAULT 1` fails the constraint, and defaulting it here would be a
      // second copy of the schema — the thing this task exists to avoid.
      final columns = <String>['id'];
      final values = <Object?>[ids[spec.section]![row.id]];
      for (final String column in spec.columns) {
        final Object? value = _value(row, column, spec.references[column], ids);
        if (value == null) continue;
        columns.add(column);
        values.add(value);
      }
      db.execute(
        'INSERT INTO ${spec.table} (${columns.join(', ')}) '
        'VALUES (${List<String>.filled(columns.length, '?').join(', ')})',
        values,
      );
    }
  }

  _insertSpeciesNames(db, source, ids);
  _insertContentStrings(db, source);
  _insertKeyLeafSpecies(db, source, ids);
  _insertZoneRings(db, source, ids);
  _insertLegalTextNorms(db);

  // content_meta is NOT authored: authoring it would let the file disagree with
  // the run that produced it.
  for (final MapEntry<String, String> meta in <String, String>{
    'schema_version': kSchemaVersion,
    'build_date': _iso(options.buildDate),
    'generator_commit': options.generatorCommit,
  }.entries) {
    db.execute('INSERT INTO content_meta (key, value) VALUES (?, ?)', <Object?>[
      meta.key,
      meta.value,
    ]);
  }
}

void _insertSpeciesNames(Database db, ContentSource source, Map<String, Map<String, int>> ids) {
  final List<SpeciesNameRow> authored = source.typedRows.whereType<SpeciesNameRow>().toList()
    ..sort((SpeciesNameRow a, SpeciesNameRow b) => a.id.compareTo(b.id));
  final List<NormalisedName> keyed = NormColumns.populate(authored);

  for (var i = 0; i < keyed.length; i++) {
    final NormalisedName name = keyed[i];
    db.execute(
      'INSERT INTO species_name '
      '(id, species_id, locale, name, search_norm, gender, is_primary, region_hint) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      <Object?>[
        i + 1,
        ids['species']![name.speciesId],
        name.locale,
        name.name,
        name.searchNorm,
        name.source.gender,
        name.isPrimary ? 1 : 0,
        name.source.regionHint,
      ],
    );
  }
}

void _insertContentStrings(Database db, ContentSource source) {
  final List<YamlRow> rows = source.section('strings').toList()
    ..sort((YamlRow a, YamlRow b) => a.id.compareTo(b.id));
  for (final row in rows) {
    final Map<String, Object?> values = row.map('values') ?? const <String, Object?>{};
    for (final String locale in values.keys.toList()..sort()) {
      db.execute('INSERT INTO content_string (key, locale, value) VALUES (?, ?, ?)', <Object?>[
        row.id,
        locale,
        '${values[locale]}',
      ]);
    }
  }
}

void _insertKeyLeafSpecies(Database db, ContentSource source, Map<String, Map<String, int>> ids) {
  final List<YamlRow> rows = source.section('key_leaf_species').toList()
    ..sort((YamlRow a, YamlRow b) => a.id.compareTo(b.id));
  for (final row in rows) {
    db.execute(
      'INSERT INTO key_leaf_species (node_id, species_id, rank) VALUES (?, ?, ?)',
      <Object?>[
        ids['key_nodes']![row.string('node_id')],
        ids['species']![row.string('species_id')],
        row.integer('rank') ?? 0,
      ],
    );
  }
}

void _insertZoneRings(Database db, ContentSource source, Map<String, Map<String, int>> ids) {
  final List<YamlRow> rows = source.section('zone_rings').toList()
    ..sort((YamlRow a, YamlRow b) => a.id.compareTo(b.id));
  final Map<String, int> ringIds = _numbered(rows.map((YamlRow r) => r.id));
  for (final row in rows) {
    final List<Object?> coords = row.list('coords') ?? const <Object?>[];
    // point_count is DERIVED. A hand-kept count and a hand-kept list disagree
    // the first time a coordinate is added.
    final data = ByteData(coords.length * 16);
    for (var i = 0; i < coords.length; i++) {
      final Object? pair = coords[i];
      if (pair is! List<Object?> || pair.length < 2) continue;
      data
        ..setFloat64(i * 16, (pair[0]! as num).toDouble(), Endian.little)
        ..setFloat64(i * 16 + 8, (pair[1]! as num).toDouble(), Endian.little);
    }
    db.execute(
      'INSERT INTO zone_ring (id, zone_id, ring_index, is_hole, point_count, coords) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      <Object?>[
        ringIds[row.id],
        ids['zones']![row.string('zone_id')],
        row.integer('ring_index') ?? 0,
        (row.boolean('is_hole') ?? false) ? 1 : 0,
        coords.length,
        data.buffer.asUint8List(),
      ],
    );
  }
}

/// Populates the FTS index over `body_norm`.
///
/// `unicode61` does not fold Arabic orthographic variants, so the index is over
/// `body_norm` — the engine's own fold — and not over `body`.
/// `remove_diacritics 2` handles the Latin side.
///
/// An **external-content** FTS table does not populate itself, and an empty
/// index fails silently: every query returns nothing, which reads as "the text
/// is not in the app".
void _insertLegalTextNorms(Database db) {
  db.execute('INSERT INTO legal_text_fts(rowid, body_norm) SELECT id, body_norm FROM legal_text');
}

/// `foreign_key_check` and `integrity_check`, on the emitted file.
///
/// `PRAGMA foreign_keys = ON` during the build catches an ordering mistake at
/// the insert that made it; `foreign_key_check` at the end catches the ones a
/// deferred constraint let through. Neither is redundant.
Iterable<Failure> _verify(Database db, String path) sync* {
  for (final Row row in db.select('PRAGMA foreign_key_check')) {
    yield Failure('A0', path, 0, 'foreign key violation in ${row.values.first}');
  }
  final integrity = '${db.select('PRAGMA integrity_check').first.values.first}';
  if (integrity != 'ok') {
    yield Failure('A0', path, 0, 'integrity_check says $integrity');
  }
}

Object? _value(
  YamlRow row,
  String column,
  String? referencedSection,
  Map<String, Map<String, int>> ids,
) {
  if (referencedSection != null) {
    final String? authored = row.string(column) ?? row.string(_aliasOf(column) ?? '');
    return authored == null ? null : ids[referencedSection]?[authored];
  }
  // body_norm is COMPUTED, never authored: it comes from the engine's own fold,
  // and content/README.md says so.
  if (column == 'body_norm') return NormColumns.bodyNorm(row.string('body') ?? '');

  final String? alias = _aliasOf(column);
  final Object? raw = row.fields[column] ?? (alias == null ? null : row.fields[alias]);
  if (raw == null) return kEmitDefaults[column];
  return raw is bool ? (raw ? 1 : 0) : raw;
}

/// The three columns whose authored name differs from the §7.1 spelling.
///
/// The citation block authors `jurisdiction`, `instrument` and `article` so
/// `check_content_pipeline.sh` check 2 can see it; §7.1 calls the columns
/// `jurisdiction_id`, `instrument_ref` and `article_ref`. D-2's rule of thumb —
/// where a gate and the prose disagree about a shape, the gate wins — and this
/// is where the two names meet again.
String? _aliasOf(String column) => switch (column) {
  'instrument_ref' => 'instrument',
  'article_ref' => 'article',
  'jurisdiction_id' => 'jurisdiction',
  _ => null,
};

/// Values for `NOT NULL` §7.1 columns that carry no `DEFAULT`.
///
/// Two of them, both ordering hints the author has no reason to write on every
/// row. Anything more would be a second copy of the schema living here.
const Map<String, Object?> kEmitDefaults = <String, Object?>{'sort_order': 0, 'occurrence': 1};

Map<String, int> _numbered(Iterable<String> ids) {
  final List<String> sorted = ids.toSet().toList()..sort();
  return <String, int>{for (var i = 0; i < sorted.length; i++) sorted[i]: i + 1};
}

String _iso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
