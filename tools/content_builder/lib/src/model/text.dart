import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/content_row.dart';

/// A `content_string` row: one bundled-content string in one locale.
///
/// Tier two of `SPEC.md` §9.2. Tier one is ARB and covers UI chrome only. A
/// `legal_text.*` id may never be keyed here — that would be an unofficial
/// translation of a penal instrument presented as the instrument.
class ContentStringRow extends ContentRow {
  /// A string read from [path] at [line].
  const ContentStringRow({
    required super.path,
    required super.line,
    required super.id,
    required this.key,
    required this.values,
  });

  /// Reads a string from [row].
  ///
  /// One authored row carries every locale, so a key that is missing one is
  /// visible in the diff rather than only in A2's output.
  factory ContentStringRow.fromRow(YamlRow row) => ContentStringRow(
    path: row.path,
    line: row.line,
    id: row.id,
    key: row.string('key') ?? row.id,
    values: <String, String>{
      for (final MapEntry<String, Object?> e in row.fields.entries)
        if (e.key != 'id' && e.key != 'key' && e.value is String) e.key: e.value! as String,
    },
  );

  /// The `*_key` every reference resolves through.
  final String key;

  /// Locale to value. A2 fails the build unless all six of D-3's locales are
  /// here: a missing key renders a blank line under the stamp, and blank is not
  /// a verdict.
  final Map<String, String> values;
}

/// A `glossary_term` row.
class GlossaryTermRow extends ContentRow {
  /// A term read from [path] at [line].
  const GlossaryTermRow({
    required super.path,
    required super.line,
    required super.id,
    required this.termKey,
    required this.definitionKey,
    this.jurisdictionId,
    this.sortOrder = 0,
  });

  /// Reads a term from [row].
  factory GlossaryTermRow.fromRow(YamlRow row) => GlossaryTermRow(
    path: row.path,
    line: row.line,
    id: row.id,
    jurisdictionId: row.string('jurisdiction_id'),
    termKey: row.string('term_key'),
    definitionKey: row.string('definition_key'),
    sortOrder: row.integer('sort_order') ?? 0,
  );

  /// `null` means the term is global.
  final String? jurisdictionId;

  /// Localised term.
  final String? termKey;

  /// Localised definition.
  final String? definitionKey;

  /// Display order within S22.
  final int sortOrder;
}

/// A `content_change` row: one line of a jurisdiction's changelog.
///
/// Authored rows record what a human wants S23 to say. E04/T09 emits the
/// per-jurisdiction diff alongside them, and A10 fails the build when a
/// jurisdiction changed and its changelog did not.
class ContentChangeRow extends ContentRow {
  /// A change read from [path] at [line].
  const ContentChangeRow({
    required super.path,
    required super.line,
    required super.id,
    required this.jurisdictionId,
    required this.fromVersion,
    required this.toVersion,
    required this.summaryKey,
    required this.changedOn,
    this.detailKey,
  });

  /// Reads a change from [row].
  factory ContentChangeRow.fromRow(YamlRow row) => ContentChangeRow(
    path: row.path,
    line: row.line,
    id: row.id,
    jurisdictionId: row.string('jurisdiction_id'),
    fromVersion: row.string('from_version'),
    toVersion: row.string('to_version'),
    summaryKey: row.string('summary_key'),
    detailKey: row.string('detail_key'),
    changedOn: row.string('changed_on'),
  );

  /// The authority whose pack changed.
  final String? jurisdictionId;

  /// The pack version this change moved away from.
  final String? fromVersion;

  /// The pack version it moved to.
  final String? toVersion;

  /// Localised one-line summary.
  final String? summaryKey;

  /// Localised detail.
  final String? detailKey;

  /// When the change was made.
  final String? changedOn;
}
