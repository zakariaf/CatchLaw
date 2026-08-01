# E20/T05 — The §9.4 acceptance test, on the seeded database

| | |
|---|---|
| **Epic** | E20 — RTL and locale hardening |
| **Branch** | `epic/20-rtl-hardening` (shared) |
| **Commit** | `test(data): run the §9.4 acceptance test against the seeded reference.db` |
| **Depends on** | The bundled content contains an Arabic-script jurisdiction — see "Precondition" below |
| **Size** | M |
| **Spec** | `SPEC.md` §9.4 (in full), §9.2 (the fallback chain), §13 (search and FTS targets), §14 (Arabic FTS in airplane mode) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Owns `references/normalisation-contract.md` — the ordered fold, the dual-index rule for `ال`, and the acceptance table this task moves onto real data |
| `catchlaw-reference-database` | The read-only open, the extraction, the sha256 and the indices the query depends on. The db under test must be the one that ships |
| `testing-strategy` | Rule 4 — the data layer is tested against a real engine, never a mocked DAO; a mock proves nothing about SQL, indices or FTS5 |
| `catchlaw-conventions-index` | Invariant 7 (three files, two databases, the shipped one read-only) and rule 6 (the one-way layer map this query travels) |
| `i18n-rtl-l10n` | Normalisation is locale-invariant on purpose: invariant lowercase, never a locale-sensitive fold |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.4, in full | The ordered Arabic fold, the Latin fold, and the acceptance test: `hamour`, `هامور`, `هامورة`, `الهامور` and `Epinephelus coioides` all resolve to one species id |
| `SPEC.md` | §9.2, "Fallback chain" | requested locale → jurisdiction `default_locale` → `en` → scientific name; a missing Tier-2 string never renders a raw key |
| `SPEC.md` | §13 | Species search `< 50 ms` at 400 species / 2,400 names; legal-text FTS `< 200 ms` |
| `SPEC.md` | §14, dynamic | "Arabic full-text search of the legal text returns results in airplane mode (`هامور` and `الهامور` both hit)" |
| `SPEC.md` | §7.1 | `species_name.search_norm`, `legal_text.body_norm` and the indices the query uses |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | "The pipeline, in order", "The definite article", "Acceptance test" | The ten ordered steps, the strip-and-keep dual key, the eight-input table and the separation assertion (`شعري` must not reach `epinephelus-coioides`) |
| `.claude/skills/catchlaw-rule-engine/references/normalisation-contract.md` | "Latin and scientific names" | `Ameixa babosa`, `Venerupis corrugata` — the Galician half of the seed |
| `epics/DECISIONS.md` | D-6 | Gzipped asset, temp file, atomic rename, sha256, JSON marker, and `readOnly: true` always |
| `epics/DECISIONS.md` | D-1, D-4 | `app/assets/db/reference.db.gz`; the builder is `tools/content_builder/` |

## Precondition, stated plainly

The eight §9.4 inputs are Arabic and Latin names of **`epinephelus-coioides`**, a Gulf species. E04
seeded **Galicia**; the Gulf jurisdictions are E22, which `epics/README.md` records as running in
parallel from E04 onward and being the long pole.

If the bundled `reference.db` does not yet contain an Arabic-script jurisdiction when this task runs,
**this task fails and says so** — it does not skip, and it does not substitute a fixture. `SPEC.md`
§14's dynamic checklist requires Arabic FTS to hit `هامور` in airplane mode before release, and E21 is
the next epic. A skipped Arabic acceptance test here is a release blocker discovered on a device
instead of on a build machine. Row 1 below is that precondition, written as an assertion whose failure
message names E22.

## What this delivers

- `app/testing/data/seeded_reference.dart` — opens the **shipped** artefact: decompresses
  `app/assets/db/reference.db.gz` into a temp file, verifies its sha256 against the generated constant,
  opens it `readOnly: true`, and closes it in `addTearDown`. A helper, so not `_test.dart`.
- `app/test/data/species_lookup_acceptance_test.dart` — the acceptance table, the separation
  assertion, the FTS rows, the fallback-chain row and the two latency tripwires.
- No change to `packages/rule_engine/` and no second copy of `normaliseSpeciesTerm` (D-7, and the
  contract's own failure mode "results appear then vanish after a content rebuild — a second normalise
  copy in the CLI drifted").

## Why it is built this way

**A fixture cannot fail for a content reason, and content is where this fails.** The E02 acceptance
test runs the fold over a hand-built map and proves the *function*. Everything between the function and
the fisher is untested by it: whether `tools/content_builder/` wrote both the stripped and unstripped
keys, whether the index the query needs exists, whether the alias rows for `hammour` were authored,
whether FTS5 was compiled in, whether the shipped `.gz` is the one the builder last produced. Each of
those produces the same symptom — an Arabic search that returns nothing at 05:40 — and none of them
moves the E02 test at all. `testing-strategy` rule 4 states the general form: a mocked data layer
proves nothing about SQL, constraints or indices.

**It opens the shipped artefact, not a rebuilt one.** The test decompresses
`app/assets/db/reference.db.gz` and checks its sha256 against the generated Dart constant D-6 point 4
describes. That single row is what makes every row beneath it a statement about the app rather than
about a file somebody had lying around. It also asserts the open is read-only by attempting a write and
expecting it to throw: a writable open lets drift run `onCreate` against shipped content and leave a
`-wal` beside it, after which the sha256 no longer matches and every later integrity check is a false
alarm (`catchlaw-conventions-index` rule 7).

**The query travels the real path.** The test calls the same `ReferenceRepository` the UI calls, which
calls the same `normaliseSpeciesTerm` from `packages/rule_engine/` that
`tools/content_builder/` called when it wrote `search_norm`. That identity is the contract; a test that
normalised its own query would prove the two halves agree with the test rather than with each other.

**Both key columns, because the classic bug is one-sided.** `normalisation-contract.md` names it: strip
`ال` at index time only, and `الهامور` typed by a fisher misses the row the gazette wrote. Two rows
assert both directions — the article-stripped query hits the unstripped alias, and the unstripped query
hits the stripped one.

**Latency here is a tripwire, not a benchmark.** `SPEC.md` §13 sets `< 50 ms` for species search at 400
species / 2,400 names and `< 200 ms` for legal-text FTS. Those targets are about a Snapdragon 665, and
this test runs on CI hardware. So the rows take the **median of 20 runs** and assert the §13 ceilings
directly — a host machine that cannot meet a phone's budget is a regression worth a red build, and the
device numbers stay E21's. The rows say so in their `reason:` string so nobody quotes them as a
benchmark.

**Rejected: `NativeDatabase.memory()` with an inline schema.** That is the right tool for E05's DAO
tests and the wrong one here: an in-memory database built by the test is a fixture wearing a database's
clothes, and it re-introduces exactly the gap this task exists to close.

**Rejected: deleting the E02 fixture test.** It is the fast tier, it runs under `dart test` with no
Flutter binding, and it localises a fold regression to one function in milliseconds. This task is the
slower, more honest tier above it, not a replacement. `testing-strategy` rule 1: test at the cheapest
tier that can assert the behaviour, and add a tier only for what the cheaper one cannot see.

## Tests first

Write all 15 before `seeded_reference.dart` exists. Run them. **They must fail** — there is no helper,
so the file will not even open a database. Once it does, rows 2–9 may pass immediately if the content
and the builder are both correct; that is the good outcome and it is not evidence the test is wrong.
The rows that carry this task's red-first evidence are 1, 10, 11, 13 and 14, none of which anything has
ever checked.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `SeededReference contains at least one jurisdiction with an Arabic default_locale` | the shipped db | ≥ 1 row | The precondition above. Its failure message names E22, so a missing Gulf pack is discovered here and not on a device in E21 |
| 2 | `ReferenceRepository.findSpecies resolves hamour to epinephelus-coioides` | `hamour` | `epinephelus-coioides` | The §9.4 acceptance table, row 1 — the transliteration a non-Arabic reader types |
| 3 | `ReferenceRepository.findSpecies resolves هامور to epinephelus-coioides` | `هامور` | same | The bare Arabic stem, which is what a fisher actually types |
| 4 | `ReferenceRepository.findSpecies resolves هامورة to epinephelus-coioides` | `هامورة` | same | Step 7 of the fold, on real data. The first draft folded `ة`→`ه` and its own acceptance test could not have passed |
| 5 | `ReferenceRepository.findSpecies resolves الهامور to epinephelus-coioides` | `الهامور` | same | The definite article: the gazette writes it, the fisher does not. This is the row that proves the dual index exists in the shipped file |
| 6 | `ReferenceRepository.findSpecies resolves هــامور with tatweel to epinephelus-coioides` | tatweel-stretched | same | Step 2. OCR of the gazette PDFs emits it; it is a typographic stretch, never a letter |
| 7 | `ReferenceRepository.findSpecies resolves a Presentation-Form paste of هامور` | U+FB50–FEFF forms | same | Step 1, NFKC — the step the first draft omitted, and exactly what a paste out of a scanned PDF looks like |
| 8 | `ReferenceRepository.findSpecies resolves Epinephelus coioides to epinephelus-coioides` | the binomial | same | The scientific name is the last link in the §9.2 fallback chain and must be indexed like any other |
| 9 | `ReferenceRepository.findSpecies resolves epinephelus  coioides with a double space` | doubled space | same | Step 10. OCR loves double spaces, and a collapse that runs before the fold would change the earlier steps' input |
| 10 | `ReferenceRepository.findSpecies resolves شعري to lethrinus-nebulosus and never to epinephelus-coioides` | `شعري` | `lethrinus-nebulosus` only | The over-merge guard the contract demands. Steps 4–7 are lossy on purpose, and two species collapsing into one is the failure that makes them dangerous |
| 11 | `ReferenceRepository.findSpecies resolves Ameixa babosa and améixa babosa to venerupis-corrugata` | both | `venerupis-corrugata` | The Latin fold on the seeded Galician content — NFD, strip marks, lowercase. Without it a mis-accented paste from the Xunta table misses |
| 12 | `SpeciesRow keeps its authored display name after a normalised lookup` | the `هامورة` hit | `display_name_ar` unmodified | The fold is lossy because its output is a **search key**; the plate must print what the instrument printed. A normalised display name is a silent content corruption |
| 13 | `LegalTextRepository.search returns rows for هامور and for الهامور` | both | ≥ 1 row each | `SPEC.md` §14's dynamic requirement, moved to the build machine. `legal_text.body_norm` uses the same fold, so this is where a builder that normalised only one of the two columns is caught |
| 14 | `SeededReference sha256 matches the generated content constant` | extracted file | equal | D-6 point 4. Makes every row above a statement about the artefact that ships, not about a stray file |
| 15 | `SeededReference rejects a write when opened readOnly` | any `INSERT` | throws | Invariant 7: a writable open drops a `-wal`, after which row 14 is a false alarm forever |
| 16 | `ReferenceRepository.findSpecies stays under 50 ms and LegalTextRepository.search under 200 ms` | median of 20 runs each | `< 50 ms` / `< 200 ms` | `SPEC.md` §13. A regression tripwire on CI hardware, explicitly not the device benchmark, which is E21's |
| 17 | `ContentStrings resolve a non-empty value for epinephelus-coioides in all six locales` | the six D-3 locales | non-empty, never the raw key | §9.2's fallback chain, on the shipped data. A raw key rendered inside a legal statement is the one place a fisher cannot guess the meaning |

```dart
// app/testing/data/seeded_reference.dart   — helper, never shipped
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the artefact that SHIPS: app/assets/db/reference.db.gz, decompressed to a temp
/// file, sha256-verified against the generated constant, opened readOnly (D-6).
/// The decoder and the digest are the SAME ones E05's installer uses — a second copy
/// that disagrees is precisely the bug this file exists to catch.
Future<ReferenceDatabase> openSeededReference() async {
  final gz = File('assets/db/reference.db.gz').readAsBytesSync();
  final bytes = gzip.decode(gz);            // dart:io, no new dependency

  expect(referenceDbDigest(bytes), kReferenceDbSha256,
      reason: 'the shipped reference.db.gz is not the artefact tools/content_builder '
          'last produced — rebuild it before trusting anything below');

  final dir = Directory.systemTemp.createTempSync('catchlaw_seeded_');
  final file = File('${dir.path}/reference.db')..writeAsBytesSync(bytes);
  addTearDown(() => dir.deleteSync(recursive: true));

  final db = ReferenceDatabase(NativeDatabase(file, readOnly: true));
  addTearDown(db.close);
  return db;
}
```

```dart
// app/test/data/species_lookup_acceptance_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../testing/data/seeded_reference.dart';

/// SPEC.md §9.4's acceptance test, on the seeded database. The eight inputs and the
/// separation assertion are normalisation-contract.md's table, verbatim.
const _hamour = 'epinephelus-coioides';

void main() {
  late ReferenceRepository species;
  late LegalTextRepository legal;

  setUp(() async {
    final db = await openSeededReference();
    species = ReferenceRepositoryDrift(db);
    legal = LegalTextRepositoryDrift(db);
  });

  test('SeededReference contains at least one jurisdiction with an Arabic default_locale',
      () async {
    expect(await species.jurisdictionsWithDefaultLocale('ar'), isNotEmpty,
        reason: 'the bundle carries no Arabic-script jurisdiction yet. §9.4 acceptance '
            'is about a Gulf species and §14 requires Arabic FTS before release — the '
            'RAK Gulf pack (E22) must land before E20 can claim this.');
  });

  for (final query in const <String>[
    'hamour',
    'هامور',
    'هامورة',
    'الهامور',
    'هــامور',          // tatweel, step 2
    'ﻫﺎﻣﻮﺭ',            // Presentation Forms, step 1
    'Epinephelus coioides',
    'epinephelus  coioides',
  ]) {
    // Interpolated, so --plain-name finds the one input that broke.
    test('ReferenceRepository.findSpecies resolves $query to $_hamour', () async {
      final hits = await species.findSpecies(query);
      expect(hits.map((s) => s.id), contains(_hamour), reason: 'query: $query');
    });
  }

  test('ReferenceRepository.findSpecies resolves شعري to lethrinus-nebulosus '
      'and never to $_hamour', () async {
    final ids = (await species.findSpecies('شعري')).map((s) => s.id).toSet();
    expect(ids, contains('lethrinus-nebulosus'));
    expect(ids, isNot(contains(_hamour)),
        reason: 'steps 4-7 are lossy on purpose; two species collapsing into one is '
            'what makes them dangerous');
  });

  test('SpeciesRow keeps its authored display name after a normalised lookup', () async {
    final hit = (await species.findSpecies('هامورة')).firstWhere((s) => s.id == _hamour);
    expect(hit.displayNameAr, 'هامورة',
        reason: 'the fold produces a SEARCH KEY; the plate prints what the instrument '
            'printed');
  });

  for (final query in const <String>['هامور', 'الهامور']) {
    test('LegalTextRepository.search returns rows for $query', () async {
      expect(await legal.search(query), isNotEmpty,
          reason: 'SPEC.md §14: both must hit, in airplane mode');
    });
  }
}
```

**Run:** `cd app && flutter test test/data/species_lookup_acceptance_test.dart` → red on the missing
helper first, then on whatever the seeded content actually contains.

## Implementation outline

1. Write `app/testing/data/seeded_reference.dart`. Decompress, verify, open read-only, tear down.
   Reuse the same gzip and sha256 code paths E05 already uses for the real extraction rather than
   writing a second decoder — a second decoder that disagrees is the bug this file exists to catch.
2. Run row 1. If it fails, **stop and report**: the Gulf pack is not in the bundle and E20 cannot
   honestly claim §9.4 on real data. That is a scheduling fact about E22, not something to work around
   with a fixture.
3. Run rows 2–11. Read each failure against the ten-step table in `normalisation-contract.md` —
   the failure modes table at the end of that file maps every symptom to its cause, and it is faster
   than guessing.
4. A failure here is fixed in the **content builder or the content**, never in the test and never by
   loosening the query. If `الهامور` misses, the builder wrote one key instead of two; if a Presentation
   Form misses, NFKC is not running first.
5. Run rows 12–15. Row 15 is expected to throw; if the write succeeds, the read-only open is missing
   and every sha256 check downstream is already unreliable.
6. Run rows 16–17. Row 16 is a median of 20; if it is noisy on CI, the fix is more iterations, not a
   looser ceiling — the ceiling is `SPEC.md` §13's.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 rows pass, and each failed first.
- [ ] The database under test is `app/assets/db/reference.db.gz` — the shipped artefact — and its
      sha256 matches the generated constant.
- [ ] It is opened `readOnly: true` and a write throws (D-6, invariant 7).
- [ ] The query path is the app's own repository, calling the one `normaliseSpeciesTerm` in
      `packages/rule_engine/`. No second normalisation implementation exists anywhere in the tree.
- [ ] The E02 fixture acceptance test still exists and still passes — this tier is added, not
      substituted.
- [ ] No temp directory survives the run; `addTearDown` deletes it.
- [ ] `packages/rule_engine/` is unchanged and still declares no Flutter dependency.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze
cd app && flutter test --exclude-tags golden
cd packages/rule_engine && dart test
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(data): run the §9.4 acceptance test against the seeded reference.db

E02 proved the fold against a hand-built map. Everything between that
function and the fisher was untested: whether the builder wrote both the
stripped and unstripped ال keys, whether the index exists, whether the
alias rows were authored, whether FTS5 is compiled in, whether the shipped
.gz is the one the builder last produced. Every one of those shows up as
the same symptom — an Arabic search returning nothing at 05:40 — and none
of them moves the E02 test.

So this opens the artefact that ships: assets/db/reference.db.gz,
decompressed, sha256-checked against the generated constant, opened
readOnly, with a write asserted to throw. The eight §9.4 inputs and the
شعري separation assertion run through the app's own repository and the one
normaliseSpeciesTerm in packages/rule_engine — the same function the
content builder called when it wrote search_norm.

Also here: both directions of the definite-article dual index, the Latin
fold on the seeded Galician rows, the §14 Arabic FTS hits over
legal_text.body_norm, the §9.2 fallback chain across all six locales, and
median-of-20 tripwires on §13's 50 ms and 200 ms ceilings — a CI regression
guard, not the device benchmark, which stays E21's.

Row 1 is a precondition, not a skip: if the bundle carries no
Arabic-script jurisdiction, this fails and names E22.

Task: E20/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
