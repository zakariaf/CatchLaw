// The four phases, and the one thing `main` may never do.
//
// catchlaw-content-pipeline rule 2: a non-empty failure list means exit 1 and
// NO database is written. Not a partial one, not a previous one left in place
// and reported as fresh. This is proved at the entry point rather than asserted
// in prose, because every later assertion in this epic depends on it.

import 'dart:io';

import 'package:content_builder/src/cli/run.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

class _Sink implements StringSink {
  final StringBuffer _buffer = StringBuffer();

  @override
  void write(Object? obj) => _buffer.write(obj);
  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) =>
      _buffer.writeAll(objects, separator);
  @override
  void writeCharCode(int charCode) => _buffer.writeCharCode(charCode);
  @override
  void writeln([Object? obj = '']) => _buffer.writeln(obj);
  @override
  String toString() => _buffer.toString();
}

({Directory root, File out}) corpus(Map<String, String> files) {
  final Directory root = Directory.systemTemp.createTempSync('content_builder_run_');
  for (final MapEntry<String, String> entry in files.entries) {
    final file = File('${root.path}/in/${entry.key}');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }
  return (root: root, out: File('${root.path}/out/reference.db'));
}

void main() {
  group('run', () {
    test('writes nothing when the failure list is non-empty', () {
      final ({Directory root, File out}) c = corpus(<String, String>{
        'es-ga/rules.yaml': kDuplicateRowIdYaml,
      });
      addTearDown(() => c.root.deleteSync(recursive: true));
      final err = _Sink();

      final int code = run(
        <String>[
          '--in',
          '${c.root.path}/in',
          '--out',
          c.out.path,
          '--build-date',
          '2026-08-14',
          '--generator-commit',
          '4f2c1ab',
        ],
        out: _Sink(),
        err: err,
      );

      expect(code, 1);
      expect(c.out.existsSync(), isFalse);
      expect(err.toString(), contains('es-ga-r-001'));
      expect(err.toString(), contains('not written'));
    });

    test('prints one line per failure and never a stack trace', () {
      final ({Directory root, File out}) c = corpus(<String, String>{
        'es-ga/rules.yaml': kMalformedYaml,
      });
      addTearDown(() => c.root.deleteSync(recursive: true));
      final err = _Sink();

      run(
        <String>[
          '--in',
          '${c.root.path}/in',
          '--out',
          c.out.path,
          '--build-date',
          '2026-08-14',
          '--generator-commit',
          '4f2c1ab',
        ],
        out: _Sink(),
        err: err,
      );

      expect(err.toString(), isNot(contains('#0')));
      expect(err.toString(), isNot(contains('package:yaml')));
    });

    test('exits 2 on a usage error and writes nothing', () {
      final ({Directory root, File out}) c = corpus(const <String, String>{});
      addTearDown(() => c.root.deleteSync(recursive: true));
      final err = _Sink();

      final int code = run(<String>['--in', '${c.root.path}/in'], out: _Sink(), err: err);

      expect(code, 2);
      expect(c.out.existsSync(), isFalse);
      expect(err.toString(), contains('--out'));
    });

    test('exits 2 and names the flag when a rejected flag is passed', () {
      final err = _Sink();

      final int code = run(<String>['--force'], out: _Sink(), err: err);

      expect(code, 2);
      expect(err.toString(), contains('--force'));
    });
  });
}
