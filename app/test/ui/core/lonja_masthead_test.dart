import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_masthead.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

Widget _masthead({String? zoneCode, String? packVersion}) =>
    LonjaMasthead(place: 'Ras Al Khaimah', zoneCode: zoneCode, packVersion: packVersion);

TextStyle _styleOf(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!;

void main() {
  testWidgets('LonjaMasthead stacks the zone code over the pack version', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, _masthead(zoneCode: 'RAK-GULF', packVersion: 'v2026.2'));

    expect(find.text('RAK-GULF'), findsOneWidget);
    expect(find.text('v2026.2'), findsOneWidget);
    // Two lines, and the code is the one on top: it says which body of rules,
    // and the version only qualifies it.
    expect(
      tester.getTopLeft(find.text('RAK-GULF')).dy,
      lessThan(tester.getTopLeft(find.text('v2026.2')).dy),
    );
  });

  testWidgets('LonjaMasthead sets the meta lines in the mono article step, muted', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, _masthead(zoneCode: 'RAK-GULF', packVersion: 'v2026.2'));

    final ramp = LonjaTypeScale.latin();
    for (final line in <String>['RAK-GULF', 'v2026.2']) {
      final TextStyle style = _styleOf(tester, line);
      expect(style.fontSize, ramp.articleNumber.fontSize, reason: line);
      expect(style.fontFamily, ramp.articleNumber.fontFamily, reason: line);
      expect(style.letterSpacing, ramp.articleNumber.letterSpacing, reason: line);
      expect(style.color, LonjaPalettes.paper.onSurfaceMuted, reason: line);
    }
  });

  testWidgets('LonjaMasthead prints the meta block at the trailing margin', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, _masthead(zoneCode: 'RAK-GULF', packVersion: 'v2026.2'));

    expect(
      tester.getBottomRight(find.text('RAK-GULF')).dx,
      greaterThan(tester.getBottomRight(find.text('Ras Al Khaimah')).dx),
    );
  });

  testWidgets('LonjaMasthead omits the meta block when neither line is given', (
    WidgetTester tester,
  ) async {
    // The block is optional so the callers that predate it are untouched: a
    // masthead with no pack to name prints the place and nothing else.
    await pumpLonja(tester, _masthead());

    expect(find.text('Ras Al Khaimah'), findsOneWidget);
    expect(find.text('RAK-GULF'), findsNothing);
    expect(find.text('v2026.2'), findsNothing);
  });

  testWidgets('LonjaMasthead prints one line when only the pack version is given', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, _masthead(packVersion: 'v2026.2'));

    expect(find.text('v2026.2'), findsOneWidget);
    expect(find.text('RAK-GULF'), findsNothing);
  });

  testWidgets('LonjaMasthead keeps the labelled place beside the meta block', (
    WidgetTester tester,
  ) async {
    await pumpLonja(tester, _masthead(zoneCode: 'RAK-GULF', packVersion: 'v2026.2'));

    expect(find.text('Ras Al Khaimah'), findsOneWidget);
    expect(find.text('Answering for'), findsOneWidget);
  });

  testWidgets('LonjaMasthead carries no control', (WidgetTester tester) async {
    // The mast row's whole job is to be read at a glance. The way to another
    // place is a chip on the band below it, and the date the pack was last
    // checked is the seal beside that chip — neither is wedged into the one row
    // that has to stay a masthead.
    await pumpLonja(tester, _masthead(zoneCode: 'RAK-GULF', packVersion: 'v2026.2'));

    expect(find.byType(TextButton), findsNothing);
    expect(find.byType(InkWell), findsNothing);
    expect(find.text('Change place'), findsNothing);
    expect(find.textContaining('2026-07-14'), findsNothing);
  });
}
