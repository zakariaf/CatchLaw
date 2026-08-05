import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_rule_facts_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/theme/pump_lonja.dart';

const List<RuleFact> _sizeFacts = <RuleFact>[
  RuleFact(label: 'Measured', value: '38 cm (Total length)'),
  RuleFact(label: 'Minimum', value: '45 cm (Total length)'),
];

const List<RuleFact> _shellFacts = <RuleFact>[
  RuleFact(label: 'Minimum', value: '38 mm (Shell length)'),
];

const List<RuleFact> _protectedFacts = <RuleFact>[
  RuleFact(label: 'Status', value: 'Fully protected', isOutcome: true),
  RuleFact(label: 'Size rule', value: 'Not applicable'),
  RuleFact(label: 'Season', value: 'Not applicable'),
];

Future<void> _pumpTable(
  WidgetTester tester,
  List<RuleFact> facts, {
  Locale locale = const Locale('en'),
  LonjaSkin skin = LonjaSkin.paper,
}) => pumpLonja(
  tester,
  ResultRuleFactsTable(facts: facts),
  locale: locale,
  skin: skin,
);

void main() {
  group('ResultRuleFactsTable', () {
    testWidgets('renders one line per fact', (WidgetTester tester) async {
      await _pumpTable(tester, _protectedFacts);

      for (final RuleFact fact in _protectedFacts) {
        // Cased at the call site, the way the ruled sheet sets its stub column.
        expect(find.text(fact.label.toUpperCase()), findsOneWidget);
      }
      // Two of the three share a value on purpose — a protected table states
      // "Not applicable" twice, and a line that de-duplicated them would drop
      // one of the two rules the reader is being told does not apply.
      expect(find.text('Fully protected'), findsOneWidget);
      expect(find.text('Not applicable'), findsNWidgets(2));
    });

    testWidgets('prints the measurement method in words', (WidgetTester tester) async {
      await _pumpTable(tester, _sizeFacts);

      // A bare TL is a wrong verdict stated with full confidence.
      expect(find.textContaining('Total length'), findsNWidgets(2));
      expect(find.textContaining('TL'), findsNothing);
    });

    testWidgets('keeps the instrument unit', (WidgetTester tester) async {
      await _pumpTable(tester, _shellFacts);

      // The unit follows the instrument, never the locale or the ruler setting.
      expect(find.textContaining('38 mm'), findsOneWidget);
      expect(find.textContaining('3.8 cm'), findsNothing);
    });

    testWidgets('renders the protected shape with no size number', (WidgetTester tester) async {
      await _pumpTable(tester, _protectedFacts);

      // A size row under a prohibition implies a threshold above which the fish
      // could be taken.
      expect(find.text('Not applicable'), findsNWidgets(2));
      expect(find.textContaining('cm'), findsNothing);
    });

    testWidgets('inks only the outcome cell', (WidgetTester tester) async {
      await _pumpTable(tester, _protectedFacts);
      final Color muted = LonjaPalettes.paper.onSurfaceMuted;

      // Once every cell can look like a verdict, no colour on the screen is
      // evidence.
      final Color? outcome = tester.widget<Text>(find.text('Fully protected')).style?.color;
      final Color? plain = tester.widget<Text>(find.text('Not applicable').first).style?.color;
      final Color? label = tester.widget<Text>(find.text('STATUS')).style?.color;
      expect(outcome, isNot(plain));
      expect(label, muted);
    });

    testWidgets('sunlight - keeps the outcome legible without leaning on the pigment', (
      WidgetTester tester,
    ) async {
      // The mockup prints `.phone.sun .rt td` in plain black, spending the one
      // remaining colour on the stamp alone — but the palette is what deletes
      // a colour, and no widget outside the stamp may branch on the skin
      // (D-20). Until a token carries it, what this asserts is the part that
      // does not depend on hue: the weight is a second, independent signal, so
      // the row survives greyscale either way (invariant 4).
      await _pumpTable(tester, _protectedFacts, skin: LonjaSkin.sunlight);

      final Text outcome = tester.widget<Text>(find.text('Fully protected'));
      final Text plain = tester.widget<Text>(find.text('Not applicable').first);
      expect(outcome.style?.fontWeight, FontWeight.w600);
      expect(plain.style?.fontWeight, isNot(FontWeight.w600));
      expect(outcome.style?.color, LonjaPalettes.sunlight.verdictFail);
    });

    testWidgets('uses tabular figures in every value cell', (WidgetTester tester) async {
      await _pumpTable(tester, _sizeFacts);
      final LonjaTypeScale type = LonjaType.of(tester.element(find.byType(ResultRuleFactsTable)));

      // 38 cm, 45 cm and 188 cm only align on a decimal spine.
      for (final RuleFact fact in _sizeFacts) {
        expect(
          tester.widget<Text>(find.text(fact.value)).style?.fontFeatures,
          type.datum.fontFeatures,
        );
      }
    });

    testWidgets('opens on a heavier rule and separates the lines with hairlines', (
      WidgetTester tester,
    ) async {
      await _pumpTable(tester, _protectedFacts);

      // Three facts: the sheet's opening rule, then one under each row. The
      // opening rule is heavier, so the first row does not read as a
      // continuation of the verdict struck above it.
      final Iterable<LonjaRule> rules = tester.widgetList<LonjaRule>(find.byType(LonjaRule));
      expect(rules, hasLength(4));
      expect(rules.first.weight, LonjaRules.strong);
      for (final LonjaRule rule in rules.skip(1)) {
        expect(rule.weight, LonjaRules.hair);
      }
      // Never Material's: it brings 16 dp of physical, non-directional padding.
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('renders nothing when there are no facts', (WidgetTester tester) async {
      await _pumpTable(tester, const <RuleFact>[]);

      expect(find.byType(Text), findsNothing);
      expect(find.byType(LonjaRule), findsNothing);
    });

    testWidgets('RTL - starts the label and ends the value', (WidgetTester tester) async {
      await _pumpTable(tester, _shellFacts, locale: const Locale('ar'));

      // Under RTL the start edge is the right one; a physical `left` compiles
      // and silently breaks in the one locale that is the moat.
      expect(
        tester.getTopRight(find.text('MINIMUM')).dx,
        greaterThan(tester.getTopRight(find.text('38 mm (Shell length)')).dx),
      );
    });

    testWidgets('survives a 200 percent text scale with no overflow', (WidgetTester tester) async {
      await pumpLonja(
        tester,
        Builder(
          builder: (BuildContext context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
            child: const SingleChildScrollView(child: ResultRuleFactsTable(facts: _sizeFacts)),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
