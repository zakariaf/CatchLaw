import 'package:flutter_test/flutter_test.dart';

import '../../testing/measurement/accuracy_stats.dart';

void main() {
  test('medianAbsoluteErrorMm reports the middle error of an odd count', () {
    expect(medianAbsoluteErrorMm(const <int>[148, 150, 153], referenceMm: 150), 2);
  });

  test('medianAbsoluteErrorMm rounds an even-count median up', () {
    // An accuracy figure that rounded its own error DOWN would be the harness
    // flattering itself.
    expect(medianAbsoluteErrorMm(const <int>[150, 151, 152, 154], referenceMm: 150), 2);
  });

  test('medianAbsoluteErrorMm handles a single reading', () {
    expect(medianAbsoluteErrorMm(const <int>[153], referenceMm: 150), 3);
  });

  test('medianAbsoluteErrorMm treats an error either side of the reference alike', () {
    // Three millimetres short and three millimetres long are the same size of
    // mistake; only one of them is in the fisher's favour, and the harness does
    // not care which.
    expect(medianAbsoluteErrorMm(const <int>[147], referenceMm: 150), 3);
    expect(medianAbsoluteErrorMm(const <int>[153], referenceMm: 150), 3);
  });

  test('worstAbsoluteErrorMm reports the fisher’s bad day', () {
    // A MEAN would hide the one reading that was 12 mm out behind nine that
    // were perfect, and it is the twelve that costs a licence.
    expect(worstAbsoluteErrorMm(const <int>[150, 150, 150, 150, 162], referenceMm: 150), 12);
  });

  test('spreadMm separates a calibration problem from a technique problem', () {
    // A tight spread that is uniformly wrong is a calibration problem; a wide
    // spread around the right answer is a technique problem. They have
    // different fixes, and one number cannot tell them apart.
    expect(spreadMm(const <int>[160, 160, 161]), 1);
    expect(spreadMm(const <int>[140, 150, 160]), 20);
  });

  test('the statistics refuse an empty set rather than reporting zero error', () {
    // Zero error over no readings is the most flattering possible lie.
    expect(() => medianAbsoluteErrorMm(const <int>[], referenceMm: 150), throwsArgumentError);
    expect(() => worstAbsoluteErrorMm(const <int>[], referenceMm: 150), throwsArgumentError);
    expect(() => spreadMm(const <int>[]), throwsArgumentError);
  });
}
