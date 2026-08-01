import 'package:meta/meta.dart';

/// One `*_key` column, and the row that referenced it.
///
/// Emitted by walking the **typed** rows rather than by scanning text for
/// `_key`. A column added to `SPEC.md` §7.1 later is then a compile-time change
/// — `ContentRow.keyColumns` is abstract, so a new model cannot forget it —
/// rather than a reference nobody checks and a blank line under the stamp.
@immutable
class KeyReference {
  /// A reference to [key] from [column] of a row at [path] line [line].
  const KeyReference({
    required this.key,
    required this.column,
    required this.path,
    required this.line,
  });

  /// The `content_string` key this row asked for.
  final String key;

  /// The `SPEC.md` §7.1 column it was written in, e.g. `name_key`.
  final String column;

  /// The corpus-relative file of the referencing row — never of the definition.
  ///
  /// The author fixes the reference or adds the key, and needs to see which row
  /// asked. Pointing at `strings.yaml` would name the file that is correct.
  final String path;

  /// The 1-based line of the referencing row.
  final int line;

  @override
  String toString() => '$column: $key ($path:$line)';
}
