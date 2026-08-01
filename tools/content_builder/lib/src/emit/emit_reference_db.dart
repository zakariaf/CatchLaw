import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/cli/options.dart';
import 'package:content_builder/src/load/content_source.dart';

/// Writes [source] to `options.outFile` as `reference.db`, or reports why not.
///
/// The real emitter lands in E04/T10 with the `SPEC.md` §7.1 schema, the FTS5
/// index and the byte-identical rebuild. Until then this is the phase's shape
/// and its contract: it is reached only with an empty failure list, and it
/// answers with failures rather than throwing, so a defect here prints like
/// every other one.
List<Failure> emitReferenceDb(ContentSource source, ContentBuildOptions options) => <Failure>[
  Failure(
    kLoadFailureId,
    options.outFile.path,
    0,
    'the SQLite emitter lands in E04/T10; ${source.rows.length} rows loaded and nothing written',
  ),
];
