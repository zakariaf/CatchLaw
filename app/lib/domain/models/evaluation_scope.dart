import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:meta/meta.dart';

/// Where the fisher is, in the shape the engine needs it.
///
/// **Codes, never ids.** `reference.db` is a separate file that a content
/// update replaces wholesale, and a row id that meant Rías Baixas in one pack
/// can mean something else in the next. The codes survive the replacement; the
/// ids do not, and a saved place that silently points somewhere else is the
/// worst kind of wrong answer because nothing about it looks wrong.
@immutable
class EvaluationScope {
  /// One place, resolved.
  const EvaluationScope({
    required this.jurisdictionCode,
    required this.zoneCode,
    required this.zonePath,
    required this.water,
  });

  /// `ES-GA`, `AE-RK`.
  final String jurisdictionCode;

  /// The zone the fisher confirmed.
  final String zoneCode;

  /// The zone chain, widest first — `['ES-GA', 'rias-baixas', 'cambados']`.
  ///
  /// §7.3 step 2: a rule reaches the active zone when its zone is `NULL` — it
  /// covers the whole jurisdiction — or is any member of this chain. Resolved
  /// once, here, so no caller walks `parent_zone_id` a second time and gets a
  /// different answer.
  final List<String> zonePath;

  /// Which water the rules are being asked about.
  final WaterKind water;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationScope &&
          other.jurisdictionCode == jurisdictionCode &&
          other.zoneCode == zoneCode &&
          _samePath(other.zonePath) &&
          other.water == water;

  /// Element-wise, by hand.
  ///
  /// `listEquals` lives in `package:flutter/foundation.dart`, and this layer is
  /// pure Dart: `check_app_invariants.sh` check 7 fails a Flutter import here,
  /// because the domain is shared with a package that has no Flutter to import.
  bool _samePath(List<String> other) {
    if (other.length != zonePath.length) return false;
    for (var i = 0; i < zonePath.length; i++) {
      if (other[i] != zonePath[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(jurisdictionCode, zoneCode, Object.hashAll(zonePath), water);
}
