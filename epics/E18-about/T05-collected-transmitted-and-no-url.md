# E18/T05 — What is collected, what is transmitted, and why there is no URL

| | |
|---|---|
| **Epic** | E18 — About and attributions |
| **Branch** | `epic/18-about` (shared) |
| **Commit** | `feat(about): state what is collected and transmitted, and why no privacy-policy URL exists` |
| **Depends on** | T02 (the `AboutScreen` scaffold) |
| **Size** | M |
| **Spec** | `SPEC.md` §6 S17 (*a plain statement that the app collects and transmits nothing, and why no privacy-policy URL is needed*), §5 and §5.3 (the exclusion list and the accurate offline formulation), §11 (Android's withheld permission; the honest iOS gap), §12 (the share sheet), §4.7 ("Flag this rule" composes nothing and sends nothing) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-offline-guarantee` | Owns the claim this task renders. Rule 5 is the whole task in one line — *iOS has NO equivalent opt-out; write that down, never fake it* — and `references/four-layers.md` carries the approved wording |
| `catchlaw-conventions-index` | Invariant 1 (no network code path) and rule 11 (no account, no identifier ever leaves the device) are what the statement asserts; invariant 2 binds how it is phrased |
| `i18n-rtl-l10n` | Every sentence here is tier-1 chrome and goes through gen-l10n in all six locales; a missing `ar` key falling back to English inside a privacy statement is the failure this rule exists for |
| `lonja-typography` | Rule 2: this is quoted-instrument-adjacent prose and sets in the serif, not the UI sans — a privacy statement that reads like a push notification is not read. Rule 8: never truncated |
| `accessibility-as-code` | Rule 5 and the 200% floor: this is the longest prose block in the app, and it is the one most likely to be "fixed" with an ellipsis |
| `dependency-hygiene` | The reason there is nothing to disclose is a dependency posture, and `references/dependency-gate-and-audit.md` is where "refuse anything that reports crashes or usage, directly or transitively" is written down |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §5.3, in full | The **accurate** guarantee: `http` appears transitively under `printing` and `flutter_svg`; the APIs are grep-banned; Android's kernel enforces it; iOS has no OS-level equivalent; URLs render as selectable text |
| `SPEC.md` | §5, the exclusion table | No accounts, no sync, no cloud backup, no sharing, no analytics — and *why* each is out |
| `SPEC.md` | §11, Android | The release manifest does not grant `INTERNET`; *"The Play data-safety form can then honestly declare that no data is collected or shared"* |
| `SPEC.md` | §11, iOS | *"There is no iOS equivalent of removing the INTERNET permission, and the first draft's proposed proofs were worthless"* |
| `SPEC.md` | §12 | Export via the system share sheet — the one user-initiated outbound path, and what each artefact contains |
| `SPEC.md` | §4.7, "Flag a wrong rule" | *"Composes nothing and sends nothing. The user exports and mails it themselves if they choose"* |
| `SPEC.md` | §6 S14, §6 S11 | Coordinate capture is a setting with a clear on/off state — the statement must not over-claim in either direction |
| `SPEC.md` | §13, "DB size at realistic usage" | 5 yrs × 200 trips × 8 catches ≈ 8,000 rows ≈ < 4 MB, plus ~200 KB per photo — what "held on this device" concretely means |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "Layer 3 — iOS, and the sentence to write" | The four false claims, and the approved paragraph marked *"use verbatim, do not improve"* |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "The strength ladder", "The API grep list" | Layer 2 is the only one a third party can check without trusting us — which is why it is named on screen |
| `.claude/skills/catchlaw-offline-guarantee/references/verification-ritual.md` | "Why a proxy is not evidence", "Evidence retention" | The packet capture the iOS sentence refers to, and the two-year retention that makes it a record rather than an assertion |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | "1 — No network code path", "2 — Statement of fact" | The banned symbol list, and the banned lexicon every string here must clear |
| `epics/DECISIONS.md` | D-3, D-18 | Six languages, `app_ca.arb` and `app_pt_BR.arb` — never `app_ur.arb`; `app_pt.arb` is the required base, not a seventh language |
| `epics/DECISIONS.md` | D-2 | The gate script beats the prose whenever they disagree — the tie-break used against `product-invariants.md`'s `url_launcher` allowance |

## What this delivers

- `app/lib/ui/about/widgets/collection_statement_section.dart` — the section, in four labelled
  blocks: *what is held on this device* · *what leaves it* · *what the guarantee rests on, per
  platform* · *why there is no privacy-policy URL*.
- ARB keys in all six files (D-3):
  `aboutPrivacyHeading`, `aboutHeldOnDeviceBody`, `aboutNothingTransmittedBody`,
  `aboutShareSheetBody`, `aboutFlagRuleBody`, `aboutCoordinatesBody`,
  `aboutAndroidGuaranteeBody`, `aboutIosGuaranteeBody`, `aboutNoPolicyUrlHeading`,
  `aboutNoPolicyUrlBody`, `aboutAuthorityContactLabel`.
- `app/test/ui/about/about_collection_statement_test.dart`.
- `app/test/l10n/about_arb_parity_test.dart` — the six-locale guard for this section's keys.

No new dependency. No new permission. No route out of the app.

## Why it is built this way

**The screen states the guarantee `SPEC.md` §5.3 actually supports, not the one the marketing copy
would prefer.** §5.3 opens by demolishing the first draft's claim that "no HTTP client is linked" —
`printing` declares `http` for `PdfGoogleFonts` and `flutter_svg` declares it for
`SvgPicture.network`, and both are on the required stack. The accurate claim is that no HTTP client is
*used*; the two edges are on a CI-diffed allowlist and their entry points are grep-banned. Writing
"CATCHLAW contains no networking code" on this screen would be false in a way a reviewer with
`flutter pub deps` can disprove in thirty seconds, and a demonstrably false privacy claim is worse
than a longer true one.

**The iOS sentence is the one that must not be improved.** `four-layers.md` tabulates four claims
people reach for and marks all four false: ATS does not prevent going online, `NSAllowsArbitraryLoads:
false` is not an offline switch, "links no Network.framework" is not a test because the Flutter engine
links CFNetwork regardless, and there is no iOS deny-networking entitlement. It then gives an approved
paragraph and says *use verbatim, do not improve*. That paragraph becomes the **`en`** ARB value here;
the other five locales are translations of it, and the ARB `@description` records that the English is
fixed wording. **Rejected:** paraphrasing it to match Android's sentence for symmetry — the asymmetry
is the fact.

**Android's sentence names the layer a stranger can check.** `four-layers.md`'s strength ladder puts
the missing `INTERNET` permission above all three source-side layers for one reason: *anyone with the
APK* can verify it, with `apkanalyzer manifest permissions`. Saying so on the screen converts the
claim from "trust us" into "here is the command". §11 adds the companion fact — debug and profile
builds keep `INTERNET` on purpose, for hot reload and the VM service — and the statement says that
too, because a reader who checks a debug build and finds the permission would otherwise conclude the
screen is lying.

**"Nothing is transmitted" needs its one carve-out stated, or it is false.** §12's export hands a file
to the system share sheet. That is the user moving their own data with the OS, not the app
transmitting — but a bare "nothing ever leaves this device" is contradicted the first time a fisher
mails a trip report to a cofradía, and a statement a user can personally disprove stops being read.
The same applies to "Flag this rule": §4.7 says it *composes nothing and sends nothing*, and saying so
explicitly is what makes the flag feature usable without suspicion.

**Coordinates get their own line, in both directions.** §6 S11 and S14 make coordinate capture a
setting with a clear on/off state. The statement says coordinates are recorded only when the user
turns capture on, and that when they are recorded they stay in `user.db` like everything else. An
over-claim in either direction is a defect: "we never record your location" is false when the setting
is on, and silence invites the assumption that it is always on.

**"Why no URL" is answered with a reason, not an absence.** A privacy policy is the disclosure a
controller publishes about the personal data it collects, uses, shares and retains. There is no
controller: no account (§5), no identifier (`product-invariants.md` rule 11), no server, no telemetry
SDK — `dependency-gate-and-audit.md` refuses those outright, transitively included. So there is no
processing to describe, and the disclosure that would otherwise live at a URL **is this screen**:
versioned with the build, readable with no signal, and shipped in six languages. The store-facing
declaration is the Play data-safety form and Apple's privacy labels (§11), which is where a regulator
looks. **Rejected:** "we do not have a privacy policy" as the whole answer — §6 S17 asks for *why it
is not needed*, and an unexplained absence reads as an omission.

**Rejected: a URL, a `mailto:` or any tappable link.** §5.3: *nothing in the app hands a URL to a
browser*, because an `ACTION_VIEW` intent fetches under the browser's own permission and defeats the
Android guarantee. §10 bans `url_launcher`, §14 fails the build on `launchUrl` or `url_launcher` under
`lib/`, and `check_no_network.sh` check 1 fails on the pubspec entry alone. Note that
`catchlaw-conventions-index/references/product-invariants.md` §1 currently permits `url_launcher` for
`mailto:` and `tel:` *on this exact screen*; the executable gate beats the prose (D-2's rule of
thumb), so the authority contact renders as selectable text. The discrepancy is raised in the epic's
Risks and in the PR, not resolved here — this task may not edit a skill.

**Nothing here instructs.** Invariant 2 has no carve-out for a privacy notice. "You can export your
data" becomes "Export writes the file the user chooses to share"; "Turn off coordinate capture"
becomes "Coordinates are recorded only while coordinate capture is on."

## Tests first

Write every row before touching `collection_statement_section.dart`. Run them. **They must fail** —
the section and its ARB keys do not exist, so the localisation lookups will not compile with
`nullable-getter: false`. That is the correct red.

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `AboutScreen states that no data is collected and none is transmitted` | default | the collection and transmission sentences render | The literal §6 S17 requirement; without it the screen is missing its headline element |
| 2 | `AboutScreen names the share sheet as the only user-initiated outbound path` | default | the export sentence renders | A bare "nothing ever leaves this device" is disproved by the first export, and a disprovable claim stops being read |
| 3 | `AboutScreen states that Flag this rule composes and sends nothing` | default | the flag sentence renders | §4.7 — the one feature whose name most suggests a report is filed somewhere |
| 4 | `AboutScreen states that coordinates are recorded only while coordinate capture is on` | default | the coordinates sentence renders | Over-claiming in either direction is a defect; §6 S14 makes it a setting |
| 5 | `AboutScreen states that the Android release build carries no INTERNET permission` | default | the Android sentence renders | The only layer a third party can check from the APK (`four-layers.md` strength ladder) |
| 6 | `AboutScreen states that the iOS guarantee rests on source-side layers and a packet capture` | default | the iOS sentence renders | Rule 5: iOS has no equivalent opt-out, and a false claim in a privacy submission is a worse liability than a documented gap |
| 7 | `AboutScreen makes no claim that iOS blocks networking at the permission level` | default | none of `ATS`, `blocks`, `prevents` in the iOS body | The four false claims `four-layers.md` tabulates; this test is the guard against a well-meaning rewrite |
| 8 | `AboutScreen explains why no privacy-policy URL is needed` | default | the reason body renders, not only the absence line | §6 S17 asks for the *why*; an unexplained absence reads as an omission |
| 9 | `AboutScreen renders no tappable link in the collection statement` | default | no `InkWell`, `GestureDetector` or `TextSpan` with a recogniser in the section | §5.3: nothing hands a URL to a browser, and a link would be dead offline anyway |
| 10 | `AboutScreen collection statement contains no imperative from the banned lexicon` | all six locales | no `keep`, `return`, `release`, `you must`, `you can` in the rendered strings | Invariant 2 has no privacy-notice carve-out |
| 11 | `Every collection-statement ARB key exists in all six locales` | read the six ARB files | key sets equal | D-3; a missing `ar` key falls back to English inside a privacy statement, which is the one place a reader cannot guess |
| 12 | `ar - AboutScreen renders the collection statement at TextScaler.linear(2.0) with no overflow` | locale `ar`, scale 2.0 | no overflow exception | The longest prose block in the app, in the script with the tallest line boxes, at §13's 200% floor |

```dart
// app/test/ui/about/about_collection_statement_test.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../harness.dart'; // pumpAbout(tester, {locale, textScaler})

void main() {
  testWidgets('AboutScreen makes no claim that iOS blocks networking at the permission level',
      (tester) async {
    await pumpAbout(tester);
    final body = tester.widget<Text>(find.byKey(const Key('about.privacy.ios'))).data!;
    for (final forbidden in const ['App Transport Security', 'blocks', 'prevents']) {
      expect(body, isNot(contains(forbidden)),
          reason: 'four-layers.md tabulates this as a false claim');
    }
  });

  testWidgets('AboutScreen renders no tappable link in the collection statement', (tester) async {
    await pumpAbout(tester);
    final section = find.byKey(const Key('about.privacy'));
    expect(find.descendant(of: section, matching: find.byType(InkWell)), findsNothing);
    expect(find.descendant(of: section, matching: find.byType(GestureDetector)), findsNothing);
    for (final t in tester.widgetList<RichText>(
        find.descendant(of: section, matching: find.byType(RichText)))) {
      t.text.visitChildren((span) {
        expect(span is TextSpan ? span.recognizer : null, isNull);
        return true;
      });
    }
  });

  // … one test per row above, one behaviour each
}
```

```dart
// app/test/l10n/about_arb_parity_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const kLocales = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR']; // D-3

void main() {
  test('Every collection-statement ARB key exists in all six locales', () {
    const keys = <String>[
      'aboutPrivacyHeading',
      'aboutHeldOnDeviceBody',
      'aboutNothingTransmittedBody',
      'aboutShareSheetBody',
      'aboutFlagRuleBody',
      'aboutCoordinatesBody',
      'aboutAndroidGuaranteeBody',
      'aboutIosGuaranteeBody',
      'aboutNoPolicyUrlHeading',
      'aboutNoPolicyUrlBody',
      'aboutAuthorityContactLabel',
    ];
    for (final locale in kLocales) {
      final arb = jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;
      for (final key in keys) {
        expect(arb.containsKey(key), isTrue, reason: '$key missing from app_$locale.arb');
      }
    }
  });
}
```

**Run:** `cd app && flutter test test/ui/about/about_collection_statement_test.dart test/l10n/about_arb_parity_test.dart`
→ 12 failures. If any passes now, the test is wrong.

## Implementation outline

1. Author the eleven keys in the template `app_en.arb` **first**, with `@description` on each. The
   `aboutIosGuaranteeBody` description records that its English value is the approved wording from
   `four-layers.md` and must not be improved.
2. Mirror the keys into the other five ARB files with real translations (D-3). Structure identical;
   bodies differ.
3. Build `CollectionStatementSection` as four labelled blocks under `LonjaSectionLabel` headings,
   each body in `t.legal`, each wrapped in the scaling reading measure
   (`LonjaMeasure.legal * MediaQuery.textScalerOf(context).scale(1)`).
4. Key the blocks (`about.privacy`, `about.privacy.ios`) so the tests can address them without
   matching on translated text.
5. The authority contact renders as selectable `Text` — `SelectionArea` around the section, no link,
   no recogniser, no `mailto:`.
6. Add the section to the `AboutScreen` scaffold in §6 S17's order, after the versions.
7. Read every string back once in `ar` at scale 2.0 on a 5-inch viewport before running the suite —
   test 12 will catch an overflow, but reading it is what catches a sentence that is technically true
   and unreadable.
8. Re-run the suite. All 12 green, and T02–T04's still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 12 tests pass, and each failed first.
- [ ] The `en` value of `aboutIosGuaranteeBody` is the `four-layers.md` paragraph, unedited, and its
      `@description` says so.
- [ ] The screen makes no claim that iOS blocks networking, and none that the app "contains no
      networking code".
- [ ] `grep -rn "launchUrl\|url_launcher\|mailto:" app/lib` returns nothing.
- [ ] No string in the section appears in `product-invariants.md`'s banned lexicon, in any of the six
      locales.
- [ ] All eleven keys exist in all six ARB files (D-3); no `app_ur.arb`, no `app_pt.arb`.
- [ ] The section renders in the serif, with no `maxLines`, `ellipsis` or `FittedBox`.
- [ ] No dependency was added, and no permission was added to either platform.

## Gates

```bash
# from the repository root
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
cd -
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh      app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh               app/lib
```

`check_app_invariants.sh` check 3 scans Dart **and every ARB locale** for imperative verdict strings,
which is why the eleven new values matter to it. ARB values are never exempt from that gate
(`CONVENTIONS.md` §7). ARB key parity is additionally covered by the §14 static check E01 wired into
CI, and by `check_arb_parity.sh app/lib/l10n` from the `i18n-rtl-l10n` skill in the Flutter-Skills
plugin if it is installed (`CONVENTIONS.md` §4). Every invocation names `app/lib`: the scripts exit 2
on a missing directory, and the default `lib/` does not exist at this root (D-1).

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(about): state what is collected and transmitted, and why no privacy-policy URL exists

SPEC.md §6 S17 asks for a plain statement and for the reason a privacy-policy
URL is unnecessary rather than merely absent. The reason is that a privacy
policy is the disclosure a controller publishes about the data it processes,
and there is no controller: no account, no identifier, no server, no telemetry
SDK. So the disclosure that would live at a URL is this screen — versioned with
the build, readable with no signal, in six languages — and the store-facing
declaration is the Play data-safety form and Apple's privacy labels.

The wording is §5.3's, not the marketing version. No HTTP client is *used*;
http appears transitively under printing and flutter_svg on a CI-diffed
allowlist with grep-banned entry points. Android names the layer a stranger can
check with apkanalyzer, and says that debug and profile builds keep INTERNET on
purpose. The iOS paragraph is four-layers.md's approved wording verbatim,
including that iOS has no permission-level equivalent — a test asserts the
screen never claims otherwise, because that is the sentence a well-meaning
rewrite would "improve" into a false privacy submission.

Task: E18/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
