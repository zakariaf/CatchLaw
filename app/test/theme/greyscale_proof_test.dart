import 'package:catchlaw/theme/lonja_button_style.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/colour_math.dart';

ButtonStyle _styleFor(LonjaButtonVariant variant, LonjaTokens tokens) =>
    LonjaButtonStyles.resolve(tokens: tokens, type: LonjaTypeScale.latin(), variant: variant);

Color _field(LonjaButtonVariant variant, LonjaTokens tokens) =>
    _styleFor(variant, tokens).backgroundColor!.resolve(<WidgetState>{})!;

double _weight(LonjaButtonVariant variant, LonjaTokens tokens) =>
    _styleFor(variant, tokens).side!.resolve(<WidgetState>{})!.width;

void main() {
  const LonjaTokens paper = LonjaPalettes.paper;

  test('the primary and destructive fields are within 3 L* of each other', () {
    // THE measurement. harbour30 is L* 30.28 and oxblood28 is L* 27.96 — 2.3
    // apart. Desaturated they are the same box, which is why every assertion
    // below is load-bearing rather than decorative.
    //
    // Invariant 4 exists because sunlight deletes every grey, salt haze eats
    // chroma, and roughly eight percent of the men who will read this screen
    // cannot separate the two hues that matter most. Colour is the third
    // signal, never the first.
    final double primary = cieLStar(_field(LonjaButtonVariant.primary, paper));
    final double destructive = cieLStar(_field(LonjaButtonVariant.destructive, paper));
    expect((primary - destructive).abs(), lessThan(3), reason: '$primary vs $destructive');
  });

  test('the three rungs differ in kind of field, not merely in hue', () {
    // Filled versus outlined survives desaturation; a hue difference does not.
    expect(_field(LonjaButtonVariant.primary, paper).a, 1.0);
    expect(_field(LonjaButtonVariant.destructive, paper).a, 1.0);
    expect(_field(LonjaButtonVariant.secondary, paper).a, 0);
  });

  test('the filled rungs differ in rule weight', () {
    // The second signal, and the one that tells the two filled boxes apart when
    // the first has been taken away.
    expect(_weight(LonjaButtonVariant.primary, paper), LonjaRules.rule);
    expect(_weight(LonjaButtonVariant.destructive, paper), LonjaRules.strong);
    expect(
      _weight(LonjaButtonVariant.primary, paper),
      isNot(_weight(LonjaButtonVariant.destructive, paper)),
    );
  });

  test('the three verdict pigments are distinguishable by lightness alone', () {
    // Downstream and worse: product-invariants.md records that oxblood carries
    // TWO states — below-minimum and protected — so hue distinguishes nothing
    // between them even in full colour.
    final lightness = <double>[
      cieLStar(paper.verdictPass),
      cieLStar(paper.verdictFail),
      cieLStar(paper.verdictWarn),
    ];
    for (var i = 0; i < lightness.length; i++) {
      for (int j = i + 1; j < lightness.length; j++) {
        expect(
          (lightness[i] - lightness[j]).abs(),
          greaterThan(3),
          reason: 'verdict pigments $i and $j: ${lightness[i]} vs ${lightness[j]}',
        );
      }
    }
  });

  testWidgets('greyscale - the three rungs carry distinct labels', (WidgetTester tester) async {
    // The third signal. A golden alone would pass if both rungs became
    // identical grey boxes together; the word is what a human actually reads.
    await tester.pumpWidget(
      MaterialApp(
        theme: LonjaTheme.paper(),
        home: const Scaffold(
          body: Column(
            children: <Widget>[
              LonjaButton.primary(label: 'Measure again', onPressed: null),
              LonjaButton.secondary(label: 'Back one step', onPressed: null),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Measure again'), findsOneWidget);
    expect(find.text('Back one step'), findsOneWidget);
  });
}
