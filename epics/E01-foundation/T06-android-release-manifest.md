# E01/T06 — Android: the release manifest without INTERNET

| | |
|---|---|
| **Epic** | E01 — Foundation, workspace and the offline gates |
| **Branch** | `epic/01-foundation` (shared) |
| **Commit** | `build(android): remove INTERNET from the shipping manifests and disable backup` |
| **Depends on** | T01 (`app/android/` comes from the Flutter template), T03 (the job the AAB check joins) |
| **Size** | M |
| **Spec** | `SPEC.md` §11 Android (in full), §14 static block bullet 3, §5.3 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | Owns layer 2, the only layer a third party can verify without trusting us. Rules 3 and 4, and `references/four-layers.md`'s source-set table and merger rules |
| `ci-pipeline-and-gates` | Rules 2 and 9, and `references/workflow-skeleton.md`'s `build-android` job: unsigned in CI, no signing secret in the job, `actions/setup-java@v4` with a pinned major |
| `catchlaw-conventions-index` | Invariant 1 and rule 1 — the OS-level half of "no network code path, at all, ever" |
| `dependency-hygiene` | Rule 7: a plugin AAR that merges INTERNET into the manifest is a transitive network path, and `tools:node="remove"` in `main/` is what catches it |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §11 Android | The `<manifest>` element **verbatim**, the sentence that the `xmlns:tools` declaration is required or the build fails, the debug/profile carve-out, `allowBackup="false"`, no `dataExtractionRules`, minSdk 24, and `context.getFilesDir()` |
| `SPEC.md` | §14 static block, bullet 3 | The check: `aapt2 dump xmltree` on the AAB contains no `android.permission.INTERNET` and no background-location permission |
| `SPEC.md` | §5.3 | "On Android the OS enforces it … any socket the app opens fails at the kernel" |
| `FLUTTER_GUIDE.md` | Part 4.6 layer 2 | The mechanism, and that `flutter run` injects INTERNET via `debug/AndroidManifest.xml` for the VM service |
| `FLUTTER_GUIDE.md` | Part 9.3 | Confirms Part 4.6 and `SPEC.md` §11 agree — main **and** release |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 2 — the Android manifest and the merger", "The strength ladder" | The four-source-set table, the three merger rules, the `apkanalyzer` / `bundletool` proof, and why layer 2 outweighs the three source-side layers combined |
| `.claude/skills/catchlaw-offline-guarantee/references/verification-ritual.md` | "The release checklist" steps 5 and 6 | The permission dump blocks release; the merger report is attached but does not block |
| `.claude/skills/ci-pipeline-and-gates/references/workflow-skeleton.md` | the `build-android` job | The job shape, and that CI builds unsigned |
| `.claude/skills/ci-pipeline-and-gates/references/policy-grep-gate.md` | "A worked example — a required manifest attribute", "Strip comments first" | `xmlOf()`, and the rule that a manifest attribute must be asserted inside the right element |

## What this delivers

- `app/android/app/src/main/AndroidManifest.xml` — `xmlns:tools` on `<manifest>`, the INTERNET element with
  `tools:node="remove"`, `android:allowBackup="false"` on `<application>`, and neither
  `android:dataExtractionRules` nor `android:fullBackupContent`.
- `app/android/app/src/release/AndroidManifest.xml` — the two-line manifest `SPEC.md` §11 prints, with the
  same removal element.
- `app/android/app/src/debug/AndroidManifest.xml` and `app/android/app/src/profile/AndroidManifest.xml` —
  each **granting** `android.permission.INTERNET`, as Flutter's own template does, with a comment saying
  why the grant is correct and must not be removed.
- `app/android/app/build.gradle.kts` — `minSdk = 24`.
- `app/test/policy/android_manifest_test.dart` — the source-level assertions.
- A `android-release-manifest` job in `.github/workflows/validate.yml` that builds an unsigned release AAB
  and reads the **merged** manifest out of it with `aapt2 dump xmltree`, plus an upload of
  `manifest-merger-release-report.txt` as a build artefact.

## Why it is built this way

**Layer 2 is worth more than the three source-side layers combined, and the reason is who can check it.**
`four-layers.md`'s strength ladder: layer 1 is defeated by editing `pubspec.yaml` in a reviewed diff, layer
4 by deleting a test, layer 3 never applied. Layer 2 is enforced by the Linux kernel and is verifiable by
**anyone with the APK** — a regulator, a store reviewer, a journalist — without reading a line of our
source. `SPEC.md` §5.3 states the consequence: any socket the app opens fails at the kernel regardless of
what the Dart code says.

**`main/` as well as `release/`, and the reason is the case a grep cannot reach.** `SPEC.md` §11 prints
only the release manifest; `FLUTTER_GUIDE.md` Part 4.6 layer 2 and Part 9.3, and
`catchlaw-offline-guarantee` rule 3, all say main **and** release. There is no conflict — the guide and the
skill are the stronger form of the same mechanism. The extra value of `main/` is specific:
`tools:` markers act on manifests of *lower* priority, so a `remove` in `main/` strips an INTERNET grant
merged in by a plugin AAR. A grep over our own source can never catch that, because the grant is not in our
source. `dependency-hygiene` rule 7 calls the same thing a transitive network path.

**`xmlns:tools` is not boilerplate.** `SPEC.md` §11 records that the first draft's snippet omitted it and
that omitting it fails the build. `four-layers.md` explains the failure mode that follows: the merger
raises an unresolved-prefix error, which is a hard failure rather than a warning, and the person hitting it
"fixes" it by deleting the whole `uses-permission` line — at which point the permission comes back and
nothing is red. Test 2 exists for that sequence, not for the XML.

**Debug and profile keep INTERNET, by design, and a test protects the exception.** Flutter's hot reload and
the profile VM service need it (`SPEC.md` §11, `FLUTTER_GUIDE.md` §4.6, skill rule 4). Tests 4 and 5 assert
the grant is *present*, which reads backwards until you read the skill's reason: *a guard that breaks
`flutter run` is a guard someone deletes before lunch*. The guard test and `check_no_network.sh` both skip
those two source sets for the same reason.

**The proof is read off the built artefact, not off the source manifest.** `SPEC.md` §14 bullet 3 says so
explicitly, and the reason is the merger: what ships is the merged manifest, and the merged manifest can
contain a permission that appears in none of our four files. Reading our own XML proves what we wrote;
`aapt2 dump xmltree --file base/manifest/AndroidManifest.xml` on the AAB proves what the user installs.
`four-layers.md` gives `apkanalyzer manifest permissions` and `bundletool dump manifest` as the equivalent
forms; `aapt2` is used here because it is present in the Android SDK the runner already installs and needs
no extra download.

**`allowBackup="false"` and no `dataExtractionRules`.** `SPEC.md` §11: the catch log must not be swept into
a Google backup the user did not choose, and portability is served by the explicit export in §12. The
attribute defaults to **true**, so leaving it alone is a decision to upload every record the user owns —
the exact case `policy-grep-gate.md`'s worked example is written about. This deliberately differs from iOS
(T07), where `NSURLIsExcludedFromBackupKey` is *not* set because iCloud device backup is the user's own
encrypted backup; §11 says both choices are explained in S17.

**Rejected: `android:usesCleartextTraffic="false"` as a belt-and-braces measure.** It constrains cleartext
only and would be the Android echo of the ATS mistake T07 refuses to make. With no INTERNET permission
there is no traffic of any kind to constrain, and adding the attribute invites the reading that it is doing
some of the work.

**Rejected: asserting the permission's absence with a whole-file `contains`.** `policy-grep-gate.md`:
anchor a manifest assertion to the right element. A line reading `android.permission.INTERNET` is a *pass*
when it carries `tools:node="remove"` and a *failure* when it does not, so the needle has to be the
element and its attribute together, not the string.

**Rejected: a signed release build in CI.** `ci-pipeline-and-gates` rule 9 and the workflow skeleton: CI
proves the artefact compiles; signing belongs to a human or a secrets-scoped release workflow. No signing
secret in this job means nothing to leak, and the manifest question is answered identically by an unsigned
bundle.

## Tests first

Write `app/test/policy/android_manifest_test.dart` before touching any XML. Run it. **All ten must fail** —
`app/android/` holds the untouched Flutter template, which grants INTERNET in `debug/` only, has no
`release/` manifest, and does not set `allowBackup`.

Every test reads through `xmlOf()`, which strips `<!-- … -->` first. The manifests carry a comment
explaining the ban, and that comment contains the string `android.permission.INTERNET`; without stripping,
the rule's own explanation fails the rule (`policy-grep-gate.md`).

| # | Test name | Asserts | Why this case exists |
|---|---|---|---|
| 1 | `Release manifest removes android.permission.INTERNET` | element carries `tools:node="remove"` | `SPEC.md` §11's headline. This is the manifest an auditor diffs |
| 2 | `Release manifest declares the tools namespace` | `xmlns:tools` on `<manifest>` | §11 records that omitting it fails the build; four-layers.md records what happens next — somebody deletes the whole line and the permission returns silently |
| 3 | `Main manifest removes android.permission.INTERNET` | same element in `main/` | `tools:` markers act on lower-priority manifests, so this is what strips a grant merged in by a plugin AAR — the case a grep over our own source can never catch |
| 4 | `Debug manifest grants android.permission.INTERNET` | present, no `remove` | The exception, protected on purpose: a guard that breaks `flutter run` is deleted before lunch (skill rule 4) |
| 5 | `Profile manifest grants android.permission.INTERNET` | present, no `remove` | The profile VM service and DevTools attach. Same reason as 4, different source set |
| 6 | `Main manifest sets android:allowBackup to false` | inside `<application>` | The attribute defaults to true: left alone the OS uploads the catch log to a cloud backup the user never chose (`SPEC.md` §11) |
| 7 | `No manifest declares dataExtractionRules or fullBackupContent` | none of the four | §11 names `dataExtractionRules` specifically. Declaring a rules file is the API-31 way to re-enable what test 6 turned off |
| 8 | `No manifest declares ACCESS_BACKGROUND_LOCATION` | none of the four | `SPEC.md` §14 bullet 3 names it. The zone suggestion is a single-shot fix (§10 geolocator, §13 battery); a background grant would be a permission the product does not use and a store reviewer will ask about |
| 9 | `build.gradle.kts sets minSdk to 24` | `minSdk = 24` | `SPEC.md` §11: Android 7.0, a three-year-old mid-range phone. A higher floor drops the target device; a lower one ships to devices the app was never measured on |
| 10 | `No shipping manifest grants INTERNET without the remove marker` | all source sets except debug and profile | The general form, so a fifth source set added by a later flavour is covered without editing this test |

```dart
// app/test/policy/android_manifest_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'repo_root.dart';

final _xmlComment = RegExp(r'<!--.*?-->', dotAll: true);

/// Manifest text with comments removed. The manifests explain the INTERNET ban
/// in a comment that contains the banned string; without this the rule's own
/// explanation fails the rule (policy-grep-gate.md).
String xmlOf(String sourceSet) => repoFile('app/android/app/src/$sourceSet/AndroidManifest.xml')
    .readAsStringSync()
    .replaceAll(_xmlComment, '');

const shipping = <String>['main', 'release'];
const devOnly = <String>['debug', 'profile'];

final _internetElement = RegExp(
  r'<uses-permission[^>]*android:name="android\.permission\.INTERNET"[^>]*>',
);

void main() {
  test('Release manifest removes android.permission.INTERNET', () {
    final match = _internetElement.firstMatch(xmlOf('release'));
    expect(match, isNotNull);
    expect(match![0], contains('tools:node="remove"'));
  });

  test('Release manifest declares the tools namespace', () {
    expect(xmlOf('release'), contains('xmlns:tools="http://schemas.android.com/tools"'),
        reason: 'the merger raises an unresolved-prefix error without it, and the fix '
            'somebody reaches for is deleting the whole uses-permission line');
  });

  test('Main manifest removes android.permission.INTERNET', () {
    final match = _internetElement.firstMatch(xmlOf('main'));
    expect(match, isNotNull);
    expect(match![0], contains('tools:node="remove"'),
        reason: 'this is what strips a grant merged in by a plugin AAR — a case no grep '
            'over our own source can reach');
  });

  for (final sourceSet in devOnly) {
    test('${sourceSet[0].toUpperCase()}${sourceSet.substring(1)} manifest grants '
        'android.permission.INTERNET', () {
      final match = _internetElement.firstMatch(xmlOf(sourceSet));
      expect(match, isNotNull,
          reason: 'the Dart VM service needs it; a guard that breaks flutter run is a '
              'guard someone deletes before lunch');
      expect(match![0], isNot(contains('tools:node="remove"')));
    });
  }

  test('Main manifest sets android:allowBackup to false', () {
    expect(xmlOf('main'), contains('android:allowBackup="false"'),
        reason: 'the attribute defaults to TRUE — left alone the OS uploads the catch '
            'log to a cloud backup the user never chose (SPEC.md §11)');
  });

  test('No manifest declares dataExtractionRules or fullBackupContent', () {
    final offenders = <String>[
      for (final s in <String>[...shipping, ...devOnly])
        if (xmlOf(s).contains('dataExtractionRules') || xmlOf(s).contains('fullBackupContent')) s,
    ];
    expect(offenders, isEmpty, reason: 'the API-31 way to re-enable backup:\n$offenders');
  });

  test('No manifest declares ACCESS_BACKGROUND_LOCATION', () {
    final offenders = <String>[
      for (final s in <String>[...shipping, ...devOnly])
        if (xmlOf(s).contains('ACCESS_BACKGROUND_LOCATION')) s,
    ];
    expect(offenders, isEmpty,
        reason: 'the zone suggestion is a single-shot fix; SPEC.md §14 names this '
            'permission as a release blocker:\n$offenders');
  });

  test('build.gradle.kts sets minSdk to 24', () {
    expect(repoFile('app/android/app/build.gradle.kts').readAsStringSync(),
        contains('minSdk = 24'));
  });

  test('No shipping manifest grants INTERNET without the remove marker', () {
    final offenders = <String>[
      for (final dir in repoDir('app/android/app/src').listSync().whereType<Directory>())
        if (!devOnly.contains(dir.path.split('/').last) &&
            File('${dir.path}/AndroidManifest.xml').existsSync())
          for (final m in _internetElement
              .allMatches(File('${dir.path}/AndroidManifest.xml').readAsStringSync()
                  .replaceAll(_xmlComment, '')))
            if (!m[0]!.contains('tools:node="remove"')) dir.path,
    ];
    expect(offenders, isEmpty, reason: 'layer 2 breached:\n${offenders.join('\n')}');
  });
}
```

**Run:** `cd app && flutter test test/policy/android_manifest_test.dart` → 10 failures. Tests 1, 2 and 3
throw on the missing `release/` manifest and the template's lack of `tools:`; test 4 passes early — the
Flutter template already ships a debug manifest granting INTERNET. That is expected and it means test 4 is
asserting nothing yet: delete the grant from the template's debug manifest, confirm the test goes red,
restore it. A test that has never been red has never been run.

## Implementation outline

1. Run `flutter create --platforms=android .` inside `app/` if the template is not already there, then
   revert everything except `android/` and the gradle files — this task adds no Dart.
2. Edit `main/AndroidManifest.xml`: add `xmlns:tools` to `<manifest>`, add the INTERNET element with
   `tools:node="remove"`, add `android:allowBackup="false"` to `<application>`, and add the comment that
   states the consequence to the user — *this app ships without the INTERNET permission, so any socket it
   opens fails at the kernel; a grant here silently turns a verifiable claim into a promise* — at the point
   of temptation, which is beside the element.
3. Create `release/AndroidManifest.xml` as `SPEC.md` §11 prints it: `<manifest>` with both namespaces and
   the single removal element. Nothing else belongs in a build-type manifest.
4. Add the explanatory comment to `debug/` and `profile/`: the grant is for the Dart VM service, it is
   correct, and removing it breaks `flutter run` rather than improving anything.
5. Set `minSdk = 24` in `app/android/app/build.gradle.kts`.
6. Add the CI job:
   ```yaml
   android-release-manifest:
     needs: flutter
     runs-on: ubuntu-24.04
     timeout-minutes: 25
     steps:
       - uses: actions/checkout@v4              # VERIFY: confirm the current major
       - uses: actions/setup-java@v4            # VERIFY: confirm the current major
         with: { distribution: temurin, java-version: '17', cache: gradle }
       - uses: subosito/flutter-action@v2
         with: { channel: stable, flutter-version-file: .fvmrc, cache: true }
       - run: dart pub get
       - run: cd app && flutter build appbundle --release      # unsigned: no secret in this job
       - name: Merged release manifest grants no INTERNET and no background location
         run: |
           set -euo pipefail
           AAPT2="$(ls "$ANDROID_HOME"/build-tools/*/aapt2 | sort | tail -1)"
           "$AAPT2" dump xmltree --file base/manifest/AndroidManifest.xml \
             app/build/app/outputs/bundle/release/app-release.aab > merged-manifest.txt
           for perm in android.permission.INTERNET android.permission.ACCESS_BACKGROUND_LOCATION; do
             if grep -q "$perm" merged-manifest.txt; then
               echo "::error::$perm is present in the MERGED release manifest"
               grep -n "$perm" merged-manifest.txt
               exit 1
             fi
           done
           grep -q 'allowBackup' merged-manifest.txt || { echo "::error::allowBackup absent"; exit 1; }
           echo "merged release manifest: no INTERNET, no background location"
       - uses: actions/upload-artifact@v4       # VERIFY: confirm the current major
         with:
           name: manifest-merger-release-report
           path: app/build/app/outputs/logs/manifest-merger-release-report.txt
           retention-days: 14
   ```
   Note the `if … then … exit 1; fi` form. `grep -q X && exit 1 || true` under `set -e` swallows the exit
   and reports success, which would be a gate that cannot fail.
7. Prove the job once: temporarily delete `tools:node="remove"` from `main/` and add a plain grant, push,
   watch the AAB step go red naming the permission, revert. The merger report artefact from that run is
   what names the source of a grant when one appears for real (`verification-ritual.md` failure triage,
   row 5).
8. Re-run the ten tests plus the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 10 tests pass. Tests 1–3 and 6–10 failed first; tests 4 and 5 were proved red by removing the
      template's debug grant and were restored.
- [ ] `flutter build appbundle --release` succeeds — the `xmlns:tools` declaration is present, so the
      merger does not raise an unresolved-prefix error (`SPEC.md` §11).
- [ ] `aapt2 dump xmltree --file base/manifest/AndroidManifest.xml` on the built AAB prints no
      `android.permission.INTERNET` and no `ACCESS_BACKGROUND_LOCATION`. The claim is read off the
      artefact, not off our source.
- [ ] `flutter run` still hot-reloads on a device or emulator. Confirmed by hand, once, and stated in the
      commit body — this is `catchlaw-offline-guarantee`'s own definition-of-done item and the reason the
      debug grant exists.
- [ ] `manifest-merger-release-report.txt` is uploaded as a build artefact and was read once, so that the
      baseline is known before a plugin ever adds a grant.
- [ ] No `android:usesCleartextTraffic`, no ATS-equivalent attribute, and no signing secret anywhere in the
      job.
- [ ] `check_no_network.sh app/lib` check 3 now has manifests to read and reports clean, including its
      `xmlns:tools` sub-check.

## Gates

```bash
cd app && flutter test test/policy/android_manifest_test.dart && flutter test && cd ..
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh app/lib
bash tools/gates/no_banned_apis.sh app/lib
# on a machine with the Android SDK:
cd app && flutter build appbundle --release && cd ..
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
build(android): remove INTERNET from the shipping manifests and disable backup

Layer 2 of the offline guarantee, and the only layer a regulator, a store
reviewer or a journalist can check from the APK without trusting us. SPEC.md
§5.3: without the permission the kernel refuses every socket whatever the Dart
code says.

The removal element goes in main/ as well as release/. tools: markers act on
manifests of lower priority, so a remove in main/ strips an INTERNET grant
merged in by a plugin AAR — the case no grep over our own source can reach.
FLUTTER_GUIDE Part 4.6 and Part 9.3 both say main and release; SPEC.md §11
prints the release file.

The xmlns:tools declaration is on the manifest element. SPEC.md §11 records
that omitting it fails the build; four-layers.md records what happens next,
which is that somebody deletes the whole uses-permission line and the
permission comes back with nothing red.

debug/ and profile/ keep INTERNET and tests assert that they do. The Dart VM
service needs it, and a guard that breaks flutter run is a guard someone
deletes before lunch.

allowBackup defaults to true. Left alone, the OS uploads the catch log to a
Google backup the user never chose; portability is served by the explicit
export in SPEC.md §12. dataExtractionRules is absent for the same reason on
API 31+.

The claim is read off the built AAB with aapt2 dump xmltree, not off our source
manifests, because what ships is the MERGED manifest and it can contain a
permission that appears in none of our four files. The merger report is
uploaded so the baseline is known before a plugin ever adds one.

Task: E01/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
