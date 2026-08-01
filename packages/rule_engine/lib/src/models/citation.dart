import 'package:meta/meta.dart';

/// The instrument a finding rests on: what it says, where, and when it was read.
///
/// Four fields, all required and all non-nullable, and there is no factory, no
/// default and no `Citation.unknown()`. That is structural on purpose —
/// invariant 3 says every result carries a citation, and the way to make a rule
/// true is to make its breach unrepresentable rather than to assert it
/// somewhere. Check 4 of `check_app_invariants.sh` greps this package for a
/// nullable citation type and fails on one, comments included.
///
/// Dates are ISO-8601 strings exactly as `SPEC.md` §7.1 stores them. `DateTime`
/// has no const constructor, so a `DateTime` field here would make every fixture
/// a runtime allocation and `const Citation(...)` impossible.
@immutable
class Citation {
  /// Every field is required: there is no way to cite nothing.
  const Citation({
    required this.instrument,
    required this.article,
    required this.publishedOn,
    required this.checkedOn,
  });

  /// The instrument itself — `Ministerial Decision 580/2015`.
  final String instrument;

  /// The article within it — `Art. 3`.
  final String article;

  /// When the instrument was published, ISO-8601.
  final String publishedOn;

  /// When a human last verified the wording, ISO-8601.
  ///
  /// Not when a machine ran: a wall-clock reading taken at build time records
  /// the build, not the reading of the gazette.
  final String checkedOn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Citation &&
          other.instrument == instrument &&
          other.article == article &&
          other.publishedOn == publishedOn &&
          other.checkedOn == checkedOn;

  @override
  int get hashCode => Object.hash(instrument, article, publishedOn, checkedOn);

  @override
  String toString() => 'Citation($instrument, $article, $publishedOn, $checkedOn)';
}
