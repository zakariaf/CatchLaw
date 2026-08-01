# E05/T03 — The marker and the generated constant

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `epic/05-data-layer` (shared) |
| **Commit** | `feat(data): decide extraction from a generated constant, not from the shipped database` |
| **Depends on** | T02 (the installer takes a `MarkerStore` and a `ReferenceBuild`), T04 (`app_meta` is where the marker lives) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.4 bullet 1 (the marker, the sidecar and the generated constant); §8 "The content pipeline is a first-class deliverable" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-reference-database` | Rule 5 — the build id ships as a sidecar asset **and** a generated Dart constant, never read from `content_meta`. `references/extraction-and-first-launch.md` states the circular check plainly |
| `catchlaw-conventions-index` | Rule 7 (three files, two databases) and rule 9 (route before you edit — the emit step lands in the content builder, whose owner is `catchlaw-content-pipeline`) |
| `persistence-drift` | The `app_meta` key/value read and write, and why it is one transaction |
| `error-handling-typed-results` | The comparison is total: a missing marker, an unreadable marker and a mismatched marker are three named outcomes, not a nullable bool |
| `testing-strategy` | Rule 4 (real in-memory engine for the `app_meta` side) and rule 5 (the spy that proves no reference database was opened) |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.4 bullet 1 | The whole mechanism: `assets/content_build.json`, the generated Dart constant, the comparison against `app_meta.content_build_date`, and the words "no database open is required to decide, which the first draft's design made circular" |
| `SPEC.md` | §8 "The content pipeline is a first-class deliverable" | The builder's existing obligations, which this task adds one emit step to |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rule 5; "The circular build-date check" | Why two artefacts exist: the constant is what the gate compares, the sidecar is what the installer reads for the byte count |
| `.claude/skills/catchlaw-reference-database/references/extraction-and-first-launch.md` | "What the content tool emits", "The circular check, stated plainly", "Verifying by hand" | The four artefacts, the three-step proof that the naive gate cannot work, and the `gzip -dc … \| wc -c` check |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | rule 9 | Route before you edit: the builder change is `catchlaw-content-pipeline`'s territory and is kept to one emit step |
| `FLUTTER_GUIDE.md` | §4.4 | Do not blanket-exclude `**/*.g.dart` — the generated constant must stay analysed |
| `FLUTTER_GUIDE.md` | §7.4 | Generated files are committed |
| `epics/DECISIONS.md` | D-4 | The builder is `tools/content_builder/`, package `content_builder`, run as `dart run content_builder:build` |
| `epics/DECISIONS.md` | D-6 | Parts 3 and 4 of the merged design: the marker is `app_meta.content_build_date`, and the decision compares a generated constant against it |

## What this delivers

- `app/assets/content_build.json` — `{"build_date": "…", "schema_version": N, "bytes": N, "sha256":
  "…"}`, emitted by the builder, listed under `assets:` in `app/pubspec.yaml`.
- `app/lib/data/services/reference/content_build.g.dart` — `kContentBuildDate`,
  `kContentSchemaVersion`, `kContentBuildBytes`, `kContentBuildSha256`. Emitted by the builder,
  committed.
- `app/lib/data/services/reference/content_build.dart` — `const ReferenceBuild kReferenceBuild`
  assembled from those four constants, plus `Future<ExtractionDecision> decideExtraction(...)` returning
  the sealed `ExtractionDecision`: `AlreadyInstalled`, `NeverInstalled`, `BuildMoved(installed:,
  expected:)`, `FileMissing`.
- `app/lib/data/services/app_meta_marker_store.dart` — `AppMetaMarkerStore implements MarkerStore`,
  reading and writing the single `app_meta` row keyed `content_build_date`.
- `tools/content_builder/lib/src/emit_content_build.dart` — the emit step, wired into
  `dart run content_builder:build` after the database is written and gzipped.
- `app/test/data/content_build_decision_test.dart`,
  `tools/content_builder/test/emit_content_build_test.dart`.

## Why it is built this way

**The obvious gate is circular, and the spec says so in its own voice.** `SPEC.md` §7.4 records that the
first draft decided whether to extract by reading the build date out of the shipped database. To read
one row you must open the database; to open it you must decompress ~10 MB to disk; which is the entire
job the check was supposed to skip. So the naive design re-extracts on every launch and its cost is the
worst possible one — paid every time, on the cold-start path, for a comparison of twenty bytes.

**The decision therefore compares two things that are already in hand.** `kContentBuildDate` is compiled
into the binary — zero I/O, and structurally incapable of disagreeing with the payload that shipped
alongside it. `app_meta.content_build_date` is one row in `user.db`, a file that opens anyway because
every screen reads settings from it, indexed by a `TEXT PRIMARY KEY`. **No reference database is opened
to make the decision**, which is the property `SPEC.md` §7.4 states and test 8 asserts with a spy.

**Two artefacts, deliberately.** The generated constant is what the gate compares. The JSON sidecar is
what the installer reads for the byte count that drives the determinate bar and what the "about the rule
book" screen (E18) reads for the counts — none of which should require opening ~10 MB of SQLite. Adding
a field to the sidecar is a sidecar change; adding a field the *gate* depends on is a change to
`content_build.g.dart`. Test 10 asserts the two never disagree, because a stale generated constant
against a fresh payload is a bar that finishes at 94 % and a review that reads it as "extraction is
slow" rather than "the constants are stale".

**The marker is written to `user.db`, not to a stamp file.** D-6 merged `SPEC.md` §7.4's marker with the
skill's mechanics and assigned the marker to `app_meta.content_build_date`. It is not re-argued here.
The consequence worth stating: the marker write is a write to the *user* database, so it must happen
**after** the rename and inside one transaction, and a failure to write it is harmless — the next launch
sees a mismatch and re-extracts a file that is already correct. The reverse ordering is not harmless,
which is why T02 asserts it.

**Reading the marker does not couple the two databases.** `AppMetaMarkerStore` holds a `UserDatabase`
and nothing else; the installer holds a `MarkerStore` and nothing else. There is no `ATTACH`, no shared
`QueryExecutor` and no SQL spanning both files — `catchlaw-reference-database` rule 11 is intact, and
`check_reference_db.sh` check 5 stays green. The two connections are opened sequentially, by two
`LazyDatabase` callbacks, and neither knows the other exists.

**The decision is a sealed type, not a bool.** Four outcomes matter and they are not the same:
`AlreadyInstalled` skips, `NeverInstalled` is a genuine first launch (E12 shows the bar),
`BuildMoved(installed:, expected:)` is an app update carrying new content (the bar again, and the
mismatch is worth logging), `FileMissing` is a marker without a database — the user cleared storage.
A `bool` collapses the last two, and the one that gets collapsed is the one that needs the log line.

**Rejected: `content_meta.schema_version` as the gate.** `content_meta` still exists inside the database
and is still authoritative for display; it is simply never part of the decision to extract. That
sentence is from `extraction-and-first-launch.md` and is repeated here only because it is the thing a
reader will try to change.

**Rejected: emitting the constant by hand.** A hand-edited `content_build.g.dart` will be wrong on the
first content rebuild that somebody forgets to mirror. It is emitted by the same command that writes the
gz, in the same run, from the same bytes: the builder hashes the file it just wrote rather than being
told what the hash is.

**A note on the `.g.dart` suffix.** `content_build.g.dart` is generated by `content_builder`, not by
`build_runner`. The suffix is kept because it is what `catchlaw-reference-database` rule 5 names and
because every gate script skips `*.g.dart` when scanning for hand-written defects. It cannot collide
with `build_runner`: no builder claims `content_build.g.dart` as an output, since there is no
`content_build.dart` input that would produce it. `FLUTTER_GUIDE.md` §4.4 keeps it analysed rather than
excluded.

## Tests first

Write every row before touching the builder or the decision function. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `decideExtraction returns NeverInstalled when app_meta holds no content_build_date` | empty `user.db` | `NeverInstalled` | A genuine first launch, and the only path that shows the 6 s bar to a new user |
| 2 | `decideExtraction returns AlreadyInstalled when the marker equals the generated constant` | marker = constant, file present | `AlreadyInstalled` | The path taken on every launch after the first; it must cost two stat calls and one row read |
| 3 | `decideExtraction returns BuildMoved with both dates when the marker is older than the constant` | marker `2026-05-02`, constant `2026-07-14` | `BuildMoved(installed: '2026-05-02', expected: '2026-07-14')` | An app update carrying new content. Both values are in the type so the log line names them |
| 4 | `decideExtraction returns BuildMoved when the marker is newer than the constant` | marker `2026-08-01`, constant `2026-07-14` | `BuildMoved` | A downgrade. The reference database is disposable, so it re-extracts — unlike `user.db`, which T06 refuses |
| 5 | `decideExtraction returns FileMissing when the marker matches but reference.db is absent` | marker = constant, no file | `FileMissing` | The user cleared storage. Collapsing this into `NeverInstalled` loses the only signal that it happened |
| 6 | `decideExtraction returns NeverInstalled when reference.db exists but the marker does not` | file present, marker `null` | `NeverInstalled` | Cheaper to re-extract than to prove an unmarked file is right — the ladder says so |
| 7 | `decideExtraction opens no reference database` | spy `AssetBundleService` and a spy on the executor | zero opens, zero asset reads | The circular-check defect, asserted rather than described |
| 8 | `decideExtraction reads app_meta exactly once` | counting `UserDatabase` wrapper | 1 | This runs on the cold-start path inside the 1.2 s budget; a loop here is invisible until it is not |
| 9 | `AppMetaMarkerStore.write replaces the previous content_build_date` | write twice | one row, latest value | `app_meta` is a key/value table; two rows for one key would make the marker ambiguous |
| 10 | `content_build.g.dart agrees with assets/content_build.json` | parse both | `build_date`, `schema_version`, `bytes`, `sha256` all equal | A stale constant against a fresh payload is the bar that finishes at 94 % |
| 11 | `emitContentBuild writes the sha256 of the gz payload it just produced` | run the emit step over a known file | sha256 equals `shasum -a 256` of the decompressed file | The builder hashes what it wrote; it is never told the hash |
| 12 | `emitContentBuild writes the uncompressed byte count of the payload` | same | equals `gzip -dc … \| wc -c` | The determinate bar's denominator. A compressed count would make the bar run past 100 % |
| 13 | `emitContentBuild overwrites a stale content_build.g.dart` | run twice with different content | second run's values | The failure mode is a builder that appends or skips, and the symptom appears one release later |

```dart
// app/test/data/content_build_decision_test.dart
import 'package:catchlaw/data/services/reference/content_build.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes/spy_asset_bundle_service.dart';

void main() {
  late UserDatabase user;

  setUp(() {
    user = UserDatabase(NativeDatabase.memory());
    addTearDown(user.close);
  });

  test('decideExtraction returns NeverInstalled when app_meta holds no content_build_date', () async {
    final decision = await decideExtraction(
      marker: AppMetaMarkerStore(user),
      expected: kReferenceBuild,
      databaseExists: () async => false,
    );

    expect(decision, isA<NeverInstalled>());
  });

  test('decideExtraction returns BuildMoved with both dates when the marker is older than the constant',
      () async {
    await AppMetaMarkerStore(user).write('2026-05-02');

    final decision = await decideExtraction(
      marker: AppMetaMarkerStore(user),
      expected: kReferenceBuild.copyWith(buildDate: '2026-07-14'),
      databaseExists: () async => true,
    );

    expect(decision, isA<BuildMoved>());
    expect((decision as BuildMoved).installed, '2026-05-02');
    expect(decision.expected, '2026-07-14');
  });

  test('decideExtraction opens no reference database', () async {
    final bundle = SpyAssetBundleService();

    await decideExtraction(
      marker: AppMetaMarkerStore(user),
      expected: kReferenceBuild,
      databaseExists: () async => true,
      bundle: bundle,
    );

    expect(bundle.opens, isEmpty,
        reason: 'reading content_meta to decide is circular: it costs the 10 MB it exists to skip');
  });

  // … one test per remaining row above, one behaviour each
}
```

## Implementation outline

1. In `tools/content_builder/`, add `emitContentBuild()`: after the database is written and gzipped,
   hash the **uncompressed** file, measure its length, and write both `app/assets/content_build.json`
   and `app/lib/data/services/reference/content_build.g.dart`. Both are truncated and rewritten, never
   appended to.
2. Wire the call into `dart run content_builder:build` after the gzip step, so the three artefacts are
   produced in one run and cannot diverge.
3. Add `assets/content_build.json` to `app/pubspec.yaml` under `assets:`.
4. Write `content_build.dart`: `kReferenceBuild` assembled from the four constants, the sealed
   `ExtractionDecision`, and `decideExtraction` — a `switch` over marker-present × file-present with no
   `default:`.
5. Write `AppMetaMarkerStore`: `read()` is one `select` on `app_meta`; `write(String)` is one
   `insertOnConflictUpdate` inside one `transaction`.
6. Call `decideExtraction` from `ReferenceInstaller.ensureInstalled` in place of T02's placeholder gate,
   and pass `kReferenceBuild` where T02 took the values as a constructor argument. T02's tests keep
   injecting theirs; nothing about the injection seam changes.
7. Run the builder once against the Galicia seed E04 shipped, and commit the three regenerated
   artefacts.
8. Re-run the suite. 13 green, and T01's and T02's still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 13 tests pass, and each failed first.
- [ ] The extraction decision reads no asset and opens no reference database — asserted, not reviewed.
- [ ] `content_build.g.dart` and `assets/content_build.json` are byte-consistent, and a test proves it.
- [ ] Both are produced by one `dart run content_builder:build`, and both are committed.
- [ ] `content_meta` is not read anywhere on the launch path.
- [ ] The marker is written after the rename and inside one transaction.
- [ ] No `ATTACH` and no shared `QueryExecutor`; check 5 of `check_reference_db.sh` is green.
- [ ] `ExtractionDecision` is switched exhaustively with no `default:` at every call site.
- [ ] `tools/content_builder/` gained one emit step and no other behaviour.

## Gates

```bash
cd tools/content_builder && dart format --set-exit-if-changed . && dart analyze && dart test
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): decide extraction from a generated constant, not from the shipped database

SPEC 7.4 records that the first draft compared the build date read out of
reference.db. That is circular: reading one row means decompressing ~10 MB
to disk, which is the whole job the check exists to skip, so the gate cost
exactly what it was meant to avoid on every launch.

The decision is now a compiled-in constant against app_meta.content_build_date
in user.db — one indexed row in a file that opens anyway — and returns a
sealed ExtractionDecision rather than a bool, so "marker present but the
database is gone" stays distinguishable from a first launch. The content
builder emits assets/content_build.json and content_build.g.dart in the same
run that writes the gz, hashing the file it just wrote, and a test asserts
the two never disagree: a stale constant is a determinate bar that finishes
at 94 %, which reads as slow extraction rather than stale constants.

Task: E05/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
