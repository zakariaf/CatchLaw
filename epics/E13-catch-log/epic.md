# E13 — The catch log

| | |
|---|---|
| **Branch** | `epic/13-catch-log` |
| **After** | E12 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §4.5 in full, §6 S8, S10, S11 and dialog D1, §7.2 (`trip`, `catch`, the denormalisation rationale), §11 (camera, no storage permission, app-private files), §13 (instant at 10,000 catches, 8,000 rows under 4 MB, crash safety) |
| **Guide** | `FLUTTER_GUIDE.md` Part 1.4, Part 5.2, Part 5.3 (the `==` rebuild trap), Part 6.4 |
| **Package** | `app/` — `app/lib/data/`, `app/lib/domain/`, `app/lib/ui/log/`, one widget in `app/lib/ui/settings/` |
| **Decisions** | D-1 (paths), D-2 (`app/lib/theme/`), D-3 (six locales), D-5 (drift 2.34.2, Riverpod 3.4.1), D-7 (the engine holds no sentence) |

## What this epic achieves

When this merges the fisher has a log, and it is the only thing in the product that cannot be
rebuilt from an asset. He can start a trip — including hours after he actually cast off — record a
catch from S2's **+ Add to today** or from S8's quick-add, see today's count per species against the
limit that applies here, photograph the fish with a camera that never writes to the shared camera
roll, attach coordinates only if he asked for them on that catch, scroll ten thousand rows of history
filtered by species, zone and date without a stutter, edit any field, delete with ten seconds to
change his mind, and see in Settings exactly how many bytes he is holding with a way to reclaim the
photo bytes that keeps every record.

Three properties are load-bearing and every task is written to protect them. **Every write is one
transaction and the catch is durable before the UI moves** (`SPEC.md` §13 — data loss unacceptable).
**The catch carries `jurisdiction_code` and `zone_code` itself**, so a zone filter finds a quick-added
catch that never belonged to a trip (§4.5 — this was a first-draft defect). **`scientific_name`,
`rule_citation_ref` and `content_version` are copied onto the row**, so a content update that
renumbers or retires a rule cannot change what a three-year-old record says (§7.2). History is
immutable against the content pipeline; it is editable only by the fisher, deliberately and in the
open.

## Where we are now

The branch is cut from a `main` where twelve epics have merged. What matters here:

- **E05** shipped `user.db`: all seven tables and five indexes of `SPEC.md` §7.2 — `trip` and `catch`
  included, with their `CHECK` constraints and `idx_catch_created`, `idx_catch_trip`,
  `idx_catch_species`, `idx_catch_zone` — behind `app/lib/data/services/user_db/`, opened through
  `LazyDatabase` with the forward-only `MigrationStrategy` of §7.4 and the `PRAGMA user_version`
  refusal. E05/T08 gave the user DAOs their `.watch()` streams and a keyset cursor over `created_at`;
  E05/T09 gave every repository an abstract interface, a drift implementation and a fake under
  `app/testing/fakes/`; E05/T10 confined drift row classes to `app/lib/data/`. E05's own PR body lists
  photo files as a deliberate follow-up: *"`catch.photo_path` is a column here and nothing more."*
- **E03** owns `packages/rule_engine/`: the §7.3 resolution algorithm, the sealed `Verdict` and
  `Finding` types with their required non-nullable `Citation`, the `is_expired` flag, and the
  `Result`/`Failure` spine at `packages/rule_engine/lib/src/failure.dart` that every repository here
  returns. E05/T09 added the sealed `DataFailure` family beneath it.
- **E07** shipped `app/lib/theme/` — the three themes, the glove-density switch and the Lonja token
  set that every row, ledger and dialog below reads.
- **E10** shipped S2 complete **except one control**: its PR body records *"+ Add to today, which
  needs the catch log — E13."* The button does not exist yet. T02 adds it.
- **E11** shipped `LocationService` for the single-shot GPS zone suggestion of §4.4, and E12 shipped
  S1, the five-item bottom navigation of §6 and the `< 1.2 s` cold-start budget. The bottom nav has
  a **Today** slot and a **Trips** slot; both currently route to a placeholder.

What does not exist: any DAO, repository, use case, view model or screen over `trip` and `catch`; any
camera code or `camera` dependency; any photo directory; any storage figure. `app/lib/ui/log/` is an
empty directory created by E01's scaffold.

## Why this epic exists here in the order

It cannot come earlier. A catch record stores the outcome of an evaluation — `outcome`,
`outcome_detail`, `rule_citation_ref`, `content_version` — and those values are produced by the
sealed `Verdict` that E10 renders and E03 computes. Writing the catch schema's consumers before that
type is final would mean copying fields that do not yet have names. It also stores
`jurisdiction_code` and `zone_code`, which come from the active zone that E11 resolves and E12's zone
chip displays. `epics/README.md` puts E10, E11 and E12 in E13's **After** column for exactly this,
and `SPEC.md` §15 step 11 lists the catch log with its dependencies `[4, 10]`.

It must not come later. E16 (Settings) is **After E09, E13** because S14 renders the storage figure
and the purge action this epic computes. E17 (Export and import) is **After E13** because there is
nothing to serialise until trips, catches and photos exist, and its merge rule dedupes on
`(created_at, species_id, length_mm)` — three columns whose exact stored shape T02 fixes here.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | Trips, including a retroactive start | `T01-trips-and-retroactive-start.md` | M | — |
| T02 | The catch record | `T02-the-catch-record.md` | M | T01 |
| T03 | S8 — today, and the vessel aggregate | `T03-s8-today-and-vessel-aggregate.md` | M | T02 |
| T04 | The in-app camera | `T04-in-app-camera.md` | L | T02 |
| T05 | Coordinates: opt-in, and a global off | `T05-coordinates-opt-in-global-off.md` | M | T02 |
| T06 | S10 — history at ten thousand rows | `T06-s10-history-at-ten-thousand-rows.md` | L | T02 |
| T07 | S11 — edit, and delete with ten seconds of undo | `T07-s11-edit-and-delete-with-undo.md` | M | T04, T05, T06 |
| T08 | Storage used, and a purge that keeps the records | `T08-storage-used-and-photo-purge.md` | M | T04, T07 |

T04, T05 and T06 have no dependency on each other and can be built in any order once T02 lands.
Everything else is a straight line.

## Definition of done for the epic

Every task's own definition of done, plus what is only checkable once the epic is whole:

- [ ] All 8 tasks committed, one commit each, every `Task: E13/T<nn>` trailer present.
- [ ] `dart format --set-exit-if-changed .` and `flutter analyze` clean at the workspace root;
      `cd app && flutter test` green — the whole suite, not just this epic's.
- [ ] Every column of `SPEC.md` §7.2's `catch` and `trip` is written by a real code path and read back
      by a test. No column is dead.
- [ ] A catch recorded with **no trip** carries `jurisdiction_code` and `zone_code`, and S10's zone
      filter returns it. This is the §4.5 defect the epic exists to close.
- [ ] Every mutation is one `db.transaction`, every statement inside it awaited, and the returned
      `Future` resolves before any UI reacts (`SPEC.md` §13, `persistence-drift` rule 4).
- [ ] A rollback test per write path: the second statement is forced to violate a constraint, the
      typed `Err` comes back and `dumpAllRows()` is byte-identical to before.
- [ ] No photo byte is ever written outside `getApplicationSupportDirectory()`; `photo_path` holds a
      **relative** path and is resolved through exactly one helper.
- [ ] `image_picker` appears in no pubspec — it is on `SPEC.md` §10's banned list and §14 diffs the
      allowlist. `camera` is added to the checked-in allowlist in T04's commit.
- [ ] With `user_profile.capture_coordinates = 0`, no code path can write a non-NULL `latitude` or
      `longitude`, proven at the repository and not at the widget.
- [ ] 10,000 seeded catches: every history page returns in under one 60 Hz frame, `EXPLAIN QUERY PLAN`
      reports `SEARCH … USING INDEX` for all three filter shapes, and the last page is within 2× the
      first.
- [ ] 8,000 catches across 200 trips: `user.db` after `VACUUM INTO` is **under 4 MB** (`SPEC.md` §13).
- [ ] A bulk photo purge removes every photo file and changes no row count; every `photo_path` in the
      affected rows is `NULL` and nothing else on those rows moved.
- [ ] `check_app_invariants.sh app/lib`, `check_lonja_lists.sh app/lib`,
      `check_lonja_dialogs.sh app/lib`, `check_lonja_buttons.sh app/lib` and
      `check_reference_db.sh app/lib` all clean.
- [ ] S8, S10 and S11 each render all four states of
      `lonja-lists-and-tables/references/the-four-states.md`, and the ochre stale bar coexists with
      data rather than replacing it.
- [ ] `packages/rule_engine/` gains no dependency and no user-visible sentence (D-7).
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**1. `catch` is a Dart keyword, and drift generates a getter from the table class name.** A drift
table class `Catch` produces `$CatchTable get catch => …` on the database class, which does not
compile. The table must be declared as `Catches` with `@DataClassName('CatchRow')` and an explicit
`String get tableName => 'catch';` so the SQL name stays exactly what `SPEC.md` §7.2 and §12's export
format publish. E05 already made this choice when it created the table; T02 must read
`app/lib/data/services/user_db/tables/catch_table.dart` before naming anything, not guess. If E05 named
the SQL table `catches` instead, that is a §7.2 divergence that belongs in a `DECISIONS.md` entry and
an E05 follow-up commit on this branch — **not** a silent rename here, because E17's import reads the
same names.

**2. The undo window is 10 seconds in `SPEC.md` and 8 seconds in the skill.** §4.5 says *"delete
undoable for 10 seconds"*; `lonja-dialogs-and-surfaces` rule 9 and its
`references/modal-decision-matrix.md` §8 both say 8 s with a deferred write. `SPEC.md` is
authoritative for the product, so T07 uses **10 s** and keeps the skill's deferred-write mechanism,
which is the part that carries the reasoning. `check_lonja_dialogs.sh` does not inspect durations, so
nothing fails on the number. **What would resolve it:** a one-line skill correction changing 8 to 10
in both files, filed as an E13 follow-up; until then this paragraph is the record.

**3. `bag_limit_unit` can be `'kg'` and the catch record holds no weight.** `SPEC.md` §7.1's `rule`
table allows a bag limit expressed in kilograms; §7.2's `catch` stores `length_mm` and nothing else.
S8 therefore cannot count against a kg limit, and inventing a length-to-weight conversion would be
the app asserting a fact it does not have. T03 renders that case as an authored *"recorded in
kilograms — this app records length"* state carrying the rule's citation, and never a number. This is
the §4.1 no-rule-versus-no-data discipline applied to a third case. **What would resolve it:** a
`weight_g` column on `catch`, which is a `SPEC.md` §7.2 amendment and out of scope here.

**4. `SPEC.md` §7.2's storage shapes and `persistence-drift` disagree, and this was settled in E05.**
§7.2 types timestamps as ISO-8601 `TEXT` and primary keys as `INTEGER PRIMARY KEY`;
`persistence-drift` rule 5 and `references/schema-and-daos.md` want UTC epoch-millis integers and a
text UUID PK with audit columns. E05's epic records the resolution in its Risks §3: `SPEC.md` wins
because §12's export format depends on those shapes, and it is safe because ISO-8601 UTC strings sort
lexicographically in chronological order. **No task in E13 re-opens this.** The one addition is to fix
the *format*: T01 ships `app/lib/data/model/iso_utc.dart`, which writes
`YYYY-MM-DDTHH:MM:SS.sssZ` — fixed width, always UTC — and every `TEXT` timestamp in `user.db` goes
through it, because T06's keyset cursor and §12's `(created_at, species_id, length_mm)` merge key both
compare those strings as text.

**5. The `Result` spine's arity is E03's.** `error-handling-typed-results` requires
`Result<T, F extends Failure>` so that adding a failure variant is a compile error at every call site;
`FLUTTER_GUIDE.md` §1.6 shows the single-parameter `Result<T>` from `flutter/samples`. E05's Risks §6
records that E05/T09 used whatever E03 committed and added `DataFailure` beneath it. Every skeleton in
this epic is written against the two-parameter form; if E03 shipped the one-parameter form the
skeletons change shape and not behaviour, and the divergence belongs in `DECISIONS.md` as a new entry
rather than being settled inside E13.

**6. `package:camera` is a new direct dependency and §14 diffs the allowlist.** `SPEC.md` §10 pins
`camera` at `^0.11` and rejects `image_picker` by name. The allowlist entry must land in T04's own
commit or the next push fails CI. `camera` also brings an Android `CAMERA` permission and an iOS
`NSCameraUsageDescription`, and §11 requires that string localised into all six locales of D-3 — six
ARB entries plus the `InfoPlist.strings` files, in the same commit.

**7. The vessel-limit aggregate can only count what this device recorded.** `rule.vessel_limit` is a
per-boat cap; CATCHLAW has no account, no sync and no second device (`catchlaw-conventions-index`
rule 11). The aggregate on S8 is therefore the total this phone holds, and T03 states that as a fact
on the surface rather than presenting it as the boat's total. Anything else would be the app claiming
knowledge it structurally cannot have.

**8. "Season totals" needs a season boundary that may not be queryable.** §6 S10 asks for *"season and
annual totals"*. The annual total is the device-local calendar year and is unambiguous. A season
boundary lives in `closed_season` (§7.1), which is keyed by `rule_id` — so it is per-species, and
there may be no jurisdiction-wide season to total against. T06 therefore totals a season only where
the resolved rule for the filtered species carries one, and otherwise renders an authored absent
state instead of silently substituting the calendar year. **What would resolve it:** reading E04's
built `reference.db` for whether any jurisdiction publishes a zone-level season window; do that before
writing T06's test table.

**9. E05/T08's keyset cursor may be single-column.** `created_at` is not unique — two quick-adds in
the same millisecond are ordinary at 05:40 — and a cursor of `created_at` alone either skips or
repeats rows at a page boundary. T06's first job is to make the cursor the composite
`(created_at, id)`. Read `app/lib/data/services/user_db/daos/` at branch cut: if E05 already shipped
the composite form, T06 keeps it and adds the filtered variants; if it shipped the single-column form,
T06 replaces it and every caller with it.

**10. The stored `outcome_detail` carries no locale tag, and that is deliberate.** §7.2 calls it "the
factual finding text as shown" and gives it no locale column, so a record made in `ar` still reads in
Arabic after the fisher switches the app to `es`. That is correct — the row says what it said — but it
means E17's CSV, whose headers are localised to the *active* language, can carry a column of sentences
in another. Do not resolve it by re-rendering the sentence at export time: that makes the record
mutable, which is the one property it must not have. If a locale tag is wanted it is a §7.2 column and
a `DECISIONS.md` entry, not a quiet addition here.

**11. §6 S11 says "all fields editable" and §7.2 has no field for when the fish was caught.** The only
instant on the row is `created_at`, which is when the *record* was written — and §12 uses it as part of
the merge key `(created_at, species_id, length_mm)`. Making it editable would let an edit change a
row's identity for E17's importer, so T07 leaves it fixed and edits everything the fisher actually
observed: species, length, measurement method, kept or released, zone, photo and coordinates. That is
a real gap between the two sections, not a decision to hide. **What would resolve it:** a `caught_at`
column on `catch`, distinct from `created_at`, which is a §7.2 amendment and a `DECISIONS.md` entry.

## PR description

### What changed

The catch log, end to end, entirely local.

**Data.** `TripDao`, `CatchDao`, `TripRepository` and `CatchLogRepository` over the §7.2 tables E05
created, with domain models `Trip`, `CatchRecord`, `CatchDraft`, `TodayTally`, `HistoryPage` and
`StorageUsage`, and one sealed `CatchLogFailure` family. Three migration steps: a partial unique index
that makes two open trips unrepresentable, and two composite indexes that serve the history screen's
filter and sort with one seek each.

**Screens.** S8 (Today) — per-species counts against limits as a Lonja ledger table, the vessel
aggregate where the resolved rule carries one, End trip, and quick-add. S10 (Trips and history) —
trip list, per-trip catches, filters by species, zone and date range, season and annual totals, and
keyset pagination. S11 (Catch detail) — every field editable, the photo, the coordinate on/off state,
and delete behind D1 with a real ten-second undo. Plus the capture surface, and a storage panel that
E16 mounts into S14.

**Services.** `CameraService` behind an injectable interface with one live `CameraGateway` over
`package:camera`, writing JPEGs into the app sandbox and returning a path relative to one base
directory. Coordinates route through E11's existing `LocationService`; no second location seam.

### Why

`SPEC.md` §13 lists data loss as unacceptable and the catch log is the only data in the product that
exists nowhere else — no account, no sync, no server (`catchlaw-conventions-index` rule 11). Every
design choice here follows from that one sentence: one transaction per mutation with every statement
awaited, the write durable before the UI animates, a delete that defers its write for the whole undo
window so a crash inside it loses nothing, and a photo purge that updates rows first and unlinks files
second so the crash window leaves orphan files rather than rows pointing at nothing.

The denormalised columns are §7.2's own argument: *"a content update can renumber or retire a rule. A
three-year-old catch record must still say what it said when it was recorded."* The
`jurisdiction_code` and `zone_code` on the catch itself are §4.5's: without them a zone filter is
blind to every quick-add that never had a trip.

The camera is in-app because §4.5 says the images are **never** written to the shared camera roll and
§10 rejects `image_picker` by name for exactly that reason. There is no storage permission because
there is nothing to write outside the sandbox (§11).

Coordinates are opt-in per catch with a global off because §4.5 says so, and the enforcement sits at
the single write path rather than in a widget, so a future screen cannot forget it.

### How it was verified

- Every write path has a rollback test: force the second statement to violate a constraint, assert the
  typed `Err`, assert the database is byte-identical (`never-lose-data.md` §1).
- A catch recorded with no trip, then filtered by zone in S10 — the §4.5 acceptance condition, as a
  test rather than a manual check.
- Immutability: record a catch, swap the reference fixture for one where the rule has been renumbered
  and its citation retired, reopen the record, assert `outcome_detail`, `rule_citation_ref` and
  `content_version` are unchanged character for character.
- 10,000 seeded catches with `EXPLAIN QUERY PLAN` asserted for each of the three filter shapes, page
  latency asserted against a 60 Hz frame, and the last page asserted within 2× the first.
- 8,000 catches over 200 trips: `user.db` measured under 4 MB after `VACUUM INTO`.
- Camera permission denied: the catch is still recordable and the surface says why the photo control
  is unavailable (`SPEC.md` §14 dynamic line 12).
- `capture_coordinates = 0` with a draft that carries a fix: `latitude` and `longitude` are written
  `NULL`.
- Undo: the row is absent from the list for the whole window, present again on undo, and gone from the
  database only after the window closes with no undo — with a test that kills the window's owner
  mid-flight and asserts the row survives.
- All four list states and the RTL and glove lanes of `the-four-states.md`'s coverage matrix, in `ar`.

### Product invariants touched

- **Invariant 2 (a verdict states a fact and never instructs).** S8's rows read `2 of 5 recorded
  today`, never `Keep` or `Stop`. Whether a count exceeds its limit is a `Finding` from
  `packages/rule_engine/`, never an `if` in a widget — D-7, and `check_lonja_buttons.sh` check 5.
- **Invariant 3 (every result carries a citation).** The limit shown on an S8 row carries the citation
  of the rule that set it; a stored catch carries `rule_citation_ref` and `content_version` as
  literals so the citation survives a content update.
- **Invariant 4 (colour is never the only signal).** Every count-against-limit state is a `LonjaPill`
  with glyph, word and hue.
- **Invariant 5 (an expired ruleset is still evaluated and still shown).** S8 and S11 render the ochre
  stale bar above unchanged data; neither returns early and neither disables a control.
- **Invariant 1 (no network) is not weakened.** `camera` opens no socket; it is added to the §14
  allowlist in T04 and diffed there.

### Follow-ups deliberately not in this PR

- **S14 itself.** T08 delivers the storage figure, the purge write path and a `StorageUsagePanel`
  widget; the Settings screen that mounts it is E16, which must call this and not re-implement it.
- **Export, import and the trip-report PDF.** E17. This epic fixes the stored shapes E17 serialises —
  the UTC timestamp format and the relative photo path — and nothing more.
- **Golden lanes for S8, S10 and S11 in all six locales.** The `ar` lanes named in
  `the-four-states.md`'s matrix are in scope here; the full six-locale × two-theme matrix is E20.
- **Semantics sweep and the 200% text-scale pass.** Every widget here authors its own semantics per
  `accessibility-as-code`; the systematic audit is E19.
- **Flag a wrong rule.** `rule_flag` is written by E10's S2 action; nothing here touches it.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start E14.

**Gate paths used throughout this epic.** In-repo gates are invoked from the repository root as
`.claude/skills/<name>/scripts/check_*.sh app/lib` — they exit 2 on a missing directory, so the target
is always explicit (`CONVENTIONS.md` §7, D-1). The general Flutter skills live in the separate plugin
named in `CONVENTIONS.md` §4; their scripts are written below as
`$FLUTTER_SKILLS/<skill>/scripts/<script>.sh app/lib`, where `$FLUTTER_SKILLS` is that plugin's
`skills/` directory. Passing the target explicitly matters there too — E05 recorded that
`check-drift-confinement.sh` prints `SKIP` and exits **0** on a missing target, which is precisely the
failure mode `CONVENTIONS.md` §7 warns about.
