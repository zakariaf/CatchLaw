# E07 — Lonja design system foundation

| | |
|---|---|
| **Branch** | `epic/07-lonja-theme` |
| **After** | E06 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §4.9 (glove mode, sunlight mode, colour independence, font scaling), §11 "Both" (dark mode supported; sunlight is a third theme, not a variant), §13 (contrast ≥ 4.5:1, ≥ 7:1 in sunlight; targets ≥ 48 dp, ≥ 56 dp in glove mode; 200% text scale; < 1.2 s cold start) |
| **Guide** | `FLUTTER_GUIDE.md` Part 8.1 (never return widgets from a helper method, and the measured reason), 8.2 (`const`), 8.3 (the `CustomPainter`), plus §2.1/§2.5 (the tree), §6.1 (test naming), §6.4 (the golden budget) |
| **Packages** | `app/` — `app/lib/theme/` (D-2), `app/lib/ui/core/ui/`, `app/testing/theme/`, `app/test/theme/` |
| **Commit scopes** | `theme` for T01–T07, `check` for T08 (`CONVENTIONS.md` §3) |

## What this epic achieves

When this merges, CATCHLAW looks like the document it quotes. Every colour, gap, rule weight, radius,
duration, type step and touch target in the app has exactly one home under `app/lib/theme/`, and a
feature file that invents a value fails a gate rather than shipping a fourth palette. Three themes
exist and are hand-authored: **paper** (the regulations booklet indoors), **night** (the same booklet
under a deck lamp) and **sunlight** (the same booklet at Gulf noon) — and sunlight is a genuine third
palette in which every grey is deleted, `surfaceSunk` collapses into `surface`, `accent` gives up
`harbour`, and the only chroma left in the build is the verdict. Every slot in every theme carries a
measured contrast figure: ≥ 4.5:1 for text and ≥ 3:1 for a bearing rule on paper and night, ≥ 7:1 for
everything in sunlight, which is `SPEC.md` §13's sunlight line.

Glove mode is **orthogonal** to all three: a density value set carried on `LonjaTokens.density`,
raising every primary target from 48 dp to 56 dp and every separation from 4 dp to 8 dp — §4.9's
"all primary targets ≥ 56 dp with ≥ 8 dp separation" — so there are three palettes and six
renderings, never six palettes. The type ramp sets anything that quotes the law in a serif and every
comparable numeral in a mono with tabular figures, and resolves the Arabic Naskh stack with its
optical uplift and zero tracking. Surfaces separate with rules, sunk stock and whitespace, and
nothing anywhere — including inside `lib/theme/` — casts a shadow, holds a gradient or carries a
non-zero elevation. The action ladder has one primary per screen, a destructive rung that always
confirms, and a greyscale golden proving that no state on any of these surfaces is carried by colour
alone (invariant 4).

Every epic from E08 onward reads slots and steps from this epic and authors no value of its own.

## Where we are now

The branch is cut from a `main` carrying six merged epics:

- **E01** — the pub workspace (`pubspec.yaml`, `analysis_options.yaml`, `app/`,
  `packages/rule_engine/`, `packages/analysis_defaults/`, `tools/content_builder/`), the toolchain
  floor of D-5, and every §14 static gate wired into CI against explicit target directories (D-1).
- **E02, E03** — the shared §9.4 fold, §7.3 resolution, expiry semantics and the sealed `Verdict`
  and `Finding` types, all in `packages/rule_engine/` and carrying no user-visible sentence (D-7).
- **E04, E05** — `reference.db` built from authored YAML, and the two drift databases with the
  atomic first-launch extraction (D-6).
- **E06** — six ARB files `app_ar.arb`, `app_en.arb`, `app_es.arb`, `app_gl.arb`, `app_ca.arb`,
  `app_pt_BR.arb` (D-3), the §9.2 fallback chain, the §9.3 numeral lever, the RTL harness, and
  `app/test/flutter_test_config.dart` loading a font with Arabic coverage for goldens
  (`FLUTTER_GUIDE.md` §6.4, `CONVENTIONS.md` §6).

What does not exist: `app/lib/theme/` in any form. Whatever `ThemeData` the E01 skeleton left in
`app/lib/main.dart` is Material's default — a `ColorScheme.fromSeed` if the Flutter template's was
kept — and T03 is what removes it. `app/lib/ui/core/ui/` exists as a directory with no Lonja
component in it.

There is a known gap this epic closes, and it is the one `CONVENTIONS.md` §7 warns about: **a gate
that scans a path with no files reports success.** `check_lonja_tokens.sh app/lib`,
`check_lonja_type.sh app/lib`, `check_lonja_buttons.sh app/lib` and `check_lonja_dialogs.sh app/lib`
have been green since E01 over a tree with almost no colour, no `TextStyle` and no button in it.
E01/T08 already records that. This is the first epic in which those four gates have something real
to find, and T08 is where that is proved rather than assumed.

## Why this epic exists here in the order

It cannot come earlier. The type ramp resolves per script — the Naskh stack, the 1.12 optical uplift
and `letterSpacing: 0` for `ar` — which needs E06's `Localizations` delegate and its six locales in
the tree, and the golden lanes need E06's font loading in `flutter_test_config.dart`, because
`flutter test`'s default font has no Arabic coverage and an `ar` golden would be indistinguishable
from an `en` one (`FLUTTER_GUIDE.md` §6.4). Nothing before E06 has a screen to theme.

It must not come later. `epics/README.md` puts E08 (species) and E09 (ruler) immediately after it,
both depending on E07 alone, and both author screens. A screen written before the theme is a screen
that gets re-authored the week after — and worse, it establishes the hardcoded `Color(0xFF…)` and
`fontSize:` habits that `check_lonja_tokens.sh` and `check_lonja_type.sh` exist to prevent, at the
exact moment those gates are still scanning an empty tree. `SPEC.md` §15 puts the design system
before the feature screens for that reason.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | `LonjaPrimitives` — the tier-one pigment box | `T01-lonja-primitives.md` | M | — |
| T02 | `LonjaTokens` — the `ThemeExtension` | `T02-lonja-tokens-extension.md` | L | T01 |
| T03 | Three themes: paper, night, sunlight | `T03-three-themes.md` | L | T02 |
| T04 | Glove density, orthogonal to the theme | `T04-glove-density.md` | M | T03 |
| T05 | The type ramp | `T05-type-ramp.md` | L | T03 |
| T06 | Surfaces, rules and plates | `T06-surfaces-and-rules.md` | M | T03 |
| T07 | The button variant ladder | `T07-button-ladder.md` | M | T04, T05, T06 |
| T08 | The token gate, and the greyscale proof | `T08-token-gate-and-greyscale-proof.md` | M | T01–T07 |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once the epic is whole:

- [ ] All 8 tasks committed, one commit each, every `Task: E07/T<nn>` trailer present.
- [ ] `cd app && flutter test` green. Line coverage of `app/lib/theme/` is **100%** — the directory
      is const data plus four builders and a handful of accessors, so the ~80% app floor in
      `CONVENTIONS.md` §6 is a floor for feature code, not a ceiling here.
- [ ] Twenty-five primitives exist, each named for its measured CIE L\* and each within **0.6 L\***
      of the number in its own name, proved by arithmetic in a test rather than by eye.
- [ ] All thirteen semantic slots are bound explicitly in all three palettes — 39 bindings, none
      derived from another palette by `copyWith`.
- [ ] Every slot in every theme carries a measured contrast figure matching
      `lonja-design-tokens/references/token-tables.md` to two decimal places, and clears its floor:
      4.5:1 text and 3:1 bearing rules on paper and night, **7:1 for every sunlight slot** (§13).
- [ ] `sunlight` binds six neutral slots plus `accent` to `black00`, binds `surfaceSunk` to
      `surface`, and contains no primitive that appears as a grey in paper or night.
- [ ] `LonjaDensity.glove` reports `tapMin 56` and `tapGap 8` (§4.9), the three-value `LonjaSkin`
      enum is the only theme axis, and `check_lonja_tokens.sh` check 9 finds no `ThemeMode.glove*`.
- [ ] All sixteen type steps match `lonja-typography/references/type-ramp.md`; every mono step
      declares `FontFeature.tabularFigures()`; every `ar` step has `letterSpacing: 0`.
- [ ] `BoxShadow`, every gradient constructor and every `elevation:` above `0` appear nowhere under
      `app/lib`, `app/lib/theme/` included, and no radius exceeds 2.
- [ ] Eight golden lanes render: three skins × two densities, one `ar` lane for the Naskh
      resolution, and one greyscale lane in which every button rung is still distinguishable
      without hue (invariant 4), paired with four assertions so the lane is evidence and not a
      picture.
- [ ] All six gates clean against `app/lib`, each invoked with the explicit target directory (D-1):
      `check_app_invariants.sh`, `check_lonja_tokens.sh`, `check_lonja_type.sh`,
      `check_lonja_buttons.sh`, `check_lonja_dialogs.sh`, `check_lonja_icons.sh`, plus
      `tools/gates/no_directional_geometry.sh` (D-8).
- [ ] Each of those gates is proved to be scanning a **non-empty** tree before its green is believed
      (`CONVENTIONS.md` §7).
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin --delete-branch` (D-9).

## Risks and the things that will bite

**1. `lonja-buttons` and `lonja-design-tokens` publish different glove numbers, and different rule
weights.** `lonja-buttons/references/button-anatomy.md` sets a regular action at 56 dp, compact at
46 dp and glove at 66 dp with 12 dp gaps, and a border of 1.5 dp rising to 3 dp on focus.
`lonja-design-tokens` publishes `tapMin 48/56`, `tapGap 4/8`, and exactly four rule weights — 0.5,
1, 2, 3 — with `.stamp` (3.0) reserved for the verdict frame and nothing else. There is no 1.5 in
the token set, and `check_lonja_tokens.sh` check 6 fails a literal stroke width outside
`lib/theme/`. **Resolution, applied in T07:** the button reads `LonjaTokens.density.tapMin` and
`.tapGap`, which is what the token skill's own worked example binds a button to, and what §13
states as the product floor (≥ 48 dp, ≥ 56 dp glove); its rules are `LonjaRules.rule` at rest and
`LonjaRules.strong` on focus, which honours the state matrix's actual signal — *the rule weight
doubles* — without minting a fifth weight or spending `.stamp`. The tie-break precedent is D-2's:
where prose and an executable gate disagree, the gate wins. **What would resolve it properly:** a
decision on this page in the style of D-1…D-9, or a correction to `button-anatomy.md`. Not E07's
file to edit.

**2. `lonja-dialogs-and-surfaces` prescribes a whole column of cancel labels that fail
`check_app_invariants.sh`.** Rule 3 says a destructive confirmation's cancel button reads `Keep it`,
and `references/modal-decision-matrix.md` §5 tables four of them — `Keep it`, `Keep the entry`,
`Keep my catches`, `Keep Ras Al Khaimah` — on the principle that a cancel names the *preservation*
rather than the abstention. Check 3 of `check_app_invariants.sh` matches a quoted string beginning
`Keep`, and the substring `keep it`, in Dart **and in every ARB file**, with no exemption anywhere
(`CONVENTIONS.md` §7); invariant 2 bans the lexicon `keep, return, release, …` outright.
**Resolution, applied in T07:** E07 ships the mechanism, not a screen's copy — `cancelLabel` is a
required parameter — and its own tests use `Back one step` from the approved corpus in
`lonja-buttons/references/button-anatomy.md`. **What would resolve it:** a correction to rule 3 and
to §5 in the same style as D-3's skill corrections, or replacement wording that names the
preservation without the banned verb. The screens that own real confirmations are E13, E16 and E17.

**3. Three reference files disagree with `token-tables.md` about a hex.**
`lonja-dialogs-and-surfaces/references/surfaces-and-plates.md` §3 gives a night panel fill of
`#1E2A25` and a night ground of `#16201C`; the token table binds night `surfaceSunk` to `ink10`
`#161E1A` and night `surface` to `ink07` `#101714`, and `#1E2A25` is not in the pigment box at all.
`lonja-buttons/references/variant-ladder-and-states.md` gives a sunlight oxblood of `#8E0F0C`, and
the mockup agrees, where the token table binds sunlight `verdictFail` to `oxblood28` `#7A2320` at
10.05:1. **Resolution:** the epic brief and the routing table both make `lonja-design-tokens` the
owner of every value, and `surfaces-and-plates.md` §3 itself closes with "this table is the
surface-side contract those tokens must satisfy". Every task here takes hexes from
`token-tables.md` only. **What would resolve it:** reconcile the three files against the token
table, adding any genuinely new pigment with its measured L\* per that file's own five-step process.

**4. A fifth skill file names the wrong sixth locale.** D-3 lists four files that say `ur` or
`app_pt.arb` and assigns their correction to E01/T09.
`lonja-typography/references/arabic-and-scripts.md` opens by naming the six locales as
`ar · en · es · gl · pt-BR · fr` — Catalan replaced by French, which appears nowhere in `SPEC.md`.
E08's epic records the same file. **Mitigation:** T05 writes `ca` and never `fr`, per D-3, and its
"five Latin locales share the ramp" list is `en, es, gl, ca, pt_BR`. **What would resolve it:** add
the file to E01/T09's correction list.

**5. The per-theme icon stroke width has no home yet.** `lonja-icons-and-plates` rule 3 requires
`LonjaIconTheme.of(context).strokeWidth` — 1.45 on paper, 1.45 on night, 1.95 in sunlight — and says
"the stroke-weight token lives in `lonja-design-tokens`". There is no such row in
`token-tables.md`, and no epic in `epics/README.md` owns the authored icon family
(`lib/design/icons/lonja_icon_paths.g.dart`) that would consume it. **Mitigation:** E07 ships no
icon and no stroke-width token; T07's button declares an empty leading-glyph slot rather than
reaching for `Icons.`, which `lonja-icons-and-plates` rule 1 bans outright. **What would resolve
it:** name the owner of the icon family — E08 is its first consumer — and add the stroke-width row
to `token-tables.md` in that epic.

**6. E08's epic states that no Lonja component exists after E07.** Its "Where we are now" reads the
E07 delivery line in `epics/README.md` — three themes, glove density, the type ramp, the tokens gate
— and concludes it authors "the first three components". This epic ships four before it:
`LonjaRule`, `LonjaPanel`, `LonjaPlateSurface` (T06) and `LonjaButton` with its confirmation surface
(T07), because E07/T06 and E07/T07 name them. **Mitigation:** the PR description lists all four by
path so the E08 builder composes on them instead of re-authoring them. Neither `epics/README.md` nor
E08's file is edited here.

**7. Goldens are host-dependent and this epic introduces eleven of them.** `FLUTTER_GUIDE.md` §6.4:
generate and verify on one platform (Linux CI) or they churn on every macOS machine, and load a real
font or every locale renders identical boxes. **Mitigation:** T08 generates on Linux CI only, keeps
the matrix at 3 themes × 2 densities plus one greyscale lane, and depends on E06's
`flutter_test_config.dart` rather than adding a second font-loading path. A golden that churns
locally is not evidence and must not be re-baselined to make a local run pass.

**8. `useMaterial3` may be deprecated on the pinned SDK.** D-5 pins Flutter 3.44.6; the worked
example in `lonja-design-tokens/examples/lonja_theme.dart` passes `useMaterial3: true`. Material 3
has been the `ThemeData` default for several releases and the flag has been on a deprecation path.
**Mitigation:** T03 constructs `ThemeData` with the hand-authored `ColorScheme` and omits the flag if
the analyzer reports it deprecated — `flutter analyze` clean is a hard condition in
`CONVENTIONS.md` §8, and a deprecation warning is not a value decision.

## PR description

### What changed

`app/lib/theme/` in full, and the first four Lonja components:

- `lonja_primitives.dart` — 25 pigments, each named for its measured CIE L\*, read by nothing
  outside `lib/theme/`.
- `lonja_tokens.dart` — the 4 pt spine, the four rule weights, the radius ceiling of 2, the motion
  durations, `LonjaDensity`, and the `LonjaTokens` `ThemeExtension`: thirteen semantic slots plus
  density, value equality over every field, an asserting `of(context)`, a `copyWith` narrowed to
  density and a `lerp` in which density snaps rather than interpolating.
- `lonja_theme.dart` — `LonjaPalettes.paper`, `.night`, `.sunlight`, each with all thirteen slots
  written out, and `LonjaTheme.paper()/.night()/.sunlight()` plus `resolveLonjaTheme(skin:, gloved:)`.
- `lonja_faces.dart`, `lonja_typography.dart` — four system stacks, sixteen named steps, tabular
  figures on every mono step, and the `ar` variant resolved at `of(context)` time.
- `lonja_button_style.dart`, and `app/lib/ui/core/ui/`: `LonjaRule`, `LonjaPanel`,
  `LonjaPlateSurface`, `LonjaButton` and `showLonjaConfirm`.
- `app/testing/theme/` — the transcribed pigment and contrast tables, the CIE arithmetic the proofs
  use, and the specimen sheet the goldens render.

### Why

`SPEC.md` §11 "Both" states that sunlight is a third theme and not a variant of either other one;
§4.9 makes glove mode a target-size requirement and colour independence a correctness requirement;
§13 puts numbers on both. D-2 puts the palette at `app/lib/theme/` rather than
`app/lib/ui/core/themes/`, because every `lonja-*` gate exempts token constructs by the path
fragment `/theme/` and check 8 of `check_lonja_tokens.sh` makes `ui/` a different neighbourhood.
The direction is Lonja: the app as an authoritative printed document, whose authority comes from
looking like the law and the field guide it actually quotes. Paper does not float, so there is no
shadow, no gradient and no elevation anywhere in this diff.

### How it was verified

- CIE L\* computed from each hex in a test and compared with the number in the primitive's own name
  (±0.6) and with the tabled figure (±0.05).
- Every contrast pair in all three themes computed from the WCAG relative-luminance formula and
  compared with `token-tables.md` to two decimal places, then against its floor — 4.5:1, 3:1, and
  7:1 for every sunlight slot.
- 39 binding assertions, one per slot per palette, each naming its slot and theme in the test name.
- Six theme × density combinations asserted to differ in density and in nothing else, expressed as
  `standard.copyWith(density: glove) == glove`.
- Eight golden lanes — six theme × density, one `ar`, one greyscale — generated and verified on
  Linux CI only, using E06's font configuration.
- The specimen sheet laid out at `textScaler` 2.0 with no overflow (§4.9's 200 % line, on E07's own
  surfaces; the whole-app audit is E19's).
- Six gates clean against `app/lib`, each proved to be scanning a non-empty tree first.

### Product invariants touched

`CONVENTIONS.md` §9, none weakened:

1. **No network** — the type ramp is four system stacks and no bundled or fetched webfont; a font
   that fails to load is a blank verdict screen. No new dependency.
2. **Statement, never instruction** — the only strings in this epic are button labels, taken from
   the approved corpus; the destructive confirmation's cancel rung reads `Back one step`, never
   `Keep it`.
3. **Required `Citation`** — nothing here renders a rule-derived surface, so nothing here owes a
   citation. `LonjaPlateSurface` is a surface, not a plate's content.
4. **Never colour alone** — proved, not asserted: the greyscale lane shows the primary and
   destructive rungs whose fields are 2.3 L\* apart, still separable by label and by field-versus-
   outline.
5. **Stale is shown** — untouched. `verdictWarn` is bound in all three palettes so E10's ochre bar
   has a slot to read.

### Follow-ups deliberately not in this PR

- The authored icon family, glyph geometry and the engraved plate content — first consumed by E08.
- `quiet` and `link`, the two remaining rungs of the ladder, and `LonjaIconButton` — added by the
  first screen that earns one.
- The 250 ms deferral on the busy rule. `lonja-buttons` rule 10 draws it only past 250 ms, and
  `token-tables.md` publishes three motion values, none of which is 250 ms. Nothing in the app can
  outrun it yet — both databases are local, and §13 budgets rule evaluation at < 10 ms and search at
  < 50 ms — so the rule is drawn for the whole latch, and the deferral lands with the first operation
  that could plausibly exceed it, together with the token row it needs.
- The ambiguity dialog and the snackbar/undo surface — `lonja-dialogs-and-surfaces`, in E10 and E13.
- The verdict stamp, the stale bar and the citation footnote — E10.
- The whole-app 200% text-scale audit, the semantics pass and the haptics — E19.
- The six-locale golden matrix as a whole-app pass — E20.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch` (D-9); then and only then start E08.
