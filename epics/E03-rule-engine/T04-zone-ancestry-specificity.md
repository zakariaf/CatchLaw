# E03/T04 — Zone ancestry and the specificity ladder

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): match null, equal and ancestor zones and rank by the SPEC 7.3 ladder` |
| **Depends on** | T03 (candidates exist before they can be matched and ranked) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.3 steps 2 and 3; §7.1 `zone` (`parent_zone_id`, `zone_kind`) and `rule.specificity`; §4.4 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-rule-engine` | Rule 5: the ladder is a closed integer table declared once, never re-derived from path depth or string prefixes — with the failure that heuristic causes |
| `catchlaw-verdict-contract` | Part 3 of the carve-out: different specificity is *not* ambiguity, so this ranking is what lets T05 be narrow. And "source order" — which is why the sort must be stable |
| `catchlaw-conventions-index` | Routing: zones and point-in-polygon belong to `catchlaw-rule-engine` here and to E11 for geometry; this task must not grow a geometry opinion |
| `dart3-idioms-and-coding-standards` | Enhanced enums with a field, and comparator shape |
| `testing-strategy` | Pure unit, table-driven where the parameter is interpolated into the description |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.3 steps 2 and 3 | "zone_id is NULL, equals the zone, or is an ancestor"; "exclusion 40 > reserve 30 > bank/basin 20 > subzone 10 > region 0" |
| `SPEC.md` | §7.1 `zone` and `rule` | `parent_zone_id`, the six-member `zone_kind` `CHECK`, and `rule.specificity INTEGER NOT NULL DEFAULT 0` — the stored copy this task deliberately does not read |
| `SPEC.md` | §4.4 | Why the zone arrives resolved: GPS is a suggestion, the zone is confirmed by the user, and the engine is handed the answer |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "Zone ancestry and specificity", "The four stages, in order", "Edge cases" | The five-row ladder table with a real example each, the `NULL`-ranks-at-0 paragraph, the "stable" annotation on stage 4, and the one-element-`zonePath` edge case |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 5; the `zoneId.split('/').length` anti-pattern | The exact failure a depth heuristic produces: a bank outranking the no-take exclusion drawn inside it |
| `.claude/skills/catchlaw-verdict-contract/references/the-five-part-carve-out.md` | Part 3, table rows 2 and 3 | Zone rule beats national rule is a `SingleRule`; equal specificity is the only ambiguity |
| `FLUTTER_GUIDE.md` | §7.2 | Enhanced enums carrying the integer, rather than a lookup map beside the enum |
| `epics/DECISIONS.md` | D-7 | The ladder holds integers, not labels |

## What this delivers

- `packages/rule_engine/lib/src/models/zone.dart` — `ZoneKind` promoted to an enhanced enum with a
  `specificity` field. Members unchanged from T01.
- `packages/rule_engine/lib/src/resolve/zone_match.dart` —
  `int specificityOf(Rule, List<Zone> zonePath)` and
  `List<Candidate> matchAndRank(EvaluationRequest, List<Candidate>)`.
- `packages/rule_engine/lib/rule_engine.dart` — exports `zone_match.dart`.
- `packages/rule_engine/test/resolve/zone_match_test.dart`.

## Why it is built this way

**The ladder is a closed integer table on the enum, and nothing derives it.**
`catchlaw-rule-engine` rule 5 gives the failure a depth heuristic produces, and it is worth having in
front of you: `banco-de-cambados` is a bank at depth 3; a no-take exclusion drawn *inside* it is at
depth 4 in some encodings and depth 3 in others depending on how the path was built. A specificity
computed from `zoneId.split('/').length` therefore ranks the bank above the exclusion roughly half
the time, and hands the permissive rule to a fisher standing exactly where the strict one applies.
The integers are published in `SPEC.md` §7.3 and they live in one place.

**`basin` is a member and it ranks 20.** `resolution-algorithm.md`'s table lists five scopes and
omits `basin`; `SPEC.md` §7.3 says *"bank/basin 20"* and §7.1's `CHECK` constraint has six members.
`SPEC.md` is authoritative for the product, so the enum has six members and `basin` shares the bank's
rung. T01 already put it in the member list; this task gives it its number.

**A `NULL` `zone_id` ranks 0, the same as `region`, and that is not a bug.**
`resolution-algorithm.md` states the intent directly: *"a national minimum and a regional minimum
that disagree is a genuine ambiguity, not something the sort order should quietly settle."* Ranking
a jurisdiction-wide rule below a regional one would be a silent resolution of exactly the conflict
the product refuses to resolve. So both land on 0 and, if they disagree, T05 returns both.

**Ancestry is list membership, not a tree walk.** The request carries `zonePath` as a `List<Zone>`,
root first and the active zone last, materialised by E05 from `zone.parent_zone_id`. A rule matches
when its `zoneId` is null, or equals any zone in that path. `resolution-algorithm.md` gives the
reason for materialising it upstream — *"ancestry is a list membership test, not a recursive CTE at
05:40"* — and `SPEC.md` §13's 10 ms budget is the number behind it. **Rejected:** the engine walking
`parentZoneId` itself, which would require it to hold every zone in the jurisdiction rather than the
five on the path, for a result the data layer can produce with one indexed query.

**`zonePath` is a `List<Zone>`, not a `List<int>`.** The same list has to answer two questions —
*is this rule's zone an ancestor of mine* and *what kind of zone is it* — and carrying ids alone
would force a second lookup structure on the request for information the first one already has.

**The engine derives specificity and never reads `rule.specificity`.** `SPEC.md` §7.1 stores the
integer on the row. The engine computes it from the matched zone's kind instead. The reason is that
two sources of truth need a tie-break, and the one that should win is the ladder `SPEC.md` §7.3
publishes rather than a value a content author could mistype into one row of one YAML file. The
column keeps its use — E04 writes it, and E05 may `ORDER BY` it as a pre-sort — and the epic's risk 6
records that E04 owes a build-time assertion that the two agree. **Rejected:** reading the column,
which would make a single-row typo authoritative over the published ladder in a way no test in this
package could see.

**The sort is stable, and it is stable by construction.** Dart's `List.sort` is documented as not
stable. `the-five-part-carve-out.md` part 3 requires two conflicting rules to be printed *in source
order*, and `catchlaw-verdict-contract` rule 6 bans a `sort` in the ambiguity path for the same
reason. If `matchAndRank` scrambles the order of equal-specificity rows, D4 renders the two citations
in an order that can change between two runs on the same input — which looks like the app choosing,
which is the one thing it must never look like. The comparator therefore breaks ties on the
candidate's original index. **Rejected:** `package:collection`'s `mergeSort`. It is correct and it is
one more dependency in the package `tools/content_builder/` compiles under plain `dart run`; the
index-decorated comparator is three lines.

## Tests first

Write all 15 rows before touching `zone_match.dart`. Run them. **They must fail.**

Zone fixtures come from `testing/models/fixtures.dart`: `kZoneUae` (region),
`kZoneRasAlKhaimah` (subzone), `kZoneRakMangroveReserve` (reserve), `kZoneRakNoTakeCore`
(exclusion), and for the Galician trace `kZoneGalicia` (region) and `kZoneBancoDeCambados` (bank).

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ZoneKind assigns exclusion 40, reserve 30, bank 20, basin 20, subzone 10 and region 0` | `ZoneKind.values` | the six integers | The ladder is the whole task; a wrong rung is a wrong rule with full confidence |
| 2 | `ZoneKind.basin ranks equal to ZoneKind.bank` | the two members | both 20 | `SPEC.md` §7.3 says "bank/basin 20" and the skill's table omits `basin`; this row is why it cannot be dropped again |
| 3 | `specificityOf returns 0 for a rule with a null zone id` | `zoneId: null` | 0 | `SPEC.md` §7.3: NULL is the whole jurisdiction, and `resolution-algorithm.md` puts it deliberately level with `region` |
| 4 | `specificityOf returns the matched zone's kind rank` (loop over all six kinds, kind interpolated into the description) | one rule per kind | the kind's integer | `CONVENTIONS.md` §5: a loop-generated test must interpolate the parameter, or `--plain-name` cannot select one |
| 5 | `specificityOf ignores the stored specificity column` | rule with `specificity: 40`, zone kind `region` | 0 | The two-sources-of-truth guard: a content typo must not outrank the published ladder |
| 6 | `matchAndRank keeps a candidate whose zone id is null` | 1 candidate, null zone | kept | `SPEC.md` §7.3 step 2, first case |
| 7 | `matchAndRank keeps a candidate whose zone id equals the active zone` | zone = last element of `zonePath` | kept | Step 2, second case |
| 8 | `matchAndRank keeps a candidate whose zone id is an ancestor of the active zone` | zone = first element of `zonePath` | kept | Step 2, third case — the one a naive equality check drops, deleting every regional rule the moment a subzone is picked |
| 9 | `matchAndRank drops a candidate whose zone is not on the path` | a sibling subzone | dropped | The other half of step 2: a neighbouring emirate's rule is not law where he stands |
| 10 | `matchAndRank sorts an exclusion above a bank` | bank 20 + exclusion 40 | exclusion first | `resolution-algorithm.md`'s worked trace: the no-take core drawn inside Banco de Cambados |
| 11 | `matchAndRank sorts a bank above a region` | region 0 + bank 20 | bank first | The Ameixa babosa trace, and the ordinary case a fisher hits daily |
| 12 | `matchAndRank preserves source order between two candidates of equal specificity` | two bank-20 rules in a known order | same order out | `the-five-part-carve-out.md` part 3 requires source order; `List.sort` is not stable, so this is the only thing standing between D4 and a screen that reorders itself |
| 13 | `matchAndRank preserves source order across 40 equal candidates` | 40 bank-20 rules | identical order | Dart's sort switches algorithm by length; a two-element test can pass while the real path scrambles |
| 14 | `matchAndRank keeps only null and jurisdiction-scoped rows when zonePath has one element` | `zonePath` = `[kZoneUae]` | the two matching rows | `resolution-algorithm.md` edge case: a jurisdiction with `has_zone_polygons = 0` still gets a valid answer |
| 15 | `matchAndRank returns an empty list when no candidate's zone is on the path` | 3 off-path candidates | `[]` | Empty here is not an error; T11 turns it into a legal statement |

```dart
// packages/rule_engine/test/resolve/zone_match_test.dart
import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('ZoneKind', () {
    test('assigns exclusion 40, reserve 30, bank 20, basin 20, subzone 10 and region 0', () {
      expect(ZoneKind.exclusion.specificity, 40);
      expect(ZoneKind.reserve.specificity, 30);
      expect(ZoneKind.bank.specificity, 20);
      expect(ZoneKind.basin.specificity, 20);
      expect(ZoneKind.subzone.specificity, 10);
      expect(ZoneKind.region.specificity, 0);
    });
  });

  group('specificityOf', () {
    for (final kind in ZoneKind.values) {
      test('returns the matched zone rank for $kind', () {
        final zone = kZoneRasAlKhaimah.copyWith(kind: kind);
        final rule = kRuleHamourMinSize.copyWith(zoneId: zone.id);
        expect(specificityOf(rule, [kZoneUae, zone]), kind.specificity);
      });
    }
  });

  group('matchAndRank', () {
    test('preserves source order across 40 equal candidates', () {
      final candidates = [
        for (var i = 0; i < 40; i++)
          Candidate(rule: kRuleCambadosMinSize.copyWith(id: i), isExpired: false),
      ];
      final ranked = matchAndRank(_galiciaRequest(), candidates);
      expect(ranked.map((c) => c.rule.id), List<int>.generate(40, (i) => i));
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `dart test test/resolve/zone_match_test.dart` → 15 failures (row 4 expands to six). If row
12 or 13 passes now, the ranking function does not exist yet and the test is asserting the identity
of an untouched list — fix the test before writing the comparator.

## Implementation outline

1. Promote `ZoneKind` in `lib/src/models/zone.dart` to an enhanced enum:
   `exclusion(40), reserve(30), bank(20), basin(20), subzone(10), region(0)` with
   `const ZoneKind(this.specificity); final int specificity;`. Member order is declaration order and
   is not load-bearing — the integers are.
2. `lib/src/resolve/zone_match.dart`:
   - `int specificityOf(Rule rule, List<Zone> zonePath)` — `rule.zoneId == null` returns 0; otherwise
     find the zone in the path by id and return `zone.kind.specificity`. A rule whose zone is not on
     the path never reaches this function, because `matchAndRank` filters first; assert that.
   - `List<Candidate> matchAndRank(EvaluationRequest request, List<Candidate> candidates)` — filter
     on null-or-on-path, then sort with an index-decorated comparator:
     compare `specificity` descending first, then the original index ascending.
3. Export `zone_match.dart` from the barrel.
4. Re-run the whole suite. All 15 green; T01–T03 still green.

**Do not** add a `ZoneScope` type. `catchlaw-rule-engine` calls the ladder's carrier `ZoneScope`;
`SPEC.md` §7.1's column is `zone_kind` and T01's model already mirrors it. One enum, named after the
column that E05's mapper round-trips. No gate depends on the identifier.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 15 tests pass, and each failed first.
- [ ] Branch coverage on `zone_match.dart` is 100%, and every `ZoneKind` member is exercised by the
      loop in row 4.
- [ ] `grep -rn 'specificity' packages/rule_engine/lib` shows the enum field and the comparator, and
      never `rule.specificity`.
- [ ] The comparator breaks ties on the original index; there is no bare `..sort((a, b) => ...)` over
      specificity alone anywhere in the package.
- [ ] `package:collection` was not added to `pubspec.yaml`.
- [ ] The six ladder integers appear exactly once in `lib/`.

## Gates

```bash
cd packages/rule_engine && dart format --set-exit-if-changed . && dart analyze && dart test
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh packages/rule_engine/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(rule_engine): match null, equal and ancestor zones and rank by the SPEC 7.3 ladder

Steps 2 and 3 of SPEC 7.3. The ladder is six integers on ZoneKind and
nothing derives it: a specificity computed from path depth ranks Banco de
Cambados above the no-take exclusion drawn inside it, which hands the
permissive rule to a fisher standing where the strict one applies. basin
shares the bank's rung because SPEC 7.3 says "bank/basin 20"; the skill's
ladder table omits it.

A null zone_id ranks 0, level with region, deliberately. A national minimum
and a regional minimum that disagree is a real ambiguity and the sort order
is not allowed to settle it quietly.

The sort is stable by construction. Dart's List.sort is not, and the
carve-out requires two conflicting rules to print in source order — an
unstable sort would render D4 in a different order on two runs of the same
input, which looks exactly like the app choosing.

The stored rule.specificity column is not read. The published ladder beats a
value a content author could mistype into one row; E04 owes the assertion
that the two agree.

Task: E03/T04
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
