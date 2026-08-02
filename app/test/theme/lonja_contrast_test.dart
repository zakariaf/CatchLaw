import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/colour_math.dart';
import '../../testing/theme/palette_table.dart';

void main() {
  // Every ratio is COMPUTED from the WCAG formula and compared with the
  // published figure. A nudged hex changes a ratio silently otherwise.
  for (final ContrastRow row in kContrastTable) {
    final LonjaTokens palette = kPalettesByName[row.theme]!;
    final Color ink = slotOf(palette, row.slot);

    test('LonjaPalettes.${row.theme} renders ${row.slot} at ${row.vsSurface}:1 on its surface', () {
      expect(contrastRatio(ink, palette.surface), closeTo(row.vsSurface, 0.005));
    });

    test(
      'LonjaPalettes.${row.theme} renders ${row.slot} at ${row.vsSurfaceSunk}:1 on sunk stock',
      () {
        expect(contrastRatio(ink, palette.surfaceSunk), closeTo(row.vsSurfaceSunk, 0.005));
      },
    );

    final double? floor = row.floor;
    if (floor != null) {
      test('LonjaPalettes.${row.theme} clears the $floor:1 floor for ${row.slot}', () {
        expect(contrastRatio(ink, palette.surface), greaterThanOrEqualTo(floor));
      });
    }
  }

  for (final ContrastRow row in kOnAccentTable) {
    final LonjaTokens palette = kPalettesByName[row.theme]!;
    test(
      'LonjaPalettes.${row.theme} renders onAccent at ${row.vsSurface}:1 on the accent fill',
      () {
        expect(contrastRatio(palette.onAccent, palette.accent), closeTo(row.vsSurface, 0.005));
        expect(contrastRatio(palette.onAccent, palette.accent), greaterThanOrEqualTo(row.floor!));
      },
    );
  }

  test('LonjaPalettes.paper renders onSurfaceFaint at 3.62:1, below the text floor', () {
    // A DOCUMENTED sub-floor value. Asserting it explicitly stops a later
    // author "fixing" the pigment and breaking the 19 sp-and-above rule it is
    // built for.
    final double ratio = contrastRatio(
      LonjaPalettes.paper.onSurfaceFaint,
      LonjaPalettes.paper.surface,
    );
    expect(ratio, closeTo(3.62, 0.005));
    expect(ratio, lessThan(4.5));
  });

  test('LonjaPalettes.paper renders verdictWarn at 3.97:1, a mark-only value', () {
    // The reason the verdict stamp is framed and never filled. If this ever
    // clears 4.5 somebody changed the pigment.
    final double ratio = contrastRatio(
      LonjaPalettes.paper.verdictWarn,
      LonjaPalettes.paper.surface,
    );
    expect(ratio, closeTo(3.97, 0.005));
    expect(ratio, lessThan(4.5));
  });

  test('sunlight - every LonjaPalettes.sunlight slot clears 7:1 against the surface', () {
    // SPEC.md §13's sunlight line. ochre38 exists solely because paper's
    // ochre47 measures 5.06:1 on white — a WCAG AA pass that misses the
    // product's sunlight floor by two points.
    const LonjaTokens s = LonjaPalettes.sunlight;
    const measurable = <String>[
      'onSurface',
      'onSurfaceMuted',
      'onSurfaceFaint',
      'hairline',
      'hairlineStrong',
      'ruleBearing',
      'accent',
      'verdictPass',
      'verdictFail',
      'verdictWarn',
    ];
    for (final name in measurable) {
      expect(contrastRatio(slotOf(s, name), s.surface), greaterThanOrEqualTo(7), reason: name);
    }
    expect(contrastRatio(s.onAccent, s.accent), greaterThanOrEqualTo(7));
  });
}
