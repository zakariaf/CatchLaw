import 'package:catchlaw/ui/zones/widgets/no_subzone_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

const String _xunta = 'Xunta de Galicia — Consellería do Mar';

void main() {
  group('NoSubZoneNotice', () {
    testWidgets('names the authority that published no boundaries', (WidgetTester tester) async {
      await pumpLonja(tester, const NoSubZoneNotice(authority: _xunta));

      // It states what a GOVERNMENT publishes, never what the app could not
      // load. Those are different facts and only one is about the law.
      expect(find.textContaining(_xunta), findsOneWidget);
      expect(find.textContaining('publishes no coordinate boundaries'), findsOneWidget);
    });

    testWidgets('states the scope the rules actually have', (WidgetTester tester) async {
      await pumpLonja(tester, const NoSubZoneNotice(authority: _xunta));

      // Without the second sentence the absence reads as a gap rather than as
      // the scope the instrument has.
      expect(find.textContaining('apply across the whole jurisdiction'), findsOneWidget);
    });

    testWidgets('offers nothing to tap', (WidgetTester tester) async {
      await pumpLonja(tester, const NoSubZoneNotice(authority: _xunta));

      // There is nothing to do about it. A control here would promise that the
      // boundaries can be fetched, and they cannot: they were never published.
      expect(find.byType(InkWell), findsNothing);
      expect(find.byType(ButtonStyleButton), findsNothing);
    });

    testWidgets('ar - reads right to left', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        const NoSubZoneNotice(authority: 'حكومة غاليسيا'),
        locale: const Locale('ar'),
      );

      expect(find.textContaining('حكومة غاليسيا'), findsOneWidget);
    });
  });
}
