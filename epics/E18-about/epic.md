# E18 — About and attributions

| | |
|---|---|
| **Branch** | `epic/18-about` |
| **Release** | **v2** — `epics/RELEASES.md`, D-22 |
| **After** | E15 merged |
| **Tasks** | 6 |
| **Spec** | `SPEC.md` §6 S17, §8 (every licence row, the plate death-year test, the fonts row), §11 (both backup postures), §5 (what is excluded, and §5.3), §7.1 (`content_meta`, `jurisdiction.content_version`) |
| **Packages** | `app/`, `tools/content_builder/` |

## What this epic achieves

S17 turns every claim the product makes about itself into something the user can check without
leaving the app and without a signal. After this epic a fisher can open About and read: the full
disclaimer; which statute makes each jurisdiction's legal text reproducible, including the one
citation `SPEC.md` §8 marks as unverified; the Catalogue of Life attribution for both the scientific
names and the vernacular-name extension; the name and death year of the illustrator behind every
bundled plate; the SIL OFL 1.1 text in full; the content version of every jurisdiction beside the app
and build versions; a plain statement of what is collected and what is transmitted, with the reason a
privacy-policy URL is unnecessary rather than merely absent; and why Android refuses a Google backup
while iOS keeps the user's own device backup.

The load-bearing decision is that `ATTRIBUTIONS.md` is **emitted by the content build**, not
hand-maintained. A hand-maintained attributions file drifts from the assets within one content
release: E22 adds a jurisdiction, the plate ledger grows, and the file that was true in July is a
false statement in August. After T01 the file cannot drift, because a content build that would change
it and does not commit the change fails.

## Where we are now

The branch is cut after E15. In the tree already:

- `tools/content_builder/` (D-4) with the ten build assertions, `emitReferenceDb` and
  `emitChangelogs` — E04. `content/plates.yaml` carries `illustrator`, `illustrator_death_year`,
  `source_work`, `source_year`, `licence` and `cleared_on` per plate, and E04/T06 is what produces
  that data; nothing yet reads it back out for a human.
- `reference.db` with `jurisdiction.content_version`, `published_on`, `checked_on`, `valid_until` and
  the `content_meta` key/value table (`SPEC.md` §7.1) — E04, E05. Read-only, opened lazily (D-6).
- Six ARB files, `app_ar.arb` `app_en.arb` `app_es.arb` `app_gl.arb` `app_ca.arb` `app_pt_BR.arb`
  (D-3), the `content_string` fallback chain and the numeral-system lever — E06.
- `app/lib/theme/` (D-2): the Lonja ramp, the three themes, glove density — E07.
- `app/lib/ui/core/ui/`: `LonjaLedgerTable`, `LonjaSectionLabel`, `LonjaEmptyState`, `LonjaStaleBar`,
  `LonjaPill`, `LonjaDisclaimer` — E07, E10, E15.
- `app/lib/ui/reference/`: S12 and S13, and the six list screens S18–S23 — E15. S17 is **not** one of
  the cards on the S12 hub (`SPEC.md` §6 S12 lists S13, S18–S23 only); the entry point is S14's
  *about* row, delivered by E16.
- `app/assets/fonts/` holds the bundled faces, and `flutter_test_config.dart` loads one with Arabic
  coverage so goldens are not six identical boxes (`CONVENTIONS.md` §6).

What does not exist: any `ATTRIBUTIONS.md`, any `app/lib/ui/about/`, any OFL text in the repository,
and any surface that states what the app collects.

## Why this epic exists here in the order

`SPEC.md` §15 step 16 puts About after step 13, the reference section — the declared dependency is
E15, and it is a real one rather than a courtesy: S17 is a long ruled document with a filter, an
empty state and a ledger table, and every one of those is a widget E15 built and hardened over S18–S23.
Building S17 first would mean inventing them twice.

It also cannot come earlier than the content it describes. T01 emits the attributions file from
`content/plates.yaml`, `content/citations.yaml` and the Catalogue of Life extract — all of which
E04 authored — and wires a fatal assertion into `tools/content_builder`. Emitting an attributions
file before there is content to attribute produces a document with one section and no rows, which
would then be quietly hand-edited, which is the exact failure the task exists to prevent.

It must not come later, because E19 (accessibility), E20 (RTL and locale hardening) and E21 (release
readiness) all sweep every screen. S17 is the longest text surface in the app and the one most likely
to overflow at 200% scale; handing it to E19 unbuilt means E19 audits a screen that does not exist,
and E21's store-presence work needs the privacy statement S17 renders to be already true.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | `ATTRIBUTIONS.md`, emitted by the build | `T01-attributions-emitted-by-the-build.md` | M | — |
| T02 | S17 renders it in full | `T02-s17-renders-it-in-full.md` | M | T01 |
| T03 | The OFL text and the font attribution | `T03-ofl-text-and-font-attribution.md` | S | T02 |
| T04 | Content version per jurisdiction, and the app version | `T04-content-version-and-app-version.md` | S | T02 |
| T05 | What is collected, what is transmitted, and why there is no URL | `T05-collected-transmitted-and-no-url.md` | M | T02 |
| T06 | Two backup postures, and why they differ | `T06-two-backup-postures.md` | S | T02 |

T02 delivers the `AboutScreen` scaffold — the section order, the full disclaimer and the attributions
section. T03 to T06 each add one section into that scaffold and touch nothing else in it.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once all six have landed:

- [ ] All 6 tasks committed, one commit each, every `Task: E18/Tnn` trailer present.
- [ ] Every element `SPEC.md` §6 S17 enumerates is on the screen: full disclaimer · data sources and
      licences per jurisdiction · `ATTRIBUTIONS.md` in full including every plate's illustrator and
      death year · content version per jurisdiction · app version · the collection statement with the
      reason there is no privacy-policy URL.
- [ ] `dart run content_builder:build` regenerates `app/assets/legal/ATTRIBUTIONS.md` byte-identically
      to the committed copy; changing one row in `content/plates.yaml` and rebuilding without
      committing the regenerated file fails the build.
- [ ] Every bundled plate has a row naming its illustrator and death year; the count of plate rows in
      the rendered screen equals the count of entries in `content/plates.yaml`.
- [ ] The UAE row still reads *cited but not independently verified*, in the words of `SPEC.md` §8.
      No task in this epic upgraded it.
- [ ] FAO ASFIS appears exactly once, as *not used*, with the non-commercial reason.
- [ ] The SIL OFL 1.1 text is present in full and reachable without leaving the screen.
- [ ] `flutter test` green in `app/`; `dart test` green in `tools/content_builder/`.
- [ ] `check_app_invariants.sh app/lib`, `check_no_network.sh app/lib`, `check_lonja_type.sh app/lib`,
      `check_lonja_lists.sh app/lib` and `check_content_pipeline.sh tools/content_builder/lib` all clean.
- [ ] No `launchUrl`, no `url_launcher`, no `mailto:` handoff anywhere in `app/lib/ui/about/`.
      `authority_url` and `citation.source_url` render as selectable text (`SPEC.md` §5.3).
- [ ] Every ARB key this epic adds exists in all six locales (D-3), and the `ar` values carry no
      positive `letterSpacing`.
- [ ] The screen holds at `TextScaler.linear(2.0)` on a 5-inch viewport with no clipping (`SPEC.md` §13).
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**The fonts row says two different things, and T03 depends on which is true.**
`SPEC.md` §8 bundles Noto Sans + Noto Naskh Arabic under SIL OFL 1.1 at `assets/fonts/` (~8 MB
subset), §12 requires the PDF to render Arabic with the bundled font, and `CONVENTIONS.md` §6 loads a
real font in `flutter_test_config.dart`. But `lonja-typography/references/type-ramp.md` states *"The
app bundles no webfont; these are system stacks, resolved offline, on device, every time"* and lists
Geeza Pro / Al Bayan / Damascus ahead of Noto Naskh Arabic in the `arabic` stack. If E07 shipped
system stacks only, the OFL notice T03 renders describes files the app does not use. **Resolved by**
running `grep -rn "Noto" app/pubspec.yaml app/lib/theme/` as the first step of T03: if the bundled
families are absent from `LonjaFaces`, stop and raise it against E07 rather than shipping a licence
notice for an unused file. `SPEC.md` is authoritative for the product, so the expected answer is that
they are bundled and the ramp lists them first.

**Whether the Noto packages we bundle declare a Reserved Font Name is not established.**
It changes the strength of the "not renamed" rule, not the rule itself — `SPEC.md` §8 states the rule
unconditionally. **Resolved by** reading the `OFL.txt` shipped inside the downloaded Noto package,
which is the same file T03 copies to `app/assets/legal/OFL-1.1.txt`. Do not assert an RFN clause the
shipped file does not contain.

**`product-invariants.md` permits `url_launcher` on this exact screen; the spec bans it.**
`catchlaw-conventions-index/references/product-invariants.md` §1 allows `url_launcher` *"ONLY for
`mailto:` and `tel:` on the about screen"*. `SPEC.md` §10 bans `url_launcher` outright, §14 fails the
build on `url_launcher` or `launchUrl` under `lib/`, and `check_no_network.sh` check 1 fails on the
pubspec entry alone. The executable gate wins over the prose (D-2's rule of thumb). This epic
therefore renders the authority contact as selectable text and offers no `mailto:`. **Resolved by** a
correction to that reference file — which is outside `epics/E18-about/` and is not this epic's to
make, so it is raised in the PR description instead.

**A generator whose output ordering is not stable turns the drift gate into noise.**
If the emitter iterates a map, every content build produces a diff, the byte-compare assertion fires
on unrelated PRs, and somebody disables it — after which the file drifts silently, which is worse
than never having built the gate. **Mitigated by** sorting every emitted collection by a stable id and
by T01 tests 8 and 9, which assert stability across two runs of the same source.

**"Searchable" is this epic's reading of S17, not the spec's word.**
`SPEC.md` §6 S17 requires the file rendered in full and says nothing about search; the filter in T02
exists because a plate ledger is unreadable on a phone otherwise. It is a client-side filter over the
parsed blocks using the shared `normalise()` — not FTS, and it never touches `reference.db` or
`legal_text_fts`. If a reviewer reads S17 as forbidding it, the field detaches without touching the
rest of the section.

**The document is authored in one language and stays that way.**
`ATTRIBUTIONS.md` quotes licences and statutes. §9.6 refuses to translate verbatim legal text, and
`licence-provenance.md` gives the two reasons; both apply here by the same argument. So the section
*headings* localise from ARB and the *body* does not, and an `ar` user reads an LTR English block
inside an RTL page. That is a deliberate outcome, handled in T02 as a direction problem rather than a
translation problem. If a reviewer expects a translated attributions file, the answer is §9.6, not a
translator.

**The UAE citation status is carried, not resolved.**
`SPEC.md` §8 marks Federal Decree-Law 38/2021 Art. 3 *cited but not independently verified in this
session*, and requires confirmation before that state's content ships. This epic renders the status;
it does not improve it. **Resolved by** E22 recording a gazette `source_url`, a `sha256` and a human
`retrieved_on` in `content/citations.yaml`, after which the emitted line changes with the content
build and not with a code edit.

## PR description

### What changed

S17 exists. `tools/content_builder` now emits `app/assets/legal/ATTRIBUTIONS.md` from the authored
content and fails the build if the committed copy is stale. `app/lib/ui/about/` renders that file in
full — scrollable, filterable, and legible in all six locales — beside the SIL OFL 1.1 text, the
per-jurisdiction content versions with the app and build versions, a plain statement of what is
collected and transmitted, and an explanation of the two backup postures.

### Why

`SPEC.md` §6 S17 is where the product's claims stop being marketing and become checkable. Every claim
made elsewhere — public-domain plates, CC BY 4.0 taxonomy, no telemetry, no network — is verifiable
here by a user with no signal. The attributions file is generated because a hand-maintained one is
false within one content release, and the file being false is the specific failure `SPEC.md` §8's
plate rules exist to prevent.

### How it was verified

`dart test` in `tools/content_builder/`, `flutter test` in `app/`, and the five gate scripts named in
the epic's definition of done, each against an explicit target directory. The drift guard was verified
by hand: edit one death year in `content/plates.yaml`, rebuild, confirm the build fails until the
regenerated file is committed. The screen was walked at `TextScaler.linear(2.0)` and in `ar`.

### Product invariants touched

Invariant 1 (no network) is **stated** on this screen for the first time, in `SPEC.md` §5.3's accurate
form: no HTTP client is *used*; `http` appears transitively under `printing` and `flutter_svg`; Android
withholds `INTERNET` and the kernel enforces it; iOS has no equivalent and rests on the dependency
allowlist plus a packet capture. The screen does not claim an iOS permission-level block. Invariant 2
(never instruct) binds every string added here. Invariant 5 (stale is shown) governs the version rows:
an expired jurisdiction keeps its row and gains an ochre pill.

### Follow-ups deliberately not in this PR

- S17's golden lanes in six locales — E20 owns the matrix (`CONVENTIONS.md` §6).
- The screen-reader and haptic sweep — E19.
- The correction to `product-invariants.md` §1's `url_launcher` allowance.
- Verifying the UAE citation against the official gazette — E22.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start the next epic.
