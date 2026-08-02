import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/resolve_locale.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The real generated list, not a hand-kept copy.
///
/// A copy would let this file keep passing after D-3 or D-18 changed what the
/// app actually offers, which is the one thing these rows exist to prevent.
const List<Locale> _supported = AppLocalizations.supportedLocales;

Locale _resolve(List<Locale> device, {Locale? override}) =>
    resolveLocale(override: override, deviceLocales: device, supported: _supported);

void main() {
  test('resolveLocale returns the device locale when there is no override', () {
    expect(_resolve(const <Locale>[Locale('es', 'ES')]), const Locale('es'));
  });

  test('resolveLocale returns gl when the override is gl and the device is es_ES', () {
    // SPEC.md §11, verbatim: "a Galician-speaking user may run a Spanish-locale
    // phone". §9.1's entire argument for shipping gl depends on this row.
    expect(
      _resolve(const <Locale>[Locale('es', 'ES')], override: const Locale('gl')),
      const Locale('gl'),
    );
  });

  test('resolveLocale keeps the override when the device locale changes from es to ar', () {
    // "Persists independently" means independently of CHANGES, not only of the
    // initial value.
    expect(
      _resolve(const <Locale>[Locale('es', 'ES')], override: const Locale('gl')),
      const Locale('gl'),
    );
    expect(
      _resolve(const <Locale>[Locale('ar', 'AE')], override: const Locale('gl')),
      const Locale('gl'),
    );
  });

  test('resolveLocale returns the second device locale when the first is unsupported', () {
    // The ordered list is user intent. `deviceLocales.first` discards it, and
    // the user it discards is exactly the one §11 names.
    expect(_resolve(const <Locale>[Locale('de', 'DE'), Locale('gl', 'ES')]), const Locale('gl'));
  });

  test('resolveLocale returns en when no device locale is supported', () {
    // Flutter's own default is supportedLocales.first, which gen-l10n emits in
    // alphabetical order — so `ar`. A German phone would launch right-to-left
    // in Arabic, which looks like a bug in the RTL code and is not.
    expect(_resolve(const <Locale>[Locale('de', 'DE')]), const Locale('en'));
  });

  test('resolveLocale returns the pt base when the device locale is pt_PT', () {
    // Language-only match. Brazilian Portuguese is intelligible to a pt_PT
    // reader and English is not — and D-18's base file is what a Portuguese
    // device with no matching region should land on. It carries the same text.
    expect(_resolve(const <Locale>[Locale('pt', 'PT')]), const Locale('pt'));
  });

  test('resolveLocale returns pt_BR when the device locale is pt_BR', () {
    expect(_resolve(const <Locale>[Locale('pt', 'BR')]), const Locale('pt', 'BR'));
  });

  test('resolveLocale returns ar when the device locale is ar_AE', () {
    // Khalid's device tag. intl has no ar_AE entry either (E06/T04's finding
    // point 3), and the two fallbacks must agree or the digits and the words
    // come from different locales.
    expect(_resolve(const <Locale>[Locale('ar', 'AE')]), const Locale('ar'));
  });

  test('resolveLocale returns en when the override names an unsupported locale', () {
    // A user.db restored from an export predating D-3 can still name `ur`.
    // Importing one must not brick the app.
    expect(
      _resolve(const <Locale>[Locale('de', 'DE')], override: const Locale('ur')),
      const Locale('en'),
    );
  });

  test('resolveLocale returns the override even when it also appears in the device list', () {
    // Idempotence, and it pins the precedence order so a later refactor cannot
    // invert it without a red row.
    expect(
      _resolve(const <Locale>[Locale('gl', 'ES')], override: const Locale('gl')),
      const Locale('gl'),
    );
  });

  test('resolveLocale returns en when the device list is empty', () {
    // A platform that reports nothing is not a platform that wants Arabic.
    expect(_resolve(const <Locale>[]), const Locale('en'));
  });
}
