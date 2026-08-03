/// The statistics the accuracy harness reports.
///
/// Pure Dart, no Flutter import. A helper and not a `_test.dart` file: one with
/// that suffix is executed as a suite of zero tests and fails the run
/// (`CONVENTIONS.md` §6).
///
/// **Median and worst, not mean.** A mean absolute error hides the one reading
/// that was 12 mm out behind nine that were perfect, and it is the twelve that
/// costs a licence. The median says what a typical measurement does; the worst
/// says what the fisher's bad day looks like.
library;

/// The median of `|reading − reference|`, in millimetres.
///
/// Rounds a two-element median **up**, deliberately: an accuracy figure that
/// rounded its own error down would be the harness flattering itself.
int medianAbsoluteErrorMm(List<int> readingsMm, {required int referenceMm}) {
  if (readingsMm.isEmpty) {
    throw ArgumentError.value(readingsMm, 'readingsMm', 'no readings to summarise');
  }
  final List<int> errors = readingsMm.map((int r) => (r - referenceMm).abs()).toList()..sort();
  final int middle = errors.length ~/ 2;
  if (errors.length.isOdd) return errors[middle];
  return ((errors[middle - 1] + errors[middle]) / 2).ceil();
}

/// The largest `|reading − reference|`, in millimetres.
int worstAbsoluteErrorMm(List<int> readingsMm, {required int referenceMm}) {
  if (readingsMm.isEmpty) {
    throw ArgumentError.value(readingsMm, 'readingsMm', 'no readings to summarise');
  }
  return readingsMm.map((int r) => (r - referenceMm).abs()).reduce((int a, int b) => a > b ? a : b);
}

/// The distance from the smallest reading to the largest.
///
/// Reported beside the errors because a tight spread that is uniformly wrong is
/// a **calibration** problem, and a wide spread around the right answer is a
/// **technique** problem. They have different fixes, and one number cannot tell
/// them apart.
int spreadMm(List<int> readingsMm) {
  if (readingsMm.isEmpty) {
    throw ArgumentError.value(readingsMm, 'readingsMm', 'no readings to summarise');
  }
  final sorted = List<int>.of(readingsMm)..sort();
  return sorted.last - sorted.first;
}
