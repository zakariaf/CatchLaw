import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/theme/palette_table.dart';

void main() {
  for (final LonjaSkin skin in LonjaSkin.values) {
    final ThemeData theme = resolveLonjaTheme(skin: skin, gloved: false);
    final LonjaTokens palette = kPalettesByName[skin.name]!;

    test('${skin.name} - the Lonja theme draws dividers as a 1 dp hairline', () {
      // Material widgets underneath us draw their own dividers and must not
      // draw them at 1.5 px in Material grey.
      expect(theme.dividerTheme.color, palette.hairline);
      expect(theme.dividerTheme.thickness, LonjaRules.rule);
    });

    test('${skin.name} - every Lonja surface sits at zero elevation', () {
      // Paper does not float. The moment a surface gains elevation it stops
      // reading as a document and starts reading as an app overlay, and this
      // app's whole authority claim is a document claim.
      expect(theme.cardTheme.elevation, 0);
      expect(theme.dialogTheme.elevation, 0);
      expect(theme.bottomSheetTheme.elevation, 0);
      expect(theme.snackBarTheme.elevation, 0);
    });

    test('${skin.name} - every Lonja surface is square', () {
      for (final shape in <ShapeBorder?>[
        theme.cardTheme.shape,
        theme.dialogTheme.shape,
        theme.bottomSheetTheme.shape,
        theme.snackBarTheme.shape,
      ]) {
        expect((shape! as RoundedRectangleBorder).borderRadius, LonjaRadii.none);
      }
    });

    test('${skin.name} - no Lonja surface carries a surface tint', () {
      // Material 3 tints an elevated surface with the primary colour. At zero
      // elevation the tint is nil anyway — but a default nobody overrode is
      // exactly how a shadow reappears.
      for (final tint in <Color?>[
        theme.cardTheme.surfaceTintColor,
        theme.dialogTheme.surfaceTintColor,
        theme.bottomSheetTheme.surfaceTintColor,
      ]) {
        expect(tint!.a, 0);
      }
    });

    test('${skin.name} - the Lonja theme suppresses the ink splash', () {
      // Paper does not ripple.
      expect(theme.splashFactory, NoSplash.splashFactory);
    });

    test('${skin.name} - the snack bar sits fixed rather than floating', () {
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.fixed);
    });
  }
}
