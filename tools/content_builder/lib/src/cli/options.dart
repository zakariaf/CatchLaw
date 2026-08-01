import 'dart:io';

import 'package:args/args.dart';
import 'package:content_builder/src/cli/usage_failure.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:rule_engine/rule_engine.dart' show parseIsoDate;

/// The three flag names that exist only to be answered.
///
/// `catchlaw-content-pipeline` rule 2: every assertion is fatal and there is no
/// warning tier, so the flag that exists is the flag CI uses at 18:00 on a
/// Friday to unblock a release. Each is declared to `package:args` — hidden, so
/// nothing advertises it — and rejected by name with an explanation, because
/// somebody will eventually paste one from a stale note or from another project
/// and "Could not find an option named force" reads as a version skew.
///
/// Accepting them and ignoring them would be worse than either alternative.
const List<String> kRejectedFlags = <String>['force', 'skip-assertions', 'allow-missing-locale'];

/// A parsed `dart run content_builder:build` invocation.
@immutable
class ContentBuildOptions {
  /// The four required inputs, plus the changelog directory derived from [inDir].
  const ContentBuildOptions({
    required this.inDir,
    required this.outFile,
    required this.buildDate,
    required this.generatorCommit,
    required this.changelogDir,
    required this.assetsRoot,
  });

  /// The authored corpus, e.g. `content/`.
  final Directory inDir;

  /// Where the emitted database goes. Required, and with no default: the tool
  /// writes a binary asset, and a default output path is how a stray invocation
  /// overwrites `app/assets/db/reference.db` with a partial corpus.
  final File outFile;

  /// The date recorded in `content_meta.build_date`, and the year the plate
  /// licence test counts from.
  ///
  /// Required input rather than a reading of the clock. `DateTime.now()` in the
  /// emitter would make T10's byte-identical rebuild untestable, and a plate
  /// would silently re-clear on the day its term expired with no diff to show
  /// for it.
  final DateTime buildDate;

  /// The commit the corpus was built from, recorded in
  /// `content_meta.generator_commit` so a stale database can be traced.
  final String generatorCommit;

  /// Where A10 writes one changelog per jurisdiction. Derived from [inDir]
  /// rather than flagged, so the diff and the corpus it diffed cannot drift
  /// apart.
  final Directory changelogDir;

  /// The asset root A5 resolves `species.silhouette_asset` against.
  ///
  /// Derived from [outFile]'s grandparent — `app/assets/db/reference.db` gives
  /// `app/assets` — rather than flagged. A separate `--assets` option would let
  /// a build check silhouettes in one tree and ship a database that names
  /// another, and the failure would be a species with no picture on a phone.
  final Directory assetsRoot;

  /// The name of the changelog directory inside the corpus.
  static const String changelogDirName = 'CHANGELOG';

  /// Parses [args], throwing [UsageFailure] on anything the tool will not do.
  static ContentBuildOptions parse(List<String> args) {
    final ArgResults results;
    try {
      results = _parser.parse(args);
    } on FormatException catch (e) {
      throw UsageFailure('${e.message}\n\n$usage');
    }

    for (final String flag in kRejectedFlags) {
      if (results.wasParsed(flag)) {
        throw UsageFailure(
          '--$flag does not exist and will not be added; every assertion is fatal',
        );
      }
    }

    for (final String option in _required) {
      if (results.option(option) == null) {
        throw UsageFailure('--$option is required\n\n$usage');
      }
    }

    final String rawDate = results.option('build-date')!;
    final DateTime buildDate;
    try {
      buildDate = parseIsoDate(rawDate);
    } on FormatException {
      throw UsageFailure("--build-date '$rawDate' is not an ISO-8601 date (YYYY-MM-DD)");
    }

    final String inPath = results.option('in')!;
    return ContentBuildOptions(
      inDir: Directory(inPath),
      outFile: File(results.option('out')!),
      buildDate: buildDate,
      generatorCommit: results.option('generator-commit')!,
      changelogDir: Directory(p.join(inPath, changelogDirName)),
      assetsRoot: Directory(p.dirname(p.dirname(results.option('out')!))),
    );
  }

  /// The help text, listing the four required options and nothing that weakens
  /// an assertion.
  static String get usage =>
      'usage: dart run content_builder:build \\\n'
      '  --in <content-dir> --out <reference.db> \\\n'
      '  --build-date <YYYY-MM-DD> --generator-commit <sha>\n\n'
      '${_parser.usage}\n\n'
      'exit codes: 0 built · 1 assertion failures, nothing written · 2 usage error';

  static const List<String> _required = <String>['in', 'out', 'build-date', 'generator-commit'];

  static final ArgParser _parser = _buildParser();

  static ArgParser _buildParser() {
    final parser = ArgParser()
      ..addOption('in', help: 'The authored corpus directory.', valueHelp: 'content-dir')
      ..addOption('out', help: 'The reference.db to write.', valueHelp: 'reference.db')
      ..addOption(
        'build-date',
        help: 'The build date recorded in content_meta. Authored, never read from the clock.',
        valueHelp: 'YYYY-MM-DD',
      )
      ..addOption(
        'generator-commit',
        help: 'The commit this corpus was built from.',
        valueHelp: 'sha',
      );
    for (final String flag in kRejectedFlags) {
      // Declared so the tool can answer by name, hidden so `usage` advertises
      // none of them.
      parser.addFlag(flag, hide: true, negatable: false);
    }
    return parser;
  }
}
