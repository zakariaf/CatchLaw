import 'package:catchlaw/domain/models/species_hint.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Citation;

/// What a species row knows beyond its name and its silhouette.
///
/// The [citation] is **required and non-nullable**, which is invariant 3 made
/// unrepresentable rather than checked. A row carries a hint — `protected`, a
/// closure, a minimum size — and every one of those is a statement about a
/// published instrument. A hint with no citation is the app asserting the law
/// on its own authority, which is the one thing it never does.
@immutable
class SpeciesFacts {
  /// The facts behind one row.
  const SpeciesFacts({required this.inActiveZone, required this.hint, required this.citation});

  /// Whether a rule for this species reaches the active zone.
  ///
  /// §7.3 step 2: a rule whose `zone_id` is `NULL`, equals the active zone, or
  /// is an ancestor of it.
  final bool inActiveZone;

  /// The one-word headline, in numbers and enums.
  final SpeciesHint hint;

  /// The instrument behind the hint.
  final Citation citation;

  @override
  bool operator ==(Object other) =>
      other is SpeciesFacts &&
      other.inActiveZone == inActiveZone &&
      other.hint == hint &&
      other.citation == citation;

  @override
  int get hashCode => Object.hash(inActiveZone, hint, citation);
}
