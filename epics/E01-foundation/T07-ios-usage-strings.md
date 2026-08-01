# E01/T07 — iOS: usage strings, and the honesty about what iOS cannot prove

| | |
|---|---|
| **Epic** | E01 — Foundation, workspace and the offline gates |
| **Branch** | `epic/01-foundation` (shared) |
| **Commit** | `build(ios): localise the two usage strings and record what iOS cannot prove` |
| **Depends on** | T01 (`app/ios/` comes from the Flutter template), T03 (the suite this runs in) |
| **Size** | M |
| **Spec** | `SPEC.md` §11 iOS (in full), §14 static block bullet 4, §5.3, §9.1 (the six locales) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | Owns layer 3 and rule 5 — iOS has **no** equivalent opt-out, and `references/four-layers.md` holds the four-row "is this claim true?" table plus the store wording marked *use verbatim, do not improve* |
| `ci-pipeline-and-gates` | Rule 10: state plainly what CI cannot prove, so the manual on-device pass is treated as a load-bearing release artefact rather than a chore. That rule is this task's shape |
| `catchlaw-conventions-index` | Rule 11 — no account, no identifier ever leaves the device — which is why the usage strings say what they say |
| `dependency-hygiene` | Rule 7's identifier row: a usage string declares a capability, and a capability the product does not ship is liability it does not need |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §11 iOS | The whole block: the two usage strings, that `NSLocationAlwaysAndWhenInUseUsageDescription` is **not** declared, that `NSURLIsExcludedFromBackupKey` is deliberately not set and why that differs from Android, iOS 13, and the sentence that the first draft's proposed proofs were worthless |
| `SPEC.md` | §14 static block, bullet 4 | `Info.plist` declares no ATS exceptions and no `NSLocationAlwaysAndWhenInUse` |
| `SPEC.md` | §5.3 | "On iOS there is no OS-level equivalent … the iOS guarantee therefore rests on the dependency allowlist plus a mandatory device packet capture" |
| `SPEC.md` | §9.1 | The six locales and the evidence for each. `pt_BR` carries a region because the content is Brazilian |
| `SPEC.md` | §10 | The `camera` row — in-app capture so photos never enter the shared camera roll, and `image_picker` rejected for exactly that reason |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 3 — iOS, and the sentence to write" | The four false claims, the one true one, and the approved store wording |
| `.claude/skills/catchlaw-offline-guarantee/references/verification-ritual.md` | "iOS — rvictl plus Wireshark", "Pass criteria" | What the real iOS proof is, and that it happens per release rather than per PR |
| `.claude/skills/catchlaw-offline-guarantee/SKILL.md` | "Layer 3 — iOS, stated honestly" | The `Info.plist` comment block, marked WRONG on the explicit ATS dict and RIGHT on the strict default plus a written note |
| `epics/DECISIONS.md` | D-3 | Six locales: `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`. Never `ur`, never bare `pt` |

## What this delivers

- `app/ios/Runner/Info.plist` — gains `NSCameraUsageDescription` and
  `NSLocationWhenInUseUsageDescription` (the base-language values), a `CFBundleLocalizations` array of the
  six locales, `MinimumOSVersion` 13.0, and the layer-3 comment block. It declares **no**
  `NSAppTransportSecurity` key, **no** `NSLocationAlwaysAndWhenInUseUsageDescription` and **no**
  `NSPhotoLibraryUsageDescription`.
- `app/ios/Runner/{ar,en,es,gl,ca,pt-BR}.lproj/InfoPlist.strings` — six files, each defining both usage
  strings. `pt-BR` is the Apple spelling of D-3's `pt_BR`; the underscore form is the ARB spelling and is
  wrong in an `.lproj` directory name.
- `app/ios/Podfile` — `platform :ios, '13.0'`.
- `app/ios/Runner.xcodeproj/project.pbxproj` — `IPHONEOS_DEPLOYMENT_TARGET = 13.0` in every configuration.
- `app/test/policy/ios_plist_test.dart`.

## Why it is built this way

**The honest sentence is the deliverable.** `SPEC.md` §11 opens the iOS block with it: *there is no iOS
equivalent of removing the INTERNET permission, and the first draft's proposed proofs were worthless.*
`four-layers.md` tabulates the four false claims that were proposed:

| Claim | True? | Why it was proposed, and why it fails |
|---|---|---|
| "ATS prevents the app going online" | **no** | ATS constrains cleartext HTTP; every TLS request is permitted. It looks like a network switch and is a transport-security policy |
| "`NSAllowsArbitraryLoads: false` is an offline switch" | **no** | It is the default, and it only tightens cleartext policy |
| "the binary links no `Network.framework`, so it cannot connect" | **no** | `dart:io`'s `HttpClient` uses BSD sockets in libSystem and `URLSession` comes from Foundation/CFNetwork, which the Flutter engine links unconditionally |
| "there is an iOS entitlement to deny outbound networking" | **no** | The iOS sandbox has no such deny entitlement |

Each of those is the kind of claim that survives a review because it sounds like engineering. The one true
statement is the fifth row: on iOS the guarantee is source-side (layers 1 and 4) plus a per-release packet
capture. `four-layers.md` carries the store and privacy-questionnaire wording marked *use verbatim, do not
improve*.

**Rejected: declaring `NSAppTransportSecurity` at all, even with `NSAllowsArbitraryLoads` false.**
`SPEC.md` §11 says ATS "is retained as defence-in-depth only, and is documented as not blocking HTTPS", and
the strict policy is already the default — so retaining it means *not writing the key*, not writing it with
the safe value. The skill's own example marks the explicit dict **WRONG**, and `SPEC.md` §14 bullet 4
requires "no ATS exceptions": the cleanest way to declare no exceptions is to declare no ATS dictionary,
because an `NSExceptionDomains` entry is only ever added *inside* one that already exists. A key that does
nothing and reads as protection is worse than an absent key with a comment.

**Rejected: writing a fresh `docs/ios-offline-gap.md`.** `four-layers.md` already holds the approved
wording and marks it verbatim. `CONVENTIONS.md`'s rule is cite, never restate — two copies drift, and here
the drifting copy would be the one quoted into a privacy submission. The `Info.plist` comment names the
reference; E21 quotes it into the store answers.

**`NSLocationAlwaysAndWhenInUseUsageDescription` is absent, and its absence is a test.** `SPEC.md` §11 and
§14. Declaring it asks for a capability the product does not use — the zone suggestion is a single-shot,
user-initiated fix with a 20-second timeout (§10 `geolocator`, §13 battery). An unused permission string is
a question at review and a liability in the privacy label (`dependency-hygiene`'s identifier row).

**`NSPhotoLibraryUsageDescription` is absent too, and that is not incidental.** `SPEC.md` §10 rejects
`image_picker` explicitly *so that photos never enter the shared camera roll*. A photo-library usage string
is the visible symptom of that rejection being undone: it would appear the moment somebody swapped the
in-app camera for a picker, and nothing else in the tree would notice.

**Backup differs from Android on purpose.** `SPEC.md` §11: `NSURLIsExcludedFromBackupKey` is **not** set,
because iCloud device backup is the user's own encrypted backup and is acceptable; what the product
excludes is any *vendor* server. Android's `allowBackup="false"` (T06) has a different destination —
Google's servers under a different trust model — and §11 says both choices are explained in S17. So this
task deliberately does not mirror T06, and the reason is written here rather than left as an inconsistency.

**Six `.lproj` bundles, because a permission dialog is where trust is decided.** `SPEC.md` §11 requires the
usage strings "localised into all six languages"; §9.1 justifies each locale by the publication language
of the instrument being bundled. A missing `InfoPlist.strings` does not fail anything — iOS falls back to
the base language — so the failure is an Arabic-speaking user in Ras Al Khaimah reading an English
sentence at the exact moment they decide whether to grant camera access. Test 8 exists for that user.

**What CI cannot do here, stated rather than glossed.** `ci-pipeline-and-gates` rule 10. The Linux runner
cannot build, codesign or run an iOS app, so every assertion in this task is source-level: it proves what
is in the `Info.plist`, and nothing about what the binary does. The real iOS evidence is E21's
`rvictl -s <udid>` capture with Wireshark, over a five-minute exercise, with the device network **up** —
`verification-ritual.md` marks a capture taken with no connectivity as INVALID, because the app must have
had the opportunity to call out. That capture blocks the release; this task's tests do not pretend to.

## Tests first

Write `app/test/policy/ios_plist_test.dart` before touching the plist. Run it. **Twelve of the cases must
fail** — the Flutter template's `Info.plist` has neither usage string, no `CFBundleLocalizations` and no
`.lproj` directories beyond `Base`.

Tests 3, 4 and 5 assert *absence* and will pass against the untouched template, which means they are
asserting nothing yet. Prove each red first: add `NSLocationAlwaysAndWhenInUseUsageDescription`, add
`NSPhotoLibraryUsageDescription`, add an `NSAppTransportSecurity` dict, watch all three go red, remove
them. A test that has never been red has never been run.

| # | Test name | Asserts | Why this case exists |
|---|---|---|---|
| 1 | `Info.plist declares NSCameraUsageDescription` | key present, value non-empty | `SPEC.md` §11. iOS kills the app on first camera use if the string is missing, and the crash looks like a bug in the catch log |
| 2 | `Info.plist declares NSLocationWhenInUseUsageDescription` | key present, value non-empty | §11. Same failure mode on the zone screen |
| 3 | `Info.plist does not declare NSLocationAlwaysAndWhenInUseUsageDescription` | key absent | §11 and §14 bullet 4. Asking for a capability the product does not use is a question at review and a worse privacy label |
| 4 | `Info.plist does not declare NSPhotoLibraryUsageDescription` | key absent | §10 rejects `image_picker` so photos never enter the shared roll. This string is the visible symptom of that rejection being undone |
| 5 | `Info.plist declares no NSAppTransportSecurity key` | key absent | §14 bullet 4: no ATS exceptions. The strict default is stronger than any dict we could write, and an exception is only ever added inside a dict that already exists |
| 6 | `Info.plist lists exactly the six shipped locales in CFBundleLocalizations` | set equality | D-3. Never `ur`, never bare `pt` |
| 7 | `InfoPlist.strings exists for $locale` (loop, 6 cases) | file present | The parameter is interpolated so `--plain-name ar` selects one (`CONVENTIONS.md` §5) |
| 8 | `$locale InfoPlist.strings defines both usage-string keys` (loop, 6 cases) | both keys | A missing key falls back to the base language inside a permission dialog — the one screen where a fisher decides whether to trust the app, and cannot guess the meaning |
| 9 | `No lproj directory names a locale outside the six` | directory listing | D-3, and the Apple spelling: `pt-BR.lproj`, never `pt_BR.lproj` and never `pt.lproj` |
| 10 | `Info.plist sets MinimumOSVersion to 13.0` | key value | `SPEC.md` §11's floor |
| 11 | `Podfile pins the iOS platform to 13.0` | `platform :ios, '13.0'` | The plist and the Podfile must agree, or pods build against a target the app does not, and the mismatch surfaces as a link error on somebody else's machine |
| 12 | `Info.plist records that iOS provides no permission-level network block` | comment names layers 1 and 4 | The honesty requirement. A plist with no note invites the next person to add ATS and call it a guarantee — which is precisely what the first draft did |

```dart
// app/test/policy/ios_plist_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'repo_root.dart';

/// D-3, in the Apple spelling: pt-BR.lproj, never pt_BR.lproj and never pt.lproj.
const shippedLocales = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt-BR'];

const usageKeys = <String>[
  'NSCameraUsageDescription',
  'NSLocationWhenInUseUsageDescription',
];

String plist() => repoFile('app/ios/Runner/Info.plist').readAsStringSync();

bool declaresKey(String key) => RegExp('<key>$key</key>').hasMatch(plist());

String strings(String locale) =>
    repoFile('app/ios/Runner/$locale.lproj/InfoPlist.strings').readAsStringSync();

void main() {
  for (final key in usageKeys) {
    test('Info.plist declares $key', () {
      expect(declaresKey(key), isTrue);
    });
  }

  test('Info.plist does not declare NSLocationAlwaysAndWhenInUseUsageDescription', () {
    expect(declaresKey('NSLocationAlwaysAndWhenInUseUsageDescription'), isFalse,
        reason: 'the zone suggestion is a single-shot, user-initiated fix (SPEC.md §10) — '
            'asking for always-on location is a capability the product does not use');
  });

  test('Info.plist does not declare NSPhotoLibraryUsageDescription', () {
    expect(declaresKey('NSPhotoLibraryUsageDescription'), isFalse,
        reason: 'SPEC.md §10 rejects image_picker so photos never enter the shared camera '
            'roll; this string is what appears when that rejection is undone');
  });

  test('Info.plist declares no NSAppTransportSecurity key', () {
    expect(declaresKey('NSAppTransportSecurity'), isFalse,
        reason: 'SPEC.md §14: no ATS exceptions. The strict default is stronger than any '
            'dict we could write, and an exception is only added inside one that exists');
  });

  test('Info.plist lists exactly the six shipped locales in CFBundleLocalizations', () {
    final block = RegExp(r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>', dotAll: true)
        .firstMatch(plist());
    expect(block, isNotNull);
    final listed = RegExp(r'<string>([^<]+)</string>')
        .allMatches(block![1]!)
        .map((m) => m[1]!)
        .toSet();
    expect(listed, shippedLocales.toSet(), reason: 'D-3: Catalan ships, Urdu does not');
  });

  for (final locale in shippedLocales) {
    test('InfoPlist.strings exists for $locale', () {
      expect(repoFile('app/ios/Runner/$locale.lproj/InfoPlist.strings').existsSync(), isTrue);
    });

    test('$locale InfoPlist.strings defines both usage-string keys', () {
      final missing = usageKeys.where((k) => !strings(locale).contains(k)).toList();
      expect(missing, isEmpty,
          reason: 'a missing key falls back to the base language inside a permission '
              'dialog, which is where a fisher decides whether to trust the app:\n$missing');
    });
  }

  test('No lproj directory names a locale outside the six', () {
    final found = repoDir('app/ios/Runner')
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split('/').last)
        .where((n) => n.endsWith('.lproj'))
        .map((n) => n.substring(0, n.length - '.lproj'.length))
        .where((n) => n != 'Base')
        .toSet();
    expect(found.difference(shippedLocales.toSet()), isEmpty,
        reason: 'D-3, in the Apple spelling: pt-BR, never pt_BR and never pt');
  });

  test('Info.plist sets MinimumOSVersion to 13.0', () {
    expect(plist(), matches(RegExp(
        r'<key>MinimumOSVersion</key>\s*<string>13\.0</string>')));
  });

  test('Podfile pins the iOS platform to 13.0', () {
    expect(repoFile('app/ios/Podfile').readAsStringSync(), contains("platform :ios, '13.0'"));
  });

  test('Info.plist records that iOS provides no permission-level network block', () {
    expect(plist(), contains('no permission-level network opt-out'),
        reason: 'a plist with no note invites the next person to add ATS and call it a '
            'guarantee — which is exactly what the first draft did');
  });
}
```

**Run:** `cd app && flutter test test/policy/ios_plist_test.dart` → 20 of the 22 cases fail (tests 3, 4 and
5 pass early; see above). Prove those three red by planting each key, then remove the plants.

## Implementation outline

1. Run `flutter create --platforms=ios .` inside `app/` if the template is not present; keep `ios/` and
   discard the rest — this task adds no Dart.
2. Add the two usage strings to `Info.plist`. Write the base-language values as statements of what the
   capability is for, matching the product's voice: the camera string says the photo stays on the device
   and is attached to a catch record; the location string says a single fix is used to suggest a zone and
   that nothing is sent anywhere. No marketing, no reassurance that is not a fact.
3. Add `CFBundleLocalizations` with the six values, then create the six `.lproj` directories with an
   `InfoPlist.strings` each. Author `en` first, `ar`, `es`, `gl`, `ca` and `pt-BR` from the same source
   text; the domain-translation rules in `SPEC.md` §9.2 apply to bundled *content*, and these two strings
   are UI chrome, so a general translation with the native-speaker review of §9.2 step 3 is the standard
   they meet. `pt-BR.lproj`, with the hyphen.
4. Add the layer-3 comment block to `Info.plist`, taken from `catchlaw-offline-guarantee/SKILL.md`'s
   "Layer 3 — iOS, stated honestly": ATS is at its strict default and is not declared; iOS has **no
   permission-level network opt-out**; CFNetwork is linked by the Flutter engine whether or not it is
   called, so "links no `Network.framework`" is not a test; on iOS the guarantee rests on layer 1 and layer
   4 and is verified per release with `rvictl` and Wireshark. Point at
   `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` for the store wording rather than
   copying it.
5. Set `platform :ios, '13.0'` in the `Podfile` and `IPHONEOS_DEPLOYMENT_TARGET = 13.0` in every build
   configuration in `project.pbxproj`.
6. Re-run the tests. Then read the plist once, top to bottom, asking the only question that matters here:
   does any line in it imply a guarantee iOS does not provide?

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 22 test cases pass. Tests 3, 4 and 5 were each proved red against a planted key and the plants
      were removed.
- [ ] `Info.plist` declares exactly two usage-description keys, and six `InfoPlist.strings` files define
      both of them.
- [ ] No `NSAppTransportSecurity`, no `NSLocationAlwaysAndWhenInUse…`, no `NSPhotoLibraryUsageDescription`,
      no `UIBackgroundModes`, no push entitlement, no App Groups, no Siri intents (`SPEC.md` §11).
- [ ] `NSURLIsExcludedFromBackupKey` is **not** set, and the reason it differs from Android's
      `allowBackup="false"` is written in the plist comment (`SPEC.md` §11, both explained in S17).
- [ ] The plist's layer-3 note says iOS has no permission-level network opt-out and names layers 1 and 4.
      It does not restate the store wording; it points at `four-layers.md`, which marks that wording
      verbatim.
- [ ] The commit body states plainly that CI proves nothing about iOS runtime behaviour and that the
      release evidence is E21's `rvictl` capture. Not a footnote.
- [ ] An `xcodebuild` or `flutter build ios --no-codesign` was run once on a Mac and the plist merged
      cleanly — or, if no Mac was available, that is stated in the commit body rather than implied.

## Gates

```bash
cd app && flutter test test/policy/ios_plist_test.dart && flutter test && cd ..
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
plutil -lint app/ios/Runner/Info.plist                    # macOS only; states so if skipped
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh app/lib
bash tools/gates/no_banned_apis.sh app/lib
```

`plutil` exists only on macOS. On Linux the plist is validated by the tests above, which parse it; if the
lint step is skipped, say so in the commit body rather than leaving the gate list looking complete.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
build(ios): localise the two usage strings and record what iOS cannot prove

SPEC.md §11 opens the iOS block by saying the first draft's proposed proofs
were worthless, and four-layers.md tabulates why: ATS constrains cleartext and
permits every TLS request; NSAllowsArbitraryLoads: false is the default;
"links no Network.framework" is not a test because dart:io's HttpClient uses
BSD sockets in libSystem and CFNetwork is linked by the Flutter engine
regardless; and iOS has no deny-networking entitlement. All four sound like
engineering, which is how they survived a review.

So this commit declares no NSAppTransportSecurity key at all. SPEC.md §14
requires no ATS exceptions, the strict policy is already the default, and an
NSExceptionDomains entry is only ever added inside a dict that already exists.
A key that does nothing and reads as protection is worse than an absent key
with a comment, and the comment is here.

NSLocationAlwaysAndWhenInUseUsageDescription is absent: the zone suggestion is
a single-shot user-initiated fix. NSPhotoLibraryUsageDescription is absent
because SPEC.md §10 rejects image_picker so that photos never enter the shared
camera roll — that string is what would appear if the in-app camera were ever
swapped out, and nothing else in the tree would notice.

Both usage strings ship in all six locales (D-3: ar, en, es, gl, ca, pt-BR —
the Apple spelling of pt_BR). A missing key falls back to the base language
inside a permission dialog, which is the one screen where a fisher decides
whether to trust the app.

NSURLIsExcludedFromBackupKey is deliberately NOT set, unlike Android's
allowBackup=false. iCloud device backup is the user's own encrypted backup;
what this product excludes is a vendor server. SPEC.md §11 explains both in
S17.

CI proves nothing about iOS runtime behaviour. The Linux runner cannot build,
codesign or run this app, so every assertion here is source-level. The iOS
evidence is E21's rvictl + Wireshark capture, taken with the network UP,
because a capture on a device with no connectivity is INVALID.

Task: E01/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
