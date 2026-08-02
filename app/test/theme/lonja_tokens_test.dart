import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/token_fixtures.dart';

void main() {
  // Loop-generated: the field name is interpolated, so `--plain-name
  // 'onSurfaceFaint'` selects one row and a missing field names itself.
  for (final TokenField field in kTokenFields) {
    test('LonjaTokens == returns false when ${field.name} alone differs', () {
      expect(kTokensProbe, isNot(field.mutate(kTokensProbe)));
    });
  }

  test('LonjaTokens == returns true for two separately constructed identical token sets', () {
    // Value equality, not identity: the snapshot has to survive being rebuilt
    // each frame.
    expect(tokensWith(kTokensProbe), kTokensProbe);
  });

  test('LonjaTokens.hashCode is equal for two identical token sets', () {
    // An == without a matching hashCode breaks every Set and Map the framework
    // puts a theme in.
    expect(tokensWith(kTokensProbe).hashCode, kTokensProbe.hashCode);
  });

  testWidgets('LonjaTokens.of returns the extension attached to the ThemeData', (
    WidgetTester tester,
  ) async {
    late LonjaTokens read;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const <ThemeExtension<dynamic>>[kTokensProbe]),
        home: Builder(
          builder: (BuildContext context) {
            read = LonjaTokens.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(identical(read, kTokensProbe), isTrue);
  });

  testWidgets('LonjaTokens.of throws an assertion when no LonjaTokens is attached', (
    WidgetTester tester,
  ) async {
    // The alternative is a silent fourth palette that no golden lane ever
    // rendered — the screen looks fine, in a theme nobody authored. The assert
    // must fire in tests, which is where a missing extension gets introduced.
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(),
        home: Builder(
          builder: (BuildContext context) {
            expect(() => LonjaTokens.of(context), throwsAssertionError);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  test('LonjaTokens.copyWith replaces the density and leaves every colour slot', () {
    final LonjaTokens dense = kTokensProbe.copyWith(density: kDensityProbe);
    expect(dense.density, kDensityProbe);
    expect(dense.copyWith(density: kTokensProbe.density), kTokensProbe);
  });

  test('LonjaTokens.copyWith returns an equal token set when given no argument', () {
    // There is no other lever: a caller cannot mint a palette by accident.
    expect(kTokensProbe.copyWith(), kTokensProbe);
  });

  test('LonjaTokens.lerp returns the receiver when other is not a LonjaTokens', () {
    // ThemeExtension.lerp is typed on the base class, and the framework does
    // pass other extensions through it.
    expect(identical(kTokensProbe.lerp(null, 0.5), kTokensProbe), isTrue);
  });

  test('LonjaTokens.lerp interpolates surface halfway at t 0.5', () {
    final LonjaTokens mid = kTokensProbe.lerp(kTokensProbeB, 0.5);
    expect(mid.surface, Color.lerp(kTokensProbe.surface, kTokensProbeB.surface, 0.5));
  });

  test('LonjaTokens.lerp keeps the receiver density at t 0.49', () {
    // A half-interpolated tap target is legal in neither mode, and a hit box
    // that changes size mid-animation is a mis-tap waiting for a wet hand.
    final LonjaTokens mid = kTokensProbe.lerp(kTokensProbeB, 0.49);
    expect(mid.density, kTokensProbe.density);
  });

  test('LonjaTokens.lerp takes the other density at t 0.5', () {
    // The snap point is defined, not incidental.
    final LonjaTokens mid = kTokensProbe.lerp(kTokensProbeB, 0.5);
    expect(mid.density, kTokensProbeB.density);
  });

  test('LonjaTokens is const-constructible and canonicalised', () {
    // FLUTTER_GUIDE.md §8.2: the const short-circuit is why a token snapshot is
    // free to pass down a screen.
    expect(identical(kTokensProbe, kTokensProbe), isTrue);
    expect(
      identical(
        const LonjaTokens(
          surface: Color(0xFF010101),
          surfaceSunk: Color(0xFF020202),
          onSurface: Color(0xFF030303),
          onSurfaceMuted: Color(0xFF040404),
          onSurfaceFaint: Color(0xFF050505),
          hairline: Color(0xFF060606),
          hairlineStrong: Color(0xFF070707),
          ruleBearing: Color(0xFF080808),
          accent: Color(0xFF090909),
          onAccent: Color(0xFF0A0A0A),
          verdictPass: Color(0xFF0B0B0B),
          verdictFail: Color(0xFF0C0C0C),
          verdictWarn: Color(0xFF0D0D0D),
          density: LonjaDensity.standard,
        ),
        kTokensProbe,
      ),
      isTrue,
    );
  });
}
