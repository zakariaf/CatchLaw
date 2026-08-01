// The Result/Failure pair of FLUTTER_GUIDE.md §1.6, vendored rather than
// depended on, and the line between a Failure and a Resolution variant.
//
// "No rule found" is a legal statement about the reference data and travels as
// Ok(...). A rule row that says minSize and carries no number is a content
// defect with no legal statement to make, and travels as Failure(...).
// catchlaw-rule-engine rule 8 is unambiguous about the first half, and names
// `findings.isEmpty ? meets : ...` as the anti-pattern that comes from blurring
// the two.

import 'dart:io';

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../testing/utils/result.dart';

/// Names a `dart:core` type that the unrenamed `Error` would have shadowed.
StateError _coreErrorStillResolves() => StateError('still dart:core');

void main() {
  group('Result', () {
    test('ok carries its value', () {
      const r = Result<int>.ok(3);
      expect(r, isA<Ok<int>>());
      expect(r.asOk.value, 3);
    });

    test('error carries its exception', () {
      const e = MalformedRule(ruleId: 1, field: 'minSizeMm');
      const r = Result<int>.error(e);
      expect(r, isA<Failure<int>>());
      expect(r.asFailure.exception, same(e));
    });

    test('error carries a stack trace when one is supplied', () {
      // §1.6 warning 3. The reference implementation drops it, and this app
      // cannot phone home: the local stack trace is all anybody gets.
      final StackTrace trace = StackTrace.current;
      // Not const: StackTrace.current is a runtime value.
      final r = Result<int>.error(const MalformedRule(ruleId: 1, field: 'minSizeMm'), trace);
      expect(r.asFailure.stackTrace, same(trace));
    });

    test('error leaves the stack trace null when none is supplied', () {
      // Optional, because a mandatory field would force every construction
      // site to fabricate a trace.
      const r = Result<int>.error(MalformedRule(ruleId: 1, field: 'minSizeMm'));
      expect(r.asFailure.stackTrace, isNull);
    });

    test('switches exhaustively with no default arm', () {
      // FLUTTER_GUIDE.md §7.2: the analyzer errors on a missed case, which is
      // the entire reason the union is sealed. A `default:` here would compile
      // today and silently swallow a third variant added later.
      String describe(Result<int> r) => switch (r) {
        Ok<int>(value: final int v) => 'ok $v',
        Failure<int>(exception: final Exception e) => 'failed $e',
      };
      expect(describe(const Result<int>.ok(7)), 'ok 7');
      expect(
        describe(const Result<int>.error(MalformedRule(ruleId: 2, field: 'x'))),
        startsWith('failed'),
      );
    });

    test('does not shadow dart:core Error in an importing file', () {
      // §1.6 warning 1, and the reason the type is called Failure rather than
      // Error. This file imports the barrel AND names StateError; if the
      // vendored type were called Error, dart:core's would be shadowed here and
      // AssertionError and StateError would stop resolving.
      expect(_coreErrorStillResolves(), isA<StateError>());
    });
  });

  group('EngineException', () {
    test('has exactly MalformedRule and MalformedSeason', () {
      // A third content-defect kind must be a deliberate edit that breaks this
      // switch, not a silent `default:`.
      String kindOf(EngineException e) => switch (e) {
        MalformedRule() => 'rule',
        MalformedSeason() => 'season',
      };
      expect(kindOf(const MalformedRule(ruleId: 1, field: 'minSizeMm')), 'rule');
      expect(kindOf(const MalformedSeason(ruleId: 1, field: 'startMonth')), 'season');
    });

    test('MalformedRule names the rule id it rejected', () {
      // A content defect is useless to E04 unless it says which authored row
      // produced it.
      const e = MalformedRule(ruleId: 91, field: 'minSizeMm');
      expect(e.ruleId, 91);
      expect(e.field, 'minSizeMm');
      expect(e.toString(), contains('91'));
      expect(e.toString(), contains('minSizeMm'));
    });

    test('is an Exception and not an Error', () {
      // §1.6 warning 2: the error channel is Exception, not Object. A TypeError
      // from a bad cast escapes Result-based control flow entirely, and this
      // type is not crash-proofing.
      expect(const MalformedRule(ruleId: 1, field: 'x'), isA<Exception>());
    });
  });

  test('lib exports no asOk helper', () {
    // §1.6 warning 4: asOk is an unchecked cast that throws on the error path,
    // which defeats the entire point of the type. It lives in testing/, and
    // tools/content_builder imports lib/ and not testing/.
    final List<File> libFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();
    expect(libFiles, isNotEmpty, reason: 'an empty scan reports success');
    final offenders = <String>[
      for (final File f in libFiles)
        if (f.readAsStringSync().contains('asOk')) f.path,
    ];
    expect(offenders, isEmpty);
  });
}
