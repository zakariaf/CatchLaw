import 'dart:io';

import 'package:test/test.dart';

void main() {
  test(
    'content_builder:build resolves under its D-4 name and exits 64',
    () {
      final ProcessResult result = Process.runSync('dart', ['run', 'content_builder:build']);
      expect(
        result.exitCode,
        64,
        reason:
            'D-4 gives this deliverable one name — directory tools/content_builder/, '
            'package content_builder, executable build. The name is live from commit '
            'one so E04 has nothing to rename. 64 is EX_USAGE.\n'
            'stdout: ${result.stdout}\nstderr: ${result.stderr}',
      );
      expect(result.stderr, contains('content_builder:build'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
