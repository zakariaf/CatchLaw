import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_setting_line.dart';
import 'package:catchlaw/ui/core/ui/lonja_switch.dart';
import 'package:catchlaw/ui/settings/widgets/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes/fake_settings_repository.dart';

Future<FakeSettingsRepository> _pumpSettings(
  WidgetTester tester, {
  UserProfile profile = const UserProfile(),
  Locale locale = const Locale('en'),
}) async {
  final settings = FakeSettingsRepository(profile: profile);
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[settingsRepositoryProvider.overrideWithValue(settings)],
      child: MaterialApp(
        theme: resolveLonjaTheme(skin: LonjaSkin.paper, gloved: false),
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return settings;
}

double _topOf(WidgetTester tester, Finder finder) => tester.getTopLeft(finder).dy;

void main() {
  group('SettingsScreen', () {
    testWidgets('heads the branch with a screen bar carrying the app stamp', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);

      expect(find.byType(LonjaScreenBar), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('CatchLaw'), findsOneWidget);
    });

    testWidgets('names the branch before the settings stream has emitted', (
      WidgetTester tester,
    ) async {
      // The mast is outside the `when`, so a stream that stalled still leaves a
      // page that says which branch it is rather than a blank frame.
      final settings = FakeSettingsRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[settingsRepositoryProvider.overrideWithValue(settings)],
          child: MaterialApp(
            theme: resolveLonjaTheme(skin: LonjaSkin.paper, gloved: false),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('orders its rubrics language, place, then reading conditions', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);

      final double language = _topOf(tester, find.text('Language and figures'));
      final double place = _topOf(tester, find.text('Where you fish'));
      final double reading = _topOf(tester, find.text('Reading conditions'));
      expect(language, lessThan(place));
      expect(place, lessThan(reading));
    });

    testWidgets('carries a rubric with a rule to the margin over every group', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);

      expect(find.byType(LonjaSectionLabel), findsNWidgets(3));
    });

    testWidgets('sets the ruler row before the two reading modes', (WidgetTester tester) async {
      // The mockup's second group, not its last: calibration belongs beside the
      // zone it is measured against, and the app had it under the switches.
      await _pumpSettings(tester);

      expect(_topOf(tester, find.text('Ruler')), lessThan(_topOf(tester, find.text('Glove mode'))));
      expect(
        _topOf(tester, find.text('Ruler')),
        lessThan(_topOf(tester, find.text('Sunlight mode'))),
      );
    });

    testWidgets('holds the language choice on one row and not seven', (WidgetTester tester) async {
      await _pumpSettings(tester);

      expect(find.text('Language'), findsOneWidget);
      // The six endonyms are named on the row's own note, and each choosable
      // language is a row on the picker rather than a row on this page.
      expect(find.text('Español'), findsNothing);
      expect(find.text('Galego'), findsNothing);
    });

    testWidgets('reads the language in force at the end of the language row', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester, profile: const UserProfile(localeOverride: 'gl'));

      final LonjaSettingLine row = tester.widget<LonjaSettingLine>(
        find.widgetWithText(LonjaSettingLine, 'Language'),
      );
      expect(row.value, 'Galego');
      expect(row.chevron, isTrue);
    });

    testWidgets('opens the language picker from the language row', (WidgetTester tester) async {
      final FakeSettingsRepository settings = await _pumpSettings(tester);

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      expect(find.text('Galego'), findsOneWidget);

      await tester.tap(find.text('Galego'));
      await tester.pumpAndSettle();
      expect(settings.writes, contains('locale_override'));
      // Back on the ledger, where the row now reads the language chosen.
      expect(find.text('Where you fish'), findsOneWidget);
    });

    testWidgets('prints the zone every answer behind this screen is read against', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester, profile: const UserProfile(activeZoneCode: 'AE-RK'));

      final LonjaSettingLine row = tester.widget<LonjaSettingLine>(
        find.widgetWithText(LonjaSettingLine, 'Zone'),
      );
      expect(row.value, 'AE-RK');
      expect(row.note, 'Rules, species list and limits follow this');
    });

    testWidgets('states no place is chosen when none is stored', (WidgetTester tester) async {
      await _pumpSettings(tester);

      expect(find.text('No place chosen'), findsOneWidget);
    });

    testWidgets('reads the measured scale when the screen has been calibrated', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(
        tester,
        profile: const UserProfile(rulerPxPerMm: 16.24, rulerCalibratedAt: '2026-07-02'),
      );

      final LonjaSettingLine row = tester.widget<LonjaSettingLine>(
        find.widgetWithText(LonjaSettingLine, 'Ruler'),
      );
      // The figure is the point of the row: it is what a fisher compares when
      // two devices disagree about the same fish.
      expect(row.value, contains('162.4'));
      expect(row.value, contains('10 millimetres'));
      expect(row.note, 'Calibrated 2026-07-02');
    });

    testWidgets('states the ruler is not calibrated when no scale is stored', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);

      final LonjaSettingLine row = tester.widget<LonjaSettingLine>(
        find.widgetWithText(LonjaSettingLine, 'Ruler'),
      );
      expect(row.value, 'Not calibrated');
      expect(row.note, isNull);
    });

    testWidgets('carries the coordinate opt-in beside the zone it records', (
      WidgetTester tester,
    ) async {
      final FakeSettingsRepository settings = await _pumpSettings(tester);

      expect(
        _topOf(tester, find.text('Coordinate capture')),
        lessThan(_topOf(tester, find.text('Sunlight mode'))),
      );

      expect(
        tester.widget<LonjaSwitch>(find.widgetWithText(LonjaSwitch, 'Coordinate capture')).value,
        isFalse,
      );

      await tester.ensureVisible(find.text('Coordinate capture'));
      await tester.tap(find.text('Coordinate capture'));
      await tester.pumpAndSettle();

      // Written, and read back through the stream the screen is a function of:
      // the opt-in is off until the fisher turns it on, and a catch carries no
      // coordinates until he does.
      expect(settings.writes, contains('flags'));
      expect(
        tester.widget<LonjaSwitch>(find.widgetWithText(LonjaSwitch, 'Coordinate capture')).value,
        isTrue,
      );
    });

    testWidgets('runs its rows to both margins', (WidgetTester tester) async {
      // The ledger is full-bleed: a row inset from the screen edge cannot carry
      // a hairline that reaches the margin, and the page stops reading as a
      // printed table.
      await _pumpSettings(tester);

      final double screen = tester.getSize(find.byType(SettingsScreen)).width;
      expect(tester.getSize(find.byType(LonjaSettingLine).first).width, screen);
    });

    testWidgets('rules a hairline between the rows of a group', (WidgetTester tester) async {
      await _pumpSettings(tester);

      final Iterable<LonjaRule> rules = tester
          .widgetList<LonjaRule>(find.byType(LonjaRule))
          .where((LonjaRule r) => r.weight == LonjaRules.hair);
      // Three groups of three, three and two rows: two hairlines, two and one,
      // plus the one over the closing note. Between rows and never under the
      // last of a group, where the next rubric's own rule would double it.
      expect(rules.length, 6);
    });

    testWidgets('sets a row key in the serif key step and its note in the quiet sans step', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(tester);

      final type = LonjaTypeScale.latin();
      expect(tester.widget<Text>(find.text('Zone')).style, type.legalSmall);
      final TextStyle note = tester
          .widget<Text>(find.text('Rules, species list and limits follow this'))
          .style!;
      expect(note.fontSize, type.uiSmall.fontSize);
      expect(note.fontFamily, type.uiSmall.fontFamily);
      expect(note.color, LonjaPalettes.paper.onSurfaceMuted);
    });

    testWidgets('closes with the offline note under a hairline', (WidgetTester tester) async {
      await _pumpSettings(tester);

      final Finder note = find.textContaining('no account and no network code');
      expect(note, findsOneWidget);
      expect(_topOf(tester, note), greaterThan(_topOf(tester, find.text('Glove mode'))));
      // Sans and quiet: the serif ramp in this product is what quotes the law,
      // and this is a note about the app.
      final TextStyle style = tester.widget<Text>(note).style!;
      expect(style.fontFamily, LonjaTypeScale.latin().uiSmall.fontFamily);
    });

    testWidgets('ar - SettingsScreen keeps the ledger in the reader’s own direction', (
      WidgetTester tester,
    ) async {
      await _pumpSettings(
        tester,
        profile: const UserProfile(activeZoneCode: 'AE-RK'),
        locale: const Locale('ar'),
      );

      expect(find.text('مكان الصيد'), findsOneWidget);
      final Element row = tester.element(find.byType(LonjaSettingLine).first);
      expect(Directionality.of(row), TextDirection.rtl);
    });
  });
}
