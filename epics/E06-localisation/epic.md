# E06 — Localisation infrastructure

| | |
|---|---|
| **Branch** | `epic/06-localisation` |
| **After** | E05 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §9 in full (§9.1 languages, §9.2 two-tier translation, §9.3 RTL and numerals, §9.4, §9.5 plurals and gender, §9.6 single-locale legal text); §11 "Both" (locale follows the system, the override persists); §13 localisation-completeness row; §14 static checklist row 5; §15 step 5 |
| **Guide** | `FLUTTER_GUIDE.md` Part 9.1, Part 9.2, Part 6.4 |
| **Package** | `app/` (ARB, resolver, gates, golden harness); `tools/gates/` (D-8) |

## What this epic achieves

After this merges, every string the app will ever show has a place to live and a language to live in.
Six locales — `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` (D-3) — are wired through `gen-l10n`; the app flips
to RTL because the resolved locale is `ar` and for no other reason; a Galician-speaking mariscadora on
a Spanish-locale phone can pin `gl` and keep it across restarts; Khalid in Ras Al Khaimah gets Western
digits by default and Arabic-Indic digits if he asks for them in S14; bundled content resolves through
the §9.2 fallback chain and can never render a raw key; and the verbatim text of a law is shown only in
the language the authority published it in, with the app saying so.

Two CI gates land with it: an ARB key/plural-category check that fails the build (`SPEC.md` §14, static
row 5) and the directional-geometry grep gate (D-8). From this point on, a physical `left` inset or a
missing `ar` plural category is a red pipeline rather than a bug that ships to one locale in six.

Every screen epic from E07 onward builds on top of this. None of them re-derive it.

## Where we are now

The branch is cut from a `main` that already carries E01–E05:

- **E01** — the pub workspace (D-1): `app/`, `packages/rule_engine/`, `packages/analysis_defaults/`,
  `tools/content_builder/`, the analysis options of `FLUTTER_GUIDE.md` §4.3, and the §14 static checks
  wired into `.github/workflows/validate.yml`. `app/lib/main.dart` and the app widget exist and run.
- **E02, E03** — `packages/rule_engine/` normalises text and returns sealed verdicts carrying a
  required `Citation`. Per D-7 it holds **no user-visible sentence in any language**, and nothing in
  this epic changes that.
- **E04** — `tools/content_builder/` builds `reference.db` from authored YAML, including the §8
  assertion that every `*_key` resolves in `content_string` for **every** shipped locale.
- **E05** — two drift databases. `reference.db` is extracted, sha256-verified and opened
  `readOnly: true` (D-6); `user.db` is writable and holds the singleton `user_profile` row with
  `locale_override` and `numeral_system` (`SPEC.md` §7.2).

What does **not** exist yet: any ARB file, any `AppLocalizations`, any locale state, any numeral
handling, any golden harness, and any font with Arabic coverage in the test tree. `app/lib/l10n/` is an
empty directory in the `FLUTTER_GUIDE.md` §2.5 tree.

Two known gaps this epic closes and one it does not. It closes D-3 (the ARB filenames, `ca` not `ur`,
`app_pt_BR.arb` not `app_pt.arb`) and D-8 (the directional ban is a grep gate, not a lint). It does not
close the `lonja-typography` reference-file discrepancy recorded under Risks below — that file is
outside `epics/E06-localisation/` and is not this epic's to edit.

## Why this epic exists here in the order

`SPEC.md` §15 step 5 places localisation fifth, before any screen, and gives the reason in six words:
*retrofitting RTL is expensive*. The dependency is real in both directions.

**It cannot come earlier.** T03 resolves `content_string` rows out of `reference.db` and T04 and T06
read `user_profile`; both databases arrive in E05. T02's plural check needs ARB files that only exist
once T01 has run, and T01's `supportedLocales` test needs an app widget, which E01 delivers.

**It must not come later.** Every widget written after this point is written with
`EdgeInsetsDirectional` because T05's gate rejects the alternative on the same pull request that
introduces it. Every screen epic that lands before the gate would have to be swept afterwards, and a
sweep finds the paddings and misses the `Alignment.centerLeft` in a painter. `FLUTTER_GUIDE.md` §9.2
states the failure mode precisely: *a physical `left` inset is a bug that manifests in 1 of 6 locales
and will never be caught by a test running in `en`*. E07's theme and E08's first screens are the first
consumers; both sit immediately behind this epic in `epics/README.md`.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | ARB scaffolding for six locales | `T01-arb-scaffolding.md` | M | — |
| T02 | CI: every key everywhere, and the right plural categories | `T02-arb-parity-and-plurals.md` | M | T01 |
| T03 | The `content_string` resolver and the fallback chain | `T03-content-string-resolver.md` | M | T01 |
| T04 | The numeral-system lever | `T04-numeral-system-lever.md` | L | T01 |
| T05 | The directional-geometry gate | `T05-directional-geometry-gate.md` | M | T01 |
| T06 | A locale override that outlives the system locale | `T06-locale-override.md` | M | T01, T03, T04 |
| T07 | Legal text is single-locale, and the app says so | `T07-legal-text-locales.md` | M | T03 |
| T08 | The golden harness, with a font that has Arabic glyphs | `T08-golden-font-harness.md` | L | T01, T04, T06 |

## Definition of done for the epic

Every task's own definition of done (`CONVENTIONS.md` §8 plus the task file), plus what is only
checkable once all eight have landed:

- [ ] All 8 tasks committed, one commit each, every `Task: E06/Tnn` trailer present.
- [ ] `app/lib/l10n/` holds exactly six ARB files: `app_ar.arb`, `app_en.arb`, `app_es.arb`,
      `app_gl.arb`, `app_ca.arb`, `app_pt_BR.arb`. No `app_ur.arb`, no `app_pt.arb` (D-3).
- [ ] Every ARB key exists in all six files, with identical placeholder names — `SPEC.md` §14 static
      row 5, enforced by `check_arb_parity.sh app/lib/l10n` in CI.
- [ ] Every `ar` plural message carries all six ICU categories; `es`, `ca` and `pt_BR` carry `many`;
      `gl` and `en` are `one`/`other` (`SPEC.md` §9.5, corrected against CLDR 48).
- [ ] `packages/rule_engine/` still holds no user-visible sentence in any language (D-7) — this epic
      adds nothing to it.
- [ ] `tools/gates/no_directional_geometry.sh app/lib` is clean and is a required CI step (D-8).
- [ ] `.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib` clean.
- [ ] `.claude/skills/i18n-rtl-l10n/…` — the plugin gates `check_arb_parity.sh app/lib/l10n` and
      `check_i18n_bans.sh app/lib` both clean.
- [ ] The app resolves `TextDirection.rtl` for `ar` and `TextDirection.ltr` for the other five, with no
      `Directionality` constructed anywhere in `app/lib` (`SPEC.md` §9.3).
- [ ] `NumberFormat.decimalPattern('ar')` emits Western digits by default and Arabic-Indic digits after
      `applyNumeralSystem(NumeralSystem.arab)`, and the map is restored in `tearDown` of every test that
      touches it (`FLUTTER_GUIDE.md` Part 9.1).
- [ ] A `content_string` lookup can never return a raw key or an empty string (`SPEC.md` §9.2).
- [ ] The `ar` golden and the `en` golden of the same specimen are **different bytes** — proof that a
      font with Arabic coverage is loaded (`FLUTTER_GUIDE.md` §6.4, golden point 1).
- [ ] The golden lane carries at most 12 images, is tagged `golden`, and runs on Linux CI only.
- [ ] `dart format --set-exit-if-changed .` and `flutter analyze` clean across the workspace; the full
      suite green.
- [ ] PR checks all SUCCESS; merged with `gh pr merge --squash --admin --delete-branch` (D-9).

## Risks and the things that will bite

**1. `l10n.yaml` keys on the pinned Flutter.** D-5 pins Flutter 3.44.6. The five keys T01 sets
(`arb-dir`, `template-arb-file`, `output-localization-file`, `output-class`, `nullable-getter`) are
documented in `i18n-rtl-l10n/references/arb-and-icu.md`; whether this Flutter still accepts
`synthetic-package`, and whether `output-dir` needs it, is **not verified here**. *Resolved by:* running
`flutter gen-l10n --help` before writing the file and taking the key list from the tool, not from
memory. `gen-l10n` names an unknown key in its error.

**2. The `intl` version is under-determined.** `SPEC.md` §10 lists `intl ^0.19`; `FLUTTER_GUIDE.md`
Part 9.1's numbering-system findings were verified on **0.20.2**. D-5 does not settle it. *Resolved by:*
T04 asserting the **emitted digit block**, not the version — whichever `intl` the workspace resolves,
the test states the truth. The resolved version goes in T04's commit body.

**3. `numberFormatSymbols` is process-wide.** A test that swaps it and does not restore corrupts every
later `NumberFormat` in the same isolate, and a golden corrupted this way fails in a file nobody
edited. *Mitigated by:* T04's `setUp`/`tearDown` discipline and T08's `flutter_test_config.dart` guard,
which asserts the map is pristine at the end of each test file. *Residual:* the guard fires in the file
that caused the damage only if `flutter test` gives that file its own isolate. It normally does; if a
future `--concurrency` or shared-isolate setting changes that, the guard degrades to "some file in this
run left it dirty", which is still better than a silent wrong-digit golden.

**4. `numberFormatSymbols`'s import path.** `FLUTTER_GUIDE.md` Part 9.1 shows the symbol, not the
`import`. T04 writes `import 'package:intl/number_symbols_data.dart';`; if that is not the library that
exports it on the resolved `intl`, the analyzer says so on the first compile. Do not guess a second
path — read the package's `lib/`.

**5. A skill reference still lists the wrong six locales.**
`.claude/skills/lonja-typography/references/arabic-and-scripts.md` opens with "`ar` · `en` · `es` ·
`gl` · `pt-BR` · `fr`" — `fr` is not shipped and `ca` is missing. D-3 is authoritative and is not
re-argued. D-3's skill-correction list (E01/T09) names four files and does not include this one, so the
discrepancy survives this epic. *What would resolve it:* a follow-up on E01/T09's correction commit.
This epic may not edit it — every file outside `epics/E06-localisation/` is out of scope.

**6. The ARB values are scaffolding-grade, not reviewed translations.** `SPEC.md` §9.2 step 3 budgets
review by one native-speaking fisher or fisheries officer per locale before release. That has not
happened, and nothing in this epic pretends otherwise. *What would resolve it:* the budgeted review,
tracked as content work in E22. The gates enforce **structure** — key parity, plural categories, no
imperative — never wording quality.

**7. Font subsetting will invalidate the goldens exactly once.** T08 lands the full regular faces of
Noto Sans and Noto Naskh Arabic so the golden lane has Arabic glyphs. `SPEC.md` §8 budgets an ~8 MB
**subset** in the shipped bundle, and subsetting changes rasterisation. *Mitigated by:* T08's DoD naming
the hand-off — whichever epic subsets the fonts regenerates the goldens in one titled commit on the
Linux lane, per `golden-two-lanes.md`'s "deliberate, reviewed, local act".

**8. The `legal_text_locales` tie-break is not in the spec.** `SPEC.md` §9.6 says the notice appears
when the user's locale is not among them, but not which language of law to show when the CSV holds two
(`'gl,es'`). T07 defines it: `default_locale` when it appears in the list, otherwise the first CSV
entry. *If E22's content authoring wants a different primary, the lever is the CSV order* — no code
change, and the tie-break stays deterministic.

## PR description

### What changed

Six-locale localisation infrastructure, end to end, with no screen work.

- `app/lib/l10n/` — six ARB files (D-3), `l10n.yaml`, `gen-l10n` output committed to git
  (`FLUTTER_GUIDE.md` §7.4), `MaterialApp` wired with `supportedLocales` and the `Global*` delegates.
- CI now fails on a missing ARB key, a mismatched placeholder, or an `ar` plural message missing one of
  the six ICU categories (`SPEC.md` §14, static row 5).
- `ContentStringResolver` implements the §9.2 fallback chain: requested locale → jurisdiction
  `default_locale` → `en` → scientific name. A missing string throws with its key; it never renders one.
- `applyNumeralSystem` swaps `numberFormatSymbols['ar']`, driven by `user_profile.numeral_system`
  (`auto`/`latn`/`arab`) — not by a `-u-nu-` locale extension, which `intl` accepts as a string and
  discards.
- `tools/gates/no_directional_geometry.sh` bans physical-side geometry across `app/lib` (D-8).
- `LocaleNotifier` persists the S14 override in `user_profile.locale_override`, independently of the
  system locale (`SPEC.md` §11).
- `LegalTextAvailability` states which language a verbatim instrument exists in and never substitutes
  another (`SPEC.md` §9.6).
- `app/test/flutter_test_config.dart` loads Noto Naskh Arabic via `FontLoader` and guards the numeral
  symbol map; the golden lane is tagged and pinned to Linux CI.

### Why

`SPEC.md` §15 step 5 puts this fifth on purpose. Directional geometry, plural categories and a numeral
lever are all cheap to establish and expensive to retrofit, and each of them fails in exactly one
locale out of six — the one nobody develops in.

Two findings drove the shape of the work. `FLUTTER_GUIDE.md` Part 9.1: `intl` has **no**
numbering-system API, its `number_symbols_data.dart` carries only `ar`, `ar_DZ` and `ar_EG`, so `ar_AE`
silently falls back to `ar` and renders Latin digits — which CLDR 48 says is **correct** for Khalid, and
which the first draft of the spec asserted backwards. `SPEC.md` §9.5: `es`, `ca` and `pt` each carry a
CLDR `many` category; only `gl` is `one`/`other`, and the first draft asserted `one`/`other` for all
four. Both corrections are now assertions in the suite rather than sentences in a document.

### How it was verified

- `flutter test` across `app/` — unit, widget, golden.
- `check_arb_parity.sh app/lib/l10n`, `check_i18n_bans.sh app/lib`,
  `check_app_invariants.sh app/lib`, `no_directional_geometry.sh app/lib`, each with an explicit target
  directory (D-1: they exit 2 on a missing directory, so a bare default would abort the run).
- `Intl.plural` interrogated directly for `ar` at 0, 2, 3, 11 and 100 and for `es`/`gl` at 1 000 000, so
  the toolchain's own CLDR data — not a document — is what the categories are checked against.
- The `ar` and `en` specimen goldens compared byte-for-byte and asserted **different**, which is the
  only way to know the Arabic font actually loaded.

### Product invariants touched

None weakened. `CONVENTIONS.md` §9:

1. **No network path** — nothing added opens a socket; `google_fonts` is banned by
   `check_i18n_bans.sh` and the fonts are bundled assets.
2. **A verdict states a fact** — T07's language-availability notice is a statement about the data
   ("this text exists only in Arabic"), checked against the banned-imperative lexicon in every one of
   the six locales.
3. **Citation required** — untouched; T04 records that citation dates stay Western-digit ISO in every
   locale (`product-invariants.md` §3) and that the numeral lever must not reach them.
4. **Colour is never the only signal** — untouched.
5. **An expired ruleset is still evaluated** — untouched.

### Follow-ups deliberately not in this PR

- **E07** — the Lonja type ramp, the Naskh optical uplift and the font subset. T08 lands the faces the
  goldens need; the ramp that consumes them is E07's.
- **E16** — S14's language and numeral-system controls. T04 and T06 land the state and the persistence;
  the settings screen is E16's.
- **E15** — S13's rule-text reader. T07 lands the availability rule and its notice string; the screen
  that renders it is E15's.
- **E20** — the full golden matrix across screens, and the §9.4 acceptance test on real content. This
  epic goldens the i18n primitives only, per `golden-two-lanes.md`.
- **E22** — native-speaker review of every ARB value and every `content_string` row.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task, tests
red first; `gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch` (D-9); then and only then start E07.
