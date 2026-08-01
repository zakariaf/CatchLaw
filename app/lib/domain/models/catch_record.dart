import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:meta/meta.dart';

/// One recorded fish, as the app reasons about it.
///
/// **No drift type appears here.** A `CatchRow` carries drift's `Value`
/// wrappers, its companion machinery and its knowledge of a table; a view model
/// that held one would be a view model that cannot be constructed in a test
/// without a database, and a change to a column name would ripple into
/// `app/lib/ui/`.
///
/// Everything §7.2 denormalises is here as a literal, because a content update
/// can renumber or retire a rule and a three-year-old record must still say
/// what it said when it was recorded.
@immutable
class CatchRecord {
  /// A recorded catch.
  const CatchRecord({
    required this.id,
    required this.jurisdictionCode,
    required this.zoneCode,
    required this.speciesId,
    required this.scientificName,
    required this.outcome,
    required this.createdAt,
    required this.updatedAt,
    this.tripId,
    this.lengthMm,
    this.measurementCode,
    this.outcomeDetail,
    this.ruleCitationRef,
    this.contentVersion,
    this.wasKept = false,
    this.photoPath,
    this.latitude,
    this.longitude,
  });

  /// The row id.
  final int id;

  /// The trip this belongs to, if any.
  final int? tripId;

  /// Where it was landed.
  final String jurisdictionCode;

  /// Which zone of that jurisdiction.
  final String zoneCode;

  /// A **soft** hint for "show me this species again". Nothing on the record
  /// screen reads through it; if it no longer resolves, the row still renders.
  final int speciesId;

  /// The binomial, as it was when the record was made.
  final String scientificName;

  /// Integer millimetres. Conversion is display-only.
  final int? lengthMm;

  /// `TL`, `FL`, `SHL` — without which the number means nothing.
  final String? measurementCode;

  /// What the verdict said.
  final CatchOutcome outcome;

  /// The factual finding **as shown**. Not regenerated: the sentence the fisher
  /// read is the sentence the record keeps.
  final String? outcomeDetail;

  /// The instrument the verdict quoted.
  final String? ruleCitationRef;

  /// Which pack produced it.
  final String? contentVersion;

  /// Whether the fish was kept.
  final bool wasKept;

  /// An in-app photo, never one from the shared camera roll.
  final String? photoPath;

  /// `null` unless the fisher opted in.
  final double? latitude;

  /// `null` unless the fisher opted in.
  final double? longitude;

  /// ISO-8601 UTC.
  final String createdAt;

  /// ISO-8601 UTC.
  final String updatedAt;
}

/// One species' contribution to a day's tally.
@immutable
class SpeciesTallyEntry {
  /// [count] caught, [kept] kept.
  const SpeciesTallyEntry({
    required this.speciesId,
    required this.scientificName,
    required this.count,
    required this.kept,
  });

  /// The soft species reference.
  final int speciesId;

  /// The binomial, as recorded.
  final String scientificName;

  /// How many were caught.
  final int count;

  /// How many were kept.
  final int kept;
}

/// A catch about to be recorded.
///
/// **Separate from [CatchRecord] because a draft has no id and no `updatedAt`.**
/// Reusing the record type would mean an `id: 0` sentinel travelling into the
/// insert, and a sentinel that means "not yet" is one forgotten check away from
/// meaning row zero.
///
/// [outcome] is a [CatchOutcome] rather than a string: §7.2's `CHECK` and this
/// enum say the same thing, and saying it in the type means the violation
/// cannot be constructed rather than being caught after the fact.
@immutable
class CatchDraft {
  /// A catch ready to be written.
  const CatchDraft({
    required this.jurisdictionCode,
    required this.zoneCode,
    required this.speciesId,
    required this.scientificName,
    required this.outcome,
    required this.createdAt,
    this.tripId,
    this.lengthMm,
    this.measurementCode,
    this.outcomeDetail,
    this.ruleCitationRef,
    this.contentVersion,
    this.wasKept = false,
    this.photoPath,
    this.latitude,
    this.longitude,
  });

  /// The trip this belongs to, if any. A quick-add has none.
  final int? tripId;

  /// Where it was landed.
  final String jurisdictionCode;

  /// Which zone of that jurisdiction.
  final String zoneCode;

  /// The soft species reference.
  final int speciesId;

  /// The binomial, denormalised at the moment of recording.
  final String scientificName;

  /// Integer millimetres.
  final int? lengthMm;

  /// `TL`, `FL`, `SHL`.
  final String? measurementCode;

  /// What the verdict said.
  final CatchOutcome outcome;

  /// The factual finding as shown.
  final String? outcomeDetail;

  /// The instrument the verdict quoted.
  final String? ruleCitationRef;

  /// Which pack produced it.
  final String? contentVersion;

  /// Whether the fish was kept.
  final bool wasKept;

  /// An in-app photo.
  final String? photoPath;

  /// `null` unless the fisher opted in.
  final double? latitude;

  /// `null` unless the fisher opted in.
  final double? longitude;

  /// ISO-8601 UTC. **The caller's**, never a clock read down here: a data layer
  /// that reads the clock is a data layer whose tests depend on when they ran.
  final String createdAt;

  /// This draft with [tripId] replaced.
  CatchDraft copyWith({int? tripId, CatchOutcome? outcome, int? lengthMm}) => CatchDraft(
    tripId: tripId ?? this.tripId,
    jurisdictionCode: jurisdictionCode,
    zoneCode: zoneCode,
    speciesId: speciesId,
    scientificName: scientificName,
    lengthMm: lengthMm ?? this.lengthMm,
    measurementCode: measurementCode,
    outcome: outcome ?? this.outcome,
    outcomeDetail: outcomeDetail,
    ruleCitationRef: ruleCitationRef,
    contentVersion: contentVersion,
    wasKept: wasKept,
    photoPath: photoPath,
    latitude: latitude,
    longitude: longitude,
    createdAt: createdAt,
  );
}
