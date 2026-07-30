## What changed

<!-- One sentence. What does this PR make true that was not true before? -->

## Why

<!-- The reason, not the mechanism. Link an issue if there is one. -->

## Gates

- [ ] `bash -n` passes on any changed `scripts/*.sh`
- [ ] Every `references/`, `examples/` and `scripts/` path cited in a `SKILL.md` exists
- [ ] Skill frontmatter still parses to exactly `name` + `description`

## Product invariants (tick only those this PR touches)

- [ ] The result remains a **statement of fact** — no imperative reaches the UI or an `.arb`
- [ ] Every result still carries its **citation** and last-checked date
- [ ] Genuine legal **ambiguity is still refused**, not resolved
- [ ] An **expired ruleset is still evaluated**, behind the non-blocking amber bar
- [ ] **No network code path** was introduced — no new dependency, no `dart:io` socket API

## Evidence

<!-- For any demand, licence or legal claim: the URL and the date you checked it.
     "Unverified" is an acceptable answer. Inventing a source is not. -->
