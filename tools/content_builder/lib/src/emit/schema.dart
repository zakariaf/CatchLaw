/// `SPEC.md` §7.1, verbatim.
///
/// One copy. §7.1 is authoritative and E05 generates its drift tables from the
/// same source; two hand-maintained copies of a schema disagree within a month,
/// and the disagreement surfaces as a `no such column` on a user's phone.
///
/// **Nothing generates this.** Building the schema from the Dart row models
/// would reverse the authority — the models exist to serve §7.1, not the other
/// way round.
///
/// It is a Dart string rather than a `.sql` asset because a package cannot read
/// a file beside its own source at runtime without guessing at a path, and a
/// guessed path is a build that works from one directory and not another.
library;

/// The `SPEC.md` §7.1 schema, statement for statement.
const String kSchemaSql = r'''
PRAGMA foreign_keys = ON;

CREATE TABLE jurisdiction (
  id                INTEGER PRIMARY KEY,
  code              TEXT    NOT NULL UNIQUE,      -- 'AE-RK', 'ES-GA', 'BR-SP'
  country_iso2      TEXT    NOT NULL,
  name_key          TEXT    NOT NULL,
  authority_key     TEXT    NOT NULL,
  authority_url     TEXT,                         -- selectable text only; never launched
  has_freshwater    INTEGER NOT NULL DEFAULT 0,
  has_saltwater     INTEGER NOT NULL DEFAULT 1,
  has_zone_polygons INTEGER NOT NULL DEFAULT 0,   -- 0 => S9 hides the sub-zone level
  default_locale    TEXT    NOT NULL,
  legal_text_locales TEXT   NOT NULL,             -- CSV, e.g. 'ar' or 'gl,es' (see §9.6)
  content_version   TEXT    NOT NULL,
  published_on      TEXT    NOT NULL,
  checked_on        TEXT    NOT NULL,
  valid_until       TEXT
);

CREATE TABLE zone (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  parent_zone_id  INTEGER REFERENCES zone(id),
  code            TEXT NOT NULL,
  name_key        TEXT NOT NULL,
  water_type      TEXT NOT NULL CHECK (water_type IN ('salt','fresh','both')),
  zone_kind       TEXT NOT NULL CHECK (zone_kind IN
                    ('region','subzone','bank','basin','reserve','exclusion')),
  geometry_source TEXT,                            -- attribution key; NULL when no polygon
  min_lat REAL, min_lon REAL, max_lat REAL, max_lon REAL,
  UNIQUE (jurisdiction_id, code)
);
CREATE INDEX idx_zone_juris ON zone(jurisdiction_id);
CREATE INDEX idx_zone_bbox  ON zone(min_lat, max_lat, min_lon, max_lon);

CREATE TABLE zone_ring (            -- packed little-endian Float64 [lat,lon] pairs
  id          INTEGER PRIMARY KEY,
  zone_id     INTEGER NOT NULL REFERENCES zone(id) ON DELETE CASCADE,
  ring_index  INTEGER NOT NULL,
  is_hole     INTEGER NOT NULL DEFAULT 0,
  point_count INTEGER NOT NULL,
  coords      BLOB    NOT NULL,
  UNIQUE (zone_id, ring_index)
);

CREATE TABLE family (
  id            INTEGER PRIMARY KEY,
  scientific    TEXT NOT NULL UNIQUE,   -- 'Lethrinidae'
  name_key      TEXT NOT NULL           -- localised family name -> content_string
);

CREATE TABLE species (
  id               INTEGER PRIMARY KEY,
  scientific_name  TEXT NOT NULL UNIQUE,
  col_id           TEXT,                            -- Catalogue of Life taxon id (CC BY 4.0)
  family_id        INTEGER NOT NULL REFERENCES family(id),
  taxon_group      TEXT NOT NULL CHECK (taxon_group IN
                     ('finfish','crustacean','bivalve','gastropod','cephalopod',
                      'echinoderm','elasmobranch','other')),
  silhouette_asset TEXT NOT NULL,
  plate_asset      TEXT                             -- optional; cleared per §8
);
CREATE INDEX idx_species_family ON species(family_id);

CREATE TABLE species_name (
  id          INTEGER PRIMARY KEY,
  species_id  INTEGER NOT NULL REFERENCES species(id) ON DELETE CASCADE,
  locale      TEXT NOT NULL,                        -- 'ar','es','gl','ca','pt_BR','en'
  name        TEXT NOT NULL,
  search_norm TEXT NOT NULL,                        -- normalised per §9.4
  gender      TEXT CHECK (gender IN ('m','f','n')), -- required in gendered locales; §9.5
  is_primary  INTEGER NOT NULL DEFAULT 0,
  region_hint TEXT                                  -- 'RAK', 'Rías Baixas'
);
CREATE INDEX idx_name_search  ON species_name(search_norm);
CREATE INDEX idx_name_species ON species_name(species_id, locale);

CREATE TABLE measurement_method (
  id             INTEGER PRIMARY KEY,
  code           TEXT NOT NULL UNIQUE,   -- 'TL','FL','SL','CW','CL','ML','DW','SHL','CUSTOM'
  name_key       TEXT NOT NULL,
  definition_key TEXT NOT NULL,
  diagram_asset  TEXT NOT NULL
);

CREATE TABLE citation (
  id                   INTEGER PRIMARY KEY,
  jurisdiction_id      INTEGER NOT NULL REFERENCES jurisdiction(id),
  instrument_type_key  TEXT NOT NULL,     -- localised label -> content_string
  instrument_ref       TEXT NOT NULL,     -- 'MD 580/2015'
  article_ref          TEXT,
  published_on         TEXT NOT NULL,
  source_url           TEXT,              -- selectable text only
  retrieved_on         TEXT NOT NULL
);

CREATE TABLE rule (
  id                    INTEGER PRIMARY KEY,
  jurisdiction_id       INTEGER NOT NULL REFERENCES jurisdiction(id),
  zone_id               INTEGER REFERENCES zone(id),   -- NULL = whole jurisdiction
  species_id            INTEGER NOT NULL REFERENCES species(id),
  water_type            TEXT NOT NULL CHECK (water_type IN ('salt','fresh','both')),
  min_size_mm           INTEGER,
  max_size_mm           INTEGER,
  measurement_method_id INTEGER REFERENCES measurement_method(id),
  bag_limit             INTEGER,
  bag_limit_unit        TEXT CHECK (bag_limit_unit IN ('count','kg')),
  bag_limit_period      TEXT CHECK (bag_limit_period IN ('day','trip','season')),
  vessel_limit          INTEGER,
  is_protected          INTEGER NOT NULL DEFAULT 0,
  licence_type_id       INTEGER REFERENCES licence_type(id),
  notes_key             TEXT,
  citation_id           INTEGER NOT NULL REFERENCES citation(id),
  valid_from            TEXT NOT NULL,
  valid_to              TEXT,                          -- expiry does NOT delete; see §7.3
  specificity           INTEGER NOT NULL DEFAULT 0,
  CHECK (min_size_mm IS NULL OR max_size_mm IS NULL OR max_size_mm >= min_size_mm)
);
CREATE INDEX idx_rule_lookup ON rule(jurisdiction_id, species_id, water_type, valid_from);
CREATE INDEX idx_rule_zone   ON rule(zone_id);

CREATE TABLE closed_season (
  id          INTEGER PRIMARY KEY,
  rule_id     INTEGER NOT NULL REFERENCES rule(id) ON DELETE CASCADE,
  recurrence  TEXT NOT NULL CHECK (recurrence IN ('annual','fixed')),
  start_month INTEGER, start_day INTEGER,
  end_month   INTEGER, end_day   INTEGER,
  start_date  TEXT,    end_date  TEXT,
  notes_key   TEXT,
  citation_id INTEGER REFERENCES citation(id)
);

CREATE TABLE licence_type (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  zone_id         INTEGER REFERENCES zone(id),
  water_type      TEXT NOT NULL CHECK (water_type IN ('salt','fresh','both')),
  code            TEXT NOT NULL,
  name_key        TEXT NOT NULL,
  description_key TEXT NOT NULL,
  citation_id     INTEGER NOT NULL REFERENCES citation(id)
);

CREATE TABLE gear_rule (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  zone_id         INTEGER REFERENCES zone(id),
  species_id      INTEGER REFERENCES species(id),   -- NULL = all species
  gear_code       TEXT NOT NULL,
  gear_name_key   TEXT NOT NULL,                    -- localised gear name
  is_allowed      INTEGER NOT NULL,
  constraint_key  TEXT,                             -- 'mesh ≥ 50 mm'
  citation_id     INTEGER NOT NULL REFERENCES citation(id)
);

CREATE TABLE penalty (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  offence_key     TEXT NOT NULL,
  occurrence      INTEGER NOT NULL DEFAULT 1,
  amount_min      INTEGER, amount_max INTEGER,
  currency        TEXT,
  secondary_key   TEXT,
  citation_id     INTEGER NOT NULL REFERENCES citation(id)
);

CREATE TABLE lookalike (
  id             INTEGER PRIMARY KEY,
  species_id     INTEGER NOT NULL REFERENCES species(id) ON DELETE CASCADE,
  confused_with  INTEGER NOT NULL REFERENCES species(id),
  difference_key TEXT NOT NULL,
  UNIQUE (species_id, confused_with)
);

CREATE TABLE glossary_term (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER REFERENCES jurisdiction(id),   -- NULL = global
  term_key        TEXT NOT NULL,
  definition_key  TEXT NOT NULL,
  sort_order      INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE content_change (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  from_version    TEXT NOT NULL,
  to_version      TEXT NOT NULL,
  summary_key     TEXT NOT NULL,
  detail_key      TEXT,
  changed_on      TEXT NOT NULL
);

-- Dichotomous key. A leaf is a node with no question and >=1 candidate species.
CREATE TABLE key_node (
  id             INTEGER PRIMARY KEY,
  taxon_group    TEXT NOT NULL,
  parent_node_id INTEGER REFERENCES key_node(id),
  question_key   TEXT                              -- NULL on a leaf
);
CREATE TABLE key_leaf_species (
  node_id    INTEGER NOT NULL REFERENCES key_node(id) ON DELETE CASCADE,
  species_id INTEGER NOT NULL REFERENCES species(id),
  rank       INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (node_id, species_id)
) WITHOUT ROWID;
CREATE TABLE key_option (
  id           INTEGER PRIMARY KEY,
  node_id      INTEGER NOT NULL REFERENCES key_node(id) ON DELETE CASCADE,
  option_index INTEGER NOT NULL,
  label_key    TEXT NOT NULL,
  figure_asset TEXT,
  next_node_id INTEGER REFERENCES key_node(id),     -- NULL = dead end (S7 terminal state)
  UNIQUE (node_id, option_index)
);

-- Every piece of BUNDLED CONTENT text. UI chrome lives in ARB files. See §9.
CREATE TABLE content_string (
  key    TEXT NOT NULL,
  locale TEXT NOT NULL,
  value  TEXT NOT NULL,
  PRIMARY KEY (key, locale)
) WITHOUT ROWID;

-- Verbatim legal text. body_norm carries the same fold as species_name.search_norm,
-- because FTS5 unicode61 does NOT fold Arabic orthographic variants.
CREATE TABLE legal_text (
  id              INTEGER PRIMARY KEY,
  jurisdiction_id INTEGER NOT NULL REFERENCES jurisdiction(id),
  citation_id     INTEGER NOT NULL REFERENCES citation(id),
  locale          TEXT NOT NULL,
  article_ref     TEXT,
  body            TEXT NOT NULL,
  body_norm       TEXT NOT NULL,
  sort_order      INTEGER NOT NULL
);
CREATE VIRTUAL TABLE legal_text_fts USING fts5(
  body_norm, content='legal_text', content_rowid='id',
  tokenize='unicode61 remove_diacritics 2'
);

CREATE TABLE content_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);
-- 'schema_version','build_date','generator_commit'
''';

/// The schema version written into `content_meta`.
///
/// Bumped when §7.1 changes. E05's migration reads it to decide whether the
/// extracted asset is one this build of the app can open.
const String kSchemaVersion = '1';
