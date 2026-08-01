import 'package:path/path.dart' as p;

/// The corpus directory whose rows belong to every jurisdiction.
const String kSharedDir = 'shared';

/// The corpus directory holding the per-jurisdiction changelogs A10 writes.
const String kChangelogDir = 'CHANGELOG';

/// The authoring files of `shared/`, and the `SPEC.md` §7.1 sections each holds.
///
/// One file per concern, one section per table. A section name is the table name
/// pluralised, so an author reading `rules.yaml` and a reviewer reading the
/// schema are looking at the same word.
const Map<String, Set<String>> kSharedFiles = <String, Set<String>>{
  'families.yaml': <String>{'families'},
  'measurement_methods.yaml': <String>{'measurement_methods'},
  'species.yaml': <String>{'species'},
  'vernacular.yaml': <String>{'species_names'},
  'plates.yaml': <String>{'plates'},
  'lookalikes.yaml': <String>{'lookalikes'},
  // The identification key is one graph across three tables; splitting it over
  // three files would let a node, its options and its leaves disagree in a diff
  // nobody reads as a whole.
  'key_nodes.yaml': <String>{'key_nodes', 'key_options', 'key_leaf_species'},
  'glossary.yaml': <String>{'glossary_terms'},
  'strings.yaml': <String>{'strings'},
};

/// The authoring files of a jurisdiction directory, and the sections each holds.
const Map<String, Set<String>> kJurisdictionFiles = <String, Set<String>>{
  'jurisdiction.yaml': <String>{'jurisdiction'},
  // A zone's rings are its geometry; they are meaningless apart from it.
  'zones.yaml': <String>{'zones', 'zone_rings'},
  'citations.yaml': <String>{'citations'},
  'rules.yaml': <String>{'rules'},
  'closed_seasons.yaml': <String>{'closed_seasons'},
  'licence_types.yaml': <String>{'licence_types'},
  'gear_rules.yaml': <String>{'gear_rules'},
  'penalties.yaml': <String>{'penalties'},
  'legal_text.yaml': <String>{'legal_texts'},
  'changes.yaml': <String>{'changes'},
  'strings.yaml': <String>{'strings'},
};

/// Files a jurisdiction directory may hold that are not authored YAML.
///
/// `snapshot.json` is A10's previous state, written by the build and read by the
/// next one. It is not a corpus file and must not be parsed as one.
const Set<String> kNonYamlFiles = <String>{'snapshot.json'};

/// The sections the file at [path] may declare, or the empty set when the file
/// name is not part of the authoring format at all.
///
/// An empty result is the caller's signal to report the file rather than its
/// contents: `rule.yaml` for `rules.yaml` is a file nobody reads and nobody
/// misses, and reporting its sections instead would bury that.
Set<String> sectionsOf(String path) {
  final String name = p.basename(path);
  return kSharedFiles[name] ?? kJurisdictionFiles[name] ?? const <String>{};
}

/// Whether [name] is an authoring file of a jurisdiction directory.
bool isJurisdictionFile(String name) => kJurisdictionFiles.containsKey(name);

/// Whether [name] is an authoring file of `shared/`.
bool isSharedFile(String name) => kSharedFiles.containsKey(name);

/// Sections whose rows are identified by a column other than `id`.
///
/// `strings` rows carry `key` because `check_content_pipeline.sh` builds its
/// definition set from lines matching `^\s*(- )?key:`. A tidier `- id:` would
/// leave that set empty and make check 1 report every reference in the corpus as
/// undefined — D-2's rule of thumb, the gate script beats the prose.
const Map<String, String> kIdentityColumn = <String, String>{'strings': 'key'};

/// The column that identifies a row of [section].
String identityColumnOf(String section) => kIdentityColumn[section] ?? 'id';
