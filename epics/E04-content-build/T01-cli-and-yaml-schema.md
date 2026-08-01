# E04/T01 — The CLI, and the authoring YAML schema

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): add the content_builder CLI and the authoring YAML loader` |
| **Depends on** | — (E03 merged) |
| **Size** | M |
| **Spec** | `SPEC.md` §8 "The content pipeline is a first-class deliverable", §7.1 (the tables the YAML must be able to express), §15 step 3 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Owns the tool. Rules 1 and 2 fix its shape — a tested workspace member with a typed CLI, and no warning tier — and `references/build-assertions.md` fixes the failure line format the loader must be able to produce |
| `project-structure-and-packages` | The pub-workspace member: `resolution: workspace`, one root lock file, no `dependency_overrides` |
| `catchlaw-conventions-index` | Rule 6, the one-way layer map: the builder may depend on `rule_engine`, never the reverse, and never on `app/` |
| `testing-strategy` | Which level this belongs at — pure Dart `package:test`, no widget binding anywhere in this package |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, "The content pipeline is a first-class deliverable" | The nine properties the tool must guarantee; this task builds the frame the other ten hang on |
| `SPEC.md` | §7.1 | Every table the YAML must be able to express, and the exact column names — the loader's models mirror these, not a tidier invention |
| `.claude/skills/catchlaw-content-pipeline/SKILL.md` | Rules 1, 2; "The tool is the deliverable" | `main` does four things — load, assert, emit, changelog — and never reaches emit with a non-empty failure list |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | "rules.yaml schema", "Failure format" | The authored field names, and `<assertion-id> <file>:<line> <message>` sorted by file then line |
| `.claude/skills/catchlaw-content-pipeline/examples/content_builder_assertions.dart` | `main()` and `ContentBuildOptions` | The worked shape of the CLI; do not diverge from it silently |
| `.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh` | checks 1, 2, 3, 5 | Three of the five checks scan YAML with **no** `content-pipeline-ok` escape hatch, which decides where negative fixtures may live |
| `FLUTTER_GUIDE.md` | §2.4, §2.5 | Workspace member layout, `resolution: workspace`, `lib/` + `bin/` for the CLI |
| `FLUTTER_GUIDE.md` | §7.1, §7.2 | SDK floor `^3.12.0` and sealed classes for the option/failure unions |
| `epics/DECISIONS.md` | D-4, D-1, D-5 | The one name (`tools/content_builder`, package `content_builder`, `dart run content_builder:build`), the workspace shape, the SDK floor |

## What this delivers

- `tools/content_builder/pubspec.yaml` — `name: content_builder`, `publish_to: none`,
  `resolution: workspace`, `environment: sdk: ^3.12.0` (D-5), dependencies `yaml`, `args`, `path`,
  `meta`, `sqlite3`, `rule_engine`; dev-dependencies `test`, `analysis_defaults`.
- `tools/content_builder/analysis_options.yaml` — `include: ../../analysis_options.yaml`. A nested
  options file *replaces* the parent for its subtree; without the include the package silently loses
  every rule (`FLUTTER_GUIDE.md` §4.3).
- `tools/content_builder/bin/build.dart` — the entry point `dart run content_builder:build` resolves.
- `tools/content_builder/lib/src/cli/options.dart` — `ContentBuildOptions.parse(List<String>)`.
- `tools/content_builder/lib/src/cli/failure.dart` — the `Failure` value and `render()`.
- `tools/content_builder/lib/src/load/yaml_source.dart` — `YamlSource.fromFile` and
  `YamlSource.fromString(source, displayPath:)`, both preserving 1-based line numbers.
- `tools/content_builder/lib/src/load/content_source.dart` — `ContentSource.load(Directory)`, the
  parsed corpus plus `assertions`, the registry later tasks add to.
- `tools/content_builder/lib/src/model/` — one immutable row type per `SPEC.md` §7.1 table.
- `content/README.md` — the authoring format, one section per file, with the directory layout below.
- `tools/content_builder/testing/fixtures/yaml_fixtures.dart` — `k`-prefixed inline YAML strings.
- `tools/content_builder/test/cli/options_test.dart`, `test/load/yaml_source_test.dart`,
  `test/load/content_source_test.dart`.

The authored layout, published in `content/README.md`:

```
content/
├── shared/            families.yaml  measurement_methods.yaml  species.yaml  vernacular.yaml
│                      plates.yaml  lookalikes.yaml  key_nodes.yaml  glossary.yaml  strings.yaml
├── es-ga/             jurisdiction.yaml  zones.yaml  citations.yaml  rules.yaml
│                      closed_seasons.yaml  licence_types.yaml  gear_rules.yaml  penalties.yaml
│                      legal_text.yaml  changes.yaml  strings.yaml  snapshot.json
└── CHANGELOG/         es-ga.md
```

One directory per jurisdiction, so E22 adds a sibling and touches nothing that already ships.

## Why it is built this way

**A tested Dart package, not a shell pipeline.** `catchlaw-content-pipeline` rule 1 gives the reason:
`sqlite3 < load.sql` emits a database nobody can reproduce, diff, or explain to a regulator. The tool
is reviewed like app code because a wrong row costs a fisher a fine, and reviewing YAML is only useful
if the thing that consumes it is itself reviewable.

**Every parsed row keeps its file and line.** The failure format in `build-assertions.md` is
`A1 content/rules.yaml:118 min_size without measurement_method`. An author fixes that in seconds and
fixes `A1: invalid rule` in an afternoon. `package:yaml`'s `loadYamlNode` returns nodes carrying a
`SourceSpan`; the loader keeps the span's `start.line + 1` on every row and throws the span away
afterwards. **Rejected:** parsing with `loadYaml` into plain maps and reporting the row's `id`
instead. An id is not a location, and the row that fails A1 most often is the one whose id was
mistyped.

**`YamlSource.fromString` exists for the tests, and it is not a convenience.**
`check_content_pipeline.sh` checks 2, 3 and 5 are `awk` window scans over every `*.yaml` under the
target directory, and — unlike checks 1, 4, 6 and 7 — they do **not** honour the
`content-pipeline-ok` escape hatch. A fixture file containing a deliberately broken row, which every
assertion task needs, would fail the gate with no way to exempt it. Inline YAML strings in
`testing/fixtures/yaml_fixtures.dart` are invisible to a `*.yaml` scan, keep the fixture beside the
test that explains it, and cost one extra constructor. **Rejected:** `test/fixtures/*.yaml` files
(fails the gate), and a `.gate-ignore` file (the gates read no config, and inventing one is the local
convention `CONVENTIONS.md` §4 forbids).

**Three flag names are rejected by name, not merely unknown.** `--force`, `--skip-assertions` and
`--allow-missing-locale` each exit 2 with `content_builder: <flag> does not exist and will not be
added; every assertion is fatal`. `catchlaw-content-pipeline` rule 2 says the flag that exists is the
flag CI uses at 18:00 on a Friday. Somebody will eventually copy a command from a stale note or from
another project; an explanation is cheaper than an argument. **Rejected:** accepting them and
ignoring them, which is worse than either alternative.

**`--build-date` and `--generator-commit` are required, not defaulted.** T10 requires a byte-identical
rebuild from identical input, so `DateTime.now()` may not appear anywhere in the emitter, and T06's
plate test needs a build year that a reviewer can reproduce. Both arrive as input and land in
`content_meta`. **Rejected:** defaulting `--build-date` to today. That single default makes
determinism untestable and silently re-clears a plate the day the term expires, with no diff to show
for it.

**`--out` is required and has no default.** The tool writes a binary asset; a default output path is
how a stray invocation overwrites `app/assets/db/reference.db` with a partial corpus.

Exit codes: **0** success, **1** assertion failures (nothing written), **2** usage error.

## Tests first

Write every row before touching `options.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ContentBuildOptions.parse accepts the four required options` | `--in content/ --out app/assets/db/reference.db --build-date 2026-08-14 --generator-commit 4f2c1ab` | parsed values, no error | The documented command in D-4 must actually parse |
| 2 | `ContentBuildOptions.parse exits 2 when --in is missing` | the command without `--in` | `UsageFailure`, code 2 | A missing input directory must not read as an empty corpus that passes every assertion |
| 3 | `ContentBuildOptions.parse exits 2 when --out is missing` | the command without `--out` | `UsageFailure`, code 2 | No default output path — a stray run must not overwrite the shipped asset |
| 4 | `ContentBuildOptions.parse exits 2 when --build-date is missing` | the command without `--build-date` | `UsageFailure`, code 2 | A defaulted build date makes T10's determinism untestable |
| 5 | `ContentBuildOptions.parse rejects --force by name` | `… --force` | code 2, message names the flag and says it will not be added | Skill rule 2; the message is the point, not the exit code |
| 6 | `ContentBuildOptions.parse rejects --skip-assertions by name` | `… --skip-assertions` | code 2, same shape | Second of the three names somebody will try |
| 7 | `ContentBuildOptions.parse rejects --allow-missing-locale by name` | `… --allow-missing-locale` | code 2, same shape | Third; and the one D-3's six locales make tempting |
| 8 | `ContentBuildOptions.parse exits 2 when --build-date is not an ISO date` | `--build-date 14/08/2026` | code 2 | The value reaches `content_meta`; a locale-formatted date there is unparseable forever |
| 9 | `YamlSource.fromString records the 1-based line of every row` | a three-row inline document | lines 2, 5, 8 | Every failure message is `file:line`; an off-by-one sends the author to the wrong row |
| 10 | `YamlSource.fromString reports the display path it was given` | `displayPath: 'content/rules.yaml'` | that string in the row's `path` | Inline fixtures must render failures identical to file-backed ones |
| 11 | `YamlSource.fromFile reports a parse error with file and line` | malformed YAML | a `Failure` at the offending line, not an exception | A crash on malformed input tells the author nothing |
| 12 | `ContentSource.load reads one jurisdiction directory and the shared directory` | a two-directory fixture tree | rows from both, tagged with their jurisdiction | The layout E22 extends must be load-bearing from the first commit |
| 13 | `ContentSource.load rejects an unknown top-level key` | `speceis:` in `rules.yaml` | a `Failure`, not a silent skip | A typo'd section that loads as "no rows" is how a whole file goes missing |
| 14 | `ContentSource.load rejects a duplicate row id within a file` | two rows with `id: r-001` | a `Failure` naming both lines | A duplicate id makes the T09 diff and the A8 grid disagree about which row is which |
| 15 | `ContentSource.assertions is empty before any assertion is registered` | a valid fixture tree | `isEmpty` | The registry T02–T09 plug into exists and starts empty; a pre-populated list hides a missing task |
| 16 | `main writes nothing when the failure list is non-empty` | a fixture producing one failure | exit 1, output file absent | Skill rule 2, proved at the entry point rather than asserted in prose |

```dart
// tools/content_builder/test/cli/options_test.dart
import 'package:content_builder/src/cli/options.dart';
import 'package:test/test.dart';

void main() {
  const args = [
    '--in', 'content/',
    '--out', 'app/assets/db/reference.db',
    '--build-date', '2026-08-14',
    '--generator-commit', '4f2c1ab',
  ];

  group('ContentBuildOptions', () {
    test('.parse accepts the four required options', () {
      final opts = ContentBuildOptions.parse(args);
      expect(opts.inDir.path, 'content/');
      expect(opts.buildDate, DateTime.utc(2026, 8, 14));
    });

    test('.parse rejects --force by name', () {
      expect(
        () => ContentBuildOptions.parse([...args, '--force']),
        throwsA(isA<UsageFailure>()
            .having((f) => f.exitCode, 'exitCode', 2)
            .having((f) => f.message, 'message', contains('--force'))),
      );
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// tools/content_builder/test/load/yaml_source_test.dart
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('YamlSource', () {
    test('.fromString records the 1-based line of every row', () {
      final source = YamlSource.fromString(
        kThreeRuleRowsYaml,
        displayPath: 'content/es-ga/rules.yaml',
      );
      expect(source.rows.map((r) => r.line), [2, 5, 8]);
    });

    test('.fromString reports the display path it was given', () {
      final source = YamlSource.fromString(
        kThreeRuleRowsYaml,
        displayPath: 'content/es-ga/rules.yaml',
      );
      expect(source.rows.first.path, 'content/es-ga/rules.yaml');
    });
  });
}
```

**Run:** `(cd tools/content_builder && dart test)` → 16 failures. If any passes now, the test is
wrong — fix the test before writing a line of `lib/`.

## Implementation outline

1. Register `tools/content_builder` in the root workspace list if E01 left it out; `dart pub get` at
   the root, never inside the package.
2. `pubspec.yaml`, `analysis_options.yaml` with the parent include, `bin/build.dart` delegating
   straight to `lib/src/cli/run.dart` so the entry point stays testable.
3. `Failure` — `id`, `path`, `line`, `message`, `render() => '$id $path:$line $message'`. Sorting is
   by `path` then `line`, per `build-assertions.md` "Failure format".
4. `ContentBuildOptions.parse` on `package:args`, with the three rejected names added as explicit
   flags whose callback throws `UsageFailure` carrying the explanation.
5. `YamlSource` over `loadYamlNode`, keeping `span.start.line + 1` per row; `fromString` takes the
   display path so an inline fixture renders identically to a file.
6. Row models, one per `SPEC.md` §7.1 table, immutable, `const` constructors, field names mirroring
   the SQL columns. A model that renames a column to something tidier costs the next reader a diff.
7. `ContentSource.load` walks `shared/` then each jurisdiction directory; unknown top-level keys and
   duplicate ids are failures, not skips.
8. `run(args)` in the four-phase shape: load → assert (empty registry) → emit (stub returning a
   failure, replaced in T10) → changelog (stub, replaced in T09). Wire the exit codes now; the phases
   fill in over T02–T10.
9. `content/README.md` documenting each file and its fields, with the worked rows from
   `build-assertions.md` "rules.yaml schema".

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 tests pass, and each failed first.
- [ ] `dart run content_builder:build --help` prints the four required options and lists no flag that
      weakens an assertion.
- [ ] `--force`, `--skip-assertions` and `--allow-missing-locale` each exit 2 with a message naming
      the flag.
- [ ] `grep -rn "DateTime.now" tools/content_builder/lib` returns nothing.
- [ ] `tools/content_builder/` imports nothing from `app/`, and nothing from `package:flutter`.
- [ ] No `.yaml` file exists anywhere under `tools/content_builder/test/`; negative fixtures are
      inline strings in `testing/fixtures/yaml_fixtures.dart`.
- [ ] `content/README.md` documents every file in the layout above.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): add the content_builder CLI and the authoring YAML loader

SPEC.md §8 calls the pipeline a first-class deliverable, so it is a tested
workspace member rather than a shell pipeline: a database emitted by
`sqlite3 < load.sql` cannot be reproduced, diffed or explained to a regulator.

Every parsed row keeps its file and 1-based line, because the failure format
is `A1 content/rules.yaml:118 …` and an author fixes that in seconds. The
loader takes a String as well as a File so negative fixtures can live as
inline YAML in Dart — checks 2, 3 and 5 of check_content_pipeline.sh scan
every *.yaml under the target with no escape hatch, and a fixture file with a
deliberately broken row would fail the gate it exists to prove.

--force, --skip-assertions and --allow-missing-locale exit 2 with a message
naming the flag. --build-date and --generator-commit are required input, not
readings: DateTime.now() in the emitter would make the byte-identical rebuild
untestable and would silently re-clear a plate with no diff to show for it.

Task: E04/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
