import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'arb_rules.dart';

/// Which branch the *resolved* `intl` actually selects.
///
/// `SPEC.md` §9.5's table is a document, and a document cannot tell you what
/// the toolchain will do. If the resolved `intl` carries plural rules older
/// than CLDR 48, a `many` branch in `app_es.arb` compiles, ships, and is never
/// selected — and only these rows would notice.
String _category(num n, String locale) => Intl.plural(
  n,
  locale: locale,
  zero: 'zero',
  one: 'one',
  two: 'two',
  few: 'few',
  many: 'many',
  other: 'other',
);

void main() {
  test('missingCategories returns no finding for the shipped app/lib/l10n tree', () {
    expect(missingCategories(loadArbDir('lib/l10n')), isEmpty);
  });

  test('unexpectedCategories returns no finding for the shipped app/lib/l10n tree', () {
    expect(unexpectedCategories(loadArbDir('lib/l10n')), isEmpty);
  });

  test('Intl.plural selects zero for ar at 0', () => expect(_category(0, 'ar'), 'zero'));
  test('Intl.plural selects two for ar at 2', () => expect(_category(2, 'ar'), 'two'));
  test('Intl.plural selects few for ar at 3', () => expect(_category(3, 'ar'), 'few'));
  test('Intl.plural selects many for ar at 11', () => expect(_category(11, 'ar'), 'many'));
  test('Intl.plural selects other for ar at 100', () => expect(_category(100, 'ar'), 'other'));

  test(
    'Intl.plural selects many for es at 1000000',
    () => expect(_category(1000000, 'es'), 'many'),
  );
  test(
    'Intl.plural selects other for gl at 1000000',
    () => expect(_category(1000000, 'gl'), 'other'),
  );

  test('ci workflow invokes check_arb_parity.sh with app/lib/l10n', () {
    // D-1: the gate takes its target as an argument and exits 2 on a missing
    // one, so a bare default aborts the run at this repo root rather than
    // scanning the wrong tree.
    final String workflow = File('../.github/workflows/validate.yml').readAsStringSync();
    expect(workflow, contains('check_arb_parity.sh app/lib/l10n'));
  });

  test('ci workflow runs the app suite that carries these rows', () {
    // The plural-category check is a Dart test, so "it runs in CI" means the
    // app suite runs. A dedicated `flutter test test/l10n` step would duplicate
    // it, and to be worth its minute it would have to run ahead of the
    // libsqlite3-dev install that `ci_workflow_test.dart` requires every suite
    // step to follow.
    final String workflow = File('../.github/workflows/validate.yml').readAsStringSync();
    expect(workflow, contains('cd app && flutter test --test-randomize-ordering-seed random'));
  });
}
