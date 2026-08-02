/// Which of the shipped locales to render in.
///
/// Pure: no binding, no I/O, no `BuildContext`. That is what lets every case in
/// `SPEC.md` §11 be a row that runs in milliseconds, rather than a widget pump
/// per configuration.
library;

import 'package:flutter/widgets.dart' show Locale;

/// The locale to render in, given the stored override and what the device asks
/// for.
///
/// Four steps, in this order:
///
/// 1. [override], if it is one of [supported]. An override that names a locale
///    this build no longer ships — a `user.db` restored from an export that
///    predates D-3's removal of `ur` — falls through rather than bricking the
///    app.
/// 2. An exact tag match in [deviceLocales].
/// 3. A language-only match in [deviceLocales]. A `pt_PT` phone shares no exact
///    tag with anything shipped, and Portuguese is intelligible to that reader
///    where English is not.
/// 4. `en`.
///
/// **[deviceLocales] is the platform's ordered list, not its first entry.** A
/// phone set to `es_ES` with `gl` second is a real configuration for exactly
/// the user §11 names, and `deviceLocales.first` throws that away.
///
/// **Step 4 is `en` and not [supported] `.first`.** Flutter's own fallback is
/// the first supported locale, which `gen-l10n` emits alphabetically — so `ar`.
/// A German phone would launch the app right-to-left in Arabic, which looks
/// like a bug in the RTL code and is not.
Locale resolveLocale({
  required Locale? override,
  required List<Locale> deviceLocales,
  required List<Locale> supported,
}) {
  if (override != null && supported.contains(override)) return override;

  for (final device in deviceLocales) {
    for (final candidate in supported) {
      if (candidate == device) return candidate;
    }
  }
  for (final device in deviceLocales) {
    for (final candidate in supported) {
      if (candidate.languageCode == device.languageCode) return candidate;
    }
  }
  return const Locale('en');
}
