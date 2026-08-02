/// The numeral-system lever, and the one formatter factory the whole app uses.
///
/// **`intl` has no numbering-system API.** Not a parameter, not a setter, not a
/// locale option (`FLUTTER_GUIDE.md` Part 9.1). Three measured facts shape
/// everything in this file:
///
/// 1. `NumberFormat.decimalPattern('ar-u-nu-arab')` returns `1,234,567`. The
///    Unicode extension is accepted as a string and **silently discarded**
///    during `verifiedLocale` fallback. It does not throw and it does not warn,
///    so the obvious fix compiles, runs, and is wrong.
/// 2. `number_symbols_data.dart` carries exactly three Arabic entries — `ar`,
///    `ar_DZ`, `ar_EG`. `ar_AE` falls back to `ar` and renders Latin digits
///    whatever CLDR says.
/// 3. CLDR 48 gives `ar` and `ar-AE` `defaultNumberingSystem: latn`, so Latin
///    digits **are** correct for Khalid in Ras Al Khaimah. `SPEC.md` §9.3
///    records that the spec's first draft asserted the opposite.
///
/// What remains is the public mutable `numberFormatSymbols` map, where
/// `ZERO_DIGIT` *is* the numbering system: `NumberFormat` computes
/// `zeroOffset = ZERO_DIGIT.codeUnitAt(0) - asciiZero` once, at construction.
///
/// That mutation is process-wide and order-dependent, which is why nothing here
/// retains a formatter and why every digit-sensitive test captures and restores
/// the map (`testing/l10n/number_symbols_guard.dart`).
library;

import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

/// The `ar` entry as `intl` shipped it, captured on the first swap.
///
/// Captured **only if still null**, which is the whole of [applyNumeralSystem]'s
/// idempotence: a second `arab` call that re-captured the already-swapped entry
/// as "the original" would make `latn` unrecoverable, and the fisher who tried
/// Arabic-Indic digits once could never get back.
NumberSymbols? _originalArabicSymbols;

/// Points `ar` at the digits [system] asks for.
///
/// `auto` and `latn` are the same swap — none — and stay separate values on
/// purpose. `auto` is a statement about **deference** and `latn` a statement
/// about **preference**: they produce identical output under CLDR 48, but if a
/// future CLDR or a future bundled jurisdiction changes the default for some
/// locale, `auto` must follow it and `latn` must not. Collapsing them now would
/// convert every user's deference into a preference behind their back.
///
/// Only the `ar` key is ever touched. `en` is already Latin, and mutating an
/// entry nobody asked about widens the blast radius of a process-wide mutation
/// for nothing.
void applyNumeralSystem(NumeralSystem system) {
  final Map<String, NumberSymbols> symbols = numberFormatSymbols.cast<String, NumberSymbols>();
  _originalArabicSymbols ??= symbols['ar'];
  symbols['ar'] = switch (system) {
    NumeralSystem.arab => symbols['ar_EG']!,
    NumeralSystem.auto || NumeralSystem.latn => _originalArabicSymbols!,
  };
}

/// The formatter for [locale], constructed fresh.
///
/// **Never memoised, never stored.** A formatter captures its symbols at
/// construction, so a retained one survives every later [applyNumeralSystem]
/// call and renders the digits of whenever it happened to be built. The same
/// function feeds chrome and any painter, so a canvas can never disagree with
/// the text beside it.
NumberFormat numberFormatFor(Locale locale) => NumberFormat.decimalPattern(_intlName(locale));

/// [input] with every non-Latin digit and separator folded to ASCII.
///
/// Digits **and** separators, because `1٫5` means 1.5 and not 15: folding one
/// without the other silently corrupts an entered length. Both Arabic-Indic
/// (U+0660–U+0669) and Persian (U+06F0–U+06F9) are handled — they are distinct
/// Unicode blocks, and a soft keyboard emitting the second must not produce a
/// measurement nobody typed.
///
/// The S3 keypad runs every input through this before parsing. `int.parse` on
/// raw input throws on exactly the characters an Arabic keyboard produces.
String normaliseDigitsToAscii(String input) {
  final out = StringBuffer();
  for (final int r in input.runes) {
    if (r >= 0x0660 && r <= 0x0669) {
      out.writeCharCode(0x30 + (r - 0x0660));
    } else if (r >= 0x06F0 && r <= 0x06F9) {
      out.writeCharCode(0x30 + (r - 0x06F0));
    } else if (r == 0x066B) {
      out.write('.'); // ٫ decimal separator
    } else if (r == 0x066C) {
      continue; // ٬ grouping separator, dropped
    } else {
      out.writeCharCode(r);
    }
  }
  return out.toString();
}

/// `ar`, `pt_BR` — the underscore form `intl` keys its tables by.
String _intlName(Locale locale) => locale.countryCode == null || locale.countryCode!.isEmpty
    ? locale.languageCode
    : '${locale.languageCode}_${locale.countryCode}';
