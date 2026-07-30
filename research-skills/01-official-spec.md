# The Official Agent Skills Specification

Research date: **2026-07-30**. Local Claude Code version: **2.1.220**
(binary: `/Users/zakariafatahi/.local/share/claude/versions/2.1.220`, a compiled Mach-O arm64 executable, 245 MB).

## 0. The single most important structural fact

There are **two overlapping specs**, and conflating them is the main way skills silently break:

| Layer | Source | Scope |
| :--- | :--- | :--- |
| **Open Agent Skills spec** | <https://agentskills.io/specification> | Portable across AI tools. 6 fields only. `name` + `description` **required**. |
| **Claude Code extensions** | <https://code.claude.com/docs/en/skills> | Claude Code only. ~17 fields. **All optional**; `description` merely "recommended". |

`docs.claude.com/en/docs/claude-code/skills` **301-redirects** to `code.claude.com/docs/en/skills`
(verified 2026-07-30). The path `platform.claude.com/docs/en/agents-and-tools/agent-skills` returns **404**.
`anthropics/skills` `spec/agent-skills-spec.md` is a 3-line stub that just points at agentskills.io.

**Consequence:** a field that is legal in Claude Code (`when_to_use`, `context`, `model`) is *rejected*
by Anthropic's own portable validator, and a field legal in the open spec (`metadata`, `license`) is
absent from Claude Code's table but tolerated at runtime. Decide which target you are writing for.

---

## 1. The exact set of valid SKILL.md frontmatter fields

### 1a. Open Agent Skills spec — the complete allowlist (6 fields)

Source: <https://agentskills.io/specification>

| Field | Required | Constraints (verbatim) |
| :--- | :--- | :--- |
| `name` | **Yes** | Max 64 characters. Lowercase letters, numbers, and hyphens only. Must not start or end with a hyphen. |
| `description` | **Yes** | Max 1024 characters. Non-empty. Describes what the skill does and when to use it. |
| `license` | No | License name or reference to a bundled license file. |
| `compatibility` | No | Max 500 characters. Indicates environment requirements. |
| `metadata` | No | Arbitrary key-value mapping for additional metadata. |
| `allowed-tools` | No | Space-separated string of pre-approved tools. **(Experimental)** |

Corroborated independently by Anthropic's own validator
`skills/skill-creator/scripts/quick_validate.py` in `anthropics/skills`, which hardcodes:

```python
ALLOWED_PROPERTIES = {'name', 'description', 'license', 'allowed-tools', 'metadata', 'compatibility'}
```

### 1b. Claude Code frontmatter reference — all optional

Source: <https://code.claude.com/docs/en/skills> §"Frontmatter reference".
Verbatim: *"All fields are optional. Only `description` is recommended so Claude knows when to use the skill."*

| Field | Purpose |
| :--- | :--- |
| `name` | Display name in listings. Defaults to directory name. **Does not set the command name** for personal/project skills. |
| `description` | What it does + when to use it. Falls back to first paragraph of body if omitted. |
| `when_to_use` | Extra trigger phrases; appended to `description` in the listing. |
| `argument-hint` | Autocomplete placeholder, e.g. `[issue-number]`. |
| `arguments` | Named positional args for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | `true` = only the user can invoke. Default `false`. |
| `user-invocable` | `false` = hide from `/` menu; only the model can invoke. Default `true`. |
| `allowed-tools` | Tools pre-approved **for the invoking turn only**. String (space/comma) or YAML list. |
| `disallowed-tools` | Tools removed from the pool while active. Cleared on next user message. |
| `model` | Model override for the rest of the turn. Accepts `/model` values or `inherit`. |
| `effort` | `low`, `medium`, `high`, `xhigh`, `max`. |
| `context` | `inline` (default) or `fork` (runs in a subagent). |
| `agent` | Subagent type when `context: fork`. Default `general-purpose`. |
| `background` | Only with `context: fork`. `false` = block the turn. Default `true`. **Requires v2.1.218+.** |
| `hooks` | Hooks scoped to this skill's lifecycle; same shape as settings.json `hooks`. |
| `paths` | Glob patterns limiting auto-activation. |
| `shell` | `bash` (default) or `powershell` for `` !`cmd` `` blocks. |

Boolean fields accept `yes/no/on/off/1/0` in any case as well as `true/false` — **v2.1.218+ only**;
earlier versions recognized only `true`/`false`.

### 1c. Verdict on each field you asked about

| Field | Verdict | Evidence |
| :--- | :--- | :--- |
| `name` | **VERIFIED** | Both specs. Required in open spec, optional in Claude Code. |
| `description` | **VERIFIED** | Both specs. Required in open spec, "recommended" in Claude Code. |
| `allowed-tools` | **VERIFIED** | Both specs. Also a literal string in the 2.1.220 binary. |
| `license` | **VERIFIED** | Open spec. Used by real Anthropic skills (`skills/pdf`, `skills/mcp-builder`). Absent from Claude Code's table but tolerated. |
| `metadata` | **VERIFIED** | Open spec (map of string→string). Absent from Claude Code's table; accepted by local validator without warning. |
| `version` | **REFUTED as a top-level field.** | Not in the open spec allowlist; `quick_validate.py` rejects it as an unexpected key; not in Claude Code's frontmatter table. It appears in a *merged* schema-name blob in the binary alongside plugin.json keys, which is not evidence of skill support. **Use `metadata: {version: "1.0"}` instead** — that is the form the official spec example uses. |
| `when_to_use` | **VERIFIED for Claude Code only.** | In Claude Code's table and in the binary's schema descriptions. **Rejected by `quick_validate.py`** — not portable. |
| `disable-model-invocation` | **VERIFIED** | Claude Code table + literal string in the binary. |
| `model` | **VERIFIED for Claude Code only.** | Claude Code table + binary. Not in the open spec. |
| `context` | **VERIFIED for Claude Code only.** | Values `inline` \| `fork`, both literal strings in the binary. Not in the open spec. |

Two further field names, `created_by` and `improved_by`, appear in the binary's schema-name blob
adjacent to skill fields. They are **not documented anywhere** and carry no description string.
Treat as **unverified / internal — do not use.**

### 1d. What happens to an unknown field

Claude Code **silently ignores** unrecognized SKILL.md frontmatter keys. Empirically confirmed:
a skill carrying `bogus-field`, `version`, `when_to_use`, `license`, `metadata` and `compatibility`
produced **zero warnings** from `claude plugin validate`, even under `--strict`.
(Contrast with `plugin.json`, where unknown fields *do* warn — see §8.)

If the YAML fails to parse, Claude Code **loads the body with empty metadata** — the skill still
appears as `/name` but has no description to match on, so the model will never auto-invoke it.
Run with `--debug` to see the parse error.

---

## 2. Constraints on `name` and `description`

### `name`

Open spec (<https://agentskills.io/specification>), corroborated by `quick_validate.py`:

* Must be **1–64 characters**
* Only unicode lowercase alphanumerics (`a-z`, `0-9`) and hyphens (`-`)
* Must **not** start or end with a hyphen
* Must **not** contain consecutive hyphens (`--`)
* **Must match the parent directory name**

Claude Code does **not enforce any of this**. Empirically, `name: UPPERCASE`,
`name: dbl--hyphen`, and `name: totally-different-name` in a directory called `mismatch`
all passed `claude plugin validate --strict` with no warning. Anthropic's `quick_validate.py`
rejected all three. **Portability, not Claude Code, is what forces the rules.**

**How the command name is actually derived** (<https://code.claude.com/docs/en/skills> §"How a skill gets its command name"):

| Layout | Command name comes from |
| :--- | :--- |
| `~/.claude/skills/X/SKILL.md` or `.claude/skills/X/SKILL.md` | **Directory name.** Frontmatter `name` is only a display label. |
| Nested `.claude/skills/` with a clash | Subdirectory path + dir name → `/apps/web:deploy` |
| `.claude/commands/deploy.md` | File name without extension |
| `<plugin>/skills/X/SKILL.md` | Frontmatter `name` **or** dir name, namespaced → `/my-plugin:X` |
| `<plugin>/SKILL.md` (plugin root) | Frontmatter `name`, falling back to plugin dir name |

So for personal/project skills, **renaming the directory renames the command**; editing `name` does not.
For plugin skills, `name` *does* set the last command segment (v2.1.216+ keeps the plugin prefix).

### `description`

* Open spec: **1–1024 characters**, non-empty.
* `quick_validate.py` adds: **must not contain `<` or `>`** (angle brackets).
* Claude Code listing cap: the **combined `description` + `when_to_use` text is truncated at
  1,536 characters** in the skill listing. Configurable via the `skillListingMaxDescChars` setting.
* Convention: state **what it does *and* when to use it**, key use case first, with keywords a
  user would naturally say. Real Anthropic skills are written in the third person
  (`"Extracts text and tables from PDF files… Use when…"`).

**Separate, global budget:** the whole skill listing is capped at **1% of the model's context window**
by default. When it overflows, Claude Code **drops descriptions starting with the least-invoked skills**.
Raise it with `skillListingBudgetFraction` (e.g. `0.02`) or the `SLASH_COMMAND_TOOL_CHAR_BUDGET`
env var. `/doctor` estimates the listing's cost; `/context` shows the post-budget size.
This is the real constraint when authoring *a large set* of skills: 40 skills × 1,024 chars
will overflow a 200k-token window's default budget and start silently losing descriptions.

---

## 3. Discovery locations and precedence

Source: <https://code.claude.com/docs/en/skills> §"Where skills live".

| Location | Path | Applies to |
| :--- | :--- | :--- |
| Enterprise | via managed settings | All users in the org |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where the plugin is enabled |

**Precedence on a name collision (verbatim):** *"enterprise overrides personal, and personal overrides
project."* A skill at any of these levels also **overrides a bundled skill** of the same name
(e.g. a project `code-review` replaces the bundled `/code-review`).

> **Counter-intuitive:** this is the **opposite** of the usual "more specific wins" rule. A personal
> `~/.claude/skills/foo/` **silently shadows** the project's `.claude/skills/foo/` that your team
> committed. Namespace personal skills to avoid clobbering project ones.

**Plugin skills cannot collide** — they are namespaced `plugin-name:skill-name`.

If a skill and a `.claude/commands/` file share a name, **the skill wins**.

**Other discovery rules:**

* Project skills load from `.claude/skills/` in the launch directory **and every parent up to the repo root**.
* **Nested** `.claude/skills/` below the launch dir are *not* loaded at startup. They load the first
  time Claude reads/edits a file in that subdirectory, then persist for the session.
* On a nested name clash, **both stay available**; the nested one gets a directory-qualified name
  (`apps/web:deploy`). Invoking the unqualified `/deploy` loads the root skill and appends a list of
  qualified variants. Requires **v2.1.203+**.
* `--add-dir` / `/add-dir` **do** load `.claude/skills/` from the added directory (an explicit
  exception to the "additional directories grant file access only" rule). The
  `permissions.additionalDirectories` **setting does not**.
* A skill directory may be a **symlink**; Claude Code follows it and de-duplicates if the same
  target is reachable twice.
* **Live change detection**: edits to `SKILL.md` under watched skill dirs are picked up mid-session
  without restart. A *newly created* top-level skills directory needs a restart.
* Cowork and cloud sessions **do not read `~/.claude/skills/`** — they load claude.ai account skills
  plus repo-committed `.claude/skills/`.

---

## 4. Invocation: model-invoked vs user-invoked

Both are enabled by default. You type `/skill-name`; Claude auto-loads it when the `description` matches.

| Frontmatter | You can invoke | Claude can invoke | When loaded into context |
| :--- | :--- | :--- | :--- |
| (default) | Yes | Yes | Description always in context; full skill loads when invoked |
| `disable-model-invocation: true` | Yes | **No** | **Description not in context**; full skill loads when you invoke |
| `user-invocable: false` | **No** | Yes | Description always in context; full skill loads when invoked |

### What `disable-model-invocation: true` does, exactly

1. Prevents Claude from auto-loading the skill.
2. **Removes the skill from Claude's context entirely** — the description is not listed, so it costs
   zero listing budget. This is the lever for keeping a large skill library affordable.
3. Blocks invocation through the **Skill tool** (programmatic access).
4. Prevents the skill being **preloaded into subagents**.
5. **v2.1.196+**: prevents the skill running when a *scheduled task* fires with it as the prompt.

> `user-invocable: false` only controls **menu visibility**, not Skill-tool access. To block
> programmatic invocation you need `disable-model-invocation: true`.

**Other invocation controls:**
* Permission rules: `Skill(commit)` exact, `Skill(review-pr *)` prefix. Deny `Skill` to disable all.
* `skillOverrides` in settings — 4 states, without editing the SKILL.md:
  `"on"` | `"name-only"` (name listed, no description) | `"user-invocable-only"` (hidden from Claude, still typable) | `"off"`.
  Does **not** affect plugin skills.
* **Stacking**: `/write-tests /fix-issue 123` loads both and passes `123` to each (**v2.1.199+**).
  First skill + up to 5 more; expansion stops at the first non-inline / forked skill.

---

## 5. Progressive disclosure — what is actually in context, and when

Source: <https://agentskills.io/specification> §"Progressive disclosure" and
<https://code.claude.com/docs/en/skills>.

**Only `name` + `description` are loaded at startup — for every skill. Nothing else.**

| Stage | What loads | When |
| :--- | :--- | :--- |
| 1. Metadata (~100 tokens/skill) | `name` + `description` (+ `when_to_use`) | Session start, all skills |
| 2. Instructions (<5,000 tokens recommended) | The **entire rendered SKILL.md body** | When the skill is invoked |
| 3. Resources | `references/`, `examples/`, `scripts/`, `assets/` | **Only when Claude chooses to read/run them** |

The binary confirms the design intent verbatim:
`"(dash = not in the current listing, costs nothing; full SKILL.md loads only when it runs)"`.

**The directory is never bulk-read.** Supporting files are ordinary files; Claude loads one only
when it decides to `Read` it or execute it. That is why you **must reference them explicitly** from
SKILL.md with a note on *what each contains and when to load it* — an unreferenced `reference.md`
is effectively invisible.

### Content lifecycle (Claude Code specific — important for authoring)

* On invocation the rendered SKILL.md enters the conversation as **a single message and stays for
  the rest of the session**. Every line is a **recurring** token cost.
* Claude Code **does not re-read the file on later turns**. Write standing instructions, not
  one-time steps.
* Re-invoking with **identical** rendered content appends only a short "already loaded" note
  (**v2.1.202+**); differing content (new args or new `` !`cmd` `` output) appends the full text again.
* **Auto-compaction**: the most recent invocation of each skill is re-attached after the summary,
  keeping the **first 5,000 tokens** of each, under a **combined 25,000-token budget**, filled
  most-recent-first. Older skills can be dropped entirely.
* `allowed-tools` grants are **turn-scoped** and clear on your next message, even though the
  content persists.

---

## 6. `${CLAUDE_SKILL_DIR}` — verified, but it is NOT an environment variable

**It is real, and it is a string-substitution token, not an env var.** This distinction is
load-bearing and I verified it empirically rather than trusting the docs.

**Evidence 1 — the binary.** Both `${CLAUDE_SKILL_DIR}` and the regex-escaped form
`\$\{CLAUDE_SKILL_DIR\}` are literal strings in the 2.1.220 binary, adjacent to
`"Base directory for this skill: "`. The escaped form proves it is regex-replaced in text.

**Evidence 2 — the env-var reference.** `CLAUDE_SKILL_DIR` is **not listed** in
<https://code.claude.com/docs/en/env-vars>.

**Evidence 3 — direct experiment.** I created a project skill whose body both printed the token and
ran a bundled bash script that echoed the corresponding shell variables, then ran `claude -p "/probe"`:

```
SUBST_SKILL_DIR=[/…/envtest/.claude/skills/probe]      <- substituted, absolute, correct
SUBST_PROJECT_DIR=[/…/envtest]                          <- substituted, absolute, correct
INLINE_BASH_ENV: ENV_CLAUDE_SKILL_DIR=[UNSET]           <- NOT in the script's environment
                 ENV_CLAUDE_PLUGIN_ROOT=[UNSET]
                 ENV_CLAUDE_PROJECT_DIR=[UNSET]
```

**A bundled script cannot read `$CLAUDE_SKILL_DIR` from its own environment.** You must pass the
path in as an argument from the SKILL.md text, where substitution happens.

### The available substitution tokens

| Token | Resolves to |
| :--- | :--- |
| `${CLAUDE_SKILL_DIR}` | Directory containing this `SKILL.md`. For plugin skills, the skill's **subdirectory**, not the plugin root. |
| `${CLAUDE_PROJECT_DIR}` | Project root. **Requires v2.1.196+.** |
| `${CLAUDE_SESSION_ID}` | Current session ID. |
| `${CLAUDE_EFFORT}` | `low`/`medium`/`high`/`xhigh`/`max`. |
| `$ARGUMENTS`, `$ARGUMENTS[N]`, `$N`, `$name` | Argument substitution. |

Substitution happens in exactly **two places**: the skill's **markdown content**, and **Bash rules
inside `allowed-tools`**.

### The correct, scope-portable way to reference a bundled script

This is the documented pattern, and it resolves identically at personal, project **and** plugin scope:

```yaml
---
name: render-chart
description: Render a chart from a CSV file
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/render.sh *)
---

Run `${CLAUDE_SKILL_DIR}/scripts/render.sh <csv-file>` to render the chart.
```

Using the token in **both** places makes the `allowed-tools` rule match the exact command the body
tells Claude to run, so it executes **without a permission prompt**.

* `${CLAUDE_SKILL_DIR}` substitution *inside `allowed-tools`* requires **v2.1.129+**. On older
  versions the rule stays a literal string, never matches, and the command prompts every time.
* **Do not use a bare relative path** (`scripts/render.sh`) in a Bash command — it resolves against
  the *current working directory*, not the skill directory.
* `${CLAUDE_PLUGIN_ROOT}` is a **different** token (plugin root, not skill dir) and is *not* a
  substitute — inside a plugin, `skills/foo/SKILL.md` needs `${CLAUDE_SKILL_DIR}` to reach its own
  `scripts/`. `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}` and `${CLAUDE_PROJECT_DIR}` *are*
  exported as real env vars — but only **to hook processes and MCP/LSP subprocesses**, never to a
  Bash call made from a skill body (confirmed by the experiment above).

---

## 7. Size and token limits

| Limit | Value | Status |
| :--- | :--- | :--- |
| `name` | 64 chars | **Verified** (open spec + `quick_validate.py`) |
| `description` | 1,024 chars | **Verified** (open spec + `quick_validate.py`) |
| `compatibility` | 500 chars | **Verified** (open spec + `quick_validate.py`) |
| `description` + `when_to_use` in listing | **1,536 chars**, then truncated | **Verified** (Claude Code docs; setting `skillListingMaxDescChars`) |
| Whole skill listing | **1% of context window** by default | **Verified** (`skillListingBudgetFraction`, `SLASH_COMMAND_TOOL_CHAR_BUDGET`) |
| SKILL.md body | **<5,000 tokens recommended**; **keep under 500 lines** | **Verified** — guidance, not enforced |
| Post-compaction retention | first **5,000 tokens** per skill, **25,000 tokens** combined | **Verified** (Claude Code docs) |
| Shared-team-memory SKILL.md | **over 128 KB is skipped** | **Verified** — verbatim string in the 2.1.220 binary. Applies to *shared memory skills* only. |
| Ordinary SKILL.md hard byte cap | **EXISTS, numeric value UNVERIFIED** | The binary contains `"[skills] skipping … : … bytes exceeds … byte limit"`, telemetry event `skill_load_too_large`, and `"Skipping plugin skill … : not a regular file or exceeds … byte limit"`. The threshold is a **compiled numeric constant**, not recoverable from strings. `claude plugin validate` does **not** enforce it — an 800 KB SKILL.md passed validation cleanly. |

Also verified for shared-memory skills: capability frontmatter (`allowed-tools`, `hooks`, `model`,
`shell`) is **ignored**, inline `` !`shell` `` does **not** run, and symlinked files are not loaded.

**Practical guidance:** the binding constraint in practice is not a byte cap — it is that the body
**persists in context for the whole session**. Push volume into `references/` and keep SKILL.md a
navigation layer.

---

## 8. Plugin packaging and what `--strict` really checks

### `.claude-plugin/plugin.json`

Source: <https://code.claude.com/docs/en/plugins-reference> §"Plugin manifest schema".

**The manifest is optional.** Without it, components are auto-discovered and the plugin name comes
from the directory. **If present, `name` is the only required field** (kebab-case, no spaces).

Metadata: `$schema`, `displayName` (v2.1.143+), `version`, `description`, `author{name,email,url}`,
`homepage`, `repository`, `license`, `keywords`, `defaultEnabled` (v2.1.154+).
Component paths: `skills`, `commands`, `agents`, `workflows`, `hooks`, `mcpServers`, `outputStyles`,
`lspServers`, `experimental.themes`, `experimental.monitors`, `userConfig`, `channels`, `dependencies`.

**Path behavior — `skills` is the exception:**
* `commands`, `agents`, `workflows`, `outputStyles`, `experimental.*` — **replace** the default dir.
* **`skills` — *adds* to the default.** `skills/` is always scanned; listed dirs load alongside it.
* All paths must be relative to the plugin root and **start with `./`**.
* A plugin with a root `SKILL.md`, no `skills/`, and no `skills` key auto-loads as a **single-skill
  plugin** (v2.1.142+); no `"skills": ["./"]` needed.

**Skills-directory plugins:** any folder under a skills dir containing `.claude-plugin/plugin.json`
loads as `<name>@skills-dir` next session, discovered in place with no marketplace or install step.

### `.claude-plugin/marketplace.json`

Source: <https://code.claude.com/docs/en/plugin-marketplaces> §"Marketplace schema".

**Required (top level):** `name` (kebab-case), `owner` (object), `plugins` (array).
**Required in `owner`:** `name`. (`email`, `url` optional.)
**Required per plugin entry:** `name`, `source`.
Optional entry fields include `description`, `version`, `author`, `homepage`, `repository`,
`license`, `keywords`, `category`, `tags`, `strict`, `relevance`, `defaultEnabled`, `skills`.
Optional top level: `$schema`, `description`, `version`, `metadata.pluginRoot`,
`allowCrossMarketplaceDependenciesOn`.

Note: **reserved marketplace names** (`anthropic-agent-skills`, `agent-skills`,
`claude-plugins-official`, …) are blocked and re-checked on every load.

### What `claude plugin validate --strict` actually checks — measured

`--help` (v2.1.220), verbatim:

```
--strict    Treat warnings as errors (exit 1). Use in CI to fail on
            unrecognized fields, missing metadata, and other issues that the
            runtime tolerates.
```

Empirically, on `plugin.json` it warns about:
* **Missing metadata**: `version`, `description`, `author`.
* **Unrecognized fields**, with a did-you-mean suggestion when the name is close:
  `versoin: Unknown field 'versoin' — did you mean 'version'? Claude Code ignores unrecognized fields at load time, so this field has no effect.`
* Plain mode exits **0** ("Validation passed with warnings"); `--strict` exits **1**.

On SKILL.md it checks **only two things**: that the **YAML parses**, and that a **`description` exists**.
It does **not** check name charset, name length, name/directory match, consecutive hyphens,
description length, unknown frontmatter keys, or file size (all confirmed by direct experiment).

### Real output against `/Users/zakariafatahi/50-apps-challenge/Flutter-Claude-Code-Skills`

**⚠ First, a targeting trap.** Pointing at the repo root validates **only the marketplace manifest**
and reports success, skipping every skill:

```
$ claude plugin validate .
Validating marketplace manifest: /Users/zakariafatahi/50-apps-challenge/Flutter-Claude-Code-Skills/.claude-plugin/marketplace.json

✔ Validation passed
EXIT=0
```

`--strict` on the repo root also exits **0**. You must point at `plugin.json` to validate skills:

```
$ claude plugin validate .claude-plugin/plugin.json --strict
Validating plugin manifest: /Users/zakariafatahi/50-apps-challenge/Flutter-Claude-Code-Skills/.claude-plugin/plugin.json

Validating skill: /Users/zakariafatahi/50-apps-challenge/Flutter-Claude-Code-Skills/skills/async-safety/SKILL.md

✘ Found 1 error:

  ❯ frontmatter: YAML frontmatter failed to parse: YAML Parse error: Unexpected token. At runtime this skill loads with empty metadata (all frontmatter fields silently dropped).

Validating skill: /Users/zakariafatahi/50-apps-challenge/Flutter-Claude-Code-Skills/skills/design-review-workflow/SKILL.md

✘ Found 1 error:

  ❯ frontmatter: YAML frontmatter failed to parse: YAML Parse error: Unexpected token. At runtime this skill loads with empty metadata (all frontmatter fields silently dropped).

✘ Validation failed
EXIT=1
```

(Identical output without `--strict`; these are **errors**, not warnings. 2 of 33 skills are broken.)

**Root cause — an unquoted `: ` inside a plain YAML scalar.** Both descriptions embed a colon
followed by a space, which YAML reads as a mapping separator:

* `skills/async-safety/SKILL.md` line 3, col 135 — `` …no lint catches (`onTap: () => vm.save(x)`)… ``
* `skills/design-review-workflow/SKILL.md` line 3, col 105 — `…never — on the release build: a screenshot sweep…`

PyYAML reports `mapping values are not allowed here` at those exact columns.

**Impact:** these two skills load with **empty metadata** — no description — so Claude will **never
auto-invoke them**. They remain typable as `/async-safety` and `/design-review-workflow`. This is a
silent failure with no runtime error.

**Fix:** quote the description, or avoid `: ` (colon+space). Any of these work:

```yaml
description: "Enforces … (`onTap: () => vm.save(x)`) …"     # double-quoted
description: >-                                              # folded block scalar
  Enforces … (`onTap: () => vm.save(x)`) …
```

Note a colon **not** followed by whitespace (`onTap:() =>`) is safe, but quoting is the reliable habit.

**Recommended CI gate** — Claude Code's validator alone is too permissive; pair it with the portable one:

```bash
claude plugin validate .claude-plugin/plugin.json --strict
for d in skills/*/; do python3 quick_validate.py "$d" || exit 1; done
```

---

## 9. Beyond markdown: scripts and execution

**Yes.** Verbatim from <https://code.claude.com/docs/en/skills>:
*"Skills can bundle and run scripts in any language, giving Claude capabilities beyond what's
possible in a single prompt."*

Canonical layout (open spec):

```
my-skill/
├── SKILL.md          # Required: metadata + instructions
├── scripts/          # Optional: executable code
├── references/       # Optional: documentation
├── assets/           # Optional: templates, resources
└── ...
```

* **Which tool executes them:** the ordinary **`Bash` tool**. There is no special script runner.
  The docs' own example uses `allowed-tools: Bash(python3 *)` and instructs
  `python3 ${CLAUDE_SKILL_DIR}/scripts/visualize.py .`.
* Scripts are **executed, not loaded into context** — the docs annotate
  `helper.py (utility script - executed, not loaded)`. This is the main lever for doing heavy work
  without paying tokens.
* Language support depends on the agent implementation; Python, Bash and JavaScript are the common
  options. Anthropic's own `skills/pdf` and `skills/skill-creator` ship Python under `scripts/`.
* Scripts should be self-contained or clearly document dependencies.

### Two other non-markdown mechanisms (Claude Code only)

**Dynamic context injection** — `` !`command` `` runs a shell command **before** Claude sees the
content and substitutes the output. This is **preprocessing, not something Claude executes**.

```markdown
## Current changes
!`git diff HEAD`
```

Multi-line form uses a fence opened with ` ```! `. Rules verified from the docs:
* `!` is only recognized at line start or immediately after whitespace — `` KEY=!`cmd` `` stays literal.
* Substitution runs **once**; output is not re-scanned, so a command cannot emit a placeholder.
* Disabled org-wide by `"disableSkillShellExecution": true` (replaced with
  `[shell command execution disabled by policy]`). Bundled/managed skills are exempt.

**Subagent execution** — `context: fork` turns the SKILL.md body into a subagent prompt with no
conversation history. Pair with `agent: Explore` for read-only research. Runs in the **background**
by default (v2.1.218+); `background: false` blocks the turn. A warning worth heeding: `context: fork`
only makes sense for skills with an **actionable task** — pure guidelines return nothing useful.

---

## 10. Authoring checklist for a large skill set

1. **Write for both specs**: use only `name`, `description`, `license`, `metadata`, `compatibility`,
   `allowed-tools` unless you deliberately need a Claude Code extension. Put version info in
   `metadata.version`, never a top-level `version`.
2. **`name` must equal the directory name**, kebab-case, ≤64 chars, no `--`. Claude Code won't
   enforce it; portability and `quick_validate.py` will.
3. **Always quote descriptions containing `: `, `#`, `[`, `{`, or a leading `*`/`&`/`!`.**
   This is the failure mode that already broke 2 of 33 skills in the target repo — silently.
4. **Budget the listing.** Every auto-invocable description is permanently resident. With many
   skills you *will* hit the 1%-of-context cap and lose descriptions least-used-first. Use
   `disable-model-invocation: true` for manual-only workflows to remove them from the listing
   entirely, and `skillOverrides: "name-only"` for low-priority ones.
5. **Keep SKILL.md a navigation layer** (<500 lines): it stays in context all session. Push detail
   into `references/` and explicitly say what each file holds and when to read it.
6. **Reference bundled scripts as `${CLAUDE_SKILL_DIR}/scripts/x.sh`** in *both* the body and the
   `allowed-tools` Bash rule. Never a bare relative path; never expect the script to see
   `$CLAUDE_SKILL_DIR` in its environment.
7. **Gate CI on `claude plugin validate .claude-plugin/plugin.json --strict`** — pointing at the
   repo root validates only the marketplace and passes green while skills are broken — **plus**
   `quick_validate.py` per skill for the constraints Claude Code ignores.

---

## Sources

**Primary docs**
* <https://code.claude.com/docs/en/skills> (canonical; `docs.claude.com/en/docs/claude-code/skills` 301s here)
* <https://agentskills.io/specification> (the open Agent Skills spec)
* <https://code.claude.com/docs/en/plugins-reference>
* <https://code.claude.com/docs/en/plugin-marketplaces>
* <https://code.claude.com/docs/en/env-vars> (negative evidence: `CLAUDE_SKILL_DIR` absent)

**GitHub (via authenticated `gh api`)**
* `anthropics/skills` — 17 skills + `template/SKILL.md`; `spec/agent-skills-spec.md` is a 3-line pointer stub
* `anthropics/skills/skills/skill-creator/scripts/quick_validate.py` — the authoritative portable validator
* `anthropics/skills/.claude-plugin/marketplace.json` — real-world marketplace example
* skill-creator plugin ships separately in `anthropics/claude-plugins-official`, installed via
  `/plugin install skill-creator@claude-plugins-official`

**Local machine (2026-07-30)**
* `claude` 2.1.220, compiled Mach-O arm64 binary — string extraction confirmed field names,
  `${CLAUDE_SKILL_DIR}`, `skill_load_too_large`, the 128 KB shared-memory limit
* `claude plugin validate --help` / `claude plugin --help`
* Live `claude plugin validate` runs against `/Users/zakariafatahi/50-apps-challenge/Flutter-Claude-Code-Skills`
* Controlled experiments in a scratch directory: frontmatter validation probes, `plugin.json`
  unknown-field probes, 800 KB size probe, and a `claude -p` run proving `${CLAUDE_SKILL_DIR}`
  is substituted but never exported to the environment

**Not verified**
* Numeric byte cap for ordinary SKILL.md files (compiled constant; mechanism confirmed, value unknown)
* `created_by` / `improved_by` frontmatter fields (present in the binary's schema blob, undocumented)
