# E20 — RTL and locale hardening

| | |
|---|---|
| **Branch** | `epic/20-rtl-hardening` |
| **After** | E19 merged |
| **Tasks** | 6 |
| **Spec** | `SPEC.md` §9.3 (RTL and numerals), §9.4 (the acceptance test), §9.5 (plurals and gender), §9.6, §13 (localisation completeness is enforced), §14 (the `ar`-locale walkthrough) |
| **Package** | `app/` — `app/test/`, `app/testing/`, `.github/workflows/validate.yml` |

## What this epic achieves

After this epic the six-locale claim is a set of assertions rather than a set of ARB files. Every
shipped surface has been rendered in `ar`, `en`, `es`, `gl`, `ca` and `pt_BR` (D-3) with a font that
actually has Arabic glyphs, in two of the three Lonja themes, on one pinned host. The Arabic plural
entries are proved to carry all six ICU categories against the strings the app really ships, not
against a synthetic key. The numeral preference — `auto` / Western / Arabic-Indic, S14 — is proved to
change what renders, and the `numberFormatSymbols` swap that implements it is proved not to leak
between tests. The ruler is proved not to mirror under `ar`, with zero at the same physical edge as it
sits at under `en` and its tick labels carrying localised digits. The §9.4 acceptance test runs
against the seeded `reference.db` instead of a hand-built fixture, so it can fail for a content
reason. And "no layout overflows at `ar`" (§9.3, last bullet) becomes 56 assertions across every
surface at scale 1.0 and 2.0, instead of a screenshot somebody looked at.

E21 can then execute the §14 device walkthrough knowing that the failures it finds are device
failures, not locale failures nobody had checked.

## Where we are now

The branch is cut from a `main` that already contains everything except release verification and the
remaining jurisdictions.

- **E06** built the localisation *infrastructure*: the six ARB files (E06/T01, D-3), the
  `content_string` fallback chain, the numeral-system lever, the RTL harness, the directional-geometry
  grep gate at `tools/gates/no_directional_geometry.sh` (E06/T05, D-8), and font loading for goldens in
  `app/test/flutter_test_config.dart` (E06/T08, `CONVENTIONS.md` §6).
- **E07–E18** built every surface S1–S23 and dialogs D1–D5 on top of it.
- **E19** delivered the accessibility pass: semantics, the 200%-text audit, the pure-Dart contrast
  sweep, the greyscale proof and haptics.

What does not exist yet is proof that any of it holds **together, in `ar`**. E06's RTL harness was
exercised against the widgets that existed in E06 — which was almost none of them. E19's text-scale
audit ran in the locale its author was reading. The Arabic type ramp raises every line height by 0.15
and every size by 1.12 (`lonja-typography/references/arabic-and-scripts.md`), so an `en` row that fits
at 200% is not evidence that the `ar` row does.

## Why this epic exists here in the order

It cannot come earlier: the matrix is over *finished* screens, and a golden blessed against a screen
that is still being built is churn with a diff image attached. `SPEC.md` §15 step 18 places RTL and
locale hardening after step 17 (accessibility) for exactly this reason, and `epics/README.md` records
the dependency as "all UI" → E19 → E20.

It must not come later: E21 runs the §14 checklist on physical devices, and its last item is "run the
entire loop with the device in `ar` locale and RTL". A device session is the most expensive place to
discover that a species row overflows at 200% in Arabic. Everything that a host machine can decide is
decided here so that E21's device time is spent on the things only a device can answer — packet
capture, per-uid byte counters, real first-launch extraction.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The golden matrix — five screens × six locales × two themes, Linux only | `T01-golden-matrix.md` | L | — |
| T02 | Arabic plural categories, asserted on the shipped strings | `T02-plural-categories.md` | M | — |
| T03 | Numerals end to end, and the `numberFormatSymbols` reset | `T03-numerals-end-to-end.md` | M | T01 |
| T04 | The ruler's LTR exception, verified in `ar` | `T04-ruler-ltr-in-ar.md` | M | T03 |
| T05 | The §9.4 acceptance test, on the seeded database | `T05-acceptance-on-seeded-data.md` | M | E22's Gulf pack on `main` — see Risk 8 |
| T06 | No overflow at `ar`, and at `ar` with 200% text | `T06-ar-overflow-matrix.md` | M | T01 |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once all six have landed:

- [ ] All 6 tasks committed, one commit each, every `Task: E20/T<nn>` trailer present.
- [ ] 60 golden files exist under `app/test/ui/golden/goldens/` — 5 screens × 6 locales × 2 themes —
      every one of them generated on `ubuntu-latest` and on nothing else.
- [ ] The golden lane is tagged `golden`, is skipped on a non-Linux host, and CI contains no
      `--update-goldens` invocation.
- [ ] `flutter test` in `app/` is green with the golden lane excluded, and green with it included on
      Linux.
- [ ] `app_ar.arb` declares `zero`, `one`, `two`, `few`, `many` and `other` on every count-bearing key,
      and each of the six renders a distinct string (T02).
- [ ] `numberFormatSymbols['ar'].ZERO_DIGIT` is `'0'` at the end of every test file in `app/test/`;
      no test leaks the swap into the next one in the isolate (T03).
- [ ] The ruler subtree resolves `TextDirection.ltr` under locale `ar`, and its zero mark sits within
      0.5 dp of the same x it sits at under `en` (T04).
- [ ] The eight §9.4 inputs resolve to `epinephelus-coioides` against the seeded `reference.db`, and
      `شعري` resolves to `lethrinus-nebulosus` (T05).
- [ ] The database those assertions ran against is the shipped `app/assets/db/reference.db.gz`, its
      sha256 matches the generated constant, and a write against it throws (D-6, T05).
- [ ] Every surface S1–S23 and D1–D5 has an `ar` × 1.0 and an `ar` × 2.0 assertion, and none of them
      suppresses an overflow (T06).
- [ ] `check_lonja_type.sh app/lib`, `check_lonja_tokens.sh app/lib`, `check_measurement.sh app/lib`
      and `check_app_invariants.sh app/lib` are clean.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**1. A bundled face with no Arabic coverage renders tofu, and tofu is deterministic.** Six locales of
identical grey boxes diff cleanly against each other and pass forever. `FLUTTER_GUIDE.md` §6.4 names
this as the first of its two hard-won golden points. Mitigation: T01's matrix opens with a coverage
probe that lays out `هامور` and fails if the resulting paragraph width equals the width of the same
string laid out in the fallback-free Latin face. Blessing is refused until that probe passes.

**2. Goldens are host-dependent, and this repository is developed on macOS.** Font rasterisation,
subpixel positioning and antialiasing differ per host and per engine revision
(`widget-golden-and-a11y-testing/references/golden-two-lanes.md`). Mitigation: the lane is
`@Tags(['golden'])`, `skip:` unless `Platform.isLinux`, generated on `ubuntu-latest` only, and CI has
no blessing step. Regeneration is a deliberate local act in a Linux container with a titled commit.

**3. `numberFormatSymbols` is process-wide and order-dependent.** `SPEC.md` §9.3 and
`FLUTTER_GUIDE.md` §9.1 both state it: a swap made in one test silently corrupts every later test in
the same isolate, including goldens, and the corruption is a *rendered* difference that a blessed PNG
will happily absorb on the next regeneration. Mitigation: T03 ships one guard in
`app/testing/l10n/numeral_symbols.dart` used by every digit-sensitive test, and T01's harness asserts
`ZERO_DIGIT == '0'` in `tearDown` so a leak from a future task reds the golden lane instead of
re-blessing it.

**4. `intl`'s version is not pinned by `DECISIONS.md`.** `SPEC.md` §10 says `^0.19`;
`FLUTTER_GUIDE.md` Part 9.1 records its measurements against **0.20.2 on Dart 3.12.2**, which is the
version whose behaviour every assertion in T03 encodes. D-5 pins Flutter, Dart, Riverpod and drift and
is silent on `intl`. This is a genuine gap, not a decision to re-argue. **What resolves it:** reading
the resolved version out of `app/pubspec.lock` on this branch. T03 asserts *behaviour*
(`ar` → Latin digits, `ar_EG` → U+0660–0669, `-u-nu-` discarded) rather than a version string, so if
the resolved version behaves differently the assertions are what discover it — loudly, in one file.

**5. `flutter_localizations` may not ship a `GlobalMaterialLocalizations` delegate for `gl` or `ca`.**
If it does not, the matrix throws at `pumpWidget` for those two lanes and the fix is a vendored
delegate borrowing a close relative (`i18n-rtl-l10n/references/arb-and-icu.md`, "Widget vendors a
delegate for a non-built-in locale"). **What resolves it:** T01's first test asserts that all six
`Locale`s from D-3 appear in `GlobalMaterialLocalizations.delegate.supportedLocales`, so the answer is
recorded in the suite rather than in somebody's memory.

**6. `lonja-typography/references/arabic-and-scripts.md` names the six locales as
`ar · en · es · gl · pt-BR · fr`.** `fr` is not a CATCHLAW locale and `ca` is missing — D-3 settled the
set, and the skill-correction task E01/T09 named four files to fix, of which this is not one. This
epic does not touch `.claude/skills/`, so the discrepancy is carried forward as a **follow-up**: one
line in that reference file, `fr` → `ca`. It does not affect any assertion here, because every task
reads its locale list from D-3.

**7. E19 may already own a surface catalogue.** T06 needs a list of every S1–S23 and D1–D5 surface
with a pump closure, and E19's 200% audit needed the same thing. Forking it produces two lists that
disagree the first time a screen is renamed. T06's implementation outline therefore begins by looking
for the existing catalogue and extending it; a second list is named as the rejected option in that
task file.

**8. T05 needs Gulf content, and Gulf content is E22.** The eight §9.4 inputs are Arabic and Latin
names of `epinephelus-coioides`. E04 seeded **Galicia**; the Gulf jurisdictions belong to E22, which
`epics/README.md` records as running in parallel from E04 onward and being the long pole. If the
bundled `reference.db` carries no Arabic-script jurisdiction when T05 runs, that task **fails and says
so** — it does not skip and it does not fall back to a fixture, because `SPEC.md` §14 requires Arabic
FTS to hit `هامور` in airplane mode before release and E21 is the next epic. **What resolves it:** the
RAK Gulf pack landing on `main` from E22 before this branch is cut. Row 1 of T05 is that precondition
written as an assertion whose failure message names E22, so the scheduling fact is discovered on a
build machine rather than on a device.

**9. Sixty goldens plus fifty-six overflow tests is a slow lane.** `testing-strategy` rule 11: a suite
that costs minutes gets skipped. Mitigation: the golden lane is tag-excluded from the default
`flutter test` run and lives in its own CI job, so the developer loop stays on the unit and widget
lanes; the overflow matrix pumps one frame per test and stays in the default run.

## PR description

### What changed

Six commits, all of them verification of work that already merged.

- A golden matrix over five screens (S1 Check, S2 Result, S3 Ruler, S5 Species search, S13 Rule text
  reader) × the six D-3 locales × the paper and sunlight themes — 60 files, generated on
  `ubuntu-latest` only, with the bundled Arabic Naskh face loaded and a glyph-coverage probe in front
  of it. New `goldens` job in `.github/workflows/validate.yml`.
- Arabic plural coverage asserted against the shipped ARB values: all six ICU categories present and
  each rendering a distinct string for counts 0, 1, 2, 3, 11 and 100; `es`, `ca` and `pt_BR` each carry
  a reachable `many` branch; `gl` carries `one`/`other` and no dead `many`.
- The numeral preference proved end to end — `auto` renders Western digits under `ar` (which is what
  CLDR says and what §9.3 says is right for Ras Al Khaimah), `arab` renders U+0660–0669, and the
  `numberFormatSymbols` swap is snapshotted and restored around every digit-sensitive test.
- The ruler's deliberate LTR exception verified under `ar`: `TextDirection.ltr` inside the subtree,
  zero within 0.5 dp of its `en` position, `labelDirection` still ambient, labels carrying localised
  digits, `shouldRepaint` honouring a direction change.
- The §9.4 acceptance test moved off a fixture and onto the seeded `reference.db` extracted from
  `app/assets/db/reference.db.gz`, plus the Arabic FTS hits (`هامور`, `الهامور`) §14 requires.
- An `ar` overflow and fit matrix over every surface S1–S23 and D1–D5 at text scale 1.0 and 2.0.

### Why

`SPEC.md` §9.3 ends with "Golden tests render every screen in `ar` and assert no overflow", §13 lists
localisation completeness as an enforced non-functional requirement, and §14's last dynamic item is
the whole `ar` walkthrough. Until this epic those were sentences. E06 built the machinery; this is the
epic that proves the machinery survived contact with eighteen epics of UI.

### How it was verified

`flutter test` in `app/` green on the default lane; `flutter test --tags golden` green on
`ubuntu-latest`; the four repository gate scripts clean against `app/lib`;
`tools/gates/no_directional_geometry.sh app/lib` clean. Every test in this epic was written first and
observed to fail — the golden lane by having no blessed file, the rest by asserting behaviour that did
not hold.

### Product invariants touched

None weakened. Two are *exercised* by this epic rather than changed:

- **Invariant 4 (colour is never the only signal)** — the sunlight lane of the golden matrix is the
  theme with zero greys and `surfaceSunk == surface`, so a block that separated itself by a change of
  stock is visible as broken there and nowhere else.
- **Invariant 5 (an expired ruleset is still evaluated and still shown)** — the S2 golden is pumped
  with an expired pack so the ochre `StaleRuleBar` is in every one of the twelve S2 images, in all six
  locales.

The ruler's forced `TextDirection.ltr` is a **documented exception** to `SPEC.md` §9.3's
mirror-everything rule, not a weakening of it: `catchlaw-measurement-ruler` rule 4 owns it, and T04
exists to prove it is deliberate.

### Follow-ups deliberately not in this PR

- `lonja-typography/references/arabic-and-scripts.md` still lists `fr` in place of `ca` (Risk 6). This
  epic writes no file under `.claude/skills/`.
- Pinning `intl` in `DECISIONS.md` (Risk 4). A decision belongs on that page, written once, not in a
  task file.
- Night-theme goldens. Two themes, not three — the argument is in `T01-golden-matrix.md` under "Why it
  is built this way", and night's neutral bindings are covered by E07's token tests and E19's contrast
  sweep.
- Device-level `ar` verification: §14's dynamic checklist is E21's, and it stays E21's.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task, in
order; `gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start E21.
