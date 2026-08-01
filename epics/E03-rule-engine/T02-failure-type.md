# E03/T02 — The `Failure` type

| | |
|---|---|
| **Epic** | E03 — Rule engine: resolution, findings and verdicts |
| **Branch** | `epic/03-rule-engine` (shared) |
| **Commit** | `feat(rule_engine): copy the sealed Result union and rename its error arm to Failure` |
| **Depends on** | T01 (the exceptions it carries name the models) |
| **Size** | S |
| **Spec** | `FLUTTER_GUIDE.md` §1.6, §2.5, §7.5; `SPEC.md` §7.3 (what is *not* an error) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `error-handling-typed-results` | Owns the `Result` spine and the rule that a resolution failure is never an exception — this task draws the line between the two channels |
| `catchlaw-rule-engine` | Rule 8: "no rule found" is a `Resolution` variant and never an error. Without that rule this file grows a `NoRuleError` and the legal contract is gone |
| `dart3-idioms-and-coding-standards` | Sealed class shape, `final` subclasses, exhaustive `switch` with no `default:` arm |
| `testing-strategy` | Pure unit; and where a test-only helper is allowed to live |
| `catchlaw-conventions-index` | Layer map: this type crosses into `app/lib/data/` and must stay Flutter-free |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `FLUTTER_GUIDE.md` | §1.6 in full, including the four numbered warnings | The 40 lines to copy, the `Error` → `Failure` rename and its cost, the `Exception`-not-`Object` channel, the dropped stack trace, and `asOk` being test-only |
| `FLUTTER_GUIDE.md` | §2.5 | `packages/rule_engine/lib/src/failure.dart` — "our renamed sealed Result", the path this task must use |
| `FLUTTER_GUIDE.md` | §7.5 | `Result`/`Failure` inside the pure-Dart package; `rethrow`, never `throw e` |
| `FLUTTER_GUIDE.md` | §7.2 | Sealed classes and exhaustive switching |
| `SPEC.md` | §7.3 | The four resolution outcomes, none of which is an error |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 8 and the `findings.isEmpty ? meets` anti-pattern | Absence is a variant, not a failure — the boundary this task fixes |
| `epics/CONVENTIONS.md` | §6 | `testing/` sits beside `lib/` and `test/`; a helper must not end in `_test.dart` |

## What this delivers

- `packages/rule_engine/lib/src/failure.dart` — `sealed class Result<T>`, `final class Ok<T>`,
  `final class Failure<T>`, carrying `Exception` plus an optional `StackTrace`.
- `packages/rule_engine/lib/src/engine_exception.dart` — `sealed class EngineException implements
  Exception` with exactly two subclasses: `MalformedRule` and `MalformedSeason`.
- `packages/rule_engine/testing/utils/result.dart` — the `asOk` / `asFailure` extension, test-only,
  never exported from the barrel.
- `packages/rule_engine/lib/rule_engine.dart` — exports `failure.dart` and `engine_exception.dart`.
- `packages/rule_engine/test/failure_test.dart`.

## Why it is built this way

**Copied, not depended upon.** `FLUTTER_GUIDE.md` §1.6 closes with the instruction: `result_dart`
2.2.0 exists and is named in the official docs, and the guidance is still *"vendor the 40 lines
instead — zero dependency, zero version risk, and it is what the Flutter team ships"*. For this
package the argument is stronger than in the app: `packages/rule_engine/` is compiled by
`tools/content_builder/` under plain `dart run`, and every dependency it takes is a dependency the
content build takes.

**Renamed, because `Error` is a `dart:core` type.** §1.6 warning 1: a file importing the unrenamed
version loses `dart:core`'s `Error`, which is what `AssertionError` and `StateError` extend. The
rename costs divergence from every doc snippet — §1.6 calls that *"a real but acceptable cost"* — and
buys back the ability to write an `assert` in this package without shadowing games.

**The error channel is `Exception`, not `Object`.** §1.6 warning 2, verbatim: a `TypeError` from a bad
cast escapes `Result`-based control flow entirely. This type is not crash-proofing and the doc
comment on `Failure` says so, so that nobody later widens the field to `Object` believing they are
hardening something.

**A `StackTrace?` field, because §1.6 warning 3 applies literally to us.** The stack trace is dropped
by the reference implementation. For an app that cannot phone home, *"the local stack trace is all
you get"*. The engine adds the optional field rather than converting at a provider boundary, because
the engine has no provider boundary — the conversion §1.6 offers as the alternative happens in
`app/lib/`, two epics away, by which time the trace is gone.

**`asOk` ships in `testing/`, never in `lib/`.** §1.6 warning 4: the docs show `result.asOk.value` in
production-looking code, and the real Compass app keeps it in `testing/utils/result.dart`. It is an
unchecked cast that throws on the error path, which defeats the entire point of the type.
`CONVENTIONS.md` §6 already gives `testing/` its home beside `lib/` and `test/`. **Rejected:** an
`asOk` getter in `lib/` marked `@visibleForTesting` — the annotation is advisory, the analyzer only
warns outside the package, and the content builder is outside the package.

**The line this task exists to draw: what is a `Failure` and what is a `Resolution`.**
`catchlaw-rule-engine` rule 8 is unambiguous that "no rule found" is a variant of the result, not an
error, and its listed anti-pattern `findings.isEmpty ? meets : ...` is the failure that comes from
blurring the two. So:

| Situation | Channel | Why |
|---|---|---|
| No rule row for this species here | `Ok(NoRuleFound(...))` | A legal statement about the reference data. T11 |
| Species not in this jurisdiction's list | `Ok(UnknownSpecies(...))` | Also a legal statement. T11 |
| Instrument records no limit | `Ok(NoLimitInInstrument(...))` | A positive, cited statement. T10 |
| Two equally specific rules disagree | `Ok(Ambiguous(...))` | The refusal is the answer. T05 |
| A `minSize` rule row with a null `minSizeMm` | `Failure(MalformedRule)` | A content defect. There is no legal statement to make |
| An `annual` season with null `startMonth` | `Failure(MalformedSeason)` | Same |
| A `Landing` with a negative length | not here | `the-five-part-carve-out.md` edge case: a validation error on the input, never a verdict. E09 owns it |

`EngineException` has exactly those two subclasses and is `sealed`, so adding a third is a visible
decision and every `switch` over it fails to compile until it is handled.

**Rejected: throwing.** `FLUTTER_GUIDE.md` §1.10 contradiction (c) records that the offline-first
page's repositories `throw` while the SQL page and the Compass app use `Result`, and resolves it in
favour of `Result`. Dart's exceptions are unchecked, so a throwing `evaluate` would put a content
defect on a code path with no compiler-visible handler, in the one package that is compiled into a
CLI that runs unattended over hundreds of authored files.

**Rejected: `Result<T, E>` with a typed error parameter.** It reads well and it doubles the type
noise at every call site in T10 for a package with exactly one error type. §1.6's copy is the
reference implementation two consumers already know.

## Tests first

Write all 9 rows before creating `failure.dart`. Run them. **They must fail.** A passing test here
means it is asserting a property of `dart:core` rather than of this file.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Result.ok carries its value` | `Result<int>.ok(3)` | `Ok<int>` with `value == 3` | The happy arm; also proves the factory constructors from §1.6 are wired |
| 2 | `Result.error carries its exception` | `Result<int>.error(MalformedRule(ruleId: 1))` | `Failure<int>` with that exception | The error arm |
| 3 | `Result.error carries a stack trace when one is supplied` | an exception plus `StackTrace.current` | `failure.stackTrace` is not null | §1.6 warning 3: the reference implementation drops it and this one must not, because there is no crash reporter downstream |
| 4 | `Result.error leaves the stack trace null when none is supplied` | exception only | `stackTrace` is null | The field is optional; a mandatory one would force every construction site to fabricate a trace |
| 5 | `Result switches exhaustively with no default arm` | a `switch` over `Ok` and `Failure` only | compiles and returns | `FLUTTER_GUIDE.md` §7.2: the analyzer errors on a missed case, which is the entire reason the union is sealed |
| 6 | `Failure does not shadow dart:core Error in an importing file` | a file importing the barrel that also references `StateError` | compiles | §1.6 warning 1 is the reason for the rename; this test is what makes the rename load-bearing instead of cosmetic |
| 7 | `EngineException has exactly MalformedRule and MalformedSeason` | a `switch` over `EngineException` | compiles with two arms and no default | A third content-defect kind must be a deliberate edit, not a silent `default:` |
| 8 | `MalformedRule names the rule id it rejected` | `MalformedRule(ruleId: 91, field: 'minSizeMm')` | both fields readable | A content defect is useless to E04 unless it says which authored row produced it |
| 9 | `lib exports no asOk helper` | source scan of `lib/` for `asOk` | no match | §1.6 warning 4: the cast throws on the error path, and the content builder imports `lib/`, not `testing/` |

```dart
// packages/rule_engine/test/failure_test.dart
import 'dart:io';

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('.ok carries its value', () {
      const result = Result<int>.ok(3);
      expect(result, isA<Ok<int>>());
      switch (result) {
        case Ok<int>():
          expect(result.value, 3);
        case Failure<int>():
          fail('constructed an Ok and matched a Failure');
      }
    });

    test('.error carries a stack trace when one is supplied', () {
      final trace = StackTrace.current;
      final result = Result<int>.error(const MalformedRule(ruleId: 1, field: 'minSizeMm'), trace);
      expect((result as Failure<int>).stackTrace, same(trace));
    });

    test('switches exhaustively with no default arm', () {
      String describe(Result<int> r) => switch (r) {
            Ok<int>(:final value) => 'ok $value',
            Failure<int>(:final error) => 'failed $error',
          };
      expect(describe(const Result<int>.ok(1)), 'ok 1');
    });
  });

  group('lib', () {
    test('exports no asOk helper', () {
      final hits = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => f.readAsStringSync().contains('asOk'))
          .map((f) => f.path)
          .toList();
      expect(hits, isEmpty, reason: 'asOk is an unchecked cast; it lives in testing/ only');
    });
  });
}
```

**Run:** `dart test test/failure_test.dart` → 9 failures. If row 9 passes before `failure.dart`
exists, it is passing vacuously on an empty scan — add the file, watch it stay green, and only then
trust it. That vacuous-pass shape is the same one `CONVENTIONS.md` §7 warns about for gate scripts.

## Implementation outline

1. Create `lib/src/failure.dart` by copying `FLUTTER_GUIDE.md` §1.6's 40 lines verbatim, then apply
   two edits and nothing else: rename `Error` to `Failure`, and add `final StackTrace? stackTrace` to
   the error arm with a positional optional parameter on the factory.
2. Create `lib/src/engine_exception.dart`: `sealed class EngineException implements Exception` with
   `final class MalformedRule` (`ruleId`, `field`) and `final class MalformedSeason` (`seasonId`,
   `field`). Both `const`. `toString()` on each names the id and the field — that string is a
   developer diagnostic that never reaches a screen, so D-7 is untouched; say so in the doc comment
   so a later reader does not delete it as a stray sentence.
3. Create `testing/utils/result.dart`: `extension ResultTestHelpers<T> on Result<T>` with `asOk` and
   `asFailure`. Doc-comment it as test-only, with the §1.6 warning 4 reason.
4. Export `failure.dart` and `engine_exception.dart` from the barrel. Do **not** export
   `testing/utils/result.dart`.
5. Re-run. All 9 green, plus every T01 test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 9 tests pass, and each failed first.
- [ ] Branch coverage on `failure.dart` and `engine_exception.dart` is 100%.
- [ ] `lib/` contains no `asOk`; `testing/utils/result.dart` does, and is not named `*_test.dart`.
- [ ] The error channel is typed `Exception`, not `Object` — a widening is a deliberate later edit.
- [ ] `EngineException` is sealed with exactly two subclasses.
- [ ] No `Resolution`-shaped outcome is representable as a `Failure`: the table in "Why it is built
      this way" is reproduced as the doc comment on `EngineException`.
- [ ] `packages/rule_engine/pubspec.yaml` gained no dependency in this task.

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
feat(rule_engine): copy the sealed Result union and rename its error arm to Failure

Vendored from FLUTTER_GUIDE 1.6 rather than taken from result_dart: every
dependency this package adds is one the content_builder CLI adds too. The
error arm is renamed because dart:core's Error is what AssertionError and
StateError extend, and a StackTrace? field is added because an app that
cannot phone home has nothing else to diagnose with.

EngineException is sealed over exactly two content defects. No resolution
outcome is representable as a Failure — "no rule recorded" is a legal
statement about the reference data and it travels in the Ok arm.

Task: E03/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
