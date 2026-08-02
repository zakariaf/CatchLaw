// Fixture for E06/T05: the hatch as a STANDALONE comment above the offending
// line, which is the only form that survives `dart format` wrapping a
// construct past the page width. Discovered by watching CI split the
// single-line form of this same fixture.

Widget build() {
  return const Padding(
    // catchlaw-directional-ok — the ruler must not mirror (SPEC.md §9.3)
    padding: EdgeInsets.only(left: 40),
    child: SizedBox.shrink(),
  );
}
