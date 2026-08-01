# E16/T01 — The settings repository over `user_profile`

| | |
|---|---|
| **Epic** | E16 — Settings |
| **Branch** | `epic/16-settings` (shared) |
| **Commit** | `feat(data): add the settings repository over the user_profile singleton` |
| **Depends on** | E05 (the `user.db` drift schema and the `onCreate` singleton insert) |
| **Size** | M |
| **Spec** | `SPEC.md` §7.2 (`user_profile`), §7.4 (`onCreate` inserts the singleton row), §10 (`flutter_secure_storage` is banned) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Rule 6, the one-way layer map, and rule 11 — no identifier and no second store; this task is the one that decides where every user preference lives |
| `persistence-drift` | The DAO, the companion update, the single-row `watchSingleOrNull` stream, and `NativeDatabase.memory()` in tests |
| `state-management-riverpod` | Where the two providers go, why the repository takes no `Ref`, and why there is no `AsyncNotifier` here |
| `flutter-architecture` | The repository/service split and the abstract-interface-plus-fake rule this task instantiates |
| `error-handling-typed-results` | Whether these methods return `Result<T>` or bare `Future<void>`, and what a failed write on a singleton row even means |
| `testing-strategy` | Which level this belongs at — drift unit tests against an in-memory database, no widget binding |
| `naming-conventions` | `SettingsRepository` / `SettingsRepositoryDrift` / `FakeSettingsRepository` and the test names below |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §7.2, the `user_profile` DDL | The nine S14 columns, their types, their `CHECK` constraints and their defaults — this is the schema the repository maps, verbatim |
| `SPEC.md` | §7.4, "`user.db` uses drift's `MigrationStrategy`" | `onCreate` inserts the singleton row; the repository must not be a second inserter |
| `SPEC.md` | §10, "Explicitly banned" | `flutter_secure_storage` is banned by name and the app PIN is out of scope; there is no second preference store to reach for |
| `FLUTTER_GUIDE.md` | Part 1.4 | "the only place where that data type is mutated"; drift belongs behind a Service and the Repository opens it; repositories own app-wide session state |
| `FLUTTER_GUIDE.md` | Part 1.5 | `implements`, not `extends`; every repository gets an abstract interface and a fake |
| `FLUTTER_GUIDE.md` | Part 5.2 | "The repository takes no `Ref` and imports no Riverpod"; return the stream, do not `await for` it |
| `FLUTTER_GUIDE.md` | Part 5.3 | Why a single-row `StreamProvider` is the cheap case: drift row classes implement `==`, so an identical re-emit is filtered |
| `FLUTTER_GUIDE.md` | Part 5.5 | The anti-pattern this task refuses: an `AsyncNotifier` mirroring database rows into `state` |
| `FLUTTER_GUIDE.md` | Part 2.2 | File and class naming: `<entity>_repository.dart`, `<entity>_repository_<flavor>.dart`, `fake_<thing>.dart` |
| `FLUTTER_GUIDE.md` | Part 2.5 | The concrete tree — and the one place this task diverges from it, argued below |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §1, the allowed list | What a wholly offline app is permitted to touch; no identifier, no install UUID |
| `.claude/skills/catchlaw-conventions-index/references/routing-table.md` | Layer map | `lib/data/` maps rows into domain types; `lib/ui/` never queries a DAO |
| `epics/DECISIONS.md` | D-1 | Paths: the app is at `app/`, so every path below starts there |
| `epics/CONVENTIONS.md` | §5, §6 | Test naming, and `testing/` beside `lib/` and `test/` for fakes |

## What this delivers

- `app/lib/domain/models/user_settings.dart` — `UserSettings`, an immutable value type with a
  `const` constructor, `==`, `hashCode` and `copyWith`, carrying the nine S14 columns plus the two
  read-only calibration columns.
- `app/lib/domain/models/numeral_system.dart` — `enum NumeralSystem { auto, latn, arab }` with a
  `code` mapping to the three strings `SPEC.md` §7.2's `CHECK` constraint accepts.
- `app/lib/domain/models/length_unit.dart` — `enum LengthUnit { cm, mm, inch }`, `code` mapping to
  `'cm'`, `'mm'`, `'in'`. **If E09 already declares a display-unit enum under `app/lib/domain/models/`,
  this task reuses it and adds no second one** — see the definition of done.
- `app/lib/data/repositories/settings_repository.dart` — `abstract interface class SettingsRepository`.
- `app/lib/data/repositories/settings_repository_drift.dart` — `SettingsRepositoryDrift`, the only
  writer of the nine S14 columns.
- `app/lib/data/repositories/settings_providers.dart` — `settingsRepositoryProvider` (keepAlive) and
  `userSettingsProvider` (a `StreamProvider<UserSettings>`). A separate file, so neither repository
  file imports Riverpod.
- `app/testing/fakes/fake_settings_repository.dart` — `FakeSettingsRepository`, in-memory, seeded from
  `UserSettings.defaults`.
- `app/test/data/repositories/settings_repository_test.dart` — the contract suite, run against both
  implementations.
- `app/test/data/repositories/settings_repository_drift_test.dart` — the drift-only cases.

No UI. No ARB keys. Nothing on screen changes in this commit.

## Why it is built this way

**One row, one repository, no second store.** `SPEC.md` §7.2 puts all nine S14 settings in
`user_profile`, a table whose primary key carries `CHECK (id = 1)`. That is not incidental: a settings
value that lived in `shared_preferences` would sit outside `user.db`, outside the migration strategy of
§7.4, outside the export of §12 and outside T07's raw-database escape hatch — the user would copy their
database to a laptop and find their own preferences missing from it. `SPEC.md` §10 bans
`flutter_secure_storage` by name, and there is nothing secret here to justify reaching past the ban.

**Rejected: `settings_repository_prefs.dart`.** `FLUTTER_GUIDE.md` §2.5's concrete tree literally lists
`settings_repository.dart + _prefs.dart`. That tree is a general Flutter sketch; `SPEC.md` §7.2 is the
product, and the product says these are columns. The implementation file is therefore
`settings_repository_drift.dart`. This is the one place this task diverges from the guide's tree, and
it diverges deliberately.

**Rejected: a `SettingsViewModel` as an `AsyncNotifier` holding the nine fields.**
`FLUTTER_GUIDE.md` §5.5 lists "an `AsyncNotifier` mirroring database rows into `state`" as its first
anti-pattern, and §5.2 shows why it is unnecessary: the write marks the table dirty, drift re-runs the
watching query, the `StreamProvider` emits, the widget rebuilds. There is no state to hold. The read
path is one `StreamProvider`; every write is `ref.read(settingsRepositoryProvider).setX(...)` from a
callback.

**Nine narrow setters, not one `save(UserSettings)`.** The result screen's sunlight long-press (E10)
and S14 can both be alive on one navigation stack. A `save(UserSettings)` built from a snapshot read
before the other screen wrote would push nine stale column values over one fresh one — last-writer-wins
across the whole row, for a change the user made in a different place two seconds ago. Each setter
issues an `UPDATE` of exactly one column, so two concurrent writers of different columns cannot
interfere. T04 has the test that proves it.

**One column, one writer.** E09 writes `ruler_px_per_mm` and `ruler_calibrated_at`; calibration is a
measurement act, not a preference, and its plausibility gate lives in E09
(`catchlaw-measurement-ruler` rule 8). `SettingsRepository` therefore **exposes those two columns and
offers no setter for them**. `FLUTTER_GUIDE.md` §1.4's "only place where that data type is mutated" is
satisfied at column granularity rather than table granularity, which is checkable by grep and does not
require an E09 refactor inside an E16 diff.

**The singleton row is self-healing.** §7.4 says `onCreate` inserts it, so in a healthy install it is
always there. It is not always there in a `user.db` restored from an import, opened from a fixture, or
half-migrated. A repository that throws `StateError` on `getSingle()` would turn S14 into a dead screen
on a boat. `watch()` therefore uses `watchSingleOrNull()` and maps `null` to `UserSettings.defaults`,
and every setter is an `insertOnConflictUpdate` keyed on `id: 1` rather than a bare `UPDATE`, so the
first write after a loss restores the row. There is a test for each half.

**`Future<void>`, not `Future<Result<void>>`.** `FLUTTER_GUIDE.md` §1.6 introduces `Result` for
operations with a meaningful failure a caller can act on. A single-column update against a local
SQLite row the app owns has exactly one failure mode — the database is unopenable — and that is
already the app's fatal path, not a per-setting error surface. The read side returns
`Stream<UserSettings>` per §5.2, and `AsyncError` on that stream is the surface. Nesting
`AsyncValue<Result<T>>` is §5.5's fourth anti-pattern.

**Where the providers live.** Not in `app/lib/ui/settings/`, because `MaterialApp` reads this stream
for the locale (T02) and the theme (T04) long before S14 is on screen. Not inside the repository
files, because §5.2 is explicit that the repository takes no `Ref` and imports no Riverpod — that is
what makes it unit-testable. So: a third file, `settings_providers.dart`, beside them in
`app/lib/data/repositories/`.

## Tests first

Write every row before touching any implementation file. Run them. **They must fail.** A test that
passes before `SettingsRepositoryDrift` exists is testing the fake, or testing nothing — fix the test.

Rows 1–9 are the **contract suite**: one test body, executed once per implementation, with the
implementation name interpolated into the description (`CONVENTIONS.md` §5). Rows 10–17 are drift-only,
because they assert against SQL the fake does not have.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `$impl.watch emits the §7.2 defaults on a fresh database` | freshly created `user.db` | `numeralSystem: auto`, `lengthUnit: cm`, `captureCoordinates: false`, `sunlightMode: false`, `gloveMode: false`, all four nullable columns `null` | These five defaults are written in `SPEC.md` §7.2's DDL; if the mapping inverts a `0`/`1` this is the only test that notices |
| 2 | `$impl.setNumeralSystem re-emits with the new value` | `setNumeralSystem(NumeralSystem.arab)` | stream's second event has `numeralSystem: arab` | The read path and the write path must be the same row; a setter that writes a different table emits nothing |
| 3 | `$impl.setLocaleOverride(null) clears an existing override` | set `'gl'`, then `null` | second read has `localeOverride: null` | `null` means "follow the system" (`SPEC.md` §11 Both). A setter that treats `null` as "no change" makes the override permanent |
| 4 | `$impl.setSunlightMode leaves gloveMode unchanged` | `setGloveMode(true)`, then `setSunlightMode(true)` | both `true` | The narrow-setter rationale: a whole-row write from a stale snapshot would revert `gloveMode` here |
| 5 | `$impl.setActiveZone stores jurisdiction and zone together` | `setActiveZone(jurisdiction: 'ES-GA', zone: 'RIAS-BAIXAS')` | both columns set | The two columns are meaningless apart — a zone code without its jurisdiction resolves against the wrong rule set |
| 6 | `$impl.watch emits UserSettings.defaults when the singleton row is absent` | delete the row, then read | `UserSettings.defaults` | An imported or half-migrated `user.db` must not make S14 a dead screen |
| 7 | `$impl.setGloveMode restores the singleton row when it is absent` | delete the row, `setGloveMode(true)`, read | `gloveMode: true`, one row present | The self-healing write; a bare `UPDATE` would affect zero rows and silently do nothing |
| 8 | `$impl.setNumeralSystem stores $value` (loop over all 3) | each `NumeralSystem` | round-trips to the same enum | Every value must survive the enum→code→enum trip; `SPEC.md` §7.2's `CHECK` accepts only `'auto'`, `'latn'`, `'arab'` |
| 9 | `$impl.setLengthUnit stores $value` (loop over all 3) | each `LengthUnit` | round-trips to the same enum | `LengthUnit.inch` must persist as `'in'`, not `'inch'` — the `CHECK` constraint rejects `'inch'` and the failure is a runtime exception, not a compile error |
| 10 | `SettingsRepositoryDrift.setLengthUnit writes 'in' for LengthUnit.inch` | `LengthUnit.inch` | the raw column value is `'in'` | Reads the column as text, not through the mapper — proves the mapper and the schema agree rather than proving the mapper agrees with itself |
| 11 | `SettingsRepositoryDrift.setCaptureCoordinates writes an INTEGER` | `true` | raw value is `1`, and its SQLite type is `integer` | §7.2 declares `INTEGER NOT NULL DEFAULT 0`; a `'true'` text would satisfy SQLite's dynamic typing and break every later boolean read |
| 12 | `SettingsRepositoryDrift.watch reports the calibration written by MeasurementRepository` | write `ruler_px_per_mm` through E09's path | `watch` emits it | The read-through half of one column, one writer |
| 13 | `SettingsRepositoryDrift exposes no setter for ruler_px_per_mm` | the interface's member list | no member name contains `pxPerMm` or `calibrat` in a write position | The write half; this is the assertion that keeps a second writer out of the calibration columns |
| 14 | `SettingsRepositoryDrift.watch does not re-emit when a catch row is inserted` | insert into `catch` | exactly one event | drift re-runs queries per table (`FLUTTER_GUIDE.md` §5.3); if this fails the query is joining tables it does not need and every catch will rebuild the whole app |
| 15 | `SettingsRepositoryDrift.watch does not re-emit when the same value is written twice` | `setGloveMode(true)` twice | exactly two events, the second identical and filtered by `==` at the provider | The `==` win from `FLUTTER_GUIDE.md` §5.3; it only works if `UserSettings` implements `==`, and this test is what fails when someone adds a field and forgets it |
| 16 | `SettingsRepositoryDrift.setNumeralSystem rejects a code outside the CHECK constraint` | a hand-built companion with `'eastern'` | throws | Proves the constraint is live in the built database rather than only in the DDL text |
| 17 | `UserSettings.copyWith replaces only the named field` | `copyWith(gloveMode: true)` | every other field identical, `==` to the original except that field | `copyWith` is the fake's whole implementation; an over-eager `copyWith` makes rows 4 and 7 pass for the wrong reason |

```dart
// app/test/data/repositories/settings_repository_test.dart
import 'package:catchlaw/data/repositories/settings_repository.dart';
import 'package:catchlaw/data/repositories/settings_repository_drift.dart';
import 'package:catchlaw/domain/models/length_unit.dart';
import 'package:catchlaw/domain/models/numeral_system.dart';
import 'package:catchlaw/domain/models/user_settings.dart';
import 'package:catchlaw/testing/fakes/fake_settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

typedef RepoFactory = ({String name, SettingsRepository Function() build});

void main() {
  final factories = <RepoFactory>[
    (name: 'FakeSettingsRepository', build: FakeSettingsRepository.new),
    (
      name: 'SettingsRepositoryDrift',
      build: () => SettingsRepositoryDrift(UserDatabase(NativeDatabase.memory())),
    ),
  ];

  for (final f in factories) {
    // The implementation name is interpolated, or --plain-name selects both at once.
    test('${f.name}.watch emits the §7.2 defaults on a fresh database', () async {
      final repo = f.build();
      final settings = await repo.watch().first;
      expect(settings.numeralSystem, NumeralSystem.auto);
      expect(settings.lengthUnit, LengthUnit.cm);
      expect(settings.captureCoordinates, isFalse);
      expect(settings.sunlightMode, isFalse);
      expect(settings.gloveMode, isFalse);
      expect(settings.localeOverride, isNull);
    });

    test('${f.name}.setSunlightMode leaves gloveMode unchanged', () async {
      final repo = f.build();
      await repo.setGloveMode(true);
      await repo.setSunlightMode(true);
      final settings = await repo.watch().first;
      expect(settings.gloveMode, isTrue);
      expect(settings.sunlightMode, isTrue);
    });

    for (final unit in LengthUnit.values) {
      test('${f.name}.setLengthUnit stores ${unit.name}', () async {
        final repo = f.build();
        await repo.setLengthUnit(unit);
        expect((await repo.watch().first).lengthUnit, unit);
      });
    }

    // … one test per contract row above, one behaviour each
  }
}
```

```dart
// app/test/data/repositories/settings_repository_drift_test.dart
import 'package:catchlaw/data/repositories/settings_repository_drift.dart';
import 'package:catchlaw/domain/models/length_unit.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late UserDatabase db;
  late SettingsRepositoryDrift repo;

  setUp(() {
    db = UserDatabase(NativeDatabase.memory());
    repo = SettingsRepositoryDrift(db);
  });
  tearDown(() => db.close());

  test('SettingsRepositoryDrift.setLengthUnit writes \'in\' for LengthUnit.inch', () async {
    await repo.setLengthUnit(LengthUnit.inch);
    final row = await db
        .customSelect('SELECT length_unit FROM user_profile WHERE id = 1')
        .getSingle();
    expect(row.read<String>('length_unit'), 'in');
  });

  test('SettingsRepositoryDrift.watch does not re-emit when a catch row is inserted', () async {
    final events = <void>[];
    final sub = repo.watch().listen((_) => events.add(null));
    await pumpEventQueue();
    await db.customStatement(
      "INSERT INTO catch (jurisdiction_code, zone_code, species_id, scientific_name, "
      "outcome, was_kept, created_at, updated_at) "
      "VALUES ('ES-GA','RIAS-BAIXAS',1,'Epinephelus coioides','meets',0,'2026-08-01','2026-08-01')",
    );
    await pumpEventQueue();
    expect(events, hasLength(1));
    await sub.cancel();
  });

  // … one test per drift-only row above
}
```

**Run:** `cd app && flutter test test/data/repositories/` → 23 failures (9 contract rows × 2
implementations, minus the 4 loop expansions counted once each, plus 8 drift-only rows). If any passes
now, the test is wrong.

## Implementation outline

Only after the tests are red.

1. `user_settings.dart`, `numeral_system.dart`, `length_unit.dart` — value types first, with
   `UserSettings.defaults` mirroring the §7.2 DDL defaults exactly. Each enum carries a `code` getter
   and a `fromCode` factory that throws on an unknown code rather than silently defaulting.
2. `settings_repository.dart` — the abstract interface: one `Stream<UserSettings> watch()`, nine
   setters, no calibration setter. Doc comments per `dartdoc-conventions` on every member; the
   interface is public API.
3. `settings_repository_drift.dart` — `implements SettingsRepository` (not `extends`;
   `FLUTTER_GUIDE.md` §1.5). `watch()` selects the singleton row and maps `null` to
   `UserSettings.defaults`. Each setter is one `insertOnConflictUpdate` on `id: 1` with a single
   `Value(...)` set and everything else `Value.absent()`.
4. `settings_providers.dart` — `@Riverpod(keepAlive: true) SettingsRepository settingsRepository(Ref)`
   and `@riverpod Stream<UserSettings> userSettings(Ref)`. Run codegen.
5. `fake_settings_repository.dart` — a `BehaviorSubject`-shaped `StreamController.broadcast()` seeded
   with `UserSettings.defaults`, each setter a `copyWith` plus an `add`. It lives in `app/testing/`, not
   `app/test/`, so goldens and `integration_test/` can use it (`CONVENTIONS.md` §6).
6. Re-run the suite. All green, and every E05 and E09 test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 17 rows pass, and each failed first.
- [ ] `grep -rn "shared_preferences\|flutter_secure_storage\|GetStorage\|Hive" app/` returns nothing,
      in `app/pubspec.yaml` as well as in `app/lib` (`SPEC.md` §10).
- [ ] `grep -rn "class .*LengthUnit\|enum LengthUnit" app/lib` returns exactly one declaration; if E09
      already declared a display-unit enum, this task reused it and deleted nothing else.
- [ ] `grep -rn "UserProfileCompanion" app/lib` shows writes only from `settings_repository_drift.dart`
      and from E09's calibration write — one column, one writer.
- [ ] `grep -rn "riverpod" app/lib/data/repositories/settings_repository.dart
      app/lib/data/repositories/settings_repository_drift.dart` returns nothing
      (`FLUTTER_GUIDE.md` §5.2).
- [ ] `UserSettings` implements `==` and `hashCode` over all eleven fields; adding a field without
      updating them fails row 15.
- [ ] The abstract interface has a doc comment on every member; `SettingsRepositoryDrift` has none
      restating them.
- [ ] `packages/rule_engine/` is untouched by this commit.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh       app/lib
```

`check_measurement.sh` is here because this task introduces a length-unit type; its check 1 fails a
length declared as `double` or `String`, which is exactly the mistake a "unit" enum invites
(`catchlaw-measurement-ruler` rule 1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(data): add the settings repository over the user_profile singleton

Every setting on S14 is a column of one row (SPEC 7.2), so there is no
second preference store to add and none is added: shared_preferences and
flutter_secure_storage are both absent, the latter banned by SPEC 10. The
setters are one per column rather than one save(UserSettings), because the
result screen's sunlight long-press and S14 can be alive at once and a
whole-row write from a stale snapshot silently reverts the other's change.

The two calibration columns are exposed and have no setter: E09 owns that
write, and one column with one writer is checkable by grep without moving
code across an epic boundary.

A missing singleton row maps to UserSettings.defaults and the first write
restores it, because an imported user.db that has lost the row must not
make Settings a dead screen at sea.

Task: E16/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
