# E17 — Export and import

| | |
|---|---|
| **Branch** | `epic/17-portability` |
| **Release** | **v2** — `epics/RELEASES.md`, D-22 |
| **After** | E13 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §12 in full, §6 S15/S16, §5.3, §10 (`pdf` · `printing` · `share_plus` · `file_picker`), §14 (export and import in airplane mode), §4.7 (Flag a wrong rule) |
| **Package** | `app/` — `app/lib/domain/`, `app/lib/data/services/portability/`, `app/lib/ui/settings/` |

## What this epic achieves

After this epic a fisher can get his data out of the phone and back into a phone, with no account and
no server anywhere in the path. Four artefacts leave the device through the OS share sheet:
`catchlaw-export-YYYYMMDD.json` (the complete round-trip dataset), `catches-YYYYMMDD.csv` (one row
per catch, UTF-8 with a BOM so Excel opens Arabic and Galician), `trip-report-YYYYMMDD.pdf` (the
artefact he hands to an inspector, a cofradía or an insurer — header, catch table, totals against
limits, the content version and citation behind each finding, disclaimer on every page), and, when
photos are included, one `.zip` holding all three plus a `photos/` directory. Import takes the JSON
or the zip, shows counts before it writes anything, and offers Merge (deduplicated on
`(created_at, species_id, length_mm)`, existing records win) or Replace (wipe and restore, behind a
typed confirmation word). A malformed file writes nothing and names the field that failed; a file
from a newer `user_db_schema_version` is refused rather than partially applied.

This is also the only route by which a wrong rule gets reported. `SPEC.md` §4.7 says the app
"composes nothing and sends nothing" — a **Flag this rule** note (E10) is a row in `rule_flag`, and
the way it reaches the Consellería do Mar or the Ministry of Climate Change and Environment is that
the fisher exports and mails it himself. Every export therefore carries the flags.

## Where we are now

The hard dependency is **E13 merged**: `user.db` holds `trip`, `catch`, `saved_zone`, `rule_flag`,
`species_recent` and the singleton `user_profile` row (`SPEC.md` §7.2), photos are written inside the
app sandbox by the in-app camera, and the catch row already denormalises `scientific_name`,
`rule_citation_ref` and `content_version` so a three-year-old record still says what it said. Because
the sequence in `epics/README.md` is strict, E14, E15 and E16 have also merged by the time this
branch is cut, which matters for one reason: **S14 (E16) is where S15 and S16 are entered from**, and
E16 already renders storage-used and the bulk photo purge that this epic's Replace path interacts
with.

What does not exist yet: any serialisation of `user.db` at all, any PDF, any dependency on `pdf`,
`printing`, `share_plus`, `file_picker` or an archive writer, and any file under
`app/lib/data/services/portability/`. `app/lib/data/services/pdf_export_service.dart` is named in
`FLUTTER_GUIDE.md` §2.5's tree but has never been written.

E05 left one thing this epic consumes directly: the drift `MigrationStrategy` and its
`schemaVersion` constant on `UserDatabase`, plus §7.4's rule that the app refuses to open a `user.db`
whose schema version is higher than it understands. T08 applies that same rule to a *file*.

## Why this epic exists here in the order

It cannot come earlier because there is nothing to export until the catch log exists — trips,
catches, photos and rule flags are all E13 (and E10) deliverables, and an exporter written against a
schema that is still moving would be rewritten twice.

It must not come later because `SPEC.md` §14's dynamic checklist has two lines that only this epic
can satisfy — "Export produces all four artefacts and the share sheet appears, in airplane mode. The
PDF renders Arabic with the bundled font" and "Import of a previously exported zip succeeds, in
airplane mode" — and E21 executes that checklist on device. E21 also runs the packet capture "while
walking every screen S1–S23 and exercising export, import, GPS, camera, PDF render and SVG load". If
this epic landed after E19/E20, the accessibility and RTL audits would have to be re-run over two new
screens plus a modal.

There is one further reason for the position: **`printing` and `share_plus` are the two dependencies
that carry the app's transitive `http` and `url_launcher_platform_interface` edges** (`SPEC.md` §5.3
and §14 static check 1). They arrive in this epic. Landing them before the release epic gives E21 a
real allowlist to diff rather than a hypothetical one.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The JSON round-trip format | `T01-json-round-trip-format.md` | L | — |
| T02 | CSV with a BOM | `T02-csv-with-a-bom.md` | M | T01 |
| T03 | The PDF trip report, with the bundled Arabic font | `T03-pdf-trip-report.md` | L | T01 |
| T04 | The zip, and relative photo paths | `T04-zip-and-relative-photo-paths.md` | M | T01, T02, T03 |
| T05 | The share sheet | `T05-share-sheet.md` | M | T04 |
| T06 | Import preview, and the merge rule | `T06-import-preview-and-merge.md` | L | T01, T04 |
| T07 | Replace, behind a typed word | `T07-replace-behind-a-typed-word.md` | M | T06 |
| T08 | Transactional import | `T08-transactional-import.md` | L | T06, T07 |

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable at the epic level:

- [ ] All 8 tasks committed, one commit each, every `Task: E17/Tnn` trailer present.
- [ ] `flutter test` green in `app/`, and `app/lib/data/services/portability/` plus
      `app/lib/domain/use_cases/` at ≥ 90% line coverage — this is data-loss code, so it sits above
      the app's ~80% budget in `FLUTTER_GUIDE.md` §6.4 without reaching the engine's 100%.
- [ ] `grep -rn "PdfGoogleFonts" app/lib` returns nothing, and every `pw.Font` in the tree is built
      by `pw.Font.ttf(await rootBundle.load('assets/fonts/…'))` or by a `pdf` base-14 constructor.
- [ ] `grep -rn "launchUrl\|url_launcher" app/lib` returns nothing.
- [ ] `flutter pub deps --style=compact` shows `url_launcher_platform_interface` reachable from
      exactly one root, `share_plus`, and `http` from exactly two, `printing` and `flutter_svg`
      (`SPEC.md` §14 static check 1). The checked-in direct-dependency allowlist is updated in the
      same commits that add `pdf`, `printing`, `share_plus`, `file_picker` and the archive writer.
- [ ] A round trip is proved end to end: export a fixture `user.db` holding 2 trips and 17 catches,
      wipe, import the zip with Replace, and assert every row and every column is byte-identical.
- [ ] Merge run twice over the same file adds nothing the second time (idempotence).
- [ ] A malformed file and a newer-schema file each leave `user.db` row counts unchanged.
- [ ] Every ARB key added by T02, T05, T06 and T07 exists in all six locales — `ar`, `en`, `es`,
      `gl`, `ca`, `pt_BR` (D-3) — and every `ar` plural carries all six ICU categories.
- [ ] `check_no_network.sh app/lib`, `check_app_invariants.sh app/lib`,
      `check_verdict_contract.sh app/lib`, `check_lonja_dialogs.sh app/lib`,
      `check_lonja_buttons.sh app/lib` and `check_lonja_type.sh app/lib` are all clean.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**The archive writer is a dependency `SPEC.md` §10 does not list.** §12 requires a `.zip`, Dart ships
no zip writer, and neither `pdf` nor `printing` provides one. A pure-Dart archive package has to be
added as a direct dependency in T04, which means an allowlist diff (§14 static check 1) and a
`dependency-hygiene` pass. *Resolution:* T04 adds it, pins the version resolved at that moment (no
version is written into these documents, because none has been verified), records it in the
allowlist, and re-derives the transitive `http` table in
`catchlaw-offline-guarantee/references/four-layers.md` from `flutter pub deps --style=compact`. If
the resolved package pulls any networking edge, it is rejected and T04 falls back to writing the four
artefacts as loose files with no zip — which costs the `photos/` directory and needs a spec
amendment, so this is checked first, not last.

**`share_plus` and the Android FileProvider path set.** T05 writes the artefacts under
`getTemporaryDirectory()` and hands the paths to `Share.shareXFiles`. Whether `share_plus`'s bundled
`FileProvider` declares a `cache-path` covering that directory is not verifiable from source and is
not asserted anywhere in this plan. *What would resolve it:* the E21 device pass — share an export on
a physical Android device and a physical iPhone. The documented fallback is
`getApplicationSupportDirectory()/export/`, which `SPEC.md` §11 already names as the app-private
location.

**`pdf` and `printing` are the only single-maintainer dependency on the critical path** (`SPEC.md`
§10). *Mitigation, and it is in the spec rather than invented here:* T03 puts every call behind
`TripReportRenderer`, so the swap is one file plus a provider override, and the fake used by every
test in T04–T08 already proves callers hold no `pw.*` type.

**PDF Latin coverage stops at Latin-1.** T03 uses the `pdf` package's base-14 Times faces for Latin
runs, which need no asset and cannot fetch, and the bundled Naskh TTF for Arabic. Base-14 fonts are
WinAnsi-encoded, which covers `ñ á ã ç í õ ü` and therefore `es`, `gl`, `ca`, `pt_BR` and `en`. It is
*not* verified that every character the content authors will use in a zone label falls inside
Latin-1. *What would resolve it:* the T03 test row that renders `Ría de Arousa`, `Xoubiña`,
`Ameixa babosa` and `São Paulo` and asserts no glyph falls back. If one does, the fix is a bundled
Latin TTF — never a fetched one.

**Arabic shaping inside the PDF is asserted at the font-selection level only.** The tests prove the
Arabic run is drawn with the bundled Naskh face and that the page is `pw.TextDirection.rtl`; they do
not prove the `pdf` package joins the letterforms correctly, because comparing rendered glyph runs
from bytes is not something a CI unit test can do honestly. *What would resolve it:* §14's device
line — "The PDF renders Arabic with the bundled font" — executed by E21 with a native reader
checking `هامور` is one joined word and not five orphans.

**The confirmation word in T07 must be typeable on an Arabic keyboard.** An English word forced into
`app_ar.arb` would make Replace unusable for the product's primary persona. The word is an ARB value
per locale and needs the §9.2 native-speaker review pass; the comparison runs through the shared
`normaliseArabic` from `packages/rule_engine/` (E02) so harakat, tatweel and a leading `ال` do not
make a correct answer fail.

**The BOM claim is proved at byte level in CI and at behaviour level only by hand.** CI can assert the
first three bytes are `EF BB BF` and that the payload decodes as UTF-8. It cannot open Microsoft
Excel. The `SPEC.md` §12 claim is about Excel's import heuristic, so the release checklist gets one
manual line: open `catches-YYYYMMDD.csv` from an `ar` export and a `gl` export in Excel and confirm
neither is mojibake.

**Photo deletion is not transactional and cannot be made so.** T07's Replace wipes rows inside one
drift transaction and unlinks orphaned photo files *after* the commit. A crash in that window leaves
orphan files, not lost data. That is the correct direction of failure, and S14's bulk photo purge
(E16) reclaims them. The alternative — unlink first — destroys photos that a rollback would have
kept.

## PR description

### What changed

`SPEC.md` §12 implemented end to end, as screens S15 and S16 reachable from S14.

- **Export.** `ExportEnvelope` and its hand-written JSON codec (profile, saved zones, trips, catches,
  rule flags, plus a header carrying `app_version`, `user_db_schema_version`, per-jurisdiction
  `content_versions` and `exported_at`); a UTF-8-with-BOM CSV whose header row is localised to the
  active language and whose values are machine-form; a per-trip PDF behind the `TripReportRenderer`
  interface; and a `.zip` with a `photos/` directory and `photo_path` rewritten relative.
- **The share sheet.** One `ShareService`, one implementation over `share_plus`, one screen. This is
  the only outbound path in the product and it is user-initiated and app-external.
- **Import.** A preview that counts trips, catches and flags and names the source app version before
  a single row is written; Merge, deduplicated on `(created_at, species_id, length_mm)` with existing
  records winning; Replace, behind a typed confirmation word; and a transactional apply where a
  malformed file writes nothing and names the failing field, and a newer `user_db_schema_version` is
  refused rather than partially applied.

### Why

There is no cloud, so this is the only way data survives a lost phone, and the only way a wrong rule
reaches the authority that published it (`SPEC.md` §4.7 — the app composes nothing and sends
nothing). The PDF exists because a fisher standing in front of an inspector needs an artefact with
the citation and the content version on it, not a screenshot.

### How it was verified

Unit tests over the codec, the CSV writer, the merge rule and the failure taxonomy; a round-trip
integration test that exports a fixture database, wipes it and restores it byte-identically;
`check_no_network.sh app/lib` clean with `PdfGoogleFonts` and `launchUrl` absent from the tree; and
`flutter pub deps --style=compact` diffed against the checked-in allowlist showing `http` reachable
only from `printing` and `flutter_svg` and `url_launcher_platform_interface` only from `share_plus`.
The airplane-mode lines in §14 are device work and belong to E21; nothing in this PR claims them.

### Product invariants touched

- **Invariant 1 (no network code path)** is the one under pressure. `share_plus` hands a file URI to
  the OS share sheet; it opens no socket, and `catchlaw-conventions-index/references/product-invariants.md`
  lists `Share.shareXFiles` for a user-initiated export as explicitly allowed. `printing` brings an
  `http` edge whose only entry point, `PdfGoogleFonts`, is grep-banned; every face in the PDF comes
  from `rootBundle` or from a base-14 constructor. `share_plus` brings
  `url_launcher_platform_interface`; `launchUrl` is grep-banned. Both edges are on the §5.3
  documented exception list and both are asserted in CI.
- **Invariant 2 (states a fact, never instructs)** — the export copies `catch.outcome_detail`
  verbatim and composes no new sentence in any artefact, including the PDF and the CSV header row.
- **Invariant 3 (required citation)** — `TripReportRow` is unconstructable without its citation
  string, and the PDF prints the citation and content version beside every finding.
- **Invariant 5 (stale is shown)** — an expired ruleset's finding is exported and printed unchanged,
  with the expiry stated as another dated fact. Nothing in this epic filters on expiry.

Nothing in this PR weakens any of the five.

### Follow-ups deliberately not in this PR

- The §14 airplane-mode device runs and the packet capture — E21.
- Accessibility audit of S15/S16 at 200% text scale, and their golden lanes in six locales — E19,
  E20.
- "Export raw database file" from S14 (`SPEC.md` §12's manual escape hatch) — that is an S14 element
  and belongs to E16; this epic does not touch it.
- Any second export format. §12 names four artefacts and this PR ships exactly four.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start the next epic.
