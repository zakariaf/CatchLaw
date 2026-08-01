import 'package:content_builder/src/assert/a02_locale_coverage.dart';
import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/cli/options.dart';
import 'package:content_builder/src/cli/usage_failure.dart';
import 'package:content_builder/src/emit/emit_reference_db.dart';
import 'package:content_builder/src/load/attributions.dart';
import 'package:content_builder/src/load/content_source.dart';

/// The build, in the four phases `catchlaw-content-pipeline` fixes: load,
/// assert, emit, changelog.
///
/// It never reaches emit with a non-empty failure list. That is the whole
/// contract of the tool, and it is proved here rather than asserted in prose,
/// because every assertion E04 adds depends on it.
///
/// Returns the process exit code: **0** built, **1** failures and nothing
/// written, **2** the invocation itself was wrong.
///
/// [out] and [err] are injected so a test reads the output instead of the
/// process, and so a failure list can be asserted line by line.
int run(List<String> args, {required StringSink out, required StringSink err}) {
  final ContentBuildOptions options;
  try {
    options = ContentBuildOptions.parse(args);
  } on UsageFailure catch (e) {
    err.writeln(e);
    return e.exitCode;
  }

  final source = ContentSource.load(options.inDir);
  final List<Failure> failures = sortedFailures(<Failure>[
    ...source.failures,
    // The assertions read a corpus the loader could parse. Running them over a
    // half-read one reports defects in rows that were never there.
    if (source.failures.isEmpty) ...runAllAssertions(source),
  ]);

  if (failures.isNotEmpty) {
    return _report(failures, options, err);
  }

  // The ledger describes the CORPUS, not the database, and a corpus that
  // passes every assertion is a corpus whose ledger is true. Written before
  // emit for that reason and because SPEC.md §8 requires it to exist for E18 to
  // assemble; it is regenerated on every clean build, so it cannot drift from
  // the data it describes.
  writePlateLedger(source, options);

  final List<Failure> emitted = emitReferenceDb(source, options);
  if (emitted.isNotEmpty) {
    return _report(emitted, options, err);
  }

  final List<String> orphans = unreferencedKeys(source);
  if (orphans.isNotEmpty) {
    // Counted, never failed. E22 authors shared glossary and family strings
    // ahead of the rows that use them, and failing here would force a rule and
    // its strings into one commit.
    out.writeln('content_builder: ${orphans.length} content_string keys are unreferenced');
  }
  out.writeln('content_builder: OK — ${source.rows.length} rows');
  return 0;
}

int _report(List<Failure> failures, ContentBuildOptions options, StringSink err) {
  for (final f in failures) {
    err.writeln(f.render());
  }
  err.writeln('content_builder: ${failures.length} failures; ${options.outFile.path} not written');
  return 1;
}
