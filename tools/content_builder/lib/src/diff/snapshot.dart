import 'dart:convert';

import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:meta/meta.dart';

/// The fields of each section that **ship**, and therefore that a change to is a
/// change the user can see.
///
/// Authoring metadata is deliberately absent: `sha256`, `min_size_mm_confirmed`,
/// `no_vernacular` reasons and `ambiguity_ack` are how the corpus is reviewed,
/// not what it says. A snapshot that included them would report a diff every
/// time a note was reworded, and a diff full of noise is a diff nobody reads.
const Map<String, List<String>> kSnapshotFields = <String, List<String>>{
  'rules': <String>[
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
  ],
  'closed_seasons': <String>[
    'rule_id',
    'recurrence',
    'start_month',
    'start_day',
    'end_month',
    'end_day',
    'start_date',
    'end_date',
    'wraps_year',
    'notes_key',
    'citation_id',
  ],
  'citations': <String>[
    'jurisdiction',
    'jurisdiction_id',
    'instrument_type_key',
    'instrument',
    'instrument_ref',
    'article',
    'article_ref',
    'published_on',
    // The footnote's date. §4.7 currency: when it moves, the user can see why.
    'retrieved_on',
    'source_url',
  ],
  'zones': <String>[
    'jurisdiction_id',
    'parent_zone_id',
    'code',
    'name_key',
    'water_type',
    'zone_kind',
  ],
  'licence_types': <String>['jurisdiction_id', 'zone_id', 'water_type', 'code', 'name_key'],
  'gear_rules': <String>[
    'jurisdiction_id',
    'zone_id',
    'species_id',
    'gear_code',
    'gear_name_key',
    'is_allowed',
    'constraint_key',
    'citation_id',
  ],
  'penalties': <String>[
    'jurisdiction_id',
    'offence_key',
    'occurrence',
    'amount_min',
    'amount_max',
    'currency',
    'citation_id',
  ],
  'legal_texts': <String>['jurisdiction_id', 'citation_id', 'locale', 'article_ref', 'body'],
  'plates': <String>['species_id', 'asset', 'origin', 'illustrator', 'illustrator_death_year'],
};

/// One jurisdiction's shipping rows, canonicalised for diffing.
///
/// Checked in as `content/<jurisdiction>/snapshot.json`. **Not** derived from a
/// git tag: a builder that shells out to `git` behaves differently in a shallow
/// CI clone, in a worktree, and on a machine with no tags fetched, and its
/// output would then depend on the checkout rather than on the input. And not
/// derived from the previously built `reference.db` either, which would make a
/// 10 MB binary a build input and put it in every review.
@immutable
class Snapshot {
  /// A snapshot of [jurisdiction] at [contentVersion].
  const Snapshot({required this.jurisdiction, required this.contentVersion, required this.rows});

  /// [source]'s rows for [jurisdiction], projected and sorted.
  factory Snapshot.of(ContentSource source, String jurisdiction) {
    final YamlRow? row = source
        .section('jurisdiction')
        .where((YamlRow r) => r.jurisdiction == jurisdiction)
        .firstOrNull;

    // Shared plates belong to the jurisdictions whose rules reach their species,
    // so a drop shows up where the species is actually shown rather than in
    // every changelog in the repository.
    final species = <String>{
      for (final YamlRow r in source.section('rules'))
        if (r.jurisdiction == jurisdiction && r.string('species_id') != null)
          r.string('species_id')!,
    };

    final projected = <String, Map<String, Object?>>{};
    for (final MapEntry<String, List<String>> section in kSnapshotFields.entries) {
      for (final YamlRow r in source.section(section.key)) {
        final bool mine = section.key == 'plates'
            ? species.contains(r.string('species_id'))
            : r.jurisdiction == jurisdiction;
        if (!mine) continue;
        projected['${section.key}/${r.id}'] = <String, Object?>{
          for (final String field in section.value)
            if (r.fields.containsKey(field)) field: r.fields[field],
        };
      }
    }

    return Snapshot(
      jurisdiction: jurisdiction,
      contentVersion: row?.string('content_version') ?? '',
      rows: _sorted(projected),
    );
  }

  /// Reads a snapshot from its committed JSON, or an empty one.
  factory Snapshot.fromJson(String jurisdiction, String json) {
    final Object? decoded = jsonDecode(json);
    if (decoded is! Map<String, Object?>) {
      return Snapshot(
        jurisdiction: jurisdiction,
        contentVersion: '',
        rows: const <String, Map<String, Object?>>{},
      );
    }
    return Snapshot(
      jurisdiction: jurisdiction,
      contentVersion: '${decoded['content_version'] ?? ''}',
      rows: <String, Map<String, Object?>>{
        for (final MapEntry<String, Object?> e
            in (decoded['rows'] as Map<String, Object?>? ?? const <String, Object?>{}).entries)
          e.key: Map<String, Object?>.from(e.value! as Map<String, Object?>),
      },
    );
  }

  /// An empty snapshot: nothing has been committed yet.
  factory Snapshot.empty(String jurisdiction) => Snapshot(
    jurisdiction: jurisdiction,
    contentVersion: '',
    rows: const <String, Map<String, Object?>>{},
  );

  /// The jurisdiction directory this covers, e.g. `es-ga`.
  final String jurisdiction;

  /// `jurisdiction.content_version` at the time it was taken.
  final String contentVersion;

  /// `<section>/<id>` to that row's shipping fields.
  final Map<String, Map<String, Object?>> rows;

  /// The committed form: two-space JSON with a trailing newline.
  ///
  /// Sorted at every level, so two runs over identical input are byte-identical
  /// and the committed file is not a diff on every build.
  String toJson() =>
      '${const JsonEncoder.withIndent('  ').convert(<String, Object?>{'jurisdiction': jurisdiction, 'content_version': contentVersion, 'rows': rows})}\n';

  static Map<String, Map<String, Object?>> _sorted(Map<String, Map<String, Object?>> rows) {
    final List<String> keys = rows.keys.toList()..sort();
    return <String, Map<String, Object?>>{
      for (final String key in keys)
        key: <String, Object?>{
          for (final String field in rows[key]!.keys.toList()..sort()) field: rows[key]![field],
        },
    };
  }
}
