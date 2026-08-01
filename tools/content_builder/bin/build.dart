// The `dart run content_builder:build` entry point.
//
// D-4 gives this deliverable one name — directory `tools/content_builder/`,
// package `content_builder`, executable `build`.
//
// The entry point delegates immediately so the build itself stays testable:
// everything below `run` reads its arguments and writes its output through
// injected sinks, and no test has to spawn a process to assert a failure line.
import 'dart:io';

import 'package:content_builder/src/cli/run.dart';

/// Runs the content build and exits with its code: 0 built, 1 failures and
/// nothing written, 2 usage error.
void main(List<String> args) {
  exitCode = run(args, out: stdout, err: stderr);
}
