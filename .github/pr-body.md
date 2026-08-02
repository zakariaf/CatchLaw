### What changed

S5, S6 and the static half of S2 — a fisher can now find a fish.

- **The search** — a range predicate over `search_norm`, never a `LIKE`, with an
  `EXPLAIN QUERY PLAN` row proving it uses the index and a latency proof at `SPEC.md` §13's own
  scale (400 species, 2 400 names). The raw query is folded by the engine's own
  `normaliseSpeciesTerm` inside the repository, so it is folded exactly once.
- **The two groups** — **in your zone** first, **elsewhere in this jurisdiction** second and never
  hidden.
- **The §7.3 predicates** — zone reach (`NULL`, the zone, or an ancestor), `valid_from` as a filter
  and `valid_to` as no filter at all, and hint precedence: protected, then closure, then size.
- **S5's empty state** — one primary (**Identify this fish**) and one secondary (**Browse by
  shape**), with the jurisdiction's real species count beside them.
- **S6** — a silhouette grid grouped by family, with the family names in the reader's own language.
- **S2's static half** — the local name large, the family, the binomial last, other-locale names
  under it, and **named, empty slots** for E09's ruler and E10's verdict.
- **The look-alike card** — both directions, one physical character from the pack, and a mark when
  the confusable species is protected.
- **Recents** — per zone, frequency before recency, written by an upsert.
- Twenty-two ARB keys in all seven files (D-18), four golden lanes, and the fakes and fixtures the
  rows run against.

### Why

`SPEC.md` §5.2 point 2 is the argument that shapes the whole epic: *a wrong confident
classification on a protected species is the worst failure this app could have.* Everything here
either helps a fisher find the right fish or admits that two fish look alike.

### How it was verified

- The search's query plan asserted, not assumed — a `LIKE` can be optimised into the same range
  today and silently stop being when a `PRAGMA` or a `COLLATE NOCASE` changes on a rebuilt content
  database.
- **E04's Galicia seed carries zero `rule` rows.** It is a structural seed and the authored content
  is E22's epic, so the §7.3 predicate rows run against a synthetic pack at the right shape — a test
  pointed at the built file would have passed over an empty table, which is the same silent-green
  failure `CONVENTIONS.md` §7 records for gates. The DAO tests that ask whether drift's tables and
  the builder's DDL agree still use the built file.
- Every gate clean, checked by exit code rather than through a pipe.

### Gate findings kept rather than worked around

Six, and every one of them was right about something real:

1. `SpeciesResultRow` wore drift's `Row` suffix *and* used `result`, a banned domain word →
   `SpeciesListing`.
2. `SpeciesHint` declared a `MeasurementMethod` in a `*species*.dart` file — the same fish is
   measured differently in two countries, so TL versus FL is a **rule** column → `RuleHint`, decoder
   moved to `enum_codecs.dart`.
3. A `Citation?` local → E05's `_require` shape: a rule whose citation does not resolve does not
   become a rule.
4. A raw `TextField` and an `InputDecoration` border outside `ui/core` → `LonjaSearchField`, drawing
   its own rule at a Lonja weight.
5. An eager `ListView` twice → slivers on S5, a scrolling column on S2, and a named empty state on
   the recents strip.
6. **An actual `.toUpperCase()`** in S6's family heading — a silent no-op on Arabic, so the heading
   would shout in Galician and read as body text in `ar`.

### One finding worth carrying forward

A widget test's `ProviderScope` that omits `retry: noRetry` is testing a different app: Riverpod 3
**retries** a provider whose build threw, with backoff, so a failing read never reaches `AsyncError`
and the screen sits in `loading` forever. The error-branch row did not fail — it hung. Every harness
here mirrors `main()` now.

### Deferred, stated rather than done badly

`species_recent`'s covering index is **not** added. D-17 records that `drift_dev`'s schema tooling
cannot run in this workspace, so there is no committed snapshot to migrate against and the first
`from → to` pair needs a hand-written before/after fixture; E13 or E16 owns it. At the seed's scale
the primary key already serves the read.

The golden PNGs are macOS placeholders; the follow-up commit on this branch replaces them with the
Linux lane's bytes.

### Product invariants touched

None weakened. Invariant 3 is made unrepresentable rather than checked — `SpeciesFacts` carries a
required, non-nullable `Citation`, because a hint about a protection is a statement about a
published instrument. Invariant 5 holds: `valid_to` never filters, and the stale bar sits above the
list rather than over it.
