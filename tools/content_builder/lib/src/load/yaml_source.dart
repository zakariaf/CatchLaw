import 'dart:io';

import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/authoring_format.dart';
import 'package:meta/meta.dart';
import 'package:yaml/yaml.dart';

/// One authored row, with the file and 1-based line it was written on.
///
/// The location is the point. `package:yaml`'s [loadYamlNode] returns nodes
/// carrying a [SourceSpan]; this keeps `span.start.line + 1` and throws the span
/// away, so nothing downstream can accidentally depend on the parser's own
/// types.
@immutable
class YamlRow {
  /// A row of [section], read from [path] at [line].
  const YamlRow({
    required this.path,
    required this.line,
    required this.section,
    required this.fields,
    this.jurisdiction,
  });

  /// The corpus-relative path this row was read from.
  final String path;

  /// The 1-based line the row opens on — the line carrying its `- id:`.
  final int line;

  /// The top-level section, e.g. `rules`. Mirrors the `SPEC.md` §7.1 table.
  final String section;

  /// The directory this row's file sat in, e.g. `es-ga`; `null` for `shared/`.
  ///
  /// `shared/` belongs to every jurisdiction, so tagging its rows with one
  /// directory's name would filter them out of every other one's diff.
  final String? jurisdiction;

  /// The authored fields, keyed by their `SPEC.md` §7.1 column name.
  final Map<String, Object?> fields;

  /// The row's `id`, or the empty string when it has none.
  String get id => string('id') ?? '';

  /// Whether [key] was authored with a value. An explicit `null` reads as absent.
  bool has(String key) => fields[key] != null;

  /// [key] as a string, or `null` when absent or of another type.
  String? string(String key) => switch (fields[key]) {
    final String value => value,
    _ => null,
  };

  /// [key] as an integer, or `null` when absent or of another type.
  int? integer(String key) => switch (fields[key]) {
    final int value => value,
    _ => null,
  };

  /// [key] as a boolean, or `null` when absent or of another type.
  bool? boolean(String key) => switch (fields[key]) {
    final bool value => value,
    _ => null,
  };

  /// [key] as a list, or `null` when absent or of another type.
  List<Object?>? list(String key) => switch (fields[key]) {
    final List<Object?> value => value,
    _ => null,
  };

  @override
  String toString() => '$section row $id ($path:$line)';
}

/// One authored YAML file, parsed into rows that remember where they came from.
@immutable
class YamlSource {
  const YamlSource._({
    required this.path,
    required this.rows,
    required this.failures,
    this.jurisdiction,
  });

  /// Parses [file], rendering failures against [displayPath].
  ///
  /// A malformed document produces a failure at the offending line rather than
  /// an exception: a `YamlException` reaching the top level prints a stack trace
  /// naming the loader, which tells the author nothing about their document.
  factory YamlSource.fromFile(File file, {required String displayPath, String? jurisdiction}) =>
      YamlSource.fromString(
        file.readAsStringSync(),
        displayPath: displayPath,
        jurisdiction: jurisdiction,
      );

  /// Parses [source], rendering failures against [displayPath].
  ///
  /// Taking a `String` is not a convenience. `check_content_pipeline.sh` checks
  /// 2, 3 and 5 scan every `*.yaml` under the target with no
  /// `content-pipeline-ok` escape hatch, so the deliberately broken fixtures
  /// every assertion needs must live as inline Dart strings.
  factory YamlSource.fromString(
    String source, {
    required String displayPath,
    String? jurisdiction,
  }) {
    final rows = <YamlRow>[];
    final failures = <Failure>[];

    final YamlNode document;
    try {
      document = loadYamlNode(source, sourceUrl: Uri.file(displayPath));
    } on YamlException catch (e) {
      failures.add(
        Failure(kLoadFailureId, displayPath, (e.span?.start.line ?? 0) + 1, _clean(e.message)),
      );
      return YamlSource._(
        path: displayPath,
        rows: rows,
        failures: failures,
        jurisdiction: jurisdiction,
      );
    }

    if (document is! YamlMap) {
      failures.add(
        Failure(
          kLoadFailureId,
          displayPath,
          document.span.start.line + 1,
          'a content file is a map of section name to rows',
        ),
      );
      return YamlSource._(
        path: displayPath,
        rows: rows,
        failures: failures,
        jurisdiction: jurisdiction,
      );
    }

    final Set<String> allowed = sectionsOf(displayPath);
    final seenIds = <String, int>{};

    for (final MapEntry<Object?, Object?> entry in document.nodes.entries) {
      final key = entry.key! as YamlScalar;
      final section = '${key.value}';
      final int keyLine = key.span.start.line + 1;

      if (allowed.isNotEmpty && !allowed.contains(section)) {
        failures.add(
          Failure(
            kLoadFailureId,
            displayPath,
            keyLine,
            "unknown section '$section'; ${_expected(allowed)}",
          ),
        );
        continue;
      }

      final value = entry.value! as YamlNode;
      if (value is! YamlList) {
        failures.add(
          Failure(kLoadFailureId, displayPath, keyLine, "section '$section' holds no rows"),
        );
        continue;
      }

      for (final YamlNode node in value.nodes) {
        final int line = node.span.start.line + 1;
        if (node is! YamlMap) {
          failures.add(Failure(kLoadFailureId, displayPath, line, 'a row is a mapping of fields'));
          continue;
        }

        final fields = <String, Object?>{
          for (final MapEntry<Object?, Object?> f in node.entries) '${f.key}': _plain(f.value),
        };
        final Object? id = fields['id'];
        if (id is! String || id.isEmpty) {
          failures.add(
            Failure(kLoadFailureId, displayPath, line, "a $section row carries no 'id'"),
          );
          continue;
        }

        final int? firstLine = seenIds[id];
        if (firstLine != null) {
          failures.add(
            Failure(
              kLoadFailureId,
              displayPath,
              line,
              "duplicate id '$id'; already defined on line $firstLine",
            ),
          );
          continue;
        }
        seenIds[id] = line;

        rows.add(
          YamlRow(
            path: displayPath,
            line: line,
            section: section,
            fields: fields,
            jurisdiction: jurisdiction,
          ),
        );
      }
    }

    return YamlSource._(
      path: displayPath,
      rows: rows,
      failures: sortedFailures(failures),
      jurisdiction: jurisdiction,
    );
  }

  /// The corpus-relative path this source renders in failure lines.
  final String path;

  /// The directory this file sat in, e.g. `es-ga`; `null` for `shared/`.
  final String? jurisdiction;

  /// Every row in the file, in document order.
  final List<YamlRow> rows;

  /// Defects found while reading, before any assertion ran.
  final List<Failure> failures;

  /// The rows of [section], in document order.
  Iterable<YamlRow> section(String section) => rows.where((YamlRow r) => r.section == section);

  static String _expected(Set<String> allowed) =>
      'expected ${allowed.map((String s) => "'$s'").join(' or ')}';

  /// The parser's message on one line, with no `package:yaml` frame in it.
  static String _clean(String message) => message.replaceAll('\n', ' ').trim();

  /// `YamlMap` and `YamlList` are `Map` and `List`, but carry spans that would
  /// keep the whole document alive behind every row. Copy the values out.
  static Object? _plain(Object? value) => switch (value) {
    final YamlMap map => <String, Object?>{
      for (final MapEntry<Object?, Object?> e in map.entries) '${e.key}': _plain(e.value),
    },
    final YamlList list => <Object?>[for (final Object? e in list) _plain(e)],
    _ => value,
  };
}
