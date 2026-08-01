// The `dart run content_builder:build` entry point.
//
// D-4 gives this deliverable one name — directory `tools/content_builder/`,
// package `content_builder`, executable `build` — and this stub makes that name
// resolve from the first commit. The compiler itself is E04.
import 'dart:io';

/// Prints the usage this CLI will honour and exits `64` (`EX_USAGE`).
void main(List<String> args) {
  stderr.writeln(
    'content_builder: usage: dart run content_builder:build '
    '--in <content-dir> --out <reference.db>',
  );
  stderr.writeln('not implemented yet — the compiler lands in E04.');
  exit(64);
}
