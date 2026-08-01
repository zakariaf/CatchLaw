# E19/T01 — Semantics coverage, and the result as a live region

| | |
|---|---|
| **Epic** | E19 — Accessibility, sunlight and glove modes |
| **Branch** | `epic/19-accessibility` (shared) |
| **Commit** | `feat(a11y): register all 28 surfaces and prove every control speaks` |
| **Depends on** | E08–E18 merged (every surface exists); E10/T02 (the stamp's merged node); E12 (`pumpLonja`, the key convention) |
| **Size** | L |
| **Spec** | `SPEC.md` §4.9 "Screen reader" row, §6 (the 23 screens and 5 dialogs), §13 (every control labelled; the result announced as a live region) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `accessibility-as-code` | Rules 1, 2, 6, 9 and the "display label, never a longer vocalization" argument — this task is the audit of exactly that authoring discipline |
| `widget-golden-and-a11y-testing` | Owns the assertion mechanics: `isSemantics` over the deprecated `containsSemantics`, semantics on by default in `testWidgets`, `await expectLater` for guideline matchers, and why the guidelines are advisory |
| `lonja-verdict-and-status` | Rule 12 and `references/verdict-anatomy.md`'s "Semantics tree": one merged node, category word first, glyph excluded — this task asserts the shape that skill specifies |
| `catchlaw-conventions-index` | Invariant 2 — the spoken label is the same statement of fact as the printed one, and a screen reader is not where an instruction sneaks in |
| `testing-strategy` | Rule 1 (cheapest tier that can assert it) and rule 11 (suite time) — the registry is a fixture, and the per-surface loop is a widget test only because semantics need a tree |
| `lonja-buttons` | Rule 8: `LonjaIconButton` takes a required `semanticLabel` and forwards it to `tooltip`, which is what `IconButton` wires into its own `Semantics` node |
| `catchlaw-conventions-index` (routing) | `references/routing-table.md` — `Semantics`, tap targets and never-colour-alone route to `accessibility-as-code`, so nothing here re-derives a rule that skill already owns |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.9 | The "Screen reader" row and its done condition: *"TalkBack and VoiceOver read the finding without navigating"* |
| `SPEC.md` | §6, all of it | The 23 screens, their elements, their empty and error states, and the five dialogs D1–D5 — the registry is this section, transcribed as data |
| `SPEC.md` | §13 accessibility row | "every control labelled; the result announced as a live region" |
| `.claude/skills/widget-golden-and-a11y-testing/references/a11y-guidelines-and-limits.md` | "State the ceiling", "The gate: assert the SemanticsNode directly", "Two API facts commonly got wrong" | `isSemantics` not `containsSemantics`; `await expectLater`; semantics are already on; the four guidelines are advisory |
| `.claude/skills/widget-golden-and-a11y-testing/examples/a11y_test.dart` | blocks (1) and (3) | The worked role-and-label assertion and the traversal assertion — do not diverge from their shape silently |
| `.claude/skills/lonja-verdict-and-status/references/verdict-anatomy.md` | "Semantics tree" | One node for the stamp; glyph `ExcludeSemantics`; the citation one node read verbatim; the disclaimer never excluded |
| `.claude/skills/accessibility-as-code/SKILL.md` | rules 1, 2, 6, 9; "Never state through color alone" | `liveRegion` is the transient-announcement channel; the label is the display label |
| `FLUTTER_GUIDE.md` | §6.1, §6.2 | Test naming with receipts; `testing/` sits beside `test/` so both it and `integration_test/` can import the registry |
| `epics/CONVENTIONS.md` | §6, §7, §9 | Where fixtures live and the `k`-prefix; the empty-scan failure mode this registry closes; invariant 2 |

## What this delivers

- `app/testing/a11y/audited_surfaces.dart` — `AuditedSurface`, `A11yAxes`, `kAuditedSurfaces`
  (28 entries: `S1`–`S23`, `D1`–`D5`) and `kCoreLoopSurfaces` (S1, S2, S3, S5, S8, S9). Each entry
  carries an id, a name, a `pump` closure that mounts the surface through `pumpLonja` under the
  supplied axes, the full list of its tappable `ValueKey` strings, and an optional
  `primaryActionKey` (read by T07).
- `app/test/a11y/support/semantics_walk.dart` — `semanticsNodesOf`, `tappableNodesOf`,
  `unlabelledIconsOf`. Helpers, deliberately not `*_test.dart` (`FLUTTER_GUIDE.md` §6.2).
- `app/test/a11y/semantics_coverage_test.dart` — the per-surface loop.
- `app/test/a11y/live_region_test.dart` — the single-live-region assertions.
- Extensions to `app/test/utils/harness.dart`: `useDevice(Device)` pinning
  `view.devicePixelRatio` and `view.physicalSize` with `addTearDown(view.reset)`, and `textScaler`
  and `boldText` parameters on `pumpLonja` if they are absent. **Extend it; do not fork it.** If a
  second harness exists under `app/test/ui/`, converge on `app/test/utils/harness.dart`, which is
  where `FLUTTER_GUIDE.md` §2.5's tree puts `utils`.
- Whatever labels, `semanticLabel`s and `ExcludeSemantics` wrappers the loop turns out to be
  missing, inside `app/lib/ui/`. That set is not knowable before the tests run; it is the point.

## Why it is built this way

**A registry, because completeness is the only thing an audit is for.** The alternative — adding a
semantics assertion to each feature's own test file — is what E08–E18 already did where they
remembered, and it passes on exactly the screens whose authors were thinking about it. It says
nothing about the ones who were not, and it says nothing at all when a 29th surface arrives. The
value of this epic is a statement about the whole app, and a statement about the whole app can only
be made from a list of the whole app. `SPEC.md` §6 is that list; `kAuditedSurfaces` is §6 transcribed
as data, and a test fails when the two disagree.

**The registry is a fixture under `app/testing/`, not a constant inside a test file.** `CONVENTIONS.md`
§6 puts fakes and fixtures in `testing/` precisely so both `test/` and `integration_test/` can import
them without shipping them. Six of the seven tasks in this epic loop over this list, E20's locale
sweep loops over it, and E21's device pass wants the same enumeration. A constant living in
`semantics_coverage_test.dart` would be copied on first reuse and diverge on second.

**The reconciliation count is the row that makes the audit self-maintaining.** Asserting "every
tappable node has a label" is worth having and is not enough: it is satisfied by a surface that
builds no tappables at all, which is the same failure `CONVENTIONS.md` §7 describes for a gate
scanning an empty directory. So each surface also asserts that the number of tap-action nodes in its
semantics tree equals the number of keys it registered. Add a button and forget the registry, and
the suite reds with a message naming the surface. That is the difference between an audit and a
snapshot of one afternoon.

**A live region, not `SemanticsService.announce()`.** The announcement API is fire-and-forget: it
posts a string to the platform with no node behind it, so it is not re-read when the user swipes
back to the result, it does not survive a screen-reader re-scan, and there is nothing to assert in a
widget test except that a method was called. `liveRegion: true` is a property of the node that *is*
the finding — the same node the user lands on when they do navigate — so the announcement and the
thing announced cannot drift apart, and the test asserts a tree rather than a call. E10/T02 already
set it; this task asserts it with the canonical matcher and adds the two properties E10 could not
check from inside one widget: that it is the app's *only* live region, and that it re-announces on a
new finding but not on a theme change.

**Exactly one live region.** Two live nodes on one screen race; the platform delivers one and drops
the other, and which one it drops is not something the app controls. The stale bar renders above the
verdict and is present at first paint, so if it were live it would take the single announcement the
user is waiting for and the finding would be silent — which is the precise failure §4.9's row
exists to prevent. The bar is therefore an ordinary node, read when reached.

**The glyph is excluded, not labelled.** `verdict-anatomy.md`'s semantics tree is explicit: the glyph
repeats the headline. A `semanticLabel` on it produces two nodes saying the same thing in an order
the platform chooses.

**Rejected — `containsSemantics(...)`.** Deprecated; `a11y-guidelines-and-limits.md`'s review
checklist names it. Use `isSemantics(...)`.

**Rejected — a manual `tester.ensureSemantics()` with a trailing `handle.dispose()`.** `testWidgets`
takes `semanticsEnabled: true` by default and disposes the handle for you; a second handle is a
redundant reference count, and a trailing `dispose()` is skipped when an `expect` throws, which
leaks a `SemanticsHandle` and flakes the next test in the file. Where a handle is genuinely needed,
`addTearDown(handle.dispose)`.

**Rejected — `labeledTapTargetGuideline` as the gate.** It checks only that the label is non-empty,
so a node whose label is `item_0` passes it. It stays as a one-line advisory tripwire, run with
`await expectLater` because it is an `AsyncMatcher` and a bare `expect` on it asserts nothing.

**Rejected — asserting the spoken sentence's wording here.** The words belong to
`catchlaw-verdict-contract` and are gated by `check_lonja_verdict.sh` over Dart and every ARB value
(D-7, invariant 2). This task asserts that a label *exists*, that it does not leak a key, and that
the category precedes the number. If it ever asserted the sentence, there would be two copies of the
wording law and they would disagree within a month.

## Tests first

Write every row before touching a single widget. Run them. **They must fail** — the registry does
not exist yet, so the loops do not compile, and rows 9–15 fail on the file that does not exist. If a
per-surface row passes before the registry is written, the test is not reaching the tree: check that
`pumpLonja` actually mounted the surface.

Rows marked ×28 are loop-generated and **must interpolate the surface into the description**
(`CONVENTIONS.md` §5), or `--plain-name` cannot address one failing screen.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `kAuditedSurfaces covers every screen and dialog in SPEC.md §6` | the id set | exactly `S1`…`S23`, `D1`…`D5` — 28 ids | The audit is exactly as complete as its list; an absent screen is a screen no task in this epic ever pumps |
| 2 | `kAuditedSurfaces names each surface once` | the id list | no duplicates | A duplicated id doubles the runtime while silently leaving a surface uncovered |
| 3 | `kAuditedSurfaces gives every core-loop surface a primary action key` | `kCoreLoopSurfaces` | each has a non-null `primaryActionKey` | T07 loops on this field; a null here makes T07's loop vacuous and green |
| 4 ×28 | `${s.id} ${s.name} registers every tappable node it builds` | surface pumped, paper, standard | tap-action node count == `s.targetKeys.length` | The row that makes the audit self-maintaining — a control added without a registry row reds the suite |
| 5 ×28 | `${s.id} ${s.name} labels every tappable node` | same | every tap-action node has a non-empty label | `SPEC.md` §4.9: *every control labelled*. An unlabelled node is read as "button" and nothing else |
| 6 ×28 | `${s.id} ${s.name} keeps widget keys out of its semantic labels` | same | no label contains any string in `s.targetKeys` | The check no guideline makes: `labeledTapTargetGuideline` passes a label of `check.search`, which a scanning user hears on every step |
| 7 ×28 | `${s.id} ${s.name} labels or excludes every icon` | same | every `Icon` has a `semanticLabel` or an `ExcludeSemantics` ancestor | `accessibility-as-code` rule 2 — there is no third option, and an engraved plate glyph is ambiguous to sighted users too |
| 8 | `LonjaIconButton forwards its semanticLabel to the semantics tree` | a labelled icon button | `isSemantics(label: 'Back one step', isButton: true, hasTapAction: true)` | `lonja-buttons` rule 8 is a constructor promise; this asserts the promise reaches the tree rather than stopping at `tooltip` |
| 9 | `LonjaNavStrip labels all five destinations` | the shell | five nodes, five distinct non-empty labels | The nav is on every screen; unlabelled, it is unlabelled 28 times and is the first thing a scanning user hits |
| 10 | `ResultVerdictPanel announces the finding as a live region` | `kStampBelowMinimum` | `isSemantics(isLiveRegion: true, isHeader: true)` on the merged node | §4.9's *"read the finding without navigating to it"*, stated as a node property with the canonical matcher |
| 11 | `ResultVerdictPanel reads the category before the measurement` | `kStampBelowMinimum` | `label.indexOf('Below the minimum') < label.indexOf('38')` | Hearing "38 centimetres" before "below the minimum" is hearing a number without a finding |
| 12 | `The app declares exactly one live region` | all 28 surfaces swept | exactly one node with `isLiveRegion`, and it is on S2 | Two live regions race, the platform drops one, and the app does not choose which |
| 13 | `ResultVerdictPanel re-announces when the finding changes` | pump below-minimum, then meets | the live node's label changes | A live region set once and never updated announces on first build only — and the second measurement is the case §4.9 exists for |
| 14 | `ResultVerdictPanel does not re-announce when only the theme changes` | same finding, paper then sunlight | the live node's label is identical | Sunlight is one tap from this screen (§4.9); re-announcing on every toggle teaches the user to switch the screen reader off |
| 15 | `StaleRuleBar states its expiry without claiming a live region` | expired pack | the bar's node has a non-empty label and `isLiveRegion` false | It paints above the verdict at first paint; live, it would spend the one announcement the fisher is listening for |
| 16 | `LonjaDisclaimer is never excluded from the semantics tree` | the result surface | a node whose label contains the disclaimer's lead clause | The one block carrying legal exposure; an `ExcludeSemantics` around it is invisible in review and silent on device |
| 17 | `S2 Result visits the verdict before the citation and the disclaimer` | the result surface | `simulatedAccessibilityTraversal` order matches the printed order | `verdict-anatomy.md` fixes the printed order; traversal order is a decision and inheriting it from layout is not |
| 18 ×28 | `${s.id} ${s.name} meets labeledTapTargetGuideline (advisory)` | same | matcher passes | A catastrophic-regression tripwire only — it proves a label is non-empty and nothing more, which is why rows 5 and 6 exist |

```dart
// app/testing/a11y/audited_surfaces.dart — the registry, imported by every task in E19.
import 'package:catchlaw/theme/lonja_density.dart';
import 'package:catchlaw/theme/lonja_skin.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The axes an audited surface is pumped under. Defaults are the shipped
/// defaults: paper, standard density, no scaling, no bold.
final class A11yAxes {
  const A11yAxes({
    this.skin = LonjaSkin.paper,
    this.density = LonjaDensity.standard,
    this.textScaler = TextScaler.noScaling,
    this.boldText = false,
  });

  final LonjaSkin skin;
  final LonjaDensity density;
  final TextScaler textScaler;
  final bool boldText;
}

typedef SurfacePump = Future<void> Function(WidgetTester tester, A11yAxes axes);

/// One screen or dialog of `SPEC.md` §6, with everything E19 needs to audit it.
final class AuditedSurface {
  const AuditedSurface({
    required this.id,
    required this.name,
    required this.pump,
    required this.targetKeys,
    this.primaryActionKey,
  });

  /// `S1`…`S23`, `D1`…`D5` — the ids `SPEC.md` §6 publishes.
  final String id;
  final String name;
  final SurfacePump pump;

  /// Every tappable this surface builds, by `ValueKey` string. The count is
  /// reconciled against the semantics tree, so this list cannot rot silently.
  final List<String> targetKeys;

  /// The single `LonjaButtonVariant.primary`, or null where the surface
  /// legitimately has none (a reference list, an about page). T07 reads it.
  final String? primaryActionKey;
}

const List<AuditedSurface> kAuditedSurfaces = <AuditedSurface>[
  AuditedSurface(
    id: 'S1',
    name: 'Check',
    pump: pumpCheckHome,
    targetKeys: <String>[
      'check.zone',
      'check.currency',
      'check.search',
      'check.browse',
      'check.identify',
      'check.tally',
      // …the six recents cells and the five nav destinations
    ],
    primaryActionKey: 'check.identify',
  ),
  // …27 more, one per §6 id
];

/// The six surfaces on the five-second core loop (`SPEC.md` §3). Every axis of
/// every audit runs over these; the other 22 run a reduced matrix.
const List<String> kCoreLoopSurfaces = <String>['S1', 'S2', 'S3', 'S5', 'S8', 'S9'];
```

```dart
// app/test/a11y/support/semantics_walk.dart — helpers, never *_test.dart.
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every node in the live semantics tree, root first.
Iterable<SemanticsNode> semanticsNodesOf(WidgetTester tester) {
  final SemanticsNode? root =
      tester.binding.pipelineOwner.semanticsOwner?.rootSemanticsNode;
  if (root == null) return const <SemanticsNode>[];
  final List<SemanticsNode> found = <SemanticsNode>[];
  void walk(SemanticsNode node) {
    found.add(node);
    node.visitChildren((SemanticsNode child) {
      walk(child);
      return true;
    });
  }

  walk(root);
  return found;
}

/// Nodes the user can activate. Flags are deliberately not read here — the role
/// assertions use `isSemantics` on a specific node, where the matcher is stable.
Iterable<SemanticsNode> tappableNodesOf(WidgetTester tester) => semanticsNodesOf(tester)
    .where((SemanticsNode n) => n.getSemanticsData().hasAction(SemanticsAction.tap));

/// Icons that are neither labelled nor explicitly decorative.
Iterable<Icon> unlabelledIconsOf(WidgetTester tester) =>
    tester.widgetList<Icon>(find.byType(Icon)).where((Icon icon) {
      if (icon.semanticLabel != null && icon.semanticLabel!.isNotEmpty) return false;
      return find
          .ancestor(of: find.byWidget(icon), matching: find.byType(ExcludeSemantics))
          .evaluate()
          .isEmpty;
    });
```

```dart
// app/test/a11y/semantics_coverage_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../testing/a11y/audited_surfaces.dart';
import 'support/semantics_walk.dart';

void main() {
  test('kAuditedSurfaces covers every screen and dialog in SPEC.md §6', () {
    final Set<String> ids = kAuditedSurfaces.map((AuditedSurface s) => s.id).toSet();
    final Set<String> expected = <String>{
      for (int i = 1; i <= 23; i++) 'S$i',
      for (int i = 1; i <= 5; i++) 'D$i',
    };
    expect(ids, expected,
        reason: 'a surface missing from the registry is audited by nothing in E19');
  });

  for (final AuditedSurface surface in kAuditedSurfaces) {
    testWidgets('${surface.id} ${surface.name} registers every tappable node it builds',
        (WidgetTester tester) async {
      await surface.pump(tester, const A11yAxes());
      expect(tappableNodesOf(tester).length, surface.targetKeys.length,
          reason: '${surface.id} builds a tappable that is not in targetKeys — add it '
              'to the registry, or E19 never measures it');
    });

    testWidgets('${surface.id} ${surface.name} labels every tappable node',
        (WidgetTester tester) async {
      await surface.pump(tester, const A11yAxes());
      for (final SemanticsNode node in tappableNodesOf(tester)) {
        expect(node.label, isNotEmpty,
            reason: '${surface.id} has a tappable node a screen reader reads as "button"');
      }
    });

    testWidgets('${surface.id} ${surface.name} keeps widget keys out of its semantic labels',
        (WidgetTester tester) async {
      await surface.pump(tester, const A11yAxes());
      for (final SemanticsNode node in tappableNodesOf(tester)) {
        for (final String key in surface.targetKeys) {
          expect(node.label, isNot(contains(key)),
              reason: 'the label leaks "$key"; a scanning user hears it on every step');
        }
      }
    });

    // … one test per row above, one behaviour each
  }
}
```

```dart
// app/test/a11y/live_region_test.dart
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/a11y/audited_surfaces.dart';
import '../../testing/models/result_fixtures.dart';
import '../utils/harness.dart';
import 'support/semantics_walk.dart';

void main() {
  testWidgets('ResultVerdictPanel announces the finding as a live region',
      (WidgetTester tester) async {
    await pumpResultSurface(tester, stamp: kStampBelowMinimum);

    // isSemantics — NOT containsSemantics, which is deprecated.
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('Below the minimum'))),
      isSemantics(isLiveRegion: true, isHeader: true),
    );
  });

  testWidgets('The app declares exactly one live region', (WidgetTester tester) async {
    final List<String> live = <String>[];
    for (final AuditedSurface surface in kAuditedSurfaces) {
      await surface.pump(tester, const A11yAxes());
      for (final SemanticsNode node in semanticsNodesOf(tester)) {
        if (node.getSemanticsData().isLiveRegion) live.add('${surface.id}: ${node.label}');
      }
    }
    expect(live, hasLength(1),
        reason: 'two live regions race and the platform drops one: $live');
  });

  testWidgets('ResultVerdictPanel does not re-announce when only the theme changes',
      (WidgetTester tester) async {
    await pumpResultSurface(tester, stamp: kStampBelowMinimum);
    final String before = tester.getSemantics(find.byType(ResultVerdictPanel)).label;

    await pumpResultSurface(tester, stamp: kStampBelowMinimum, skin: LonjaSkin.sunlight);
    expect(tester.getSemantics(find.byType(ResultVerdictPanel)).label, before,
        reason: 'the sunlight toggle re-announced the verdict');
  });

  // … one test per row above, one behaviour each
}
```

**Run:** `cd app && flutter test test/a11y/` → the file does not compile until
`audited_surfaces.dart` exists, then 3 + (28 × 5) + 10 failures. If any per-surface row passes
before a single label is written, `pumpLonja` did not mount the surface — fix the pump, not the
assertion.

## Implementation outline

1. Read `app/test/utils/harness.dart` **first**. Add `useDevice(Device)` — `view.devicePixelRatio`,
   `view.physicalSize = logical * dpr`, `addTearDown(view.reset)` — and `textScaler` / `boldText`
   parameters if missing, layering `MediaQuery` above `MaterialApp` from
   `MediaQuery.of(context).copyWith(...)`, never a bare `MediaQueryData()`. If a second harness
   exists under `app/test/ui/`, converge on this one and update its importers in the same commit.
2. Write `audited_surfaces.dart` with all 28 entries. Take the id, the name and the element list
   from `SPEC.md` §6 row by row. Each `pump` forwards to `pumpLonja` with the axes; a dialog's pump
   mounts its host screen and opens it, because a dialog that is never shown is never measured
   (`overflow-and-textscale.md` trap 3: a widget that does not paint reports nothing).
3. Write `semantics_walk.dart`.
4. Write both test files in full. Run. Confirm they fail.
5. Work the failures surface by surface, in registry order. Three kinds of fix, in this order of
   preference: add a `semanticLabel` sourced from the ARB key the control already displays; wrap a
   decorative glyph in `ExcludeSemantics`; add the missing `ValueKey` and its registry row. Never
   fix a failure by deleting the key from `targetKeys`.
6. For any label that leaks a key, the fix is the label, never the key: `accessibility-as-code`
   distinguishes the display label from a longer vocalization and nothing in the type system does.
7. Assert the live-region rows against `ResultVerdictPanel` as E10/T02 built it. If row 12 finds a
   second live region anywhere, remove it there — an ordinary node is read when reached, which is
   what every surface except the finding wants.
8. Re-run the whole `app` suite, not just `test/a11y/`. Labels added to shared widgets change what
   `find.bySemanticsLabel` matches in E08–E18's own tests.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 rows pass (with rows 4–7 and 18 generated ×28), and each failed first.
- [ ] `kAuditedSurfaces` has exactly 28 entries and row 1 proves the id set.
- [ ] Every `pump` in the registry mounts a real surface — no entry pumps a placeholder, and row 4
      would catch it if one did.
- [ ] One harness, at `app/test/utils/harness.dart`, pinning the view with `addTearDown(view.reset)`.
- [ ] `isSemantics` everywhere; no `containsSemantics`, no bare `expect(tester, meetsGuideline(...))`,
      no trailing `handle.dispose()`.
- [ ] Exactly one `liveRegion: true` in `app/lib/`, and it is on the verdict stamp.
- [ ] No new user-visible string was introduced by this task; every label added resolves through an
      existing ARB key (D-3's six locales, invariant 2).
- [ ] Nothing under `packages/rule_engine/` changed.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
.claude/skills/lonja-buttons/scripts/check_lonja_buttons.sh                app/lib
.claude/skills/lonja-verdict-and-status/scripts/check_lonja_verdict.sh     app/lib
```

`check_lonja_buttons.sh` check 3 is the grep behind row 8 — an icon-only button with no
`semanticLabel` and no `tooltip`. It is a floor, not proof: it cannot see through a helper that
builds the button, which is what row 8 covers.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(a11y): register all 28 surfaces and prove every control speaks

An accessibility assertion added screen by screen passes on the screens
whose author was thinking about it and says nothing about the rest, so
SPEC.md §6 is transcribed as data — 23 screens, 5 dialogs — and every audit
in this epic is a loop over that list. Each surface also reconciles its
tap-action node count against the keys it registered, so a control added
without a registry row reds the suite instead of arriving unmeasured.

The finding is asserted to be the app's only live region: two live nodes
race and the platform drops one without asking. It re-announces when the
finding changes and not when the sunlight toggle fires, because a verdict
re-read on every theme switch is how a user learns to turn the screen
reader off.

Task: E19/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
