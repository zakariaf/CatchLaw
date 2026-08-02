import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// The tier-two string table, one key at a time.
///
/// Tier 1 is UI chrome and goes through `AppLocalizations`; tier 2 is bundled
/// content — species and family names, measurement definitions, rule notes,
/// gear names, glossary entries, zone and jurisdiction names — and goes through
/// here (`SPEC.md` §9.2). The line matters because the two have different
/// authors, different review, and different failure modes.
///
/// **One method, and it returns every locale at once.** The §9.2 fallback chain
/// is a decision about which of those values to render, and it belongs to
/// `ContentStringResolver`. A repository that took a locale and applied one
/// step of the chain would give the caller no way to tell a resolved Galician
/// string from an English one silently substituted for it.
abstract interface class ContentStringRepository {
  /// Every locale row for [key], keyed by locale.
  ///
  /// An unknown key is an empty map, not a failure: whether an absent key is a
  /// defect depends on what was asked for, and only the resolver knows.
  @useResult
  Future<Result<Map<String, String>>> valuesFor(String key);
}
