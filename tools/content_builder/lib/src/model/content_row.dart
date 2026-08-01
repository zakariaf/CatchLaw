import 'package:content_builder/src/load/yaml_source.dart';
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
}

/// Builds one typed row from one parsed [YamlRow].
typedef RowBuilder = ContentRow Function(YamlRow row);
