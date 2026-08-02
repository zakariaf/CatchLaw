@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Naskh string with joining behaviour — `هامور` — so a font that merely has
/// the codepoints but no shaping still measures differently from one that does.
const String _arabic = 'هامور كنعد';

double _widthOf(String text, {String? fontFamily}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontFamily: fontFamily, fontSize: 24),
    ),
    textDirection: TextDirection.rtl,
  )..layout();
  final double width = painter.width;
  painter.dispose();
  return width;
}

void main() {
  // THE row this whole task exists for, in its cheapest honest form.
  //
  // `flutter test` runs with a test font whose every glyph is an identical box
  // and which has NO Arabic coverage at all. Under it, a request for
  // NotoNaskhArabic silently falls back to that font, so the two layouts below
  // come out the same width — and every `ar` golden in this repository would
  // pass through any amount of broken Arabic shaping and mean nothing
  // (FLUTTER_GUIDE.md §6.4 point 1).
  testWidgets('ar - the Naskh face lays Arabic out differently from the default test font', (
    WidgetTester tester,
  ) async {
    final double naskh = _widthOf(_arabic, fontFamily: 'NotoNaskhArabic');
    final double fallback = _widthOf(_arabic);

    expect(
      naskh,
      isNot(closeTo(fallback, 0.01)),
      reason:
          'NotoNaskhArabic resolved to the default test font — is '
          'loadCatchlawFonts() running in flutter_test_config.dart?',
    );
  });

  test('the ar golden and the en golden of the same specimen are different bytes', () {
    // The same claim, made against what is actually committed. A blessed pair
    // produced with no Arabic coverage would be byte-identical, and this is the
    // only row that would notice.
    final ar = File('test/l10n/golden/goldens/numeral_specimen_ar.png');
    final en = File('test/l10n/golden/goldens/numeral_specimen_en.png');
    expect(ar.existsSync() && en.existsSync(), isTrue, reason: 'goldens not blessed');
    expect(ar.readAsBytesSync(), isNot(equals(en.readAsBytesSync())));
  });

  test('the ar golden under NumeralSystem.arab differs from the plain ar golden', () {
    // The digits actually changed. If E06/T04's lever regresses to a no-op,
    // these two become the same image and nothing else in the suite says so in
    // pixels.
    final plain = File('test/l10n/golden/goldens/numeral_specimen_ar.png');
    final arab = File('test/l10n/golden/goldens/numeral_specimen_ar_arab.png');
    expect(plain.existsSync() && arab.existsSync(), isTrue, reason: 'goldens not blessed');
    expect(plain.readAsBytesSync(), isNot(equals(arab.readAsBytesSync())));
  });
}
