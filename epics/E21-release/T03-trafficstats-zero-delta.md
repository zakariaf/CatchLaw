# E21/T03 — TrafficStats, and a delta of exactly zero

| | |
|---|---|
| **Epic** | E21 — Offline verification and release readiness |
| **Branch** | `epic/21-release` (shared) |
| **Commit** | `test(ci): assert a zero per-uid TrafficStats delta across the full walkthrough` |
| **Depends on** | T02 (the walkthrough this brackets, and the exercise script the manual run follows) |
| **Size** | M |
| **Spec** | `SPEC.md` §14 dynamic row 20; §11 Android; §5.3 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | Rule 12 and `references/verification-ritual.md`'s failure triage — specifically the row that says a clean Android result can be clean because the kernel refused the socket, which is why the diagnostic run keeps `INTERNET` |
| `service-boundary-and-native` | Rule 10: every `MethodChannel` lives under `lib/native/` and nothing else creates one. This task deliberately adds none, and the reasoning for that is the core of its design |
| `testing-strategy` | Rule 1 (cheapest tier that can assert the behaviour) and the manual-handoff rule — the counters are an instrumentation-tier fact and cannot be faked downward |
| `ci-pipeline-and-gates` | Rule 10: be honest about what CI cannot prove. This measurement cannot run on a hosted runner and must not be presented as though it does |
| `catchlaw-conventions-index` | Invariant 1, and the check that the measurement apparatus did not leak into `app/lib` |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §14 dynamic row 20 | `TrafficStats.getUidRxBytes` / `getUidTxBytes` before and after the full walkthrough; delta must be **exactly zero** |
| `SPEC.md` | §11 Android | minSdk 24; the release manifest grants no `INTERNET`; debug and profile retain it by design |
| `SPEC.md` | §5.3 | Why Android's guarantee is OS-enforced and iOS's is not — the asymmetry this task exploits |
| `FLUTTER_GUIDE.md` | Part 4.6 layer 2, Part 9.3 | `flutter run` injects `INTERNET` via the debug manifest; that is expected and fine |
| `.claude/skills/catchlaw-offline-guarantee/references/verification-ritual.md` | "Pass criteria", "Failure triage" | The INVALID cases, and the row about layer 2 masking a real call |
| `.claude/skills/catchlaw-offline-guarantee/SKILL.md` | rules 4, 12 | Debug and profile keep `INTERNET`, and that is correct; release evidence is a capture, not a proxy |
| `service-boundary-and-native` → `references/native-channels.md` (Flutter-Skills plugin) | "Every MethodChannel lives under `lib/native/`" | The rule this task honours by not adding a channel at all |
| `service-boundary-and-native` → `SKILL.md` (Flutter-Skills plugin) | rules 1, 10 | Injected interfaces for side effects; channels confined to one directory |
| `epics/CONVENTIONS.md` | §5, §6, §9 | Test naming applies to the Kotlin rule too; where integration tests live; the invariants |
| `epics/DECISIONS.md` | D-1 | `app/` holds the Flutter project, so the Android tree is `app/android/` |

## What this delivers

- `app/android/app/src/androidTest/kotlin/<applicationId-path>/TrafficStatsRule.kt` — a JUnit4
  `TestWatcher` that reads `TrafficStats.getUidRxBytes(Process.myUid())` and `getUidTxBytes` in
  `starting()` and again in `finished()`, records `Process.myUid()` at both reads, and fails the run on
  a non-zero delta, on an `UNSUPPORTED` (`-1`) reading, or on a uid that changed between reads.
- `app/android/app/src/androidTest/kotlin/<applicationId-path>/MainActivityTest.kt` — the standard
  Flutter instrumentation entry point, with `TrafficStatsRule` added as a second `@Rule` so it brackets
  the entire Dart suite that runs inside it.
- `docs/release/traffic-stats.md` — the procedure: which build type, which command, what a `-1` means,
  the `adb shell dumpsys netstats detail` cross-check, and why a reinstall between the two reads voids
  the run.
- `app/test/policy/measurement_harness_isolation_test.dart` — asserts the apparatus stayed out of the
  shipped app: no `TrafficStats` anywhere under `app/lib`, no `MethodChannel` constructed under
  `app/lib`, and the Kotlin harness present only under `androidTest/`.
- No change to `app/integration_test/offline_walkthrough_test.dart`. T02 owns it; this task brackets it.

## Why it is built this way

**The counters are per-uid and cumulative since boot, so the reads do not have to happen inside the
walkthrough — only inside the same uid, on the same install, without a reboot.** That single fact is
what makes this measurable without shipping anything. `TrafficStats.getUidRxBytes(uid)` is supported for
the caller's own uid; since Android N it returns `UNSUPPORTED` for any other app's uid, and minSdk is 24
(§11), so a separate observer APK could never read CatchLaw's counters. That option is closed by the
platform, not by preference, and the file says so.

**The apparatus lives in the `androidTest` source set, which never ships.** An Android instrumentation
test runs under the target application's uid, so `Process.myUid()` inside the rule is the app's uid.
`integration_test` executes the whole Dart suite inside one instrumentation test method, so an ordinary
JUnit4 `@Rule` on that method brackets the entire walkthrough in one process. Nothing is added to
`app/lib`, nothing is added to `app/pubspec.yaml`, and the release AAB is byte-identical to the one T01
gated.

**Rejected: a `MethodChannel` so Dart can read the counters.** It would work, and it would be wrong.
`service-boundary-and-native` rule 10 confines every channel to `lib/native/`, and the app has no native
channel of its own — adding one whose only caller is a test adds a permanent native touchpoint to the
shipped binary in order to measure a property of the shipped binary. The measurement would then be part
of what it measures. `measurement_harness_isolation_test.dart` exists to keep that decision from being
quietly reversed later.

**Rejected: `adb shell dumpsys netstats` as the primary instrument.** §14 row 20 names `TrafficStats`,
and `dumpsys` aggregates into buckets whose boundaries are not ours to choose — a small transfer can
land in a bucket that has not been flushed. It is kept as the **cross-check**, because a single witness
is how a measurement error becomes a release claim.

**Rejected: `/proc/uid_stat/<uid>/tcp_rcv` and `/proc/net/xt_qtaguid/stats`.** Both are the answers a
search returns and both were removed from modern Android. A procedure that names a path which does not
exist on the reference device is a procedure that gets abandoned mid-release.

**The diagnostic run uses the profile build, where `INTERNET` is granted.** This is the point of the
task that is easy to get backwards. On the release build the kernel refuses the socket, so a delta of
zero is consistent both with "the app is silent" and with "the app called out and was blocked" —
`verification-ritual.md`'s failure triage names exactly that ambiguity. `catchlaw-offline-guarantee`
rule 4 records that debug and profile retain `INTERNET` by design, so a profile-build run is a build
where a real call would produce real bytes. Running both and requiring zero on both is what turns the
number into evidence: the profile run proves the Dart code is silent, the release run proves the shipped
artefact is silent.

**Exactly zero, and `-1` is not zero.** §14 says "delta must be exactly zero". There is no threshold and
no "negligible". A `-1` from either call means `UNSUPPORTED`; treating it as a small number would turn
an unavailable instrument into a pass, which is the same class of error as the clean proxy trace in T02.

## Tests first

Write every row before writing `TrafficStatsRule.kt`. Run them. **They must fail** — the Kotlin rows
because the class does not compile, the policy rows because the harness file does not exist. If the
delta row passes now, the test is wrong: it is almost certainly reading the counters twice in the same
millisecond with no walkthrough between them, so assert that the bracketed suite actually ran and that
its duration is non-zero before asserting on the delta.

Kotlin test names follow `CONVENTIONS.md` §5 unchanged — subject first, present tense, no `should`.

| # | Test name | Tier | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `TrafficStats delta is zero across the full walkthrough on the release build` | instrumentation | `rxAfter - rxBefore == 0` and `txAfter - txBefore == 0` | §14 row 20, on the artefact that ships. The headline assertion |
| 2 | `TrafficStats delta is zero across the full walkthrough on the profile build with INTERNET granted` | instrumentation | both deltas `0` | The diagnostic run. On release the kernel could be masking a real call; on profile it cannot, so this is the run that proves the Dart code is silent |
| 3 | `TrafficStatsRule fails the run when getUidRxBytes reports UNSUPPORTED` | instrumentation | fails, message names `UNSUPPORTED` | `-1` means the instrument is unavailable. Arithmetic on it produces a plausible-looking delta and a false pass |
| 4 | `TrafficStatsRule fails the run when the uid differs between the two reads` | instrumentation | fails, message names both uids | A reinstall reassigns the uid, and the counters are per-uid — comparing across it compares two different apps |
| 5 | `TrafficStatsRule fails the run when the bracketed suite recorded no walkthrough` | instrumentation | fails | A zero delta over a walkthrough that never ran is the easiest false pass available, and the one a tired operator will produce at 23:00 |
| 6 | `TrafficStatsRule reports the raw before and after byte counts` | instrumentation | both values in the failure and success message | T08's checklist records numbers, not a boolean. A rule that only says "pass" leaves nothing to attach |
| 7 | `app/lib references TrafficStats nowhere` | policy | no match | The apparatus must not leak into the shipped app. One import is all it takes |
| 8 | `app/lib constructs no MethodChannel` | policy | no match | The rejected design, made unreversible. `service-boundary-and-native` rule 10 confines channels to `lib/native/`, and this app has none |
| 9 | `The TrafficStats harness exists only under androidTest` | policy | found under `androidTest/`, absent from `main/` | A Kotlin file moved from `androidTest/` to `main/` compiles fine and ships. Nothing else would notice |

```kotlin
// app/android/app/src/androidTest/kotlin/<applicationId-path>/TrafficStatsRule.kt
// androidTest source set only — never compiled into a shipping artefact.
class TrafficStatsRule : TestWatcher() {
    private var uidBefore = -1
    private var rxBefore = 0L
    private var txBefore = 0L
    private var startedAt = 0L

    override fun starting(description: Description) {
        uidBefore = Process.myUid()
        rxBefore = TrafficStats.getUidRxBytes(uidBefore)
        txBefore = TrafficStats.getUidTxBytes(uidBefore)
        startedAt = SystemClock.elapsedRealtime()
        require(rxBefore != TrafficStats.UNSUPPORTED.toLong()) { "TrafficStats UNSUPPORTED before" }
    }

    override fun finished(description: Description) {
        val uidAfter = Process.myUid()
        assertEquals("uid changed between reads — a reinstall voids the run", uidBefore, uidAfter)
        // … rx/tx after, UNSUPPORTED guard, non-zero duration guard, exact-zero deltas
    }
}
```

```dart
// app/test/policy/measurement_harness_isolation_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final RegExp _lineComment = RegExp(r'//[^\n]*');

Iterable<File> _dartUnderLib() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((File f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));

String _code(File f) => f.readAsStringSync().replaceAll(_lineComment, '');

void main() {
  test('app/lib references TrafficStats nowhere', () {
    final Iterable<String> hits = _dartUnderLib()
        .where((File f) => _code(f).contains('TrafficStats'))
        .map((File f) => f.path);
    expect(hits, isEmpty, reason: 'the measurement harness leaked into the shipped app');
  });

  test('app/lib constructs no MethodChannel', () {
    final Iterable<String> hits = _dartUnderLib()
        .where((File f) => _code(f).contains('MethodChannel('))
        .map((File f) => f.path);
    expect(hits, isEmpty, reason: 'this app owns no native channel; see service-boundary-and-native r10');
  });

  test('The TrafficStats harness exists only under androidTest', () {
    final List<String> all = Directory('android/app/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.readAsStringSync().contains('TrafficStats'))
        .map((File f) => f.path)
        .toList();
    expect(all, isNotEmpty, reason: 'the harness is missing entirely');
    expect(all.every((String p) => p.contains('/androidTest/')), isTrue, reason: 'harness outside androidTest: $all');
  });
}
```

**Run:** `cd app && flutter test test/policy/measurement_harness_isolation_test.dart` → 3 failures, and
the instrumentation rows → 6 failures on a device. Any pass now is a wrong test.

## Implementation outline

1. Write `measurement_harness_isolation_test.dart` first. Row 7 and row 8 must be green immediately
   *and stay green*, so record in the commit body that they were verified to fail by pasting a
   `TrafficStats` reference into `app/lib` on purpose and removing it again — a guard that has never
   been seen to fail is a guard nobody trusts.
2. Add the Kotlin source set: `app/android/app/build.gradle.kts` gains
   `testInstrumentationRunner` for the Flutter test runner if E01 did not already set it, and
   `androidTestImplementation` for `androidx.test:runner` and `androidx.test.ext:junit`. Record the
   resolved versions in the commit body; do not guess them into this plan.
3. Write `TrafficStatsRule.kt` with four failure modes in this order: `UNSUPPORTED` before, uid changed,
   zero elapsed time, non-zero delta. Order matters — an `UNSUPPORTED` reported as a delta is the
   confusing failure.
4. Add the rule to `MainActivityTest.kt` beside the existing Flutter rule. Confirm by ordering that the
   `TrafficStatsRule` brackets the Dart suite rather than nesting inside one Dart test.
5. Run against the **profile** build first: `flutter build apk --profile`, install, run the
   instrumentation. `INTERNET` is granted here, so a leak produces bytes. Record both raw counts.
6. Run against the **release** build. Record both raw counts.
7. Cross-check with `adb shell dumpsys netstats detail` filtered to the uid from
   `adb shell dumpsys package <applicationId> | grep userId`. Record the output.
8. Write `docs/release/traffic-stats.md` with the two runs, the cross-check, the `-1` rule, the
   no-reinstall-between-reads rule, and the raw numbers from this release's runs.
9. Re-run the suite. All 9 green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 9 tests pass, and each failed first.
- [ ] The rx delta and the tx delta are both exactly `0` on the release build **and** on the profile
      build, and the four raw counts are recorded in `docs/release/traffic-stats.md`.
- [ ] Neither run reported `-1` from either call; if one did, the run is recorded as INVALID and
      repeated, never rounded to zero.
- [ ] `Process.myUid()` was identical at both reads of each run, and the uid is recorded.
- [ ] The `adb shell dumpsys netstats detail` cross-check agrees with the `TrafficStats` result.
- [ ] `app/lib` contains no `TrafficStats` and constructs no `MethodChannel`.
- [ ] `app/pubspec.yaml` is unchanged by this task — no dependency was added to measure the app.
- [ ] The release AAB built after this task has the same permission set T01's gate recorded before it.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test
cd app && flutter test integration_test/offline_walkthrough_test.dart -d <device-id> --profile
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
tools/gates/check_release_aab_manifest.sh app/build/app/outputs/bundle/release/app-release.aab
tools/gates/check_dependency_allowlist.sh app
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(ci): assert a zero per-uid TrafficStats delta across the full walkthrough

The counters are per-uid and cumulative since boot, so the two reads only have
to happen in the same uid on the same install — which an androidTest JUnit rule
can do without adding a single line to app/lib. A MethodChannel was rejected:
this app owns no native channel, and adding one whose only caller is a test
would make the measurement part of what it measures. Two runs are required.
The release run proves the shipped artefact is silent; the profile run, where
INTERNET is granted by design, proves the Dart code is silent rather than merely
blocked — without it a zero delta is consistent with a call the kernel refused.
UNSUPPORTED (-1) is INVALID, never zero, and a uid that moved between reads
voids the run.

Task: E21/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
