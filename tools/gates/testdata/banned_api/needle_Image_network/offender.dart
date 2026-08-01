// Fixture for E01/T05: one plausible call site for a single SPEC.md §14 needle.
// Valid Dart so `dart format` can parse it; excluded from the analyzer because the
// identifiers are deliberately undefined — the gate greps text, it does not compile.

Future<void> offend() async {
  final w = Image.network(plateUrl);
}
