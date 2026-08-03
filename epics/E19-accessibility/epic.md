# E19 — Accessibility, sunlight and glove modes

| | |
|---|---|
| **Branch** | `epic/19-accessibility` |
| **Release** | **v2** — `epics/RELEASES.md`, D-22 |
| **After** | E08–E18 merged — every screen S1–S23 and every dialog D1–D5 exists |
| **Tasks** | 7 |
| **Spec** | `SPEC.md` §4.9 in full, §13 (the accessibility row: WCAG 2.1 AA equivalent, ≥ 4.5:1 and ≥ 7:1 in sunlight, ≥ 48 dp and ≥ 56 dp, 200% text scale), §6 (every screen and every dialog), §3 (one thumb, in sunlight, wearing wet gloves, under five seconds) |
| **Guide** | `FLUTTER_GUIDE.md` Part 6.4 (the test budget and the two golden points), Part 8.1 (never return widgets from a helper method), Part 8.2 (`const`), §6.1 (test naming), §6.2 (where tests live) |
| **Packages** | `app/` only — `app/test/a11y/`, `app/testing/a11y/`, `app/test/utils/harness.dart`, and fixes inside `app/lib/ui/` and `app/lib/theme/`. **Nothing under `packages/rule_engine/`** (D-7: it holds no user-visible sentence and paints nothing) |
| **Commit scopes** | `a11y` for T01, T02, T03, T05, T06, T07; `theme` for T04 (`CONVENTIONS.md` §3) |

## What this epic achieves

`SPEC.md` §4.9 stops being seven rows in a table that somebody once read and becomes seven
assertions that run on every pull request. When this merges: every control on all 28 surfaces
carries a label a screen reader can speak and none of them leaks a widget key; the finding is
announced as a live region, so TalkBack and VoiceOver read *Below the minimum — 38 centimetres
measured, minimum 45, total length* without the user navigating to it; every target measures at
least 48 dp, and at least 56 dp with at least 8 dp of separation in glove mode, measured by
`getSize` on all 28 surfaces in both densities rather than by eye on one; every layout survives a
200% text scale on a 320 dp surface with nothing clipped and nothing overlapping; every text pair
clears 4.5:1 where it actually composites, and 7:1 in sunlight; a greyscale golden proves that no
state anywhere is carried by hue alone; the pass and fail haptics are provably different sequences
and survive reduce-motion; and every primary action sits in the bottom third of the viewport where
one thumb can reach it.

The point is not the pass. The point is that **each of these is now a test that fails**, so the next
pull request cannot quietly undo it. `SPEC.md` §4.9's "done looks like" column is written in the
present tense — *"Result and species tiles pass at 56 dp"*, *"No clipping or overlap at 200% on a
5-inch screen"*, *"Passes a greyscale screenshot test"* — and until this epic there was no `pass`
anywhere in the repository that meant those sentences.

E20 then runs the same surfaces through six locales and an RTL flip on top of a floor that already
holds, and E21's §14 device pass starts from a build whose automated floors are green, so the
manual time goes to what only a device can show: TalkBack actually speaking, and a wet glove
actually landing.

## Where we are now

The branch is cut from a `main` carrying eighteen merged epics. What matters here:

- **E07** (`app/lib/theme/`, D-2) — `LonjaPrimitives`, the `LonjaTokens` `ThemeExtension` with its
  thirteen slots plus `density`, three hand-authored themes selected by the three-value `LonjaSkin`
  enum, and `LonjaDensity.standard` (`tapMin` 48, `tapGap` 4, `rowHeight` 56) versus `.glove`
  (`tapMin` 56, `tapGap` 8, `rowHeight` 72). E07 already asserts every slot's contrast figure
  against `surface` and `surfaceSunk` in all three themes, and already runs a component-level
  greyscale lane over the button rungs. **This epic does not repeat either of those.**
- **E08–E18** — all 23 screens and all 5 dialogs of `SPEC.md` §6, their widgets under
  `app/lib/ui/<feature>/`, the shared shell and nav strip at `app/lib/ui/core/ui/app_shell.dart`
  and `lonja_nav_strip.dart` (E12), and the result surface at
  `app/lib/ui/result/widgets/result_verdict_panel.dart` with `result_haptics.dart` beside it (E10).
- **E10/T02** already sets `liveRegion: true` on the merged stamp node, already narrows the panel's
  watch with `select` so a moving ruler does not re-announce, and already fixes the haptic patterns:
  `.meets` fires one `HapticFeedback.lightImpact()`, every adverse category fires
  `HapticFeedback.heavyImpact()` twice separated by 120 ms. **This epic does not re-argue those
  numbers.** E10's own Risks hand the confirmation here.
- **E06** — `app/test/flutter_test_config.dart` loads a font with Arabic coverage, which is what
  makes any golden in `app/test/` worth rendering (`FLUTTER_GUIDE.md` §6.4, point 1).
- **E12** — `app/test/utils/harness.dart` with `pumpLonja(...)`, carrying theme, density, locale and
  `MediaQuery`, and the `ValueKey('<screen>.<control>')` key convention (`check.search`).

What does not exist: any statement about the app **as a whole**. Every assertion above is local to
the widget that shipped with it. There is no list of the 28 surfaces, nothing that fails when a
29th arrives unaudited, no cross-surface tap-target sweep, no text-scale matrix beyond the single
screens that thought to add one, no composited contrast test, no screen-level greyscale golden, and
no test anywhere that says where a primary action must sit.

## Why this epic exists here in the order

**It cannot come earlier**, and the reason is the failure mode `CONVENTIONS.md` §7 names for gate
scripts: *a gate that scans a path with no files reports success*. An accessibility suite has the
same shape. Run the tap-target sweep after E12 and it audits six screens and passes; the fourteen
screens that arrive later are never measured, and the suite's green is a statement about a tree that
no longer exists. `SPEC.md` §15 places this at step 17, after every UI step, for that reason.

**It must not come later.** E20 multiplies whatever is here by six locales and an RTL flip: a
fixed-height row that clips at 200% clips six times in E20 and is diagnosed six times. E21 executes
§14 on physical devices, and the only manual time worth spending is on what automation genuinely
cannot cover — TalkBack and VoiceOver actually announcing, the focus highlight actually visible, a
switch actually escaping a modal (`widget-golden-and-a11y-testing/references/a11y-guidelines-and-limits.md`
is explicit that Switch Access cannot be tested automatically at all). Spending that time finding a
44 dp icon button instead is the waste this epic exists to prevent.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | Semantics coverage, and the result as a live region | `T01-semantics-and-live-region.md` | L | — |
| T02 | Targets: 48 dp, 56 dp in glove mode, 8 dp apart | `T02-tap-targets-and-glove-density.md` | M | T01 |
| T03 | Two hundred per cent text on a five-inch screen | `T03-two-hundred-per-cent-text.md` | L | T01 |
| T04 | Contrast: 4.5:1, and 7:1 in sunlight | `T04-contrast-floors.md` | M | T01 |
| T05 | The greyscale golden | `T05-the-greyscale-golden.md` | M | T01 |
| T06 | Haptics that differ | `T06-haptics-that-differ.md` | S | T01 |
| T07 | One-handed reach | `T07-one-handed-reach.md` | S | T01, T02 |

T01 is first because it builds `kAuditedSurfaces`, the registry of all 28 surfaces with their
control keys, and every task after it is a loop over that list. T02–T06 are independent of each
other and may be executed in any order; T07 reads T02's separation helper.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once the epic is whole:

- [ ] All 7 tasks committed, one commit each, every `Task: E19/T<nn>` trailer present.
- [ ] `app/testing/a11y/audited_surfaces.dart` lists **28** surfaces — `S1`–`S23` and `D1`–`D5` —
      and a test fails if any `SPEC.md` §6 id is missing from the list.
- [ ] Every surface in that list is pumped by at least four of the seven audits, and the six
      core-loop surfaces (S1, S2, S3, S5, S8, S9) by all seven.
- [ ] `cd app && flutter test` green, including the 176 generated text-scale cases of T03.
- [ ] Every tappable node on every surface has a non-empty label that contains no widget key, and
      the count of tap-action nodes on each surface equals that surface's registered `targetKeys` —
      so a control added without a registry row fails the suite (`CONVENTIONS.md` §7's empty-scan
      failure mode, closed).
- [ ] Exactly **one** live region exists in the app, on the verdict stamp, and it re-announces when
      the finding changes and not when the theme, the density or the scroll offset changes.
- [ ] Every target measures ≥ 48 dp standard and ≥ 56 dp glove, with ≥ 4 dp and ≥ 8 dp separation,
      on all 28 surfaces, at scale 1.0 and 2.0 (`SPEC.md` §4.9, §13).
- [ ] Nothing overflows and no label is silently clipped at `TextScaler.linear(2.0)` on a 320 dp and
      a 360 dp surface, in both densities, with `boldText` both ways.
- [ ] Every composited text pair clears 4.5:1, and every sunlight pair clears **7:1** (§13).
- [ ] Six greyscale goldens exist, generated on Linux CI only, and the four verdict categories are
      pairwise distinguishable by glyph, headline and the presence or absence of the measurement
      sub-line with hue removed (invariant 4).
- [ ] The pass and fail haptic sequences are asserted to differ, and both still fire with
      `disableAnimations: true`.
- [ ] Every surface that declares a primary action places it wholly within the bottom third of the
      viewport, at scale 1.0 and 2.0, in both densities; every surface that declares none is
      asserted to build none.
- [ ] The four built-in guidelines (`androidTapTargetGuideline`, `iOSTapTargetGuideline`,
      `labeledTapTargetGuideline`, `textContrastGuideline`) run over the core-loop surfaces via
      `await expectLater`, labelled advisory in the test name, and are **not** anybody's gate.
- [ ] No test, commit message or PR body in this epic claims the suite "tests accessibility"
      (`a11y-guidelines-and-limits.md`, "State the ceiling before writing a line").
- [ ] Gates clean against `app/lib`, each with its explicit target directory (D-1):
      `check_app_invariants.sh`, `check_lonja_tokens.sh`, `check_lonja_type.sh`,
      `check_lonja_buttons.sh`, `check_lonja_verdict.sh`, plus
      `tools/gates/no_directional_geometry.sh` (D-8).
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin --delete-branch` (D-9).

## Risks and the things that will bite

**1. The 44 dp icon button and the 46 dp compact action are below `SPEC.md` §13's floor.**
`lonja-buttons/references/variant-ladder-and-states.md` publishes an icon-only box of 44 × 44 dp in
standard density and a compact action height of 46 dp. §13 says *targets ≥ 48 dp*, and
`lonja-design-tokens/references/token-tables.md` publishes `LonjaDensity.standard.tapMin = 48`.
E07's Risks record the same clash and E07/T07 already resolved it *for the button widget* by binding
it to `LonjaTokens.density`. **What bites here:** any screen from E08–E18 that reached for a raw
44 dp `IconButton` box, or a compact rung, still ships below the floor and only a whole-app sweep
finds it. T02 asserts 48/56 and fixes what fails; it does not re-open the decision. **What would
resolve it properly:** a correction to `variant-ladder-and-states.md` replacing 44/46 with 48, so
the two references stop disagreeing — that edit is not this epic's to make.

**2. The ochre stale-bar ground `#E8E0C6` is not one of the 25 primitives.**
`lonja-verdict-and-status`'s worked example and `verdict-anatomy.md` both name `#E8E0C6` as the bar's
ground, and `token-tables.md`'s pigment box does not contain it. Until it exists as a primitive with
a measured L\*, T04 cannot write a contrast row for the bar's text against its actual ground — and
`check_lonja_tokens.sh` check 1 fails a raw hex outside `lib/theme/` anyway, so E10/T06 must already
have bound it to something. **What resolves it:** read what E10/T06 actually bound; if it is a new
primitive, T04 asserts its row; if the bar was re-based onto `surfaceSunk`, T04 asserts that pair
instead. Do not invent a hex.

**3. The harness may not carry the axes this epic needs.** E12 established
`app/test/utils/harness.dart` with `pumpLonja(...)` for theme, density, locale and `MediaQuery`;
E10 imports a `harness.dart` from `app/test/ui/`. Nothing guarantees either pins
`tester.view.physicalSize` — and an unpinned layout test runs on the 800 × 600 default, wider than
any phone, where everything fits and the suite is green
(`widget-golden-and-a11y-testing` rule 1). **Mitigation:** T01's first act is to read the harness
and extend it with `useDevice(Device)`, `textScaler` and `boldText` if they are absent — extend, do
not fork. If two harnesses exist, T01 converges them; that cost is real and is why T01 is an L.

**4. `textContrastGuideline` false-passes, and cannot see the ruler at all.** It screenshots the
layer and attributes foreground and background by a naive light/dark histogram: white text on
`#FAFAFA` passes. It also only sees text findable through `find.text`, so every numeral the ruler's
`CustomPainter` draws (E09) is invisible to it. **Mitigation:** T04's gate is a pure-Dart ratio over
token values; the guideline runs as an advisory tripwire only, and the ruler's painted contrast is
asserted on the token pair it paints with and confirmed by hand in E21.

**5. Suite time.** T03 generates 176 `testWidgets`, one pumped frame each, and T02/T04/T07 add
roughly 150 more. `testing-strategy` rule 11 is blunt about the consequence: a suite that costs
minutes gets skipped, and a skipped suite is a distrusted one. **The lever, named in advance:** drop
the 1.3 and 3.0 rungs from the non-core surfaces. Never drop the 2.0 rung — it is the §13
requirement — and never drop a surface.

**6. Goldens churn off Linux.** `FLUTTER_GUIDE.md` §6.4 point 2: goldens are host-dependent.
T05's six images are generated and verified on Linux CI only; a regeneration on the maintainer's
macOS machine reds the lane for antialiasing. **Mitigation:** `@Tags(['golden'])` on the file, and
CI blocks `--update-goldens`.

**7. Whether 120 ms between two heavy impacts is felt as two pulses through a wet neoprene glove is
unknown, and no widget test can settle it.** E10/T02 chose the number and said so. T06 asserts the
sequences differ; it cannot assert they *feel* different. **What resolves it:** the E21 device pass,
with a glove, on both platforms. It is named there, not faked green here.

**8. `SPEC.md` §4.9's one-handed-reach row has an empty "Done looks like" cell.** It is the only row
in the table with no acceptance condition. T07 therefore writes one — the primary action's rect lies
wholly below two-thirds of the viewport height — and says in the file that it is deriving it from §3
("one thumb") and §6's screen inventory rather than quoting §4.9. That is a definition this epic
introduces, and a reviewer should read it as such.

## PR description

### What changed

`SPEC.md` §4.9 is now seven executable assertions over a registry of all 28 surfaces:

- **T01** — `app/testing/a11y/audited_surfaces.dart`, the registry; every tappable node labelled,
  no label leaking a widget key, the tap-node count reconciled against the registry so a new control
  cannot arrive unaudited; the verdict announced as the app's single live region, category word
  first, glyph excluded.
- **T02** — every target ≥ 48 dp, ≥ 56 dp in glove mode, with ≥ 4 dp and ≥ 8 dp separation,
  measured with `getSize`/`getRect` on all 28 surfaces in both densities.
- **T03** — a 176-case matrix of surface × device × scale × bold × density with no overflow and no
  silent clip, plus the fit assertions that the overflow net cannot make, plus the anti-clamp
  behavioural check.
- **T04** — contrast asserted in pure Dart where it composites, not only where it is declared:
  4.5:1 body, 3:1 bearing rules, **7:1 for every sunlight pair**.
- **T05** — six greyscale goldens, and the structural assertions that a golden cannot make: the four
  categories differ by glyph, by headline and by the presence of the measurement sub-line.
- **T06** — the pass and fail haptic sequences asserted to differ, to survive reduce-motion, to fire
  once per finding, and to exist for every `VerdictCategory` value.
- **T07** — every primary action wholly inside the bottom third, at 1.0 and 2.0 scale, in both
  densities, with one primary per surface and no surface silently exempt.

### Why

Because an accessibility pass done by looking is undone by the next pull request. The context is the
argument: one thumb, in sunlight, wearing wet gloves, at 05:40, with a live fish in the bin
(`SPEC.md` §3). Sunlight is a third palette rather than a high-contrast variant, so its floor is 7:1
rather than 4.5:1; glove mode is a density rather than a theme, so it multiplies the geometry checks
and not the palettes; and colour is never the only signal, so the greyscale golden is the proof
rather than the reviewer's eye (invariant 4).

### How it was verified

`flutter test` over `app/test/a11y/`; the four built-in guidelines as advisory tripwires via
`await expectLater`; the six goldens generated on Linux CI only; the six repository gates green
against `app/lib` with explicit target directories.

**What this does not verify, stated plainly:** Flutter ships four machine-checkable guidelines, one
of them known-broken, covering a small minority of real accessibility. Switch Access and Switch
Control cannot be tested automatically at all. TalkBack and VoiceOver actually speaking, the focus
highlight actually visible against all three themes, and a gloved thumb actually landing are E21's
device pass. This PR does not claim to "test accessibility".

### Product invariants touched

Invariant 4 (colour is never the only signal) is the one this epic proves rather than assumes — T05
is its proof and `check_app_invariants.sh` check 5 is its grep. Invariant 2 is guarded in passing:
the live-region label and the haptic are both signals about a statement of fact, and neither may
become an instruction. Invariants 1, 3 and 5 are untouched.

### Follow-ups deliberately not in this PR

- Six locales and the RTL flip over the same surfaces — E20.
- The §14 device pass, TalkBack and VoiceOver, Accessibility Scanner and Accessibility Inspector,
  and the gloved-hand haptic confirmation — E21.
- Correcting `variant-ladder-and-states.md`'s 44/46 dp figures to 48 — a skill edit, out of scope.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch` (D-9); then and only then start E20.
