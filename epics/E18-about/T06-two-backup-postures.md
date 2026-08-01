# E18/T06 — Two backup postures, and why they differ

| | |
|---|---|
| **Epic** | E18 — About and attributions |
| **Branch** | `epic/18-about` (shared) |
| **Commit** | `feat(about): explain the Android and iOS backup postures and why they differ` |
| **Depends on** | T02 (the `AboutScreen` scaffold), T05 (the privacy section this one sits under) |
| **Size** | S |
| **Spec** | `SPEC.md` §11 Android (`allowBackup="false"`, no `dataExtractionRules`), §11 iOS (`NSURLIsExcludedFromBackupKey` **not** set — *"Both choices are explained in S17"*), §12 (export is the portability path), §14 (the reinstall test) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | Owns the platform artefacts. `references/four-layers.md`'s source-set table is what the manifest tests assert against, and rule 5's discipline — write the platform difference down, never fake symmetry — is this task in miniature |
| `catchlaw-conventions-index` | Rule 11: `user.db` is local, exportable by the user and by nobody else. The Android choice is that rule enforced by the OS; the iOS choice is that rule not being violated by the OS |
| `i18n-rtl-l10n` | Two sentences about two platforms, in six locales (D-3), with no concatenation — ICU or nothing, because "on Android, X; on iOS, Y" is a sentence whose word order does not survive translation as fragments |
| `lonja-typography` | Rule 2 and rule 8 again: serif, never truncated. This is the section a reader reaches after losing data, and it must be readable in full |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §11 Android | `android:allowBackup="false"`, no `dataExtractionRules`, and the reason: *"the catch log must not be swept into a Google backup the user did not choose. Portability is served by explicit export (§12)"* |
| `SPEC.md` | §11 iOS | *"`NSURLIsExcludedFromBackupKey` is **not** set — iCloud device backup is the user's own encrypted backup and is acceptable; what we exclude is any vendor server. This differs deliberately from Android's `allowBackup="false"`, where the destination is Google's servers under a different trust model. Both choices are explained in S17."* |
| `SPEC.md` | §14, dynamic checklist | *"Reinstall: confirm the catch log is gone (Android `allowBackup=false`) and that a pre-taken export restores it completely"* — the user-visible cost this section exists to state in advance |
| `SPEC.md` | §12 | The four export artefacts and the round-trip JSON — what "a pre-taken export restores it completely" means |
| `SPEC.md` | §5, exclusion table | *Accounts, login, sync, cloud backup* are excluded, and why: verified reviews of five apps describe users locked out of data already on their phone |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 2 — the Android manifest and the merger" | The four source sets and which two ship; the merger priority rule that a marker in `main/` acts on lower-priority manifests |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | "1 — No network code path", consequences paragraph | No remote config, no OTA, no crash upload — the surrounding posture the backup choice belongs to |
| `epics/DECISIONS.md` | D-6, D-1 | `user.db` is the only writable and only irreplaceable file, under `getApplicationSupportDirectory()`; the app lives at `app/` so the platform folders are `app/android/` and `app/ios/` |

## What this delivers

- `app/lib/ui/about/widgets/backup_posture_section.dart` — two labelled blocks and a third that gives
  the reason they differ, plus one line naming export as the path that works on both.
- ARB keys in all six files (D-3): `aboutBackupHeading`, `aboutBackupAndroidBody`,
  `aboutBackupIosBody`, `aboutBackupWhyDifferBody`, `aboutBackupExportBody`.
- `app/test/platform/backup_posture_test.dart` — the artefact guards: the Android manifests and the
  absence of the iOS key.
- `app/test/ui/about/about_backup_posture_test.dart` — the screen tests.

No manifest change. `SPEC.md` §11's Android settings land in E01 with the rest of the platform
configuration; this task asserts they are still true and explains them.

## Why it is built this way

**The asymmetry is deliberate and looks like an oversight, which is why it is on the screen.** A
reviewer who sees `allowBackup="false"` on Android and no `NSURLIsExcludedFromBackupKey` on iOS will
read it as one platform having been forgotten. §11 gives the actual reason, and it is a distinction
about **destination**, not about platform effort: an Android auto-backup ships `user.db` to Google's
servers under Google's trust model, which the user never chose per-app; an iCloud device backup is the
user's own backup of their own device. What the product excludes is any *vendor* server — and Apple's
device backup is not one in the sense that matters, because the user turned it on for their whole
phone and can turn it off in the same place. `SPEC.md` §11 says both choices are explained in S17, so
this section is the spec being satisfied, not a nicety.

**The Android choice has a cost, and the screen states it before the user pays it.** §14's dynamic
checklist requires proving that after a reinstall the catch log is **gone**. A fisher who reinstalls
and finds five years of trips missing will conclude the app lost their data — and on a product whose
whole promise is that nothing is uploaded, that is the worst possible interpretation to leave
unaddressed. The screen therefore states the consequence and names the remedy (§12's export), in that
order, as a statement of fact rather than an instruction (invariant 2): *"An Android reinstall starts
with an empty log. An export file taken beforehand restores it completely."* Not *"back up your data
before reinstalling."*

**The manifest is asserted from the artefact, not trusted.** A screen that says "this build carries
`allowBackup=false`" and a manifest that no longer does is a false statement in a privacy notice — the
same class of defect T05's iOS test guards. Reading `app/android/app/src/main/AndroidManifest.xml` in
a test is cheap and permanent. `four-layers.md`'s source-set table is what makes the test correct
about *which* manifests matter: `main/` and `release/` ship; `debug/` and `profile/` do not, and are
not asserted.

**`dataExtractionRules` is asserted absent, not merely unset.** §11 says *"no `dataExtractionRules`"*.
On Android 12+ that attribute re-opens per-content control over cloud and device-to-device transfer,
so a well-meaning future commit adding a rules file would partially undo `allowBackup="false"` while
leaving the flag visibly in place. That is exactly the kind of change a grep-level test catches and a
code review does not.

**The iOS test asserts an absence, which is unusual and is the point.** The correct iOS behaviour is
that nobody ever calls `NSURLIsExcludedFromBackupKey`. There is no artefact to inspect, so the test is
a source scan over `app/ios/` and `app/lib/` for the symbol. Without it, a future commit "excluding
our database from backup for privacy" would silently remove the user's own restore path, which is the
opposite of the intent, and nothing else in the repository would notice.

**Rejected: making the two platforms symmetric.** Either direction is worse. Setting
`NSURLIsExcludedFromBackupKey` would delete the user's own restore path on iOS with no replacement,
on a product with no cloud. Setting `allowBackup="true"` would put the catch log on Google's servers,
which §5's exclusion list rules out and which the collection statement in T05 would then contradict.

**Rejected: a sentence assembled from fragments.** "On Android … but on iOS …" concatenated from ARB
pieces breaks word order in translation and reorders unpredictably in `ar`. Each platform's statement
is one complete ARB message (§9.5: content strings are authored as complete phrases, never assembled
from fragments).

**Rejected: claims about how the backups are encrypted.** The screen uses §11's framing — *the user's
own encrypted backup* — and goes no further. Describing Apple's or Google's cryptography is a claim
about a third party's implementation that we cannot verify and that changes without telling us.

## Tests first

Write both files before touching `backup_posture_section.dart`. Run them. **They must fail** — the
section and its ARB keys do not exist. The two artefact tests are the exception to watch: if
`backup_posture_test.dart` passes on the first run, that is correct and expected, because E01 already
set the manifest. Confirm the assertion is real by inverting it once — flip the manifest value locally,
watch the test go red, revert. A guard nobody has seen fail is a guard nobody knows works.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `Android main manifest sets allowBackup to false` | read `app/android/app/src/main/AndroidManifest.xml` | `android:allowBackup="false"` present | The screen's claim and the shipped artefact must not be able to drift apart |
| 2 | `Android release manifest sets allowBackup to false` | read the `release/` manifest | same | `four-layers.md`: `main/` and `release/` are the two that ship, and the release one is what an auditor diffs |
| 3 | `Android manifests declare no dataExtractionRules` | both shipping manifests | attribute absent | On Android 12+ it re-opens the transfer path the flag closed, while the flag still reads `false` |
| 4 | `iOS sources set NSURLIsExcludedFromBackupKey nowhere` | grep `app/ios/`, `app/lib/` | no match | The deliberate non-setting; a future "privacy" commit adding it removes the user's own restore path |
| 5 | `AboutScreen states that an Android reinstall starts with an empty log` | default | the Android consequence sentence renders | §14's reinstall test made visible; otherwise the user concludes the app lost their data |
| 6 | `AboutScreen states that an iOS device backup restores the log` | default | the iOS sentence renders | The other half of the asymmetry; stating only the Android half reads as a defect report |
| 7 | `AboutScreen gives the reason the two platforms differ` | default | the destination/trust-model sentence renders | §11 requires *both choices explained*, and without the reason the pair looks like one platform was forgotten |
| 8 | `AboutScreen names export as the path that works on both` | default | the export sentence renders | §12 is the portability answer; a consequence stated with no remedy is alarming rather than informative |
| 9 | `AboutScreen backup section contains no imperative from the banned lexicon` | all six locales | no `back up`, `you must`, `you should`, `remember to` | Invariant 2 binds this section too — the temptation to write "back up before reinstalling" is high here |
| 10 | `Every backup-posture ARB key exists in all six locales` | read the six ARB files | key sets equal | D-3; a missing `ar` key falls back to English in a statement about the user's own data |

```dart
// app/test/platform/backup_posture_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const shipping = <String>[
    'android/app/src/main/AndroidManifest.xml',
    'android/app/src/release/AndroidManifest.xml',
  ];

  for (final path in shipping) {
    test('Android manifest at $path sets allowBackup to false', () {
      final xml = File(path).readAsStringSync();
      expect(xml, contains('android:allowBackup="false"'));
    });

    test('Android manifest at $path declares no dataExtractionRules', () {
      expect(File(path).readAsStringSync(), isNot(contains('dataExtractionRules')));
    });
  }

  test('iOS sources set NSURLIsExcludedFromBackupKey nowhere', () {
    final hits = <String>[];
    for (final dir in const ['ios', 'lib']) {
      for (final f in Directory(dir).listSync(recursive: true).whereType<File>()) {
        if (f.readAsStringSync().contains('NSURLIsExcludedFromBackupKey')) hits.add(f.path);
      }
    }
    expect(hits, isEmpty,
        reason: 'excluding user.db from the device backup removes the user own restore path');
  });
}
```

Note the loop bodies interpolate `$path` into the description, so `--plain-name` still selects one
manifest (`CONVENTIONS.md` §5).

```dart
// app/test/ui/about/about_backup_posture_test.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../harness.dart'; // pumpAbout(tester, {locale, textScaler})

void main() {
  testWidgets('AboutScreen gives the reason the two platforms differ', (tester) async {
    await pumpAbout(tester);
    expect(find.byKey(const Key('about.backup.whyDiffer')), findsOneWidget);
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/platform/backup_posture_test.dart test/ui/about/about_backup_posture_test.dart`
→ the six screen and ARB tests fail; the four artefact tests pass because E01 already made them true.
Invert one manifest value once, confirm red, revert.

## Implementation outline

1. Author the five keys in the template `app_en.arb` with `@description`, then mirror them into the
   other five (D-3). Each platform statement is one complete message; nothing is concatenated.
2. Write the artefact tests first and run the inversion check on test 1.
3. Build `BackupPostureSection`: `LonjaSectionLabel` heading, then Android, iOS, why-they-differ and
   export, each a `t.legal` block inside the scaling reading measure. Key the blocks
   (`about.backup.android`, `about.backup.ios`, `about.backup.whyDiffer`) so tests address them
   without matching translated text.
4. Place it directly after T05's collection statement in the `AboutScreen` scaffold — the two answer
   the same question and reading them apart weakens both.
5. Re-read the four sentences against `product-invariants.md`'s banned lexicon before running the
   suite. "Back up your data" is the one that will slip in.
6. Re-run the suite. All 10 green, and T02–T05's still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 10 tests pass; the six new ones failed first, and test 1 was seen to fail under an inverted
      manifest before being reverted.
- [ ] Both shipping Android manifests are unchanged by this task, and both still assert.
- [ ] `grep -rn "NSURLIsExcludedFromBackupKey" app/` returns nothing.
- [ ] The section states the Android reinstall consequence **and** the export remedy, in that order.
- [ ] No sentence instructs; no string appears in the banned lexicon in any of the six locales.
- [ ] The section makes no claim about how either vendor encrypts a backup.
- [ ] All five keys exist in all six ARB files (D-3).

## Gates

```bash
# from the repository root
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd -
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh      app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh               app/lib
```

`check_no_network.sh` check 3 reads the shipping `AndroidManifest.xml` files from the parent of the
target, which is why the target is `app/lib`. `check_app_invariants.sh` check 3 scans every ARB
locale for imperatives, and ARB values are never exempt (`CONVENTIONS.md` §7). Every invocation names
`app/lib`: the scripts exit 2 on a missing directory and the default `lib/` does not exist here (D-1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(about): explain the Android and iOS backup postures and why they differ

SPEC.md §11 sets allowBackup="false" on Android and deliberately does NOT set
NSURLIsExcludedFromBackupKey on iOS, and says both choices are explained in S17.
The difference is about destination, not effort: an Android auto-backup ships
user.db to Google's servers under a trust model the user never chose per app,
while an iCloud device backup is the user's own backup of their own device.
Without the explanation on screen the pair reads as one platform having been
forgotten.

The Android choice has a cost §14 tests for — after a reinstall the catch log is
gone — so the section states that consequence and names export as the remedy,
before the user pays it. A fisher who reinstalls and finds five years of trips
missing otherwise concludes the app lost their data, which is the worst reading
to leave unaddressed on a product whose promise is that nothing is uploaded.

Both claims are asserted against the artefacts: the two shipping manifests are
read in a test, and a source scan proves NSURLIsExcludedFromBackupKey is set
nowhere, so a future commit "excluding our database for privacy" cannot quietly
delete the user's own restore path.

Task: E18/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
