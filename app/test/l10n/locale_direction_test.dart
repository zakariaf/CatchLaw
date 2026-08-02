import 'package:catchlaw/app.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps the real app root at [locale] and reports the direction a descendant
/// inherits.
///
/// Reading it from a `Builder` under the app is the point: direction must be a
/// consequence of the resolved locale reaching `GlobalWidgetsLocalizations`,
/// and a test that inspected source instead would pass against an app that
/// hardcodes it.
Future<TextDirection> _pumpAndReadDirection(WidgetTester tester, Locale locale) async {
  late TextDirection observed;
  await tester.pumpWidget(
    CatchlawApp(
      locale: locale,
      home: Builder(
        builder: (BuildContext context) {
          observed = Directionality.of(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pump();
  return observed;
}

void main() {
  testWidgets('CatchlawApp resolves TextDirection.rtl when the locale is ar', (
    WidgetTester tester,
  ) async {
    expect(await _pumpAndReadDirection(tester, const Locale('ar')), TextDirection.rtl);
  });

  // Loop-generated: the parameter is interpolated, per CONVENTIONS.md §5.
  for (final locale in const <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('gl'),
    Locale('ca'),
    Locale('pt', 'BR'),
  ]) {
    final String code = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    testWidgets('CatchlawApp resolves TextDirection.ltr when the locale is $code', (
      WidgetTester tester,
    ) async {
      expect(await _pumpAndReadDirection(tester, locale), TextDirection.ltr);
    });
  }

  testWidgets('CatchlawApp flips direction when the locale changes from en to ar', (
    WidgetTester tester,
  ) async {
    expect(await _pumpAndReadDirection(tester, const Locale('en')), TextDirection.ltr);
    expect(await _pumpAndReadDirection(tester, const Locale('ar')), TextDirection.rtl);
  });

  testWidgets('ar - AppLocalizations.settingsLanguage differs from the en value', (
    WidgetTester tester,
  ) async {
    final AppLocalizations ar = await AppLocalizations.delegate.load(const Locale('ar'));
    final AppLocalizations en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(ar.settingsLanguage, isNot(en.settingsLanguage));
  });
}
