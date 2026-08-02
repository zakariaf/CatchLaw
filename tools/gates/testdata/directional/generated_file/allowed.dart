// Fixture for E06/T05: one banned or one allowed directional construct.
// Valid Dart so `dart format` can parse it; excluded from the analyzer
// because the identifiers are deliberately undefined — the gate greps
// text, it does not compile.
//
// This clean sibling exists so the directory is a NON-EMPTY scan. Without it
// the fixture would pass for the wrong reason — zero files, not one skipped —
// and the row would stop asserting anything about generated output.

Widget build() {
  return const Padding(
    padding: EdgeInsetsDirectional.only(start: 16, end: 8),
    child: SizedBox.shrink(),
  );
}
