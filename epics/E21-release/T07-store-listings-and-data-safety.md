# E21/T07 — Store listings in six locales, and the data-safety form

| | |
|---|---|
| **Epic** | E21 — Offline verification and release readiness |
| **Branch** | `epic/21-release` (shared) |
| **Commit** | `docs(l10n): six localised store listings, per-locale display names and the data-safety answers` |
| **Depends on** | T01 (the allowlist and manifest evidence the data-safety answers rest on) |
| **Size** | L |
| **Spec** | `SPEC.md` §15 step 20; §9.1 (the six locales and why each); §5.3 (the wording); §11 (both platforms); §17 S17 |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | `references/four-layers.md` holds the wording approved for the store listing and the privacy questionnaire, marked "use verbatim, do not improve". This task's central content is quoted from there, not written |
| `catchlaw-conventions-index` | Invariant 2's banned lexicon in `references/product-invariants.md` — a store description is the one place a verdict-shaped sentence escapes the app, and invariant 11's "nothing leaves the device", which is what the data-safety form declares |
| `catchlaw-reference-database` | Rule 10 and the backup policy, because the Play data-safety form and the iOS privacy label both ask where data is stored and whether it is backed up |
| `ci-pipeline-and-gates` | Rule 7's three-criteria bar for the listing gate, and `references/policy-grep-gate.md`'s "write the reason for a stranger" |
| `dependency-hygiene` | Rule 7: a transitively-arriving telemetry core can worsen the store privacy label even when nothing calls it. The label is only true down to the last transitive package |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §15 step 20 | Localised listings, per-locale display names, data-safety declarations, screenshots shot in `ar` and `gl` rather than only `en` |
| `SPEC.md` | §9.1 | The six locales and the justification for each — the listing copy repeats the product's reason for existing in that language |
| `SPEC.md` | §5.3 | The accurate guarantee, including the iOS sentence that must not be softened in a listing |
| `SPEC.md` | §11 Android | The release manifest grants no `INTERNET`, so "the Play data-safety form can then honestly declare that no data is collected or shared" |
| `SPEC.md` | §11 iOS | No push entitlement, no background modes, and the backup asymmetry the privacy label describes |
| `SPEC.md` | §6 S17 | The plain statement that the app collects and transmits nothing, and why no privacy-policy URL is needed — the listing must agree with the app |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 3 — iOS, and the sentence to write" | The four false claims table, and the approved verbatim paragraph |
| `.claude/skills/catchlaw-offline-guarantee/SKILL.md` | rule 5 | iOS has no equivalent opt-out — write that down, never fake it |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | "2 — Statement of fact, never an instruction" | The banned lexicon the listing gate greps for |
| `dependency-hygiene` → `references/dependency-gate-and-audit.md` (Flutter-Skills plugin) | "The refuse-outright list" | Why the privacy label depends on the transitive tree and not on the direct dependency list |
| `epics/DECISIONS.md` | D-3 | Exactly six locales: `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`. Never `ur`, never `app_pt` |

## What this delivers

- `store/README.md` — the index: what each directory is for, which platform consumes it, and the record
  of any locale a platform does not offer.
- `store/listings/{ar,en,es,gl,ca,pt_BR}/title.txt`, `short_description.txt`, `full_description.txt` —
  eighteen files. Each `full_description.txt` carries the approved offline paragraph from
  `four-layers.md` verbatim.
- `store/display-names.md` — the per-locale display name for each platform, with the resource paths:
  `app/android/app/src/main/res/values/strings.xml` (default `en`), `values-ar`, `values-es`,
  `values-gl`, `values-ca` and `values-b+pt+BR` (the BCP-47 qualifier form; `values-pt-rBR` is the
  legacy equivalent), and `app/ios/Runner/{ar,es,gl,ca,pt-BR}.lproj/InfoPlist.strings` carrying
  `CFBundleDisplayName`.
- The strings files themselves, one `app_name` per locale.
- `store/screenshots/plan.md` — the shot list and the rule that the `ar` and `gl` sets are captured on
  device in that locale, never composited from the `en` set.
- `store/data-safety.md` — the Play Data safety answers, the iOS privacy-label answers, and the evidence
  each answer rests on.
- `app/ios/Runner/PrivacyInfo.xcprivacy` — `NSPrivacyTracking` false, `NSPrivacyTrackingDomains` empty,
  `NSPrivacyCollectedDataTypes` empty, and `NSPrivacyAccessedAPITypes` derived from the shipped plugins'
  own privacy manifests.
- `tools/gates/check_store_listings.sh` — the listing gate.
- `app/test/policy/store_listing_gate_test.dart` — drives it, plus the locale-set and display-name rows.

## Why it is built this way

**The offline sentence is quoted, not written.** `four-layers.md` carries a paragraph marked "use
verbatim, do not improve", and the reason it exists is that every attempt to improve it makes it either
weaker or false. It states three things in order: no network requests; on Android the OS refuses any
connection because the `INTERNET` permission is absent; iOS provides no equivalent permission-level
control and the guarantee there is enforced in source and verified before each release with a packet
capture. A listing that stops after the second clause is a false claim in a privacy submission, which
`catchlaw-offline-guarantee` rule 5 calls a worse liability than a documented, mitigated gap. The gate
asserts the paragraph is present in all six locales — the surrounding copy is translated, this paragraph
is translated faithfully and its three clauses are all present.

**Six locales, because §9.1 justified each by the publication language of the instrument.** A listing in
five would leave one bundled jurisdiction addressed in a language its own regulator does not publish in.
D-3 fixes the set; the gate asserts it exactly, including the absence of a `ur` directory and of a
region-less `pt`, because those two names appear in older skill text and are exactly what a helpful
autocomplete will produce.

**Per-locale display names are a resource question, not a listing question.** The name under the icon
comes from `android:label` resolved through `values-<qualifier>/strings.xml` and from
`CFBundleDisplayName` in a per-`.lproj` `InfoPlist.strings`. Android's qualifier for Brazilian
Portuguese is the BCP-47 form `b+pt+BR`; iOS wants `pt-BR.lproj`. Getting either wrong produces an app
that silently falls back to English on exactly the devices the locale was added for, and nothing in the
build warns.

**Screenshots are shot in `ar` and `gl` on device.** §15 step 20 says so, and the reason is E20's work:
RTL mirroring, the ruler's deliberate LTR exception and the resolved numeral system are all things a
composited screenshot would get right by accident and a real one gets right or exposes. A `gl` set also
proves the Galician content actually renders, which is the product's whole claim in that market (§9.1).

**The data-safety form is answered from evidence, not from intent.** "No data collected, no data shared"
is only true if nothing in the transitive tree collects — `dependency-hygiene` rule 7 is explicit that a
telemetry core can register data categories even when nothing calls it. So each answer in
`store/data-safety.md` names its evidence: T01's allowlist diff for "no network path", the merged
manifest dump for "no `INTERNET`", T02's captures for the runtime claim, and the absence of any
analytics or crash SDK from `dart pub deps`.

**Rejected: an inline privacy-policy URL.** §6 S17 says the app states plainly that it collects and
transmits nothing and why no privacy-policy URL is needed. Adding a hosted URL to satisfy a form field
would create the first thing about this product that lives on a server, and §5.3 has already banned
handing a URL to a browser from inside the app.

**Rejected: guessing `NSPrivacyAccessedAPITypes` reason codes.** Apple's required-reason list changes and
every plugin ships its own privacy manifest. The entries are derived by reading the bundled manifest of
each plugin in `app/pubspec.yaml`, and `store/data-safety.md` records where each entry came from. A
guessed code is a rejection on submission at best and a false declaration at worst.

**Rejected: marketing copy that gives fishing advice.** `product-invariants.md` invariant 2 binds the
app's verdicts; a store description is outside the app and therefore outside that gate's usual scope,
which is exactly why it is the place the banned lexicon will reappear. "Know what you can keep" is the
sentence that will be written. The gate greps the descriptions for the same lexicon, and the reason is
written into the script for a stranger to read.

## Tests first

Write every row before creating a single listing file. Run them. **They must fail** — `store/` does not
exist. If row 1 passes now, the test is wrong: it is almost certainly asserting on a glob that returns
an empty set, which passes vacuously (`CONVENTIONS.md` §7's failure mode, in Dart).

| # | Test name | Expected | Why this case exists |
|---|---|---|---|
| 1 | `store/listings holds exactly the six locales from D-3` | set equality with `{ar, en, es, gl, ca, pt_BR}` | D-3. Asserting equality rather than containment is what catches both a missing `ca` and a stray `ur` |
| 2 | `store/listings holds no ur directory and no region-less pt` | absent | Named separately because these two are what older skill text says and what an autocomplete offers. A generic set-equality failure would not say which mistake was made |
| 3 | `Every listing locale carries a title, a short description and a full description` | 3 non-empty files each | A locale directory that exists with two of three files is a half-shipped locale, and the store will accept it |
| 4 | `Every full description carries the approved offline paragraph` | present in all six | `four-layers.md`'s verbatim wording. A listing that drops it is a listing that claims less, or worse, more |
| 5 | `No full description claims an iOS permission-level network block` | banned phrases absent | The specific false claim `catchlaw-offline-guarantee` rule 5 exists to prevent, in the specific document where it would be most damaging |
| 6 | `No listing text uses a banned imperative from the verdict lexicon` | no match | Invariant 2 leaking into marketing copy. "Know what you can keep" is the sentence this row is here to reject |
| 7 | `No listing text offers sync, an account, a cloud or an update feed` | no match | The product has none of these. A listing that implies one produces a refund request and a one-star review that is factually correct |
| 8 | `Every locale has an Android display-name resource` | 6 resolved paths exist | Including the default `values/` for `en`. A missing qualifier directory falls back to English silently, on exactly the devices the locale was for |
| 9 | `The Brazilian Portuguese Android qualifier is the BCP-47 form` | `values-b+pt+BR` present | The one qualifier that is not the obvious two-letter form, and the one that will be written as `values-pt` |
| 10 | `Every locale has an iOS InfoPlist.strings declaring CFBundleDisplayName` | 6 files, key present | The iOS half of row 8, which fails independently and silently |
| 11 | `screenshots/plan.md requires ar and gl sets shot on device` | both named, "on device" stated | §15 step 20. A plan that only lists shot names will be satisfied by compositing the `en` set |
| 12 | `data-safety.md declares no data collected and no data shared` | both statements present | The form's two headline answers, in the file that is the source of truth for what gets typed into the console |
| 13 | `data-safety.md names the evidence behind every declaration` | every answer row has an evidence cell | An answer with no evidence is an intention. §11 says the form can be answered honestly *because* of the manifest — the file has to carry that link |
| 14 | `PrivacyInfo.xcprivacy declares no collected data types and no tracking` | empty arrays, `NSPrivacyTracking` false | The machine-readable half of row 12. The console form and the manifest disagreeing is a submission rejection |

```dart
// app/test/policy/store_listing_gate_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const Set<String> _locales = <String>{'ar', 'en', 'es', 'gl', 'ca', 'pt_BR'};
const String _store = '../store';

Iterable<String> _listingDirs() => Directory('$_store/listings')
    .listSync()
    .whereType<Directory>()
    .map((Directory d) => d.path.split(Platform.pathSeparator).last);

String _fullDescription(String locale) =>
    File('$_store/listings/$locale/full_description.txt').readAsStringSync();

void main() {
  test('store/listings holds exactly the six locales from D-3', () {
    expect(_listingDirs().toSet(), _locales);
  });

  test('store/listings holds no ur directory and no region-less pt', () {
    final Set<String> found = _listingDirs().toSet();
    expect(found.contains('ur'), isFalse, reason: 'D-3: Catalan ships, Urdu does not');
    expect(found.contains('pt'), isFalse, reason: 'D-3: the filename carries the region — pt_BR');
  });

  test('Every full description carries the approved offline paragraph', () {
    for (final String locale in _locales) {
      final String text = _fullDescription(locale);
      expect(text, contains('INTERNET'), reason: '$locale drops the Android clause');
      expect(text.toLowerCase(), contains('packet capture'), reason: '$locale drops the iOS clause');
    }
  });

  test('No full description claims an iOS permission-level network block', () {
    for (final String locale in _locales) {
      final String text = _fullDescription(locale).toLowerCase();
      for (final String claim in <String>[
        'ios blocks', 'ios prevents', 'app transport security prevents', 'ats blocks all',
      ]) {
        expect(text, isNot(contains(claim)), reason: '$locale makes a claim four-layers.md refutes');
      }
    }
  });

  // … rows 3, 6, 7, 8, 9, 10, 11, 12, 13, 14
}
```

**Run:** `cd app && flutter test test/policy/store_listing_gate_test.dart` → 14 failures. Any pass now is
a wrong test.

## Implementation outline

1. Write the fourteen rows and the empty `store/` skeleton. Confirm they fail for the right reason —
   "directory does not exist", not "no files matched".
2. Write `store/listings/en/` first: title, short description, full description. The full description
   ends with `four-layers.md`'s approved paragraph, unedited.
3. Translate the other five. The approved paragraph is translated faithfully, keeping all three clauses
   — it is not replaced with a shorter local idiom. Per §9.2 point 3, each locale is reviewed by the
   same native speaker who reviewed that locale's Tier-2 content.
4. Write the display-name resources. Verify each by building and installing with the device set to that
   locale and reading the name under the icon — a resource that resolves is the only proof the qualifier
   is right.
5. Write `store/screenshots/plan.md`: the shot list, the device frame, and the requirement that the `ar`
   and `gl` sets are captured on a device set to that locale. Capture them during T02's walkthrough so
   the screenshots are of the same build the capture was taken against.
6. Write `store/data-safety.md` as a table: question, answer, evidence. Evidence cells point at T01's
   allowlist output, the `aapt2` manifest dump, T02's two captures and the `dart pub deps` snapshot.
7. Write `PrivacyInfo.xcprivacy`. Derive `NSPrivacyAccessedAPITypes` by opening each plugin's own
   privacy manifest under `~/.pub-cache` and record which plugin contributed which entry in
   `store/data-safety.md`. Do not add an entry that no plugin declares.
8. Check the App Store Connect language list for `gl` (see the epic's Risks). Record the result in
   `store/README.md` either way; if it is absent, `store/listings/gl/` still ships for Play and the gap
   is a recorded fact rather than a dropped locale.
9. Re-run the suite. All 14 green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 14 tests pass, and each failed first.
- [ ] `store/listings/` holds exactly six directories, and their names are exactly D-3's six.
- [ ] All six full descriptions carry the `four-layers.md` paragraph with all three of its clauses.
- [ ] No listing text implies an iOS permission-level block, offers sync or an account, or gives
      fishing advice.
- [ ] Each of the six display names was verified by installing the build with the device set to that
      locale and reading the name under the icon.
- [ ] The `ar` and `gl` screenshot sets exist and were shot on device against the same build T02
      captured.
- [ ] `store/data-safety.md` answers "no data collected" and "no data shared", and every answer names
      its evidence file.
- [ ] `PrivacyInfo.xcprivacy` and `store/data-safety.md` agree, and every
      `NSPrivacyAccessedAPITypes` entry is traceable to a named plugin's own manifest.
- [ ] `store/README.md` records the App Store Connect result for `gl`, whichever way it went.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze --fatal-infos && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh   app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
bash -n tools/gates/check_store_listings.sh
tools/gates/check_store_listings.sh store
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
docs(l10n): six localised store listings, per-locale display names and the data-safety answers

The offline paragraph is quoted verbatim from four-layers.md rather than
written, because every attempt to improve it makes it weaker or false: it has
three clauses and the third says iOS has no permission-level equivalent and
rests on source enforcement plus a packet capture. A listing that stops after
the Android clause is a false claim in a privacy submission. Six locales exactly
per D-3, with a row that names ur and region-less pt specifically because those
are what older skill text says. Display names go through values-b+pt+BR and
pt-BR.lproj — the two qualifiers that fall back to English silently on exactly
the devices the locale was added for. The data-safety answers each name their
evidence, because "no data collected" is only true down to the last transitive
package.

Task: E21/T07
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
