# E04/T09 — The per-jurisdiction diff into `content_change`

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): emit the per-jurisdiction diff into content_change` |
| **Depends on** | T02 (`Failure`, the registry), T03 (`*_key` coverage — the change keys are `*_key`s) |
| **Size** | M |
| **Spec** | `SPEC.md` §8 bullet 9, §7.1 `content_change`, §6 S23, §4.7 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | A10 and `references/licence-provenance.md` §"The per-jurisdiction changelog" — what the changelog is for and who reads it |
| `catchlaw-reference-database` | Rule 4 — a content update replaces `reference.db` wholesale. The diff is the only record of what moved between two wholesale replacements |
| `catchlaw-conventions-index` | Rule 12 — a `summary_key` is a shipped string and gains all six locales in the same PR as the change it describes |
| `testing-strategy` | Fixture corpora at two versions; the snapshot is itself a fixture |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, bullet 9 | "emit the per-jurisdiction diff into `content_change`" |
| `SPEC.md` | §7.1, `content_change` | The columns: `jurisdiction_id`, `from_version`, `to_version`, `summary_key`, `detail_key`, `changed_on` |
| `SPEC.md` | §6, S23 | The changelog screen that reads these rows — E15's consumer |
| `SPEC.md` | §4.7 | Trust and currency: the user must be able to see what changed and on whose authority |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | A10 row | `A10 AE-RAK changed but content/CHANGELOG/ae-rak.md is unchanged`, and the cause: a rule edited without regenerating |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "The per-jurisdiction changelog" | Rules added, amended (old → new), withdrawn; citations re-retrieved; plates added or dropped. And who reads it: a regulator, a translator, a future maintainer |
| `.claude/skills/catchlaw-content-pipeline/SKILL.md` | "Run the engine over the data, then diff the jurisdictions" | The changelog is emitted **after** the assertions pass, one file per jurisdiction |
| `epics/README.md` | E15, E22 | S23 is E15's; E22 is the epic that will actually exercise this daily |

## What this delivers

- `tools/content_builder/lib/src/diff/snapshot.dart` — `Snapshot.of(ContentSource, jurisdiction)`, a
  sorted, canonical JSON projection of the shipping rows for one jurisdiction.
- `tools/content_builder/lib/src/diff/content_diff.dart` — `ContentDiff.between(Snapshot, Snapshot)`
  producing added / amended / withdrawn entries with old and new values.
- `tools/content_builder/lib/src/assert/a10_changelog.dart` — `ChangelogAssertion`.
- `content/<jurisdiction>/changes.yaml` — the authored change notes, each keyed and translated.
- `content/<jurisdiction>/snapshot.json` and `content/CHANGELOG/<jurisdiction>.md` — generated,
  committed, and re-generated on every build.
- `--check` on the CLI: compute everything, write nothing, exit 1 if the committed artefacts are
  stale.
- `tools/content_builder/test/diff/snapshot_test.dart`, `test/diff/content_diff_test.dart`,
  `test/assert/a10_changelog_test.dart`.

## Why it is built this way

**The diff needs a previous state, and a git tag is the wrong place to keep it.**
`catchlaw-content-pipeline` describes the changelog as a diff against the previous content tag. A
builder that shells out to `git` is a builder that behaves differently in a shallow CI clone, in a
worktree, and on a machine with no tags fetched — and its output would then depend on the checkout
rather than on the input. `content/<jurisdiction>/snapshot.json` is checked in instead: a canonical,
sorted projection of exactly the fields that ship. The diff is `snapshot.json` versus the corpus, and
the snapshot is rewritten by the same build. **Rejected:** diffing against the previously built
`reference.db`, which would make the binary asset a build input and put a 10 MB file in every review.

**A machine cannot write a `summary_key`, so it does not try.** `content_change.summary_key` is a
`*_key`, and T03's A2 requires it in all six locales. A generated English sentence would fail A2 the
moment it was generated, and generating six of them is machine translation of a legal note — exactly
what `SPEC.md` §9.2 forbids for tier-2 content. So the mechanical diff **detects** the change and the
author **writes** it: `content/<jurisdiction>/changes.yaml` carries one entry per change, with
`from_version`, `to_version`, `summary_key`, optional `detail_key`, `changed_on` and the list of rule
ids it covers. A10 fails when a rule differs from the snapshot and no authored entry covers it.

That inversion is the whole point of A10. The failure it prevents — recorded in `build-assertions.md`
as "a rule edited without regenerating" — is a minimum size that changed with nothing in S23 to say
so. `SPEC.md` §4.7 promises the user can see currency; an undocumented change breaks that promise
silently.

**`--check` exists because a build that always writes can never fail A10.** If the build regenerates
`snapshot.json` and the changelog every time, the committed files are correct by construction and A10
detects nothing. The standard generated-file discipline applies: the local build writes, and `--check`
computes the same artefacts and exits 1 when they differ from what is committed, naming the file. The
authored `changes.yaml` requirement is checked in **both** modes — that half is about the corpus, not
about generated-file drift.

**The changelog `.md` is a repository artefact and is not translated.**
`licence-provenance.md` says who reads it: a regulator, a translator, a future maintainer answering
"when did this minimum change, and on whose authority". It is not shipped in the database, so it
carries no A2 obligation. What ships is the `content_change` row and its keyed strings. Keeping the
two separate stops somebody translating a diff into Catalan.

**One file per jurisdiction, because that is how the work is divided.** `SPEC.md` §15 step 19 has
content authoring running in parallel from step 3 onward. Two authors on two jurisdictions must not
collide in one changelog, and E22 will have several. The snapshot is per jurisdiction for the same
reason.

**`changed_on` is authored, `from_version` and `to_version` come from `jurisdiction.content_version`.**
`SPEC.md` §7.1 puts `content_version` on the jurisdiction row, so the diff reads the previous value
out of the snapshot and the new value out of the corpus. A10 fails when rows changed and
`content_version` did not: a wholesale replacement that reports the same version as the one it
replaced makes `catch.content_version` — the column §7.1 denormalises precisely so history survives —
point at two different rulesets.

## Tests first

Write every row before touching `snapshot.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Snapshot.of projects only the fields that ship` | a corpus with authoring-only fields | no `sha256`, no `no_vernacular` reason text, no comments | A snapshot that includes authoring metadata reports a diff every time a note is reworded |
| 2 | `Snapshot.of sorts rows by id` | rows authored out of order | ascending id order | A diff driven by file order is noise, and noise is what makes a diff unread |
| 3 | `Snapshot.of is stable across two runs over identical input` | same corpus twice | byte-identical JSON | The snapshot is committed; an unstable projection makes every build a diff |
| 4 | `ContentDiff.between reports an added rule` | rule absent, then present | one `added` entry naming the id | The commonest change |
| 5 | `ContentDiff.between reports an amended rule with old and new values` | `min_size_mm` 380 → 400 | one `amended` entry carrying both | `licence-provenance.md` requires old → new, because "it changed" answers nothing |
| 6 | `ContentDiff.between reports a withdrawn rule` | rule present, then absent | one `withdrawn` entry | A rule that disappears is the change least likely to be noticed in review |
| 7 | `ContentDiff.between reports a re-retrieved citation` | `retrieved_on` moved | one `amended` entry on the citation | §4.7 currency: the footnote's date changed and the user can see why |
| 8 | `ContentDiff.between reports a dropped plate` | plate removed from the ledger | one `withdrawn` entry | T06 drops plates; S17's attribution list shrinks and the reason must be recorded |
| 9 | `ContentDiff.between reports nothing when the corpus is unchanged` | identical snapshots | empty diff | The green path, and the one that runs on every build that changes nothing |
| 10 | `ChangelogAssertion reports A10 when a changed rule has no authored change entry` | `min_size_mm` moved, `changes.yaml` untouched | one `A10` naming the jurisdiction and the rule id | The failure this assertion exists for |
| 11 | `ChangelogAssertion accepts a changed rule covered by an authored entry` | entry listing the rule id | no failures | The green path the author is being pushed towards |
| 12 | `ChangelogAssertion reports A10 when rows changed and content_version did not` | rows differ, same version | one `A10` | `catch.content_version` would point at two different rulesets, and §7.1 denormalises it so history survives |
| 13 | `ChangelogAssertion reports A10 in --check mode when snapshot.json is stale` | committed snapshot behind the corpus | one `A10` naming the file | The generated-file discipline; without it A10 can never fire |
| 14 | `ChangelogAssertion reports A10 in --check mode when the changelog markdown is stale` | committed `.md` behind the corpus | one `A10` naming the file | Same, for the human-readable half |
| 15 | `ChangelogAssertion writes one changelog file per jurisdiction` | two jurisdictions changed | two files, each holding only its own rows | Parallel authoring per `SPEC.md` §15 step 19 |
| 16 | `ContentChangeRows carry the six §7.1 columns` | one authored entry | `jurisdiction_id`, `from_version`, `to_version`, `summary_key`, `detail_key`, `changed_on` | The rows S23 reads; a missing column is a screen with nothing on it |
| 17 | `ChangelogAssertion emits summary_key as a KeyReference` | one authored entry | A2 sees the key | A change note that is not translated fails the build in T03, which is where it should fail |

```dart
// tools/content_builder/test/assert/a10_changelog_test.dart
import 'package:content_builder/src/assert/a10_changelog.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('ChangelogAssertion', () {
    test('reports A10 when a changed rule has no authored change entry', () {
      final source = contentSourceWithAmendedRule(
        ruleId: 'es-ga-r-014',
        from: 380,
        to: 400,
        changesYaml: kEmptyChangesYaml,
      );
      final failures = const ChangelogAssertion().run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A10');
      expect(failures.single.message,
          contains('ES-GA rule es-ga-r-014 changed with no entry in changes.yaml'));
    });

    test('reports A10 when rows changed and content_version did not', () {
      final source = contentSourceWithAmendedRule(
        ruleId: 'es-ga-r-014', from: 380, to: 400, bumpVersion: false,
      );
      expect(const ChangelogAssertion().run(source).single.message,
          contains('content_version'));
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/diff test/assert/a10_changelog_test.dart)` →
every case red. If case 9 passes now, the diff is returning empty for everything — check case 4 is
also red before believing it.

## Implementation outline

1. `Snapshot.of` — build a `Map<String, Object?>` per shipping row, restricted to the fields that
   reach the database, then encode with sorted keys and a stable two-space indent.
2. `ContentDiff.between` — set difference on ids for added and withdrawn; field-by-field comparison
   for amended, keeping old and new for each changed field.
3. `changes.yaml` loaded as authored entries, each naming the rule, citation or plate ids it covers.
4. `ChangelogAssertion` — for each jurisdiction, diff the corpus against its committed snapshot,
   require an authored entry covering every changed id, and require `content_version` to differ when
   the diff is non-empty.
5. In `--check` mode, render the snapshot and the markdown to strings and compare against the
   committed files; report each stale file as its own `A10`.
6. In write mode, emit `content/<jurisdiction>/snapshot.json` and
   `content/CHANGELOG/<jurisdiction>.md` — but only after every assertion has passed, per T01's
   four-phase contract.
7. Emit one `content_change` row per authored entry, into the emit step T10 owns.
8. Emit each `summary_key` and `detail_key` as a `KeyReference` so A2 forces the six translations.
9. Register after A8.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 rows pass, and each failed first.
- [ ] 100 % branch coverage on `snapshot.dart`, `content_diff.dart` and `a10_changelog.dart`.
- [ ] Running the build twice over an unchanged corpus produces no diff in `snapshot.json` or in
      `content/CHANGELOG/`.
- [ ] `--check` exits 1 with a named file when either generated artefact is stale, and exits 0 when
      they are current.
- [ ] The builder shells out to no external process; `grep -rn "Process.run\|Process.start"
      tools/content_builder/lib` returns nothing.
- [ ] `content/CHANGELOG/es-ga.md` exists and is committed, and the changelog format is documented in
      `content/README.md`.
- [ ] `content_change` rows carry all six `SPEC.md` §7.1 columns, ready for E15's S23.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): emit the per-jurisdiction diff into content_change

licence-provenance.md names the readers: a regulator, a translator and a
future maintainer answering "when did this minimum change, and on whose
authority". SPEC.md §4.7 promises the user can see currency, and S23 is where
they see it.

The previous state is a committed snapshot.json rather than a git tag. A
builder that shells out to git behaves differently in a shallow clone, in a
worktree and on a machine with no tags fetched, and its output would then
depend on the checkout instead of on the input.

A machine cannot write a summary_key. It is a *_key and A2 requires it in all
six locales; generating six of them is machine translation of a legal note,
which §9.2 forbids for tier-2 content. So the diff DETECTS the change and the
author WRITES it in changes.yaml, and A10 fails when a rule differs from the
snapshot with nothing to explain it. That inversion is the whole assertion: a
minimum size that moved with nothing in S23 to say so.

--check exists because a build that always regenerates can never fail A10; it
computes the same artefacts, writes nothing, and exits 1 naming the stale
file. Rows that changed with no content_version bump also fail: §7.1
denormalises content_version onto the catch row so history survives a wholesale
replacement, and two rulesets sharing a version make that column a lie.

Task: E04/T09
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
