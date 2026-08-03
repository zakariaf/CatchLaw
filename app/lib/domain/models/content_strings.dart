import 'package:catchlaw/domain/models/content_string_missing.dart';
import 'package:meta/meta.dart';

/// Tier-two words, already resolved for one locale.
///
/// `ContentStringResolver` is asynchronous because it reads `reference.db`, and
/// a verdict sentence has to be assembled synchronously — the presenter is a
/// pure function so six locales cost six calls rather than six widget pumps.
/// This is the seam between the two: whoever owns the screen resolves the keys
/// it needs once, and hands the presenter a snapshot.
///
/// **A missing key throws.** `SPEC.md` §9.2 forbids rendering the key and
/// forbids rendering an empty string, and the resolver has already run every
/// step of the fallback chain by the time a value lands here — so an absent key
/// means a `reference.db` that violates the §8 build assertion, not a gap this
/// class can paper over. [ContentStringMissing] carries the key, which is the
/// only diagnostic anybody will ever get: there is no network and no crash
/// upload.
@immutable
class ContentStrings {
  /// Wraps an already-resolved [values] map.
  const ContentStrings(this._values);

  final Map<String, String> _values;

  /// The resolved value for [key].
  String operator [](String key) => _values[key] ?? (throw ContentStringMissing(key));
}
