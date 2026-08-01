# E15/T01 — S12, the reference hub

| | |
|---|---|
| **Epic** | E15 — The reference section |
| **Branch** | `epic/15-reference` (shared) |
| **Commit** | `feat(reference): add S12, the reference hub, routing to the seven reference surfaces` |
| **Depends on** | — (first task of the epic) |
| **Size** | S |
| **Spec** | `SPEC.md` §6 S12, §6's bottom-navigation enumeration, §4.6 (what the seven surfaces are), §4.9 (target size) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-navigation-chrome` | The hub mounts on `LonjaDestination.reference`; this skill owns the masthead, the frozen five, the back affordance and — critically — the rule its gate enforces about any enum whose name ends in `Destination` |
| `lonja-lists-and-tables` | The seven "cards" of §6 S12 are ruled rows, not `Card`s. Rule 1 (whole row is one target), rule 2 (hairline, never a card gap), rule 3 (`ListTile` banned), rule 11 (fixed slot order) |
| `lonja-typography` | `LonjaSectionLabel`'s `microLabel` rubric, the `title`/`uiSmall` pairing in a hub row, and rule 10 — no `.toUpperCase()` in a widget |
| `catchlaw-conventions-index` | The routing table decides who owns what here; invariant 4 (colour is never the only signal) applies to the row chevron and the currency chip |
| `i18n-rtl-l10n` | Every row label is an ARB key; the chevron mirrors; the geometry is directional from the first commit |
| `widget-golden-and-a11y-testing` | `useDevice` before `pumpApp`, the explicit `getSize` tap-target loop, and `isSemantics` for the row role |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §6 S12 | The exact element list: cards routing to S13, S18, S19, S20, S21, S22 and S23. Seven, no more |
| `SPEC.md` | §6, the line above S1 | The five frozen destinations, and that `Reference` is one of them |
| `SPEC.md` | §4.6 | What each of the seven surfaces is for — the one-line detail each hub row carries |
| `SPEC.md` | §4.9 | "All primary targets ≥ 56 dp with ≥ 8 dp separation" — the floor the row must clear |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rules 1, 2, 3, 11, 12 | Whole-row target, hairline separation, the `ListTile` ban, fixed slots, glove as density only |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The divider ladder", "Density" | `hairlineDotted`, `groupOpen`, `structural`, `LonjaSectionLabel`; `rowMinHeight` 64 dp / 76 dp glove |
| `.claude/skills/lonja-navigation-chrome/SKILL.md` | rules 1, 4, 5, 6, 7 | The frozen five, ARB-only chrome strings, directional-only geometry, the mirrored back affordance, the masthead |
| `.claude/skills/lonja-navigation-chrome/references/nav-anatomy-and-states.md` | "The five destinations, frozen", "Masthead anatomy" | `reference` holds "the booklet: instruments, articles, penalties, plates"; the pushed-route bar row |
| `.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh` | checks 1a and 3a | Check 3a matches **any** enum whose name contains `Destination` and demands exactly five values. Check 1a rejects a string literal passed to `label:`, `tooltip:` or `semanticLabel:` anywhere under the target |
| `.claude/skills/lonja-typography/references/type-ramp.md` | the ramp table | `title` 23, `uiSmall` 13, `microLabel` 9.5 — the three steps a hub row and its section rubric use |
| `FLUTTER_GUIDE.md` | §2.2 | `reference_hub_screen.dart` → `ReferenceHubScreen`; sub-widget `<feature>_<part>.dart` |
| `FLUTTER_GUIDE.md` | §9.2 | The directional/physical geometry table, and why a physical `left` inset is a bug in one locale of six |
| `epics/DECISIONS.md` | D-1, D-2, D-3 | `app/` and `app/lib/theme/`; the six locales are `ar en es gl ca pt_BR` |

## What this delivers

- `app/lib/ui/reference/reference_section.dart` — `enum ReferenceSection` with seven values:
  `ruleText`, `protectedSpecies`, `gearAndMethods`, `penalties`, `licenceTypes`, `glossary`,
  `changelog`. Each carries its route name and its `LonjaGlyphs` glyph; its label and detail come
  from `AppLocalizations` through an exhaustive `switch`.
- `app/lib/ui/reference/reference_hub_screen.dart` — `ReferenceHubScreen`: masthead, jurisdiction and
  content-version header, one ruled group of seven rows.
- `app/lib/ui/reference/widgets/reference_hub_row.dart` — `ReferenceHubRow`: one `InkWell` over the
  whole rect, glyph → title → detail → inert mirrored chevron.
- `app/lib/ui/reference/widgets/reference_screen_header.dart` — `ReferenceScreenHeader`: the
  jurisdiction name and `jurisdiction.content_version`, reused by every screen T02–T08 adds.
- `app/lib/ui/reference/reference_strings.dart` — the single seam onto E06's `content_string`
  resolver. Every `*_key` lookup in this epic goes through here (epic Risk 2).
- `app/lib/ui/core/ui/lonja_section_label.dart` — **only if absent.** If E12 or E13 already authored
  `LonjaSectionLabel`, use it and author nothing.
- `app/lib/routing/reference_routes.dart` — the hub route plus seven child routes, each a named
  placeholder until its task lands.
- ARB keys in all six files (D-3): `referenceHubTitle`, and `referenceSection*Label` /
  `referenceSection*Detail` for each of the seven.
- `app/test/ui/reference/reference_hub_screen_test.dart`.

## Why it is built this way

**`SPEC.md` §6 S12 says "cards"; Lonja says the word "card" is not a `Card`.**
`lonja-lists-and-tables` rule 2 bans `Card`, `elevation`, `BorderRadius` and any vertical gap between
sibling rows, because a floating card reads as a consumer app and a ruled column reads as the printed
register the product's authority rests on. So the seven cards are seven rows in one group: a 1 px
solid `ink` `groupOpen` rule above the first, a 1 px dotted `rule` hairline under each. **Rejected:**
`Card(elevation: 2)` per row, and `ListTile` — the latter hardcodes Material's paddings, its splash
and a three-line cap, and silently overrides every Lonja type role the row sets (rule 3).

**The enum may not be called `ReferenceDestination`.**
`check_lonja_nav.sh` check 3a greps for `enum\s+[A-Za-z0-9_]*Destination[A-Za-z0-9_]*` and fails any
match that does not declare exactly five values. That rule exists to freeze the bottom bar at five,
and it is right; but a seven-value `ReferenceDestination` would trip it and the only ways out would be
an escape-hatch comment or weakening a gate. Neither is acceptable, so the type is
**`ReferenceSection`**. The name is also more honest: these are sections of one document, not
destinations of the shell.

**The row is one tap target, and the chevron owns no gesture.**
Rule 1: `rowMinHeight` is 64 dp on paper and 76 dp in glove mode, and the whole rect is the `InkWell`.
`SPEC.md` §4.9's floor is ≥ 56 dp with ≥ 8 dp separation; 64 dp clears it and 76 dp clears it with
room. **Rejected:** `trailing: IconButton(onPressed: onTap)`, which shrinks a 64 dp target to 15 dp
and leaves 92 % of the row inert — the exact failure a wet neoprene fingertip produces at 05:40.

**Seven rows are static and known at build time, so this is a `Column`, not a `ListView`.**
`row-and-table-anatomy.md`'s container table: "fewer than 8 static rows, fixed at build → `Column` of
const rows", never `ListView` with `shrinkWrap: true`. Seven is under eight. This is also why the hub
is the one reference screen with no empty state: `ReferenceSection.values` cannot be empty, so
`check_lonja_lists.sh`'s empty-state check does not apply and no `// lonja-list-ok` hatch is needed —
the file builds no lazy list at all.

**The header is shared from this task onward.**
`SPEC.md` §6's line for S18–S23 requires "the jurisdiction and content version in the header" on every
one of them. Authoring that seven times is seven places for the content version to drift out of the
jurisdiction it belongs to, so `ReferenceScreenHeader` is delivered here, by the first screen that
needs it, and T02–T08 consume it. **This is deliberately unlike the empty state**, which is authored
per surface in T02–T08 and consolidated in T09 — see T09's reasoning for why the two are treated
differently.

**Every string is an ARB key, with no exception for a "temporary" label.**
`check_lonja_nav.sh` check 1a rejects a string literal passed to `label:`, `tooltip:` or
`semanticLabel:` **anywhere under `app/lib`**, not only in chrome files. A hardcoded label ships
English chrome into the Arabic build, which is the one build where the reader cannot guess.

## Tests first

Write every row before touching `reference_hub_screen.dart`. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ReferenceHubScreen renders seven section rows` | pump with a stub jurisdiction | `find.byType(ReferenceHubRow)` finds 7 | §6 S12 names exactly seven surfaces; an eighth or a missing one is a spec violation the compiler cannot see |
| 2 | `ReferenceHubRow opens the ${section.name} route when tapped` | loop over `ReferenceSection.values` | the router records that section's route name | Seven loop-generated tests, the parameter interpolated per `CONVENTIONS.md` §5 so `--plain-name` still selects one |
| 3 | `ReferenceHubRow fires onTap when tapped at its start edge` | tap at `getRect(...).centerLeft + 4 dp` | the callback fires once | Rule 1's actual claim. Tapping the centre would pass even with a 15 dp chevron-only target |
| 4 | `ReferenceHubRow measures 64 dp on the paper density` | `getSize` on the row | height ≥ 64 | `rowMinHeight`, and the §4.9 floor of 56 dp it must clear |
| 5 | `glove - ReferenceHubRow measures 76 dp` | glove density on | height ≥ 76 | Glove mode raises rows without re-laying them out (rule 12); a row that stays at 64 dp silently fails the wet-hand case |
| 6 | `ReferenceHubScreen renders the jurisdiction name and content version in the header` | stub jurisdiction `ES-GA`, version from the fixture | both strings present | The header contract §6 imposes on every reference surface, asserted once where it is authored |
| 7 | `RTL - ReferenceHubScreen mirrors the row chevron` | `Locale('ar')` | the chevron's `Transform` flips on X | An unmirrored chevron points away from its destination in half this product's launch surface |
| 8 | `ar - ReferenceHubScreen resolves every row label through AppLocalizations` | `Locale('ar')` | no rendered label equals its `en` value | The failure `check_lonja_nav.sh` check 1a exists for, asserted behaviourally rather than by grep |
| 9 | `ReferenceHubScreen renders no ListTile and no Card` | default pump | both `findsNothing` | Rules 2 and 3. A grep gate catches the constructor; this catches it arriving through a helper |
| 10 | `ReferenceHubRow exposes a button role labelled by its section title` | `getSemantics` | `isSemantics(isButton: true, hasTapAction: true, label: <title>)` | Every control labelled (§4.9); the label carries the display name, not the enum name |

```dart
// app/test/ui/reference/reference_hub_screen_test.dart
import 'package:catchlaw/ui/reference/reference_hub_screen.dart';
import 'package:catchlaw/ui/reference/reference_section.dart';
import 'package:catchlaw/ui/reference/widgets/reference_hub_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('ReferenceHubScreen renders seven section rows', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(overrides: kGaliciaOverrides);
    expect(find.byType(ReferenceHubRow), findsNWidgets(7));
  });

  // Loop-generated: the parameter is interpolated so --plain-name can select one.
  for (final section in ReferenceSection.values) {
    testWidgets('ReferenceHubRow opens the ${section.name} route when tapped',
        (tester) async {
      tester.useDevice(Device.small);
      final observer = RecordingRouteObserver();
      await tester.pumpApp(overrides: kGaliciaOverrides, observer: observer);
      await tester.tap(find.byKey(ValueKey('reference_section_${section.name}')));
      await tester.pump();
      expect(observer.lastPushedName, section.routeName);
    });
  }

  testWidgets('ReferenceHubRow fires onTap when tapped at its start edge',
      (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(overrides: kGaliciaOverrides);
    final rect = tester.getRect(
      find.byKey(const ValueKey('reference_section_penalties')),
    );
    // The whole rect is the target (rule 1) — not the chevron, not the centre.
    await tester.tapAt(rect.centerLeft + const Offset(4, 0));
    await tester.pump();
    expect(find.byType(PenaltiesScreen), findsOneWidget);
  });

  testWidgets('glove - ReferenceHubRow measures 76 dp', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(overrides: [...kGaliciaOverrides, kGloveDensityOverride]);
    for (final section in ReferenceSection.values) {
      final size = tester.getSize(
        find.byKey(ValueKey('reference_section_${section.name}')),
      );
      expect(size.height, greaterThanOrEqualTo(76),
          reason: '${section.name} row is below the glove rowMinHeight');
    }
  });

  testWidgets('ReferenceHubScreen renders no ListTile and no Card', (tester) async {
    tester.useDevice(Device.small);
    await tester.pumpApp(overrides: kGaliciaOverrides);
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(Card), findsNothing);
  });

  // … one test per row of the table above, one behaviour each.
}
```

**Run:** `cd app && flutter test test/ui/reference/reference_hub_screen_test.dart` → 16 failures
(10 table rows, of which row 2 expands to 7). If any passes now, the test is wrong — fix the test
before writing a line of `reference_hub_screen.dart`.

## Implementation outline

1. Declare `ReferenceSection` with seven values. **Do not name it `ReferenceDestination`** — see the
   reasoning above. Give each value a `routeName` and a `LonjaGlyphs` glyph; resolve label and detail
   through an exhaustive `switch` over `AppLocalizations`, so a new value is a compile error rather
   than a missing string.
2. Add the fourteen ARB keys to `app_en.arb` with `@description`s, then mirror them into `app_ar.arb`,
   `app_es.arb`, `app_gl.arb`, `app_ca.arb` and `app_pt_BR.arb` (D-3). Run `flutter gen-l10n`.
3. Write `ReferenceScreenHeader`: jurisdiction name from `content_string` via
   `reference_strings.dart`, `jurisdiction.content_version` in the mono `citation` step, the
   `structural` rule beneath.
4. Write `ReferenceHubRow` as a `const` widget class — one `InkWell` at
   `l.density.rowMinHeight`, `EdgeInsetsDirectional` padding, a `BorderDirectional(bottom:
   l.rules.hairlineDotted)`, and a chevron that mirrors under `Directionality.of(context)` and owns
   no gesture. Give it a `ValueKey('reference_section_${section.name}')`.
5. Write `ReferenceHubScreen`: the masthead, `ReferenceScreenHeader`, a `LonjaSectionLabel`, then a
   `DecoratedBox` with `l.rules.groupOpen` on top wrapping a `Column` of the seven const rows.
6. Register the routes in `app/lib/routing/reference_routes.dart` and attach the hub to
   `LonjaDestination.reference`. The six child routes T02–T08 will fill point at a placeholder that
   renders `ReferenceEmptyState`'s eventual copy — replaced task by task.
7. Re-run the suite. All 16 green, and E12's shell tests still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 16 tests pass, and each failed first.
- [ ] `ReferenceSection` declares exactly seven values and its name does not contain `Destination`;
      `check_lonja_nav.sh app/lib` is clean without any `// lonja-nav-ok` hatch.
- [ ] `grep -rn 'ListTile\|DataTable\|Card(' app/lib/ui/reference/` returns nothing.
- [ ] The fourteen ARB keys exist in all six locale files, and `check_arb_parity` is clean.
- [ ] No string literal is passed to `label:`, `tooltip:` or `semanticLabel:` anywhere in the diff.
- [ ] `LonjaSectionLabel` was authored **only if it did not already exist**, and if authored it lives
      in `app/lib/ui/core/ui/`, not under `app/lib/ui/reference/`.
- [ ] Tapping `Reference` in the shell lands on `ReferenceHubScreen`; E12's own tests are unchanged.
- [ ] `packages/rule_engine/` untouched (D-7).

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh          app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh         app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh           app/lib
tools/gates/no_directional_geometry.sh                                     app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(reference): add S12, the reference hub, routing to the seven reference surfaces

The Reference destination has existed since E12 and resolved to nothing. It now
opens a ruled group of seven rows — rule text, protected species, gear and
methods, penalties, licence types, glossary, changelog — with the jurisdiction
and content version in a header the six list screens will share.

The section type is named ReferenceSection rather than ReferenceDestination
because check_lonja_nav.sh fails any enum whose name contains "Destination" and
does not declare exactly five values. That gate freezes the bottom bar and is
right; renaming the type is cheaper and more honest than an escape hatch.

Task: E15/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
