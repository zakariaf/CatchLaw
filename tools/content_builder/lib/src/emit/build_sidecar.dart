import 'dart:convert';
import 'dart:io';

import 'package:content_builder/src/cli/options.dart';
import 'package:content_builder/src/emit/schema.dart';
import 'package:crypto/crypto.dart';

/// Writes `reference.db.gz` and `reference.build.json` beside the emitted
/// database.
///
/// **The sidecar carries the sha256 of the UNCOMPRESSED file.**
/// `catchlaw-reference-database` rule 6 verifies the digest *after*
/// decompression and drives the determinate progress bar from the uncompressed
/// byte count. A digest of the `.gz` would be verified before the bytes that
/// matter existed.
///
/// It sits at `app/assets/db/reference.build.json`, beside the file it
/// describes. `SPEC.md` §7.4 calls it `assets/content_build.json` and
/// `catchlaw-reference-database` rule 5 calls it
/// `assets/db/reference.build.json`; D-6 fixes the `.gz` at
/// `app/assets/db/reference.db.gz`, so this is a consequence of D-6 rather than
/// a new decision.
///
/// **This does not emit the generated Dart constant.** D-6 gives extraction to
/// E05/T01–T03, and `kReferenceBuildId`, `kReferenceBytes` and
/// `kReferenceSha256` belong there — E05 owns the extraction contract and
/// generates the constant from this sidecar. Writing Dart into `app/lib/` from
/// here would put two epics in one file.
void writeBuildSidecar(ContentBuildOptions options) {
  final File db = options.outFile;
  final List<int> bytes = db.readAsBytesSync();
  final Digest digest = sha256.convert(bytes);

  // The shipping artefact (D-6 item 1). gzip at maximum, and the level is fixed
  // so two builds of one corpus compress identically.
  gzipFile(options).writeAsBytesSync(GZipCodec(level: 9).encode(bytes));

  const encoder = JsonEncoder.withIndent('  ');
  sidecarFile(options).writeAsStringSync(
    '${encoder.convert(<String, Object?>{'build_id': options.generatorCommit, 'build_date': _iso(options.buildDate), 'schema_version': kSchemaVersion, 'bytes': bytes.length, 'sha256': '$digest'})}\n',
  );
}

/// `app/assets/db/reference.db.gz` — the file that ships.
File gzipFile(ContentBuildOptions options) => File('${options.outFile.path}.gz');

/// `app/assets/db/reference.build.json`.
File sidecarFile(ContentBuildOptions options) =>
    File(options.outFile.path.replaceAll(RegExp(r'\.db$'), '.build.json'));

/// The sha256 of [file], as the sidecar records it.
String sha256OfFile(File file) => '${sha256.convert(file.readAsBytesSync())}';

String _iso(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
