import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/l10n/locale_notifier.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one place app code calls [applyNumeralSystem].
///
/// The naive reading of the order-dependence in `numeral_system.dart` is "read
/// `user_profile` before `runApp`" — but that is an `await` on the launch path,
/// which `catchlaw-conventions-index` rule 8 forbids and which `SPEC.md` §13
/// prices against a 1.2 s cold-start budget that would be spent on a black
/// screen. So `main()` applies the default synchronously and this notifier
/// applies the stored value when `user_profile` resolves, live, with no
/// restart.
///
/// It emits the system it applied rather than `void`, so anything that renders
/// a number can watch it and rebuild after the swap. A widget that formatted
/// without watching would keep whatever digits were current when it last built,
/// which is the same order-dependence one level up.
final class NumeralSystemNotifier extends StreamNotifier<NumeralSystem> {
  @override
  Stream<NumeralSystem> build() {
    // `auto` means "whatever CLDR says for the RESOLVED locale", so a locale
    // change has to re-evaluate it. Declared as a Riverpod dependency rather
    // than by calling applyNumeralSystem from LocaleNotifier: one function,
    // one caller. Today every shipped locale is Latin, so a missing edge here
    // would be invisible — which is exactly why it is stated rather than
    // relied upon.
    ref.watch(localeNotifierProvider);

    return ref
        .watch(settingsRepositoryProvider)
        .watchProfile()
        .map((UserProfile profile) => profile.numeralSystem)
        .distinct()
        .map((NumeralSystem system) {
          applyNumeralSystem(system);
          return system;
        });
  }
}

/// The numeral system in force, applied as a side effect of resolving.
final StreamNotifierProvider<NumeralSystemNotifier, NumeralSystem> numeralSystemProvider =
    StreamNotifierProvider<NumeralSystemNotifier, NumeralSystem>(NumeralSystemNotifier.new);
