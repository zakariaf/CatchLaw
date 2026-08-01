# E17/T03 — The PDF trip report, with the bundled Arabic font

| | |
|---|---|
| **Epic** | E17 — Export and import |
| **Branch** | `epic/17-portability` (shared) |
| **Commit** | `feat(export): render the trip report PDF with fonts loaded only from rootBundle` |
| **Depends on** | T01 (`ExportEnvelope` supplies the rows and the content versions) |
| **Size** | L |
| **Spec** | `SPEC.md` §12 export item 3, §5.3 (the accurate offline guarantee), §10 (`pdf` / `printing`, the single-maintainer flag, `TripReportRenderer`), §14 (static grep list; "The PDF renders Arabic with the bundled font") |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | **This is the task that skill exists for.** `references/four-layers.md` holds the transitive allowlist row for `printing → http` and names `PdfGoogleFonts` as its only entry point; the SKILL's "transitive allowlist" section shows the exact wrong and right font calls |
| `catchlaw-verdict-contract` | Rules 3, 4, 5 and 11 all render on this page: the numeric margin, the named measurement method, the required citation quadruple, and a disclaimer that names the authority and cannot be dismissed |
| `catchlaw-conventions-index` | Invariant 3 (a citation on every result) and invariant 5 (an expired ruleset still prints) both have to survive the trip from screen to paper |
| `lonja-typography` | Which role carries which content — serif for anything quoting the law, mono tabular figures for every comparable numeral — and `references/arabic-and-scripts.md` for why Arabic takes zero tracking and extra line height |
| `service-boundary-and-native` | `TripReportRenderer` is a service abstraction over a single-maintainer plugin; this skill owns the boundary shape and the fake |
| `error-handling-typed-results` | Rendering returns bytes or a `Failure`; a missing font asset is a named failure, never an exception crossing the UI |
| `dependency-hygiene` | `pdf` and `printing` are added to `pubspec.yaml` here, and to the checked-in direct-dependency allowlist in the same commit |
| `testing-strategy` | What can honestly be asserted from PDF bytes, and what has to be a device check instead |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §12, export item 3 | The six things the page must carry: header, catch table, totals against limits, the content version and citation behind each finding, the disclaimer. And "Rendered with the bundled Arabic font, never a downloaded one" |
| `SPEC.md` | §5.3 | The accurate guarantee: `http` arrives via `printing`, the edge is allowlisted, and "PDF fonts load only via `pw.Font.ttf(rootBundle.load('assets/fonts/…'))`" |
| `SPEC.md` | §10, `pdf` + `printing` row | The maintenance flag — one maintainer, the only such dependency on the critical path, isolated behind `TripReportRenderer` so it can be swapped without touching callers |
| `SPEC.md` | §14, static grep list | `PdfGoogleFonts` is in the grep that must return nothing over `lib/` |
| `SPEC.md` | §7.3 | Expiry does not delete: a rule past `valid_to` still produces a finding. The report prints it, flagged |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "The transitive allowlist" | The `printing → http` row, reachable only through `PdfGoogleFonts.*`, banned by grep, allowlisted |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "The API grep list" | The full list `check_no_network.sh` enforces, `PdfGoogleFonts` included |
| `.claude/skills/catchlaw-offline-guarantee/SKILL.md` | "The transitive allowlist and the API grep list" | The WRONG/RIGHT pair: `PdfGoogleFonts.notoSansArabicRegular()` versus `pw.Font.ttf(await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'))` |
| `.claude/skills/catchlaw-verdict-contract/SKILL.md` | rules 3, 4, 5, 11 | Margin, method, citation quadruple, and the disclaimer wording that names the authority |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Zero tracking", "Numerals" | Positive tracking severs Arabic joins; citation dates stay Western-digit ISO because they quote a publication record |
| `.claude/skills/lonja-typography/references/type-ramp.md` | "Faces" table (rows for `serif`, `arabic`) | The app bundles no webfont for the *screen* — the stacks are system stacks. That is why the PDF has to bundle its own, and the two facts must not be confused |
| `FLUTTER_GUIDE.md` | §1.4, §1.5 | `PdfExportService` is named in the minimum service set; `implements`, not `extends`, and every repository/service gets an abstract interface and a fake |
| `FLUTTER_GUIDE.md` | §7.5 | `rethrow`, never `throw e`; `Result`/`Failure` in the data layer |
| `epics/DECISIONS.md` | D-7 | The engine holds no user-visible sentence, so every string on this page arrives already rendered from the app layer |

## What this delivers

- `app/lib/domain/models/portability/trip_report.dart` — `TripReport`, `TripReportRow`,
  `TripReportTotal`. Every string on the page arrives pre-rendered from the app's localisation layer
  (D-7). `TripReportRow` takes `citation` as a **required, non-nullable** `String` and
  `contentVersion` as required — invariant 3 made structural, exactly as the engine does it.
- `app/lib/data/services/portability/trip_report_renderer.dart` — the abstract interface:
  `Future<Failure<Uint8List>> render(TripReport report)`. No `pw.*` type appears in this file.
- `app/lib/data/services/portability/trip_report_renderer_pdf.dart` — the only file in the repository
  that imports `package:pdf/widgets.dart`.
- `app/lib/data/services/portability/pdf_font_bundle.dart` — `PdfFontBundle.load(AssetBundle)`,
  which resolves the Naskh face through `pw.Font.ttf(await bundle.load('assets/fonts/…'))` and the
  Latin faces through the `pdf` package's base-14 constructors. **This is the only place in the app
  where a font is constructed for a PDF.**
- `app/assets/fonts/NotoNaskhArabic-Regular.ttf` declared in `app/pubspec.yaml` under `assets:`.
- `app/testing/fakes/fake_trip_report_renderer.dart` and
  `app/testing/fakes/recording_asset_bundle.dart` — the bundle fake records every requested key and
  throws on any key outside `assets/`.
- Tests: `app/test/data/services/portability/trip_report_renderer_pdf_test.dart`,
  `app/test/data/services/portability/pdf_font_bundle_test.dart`.
- `pdf` and `printing` added to `app/pubspec.yaml` and to the checked-in direct-dependency allowlist.

## Why it is built this way

**`PdfGoogleFonts` is the single most likely accidental network call in this application, and it must
be said out loud in this file rather than left to the gate.** `printing` declares `http` as a direct
dependency for exactly one purpose: fetching Google Fonts at runtime. Every PDF tutorial on the
internet opens with `await PdfGoogleFonts.notoSansArabicRegular()`. It compiles. It analyzes clean.
It works on the developer's machine on wifi. Then at 05:40 off Ras Al Khaimah, with the release
build's `INTERNET` permission stripped (§11), the call fails and the Arabic renders as blank boxes on
the one artefact the fisher is handing to an inspector — or, on iOS where there is no permission-level
block (§5.3), it silently succeeds and the app has made a network request while the store listing
says it makes none. That is why the symbol is in `SPEC.md` §14's grep list, in
`four-layers.md`'s API grep list, and in check 5 of `check_no_network.sh`.

The only correct form is the one in the offline-guarantee skill:

```dart
final arabic = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'));
```

and it is confined to `pdf_font_bundle.dart` so there is exactly one file to review.

**Latin runs use the `pdf` package's base-14 faces; Arabic uses the bundled TTF.** Base-14 fonts
(Times, Helvetica, Courier) are part of the PDF specification: every reader has them, nothing is
embedded, nothing is fetched, and their WinAnsi encoding covers Latin-1 — which is `ñ á ã ç í õ ü`
and therefore `es`, `gl`, `ca`, `pt_BR` and `en`. They carry no Arabic glyphs at all, which is why
the Naskh face is bundled and embedded. Rejected: bundling a Latin TTF as well "for consistency" —
that is a second font licence to clear, a second asset in the APK, and a larger PDF, to solve a
problem the format already solved. The residual risk (a content author using a character outside
Latin-1 in a zone label) is a named epic risk with a test row below and a documented fix that is a
bundled TTF, never a fetched one.

**Note the thing that will otherwise be confused:** `lonja-typography`'s `references/type-ramp.md`
says "The app bundles no webfont; these are system stacks, resolved offline, on device, every time."
That is true of the *screen*. A PDF has no system stack — it is read on a laptop in a cofradía
office, so its glyphs must be embedded in the file. Bundling a TTF for the PDF does not contradict
the ramp; it is the reason the ramp can stay system-resolved.

**Behind `TripReportRenderer`, because `SPEC.md` §10 says so.** `pdf` and `printing` share one
maintainer and are the only single-maintainer dependency on the critical path. The interface is
declared with `implements` (`FLUTTER_GUIDE.md` §1.5 — no shared base class), returns `Uint8List`, and
mentions no `pw.*` type, so a replacement renderer is one new file plus a provider override. Every
test in T04–T08 uses `FakeTripReportRenderer`, which is also how the boundary is *proved*: if a
caller ever needed a `pw.Document`, the fake would not compile.

**Invariant 3 is structural, not asserted.** `TripReportRow` cannot be constructed without a citation
string and a content version. §12 requires "the content version and citation behind each finding" on
this page, and the verdict contract's rule 5 requires the citation quadruple be unconstructable
without its parts. A `String?` here would put an uncited finding on the artefact a man hands to an
inspector, which is precisely the moment it matters.

**The disclaimer is a page footer, on every page.** Verdict-contract rule 11 requires it permanent and
on-screen and naming the authority. On paper "permanent" means every page, because a stapled report
gets separated and page 2 is what ends up in the file. Rejected: a single disclaimer block at the end
— it is the page most likely to be lost.

**An expired ruleset still prints.** Invariant 5 and §7.3: expiry does not delete. The report prints
the finding at full strength and adds the rule's `valid_to` as another dated fact beside its citation.
Rejected: omitting expired findings from the PDF "to avoid confusing an inspector" — that is the app
deciding the fisher is better off with less, which the verdict contract's rule 10 names as itself
advice.

**Nothing on the page is composed.** Every sentence in `TripReport` is built by the UI layer from ARB
and `content_string` and handed down (D-7). The renderer lays out strings; it never concatenates a
number to a word. That is what keeps a PDF-only imperative from ever existing.

## Tests first

Write every row before touching `trip_report_renderer_pdf.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `PdfFontBundle.load requests only asset keys under assets/fonts/` | `RecordingAssetBundle` | recorded keys are exactly `['assets/fonts/NotoNaskhArabic-Regular.ttf']` | The direct proof that no font arrives from anywhere but the bundle. This row is the task |
| 2 | `PdfFontBundle.load returns a Failure when the font asset is missing` | bundle that throws on that key | `Failure`, no exception escapes | A mis-declared asset in `pubspec.yaml` must not crash an export at sea |
| 3 | `trip_report_renderer_pdf.dart contains no PdfGoogleFonts reference` | the file's own source | no match | Belt and braces beside `check_no_network.sh`: a gate can be bypassed with an escape-hatch comment, a test in the suite cannot be, and this is the file where the mistake will be made |
| 4 | `pdf_font_bundle.dart builds every pw.Font from rootBundle or a base-14 constructor` | the file's own source | every `pw.Font` construction matches `Font.ttf(` or `Font.times`/`Font.helvetica`/`Font.courier` | Catches the *next* fetching API if the package adds one, which a `PdfGoogleFonts`-only grep would not |
| 5 | `TripReportRendererPdf.render returns bytes beginning with %PDF-` | `kTripReportGaliciaOneTrip` | first five bytes are `%PDF-` | The cheapest proof the output is a PDF at all and not an error page |
| 6 | `TripReportRendererPdf.render emits a page for a trip with no catches` | trip, zero catches | non-empty bytes, no failure | S10's empty state has a paper equivalent; a zero-row table must not divide by zero in the totals |
| 7 | `TripReportRendererPdf.render embeds the Arabic font when a row contains Arabic text` | row with `هامور` | the recording bundle saw the TTF key | Ties the font load to actual Arabic content rather than to a locale flag that could drift |
| 8 | `ar - TripReportRendererPdf.render sets the page direction to RTL` | report with `locale: 'ar'` | the rendered document's text direction is RTL | §9.3 — the report is a document, not the ruler, so it mirrors |
| 9 | `TripReportRow requires a non-null citation` | attempt to construct without one | compile-time failure, asserted by an analyzer test or a `const` construction test | Invariant 3 made structural — a runtime assert would let an uncited row reach paper in release mode |
| 10 | `TripReportRow requires a non-null content version` | as above | as above | §12 names the content version alongside the citation; both or neither |
| 11 | `TripReportRendererPdf.render prints the citation string for every row` | 3 rows, 3 distinct citations | all three strings appear in the extracted text | The claim §12 makes, verified rather than assumed |
| 12 | `TripReportRendererPdf.render prints the disclaimer on every page` | report long enough to paginate (40 catches) | the disclaimer text appears once per page | Verdict-contract rule 11 on paper: page 2 is the page that survives |
| 13 | `TripReportRendererPdf.render prints an expired rule's finding unchanged` | row flagged expired | the finding text is identical to the unexpired case, plus the `valid_to` date | Invariant 5 and §7.3 — expiry adds a fact, it never removes one |
| 14 | `TripReportRendererPdf.render prints totals against the limit for each species` | 6 hamour, bag limit 4 | a totals row reading `6` and `4` | §12: "totals against limits". Both numbers, so the page states a fact rather than a conclusion |
| 15 | `TripReportRendererPdf.render composes no sentence not present in the input` | report whose strings are all sentinel tokens | every text run in the output is one of the sentinels or a literal from the layout | D-7 and invariant 2 — proves the renderer lays out rather than writes |
| 16 | `gl - TripReportRendererPdf.render renders Ría de Arousa, Xoubiña and Ameixa babosa` | Galician fixture | no glyph resolves to the notdef box | The Latin-1 boundary named in the epic's risks, turned into a test that fails loudly if it is crossed |
| 17 | `pt_BR - TripReportRendererPdf.render renders São Paulo and piracema` | Brazilian fixture | as above | The second diacritic-heavy locale, and the one whose content is Brazilian rather than Iberian (D-3) |
| 18 | `TripReportRendererPdf.render returns a Failure rather than throwing when a row is longer than one page` | one row with a 4,000-character note | `Failure` or a paginated document, never an uncaught exception | `pdf` throws on an unbreakable overflow; an export must not crash on a long note |

```dart
// app/test/data/services/portability/trip_report_renderer_pdf_test.dart
import 'dart:io';

import 'package:catchlaw/data/services/portability/trip_report_renderer.dart';
import 'package:catchlaw/data/services/portability/trip_report_renderer_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/fakes/recording_asset_bundle.dart';
import '../../../../testing/models/portability_fixtures.dart';

void main() {
  group('PdfFontBundle', () {
    test('.load requests only asset keys under assets/fonts/', () async {
      final bundle = RecordingAssetBundle();
      await PdfFontBundle.load(bundle);
      expect(bundle.requestedKeys, <String>['assets/fonts/NotoNaskhArabic-Regular.ttf']);
    });
  });

  group('TripReportRendererPdf', () {
    test('.render returns bytes beginning with %PDF-', () async {
      final renderer = TripReportRendererPdf(bundle: RecordingAssetBundle());
      final result = await renderer.render(kTripReportGaliciaOneTrip);
      final bytes = (result as Ok<Uint8List>).value;
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });

    test('.render embeds the Arabic font when a row contains Arabic text', () async {
      final bundle = RecordingAssetBundle();
      await TripReportRendererPdf(bundle: bundle).render(kTripReportRasAlKhaimahArabic);
      expect(bundle.requestedKeys, contains('assets/fonts/NotoNaskhArabic-Regular.ttf'));
    });

    test('.render prints the disclaimer on every page', () async {
      final renderer = TripReportRendererPdf(bundle: RecordingAssetBundle());
      final result = await renderer.render(kTripReportFortyCatches);
      final pages = extractTextPerPage((result as Ok<Uint8List>).value);
      expect(pages, hasLength(greaterThan(1)));
      for (final page in pages) {
        expect(page, contains(kTripReportFortyCatches.disclaimer));
      }
    });
  });

  group('source guard', () {
    test('trip_report_renderer_pdf.dart contains no PdfGoogleFonts reference', () {
      final source =
          File('lib/data/services/portability/trip_report_renderer_pdf.dart').readAsStringSync();
      expect(source, isNot(contains('PdfGoogleFonts')));
    });

    test('pdf_font_bundle.dart builds every pw.Font from rootBundle or a base-14 constructor', () {
      final source = File('lib/data/services/portability/pdf_font_bundle.dart').readAsStringSync();
      final constructions = RegExp(r'Font\.\w+\(').allMatches(source).map((m) => m.group(0));
      const allowed = <String>{'Font.ttf(', 'Font.times(', 'Font.timesBold(', 'Font.courier('};
      expect(constructions.toSet().difference(allowed), isEmpty);
    });
  });

  // … one test per row in the table above, one behaviour each
}
```

**Run:** `cd app && flutter test test/data/services/portability/trip_report_renderer_pdf_test.dart`
→ 18 failures. If row 3 or row 4 passes now, the test is wrong — the file does not exist, so
`readAsStringSync` should throw rather than report a clean source.

## Implementation outline

1. Add `pdf` and `printing` to `app/pubspec.yaml`. Resolve the versions with `flutter pub add`; do
   **not** copy a version from this document — none has been verified here. Record both in the
   checked-in direct-dependency allowlist in this same commit, and re-run
   `flutter pub deps --style=compact` to confirm `http` is still reachable from exactly `printing`
   and `flutter_svg` (§14 static check 1).
2. Add `assets/fonts/NotoNaskhArabic-Regular.ttf` to the repository and declare it in `pubspec.yaml`.
   Record its licence (SIL OFL) in `ATTRIBUTIONS.md`'s font section — E18 renders that file in full,
   and a font added without its licence line is a gap E18 would have to discover.
3. Write `RecordingAssetBundle` in `app/testing/fakes/` — it records every `load` key and throws
   `StateError` on any key not starting `assets/`. This is the fake that makes row 1 meaningful.
4. Write `PdfFontBundle.load(AssetBundle)`: one `pw.Font.ttf(await bundle.load(...))` for Naskh, and
   base-14 constructors for the Latin faces. Return `Failure` on a missing asset — `rethrow` is for
   the caller, but this boundary converts to a typed failure (`FLUTTER_GUIDE.md` §7.5).
5. Write `TripReport`, `TripReportRow`, `TripReportTotal` with required, non-nullable `citation` and
   `contentVersion`.
6. Write `TripReportRenderer` (abstract) and `FakeTripReportRenderer`.
7. Write `TripReportRendererPdf`: page header (trip label, start/end, jurisdiction and zone codes,
   content version per jurisdiction), a `pw.TableHelper`-built catch table, a totals block, and a
   footer built once and attached to every page. Wrap the whole document in
   `pw.Directionality(textDirection: report.isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr)`.
   Set `letterSpacing: 0` on every Arabic run — positive tracking severs the cursive joins
   (`arabic-and-scripts.md`).
8. Pick the face per run: any code point in U+0600–U+06FF selects the Naskh face; otherwise base-14.
   Do not select by locale — a Galician trip can hold an Arabic species note.
9. Re-run the suite. All 18 green, and `check_no_network.sh app/lib` clean.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] `grep -rn "PdfGoogleFonts" app/` returns nothing — not in `lib/`, not in `test/`, not in a
      comment.
- [ ] `package:pdf/widgets.dart` is imported by exactly two files:
      `trip_report_renderer_pdf.dart` and `pdf_font_bundle.dart`.
- [ ] `trip_report_renderer.dart` (the interface) mentions no `pw.` type and imports nothing from
      `package:pdf` or `package:printing`.
- [ ] `pdf` and `printing` appear in the checked-in direct-dependency allowlist, and
      `flutter pub deps --style=compact` shows `http` reachable from exactly `printing` and
      `flutter_svg`.
- [ ] `assets/fonts/NotoNaskhArabic-Regular.ttf` is declared in `pubspec.yaml` and its OFL licence
      line is in `ATTRIBUTIONS.md`.
- [ ] `TripReportRow.citation` and `.contentVersion` are non-nullable with no default and no
      `?? 'unknown'` fallback anywhere in the tree.
- [ ] Every page of a 40-catch report carries the disclaimer.
- [ ] `check_no_network.sh app/lib` is clean **without** any `// no-network-ok` escape hatch in the
      portability directory.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh        app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh   app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                  app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(export): render the trip report PDF with fonts loaded only from rootBundle

printing declares http for one reason — PdfGoogleFonts — and that call is the
single most likely accidental network request in this application. It
compiles, it analyzes clean, and it works on wifi; on a release Android build
with INTERNET stripped it renders the Arabic as blank boxes on the artefact a
fisher is handing to an inspector, and on iOS it just quietly succeeds while
the store listing says nothing is sent. Every face here comes from
pw.Font.ttf(rootBundle.load('assets/fonts/…')) or from a base-14 constructor,
in one file, with a recording AssetBundle asserting no other key is ever
requested.

Behind TripReportRenderer per SPEC.md §10: pdf and printing share one
maintainer and are the only such dependency on the critical path, so no
caller holds a pw.* type. Citation and content version are non-nullable on
every row, and the disclaimer is a footer on every page because page two is
the one that survives being stapled.

Task: E17/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
