import 'dart:io';

import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/diff/content_diff.dart';
import 'package:content_builder/src/diff/snapshot.dart';
import 'package:content_builder/src/load/authoring_format.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/text.dart';
import 'package:path/path.dart' as p;

/// A10 — a jurisdiction whose rows changed has a changelog that says so.
///
/// **A machine cannot write a `summary_key`, so it does not try.**
/// `content_change.summary_key` is a `*_key` and A2 requires it in all six
/// locales; a generated English sentence would fail A2 the moment it was
/// generated, and generating six of them is machine translation of a legal note
/// — what `SPEC.md` §9.2 forbids for tier-2 content. So the mechanical diff
/// **detects** the change and the author **writes** it, in `changes.yaml`.
///
/// That inversion is the whole point. The failure it prevents is recorded in
/// `build-assertions.md` as "a rule edited without regenerating": a minimum size
/// that changed with nothing in S23 to say so. §4.7 promises the user can see
/// currency, and an undocumented change breaks that promise silently.
final class ChangelogAssertion implements Assertion {
  /// The A10 assertion.
  ///
  /// In [check] mode the build computes the same artefacts and writes nothing,
  /// failing when the committed `snapshot.json` or changelog differs. Without
  /// it A10 could never fire: a build that regenerates both every time makes
  /// the committed files correct by construction.
  const ChangelogAssertion({this.check = false});

  /// Whether to verify the committed generated files rather than trust them.
  final bool check;

  @override
  String get id => 'A10';

  @override
  Iterable<Failure> run(ContentSource source) sync* {
    for (final String jurisdiction in jurisdictionsOf(source)) {
      final Snapshot committed = readSnapshot(source, jurisdiction);
      final current = Snapshot.of(source, jurisdiction);
      final diff = ContentDiff.between(committed, current);
      if (diff.isEmpty) continue;

      // A wholesale replacement that reports the version it replaced makes
      // catch.content_version — the column §7.1 denormalises precisely so
      // history survives a content update — point at two different rulesets.
      if (committed.contentVersion == current.contentVersion) {
        yield Failure(
          _id,
          p.join(jurisdiction, 'jurisdiction.yaml'),
          0,
          '$jurisdiction changed but content_version is still '
          "'${current.contentVersion}'",
        );
      }

      final covered = <String>{
        for (final ContentChangeRow row in source.typedRows.whereType<ContentChangeRow>())
          if (row.jurisdictionId != null) ...row.ruleIds,
      };
      for (final String id in diff.touchedIds.toList()..sort()) {
        if (covered.contains(id)) continue;
        yield Failure(
          _id,
          p.join(jurisdiction, 'changes.yaml'),
          0,
          "'$id' changed and no authored entry in changes.yaml covers it",
        );
      }

      if (check) {
        yield* _stale(source, jurisdiction, current, diff);
      }
    }
  }

  Iterable<Failure> _stale(
    ContentSource source,
    String jurisdiction,
    Snapshot current,
    ContentDiff diff,
  ) sync* {
    final Directory? root = source.rootDir;
    if (root == null) return;

    final File snapshot = snapshotFile(root, jurisdiction);
    if (!snapshot.existsSync() || snapshot.readAsStringSync() != current.toJson()) {
      yield Failure(
        _id,
        p.join(jurisdiction, kSnapshotFile),
        0,
        'is stale; run the build without --check to regenerate it',
      );
    }

    final File markdown = changelogFile(root, jurisdiction);
    if (!markdown.existsSync() || markdown.readAsStringSync() != diff.renderMarkdown()) {
      yield Failure(
        _id,
        p.join(kChangelogDir, '$jurisdiction.md'),
        0,
        'is stale; run the build without --check to regenerate it',
      );
    }
  }

  static const String _id = 'A10';
}

/// The name of the committed previous-state file inside a jurisdiction.
const String kSnapshotFile = 'snapshot.json';

/// Every jurisdiction directory the corpus holds, sorted.
List<String> jurisdictionsOf(ContentSource source) => <String>{
  for (final YamlSource s in source.sources)
    if (s.jurisdiction != null) s.jurisdiction!,
}.toList()..sort();

/// `content/<jurisdiction>/snapshot.json`.
File snapshotFile(Directory root, String jurisdiction) =>
    File(p.join(root.path, jurisdiction, kSnapshotFile));

/// `content/CHANGELOG/<jurisdiction>.md`.
///
/// One file per jurisdiction, because that is how the work is divided:
/// `SPEC.md` §15 step 19 has content authoring running in parallel from step 3
/// onward, and two authors on two jurisdictions must not collide in one file.
File changelogFile(Directory root, String jurisdiction) =>
    File(p.join(root.path, kChangelogDir, '$jurisdiction.md'));

/// The committed snapshot for [jurisdiction], or an empty one.
Snapshot readSnapshot(ContentSource source, String jurisdiction) {
  final Directory? root = source.rootDir;
  if (root == null) return Snapshot.empty(jurisdiction);
  final File file = snapshotFile(root, jurisdiction);
  if (!file.existsSync()) return Snapshot.empty(jurisdiction);
  return Snapshot.fromJson(jurisdiction, file.readAsStringSync());
}

/// Regenerates the committed snapshot and changelog for every jurisdiction.
///
/// Called only on a build with no failures: a corpus that passes every assertion
/// is a corpus whose changelog is true.
void writeChangelogs(ContentSource source) {
  final Directory? root = source.rootDir;
  if (root == null) return;
  for (final String jurisdiction in jurisdictionsOf(source)) {
    final current = Snapshot.of(source, jurisdiction);
    final diff = ContentDiff.between(readSnapshot(source, jurisdiction), current);

    changelogFile(root, jurisdiction)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(diff.renderMarkdown());
    // The snapshot last: it is the state the next build diffs against, so
    // writing it before the changelog would leave the two describing different
    // corpora if the process died between them.
    snapshotFile(root, jurisdiction).writeAsStringSync(current.toJson());
  }
}
