import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_section.dart';
import 'package:catchlaw/ui/result/widgets/result_verdict_panel.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_placeholders.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

/// Lets the 120 ms gap between the two adverse impacts elapse.
///
/// Without it the second impact is a timer still pending when the tree is torn
/// down, which the binding reports as a leak rather than as a haptic.
Future<void> _drainHaptics(WidgetTester tester) => tester.pump(const Duration(milliseconds: 200));

const ResultDisplay _belowMinimum = ResultDisplay(
  findings: <FindingDisplay>[],
  disclaimer: 'CatchLaw quotes published instruments.',
  stamp: kStampBelowMinimum,
);

const ResultDisplay _noRule = ResultDisplay(
  findings: <FindingDisplay>[],
  disclaimer: 'CatchLaw quotes published instruments.',
  note: NoteDisplay(
    sentence: 'No rule recorded for this species here. This does not mean it is legal.',
    kind: NoteKind.noRuleRecorded,
    citations: <CitationDisplay>[kCitationDisplayMd580],
  ),
);

void _ignore(int citationId) {}

void main() {
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  group('ResultSection', () {
    testWidgets('draws the stamp when the display carries one', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        const ResultSection(
          display: _belowMinimum,
          jurisdiction: 'United Arab Emirates',
          onOpenRuleText: _ignore,
        ),
      );
      await _drainHaptics(tester);

      expect(find.byType(ResultVerdictPanel), findsOneWidget);
    });

    testWidgets('draws no stamp for a display that carries none', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        const ResultSection(
          display: _noRule,
          jurisdiction: 'United Arab Emirates',
          onOpenRuleText: _ignore,
        ),
      );

      expect(find.byType(ResultVerdictPanel), findsNothing);
    });

    testWidgets('announces the verdict through the vibrator once', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        const ResultSection(
          display: _belowMinimum,
          jurisdiction: 'United Arab Emirates',
          onOpenRuleText: _ignore,
        ),
      );
      await tester.pump();

      expect(calls, hasLength(1), reason: 'the first impact; the second is 120 ms later');
      expect(calls.single, 'HapticFeedbackType.heavyImpact');

      await _drainHaptics(tester);
      expect(calls, hasLength(2), reason: 'count and weight are the distinction');
    });

    testWidgets('announces nothing for a display that carries no stamp', (
      WidgetTester tester,
    ) async {
      // A buzz for "no rule recorded" would itself read as a verdict.
      await pumpLonja(
        tester,
        const ResultSection(
          display: _noRule,
          jurisdiction: 'United Arab Emirates',
          onOpenRuleText: _ignore,
        ),
      );
      await tester.pump();

      expect(calls, isEmpty);
    });
  });

  group('SpeciesVerdictSlot', () {
    testWidgets('reserves the space when there is no answer yet', (WidgetTester tester) async {
      await pumpLonja(tester, const SpeciesVerdictSlot());

      expect(find.byType(ResultSection), findsNothing);
    });

    testWidgets('mounts the result section when given a display', (WidgetTester tester) async {
      await pumpLonja(tester, const SpeciesVerdictSlot(display: _belowMinimum));
      await _drainHaptics(tester);

      expect(find.byType(ResultSection), findsOneWidget);
    });
  });
}
