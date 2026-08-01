# E06/T05 — The directional-geometry gate

| | |
|---|---|
| **Epic** | E06 — Localisation infrastructure |
| **Branch** | `epic/06-localisation` (shared) |
| **Commit** | `ci(l10n): ban physical-side geometry in app/lib with a grep gate` |
| **Depends on** | T01 (there must be an `app/lib` tree with widgets to scan) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.3 bullet 2 and the ruler exception; §15 step 1 ("the directional-padding ban"); D-8 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `i18n-rtl-l10n` | Owns `references/rtl-and-bidi.md` — the complete allow/ban table this gate encodes, plus which icons mirror and which must not, and ships `scripts/check_i18n_bans.sh` as the reference implementation |
| `ci-pipeline-and-gates` | How a grep gate is wired so it blocks a merge rather than printing into a log nobody reads |
| `catchlaw-conventions-index` | Rule 10 (do not fork a general rule) and `CONVENTIONS.md` §7's escape-hatch and empty-scan discipline, which this new script must match |
| `widget-golden-and-a11y-testing` | Why a gate and not a golden: a mirroring bug is caught by geometry and greps, and a layout golden blesses whatever shipped |
| `naming-conventions` | The script's name states what it rejects; the marker comment is one token and greppable |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `epics/DECISIONS.md` | **D-8** | The decision in full: the ban is a CI grep gate in `tools/gates/no_directional_geometry.sh` over `app/lib`, **not** a lint. No such lint exists in `package:lints`, `flutter_lints` or the analyzer's built-in set |
| `SPEC.md` | §9.3 bullet 2 | The rule itself — `EdgeInsetsDirectional` / `AlignmentDirectional` / `start`/`end` everywhere. Note it calls the mechanism a lint; D-8 corrects that and this task cites D-8, not §9.3, for the mechanism |
| `SPEC.md` | §9.3 bullet 3 | **The ruler does not mirror.** The one documented exception, arriving in E09. This gate must have a way to say so without a blanket exemption |
| `FLUTTER_GUIDE.md` | §9.2 | The measured table: `EdgeInsetsDirectional(start:40)` flips, `EdgeInsets(left:40)` never does; `EdgeInsets.all` and `symmetric(horizontal:)` are direction-neutral and fine |
| `epics/CONVENTIONS.md` | §7 | Gate scripts take an explicit target directory and exit 2 when it is missing; one documented escape hatch each; a scan over an empty tree must not report success |
| `epics/DECISIONS.md` | D-1 | Why the gate is always invoked as `… app/lib` and never with a bare default |
| `.claude/skills/i18n-rtl-l10n/references/rtl-and-bidi.md` | "The allow / ban table", "Direction is a locale consequence", "CustomPainter" | The exact pairs, the ban on a hardcoded root `Directionality`, and the sanctioned painter island |
| `.claude/skills/i18n-rtl-l10n/scripts/check_i18n_bans.sh` | check 1 | The reference regex, and its exclusion of `*.g.dart`, `*.freezed.dart` and `app_localizations*.dart` |

## What this delivers

- `tools/gates/no_directional_geometry.sh` — the gate (D-8). Takes a target directory, **exits 2** when
  it does not exist, exits 1 on any hit, exits 0 otherwise, and prints the number of Dart files it
  scanned so an empty scan is visible.
- `app/test/gates/no_directional_geometry_test.dart` — the gate's own tests, driving it over fixtures
  with `Process.runSync`.
- `app/test/gates/fixtures/` — one small Dart file per banned and per allowed construct.
- `.github/workflows/validate.yml` — one step: `tools/gates/no_directional_geometry.sh app/lib`.
- A sweep of `app/lib` to directional equivalents. At E06 the tree is small; that is the point of doing
  this now (`SPEC.md` §15 step 5).

**What the gate rejects**, from `FLUTTER_GUIDE.md` §9.2 and `rtl-and-bidi.md`:

| Rejected | Use instead |
|---|---|
| `EdgeInsets.only(left:` / `right:` | `EdgeInsetsDirectional.only(start:, end:)` |
| `EdgeInsets.fromLTRB(` | `EdgeInsetsDirectional.fromSTEB(` — or `EdgeInsets.symmetric` when the two sides are equal |
| `Alignment.centerLeft` / `centerRight` / `topLeft` / `topRight` / `bottomLeft` / `bottomRight` | `AlignmentDirectional.centerStart` / `.centerEnd` / `.topStart` / … |
| `Positioned(` with `left:` or `right:` | `PositionedDirectional(start:, end:)` |
| `TextAlign.left` / `.right` | `TextAlign.start` / `.end` |
| `BorderRadius.only(topLeft:` … | `BorderRadiusDirectional.only(topStart:, …)` |
| `Icons.arrow_back` / `Icons.arrow_forward` | `Icons.adaptive.arrow_back` / `.arrow_forward` |
| `Directionality(` | nothing — direction comes from the resolved locale |

**What it must not flag:** `EdgeInsets.all(`, `EdgeInsets.symmetric(`, `EdgeInsets.zero`, anything
already `*Directional`, and any generated file.

**The escape hatch** is a trailing `// catchlaw-directional-ok` on the single offending line. That
marker is defined by this task — it is the first repo-local gate outside `.claude/skills/`, and
`CONVENTIONS.md` §7's rule is one documented hatch per gate, not one shared token. Its first legitimate
user is E09's ruler.

## Why it is built this way

**A grep, and D-8 says why.** `SPEC.md` §9.3 says "a lint rule bans `EdgeInsets.only(left:`". No such
rule exists in `package:lints`, in `flutter_lints`, or in the analyzer's built-in set, and writing a
custom analyzer plugin to enforce one line is disproportionate. D-8 settles it and this task does not
re-argue it. The reason it matters practically: calling a grep a lint sends the next builder looking
for a rule name that was never published, and they find nothing and conclude the rule is optional.

**A repo-local gate even though the plugin ships one.** `check_i18n_bans.sh` covers check 1 with almost
the same regex, and `catchlaw-conventions-index` rule 10 forbids forking general rules. This is not a
fork of the rule — the rule stays the plugin's, and `check_i18n_bans.sh` still runs in this task's gate
list. What lands here is the *enforcement point* D-8 names, for three reasons a plugin script cannot
cover:

1. **CI must not depend on a plugin checkout.** `.github/workflows/validate.yml` runs on a clean
   ubuntu image. A required check that lives in a separately-versioned plugin is a check that can
   disappear between two green runs.
2. **The escape hatch has to exist here.** `SPEC.md` §9.3 grants exactly one exception — the ruler —
   and it is CATCHLAW's exception, not general Flutter practice. A plugin script cannot carry a
   product-specific carve-out.
3. **The empty-scan failure.** `CONVENTIONS.md` §7 records it and E01/T08 asserts it: a gate that scans
   a path with no files reports success, which is worse than no gate. This script counts and reports.

**`EdgeInsets.fromLTRB` is banned outright, and that is a choice.** When left equals right it is
direction-neutral and harmless — but a regex cannot see that, and a hatch on every symmetric
`fromLTRB` would train people to add the marker without thinking. `EdgeInsets.symmetric` expresses the
symmetric case better anyway, and `EdgeInsetsDirectional.fromSTEB` expresses the asymmetric one
correctly. Banning it costs one refactor per site and removes an entire category of judgement call.

**`Directionality(` is on the list.** `rtl-and-bidi.md` is blunt: wrapping the app root in
`Directionality(TextDirection.rtl)` to "turn on RTL" hides physical-side bugs — they *happen* to look
right — and breaks the moment an LTR island is needed. T01 asserts the behaviour by pumping `ar` and
`en`; this gate asserts the construct never appears. The ruler will carry the hatch with the comment
`SPEC.md` §9.3 already requires.

**The gate is tested, because the gate is code.** A regex that matches nothing passes silently on every
run — the same failure class as the empty scan. Sixteen fixture rows, each red for one reason, is what
makes the pass meaningful.

**Rejected: `flutter analyze` with a custom lint.** D-8. Also: an analyzer plugin is a build-time
dependency that runs in the IDE, and the one line it would enforce is not worth a plugin's failure
modes.

**Rejected: banning `left`/`right` as bare words.** It would hit `Alignment.centerLeft` and also
`RulerPainter`'s `leftEdge`, `Rect.left`, `TextDirection.ltr` and half of `dart:ui`. The ban is on the
specific constructors and constants in the table above, which is what `check_i18n_bans.sh` does too.

**Rejected: running the gate over `app/` rather than `app/lib`.** D-8 says `app/lib`. `app/test`
legitimately constructs `Directionality` — `golden-two-lanes.md` pumps RTL goldens under it, and T08
does exactly that. A gate that fought its own test harness would be turned off within a week.

## Tests first

Write the fixtures and every row before the script exists. Run them. **They must fail** — the first run
cannot even find the script. A row that passes early means the fixture does not contain what it claims.

The test resolves the script relative to the repository root. `flutter test` runs with its working
directory at the package root, which is `app/`, so the path is `../tools/gates/no_directional_geometry.sh`.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `no_directional_geometry.sh exits 2 when the target directory does not exist` | a path that is not there | exit 2 | `CONVENTIONS.md` §7 and D-1. A gate that exits 0 on a typo'd path is a gate that never ran |
| 2 | `no_directional_geometry.sh exits 1 when it scans zero Dart files` | an empty directory | exit 1 | The failure mode that makes a gate worse than no gate. E01/T08's lesson, applied to a new script |
| 3 | `no_directional_geometry.sh exits 1 for EdgeInsets.only(left:)` | fixture | exit 1 | The headline case. `FLUTTER_GUIDE.md` §9.2 measured it: `left: 40` gives `rtl.left = 40.0` — it never flips |
| 4 | `no_directional_geometry.sh exits 1 for EdgeInsets.only(right:)` | fixture | exit 1 | The half a regex anchored on `left` would miss |
| 5 | `no_directional_geometry.sh exits 1 for EdgeInsets.fromLTRB` | fixture | exit 1 | Four positional physical sides. Banned outright rather than conditionally, so nobody has to judge |
| 6 | `no_directional_geometry.sh exits 1 for Alignment.centerLeft` | fixture | exit 1 | Alignment is the second-most-common physical-side bug and is invisible in an `en` test |
| 7 | `no_directional_geometry.sh exits 1 for Alignment.topRight` | fixture | exit 1 | A regex written only for `center*` leaves four corners open |
| 8 | `no_directional_geometry.sh exits 1 for Positioned(left:)` | fixture | exit 1 | `PositionedDirectional` exists precisely because this one is easy to reach for in a `Stack` |
| 9 | `no_directional_geometry.sh exits 1 for TextAlign.right` | fixture | exit 1 | `TextAlign.right` in `ar` puts the text on the wrong edge of its own paragraph |
| 10 | `no_directional_geometry.sh exits 1 for BorderRadius.only(topLeft:)` | fixture | exit 1 | A rounded card corner that stays on the same physical side is subtle and permanent |
| 11 | `no_directional_geometry.sh exits 1 for Icons.arrow_back` | fixture | exit 1 | A back arrow pointing the wrong way in `ar` reads as "forward". `Icons.adaptive` mirrors it for free |
| 12 | `no_directional_geometry.sh exits 1 for Directionality(` | fixture | exit 1 | A hardcoded root direction makes every physical-side bug *look* correct — the reason this whole gate would otherwise pass on a broken app |
| 13 | `no_directional_geometry.sh exits 0 for EdgeInsets.symmetric(horizontal:)` | fixture | exit 0 | `FLUTTER_GUIDE.md` §9.2 names it direction-neutral. A false positive here gets the gate disabled |
| 14 | `no_directional_geometry.sh exits 0 for EdgeInsetsDirectional.only(start:)` | fixture | exit 0 | The construct the gate exists to encourage must not itself trip a sloppy regex on the substring `Insets.only(` |
| 15 | `no_directional_geometry.sh exits 0 for a banned line carrying // catchlaw-directional-ok` | fixture | exit 0 | E09's ruler needs this, and `CONVENTIONS.md` §7 requires exactly one documented hatch per gate |
| 16 | `no_directional_geometry.sh exits 0 while skipping a generated .g.dart file` | fixture with a banned line in `x.g.dart` | exit 0 | Generated files are not hand-authored; flagging them makes the gate unfixable |
| 17 | `no_directional_geometry.sh exits 0 over app/lib` | the real tree | exit 0 | The live assertion, and the reason the sweep is part of this task |
| 18 | `no_directional_geometry.sh reports the number of files it scanned` | the real tree | stdout carries a non-zero count | A human reading a green log must be able to see it scanned something |

```dart
// app/test/gates/no_directional_geometry_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// flutter test runs with cwd = the package root, which is app/.
const _gate = '../tools/gates/no_directional_geometry.sh';

ProcessResult _run(String target) => Process.runSync(_gate, <String>[target]);

void main() {
  test('no_directional_geometry.sh exits 2 when the target directory does not exist', () {
    expect(_run('test/gates/fixtures/does_not_exist').exitCode, 2);
  });

  test('no_directional_geometry.sh exits 1 when it scans zero Dart files', () {
    final empty = Directory.systemTemp.createTempSync('catchlaw_gate_');
    addTearDown(() => empty.deleteSync(recursive: true));
    expect(_run(empty.path).exitCode, 1,
        reason: 'a gate that scans nothing must not report success');
  });

  // One testWidgets-free row per banned construct; the fixture name is the case.
  for (final fixture in const <String>[
    'edge_insets_only_left',
    'edge_insets_only_right',
    'edge_insets_from_ltrb',
    'alignment_center_left',
    'alignment_top_right',
    'positioned_left',
    'text_align_right',
    'border_radius_top_left',
    'icons_arrow_back',
    'directionality',
  ]) {
    test('no_directional_geometry.sh exits 1 for $fixture', () {
      expect(_run('test/gates/fixtures/$fixture').exitCode, 1);
    });
  }

  for (final fixture in const <String>[
    'edge_insets_symmetric',
    'edge_insets_directional',
    'hatched_line',
    'generated_file',
  ]) {
    test('no_directional_geometry.sh exits 0 for $fixture', () {
      expect(_run('test/gates/fixtures/$fixture').exitCode, 0);
    });
  }

  test('no_directional_geometry.sh exits 0 over app/lib', () {
    final result = _run('lib');
    expect(result.exitCode, 0, reason: result.stdout.toString());
  });

  test('no_directional_geometry.sh reports the number of files it scanned', () {
    final stdout = _run('lib').stdout.toString();
    expect(stdout, matches(RegExp(r'scanned [1-9][0-9]* dart files')));
  });
}
```

**Run:** `cd app && flutter test test/gates/` → 18 rows red, all of them because the script does not
exist. That is the correct first failure.

## Implementation outline

1. Create the fixture directories. Each holds one `.dart` file containing exactly one construct, so a
   failure names the construct. `generated_file/` holds `x.g.dart`; `hatched_line/` holds a banned line
   with the trailing marker.
2. Write `tools/gates/no_directional_geometry.sh`, modelled on
   `.claude/skills/i18n-rtl-l10n/scripts/check_i18n_bans.sh` — same `set -euo pipefail`, same
   `TARGET="${1:-…}"` shape, same exclusion of `*.g.dart`, `*.freezed.dart` and
   `app_localizations*.dart`. Differences, all deliberate:
   - exit **2** on a missing directory (`CONVENTIONS.md` §7);
   - exit **1** when the scanned Dart-file count is zero;
   - print `scanned N dart files` on every run, pass or fail;
   - drop any line whose trailing comment is `// catchlaw-directional-ok` before scanning;
   - add `Directionality(` and `EdgeInsets.fromLTRB(` to the pattern set.
3. `chmod +x`, and `bash -n` it — the existing `validate.yml` already parses every
   `.claude/skills/*/scripts/*.sh`; extend that step's glob to cover `tools/gates/*.sh` so a syntax
   error in this script is caught by the same mechanism.
4. Make rows 1–16 green.
5. Sweep `app/lib` until row 17 is green. Every replacement is a straight swap from the table; if any
   site genuinely needs a physical side, it is not swept — it gets the hatch and a comment saying why,
   and that comment is reviewed in this PR rather than discovered in E20.
6. Add the CI step with the explicit `app/lib` argument (D-1).

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 rows pass, and each failed first.
- [ ] `tools/gates/no_directional_geometry.sh app/lib` exits 0, and its output states how many files it
      scanned.
- [ ] The same command is a step in `.github/workflows/validate.yml`, with the path written out.
- [ ] `bash -n tools/gates/no_directional_geometry.sh` is covered by the workflow's script-parse step.
- [ ] `.claude/skills/i18n-rtl-l10n/scripts/check_i18n_bans.sh app/lib` is also clean — the general
      rule stays the plugin's and is not forked (rule 10).
- [ ] Zero `// catchlaw-directional-ok` markers exist in `app/lib` at the end of this task. The first
      legitimate one is E09's ruler.
- [ ] The escape hatch is documented in the script's header comment, in the same form
      `CONVENTIONS.md` §7 uses for the skill gates.
- [ ] No file outside `app/lib`, `app/test`, `tools/gates/` and `.github/workflows/` changed.

## Gates

```bash
tools/gates/no_directional_geometry.sh                  app/lib
.claude/skills/i18n-rtl-l10n/scripts/check_i18n_bans.sh app/lib
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
ci(l10n): ban physical-side geometry in app/lib with a grep gate

SPEC.md §9.3 calls this a lint rule. There is no such rule in package:lints,
flutter_lints or the analyzer's built-in set, and a custom analyzer plugin to
enforce one line is disproportionate — D-8 settles it as a grep gate in
tools/gates/, and this is that gate.

It lives in the repo rather than only in the i18n-rtl-l10n plugin for three
reasons a plugin script cannot cover: a required CI check must not depend on
a separately-versioned checkout; SPEC.md §9.3's one exception — the ruler,
which must not mirror — is CATCHLAW's carve-out and needs a local escape
hatch; and the gate has to fail when it scans zero files, which is the
failure mode that makes a gate worse than none.

EdgeInsets.fromLTRB is banned outright even though a symmetric one is
harmless: a regex cannot tell, and a hatch on every symmetric site would
train people to add the marker without reading it.

The gate is tested over sixteen fixtures, because a regex that matches
nothing passes silently on every run.

Task: E06/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
