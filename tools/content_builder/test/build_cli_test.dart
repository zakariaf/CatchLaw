// The name D-4 fixes, exercised through the process rather than the library.
//
// Every other test in this package calls `run` directly. This one spawns
// `dart run content_builder:build`, because the name in D-4 is the thing CI, the
// epic's definition of done and every task file type — and a package that
// imports cleanly can still fail to resolve under its executable name.

import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'content_builder:build resolves under its D-4 name and exits 2 with no arguments',
    () {
      final ProcessResult result = Process.runSync('dart', <String>[
        'run',
        'content_builder:build',
      ]);

      expect(
        result.exitCode,
        2,
        reason:
            'exit 2 is a usage error: the invocation was wrong and no content '
            'was examined. Exit 1 would say the corpus is broken and send '
            'somebody to edit rules.yaml looking for it.\n'
            'stdout: ${result.stdout}\nstderr: ${result.stderr}',
      );
      expect(result.stderr, contains('--in'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test('content_builder:build rejects --force by name', () {
    final ProcessResult result = Process.runSync('dart', <String>[
      'run',
      'content_builder:build',
      '--force',
    ]);

    expect(result.exitCode, 2);
    expect(result.stderr, contains('will not be added'));
  }, timeout: const Timeout(Duration(minutes: 2)));
}
