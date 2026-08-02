import 'package:catchlaw/app.dart';
import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/settings_repository.dart';
import 'package:catchlaw/data/repositories/settings_repository_drift.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/l10n/locale_notifier.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/l10n/numeral_system_notifier.dart';
import 'package:drift/drift.dart' show QueryRow;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Override is exported from misc.dart in Riverpod 3, not the main entry point.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok;

import '../../testing/l10n/number_symbols_guard.dart';

/// The column itself, not the object above it.
///
/// A round trip through `UserProfile` would pass even if the setter wrote a
/// sentinel, because the same code would decode it back.
Future<String?> _localeOverrideColumn(UserDatabase db) async {
  final List<QueryRow> rows = await db
      .customSelect('SELECT locale_override FROM user_profile WHERE id = 1')
      .get();
  return rows.single.read<String?>('locale_override');
}

bool _isArabicIndic(String formatted) => formatted.runes
    .where((int r) => !'٬٫,. '.runes.contains(r))
    .every((int r) => r >= 0x0660 && r <= 0x0669);

void main() {
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  late UserDatabase db;
  late SettingsRepository settings;
  late ProviderContainer container;

  ProviderSubscription<AsyncValue<Locale?>> listenLocale() => container.listen(
    localeNotifierProvider,
    (AsyncValue<Locale?>? _, AsyncValue<Locale?> _) {},
    fireImmediately: true,
  );

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    settings = DriftSettingsRepository(db);
    container = ProviderContainer(
      overrides: <Override>[settingsRepositoryProvider.overrideWithValue(settings)],
    );
    addTearDown(container.dispose);
  });

  test('LocaleNotifier starts at null and follows the device', () async {
    final ProviderSubscription<AsyncValue<Locale?>> sub = listenLocale();
    addTearDown(sub.close);
    await pumpEventQueue();

    expect(container.read(localeNotifierProvider).requireValue, isNull);
  });

  test('LocaleNotifier.setOverride writes pt_BR to user_profile.locale_override', () async {
    final ProviderSubscription<AsyncValue<Locale?>> sub = listenLocale();
    addTearDown(sub.close);
    await pumpEventQueue();

    expect(
      await container.read(localeNotifierProvider.notifier).setOverride(const Locale('pt', 'BR')),
      isA<Ok<void>>(),
    );
    await pumpEventQueue();

    expect(await _localeOverrideColumn(db), 'pt_BR');
    expect(container.read(localeNotifierProvider).requireValue, const Locale('pt', 'BR'));
  });

  test('LocaleNotifier reads back the stored override from a reopened user.db', () async {
    // Persistence is the requirement, so the assertion is against a real
    // database that was closed and opened again — a mocked DAO would prove
    // nothing about the column existing.
    expect(await settings.setLocaleOverride('pt_BR'), isA<Ok<void>>());

    final reopened = ProviderContainer(
      overrides: <Override>[
        settingsRepositoryProvider.overrideWithValue(DriftSettingsRepository(db)),
      ],
    );
    addTearDown(reopened.dispose);
    final ProviderSubscription<AsyncValue<Locale?>> sub = reopened.listen(
      localeNotifierProvider,
      (AsyncValue<Locale?>? _, AsyncValue<Locale?> _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);
    await pumpEventQueue();

    expect(reopened.read(localeNotifierProvider).requireValue, const Locale('pt', 'BR'));
  });

  test(
    'LocaleNotifier.setOverride(null) clears the override rather than storing a sentinel',
    () async {
      final ProviderSubscription<AsyncValue<Locale?>> sub = listenLocale();
      addTearDown(sub.close);
      await pumpEventQueue();

      final LocaleNotifier notifier = container.read(localeNotifierProvider.notifier);
      expect(await notifier.setOverride(const Locale('gl')), isA<Ok<void>>());
      await pumpEventQueue();
      expect(await notifier.setOverride(null), isA<Ok<void>>());
      await pumpEventQueue();

      expect(await _localeOverrideColumn(db), isNull);
    },
  );

  test('LocaleNotifier re-applies the numeral system when the override changes', () async {
    // T04's `auto` means "whatever CLDR says for the RESOLVED locale". If a
    // locale change does not re-evaluate it, `auto` quietly becomes "whatever
    // CLDR said at launch" — and because all six locales are Latin today, that
    // regression is invisible and would never be noticed as missing.
    //
    // Observed by corrupting the map behind the notifier's back and checking it
    // is put right again, because with `arab` stored the visible output would
    // be identical either way.
    final ProviderSubscription<AsyncValue<NumeralSystem>> numerals = container.listen(
      numeralSystemProvider,
      (AsyncValue<NumeralSystem>? _, AsyncValue<NumeralSystem> _) {},
      fireImmediately: true,
    );
    addTearDown(numerals.close);
    final ProviderSubscription<AsyncValue<Locale?>> sub = listenLocale();
    addTearDown(sub.close);

    expect(await settings.setNumeralSystem(NumeralSystem.arab), isA<Ok<void>>());
    await pumpEventQueue();
    expect(_isArabicIndic(numberFormatFor(const Locale('ar')).format(1234567)), isTrue);

    applyNumeralSystem(NumeralSystem.latn); // behind its back
    expect(numberFormatFor(const Locale('ar')).format(1234567), '1,234,567');

    expect(
      await container.read(localeNotifierProvider.notifier).setOverride(const Locale('ar')),
      isA<Ok<void>>(),
    );
    await pumpEventQueue();

    expect(
      _isArabicIndic(numberFormatFor(const Locale('ar')).format(1234567)),
      isTrue,
      reason: 'a locale change must re-evaluate the numeral system',
    );
  });

  testWidgets('CatchlawApp renders RTL when the override is ar and the device is en', (
    WidgetTester tester,
  ) async {
    expect(await settings.setLocaleOverride('ar'), isA<Ok<void>>());

    late TextDirection observed;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: CatchlawApp(
          home: Builder(
            builder: (BuildContext context) {
              observed = Directionality.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      observed,
      TextDirection.rtl,
      reason: 'the override must reach Directionality without a restart',
    );
  });
}
