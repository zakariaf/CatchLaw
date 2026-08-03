# E04/T12 — A12, every authored date is one a human could have established

| | |
|---|---|
| **Epic** | E04 — Content build: the corpus becomes `reference.db` |
| **Branch** | `fix/content-date-assertions` |
| **Commit** | `feat(content): assert every authored date is one a human could have established` |
| **Depends on** | T05 (A4 owns the citation pair), T11 (the Galicia seed is the corpus this fires on) |
| **Size** | S |
| **Spec** | `SPEC.md` §4.7 (currency), §7.1 (`jurisdiction`, `changes`) |
| **Found by** | Reading the Check screen on a simulator: `checked 2026-08-12`, nine days from now |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rule 2 (every assertion is fatal, no warning tier) and rule 6 (`retrieved_on` is authored, never a clock reading) — A12 is rule 6's logic applied to every field rule 6 does not reach |
| `catchlaw-conventions-index` | Rule 9, routing: the assertion is the builder's, the date it guards is displayed by E12's masthead, and neither owns the other |
| `testing-strategy` | Why a fixture whose dates are all sensible proves nothing, and why the real corpus is a test input here |

## What went wrong

`content/es-ga/jurisdiction.yaml` shipped `checked_on: '2026-08-12'` against a build dated
`2026-08-03`. Nothing rejected it. A4 has checked exactly this since T05 — `retrieved_on` may not
follow `--build-date` — but A4 is scoped to `citations`, and `checked_on` is a jurisdiction field.
Every other authored date in the corpus had no check at all.

**`checked_on` is not decorative.** It is what the Check screen prints under the place — *"checked
2026-08-12"* — and it is the fisher's only handle on whether the rule book is current. A future value
says the book was verified more recently than it can have been. That is the one direction the error
must never point: it reads as **fresher** than it is, and the entire purpose of showing the date is to
let him distrust a stale one. A date in the past that is wrong makes him check; a date in the future
that is wrong makes him stop checking.

## What this delivers

- `tools/content_builder/lib/src/assert/a12_authored_dates.dart` — `AuthoredDateAssertion`,
  registered in `kAssertions`.
- `tools/content_builder/test/assert/a12_authored_dates_test.dart` — twelve tests.
- `content/es-ga/jurisdiction.yaml` and `content/es-ga/changes.yaml` — both dates corrected to
  `2026-08-03`, the day the DOG was actually opened for the rule row, matching the citation's
  `retrieved_on`. The reviewer sets the real value when the row is reviewed.
- The register and every document stating a count: `references/build-assertions.md` gains A12 and an
  explicit **A11 reserved by E18/T01** row, and eight files stop saying "the ten assertions".

## Why it is built this way

**A11 is a hole on purpose.** E18/T01 claimed that id before A12 was written, and renumbering a
deferred task across ten mentions is churn that buys nothing. The register says so in a row of its
own, and `assertion.dart`'s dartdoc repeats it, so the gap is a documented fact rather than a
question the next reader has to answer twice.

**A12 takes only what A4 does not.** A4 owns `citations.retrieved_on` and `citations.published_on`.
Adding them to A12 as well would mean two failures for one typo, and a failure list padded with
duplicates is a failure list nobody reads to the end.

**Two classes of date, and only one may not be in the future.** A date recording a HUMAN ACT —
`checked_on`, `changed_on`, `published_on` — cannot be ahead of the build, because the act has not
happened. A date naming an INSTRUMENT'S REACH — `valid_from`, `valid_to` — routinely is, and must be:
a closure authored in July that bites in September is correct data, and rejecting it would leave the
corpus unable to state a season before it starts. Those two get format and ordering only.

**Inclusive against the build date.** `checked_on` equal to `--build-date` is the normal case, not an
edge one — a pack built the day it was checked. An exclusive comparison would fail every same-day
build, and the fix somebody would reach for is loosening the check rather than the comparison.

**`parseIsoDate` throws, so A12 catches.** An unguarded call turns the one failure this assertion
exists to report into an uncaught `FormatException` — which kills the build with a stack trace instead
of `A12 jurisdiction.yaml:18 …`, and tells the author nothing about which of thirty dates is wrong.

## Tests first

Twelve, each failing before the assertion existed.

| # | Test name | Expected |
|---|---|---|
| 1 | `reports A12 when checked_on follows the build date` | one A12, at the jurisdiction's path and line |
| 2 | `accepts checked_on on the build date itself` | none — same-day is the normal case |
| 3 | `reports A12 when checked_on precedes published_on` | one; you cannot read text before it exists |
| 4 | `reports A12 when published_on follows the build date` | one; a year typo puts a repealed order back in force |
| 5 | `reports A12 when changed_on follows the build date` | one; §4.7's history must not contain the future |
| 6 | `accepts valid_from in the future` | none — the deliberate exemption |
| 7 | `accepts valid_to in the future` | none |
| 8 | `reports A12 when valid_to precedes valid_from` | one; a window that closes before it opens matches no date, so the rule is silently never evaluated |
| 9 | `reports A12 when an authored date is not an ISO date` | one; `27/07/2012` is the format the DOG prints and the format an author copies |
| 10 | `reports every violating date rather than the first` | ≥ 3; one round-trip tells the author everything |
| 11 | `reports nothing for a corpus whose dates are all past and ordered` | none |
| 12 | `reports nothing when a date is absent` | none — presence is A1's |

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All twelve pass, and each failed first.
- [ ] A12 is registered in `kAssertions` and is fatal like every other.
- [ ] The real corpus builds clean, and building it with the old date fails with the A12 line.
- [ ] No document under `epics/` or `.claude/skills/` still says "the ten assertions".
- [ ] The register carries the A11-reserved row, so the gap is documented rather than discovered.

## Gates

```bash
cd tools/content_builder && dart format --set-exit-if-changed . && dart analyze && dart test
dart run content_builder:build --in content/ --out app/assets/db/reference.db \
  --build-date <YYYY-MM-DD> --generator-commit <sha>
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
```
