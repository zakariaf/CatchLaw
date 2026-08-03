import 'package:catchlaw/domain/models/measurement_draft.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MeasurementDraft.totalMm sums every marked segment', () {
    // A fish longer than the phone is measured in segments — mark at the tail,
    // slide the fish, mark again — which is why the draft is a list.
    expect(MeasurementDraft(segmentsMm: const <int>[180, 200]).totalMm, 380);
  });

  test('MeasurementDraft.totalMm is zero before anything is marked', () {
    expect(MeasurementDraft().totalMm, 0);
    expect(MeasurementDraft().isEmpty, isTrue);
  });

  test('MeasurementDraft.mark appends without touching the commitment', () {
    final MeasurementDraft draft = MeasurementDraft(committedMm: 450).mark(180);
    expect(draft.segmentsMm, <int>[180]);
    expect(draft.committedMm, 450);
  });

  test('MeasurementDraft.cancel restores rather than clearing', () {
    // THE behaviour most likely to be written the obvious wrong way. Wet hands
    // hit cancel by accident, and a cancel that wiped an accepted 380 mm costs
    // a measurement that cannot be retaken once the fish is in the bin.
    final MeasurementDraft draft = MeasurementDraft(
      segmentsMm: const <int>[180, 200],
      committedMm: 380,
    ).cancel();
    expect(draft.segmentsMm, isEmpty);
    expect(draft.committedMm, 380);
  });

  test('MeasurementDraft.cancel keeps a null commitment null', () {
    // Never zero. Zero is a fish of no length; null is no measurement.
    expect(MeasurementDraft(segmentsMm: const <int>[180]).cancel().committedMm, isNull);
  });

  test('MeasurementDraft.undo removes only the last segment', () {
    final MeasurementDraft draft = MeasurementDraft(segmentsMm: const <int>[180, 200, 40]).undo();
    expect(draft.segmentsMm, <int>[180, 200]);
  });

  test('MeasurementDraft.undo on an empty draft is a no-op', () {
    // A fisher tapping undo twice with wet hands has not done anything wrong.
    expect(MeasurementDraft().undo().segmentsMm, isEmpty);
  });

  test('MeasurementDraft.accept commits the running total', () {
    final MeasurementDraft draft = MeasurementDraft(segmentsMm: const <int>[180, 200]).accept();
    expect(draft.committedMm, 380);
    expect(draft.segmentsMm, isEmpty);
  });

  test('MeasurementDraft.accept on an empty draft leaves the commitment alone', () {
    // A stray tap must not turn a real measurement into zero, which reads as a
    // fish of no length rather than as no measurement at all.
    expect(MeasurementDraft(committedMm: 450).accept().committedMm, 450);
  });

  test('MeasurementDraft == compares the segments and the commitment', () {
    expect(
      MeasurementDraft(segmentsMm: const <int>[180], committedMm: 450),
      MeasurementDraft(segmentsMm: const <int>[180], committedMm: 450),
    );
    expect(
      MeasurementDraft(segmentsMm: const <int>[180]),
      isNot(MeasurementDraft(segmentsMm: const <int>[181])),
    );
  });

  test('MeasurementDraft holds only integer millimetres', () {
    // SPEC.md §9.5: storage is always integer millimetres, and the display unit
    // is a separate decision. A double here would let two screens that measured
    // the same fish store different numbers.
    expect(MeasurementDraft(segmentsMm: const <int>[180]).segmentsMm.first, isA<int>());
    expect(MeasurementDraft(committedMm: 450).committedMm, isA<int>());
  });
}
