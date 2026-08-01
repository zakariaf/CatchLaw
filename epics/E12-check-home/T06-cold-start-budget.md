# E12/T06 — Cold start under 1.2 s, with nothing awaited before `runApp`

| | |
|---|---|
| **Epic** | E12 — Check home and the navigation shell |
| **Branch** | `epic/12-check-home` (shared) |
| **Commit** | `feat(check): make Check interactive under 1.2 s with nothing awaited before runApp` |
| **Depends on** | T01, T02 (the launch path is the shell plus S1) |
| **Size** | L |
| **Spec** | `SPEC.md` §13 (first launch < 6 s determinate; cold start < 1.2 s), §3 step 1 (no splash), §7.4 (the marker), §14 (the dynamic first-launch rows) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `app-startup-and-bootstrap` | Owns `main.dart`, `bootstrap.dart`, the first-launch extraction and the frame budget. This task is that skill's subject matter. |
| `catchlaw-conventions-index` | Invariant 8 — nothing is awaited before `runApp` — plus invariant 7's read-only open. Gate check 8 is the executable form. |
| `state-management-riverpod` | `LazyDatabase` behind provider overrides, and letting `AsyncLoading` cover the open instead of blocking the first frame. |
| `flutter-performance` | `const` subtrees on the launch path, sized image decode, and what actually costs a frame on a 2 GB Android 7 device. |
| `lonja-lists-and-tables` | The loading body is a ruled skeleton and never a spinner; the one place a determinate bar is allowed is the first-launch seed. |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §13, rows 1 and 2 | First launch < 6 s with a **determinate** indicator; subsequent cold start < 1.2 s on a Snapdragon 665, met by a lazy read-only open, recents from an indexed query, no asset decoding on the launch path, no splash animation |
| `SPEC.md` | §13, "Low-end devices" | No image caching beyond the visible grid; SVGs rasterised at display size; plates only on S2 |
| `SPEC.md` | §3 step 1 | No splash, no login, no onboarding, no what's-new |
| `SPEC.md` | §7.4 | The generated Dart constant compared against `app_meta.content_build_date` — the decision needs no database open |
| `SPEC.md` | §7.2, `species_recent` | `WITHOUT ROWID`, primary key `(species_id, jurisdiction_code, zone_code)` |
| `SPEC.md` | §14, dynamic rows 1 and 2 | Cold first launch in airplane mode reaches Check under 6 s; force-quit mid-extraction restarts cleanly |
| `FLUTTER_GUIDE.md` | Part 5.2 | The exact `main()` shape: `LazyDatabase`, `NativeDatabase.createInBackground`, never `await` a database open before `runApp` |
| `FLUTTER_GUIDE.md` | Part 8.2 | The measured `const` subtree short-circuit and the zero-allocation-per-build argument on a low-end heap |
| `FLUTTER_GUIDE.md` | Part 5.3 | `List.==` is identity: an unscoped list provider rebuilds every consumer on every re-query |
| `.claude/skills/catchlaw-conventions-index/SKILL.md` | rules 7, 8 | Read-only open; nothing awaited before `runApp`; the right and wrong `main()` side by side |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariant 1 | The allowed I/O list: `rootBundle`, `getApplicationSupportDirectory()` — and nothing that opens a socket |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Loading skeleton" | Six skeleton rows, no spinner, no percentage — except the first-launch seed, where a determinate bar is the one exception |
| `epics/DECISIONS.md` | D-6 | The five mechanisms of the reference database: gz asset, temp file, atomic rename, sha256, JSON marker, read-only open |
| `epics/CONVENTIONS.md` | §7 | Gate scripts take an explicit target directory and exit 2 on a missing one |

## What this delivers

- `app/lib/main.dart` — `void main() => runApp(const ProviderScope(...))`. Not `async`, no `await`, no
  work before the first frame beyond `WidgetsFlutterBinding.ensureInitialized()`.
- `app/lib/bootstrap.dart` — the provider overrides and the two `LazyDatabase` executors, with the
  extraction decision made from the generated constant versus `app_meta.content_build_date` (§7.4, D-6).
- `app/lib/ui/check/view_models/check_view_model.dart` — the recents query capped and scoped in SQL.
- `app/test/startup/no_await_before_run_app_test.dart` — a source-level test over `main.dart`.
- `app/test/startup/launch_path_assets_test.dart` — a source-level test over the launch-path file set.
- `app/test/startup/start_up_budget_test.dart` — reads `build/start_up_info.json` when a device run has
  produced one; skipped, with a message naming the command, when it has not.
- `app/test/ui/check/check_first_frame_test.dart` — the first frame paints without the query.
- `app/integration_test/first_launch_test.dart` — the determinate indicator, and the app reaching Check.

## Why it is built this way

**The await ban and the 1.2 s budget are one property, so they are one task.** Every `await` before
`runApp` is a black screen, and a black screen on a boat is indistinguishable from a crashed app. The
budget in §13 is not met by making the work faster; it is met by not doing the work before the first
frame. `LazyDatabase` defers all file I/O until the first query and
`NativeDatabase.createInBackground` puts SQLite on a background isolate, so the first frame paints the
shell with `check` selected — which `nav-anatomy-and-states.md` requires to happen before any database
read completes — and the recents strip resolves under an `AsyncLoading` skeleton a frame or two later.

**"Recents from one indexed query" needs a precise reading.** §13's phrase cannot be literally true:
`species_recent` is in `user.db` and the display names and silhouettes are in `reference.db`, which are
two files by design (§7, D-6). The honest reading, and what this task tests, is **one indexed statement
per database and no per-row lookup**: an index range scan on `species_recent`'s primary key for the six
ids, and one `WHERE id IN (…)` against `species`/`species_name`. Six round trips instead of two would
turn a sub-frame read into a visible stall on the device §13 names.

**Rejected: `ATTACH`-ing `reference.db` to `user.db` to make it literally one query.** It couples the
two files' lifetimes, which is the thing D-6 and §7 separate on purpose — a content update replaces
`reference.db` wholesale and must never be able to touch the catch log. It also forces `reference.db`
open before the first `user.db` query, reintroducing exactly the launch-path dependency this task
removes.

**Rejected: precaching the six silhouettes on the launch path.** §13 says no asset decoding on the
launch path and no image caching beyond the visible grid. The silhouettes decode as the strip lays out,
at display size, and the plates load only on S2.

**Rejected: a splash screen "to cover the gap".** §3 step 1 and §13 both forbid it, and it would be
self-defeating: a splash animation is the asset decoding and the frame budget it claims to hide.

**Rejected: asserting the 1.2 s figure in CI.** GitHub's runners are not a Snapdragon 665 and an
emulator number would be a fiction dressed as a gate. CI asserts the two structural properties that
make the budget reachable — no await before `runApp`, no asset decoding on the launch path — and the
wall-clock figure comes from `flutter run --profile --trace-startup` on a physical device, which writes
`build/start_up_info.json` with `timeToFirstFrameRasterizedMicros`. `start_up_budget_test.dart` reads
that file when it exists, so the number is checkable and versionable rather than remembered.

**First launch is a separate budget and keeps its determinate bar.** §13 carves out < 6 s explicitly
because a ~10 MB extraction plus an FTS index build cannot fit the interactive target. E05 owns the
extraction, the temp file, the atomic rename and the sha256 (D-6). This task owns two facts about it:
the first frame still paints immediately, and the indicator is determinate — the one place
`the-four-states.md` allows a progress bar at all, because there a real count exists.

## Tests first

Write every row before touching `main.dart`. Run them. **They must fail.** The await test is the one
most likely to pass early — if it does, read `main.dart`: either it is already correct, in which case
the test must be strengthened to also cover `bootstrap.dart`, or the matcher is not matching.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `main declares no await before runApp` | parse `app/lib/main.dart` | no `async` on `main`, no `await` before the `runApp` call | Invariant 8; the same property gate check 8 greps for |
| 2 | `bootstrap declares no await outside a LazyDatabase callback` | parse `bootstrap.dart` | every `await` is inside a deferred callback | The await moves to `bootstrap.dart` the moment `main.dart` is cleaned |
| 3 | `The launch path decodes no asset` | scan the launch-path file set | no `precacheImage`, `rootBundle.load`, `Image.asset` outside a lazily built subtree | §13: no asset decoding on the launch path |
| 4 | `The launch path shows no splash animation` | scan the launch-path file set | no animation controller, no timed route on the way to Check | §3 step 1 and §13 both forbid it |
| 5 | `AppShell paints the nav strip before any database query resolves` | providers left pending, one `pump` | five cells rendered, `check` selected | `nav-anatomy-and-states.md`: the strip renders before any read completes and never shows a spinner |
| 6 | `CheckScreen paints its first frame while the recents query is pending` | one `pump` | skeleton, no exception, no spinner | `AsyncLoading` covers the open (`FLUTTER_GUIDE.md` Part 5.2) |
| 7 | `ReferenceDatabase opens on its first query and not before` | build the shell, no query | open count 0; after one query, 1 | `LazyDatabase`'s whole purpose, and the difference between 1.2 s and a black screen |
| 8 | `ReferenceDatabase opens read-only` | first query | `readOnly: true` | Invariant 7 and D-6: a writable open leaves a `-wal` that breaks every later sha256 check |
| 9 | `UserDatabase opens on its first query and not before` | as row 7 | same | Both databases, one rule |
| 10 | `Recents query reads at most six rows` | 20 rows seeded | 6 | The cap is in SQL because it is on this budget |
| 11 | `Recents query scans the species_recent primary key for the active zone` | explain the statement | index scan, no table scan | §7.2 made the table `WITHOUT ROWID` with that key for this read |
| 12 | `Recents query issues one statement per database and no per-row lookup` | count statements | 2, not 7 | The N+1 that turns a sub-frame read into a stall |
| 13 | `The extraction decision reads no database` | fresh install fixture | decision made from the generated constant and the marker only | §7.4: the first draft's design was circular |
| 14 | `First launch shows a determinate indicator while the reference database is extracted` | integration, fresh install | a determinate progress value, never indeterminate | §13's carve-out and §14's first dynamic row |
| 15 | `First launch reaches Check after extraction completes` | integration, fresh install | Check on screen | §14 row 1 |
| 16 | `Cold start to interactive Check stays under 1200 ms on the reference device` | `build/start_up_info.json` present | `timeToFirstFrameRasterizedMicros` < 1,200,000 | §13's number, checkable rather than remembered; skipped with a message when the file is absent |

```dart
// app/test/startup/no_await_before_run_app_test.dart
import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('main declares no await before runApp', () {
    final source = File('lib/main.dart').readAsStringSync();
    final beforeRunApp = source.substring(0, source.indexOf('runApp('));

    expect(RegExp(r'\bFuture<void>\s+main\b').hasMatch(source), isFalse,
        reason: 'an async main is an await before the first frame');
    expect(beforeRunApp.contains('await '), isFalse,
        reason: 'invariant 8: every await before runApp is a black screen');
  });

  test('The launch path decodes no asset', () {
    const launchPath = <String>[
      'lib/main.dart',
      'lib/bootstrap.dart',
      'lib/ui/core/ui/app_shell.dart',
      'lib/ui/core/ui/lonja_nav_strip.dart',
      'lib/ui/check/check_screen.dart',
    ];
    const banned = ['precacheImage', 'rootBundle.load', 'AnimationController'];

    for (final path in launchPath) {
      final source = File(path).readAsStringSync();
      for (final symbol in banned) {
        expect(source, isNot(contains(symbol)), reason: '$symbol on the launch path in $path');
      }
    }
  });
}
```

```dart
// app/test/startup/start_up_budget_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  final info = File('../build/start_up_info.json');

  test('Cold start to interactive Check stays under 1200 ms on the reference device', () {
    final json = jsonDecode(info.readAsStringSync()) as Map<String, dynamic>;

    expect(json['timeToFirstFrameRasterizedMicros'] as int, lessThan(1200000),
        reason: 'SPEC.md §13: subsequent cold start to interactive Check');
  },
      skip: info.existsSync()
          ? false
          : 'no device profile recorded — run: flutter run --profile --trace-startup');
}
```

```dart
// app/test/ui/check/check_first_frame_test.dart
testWidgets('AppShell paints the nav strip before any database query resolves', (tester) async {
  await tester.pumpWidget(pendingApp()); // providers overridden with never-completing streams
  await tester.pump();

  expect(find.byType(LonjaNavStrip), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsNothing);
  expect(selectedDestination(tester), LonjaDestination.check);
});
```

**Run:** `cd app && flutter test test/startup test/ui/check/check_first_frame_test.dart` → 14 failures
plus one skip. Run the two integration rows with
`flutter test integration_test/first_launch_test.dart` on a device with the app freshly installed.

## Implementation outline

1. Reduce `main.dart` to `WidgetsFlutterBinding.ensureInitialized()` and `runApp`. Everything that
   currently awaits moves behind a `LazyDatabase` callback or into a provider.
2. `bootstrap.dart`: both executors as in `FLUTTER_GUIDE.md` Part 5.2 — `LazyDatabase` +
   `NativeDatabase.createInBackground`, `readOnly: true` on the reference file. The extraction decision
   compares the generated build-date constant with `app_meta.content_build_date` and opens nothing to
   make it (§7.4).
3. `ProviderScope(retry: (retryCount, error) => null, overrides: [...])` — an offline app never retries;
   a retry loop is a spinner that never resolves.
4. Cap and scope the recents statement in SQL. One statement per database; assemble the six tiles from
   the two result sets in the repository, not with a per-row lookup.
5. Give the launch-path widgets `const` constructors wherever the analyzer allows
   (`FLUTTER_GUIDE.md` Part 8.2) and confirm `dart fix --apply` leaves nothing.
6. Wire the determinate first-launch indicator into the shell as a body that the first frame can paint
   over: the frame is not blocked on the extraction, and the bar reports a real fraction.
7. Run `flutter run --profile --trace-startup` on the reference device, twice: the first launch to seed
   the database and the second for the number. Paste the figure into the PR body.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 unit and widget rows pass, and each failed first; the two integration rows pass on a
      device with a fresh install.
- [ ] `main.dart` is not `async` and contains no `await`.
- [ ] `check_app_invariants.sh` check 8 (an awaiting `main()` ahead of `runApp`) is clean.
- [ ] Neither database is opened by building the shell; both open on their first query.
- [ ] `reference.db` is opened `readOnly: true` (invariant 7, D-6).
- [ ] The recents read is two statements, both index-backed, capped at six in SQL.
- [ ] No `precacheImage`, `rootBundle.load` or `AnimationController` on the launch-path file set.
- [ ] `build/start_up_info.json` from the reference device reports
      `timeToFirstFrameRasterizedMicros` < 1,200,000, and the figure is in the PR body.
- [ ] The first-launch indicator is determinate, and the first frame paints before extraction finishes.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh  app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh   app/lib
```

On the device, once:

```bash
cd app && flutter run --profile --trace-startup
# writes build/start_up_info.json; timeToFirstFrameRasterizedMicros must be < 1200000
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(check): make Check interactive under 1.2 s with nothing awaited before runApp

SPEC.md §13's 1.2 s is not met by making the launch work faster; it is met by
not doing it before the first frame. main() is no longer async, both databases
open through LazyDatabase on their first query, and reference.db opens
readOnly so no -wal appears beside a file whose sha256 is checked. The shell
paints with check selected before any read completes.

§13's "recents from one indexed query" cannot be literally true — species_recent
is in user.db and the names are in reference.db, two files by design. The
honest reading, now tested, is one indexed statement per database and no
per-row lookup. ATTACH would satisfy the literal wording and couple two files
that D-6 separates so a content update can never touch the catch log.

The 1.2 s figure itself comes from flutter run --profile --trace-startup on a
physical device; CI asserts the two structural properties that make it
reachable, because an emulator number would be a fiction dressed as a gate.

Task: E12/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
