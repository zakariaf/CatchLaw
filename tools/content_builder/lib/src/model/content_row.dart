import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/key_reference.dart';
import 'package:meta/meta.dart';

/// One authored row, typed against the `SPEC.md` §7.1 table it becomes.
///
/// Field names mirror the SQL columns exactly. A model that renames a column to
/// something tidier costs the next reader a diff between the schema, the
/// authoring format and the emitter, and one of the three will be wrong.
///
/// Foreign keys are the **authored** string ids — `venerupis-corrugata`,
/// `es-ga-rias-baixas` — not the `INTEGER PRIMARY KEY` values. The emitter
/// (E04/T10) assigns those, because an integer authored by hand is a number two
/// people have to keep in step across eleven files.
///
/// These types do not validate. A1 (E04/T02) does, at load, where the message
/// can carry the file and the line; a constructor that threw would report the
/// first defect and hide the rest.
@immutable
abstract class ContentRow {
  /// A row read from [path] at [line].
  const ContentRow({required this.path, required this.line, required this.id});

  /// The corpus-relative file this row was authored in.
  final String path;

  /// The 1-based line the row opens on.
  final int line;

  /// The authored id, stable forever: the changelog diff references it.
  final String id;

  /// Every `*_key` column of this row, by column name, with its authored value.
  ///
  /// Abstract on purpose. A2 walks these rather than scanning text for `_key`,
  /// so a column added to `SPEC.md` §7.1 later is a compile error in this file's
  /// subclasses rather than a reference nobody checks. A `null` value means the
  /// nullable column was not authored, and is skipped rather than reported.
  Map<String, String?> get keyColumns;

  /// This row's key references, ready for A2.
  Iterable<KeyReference> get keyReferences => <KeyReference>[
    for (final MapEntry<String, String?> column in keyColumns.entries)
      if (column.value != null)
        KeyReference(key: column.value!, column: column.key, path: path, line: line),
  ];
}

/// Builds one typed row from one parsed [YamlRow].
typedef RowBuilder = ContentRow Function(YamlRow row);
