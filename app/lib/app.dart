import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/locale_notifier.dart';
import 'package:catchlaw/l10n/numeral_system_notifier.dart';
import 'package:catchlaw/l10n/resolve_locale.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/check/check_screen.dart';
import 'package:catchlaw/ui/core/ui/app_shell.dart';
import 'package:catchlaw/ui/log/widgets/today_screen.dart';
import 'package:catchlaw/ui/log/widgets/trips_screen.dart';
import 'package:catchlaw/ui/reference/widgets/reference_screen.dart';
import 'package:catchlaw/ui/settings/widgets/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The application root.
///
/// Carries no theme, no colour and no route yet: the Lonja theme lives at
/// `app/lib/theme/` and arrives in E07 (D-2), and the navigation shell in E12.
///
/// **No `Directionality` is constructed here or anywhere under `app/lib`.**
/// Direction is a consequence of the resolved locale reaching
/// [GlobalWidgetsLocalizations]: `ar` is the one RTL language this product
/// ships (D-3). A root `Directionality(TextDirection.rtl)` would make every
/// physical-side inset *look* correct in Arabic and break any LTR island —
/// including E09's ruler, which must not mirror. `no_directional_geometry.sh`
/// enforces the construct's absence; E06/T01's rows prove the behaviour by
/// pumping `ar` and `en`.
class CatchlawApp extends ConsumerWidget {
  /// Creates the application root.
  const CatchlawApp({super.key, this.locale, this.home});

  /// A locale to pin regardless of state, for tests that are about direction
  /// rather than about persistence.
  ///
  /// Production leaves this `null` and the stored override decides.
  final Locale? locale;

  /// What to show inside the localised scope.
  ///
  /// A seam for tests, which need a `BuildContext` *below* `MaterialApp` to
  /// observe what the locale resolved to. E12 supplies the navigation shell.
  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched, not read: the swap must happen and a rebuild must follow it, or
    // a screen renders the digits of whenever it last built (E06/T04).
    ref.watch(numeralSystemProvider);

    // The two flags a fisher can set in S14, READ here. They were written to
    // user.db from the first release and consumed by nothing: `theme:` was a
    // bare `LonjaTheme.paper()`, so turning sunlight on changed a row in a
    // database and not one pixel on the screen. A setting that saves and does
    // nothing is worse than a setting that is absent, because he now believes
    // the screen is as legible as it gets.
    //
    // `.value` and not `.requireValue`: the first frame runs before the stream
    // has emitted, and rule 8 forbids awaiting anything before `runApp`. The
    // defaults here are the same defaults `UserProfile` declares, so the frame
    // before the first emission is identical to the frame after it for a fisher
    // who has changed nothing.
    final AsyncValue<UserProfile> profile = ref.watch(settingsProfileProvider);
    final bool sunlight = profile.value?.sunlightMode ?? false;
    final LonjaDensity density = (profile.value?.gloveMode ?? false)
        ? LonjaDensity.glove
        : LonjaDensity.standard;

    return MaterialApp(
      onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appTitle,
      // SPEC.md §11 "Both": the booklet indoors and the same booklet under a
      // deck lamp. Sunlight is a THIRD theme rather than a variant of either,
      // and it is reached by a control in S14 (E16) and by a long-press on the
      // result (E10) — not by the platform, which has no signal for 100 000 lux.
      // Sunlight is a THIRD skin, not a variant of either, so it replaces both
      // slots — a fisher who turns it on at 05:40 must not lose it when the
      // platform flips to dark at sunrise.
      theme: sunlight ? LonjaTheme.sunlight(density: density) : LonjaTheme.paper(density: density),
      darkTheme: sunlight
          ? LonjaTheme.sunlight(density: density)
          : LonjaTheme.night(density: density),
      locale: locale ?? ref.watch(localeNotifierProvider).value,
      // gen-l10n emits this list already carrying the three Global delegates, so
      // a hand-written copy is one that drifts.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // The platform's ORDERED list, not its first entry: a phone set to es_ES
      // with gl second is a real configuration, and Flutter's own fallback for
      // no match is supportedLocales.first — which gen-l10n emits
      // alphabetically, so a German phone would launch in Arabic.
      localeListResolutionCallback: (List<Locale>? deviceLocales, Iterable<Locale> supported) =>
          resolveLocale(
            override: locale ?? ref.read(localeNotifierProvider).value,
            deviceLocales: deviceLocales ?? const <Locale>[],
            supported: supported.toList(),
          ),
      // The front door, at last. E01 through E11 built an engine, a database,
      // six locales, a theme and five screens behind a `SizedBox.shrink()`;
      // this is the line that lets a fisher reach any of it.
      home:
          home ??
          const AppShell(
            check: CheckScreen(),
            today: TodayScreen(),
            trips: TripsScreen(),
            reference: ReferenceScreen(),
            settings: SettingsScreen(),
          ),
    );
  }
}
