import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/repositories/reference_repository.dart';
import 'package:catchlaw/data/repositories/settings_repository.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:rule_engine/rule_engine.dart' show Ok, Result;

/// The active place, re-resolved whenever the fisher changes it.
///
/// **A use case and not a repository method.** It joins `user.db` — which
/// remembers the two codes — with `reference.db`, which knows what those codes
/// mean and what nests inside what. The two repositories may never call each
/// other (`FLUTTER_GUIDE.md` §2.5 rule 3), and this is the join.
///
/// §4.4: switching zone re-evaluates instantly. That is why it is a stream: the
/// place is written once by S9 and every screen watching a verdict re-asks the
/// engine without a navigation event, a refresh control or a round trip.
final class WatchEvaluationScope {
  /// Joins [settings] with [reference].
  const WatchEvaluationScope({required this.settings, required this.reference});

  /// Where the two codes are remembered.
  final SettingsRepository settings;

  /// Where they are given meaning.
  final ReferenceRepository reference;

  /// The scope, or `null` until the fisher has told the app where he is.
  ///
  /// **Null is a real state and is not an error.** A new install has no place,
  /// and every screen that needs one shows S9 rather than a verdict computed
  /// against a jurisdiction nobody chose.
  Stream<EvaluationScope?> call() async* {
    await for (final UserProfile profile in settings.watchProfile()) {
      final String? jurisdictionCode = profile.activeJurisdiction;
      if (jurisdictionCode == null) {
        yield null;
        continue;
      }
      yield await _resolve(jurisdictionCode, profile.activeZoneCode);
    }
  }

  Future<EvaluationScope?> _resolve(String jurisdictionCode, String? zoneCode) async {
    final Result<List<Jurisdiction>> all = await reference.jurisdictions();
    if (all is! Ok<List<Jurisdiction>>) return null;

    Jurisdiction? jurisdiction;
    for (final Jurisdiction j in all.value) {
      if (j.code == jurisdictionCode) jurisdiction = j;
    }
    // A stored jurisdiction the pack no longer carries: a content update that
    // dropped it, or a user.db restored from an export that predates it. The
    // place is treated as unset rather than half-resolved, so the fisher is
    // asked again instead of being answered against a jurisdiction that is not
    // there.
    if (jurisdiction == null) return null;

    final Result<List<Zone>> zonesRead = await reference.zones(jurisdiction.id);
    final List<Zone> zones = zonesRead is Ok<List<Zone>> ? zonesRead.value : const <Zone>[];

    final Zone? zone = _zoneByCode(zones, zoneCode);
    return EvaluationScope(
      jurisdictionCode: jurisdiction.code,
      zoneCode: zone?.code ?? jurisdictionCode,
      zonePath: _pathTo(zone, zones, jurisdictionCode),
      // The zone's own water when it publishes one, because water type is a
      // property of the PLACE: a freshwater rule answered for a sea zone is a
      // wrong verdict, and neither the fisher nor the app gets to choose which
      // water a river is.
      water: zone?.waterType ?? WaterKind.both,
    );
  }

  Zone? _zoneByCode(List<Zone> zones, String? code) {
    if (code == null) return null;
    for (final z in zones) {
      if (z.code == code) return z;
    }
    return null;
  }

  /// The chain from the jurisdiction down to [zone], widest first.
  List<String> _pathTo(Zone? zone, List<Zone> zones, String jurisdictionCode) {
    final path = <String>[jurisdictionCode];
    if (zone == null) return path;

    // Walked from the leaf up and reversed, with a visited set: a pack whose
    // parent chain cycles would otherwise hang the app at the moment a fisher
    // picks a place, which is the least recoverable place to hang.
    final chain = <String>[];
    final seen = <int>{};
    Zone? current = zone;
    while (current != null && seen.add(current.id)) {
      chain.add(current.code);
      final int? parentId = current.parentZoneId;
      current = parentId == null ? null : _zoneById(zones, parentId);
    }
    return <String>[...path, ...chain.reversed];
  }

  Zone? _zoneById(List<Zone> zones, int id) {
    for (final z in zones) {
      if (z.id == id) return z;
    }
    return null;
  }
}
