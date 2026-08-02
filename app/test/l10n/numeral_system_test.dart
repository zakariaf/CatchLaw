import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols_data.dart';

import '../../testing/l10n/number_symbols_guard.dart';

/// Whether every digit in [formatted] is Arabic-Indic (U+0660–U+0669).
///
/// Asserted on code points rather than against a string literal: an Arabic
/// literal in a test file is invisible to review, and the whole question here
/// is which Unicode block the digits came from.
bool _isArabicIndic(String formatted) => formatted.runes
    .where((int r) => !'٬٫,. '.runes.contains(r))
    .every((int r) => r >= 0x0660 && r <= 0x0669);

void main() {
  // Process-wide and order-dependent (FLUTTER_GUIDE.md Part 9.1). Without this
  // pair one test in this file silently corrupts every later golden in the
  // isolate, and the failure surfaces somewhere else entirely.
  setUp(captureNumberSymbols);
  tearDown(restoreNumberSymbols);

  test('numberFormatFor emits Latin digits for ar before any swap', () {
    // CLDR 48 gives ar and ar-AE defaultNumberingSystem latn, so this is
    // correct for Khalid in Ras Al Khaimah. SPEC.md §9.3 records that the
    // first draft asserted the opposite.
    expect(numberFormatFor(const Locale('ar')).format(1234567), '1,234,567');
  });

  test('NumberFormat.decimalPattern with a -u-nu-arab extension emits Latin digits', () {
    // The tombstone on the obvious fix: intl accepts the extension as a string
    // and discards it during verifiedLocale fallback. It does not throw and it
    // does not warn.
    expect(NumberFormat.decimalPattern('ar-u-nu-arab').format(1234567), '1,234,567');
  });

  test('numberFormatSymbols carries exactly ar, ar_DZ and ar_EG for Arabic', () {
    // If a future intl adds ar_AE this row goes red, and that is the only way
    // anybody would ever find out that the whole lever can be reconsidered.
    final Set<String> arabic = numberFormatSymbols.keys
        .cast<String>()
        .where((String k) => k == 'ar' || k.startsWith('ar_'))
        .toSet();
    expect(arabic, <String>{'ar', 'ar_DZ', 'ar_EG'});
  });

  test('numberFormatFor emits the same digits for ar_AE as for ar', () {
    expect(
      numberFormatFor(const Locale('ar', 'AE')).format(1234567),
      numberFormatFor(const Locale('ar')).format(1234567),
      reason: 'intl has no ar_AE entry, so it falls back to ar — SPEC.md §14',
    );
  });

  test('applyNumeralSystem(arab) makes numberFormatFor emit U+0660 to U+0669 for ar', () {
    applyNumeralSystem(NumeralSystem.arab);
    expect(_isArabicIndic(numberFormatFor(const Locale('ar')).format(1234567)), isTrue);
  });

  test('applyNumeralSystem(latn) restores Latin digits for ar after arab was applied', () {
    applyNumeralSystem(NumeralSystem.arab);
    applyNumeralSystem(NumeralSystem.latn);
    expect(numberFormatFor(const Locale('ar')).format(1234567), '1,234,567');
  });

  test('applyNumeralSystem(auto) leaves ar on Latin digits', () {
    applyNumeralSystem(NumeralSystem.arab);
    applyNumeralSystem(NumeralSystem.auto);
    expect(numberFormatFor(const Locale('ar')).format(1234567), '1,234,567');
  });

  test('applyNumeralSystem(arab) leaves the es formatter unchanged', () {
    // Blast radius. A mutation that touched a second key would break the
    // es/gl/ca/pt_BR decimal comma — `45,5 cm` (SPEC.md §9.5).
    applyNumeralSystem(NumeralSystem.arab);
    expect(numberFormatFor(const Locale('es')).format(1234.5), '1.234,5');
  });

  test('applyNumeralSystem is idempotent when called twice with arab', () {
    // The bug this row exists for: a second `arab` call that re-captured the
    // ALREADY SWAPPED entry as the original would make `latn` unrecoverable,
    // and nothing else in this file would notice.
    applyNumeralSystem(NumeralSystem.arab);
    applyNumeralSystem(NumeralSystem.arab);
    applyNumeralSystem(NumeralSystem.latn);
    expect(numberFormatFor(const Locale('ar')).format(1234567), '1,234,567');
  });

  test('a NumberFormat constructed before applyNumeralSystem(arab) keeps Latin digits', () {
    // Order-dependence made visible. This is the row that justifies the
    // no-retained-formatter scan.
    final NumberFormat early = numberFormatFor(const Locale('ar'));
    applyNumeralSystem(NumeralSystem.arab);
    expect(early.format(1234567), '1,234,567');
    expect(_isArabicIndic(numberFormatFor(const Locale('ar')).format(1234567)), isTrue);
  });

  test("restoreNumberSymbols returns numberFormatSymbols['ar'] to its original entry", () {
    applyNumeralSystem(NumeralSystem.arab);
    expect(numberSymbolsArePristine(), isFalse);
    restoreNumberSymbols();
    expect(numberSymbolsArePristine(), isTrue);
    captureNumberSymbols(); // so the tearDown below has something to restore
  });

  test('numeralSystemOf maps auto, latn and arab and falls back to auto on any other value', () {
    expect(numeralSystemOf('auto'), NumeralSystem.auto);
    expect(numeralSystemOf('latn'), NumeralSystem.latn);
    expect(numeralSystemOf('arab'), NumeralSystem.arab);
    // E05 chose a TOTAL decode with a documented fallback over a throw, and the
    // §7.2 CHECK makes a fourth value unrepresentable in user.db anyway. A
    // screen that renders digits the way CLDR says beats one that cannot render
    // numbers at all.
    expect(numeralSystemOf('arabext'), NumeralSystem.auto);
    expect(numeralSystemOf(null), NumeralSystem.auto);
  });

  test('normaliseDigitsToAscii folds Arabic-Indic digits and the U+066B decimal separator', () {
    // `1٫5` means 1.5, not 15. Folding digits and not separators silently
    // corrupts an entered length.
    expect(normaliseDigitsToAscii('١٫٥'), '1.5');
  });

  test('normaliseDigitsToAscii drops the U+066C grouping separator', () {
    expect(normaliseDigitsToAscii('١٬٢٣٤'), '1234');
  });

  test('normaliseDigitsToAscii folds Persian digits, which are a different block', () {
    // U+06Fx, not U+066x. A soft keyboard that emits them must not silently
    // produce a length nobody typed.
    expect(normaliseDigitsToAscii('۴۵'), '45');
  });

  for (final locale in const <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('gl'),
    Locale('ca'),
    Locale('pt', 'BR'),
  ]) {
    final String code = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';
    test(
      'normaliseDigitsToAscii round-trips every integer formatted by numberFormatFor for $code',
      () {
        applyNumeralSystem(NumeralSystem.arab); // the hostile case
        for (final value in const <int>[0, 1, 45, 450, 2400, 1234567]) {
          final String formatted = numberFormatFor(locale).format(value);
          expect(
            int.parse(normaliseDigitsToAscii(formatted).replaceAll(RegExp(r'[.,\s]'), '')),
            value,
            reason: 'locale=$code value=$value formatted=$formatted',
          );
        }
      },
    );
  }
}
