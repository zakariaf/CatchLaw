import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mounts [child] inside a real Lonja theme.
///
/// One place decides how a Lonja widget is mounted, so a test cannot
/// accidentally assert against a bare `ThemeData` — which would throw at
/// `LonjaTokens.of` and be read as a widget bug rather than as a harness bug.
///
/// [locale] reaches `LonjaType.of`, which selects the Arabic ramp on `ar` and
/// the Latin one otherwise, and reaches `GlobalWidgetsLocalizations`, which is
/// the only thing that flips direction.
Future<void> pumpLonja(
  WidgetTester tester,
  Widget child, {
  LonjaSkin skin = LonjaSkin.paper,
  bool gloved = false,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: resolveLonjaTheme(skin: skin, gloved: gloved),
      locale: locale,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const <Locale>[
        Locale('ar'),
        Locale('en'),
        Locale('es'),
        Locale('gl'),
        Locale('ca'),
        Locale('pt'),
        Locale('pt', 'BR'),
      ],
      home: Scaffold(body: Center(child: child)),
    ),
  );
  await tester.pump();
}
