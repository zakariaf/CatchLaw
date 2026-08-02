import 'package:catchlaw/app.dart';
import 'package:catchlaw/theme/lonja_faces.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<LonjaTypeScale> _scaleFor(WidgetTester tester, Locale locale) async {
  late LonjaTypeScale observed;
  await tester.pumpWidget(
    ProviderScope(
      child: CatchlawApp(
        locale: locale,
        home: Builder(
          builder: (BuildContext context) {
            observed = LonjaType.of(context);
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
  testWidgets('ar - LonjaType.of returns the Arabic scale', (WidgetTester tester) async {
    // Read at of(context) time rather than baked into the ThemeData, because
    // E06/T06 lets the locale change live and a scale captured at theme
    // construction would keep the Latin serif through an Arabic screen.
    final LonjaTypeScale scale = await _scaleFor(tester, const Locale('ar'));
    expect(scale.legal.fontFamilyFallback, LonjaFaces.arabic);
  });

  // The five Latin locales share the ramp. `ca`, not `fr`: D-3 is the
  // authority, and lonja-typography's own reference file still lists `fr`,
  // which appears nowhere in SPEC.md.
  for (final locale in const <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('gl'),
    Locale('ca'),
    Locale('pt', 'BR'),
  ]) {
    final String tag = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    testWidgets('LonjaType.of returns the Latin scale for $tag', (WidgetTester tester) async {
      final LonjaTypeScale scale = await _scaleFor(tester, locale);
      expect(scale.legal.fontFamilyFallback, LonjaFaces.serif);
    });
  }

  testWidgets('LonjaType.of throws an assertion when no LonjaType is attached', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(),
        home: Builder(
          builder: (BuildContext context) {
            expect(() => LonjaType.of(context), throwsAssertionError);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  test('LonjaTheme.sunlight() floors every step at w500', () {
    final LonjaType type = LonjaTheme.sunlight().extension<LonjaType>()!;
    for (final style in <TextStyle>[...type.latin.steps, ...type.arabic.steps]) {
      expect(style.fontWeight!.value, greaterThanOrEqualTo(FontWeight.w500.value));
    }
  });

  test('LonjaTheme.paper() does not floor the weight', () {
    // legal is w400 on paper and must stay there: raising it everywhere would
    // make the booklet shout indoors.
    expect(LonjaTheme.paper().extension<LonjaType>()!.latin.legal.fontWeight, FontWeight.w400);
  });

  test('LonjaType.lerp snaps rather than interpolating', () {
    // A half-interpolated ramp is a font size no step defines, and a line that
    // reflows mid-animation reads as a rendering fault rather than as a theme
    // change.
    final LonjaType paper = LonjaTheme.paper().extension<LonjaType>()!;
    final LonjaType sun = LonjaTheme.sunlight().extension<LonjaType>()!;
    expect(paper.lerp(sun, 0.49), paper);
    expect(paper.lerp(sun, 0.5), sun);
  });
}
