import 'package:meta/meta.dart';

/// One outing.
@immutable
class Trip {
  /// A trip that started at [startedAt].
  const Trip({
    required this.id,
    required this.startedAt,
    required this.jurisdictionCode,
    required this.zoneCode,
    this.endedAt,
    this.label,
    this.notes,
  });

  /// The row id.
  final int id;

  /// ISO-8601 UTC.
  final String startedAt;

  /// `null` while the trip is open.
  final String? endedAt;

  /// Where it happened.
  final String jurisdictionCode;

  /// Which zone.
  final String zoneCode;

  /// What the fisher calls it, which may not be what the instrument calls it.
  final String? label;

  /// Their own notes.
  final String? notes;

  /// Whether the trip is still running.
  bool get isOpen => endedAt == null;
}

/// A place the fisher saved.
@immutable
class SavedZone {
  /// A saved place.
  const SavedZone({
    required this.id,
    required this.jurisdictionCode,
    required this.zoneCode,
    required this.sortOrder,
    this.label,
  });

  /// The row id.
  final int id;

  /// The jurisdiction code, never an id: `reference.db` is a separate file.
  final String jurisdictionCode;

  /// The zone code, for the same reason.
  final String zoneCode;

  /// Their own name for it.
  final String? label;

  /// Their own order.
  final int sortOrder;
}

/// A species this place has seen recently.
@immutable
class RecentSpecies {
  /// [useCount] uses, most recently at [lastUsedAt].
  const RecentSpecies({
    required this.speciesId,
    required this.jurisdictionCode,
    required this.zoneCode,
    required this.useCount,
    required this.lastUsedAt,
  });

  /// The soft species reference.
  final int speciesId;

  /// Where.
  final String jurisdictionCode;

  /// Which zone.
  final String zoneCode;

  /// How often.
  final int useCount;

  /// When, ISO-8601 UTC.
  final String lastUsedAt;
}
