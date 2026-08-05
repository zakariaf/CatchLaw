import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/palette_table.dart';

final Map<String, ThemeData Function({LonjaDensity density})> _builders =
    <String, ThemeData Function({LonjaDensity density})>{
      'paper': LonjaTheme.paper,
      'night': LonjaTheme.night,
      'sunlight': LonjaTheme.sunlight,
    };

LonjaTokens _tokensOf(ThemeData theme) => theme.extension<LonjaTokens>()!;

void main() {
  test('LonjaDensity.glove raises the tap target to 56 dp', () {
    // SPEC.md §4.9's headline number; the whole task is downstream of it.
    expect(LonjaDensity.glove.tapMin, 56);
  });

  test('LonjaDensity.glove raises the separation to 12 dp', () {
    // Separation is what prevents the adjacent-target mis-tap. §4.9 states it
    // beside the size, and it is the half people drop.
    //
    // 12 and not 8: the mockup's glove screen names both numbers in one
    // sentence — "no two free-standing targets sit closer than 12 dp, against
    // a floor of 8" — and its `.chips`, `.strip` and `.btn-row` all take 12. A
    // density authored on the floor meets §4.9 and misses the drawing.
    expect(LonjaDensity.glove.tapGap, LonjaSpace.s3);
    expect(LonjaDensity.glove.tapGap, 12);
  });

  test('LonjaDensity.glove sizes each target class separately', () {
    // §13 of the mockup grows five classes, not one number: a chip and a
    // navigation cell are hit with different intent, and a single tapMin
    // flattens all five onto the smallest of them. These are its figures.
    expect(LonjaDensity.glove.tapMin, 56, reason: 'chips sit on the floor');
    expect(LonjaDensity.glove.actionHeight, 66);
    expect(LonjaDensity.glove.entryHeight, 72);
    expect(LonjaDensity.glove.navHeight, 84);
    expect(LonjaDensity.glove.tileWidth, 126);
    expect(LonjaDensity.glove.tileHeight, 118);
  });

  test('LonjaDensity.glove raises every target class above its standard size', () {
    // The direction of the whole axis, asserted over the set rather than one
    // class at a time: glove mode is a DENSITY, so a class that failed to grow
    // is a class somebody forgot, not a design decision.
    expect(LonjaDensity.glove.tapMin, greaterThan(LonjaDensity.standard.tapMin));
    expect(LonjaDensity.glove.tapGap, greaterThan(LonjaDensity.standard.tapGap));
    expect(LonjaDensity.glove.actionHeight, greaterThan(LonjaDensity.standard.actionHeight));
    expect(LonjaDensity.glove.entryHeight, greaterThan(LonjaDensity.standard.entryHeight));
    expect(LonjaDensity.glove.navHeight, greaterThan(LonjaDensity.standard.navHeight));
    expect(LonjaDensity.glove.tileWidth, greaterThan(LonjaDensity.standard.tileWidth));
    expect(LonjaDensity.glove.tileHeight, greaterThan(LonjaDensity.standard.tileHeight));
  });

  test('LonjaDensity.glove orders the target classes chip, action, entry, navigation', () {
    // The ladder the mockup draws, and the reason there are five numbers: a
    // chip is read and confirmed, an action is aimed at, the entry line is
    // written in, and the navigation strip is hit blind with the phone already
    // moving. Sizes follow intent, in that order.
    expect(LonjaDensity.glove.actionHeight, greaterThan(LonjaDensity.glove.tapMin));
    expect(LonjaDensity.glove.entryHeight, greaterThan(LonjaDensity.glove.actionHeight));
    expect(LonjaDensity.glove.navHeight, greaterThan(LonjaDensity.glove.entryHeight));
  });

  test('LonjaDensity.glove raises the row height to 72 dp', () {
    // §4.9's "done looks like" names species tiles, which are rows, not buttons.
    expect(LonjaDensity.glove.rowHeight, 72);
  });

  test('LonjaDensity.glove extends the hit box by 4 dp', () {
    // The hit box grows without the ink moving: a layout that reflows on a
    // settings toggle looks broken.
    expect(LonjaDensity.glove.hitSlop, 4);
  });

  test('LonjaDensity.glove widens the gutter to 24 dp', () {
    // And it stays on the 4 pt spine, so it can be scaled.
    expect(LonjaDensity.glove.gutter, LonjaSpace.s5);
  });

  test('LonjaDensity.standard clears the 48 dp target floor', () {
    // SPEC.md §13. Lonja sits above accessibility-as-code's 44 dp deliberately
    // and must not drift below the spec's own number.
    expect(LonjaDensity.standard.tapMin, greaterThanOrEqualTo(48));
  });

  test('glove - every target in the glove set is at least 56 dp and every gap at least 8 dp', () {
    // §4.9 as one assertion over the whole set, so a field added later cannot
    // quietly land below the floor.
    expect(LonjaDensity.glove.tapMin, greaterThanOrEqualTo(56));
    expect(LonjaDensity.glove.rowHeight, greaterThanOrEqualTo(56));
    expect(LonjaDensity.glove.actionHeight, greaterThanOrEqualTo(56));
    expect(LonjaDensity.glove.entryHeight, greaterThanOrEqualTo(56));
    expect(LonjaDensity.glove.navHeight, greaterThanOrEqualTo(56));
    expect(LonjaDensity.glove.tileWidth, greaterThanOrEqualTo(56));
    expect(LonjaDensity.glove.tileHeight, greaterThanOrEqualTo(56));
    expect(LonjaDensity.glove.tapGap, greaterThanOrEqualTo(8));
    expect(LonjaDensity.glove.gutter, greaterThanOrEqualTo(8));
  });

  _builders.forEach((String name, ThemeData Function({LonjaDensity density}) build) {
    test('glove - LonjaTheme.$name(density: glove) carries the glove density', () {
      // The crossing must actually reach the extension rather than stopping at
      // the builder's signature.
      expect(_tokensOf(build(density: LonjaDensity.glove)).density, LonjaDensity.glove);
    });

    test('glove - LonjaTheme.$name(density: glove) changes no colour slot', () {
      // Density is geometry only. This equality also proves T02's narrowed
      // copyWith is sufficient: nothing else CAN differ.
      final LonjaTokens standard = _tokensOf(build());
      final LonjaTokens gloved = _tokensOf(build(density: LonjaDensity.glove));
      expect(standard.copyWith(density: LonjaDensity.glove), gloved);
    });
  });

  for (final LonjaSkin skin in LonjaSkin.values) {
    for (final gloved in <bool>[false, true]) {
      test('resolveLonjaTheme(skin: ${skin.name}, gloved: $gloved) binds the ${skin.name} palette '
          'at ${gloved ? 'glove' : 'standard'} density', () {
        // The one crossing point in the app. A switch that drops a case is a
        // screen that silently renders paper.
        final LonjaTokens tokens = _tokensOf(resolveLonjaTheme(skin: skin, gloved: gloved));
        final LonjaTokens palette = kPalettesByName[skin.name]!;
        expect(tokens.surface, palette.surface);
        expect(tokens.onSurface, palette.onSurface);
        expect(tokens.density, gloved ? LonjaDensity.glove : LonjaDensity.standard);
      });
    }
  }

  test('LonjaSkin declares exactly three values', () {
    // There is no fourth theme and no runtime-generated theme; a fourth value
    // is how the density axis gets folded back in.
    expect(LonjaSkin.values, hasLength(3));
  });

  test('LonjaSkin declares no value whose name mentions a glove', () {
    // The property check 9 of check_lonja_tokens.sh greps for — the one check
    // with no /theme/ exemption and no escape hatch — asserted where a
    // developer will see it fail first.
    for (final LonjaSkin skin in LonjaSkin.values) {
      expect(skin.name.toLowerCase(), isNot(contains('glove')));
    }
  });

  test('LonjaTheme.paper() defaults to the standard density', () {
    // The default must be what a first launch gets, before any setting exists
    // to restore.
    expect(_tokensOf(LonjaTheme.paper()).density, LonjaDensity.standard);
  });

  test('glove - LonjaTokens.lerp snaps from standard to glove at t 0.5', () {
    // T02 proved the snap with probes; this proves it for the pair that
    // actually animates when the setting is toggled.
    const LonjaTokens standard = LonjaPalettes.paper;
    final LonjaTokens gloved = standard.copyWith(density: LonjaDensity.glove);
    expect(standard.lerp(gloved, 0.49).density, LonjaDensity.standard);
    expect(standard.lerp(gloved, 0.5).density, LonjaDensity.glove);
  });
}
