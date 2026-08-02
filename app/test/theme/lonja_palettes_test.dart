import 'package:catchlaw/theme/lonja_primitives.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/palette_table.dart';

/// The thirteen slot values of one palette, in table order.
List<Color> _slots(LonjaTokens t) => <Color>[
  t.surface,
  t.surfaceSunk,
  t.onSurface,
  t.onSurfaceMuted,
  t.onSurfaceFaint,
  t.hairline,
  t.hairlineStrong,
  t.ruleBearing,
  t.accent,
  t.onAccent,
  t.verdictPass,
  t.verdictFail,
  t.verdictWarn,
];

void main() {
  // 39 bindings, one row each. A slot bound to the wrong pigment is invisible
  // until somebody reads that screen in that theme.
  for (final PaletteRow row in kPaletteTable) {
    test('LonjaPalettes.${row.theme} binds ${row.slot} to ${row.primitiveName}', () {
      expect(row.actual, row.expected);
    });
  }

  test('kPaletteTable covers all thirteen slots in all three palettes', () {
    expect(kPaletteTable, hasLength(39));
  });

  test('sunlight - LonjaPalettes.sunlight binds every neutral slot to black00', () {
    // The assertion a copyWith-derived sunlight fails first.
    const LonjaTokens s = LonjaPalettes.sunlight;
    for (final neutral in <Color>[
      s.onSurface,
      s.onSurfaceMuted,
      s.onSurfaceFaint,
      s.hairline,
      s.hairlineStrong,
      s.ruleBearing,
      s.accent,
    ]) {
      expect(neutral, LonjaPrimitives.black00);
    }
  });

  test('sunlight - LonjaPalettes.sunlight binds surfaceSunk to surface', () {
    // White paper has no second stock. The consequence for every panel — that a
    // block marked only by a stock change disappears — is T06's to carry.
    expect(LonjaPalettes.sunlight.surfaceSunk, LonjaPalettes.sunlight.surface);
  });

  test(
    'sunlight - LonjaPalettes.sunlight shares exactly two slot values with LonjaPalettes.paper',
    () {
      // The sharpest available proof that sunlight is authored rather than
      // derived: a copyWith sunlight would share six neutrals and both hairlines.
      final List<Color> paper = _slots(LonjaPalettes.paper);
      final List<Color> sun = _slots(LonjaPalettes.sunlight);
      final shared = <int>[
        for (var i = 0; i < paper.length; i++)
          if (paper[i] == sun[i]) i,
      ];
      expect(shared.map((int i) => kPaletteTable[i].slot).toList(), <String>[
        'verdictPass',
        'verdictFail',
      ]);
    },
  );

  test('sunlight - LonjaPalettes.sunlight holds exactly three chromatic values', () {
    // "Exactly one colour survives — the verdict", counted.
    final Set<Color> chroma = _slots(
      LonjaPalettes.sunlight,
    ).where((Color c) => c != LonjaPrimitives.white100 && c != LonjaPrimitives.black00).toSet();
    expect(chroma, hasLength(3));
  });

  test('LonjaPalettes.night shares no slot value with LonjaPalettes.paper', () {
    // Night is hand-authored too; a shared value means a slot was copied rather
    // than chosen.
    final List<Color> paper = _slots(LonjaPalettes.paper);
    final List<Color> night = _slots(LonjaPalettes.night);
    for (var i = 0; i < paper.length; i++) {
      expect(night[i], isNot(paper[i]), reason: kPaletteTable[i].slot);
    }
  });
}
