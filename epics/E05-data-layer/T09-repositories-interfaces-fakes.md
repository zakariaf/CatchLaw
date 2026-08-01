# E05/T09 — Repositories, interfaces and fakes

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `epic/05-data-layer` (shared) |
| **Commit** | `feat(data): put every repository behind an interface, a typed Result and a fake` |
| **Depends on** | T07 (reference DAOs), T08 (user DAOs) |
| **Size** | L |
| **Spec** | `SPEC.md` §7.1, §7.2 (what is read and written); §13 (cold start < 1.2 s — the providers must construct synchronously) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `state-management-riverpod` | Providers are DI: throwing placeholder seams overridden once at the composition root, plain `Provider` for app-scope singletons, `StreamProvider` over a repository stream, and no Riverpod inside a repository |
| `error-handling-typed-results` | The `Result`/`Failure` spine every fallible method returns, the convert-at-the-boundary catch that logs before returning, and the ban on `default:` in a sealed switch |
| `persistence-drift` | Rule 7: the repository is the single write path and the single source of truth; DAOs hold single-table queries and repositories hold cross-table work |
| `testing-strategy` | Rule 5 and `references/property-and-fakes.md`: bare-`implements` fakes driven by an enum, and the absence-of-a-failure-class test |
| `app-startup-and-bootstrap` | Rules 6 and 10: real infra built in a composition-root `bootstrap()` and injected via `overrideWithValue`, and `retry: (count, error) => null` for an app whose only failures are local |
| `catchlaw-reference-database` | Rule 11: `ReferenceRepository` and `MeasurementRepository` share no `QueryExecutor` and never call each other |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `FLUTTER_GUIDE.md` | §1.4 | Repository vs Service, "two repositories, one per data type — not one per database", and repositories owning app-wide session state |
| `FLUTTER_GUIDE.md` | §1.5 | Abstract repositories: `implements`, not `extends`; `ReferenceRepository` → `ReferenceRepositoryDrift` and `ReferenceRepositoryFixture` |
| `FLUTTER_GUIDE.md` | §1.6 | The four things to know before copying `Result`: it shadows `dart:core.Error`, its error channel is `Exception`, it drops stack traces, and `asOk` is test-only and must never ship |
| `FLUTTER_GUIDE.md` | §1.7 | Skip `Command`; never nest `AsyncValue<Result<T>>` — unwrap the `Result` in the notifier |
| `FLUTTER_GUIDE.md` | §2.5 | The eight review rules, of which 3, 4, 5 and 7 are this task |
| `FLUTTER_GUIDE.md` | §5.2 | The vertical slice: repositories take no `Ref` and import no Riverpod; `Provider` + `StreamProvider` is the entire read path |
| `$FLUTTER_SKILLS/error-handling-typed-results/references/result-failure-spine.md` | "The `Result` spine", "Why `F extends Failure`", "Failure taxonomy per boundary", "Convert-at-the-boundary" | The typed error arm, one sealed family per boundary, and the `SqliteException` mapping with its regex caveat |
| `$FLUTTER_SKILLS/state-management-riverpod/SKILL.md` | rules 5, 7; "Riverpod: providers are DI (throwing seams)"; "lifecycle & disposal" | Throwing seams, app-scope singletons as plain `Provider`, resources released in `ref.onDispose` |
| `$FLUTTER_SKILLS/testing-strategy/references/property-and-fakes.md` | "Fakes over mocks", "Model the world as an enum", "Assert the absence of a failure class" | The fake shape, and the loop that proves nothing fails silently |
| `$FLUTTER_SKILLS/app-startup-and-bootstrap/SKILL.md` | rules 6, 10; "The composition root" | `bootstrap()` and `overrideWithValue`, and the retry policy |
| `.claude/skills/catchlaw-reference-database/SKILL.md` | rules 2, 11 | Nothing awaited before `runApp`; no shared executor |
| `epics/DECISIONS.md` | D-5 | Riverpod 3.4.1 — `autoDispose`/`family` are modifiers, not base classes |

## What this delivers

- `app/lib/data/repositories/reference_repository.dart` — `abstract interface class
  ReferenceRepository`, plus `reference_repository_drift.dart` and `reference_repository_fixture.dart`.
- `app/lib/data/repositories/measurement_repository.dart` — the catch-log write path — plus
  `measurement_repository_drift.dart`.
- `app/lib/data/repositories/settings_repository.dart` + `settings_repository_drift.dart` — the
  singleton profile, exposed as `Stream<UserProfile>` and typed setters.
- `app/lib/data/repositories/data_failure.dart` — the sealed `DataFailure` family:
  `DataNotFound` (`data.not_found`, params `String entity, String id`),
  `DataConstraintViolated` (`data.constraint_violated`, param `String field`),
  `DataStoreUnavailable` (`data.store_unavailable`),
  `DataTransactionRolledBack` (`data.transaction_rolled_back`).
- `app/lib/data/providers.dart` — throwing placeholder providers for `UserDatabase`,
  `ReferenceDatabase` and the three repositories.
- `app/lib/data/bootstrap_data.dart` — `List<Override> dataOverrides({required AppDirectories
  directories})`, constructed **synchronously**, wired into the `ProviderScope` of `app/lib/main.dart`
  together with `retry: (count, error) => null`.
- `app/testing/fakes/fake_reference_repository.dart`, `fake_measurement_repository.dart`,
  `fake_settings_repository.dart` — bare `implements`, each driven by a `StoreEnv` enum.
- `app/test/data/repositories/` — one test file per repository, plus
  `app/test/data/layering_test.dart`.

## Why it is built this way

**Two repositories, one per data type — not one per database.** `FLUTTER_GUIDE.md` §1.4 is explicit, and
so is the consequence: `ReferenceRepository` (read-only content) and `MeasurementRepository`
(read/write record) **must never call each other**. A screen that needs both — the result screen joins a
species to its rules to the fisher's tally — does the join in `domain/use_cases/`, where it is testable
without either database. Test 12 asserts the absence of the import edge in both directions, because this
is the rule that decays first: the first time somebody wants a species name on a catch row, calling the
other repository is one line and denormalisation is three.

**Every fallible method returns `Future<Result<T, DataFailure>>`; every reactive read returns
`Stream<T>`.** `FLUTTER_GUIDE.md` §2.5 rule 5 states the shape. The error arm is typed as a sealed family
so a `switch` at the call site is exhaustive and adding a failure is a compile error at every one of them
(`error-handling-typed-results` rule 4). Streams are **not** wrapped in `Result`: a `Stream<Result<T,
F>>` gives four states where two are meaningful, and `FLUTTER_GUIDE.md` §1.7 bans the nesting outright —
a stream that fails does so through Riverpod's `AsyncError`, with the stack trace still in scope.

**The `Result` type is E03's and is not forked here.** It lives in
`packages/rule_engine/lib/src/failure.dart` (`FLUTTER_GUIDE.md` §2.5) so the pure engine and the data
layer share one vocabulary. This task adds one sealed `DataFailure` family beneath it and nothing else.
Two of §1.6's four warnings bite immediately: the error arm's name shadows `dart:core.Error` if it is
called `Error`, and `asOk` is a test-only unchecked cast that must never appear in `lib/`. If E03 shipped
the single-parameter `Result<T>`, this task uses it as shipped and the epic's Risks section records the
arity question — **it does not define a second spine**.

**Failures carry codes and typed params, never sentences.** A message baked into a failure cannot be
translated, cannot be mirrored for RTL and cannot have its numerals re-rendered — and this app renders
in `ar` with a numeral system §9.3 resolves per locale. The mapping from `SqliteException` to a
`DataFailure` happens once, at the repository boundary, in an `on SqliteException catch (e, st)` that
logs `(e, st)` **before** returning. Note the caveat `result-failure-spine.md` records: `SqliteException`
exposes `resultCode`, `extendedResultCode`, `message` and `explanation` and has **no** column field, so
the offending column is a best-effort regex over the message with a fallback.

**Providers are dependency injection and nothing else.** Each is a throwing placeholder — `Provider<T>((ref)
=> throw UnimplementedError('override in bootstrap()'))` — so a forgotten wiring fails loudly at first
read instead of silently constructing a live database inside a widget test. `dataOverrides` builds the
real values **synchronously**: `UserDatabase(userExecutor(file))` constructs a `LazyDatabase` and opens
nothing, so `runApp` is reached without an `await` and `catchlaw-conventions-index` rule 8 holds. The
database providers are plain `Provider`s with `ref.onDispose(db.close)`, never `autoDispose` — an
app-scope singleton that tears down when the last screen closes reopens SQLite on the next navigation.

**`retry: (count, error) => null` on the root `ProviderScope`.** Riverpod 3 retries a failing provider
for roughly 38 s of exponential backoff by default. Every failure reachable here is local — a corrupt
file, a missing asset, a database from the future — and none of them get better by waiting. Retrying
turns T06's refusal into half a minute of spinner on a screen that should be stating a fact.

**The fakes are bare `implements` and are driven by an enum.** No `Mock`, no `Fake` superclass, no
`noSuchMethod`: adding a method to an interface must be a compile error in every fake, not a runtime
surprise in one forgotten test. Each fake carries a `StoreEnv` field so "what happens when the store is
empty / the write fails" is a named case, and a spy list so a test can assert **what** was saved rather
than that saving happened. One value — `corruptButReportsOk` — exists only to be excluded from
`.detectable`, and its doc comment is the honest line that justifies E21's manual pass.

**Rejected: the `Command` pattern.** `FLUTTER_GUIDE.md` §1.7 — Riverpod's `AsyncValue` is a strict
superset, and building `Command` on top of it is two state machines that will drift apart. The one thing
kept is the idempotency rule: Riverpod gives no double-tap protection, so E13's intent methods guard it.

**Rejected: `get_it` alongside Riverpod.** Two DI mechanisms is strictly worse than one
(`state-management-riverpod` anti-patterns), and `ban-legacy-providers.sh` fails on it.

**Rejected: a repository holding a `Ref`.** `FLUTTER_GUIDE.md` §5.2 — a repository that takes a `Ref`
imports Riverpod, and a repository that imports Riverpod cannot be unit-tested without a container. They
take their DAOs by constructor.

## Tests first

Write every row before touching a repository. Run them. **They must fail.** Row 12 is the one that will
appear to pass early: a layering test that greps a directory with no files reports success, so it asserts
the file set is non-empty first — the failure mode `CONVENTIONS.md` §7 names.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ReferenceRepositoryDrift.speciesByPrefix returns Ok with the mapped species` | seeded fixture | `Ok`, domain types, no drift row class in the signature | The read path, and the boundary T10 enforces |
| 2 | `ReferenceRepositoryDrift.speciesById returns DataNotFound for an unknown id` | id 999 999 | `Err(DataNotFound)` carrying entity and id | An expected miss is a value, not an exception (`error-handling-typed-results` rule 1) |
| 3 | `ReferenceRepositoryDrift maps a SqliteException to DataStoreUnavailable` | closed database | `Err(DataStoreUnavailable)` | A `SqliteException` reaching a Notifier is the leak this boundary exists to stop |
| 4 | `ReferenceRepositoryDrift logs the original error before returning a failure` | spy logger | log recorded, then `Err` | Log first, then return — the stack trace is the only diagnostic an offline app ever gets |
| 5 | `MeasurementRepositoryDrift.recordCatch returns Ok and the watched stream re-emits` | listen, record | `Ok`, 2 emissions | The single write path plus persist-before-publish, end to end |
| 6 | `MeasurementRepositoryDrift.recordCatch returns DataConstraintViolated naming the field` | invalid `outcome` | `Err(DataConstraintViolated('outcome'))` | The best-effort column recovery, with its documented fallback |
| 7 | `MeasurementRepositoryDrift.watchTallyForDay returns a Stream, not a Stream of Result` | signature | `Stream<List<SpeciesTally>>` | `AsyncValue<Result<T>>` is four states where two are meaningful |
| 8 | `SettingsRepositoryDrift.watchProfile emits the singleton profile on subscription` | fresh database | 1 emission, `id` 1 | Every screen reads this; an empty first emission is a frame in the wrong unit |
| 9 | `SettingsRepositoryDrift.setLengthUnit rejects a unit outside cm, mm and in` | `'ft'` | `Err(DataConstraintViolated)` | The schema `CHECK` surfaced as a typed failure rather than an uncaught exception |
| 10 | `referenceRepositoryProvider throws when it is not overridden` | bare `ProviderContainer` | `UnimplementedError` | A forgotten wiring must fail loudly at first read, not construct a live database in a test |
| 11 | `dataOverrides constructs every database without awaiting an open` | call it, assert synchronous | returns without a microtask boundary; no file created | Rule 8: an awaited open before `runApp` is a black screen indistinguishable from a crash |
| 12 | `ReferenceRepository and MeasurementRepository do not import each other` | read both source trees | no import edge either way, and the file list is non-empty | `FLUTTER_GUIDE.md` §2.5 rule 3. A gate over an empty tree reports success |
| 13 | `every repository interface has a fake under testing/fakes/` | enumerate interfaces | one fake each | §2.5 rule 4, asserted rather than reviewed |
| 14 | `every public repository method returns Future<Result<T, DataFailure>> or Stream<T>` | reflect over the interfaces' sources | no other return type | §2.5 rule 5 — the rule that decays the first time someone returns a raw `Future<int>` |
| 15 | `$env: a recordCatch either persists or surfaces a typed failure` (loop over `StoreEnv.detectable`) | each fake env | persisted `\|\|` `Err` | The absence-of-a-failure-class test: silent loss here is a catch the fisher believes is recorded |
| 16 | `asOk appears nowhere under app/lib` | grep | no match | `FLUTTER_GUIDE.md` §1.6 point 4: an unchecked cast that throws on the error path and defeats the point |

```dart
// app/test/data/repositories/measurement_repository_test.dart
import 'package:catchlaw/data/repositories/data_failure.dart';
import 'package:catchlaw/data/repositories/measurement_repository_drift.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Err, Ok;

import '../../../testing/models/user_fixtures.dart';

void main() {
  late UserDatabase db;
  late MeasurementRepositoryDrift repository;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    repository = MeasurementRepositoryDrift(catches: db.catchDao, recents: db.speciesRecentDao);
  });

  test('MeasurementRepositoryDrift.recordCatch returns Ok and the watched stream re-emits', () async {
    final emissions = <int>[];
    final sub = repository.watchCatchesForTrip(1).listen((rows) => emissions.add(rows.length));
    addTearDown(sub.cancel);
    await pumpEventQueue();

    final result = await repository.recordCatch(kCatchDraftCentolla);
    await pumpEventQueue();

    expect(result, isA<Ok<CatchRecord, DataFailure>>());
    expect(emissions, [0, 1],
        reason: 'persist-before-publish: the commit is what makes the stream emit, not a manual push');
  });

  test('MeasurementRepositoryDrift.recordCatch returns DataConstraintViolated naming the field', () async {
    final result = await repository.recordCatch(kCatchDraftCentolla.copyWith(outcome: 'ok'));

    expect(
      result,
      isA<Err<CatchRecord, DataFailure>>().having(
        (e) => e.failure,
        'failure',
        isA<DataConstraintViolated>().having((f) => f.field, 'field', contains('outcome')),
      ),
    );
  });
}
```

```dart
// app/test/data/layering_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ReferenceRepository and MeasurementRepository do not import each other', () {
    final reference = _dartFilesUnder('lib/data/repositories', containing: 'reference_repository');
    final measurement = _dartFilesUnder('lib/data/repositories', containing: 'measurement_repository');

    expect(reference, isNotEmpty, reason: 'a scan of an empty tree reports success — CONVENTIONS 7');
    expect(measurement, isNotEmpty);

    for (final file in reference) {
      expect(file.readAsStringSync(), isNot(contains('measurement_repository')),
          reason: 'FLUTTER_GUIDE 2.5 rule 3: joins go in domain/use_cases/, not across repositories');
    }
    for (final file in measurement) {
      expect(file.readAsStringSync(), isNot(contains('reference_repository')));
    }
  });
}

List<File> _dartFilesUnder(String path, {required String containing}) => Directory(path)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart') && f.path.contains(containing))
    .toList();
```

## Implementation outline

1. Write `data_failure.dart`: `sealed class DataFailure extends Failure` with four `final class`
   subtypes, each `const`, each with a stable `code` and typed params, none with a sentence.
2. Write the three abstract interfaces with `abstract interface class`. Every fallible method returns
   `Future<Result<T, DataFailure>>` and carries `@useResult`; every reactive read returns `Stream<T>`.
3. Write the three drift implementations with `implements`, not `extends`. Each takes its DAOs by
   constructor and imports no Riverpod. Cross-table work (record a catch **and** stamp recents) lives
   here, not in a DAO.
4. Write one `_mapSqliteException` per boundary: `switch (e.resultCode)` with `19` →
   `DataConstraintViolated(_offendingColumn(e))` and a fallback to `DataTransactionRolledBack`.
   `_offendingColumn` is the documented best-effort regex with a fallback string.
5. Write `providers.dart` with five throwing placeholders, and `bootstrap_data.dart` with
   `dataOverrides` — synchronous, `ref.onDispose(db.close)` on each database provider, no `autoDispose`.
6. Wire the overrides plus `retry: (count, error) => null` into the `ProviderScope` in
   `app/lib/main.dart`. `main()` gains no `await`.
7. Write `reference_repository_fixture.dart` — the in-memory implementation E07's goldens will use — and
   the three fakes under `app/testing/fakes/` with their `StoreEnv` enums.
8. Re-run the suite. 16 green, and T07's and T08's still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 tests pass, and each failed first.
- [ ] Every repository has an abstract interface (`implements`, never `extends`), a drift implementation
      and a fake in `app/testing/fakes/`.
- [ ] Every public repository method returns `Future<Result<T, DataFailure>>` or `Stream<T>`; no stream
      is wrapped in a `Result`.
- [ ] `ReferenceRepository` and `MeasurementRepository` have no import edge in either direction.
- [ ] No repository imports Riverpod or holds a `Ref`.
- [ ] Every provider is a throwing placeholder until overridden; the database providers are plain
      `Provider`s with `ref.onDispose(db.close)`.
- [ ] `dataOverrides` is synchronous and `app/lib/main.dart` contains no `await`; check 1 of
      `check_reference_db.sh` is green.
- [ ] `retry: (count, error) => null` is set on the root `ProviderScope`.
- [ ] No `DataFailure` subtype carries a user-facing string; every one has a stable `code`.
- [ ] `asOk` appears nowhere in `app/lib/`; if it exists at all it is under `app/testing/`.
- [ ] Every fake is bare `implements` with no `Mock`/`Fake` superclass, and exposes failure.
- [ ] No `get_it`, no `package:provider`, no legacy Riverpod provider;
      `ban-legacy-providers.sh app/lib` is clean.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh      app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh     app/lib
$FLUTTER_SKILLS/state-management-riverpod/scripts/ban-legacy-providers.sh     app/lib
$FLUTTER_SKILLS/error-handling-typed-results/scripts/check-swallowed-catch.sh app/lib
$FLUTTER_SKILLS/persistence-drift/scripts/check-drift-confinement.sh          app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): put every repository behind an interface, a typed Result and a fake

Three repositories — reference, measurement, settings — each an abstract
interface with a drift implementation and a bare-implements fake. Fallible
methods return Future<Result<T, DataFailure>> with a sealed error arm, so a
switch at the call site is exhaustive and a new failure is a compile error
everywhere; reactive reads return a plain Stream, because AsyncValue over a
Result is four states where two are meaningful.

ReferenceRepository and MeasurementRepository have no import edge in either
direction. A screen that joins content to the fisher's record does it in a
use case. The test asserts the absence of the edge and asserts the file list
is non-empty first, because a scan of an empty tree reports success.

SqliteException is mapped to a typed failure once, at the boundary, after
logging (e, st) — the local stack trace is the only diagnostic an app that
cannot phone home will ever produce. Providers are throwing placeholders
overridden synchronously at the composition root, so nothing is awaited
before runApp, and the root scope sets retry: null: every failure reachable
here is local and none of them improve after 38 seconds of backoff.

Task: E05/T09
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
