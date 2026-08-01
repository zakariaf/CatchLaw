// The absence-of-a-failure-class test.
//
// Not "does the happy path work" — that is every other file here. This asks the
// question that has no happy path: across every world the fakes can be put in,
// is there one where a catch is neither persisted nor reported as failed? A
// silently lost record is a fish the fisher believes is in the log, and he finds
// out it is not while an inspector is holding the phone.

import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

import '../../../testing/fakes/fake_measurement_repository.dart';
import '../../../testing/fakes/fake_reference_repository.dart';
import '../../../testing/fakes/fake_settings_repository.dart';
import '../../../testing/fakes/store_env.dart';
import '../../../testing/models/user_fixtures.dart';

void main() {
  for (final StoreEnv env in StoreEnv.detectable) {
    test('$env: recordCatch either persists or surfaces a typed failure', () async {
      final repository = FakeMeasurementRepository(env: env);

      final Result<CatchRecord> result = await repository.recordCatch(kCatchDraftAmeixa);

      switch (result) {
        case Ok<CatchRecord>(:final CatchRecord value):
          expect(
            repository.recorded.map((CatchRecord c) => c.id),
            contains(value.id),
            reason: 'Ok means the row is readable, not merely that no error was raised',
          );
        case Failure<CatchRecord>(:final Exception exception):
          expect(exception, isA<DataFailure>());
          expect((exception as DataFailure).code, isNotEmpty);
      }
    });

    test('$env: searchSpecies either answers or surfaces a typed failure', () async {
      final Result<List<Species>> result = await FakeReferenceRepository(
        env: env,
      ).searchSpecies('ameixa');

      switch (result) {
        case Ok(:final value):
          expect(value, isA<List<Object>>());
        case Failure(:final Exception exception):
          expect(exception, isA<DataFailure>());
      }
    });

    test('$env: setLengthUnit either applies or surfaces a typed failure', () async {
      final repository = FakeSettingsRepository(env: env);

      final Result<void> result = await repository.setLengthUnit(kFixtureLengthUnit);

      switch (result) {
        case Ok<void>():
          expect(repository.writes, contains('length_unit'));
        case Failure<void>(:final Exception exception):
          expect(exception, isA<DataFailure>());
      }
    });
  }

  test('StoreEnv.corruptButReportsOk is excluded from detectable', () {
    // The honest line. This world answers Ok and has written nothing, and no
    // test in this suite can tell the difference — which is precisely why E21
    // keeps a manual pass on a real device, and why the value is named rather
    // than left out.
    expect(StoreEnv.detectable, isNot(contains(StoreEnv.corruptButReportsOk)));
    expect(StoreEnv.values, contains(StoreEnv.corruptButReportsOk));
  });
}
