import 'package:catchlaw/theme/lonja_faces.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/type_ramp_table.dart';

const Map<String, List<String>> _stacks = <String, List<String>>{
  'serif': LonjaFaces.serif,
  'sans': LonjaFaces.sans,
  'mono': LonjaFaces.mono,
};

void main() {
  final latin = LonjaTypeScale.latin();

  for (final TypeRow row in kTypeRamp) {
    final TextStyle style = typeStep(latin, row.step);

    test('LonjaTypeScale.latin ${row.step} is ${row.size}px on the ${row.face} stack', () {
      expect(style.fontSize, row.size);
      expect(style.fontFamilyFallback, _stacks[row.face]);
    });

    test('LonjaTypeScale.latin ${row.step} is ${row.weight} at height ${row.height}', () {
      expect(style.fontWeight, row.weight);
      expect(style.height, row.height);
    });

    test('LonjaTypeScale.latin ${row.step} tracks ${row.trackingPx}px', () {
      // Absolute logical pixels, which do NOT scale — the em column in the
      // table is the design intent, this is what gets typed.
      expect(style.letterSpacing, row.trackingPx);
    });

    if (row.face == 'mono') {
      test('LonjaTypeScale.latin ${row.step} declares tabular figures', () {
        // A column of lengths is only scannable if the digits line up. Every
        // mono step carries it; a missing one is a column that jitters.
        expect(style.fontFeatures, LonjaFaces.tabular);
      });
    }
  }

  test('kTypeRamp lists sixteen steps', () {
    // A seventeenth is added to the published table and to the scale in the
    // same commit — never invented at a call site.
    expect(kTypeRamp, hasLength(16));
    expect(latin.steps, hasLength(16));
  });

  test('LonjaTypeScale.latin binomial is the only italic step', () {
    // The app's only italic, and it is for scientific names.
    final italics = <String>[
      for (final TypeRow row in kTypeRamp)
        if (typeStep(latin, row.step).fontStyle == FontStyle.italic) row.step,
    ];
    expect(italics, <String>['binomial']);
  });

  test('LonjaTypeScale.latin raises every step below the minWeight floor', () {
    // Sunlight's w500 floor. At 100,000 lux a w400 stem thins to nothing
    // against white long before its contrast ratio says anything is wrong.
    final floored = LonjaTypeScale.latin(minWeight: FontWeight.w500);
    for (final TypeRow row in kTypeRamp) {
      final TextStyle style = typeStep(floored, row.step);
      expect(
        style.fontWeight!.value,
        greaterThanOrEqualTo(FontWeight.w500.value),
        reason: row.step,
      );
      // And it RAISES rather than flattens: a w700 verdict stays w700.
      if (row.weight.value > FontWeight.w500.value) {
        expect(style.fontWeight, row.weight, reason: row.step);
      }
    }
  });

  test('LonjaFaces declares four stacks and bundles no webfont', () {
    expect(LonjaFaces.serif.last, 'serif');
    expect(LonjaFaces.sans.last, 'sans-serif');
    expect(LonjaFaces.mono.last, 'monospace');
    expect(LonjaFaces.arabic.last, 'serif');
  });

  test('LonjaMeasure caps legal prose at 500px', () {
    // A line of legal prose past roughly 500px stops being scannable, and the
    // whole product is one five-second read.
    expect(LonjaMeasure.legal, 500);
    expect(LonjaMeasure.legalNarrow, lessThan(LonjaMeasure.legal));
  });
}
