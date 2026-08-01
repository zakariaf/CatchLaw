import 'dart:io';

import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/authoring_format.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/content_row.dart';
import 'package:content_builder/src/model/key_reference.dart';
import 'package:content_builder/src/model/rows.dart';
import 'package:content_builder/src/model/text.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// The whole authored corpus: `shared/` plus one directory per jurisdiction.
///
/// One directory per jurisdiction is what lets E22 add a sibling and touch
/// nothing that already ships.
@immutable
class ContentSource {
  /// A corpus of already-parsed [sources], carrying any load-time [failures].
  const ContentSource({required this.sources, required this.failures});

  /// Reads [dir] as a corpus.
  ///
  /// A missing directory is a failure and not an empty corpus. An empty corpus
  /// passes every assertion there is, and the build would emit a database with
  /// no rules in it and exit 0.
  factory ContentSource.load(Directory dir) {
    if (!dir.existsSync()) {
      return ContentSource(
        sources: const <YamlSource>[],
        failures: <Failure>[Failure(kLoadFailureId, dir.path, 0, 'corpus directory not found')],
      );
    }

    final sources = <YamlSource>[];
    final failures = <Failure>[];
    final List<FileSystemEntity> entries = dir.listSync()..sort((a, b) => a.path.compareTo(b.path));

    // A YAML file dropped at the root belongs to no jurisdiction and to no
    // `shared/`, so nothing reads it — the misspelt-file-name defect one level
    // further up. README.md and anything else that is not YAML is documentation.
    for (final File file in entries.whereType<File>()) {
      final String fileName = p.basename(file.path);
      if (p.extension(fileName) == '.yaml' || p.extension(fileName) == '.yml') {
        failures.add(
          Failure(
            kLoadFailureId,
            fileName,
            0,
            "'$fileName' sits at the corpus root; it belongs in $kSharedDir/ or in a jurisdiction directory",
          ),
        );
      }
    }

    var jurisdictions = 0;
    for (final Directory child in entries.whereType<Directory>()) {
      final String name = p.basename(child.path);
      if (name == kChangelogDir) continue;
      final shared = name == kSharedDir;
      if (!shared) jurisdictions++;

      final List<File> files = child.listSync().whereType<File>().toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));

      for (final file in files) {
        final String fileName = p.basename(file.path);
        final String displayPath = p.join(name, fileName);
        if (kNonYamlFiles.contains(fileName)) continue;

        final bool known = shared ? isSharedFile(fileName) : isJurisdictionFile(fileName);
        if (!known) {
          failures.add(
            Failure(
              kLoadFailureId,
              displayPath,
              0,
              "'$fileName' is not part of the authoring format for ${shared ? '$kSharedDir/' : 'a jurisdiction'}",
            ),
          );
          continue;
        }

        final source = YamlSource.fromFile(
          file,
          displayPath: displayPath,
          jurisdiction: shared ? null : name,
        );
        sources.add(source);
        failures.addAll(source.failures);
      }
    }

    if (jurisdictions == 0) {
      // The silent green this tool exists to avoid. A corpus with no rules in it
      // satisfies all ten assertions, and the build would write a database with
      // no rules in it and exit 0.
      failures.add(
        Failure(kLoadFailureId, dir.path, 0, 'the corpus holds no jurisdiction directory'),
      );
    }

    return ContentSource(sources: sources, failures: sortedFailures(failures));
  }

  /// Every parsed file, in path order.
  final List<YamlSource> sources;

  /// Defects found while reading the corpus, before any assertion ran, sorted by
  /// path then line.
  final List<Failure> failures;

  /// The assertions this build runs, in the order they were registered.
  ///
  /// The registry E04/T02 through T09 plug into. It starts empty on purpose: a
  /// pre-populated list is how a missing task looks exactly like a finished one.
  List<Assertion> get assertions => kAssertions;

  /// Every row of [name], across every file that declares it.
  Iterable<YamlRow> section(String name) => sources.expand((YamlSource s) => s.section(name));

  /// Every row of the corpus, in file then document order.
  Iterable<YamlRow> get rows => sources.expand((YamlSource s) => s.rows);

  /// Every row, typed against the `SPEC.md` §7.1 table it becomes.
  ///
  /// A section with no builder is skipped here and reported by the model test
  /// that asserts the two registries agree — silently dropping a whole file's
  /// rows is the defect that test exists to catch.
  Iterable<ContentRow> get typedRows sync* {
    for (final YamlRow row in rows) {
      final RowBuilder? build = kRowBuilders[row.section];
      if (build != null) yield build(row);
    }
  }

  /// Every `*_key` reference in the corpus, with the row that made it.
  Iterable<KeyReference> get keyReferences => typedRows.expand((ContentRow r) => r.keyReferences);

  /// Every authored `content_string` block.
  Iterable<ContentStringRow> get contentStrings => typedRows.whereType<ContentStringRow>();
}
