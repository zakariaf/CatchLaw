import 'package:catchlaw/theme/lonja_faces.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/type_ramp_table.dart';

void main() {
  final arabic = LonjaTypeScale.arabic();
  final latin = LonjaTypeScale.latin();

  for (final TypeRow row in kTypeRamp) {
    if (row.step == 'binomial') continue;
    final TextStyle style = typeStep(arabic, row.step);

    test('ar - LonjaTypeScale.arabic ${row.step} is the tabled size times 1.12', () {
      // Arabic reads a size smaller at the same nominal size.
      expect(style.fontSize, closeTo(row.size * 1.12, 0.001));
    });

    test('ar - LonjaTypeScale.arabic ${row.step} carries zero tracking', () {
      // Not a preference. Arabic is a joining script: Latin tracking inserts
      // space INTO a connected word, so هامور renders as ه ا م و ر and a native
      // reader has to reassemble it letter by letter — which destroys the
      // five-second read this product exists to deliver.
      expect(style.letterSpacing, 0);
    });

    test('ar - LonjaTypeScale.arabic ${row.step} resolves on the Naskh stack', () {
      // The Latin serif has no Arabic coverage at all.
      expect(style.fontFamilyFallback, LonjaFaces.arabic);
    });
  }

  test('ar - LonjaTypeScale.arabic legal gains headroom to 1.80', () {
    // Ascenders, descenders and dot stacks need the vertical room. 19.0px on
    // the Naskh stack at 1.80.
    expect(arabic.legal.height, 1.80);
    expect(arabic.legal.fontSize, closeTo(19.04, 0.01));
  });

  test('ar - LonjaTypeScale.arabic measure sits at 1.10 rather than the Latin 1.00', () {
    // The dots need the room; 1.00 clips them.
    expect(latin.measure.height, 1.00);
    expect(arabic.measure.height, 1.10);
  });

  test('ar - LonjaTypeScale.arabic gives every other step the Latin height plus 0.15', () {
    for (final TypeRow row in kTypeRamp) {
      if (row.step == 'binomial' || row.step == 'legal' || row.step == 'measure') continue;
      expect(
        typeStep(arabic, row.step).height,
        closeTo(row.height + 0.15, 0.001),
        reason: row.step,
      );
    }
  });

  test('ar - LonjaTypeScale.arabic binomial keeps the Latin serif and stays italic', () {
    // The ONE step that does not swap face. Scientific names are Latin
    // binomials in every locale including ar, and there is no true italic
    // master in the Arabic stack — FontStyle.italic there triggers a synthetic
    // oblique that slants a right-to-left cursive script into unreadability.
    expect(arabic.binomial.fontFamilyFallback, LonjaFaces.serif);
    expect(arabic.binomial.fontStyle, FontStyle.italic);
    expect(arabic.binomial.fontSize, latin.binomial.fontSize);
  });

  test('ar - LonjaTypeScale.arabic carries eyebrow and microLabel at w700', () {
    // They have no Arabic form as designed: tracking is what makes them, and
    // .toUpperCase() on Arabic is a silent no-op. Hierarchy comes from weight,
    // colour and a rule instead — never from tracking, never from a case
    // transform.
    expect(arabic.eyebrow.fontWeight, FontWeight.w700);
    expect(arabic.microLabel.fontWeight, FontWeight.w700);
  });

  test('ar - no step rendered on the Naskh stack carries positive tracking', () {
    // Stated as a universal, because the failure is per-step and invisible in
    // any locale but one.
    //
    // Scoped to what actually renders in Naskh, not to the whole scale: this
    // row was first written over every step and caught `binomial`, which keeps
    // the Latin serif and its 0.15px tracking on purpose. A Latin binomial
    // embedded in an Arabic paragraph is Latin text, and Latin tracking is
    // correct for it. Selecting on the stack rather than listing an exception
    // means a future step that swaps face is covered without an edit.
    for (final TextStyle style in arabic.steps) {
      if (style.fontFamilyFallback != LonjaFaces.arabic) continue;
      expect(style.letterSpacing ?? 0, lessThanOrEqualTo(0));
    }
  });
}
