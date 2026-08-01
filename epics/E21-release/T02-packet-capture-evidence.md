# E21/T02 — Packet capture, and what counts as evidence

| | |
|---|---|
| **Epic** | E21 — Offline verification and release readiness |
| **Branch** | `epic/21-release` (shared) |
| **Commit** | `test(ci): drive the S1-S23 airplane-mode walkthrough and fix the packet-capture procedure` |
| **Depends on** | T01 (the release artefact the capture is taken against is the one T01's workflow builds) |
| **Size** | L |
| **Spec** | `SPEC.md` §14 dynamic rows 6–15, 19 and 21; §5.3; §6 (S1–S23, D1–D5); §13 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | Owns `references/verification-ritual.md` — the whole procedure, why a proxy is not evidence, the pass-criteria table and the evidence-retention rules this task turns into files |
| `catchlaw-conventions-index` | Invariant 1, and invariant 11's corollary: the walkthrough must find no refresh, sync or connectivity affordance to exercise, because none may exist |
| `catchlaw-reference-database` | Rules 6 and 7: what "extraction restarts cleanly" means (orphan `*.tmp` sweep, atomic rename, `INSTALLED` stamp last) and the < 6 s determinate-bar budget rows 6 and 7 of §14 are measuring |
| `testing-strategy` | `references/coverage-and-budget.md`: hand structurally-untestable paths to a named manual pass and do not write a test that appears to cover them. This is the task most at risk of pretending automation discharges a device row |
| `ci-pipeline-and-gates` | Rule 10: state plainly what CI cannot prove, so the manual on-device pass is treated as a load-bearing release artifact rather than a chore |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §14 dynamic block | Rows 6–15, 19 and 21 verbatim, including "capturing while walking every screen S1–S23 and exercising export, import, GPS, camera, PDF render and SVG load" |
| `SPEC.md` | §5.3 | The accurate guarantee, and the sentence that the iOS half rests on the allowlist, the grep and this capture |
| `SPEC.md` | §6 | The enumeration of S1–S23 and D1–D5, and that S7 must be reachable from S1, from S5's empty state and from S6 |
| `SPEC.md` | §13 | < 6 s first launch with a determinate indicator; < 1.2 s subsequent cold start; both measured during the walk |
| `SPEC.md` | §11 iOS | Why there is no OS-level equivalent, stated rather than glossed |
| `FLUTTER_GUIDE.md` | Part 4.6 | The four layers, and that layer 2 is the only third-party-verifiable one |
| `.claude/skills/catchlaw-offline-guarantee/references/verification-ritual.md` | whole | Why a proxy is not evidence, PCAPdroid, `adb` + `tcpdump`, `rvictl` + Wireshark, pass criteria, the release checklist, evidence retention, failure triage |
| `.claude/skills/catchlaw-offline-guarantee/SKILL.md` | rule 12 | Packet capture, not a proxy — and `HttpClient` ignoring the system proxy unless `findProxy` is set |
| `.claude/skills/catchlaw-offline-guarantee/examples/no_network_test.dart` | whole | The layer-4 guard this capture is the runtime counterpart of; the walk exercises what the scanner cannot see |
| `testing-strategy` → `references/coverage-and-budget.md` (Flutter-Skills plugin) | "Hand structurally-untestable paths to a named manual pass" | The rule that keeps this task honest |
| `epics/CONVENTIONS.md` | §6, §9 | Where the integration test lives; the five invariants the walk re-checks in passing |
| `epics/DECISIONS.md` | D-3 | Six locales; the `ar` lane is the only RTL lane |

## What this delivers

- `docs/offline-exercise.md` — the exercise script. Numbered, reproducible, naming every screen S1
  through S23, every dialog D1 through D5, and the six subsystems §14 row 19 requires: export, import,
  GPS, camera, PDF render, SVG load. `verification-ritual.md` names this exact path as a permanent
  evidence artefact, kept "forever, so a re-run is comparable".
- `docs/release/packet-capture.md` — the procedure. Android with PCAPdroid (no root, app-scoped) and
  the `adb` + `tcpdump` alternative; iOS with `rvictl -s <udid>` and Wireshark on `rvi0`; the quiescing
  steps; the pass-criteria table; the failure-triage table; and the section on why a proxy is
  insufficient, with the reason rather than the conclusion.
- `docs/release/evidence-retention.md` — the naming and retention rules:
  `catchlaw-android-<version>.pcap`, `catchlaw-ios-<version>.pcap`, kept for the life of the release
  plus two years, stored under `docs/release/<version>/evidence/`.
- `app/integration_test/offline_walkthrough_test.dart` — the driven walk. Visits every screen, opens
  every dialog, exercises the six subsystems, and is the deterministic exercise T03 brackets with its
  counter reads.
- `app/integration_test/harness/walkthrough.dart` — the shared navigation helpers. Not `_test.dart`
  (`CONVENTIONS.md` §6).
- `tools/gates/assert_zero_packets.sh` — takes a `.pcap`; refuses a file that is not a capture; fails
  on one or more frames; passes on a capture holding zero frames.
- `app/test/policy/offline_exercise_coverage_test.dart` — parses `docs/offline-exercise.md` and fails
  when a screen, a dialog or a subsystem is missing from it.

## Why it is built this way

**A proxy is not evidence, and the reason matters more than the rule.** Dart's `HttpClient` ignores the
system proxy unless `findProxy` is set. A Charles, Proxyman or mitmproxy session therefore shows a clean
trace whether or not the app called out — the single most likely real failure here, a `dart:io` HTTP
request from a plugin, is invisible to it. `verification-ritual.md` puts it exactly right: it "looks
like the strongest possible test and is structurally incapable of failing". A test incapable of failing
attached to a release tag is worse than no test, because it stops anyone doing the real one.

**The capture runs with connectivity UP.** Every other dynamic row in §14 is run in airplane mode, and
the instinct is to capture in airplane mode too. That inverts the experiment. Airplane mode proves the
app *functions* without a network; the capture proves the app is *silent when a network is available*.
`verification-ritual.md`'s pass-criteria table marks a capture taken with no connectivity as **INVALID**,
not as a pass. The procedure says so in bold, in the first step, because this is the mistake that will
be made.

**The capture runs against the release build.** A debug build emits mDNS and the Dart VM service, so a
debug capture is noise that has to be explained away, and explaining traffic away is exactly the habit
this task is meant to prevent. Same table: mDNS or the VM service on a debug build is "pass, and re-run
against the RELEASE build".

**A clean Android capture is weaker evidence than it looks, and the file says so.** Without
`android.permission.INTERNET` the kernel refuses the socket, so the Android capture confirms layer 2 is
working — not that the Dart code is silent. `verification-ritual.md`'s failure triage names the
consequence: if iOS shows traffic Android does not, the Dart code IS calling out and layer 2 has been
absorbing the bug. `docs/release/packet-capture.md` carries that paragraph, and T03's profile-build run
(where `INTERNET` is granted by design) is the diagnostic that removes the ambiguity.

**iOS has no OS-level equivalent, and this file does not soften it.** `SPEC.md` §11 and §5.3 both say
so: ATS blocks only cleartext HTTP and permits every TLS request, and CFNetwork is linked by the Flutter
engine regardless, so "links no `Network.framework`" is not a test. The iOS guarantee rests on three
things and only three: the dependency allowlist (T01), the API grep (E01), and this capture. That
sentence goes into `docs/release/packet-capture.md` unqualified. Any wording that implies iOS has a
permission-level block is a defect in this task, not a simplification.

**The walkthrough test does not discharge the manual rows.** `coverage-and-budget.md` is explicit that a
green test which appears to cover a structurally-untestable path stops anyone checking by hand. The
integration test exists for two reasons: it makes the walk identical between runs and between releases,
and it gives T03 a deterministic exercise to bracket. Every §14 dynamic row is still ticked by a person
on hardware, and `docs/offline-exercise.md` is written for that person, not for the test runner.

**Rejected: attributing packets by uid inside the `.pcap`.** A pcap has no uid column. On Android the
attribution comes from scoping PCAPdroid to the CatchLaw app before capture, so every frame in the file
is by construction the app's and the assertion collapses to "the file has zero frames" — which
`assert_zero_packets.sh` can check mechanically. On iOS `rvi0` carries the whole device, so there is no
mechanical assertion available; attribution is by timestamp against the exercise script, and the
procedure says that plainly rather than shipping a script that pretends otherwise.

**Rejected: `adb shell dumpsys netstats` as the primary Android instrument.** It aggregates and it
buckets. §14 row 19 asks for packets; row 20 asks for byte counters and is T03's job. Using one
instrument for both would leave the release with a single witness.

**Rejected: capturing on Wi-Fi only.** A device with cellular data will use it. The procedure captures
with Wi-Fi on and cellular on, because the point is that every available path stays unused.

## Tests first

Write every row before writing a line of `docs/offline-exercise.md` or the walkthrough. Run them.
**They must fail** — the policy rows because the document does not exist, the integration rows because
`harness/walkthrough.dart` does not exist. If a policy row passes now the test is wrong: the likeliest
cause is a regex loose enough to match `S1` inside `S13`, so anchor on word boundaries and assert the
count as well as the presence.

| # | Test name | Tier | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `offline-exercise.md names every screen from S1 to S23` | policy | all 23 tokens present | A walk that skips a screen produces a signed checklist that means less than it looks like. §14 row 9 says *every* screen |
| 2 | `offline-exercise.md names every dialog from D1 to D5` | policy | all 5 tokens present | §14 row 9 names the dialogs separately from the screens; a walk of screens alone misses D4's ambiguous-zone path entirely |
| 3 | `offline-exercise.md names export, import, GPS, camera, PDF render and SVG load` | policy | all 6 present | §14 row 19 names these six subsystems explicitly. The PDF and SVG paths are the two with a real `http` edge behind them — omitting them omits the only interesting cases |
| 4 | `offline-exercise.md states that the capture runs with connectivity up` | policy | the sentence present | The one instruction most likely to be reversed by someone applying the airplane-mode habit from the rows above it |
| 5 | `assert_zero_packets.sh exits 2 when the capture file does not exist` | policy | exit `2` | `CONVENTIONS.md` §7. A missing capture must abort, never pass |
| 6 | `assert_zero_packets.sh fails when the file is not a capture` | policy | exit `2` | An empty or truncated file must be INVALID, not clean. "Zero frames" and "no capture" look identical to `wc -l` and mean opposite things |
| 7 | `assert_zero_packets.sh fails when the capture holds one frame` | policy | exit `1` | One packet is a failure. There is no threshold, and a gate with a threshold would have one |
| 8 | `assert_zero_packets.sh passes on a capture holding zero frames` | policy | exit `0` | The pass path must exist and be reachable, or the gate is only ever red and gets bypassed |
| 9 | `Offline walkthrough reaches every screen from S1 to S23` | integration | 23 screens visited | The mechanical half of §14 row 9, and the exercise T03 brackets |
| 10 | `Offline walkthrough opens every dialog from D1 to D5` | integration | 5 dialogs opened | As row 2, on the device rather than in the document |
| 11 | `S7 opens from S1, from S5's empty state and from S6` | integration | 3 routes reach S7 | §14 row 9 calls these three out by name. §6 gives S7 three entry points and E14 built them; a single-entry-point regression is invisible from S1 alone |
| 12 | `ar - Legal-text search returns a hit for هامور and for الهامور` | integration | both non-empty | §14 row 10. The definite-article case is the one §9.4's fold exists for, and it is the case that breaks first |
| 13 | `Citation tap expands S13 and copies the citation to the clipboard` | integration | S13 shown, clipboard non-empty | §14 row 11. The assertion that no browser opens is a device observation, recorded on the checklist — the test asserts the half it can |
| 14 | `Export writes the JSON, the CSV, the PDF and the zip` | integration | 4 files present | §14 row 12. The PDF path is where `printing` could reach `PdfGoogleFonts`, so this is the subsystem the capture most needs exercised |
| 15 | `Import of the exported zip restores the trip count` | integration | counts equal | §14 row 13, and the round-trip that makes T06's restore claim testable |
| 16 | `S9 stays usable and states why nothing was suggested when location permission is denied` | integration | picker usable, reason shown | §14 row 14. §6 says the manual list stays fully usable with one line saying why — "usable" alone would pass on a screen that says nothing |
| 17 | `Catch records without a photo when camera permission is denied` | integration | catch persisted | §14 row 15. A permission denial that blocks the record breaks the core loop at the one moment it matters |
| 18 | `RTL - Ruler reads left to right with the device locale set to ar` | integration | ruler subtree is LTR | §14 row 21 and `FLUTTER_GUIDE.md` appendix rule 11 — the ruler is the deliberate LTR exception inside an RTL page |
| 19 | `ar - Walkthrough overflows no layout with the device locale set to ar` | integration | no overflow reported | §14 row 21's third clause. A `RenderFlex overflowed` in `ar` is silent in release and loud in a screenshot |

```dart
// app/test/policy/offline_exercise_coverage_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _exercise() => File('../docs/offline-exercise.md').readAsStringSync();

void main() {
  test('offline-exercise.md names every screen from S1 to S23', () {
    final String text = _exercise();
    final List<String> missing = <String>[
      for (int i = 1; i <= 23; i++)
        if (!RegExp(r'\bS' '$i' r'\b').hasMatch(text)) 'S$i',
    ];
    expect(missing, isEmpty, reason: 'SPEC §14 row 9 says every screen: missing $missing');
  });

  test('offline-exercise.md names every dialog from D1 to D5', () {
    final String text = _exercise();
    final List<String> missing = <String>[
      for (int i = 1; i <= 5; i++)
        if (!RegExp(r'\bD' '$i' r'\b').hasMatch(text)) 'D$i',
    ];
    expect(missing, isEmpty, reason: 'SPEC §14 row 9 names the dialogs too: missing $missing');
  });

  test('offline-exercise.md names export, import, GPS, camera, PDF render and SVG load', () {
    final String text = _exercise().toLowerCase();
    for (final String subsystem in <String>[
      'export', 'import', 'gps', 'camera', 'pdf render', 'svg load',
    ]) {
      expect(text, contains(subsystem), reason: 'SPEC §14 row 19 names $subsystem');
    }
  });

  test('offline-exercise.md states that the capture runs with connectivity up', () {
    expect(_exercise(), contains('airplane mode OFF'),
        reason: 'a capture taken with no connectivity is INVALID, not a pass');
  });
}
```

```dart
// app/integration_test/offline_walkthrough_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'harness/walkthrough.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Offline walkthrough reaches every screen from S1 to S23', (WidgetTester t) async {
    final Walkthrough walk = await Walkthrough.launch(t);
    for (final ScreenId id in ScreenId.values) {
      await walk.open(id);
      expect(walk.currentScreen, id, reason: 'could not reach $id');
    }
    expect(walk.visited, hasLength(23));
  });

  testWidgets('S7 opens from S1, from S5 empty state and from S6', (WidgetTester t) async {
    final Walkthrough walk = await Walkthrough.launch(t);
    for (final ScreenId from in <ScreenId>[ScreenId.s1, ScreenId.s5Empty, ScreenId.s6]) {
      await walk.open(from);
      await walk.tapIdentifyThisFish();
      expect(walk.currentScreen, ScreenId.s7, reason: 'S7 unreachable from $from');
    }
  });

  testWidgets('ar - Legal-text search returns a hit for هامور and for الهامور', (WidgetTester t) async {
    final Walkthrough walk = await Walkthrough.launch(t, locale: 'ar');
    await walk.open(ScreenId.s13);
    for (final String query in <String>['هامور', 'الهامور']) {
      expect(await walk.searchLegalText(query), isNotEmpty, reason: 'no FTS hit for $query');
    }
  });

  // … rows 10, 13–19
}
```

**Run:** `cd app && flutter test test/policy/offline_exercise_coverage_test.dart` → 4 failures, and
`flutter test integration_test/offline_walkthrough_test.dart -d <device>` → 11 failures. Any pass now is
a wrong test.

## Implementation outline

1. Write `app/integration_test/harness/walkthrough.dart`: a `ScreenId` enum with 23 values, a
   `DialogId` enum with 5, `Walkthrough.launch(tester, {locale})`, `open(ScreenId)`, and a `visited`
   set. Navigation goes through the app's real routes — never by pushing a route object directly, which
   would prove the screen builds rather than that it is reachable.
2. Make the permission-denied rows real: the runner revokes before launching, with
   `adb shell pm revoke <applicationId> android.permission.CAMERA` and the same for
   `ACCESS_FINE_LOCATION`. Record the two commands in `docs/offline-exercise.md` so the manual pass
   performs the same setup. Do not fake the denial through a provider override in the integration
   tier — that would test the fake.
3. Write `docs/offline-exercise.md` as numbered steps with an estimated wall-clock time per block, so
   the operator can align a capture timestamp against a step. Step 0 is the setup: release build
   installed, **airplane mode OFF**, Wi-Fi on, cellular on, other apps closed, iCloud sync and
   Background App Refresh disabled for everything else on iOS.
4. Write `docs/release/packet-capture.md`: the Android block, the iOS block, the pass criteria table
   copied in shape from `verification-ritual.md` (cited, not paraphrased into something weaker), the
   failure-triage table, and the two paragraphs above about why a proxy fails and why a clean Android
   capture is weaker than it looks.
5. `tools/gates/assert_zero_packets.sh`: exit 2 when the path is absent or when `tshark -r` cannot read
   it as a capture; count frames with `tshark -r "$1" -T fields -e frame.number | wc -l`; exit 1 with
   the first ten frames printed when the count is non-zero; exit 0 only on an exact zero.
6. `docs/release/evidence-retention.md`: the filename pattern, the location, and the two-year window.
7. Run the walk on both devices. Record the first-launch extraction time against §13's < 6 s and the
   subsequent cold start against < 1.2 s; those two numbers go on T08's checklist.
8. Re-run the suite. All 19 green, and every gate from T01 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first.
- [ ] `docs/offline-exercise.md` names S1–S23, D1–D5 and the six subsystems, and its step 0 says
      **airplane mode OFF** for the capture.
- [ ] `docs/release/packet-capture.md` states, without qualification, that iOS has no OS-level
      equivalent of removing the `INTERNET` permission and that the iOS guarantee rests on the
      dependency allowlist, the API grep and this capture.
- [ ] The same file states that a capture taken with no connectivity is INVALID rather than a pass.
- [ ] The same file states that a clean Android capture may be clean because the kernel refused the
      socket, and points at T03's profile-build run as the diagnostic.
- [ ] `docs/release/packet-capture.md` contains no instruction involving Charles, Proxyman or
      mitmproxy except in the section explaining why they cannot be used.
- [ ] An Android `.pcap` and an iOS `.pcap` exist under `docs/release/<version>/evidence/`, both taken
      against the **release** build with connectivity up, and `assert_zero_packets.sh` passes on the
      Android one.
- [ ] The walkthrough found no refresh, sync, retry or connectivity affordance to exercise — because
      none exists (`catchlaw-offline-guarantee` rule 11).
- [ ] Nothing in this task's files claims that the integration test discharges a §14 dynamic row.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test
cd app && flutter test integration_test/offline_walkthrough_test.dart -d <device-id>
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh app/lib
bash -n tools/gates/assert_zero_packets.sh
tools/gates/assert_zero_packets.sh docs/release/<version>/evidence/catchlaw-android-<version>.pcap
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(ci): drive the S1-S23 airplane-mode walkthrough and fix the packet-capture procedure

SPEC §5.3 puts the entire iOS offline guarantee on three things — the dependency
allowlist, the API grep and a device packet capture — and the third had never
been performed. The obvious instrument is wrong: Dart's HttpClient ignores the
system proxy unless findProxy is set, so a Charles trace is clean whether or not
the app called out. The procedure is PCAPdroid or tcpdump on Android and rvictl
plus Wireshark on iOS, taken against the release build with connectivity UP,
while walking S1-S23, D1-D5 and the six subsystems SPEC §14 names. The walk is
also a driven integration test so it is identical between releases and so T03
has a deterministic exercise to bracket — it does not discharge the manual row.

Task: E21/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
