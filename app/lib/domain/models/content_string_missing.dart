/// A `content_string` key that resolved in no locale and had no fallback left.
///
/// **This throws rather than returning something.** `SPEC.md` §9.2 forbids
/// rendering the key and forbids rendering an empty string, and the three
/// tempting alternatives are each worse than a crash:
///
/// * the key itself — `species.hamour.name` on a result screen is a defect that
///   looks like a design choice and survives review;
/// * an empty string — a blank cell reads as "not recorded", which is a real
///   and different state (`SPEC.md` §6, S18–S23);
/// * whatever locale happens to have a row — Galician inside an Arabic
///   sentence, silently, and a confident wrong vernacular name is worse than
///   no name at all (§9.2 point 3).
///
/// The only way to reach it is a `reference.db` that violates the §8 build
/// assertion — a database this project did not build, or one that arrived
/// corrupted. This does not weaken invariant 5: an unresolvable string is
/// **absent**, not stale, and the two are not merged into one word here any
/// more than anywhere else.
///
/// There is no network and no crash upload (`CONVENTIONS.md` §9.1), so [key]
/// travelling in the message is the only diagnostic anybody will ever get.
final class ContentStringMissing implements Exception {
  /// Records that [key] resolved nowhere.
  const ContentStringMissing(this.key);

  /// The key that could not be resolved.
  final String key;

  @override
  String toString() => 'ContentStringMissing: $key resolved in no locale, and no fallback remained';
}
