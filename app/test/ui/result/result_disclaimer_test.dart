import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_disclaimer.dart';
import 'package:catchlaw/ui/result/widgets/result_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../../../testing/theme/pump_lonja.dart';

const String _galicia = 'Xunta de Galicia — Consellería do Mar';
const String _uae = 'Ministry of Climate Change and Environment';

const NoteDisplay _noRule = NoteDisplay(
  sentence: 'No rule recorded for this species here. This does not mean it is legal.',
  kind: NoteKind.noRuleRecorded,
  citations: <CitationDisplay>[kCitationDisplayMd580],
);

/// Every result state, so the disclaimer can be proved present in all of them.
const Map<String, ResultDisplay> _states = <String, ResultDisplay>{
  'decided': ResultDisplay(
    findings: <FindingDisplay>[kFindingMinSizeFails],
    disclaimer: '',
    authority: 'Xunta de Galicia — Consellería do Mar',
    stamp: kStampBelowMinimum,
  ),
  'protected': ResultDisplay(
    findings: <FindingDisplay>[],
    disclaimer: '',
    authority: 'Xunta',
    stamp: kStampProtected,
  ),
  'closed season': ResultDisplay(
    findings: <FindingDisplay>[],
    disclaimer: '',
    authority: 'Xunta de Galicia — Consellería do Mar',
    stamp: kStampClosedSeason,
  ),
  'meets': ResultDisplay(
    findings: <FindingDisplay>[],
    disclaimer: '',
    authority: 'Xunta',
    stamp: kStampMeets,
  ),
  'no rule recorded': ResultDisplay(
    findings: <FindingDisplay>[],
    disclaimer: '',
    authority: 'Xunta',
    note: _noRule,
  ),
  'open question': ResultDisplay(
    findings: <FindingDisplay>[kFindingBagLimitIndeterminate],
    disclaimer: '',
    authority: 'Xunta de Galicia — Consellería do Mar',
    note: NoteDisplay(
      sentence: 'Nothing recorded for this period — the bag limit is 6 per day',
      kind: NoteKind.openQuestion,
      citations: <CitationDisplay>[kCitationDisplayMd580],
    ),
  ),
  'ambiguous': ResultDisplay(
    findings: <FindingDisplay>[],
    disclaimer: '',
    authority: 'Xunta de Galicia — Consellería do Mar',
    ambiguity: AmbiguityDisplay(
      sentence: 'Two rules of equal standing apply here.',
      rules: <AmbiguousRuleDisplay>[
        AmbiguousRuleDisplay(
          instrumentId: 'es-ga-orde-2012-07-27',
          facts: <RuleFact>[],
          citation: kCitationDisplayXunta,
        ),
      ],
    ),
  ),
  'expired': ResultDisplay(
    findings: <FindingDisplay>[kFindingMinSizeFails],
    disclaimer: '',
    authority: 'Xunta de Galicia — Consellería do Mar',
    stamp: kStampBelowMinimum,
    stale: StaleDisplay(sentence: 'These rules passed their end date.', provenance: 'pack v1'),
  ),
};

void _ignore(int citationId) {}

void main() {
  group('ResultDisclaimer', () {
    testWidgets('names the authority of the active jurisdiction', (WidgetTester tester) async {
      await pumpLonja(tester, const ResultDisclaimer(authority: _galicia));

      expect(find.textContaining('Consellería do Mar'), findsOneWidget);
    });

    testWidgets('names a different authority in a second jurisdiction', (
      WidgetTester tester,
    ) async {
      await pumpLonja(tester, const ResultDisclaimer(authority: _uae));

      expect(find.textContaining('Ministry of Climate Change'), findsOneWidget);
      expect(find.textContaining('Consellería'), findsNothing);
    });

    testWidgets('states that it is not legal advice and authorises nothing', (
      WidgetTester tester,
    ) async {
      await pumpLonja(tester, const ResultDisclaimer(authority: _galicia));

      expect(find.textContaining('not legal advice'), findsOneWidget);
      expect(find.textContaining('does not authorise any catch'), findsOneWidget);
    });

    testWidgets('carries no dismiss affordance', (WidgetTester tester) async {
      await pumpLonja(tester, const ResultDisclaimer(authority: _galicia));

      // A dismissable disclaimer is, in the record of what the reader was
      // shown, one that was never shown.
      expect(find.byType(ButtonStyleButton), findsNothing);
      expect(find.byType(IconButton), findsNothing);
      expect(find.textContaining('Got it'), findsNothing);
    });

    testWidgets('prints the line saying it cannot be dismissed', (WidgetTester tester) async {
      await pumpLonja(tester, const ResultDisclaimer(authority: _galicia));

      // It makes the disclaimer's absence legible in a screenshot.
      expect(find.text('It cannot be dismissed.'), findsOneWidget);
    });

    testWidgets('reads the whole sentence to a screen reader', (WidgetTester tester) async {
      await pumpLonja(tester, const ResultDisclaimer(authority: _galicia));

      expect(
        find.bySemanticsLabel(RegExp('not legal advice')),
        findsOneWidget,
        reason: 'a screen-reader user gets the same disclaimer a sighted user does',
      );
    });

    testWidgets('survives a 200 percent text scale with no overflow', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
            child: const SingleChildScrollView(child: ResultDisclaimer(authority: _galicia)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('ResultSection', () {
    for (final MapEntry<String, ResultDisplay> state in _states.entries) {
      testWidgets('renders the disclaimer in the ${state.key} state', (WidgetTester tester) async {
        await pumpLonja(
          tester,
          SingleChildScrollView(
            child: ResultSection(
              display: state.value,
              jurisdiction: _galicia,
              onOpenRuleText: _ignore,
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));

        // The no-rule and ambiguous states are where a reader most needs it.
        expect(find.byType(ResultDisclaimer), findsOneWidget);
        expect(find.textContaining('not legal advice'), findsOneWidget);
      });
    }
  });
}
