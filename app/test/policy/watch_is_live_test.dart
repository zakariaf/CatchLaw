// A method named `watch*` must return a LIVE query.
//
// `TripDao.watchRecentTrips` shipped as `.get().asStream()`. It compiled, it
// satisfied `Stream<List<TripRow>>`, and it emitted exactly once — so the trips
// screen rendered whatever existed when it opened and never moved again.
//
// The symptom pointed at the wrong layer, which is what makes this worth a
// policy test rather than only a behavioural one: tapping "Start a trip"
// flipped the button (that stream was a real `.watch()`) and the list below it
// stayed empty, so the feature looked broken while the database was perfectly
// correct.
//
// A behavioural test catches this for the ONE query it covers. This grep
// catches it for every query written afterwards, including the ones nobody
// remembers to write a stream test for — and it is cheap, because
// `.get().asStream()` has no legitimate use in a DAO: a caller that wants a
// one-shot read should call a method that says so in its name.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Where the hand-written queries live. Generated code is excluded because it
/// is not authored and cannot carry the defect.
const String kDaoRoot = 'lib/data/daos';

void main() {
  test('no DAO turns a one-shot read into a stream', () {
    final offenders = <String>[];

    for (final FileSystemEntity entity in Directory(kDaoRoot).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.g.dart')) continue;

      final String source = entity.readAsStringSync();
      final List<String> lines = source.split('\n');
      for (var i = 0; i < lines.length; i++) {
        // The comment in trip_dao.dart naming the defect is not the defect.
        if (lines[i].trimLeft().startsWith('///') || lines[i].trimLeft().startsWith('//')) continue;
        if (lines[i].contains('.asStream()')) {
          offenders.add('${entity.path}:${i + 1}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'A Future turned into a Stream emits once and never again. Use .watch() '
          'or .watchSingleOrNull() so the screen updates when the row changes.',
    );
  });

  test('every DAO method named watch returns a Stream', () {
    // The other half of the same mistake: a `watch*` that returns a Future is
    // caught by the analyzer at the call site, but a `watch*` returning
    // `Future<Stream<T>>` or a stream built by hand is not — and both read as
    // live at the call site, which is the only place anyone checks.
    final offenders = <String>[];
    final declaration = RegExp(r'^\s*(\w[\w<>?, ]*)\s+(watch\w*)\s*\(');

    for (final FileSystemEntity entity in Directory(kDaoRoot).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.g.dart')) continue;

      final List<String> lines = entity.readAsStringSync().split('\n');
      for (var i = 0; i < lines.length; i++) {
        final RegExpMatch? m = declaration.firstMatch(lines[i]);
        if (m == null) continue;
        final String returnType = m.group(1)!.trim();
        if (returnType.startsWith('Stream<')) continue;
        offenders.add('${entity.path}:${i + 1} ${m.group(2)} returns $returnType');
      }
    }

    expect(offenders, isEmpty, reason: 'a watch* method must return a Stream');
  });
}
