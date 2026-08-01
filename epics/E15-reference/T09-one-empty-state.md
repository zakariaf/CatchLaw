# E15/T09 — One empty state, used eight times

| | |
|---|---|
| **Epic** | E15 — The reference section |
| **Branch** | `epic/15-reference` (shared) |
| **Commit** | `refactor(reference): replace eight local empty states with one ReferenceEmptyState` |
| **Depends on** | T02, T04, T05, T06, T07, T08 — all eight surfaces must exist before they are generalised |
| **Size** | S |
| **Spec** | `SPEC.md` §6's shared line for S18–S23 ("an empty state reading 'not recorded for this jurisdiction' (never a blank screen)"), §6 S13, §4.1 (an absence never reads as permission), §4.7 (the content version on every surface) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-lists-and-tables` | Rule 6 makes an authored empty state mandatory and its absence a gate failure; `references/the-four-states.md` owns the parts, the copy table and the golden lanes |
| `lonja-icons-and-plates` | The engraved plate an empty state carries — `ink` on `paper`, 96–140 dp, never a 3-D or coloured illustration |
| `lonja-typography` | The serif 21 headline / serif 15 `ink-muted` body pairing, and rule 10 — no `.toUpperCase()` |
| `catchlaw-verdict-contract` | Rule 7 and grep family E: an absence that is softened into permission is the costliest misreading this app can cause |
| `lonja-buttons` | The single optional `LonjaButton.primary`, its 56 dp floor and its disabled encoding |
| `widget-golden-and-a11y-testing` | Lanes 6 and 7, and the reason a blank golden passes review far too easily |
| `catchlaw-conventions-index` | The routing table's tie-break — the copy belongs to `catchlaw-verdict-contract`, the geometry to `lonja-lists-and-tables` |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6, the S18–S23 line | "an empty state reading 'not recorded for this jurisdiction' (never a blank screen)" — the sentence this whole task exists to make true once |
| `SPEC.md` | §4.1 | "No rule recorded for this species here. This does not mean it is legal." — the two-sentence shape every absence in this product takes |
| `SPEC.md` | §4.7 | The content-version banner per jurisdiction, which the header already carries from T01 |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rule 6 | "`SizedBox.shrink()`, a bare `Center(child: Text('No data'))`, or nothing at all is a defect and fails `scripts/check_lonja_lists.sh`" |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Empty", "Golden coverage matrix" | The five parts of an empty state; "exactly ONE `LonjaButton.primary`"; lanes 6 and 7; "Assert on the headline text, not only on the pixels" |
| `.claude/skills/catchlaw-verdict-contract/references/verdict-copy-rules.md` | "The grep lexicon", family E | "no restrictions", "nothing applies", "all clear", "good to go" — hard failures everywhere |
| `.claude/skills/lonja-icons-and-plates/SKILL.md` | the plate scale | The engraved empty-state art and its sizing |
| `.claude/skills/lonja-buttons/SKILL.md` | the variant ladder | `LonjaButton.primary` and its target floor |
| `FLUTTER_GUIDE.md` | §6.4 | The golden budget: keep the matrix small; goldens prove shaping and mirroring, not layout |
| `FLUTTER_GUIDE.md` | §8.1 | Never return widgets from a helper method — the eight locals being deleted here are `const` widget classes or inline trees, and the replacement is one `const` widget class |
| `epics/DECISIONS.md` | D-3 | The six locales; the `ar` lane is the one that matters most here |

## What this delivers

- `app/lib/ui/reference/reference_empty_surface.dart` — `enum ReferenceEmptySurface` with **exactly
  eight** values:

  | # | Value | Screen | Condition |
  |---|---|---|---|
  | 1 | `legalTextNoMatch` | S13 | the search returned no article |
  | 2 | `legalTextNotRecorded` | S13 | `legal_text_locales` is empty, or the jurisdiction has no `legal_text` rows |
  | 3 | `protectedSpecies` | S18 | no rule with `is_protected = 1` in scope |
  | 4 | `gearAndMethods` | S19 | no `gear_rule` in scope |
  | 5 | `penalties` | S20 | no `penalty` for this jurisdiction |
  | 6 | `licenceTypes` | S21 | no `licence_type` matches the zone and water type |
  | 7 | `glossary` | S22 | no `glossary_term` for this jurisdiction and none global |
  | 8 | `changelog` | S23 | no `content_change` — the first content version |

- `app/lib/ui/reference/widgets/reference_empty_state.dart` — `ReferenceEmptyState`, a `const` widget
  class composing E08's `LonjaEmptyState`. Takes a `ReferenceEmptySurface`, resolves headline and body
  through an exhaustive `switch` over `AppLocalizations`, and takes a **nullable** action.
- Eight call-site replacements: the local empty widgets authored in T02, T04, T05, T06, T07 and T08
  are **deleted**, not left beside the new one.
- ARB: no key renames. The sixteen headline/body keys authored in T02–T08 keep their names; T09 adds
  only what the audit finds missing.
- Tests: `app/test/ui/reference/reference_empty_state_test.dart`, plus two goldens under
  `app/test/ui/reference/goldens/`.

## Why it is built this way

**The extraction comes last on purpose, and the reason is not laziness.**
Two things about an empty state generalise badly until you have several of them.

The first is the copy. `the-four-states.md` publishes a per-surface copy table precisely because the
words are the part that cannot be shared: "No species matches قباب" and "No trips recorded on this
device" are different sentences doing different jobs. Authoring those eight sentences is screen work
and belongs with the screen, which is why T02–T08 each authored their own.

The second is the shape, and it only became visible at T08. `the-four-states.md` specifies "exactly
ONE `LonjaButton.primary`; two competing actions is a defect" — and says nothing about zero. Surface 8,
the changelog on a first content version, has nothing the reader can do and nowhere useful to go, so
its correct action count is **zero**. Had the component been extracted at T04 it would have a required
action, and T08 would either have invented a pointless button or bypassed the component. Extracting
after all eight exist is how the action ends up nullable rather than mandatory. That is the whole
content of this task, and it is why the ID is last.

**It composes `LonjaEmptyState`; it does not compete with it.**
E08 authored `LonjaEmptyState` in `app/lib/ui/core/ui/` with the plate, headline, body and action
slots and the geometry from `the-four-states.md`. `ReferenceEmptyState` is a thin reference-section
wrapper that binds a surface to its copy and its optional action. **Rejected:** a second general
empty-state widget (two components with the same job drift within two PRs, which is what
`catchlaw-conventions-index` rule 10 says about forked rules and is just as true of widgets);
`ReferenceEmptyState` living in `app/lib/ui/core/ui/` (it knows about reference surfaces, so it
belongs to the feature).

**Every body carries a second sentence, and this task audits all eight for it.**
§4.1's wording is two sentences because the second one — "This does not mean it is legal." — is what
stops silence in the sources being read as permission. The same hazard is on every screen here: an
empty penalties list must not read as "there are no penalties", and an empty gear list must not read
as "all gear is permitted". So each body states the absence and then states what the absence *is*: a
gap in this app's recorded content for this jurisdiction and content version, not a statement about
the law. The header already carries the jurisdiction and the content version from T01, so the body
names them without repeating the header.

**Two goldens, not sixteen.**
`the-four-states.md` asks for lanes 6 and 7 — `en` empty and `ar` empty. Eight surfaces × two locales
would be sixteen golden files for a component whose geometry is identical in all eight cases and whose
only variable is text. `golden-two-lanes.md` is explicit that goldens earn their keep for glyph
shaping and mirroring and are a poor gate for anything else, and `the-four-states.md` itself says
"Assert on the headline text, not only on the pixels". So: **two** goldens of the component — `en` and
`ar`, using the surface with the longest body so wrapping is exercised — and **eight** loop-generated
text assertions covering the rest. `FLUTTER_GUIDE.md` §6.4's instruction is to keep the golden matrix
small, and this is what that means in practice.

**The gate is the point.**
`check_lonja_lists.sh` check 3 fails a file that builds a lazy list and references no empty-state
widget. Before this task, eight files each satisfied that check with their own widget; after it, one
widget satisfies it eight times and a ninth screen added later cannot forget, because the enum makes
the omission a compile error rather than a blank frame.

## Tests first

Write every row before touching `reference_empty_state.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ReferenceEmptySurface declares eight values` | the enum | length 8 | The count is published in this epic and in `epics/README.md`'s delivery line; a ninth surface without a ninth authored copy is the defect |
| 2 | `ReferenceEmptyState renders a headline for the ${surface.name} surface` | loop over all eight | non-empty headline, not equal to the enum name | Eight loop-generated tests, the parameter interpolated per `CONVENTIONS.md` §5. A missing `switch` arm shows up as the enum name on screen |
| 3 | `ReferenceEmptyState renders a two-sentence body for the ${surface.name} surface` | loop over all eight | body contains at least two sentences | §4.1's shape: the second sentence is what stops an absence reading as permission |
| 4 | `ReferenceEmptyState renders no softened-absence wording in any of the six locales` | every ARB value behind the sixteen keys | none of grep family E | "No restrictions", "all clear" and "good to go" are hard failures everywhere |
| 5 | `ReferenceEmptyState renders at most one action` | loop over all eight | `LonjaButton` count ≤ 1 | `the-four-states.md`: two competing actions is a defect |
| 6 | `ReferenceEmptyState renders no action for the changelog surface` | surface 8 | zero buttons | The discovery that made the action nullable; pinned so a later change cannot quietly require one |
| 7 | `ReferenceEmptyState renders an engraved plate` | any surface | the plate widget is present | Rule 6's first part — a bare `Center(child: Text(...))` is a defect |
| 8 | `ReferenceEmptyState uses no semantic colour` | any surface | resolved colours exclude verdant, oxblood and ochre | "an empty list is not a verdict" — `the-four-states.md`'s Empty table |
| 9 | `ar - ReferenceEmptyState golden matches` | `Locale('ar')`, longest-copy surface, real fonts | golden matches | Lane 7. Arabic script joining is exactly what geometry assertions cannot see |
| 10 | `ReferenceEmptyState golden matches` | `Locale('en')`, longest-copy surface, real fonts | golden matches | Lane 6, and the baseline the `ar` lane is read against |
| 11 | `Reference screens contain no SizedBox.shrink and no bare Center-Text empty body` | grep over `app/lib/ui/reference/` | no hits | The exact defect rule 6 exists to kill, asserted in the suite as well as in the gate |
| 12 | `Every reference list screen renders ReferenceEmptyState when its query returns nothing` | loop over the seven screens with empty fixtures | the component is found | The replacement actually happened at all eight call sites, rather than one being missed |

```dart
// app/test/ui/reference/reference_empty_state_test.dart
import 'package:catchlaw/ui/reference/reference_empty_surface.dart';
import 'package:catchlaw/ui/reference/widgets/reference_empty_state.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  test('ReferenceEmptySurface declares eight values', () {
    expect(ReferenceEmptySurface.values, hasLength(8));
  });

  // Loop-generated: the parameter is interpolated so --plain-name can select one.
  for (final surface in ReferenceEmptySurface.values) {
    testWidgets('ReferenceEmptyState renders a headline for the ${surface.name} surface',
        (tester) async {
      tester.useDevice(Device.small);
      await tester.pumpApp(child: ReferenceEmptyState(surface: surface));
      final headline = tester.widget<Text>(
        find.byKey(const ValueKey('reference_empty_headline')),
      );
      expect(headline.data, isNotEmpty);
      expect(headline.data, isNot(surface.name));   // a missing switch arm looks like this
    });
  }

  testWidgets('ReferenceEmptyState renders no action for the changelog surface',
      (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(
      child: const ReferenceEmptyState(surface: ReferenceEmptySurface.changelog),
    );
    // The first content version has no changes recorded. There is nothing to do
    // and nowhere useful to go, so the correct action count is zero.
    expect(find.byType(LonjaButton), findsNothing);
  });
}
```

```dart
// app/test/ui/reference/reference_empty_state_golden_test.dart
@Tags(['golden'])
library;

testWidgets('ar - ReferenceEmptyState golden matches', (tester) async {
  tester.useDevice(Device.small);
  await tester.pumpApp(
    child: const ReferenceEmptyState(surface: ReferenceEmptySurface.legalTextNotRecorded),
    locale: const Locale('ar'),
  );
  await expectLater(
    find.byType(ReferenceEmptyState),
    matchesGoldenFile('goldens/reference_empty_state_ar.png'),
  );
});
```

**Run:** `cd app && flutter test test/ui/reference/reference_empty_state_test.dart` → 19 failures
(12 table rows, of which rows 2 and 3 expand to eight each and row 12 to seven). Test 11 is a grep
assertion and will pass immediately if T02–T08 were done correctly — that is the one case where an
early pass is **not** a broken test, and the reason is recorded here so nobody deletes it.

## Implementation outline

1. Declare `ReferenceEmptySurface` with the eight values in the table above.
2. Write `ReferenceEmptyState` as a `const` widget class: an exhaustive `switch` over the surface
   returning `(headline, body, action?)` from `AppLocalizations`, composed into `LonjaEmptyState` with
   the engraved plate. A new enum value is a compile error until its copy exists.
3. Audit the sixteen existing headline/body ARB values against the two-sentence rule and grep family
   E; fix what the audit finds, in all six locales. **Rename nothing** — the keys T02–T08 authored stay
   as they are, because a rename is churn across six files for no behavioural gain.
4. Replace the eight call sites. **Delete** each local empty widget in the same commit; leaving one
   behind is the failure this task exists to prevent, and `/simplify` will find it if the deletion is
   forgotten.
5. Add the two goldens, both under `loadAppFonts()`, tagged `@Tags(['golden'])`, generated on the
   pinned CI environment only.
6. Re-run the whole suite — all of T01–T08's tests, not just this file.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first except test 11, whose early pass is explained above.
- [ ] `ReferenceEmptySurface` declares exactly eight values and the `switch` over it is exhaustive
      with no `default` arm.
- [ ] Zero local empty-state widgets remain in `app/lib/ui/reference/`; `grep -rn 'SizedBox.shrink'
      app/lib/ui/reference/` returns nothing.
- [ ] `ReferenceEmptyState.action` is nullable, and the changelog surface passes `null`.
- [ ] Every one of the sixteen ARB values carries two sentences and none matches grep family E, in all
      six locales.
- [ ] Two goldens exist (`en`, `ar`), both loading real fonts, both tagged; no golden was blessed with
      `--update-goldens` in CI.
- [ ] `check_lonja_lists.sh app/lib` is clean with no `// lonja-list-ok` hatch anywhere in
      `app/lib/ui/reference/`.
- [ ] `packages/rule_engine/` untouched (D-7).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze
cd app && flutter test --exclude-tags golden
cd app && flutter test --tags golden
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh          app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                 app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
tools/gates/no_directional_geometry.sh                                       app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
refactor(reference): replace eight local empty states with one ReferenceEmptyState

SPEC.md §6 requires "not recorded for this jurisdiction" and never a blank screen
on every reference surface. Eight of them existed, each with its own widget.
They are now one component and eight authored copies behind an enum, so a ninth
surface added later is a compile error rather than a blank frame.

The extraction is last on purpose. The copy is per-surface and belongs with the
screen that authored it, and the shape only settled at T08: the changelog on a
first content version has nothing the reader can do and nowhere to go, so its
correct action count is zero — a case the-four-states.md does not cover. Had this
been extracted at T04 the action would be required, and T08 would have invented a
pointless button or bypassed the component.

Every body carries a second sentence stating that the absence is a gap in this
app's recorded content for this jurisdiction and content version, not a statement
about the law — the same reason SPEC.md §4.1's no-rule wording is two sentences.

Two goldens, en and ar, not sixteen: the geometry is identical across the eight
surfaces and only the text varies, so the other seven are asserted on their
headline rather than on pixels.

Task: E15/T09
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
