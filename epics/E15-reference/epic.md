# E15 — The reference section

| | |
|---|---|
| **Branch** | `epic/15-reference` |
| **Release** | **v2** — `epics/RELEASES.md`, D-22 |
| **After** | E06 merged (the hard dependency). In `epics/README.md`'s published order this is the fifteenth epic, so E07–E14 are merged when the branch is cut |
| **Tasks** | 9 |
| **Spec** | `SPEC.md` §4.6 in full, §6 S12, S13, S18, S19, S20, S21, S22, S23, §9.6, §7.1 (`legal_text`, `legal_text_fts`, `penalty`, `gear_rule`, `licence_type`, `glossary_term`, `content_change`), §13 (FTS < 200 ms) |
| **Guide** | `FLUTTER_GUIDE.md` Part 5.2 (the vertical slice), Part 6.4 (the test budget), Part 9.2 (RTL) |
| **Packages** | `app/` — `app/lib/data/daos/`, `app/lib/data/repositories/`, `app/lib/domain/`, `app/lib/ui/reference/`, `app/lib/ui/core/ui/`, `app/lib/routing/`, `app/lib/l10n/` |
| **Commit scopes** | `reference` for every task in this epic (`CONVENTIONS.md` §3: "the package or feature") |

## What this epic achieves

When this merges, the app stops being a machine that answers one question and becomes the booklet it
claims to be. `Reference` — the fourth of the five frozen destinations — opens onto seven surfaces
that a fisher can read without having caught anything.

The one that matters most is **S13**, the rule-text reader. It holds the verbatim governing text as
the authority published it, and it is searchable — in Arabic. Typing `هامور` finds an article that
writes `الهامور`, and typing `الهامور` finds an article that writes `هامور`, because the FTS5 index is
built over `legal_text.body_norm` and the query is folded by the same function from
`packages/rule_engine/` that wrote that column. `SPEC.md` §14 lists exactly that pair as a manual
check in airplane mode; after this epic it is also a unit test. The search returns in **under 200 ms**
(§13), the article list navigates by `article_ref`, the citation header names the instrument and the
date we last checked it, and the source URL sits there as selectable text that no code path hands to
a browser (§5.3).

Where a jurisdiction publishes its law in a language the reader does not have, **S13 says so**.
Bundled law exists only in the language the authority published it in; we do not translate a penal
instrument (§9.6). The language-availability notice names what exists, the reader chooses among the
published languages, and the §9.2 `content_string` fallback chain — which is for labels — never gets
anywhere near the text of the law.

The other six are lists, and one of them is a product in its own right. **S20, penalties**, is what
`SPEC.md` §4.6 calls "the screen that makes people keep the app": what a violation costs, per
jurisdiction and per occurrence, in that jurisdiction's own currency, never converted. **S18** is the
full protected-species list with silhouettes, browsable without a result to hang it off. **S19** is
banned gear, banned methods, mesh sizes and hook restrictions, with every gear name in the reader's
language. **S21** answers which licence class covers this zone and this water type, from the
`licence_type` table rather than from a boolean. **S22** is the glossary and **S23** is what changed
between content versions.

Every one of them carries the jurisdiction and the content version in its header, resolves every
label through `content_string`, and — when it has nothing to show — renders **"not recorded for this
jurisdiction"** rather than a blank frame. There are eight such moments in this epic and after T09
there is one component behind all eight.

## Where we are now

The branch is cut from a `main` carrying fourteen merged epics. What this one leans on:

- **E01** — the pub workspace (`app/`, `packages/rule_engine/`, `tools/content_builder/`) and every
  §14 static gate in CI (D-1, D-5).
- **E02** — the §9.4 fold in `packages/rule_engine/`, exported from
  `packages/rule_engine/lib/rule_engine.dart`, with its acceptance test. **This epic calls it and
  reimplements nothing.**
- **E03** — §7.3 resolution and the sealed verdict types, carrying a required `Citation` and no
  user-visible sentence in any language (D-7).
- **E04** — `tools/content_builder/` and the Galicia seed. `reference.db` therefore already holds
  `legal_text` with `body_norm` written by E02's fold, the `legal_text_fts` external-content index,
  and rows in `penalty`, `gear_rule`, `licence_type`, `glossary_term` and `content_change`.
- **E05** — `app/lib/data/services/reference_database_service.dart`, the read-only lazy open, and the
  atomic first-launch extraction (D-6).
- **E06** — the six ARB files `app_ar.arb`, `app_en.arb`, `app_es.arb`, `app_gl.arb`, `app_ca.arb`,
  `app_pt_BR.arb` (D-3), the `content_string` resolver with §9.2's fallback chain, and §9.3's
  numeral-system lever.
- **E07** — `app/lib/theme/` (D-2): three themes, glove density, the type ramp, tokens gate green.
- **E08** — the first Lonja components in `app/lib/ui/core/ui/`: `LonjaSearchField`,
  `LonjaSpeciesRow` and `LonjaEmptyState`, plus `LengthDisplay.format`.
- **E10** — the result surface, its ochre stale bar and the citation footnote. S13 is the target
  E10's citation row expands into (§4.6); this epic is where that target becomes real.
- **E11** — zones, zone ancestry and the active-zone selection S21 filters by.
- **E12** — the five-destination shell. `LonjaDestination.reference` exists and currently resolves to
  nothing; T01 gives it a screen.
- **E13** — the catch log, and whatever ledger component the Today tally needed.

What does **not** exist: `app/lib/ui/reference/` in any form, any DAO over `legal_text`, `penalty`,
`gear_rule`, `licence_type`, `glossary_term` or `content_change`, and any query that has ever touched
`legal_text_fts`. E04 has been writing `body_norm` and rebuilding that index since the Galicia seed
landed; nothing has read it. That is the load-bearing gap this epic closes.

Two shared components may or may not already exist depending on what E12 and E13 needed:
`LonjaSectionLabel` (the gazette rubric — an uppercase tracked label followed by a flex-filling rule)
and `LonjaLedgerTable`. **T01 authors `LonjaSectionLabel` in `app/lib/ui/core/ui/` if it is absent;
T06 authors `LonjaLedgerTable` there if it is absent. If either is present, use it and author
nothing.** Both are shared, so `app/lib/ui/core/ui/` is their home per `FLUTTER_GUIDE.md` §2.5 and
D-2 — never `app/lib/ui/reference/`.

## Why this epic exists here in the order

It cannot come earlier. Every surface in it reads a table that only exists once E04 has built
`reference.db` and E05 has extracted and opened it read-only. Every label on every one of the seven
screens resolves through `content_string` in the active locale, which is E06's resolver and its
fallback chain — and §9.6's language-availability notice is meaningless until that chain exists,
because the notice's entire job is to state where the chain stops. `SPEC.md` §15 step 13 records the
dependency set as `[4,5]`: the data layer and localisation. That is the floor, and `epics/README.md`
records the same thing as **After: E06**.

It must not come later. S17 (About) renders `ATTRIBUTIONS.md` in full and `epics/README.md` puts E18
**After: E15** — the attribution surface sits on top of the reference section's chrome. E10 already
promises that tapping a citation "expands the bundled verbatim text in S13"; until this epic that
promise points at nothing, and §14's manual check "tapping a citation expands S13 and copies to
clipboard — no browser opens" cannot be run. S1's content-currency chip routes to S23 (§6 S1); E12
built the chip against a route that does not resolve yet.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | S12 — the hub | `T01-s12-reference-hub.md` | S | — |
| T02 | S13 — the reader, and Arabic FTS in under 200 ms | `T02-s13-reader-and-arabic-fts.md` | L | T01 |
| T03 | The language-availability notice | `T03-language-availability-notice.md` | M | T02 |
| T04 | S18 — protected species | `T04-s18-protected-species.md` | M | T01 |
| T05 | S19 — gear and methods | `T05-s19-gear-and-methods.md` | M | T04 |
| T06 | S20 — penalties | `T06-s20-penalties.md` | M | T04 |
| T07 | S21 — licence types | `T07-s21-licence-types.md` | M | T04 |
| T08 | S22 and S23 — glossary and changelog | `T08-s22-s23-glossary-and-changelog.md` | M | T04 |
| T09 | One empty state, used eight times | `T09-one-empty-state.md` | S | T02, T04, T05, T06, T07, T08 |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once the epic is whole:

- [ ] All 9 tasks committed, one commit each, every `Task: E15/T<nn>` trailer present.
- [ ] `cd app && flutter test` green; `app/lib/ui/reference/` and the new DAOs at or above the ~80%
      app coverage floor of `CONVENTIONS.md` §6, generated code excluded.
- [ ] `هامور` and `الهامور` each return the same article set from `legal_text_fts`, in both
      directions — a body writing one form is found by a query typing the other. This is the §14
      airplane-mode check, executed as a unit test.
- [ ] The FTS query returns in **< 200 ms** (§13) over a `legal_text` fixture filled to §8's ~3 MB
      per-jurisdiction verbatim-text budget, measured as a median over 100 queries on the CI runner.
      The device figure is E21's §14 pass and is not claimed here.
- [ ] No fold, strip, lowercase or `replaceAll` over query text exists anywhere in `app/lib/` — the
      only normalisation is the call into `package:rule_engine` (§8, §9.4).
- [ ] `packages/rule_engine/` is unchanged by this epic. No user-visible sentence entered it (D-7).
- [ ] Every one of S13, S18, S19, S20, S21, S22 and S23 renders the jurisdiction name and
      `jurisdiction.content_version` in its header, and every label on every one of them resolves
      through `content_string` — no raw `*_key` string reaches a `Text`.
- [ ] All eight empty surfaces render `ReferenceEmptyState`; `grep -rn 'SizedBox.shrink' app/lib/ui/reference/`
      returns nothing, and each surface has an `en` and an `ar` golden (lanes 6 and 7 of
      `lonja-lists-and-tables/references/the-four-states.md`).
- [ ] S13 renders the language-availability notice for every locale not in
      `jurisdiction.legal_text_locales`, and no code path substitutes one language of law for another
      (§9.6).
- [ ] Penalty amounts render in `penalty.currency` through `NumberFormat.currency` with the
      currency's own ISO-4217 exponent, and no conversion, rate or "≈" appears anywhere (§9.5).
- [ ] `source_url` and `authority_url` render as selectable text with copy-to-clipboard, and
      `check_no_network.sh` confirms no `launchUrl`, `url_launcher`, `AndroidIntent` or `ACTION_VIEW`
      reaches `app/lib` (§5.3).
- [ ] All gates clean against `app/lib`: `check_app_invariants.sh`, `check_no_network.sh`,
      `check_reference_db.sh`, `check_verdict_contract.sh`, `check_lonja_tokens.sh`,
      `check_lonja_type.sh`, `check_lonja_lists.sh`, `check_lonja_nav.sh`, `check_lonja_controls.sh`,
      plus `tools/gates/no_directional_geometry.sh` (D-8).
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin --delete-branch` (D-9).

## Risks and the things that will bite

**1. `penalty.amount_min` has no declared unit.**
`SPEC.md` §7.1 declares `amount_min INTEGER, amount_max INTEGER, currency TEXT` and says nothing
about whether the integer is major or minor units. `persistence-drift` rule 5 requires integer minor
units keyed to the currency's real ISO-4217 exponent, and that exponent is **not 2 everywhere this
app ships**: AED and EUR and BRL are 2, but BHD, KWD and OMR are 3. A hardcoded `/100` renders a
Bahraini fine at ten times its value, in the one screen `SPEC.md` says keeps the user.
**Resolution, applied in T06:** the renderer treats `amount_*` as minor units and takes the divisor
from `NumberFormat.currency(...).decimalDigits`, never from a literal; a test covers BHD (3) beside
AED and EUR (2). **What would resolve it properly:** one line in `tools/content_builder/`'s assertion
list (§8) declaring the unit and failing a row whose magnitude is implausible for its currency. That
is E22's file, not this epic's.

**2. The `content_string` resolver's symbol name is E06's, not this epic's.**
Every task here calls it. This epic writes it as `ContentStrings` with `String resolve(String key)`,
reached through one provider. **Mitigation:** every call site in the epic goes through
`app/lib/ui/reference/reference_strings.dart`, so if E06 named it otherwise the rename is one file.
Nothing in `app/lib/ui/reference/` may call the resolver directly.

**3. The FTS index is only as good as the build that wrote it.**
`legal_text_fts` is an FTS5 **external-content** table (`content='legal_text'`). If E04 ever stops
issuing its rebuild after populating `legal_text`, every query returns zero rows and the app renders
a perfectly authored "no matches" state — a silent, total failure that looks like correct behaviour.
**Mitigation, applied in T02:** one test queries the **committed Galicia fixture built by E04** for a
sentinel token that is present in every shipped jurisdiction, rather than only querying rows the test
normalised itself. That test goes red instead of the app going quiet.

**4. The 200 ms number cannot be honestly proved on CI.**
§13's targets are stated against a Snapdragon 665. The CI runner is not one, so T02's latency test is
a **regression guard with the spec's number as its ceiling**, not a proof. **What would resolve it:**
the §14 dynamic pass in E21, on physical devices of both platforms. Nothing in this epic may be
described as having measured the device figure.

**5. `legal_text_locales` is a CSV in a `TEXT` column and can be empty.**
§7.1 declares it `NOT NULL` but nothing forbids `''`. A jurisdiction whose verbatim text has not been
transcribed yet — §16 R1 says the Gulf texts are the risk — will have rules and citations but no
`legal_text` rows. **Resolution, applied in T03:** an empty or unparseable value is treated as "no
legal text recorded for this jurisdiction", which is empty surface 2 of the eight, not an error and
not a crash. **What would resolve it:** a `content_builder` assertion that `legal_text_locales` is
non-empty exactly when `legal_text` rows exist for that jurisdiction.

**6. Glossary ordering cannot use `String.compareTo`.**
`glossary_term` carries `sort_order`, and S22 must use it. Dart's `String.compareTo` is UTF-16
code-unit order: it sorts `Ñ` after `Z`, and it sorts every Arabic term after every Latin one, so a
mixed-script glossary comes out in two blocks. Dart ships no ICU collator.
**Resolution, applied in T08:** order by `sort_order` then `id`, never by the localised value. **The
residual risk:** if a jurisdiction's authored `sort_order` is all zeros, the list falls back to
insertion order silently. T08 asserts the Galicia seed's terms are not all-zero, so the failure is
visible in CI rather than on a boat.

**7. Highlighting a search hit inside verbatim law is not possible, and must not be faked.**
FTS5's `snippet()` and `highlight()` return offsets into the **indexed** column, which is `body_norm`
— normalisation has stripped tatweel and harakat and changed the string's length, so those offsets do
not map onto `body`. **Resolution, applied in T02:** hits are listed by `article_ref` plus the
opening run of `body`, and the article opens rendered verbatim with no highlight. **Rejected:**
rendering `snippet(legal_text_fts, ...)` to the user, which would show the reader normalised law —
an Arabic legal text with its diacritics deleted, presented as the published wording.

**8. E15's hard dependency is E06, but three tasks assume E07's components and E12's shell.**
T01 attaches the hub to `LonjaDestination.reference`, and every list uses `LonjaSearchField`,
`LonjaSpeciesRow` and `LonjaEmptyState`. At position 15 in the published order all of that exists.
**If this epic were ever pulled forward to run immediately after E06**, T01's shell attachment is the
only thing that would need deferring; the seven screens themselves are reachable by route and fully
testable without a shell.

## PR description

### What changed

`SPEC.md` §6's whole reference section, S12 through S23, plus the data layer under it:

- **S12** — a ruled hub routing to the seven reference surfaces, mounted on
  `LonjaDestination.reference`.
- **S13** — an FTS5 search over `legal_text.body_norm` with the query folded by
  `package:rule_engine`, article navigation by `article_ref`, the citation header, the "as checked
  on" date, and `source_url` as selectable text with copy-to-clipboard and no browser.
- **The language-availability notice** — rendered whenever the reader's locale is not in
  `jurisdiction.legal_text_locales`, with a picker across the languages that do exist.
- **S18** — protected species, full list, silhouettes, browsable independently of any result.
- **S19** — banned gear, banned methods, mesh sizes and hook restrictions, gear names localised.
- **S20** — penalties, per jurisdiction, per occurrence, as a ruled ledger in the jurisdiction's own
  currency.
- **S21** — licence types applicable to the active zone and water type, from `licence_type`.
- **S22 / S23** — glossary terms per locale, and the per-jurisdiction content changelog.
- **One `ReferenceEmptyState`** behind all eight empty surfaces.
- New DAOs and repositories over `legal_text`, `penalty`, `gear_rule`, `licence_type`,
  `glossary_term` and `content_change`.

### Why

`SPEC.md` §15 step 13 places the reference section after the data layer and localisation. §4.6 makes
"FTS in ≤ 200 ms, Arabic search works" the acceptance condition for the rule text and names S20 the
screen that makes people keep the app. §9.6 requires the language-availability notice, because
shipping an unofficial translation of a penal instrument would be a liability and, in Spain, outside
the Art. 13 LPI carve-out, which covers *official* translations only. §14 lists the Arabic FTS check
and the citation-expands-to-S13 check as release blockers, and neither could be executed before this.

### How it was verified

- `هامور` finds `الهامور` and `الهامور` finds `هامور`, in both directions, through the real index.
- The query fold and `body_norm` agree on every §9.4 acceptance input, asserted against the
  **committed Galicia fixture written by E04**, not against rows the test normalised itself.
- A latency regression test holds the FTS query under 200 ms over a ~3 MB `body_norm` corpus on CI.
  The device figure is E21's and is not claimed here.
- The four list states per screen, with the ochre stale bar composed with data rather than replacing
  it; `en` and `ar` goldens for all eight empty surfaces.
- BHD (ISO-4217 exponent 3) rendered beside AED and EUR (exponent 2), with no conversion anywhere.
- `check_no_network.sh` confirms no URL reaches a launcher; the copy-to-clipboard path is asserted.
- Row and control targets asserted by `getSize` at 64 dp paper / 76 dp glove, clearing §4.9's 56 dp
  floor with 8 dp separation.

### Product invariants touched

`CONVENTIONS.md` §9, none weakened:

1. **No network** — every byte comes from `reference.db` and the ARB. No new dependency. `source_url`
   is selectable text; nothing is handed to a browser (§5.3).
2. **Statement, never instruction** — a penalty row states an amount and an occurrence; a gear row
   states `not allowed`; an empty state states what is absent. No imperative reaches any surface, and
   no empty state is softened into permission.
3. **Required `Citation`** — every penalty, gear rule, licence type and legal-text article renders
   its citation, because §7.1 declares `citation_id NOT NULL` on all four.
4. **Never colour alone** — `PROTECTED` and `NOT ALLOWED` are glyph plus word plus hue; the stale bar
   is ochre plus warn glyph plus a changed word.
5. **Stale is shown** — an expired jurisdiction still renders every list in full behind the
   non-blocking ochre bar. No reference screen has an expiry branch that returns early.

### Follow-ups deliberately not in this PR

- S17, `ATTRIBUTIONS.md` rendered in full, and the per-plate illustrator and death year — E18.
- Storage usage and the bulk photo purge that share the Settings chrome — E16.
- The greyscale proof, the 200% audit and the semantics pass as whole-app work — E19.
- The six-locale golden matrix as a whole-app pass, and the §9.4 acceptance test over real data at
  full scale — E20.
- The §14 dynamic pass: Arabic FTS in airplane mode on a physical device, the packet capture, and
  the citation-expands-to-S13 walk — E21.
- The verbatim text for the remaining jurisdictions, and the `legal_text_locales` values that go with
  them — E22.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch` (D-9); then and only then start E16.
