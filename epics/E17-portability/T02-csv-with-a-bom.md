# E17/T02 — CSV with a BOM

| | |
|---|---|
| **Epic** | E17 — Export and import |
| **Branch** | `epic/17-portability` (shared) |
| **Commit** | `feat(export): write the catch CSV as UTF-8 with a BOM and a localised header row` |
| **Depends on** | T01 (the envelope's `ExportedCatch` is the row shape) |
| **Size** | M |
| **Spec** | `SPEC.md` §12 export item 2, §7.2 (`catch` columns), §9.1 (the six locales), §9.5 (numbers, dates, units) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `i18n-rtl-l10n` | The header row is localised to the active language across all six locales; this skill owns ARB keys and the numeral-system lever the value columns must *not* use |
| `catchlaw-conventions-index` | Rule 12 as corrected by D-3: six ARB files gain the key in the same PR, or the feature does not ship |
| `catchlaw-verdict-contract` | `outcome_detail` becomes a CSV cell. Rule 1 and rule 2 bind it here as much as on screen, and rule 12 governs the `@description` on every new ARB key |
| `catchlaw-offline-guarantee` | Rule 10 — everything resolves from assets and local data; a CSV writer must not reach for a locale service that could |
| `error-handling-typed-results` | The writer returns bytes or a `Failure`; it never throws mid-file leaving a half-written export |
| `testing-strategy` | Byte-level unit tests, not widget tests — the BOM claim is about bytes |
| `naming-conventions` | ARB key naming for the header row, and the test names below |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §12, export item 2 | "flat, UTF-8 **with BOM** so Excel opens Arabic and Galician correctly; one row per catch; headers localised to the active language" — all four constraints |
| `SPEC.md` | §7.2, `catch` table | The columns that become CSV columns, and which are nullable |
| `SPEC.md` | §9.1 | Which locales ship and why — read together with D-3, which corrects the list |
| `SPEC.md` | §9.5 | "Numbers: locale decimal separator (`45,5 cm` in es/pt_BR/gl/ca)" — the rule this task deliberately does **not** apply to CSV values, and must say why |
| `SPEC.md` | §9.3 | The numeral-system lever (`numberFormatSymbols`) is process-wide and order-dependent — which is exactly why a CSV must not go through `NumberFormat` |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | rule 12 | Every new ARB key's `@description` carries its constraint; the CSV header keys are UI chrome, so they take a plain description, but the `outcome_detail` column must not acquire one |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Numerals", point 5 | Dates in citations stay Western-digit ISO in every locale because they quote a record. The same argument covers every value column in a machine-readable file |
| `epics/DECISIONS.md` | D-3 | `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`. Never `ur`, never `app_pt.arb` |

## What this delivers

- `app/lib/data/services/portability/catch_csv_writer.dart` — `CatchCsvWriter` with
  `Uint8List write(List<ExportedCatch> catches, CatchCsvHeaders headers)`. Returns bytes, not a
  `String`, because the BOM is a byte-level fact and a `String` cannot carry one.
- `app/lib/data/services/portability/catch_csv_headers.dart` — `CatchCsvHeaders`, a plain value
  object of 16 localised strings, built in the UI layer from `AppLocalizations` and passed down. The
  writer holds no `BuildContext` and no `AppLocalizations` (`FLUTTER_GUIDE.md` §1.4 — a service
  isolates data loading and holds no state).
- ARB keys in all six files — `app_ar.arb`, `app_en.arb`, `app_es.arb`, `app_gl.arb`, `app_ca.arb`,
  `app_pt_BR.arb` (D-3): `csvHeaderCreatedAt`, `csvHeaderTripLabel`, `csvHeaderJurisdiction`,
  `csvHeaderZone`, `csvHeaderSpeciesId`, `csvHeaderScientificName`, `csvHeaderLengthMm`,
  `csvHeaderMeasurement`, `csvHeaderOutcome`, `csvHeaderOutcomeDetail`, `csvHeaderCitation`,
  `csvHeaderContentVersion`, `csvHeaderWasKept`, `csvHeaderPhoto`, `csvHeaderLatitude`,
  `csvHeaderLongitude`.
- Tests: `app/test/data/services/portability/catch_csv_writer_test.dart`.
- Fixtures extended in `app/testing/models/portability_fixtures.dart`: `kCatchWithCommaInDetail`,
  `kCatchWithQuoteInDetail`, `kCatchWithNewlineInDetail`, `kCatchGalicianZone`, `kCatchArabicNote`.

## Why it is built this way

**The BOM is the whole point of the task, and it is three bytes.** `EF BB BF`, written before
anything else. Without it Excel's import heuristic falls back to the system ANSI code page: on a
Spanish-locale Windows machine `Ría de Arousa` opens as `RÃ­a de Arousa`, and an Arabic export opens
as line noise. `SPEC.md` §12 names Arabic and Galician specifically because those are the two the
product cannot afford to lose. Rejected: writing a plain UTF-8 file and telling the user to pick the
encoding in Excel's import wizard — that is a support burden landing on a man with a phone on a boat,
and it fails the "hand it to the cofradía" use the artefact exists for.

**The header row is localised; every value column is not.** This looks like an inconsistency with
`SPEC.md` §9.5 ("locale decimal separator, `45,5 cm`"), so it is written down here rather than left
to be re-derived. A CSV is comma-separated. A Galician or Spanish decimal comma inside an unquoted
numeric cell *is a column boundary*, and quoting the number to save it turns a numeric column into
text in every spreadsheet that opens it. §9.5's rule is about presentation; a CSV cell is data.
Concretely:

- `length_mm` is written as the integer millimetres §9.5 already says everything is stored as.
  No unit suffix, no conversion, no separator. The header says which unit.
- Dates are ISO 8601, copied through from `created_at` untouched.
- Digits are always Western, in every locale including `ar`. §9.3 records that the numeral system is
  implemented by mutating the process-wide `numberFormatSymbols` map; routing CSV values through
  `NumberFormat` would make the file's contents depend on a global the user set for the *screen*, and
  Arabic-Indic digits in a CSV cell are not a number to any spreadsheet on earth.
- `latitude` / `longitude` use `.` as the decimal point, for the same reason, and are empty when the
  catch opted out of coordinates (§4.5 — coordinates are opt-in per catch).

**RFC 4180 quoting, and CRLF line endings.** A field is quoted when it contains a comma, a double
quote, a CR or an LF; an embedded double quote is doubled. `outcome_detail` is the field that will
hit all three — "Below the minimum — 38 cm measured, minimum 45 cm (total length)" already contains a
comma, and a trip `notes` field will eventually contain a newline. Lines end `\r\n` because that is
what RFC 4180 specifies and what Excel expects; a lone `\n` is tolerated by modern Excel but not by
every tool a cofradía will use.

**No CSV package.** Rejected: adding a dependency for ~40 lines of quoting. `SPEC.md` §14 static
check 1 diffs the direct-dependency allowlist on every build, so each new package costs an allowlist
entry and a transitive-edge audit forever. The quoting rules are four lines of RFC 4180 and are
tested exhaustively below.

**One row per catch, and no trip rows.** §12 says "one row per catch". The trip is carried on the row
as its label, so a spreadsheet can group by it without a join. Rejected: a second sheet or a second
file for trips — a CSV has one table, and the JSON (T01) is where the relational structure lives.

**`outcome_detail` is copied verbatim into its cell.** Same rule as T01: this is the sentence that
was shown, and the export composes nothing. Truncating it to fit a column, or replacing the em dash
with a hyphen so Excel does not sulk, would be the export re-wording a statement of law.

## Tests first

Write every row before touching `catch_csv_writer.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `CatchCsvWriter.write emits a UTF-8 BOM as the first three bytes` | one catch | bytes `[0xEF, 0xBB, 0xBF, …]` | The single claim §12 makes about this file. If this row is deleted the artefact silently stops working in Excel |
| 2 | `CatchCsvWriter.write emits the header row after the BOM` | one catch | fourth byte onward decodes to the header names | A BOM in the middle of the file is a visible `` in cell A1 |
| 3 | `CatchCsvWriter.write emits one row per catch` | 17 catches | 18 CRLF-terminated lines | §12: "one row per catch" |
| 4 | `CatchCsvWriter.write terminates every line with CRLF` | 3 catches | no bare `\n` in the byte stream | RFC 4180, and the tools a cofradía runs |
| 5 | `CatchCsvWriter.write quotes a field containing a comma` | `kCatchWithCommaInDetail` | cell wrapped in `"` | `outcome_detail` always contains a comma; an unquoted one shifts every later column by one |
| 6 | `CatchCsvWriter.write doubles an embedded double quote` | `kCatchWithQuoteInDetail` | `"" ` inside the quoted cell | The RFC's escape, and the one a hand-rolled writer gets wrong first |
| 7 | `CatchCsvWriter.write quotes a field containing a newline` | `kCatchWithNewlineInDetail` | quoted, and the row count stays 2 | A note with a line break must not become two rows and corrupt every row after it |
| 8 | `CatchCsvWriter.write writes length_mm as bare integer millimetres` | length 450 | cell is `450`, not `45,0` and not `45 cm` | §9.5 stores millimetres; a decimal comma in a comma-separated file is a column boundary |
| 9 | `CatchCsvWriter.write writes an empty cell for a null length_mm` | `kCatchNoLength` | two adjacent commas, no `null` literal | The tally-only catch is legal; the string `null` would import back as text |
| 10 | `CatchCsvWriter.write writes created_at as the stored ISO 8601 text` | `2026-07-14T05:41:00+04:00` | identical string | Copied through, not reformatted — the offset is information about where the catch happened |
| 11 | `ar - CatchCsvWriter.write emits Arabic header names` | `ar` headers | header row decodes to the Arabic strings | §12: "headers localised to the active language" |
| 12 | `ar - CatchCsvWriter.write writes Western digits in the length column` | `ar` headers, length 450 | `450`, not `٤٥٠` | §9.3's numeral lever is process-wide; a spreadsheet cannot read Arabic-Indic digits as a number |
| 13 | `ar - CatchCsvWriter.write inserts no bidi control characters` | `ar` headers, Arabic note | no U+200E/U+200F/U+2066–U+2069 in the bytes | Bidi isolates are a *rendering* device; in a CSV they become invisible characters inside a cell that break every string comparison |
| 14 | `gl - CatchCsvWriter.write round-trips a Galician zone label through UTF-8` | `kCatchGalicianZone` (`Ría de Arousa`) | decoded cell equals the input | The second locale §12 names; a mangled `í` is the failure the BOM exists to prevent |
| 15 | `CatchCsvWriter.write emits sixteen columns in every row` | 17 catches, mixed nullability | every row splits to 16 fields | A nullable column silently dropped shifts the header off the data and is invisible until someone sorts |
| 16 | `CatchCsvWriter.write copies outcome_detail with no transformation` | detail with an em dash and a comma | identical text inside the quotes | Invariant 2 — the export re-words nothing, including punctuation |
| 17 | `CatchCsvWriter.write writes was_kept as 0 or 1` | one kept, one released | `1` and `0` | §7.2 stores an INTEGER; `true`/`false` would not match the JSON and would import back as text |
| 18 | `CatchCsvWriter.write leaves latitude and longitude empty when coordinates were not captured` | catch with null coords | two empty cells | §4.5 — coordinates are opt-in per catch, and `0.0` would put the fisher off the coast of Ghana |
| 19 | `CatchCsvHeaders has a value for every column in all six locales` | loop over `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` | 16 non-empty strings each | D-3, and rule 12 of `catchlaw-conventions-index`: six locales ship together or the feature does not ship |

```dart
// app/test/data/services/portability/catch_csv_writer_test.dart
import 'dart:convert';

import 'package:catchlaw/data/services/portability/catch_csv_writer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/models/portability_fixtures.dart';

void main() {
  const writer = CatchCsvWriter();

  group('CatchCsvWriter', () {
    test('.write emits a UTF-8 BOM as the first three bytes', () {
      final bytes = writer.write(<ExportedCatch>[kCatchHamourExpiredRule], kCsvHeadersEn);
      expect(bytes.take(3), <int>[0xEF, 0xBB, 0xBF]);
    });

    test('.write doubles an embedded double quote', () {
      final text = utf8.decode(
        writer.write(<ExportedCatch>[kCatchWithQuoteInDetail], kCsvHeadersEn).skip(3).toList(),
      );
      expect(text, contains('""'));
    });

    test('.write writes length_mm as bare integer millimetres', () {
      final text = utf8.decode(
        writer.write(<ExportedCatch>[kCatchHamour450mm], kCsvHeadersEs).skip(3).toList(),
      );
      final cells = text.split('\r\n')[1].split(',');
      expect(cells[6], '450');
    });

    test('ar - .write writes Western digits in the length column', () {
      final text = utf8.decode(
        writer.write(<ExportedCatch>[kCatchHamour450mm], kCsvHeadersAr).skip(3).toList(),
      );
      expect(text, contains('450'));
      expect(text, isNot(contains('٤٥٠')));
    });

    test('ar - .write inserts no bidi control characters', () {
      final text = utf8.decode(
        writer.write(<ExportedCatch>[kCatchArabicNote], kCsvHeadersAr).skip(3).toList(),
      );
      const bidi = <int>[0x200E, 0x200F, 0x2066, 0x2067, 0x2068, 0x2069];
      expect(text.runes.where(bidi.contains), isEmpty);
    });

    for (final locale in <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR']) {
      test('CatchCsvHeaders has a value for every column in $locale', () {
        expect(kCsvHeadersByLocale[locale]!.all, hasLength(16));
        expect(kCsvHeadersByLocale[locale]!.all.where((String s) => s.isEmpty), isEmpty);
      });
    }

    // … one test per row in the table above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/data/services/portability/catch_csv_writer_test.dart` → 19
failures (the six-locale loop counts as six). If the BOM row passes now, the test is wrong — it is
asserting against a literal rather than against `write`.

## Implementation outline

1. Write `CatchCsvHeaders` as a value object with 16 named fields and an `all` getter returning them
   in column order. Column order is defined once, here, and the writer reads it — so a new column
   cannot be added to the header without being added to the row.
2. Add the 16 ARB keys to `app_en.arb` with `@` descriptions, then to the other five (D-3). Run
   `gen-l10n`. The E06 CI check that fails on a key missing from any locale is what proves this step.
3. Write `_field(String? value)` — the RFC 4180 quoter. Null → empty. Contains `,`, `"`, `\r` or
   `\n` → wrap in `"` and double every `"`. Otherwise pass through.
4. Write `write`: `BytesBuilder`, push `[0xEF, 0xBB, 0xBF]`, then `utf8.encode` of the header line
   and each row line, `\r\n` terminated.
5. Wire `CatchCsvHeaders.fromL10n(AppLocalizations)` in `app/lib/ui/settings/export/` — the only
   place that touches `AppLocalizations`, keeping the service free of Flutter.
6. Re-run the suite. All 19 green, and every T01 codec test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] The 16 ARB keys exist in all six files — `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` — and the E06
      completeness check is green.
- [ ] `catch_csv_writer.dart` imports nothing from `package:flutter` except `dart:typed_data`'s
      `Uint8List` re-export path, and imports no `intl` `NumberFormat`.
- [ ] No `NumberFormat`, no `DateFormat` and no `toLocal()` appears in the writer.
- [ ] The writer returns `Uint8List`; no public method returns `String`.
- [ ] Line coverage on `catch_csv_writer.dart` is ≥ 95%.
- [ ] The header order and the row order are driven by the same `all` getter — verified by a test
      that reverses the header list and watches the row test fail.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh        app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh   app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(export): write the catch CSV as UTF-8 with a BOM and a localised header row

Without the three-byte BOM Excel falls back to the system code page, and the
two locales SPEC.md §12 names by name are exactly the two that break: Ría de
Arousa opens as RÃ­a de Arousa and an Arabic export opens as line noise. The
artefact exists to be handed to a cofradía, so the encoding is not a detail.

The header row is localised; no value column is. §9.5's decimal comma is a
presentation rule, and a decimal comma inside a comma-separated file is a
column boundary. Lengths stay bare integer millimetres and digits stay
Western in every locale, including ar, because a spreadsheet cannot read
٤٥٠ as a number.

Task: E17/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
