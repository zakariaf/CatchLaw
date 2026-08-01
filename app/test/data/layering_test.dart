// The rules of §2.5 that decay first, asserted rather than reviewed.
//
// Every scan here checks its file list is non-empty before it checks anything
// about the contents. A grep over a tree with no files reports success, and a
// green tick that means "I looked at nothing" is the failure `CONVENTIONS.md`
// §7 names.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ReferenceRepository and MeasurementRepository do not import each other', () {
    // §2.5 rule 3. The first time somebody wants a species name on a catch row,
    // calling the other repository is one line and denormalising is three —
    // and the join belongs in domain/use_cases/, where it is testable with
    // neither database.
    final List<File> reference = _repositoryFiles('reference_repository');
    final List<File> measurement = _repositoryFiles('measurement_repository');

    expect(reference, isNotEmpty, reason: 'a scan of an empty tree reports success');
    expect(measurement, isNotEmpty, reason: 'a scan of an empty tree reports success');

    for (final file in reference) {
      expect(
        file.readAsStringSync(),
        isNot(contains('measurement_repository')),
        reason: '${file.path}: joins go in domain/use_cases/, not across repositories',
      );
    }
    for (final file in measurement) {
      expect(file.readAsStringSync(), isNot(contains('reference_repository')), reason: file.path);
    }
  });

  test('no repository imports Riverpod or holds a Ref', () {
    // §5.2. A repository that takes a Ref cannot be unit-tested without a
    // container, and a repository that cannot be unit-tested is one whose
    // failure modes are only ever exercised through a widget.
    final List<File> files = _dartFilesUnder('lib/data/repositories');
    expect(files, isNotEmpty);

    for (final file in files) {
      final String source = file.readAsStringSync();
      expect(source, isNot(contains('riverpod')), reason: file.path);
      expect(source, isNot(contains('Ref ref')), reason: file.path);
    }
  });

  test('every repository interface has a drift implementation and a fake', () {
    // §2.5 rule 4. Bare `implements` means adding a method to an interface is a
    // compile error in every fake rather than a runtime surprise in one test.
    const interfaces = <String>[
      'reference_repository',
      'measurement_repository',
      'settings_repository',
    ];

    for (final name in interfaces) {
      expect(File('lib/data/repositories/$name.dart').existsSync(), isTrue, reason: name);
      expect(File('lib/data/repositories/${name}_drift.dart').existsSync(), isTrue, reason: name);
      expect(File('testing/fakes/fake_$name.dart').existsSync(), isTrue, reason: name);
    }
  });

  test('every repository interface method returns a Result future or a plain Stream', () {
    // §2.5 rule 5 — the rule that decays the first time somebody returns a raw
    // Future<int> because the call site "cannot fail". A Stream is never
    // wrapped: AsyncValue<Result<T>> is four states where two are meaningful.
    final signature = RegExp(r'^\s{2}(\w[\w<>?, ]*)\s+\w+\(', multiLine: true);
    final files = <File>[
      File('lib/data/repositories/reference_repository.dart'),
      File('lib/data/repositories/measurement_repository.dart'),
      File('lib/data/repositories/settings_repository.dart'),
    ];

    var checked = 0;
    for (final file in files) {
      for (final RegExpMatch m in signature.allMatches(file.readAsStringSync())) {
        final String returnType = m.group(1)!.trim();
        checked++;
        expect(
          returnType.startsWith('Future<Result<') || returnType.startsWith('Stream<'),
          isTrue,
          reason: '${file.path}: $returnType',
        );
        expect(returnType, isNot(startsWith('Stream<Result<')), reason: file.path);
      }
    }
    expect(checked, greaterThan(20), reason: 'the regex matched almost nothing');
  });

  test('asOk appears nowhere under app/lib', () {
    // `FLUTTER_GUIDE.md` §1.6 point 4: an unchecked cast that throws on exactly
    // the path the Result type exists to make explicit.
    final List<File> files = _dartFilesUnder('lib');
    expect(files, isNotEmpty);

    for (final file in files) {
      expect(file.readAsStringSync(), isNot(contains('asOk')), reason: file.path);
    }
  });

  test('no drift row type appears outside lib/data', () {
    // T10's boundary. A `Row` class carries drift's Value wrappers and its
    // knowledge of a table; a view model holding one cannot be constructed in a
    // test, and a renamed column reaches app/lib/ui/.
    final rowType = RegExp(r'\b\w+Row\b|\bCompanion\b|package:drift/');
    final files = <File>[..._dartFilesUnder('lib/domain'), ..._dartFilesUnder('lib/ui')];
    expect(
      files,
      isNotEmpty,
      reason: 'lib/domain is populated by T10; an empty scan proves nothing',
    );

    for (final file in files) {
      // Comments are stripped first, and deliberately: these files EXPLAIN why
      // no drift row appears in them, and a scan that cannot tell a prohibition
      // from its own rationale forces the rationale out of the file.
      expect(
        rowType.hasMatch(_withoutComments(file.readAsStringSync())),
        isFalse,
        reason: file.path,
      );
    }
  });
}

String _withoutComments(String source) =>
    source.split('\n').where((String line) => !line.trimLeft().startsWith('//')).join('\n');

List<File> _repositoryFiles(String containing) => _dartFilesUnder(
  'lib/data/repositories',
).where((File f) => f.path.contains(containing)).toList();

List<File> _dartFilesUnder(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return const <File>[];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .toList();
}
