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
      // Read per emission rather than carried on the profile: the choice lives
      // in `app_meta` because a new `user_profile` column would be a schema
      // change, and a schema change is irreversible after the first shipped
      // pack.
      final Result<WaterKind?> chosen = await settings.readActiveWater();
      yield await _resolve(
        jurisdictionCode,
        profile.activeZoneCode,
        chosen is Ok<WaterKind?> ? chosen.value : null,
      );
    }
  }

  /// The water the rules are asked about.
  ///
  /// Total, and with the stored choice reaching only the one branch where the
  /// place leaves the question open.
  WaterKind _waterFor(Zone? zone, WaterKind? chosen) => switch (zone?.waterType) {
    WaterKind.salt => WaterKind.salt,
    WaterKind.fresh => WaterKind.fresh,
    WaterKind.both => chosen ?? WaterKind.both,
    // No zone row, or a `water_type` this build does not recognise. `both`
    // filters nothing, which is the honest answer: the app has not been told
    // which water, so it withholds no rule on that ground.
    WaterKind.unknown || null => chosen ?? WaterKind.both,
  };

  Future<EvaluationScope?> _resolve(
    String jurisdictionCode,
    String? zoneCode,
    WaterKind? profileWater,
  ) async {
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
      // **The zone's own water decides, and the fisher only chooses where the
      // zone itself says `both`.** Water type is a property of the PLACE: a
      // freshwater rule answered for a sea zone is a wrong verdict, and neither
      // he nor the app gets to say which water a river is. Where the zone
      // genuinely covers both, the stored choice is his — and until he has made
      // one the scope carries `both`, which the engine reads as "no water
      // filter" rather than as a guess.
      water: _waterFor(zone, profileWater),
      authorityKey: jurisdiction.authorityKey,
      defaultLocale: jurisdiction.defaultLocale,
      packVersion: jurisdiction.contentVersion,
      checkedOn: jurisdiction.checkedOn,
      packValidUntil: jurisdiction.validUntil,
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
