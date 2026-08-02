// Fixture for E06/T05: one banned or one allowed directional construct.
// Valid Dart so `dart format` can parse it; excluded from the analyzer
// because the identifiers are deliberately undefined — the gate greps
// text, it does not compile.

Widget build() {
  return const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 8), child: SizedBox.shrink());
}
