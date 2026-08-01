# E20/T06 — No overflow at `ar`, and at `ar` with 200% text

| | |
|---|---|
| **Epic** | E20 — RTL and locale hardening |
| **Branch** | `epic/20-rtl-hardening` (shared) |
| **Commit** | `test(l10n): assert no overflow and a real fit at ar and at ar with 200% text` |
| **Depends on** | T01 (the golden matrix has already flushed the obvious `ar` breakage out of five screens) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.3 final bullet, §6 (S1–S23, D1–D5), §13 "layouts hold at 200% text scale", §14 last dynamic item |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `widget-golden-and-a11y-testing` | Owns the overflow doctrine: the two overflow classes, the three traps, one `testWidgets` per tuple, the fit assertion, and the four wrong fixes |
| `lonja-typography` | Why `ar` overflows where `en` does not: `references/arabic-and-scripts.md` carries the ×1.12 optical uplift and the per-step +0.15 line-height table, and rules 7 and 8 forbid the two easiest ways to make this test green |
| `lonja-design-tokens` | Rule 7 (the 4pt spine) and rule 11 (glove density) — the shared steps a legitimate layout fix moves, and the literals it must not introduce |
| `i18n-rtl-l10n` | Direction comes from the locale; a physical `left` inset is a bug that manifests in exactly one of six locales and is invisible to an `en` suite |
| `testing-strategy` | Rule 11 — this matrix must stay fast enough to run in the default lane, or it gets skipped and a skipped suite is a distrusted one |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.3, final bullet | "Golden tests render every screen in `ar` and assert no overflow" — the assert half, which a golden cannot do |
| `SPEC.md` | §6, S1–S23 and D1–D5 | The complete surface inventory this matrix must cover. Nothing is exempt: §14 requires every one of them reachable and functional |
| `SPEC.md` | §13, Accessibility row | "layouts hold at 200% text scale" |
| `.claude/skills/widget-golden-and-a11y-testing/references/overflow-and-textscale.md` | whole | The loud/silent split, the three traps, the fit assertion, and the four wrong fixes with the reason each is banned |
| `.claude/skills/widget-golden-and-a11y-testing/references/harness-and-mediaquery.md` | the device pin | `physicalSize` is physical pixels; `MediaQuery` layers above `MaterialApp` from `copyWith` |
| `.claude/skills/widget-golden-and-a11y-testing/SKILL.md` | rules 5, 6, 7, 12 | Never suppress; one `testWidgets` per tuple; assert the fit, not just the absence of overflow; never clamp `TextScaler` |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Arabic resolution rules", "Line-height headroom", "Numerals" | ×1.12 size, +0.15 height, `letterSpacing: 0`, and the pinned digit column Arabic-Indic figures need |
| `.claude/skills/lonja-typography/SKILL.md` | rules 7, 8 | Legal prose is capped at 65 characters and the cap **scales**; legal text is never truncated |
| `.claude/skills/lonja-design-tokens/SKILL.md` | rules 7, 11 | The 4pt spine and the density set — where a legitimate fix lives |

## What this delivers

- `app/testing/ui/surface_catalogue.dart` — one entry per surface S1–S23 and dialog D1–D5: a stable
  id, a pump closure that makes it the **painted** route, whether it scrolls, and the handful of
  `fitKeys` whose content must fit its cell. A helper, so not `_test.dart`.
- `app/test/ui/ar_overflow_matrix_test.dart` — 56 generated `testWidgets` (28 surfaces × 2 scales),
  plus 4 named guards.
- Layout fixes in `app/lib/ui/` for whatever it finds. Those are the point of the task, and each is
  named in the commit body.

**If E19 already landed a surface catalogue for its `en` 200% audit, this task extends it and does not
fork it.** Two lists of screens disagree the first time a screen is renamed, and the one that is wrong
is always the one nobody is looking at. Look for it before writing a line: the rejected option is
naming a second list.

## Why it is built this way

**`ar` is not `en` with different words.** `lonja-typography/references/arabic-and-scripts.md` is
explicit: for `ar` the ramp returns a variant where **four things change together** — the Naskh face,
size × 1.12, line height raised by 0.15 (and `legal` all the way to 1.80), and `letterSpacing` forced
to 0. A row that fits at 200% in `en` is therefore not evidence about `ar` at any scale; it is evidence
about a different type ramp. E19's audit ran the scale axis; this task runs the locale axis crossed
with it, which is the only crossing where the Arabic headroom is actually loaded.

**Two overflow classes, and only one of them is loud.** A `RenderFlex` overflow already **fails** a
widget test — `DebugOverflowIndicatorMixin` routes through `FlutterError.reportError` and the binding
rethrows at test end. So the job is not to make overflow fail; it is to **never lose the net that
already exists**. A clipped `Text` reports nothing, ever: `RenderParagraph` has no overflow indicator.
Hence three assertions per tuple rather than one — the exception, a `didExceedMaxLines` sweep over
every paragraph in the tree, and the per-cell fit.

**One `testWidgets` per tuple, loops on the outside.** Overflow is reported **once per
`RenderObject`**; the internal flag resets only on `reassemble()`. A `for` loop over scales inside one
test silently under-reports every scale after the first, and the test still passes. This is the trap
that makes a 56-assertion matrix worth exactly one assertion, so the loop structure is not a style
choice.

**It only reports if the widget paints.** `Offstage` subtrees, content behind a tab, a collapsed sheet
and anything scrolled outside the viewport never report at all. That is why the catalogue's pump
closure has to make each surface the *visible* route and open each dialog, and why surfaces marked
`scrollable` are dragged to the end and re-asserted. A screen the matrix never painted is a screen the
matrix never checked, and it would sit in the count looking like coverage.

**Two conditions, not thirty.** `overflow-and-textscale.md` describes 3 devices × 5 scales × 2 bold.
E19 owns that product for `en`. This task adds the locale axis at the two scales that decide it: 1.0,
because a layout that breaks under `ar` at normal size is broken for every Arabic user today, and 2.0,
because `SPEC.md` §13 names 200% as the floor layouts must hold at. Crossing the full product with six
locales would be 900 tests to buy almost nothing: the Arabic uplift is a constant multiplier, so if it
fits at 2.0 it fits at 1.5.

**The device is pinned at 360 × 800, DPR 3.0.** The default widget surface is 800 × 600 logical —
wider than any phone. Unpinned, content comes out about twice as wide, everything fits, the suite is
green, and the shipped 360 dp phone is broken. `physicalSize` is in **physical** pixels, so it is
`logical × dpr`, and `addTearDown(view.reset)` stops a leaked pin from poisoning the rest of the file.

**The four wrong fixes are named here so nobody reaches for them at 2am.** When a row goes red:

| Reach for | Why it is banned |
|---|---|
| `MediaQuery.withClampedTextScaling`, `textScaleFactor` | Defeats the whole matrix while contrast and tap targets stay green, and overrides the OS setting the user needs |
| `FittedBox`, any auto-shrink | Backwards — it makes the longest string the smallest, and Arabic strings are the longest |
| `TextOverflow.ellipsis` / `maxLines` on legal text | `lonja-typography` rule 8: truncating a citation removes the article number that makes the verdict defensible |
| A smaller font on the offending element | One uniform size is load-bearing; variable line count reads fine, variable size reads as broken |

Legitimate fixes: shorten the ARB copy, adjust the shared component's role, make the region scroll past
a threshold, or move to the denser variant — and run the matrix against **both** variants.

**Rejected: a golden per surface per scale.** 56 more images, none of which can assert anything, all of
which absorb a clipped label the moment somebody re-blesses. T01 is deliberately five screens for this
reason; layout is proven by computed geometry.

**Rejected: `takeException()` in a shared `tearDown`.** It clears `_pendingExceptionDetails` before
`testWidgets` rethrows and converts the entire suite's overflow net into a no-op. Guard 4 below asserts
no test file in `app/test/` contains one.

## Tests first

Write the catalogue and all 60 tests before touching a widget. Run them. **They must fail** — at `ar`
2.0 something always does, and if nothing does on the first run, check that the locale really resolved
and that the device pin took, because a 800 × 600 surface at `en` will pass all sixty.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SurfaceCatalogue covers every screen S1 to S23 and every dialog D1 to D5` | catalogue | 28 entries, ids `s01`…`s23`, `d1`…`d5` | The catalogue *is* the coverage claim. An entry missing from it is a surface nobody checks, and it would not even show up as a gap |
| 2–29 | `ar - <surface> has no overflow and every cell fits at text scale 1.0` (28 rows) | locale `ar`, 360×800 | `takeException()` null; no `RenderParagraph` reports `didExceedMaxLines`; every `fitKey` label fits its cell | Arabic at normal size is what every Gulf user sees on day one. The ×1.12 uplift alone breaks rows that were tuned in `en` |
| 30–57 | `ar - <surface> has no overflow and every cell fits at text scale 2.0` (28 rows) | locale `ar`, scale 2.0 | same three | `SPEC.md` §13's 200% floor, on the locale with the tallest line boxes. This is the crossing E19's audit could not make |
| 58 | `ar - S02 result grows its verdict text at 2.0 and is never clamped` | S02 at 1.0 then 2.0 | height `> base × 1.8` | The anti-clamp behavioural check. No guideline catches a hand-rolled clamp: contrast and tap targets both stay green while the text stops growing |
| 59 | `ar - S02 legal measure scales with textScaler` | S13 article at 1.0 then 2.0 | measure width grows | `lonja-typography` rule 7 — a fixed 500 px box holds ~65 characters at 1.0 and ~32 at 2.0, turning a two-sentence article into a ladder |
| 60 | `ar - S02 digit column fits its pinned width at 2.0` | the measurement column | text width ≤ `LonjaMeasure.digitColumn` | Arabic-Indic digits have no tabular coverage, so the column is pinned rather than trusted to figure widths. At 2.0 a pinned width is exactly where the pin is tested |
| 61 | `OverflowMatrix suppresses no exception anywhere under app/test` | scan of `app/test/` | no `takeException` in a `tearDown`, no `ignoreOverflowErrors`, no `FlutterError.onError =` | One of these anywhere disarms the net for the whole suite, including all 56 rows above |

```dart
// app/testing/ui/surface_catalogue.dart   — helper, never shipped
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// One shipped surface. `pump` must leave it PAINTING: overflow is never reported by an
/// Offstage subtree, a screen behind a tab, or a collapsed sheet.
final class Surface {
  const Surface({
    required this.id,
    required this.title,
    required this.pump,
    this.scrollable = false,
    this.fitKeys = const <String>[],
  });

  final String id;                                    // 's02', 'd3'
  final String title;                                 // 'S02 result'
  final Future<void> Function(WidgetTester, Locale, TextScaler) pump;
  final bool scrollable;                              // dragged to the end and re-checked
  final List<String> fitKeys;                         // cells whose label must fit
}

/// S1–S23 and D1–D5 — SPEC.md §6, complete. If E19 already ships a catalogue for its
/// en 200% audit, extend THAT one; two lists disagree the first time a screen is renamed.
const kSurfaces = <Surface>[ /* 28 entries */ ];
```

```dart
// app/test/ui/ar_overflow_matrix_test.dart
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/l10n/numeral_symbols.dart';
import '../../testing/ui/surface_catalogue.dart';

/// The tightest shipped layout. The default surface is 800x600 logical — wider than any
/// phone — and an unpinned matrix passes while the 360 dp phone is broken.
const _device = Size(360, 800);
const _dpr = 3.0;

/// Real fonts come from app/test/flutter_test_config.dart (E06/T08). Without them the
/// Arabic ramp lays out as em squares and this whole matrix measures nothing.
void _pinDevice(WidgetTester t) {
  t.view.devicePixelRatio = _dpr;
  t.view.physicalSize = _device * _dpr;   // physical px = logical x DPR
  addTearDown(t.view.reset);
}

/// The SILENT class: RenderParagraph has no overflow indicator, so a truncated label
/// reports nothing. This is the sweep that sees it.
void _expectNoTruncatedParagraph(WidgetTester t, String where) {
  for (final p in t.renderObjectList<RenderParagraph>(find.byType(RichText))) {
    expect(p.didExceedMaxLines, isFalse,
        reason: '$where: a paragraph was truncated — a truncated citation loses the '
            'article number that makes the verdict defensible');
  }
}

void main() {
  guardNumberFormatSymbols();

  test('SurfaceCatalogue covers every screen S1 to S23 and every dialog D1 to D5', () {
    expect(kSurfaces.length, 28);
    expect(kSurfaces.map((s) => s.id).toSet().length, 28);
  });

  for (final surface in kSurfaces) {
    for (final scale in const <double>[1.0, 2.0]) {
      // AROUND the call, never inside it: overflow is reported once per RenderObject,
      // so a loop inside one test silently under-reports every scale after the first.
      testWidgets(
        'ar - ${surface.title} has no overflow and every cell fits at text scale $scale',
        (tester) async {
          _pinDevice(tester);
          await surface.pump(tester, const Locale('ar'), TextScaler.linear(scale));

          expect(tester.takeException(), isNull,
              reason: '${surface.title} overflowed at ar x$scale');
          _expectNoTruncatedParagraph(tester, '${surface.title} @ ar x$scale');

          for (final key in surface.fitKeys) {
            final cell = tester.getRect(find.byKey(ValueKey('${key}_cell')));
            final label = tester.getSize(find.byKey(ValueKey(key)));
            expect(label.height, lessThanOrEqualTo(cell.height),
                reason: '$key needs ${label.height} dp inside a ${cell.height} dp cell '
                    'at ar x$scale — it is being clipped silently');
            expect(label.width, lessThanOrEqualTo(cell.width));
          }

          if (surface.scrollable) {
            // Content scrolled outside the viewport never reports. Drag to the end and
            // assert again, or the bottom half of every long screen is untested.
            await tester.drag(find.byType(Scrollable).first, const Offset(0, -4000));
            await tester.pump();
            expect(tester.takeException(), isNull,
                reason: '${surface.title} overflowed below the fold at ar x$scale');
            _expectNoTruncatedParagraph(tester, '${surface.title} below the fold');
          }
        },
      );
    }
  }
}
```

**Run:** `cd app && flutter test test/ui/ar_overflow_matrix_test.dart` → red. Read the failures in
order; the same shared component usually accounts for several rows at once.

## Implementation outline

1. Look for E19's catalogue. Extend it if it exists; write
   `app/testing/ui/surface_catalogue.dart` only if it does not.
2. Fill all 28 entries. Each `pump` closure must leave its surface **painting**: push the route, open
   the dialog, select the tab. Mark the scrolling ones. Give each entry the two or three `fitKeys`
   that carry a fact — the verdict word, the measurement, the citation line — and no more; the
   `_cell` key is the box, the bare key is the label.
3. Run row 1, then rows 2–29 at scale 1.0. Fix what breaks, in the shared component wherever possible:
   one fix in the species row usually clears S5, S6, S8 and S10 together.
4. Run rows 30–57 at 2.0. This is where the +0.15 Arabic headroom lands. Legitimate fixes only —
   the four banned ones are tabulated above, and `check_lonja_type.sh` check 5 and check 7 will catch
   two of them structurally.
5. Run rows 58–60. Row 59 is a `lonja-typography` rule 7 defect if it fails: a constant `maxWidth`
   instead of `LonjaMeasure.legal * MediaQuery.textScalerOf(context).scale(1)`.
6. Row 61 is a grep over `app/test/` — keep it as a Dart test rather than a shell gate so it fails in
   the same run as the thing it protects.
7. Re-run the whole suite, then the golden lane on Linux. A layout fix moves goldens; every moved
   golden is either the fix landing or the fix being wrong, and each one is looked at before it is
   re-blessed.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] 61 tests exist; all 56 matrix rows are separate `testWidgets`, generated by loops **around** the
      call, and each failed before its fix.
- [ ] The catalogue has exactly 28 entries covering S1–S23 and D1–D5, with no duplicate id, and it is
      the only such list in the repository.
- [ ] Every entry's `pump` leaves its surface painting; every scrolling entry is dragged to its end and
      re-asserted.
- [ ] No `takeException()` in any `tearDown`, no `ignoreOverflowErrors`, no `FlutterError.onError =`
      anywhere under `app/test/`.
- [ ] No `withClampedTextScaling`, no `textScaleFactor`, and no `FittedBox` was added to `app/lib/`;
      `check_lonja_type.sh` check 5 is clean.
- [ ] No `maxLines` or `TextOverflow` was added to a `legal`, `legalSmall`, `citation` or `verdict`
      style; `check_lonja_type.sh` check 7 is clean.
- [ ] Every gap introduced by a fix is a `LonjaSpace` step, and every target still meets the density
      set — no numeric `EdgeInsets` literal outside `app/lib/theme/` (`lonja-design-tokens` rules 1, 7).
- [ ] `tools/gates/no_directional_geometry.sh app/lib` is clean: no fix introduced a physical `left`
      or `right` inset, which is the bug that would show in exactly one of six locales.
- [ ] The matrix runs in the default `flutter test` lane and does not need the `golden` tag.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze
cd app && flutter test --exclude-tags golden
cd app && flutter test --tags golden          # Linux; any moved golden is explained
.claude/skills/lonja-typography/scripts/check_lonja_type.sh        app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
tools/gates/no_directional_geometry.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(l10n): assert no overflow and a real fit at ar and at ar with 200% text

SPEC.md §9.3 ends "and assert no overflow"; §13 says layouts hold at 200%.
E19 ran the scale axis in one locale. ar is not en with different words —
the Lonja ramp returns a variant where the face, a 1.12 size uplift, a
+0.15 line-height uplift and letterSpacing 0 all change together, so an en
row that fits at 200% is evidence about a different type ramp.

56 assertions: 28 surfaces (S1–S23, D1–D5) x text scale 1.0 and 2.0, one
testWidgets per tuple because overflow is reported once per RenderObject
and a loop inside a test silently under-reports every scale after the
first. Three assertions per tuple, because only one of the two overflow
classes is loud: takeException for RenderFlex, a didExceedMaxLines sweep
for the silent truncation RenderParagraph never reports, and a getSize
inside getRect fit for the cells that carry a fact. Scrolling surfaces are
dragged to their end and re-asserted — content outside the viewport never
reports at all.

The device is pinned at 360x800 DPR 3.0; unpinned, the default 800x600
surface passes everything while the shipped phone is broken.

Nothing is suppressed and nothing is clamped. The fixes are in the layout,
the copy and the shared components — a separate test asserts no
takeException lives in a tearDown anywhere under app/test, because one of
those disarms the whole net.

Task: E20/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
