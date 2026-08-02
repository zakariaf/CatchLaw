import 'package:catchlaw/app.dart';
import 'package:catchlaw/theme/lonja_primitives.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/palette_table.dart';

final Map<String, ThemeData Function()> _builders = <String, ThemeData Function()>{
  'paper': LonjaTheme.paper,
  'night': LonjaTheme.night,
  'sunlight': LonjaTheme.sunlight,
};

Future<Color> _pumpAndReadSurface(WidgetTester tester, Brightness platform) async {
  tester.platformDispatcher.platformBrightnessTestValue = platform;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  late Color observed;
  await tester.pumpWidget(
    ProviderScope(
      child: CatchlawApp(
        locale: const Locale('en'),
        home: Builder(
          builder: (BuildContext context) {
            observed = LonjaTokens.of(context).surface;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return observed;
}

void main() {
  _builders.forEach((String name, ThemeData Function() build) {
    final LonjaTokens palette = kPalettesByName[name]!;

    test('LonjaTheme.$name() attaches its palette as a LonjaTokens extension', () {
      // Without this the asserting of(context) from T02 throws on every screen.
      //
      // Value equality, not identity: T04's density parameter means the builder
      // returns `palette.copyWith(density: …)`, which is a new instance even
      // when the density is unchanged. What is being claimed is that the
      // attached tokens ARE the palette, and that is what == says.
      expect(build().extension<LonjaTokens>(), palette);
    });

    test('LonjaTheme.$name() paints the scaffold with the surface slot', () {
      // The ground the whole document sits on. Material's default is not one of
      // our three.
      expect(build().scaffoldBackgroundColor, palette.surface);
    });

    test('LonjaTheme.$name() binds colorScheme.primary to the accent slot', () {
      // The fromSeed guard: a generated scheme cannot reproduce harbour30
      // exactly, so this equality is one a seed can never satisfy by accident.
      expect(build().colorScheme.primary, palette.accent);
    });

    test('LonjaTheme.$name() binds colorScheme.error to the verdictFail slot', () {
      // Material error surfaces underneath us must not introduce a fourth red.
      expect(build().colorScheme.error, palette.verdictFail);
    });

    test('LonjaTheme.$name() sets a fully transparent shadowColor', () {
      // Paper does not float, and the cheapest way a shadow appears is a
      // Material default nobody overrode.
      expect(build().shadowColor.a, 0);
    });
  });

  test('LonjaTheme.night() reports Brightness.dark', () {
    // Platform chrome, cursor colour and system overlays read this.
    expect(LonjaTheme.night().brightness, Brightness.dark);
  });

  test('LonjaTheme.sunlight() reports Brightness.light', () {
    // Sunlight is a LIGHT theme with a white ground; reporting dark would
    // invert the system UI over it.
    expect(LonjaTheme.sunlight().brightness, Brightness.light);
  });

  testWidgets('CatchlawApp paints the paper surface when the platform brightness is light', (
    WidgetTester tester,
  ) async {
    // SPEC.md §11's dark-mode support, proved at the wiring rather than in
    // prose.
    expect(await _pumpAndReadSurface(tester, Brightness.light), LonjaPrimitives.paper90);
  });

  testWidgets('CatchlawApp paints the night surface when the platform brightness is dark', (
    WidgetTester tester,
  ) async {
    expect(await _pumpAndReadSurface(tester, Brightness.dark), LonjaPrimitives.ink07);
  });
}
