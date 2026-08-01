# E10/T10 — The verdict-contract gate, in six locales

| | |
|---|---|
| **Epic** | E10 — The result screen |
| **Branch** | `epic/10-result` (shared) |
| **Commit** | `test(l10n): sweep every verdict string in six locales for the wording contract` |
| **Depends on** | T01–T09 (every key and every rendered string this sweeps) |
| **Size** | M |
| **Spec** | `SPEC.md` §5.1 points 1 and 4, §9.2, §9.5, §14 static checklist final bullet |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-verdict-contract` | Owns the lexicon, the ARB authoring rules and `examples/verdict_strings_test.dart`, which this task adapts into the repository |
| `i18n-rtl-l10n` | Rules 1–3 and the ARB workflow: template first, key and placeholder parity, ICU rather than concatenation |
| `lonja-verdict-and-status` | Rule 6 and its own gate — the same lexicon, enforced at the widget as well as at the string |
| `catchlaw-conventions-index` | Invariant 2, and D-3's correction of the skill's own `app_ur.arb` / `app_pt.arb` references |
| `testing-strategy` | This is a blocking acceptance gate, not a smoke test; where it sits and what it may not mock |
| `accessibility-as-code` | Rule 6 — the rendered sweep must read `Semantics` labels too, not only `Text` |
| `state-management-riverpod` | Pumping the result surface headlessly for lane 3 with a `ProviderContainer` and fakes |
| `catchlaw-rule-engine` | The nine resolutions the rendered lane sweeps, and why `NoRuleFound` wording may not be softened |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `.claude/skills/catchlaw-verdict-contract/examples/verdict_strings_test.dart` | whole | The three lanes, the const lexicons, the Arabic substring pass, and the `expect(arbs, isNotEmpty)` non-vacuity guard |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "The grep lexicon", "ARB authoring", "The six locales" | Families A–E, the key prefixes, the `@description` opener, and the per-locale traps |
| `.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh` | checks 2, 3, 6b | What the script already covers, so this test covers what a grep cannot |
| `.claude/skills/lonja-verdict-and-status/references/states-and-signals.md` | "Banned imperatives, and what is printed instead" | The BAD → GOOD table both gates read from |
| `SPEC.md` | §14 static checklist, final bullet | Every ARB key exists in all six locales; every `ar` plural has all six categories |
| `SPEC.md` | §9.5 | The plural categories per locale — `ar` six, `es`/`ca`/`pt` one/many/other, `gl` one/other |
| `i18n-rtl-l10n` → `references/arb-and-icu.md` (plugin, not this repo — `CONVENTIONS.md` §4) | "l10n.yaml", "Step-by-step" | `nullable-getter: false`, the template-first workflow, and `check_arb_parity.sh` |
| `epics/DECISIONS.md` | D-3 | The six filenames — `app_ca.arb`, `app_pt_BR.arb`, and no `app_ur.arb` |
| `epics/CONVENTIONS.md` | §7 | A gate scanning an empty tree reports success; assert non-vacuity before trusting it |

## What this delivers

- `app/test/ui/result/verdict_strings_test.dart` — the three-lane sweep, adapted from the skill's
  worked example to this repository's paths and to the six locales of D-3.
- `app/test/ui/result/verdict_arb_parity_test.dart` — key and placeholder parity across the six ARB
  files for the `verdict*` / `finding*` / `citation*` / `disclaimer*` families, plus the `ar` plural
  categories on any key that uses ICU `plural`.
- `.github/workflows/` — `check_verdict_contract.sh app/lib` and `check_lonja_verdict.sh app/lib`
  added to the existing gate job, each with the target directory passed explicitly (D-1).
- Whatever wording fixes the sweep turns up in T01–T09's keys, made **in this commit**.

## Why it is built this way

**A grep cannot see an Arabic imperative, and a translator will write one.** The Arabic imperative is
one short fluent word — أعِدْه, احتفظ — and it is exactly what a translator asked for natural Arabic
produces. `verdict-copy-rules.md` says the `@description` shipping with the key is the only defence,
and this test is the second: a const list of Arabic tokens, substring-matched, because word
boundaries do not survive the shift out of Latin script. `check_verdict_contract.sh` already carries
the same list; the two are kept identical deliberately, because a lexicon that exists in one place
gets edited in the other.

**Three lanes, because each catches what the previous one cannot.** Lane 1 sweeps the canonical copy
table — the sentences as designed. Lane 2 walks every `app_*.arb` on disk, which is what
`AppLocalizations` is compiled from, so it covers all six locales without gen-l10n having run. Lane 3
pumps the result surface and re-checks every string that actually reaches a `Text` or a `Semantics`
label — which catches a sentence assembled at a call site from two clean fragments, and a label that
never appears in an ARB at all.

**Semantics labels are user-facing strings.** Lane 3 reads `Semantics.properties.label` as well as
`Text.data`. A screen-reader user hearing "you can keep this" is exactly as badly served as one
reading it, and the semantics label of the stamp is composed in T02 from two ARB values.

**Non-vacuity is asserted, not assumed.** `CONVENTIONS.md` §7 names the failure mode that makes a
gate worse than no gate: a scan over a path with no files reports success. The ARB lane therefore
asserts six files were found, that at least one `verdict*` key exists in each, and that the rendered
lane collected a non-empty list of strings before checking any of them.

**Parity is a separate test from wording.** A key present in the template and missing from `app_gl
.arb` ships the English sentence inside a Galician legal statement — the one place a reader cannot
guess the meaning. A renamed placeholder breaks that translation at runtime rather than at build. Both
are structural and neither is a lexicon question, so they live in their own file.

**The `@description` mirroring is the one uncertainty in this task.**
`check_verdict_contract.sh` check 6b requires the literal string `STATEMENT OF FACT` in *every* ARB
holding a verdict key, and no ARB value is ever exemptible. Standard practice puts `@` metadata only
in the template. The plan is to mirror the `@key` description blocks into all six files, because
gen-l10n reads placeholder metadata from the template and skips `@`-prefixed keys elsewhere. **Verify
it rather than assume it:** run `flutter gen-l10n` and `flutter analyze` immediately after the first
mirrored file. If gen-l10n rejects the blocks, fall back to one top-level `"@@x-verdict-constraint"`
global attribute per file carrying the same sentence, and record which of the two shipped in the
commit body.

**Rejected — running the sweep only in CI as a shell gate.** The script is a heuristic grep and
cannot pump a widget; lane 3 is the only thing that sees a string composed at a call site. Both run.

**Rejected — a `@Skip`-able or "warning" mode.** `catchlaw-verdict-contract`'s definition of done
says the example runs green in CI as a blocking gate, not a smoke test. One "you may keep this" is
enough to void the carve-out.

**Rejected — asserting the six ARB files by a hardcoded list only.** The test asserts both: exactly
the six D-3 filenames exist, *and* every `.arb` found on disk is swept. A seventh file added later
without the six-name list being updated must still be checked.

## Tests first

Write every row before fixing a single string. Run them. **They must fail** — if the whole sweep is
green on the first run, either the lexicons were not wired in or the ARB path is wrong, and a
passing vacuous gate is the outcome this task exists to prevent.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `verdict copy table <key> is a statement of fact` (loop, key interpolated) | each canonical sentence | no banned token | Lane 1; the loop names the key so `--plain-name` can select one |
| 2 | `the no-rule wording keeps BOTH sentences, verbatim` | `verdictNoRuleRecorded` | contains `This does not mean it is legal.` | Losing sentence two turns a gap in the reference DB into a permission |
| 3 | `every measurement statement names its method and both numbers` | the three size keys | `measured`, `minimum`, and a parenthesised method | Kanaad is 65 cm fork length; an unnamed method is a confident wrong verdict |
| 4 | `six ARB files are present` | `app/lib/l10n` | exactly `ar en es gl ca pt_BR`, and no `ur` or bare `pt` | D-3, against three skill files that still say otherwise |
| 5 | `<locale> - every verdict ARB value is a statement of fact` (loop, locale interpolated) | each ARB | no Latin banned token | Lane 2, per locale, so a failure names the file |
| 6 | `ar - app_ar.arb contains no Arabic imperative or second person` | `app_ar.arb` | none of احتفظ أعِدْه أعده ارمه أطلقه يمكنك بإمكانك | The fluent imperative no English-language grep will ever see |
| 7 | `es - app_es.arb contains no imperative or polite subjunctive` | `app_es.arb` | none of devuélvalo, que lo devuelva, puede quedárselo | Both forms read as instructions in Spanish |
| 8 | `gl - app_gl.arb contains no imperative` | `app_gl.arb` | none of the Galician forms | Same risk as `es`, different lexicon |
| 9 | `ca - app_ca.arb contains no imperative` | `app_ca.arb` | none of the Catalan forms | Catalan ships (D-3) and carries the same trap |
| 10 | `pt_BR - app_pt_BR.arb contains no permission verb` | `app_pt_BR.arb` | none of "pode ficar com ele" | A permission verb with no English cognate in the grep |
| 11 | `<locale> - every verdict key ships the STATEMENT OF FACT constraint` (loop) | each ARB | every `@verdict*`/`@finding*` description starts with it | Rule 12: the constraint must travel with the key to the translator |
| 12 | `every verdict key exists in all six locales` | key sets | identical sets | §14's static bullet; a missing key ships English inside a legal statement |
| 13 | `every placeholder name is identical across the six locales` | placeholder sets per key | identical | A renamed placeholder breaks that translation at runtime, not at build |
| 14 | `every number in a verdict value is a placeholder` | all six | no bare digit run in a `verdict*` value | A baked-in number is a measurement a translator restated |
| 15 | `ar - every ICU plural in app_ar.arb declares all six categories` | `ar` plural keys | zero, one, two, few, many, other | §9.5, and a build failure if missing |
| 16 | `es, ca and pt_BR ICU plurals declare a many category` (loop, locale interpolated) | those three | `many` present | CLDR 48 correction; the first draft asserted one/other for all four |
| 17 | `gl ICU plurals declare one and other only` | `gl` | exactly those | The one locale of the four that is not one/many/other |
| 18 | `<state> - nothing banned reaches the rendered result surface` (loop over the nine states) | pumped surface | every `Text` and `Semantics` label clean | Lane 3; catches a sentence assembled at a call site from clean fragments |
| 19 | `<state> - the rendered result surface carries the citation quadruple` (loop) | pumped surface | instrument, article, both dates on screen | Invariant 3, asserted on the rendered tree rather than on the model |
| 20 | `<state> - the rendered result surface carries the disclaimer` (loop) | pumped surface | the disclaimer text found once | T09's property, re-asserted where it is actually rendered |
| 21 | `no acknowledge affordance reaches the rendered result surface` | all nine | no `Got it`, no `I understand`, no `Do not show again` | A dismissable disclaimer is one never shown |
| 22 | `the ARB sweep is not vacuous` | the file list | six files, each with ≥ 1 verdict key | A gate over an empty scan reports success — the §7 failure mode |
| 23 | `the rendered sweep is not vacuous` | lane 3 | the collected string list is non-empty for every state | Same hazard, on the widget side |
| 24 | `the Dart and shell lexicons agree` | the const lists vs the script | every token in the test's lists appears in `check_verdict_contract.sh` | Two copies of a lexicon drift; this test is how the drift is found |

```dart
// app/test/ui/result/verdict_strings_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';
import '../harness.dart';

const List<String> kImperative = <String>['keep', 'kept', 'return it', 'release it', 'discard',
    'retain', 'toss', 'land it', 'put it back', 'throw it back', 'do not keep']; // verdict-contract-ok
const List<String> kArabicBanned = <String>['احتفظ', 'أعِدْه', 'أعده', 'ارمه', 'أطلقه',
    'لا تحتفظ', 'لا تصطد', 'يمكنك', 'بإمكانك']; // verdict-contract-ok
const List<String> kLocales = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR']; // D-3

void main() {
  test('six ARB files are present', () {
    final names = Directory('lib/l10n')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.arb'))
        .map((f) => f.uri.pathSegments.last)
        .toSet();

    expect(names, kLocales.map((l) => 'app_$l.arb').toSet());
  });

  for (final locale in kLocales) {
    test('$locale - every verdict ARB value is a statement of fact', () {
      final arb = jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;
      final verdictKeys = arb.keys.where(_isVerdictKey).toList();
      expect(verdictKeys, isNotEmpty, reason: 'app_$locale.arb swept vacuously');

      for (final key in verdictKeys) {
        expectFactShaped('app_$locale.arb#$key', arb[key] as String);
      }
    });

    test('$locale - every verdict key ships the STATEMENT OF FACT constraint', () {
      final arb = jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;

      for (final key in arb.keys.where(_isVerdictKey)) {
        final meta = arb['@$key'];
        expect(meta is Map<String, dynamic> ? meta['description'] : null,
            startsWith('STATEMENT OF FACT.'),
            reason: 'app_$locale.arb#$key — the constraint must reach the translator');
      }
    });
  }

  for (final entry in kAllNineResultStates.entries) {
    testWidgets('${entry.key} - nothing banned reaches the rendered result surface',
        (tester) async {
      await tester.pumpApp(ResultSection(display: entry.value));

      final rendered = <String>[
        for (final t in tester.widgetList<Text>(find.byType(Text)))
          if (t.data != null) t.data!,
        for (final s in tester.widgetList<Semantics>(find.byType(Semantics)))
          if (s.properties.label != null) s.properties.label!,
      ];
      expect(rendered, isNotEmpty, reason: '${entry.key} rendered nothing — vacuous sweep');
      for (final s in rendered) {
        expectFactShaped('${entry.key}', s);
      }
    });
  }
}
```

**Run:** `cd app && flutter test test/ui/result/verdict_strings_test.dart
test/ui/result/verdict_arb_parity_test.dart` → the sweep must report real failures before the wording
fixes land. A wholly green first run means the lexicons or the paths are wrong, not that the copy is
clean.

## Implementation outline

1. Write both test files first. Confirm they fail for the right reason — inspect at least one
   reported hit by hand before changing any string.
2. Fix every hit **in this commit**. A wording defect this sweep catches is not a follow-up; the
   findings of `/simplify` and `/code-review` are handled the same way (`CONVENTIONS.md` §2).
3. Mirror the `@key` description blocks into all six ARB files. Immediately run `flutter gen-l10n`
   and `flutter analyze`. If gen-l10n rejects them, switch to the `"@@x-verdict-constraint"` global
   and record which shipped in the commit body.
4. Reconcile the Dart lexicons with `check_verdict_contract.sh`'s patterns and add the drift test
   (row 24) so the next edit to either is caught.
5. Add both gate scripts to the CI gate job with explicit targets:
   `check_verdict_contract.sh app/lib` and `check_lonja_verdict.sh app/lib`. A bare default would
   scan `lib/` at the repository root, which does not exist, and the script would exit 2 (D-1).
6. Run every gate in the list below over `app/lib` and confirm each reports the target it scanned.
7. Re-run the whole suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 24 test rows pass (rows 1, 5, 11, 16, 18, 19, 20 expand into loops), and each failed first.
- [ ] Every loop-generated test interpolates its locale or state name into the description.
- [ ] `check_verdict_contract.sh app/lib` and `check_lonja_verdict.sh app/lib` are clean and are
      wired into CI with the target passed explicitly.
- [ ] Exactly six ARB files exist, named per D-3, with identical key and placeholder sets.
- [ ] Every `verdict*` / `finding*` / `citation*` / `disclaimer*` value carries its numbers as
      placeholders.
- [ ] The Dart lexicons and the shell script's patterns cover the same tokens, proved by row 24.
- [ ] No `@Skip`, no `markTestSkipped` on any lane, and no locale excluded.
- [ ] The commit body records whether the mirrored `@description` blocks or the `@@x-` global shipped.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter gen-l10n && flutter analyze && flutter test
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh      app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-dialogs-and-surfaces/scripts/check_lonja_dialogs.sh    app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
test(l10n): sweep every verdict string in six locales for the wording contract

check_verdict_contract.sh is a grep, and the Arabic imperative is one short
fluent word a grep written in English will never see. So the contract is
enforced twice: by the script, and by a three-lane test that sweeps the
canonical copy table, every app_*.arb on disk including app_ar.arb with a
substring pass, and every string that actually reaches a Text or a
Semantics label on the nine rendered result states.

Semantics labels are swept because a screen-reader user hearing "you can
keep this" is exactly as badly served as one reading it. Every lane asserts
it collected something before checking it: a gate that scans an empty tree
reports success, which is the failure mode that makes a gate worse than no
gate.

Task: E10/T10
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
