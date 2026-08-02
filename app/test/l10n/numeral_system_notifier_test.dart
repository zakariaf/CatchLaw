import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/repositories/settings_repository.dart';
import 'package:catchlaw/data/repositories/settings_repository_drift.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/l10n/numeral_system_notifier.dart';
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Override is exported from misc.dart in Riverpod 3, not the main entry point.
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok;

import '../../testing/l10n/number_symbols_guard.dart';

bool _isArabicIndic(String formatted) => formatted.runes
    .where((int r) => !'\u066c\u066b,. '.runes.contains(r))
    .every((int r) => r >= 0x0660 && r <= 0x0669);

String _arabicOneMillion() => numberFormatFor(const Locale('ar')).format(1234567);

void main() {
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  late UserDatabase db;
  late SettingsRepository settings;
  late ProviderContainer container;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    settings = DriftSettingsRepository(db);
    // Headless, through a container rather than a pump: the notifier is state,
    // and nothing here needs a frame (`testing-strategy` rule 7).
    container = ProviderContainer(
      overrides: <Override>[settingsRepositoryProvider.overrideWithValue(settings)],
    );
    addTearDown(container.dispose);
    // A live listener, always. A bare `read` on a stream provider leaves the
    // element in AsyncLoading forever and then the teardown disposes it
    // mid-load — which reads as a hung notifier rather than as a test that
    // never subscribed. In the app a widget watches it; here this stands in.
    final ProviderSubscription<AsyncValue<NumeralSystem>> sub = container.listen(
      numeralSystemProvider,
      (AsyncValue<NumeralSystem>? _, AsyncValue<NumeralSystem> _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);
  });

  Future<NumeralSystem> settled() async {
    await pumpEventQueue();
    return container.read(numeralSystemProvider).requireValue;
  }

  test('NumeralSystemNotifier applies arab when user_profile.numeral_system is arab', () async {
    // The setter returns a Result, so the write is asserted here rather than
    // discarded — a silently failed write would make every later expectation
    // in this file a statement about the default.
    expect(await settings.setNumeralSystem(NumeralSystem.arab), isA<Ok<void>>());

    expect(await settled(), NumeralSystem.arab);
    expect(_isArabicIndic(_arabicOneMillion()), isTrue);
  });

  test(
    'NumeralSystemNotifier restores Latin digits when the stored value changes from arab to latn',
    () async {
      expect(await settings.setNumeralSystem(NumeralSystem.arab), isA<Ok<void>>());
      expect(_isArabicIndic(await settled().then((_) => _arabicOneMillion())), isTrue);

      // The live S14 toggle. No restart, and no second code path.
      expect(await settings.setNumeralSystem(NumeralSystem.latn), isA<Ok<void>>());
      expect(await settled(), NumeralSystem.latn);
      expect(_arabicOneMillion(), '1,234,567');
    },
  );

  test('NumeralSystemNotifier leaves ar on Latin digits for a fresh profile', () async {
    // The default is `auto`, and CLDR 48 says latn for ar — so a fisher who has
    // touched nothing gets Western digits, which is what SPEC.md §14's last
    // dynamic row checks on the device.
    expect(await settled(), NumeralSystem.auto);
    expect(_arabicOneMillion(), '1,234,567');
  });
}
