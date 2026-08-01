# E16 — Settings

| | |
|---|---|
| **Branch** | `epic/16-settings` |
| **After** | E09 and E13 merged |
| **Tasks** | 7 |
| **Spec** | `SPEC.md` §6 S14, §7.2 (`user_profile`), §9.3 (numeral system), §9.5 (units), §4.5 (storage management), §12 (the manual escape hatch), §11 Both (locale follows the system; the override persists independently), §13 (the byte budgets S14 reports against) |
| **Guide** | `FLUTTER_GUIDE.md` Part 1.4, Part 1.5, Part 5.2, Part 5.5 |
| **Package** | `app/` — `app/lib/data/`, `app/lib/domain/`, `app/lib/ui/settings/` |

## What this epic achieves

S14 becomes the one place where every stored preference in the app is set, and the one place that
tells the truth about what the app is holding. A user can pin the interface to Galician on a
Spanish-locale phone, choose Arabic-Indic digits on a device CLDR says wants Western ones, switch
between centimetres, millimetres and inches without a single stored length changing, re-run
calibration, turn coordinate capture off globally so no catch can record a position at all, see the
exact number of bytes `user.db` and the photo directory occupy, delete every catch photo while
keeping every catch record, read the on-device path of `user.db` as selectable text, and hand a copy
of that database to any SQLite tool through the system share sheet. That last item is the point of
the screen: the no-cloud promise stops being a claim in S17 and becomes something a user can verify
on a laptop without our cooperation.

For later epics: E17 inherits a share path that is already proved to work in airplane mode, and every
screen built after this one can read a single `Stream<UserSettings>` instead of inventing its own
preference lookup.

## Where we are now

The branch is cut from a `main` that already carries, per `epics/README.md`'s Delivers column:

- **E05** — `user.db` as a drift database with the §7.2 schema, including `user_profile` with its
  `CHECK (id = 1)` singleton constraint and the `onCreate` insert of that row (`SPEC.md` §7.4), behind
  `app/lib/data/services/user_database_service.dart`.
- **E06** — the six ARB files `app/lib/l10n/app_{ar,en,es,gl,ca,pt_BR}.arb` (D-3), the `content_string`
  fallback chain, and the numeral-system lever: the `numberFormatSymbols` map swap at bootstrap
  (E06/T04, `SPEC.md` §9.3). **E06 owns that mechanism. This epic only writes the preference.**
- **E07** — three themes (paper, night, sunlight) and the glove density switch in `app/lib/theme/`
  (D-2).
- **E09** — S3 and S4, and the writes to `user_profile.ruler_px_per_mm` / `ruler_calibrated_at`.
- **E10** — the result screen, including the long-press that toggles sunlight mode.
- **E11** — S9, the zone picker this epic routes into.
- **E12** — the bottom navigation with a `Settings` destination, currently a placeholder route.
- **E13** — trips, catches, `catch.photo_path`, and the in-app camera that writes photos into the app
  sandbox.

What does not exist: any repository over `user_profile`, any settings UI, any storage accounting, and
any path by which a user can get at `user.db` as a file. There is no preference store of any kind, and
there must not be one — `SPEC.md` §10 bans `flutter_secure_storage` outright and §7.2 makes every
setting on S14 a column of one row.

## Why this epic exists here in the order

`SPEC.md` §15 step 14 lists Settings after step 7 (ruler and calibration) and step 11 (catch log), and
the dependency is literal rather than tidy:

- **E09** must be merged because T03's calibration row shows a stored `ruler_calibrated_at` and re-runs
  S4. There is nothing to display and nowhere to route before S4 exists.
- **E13** must be merged because T06 purges `catch.photo_path` images and sums their bytes. A photo
  purge with no photos is untestable, and the byte figure would be a constant.

It must not come later because E17 (export and import) needs a share path and a database that is
already checkpoint-safe to copy, and E19's accessibility audit needs the glove and sunlight switches
reachable from a real screen rather than from a debug menu.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The settings repository over `user_profile` | `T01-settings-repository.md` | M | — |
| T02 | Language, numeral system, units | `T02-language-numerals-units.md` | M | T01 |
| T03 | Zone defaults, and the way in to calibration | `T03-zone-defaults-and-calibration.md` | S | T02 |
| T04 | Sunlight and glove | `T04-sunlight-and-glove.md` | S | T02 |
| T05 | The coordinate-capture master switch | `T05-coordinate-capture-switch.md` | S | T02 |
| T06 | Storage used, and the bulk photo purge | `T06-storage-and-photo-purge.md` | M | T02 |
| T07 | The escape hatch | `T07-escape-hatch.md` | M | T01, T06 |

T02 builds the screen shell that T03–T07 add sections to; everything after T01 therefore depends on
T02 for the scaffold even where it does not depend on it for behaviour.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once all seven have landed:

- [ ] All 7 tasks committed, one commit each, every `Task: E16/T<nn>` trailer present.
- [ ] Exactly one abstract `SettingsRepository`, one drift implementation and one fake exist in
      `app/`; `grep -rn "shared_preferences\|flutter_secure_storage" app/` returns nothing, in
      `pubspec.yaml` as well as in `lib/`.
- [ ] Every one of the nine S14 columns named in `SPEC.md` §7.2 — `locale_override`, `numeral_system`,
      `length_unit`, `active_jurisdiction`, `active_zone_code`, `ruler_px_per_mm`,
      `capture_coordinates`, `sunlight_mode`, `glove_mode` — is reachable from S14, and no setting on
      S14 is stored anywhere else.
- [ ] One column, one writer: `grep -rn "UserProfileCompanion" app/lib` shows writes only from
      `settings_repository_drift.dart` and from E09's calibration write.
- [ ] Every ARB key added by this epic exists in all six locales `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`
      (D-3), and every plural key added carries all six ICU categories in `app_ar.arb` and a `many`
      category in `es`, `ca` and `pt_BR` (`SPEC.md` §9.5).
- [ ] The settings screen builds **zero** `LonjaButtonVariant.primary` — `check_lonja_buttons.sh` is
      clean and the zero-primary case is the legal one
      (`lonja-buttons/references/variant-ladder-and-states.md`, Edge cases).
- [ ] `flutter test` green in `app/`; the settings feature has no golden lane rendering a blank frame
      (`lonja-lists-and-tables/references/the-four-states.md`, lanes 6 and 7).
- [ ] `check_app_invariants.sh app/lib`, `check_lonja_tokens.sh app/lib`, `check_lonja_controls.sh
      app/lib`, `check_lonja_lists.sh app/lib`, `check_lonja_buttons.sh app/lib`,
      `check_lonja_dialogs.sh app/lib`, `check_measurement.sh app/lib` and
      `tools/gates/no_directional_geometry.sh app/lib` all clean.
- [ ] A raw database export taken on device opens in a desktop SQLite client and contains a catch row
      written seconds before the export.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Product invariants this epic could weaken, and does not

`CONVENTIONS.md` §9 is the floor. Two of the five are genuinely in play here and are named in the
tasks that touch them:

- **Invariant 1 — no network code path.** T07 hands a file to the OS share sheet. That is the one
  outbound path `catchlaw-conventions-index/references/product-invariants.md` §1 allows, because it is
  user-initiated and app-external; it fetches nothing. The path of `user.db` is rendered as
  `SelectableText` and is never handed to a launcher, exactly as `SPEC.md` §5.3 requires of
  `authority_url` and `citation.source_url`. `url_launcher` stays banned (`SPEC.md` §10).
- **Invariant 4 — colour is never the only signal.** T04's two switches carry their state as a word
  beside a filled square (`lonja-forms-and-controls` rule 11), and sunlight mode deletes every grey in
  the row chrome (`lonja-lists-and-tables/references/row-and-table-anatomy.md`, Density).

No task on this screen may offer to check for, download or refresh anything, and none does.

## Risks and the things that will bite

1. **The `numberFormatSymbols` swap is process-wide and order-dependent.** `SPEC.md` §9.3 records that
   it "must run in `main()` before the first `NumberFormat` is constructed, and it will silently
   corrupt golden tests sharing an isolate unless reset in `setUp`/`tearDown`". T02 changes it at
   runtime, from a screen. Mitigation: every test that touches it saves and restores
   `numberFormatSymbols['ar']` in `setUp`/`tearDown`, and T02's definition of done bans caching a
   `NumberFormat` in a field or a top-level `final` — a cached formatter keeps the digits it was born
   with and the setting appears not to work.
2. **Who applies the `en` + US-region inch default is unowned.** `SPEC.md` §9.5 says inches are
   "default only for `en` with a US device region". `epics/README.md`'s traceability table routes §9 to
   E06 and E20 and §6's dialogs to E08–E18, so no epic clearly owns applying that first-run default.
   E16 deliberately does not: a settings screen that writes a column on mount overwrites the user's own
   choice on every visit, and T02 has a test asserting it never does. **What resolves it:** naming the
   owner — E06's first-run flow or E12's first launch — before this epic merges. Until then the schema
   default `'cm'` stands for every locale, which is honest but not what §9.5 describes.
3. **`SPEC.md` §14's dynamic checklist does not name the raw database export.** Its export line covers
   S15's four artefacts. The T07 export is a fifth artefact from a different screen and is not on that
   list. **What resolves it:** E21 adds the line when it executes §14 on device. T07's definition of
   done carries the manual airplane-mode check in the meantime.
4. **Two writers of one `user_profile` row.** E09 writes `ruler_px_per_mm` and `ruler_calibrated_at`;
   this epic writes the other nine columns. `FLUTTER_GUIDE.md` §1.4 says a repository "should be the
   only place where that data type is mutated". The rule adopted here is narrower and checkable: **one
   column, one writer.** T01 exposes the calibration columns read-only and offers no setter for them,
   so the two writers can never clobber each other. If that ever needs to become one repository, it is
   an E09 refactor and not an E16 diff.
5. **A whole-row write would silently revert a concurrent change.** The result screen's sunlight
   long-press (E10) and S14 can both be alive across a navigation stack. T01's setters therefore write
   one column each; a `save(UserSettings)` taken from a stale snapshot is the defect this design
   exists to prevent, and T04 has the test.
6. **A photo purge is not undoable.** `lonja-dialogs-and-surfaces` rule 9's eight-second deferred write
   restores a row; it cannot restore an unlinked file. T06 uses a `barrierDismissible: false` typed
   confirm instead, and orders the work so that a crash mid-purge leaves orphan files rather than
   `photo_path` values pointing at nothing.
7. **Copying an open SQLite database can miss recent writes.** T07 runs a checkpoint through drift's
   `customStatement` before copying, and proves it with a test that writes a catch, exports, reopens
   the exported file and reads the row back. The test is the proof; no claim is made about drift's
   default journal mode.

## PR description

### What changed

S14 is implemented in full. `SettingsRepository` (abstract, drift implementation, in-memory fake) is
the single reader and the single writer of the nine S14 columns of `user_profile`. The screen carries
five sections: language / numerals / units, zone defaults and calibration, display modes, coordinate
capture, and storage plus the escape hatch. `StorageUsageService` reports real bytes;
`CatchPhotoPurgeUseCase` removes every catch image and keeps every catch row;
`DatabaseExportService` checkpoints and shares a copy of `user.db`.

### Why

`SPEC.md` §7.2 makes every setting on S14 a column of one writable row, so the alternative — a second
preference store — would have split the user's state across two files with two migration stories and
no export path. `SPEC.md` §12 makes the raw-database escape hatch the thing that lets a user verify
the no-cloud promise without us. `SPEC.md` §4.5 makes the photo purge record-preserving, because the
catch log is the only copy of a fisher's history that exists anywhere.

### How it was verified

Unit tests over the drift repository against `NativeDatabase.memory()`, including a contract suite run
against both the drift implementation and the fake. Widget tests per row, with `ar` RTL, sunlight and
glove lanes. A test that writes a catch, exports the raw database, reopens the exported file and reads
the row back. A manual airplane-mode run of the export on device. All eight gate scripts against
`app/lib`.

### Product invariants touched

Invariant 1 (the share sheet is the only outbound path, user-initiated, app-external; the database
path is selectable text and is never launched) and invariant 4 (both switches state their state as a
word). Neither is weakened; both are asserted in tests.

### Follow-ups deliberately not in this PR

- Moving E09's calibration write behind `SettingsRepository` — an E09 refactor, not an E16 diff (Risk 4).
- The `en` + US-region inch default (Risk 2) — unowned, and this screen must not write on mount.
- Adding the raw export to `SPEC.md` §14's dynamic checklist (Risk 3) — E21 owns that checklist.
- S15 and S16 (JSON, CSV, PDF, zip, transactional import) — E17.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start E17.
