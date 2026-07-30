# The Five-Part Carve-Out

Scope: the clause CATCHLAW is built to survive, the five structural commitments that keep it a
reference tool rather than an advisory one, a testable assertion for each, the per-jurisdiction
authority table, the edge cases that get argued about, and the three things that void the carve-out.

## The clause this is all traceable to

The brief auto-rejects tools carrying serious liability, including legal advice, "unless it is
clearly a reference/logging tool with no advisory function". Everything below exists so that the
sentence remains true of every screen the app can reach. The five parts are not style preferences;
each one is the difference between quoting an instrument and counselling a person.

| # | Commitment | The advisory version it replaces |
|---|---|---|
| 1 | The output states a fact | "Throw it back" / "You may keep this" |
| 2 | Every finding carries its citation | an unattributed pronouncement |
| 3 | Ambiguity is shown, never resolved | picking the stricter (or the more permissive) rule |
| 4 | The app never interprets | "this probably counts as a grouper" |
| 5 | A non-dismissable disclaimer names the authority | a one-time "I understand" splash |

## Part 1 — statement of fact, never instruction

The sentence describes the world; it never describes an action for the reader to take. The test is
mechanical: **can the sentence be prefixed with "It is recorded that"?** If not, it is an
instruction.

| Banned | Printed instead |
|---|---|
| "Keep" / "You can keep it" / "Legal to keep" | "Meets the minimum — 47 cm measured, minimum 45 cm (total length)" |
| "Return it" / "Throw it back" / "Put it back" | "Below the minimum — 38 cm measured, minimum 45 cm (total length)" |
| "Release it" / "Do not land it" | "Protected species — taking prohibited." |
| "Do not fish for this now" | "Closed season — 1 March to 30 April. In force today, day 14 of 61." |
| "Retain" / "Discard" / "Land it" | the rule-table row that states the fact |
| "Check again later" | "Rule data expired 2026-06-30 — still shown, verify before relying on it" |

Testable: every string reachable by the result screen passes `check_verdict_contract.sh` and the
imperative and second-person assertions in `examples/verdict_strings_test.dart`.

## Part 2 — every finding carries its citation

The quadruple is instrument, article, publication date, last-checked date. It is what makes the app
transparently a READER of someone else's text.

| Field | Example | Why it is not optional |
|---|---|---|
| `instrument` | Ministerial Decision 580/2015 | names whose rule this is, not the app's |
| `article` | Art. 3 | lets a fisher or an inspector find the exact provision |
| `publishedOn` | 2015-11-03 | dates the law, not the app build |
| `checkedOn` | 2026-07-14 | states how current the transcription is, and bounds the claim |

Testable: `Citation` has four required non-nullable fields; `Verdict`, `NoRuleRecorded` and every
element of `ConflictingRules` require one; no `??` supplies an instrument name; the citation renders
on-screen, not behind an `ExpansionTile`, tooltip or "More info" route.

## Part 3 — genuine ambiguity is shown, not resolved

Two rules are in genuine conflict when they are **equally specific** for the same catch. Different
specificity is not ambiguity — a zone rule beats a national rule and the engine says so.

| Situation | Engine result | Surface |
|---|---|---|
| One rule matches | `SingleRule` | one stamp, one citation |
| Zone rule + national rule, zone is narrower | `SingleRule` (zone) | one stamp; the national rule still listed in the table |
| Two rules, same zone, same species, same method | `ConflictingRules` | dialog printing both, source order, no primary action |
| Two rules, same specificity, different methods (TL vs FL) | `ConflictingRules` | both, each with its own method named |
| Rules that disagree only on a date already past | `SingleRule` | the rule in force today |

Banned resolutions, all of which are advice: `reduce` on the stricter minimum, `reduce` on the more
permissive minimum, `candidates.first`, `sort` by anything, a "recommended" badge, an autofocused
primary button, and rendering only one rule with a "another rule may apply" footnote.

Testable: `ConflictingRules` is a distinct `sealed` case; the ambiguity dialog contains exactly N
equal-weight actions for N rules plus a defer action, and no widget in it is styled as primary.

## Part 4 — the app never interprets

No inference, no analogy, no reasoning about edge cases, no confidence language. The app knows what
was transcribed and nothing else.

| Inference the app must refuse | What it does instead |
|---|---|
| species not in the reference DB | "No rule recorded for this species here. This does not mean it is legal." |
| a similar species has a 45 cm minimum | nothing — similarity is not a rule |
| the measurement is 44.6 cm, "close enough" | states the number and the threshold; rounding lives in `catchlaw-measurement-ruler` |
| a rule's wording is unclear | prints the transcribed wording verbatim and cites it |
| the zone boundary is uncertain | states which zone was used and offers a manual zone change |

The no-rule wording is fixed and both sentences are mandatory in every locale. Losing the second
sentence turns a gap in the reference database into a permission, which is the single most expensive
misreading the app can produce.

Banned vocabulary in copy: probably · likely · should be · appears to · seems · similar to · counts
as · we think · in our view · typically · usually · close enough · roughly · about right.

## Part 5 — the non-dismissable disclaimer

It sits on the result screen, permanently, and it names the body to verify with.

| Jurisdiction | Authority named in the disclaimer |
|---|---|
| UAE (Ras Al Khaimah) | Ministry of Climate Change and Environment (MOCCAE) |
| Spain — Galicia (Rias Baixas, Banco de Cambados) | Consellería do Mar, Xunta de Galicia |
| Brazil (Represa de Jurumirim) | IBAMA |

Testable: the disclaimer widget is an unconditional `const` child with no `bool` near it; there is
no "Got it", "I understand", "Do not show again", ⓘ button, tooltip or one-time splash anywhere in
its call chain; a golden of the result screen at the smallest supported text scale still shows it.

## Edge cases that get argued about

| Case | Ruling |
|---|---|
| A gear or bag-limit rule with no number | print the transcribed wording and its citation; do not paraphrase |
| Two rules where one is expired | both shown; the expired one carries the dated stale notice |
| The whole pack is expired | evaluate and show everything, plus one stale notice — never withhold |
| The species is protected AND undersized | one category (`.protected`, per the engine's precedence) plus the full rule table |
| A user-entered measurement below zero | a validation error on the input, never a verdict |
| Logging a catch the app said fails a rule | the log records the fact; it never comments on the decision |
| The user asks "can I keep it" in search | the query returns the rule; the app does not answer the question |

## What voids the carve-out

Three things turn this product back into a liability the brief rejects, regardless of everything
else on this page:

1. **Any imperative or permission verb reaching the user.** One "you may keep this" is enough.
2. **Any health, edibility, toxin or ciguatera claim.** A different regulated domain with a bodily
   consequence, sourced from nothing in the shipped reference DB.
3. **Any silent resolution of a genuine legal conflict.** The moment the app chooses between two
   live instruments it has performed the advisory act.

Everything else on this page is a defence in depth around those three.
