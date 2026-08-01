# E18/T03 — The OFL text and the font attribution

| | |
|---|---|
| **Epic** | E18 — About and attributions |
| **Branch** | `epic/18-about` (shared) |
| **Commit** | `feat(about): ship the SIL OFL 1.1 text and name the unrenamed Noto files` |
| **Depends on** | T02 (the `AboutScreen` scaffold and the block renderer), T01 (the fonts row in `ATTRIBUTIONS.md`) |
| **Size** | S |
| **Spec** | `SPEC.md` §8 fonts row (*"SIL OFL 1.1 — bundling permitted; the font files are not renamed and the OFL text ships in S17"*), §5.3 (no runtime font fetch), §12 (the PDF renders Arabic with the bundled font) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-typography` | Rule 12 bans `GoogleFonts` and any runtime webfont outright; rule 8 forbids truncating a quoted text. `references/type-ramp.md` is also the file this task has to reconcile against `SPEC.md` §8 before writing a line |
| `dependency-hygiene` | The gate that keeps `google_fonts` out is a dependency decision, not a style one: `references/dependency-gate-and-audit.md` refuses a package that opens a network path, and rule 6 says audit the resolved tree rather than the pubspec |
| `catchlaw-offline-guarantee` | Rule 10 — fonts ship as assets, never a CDN — and the failure it names: a remotely-fetched font renders the verdict as blank boxes at 05:40 |
| `i18n-rtl-l10n` | Rule 9: bundle fonts that cover the shipped scripts with fallback and no runtime fetch. The OFL block is an English text inside a possibly-RTL page, so `references/rtl-and-bidi.md`'s standalone-field rule applies again |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, the fonts row | The licence name, the two families, the ~8 MB subset, `assets/fonts/`, and the two obligations: files not renamed, OFL text in S17 |
| `SPEC.md` | §5.3 and §14 static list | `PdfGoogleFonts` and every fetching API is grep-banned; fonts load only via `pw.Font.ttf(rootBundle.load('assets/fonts/…'))` |
| `SPEC.md` | §12 | The trip-report PDF renders with the bundled Arabic font, *never a downloaded one* — the concrete consequence of the bundling decision |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 1 — the banned package table" | `google_fonts` is listed with its reason ("fetches TTF over HTTPS on first paint") and its replacement (`assets/fonts/*.ttf` in `pubspec.yaml`) |
| `.claude/skills/dependency-hygiene/references/dependency-gate-and-audit.md` | "The refuse-outright list", "Record the licence" | Why a network-path package is refused outright, and that a licence is recorded per dependency — the same discipline this task applies to a bundled asset |
| `.claude/skills/lonja-typography/references/type-ramp.md` | "The four faces" | The stacks as they stand today. **Read this before writing code** — see the pre-flight check below |
| `.claude/skills/i18n-rtl-l10n/references/rtl-and-bidi.md` | "Bidi isolation" | A standalone strong-LTR block sets `textDirection` on the widget; isolates are for inline runs |
| `epics/DECISIONS.md` | D-2 | The theme lives at `app/lib/theme/`, which is where `LonjaFaces` declares the families this task attributes |

## Pre-flight check, before any code

```bash
grep -rn "Noto" app/pubspec.yaml app/lib/theme/
ls app/assets/fonts/
```

`SPEC.md` §8 bundles Noto Sans and Noto Naskh Arabic; `lonja-typography/references/type-ramp.md`
says *"The app bundles no webfont; these are system stacks"* and lists Geeza Pro, Al Bayan and
Damascus ahead of Noto Naskh Arabic. If the bundled families are absent from `LonjaFaces`, **stop**:
this task would ship a licence notice for files the app does not use, which is worse than shipping no
notice. Raise it against E07 and record it. The expected answer is that they are bundled — `SPEC.md`
is authoritative for the product, §12 requires the bundled Arabic face in the PDF, and
`CONVENTIONS.md` §6 loads a real font in `flutter_test_config.dart` so `ar` goldens are not six
identical boxes.

## What this delivers

- `app/assets/legal/OFL-1.1.txt` — the SIL Open Font License 1.1 text, copied byte-for-byte from the
  `OFL.txt` shipped inside the Noto packages already in `app/assets/fonts/`. Not retyped, not
  reflowed, not summarised.
- `app/lib/ui/about/widgets/font_licence_section.dart` — renders that file in full inside the
  `AboutScreen` scaffold, under a localised heading, naming both families and the files they ship as.
- `app/pubspec.yaml` — `assets/legal/` already declared by T01; confirm the new file is covered.
- ARB keys in all six files (D-3): `aboutFontsHeading`, `aboutFontsBody`, `aboutFontsLicenceHeading`.
- `app/test/ui/about/about_font_licence_test.dart`.
- `app/test/assets/ofl_asset_test.dart` — the asset-shape guard.

This task adds **no font files**. They are bundled already (E06/E07 need them for goldens and the
theme). It adds the licence text those files oblige us to ship, and the assertions that keep the two
in step.

## Why it is built this way

**The obligation is concrete and `SPEC.md` §8 states both halves.** Bundling under SIL OFL 1.1 is
permitted; the conditions we hold ourselves to are that the files are not renamed and that the licence
text ships in S17. Both are checkable, so both get a test. The first is checked against the file names
recorded in `ATTRIBUTIONS.md` by T01 rather than against a hand-typed list in a test — a hand-typed
list is a second copy and drifts, which is the same argument T01 makes for the whole document.

**The licence ships as a verbatim asset, not as ARB.** An ARB value would demand six translations
(D-3, §9.2), and a translated licence is a new derivative that no longer says what the licence says —
the identical argument §9.6 makes for verbatim legal text. So the OFL text is one file, in one
language, rendered as a standalone LTR block.

**Rendered in full, in the serif.** `lonja-typography` rule 2 puts anything that quotes an instrument
in the serif, and rule 8 forbids truncating it. A licence behind a "show more" is a licence the user
was not shown. It sits in its own scroll region inside the page, not behind a route, so nothing about
reading it can fail offline.

**Rejected: a link to `scripts.sil.org`.** `SPEC.md` §5.3 renders every URL as selectable text and
hands nothing to a browser; §10 bans `url_launcher` and §14 fails the build on `launchUrl`. A licence
we are obliged to ship, shipped as a URL, is also a licence nobody can read at sea — which is every
time this app is used.

**Rejected: `showLicensePage` / `LicenseRegistry`.** Material's licence page is a route with its own
chrome, its own type scale and its own back affordance, none of which come from the Lonja ramp; and
it aggregates package licences, which is not what §8's fonts row asks for. §6 S17 puts the notice on
this screen.

**Rejected: subsetting further to save bytes.** §8 budgets ~8 MB for the subset inside a 55–70 MB
bundle target and says explicitly that no size trade-off argument is needed. Re-subsetting would
change the shipped font files, which is precisely the thing §8's "not renamed" clause is guarding.

**The `google_fonts` assertion is not paranoia.** `four-layers.md` names the exact failure mode:
`google_fonts` resolves faces over HTTPS on first paint, so a cold cache at sea renders the verdict as
blank boxes. It would also make this section a lie — the OFL notice would describe bundled files the
app had stopped using. One assertion covers both.

## Tests first

Write both files before touching `font_licence_section.dart`. Run them. **They must fail** — the
asset and the widget do not exist. A test that passes now is reading some other screen's text.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `OFL asset contains the five SIL OFL 1.1 section headings` | read `assets/legal/OFL-1.1.txt` | `PREAMBLE`, `DEFINITIONS`, `PERMISSION & CONDITIONS`, `TERMINATION`, `DISCLAIMER` all present | A truncated or paraphrased licence is not the licence; these headings are the cheapest structural proof the whole text is there |
| 2 | `OFL asset contains the Reserved Font Name clause` | same | the phrase `Reserved Font Name` present | The clause the "files are not renamed" rule attaches to. If the shipped `OFL.txt` does not contain it, **delete this row and record it in the epic's risks** — do not weaken the file to fit the test |
| 3 | `AboutScreen renders the OFL text in full` | default | every `Text` in the section has `maxLines == null` and `overflow != ellipsis` | The same regression T02 guards: a future overflow fix truncates a licence we are obliged to ship |
| 4 | `AboutScreen names Noto Sans and Noto Naskh Arabic beside the licence` | default | both family names present | A licence notice attached to nothing tells the reader which licence, not which files |
| 5 | `Bundled font filenames match the names recorded in ATTRIBUTIONS.md` | list `assets/fonts/`, parse the fonts row | sets are equal | §8's "not renamed" rule, checked against the generated ledger rather than a second hand-typed list |
| 6 | `app/pubspec.yaml declares every file under assets/fonts/` | parse pubspec | every file covered | An undeclared font is a tofu verdict screen offline, and the failure appears only on a real device |
| 7 | `No pubspec in the workspace declares google_fonts` | walk every `pubspec.yaml` | no match | It would fetch the same faces at runtime — a network path, and a notice describing files the app no longer uses |
| 8 | `ar - AboutScreen renders the OFL text left-to-right` | locale `ar` | the block's `Text` carries `textDirection: TextDirection.ltr` | An English licence reordered by an RTL paragraph is unreadable, and its clause numbering scrambles |
| 9 | `AboutScreen renders the OFL section at TextScaler.linear(2.0) with no overflow` | scale 2.0 | no overflow exception | `SPEC.md` §13: layouts hold at 200% |

```dart
// app/test/assets/ofl_asset_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('OFL asset contains the five SIL OFL 1.1 section headings', () {
    final text = File('assets/legal/OFL-1.1.txt').readAsStringSync();
    for (final heading in const [
      'PREAMBLE',
      'DEFINITIONS',
      'PERMISSION & CONDITIONS',
      'TERMINATION',
      'DISCLAIMER',
    ]) {
      expect(text, contains(heading), reason: 'OFL 1.1 section $heading is missing');
    }
  });

  test('Bundled font filenames match the names recorded in ATTRIBUTIONS.md', () {
    final onDisk = Directory('assets/fonts')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toSet();
    final recorded = fontFilenamesIn(File('assets/legal/ATTRIBUTIONS.md').readAsStringSync());
    expect(onDisk, recorded);
  });

  test('No pubspec in the workspace declares google_fonts', () {
    for (final pubspec in Directory('..').listSync(recursive: true).whereType<File>()
        .where((f) => f.path.endsWith('pubspec.yaml'))) {
      expect(pubspec.readAsStringSync(), isNot(contains('google_fonts')),
          reason: '${pubspec.path} fetches fonts at runtime');
    }
  });
}
```

```dart
// app/test/ui/about/about_font_licence_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../harness.dart'; // pumpAbout(tester, {locale, textScaler, repository})

void main() {
  testWidgets('AboutScreen names Noto Sans and Noto Naskh Arabic beside the licence',
      (tester) async {
    await pumpAbout(tester);
    expect(find.textContaining('Noto Sans'), findsOneWidget);
    expect(find.textContaining('Noto Naskh Arabic'), findsOneWidget);
  });

  testWidgets('ar - AboutScreen renders the OFL text left-to-right', (tester) async {
    await pumpAbout(tester, locale: const Locale('ar'));
    final block = tester.widget<Text>(find.byKey(const Key('about.ofl.body')));
    expect(block.textDirection, TextDirection.ltr);
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/assets/ofl_asset_test.dart test/ui/about/about_font_licence_test.dart`
→ 9 failures. If any passes now, the test is wrong.

## Implementation outline

1. Run the pre-flight check. Stop if the bundled families are not in `LonjaFaces`.
2. Copy `OFL.txt` from the Noto package already in `app/assets/fonts/` to
   `app/assets/legal/OFL-1.1.txt`. Byte-for-byte. Do not reflow it to fit an editor's ruler — the
   ruled columns are part of the document.
3. Confirm `assets/legal/` covers the new file in `app/pubspec.yaml` (T01 declared the directory).
4. Add `FontLicenceSection`. Heading and the "which files, which families" sentence come from ARB;
   the licence body is the asset, rendered in `t.legal` inside a scroll region, with
   `textDirection: TextDirection.ltr` on the body `Text` and a `Key('about.ofl.body')`.
5. Wrap the body in the scaling reading measure —
   `LonjaMeasure.legal * MediaQuery.textScalerOf(context).scale(1)` — not a constant box
   (`lonja-typography` rule 7).
6. Add the section to the `AboutScreen` scaffold in the position §6 S17 implies: with the other
   data-source and licence material, after the attributions document.
7. Add the six ARB keys. `ar` values carry `letterSpacing: 0` by construction — the ramp handles it;
   just do not hand-track anything.
8. Re-run the suite. All 9 green, and T02's 12 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 9 tests pass, and each failed first. If row 2 was deleted, the reason is written into the
      epic's Risks section, not into a code comment.
- [ ] `app/assets/legal/OFL-1.1.txt` is byte-identical to the `OFL.txt` distributed with the bundled
      Noto packages, and the source is named in the commit body.
- [ ] The font filenames on disk, in `app/pubspec.yaml` and in `ATTRIBUTIONS.md` are the same set.
- [ ] `grep -rn "google_fonts\|GoogleFonts\|PdfGoogleFonts" app/ packages/ tools/` returns nothing.
- [ ] No `maxLines`, `TextOverflow.ellipsis` or `FittedBox` in `font_licence_section.dart`.
- [ ] The section renders no tappable link.
- [ ] Every new ARB key exists in all six files (D-3).

## Gates

```bash
# from the repository root
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd -
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh      app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh               app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
```

`check_no_network.sh` also reads `pubspec.yaml` and `analysis_options.yaml` from the parent of the
target, which is why the target is `app/lib` and not `app`. Every invocation names the directory: the
scripts exit 2 on a missing one, and the default `lib/` does not exist at this root (D-1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(about): ship the SIL OFL 1.1 text and name the unrenamed Noto files

SPEC.md §8's fonts row states two obligations we took on by bundling Noto Sans
and Noto Naskh Arabic: the files are not renamed, and the OFL text ships in
S17. Both are now checkable. The licence is a verbatim asset rather than an ARB
value, because six translations of a licence produce six documents that no
longer say what the licence says — the same argument §9.6 makes for verbatim
legal text.

The filename check compares the files on disk against the fonts row that
content_builder emits into ATTRIBUTIONS.md, not against a list typed into a
test, so there is still exactly one copy of that fact. The google_fonts
assertion covers the failure four-layers.md names: it would fetch the same
faces over HTTPS on first paint, rendering the verdict as blank boxes offline
and leaving this notice describing files the app no longer uses.

Task: E18/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
