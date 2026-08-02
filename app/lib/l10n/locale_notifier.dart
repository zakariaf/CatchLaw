import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/l10n/locale_codec.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// The S14 language override, persisted in `user_profile.locale_override`.
///
/// `null` means **follow the device**, and it is stored as SQL `NULL`
/// (`SPEC.md` §7.2). `SPEC.md` §11 wants both behaviours at once: the locale
/// follows the system by default, and the override survives independently of it
/// — because a Galician-speaking mariscadora may be holding a Spanish-locale
/// phone, and §9.1's whole argument for shipping `gl` collapses if she cannot
/// pin it.
///
/// A stream and not a one-shot read, so a write in S14 reaches `MaterialApp`
/// without a restart. Nothing here is awaited before `runApp`: the notifier
/// starts in `AsyncLoading`, the first frame gets `locale: null` and follows
/// the device — which is the correct default anyway — and the only visible
/// consequence for an overriding user is a flip on frame one, which is not a
/// flip anybody sees.
final class LocaleNotifier extends StreamNotifier<Locale?> {
  @override
  Stream<Locale?> build() => ref
      .watch(settingsRepositoryProvider)
      .watchProfile()
      .map((UserProfile profile) => decodeLocale(profile.localeOverride))
      .distinct();

  /// Pins [locale], or clears the override when it is `null`.
  ///
  /// The single write path. A `StateProvider` was rejected for exactly this
  /// reason: the write has a persistence side effect, and a type with nowhere
  /// to put one puts it at the call site — which means at *some* call sites.
  ///
  /// Returns the repository's `Result` rather than swallowing it. The task file
  /// specifies `Future<void>`, but a `void` here would make a failed write
  /// silent: S14 would show the new language, the stream would never re-emit,
  /// and the next launch would be back in the old one with nothing to explain
  /// why. E05/T09's spine exists so a boundary failure is visible in the type.
  @useResult
  Future<Result<void>> setOverride(Locale? locale) =>
      ref.read(settingsRepositoryProvider).setLocaleOverride(encodeLocale(locale));
}

/// The pinned locale, or `null` to follow the device.
final StreamNotifierProvider<LocaleNotifier, Locale?> localeNotifierProvider =
    StreamNotifierProvider<LocaleNotifier, Locale?>(LocaleNotifier.new);
