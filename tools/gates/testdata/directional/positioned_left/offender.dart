// Fixture for E06/T05: one banned or one allowed directional construct.
// Valid Dart so `dart format` can parse it; excluded from the analyzer
// because the identifiers are deliberately undefined — the gate greps
// text, it does not compile.

Widget build() {
  return const Positioned(left: 12, child: SizedBox.shrink());
}
