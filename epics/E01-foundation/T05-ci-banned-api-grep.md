# E01/T05 — CI: the banned-API grep and the layer-4 guard test

| | |
|---|---|
| **Epic** | E01 — Foundation, workspace and the offline gates |
| **Branch** | `epic/01-foundation` (shared) |
| **Commit** | `ci(check): add the layer-4 guard test and the SPEC §14 banned-API grep over app/lib` |
| **Depends on** | T01 (`app/lib` must exist), T03 (the job this hangs off) |
| **Size** | S |
| **Spec** | `SPEC.md` §14 static block, bullet 2; §5.3 (the grep-banned API list) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | Owns layer 4. Rules 6, 7 and 9, and `examples/no_network_test.dart` — the complete, runnable guard test this task copies rather than rewrites |
| `ci-pipeline-and-gates` | `references/policy-grep-gate.md`: the three-criteria bar, strip comments first, anchor the needle to a structure, accumulate and fail once, write the reason for a stranger at 2am |
| `catchlaw-conventions-index` | Rule 10 — a general rule is never forked. A second implementation of layer 4 beside the skill's example is exactly that fork |
| `dependency-hygiene` | Rule 8: grep `lib/` after removing a dependency, because a package that still resolves keeps compiling today and breaks on the clone that matters |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §14 static block, bullet 2 | The grep, verbatim. Fifteen alternations: `package:http`, `package:dio`, `HttpClient`, `Socket`, `WebSocket`, `firebase`, `connectivity_plus`, `PdfGoogleFonts`, `SvgPicture\.network`, `Image\.network`, `NetworkImage`, `url_launcher`, `launchUrl`, `AndroidIntent`, `ACTION_VIEW` |
| `SPEC.md` | §5.3 | Why each needle is there — "the APIs that would use them are banned by grep, not by hope" |
| `.claude/skills/catchlaw-offline-guarantee/examples/no_network_test.dart` | whole | The guard test, complete and runnable. Copy it; do not reimplement it |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 4 — the `dart:io` split", "The API grep list" | The banned/allowed symbol table the guard's map must match, and the escape-hatch rule |
| `.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh` | checks 4, 5, 6 | The skill's own maintained list, and why this task does **not** edit it |
| `.claude/skills/ci-pipeline-and-gates/scripts/banned-strings.sh` | whole | The shell shape: comment-stripped view, a `RULES` table of `regex|reason`, accumulate, fail once |
| `.claude/skills/ci-pipeline-and-gates/references/policy-grep-gate.md` | "Strip comments first", "Anchor the needle" | The two mistakes this gate would otherwise make |
| `epics/DECISIONS.md` | D-1 | `SPEC.md` §14 writes `lib/`; under D-1 the app's source is `app/lib`. The path changes, the list does not |

## What this delivers

- `app/test/no_network_test.dart` — the layer-4 guard, copied from
  `.claude/skills/catchlaw-offline-guarantee/examples/no_network_test.dart`. It needs no path edits:
  `flutter test` sets the working directory to `app/`, so the example's `Directory('lib')`,
  `File('pubspec.yaml')` and `Directory('android/app/src')` already resolve to `app/lib`,
  `app/pubspec.yaml` and `app/android/app/src`. The only change is a header line naming this task and the
  file it came from.
- `tools/gates/no_banned_apis.sh` — `SPEC.md` §14's fifteen needles as a shell gate over an explicit target
  directory. Exits 2 on a missing target **and** on a target holding no `.dart` file.
- `tools/gates/testdata/banned_api/` — one small Dart file per case, plus an empty directory fixture.
- A `banned-apis` step in the `flutter` job of `.github/workflows/validate.yml`, and `app/test/` running
  the guard as part of the existing app suite step.
- `app/test/policy/banned_api_grep_test.dart`.

## Why it is built this way

**The guard test is a copy, not a rewrite.** `catchlaw-offline-guarantee` ships
`examples/no_network_test.dart` marked "complete and runnable", with the `dart:io` split already correct
(`HttpClient`, `Socket`, `WebSocket`, `InternetAddress` banned; `File`, `Directory`, `Platform` kept), the
generated-file suffixes already skipped, the escape hatch already honoured, and — importantly for T08 —
`setUpAll` already asserting `libFiles` is not empty with the reason *"lib/ scanned but empty — the guard
would pass vacuously"*. Reimplementing it would fork a rule that already exists, which
`catchlaw-conventions-index` rule 10 forbids, and the fork drifts from its origin within two PRs.

**Two mechanisms for one contract, on purpose.** `policy-grep-gate.md` offers a Dart test under
`test/policy/` *or* a shell step in the workflow, and notes the difference: the shell step "runs even when
the Dart suite is broken". `SPEC.md` §14 is a release checklist item that has to be answerable when the app
does not compile, so it gets the shell step. The guard test covers what a grep cannot — it walks files,
skips generated output and reports file and line — so it gets the suite. They are not redundant; they fail
at different times.

**Rejected: folding §14's list into `check_no_network.sh`.** That script is a shared skill artefact under
`.github/CODEOWNERS` review, and its list serves the skill's own definition of done. The two lists differ
in both directions: the skill bans `Connectivity()`, `FadeInImage.assetNetwork` and `NetworkAssetBundle`,
which §14 omits; §14 bans `AndroidIntent`, `ACTION_VIEW`, bare `firebase`, bare `Socket` and bare
`url_launcher`, which the skill's regexes do not cover in that form. Editing a skill's script from a CI
task would make that skill's own definition of done untrue, and E01/T09 is the only task in the whole plan
licensed to touch a skill. Where the two ever disagree, **§14 wins for the release gate** — it is the list
the release signs — and the skill's list stays the maintained superset for authoring.

**Comments are stripped before matching, and this is not a nicety.** Every needle in this list is also what
a developer types when explaining why the needle is banned. `tools/gates/no_banned_apis.sh` has a header
comment naming all fifteen; a raw `grep -rn` over a tree that contains its own documentation fails on the
documentation. `policy-grep-gate.md` makes this the first rule for a reason, and its caveat applies: this
strips `//` inside string literals too, so no needle here may legitimately appear inside a URL-shaped
string. None does — `Uri.parse` is deliberately **not** banned, because `authority_url` and
`citation.source_url` are stored as URIs and printed as selectable text (`SPEC.md` §5.3, four-layers.md
"The API grep list").

**`Socket` is anchored to a word boundary.** `\bSocket\b` does not match inside `WebSocket` (no boundary
before the `S`) and does not match `socketPathLabel` (case, and no boundary). `four-layers.md` names
`socketPathLabel` as the documented false positive the escape hatch exists for, and test 7 pins the
behaviour so a later "simplification" of the regex cannot quietly widen it.

**The escape hatch is `// no-network-ok`, not a new marker.** The same string `check_no_network.sh` and the
guard test honour. `four-layers.md`: allowed only for a false-positive identifier or a doc comment naming a
symbol in prose, **never** on an import and never on a real call. A second marker would mean a line exempt
from one gate and caught by another, and the resolution would be to add the second marker everywhere.

**The gate exits 2 on an empty target, not 0.** `CONVENTIONS.md` §7 and E01/T08: a gate that scans a path
with no files reports success. The skill's scripts exit 2 only when the directory is *missing*; a directory
that exists and holds nothing passes. This gate closes that hole at its own source rather than relying on
T08's wrapper to notice — and T08's wrapper is what enforces it for the sixteen scripts this task cannot
edit.

## Tests first

Write `app/test/policy/banned_api_grep_test.dart` and the fixtures before writing the shell script or
copying the guard. Run them. **All ten must fail** — `tools/gates/no_banned_apis.sh` does not exist and
`app/test/no_network_test.dart` does not exist.

| # | Test name | Fixture | Expect | Why this case exists |
|---|---|---|---|---|
| 1 | `Guard test bans every dart:io networking symbol named in four-layers.md` | the guard's own source | every symbol present | The list must not drift from the reference table it was copied from. A symbol quietly dropped in a refactor is a hole nobody sees |
| 2 | `Guard test leaves File, Directory and Platform legal` | the guard's own source | absent from the banned maps | A wholesale `dart:io` ban is unenforceable, gets waived in week two and then guards nothing (skill rule 6). Drift and the PDF export need all three |
| 3 | `Guard test fails when app/lib is empty` | the guard's own source | `setUpAll` asserts `isNotEmpty` | The example already carries this assertion; the test exists so a later edit cannot delete it and leave the guard passing vacuously |
| 4 | `Banned-API gate rejects $needle` (loop, 15 cases) | one Dart file per needle | exit 1, names the file and line | `SPEC.md` §14's list, one behaviour per test. The description interpolates the needle so `--plain-name` can select one (`CONVENTIONS.md` §5) |
| 5 | `Banned-API gate ignores a needle that appears only in a comment` | `comment_only.dart` | exit 0 | The gate's own header names all fifteen needles. A raw grep over a documented tree fails on its own documentation |
| 6 | `Banned-API gate ignores a needle on a line carrying // no-network-ok` | `escaped.dart` | exit 0 | The documented escape hatch, honoured by the same string the other two layers honour |
| 7 | `Banned-API gate matches Socket as a whole word only` | `socket_path_label.dart` | exit 0 | `socketPathLabel` is the false positive four-layers.md names. An unanchored needle makes the gate cry wolf, and a gate that cries wolf gets deleted |
| 8 | `Banned-API gate reports every offender, not the first` | `three_offenders.dart` | three lines in stdout | Reporting offender #1 and hiding the rest teaches people to fix one line per push (`policy-grep-gate.md`) |
| 9 | `Banned-API gate exits 2 when the target directory does not exist` | `no/such/dir` | exit 2 | D-1's consequence: a wrong path fails loudly instead of passing on nothing |
| 10 | `Banned-API gate exits 2 when the target directory holds no Dart file` | an empty temp dir | exit 2 | `CONVENTIONS.md` §7 — the failure mode that makes a gate worse than no gate, closed at this gate's own source |

```dart
// app/test/policy/banned_api_grep_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'repo_root.dart';

/// The fifteen needles of SPEC.md §14, in the order the spec prints them.
const spec14Needles = <String>[
  'package:http', 'package:dio', 'HttpClient', 'Socket', 'WebSocket',
  'firebase', 'connectivity_plus', 'PdfGoogleFonts', 'SvgPicture.network',
  'Image.network', 'NetworkImage', 'url_launcher', 'launchUrl',
  'AndroidIntent', 'ACTION_VIEW',
];

/// The banned dart:io symbols of four-layers.md "Layer 4 — the dart:io split".
const layer4Symbols = <String>[
  'HttpClient', 'HttpServer', 'HttpOverrides', 'Socket', 'RawSocket',
  'SecureSocket', 'ServerSocket', 'WebSocket', 'InternetAddress',
  'NetworkInterface', 'RawDatagramSocket', 'SecurityContext',
];

ProcessResult runGate(String target) => Process.runSync(
      'bash',
      <String>[repoFile('tools/gates/no_banned_apis.sh').path, target],
      workingDirectory: repoRoot().path,
    );

String fixture(String name) => repoDir('tools/gates/testdata/banned_api/$name').path;

String guardSource() => repoFile('app/test/no_network_test.dart').readAsStringSync();

void main() {
  test('Guard test bans every dart:io networking symbol named in four-layers.md', () {
    final missing = layer4Symbols.where((s) => !guardSource().contains(s)).toList();
    expect(missing, isEmpty,
        reason: 'the guard drifted from the table it was copied from:\n${missing.join('\n')}');
  });

  test('Guard test leaves File, Directory and Platform legal', () {
    for (final allowed in <String>['File', 'Directory', 'Platform']) {
      expect(guardSource(), isNot(contains("r'\\b$allowed\\b'")),
          reason: 'a wholesale dart:io ban is unenforceable and gets waived in week two');
    }
  });

  test('Guard test fails when app/lib is empty', () {
    expect(guardSource(), contains('the guard would pass vacuously'),
        reason: 'the setUpAll emptiness assertion is what stops a vacuous green');
  });

  for (final needle in spec14Needles) {
    test('Banned-API gate rejects $needle', () {
      final r = runGate(fixture('needle_${needle.replaceAll(RegExp('[^a-zA-Z]'), '_')}'));
      expect(r.exitCode, 1, reason: '${r.stdout}\n${r.stderr}');
      expect(r.stderr, contains(needle));
    });
  }

  test('Banned-API gate ignores a needle that appears only in a comment', () {
    final r = runGate(fixture('comment_only'));
    expect(r.exitCode, 0,
        reason: 'the gate\'s own header names all fifteen needles:\n${r.stderr}');
  });

  test('Banned-API gate ignores a needle on a line carrying // no-network-ok', () {
    expect(runGate(fixture('escaped')).exitCode, 0);
  });

  test('Banned-API gate matches Socket as a whole word only', () {
    final r = runGate(fixture('socket_path_label'));
    expect(r.exitCode, 0,
        reason: 'socketPathLabel is the documented false positive; a gate that cries '
            'wolf gets deleted:\n${r.stderr}');
  });

  test('Banned-API gate reports every offender, not the first', () {
    final r = runGate(fixture('three_offenders'));
    expect(r.exitCode, 1);
    expect('${r.stderr}'.split('\n').where((l) => l.contains('three_offenders')).length, 3);
  });

  test('Banned-API gate exits 2 when the target directory does not exist', () {
    expect(runGate('no/such/dir').exitCode, 2);
  });

  test('Banned-API gate exits 2 when the target directory holds no Dart file', () {
    final empty = Directory.systemTemp.createTempSync('catchlaw_empty_target');
    addTearDown(() => empty.deleteSync(recursive: true));
    expect(runGate(empty.path).exitCode, 2,
        reason: 'a gate that scans a path with no files reports success — CONVENTIONS §7');
  });
}
```

**Run:** `cd app && flutter test test/policy/banned_api_grep_test.dart` → 24 failures (nine named cases
plus the fifteen loop cases). If any passes now, the fixture is empty or the path is wrong.

## Implementation outline

1. Create the fixture tree under `tools/gates/testdata/banned_api/`: one directory per case, each holding
   one small `.dart` file. The fifteen needle fixtures each contain a single plausible line —
   `import 'package:http/http.dart' as http;`, `final img = Image.network(url);`,
   `await launchUrl(uri);`, `<action android:name="ACTION_VIEW" />` inside a Dart string, and so on.
   `comment_only.dart` puts a needle in a `//` line and nothing else. `socket_path_label.dart` declares
   `const socketPathLabel = 'db';`.
2. Write `tools/gates/no_banned_apis.sh`, modelled on
   `ci-pipeline-and-gates/scripts/banned-strings.sh`:
   - `TARGET="${1:-}"`; exit 2 with a message when it is empty or not a directory.
   - Count `*.dart` files under the target; exit 2 with "would have passed over an empty tree" when zero.
   - `strip_comments() { sed -E 's,//.*,,' "$1"; }` — one line, dependency-free.
   - A `RULES` array of `regex|reason`, one entry per §14 needle, each anchored: `package:` needles anchor
     to an `import` line, `Socket` and `WebSocket` to `\b…\b`, `SvgPicture\.network` and `Image\.network`
     to the literal dot.
   - Skip `*.g.dart`, `*.freezed.dart`, `*.drift.dart`, `*.gr.dart`.
   - Skip any line containing `no-network-ok`.
   - Accumulate every offender as `file:line — needle — reason`; print all of them to stderr with a
     `::error::` prefix and exit 1 once.
   - The header comment states the consequence to the user, not the rule: these APIs cannot work on a
     device that ships without `android.permission.INTERNET`, so a call site here is a feature that is
     dead in the field and live in the office.
3. Copy `.claude/skills/catchlaw-offline-guarantee/examples/no_network_test.dart` to
   `app/test/no_network_test.dart`. Change nothing but the header: name this task, name the file it came
   from, and say that edits belong upstream in the skill first.
4. Add the workflow step after the analyze step:
   ```yaml
   - name: Banned network APIs (SPEC §14)
     run: bash tools/gates/no_banned_apis.sh app/lib
   ```
5. Prove it once against the live tree: paste `final c = HttpClient();` into `app/lib/main.dart`, run both
   the gate and `flutter test test/no_network_test.dart`, watch both go red with a file and a line, and
   revert. This is `catchlaw-offline-guarantee`'s own definition-of-done item and it is not optional.
6. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 24 test cases pass, and each failed first.
- [ ] `app/test/no_network_test.dart` differs from the skill's example only in its header comment. A `diff`
      against `.claude/skills/catchlaw-offline-guarantee/examples/no_network_test.dart` shows nothing else.
- [ ] Pasting `final c = HttpClient();` into `app/lib/main.dart` turns **both** the guard test and the
      shell gate red, each naming the file and the line, and the paste is reverted.
- [ ] `tools/gates/no_banned_apis.sh` contains all fifteen `SPEC.md` §14 needles and no sixteenth. A
      needle added here without a spec line is a promise the gate has to keep forever with nothing behind
      it (`ci-pipeline-and-gates` rule 1).
- [ ] The gate exits 2 — not 0 and not 1 — on both a missing directory and an empty one.
- [ ] `.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh` is unchanged by this task.
- [ ] `Uri.parse` is not banned, and the header says why.

## Gates

```bash
bash tools/gates/no_banned_apis.sh app/lib
cd app && flutter test test/no_network_test.dart && flutter test && cd ..
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
ci(check): add the layer-4 guard test and the SPEC §14 banned-API grep over app/lib

SPEC.md §5.3: the APIs that could reach the two allowlisted http edges are
banned by grep, not by hope. §14 bullet 2 gives the list; D-1 puts the source
at app/lib rather than lib/. The path changes, the fifteen needles do not.

app/test/no_network_test.dart is a copy of the skill's worked example, not a
reimplementation. It already has the dart:io split right — HttpClient, Socket,
WebSocket and InternetAddress banned, File, Directory and Platform kept for
drift and the PDF export — and it already asserts lib/ is non-empty so it
cannot pass vacuously. Rewriting it would fork a rule that exists, which
catchlaw-conventions-index rule 10 forbids.

Two mechanisms for one contract, on purpose: the shell gate runs even when the
Dart suite is broken, which is when a release checklist item most needs
answering; the test walks files, skips generated output and reports file and
line, which a grep cannot.

check_no_network.sh is deliberately untouched. Its list and §14's differ in
both directions, it is a shared skill artefact under CODEOWNERS review, and
E01/T09 is the only task licensed to edit a skill. Where the two disagree, §14
wins for the release gate.

Comments are stripped before matching: every needle here is also what somebody
types when explaining why it is banned, including the gate's own header.

Task: E01/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
