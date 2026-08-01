import 'package:meta/meta.dart';
import 'package:rule_engine/src/models/catch_tally.dart';
import 'package:rule_engine/src/models/landing.dart';
import 'package:rule_engine/src/models/species.dart';
import 'package:rule_engine/src/models/zone.dart';

/// Everything the engine is allowed to know, declared once.
///
/// The whole contract lands in one commit even though [landing], [tally] and
/// [species] are not read until E03/T07, T08 and T11. A value type that gains a
/// required field in five separate commits forces five rewrites of every
/// construction site inside one epic, and each of those diffs stops being about
/// the thing its task is named after.
///
/// There is no `Clock` in this package. `catchlaw-rule-engine` rule 3 requires
/// the evaluation date to be a parameter and forbids reading the wall clock
/// under `lib/`; [on] being required is that seam. A `Clock` interface here would
/// have no caller inside the package and `/simplify` would be right to delete
/// it — the wall-clock implementation belongs in E10, where something calls it.
@immutable
class EvaluationRequest {
  /// [waterType] must be [WaterType.salt] or [WaterType.fresh]: the fisher is
  /// standing in one or the other.
  const EvaluationRequest({
    required this.jurisdictionId,
    required this.speciesId,
    required this.species,
    required this.waterType,
    required this.zonePath,
    required this.on,
    required this.contentCheckedOn,
    required this.landing,
    required this.tally,
  }) : assert(
         waterType != WaterType.both,
         'a request is salt or fresh; `both` is a property of a RULE, and a '
         '`both` request would make the fresh-drops-in-salt guard meaningless',
       );

  /// Which authority's rules to read.
  final int jurisdictionId;

  /// The species search already resolved.
  final int speciesId;

  /// That species, for the statements T11 makes about absence.
  final Species species;

  /// Salt or fresh. Never [WaterType.both] — see the constructor's assert.
  final WaterType waterType;

  /// The zone and every ancestor above it, outermost first.
  ///
  /// Materialised by the caller. E11 produces it from a single GPS fix; this
  /// package does no point-in-polygon work and holds no geometry.
  final List<Zone> zonePath;

  /// The landing date, ISO-8601. Required, so no clock is read here.
  final String on;

  /// When the bundled content was last verified, ISO-8601.
  final String contentCheckedOn;

  /// The individual in the hand, measured or not.
  final Landing landing;

  /// What has already been taken.
  final CatchTally tally;
}
