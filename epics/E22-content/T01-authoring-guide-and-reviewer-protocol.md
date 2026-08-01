# E22/T01 — The authoring guide and the reviewer protocol

| | |
|---|---|
| **Epic** | E22 — Content authoring at scale |
| **Branch** | `epic/22-content/T01-authoring-guide` (cut from a current `main`) |
| **Commit** | `feat(content_builder): require a current reviewer sign-off for every shipped locale (A11)` |
| **Depends on** | — (E04 merged) |
| **Size** | L |
| **Spec** | `SPEC.md` §8 ("The content pipeline is a first-class deliverable", the authoring-volume paragraph), §9.2 step 3, §4.7, §17 step 5 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Owns the authoring formats and the assertion contract. Rules 2, 6 and 12 fix what this guide may not soften — every assertion fatal, `retrieved_on` human-authored, gazette-only sourcing — and `references/build-assertions.md` fixes the failure-line shape A11 must match |
| `catchlaw-conventions-index` | Rule 9, route before you edit: this task writes the front door for eight more, so it must point at owners rather than restate them. Invariant 3 is what a rule row's evidence exists to satisfy |
| `catchlaw-rule-engine` | Rule 9 (`RuleFinding({required Citation citation})`) and rule 12 (a measurement is compared only against its own method) — the two engine facts an author has to understand before touching `rules.yaml` |
| `catchlaw-reference-database` | Rule 8 — a `catches` row denormalises `citation_text` and `content_version`, so an authored row's wording is copied into a fisher's permanent record and cannot be quietly corrected later |
| `testing-strategy` | Which level A11 belongs at — pure Dart `package:test` over an in-memory corpus, no widget binding |
| `dependency-hygiene` | This task adds an assertion to an existing package and must add no dependency to do it; a YAML ledger needs nothing that is not already there |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, "The content pipeline is a first-class deliverable" | The nine build guarantees an author is writing against, and the authoring-volume paragraph that sizes the job |
| `SPEC.md` | §9.2, steps 1–4 | The sourcing order, and step 3 verbatim: *a wrong vernacular name is worse than no name, because it produces a confident wrong finding* |
| `SPEC.md` | §17 step 5 | The disconfirming-question discipline: *"What do you use today when you're not sure, and what would have to be true for you to stop using it?"* — a group that answers "I just know" has told you something |
| `SPEC.md` | §4.7 | What the app promises about currency: the content-version banner, the per-jurisdiction changelog, "checked <date>" |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | "The ten assertions", "Failure format", "rules.yaml schema" | The `<assertion-id> <file>:<line> <message>` shape A11 joins, and the field list the guide documents |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "Sourcing: the gazette, and nothing else"; "The two translation tiers" | What a `source_url` may point at, why `retrieved_on` is human-entered, and which table a verbatim article may never enter |
| `.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh` | checks 1, 2 and the `OK_RE` line | Which checks honour `content-pipeline-ok` and which do not — the guide must tell an author where a fixture may live |
| `epics/CONVENTIONS.md` | §7, §8, §9 | The gate-is-a-floor rule, the definition of done under every task, and the five invariants an authored row can weaken |
| `epics/DECISIONS.md` | D-3, D-4, D-7 | Six locales and their exact ARB filenames; the one name for the builder; and that no user-visible sentence lands in the engine |
| `FLUTTER_GUIDE.md` | §2.4, §2.5 | The pub-workspace member this assertion lands in: one root `dart pub get`, one lock file, no `dependency_overrides` |
| `FLUTTER_GUIDE.md` | §6.1, §6.4 | Test naming with receipts, and the budget: an assertion over an in-memory corpus is a pure-Dart unit test — push the weight down the pyramid |

## What this delivers

- `content/AUTHORING.md` — how one rule row is authored end to end, and the evidence it carries. One
  section per authored file, keyed to the assertion that will reject a mistake in it.
- `content/REVIEW.md` — the reviewer protocol: who reviews each locale, what they are shown, what
  they are asked to **disconfirm**, and what a sign-off means.
- `content/reviewers.yaml` — the sign-off ledger. One block per (locale, jurisdiction, scope), each
  carrying the `scope_hash` of exactly the rows it covered.
- `tools/content_builder/lib/src/model/review_signoff.dart` — the ledger row type.
- `tools/content_builder/lib/src/review/scope_hash.dart` — `scopeHash(ContentSource, {locale,
  jurisdiction, scope})`, a canonical, order-independent digest of the rows a sign-off covers.
- `tools/content_builder/lib/src/assert/a11_review_signoff.dart` — `ReviewSignoffAssertion`.
- `tools/content_builder/testing/fixtures/review_fixtures.dart` — `k`-prefixed inline YAML.
- `tools/content_builder/test/review/scope_hash_test.dart`,
  `test/assert/a11_review_signoff_test.dart`.

The ledger block, shaped so `check_content_pipeline.sh` check 2's `- id:` window scan reads it
cleanly:

```yaml
signoffs:
  - id: es-ga-gl-vernacular-2026-09-14
    locale: gl
    jurisdiction: ES-GA
    scope: vernacular            # vernacular | rules | legal_text | strings
    reviewer_role: fisheries officer     # or: fisher
    reviewer_ref: FGC-2026-011           # an engagement reference, never a name
    reviewed_on: 2026-09-14
    scope_hash: 9f2c…                    # of the rows as they were when reviewed
    disconfirmed:                        # what the reviewer said was WRONG — may be empty, never absent
      - 'ameixa fina and ameixa babosa were swapped on two rows'
      - 'no one in Cambados says «berberecho de area»'
```

`reviewer_ref` is an engagement reference and not a person's name: `ATTRIBUTIONS.md` (E18) renders
the ledger, and a named individual on a public screen is a privacy decision nobody made.

## Why it is built this way

**A protocol nobody can fail is a memo.** `SPEC.md` §9.2 step 3 budgets a native-speaking reviewer
per locale and states the failure it prevents: a wrong vernacular name produces a *confident wrong
finding*. `catchlaw-content-pipeline` rule 2 is the pattern the whole pipeline already uses —
everything that matters is fatal, and there is no warning tier — so the review is a build assertion.
A11 fails when a shipped locale has no sign-off covering the rows currently in the corpus.
**Rejected:** a `reviewed: true` boolean on the vernacular row (true forever, including after the row
changes); **rejected:** recording the review only in the PR description (invisible to the build,
un-diffable, and gone the moment the PR is squashed).

**The sign-off is bound to a hash of what was reviewed, not to a date.** A date tells you when
somebody looked; it does not tell you whether they looked at *this*. `scopeHash` is a canonical
digest — rows selected by (locale, jurisdiction, scope), projected to exactly the fields a reviewer
sees, sorted by id, joined with a separator that cannot occur in a value. Edit a name and the hash
moves and A11 fails until the locale is re-signed. This is the same discipline E04/T09 uses for
`snapshot.json`, for the same reason: a generated-file check that cannot go stale can never fire.
**Rejected:** comparing `reviewed_on` against file modification time — git does not preserve mtimes,
so a fresh clone would re-sign every locale.

**The reviewer is asked to disconfirm.** `SPEC.md` §17 step 5 sets the discipline for the validation
interviews and it applies here unchanged: a leading question gets a polite yes. `REVIEW.md` therefore
asks for the wrong ones — *"Which of these names would send a fisher to the wrong fish?"*, *"What
does a fisher in your port actually call this, without looking at my list?"*, *"Which of these rows
would you not bet a fine on?"* — and `disconfirmed:` is a **required** key that may be an empty list
but may not be absent. An empty list is a claim: the reviewer looked and found nothing. A missing key
is a form that was never filled in, and the two must not look the same in a diff.

**Four scopes, because four different people are qualified.** `vernacular` is a fisher's knowledge;
`rules` is a fisheries officer's; `legal_text` is a transcription check against the gazette; `strings`
is the editorial prose of `content_string`. One sign-off covering "everything" would mean a fisher
attesting to a transcription he was never shown. **Rejected:** a single sign-off per locale — it is
cheaper to author and it is the one shape that makes the ledger untrue.

**`AUTHORING.md` cites and never restates.** Every rule an author must obey already lives in
`SPEC.md` §7.1, §8 and §9.2, in `build-assertions.md`, or in `licence-provenance.md`. The guide's job
is the **order of operations** — gazette → citation block → rule rows → strings → changelog →
rebuild — and the pointer at the assertion that will reject each mistake. A guide that re-types the
required-when matrix is a second copy that will disagree with A1 within a month
(`CONVENTIONS.md` §10, "It cites, never restates").

**The guide names the two ways this corpus can lie.** Both are already in the sources and both are
invisible in review: a `retrieved_on` filled in by anyone other than the person who opened the
gazette (`licence-provenance.md`: the footnote claims a human checked it on that date), and a
`min_size` copied out of a PDF table without its column header, which is A1's recorded cause. They go
at the top of `AUTHORING.md`, not in a footnote.

**An authored row can weaken invariant 5, and nothing else in the pipeline notices.** An *orden de
vedas* whose `valid_until` has passed is still law-as-last-published, and `CONVENTIONS.md` §9
invariant 5 requires it to be evaluated and shown behind the ochre bar. The tempting authoring
mistake is to quietly extend `valid_until` to keep the bar off the screen. `AUTHORING.md` names that
as forbidden in the same words the invariant uses, and points at E04/T09's changelog: an extended
validity window is a change, and a change with no `changes.yaml` entry fails A10 anyway.

## Tests first

Write every row before touching `scope_hash.dart` or `a11_review_signoff.dart`. Run them.
**They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `scopeHash returns the same digest for the same rows in a different file order` | two corpora, rows shuffled | equal digests | A sign-off must not go stale because somebody sorted a YAML file |
| 2 | `scopeHash returns a different digest when a reviewed value changes` | one vernacular name edited | different digest | The whole mechanism: an edit un-signs the locale |
| 3 | `scopeHash ignores a field the reviewer is not shown` | `is_primary` toggled on a `rules` scope | equal digests | Hashing the whole row would re-sign a locale for a change nobody reviewed |
| 4 | `scopeHash separates two rows whose fields concatenate identically` | `('ab','c')` vs `('a','bc')` | different digests | The classic delimiter collision; a joined digest with a weak separator is a silent equality |
| 5 | `scopeHash returns a different digest per locale for the same species` | `gl` vs `es` names | different digests | A sign-off in one locale must never satisfy another |
| 6 | `scopeHash returns a stable digest across two runs in one process` | same corpus twice | equal digests | The builder is deterministic (E04/T10); a hash seeded per run breaks the rebuild |
| 7 | `ReviewSignoffAssertion reports A11 when $locale has no sign-off row` (loop over the six) | ledger missing `$locale` | one `A11` naming `$locale` and the jurisdiction | D-3's six locales, six chances to forget one; `ca` and `pt_BR` are the ones that get forgotten |
| 8 | `ReviewSignoffAssertion reports A11 when the sign-off scope_hash is stale` | name edited after sign-off | one `A11` naming the scope | A dated sign-off over changed rows is the failure this task exists to prevent |
| 9 | `ReviewSignoffAssertion accepts a current sign-off for every locale and scope` | the worked ledger | no failures | The green path, and proof the fixture is reachable |
| 10 | `ReviewSignoffAssertion reports A11 when disconfirmed is absent` | block with no `disconfirmed` key | one `A11` | A missing key is an unfilled form; an empty list is a claim |
| 11 | `ReviewSignoffAssertion accepts an empty disconfirmed list` | `disconfirmed: []` | no failures | The reviewer looked and found nothing, and that must be expressible |
| 12 | `ReviewSignoffAssertion reports A11 when reviewer_ref is absent` | block with a role but no ref | one `A11` | E18 renders the ledger; an unattributable sign-off is not a sign-off |
| 13 | `ReviewSignoffAssertion reports A11 when reviewer_role is outside the allowed set` | `reviewer_role: translator` | one `A11` | §9.2: domain translation *cannot be handed to a general translator* |
| 14 | `ReviewSignoffAssertion reports A11 when reviewed_on is after the build date` | reviewed 2027, build 2026 | one `A11` | A future review date is a copied template, the same failure A4 catches on `retrieved_on` |
| 15 | `ReviewSignoffAssertion reports A11 once per missing scope` (loop over `vernacular`, `rules`, `legal_text`, `strings`) | ledger missing `$scope` | one `A11` per case | Four scopes, four different qualified people; one blanket sign-off is the shape that makes the ledger untrue |
| 16 | `ReviewSignoffAssertion skips a scope a jurisdiction does not have` | jurisdiction with no `legal_text` rows | no failures | A jurisdiction whose text is not yet transcribed must not be blocked by a review of nothing |
| 17 | `ar - ReviewSignoffAssertion reports A11 when the ar sign-off covers a different jurisdiction` | `ar` signed for `AE-RK`, corpus has `AE-DU` | one `A11` naming `AE-DU` | Arabic is one language across several jurisdictions and the temptation is one sign-off for all of them |
| 18 | `ReviewSignoffAssertion reports A11 for an unknown locale in the ledger` | `signoffs` block with `locale: ur` | one `A11` | D-3: Urdu is not shipped; a ledger row for a locale that does not exist is a paste from another project |

```dart
// tools/content_builder/test/review/scope_hash_test.dart
import 'package:content_builder/src/review/scope_hash.dart';
import 'package:content_builder/testing/fixtures/review_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('scopeHash', () {
    test('returns the same digest for the same rows in a different file order', () {
      final a = scopeHash(kGaliciaSource, locale: 'gl', jurisdiction: 'ES-GA', scope: Scope.vernacular);
      final b = scopeHash(kGaliciaSourceShuffled, locale: 'gl', jurisdiction: 'ES-GA', scope: Scope.vernacular);

      expect(a, b);
    });

    test('separates two rows whose fields concatenate identically', () {
      final a = scopeHash(kNamesSource(['ab', 'c']), locale: 'gl', jurisdiction: 'ES-GA', scope: Scope.vernacular);
      final b = scopeHash(kNamesSource(['a', 'bc']), locale: 'gl', jurisdiction: 'ES-GA', scope: Scope.vernacular);

      expect(a, isNot(b));
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// tools/content_builder/test/assert/a11_review_signoff_test.dart
import 'package:content_builder/src/assert/a11_review_signoff.dart';
import 'package:content_builder/src/locales.dart';
import 'package:content_builder/testing/fixtures/review_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('ReviewSignoffAssertion', () {
    for (final locale in kShippedLocales) {
      test('reports A11 when $locale has no sign-off row', () {
        final source = contentSourceMissingSignoff(locale: locale, jurisdiction: 'ES-GA');
        final failures = ReviewSignoffAssertion(buildDate: DateTime.utc(2026, 9, 20)).run(source).toList();

        expect(failures, hasLength(1));
        expect(failures.single.id, 'A11');
        expect(failures.single.message, contains(locale));
      });
    }

    test('reports A11 when the sign-off scope_hash is stale', () {
      final source = contentSourceEditedAfterSignoff(locale: 'gl', jurisdiction: 'ES-GA');
      final failures = ReviewSignoffAssertion(buildDate: DateTime.utc(2026, 9, 20)).run(source).toList();

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('vernacular'));
    });

    test('accepts an empty disconfirmed list', () {
      expect(
        ReviewSignoffAssertion(buildDate: DateTime.utc(2026, 9, 20)).run(kSignedGaliciaSource),
        isEmpty,
      );
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/review/scope_hash_test.dart
test/assert/a11_review_signoff_test.dart)` → 18 failures. If any passes now the test is wrong — in
particular case 3, which passes trivially against a hash of the whole row, and case 11, which passes
against an assertion that does not look at `disconfirmed` at all.

## Implementation outline

1. `Scope` as an `enum` (`vernacular`, `rules`, `legalText`, `strings`) with the YAML spelling on the
   enum, so the ledger and the code cannot disagree about `legal_text`.
2. `ReviewSignoff` — the ledger row, every field nullable at parse time so A11 reports *which* field
   is missing instead of crashing on load (the shape E04/T06 uses for `PlateSpec`).
3. `scopeHash`: select rows by (locale, jurisdiction, scope); project to the reviewer-visible fields
   listed per scope in one `const` map; sort by row id; join field values with `U+001F` (unit
   separator) and rows with `U+001E` (record separator), neither of which can occur in an authored
   value; digest with `package:crypto`'s sha256 — already in the workspace lock file for the
   emitter's build sidecar, so nothing new is added (`dependency-hygiene`).
4. `ReviewSignoffAssertion(buildDate:)`: for each (jurisdiction, locale, scope) that has rows,
   require exactly one sign-off; then check completeness, the role allow-list, `reviewed_on` ordering
   and the hash. Report each failure at the ledger line, or at the jurisdiction line when the block
   is absent entirely.
5. Register after A10 in `ContentSource.assertions`. A11 is the first assertion this repository adds
   after E04; the id continues that sequence and is recorded in `content/README.md`.
6. Write `content/AUTHORING.md` and `content/REVIEW.md` last, from the finished behaviour, so the
   guide documents what the build actually enforces.
7. Seed `content/reviewers.yaml` with the Galicia sign-offs E04 shipped without. If no review has
   happened yet, the ledger is **empty and the build fails** — that is correct, and it is the
   sequencing this epic then works through, not a reason to soften A11.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 rows pass, and each failed first.
- [ ] 100 % branch coverage on `a11_review_signoff.dart` and `scope_hash.dart`.
- [ ] `content/AUTHORING.md` documents the order of operations and names, per authored file, the
      assertion that rejects a mistake in it — and restates no rule that lives in `SPEC.md` §7.1,
      `build-assertions.md` or `licence-provenance.md`.
- [ ] `content/REVIEW.md` states the four scopes, the two allowed reviewer roles, and at least three
      disconfirming questions per scope, in the §17 step 5 shape.
- [ ] `content/reviewers.yaml` is committed and A11 is clean over `content/`, or the failing locales
      are named in the commit body as the work T03–T06 will close.
- [ ] `grep -rn "DateTime.now" tools/content_builder/lib` still returns nothing.
- [ ] `tools/content_builder/pubspec.yaml` gained no dependency.
- [ ] `content/README.md` records A11 in the assertion list, so the ids stay a single sequence.

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
feat(content_builder): require a current reviewer sign-off for every shipped locale (A11)

SPEC.md §9.2 step 3 budgets one native-speaking fisher or fisheries officer
per locale before release, and gives the reason: a wrong vernacular name is
worse than no name, because it produces a confident wrong finding. A protocol
nobody can fail is a memo, so the review is a build assertion like every other
guarantee in §8.

The sign-off binds to a canonical hash of exactly the rows it covered, not to
a date. A date says somebody looked; it does not say they looked at this. Edit
a name and the hash moves and the locale is unsigned until it is reviewed
again. Comparing reviewed_on against file mtime was rejected — git does not
preserve mtimes, so a fresh clone would re-sign everything.

Four scopes — vernacular, rules, legal_text, strings — because four different
people are qualified, and one blanket sign-off would have a fisher attesting
to a transcription he was never shown. `disconfirmed:` is required and may be
empty: an empty list is a claim that the reviewer found nothing, a missing key
is a form nobody filled in, and those must not look the same in a diff.

content/AUTHORING.md documents the order of operations and points at the
assertion that rejects each mistake. It restates no rule that already lives in
SPEC.md §7.1, build-assertions.md or licence-provenance.md.

Task: E22/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
