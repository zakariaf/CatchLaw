# E08/T08 — Widget and golden tests for S5, S6 and S2

| | |
|---|---|
| **Epic** | E08 — Species: search, browse and the static detail |
| **Branch** | `epic/08-species` (shared) |
| **Commit** | `test(species): pin S5, S6 and S2 with geometry, semantics and two golden lanes` |
| **Depends on** | T03, T04, T05, T06, T07 |
| **Size** | L |
| **Spec** | `SPEC.md` §4.9 (accessibility and field usability), §9.3 (RTL and numerals), §13 (200% scale) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `widget-golden-and-a11y-testing` | Owns the whole task: the harness, the device pinning, the overflow matrix, the two golden lanes, and the argument for refusing layout goldens |
| `lonja-lists-and-tables` | `references/the-four-states.md` publishes the eleven-lane matrix per list screen and names the two lanes reviewers skip |
| `lonja-typography` | `references/arabic-and-scripts.md` names what an `ar` lane must prove: joining, zero tracking, the height uplift, and the binomial keeping its Latin face |
| `lonja-icons-and-plates` | The silhouette and plate are `CustomPainter` output, which is one of the four things a golden can see and geometry cannot |
| `lonja-design-tokens` | The three themes and the orthogonal glove density are the axes the lanes vary |
| `state-management-riverpod` | Every seam throws until overridden, and `ProviderContainer.test` / `overrideWithValue` are the wiring the harness uses |
| `catchlaw-conventions-index` | Invariant 4's proof here is a glyph-and-word assertion; the colour-value ratios are E19's, and `epic.md` risk 9 records why a greyscale screenshot is not the test §4.9 thinks it is |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.9 whole | 56 dp glove targets with 8 dp separation, 200% text scale with no clipping, every control labelled, never colour alone |
| `SPEC.md` | §9.3 | No hardcoded `Directionality`; the ruler's LTR exception is E09's, not this epic's |
| `SPEC.md` | §13 "Accessibility" | Targets ≥ 48 dp (≥ 56 glove); layouts hold at 200% text scale |
| `Flutter-Skills: widget-golden-and-a11y-testing/references/harness-and-mediaquery.md` | whole | The four load-bearing lines, `useDevice`, `MediaQuery` above `MaterialApp`, `pump` versus `pumpAndSettle`, finder policy |
| `Flutter-Skills: widget-golden-and-a11y-testing/references/golden-two-lanes.md` | whole | Why layout goldens are refused; the four things goldens are for; the two lanes; `@Tags(['golden'])`; blocking `--update-goldens` |
| `Flutter-Skills: widget-golden-and-a11y-testing/references/overflow-and-textscale.md` | whole | The loud and silent overflow classes; the three traps; the 3 × 5 × 2 matrix; the fit assertion with `computeLineMetrics`; the anti-clamp check; the four wrong fixes |
| `Flutter-Skills: widget-golden-and-a11y-testing/references/a11y-guidelines-and-limits.md` | whole | Why all four built-in guidelines are advisory only; `await expectLater` on `meetsGuideline`; `isSemantics` and `startNode:`/`endNode:`; the `getSize` target loop; **greyscale is not an independent channel**; what automation cannot cover |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Golden coverage matrix" | The eleven lanes per list screen, and why lanes 6 and 7 are the ones that catch the defect |
| `.claude/skills/lonja-typography/references/arabic-and-scripts.md` | "Zero tracking", "Mixed-script rows", "Review checklist for an ar diff" | Exactly what the `ar` lane exists to prove |
| `.claude/skills/lonja-icons-and-plates/references/engraved-plates.md` | "Plate anatomy and ink weights" | The per-theme stroke values the sunlight lane shows |
| `CONVENTIONS.md` | §6 | Where tests live; the golden matrix budget; `flutter_test_config.dart` is directory-scoped |
| `epics/DECISIONS.md` | D-3 | RTL golden lanes are `ar` only — there is one RTL locale in this product |

## What this delivers

- `app/test/support/harness.dart` — one `pumpApp` extension: `useDevice`, the `MediaQuery` layered
  **above** `MaterialApp` from `.copyWith`, `addTearDown(view.reset)`, and named axes for `locale`,
  `theme`, `density`, `textScaler` and `boldText`.
- `app/test/support/devices.dart` — three presets named by their measured logical size:
  `compact_320`, `small_360`, `medium_412`.
- `app/test/support/reference_fixture.dart` — opens the committed Galicia fixture read-only and
  builds the in-memory `user.db`.
- `app/test/flutter_test_config.dart` — `loadAppFonts()` and the lane configuration, directory-scoped
  per `CONVENTIONS.md` §6.
- `app/test/ui/species/overflow_matrix_test.dart` — device × `textScaler` × `boldText` across the
  three screens, one `testWidgets` per tuple.
- `app/test/ui/species/geometry_test.dart` — `getSize` and `getRect` invariants: targets, the four
  states' presence, group order, header order, tile aspect.
- `app/test/ui/species/a11y_test.dart` — every control labelled, the traversal order, the
  glyph-and-word assertion for every semantic state.
- `app/test/ui/species/goldens/species_goldens_test.dart` — the narrow golden set, tagged.
- `app/test/ui/species/goldens/*.png` — the blessed files, generated in the one pinned environment.
- A CI job change: the golden lane runs `--tags golden` on the pinned Linux runner, the unit lane
  runs `--exclude-tags golden`, and no step passes `--update-goldens`.

## Why it is built this way

**Goldens are refused for layout and kept for four things.** `golden-two-lanes.md` is unambiguous:
a golden *cannot assert anything* — it asserts only that these pixels equal the pixels someone
blessed. Bless a screen of clipped, unreadable Arabic once and it passes forever, green. Layout is
proven more cheaply by computed geometry, and each of those failures names what broke in a sentence.
So the bulk of this task is `getSize`, `getRect` and semantics, and goldens are kept only for what
geometry cannot see:

1. **Glyph shaping** — Arabic cursive joining in the species header and the row name. This is the
   single highest-value golden in the app: `arabic-and-scripts.md` says positive tracking renders
   `هامور` as `ه ا م و ر`, and no geometry assertion can see that.
2. **Mirroring** — the row chevron mirrors, the fish does not. Both directions in one image.
3. **Numeral rendering** — §9.3's numeral-system lever is process-wide and order-dependent, and a
   golden is the only thing that shows which digit glyphs actually rendered.
4. **`CustomPainter` output** — the silhouette and the plate have no widget tree to measure, so the
   sunlight stroke step from 1.60 to 2.10 is seen here and asserted numerically in T04.

**Two lanes, both loading fonts.** `flutter test` runs with Ahem, whose every glyph is an identical
box, so a golden either renders boxes and proves nothing about type, or loads the real font.
The Ahem lane runs on every PR on one pinned Linux box and proves geometry, mirroring and box
layout; the real-font lane runs on a label or nightly and proves joining, ligatures and numeral
glyphs. Both call `loadAppFonts()`; forgetting it renders tofu that differs per machine.

**The matrix is argued, not crossed.** `CONVENTIONS.md` §6 budgets 4–6 screens × 6 locales × 2
themes and says keep it small; `the-four-states.md` publishes eleven lanes per list screen, each of
which already pins its own locale. Crossing the two would be sixty-six images per screen. The set
here is:

| Screen | Lanes |
|---|---|
| S5 (list) | the eleven from `the-four-states.md`, plus one `gl` lane for the empty state's jurisdiction note and the two group headings |
| S6 (list) | the eleven, plus one `gl` lane for the localised family headings — the assertion the screen exists for |
| S2 (not a list) | five: paper/`en`, paper/`ar`, night/`en`, sunlight/`en`, paper-glove/`ar` |

`gl` earns a lane on S5 and S6 and not on S2, because `arabic-and-scripts.md` records that the five
Latin locales share the ramp verbatim — so a `gl` lane proves nothing typographic. What it proves is
**content**: that `family.name_key` and the empty-state body resolved through `content_string` in
Galician rather than falling back to Latin or English. That is a real regression surface and it is
the one the author of §9.1 cared about.

**Lanes 6 and 7 are asserted on text, not only on pixels.** `the-four-states.md` names them as the
lanes reviewers skip and the ones that catch the defect: an empty state that was never authored
renders as a blank frame, and a blank golden passes review far too easily. So every empty-state lane
is paired with a text assertion on the headline in the same test.

**Overflow is never suppressed, and the net is only half the gate.** A `RenderFlex` overflow already
fails a widget test — `DebugOverflowIndicatorMixin` calls `FlutterError.reportError`, the binding
captures it, and `testWidgets` rethrows at test end unless something clears it. So the job is not to
make overflow fail; it is to never lose the net that already exists. `takeException()` to swallow,
assigning `FlutterError.onError`, a copied `ignoreOverflowErrors`, and a `takeException()` in a
global `tearDown` are all banned by `overflow-and-textscale.md`, the last because it clears the
pending exception before `testWidgets` rethrows and silently converts the whole suite's net into a
no-op.

The net is **necessary and not sufficient**. Only a `Flex` child reports; `RenderParagraph` has no
overflow indicator at all, so a clipped `Text` inside a `SizedBox` produces zero errors, a green
test and unreadable words on a real phone. That silent class is caught by the **fit assertion** —
`getRect` the cell, `getSize` the label, `computeLineMetrics().length` for the line ceiling — which
is why rows 33–36 exist alongside the matrix rather than instead of it.

**The matrix is three devices × five scales × two bold values, per screen.**
`overflow-and-textscale.md` sets the scale list at `[1.0, 1.3, 1.5, 2.0, 3.0]`: `1.3` and `1.5`
are there because Android 14+ scales large text less than small, which makes the mid-range the
non-obvious part, and `3.0` is Larger-Accessibility-Sizes / iOS AX5 territory. Thirty tuples per
screen, ninety across the three; each pumps one frame, so the cost is nothing and the coverage is
the product. Overflow is reported **once per `RenderObject`** — the internal flag goes false after
the first report — so the loop goes *around* `testWidgets`, never inside it, or scales 2..n silently
under-report.

**It only reports if the widget paints.** `Offstage` subtrees and content scrolled out of the
viewport never report. Each of the four list states is a different pumped tree, so each gets its own
tuple set rather than riding on the data state's — otherwise the empty state, the skeleton and the
error state are never measured at any scale.

**`boldText` is inert without real fonts.** Under Ahem every glyph is a weight-independent
em-square, so `boldText: true` lays out identically to `false` and the whole bold half of the matrix
asserts nothing while looking thorough. `setUpAll(loadAppFonts)` — which
`app/test/flutter_test_config.dart` already provides for the directory — is what makes the axis and
real advance widths live. Do not treat the bold half of an unloaded matrix as coverage.

**`TextScaler.linear` is a deliberate over-approximation, and it is not device-faithful.** It
stresses large labels harder than a real device would. That is wanted conservatism, and this task
does not claim otherwise anywhere in its output.

**No wrong fix is available.** When the matrix goes red, the four reaches that turn it green and the
product worse are banned outright: `MediaQuery.withClampedTextScaling` and `textScaleFactor` (they
override the user's own OS setting while contrast and tap-target stay green), `FittedBox` or any
auto-shrink (it makes the longest string the smallest and cancels the user's `TextScaler`),
`TextOverflow.ellipsis` or `maxLines` truncation (a truncated label is a different label, and
`lonja-typography` rule 8 already bans it on every serif step here), and a smaller font on the
offending element. The legitimate fixes are shorter ARB copy, a component role change, or making the
region scroll — and the matrix then runs against both variants, never the roomy one alone.

**Never `pumpAndSettle`.** It carries a ten-minute timeout, truncates its stack trace, and hangs
forever on an indefinite indicator. These screens have a 900 ms skeleton pulse that is frozen under
reduced motion; `pump()` for state changes and `pump(Duration)` for the pulse.

**Finders name behaviour, not structure.** `find.bySemanticsLabel` for anything tapped —
it can be written before the widget and survives a layout refactor — and `find.byKey(ValueKey(...))`
for anything measured. `find.byType` on an app widget is banned: renaming a private widget would red
the suite for no reason.

**The four built-in a11y guidelines are advisory tripwires, never the gate.**
`a11y-guidelines-and-limits.md` documents three load-bearing defects.
`MinimumTapTargetGuideline` returns `Evaluation.pass()` **without measuring** any node flush with
the view edge — on S6's edge-to-edge grid that is every perimeter tile, so the guideline goes green
while checking almost nothing. `textContrastGuideline` has an open, unfixed false negative: it picks
foreground and background from a naive light/dark histogram, so white on `0xFAFAFA` passes, and it
cannot see a `CustomPainter` label at all — which is every silhouette and plate in this epic.
`labeledTapTargetGuideline` only checks the label is non-empty, so a node leaking `item_0` passes.
So the gate is an explicit `getSize` loop for targets, `isSemantics` assertions for labels, and a
pure-Dart WCAG ratio over the theme's colour **values** for contrast. Two API facts that look right
and are not: `meetsGuideline` returns an `AsyncMatcher`, so `await expectLater` is mandatory; and
`containsSemantics` is deprecated in favour of `isSemantics`, as `start:`/`end:` are in favour of
`startNode:`/`endNode:`.

**Semantics is already on.** `testWidgets` takes `semanticsEnabled = true` and calls
`ensureSemantics()` itself. A manual `tester.ensureSemantics()` / `handle.dispose()` pair is a
redundant second reference-counted handle and a flake source; if one is ever genuinely needed it is
registered with `addTearDown(handle.dispose)`, never a trailing call that a throwing `expect` skips.

**Invariant 4's proof here is glyph-and-word — and a greyscale image would prove nothing extra.**
`product-invariants.md` names a greyscale golden and §4.9 promises the result "passes a greyscale
screenshot test". `a11y-guidelines-and-limits.md` shows why that framing carries no information:
`Color.computeLuminance()` is chroma-blind, any correct `gray(c)` reconstructs a grey of exactly
that luminance, so `wcag(gray(a), gray(b)) == wcag(a, b)` for **all** a and b. Greyscale is not an
independent channel. The real concern it gestures at is a **chroma-only distinction** — two states
at near-equal luminance that look different in colour and collapse to nothing without it — and that
is caught by asserting the WCAG luminance ratio between the two state colours directly. This task
therefore asserts the composition every state must have (glyph **and** word **and** hue) and leaves
the colour-value ratios to E19, which owns the whole-app pass. `epic.md` risk 9 records the framing
correction so E19 writes a luminance-ratio test rather than a screenshot that cannot fail.

**Nothing here claims the suite "tests accessibility".** Automated checks catch a small minority of
real accessibility issues; Flutter ships four guidelines and one is known-broken. Overclaiming is
exactly how an inaccessible app ships green, so neither the commit message, the definition of done,
nor any comment in the delivered files makes that claim. Switch Access and Switch Control cannot be
tested automatically at all, and TalkBack and VoiceOver actually announcing these labels belongs on
E21's pre-release checklist.

**Rejected: `golden_toolkit`.** Discontinued at v0.15.0 with no replacement, and
`golden-two-lanes.md` says never to recommend it — tutorials still do, and they are stale.
`alchemist` is the maintained option, with the caveat that its CI mode obscures text with coloured
blocks and therefore proves geometry rather than glyphs, which is precisely why the real-font lane
exists separately.

**Rejected: blessing goldens in CI.** A step that runs `--update-goldens` turns the suite into a
ratchet that approves whatever shipped. Regeneration is a deliberate, reviewed, local act in the one
pinned environment, with a titled commit.

## Tests first

These *are* the tests, so "tests first" means the assertions are written against the screens as
T03–T07 left them and **must fail before the harness exists** — every one of them fails on a missing
`pumpApp`. Do not write the harness first and then fit assertions to it.

| # | Test name | Case | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `pumpApp pins the logical surface at the device preset` | `compact_320` | `MediaQuery.size` is 320 × 640 | The default surface is 800 × 600 — wider than any phone, so unpinned everything fits and the shipped phone is broken |
| 2 | `pumpApp multiplies physicalSize by the device pixel ratio` | dpr 3.0 | `physicalSize` is 960 × 1920 | `Size(320, 640)` at dpr 3 is a 107 × 213 logical surface; getting this wrong makes every other lane meaningless |
| 3 | `pumpApp layers MediaQuery above MaterialApp` | `textScaler` 2.0 | a descendant reads 2.0 | Placed below `MaterialApp` the override is shadowed and every scale lane silently asserts 1.0 |
| 4 | `pumpApp preserves the pinned size when an axis is overridden` | `boldText` true | size still 320 × 640 | A bare `MediaQueryData()` zeroes the view-derived size and the test measures a 0 × 0 screen, green |
| 5 | `pumpApp resets the view after each test` | two tests in one file | second sees the default | A leaked view size poisons every later test, in a file nobody edited |
| 6–35 | `SpeciesSearchScreen renders without overflow at <device> and scale <s> and bold <b>` | 3 devices × {1.0, 1.3, 1.5, 2.0, 3.0} × {false, true} = 30 | `takeException()` null | §4.9's 200% promise, over the scale list `overflow-and-textscale.md` sets; the loop is around `testWidgets` because overflow reports once per `RenderObject` |
| 36–65 | `SpeciesBrowseScreen renders without overflow at <device> and scale <s> and bold <b>` | same 30 | null | The grid is where a scale bites first — a caption inside a computed tile, at 3.0 on a 320 dp screen |
| 66–95 | `SpeciesDetailScreen renders without overflow at <device> and scale <s> and bold <b>` | same 30 | null | The header is three lines of three faces; the mid-range 1.3 and 1.5 are where a bilingual line breaks first |
| 96–101 | `SpeciesSearchScreen renders its <state> state without overflow at scale <s>` | {error, loading, empty} × {1.0, 2.0, 3.0} | null | Trap 3: overflow only reports if the widget **paints**, so a state behind a branch is never measured by the data state's tuples |
| 102 | `SpeciesSearchScreen keeps the row hint inside the row rect at every scale` | 5 scales | `getSize` ≤ cell minus inset, lines ≤ 2 | The silent class: `RenderParagraph` reports nothing, so the net alone cannot see a clipped hint |
| 103 | `SpeciesBrowseScreen keeps the tile caption inside the tile rect at every scale` | 5 scales | fits, lines ≤ 3 | `structural-layout.md`: the real constraint is that the label fits, never a pixel floor |
| 104 | `SpeciesDetailScreen keeps the species header inside its measure at every scale` | 5 scales | fits, no clip | The header is the one thing on S2 the fisher must read |
| 105 | `SpeciesSearchScreen honours the text scale and never clamps it` | 1.0 then 2.0 | scaled height > base × 1.8 | The grep catches the named API; only this catches a clamp built by hand, while contrast and tap-target stay green |
| 106 | `SpeciesSearchScreen aligns every row hint on a shared end edge` | 5 rows | equal `right` in LTR | Tabular figures exist so `45 cm` and `188 cm` can be compared at a glance in swell |
| 107 | `ar - SpeciesSearchScreen aligns every row hint on a shared start-relative edge` | locale `ar` | equal `left` | `TextAlign.right` pins the figure to the physical right, which is the START of the row in Arabic |
| 108 | `SpeciesSearchScreen shares a row top edge across the silhouette, name and hint` | 3 rows | equal `top` within 0.5 | The geometry invariant that replaces a layout golden, and it names which slot moved |
| 109 | `SpeciesSearchScreen labels every interactive control` | default | no unlabelled tappable node | §4.9: every control labelled; an unlabelled glyph is announced as "image" at 05:40 |
| 110 | `SpeciesBrowseScreen labels every interactive control` | default | same | The app-bar Identify action is the one most likely to ship bare |
| 111 | `SpeciesSearchScreen keeps the species id out of every semantic label` | any row | label does not contain the key string | The check no guideline makes: `labeledTapTargetGuideline` passes a label that is an internal id |
| 112 | `SpeciesDetailScreen labels the plate with a description of the drawing` | plate present | non-empty label, no `PL.` in it | The figure number is a printed-document affordance, not what a reader needs first |
| 113 | `SpeciesSearchScreen traverses the search field before the results` | default | `startNode`/`endNode` order | Reachability and traversal order are independent, and both are required |
| 114 | `SpeciesSearchScreen measures every row target at 48 dp or more at 200 percent scale` | scale 2.0, `compact_320` | ≥ 48 × 48 | An explicit `getSize` loop, because `MinimumTapTargetGuideline` skips every node flush with the view edge without measuring |
| 115 | `glove - SpeciesSearchScreen separates adjacent targets by at least 8 dp` | glove density | gaps ≥ 8 | §4.9's separation figure; targets that touch are mis-hits with a wet glove |
| 116 | `glove - SpeciesBrowseScreen tiles measure at least 66 dp` | glove density | ≥ 66 | `LonjaTargets.gloveControl` |
| 117 | `SpeciesSearchScreen renders a glyph and a word beside every semantic hue` | protected and closed rows | glyph and word for each | Invariant 4's composition; a hue on its own states nothing to a reader who cannot separate it |
| 118 | `SpeciesSearchScreen renders a glyph and a word on the stale bar` | expired pack | glyph and word | Ochre is not oxblood, and the word is what carries that distinction |
| 119 | `SpeciesSearchScreen renders its four states, each with its authored headline` | error, loading, empty, data | each headline present | The lanes reviewers skip: a blank golden passes review, a missing headline does not |
| 120 | `SpeciesBrowseScreen renders its four states, each with its authored headline` | same | same | The same defect, on the other list screen |
| 121 | `ar - SpeciesDetailScreen header joins the Arabic name` | real-font lane, `ar` | matches blessed | Geometry cannot see `هامور` rendered as `ه ا م و ر`; this is the highest-value golden in the app |
| 122 | `RTL - SpeciesSearchScreen mirrors the chevron and not the silhouette` | Ahem lane, `ar` | matches blessed | Two mirroring decisions in one image, and they point opposite ways |
| 123 | `ar - SpeciesSearchScreen renders the row hint numerals` | real-font lane, `ar` | matches blessed | §9.3's numeral lever is process-wide and order-dependent; only an image shows which digits arrived |
| 124 | `SpeciesBrowseScreen renders family headings in Galician` | Ahem lane, `gl` | matches blessed | The content regression the screen exists to prevent: a fallback to Latin family names |
| 125 | `SpeciesSearchScreen renders the empty state jurisdiction note in Galician` | Ahem lane, `gl` | matches blessed | The second content lane; the note quotes a count and a jurisdiction name, both resolved |
| 126 | `sunlight - SpeciesBrowseScreen draws the thickened silhouette outline` | Ahem lane, sunlight | matches blessed | `CustomPainter` output has no widget tree to measure; T04 asserts 2.10 numerically, this shows it |
| 127 | `sunlight - SpeciesSearchScreen draws solid hairlines and deletes every grey` | Ahem lane, sunlight | matches blessed | Sunlight collapses `ink-muted` and `ink-faint` to `sun-ink` and makes dotted rules solid |
| 128 | `SpeciesDetailScreen keeps the plate stroke unthickened in the night theme` | Ahem lane, night | matches blessed | Night is deliberately NOT thickened — a light stroke on dark blooms — and only an image catches a wrong theme branch |
| 129 | `glove - SpeciesSearchScreen raises the row without re-laying it out (RTL)` | Ahem lane, `ar` glove | matches blessed | Rule 12: glove raises the row, it does not reflow; a reflow doubles the matrix and ships a layout nobody reviewed |

```dart
// app/test/support/harness.dart
import 'package:catchlaw/theme/lonja_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class Device {
  const Device(this.name, this.logicalSize, this.dpr);
  final String name;
  final Size logicalSize;
  final double dpr;

  static const compact320 = Device('compact_320', Size(320, 640), 2.0);
  static const small360 = Device('small_360', Size(360, 780), 3.0);
  static const medium412 = Device('medium_412', Size(412, 892), 2.625);
}

void useDevice(Device d) {
  final view = TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
  view.devicePixelRatio = d.dpr;
  view.physicalSize = d.logicalSize * d.dpr; // PHYSICAL pixels — always multiply
  addTearDown(view.reset); // a leaked size poisons every later test in the file
}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget child, {
    List<Override> overrides = const [],
    Locale locale = const Locale('en'),
    LonjaThemeMode theme = LonjaThemeMode.paper,
    LonjaDensity density = LonjaDensity.paper,
    double textScale = 1.0,
    bool boldText = false,
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: Builder(
          builder: (context) => MediaQuery(
            // copyWith, never a bare MediaQueryData(): that would zero the
            // view-derived size useDevice just pinned, and the test would
            // measure a 0x0 screen and pass.
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              boldText: boldText,
            ),
            // ABOVE MaterialApp: MaterialApp inserts no MediaQuery of its own,
            // so this one is the nearest ancestor and wins.
            child: MaterialApp(
              locale: locale,
              supportedLocales: const [
                Locale('ar'), Locale('en'), Locale('es'),
                Locale('gl'), Locale('ca'), Locale('pt', 'BR'), // DECISIONS D-3
              ],
              theme: LonjaTheme.of(theme, density),
              home: child,
            ),
          ),
        ),
      ),
    );
  }
}
```

```dart
// app/test/ui/species/overflow_matrix_test.dart
import 'package:catchlaw/ui/species/widgets/species_search_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  // Real fonts, or boldText is metrically inert under Ahem and half the matrix
  // asserts nothing. flutter_test_config.dart already does this for the
  // directory; it is repeated here so the file is honest read on its own.
  setUpAll(loadAppFonts);

  for (final device in [Device.compact320, Device.small360, Device.medium412]) {
    // 1.3 and 1.5 are in the list because Android 14+ scales large text less
    // than small, so the mid-range is the non-obvious part; 3.0 is iOS AX5.
    for (final scale in const <double>[1.0, 1.3, 1.5, 2.0, 3.0]) {
      for (final bold in const <bool>[false, true]) {
        // One testWidgets per tuple: overflow is reported once per RenderObject
        // and the flag never resets, so a loop INSIDE a single test silently
        // under-reports every scale after the first.
        testWidgets(
          'SpeciesSearchScreen renders without overflow at ${device.name} '
          'and scale $scale and bold $bold',
          (tester) async {
            useDevice(device);
            await tester.pumpApp(
              const SpeciesSearchScreen(),
              textScale: scale,
              boldText: bold,
              overrides: [/* stub view model with mixed hints */],
            );
            await tester.pump();

            // NEVER takeException() to swallow this, and never in a global
            // tearDown — that clears the pending exception before testWidgets
            // rethrows and turns the whole suite's net into a no-op.
            expect(tester.takeException(), isNull,
                reason: 'S5 overflowed at ${device.name} x$scale bold=$bold');
          },
        );
      }
    }
  }
}
```

```dart
// app/test/ui/species/geometry_test.dart — the silent class the net cannot see
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

int linesOf(WidgetTester tester, Finder text) =>
    tester.renderObject<RenderParagraph>(text).computeLineMetrics().length;

void main() {
  setUpAll(loadAppFonts);

  for (final scale in const <double>[1.0, 1.3, 1.5, 2.0, 3.0]) {
    testWidgets('SpeciesBrowseScreen keeps the tile caption inside the tile rect at scale $scale',
        (tester) async {
      useDevice(Device.compact320); // the tightest shipped layout
      await tester.pumpApp(const SpeciesBrowseScreen(), textScale: scale);
      await tester.pump();
      expect(tester.takeException(), isNull); // the loud class

      for (final tile in kBrowseFixtureTiles) {
        final cell = tester.getRect(find.byKey(ValueKey('tile_${tile.speciesId}')));
        final label = find.text(tile.displayName);
        final text = tester.getSize(label);

        // RenderParagraph has no overflow indicator: a clipped caption reports
        // nothing at all. The inset comes from the theme, never a design number
        // retyped here.
        expect(text.height, lessThanOrEqualTo(cell.height - kTileInset * 2),
            reason: '"${tile.displayName}" needs ${text.height}dp inside a '
                '${cell.height}dp tile at x$scale — it is being clipped silently');
        expect(linesOf(tester, label), lessThanOrEqualTo(3));
      }
    });
  }

  testWidgets('SpeciesSearchScreen honours the text scale and never clamps it', (tester) async {
    useDevice(Device.compact320);
    await tester.pumpApp(const SpeciesSearchScreen());
    final base = tester.getSize(find.text('Ameixa babosa')).height;

    await tester.pumpApp(const SpeciesSearchScreen(), textScale: 2.0);
    final scaled = tester.getSize(find.text('Ameixa babosa')).height;

    // 1.8, not 2.0: tolerate line-height rounding, still fail hard on a clamp.
    // No guideline catches this — contrast and tap-target stay green while the
    // text simply stops growing.
    expect(scaled, greaterThan(base * 1.8),
        reason: 'text did not grow at 2.0x — someone clamped TextScaler');
  });
}
```

```dart
// app/test/ui/species/a11y_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';
import '../../../testing/models/k_species.dart';

void main() {
  testWidgets('SpeciesSearchScreen keeps the species id out of every semantic label',
      (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(const SpeciesSearchScreen(), overrides: [/* … */]);
    await tester.pump();

    // Semantics is already on: testWidgets defaults semanticsEnabled to true and
    // calls ensureSemantics itself. A manual handle here would be a redundant
    // second reference-counted handle and a flake source.
    final node = tester.getSemantics(find.byKey(ValueKey('row_${kSpeciesHamour.id}')));

    // isSemantics, not the deprecated containsSemantics.
    expect(node, isSemantics(isButton: true, hasTapAction: true, isFocusable: true));

    // The check NO built-in guideline makes: labeledTapTargetGuideline passes a
    // label that is an internal id.
    expect(node.label, isNot(contains('row_${kSpeciesHamour.id}')));
    expect(node.label, contains('Hamour'));
  });

  testWidgets('SpeciesSearchScreen measures every row target at 48 dp or more at 200 percent scale',
      (tester) async {
    useDevice(Device.compact320);
    await tester.pumpApp(const SpeciesSearchScreen(), textScale: 2.0, overrides: [/* … */]);
    await tester.pump();

    // An explicit getSize loop, because MinimumTapTargetGuideline returns
    // Evaluation.pass() WITHOUT measuring any node flush with the view edge.
    for (final row in kSearchFixtureRows) {
      final size = tester.getSize(find.byKey(ValueKey('row_${row.speciesId}')));
      expect(size.height, greaterThanOrEqualTo(48.0));
    }
  });
}
```

```dart
// app/test/ui/species/goldens/species_goldens_test.dart
@Tags(['golden'])
library;

import 'package:catchlaw/ui/species/widgets/species_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/harness.dart';

void main() {
  testWidgets('ar - SpeciesDetailScreen header joins the Arabic name', (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesDetailScreen(speciesId: 1),
      locale: const Locale('ar'),
      overrides: [/* stub account: هامور Hamour · Epinephelus coioides */],
    );
    await tester.pump();

    // Geometry cannot see هامور rendered as ه ا م و ر. This is the one thing
    // only a real-font image can prove, and it is why zero tracking is a rule.
    await expectLater(
      find.byKey(const ValueKey('species_header')),
      matchesGoldenFile('ar_species_header.png'),
    );
  });

  testWidgets('SpeciesBrowseScreen renders family headings in Galician',
      (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      const SpeciesBrowseScreen(),
      locale: const Locale('gl'),
      overrides: [/* stub groups with gl family names */],
    );
    await tester.pump();

    // The content regression this screen exists to prevent: a fallback to
    // Latin family names on a Galician grid (SPEC §4.3, §9.1).
    await expectLater(
      find.byType(SpeciesBrowseScreen),
      matchesGoldenFile('gl_browse_family_headings.png'),
    );
  });

  // … one test per golden row in the table above
}
```

**Run:** `cd app && flutter test test/ui/species/ --exclude-tags golden` → every non-golden row
fails on the missing harness. Then `flutter test test/ui/species/ --tags golden` → every golden
fails with no blessed file. Bless once, in the pinned environment, in a titled commit.

If a row passes early, the test is wrong, and in this task the early pass is the dangerous failure
mode rather than a curiosity. Three shapes produce one: a harness that pins nothing, so the screen
is laid out on the 800 × 600 default and everything fits; a `MediaQuery` placed **below**
`MaterialApp`, so every scale and bold tuple silently asserts 1.0 and `false`; and a finder that
matches nothing, so a `findsNothing` assertion passes vacuously. Tests 1–5 exist to make the first
two impossible; for the third, every negative assertion is paired with a positive one in the same
test, so a finder that matches nothing fails on the positive half.

## Implementation outline

1. Write `harness.dart` and `devices.dart` with the four load-bearing lines. Tests 1–5 are the
   harness's own tests and go first, because a harness that silently zeroes the surface makes every
   later lane a false green.
2. `flutter_test_config.dart` at `app/test/` — directory-scoped and scanned upward, per
   `CONVENTIONS.md` §6 — calling `loadAppFonts()` and configuring the two lanes.
3. Wire every side-effecting provider as a seam that throws `UnimplementedError` until overridden,
   so an un-overridden dependency fails loudly instead of constructing a live database.
4. The overflow matrix next: three files, one loop nest each, `setUpAll(loadAppFonts)` at the top,
   one `testWidgets` per tuple, plus the per-state tuples for `error`, `loading` and `empty` — those
   trees never paint under the data state's tests and would otherwise be measured at no scale at
   all. Fix what it finds by changing the layout or the ARB copy — never with `FittedBox`, never
   with `maxLines`, never by clamping the scaler.
5. The geometry file: the fit assertions with `computeLineMetrics`, the anti-clamp behavioural
   check, the shared-end-edge invariant in both directions, target sizes in both densities, and the
   four-state presence checks paired with their headline text.
6. The a11y file: `isSemantics` assertions, the label-does-not-leak-the-id check, the explicit
   `getSize` target loop, `startNode:`/`endNode:` traversal, and the glyph-and-word assertion per
   semantic state. Keep the four built-in guidelines as one-line advisory tripwires, each with
   `await expectLater` — they are a regression alarm, not the gate.
7. The goldens last, narrowed to the nine rows above. Tag the library, not each test. Generate and
   commit the blessed files in the one pinned environment.
8. Split the CI lanes: `--exclude-tags golden` on every PR, `--tags golden` on the pinned Linux
   runner. Assert in the pipeline file that no step passes `--update-goldens`.
9. Re-run everything. All 129 rows green, T01–T07 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 129 rows pass, and each failed first — the non-golden rows on a missing harness, the
      golden rows on a missing blessed file.
- [ ] `addTearDown(view.reset)` is in `useDevice`, and test 5 proves a leak would be caught.
- [ ] `MediaQuery` is layered above `MaterialApp` and built with `.copyWith`; test 4 proves the
      pinned size survives an axis override.
- [ ] The overflow matrix is 3 devices × 5 scales × 2 bold values **per screen**, plus the three
      non-data states, and `loadAppFonts` runs before it — an unloaded bold axis is not coverage.
- [ ] `grep -rn 'pumpAndSettle\|ignoreOverflowErrors\|FlutterError.onError\|withClampedTextScaling\|textScaleFactor' app/test/ app/lib/`
      returns nothing, and no `takeException()` appears in any `tearDown`.
- [ ] `grep -rn 'containsSemantics\|simulatedAccessibilityTraversal(start:' app/test/` is empty —
      `isSemantics` and `startNode:`/`endNode:` are the current API.
- [ ] Every `meetsGuideline` call is `await expectLater`, and no target or contrast claim rests on a
      built-in guideline alone.
- [ ] At least one semantics test asserts a label does **not** contain its widget's key string.
- [ ] `grep -rn 'find.byType(Species\|find.byType(Lonja' app/test/` is empty except where the
      finder targets a framework type — behaviour is found by semantics label, geometry by key.
- [ ] Every golden test is inside a `@Tags(['golden'])` library, and `--exclude-tags golden` runs
      the whole suite green without a blessed file present.
- [ ] The golden set is nine images, each justified by one of the four things geometry cannot see.
- [ ] The `gl` lanes assert **content** — localised family headings and the jurisdiction note — and
      are not a typographic duplicate of `en`.
- [ ] Both empty-state lanes assert their headline text in the same test as the image.
- [ ] No CI step passes `--update-goldens`.
- [ ] `ar` is the only RTL lane (D-3).
- [ ] Nothing in the commit message, the delivered files or this checklist claims the suite "tests
      accessibility" — automation catches a small minority, and overclaiming is how an inaccessible
      app ships green.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze
cd app && flutter test --exclude-tags golden
cd app && flutter test --tags golden          # pinned Linux runner only
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-forms-and-controls/scripts/check_lonja_controls.sh     app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh          app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
# from the Flutter-Skills plugin, per CONVENTIONS.md §4:
#   widget-golden-and-a11y-testing  scripts/check-test-hygiene.sh  app/test
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(species): pin S5, S6 and S2 with geometry, semantics and two golden lanes

Layout is proved by computed geometry, not by blessed pixels. A golden cannot
assert anything — it asserts only that these pixels equal the pixels somebody
blessed — so a screen of clipped Arabic blessed once passes forever, green.
Goldens are kept for the four things geometry cannot see: cursive joining,
mirroring, numeral glyphs and CustomPainter output. Nine images, each justified.

The gl lanes are content lanes, not typographic ones: the five Latin locales
share the ramp verbatim, so what a Galician image proves is that family.name_key
and the empty-state jurisdiction note resolved through content_string instead of
falling back to Latin. That is the regression SPEC §4.3 and §9.1 care about.

The overflow matrix is one testWidgets per device x scale x bold tuple, because
an overflow is reported once per RenderObject and a loop inside one test hides
every failure after the first. Nothing suppresses it — and because a clipped
RenderParagraph reports nothing at all, the net is paired with a fit assertion
that measures the label against its computed cell.

The four built-in accessibility guidelines are kept as advisory tripwires and
are not the gate: MinimumTapTargetGuideline passes edge-flush nodes without
measuring them, which on an edge-to-edge grid is every perimeter tile, and
textContrastGuideline has an open false negative. Targets are measured with an
explicit getSize loop. This suite does not test accessibility and does not say
that it does.

Task: E08/T08
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
