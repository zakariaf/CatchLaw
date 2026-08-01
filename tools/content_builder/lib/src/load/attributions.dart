import 'dart:io';

import 'package:content_builder/src/assert/a06_plate_licence.dart';
import 'package:content_builder/src/cli/options.dart';
import 'package:content_builder/src/load/authoring_format.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:path/path.dart' as p;

/// The generated plate ledger, inside the corpus.
///
/// `content/ATTRIBUTIONS/plates.md`. Generated rather than hand-kept because
/// `SPEC.md` §8 requires every plate's illustrator and death year to be recorded
/// and rendered in S17, and a hand-kept list drifts from the data the first time
/// a plate is dropped.
File plateLedgerFile(ContentBuildOptions options) =>
    File(p.join(options.inDir.path, kAttributionsDir, 'plates.md'));

/// Writes the plate ledger for [source].
void writePlateLedger(ContentSource source, ContentBuildOptions options) {
  final File file = plateLedgerFile(options)..parent.createSync(recursive: true);
  file.writeAsStringSync(renderPlateLedger(source));
}
