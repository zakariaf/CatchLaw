import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';

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
/// including E09's ruler, which must not mirror.
class CatchlawApp extends StatelessWidget {
  /// Creates the application root.
  const CatchlawApp({super.key, this.locale, this.home});

  /// The locale to pin, or `null` to follow the device.
  ///
  /// E06/T06 replaces the `null` with the override persisted in
  /// `user_profile.locale_override`; until then the device decides and a test
  /// pins one directly.
  final Locale? locale;

  /// What to show inside the localised scope.
  ///
  /// A seam for tests, which need a `BuildContext` *below* `MaterialApp` to
  /// observe what the locale resolved to. E12 supplies the navigation shell.
  final Widget? home;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (BuildContext context) => AppLocalizations.of(context).appTitle,
    locale: locale,
    // gen-l10n emits this list already carrying the three Global delegates, so
    // a hand-written copy is one that drifts.
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home ?? const SizedBox.shrink(),
  );
}
