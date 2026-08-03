# CatchLaw

CatchLaw is an offline catch-legality reference for artisanal and recreational fishers in the Arabian
Gulf, Iberia and Brazil, built around one five-second answer given at 05:40 in the dark, with wet hands
and no signal: does this fish meet the rules in the place it was landed, and if not, which rule does it
fail. It has no account, no server, no sync and no network code of any kind — not a dependency, not an
import, not a socket. It states what the published instrument says and cites it — instrument, article,
publication date, and the date that text was last checked — and it never says what to do about it, in
any language. It is a printed regulations booklet with a ruler on the back cover, which is exactly what
it replaces.

**Authority.** `SPEC.md` (the product — the complete finished application, no v2), `FLUTTER_GUIDE.md`
(how the code is written), `epics/CONVENTIONS.md` (how an epic and a task are run) and `.claude/skills/`
were written in separate passes and disagree in nine places. There is no stable ranking between them:
`epics/DECISIONS.md` settles each conflict individually, names the losing source, and is read first.
D-2 overrules the guide with a skill's gate script, D-5 overrules the spec with the guide, D-4 and D-8
overrule the spec outright. **Where no `D-n` covers the conflict and it is about a path, the gate script
beats the prose** — D-2's rule of thumb, and the only general tie-break this project has.

## The five product invariants

Here rather than only in a skill because they must be *present*, not *consulted*: a one-line request may
fire no skill at all and can still break all five. Clauses, edge cases and the failure each one prevents
are in `catchlaw-conventions-index/references/product-invariants.md`, the authority; `CONVENTIONS.md` §9
restates them. What this table adds is the mechanism.

| Invariant | Held by |
|---|---|
| **1** No network code path, ever | `check_no_network.sh` over `pubspec.yaml`, imports and symbols; on Android, the permission the release manifest does not grant |
| **2** A verdict states a fact and never instructs | `check_verdict_contract.sh` over `app/lib` and every ARB value — English patterns and a separate Arabic pass |
| **3** Every result carries a required, non-nullable `Citation` | unrepresentable: a non-nullable field on the sealed types in `packages/rule_engine/`. A `Citation?` is a defect |
| **4** Colour is never the only signal | the greyscale proof and contrast tests of E19, plus `check_lonja_verdict.sh` |
| **5** An expired ruleset is still evaluated and still shown | a test that the finding still carries its numbers behind the non-blocking ochre bar |

**If a task appears to require breaking one, the task is wrong. Stop and say so.** Three of the five
rest on a grep, so read the next section before trusting a green one.

## The gates, and what a green one does not mean

Sixteen runnable `.claude/skills/*/scripts/check_*.sh` — and after D-13 that glob matches exactly
sixteen, because the vendored general skills sit in `.claude/skills-flutter/`. `tools/gates/` grows
alongside them across E01/T03–T05, T08, T09 and E06/T05; **E01/T08** is the task that wired all sixteen
into `tools/gates/skill_gates.tsv` and `run_skill_gates.sh`, counting the files each one matched before
trusting its exit code. A row is required for **every** script that glob finds, so a seventeenth is a
failed test rather than a gate nobody runs.

**Always pass the real target directory.** The target is an argument, and the wrong one passes silently.

| Script | Target | Why |
|---|---|---|
| the other fourteen | `app/lib` | D-1 |
| `check_rule_engine.sh` | `packages/rule_engine/lib` | D-1 |
| `check_content_pipeline.sh` | `tools/content_builder` **and** `content` | D-4. E01/T08's table names the package, but checks 1, 2, 3, 5, 6 and 7 read only `*.yaml`, which lives at `content/` — hence 19 invocations against `content` across E04, E22 and E18. Its header offers `.` for both |

`check_app_invariants.sh` is not `app/lib`-only either: E03 and E04 run it against
`packages/rule_engine/lib`. Pointed at `app/lib` it fans out to all fifteen siblings with that same
target, so one green command can mean the engine and the builder were never scanned.

A missing directory exits 2, which is loud and recoverable. **A directory that exists and is empty exits
0**, and thirteen of the sixteen print a clean `OK` with no hint they read nothing: a green tick meaning
"I found nothing" and one meaning "I looked at nothing" are the same pixel. They are heuristic greps —
**passing is a floor, not proof.** Each documents its own escape hatch in its header, the token differs
per gate (`catchlaw-invariant-ok`, `lonja-token-ok`, `catchlaw-db-ok`, `// lonja-type: ok`,
`lonja-dialogs: allow`, and eleven more). **Scope is per check, not per script, and a header can be
wrong about it:** `check_lonja_lists.sh` waives a whole file, and so does one check in
`check_reference_db.sh` — its line 116 is `grep -q 'catchlaw-db-ok' "$f" && continue`, while that
script's own header says the token sits on the offending line. Read the check, not the header. ARB
values and `pubspec.yaml` dependencies are never exempt. Never edit a
gate, its patterns or its allowlist to make a build pass; if a gate is genuinely wrong, say so and stop.

## What this product refuses

A scope boundary, not a backlog (`SPEC.md` §5).

| Refused | Because |
|---|---|
| accounts, login, sync, cloud backup, licence validation | being locked out of data already on the phone is the failure this product exists to avoid |
| maps, tides, weather, prices, catch sharing, leaderboards, spot marking | each is a second product, and each wants a network |
| ciguatera, toxin, mercury or edibility advice | health claims, not a quotation of an instrument |
| fetching anything, ever — `authority_url` and `citation.source_url` are selectable text, never a link | an `ACTION_VIEW` fetches under the browser's own permission and defeats the Android guarantee; `url_launcher` and `launchUrl` are grep-banned (see *Not yet settled*) |
| photo-AI identification | `SPEC.md` §5.2 argues it in full, with the receipts. Do not re-derive it |
| presenting the catch log as satisfying a declaration duty | it is a private complement to the EU's `RecFishing` app, never a substitute |

**In scope, and easy to refuse by mistake.** The OS share sheet — `share_plus`, which `SPEC.md` §10
calls "the only outbound path, user-initiated and app-external"; E17/T05, tested in airplane mode by
§14. A single-shot GPS fix — `geolocator`, no geocoding, no map, no network; E11 delivers it as a
suggestion, and denying it must cost nothing. The in-app camera — `camera`, chosen over `image_picker`
so photos never enter the shared camera roll; E13.

## Vocabulary — one word per concept

Everywhere: prose, class names, ARB keys and values in all six files, column names, commit messages.

| Use | Never |
|---|---|
| **verdict** (the whole answer for one fish) · **finding** (one rule that fired) | result or outcome as a domain word; judgement, decision, advice. The *class* names are unsettled — see below |
| **citation** (instrument · article · `publishedOn` · `checkedOn`) · **instrument** (the decision or order itself) | source, link, reference — nothing in this app is a link |
| **pack** (a bundled jurisdiction's content, versioned) · **ruleset** (the rows it contributes) | dataset, feed, content — `reference.db` is the file, not the law |
| **zone** (a geometry a rule attaches to) · **jurisdiction** (the authority that published it) | region, area, territory used as if interchangeable |
| **expired** (`valid_to` passed — still evaluated, still shown) · **no limit in instrument** (positively recorded, and cited) · **no rule recorded** (nothing transcribed, and not a permission) | merging any two of the three; missing, unknown, unavailable, "not regulated" |
| the stale bar's colour is the **`verdictWarn`** slot, bound to `ochre47` / `ochre76` / `ochre38` | a bare `ochre` in Dart — primitives carry their measured L\* (`lonja-design-tokens` rule 2). "amber" is the prose word in `SPEC.md`, `README.md`, the PR template and 23 lines under `epics/`, including E10/T06, the task that builds the bar |
| **check** (the act, S1) · **identify** (the key, S7) · S2 is the species detail *and* the result — E08 ships its static half, E10 the verdict | scan, lookup, query. Two things are searches and both keep the word: the species search (S5) and the Arabic legal-text FTS (S13, E15) |

**The banned lexicon belongs to `catchlaw-verdict-contract`** (rules 1 and 2), with the token set in
`product-invariants.md` §2 and the BAD → GOOD pairs in `references/verdict-copy-rules.md`. Do not carry
a copy anywhere: `check_verdict_contract.sh` enforces a *narrower* set than the law — its
permission-verb grep fires only inside ARB keys prefixed `verdict*` or `finding*`, and in no Dart
pattern at all — and it allows a `// verdict-contract-ok` on a Dart line, where no ARB value is ever
exempt. A green gate is not evidence the sentence is lawful.

## The pinned stack, and this machine

| | |
|---|---|
| Toolchain | Flutter **3.44.6** stable · Dart SDK constraint **`^3.12.0`** |
| State | Riverpod **3.4.1** with `riverpod_generator` **4.0.6** |
| Persistence | `drift` **2.34.2** |

**D-5** settles Flutter, the Dart SDK constraint, Riverpod and drift, and overrules `SPEC.md` §10 on two
of them — "Flutter 3.24+ / Dart 3.5+" and "flutter_riverpod ^2.5". Dart 3.5 cannot resolve a pub
workspace at all, so the spec's floor is not merely old, it is incompatible with D-1. The drift pin
satisfies §10's `^2.20` rather than overruling it. **Every other version comes from `SPEC.md` §10**,
and E01/T04 makes
`tools/gates/allowlist/direct_dependencies.txt` the checked-in set. Not `pub add`, not memory, not this
table. The dependency ban list is `catchlaw-offline-guarantee`'s.

**The 33 general Flutter skills are installed at project scope** — `flutter@flutter-skills` 0.1.0,
declared in `.claude/settings.json` so a fresh clone inherits it — **and vendored at
`.claude/skills-flutter/`** so a clone can read them without a marketplace fetch. **179 of the 181** task
files name at least one of them. They are namespaced: a task table writes `state-management-riverpod`,
the Skill tool takes `flutter:state-management-riverpod`.

**They are not under `.claude/skills/`, and that is load-bearing (D-13).** `check_app_invariants.sh`
check 9 delegates to every *sibling* `check_*.sh`, so a general gate parked beside the sixteen gets run
against `app/lib` — and `check_routing.sh` then fails for want of a `GoRouter` that E12 delivers. Keeping
the two registries in two directories is what makes `CONVENTIONS.md` §7's "sixteen" a fact about the
filesystem rather than about the prose. Reinstall the plugin with:

```bash
claude plugin marketplace add zakariaf/Flutter-Skills --scope project
claude plugin install flutter@flutter-skills --scope project

.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
dart run content_builder:build --in content/ --out app/assets/db/reference.db
gh pr merge --squash --admin --delete-branch   # only once every check reports SUCCESS (D-9)
```

**Two of the 33 cannot auto-invoke.** `async-safety` and `design-review-workflow` carry an unquoted
`: ` inside a plain YAML scalar — `async-safety`'s description contains `` `onTap: () => vm.save(x)` ``
— so the frontmatter parses to nothing and the model is never offered them. It is a `description: >-`
away from fixed, in the plugin repository rather than here. **E07/T07, E10/T07 and E16/T07 route to
`async-safety`:** until the plugin is fixed, load it by explicit name or read its `SKILL.md` directly,
and do not read a silent non-invocation as "no async rule applies".

## The shape of the repository

Nothing under `app/`, `packages/` or `tools/` exists yet — this is the target, not the tree (D-1).

```
pubspec.yaml                    name: catchlaw_workspace — the workspace root, ships nothing
app/                            the Flutter app (name: catchlaw); the theme at app/lib/theme/ (D-2)
packages/rule_engine/           pure Dart, zero Flutter, no user-visible sentence in any language (D-7)
packages/analysis_defaults/     shared lints, a dev-dependency of every member
tools/content_builder/          authoring YAML → reference.db, `dart run content_builder:build` (D-4)
content/                        the authored YAML itself — E04's input and the whole of E22
.github/                        validate.yml, CODEOWNERS, the PR template
epics/ · design/ · research*/   already here
```

Dependencies run one way and `app/lib/ui/` never touches a DAO. Take the layer tree from
`FLUTTER_GUIDE.md` §2.5, not from `catchlaw-conventions-index` rule 6, which omits `app/lib/domain/` —
§1.9 makes the domain layer mandatory here and review rule 3 puts every cross-repository join in
`domain/use_cases/`. Two databases: `reference.db`, shipped and read-only, and `user.db`, the only
writable one; the extraction mechanism is **D-6**, owned by `catchlaw-reference-database`, and is not
something to re-derive.

`app/lib/main.dart` is not `async` — **nothing is awaited before `runApp`** (`catchlaw-conventions-index`
rule 8, `check_app_invariants.sh` check 8, E01/T01 test 11, rejected again in E06/T04 and E06/T06).
Restoring a persisted theme before first paint is `flutter:app-startup-and-bootstrap`'s problem, not an
exception to this.

**Take locales from D-3 and paths from D-1, always.** The locale and builder-name drift is now
*cleared*: E01/T09 corrected four skill files and the E01 close-out corrected the remaining six, so no
file under `.claude/skills/` names `app_ur.arb`, an Urdu RTL lane, `app_pt.arb`, a bare `ur`, or the
`content_build` CLI. The register `tools/gates/known_skill_drift.txt` is now **empty, and still
load-bearing** — `app/test/policy/skill_locale_test.dart` asserts the stale set equals the register, so
an empty register is the assertion that no file carries the old wording at all. Consult it, never a
list kept elsewhere; if you must add a line, it is a correction with an owner, not an exemption.

D-1's path staleness is a separate, open item — see *Not yet settled* on the routing table's
root-relative `lib/` paths.

There is no application code under `app/lib/ui/check/` yet, and nothing routes to what is built.
`epics/README.md` is the order in which the rest appears — 22 epics, 183 tasks, hard dependencies,
**E22** the one that runs in parallel from E04 onward. Merging an epic's PR includes updating its row
in that file's status table.

**`epics/RELEASES.md` is the release order and it overrules that build order (D-22).** E01–E10 are
merged; the remaining ninety tasks are **v1 (thirteen)** and **v2 (seventy-nine)**. v1 is one
jurisdiction answered offline, and two of its thirteen tasks are new — `E12/T08`, the evaluation seam
nobody owned, and `E22/T10`, the first rule rows this repository has ever carried. Read `RELEASES.md`
before picking up a task: a task file carrying **`Release: v2 — deferred`** is not the next thing to
build.

## Which skill owns this

Two registries, kept apart by one rule (`CONVENTIONS.md` §4): the sixteen `catchlaw-*` and `lonja-*`
skills under `.claude/skills/` carry token **values** and app-domain **law**; the 33 general Flutter
skills carry general **practice**. A general rule is never restated in an app skill, and vice versa. A
rule that lives in neither is a gap — record it in
`catchlaw-conventions-index/references/routing-table.md`; do not invent a local convention.

| If the change touches | Load |
|---|---|
| anything at all, when ownership is unclear — **the front door** | `catchlaw-conventions-index`, then its `references/routing-table.md` |
| a colour, gap, radius, rule weight, duration or target size — **the value front door** | `lonja-design-tokens` |
| any user-facing sentence about a rule, in Dart or in an ARB value | `catchlaw-verdict-contract` |
| rule evaluation, precedence, seasons, zones, expiry, ambiguity | `catchlaw-rule-engine` |
| a length, a unit, a measurement method, the ruler or calibration | `catchlaw-measurement-ruler` |
| `pubspec.yaml` or `AndroidManifest.xml` | `catchlaw-offline-guarantee`, then `flutter:dependency-hygiene` |
| `reference.db`, `user.db`, schema, seeding, first-launch extraction | `catchlaw-reference-database` |
| authoring YAML, the build CLI, a build assertion, a plate's licence | `catchlaw-content-pipeline` |
| the result surface, the stamp, the stale bar, the citation footnote | `lonja-verdict-and-status` |
| a widget, notifier, route, test, ARB key, lint or CI job | the plugin — start at `flutter:flutter-conventions-index` |
| a schema change, or regenerating code | `flutter:run-migration` / `flutter:run-codegen` — **these never fire on their own; invoke them by name** |

A seam the routing table does not cover is added *there*, in the same change as the ambiguity that
found it. **A task's "Skills to load" table is a precondition, not a bibliography.** If a named skill
will not resolve, stop and report the name — falling back on general Flutter knowledge is inventing a
local convention without noticing you did.

## How work happens

`epics/CONVENTIONS.md` is the ritual — read it once per session, before the first task. It owns the epic
loop, the task loop, the commit format and the `Task: Enn/Tnn` trailer, where tests live, and the
definition of done. Two of its rules are worth carrying in before you open it:

- **Test names are `<Subject> <present-tense verb phrase> [when/with <condition>]`.** Subject first. No
  `should`, no `it`, no given/when/then, no `group('X tests')` (§5). This is the strongest wrong default
  a model brings to the file.
- **Tests are written first and must be seen failing**, because a test that passes before the
  implementation exists is testing nothing; `/simplify` then `/code-review` run before the commit and
  the work they produce lands in it; a failed check is fixed by a further commit on the same branch,
  never an amend and never a force-push (§1, §2).

## Not yet settled — do not decide these quietly

Raise each as a new `D-n` in `epics/DECISIONS.md`, naming the losing source. Do not pick a side inside a
task.

- **`url_launcher` for `mailto:` and `tel:`.** `product-invariants.md` §1 allows it on the About screen;
  `SPEC.md` §10 and §14 and `check_no_network.sh` ban it outright. D-2's rule of thumb already
  tie-breaks — the gate wins — so E18 ships selectable text and raises it in its PR. The outstanding
  action is a correction to `product-invariants.md` §1, which no epic owns.
- **Millimetres.** `catchlaw-measurement-ruler` requires an integer `lengthMm`;
  `catchlaw-conventions-index`'s worked example — `examples/catchlaw_layering.dart` lines 42, 54, 62–63,
  and the same snippet in its `SKILL.md` — declares `double minimumCm` and `double measuredCm`: wrong
  type, wrong unit. `check_measurement.sh` check 1 misses it, because its regex requires the identifier
  to contain `length`. The ruler skill is authoritative.
- ~~**The engine's top type name.**~~ **Settled by D-15**, at the head of E03 where it landed. The three
  conflicts had three different losers, so each name was decided on its own evidence: **`Resolution`**
  (D-7's `Verdict` loses), **`Finding`** (`catchlaw-rule-engine`'s `RuleFinding` loses — it appears in
  that skill and in no task file), **`Ambiguous`** (`catchlaw-verdict-contract`'s `ConflictingRules`
  loses). D-7 is amended rather than overturned: its substance, that the engine holds no user-visible
  sentence, is untouched. In the vocabulary table below, **verdict** and **finding** remain the words for
  prose, ARB keys and column names; D-15 governs a class name in a package that contains no words.
- **Is `Citation` four fields or five?** `catchlaw-verdict-contract` rule 5 and `catchlaw-rule-engine`
  rule 9 require exactly instrument, article, `publishedOn`, `checkedOn`; `product-invariants.md` §3
  adds `packId`.
- **The routing table's root-relative `lib/` paths.** D-1 overrules them and names E01/T09 as its
  correction site, but T09 is scoped to D-3 and D-4 and leaves the paths alone. Its Risks name the
  resolution: a line in `DECISIONS.md` naming the task that rewrites them.

## The amendment rule

> **A decision changes in `epics/DECISIONS.md`, with the losing source named, in the same change as every
> document, skill and task file that applies it.**

1. Amend the `D-n` entry. A superseded decision is struck with its reason, never quietly rewritten.
2. `grep -rn` the identifier across `epics/` and `.claude/skills/`. Every hit changes in that commit.
3. A **skill** correction gets a task ID and lands as a task, the way E01/T09 carries D-3.
4. A **path** change re-checks every gate call site — the target is an argument, and a wrong one is the
   silent-green failure above.
5. A **schema** change is irreversible after the first shipped pack. Say so, and route it to the owner.

You may never implement around a decision you disagree with. Every rule in this file has a failure behind
it, and those failures land at 05:40, on a wet phone, in front of an inspector, inside a sentence about
the law that the fisher holding it has no way to check.
