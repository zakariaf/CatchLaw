# What Makes a Claude Code Skill *Good* and *Rich* (not merely valid)

**Research date:** 2026-07-30
**Claude Code version on this machine:** `2.1.220` (binary: `/Users/zakariafatahi/.local/share/claude/versions/2.1.220`, `claude --version` → `2.1.220 (Claude Code)`)

## Source inventory (what was actually read)

| # | Source | Type | Notes |
|---|---|---|---|
| S1 | `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` | Primary docs | "Skill authoring best practices". `docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices` 302-redirects here as of 2026-07-30. |
| S2 | `https://code.claude.com/docs/en/skills` | Primary docs | "Extend Claude with skills" — Claude Code-specific frontmatter reference, lifecycle, troubleshooting. |
| S3 | `github.com/anthropics/skills` @ `main` | Primary repo | Cloned shallow 2026-07-30. 17 skills under `skills/`. |
| S4 | `skills/skill-creator/SKILL.md` (S3) | Primary | Anthropic's own authoring guidance, 485 lines / 5,205 words. Read in full. |
| S5 | `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator/` | On disk | Local copy of the same skill + its `scripts/`. `quick_validate.py` read in full. |
| S6 | `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/plugin-dev/` | On disk | `skills/skill-development/SKILL.md` and `agents/skill-reviewer.md`. **Secondary-quality** — see the contradiction warning in §1.4. |
| S7 | `https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills` | Primary blog | Linked from the anthropics/skills README. |
| S8 | `claude plugin --help`, `claude plugin eval --help`, `claude plugin validate --help` | On disk / CLI | Verified 2026-07-30 on v2.1.220. |

**Not found / not verified:**
- `anthropic.com/news/skills` — not fetched; no evidence gathered. Treat as unverified.
- `github.com/anthropics/skills/spec/agent-skills-spec.md` exists but is now a **stub**: its entire content is `The spec is now located at <https://agentskills.io/specification>`. The normative spec has moved off Anthropic's own domain to `agentskills.io` (referred to by S2 as "the Agent Skills open standard"). I did not fetch agentskills.io, so anything attributed to it below is second-hand via S1/S2/S5.
- No official Anthropic cookbook page on skills was located.

---

## 1. The description: what Anthropic actually says

### 1.1 Confirm/correct the premise "the description is the only thing loaded until the skill fires"

**Mostly true, with two corrections that matter.**

Confirmed (S1, *Concise is key*):

> "At startup, only the metadata (name and description) from all Skills is pre-loaded. Claude reads SKILL.md only when the Skill becomes relevant, and reads additional files only as needed."

And (S1, *Runtime environment*):

> "**Metadata pre-loaded:** At startup, the name and description from all Skills' YAML frontmatter are loaded into the system prompt"

**Correction 1 — in Claude Code it is `name` + `description` + optionally `when_to_use`.** S2's frontmatter reference documents a `when_to_use` field that is *appended to `description` in the skill listing*. So the pre-loaded budget is the combined text, not the description alone.

**Correction 2 — the description is not guaranteed to survive intact.** This is the single most under-appreciated fact for anyone about to write "a large set of new skills". From S2, *Skill descriptions are cut short*:

> "The listing always contains every skill name, but if you have many skills, Claude Code shortens descriptions to fit the listing's character budget, which can strip the keywords Claude needs to match your request. The budget scales at 1% of the model's context window. When the listing overflows, Claude Code drops descriptions starting with the skills you invoke least, so the skills you use most keep their full text."

Concrete numbers, all from S2:

| Limit | Value | Source field / setting |
|---|---|---|
| Per-skill cap on combined `description` + `when_to_use` in the listing | **1,536 characters** | configurable via `skillListingMaxDescChars` |
| Whole-listing budget | **1% of the model's context window** | configurable via `skillListingBudgetFraction` (e.g. `0.02` = 2%) or env var `SLASH_COMMAND_TOOL_CHAR_BUDGET` (fixed char count) |
| Hard spec cap on `description` | **1,024 characters** | S1 *YAML frontmatter requirements*; enforced by `quick_validate.py` (S5) |
| Hard spec cap on `name` | **64 characters** | S1; enforced by `quick_validate.py` (S5) |

Note the 1,024 (spec) vs 1,536 (Claude Code listing) discrepancy — they are different limits on different things and both are real. Write to **1,024** to stay portable.

**Practical consequence for a 50-skill set:** with ~50 skills at ~400 chars each you are at ~20,000 characters of listing. Against a 1M-context model at 1%, that fits; against a 200k-context model at 1% (~2,000 chars scaled by whatever char/token ratio applies) it will not, and Claude Code will start dropping descriptions from the least-invoked skills. **Verification tool:** S2 says run `/doctor` "for an estimate of the listing's context cost and its biggest contributors", and the Skills row in `/context` "reports the size of the listing after the budget is applied". Also `claude plugin details <name>` — its help text (S8) reads "Show a plugin's component inventory and **projected token cost**".

### 1.2 What a good description looks like — the rules

From S1, *Writing effective descriptions*:

- **Third person, always.** > "**Always write in third person**. The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems."
  - Good: `"Processes Excel files and generates reports"`
  - Avoid: `"I can help you process Excel files"` / `"You can use this to process Excel files"`
- **Both halves: what + when.** > "The `description` field enables Skill discovery and should include both what the Skill does and when to use it."
- **Selection pressure is real.** > "Claude uses it to choose the right Skill from potentially 100+ available Skills."
- **Put the key use case first** (S2) — because of the 1,536-char truncation.

Anthropic's own canonical examples (S1):

```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```
```yaml
description: Analyze Excel spreadsheets, create pivot tables, generate charts. Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.
```
```yaml
description: Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.
```

Explicit anti-examples (S1): `Helps with documents` / `Processes data` / `Does stuff with files`.

The shape is consistent: **`<verb-phrase list of capabilities>. Use when <trigger conditions>.`**

### 1.3 Be "pushy" — the undertriggering correction

This is the most actionable guidance and it comes straight from Anthropic's own skill-creator (S4):

> "**description**: When to trigger, what it does. This is the primary triggering mechanism - include both what the skill does AND specific contexts for when to use it. **All "when to use" info goes here, not in the body.** Note: currently Claude has a tendency to "undertrigger" skills -- to not use them when they'd be useful. **To combat this, please make the skill descriptions a little bit "pushy".** So for instance, instead of "How to build a simple fast dashboard to display internal Anthropic data.", you might write "How to build a simple fast dashboard to display internal Anthropic data. Make sure to use this skill whenever the user mentions dashboards, data visualization, internal metrics, or wants to display any kind of company data, even if they don't explicitly ask for a 'dashboard.'""

Also from S4, *How skill triggering works* — a mechanism detail with real design consequences:

> "Claude only consults skills for tasks it can't easily handle on its own — simple, one-step queries like "read this PDF" may not trigger a skill even if the description matches perfectly, because Claude can handle them directly with basic tools. **Complex, multi-step, or specialized queries reliably trigger skills** when the description matches."

**Implication:** if your skill's value is on simple one-step tasks, description tuning will not save it. Either fold it into a bigger skill or accept manual `/skill-name` invocation.

### 1.4 Measured reality: what Anthropic's own descriptions look like

Measured on the 17 skills in `anthropics/skills` @ main (2026-07-30):

| Skill | description chars |
|---|---|
| claude-api | 1077 |
| xlsx | 950 |
| docx | 835 |
| pptx | 738 |
| pdf | 437 |
| doc-coauthoring | 428 |
| internal-comms | 329 |
| algorithmic-art | 324 |
| skill-creator | 319 |
| canvas-design | 289 |
| web-artifacts-builder | 288 |
| mcp-builder | 277 |
| theme-factory | 262 |
| brand-guidelines | 236 |
| slack-gif-creator | 226 |
| frontend-design | 204 |
| webapp-testing | 204 |

**Median 319, mean 437.** The four document skills (the ones that ship in production behind Claude's file capabilities) are the long, pushy ones — 738–1077 chars. Note `claude-api` at 1077 **exceeds the 1,024 spec cap**; that is Anthropic's own repo violating the documented limit, so treat 1,024 as advisory-but-enforced-by-validators rather than universally enforced at runtime.

The best exemplar of a rich description is `docx` (835 chars), because it does something the docs never explicitly teach — **negative scoping**:

```yaml
description: "Use this skill whenever the user wants to create, read, edit, or manipulate Word documents (.docx files) or Word templates (.dotx files). Triggers include: any mention of 'Word doc', 'word document', '.docx', '.dotx', or requests to produce professional documents with formatting like tables of contents, headings, page numbers, or letterheads. Also use when extracting or reorganizing content from .docx or .dotx files, inserting or replacing images in documents, performing find-and-replace in Word files, working with tracked changes or comments, or converting content into a polished Word document. If the user asks for a 'report', 'memo', 'letter', 'template', or similar deliverable as a Word or .docx file, use this skill. Do NOT use for PDFs, spreadsheets, Google Docs, or general coding tasks unrelated to document generation."
```

Structure of that description, worth copying literally:
1. `Use this skill whenever the user wants to <core verbs> <object>`
2. `Triggers include: <literal quoted strings a user would type>`
3. `Also use when <secondary/adjacent scenarios>`
4. `If the user asks for <deliverable nouns>, use this skill.`
5. `Do NOT use for <named sibling skills' territory>.`

Step 5 is the collision-avoidance mechanism for a large skill set. Nothing in the official docs states it; it is an inferred-from-practice pattern with a strong primary-source example.

### 1.4b ⚠️ Contradiction to be aware of

`plugin-dev`'s `agents/skill-reviewer.md` (S6, on disk) says:

> "Optional fields: `version`, `when_to_use` (note: deprecated, use description only)"

This **contradicts** S2, the current Claude Code docs, which document `when_to_use` as a live, supported field. `plugin-dev`'s `skill-development/SKILL.md` also uses `version: 0.1.0` in its frontmatter, a field that is **not** in `quick_validate.py`'s `ALLOWED_PROPERTIES` (S5) and would fail that validator. **Prefer S1/S2 over S6 wherever they disagree.** S6 appears to be older material — it self-describes as deriving from a `references/skill-creator-original.md`.

---

## 2. Progressive disclosure and the token-budget argument

### 2.1 The argument, in Anthropic's words

S1, *Concise is key*:

> "The context window is a public good. Your Skill shares the context window with everything else Claude needs to know, including: the system prompt, conversation history, other Skills' metadata, your actual request."
>
> "Not every token in your Skill has an immediate cost. ... However, being concise in SKILL.md still matters: once Claude loads it, **every token competes with conversation history and other context**."

S1's stated default assumption, which is the actual editorial test:

> "**Default assumption:** Claude is already very smart. Only add context Claude doesn't already have. Challenge each piece of information: 'Does Claude really need this explanation?' / 'Can I assume Claude knows this?' / **'Does this paragraph justify its token cost?'**"

S7 (engineering blog) frames the upside: because of on-demand loading, "the amount of context that can be bundled into a skill is effectively unbounded."

S2 adds the Claude Code-specific sharpener, and this is the strongest version of the argument:

> "Keep the body itself concise. Once a skill loads, its content **stays in context across turns**, so **every line is a recurring token cost**. State what to do rather than narrating how or why."

Note this last clause ("state what to do rather than narrating how or why") is in tension with S4's "Explain the why" (§3.4). See §3.4 for how to reconcile.

### 2.2 The three-level model

From S4 (skill-creator), *Progressive Disclosure*:

> 1. **Metadata** (name + description) - Always in context (~100 words)
> 2. **SKILL.md body** - In context whenever skill triggers (<500 lines ideal)
> 3. **Bundled resources** - As needed (unlimited, scripts can execute without loading)
>
> "These word counts are approximate and you can feel free to go longer if needed."

### 2.3 Stated numeric targets (with provenance, because they disagree)

| Target | Value | Source | Confidence |
|---|---|---|---|
| SKILL.md body length | **under 500 lines** | S1 (*Progressive disclosure patterns*, *Token budgets*, and the final checklist), S2 (`<Tip>Keep SKILL.md under 500 lines`), S4 | **High — three independent primary sources agree.** This is *the* number. |
| Table of contents threshold for reference files | **>100 lines** | S1, *Structure longer reference files* | High |
| ToC threshold (alternate) | **>300 lines** | S4, skill-creator | Medium — S4 and S1 disagree; use 100 (the stricter). |
| Grep-hints threshold for reference files | **>10k words** | S6, `plugin-dev/skill-development` | Low (secondary source) |
| SKILL.md body word count | 1,500–2,000 ideal, <3,000, <5k max | S6 only | **Low — secondary source, and it conflicts with observed reality (see below).** |
| Metadata size | ~100 words | S4, S6 | Medium |

**Measured reality beats the word-count advice.** Line/word counts of Anthropic's own 17 SKILL.md files (2026-07-30):

| Skill | lines | words |
|---|---|---|
| internal-comms | 32 | 211 |
| frontend-design | 55 | 1336 |
| theme-factory | 59 | 486 |
| brand-guidelines | 73 | 329 |
| web-artifacts-builder | 73 | 446 |
| docx | 91 | 975 |
| webapp-testing | 95 | 501 |
| xlsx | 99 | 1312 |
| canvas-design | 129 | 1749 |
| mcp-builder | 236 | 1143 |
| pptx | 238 | 3129 |
| slack-gif-creator | 254 | 1103 |
| pdf | 314 | 1007 |
| doc-coauthoring | 375 | 2466 |
| algorithmic-art | 404 | 2763 |
| skill-creator | 485 | 5205 |
| claude-api | 546 | 9556 |

**Median: 129 lines / 1,103 words.** Fifteen of seventeen are under 500 lines; `claude-api` (546) is the only breach. The production document skills — `docx` (91), `xlsx` (99), `pdf` (314), `pptx` (238) — are all *far* under the limit while being the most heavily used. **The real target is ~100–250 lines, not 500.** 500 is a ceiling, not a goal.

### 2.4 What goes in SKILL.md vs a reference file

S1's three named patterns:

**Pattern 1 — High-level guide with references.** SKILL.md holds a quick-start code block plus a link table:
```markdown
## Advanced features

**Form filling**: See [FORMS.md](FORMS.md) for complete guide
**API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
**Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
```

**Pattern 2 — Domain-specific organization.** One reference file per domain, so irrelevant domains cost zero:
```text
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md   (revenue, billing metrics)
    ├── sales.md     (opportunities, pipeline)
    ├── product.md   (API usage, features)
    └── marketing.md (campaigns, attribution)
```
S1: "When a user asks about sales metrics, Claude only needs to read sales-related schemas, not finance or marketing data." S1 also recommends bundling **grep hints** into SKILL.md for this pattern:
```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
```
S4 gives the same shape under "Domain organization" with `cloud-deploy/{aws,gcp,azure}.md`.

**Pattern 3 — Conditional details.** Basic content inline, advanced behind a link.

**The directory contract** (S4's "Anatomy of a Skill", corroborated by S1 and S6):
```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name, description required)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code for deterministic/repetitive tasks
    ├── references/ - Docs loaded into context as needed
    └── assets/     - Files used in output (templates, icons, fonts)
```
The three-way distinction is the useful part: `references/` is **read**, `scripts/` is **executed**, `assets/` is **copied into output**. S6 states it crisply: assets are "files not intended to be loaded into context, but rather used within the output Claude produces."

### 2.5 Two hard structural rules

**Rule A — references must be exactly one level deep.** S1, *Avoid deeply nested references*:

> "Claude may partially read files when they're referenced from other referenced files. When encountering nested references, Claude might use commands like `head -100` to preview content rather than reading entire files, **resulting in incomplete information**. **Keep references one level deep from SKILL.md.**"

**Rule B — no duplication between SKILL.md and references.** S6: "Information should live in either SKILL.md or references files, not both."

Plus: forward slashes only, even on Windows (S1, *Avoid Windows-style paths*); and descriptive filenames — "`form_validation_rules.md`, not `doc2.md`" (S1).

---

## 3. Patterns Anthropic's own skills actually use

### 3.1 Do they use "Non-negotiable rules"? — **No. Not as a structure.**

I grepped every SKILL.md and reference file in `anthropics/skills` for `non-negotiable`. **There is no `## Non-negotiable rules` heading anywhere in the repo.** The literal phrase appears exactly 3 times, all inline mid-paragraph, all as emphasis on a single specific point:

- `claude-api/SKILL.md:187` — "**ALWAYS use `claude-opus-5` unless the user explicitly names a different model.** This is non-negotiable."
- `claude-api/shared/model-migration.md:36` — "This is non-negotiable: even imperative-sounding requests like 'migrate my codebase' ... leave the scope ambiguous and require a clarifying question."
- `canvas-design/SKILL.md:108` — "This is non-negotiable for professional execution."

And skill-creator (S4) actively warns against the register that a "Non-negotiable rules" section invites:

> "If you find yourself writing ALWAYS or NEVER in all caps, or using super rigid structures, **that's a yellow flag** — if possible, reframe and explain the reasoning so that the model understands why the thing you're asking for is important. That's a more humane, powerful, and effective approach."

**Verdict:** reserve all-caps absolutes for the two or three places where a wrong choice is unrecoverable (a destructive command, a model ID, an unbounded edit scope). Do not create a rules section as a default structure.

### 3.2 What they *do* use — the real heading vocabulary

Heading inventory across the 17 SKILL.md files. The recurring ones:

- `## Overview` (3), `## Quick Start` (2), `## Dependencies` (4)
- Decision-first headings: `## Decision Tree: Choosing Your Approach`, `## Which Surface Should I Use?`, `## When to use this skill`, `## When to Use WebFetch`, `## When to Offer This Workflow`
- Failure-first headings: `## Common Pitfall`, `## openpyxl gotchas`, `## ⚠️ API Drift — Your Training Prior May Be Stale`
- Verification headings: `## Verify the output`, `## Recalculate (mandatory whenever the file contains formulas)`, `## Requirements for every output`
- Navigation headings: `## Reference Files`, `## 📚 Documentation Library`, `## Scripts`
- Phase/stage workflows: `### Phase 1: Deep Research and Planning` … `### Phase 4: Create Evaluations`; `## Stage 1: Context Gathering` … `## Stage 3: Reader Testing`

Almost every skill opens with either a **decision table/tree** or a **quick-start code block**, and closes with **`## Dependencies`** and/or **`## Reference Files`**.

### 3.3 Two exemplars worth copying structurally

**`docx/SKILL.md` — 91 lines, 975 words. The best model for a codebase-convention skill.**

Its whole shape:
```
# DOCX creation, editing, and analysis
  <one-sentence mental model: "A .docx is a ZIP archive of XML files.">
  <3-row decision table: Task | Approach>
  <note: "Script paths below are relative to this skill's directory.">
## Creating with docx-js — gotchas
## Verify the output
## Editing existing documents
## Comments
## Dependencies
```

The single most instructive line in the whole repo is line 21:

> "`docx` is preinstalled — do not run `npm install` first; write the script and `require('docx')` directly. Only if that require fails: `npm install docx`. **The model knows the API; these are the footguns:**"

That clause is the operational form of S1's "Claude is already very smart". The skill does not teach the library. It enumerates **only the delta between the model's prior and reality** — 11 bullets, each one a specific failure the model would otherwise walk into ("Table shading: use `ShadingType.CLEAR`, never `SOLID` (renders black)"). This is what "rich" actually means: high failure-density per token, zero tutorial.

**`webapp-testing/SKILL.md` — 95 lines. Best model for a script-bundling skill.**

Contains the explicit **black-box scripts** instruction, which is a context-hygiene pattern the official docs never spell out this bluntly:

> "**Always run scripts with `--help` first** to see usage. **DO NOT read the source until you try running the script first and find that a customized solution is absolutely necessary. These scripts can be very large and thus pollute your context window. They exist to be called directly as black-box scripts rather than ingested into your context window.**"

And its `## Common Pitfall` section is a two-line ❌/✅ pair — the cheapest possible correction format:
```markdown
## Common Pitfall

❌ **Don't** inspect the DOM before waiting for `networkidle` on dynamic apps
✅ **Do** wait for `page.wait_for_load_state('networkidle')` before inspection
```

### 3.4 Writing style — and the one genuine conflict in the guidance

Three overlapping style prescriptions:

- **Imperative form.** S4: "Prefer using the imperative form in instructions." S6 elaborates: "'To accomplish X, do Y' rather than 'You should do X'."
- **Consistent terminology.** S1: "Choose one term and use it throughout." Bad: mixing "API endpoint / URL / API route / path"; mixing "extract / pull / get / retrieve". "Consistency helps Claude parse and follow instructions."
- **No time-sensitive content.** S1: don't write "If you're doing this before August 2025…". Instead keep a collapsed `## Old patterns` section using `<details>`.

**The conflict:** S4 says explain the why —

> "**Explain the why.** Try hard to explain the **why** behind everything you're asking the model to do. Today's LLMs are *smart*. They have good theory of mind and when given a good harness can go beyond rote instructions and really make things happen."

S2 says the opposite —

> "State what to do rather than narrating how or why."

**Reconciliation (my reading, flagged as interpretation, not quoted guidance):** these target different content. S4's "why" applies to *rules the model might otherwise override* — a rule with a stated reason survives contact with a novel situation, an unreasoned rule doesn't. S2's "don't narrate" applies to *background exposition* — explaining what a `.docx` is, what a pivot table does. `docx/SKILL.md` does both simultaneously: "use `ShadingType.CLEAR`, never `SOLID`" (what) "**(renders black)**" (why, in two words). **A parenthetical consequence is the correct dose of "why".** Do not write paragraphs of rationale.

### 3.5 Degrees of freedom — the single best framing in the docs

S1, *Set appropriate degrees of freedom*, with its analogy:

> - **Narrow bridge with cliffs on both sides:** There's only one safe way forward. Provide specific guardrails and exact instructions (low freedom). Example: database migrations that must run in exact sequence.
> - **Open field with no hazards:** Many paths lead to success. Give general direction and trust Claude to find the best route (high freedom). Example: code reviews where context determines the best approach.

| Freedom | Form | Use when |
|---|---|---|
| High | Text instructions / numbered heuristics | Multiple approaches valid; decisions are context-dependent |
| Medium | Pseudocode, or scripts with parameters | A preferred pattern exists; config affects behavior |
| Low | Specific scripts, few or no parameters | Operations are fragile; consistency is critical; exact sequence required |

S1's low-freedom example is deliberately blunt: "Run exactly this script: `python scripts/migrate.py --verify --backup`. Do not modify the command or add additional flags."

### 3.6 Templates and examples

**Template pattern (S1)** — with a strictness dial, which is the part people miss:

Strict: `"ALWAYS use this exact template structure:"` followed by the literal markdown skeleton.
Flexible: `"Here is a sensible default format, but use your best judgment based on the analysis:"` followed by the same skeleton with `[Adapt sections based on what you discover]` placeholders.

**Examples pattern (S1 and S4, near-identical wording)** — input/output pairs, exactly as in ordinary prompting:
```markdown
## Commit message format
**Example 1:**
Input: Added user authentication with JWT tokens
Output: feat(auth): implement JWT-based authentication
```
S1: "Examples convey the desired style and level of detail to Claude more clearly than descriptions alone."

**Conditional workflow pattern (S1)** — explicit branch routing:
```markdown
1. Determine the modification type:
   **Creating new content?** → Follow "Creation workflow" below
   **Editing existing content?** → Follow "Editing workflow" below
```
With the tip: "If workflows become large or complicated with many steps, consider pushing them into separate files and tell Claude to read the appropriate file based on the task at hand."

**Avoid offering too many options (S1).** Bad: "You can use pypdf, or pdfplumber, or PyMuPDF, or pdf2image, or…". Good: one default plus one escape hatch — "Use pdfplumber for text extraction… For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."

---

## 4. Scripts vs prose — when is a script the right answer?

### 4.1 The stated criteria

S1, *Provide utility scripts*:

> "Even if Claude could write a script, pre-made scripts offer advantages: More reliable than generated code; Save tokens (no need to include code in context); Save time (no code generation required); Ensure consistency across uses."

S1, *Runtime environment*: "**Prefer scripts for deterministic operations:** Write `validate_form.py` rather than asking Claude to generate validation code."

S7 (engineering blog) gives the economic version: "sorting a list via token generation is far more expensive than simply running a sorting algorithm."

S6 adds the trigger condition: include a script "when the same code is being rewritten repeatedly or deterministic reliability is needed."

### 4.2 The best signal for *discovering* which scripts to bundle

S4, *Improving the skill*, item 4 — this is a genuinely non-obvious technique:

> "**Look for repeated work across test cases.** Read the transcripts from the test runs and notice if the subagents all independently wrote similar helper scripts or took the same multi-step approach to something. **If all 3 test cases resulted in the subagent writing a `create_docx.py` or a `build_chart.py`, that's a strong signal the skill should bundle that script.** Write it once, put it in `scripts/`, and tell the skill to use it. This saves every future invocation from reinventing the wheel."

So: don't guess which scripts to bundle. Run the skill three times, read the transcripts, and bundle whatever the model kept rewriting.

### 4.3 Execute vs read — you must say which

S1, twice, because it's a common failure:

> "**Important distinction:** Make clear in your instructions whether Claude should: **Execute the script** (most common): 'Run `analyze_form.py` to extract fields'; **Read it as reference** (for complex logic): 'See `analyze_form.py` for the field extraction algorithm'. For most utility scripts, execution is preferred because it's more reliable and efficient."

S7 says the same: "code can serve as both executable tools and as documentation. It should be clear whether Claude should run scripts directly or read them into context as reference."

And `webapp-testing` (§3.3) shows the strongest form: an explicit *prohibition* on reading, with the reason given.

### 4.4 Script-quality rules (S1, *Advanced: Skills with executable code*)

**Solve, don't defer.** Handle error conditions in the script rather than letting it throw for Claude to figure out:
```python
def process_file(path):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"File {path} not found, creating default")
        with open(path, "w") as f:
            f.write("")
        return ""
```
vs the bad version: `return open(path).read()  # Just fail and let Claude figure it out`.

**No voodoo constants** (S1 cites "Ousterhout's law"):
```python
# HTTP requests typically complete within 30 seconds
# Longer timeout accounts for slow connections
REQUEST_TIMEOUT = 30
```
> "If you don't know the right value, how will Claude determine it?"

**Verbose, actionable error messages.** S1: make validators emit things like `"Field 'signature_date' not found. Available fields: customer_name, order_total, signature_date_signed"` — the error message is itself an instruction to the model.

**Don't assume packages are installed.** S1: state the install command. Note the platform split S1 gives: claude.ai "Can install packages from npm and PyPI"; Claude API "Has no network access and no runtime package installation."

**MCP tools need fully qualified names.** S1: use `ServerName:tool_name` (e.g. `BigQuery:bigquery_schema`, `GitHub:create_issue`) — "Without the server prefix, Claude may fail to locate the tool."

**Claude Code bonus (S2):** you can make a bundled script run *without a permission prompt* by matching `allowed-tools` to the exact command, using `${CLAUDE_SKILL_DIR}`:
```yaml
---
name: render-chart
description: Render a chart from a CSV file
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/render.sh *)
---
Run `${CLAUDE_SKILL_DIR}/scripts/render.sh <csv-file>` to render the chart.
```
Requires **v2.1.129+** for the `allowed-tools` substitution; on earlier versions the rule stays literal and never matches. `${CLAUDE_PROJECT_DIR}` substitution requires **v2.1.196+**. (S2)

---

## 5. Verification — is there an established pattern? **Yes, three of them.**

### 5.1 The checklist pattern (established, documented, quoted)

S1, *Use workflows for complex tasks*:

> "Break complex operations into clear, sequential steps. For particularly complex workflows, **provide a checklist that Claude can copy into its response and check off as it progresses**."

The literal form S1 gives (note: a fenced plain-text block, not markdown checkboxes in prose):

````markdown
## PDF form filling workflow

Copy this checklist and check off items as you complete them:

```
Task Progress:
- [ ] Step 1: Analyze the form (run analyze_form.py)
- [ ] Step 2: Create field mapping (edit fields.json)
- [ ] Step 3: Validate mapping (run validate_fields.py)
- [ ] Step 4: Fill the form (run fill_form.py)
- [ ] Step 5: Verify output (run verify_output.py)
```
````

S1 explicitly notes this works for non-code skills too, giving a "Research synthesis workflow" checklist as Example 1. Closing line: "Clear steps prevent Claude from skipping critical validation."

### 5.2 The feedback loop / gate script pattern (established)

S1, *Implement feedback loops*:

> "**Common pattern:** Run validator → fix errors → repeat. This pattern greatly improves output quality."

Code version, verbatim:
```markdown
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python ooxml/scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues in the XML
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild: `python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. Test the output document
```

Prose version (no scripts required) — "The 'validator' is STYLE_GUIDE.md, and Claude performs the check by reading and comparing":
```markdown
## Content review process
1. Draft your content following the guidelines in STYLE_GUIDE.md
2. Review against the checklist: ...
3. If issues found: note each issue with specific section reference; revise; review again
4. Only proceed when all requirements are met
```

**Real shipped example** — `docx/SKILL.md` (S3) implements the code version twice:
```bash
python scripts/office/validate.py out.docx --original doc.docx   # XSD checks; --auto-repair fixes common issues
```
and a **visual** gate under `## Verify the output`:
```bash
python scripts/office/soffice.py --headless --convert-to pdf output.docx
pdftoppm -jpeg -r 100 output.pdf page
ls page-*.jpg   # then Read the images
```
S1 names this last one separately as **Use visual analysis**: "When inputs can be rendered as images, have Claude analyze them… Claude's vision capabilities help analyze layouts and structures."

### 5.3 The plan-validate-execute pattern (established)

S1, *Create verifiable intermediate outputs*:

> "When Claude performs complex, open-ended tasks, it can make mistakes. The 'plan-validate-execute' pattern catches errors early by having Claude first create a plan in a structured format, then validate that plan with a script before executing it."
>
> Workflow: `analyze → **create plan file** → **validate plan** → execute → verify`
>
> "**When to use:** Batch operations, destructive changes, complex validation rules, high-stakes operations."

Stated benefits: catches errors early; machine-verifiable; reversible planning ("Claude can iterate on the plan without touching originals"); clear debugging.

### 5.4 Verification of the *skill itself* (as opposed to its output)

Three real, runnable mechanisms exist on this machine today:

**(a) `quick_validate.py`** — schema gate. From S5, the authoritative allowed-key list:
```python
ALLOWED_PROPERTIES = {'name', 'description', 'license', 'allowed-tools', 'metadata', 'compatibility'}
```
It enforces: SKILL.md exists; frontmatter parses as a YAML dict; no unexpected keys; `name` and `description` present; `name` matches `^[a-z0-9-]+$`, no leading/trailing hyphen, no `--`, ≤64 chars; `description` contains no `<` or `>`, ≤1024 chars; `compatibility` ≤500 chars.
Run: `python quick_validate.py <skill_directory>`

**(b) `claude plugin validate <path>`** — verified present on v2.1.220 (S8). Has a `--strict` flag: "Treat warnings as errors (exit 1). Use in CI to fail on unrecognized fields, missing metadata, and other issues that the runtime tolerates." **Use `--strict` in CI for a large skill set.**

**(c) `claude plugin eval [target]`** — a full eval harness shipped in the CLI (S8). Its help text:
> "Run eval cases (`evals/**/case.yaml` or `evals/**/prompt.md` + `graders/*.md`) against a plugin and report scored results."

Notable flags: `--ablation <none|with-without>` (runs a no-plugin baseline arm and reports the score delta; defaults to `with-without` when targeting a plugin by name), `--runs <n>` (default `case.runs ?? 3`), `--judge-model` (default `haiku`), `--report <path>` for self-contained HTML, `--max-cost-usd`.

**(d) skill-creator's own loop** (S4) — the most thorough. Its measurement design, which is worth internalizing:
- **Always run a baseline arm.** "For each test case, spawn two subagents in the same turn — one with the skill, one without. This is important: don't spawn the with-skill runs first and then come back for baselines later."
- **Grade programmatically where possible.** "For assertions that can be checked programmatically, write and run a script rather than eyeballing it."
- **Watch for non-discriminating assertions** — S4 directs an analyst pass looking for "assertions that always pass regardless of skill (non-discriminating), high-variance evals (possibly flaky), and time/token tradeoffs." An assertion that passes without the skill measures nothing.
- **Measure cost, not just quality.** The benchmark records "pass_rate, time, and tokens for each configuration, with mean ± stddev and the delta."
- **Don't force assertions on subjective work.** "Skills with objectively verifiable outputs (file transforms, data extraction, code generation, fixed workflow steps) benefit from test cases. Skills with subjective outputs (writing style, art) often don't need them."

S2 gives the minimum viable version for people who won't build a harness:
> "Collect a few realistic prompts, run each one in a fresh session with the skill available and again with it disabled, and compare the results. **A fresh session matters because leftover context from authoring the skill will mask gaps in the written instructions.**"

**(e) Description triggering, measured separately.** S4 §*Description Optimization* + `scripts/run_eval.py` / `run_loop.py` (S5). Mechanism verified from source: `run_eval.py` "Creates a command file in `.claude/commands/` so it appears in Claude's available_skills list, then runs `claude -p` with the raw query. Uses `--include-partial-messages` to detect triggering early." The loop:
- 20 eval queries: 8–10 should-trigger, 8–10 should-not-trigger
- 60% train / 40% held-out test split; each query run 3× for a reliable trigger rate; up to 5 iterations
- `best_description` is "selected by test score rather than train score to avoid overfitting"

S4's guidance on writing those queries is the valuable part:
> "The key thing to avoid: don't make should-not-trigger queries obviously irrelevant. 'Write a fibonacci function' as a negative test for a PDF skill is too easy — it doesn't test anything. **The negative cases should be genuinely tricky.**"
>
> Bad: `"Format this data"`, `"Extract text from PDF"`, `"Create a chart"`
> Good: `"ok so my boss just sent me this xlsx file (its in my downloads, called something like 'Q4 sales final FINAL v2.xlsx') and she wants me to add a column that shows the profit margin as a percentage. The revenue is in column C and costs are in column D i think"`

Realistic means: file paths, job context, column names, company names, URLs, "a little bit of backstory", lowercase, typos, casual speech, mixed lengths.

### 5.5 S1's shipped checklist (reproduce as-is for your own QA gate)

> **Core quality**
> - [ ] Description is specific and includes key terms
> - [ ] Description includes both what the Skill does and when to use it
> - [ ] SKILL.md body is under 500 lines
> - [ ] Additional details are in separate files (if needed)
> - [ ] No time-sensitive information (or in "old patterns" section)
> - [ ] Consistent terminology throughout
> - [ ] Examples are concrete, not abstract
> - [ ] File references are one level deep
> - [ ] Progressive disclosure used appropriately
> - [ ] Workflows have clear steps
>
> **Code and scripts**
> - [ ] Scripts solve problems rather than defer to Claude
> - [ ] Error handling is explicit and helpful
> - [ ] No "voodoo constants" (all values justified)
> - [ ] Required packages listed in instructions and verified as available
> - [ ] Scripts have clear documentation
> - [ ] No Windows-style paths (all forward slashes)
> - [ ] Validation/verification steps for critical operations
> - [ ] Feedback loops included for quality-critical tasks
>
> **Testing**
> - [ ] At least three evaluations created
> - [ ] Tested with Haiku, Sonnet, and Opus
> - [ ] Tested with real usage scenarios
> - [ ] Team feedback incorporated (if applicable)

### 5.6 Evaluation-driven development (build evals *first*)

S1, *Build evaluations first*:

> "**Create evaluations BEFORE writing extensive documentation.** This ensures your Skill solves real problems rather than documenting imagined ones."
>
> 1. **Identify gaps:** Run Claude on representative tasks **without** a Skill. Document specific failures or missing context
> 2. **Create evaluations:** Build three scenarios that test these gaps
> 3. **Establish baseline:** Measure Claude's performance without the Skill
> 4. **Write minimal instructions:** Create just enough content to address the gaps and pass evaluations
> 5. **Iterate:** Execute evaluations, compare against baseline, and refine

Eval file shape S1 gives:
```json
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```
S1 caveats this format: "There is not currently a built-in way to run these evaluations. Users can create their own evaluation system." (Note that this is now partly stale for Claude Code specifically, given `claude plugin eval` exists at v2.1.220 with its own `evals/**/case.yaml` format — **the two formats are different and should not be confused.**)

skill-creator's own format (S4), which `claude plugin eval` does *not* consume:
```json
{
  "skill_name": "example-skill",
  "evals": [
    {"id": 1, "prompt": "User's task prompt", "expected_output": "Description of expected result", "files": []}
  ]
}
```

---

## 6. Common failure modes and their documented fixes

### 6.1 Skill never triggers

**Documented fixes (S2, *Skill not triggering*):**
1. "Check the description includes keywords users would naturally say"
2. "Verify the skill appears in `What skills are available?`"
3. "Try rephrasing your request to match the description more closely"
4. "Invoke it directly with `/skill-name` if the skill is user-invocable"

Plus a silent-failure trap worth designing against:
> "If the frontmatter YAML is malformed, Claude Code loads the skill body **with empty metadata**, so `/skill-name` still works but Claude has no `description` to match against. Run with `--debug` to see the parse error."

That is vicious: manual invocation keeps working, so the skill looks fine, while auto-triggering is dead. **A CI `claude plugin validate --strict` pass catches it.**

Additional causes:
- **Undertriggering is the model's baseline tendency** (S4). Fix: make descriptions pushy (§1.3).
- **Task too simple to warrant a skill** (S4): "simple, one-step queries … may not trigger a skill even if the description matches perfectly." Not fixable by description tuning.
- **Description silently truncated** because the listing overflowed (§1.1). Fix: `/doctor`, `skillListingBudgetFraction`, `skillOverrides: name-only` on low-priority skills, or shorten the description at source.
- **Skill not discovered at all** in nested dirs (S2): "Skills in nested `.claude/skills/` directories below your starting directory aren't loaded at startup. They load the first time Claude reads or edits a file inside that subdirectory."

### 6.2 Skill triggers too often

**Documented fixes (S2, *Skill triggers too often*):**
1. "Make the description more specific"
2. "Add `disable-model-invocation: true` if you only want manual invocation"

Additional verified levers:
- `paths` frontmatter (S2): "Glob patterns that limit when this skill is activated. When set, Claude loads the skill automatically only when working with files matching the patterns." **This is the precision instrument for over-triggering in a codebase skill set.**
- `user-invocable: false` (S2) to hide from the `/` menu — for background knowledge users shouldn't invoke.
- Explicit negative scoping in the description (the `docx` "Do NOT use for…" pattern, §1.4).
- Run the trigger-eval loop with genuinely tricky negatives (§5.4e) — false-trigger rate is exactly what `run_eval.py` measures.

### 6.3 Skills conflict with each other

Documented mechanics (S2, *Where skills live*):
- Precedence: **enterprise > personal > project**; any of these overrides a bundled skill of the same name. "For example, a `code-review` skill in your project's `.claude/skills/` replaces the bundled `/code-review`."
- **Plugin skills cannot conflict** — they use a `plugin-name:skill-name` namespace.
- Nested same-name skills **both stay available**, disambiguated as `apps/web:deploy`; "Claude picks the variant that matches the files it is working on." Requires **v2.1.203+** for the auto-append behavior on unqualified invocation.
- Skill beats command when a `.claude/commands/` file and a skill share a name.
- `skillOverrides` in settings (four states: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"`) turns down or hides skills you don't own. Written by `/skills` (Space to cycle, Enter to save to `.claude/settings.local.json`). **Does not affect plugin skills** — manage those via `/plugin`.

For *semantic* conflict (two skills both plausibly matching a request), there is **no official mechanism**. The observed practice is negative scoping in descriptions (§1.4) plus S4's instruction to include, in trigger evals, "cases where this skill competes with another but should win."

### 6.4 Skills bloat context

- **Recurring cost, not one-time** (S2): "Once a skill loads, its content stays in context across turns, so every line is a recurring token cost." "Claude Code does not re-read the skill file on later turns, so **write guidance that should apply throughout a task as standing instructions rather than one-time steps.**"
- **Re-invocation is deduplicated as of v2.1.202** (S2): identical rendered content produces "a short note that the skill is already loaded rather than a second copy". "Before v2.1.202, every re-invocation appended another full copy."
- **Compaction budgets** (S2): after auto-compaction, Claude Code re-attaches the most recent invocation of each skill, "keeping the **first 5,000 tokens** of each. Re-attached skills share a combined budget of **25,000 tokens**." Filled most-recent-first, "so older skills can be dropped entirely after compaction if you have invoked many in one session." → **Front-load the most important content in the first 5,000 tokens of every SKILL.md.**
- **Fixes:** progressive disclosure (§2.4); black-box scripts (§3.3); `claude plugin details <name>` for projected token cost; `/context` Skills row.

### 6.5 Skill "stops working" mid-session

S2, *Skill content lifecycle* — a failure mode that is usually misdiagnosed:
> "If a skill seems to stop influencing behavior after the first response, **the content is usually still present and the model is choosing other tools or approaches.** Strengthen the skill's `description` and instructions so the model keeps preferring it, or use **hooks** to enforce behavior deterministically. If the skill is large or you invoked several others after it, re-invoke it after compaction to restore the full content."

The escalation ladder is: prose → stronger prose → **hooks** (deterministic enforcement). A `hooks` frontmatter field exists on skills (S2) for lifecycle-scoped hooks.

### 6.6 Overfitting to your own test cases

S4, *How to think about improvements*, item 1 — the failure mode nobody warns about:
> "we're trying to create skills that can be used a million times … Here you and the user are iterating on only a few examples over and over again because it helps move faster. … **But if the skill you and the user are codeveloping works only for those examples, it's useless.** Rather than put in fiddly overfitty changes, or oppressively constrictive MUSTs, if there's some stubborn issue, you might try branching out and using different metaphors, or recommending different patterns of working."

And item 2: "**Keep the prompt lean.** Remove things that aren't pulling their weight. Make sure to **read the transcripts, not just the final outputs** — if it looks like the skill is making the model waste a bunch of time doing things that are unproductive, you can try getting rid of the parts of the skill that are making it do that and seeing what happens."

### 6.7 Model-dependence

S1, *Test with all models you plan to use*:
> "**Claude Haiku** (fast, economical): Does the Skill provide enough guidance? **Claude Sonnet** (balanced): Is the Skill clear and efficient? **Claude Opus** (powerful reasoning): Does the Skill avoid over-explaining? What works perfectly for Opus might need more detail for Haiku."

Note `claude plugin eval` defaults its judge to haiku (S8) and `run_loop.py` (S4) is told to use "the model ID from your system prompt (the one powering the current session) so the triggering test matches what the user actually experiences."

---

## 7. Writing skills for a SPECIFIC codebase vs general-purpose

Anthropic has published **less here than elsewhere**, but the guidance that exists is concrete.

### 7.1 When a codebase skill is the right container

S2's opening, which is the clearest statement of the boundary against CLAUDE.md:

> "Create a skill when you keep pasting the same instructions, checklist, or multi-step procedure into chat, or **when a section of CLAUDE.md has grown into a procedure rather than a fact.** Unlike CLAUDE.md content, **a skill's body loads only when it's used**, so long reference material costs almost nothing until you need it."

**Facts → CLAUDE.md. Procedures → skills.** That is the split.

S2's content taxonomy sharpens it further:
- **Reference content** — "Conventions, patterns, style guides, domain knowledge. This content runs inline so Claude can use it alongside your conversation context." (Its own example is literally `name: api-conventions`, `description: API design patterns for this codebase`.)
- **Task content** — "step-by-step instructions for a specific action, like deployments, commits, or code generation. These are often actions you want to invoke directly with `/skill-name` rather than letting Claude decide when to run them. Add `disable-model-invocation: true`."

**For an app-specific skill set: convention skills should be model-invocable; action skills (migrate, deploy, scaffold, release) should carry `disable-model-invocation: true`.** S2's rationale: "You don't want Claude deciding to deploy because your code looks ready."

### 7.2 Codebase-specific content is explicitly in scope

S1 (S6 echoes it) names company/codebase knowledge as a first-class skill purpose — the running example throughout S1 is a BigQuery skill containing "table names, field definitions, filtering rules (such as 'always exclude test accounts'), and common query patterns." S6 lists "Domain expertise - Company-specific knowledge, schemas, business logic."

The origin story S1 prescribes for such a skill:
> "1. **Complete a task without a Skill:** Work through a problem with Claude A using normal prompting. As you work, you'll naturally provide context, explain preferences, and share procedural knowledge. **Notice what information you repeatedly provide.** 2. **Identify the reusable pattern** … 3. **Ask Claude A to create a Skill**"

And the conciseness pass, quoted because it's the exact editorial move: "Check that Claude A hasn't added unnecessary explanations. Ask: **'Remove the explanation about what win rate means - Claude already knows that.'**"

### 7.3 Claude Code mechanisms specific to codebase skills

| Need | Mechanism | Source / version |
|---|---|---|
| Ship with the repo | `.claude/skills/<name>/SKILL.md`, committed | S2 |
| Scope a skill to part of the tree | `paths:` frontmatter — globs; "Claude loads the skill automatically only when working with files matching the patterns" | S2 |
| Monorepo per-package skills | Nested `.claude/skills/` — "This lets a monorepo package provide its own skills that apply when working on that package, even if the session started at the repo root." Loads lazily on first read/edit in that subdir. | S2 |
| Same name at two levels | Auto-qualified as `apps/web:deploy`; unqualified invoke appends variant list | S2, v2.1.203+ |
| Iterate without restart | Live change detection watches `~/.claude/skills/`, project `.claude/skills/`, and `--add-dir` skills dirs. **SKILL.md text only** — `hooks/`, `.mcp.json`, `agents/`, `output-styles/` need `/reload-plugins`. | S2 |
| Run project scripts from a skill | `${CLAUDE_PROJECT_DIR}` substitution | S2, v2.1.196+ |
| Distribute across many repos | Plugin with a `skills/` directory; or `claude plugin init <name>` which scaffolds at `~/.claude/skills/<name>/` and auto-loads as `<name>@skills-dir` | S2, S8 |

**Security note that applies specifically to committed project skills (S2):** "For skills checked into a project's `.claude/skills/` directory, `allowed-tools` takes effect after you accept the workspace trust dialog for that folder… **Review project skills before trusting a repository, since a skill can grant itself broad tool access.**"

### 7.4 Where there is genuinely **no official guidance**

Say so rather than inventing:

- **No official guidance** on how many skills is too many for one project, or on how to decompose a domain into N skills. The only related fact is the 1%-of-context listing budget (§1.1), which is a mechanical constraint, not advice.
- **No official guidance** on a naming taxonomy for a large intra-project skill set (prefixes, namespacing conventions). S1 offers only the general naming advice below.
- **No official guidance** on versioning skills alongside a codebase. `version:` is **not** in `quick_validate.py`'s allowed keys and **not** in S2's frontmatter table; only S6 uses it. Treat `version:` in SKILL.md frontmatter as **unsupported**.
- **No official guidance** on cross-skill composition (one skill instructing Claude to invoke another). Not documented in S1 or S2.
- **No evidence found** for any recommended `index` or `router` skill pattern, despite the user's own `flutter-conventions-index` skill implying one. Not an Anthropic pattern as far as these sources show.

For naming, S1 does give a rule (*Naming conventions*):
> "Consider using **gerund form** (verb + -ing) … `processing-pdfs`, `analyzing-spreadsheets`, `managing-databases`, `testing-code`, `writing-documentation`. **Acceptable alternatives:** Noun phrases: `pdf-processing`, `spreadsheet-analysis`; Action-oriented: `process-pdfs`, `analyze-spreadsheets`. **Avoid:** Vague names: `helper`, `utils`, `tools`; Overly generic: `documents`, `data`, `files`; Reserved words: `anthropic-helper`, `claude-tools`; Inconsistent patterns within your skill collection."

Note Anthropic's own 17 skills mostly use **noun phrases**, not gerunds (`docx`, `pdf`, `mcp-builder`, `webapp-testing`, `brand-guidelines`). The gerund advice is aspirational; the enforced rules are: lowercase/digits/hyphens, ≤64 chars, no `anthropic`/`claude`.

---

## 8. Verified frontmatter reference (the thing you must not get wrong)

**Two different field sets exist. Do not mix them without knowing which surface you target.**

### 8.1 Portable / spec set — enforced by `quick_validate.py` (S5)
```python
ALLOWED_PROPERTIES = {'name', 'description', 'license', 'allowed-tools', 'metadata', 'compatibility'}
```
Required: `name`, `description`. Constraints: `name` ≤64 chars matching `^[a-z0-9-]+$` (no leading/trailing hyphen, no `--`); `description` ≤1024 chars, no `<` or `>`; `compatibility` ≤500 chars.
S1 adds: `name` cannot contain reserved words "anthropic", "claude".

**Anthropic's own 17 skills use only three keys: `name` (17), `description` (17), `license` (15).** Zero use of `version`, `when_to_use`, `allowed-tools`, `metadata`, or `compatibility`. That is the strongest available signal about what a portable skill should contain.

### 8.2 Claude Code superset — S2 frontmatter table, v2.1.220

All optional; only `description` recommended. Booleans accept `yes/no/on/off/1/0` in any case as of **v2.1.218** (before that, only `true`/`false`).

| Field | Purpose |
|---|---|
| `name` | Display name; defaults to directory name. In a **plugin** skill it sets the last command segment; in personal/project skills it's label-only and the **directory name** still determines `/command`. |
| `description` | What + when. If omitted, uses the first paragraph of markdown. Combined with `when_to_use`, truncated at **1,536 chars** in the listing. |
| `when_to_use` | Extra trigger phrases / example requests. Appended to `description`; counts toward the 1,536 cap. |
| `argument-hint` | Autocomplete hint, e.g. `[issue-number]`. |
| `arguments` | Named positional args for `$name` substitution. |
| `disable-model-invocation` | `true` = manual `/name` only. Also blocks preloading into subagents; as of **v2.1.196** also blocks scheduled-task firing. |
| `user-invocable` | `false` = hide from `/` menu. |
| `allowed-tools` | Pre-approved tools **for the invoking turn only**; grant clears on your next message. |
| `disallowed-tools` | Tools removed from the pool while active; clears on next message. Cannot remove `EndConversation` while other tools remain. |
| `model` | Model override for the rest of the current turn; not saved to settings. Accepts `/model` values or `inherit`. |
| `effort` | `low`/`medium`/`high`/`xhigh`/`max`; overrides session effort. |
| `context` | `fork` = run in a forked subagent context. |
| `agent` | Which subagent type, when `context: fork`. |
| `background` | Only with `context: fork`; `false` = wait for result in the invoking turn. Default `true`. Requires **v2.1.218+**. |
| `hooks` | Hooks scoped to this skill's lifecycle. |
| `paths` | Globs limiting automatic activation to matching files. |
| `shell` | `bash` (default) or `powershell` for inline `` !`command` ``. |

**Substitutions** (S2): `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `$name`, `${CLAUDE_SESSION_ID}`, `${CLAUDE_EFFORT}`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`.

**Shared-team-memory skills are a restricted subset** — verified from strings in the v2.1.220 binary:
> "When a shared memory skill loads, capability frontmatter (`allowed-tools`, `hooks`, `model`, `shell`) is ignored, inline shell (`!` commands) does not run, symlinked files are not loaded, and a `SKILL.md` over **128KB** is skipped."

---

## 9. Operational summary — what "rich" means in practice

Distilled, each item traceable to a source above:

1. **The description is a retrieval index, not a summary.** `<capabilities>. Use when <triggers>.` Third person. Pushy. Literal user phrases. Negative scope (`Do NOT use for…`) when siblings exist. Target 200–450 chars for ordinary skills; up to ~850 for a broad, heavily-triggered one. Hard cap 1,024. (§1)
2. **Aim for 100–250 lines of SKILL.md, not 500.** 500 is the ceiling three sources agree on; Anthropic's own median is 129. (§2.3)
3. **Only write the delta over the model's prior.** `docx`: "The model knows the API; these are the footguns." If Claude already knows it, deleting it is a strict improvement. (§2.1, §3.3)
4. **Open with a decision table or decision tree.** Close with `## Dependencies` and `## Reference Files`. (§3.2)
5. **References exactly one level deep from SKILL.md, never nested.** ToC on anything over 100 lines. No duplication between SKILL.md and references. (§2.5)
6. **Match freedom to fragility.** Narrow bridge → exact command, "do not add flags". Open field → heuristics. (§3.5)
7. **Bundle a script when three transcripts show the model rewriting the same code.** Then say explicitly whether to *run* it or *read* it — and if it's big, forbid reading it. (§4.2, §4.3, §3.3)
8. **Every skill that produces an artifact gets a verification gate:** a checklist to copy, a validator to loop on, or a render-and-look step. "Only proceed when validation passes." (§5.1–5.3)
9. **Prose "why" belongs in parentheses, not paragraphs.** `never SOLID (renders black)`. Reserve all-caps absolutes for unrecoverable mistakes — Anthropic uses "non-negotiable" 3 times in 17 skills and never as a heading. (§3.1, §3.4)
10. **Front-load: the first 5,000 tokens of SKILL.md are what survives compaction.** Write standing instructions, not one-time steps, because the file is never re-read. (§6.4)
11. **Scope aggressively for a codebase set:** `paths:` globs on convention skills, `disable-model-invocation: true` on anything with side effects, nested `.claude/skills/` per package. Facts → CLAUDE.md; procedures → skills. (§7)
12. **Verify mechanically before shipping:** `claude plugin validate --strict` in CI (catches the malformed-YAML-empty-metadata trap), `claude plugin details` for token cost, `/doctor` + `/context` for listing budget, `claude plugin eval --ablation with-without` or skill-creator's loop for actual value-over-baseline. **Always run a no-skill baseline arm** — an assertion that passes without the skill measures nothing. (§5.4)

---

## Appendix: honest gaps

- **agentskills.io not fetched.** The normative spec now lives there (`anthropics/skills/spec/` is a one-line pointer). Everything here about hard limits comes from S1 (Anthropic docs) and `quick_validate.py` (Anthropic code), which agree with each other, but I did not read the spec itself.
- **`anthropic.com/news/skills` not checked.** No evidence gathered either way.
- **The `claude plugin eval` case format (`evals/**/case.yaml`, `graders/*.md`) was read only from `--help` output.** I did not locate documentation or an example case file, so field names inside `case.yaml` beyond `runs`, `scaffold_script`, `max_turns`, `timeout_seconds` (all inferred from flag help text) are **unverified**.
- **`metadata` frontmatter key**: allowed by `quick_validate.py` but I found no documentation of its shape or purpose, and no Anthropic skill uses it. **Unverified.**
- **S6 (`plugin-dev`) conflicts with S1/S2** on `when_to_use` and `version`. I have treated S1/S2 as authoritative. The 1,500–2,000 word target and the "third person 'This skill should be used when…'" description formula come from S6 only and are **not** corroborated by S1, S2, or Anthropic's own skills — none of the 17 uses that formula.
