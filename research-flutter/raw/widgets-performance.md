# Widget Composition, UI Code Quality and Performance

**Lane:** widget composition, UI code quality, rendering performance, cold start, app size, accessibility-as-code.
**Toolchain this was verified against:** Flutter **3.44.6 stable** (framework revision `ee80f08bbf`, released 2026-07-08), Dart **3.12.2**, DevTools **2.57.0**.
**Date of research:** 2026-07-27.

---

## 0. How this document was produced (read this first)

Everything below is either (a) quoted from a primary source I fetched, or (b) **measured by me** by writing and running real Flutter tests against the local 3.44.6 SDK. Measured results are labelled **[MEASURED]** and the exact test code is included so you can re-run it.

Three classes of source were used, in order of authority:

1. **The Flutter framework source at the exact revision you are running.** The local SDK at `/Users/zakariafatahi/development/flutter` is git revision `ee80f08bbf97172ec030b8751ceab557177a34a6`, which is *identical* to the `3.44.6` tag on GitHub (verified via `gh api repos/flutter/flutter/git/ref/tags/3.44.6`). So every line-number citation below is a stable permalink of the form
   `https://github.com/flutter/flutter/blob/3.44.6/<path>#L<n>`.
2. **The flutter/website repo source markdown**, not the rendered page. This matters: I fetched `docs.flutter.dev/perf/impeller` through a summarising fetch tool first, and it returned a **fabricated "Version History" table** that does not exist in the source. I discarded it and re-read `sites/docs/src/content/perf/impeller.md` verbatim. Treat any AI-summarised Flutter doc with suspicion.
3. **The pub.dev API** for package version/publish dates.

**Zero Medium posts are cited.** Two blog posts on `blog.flutter.dev` are referenced only because the official docs link them and they were written by the Flutter Material team; they are marked as such.

### The measurement rig

All **[MEASURED]** numbers come from a throwaway package:

```
probe/
  pubspec.yaml          # name: probe, deps: flutter, flutter_test
  lib/ruler.dart
  test/rebuild_test.dart
  test/inherited_test.dart
  test/list_test.dart
  test/boundary_test.dart
  test/keys_test.dart
  test/const_identity_test.dart
  test/ruler_test.dart
```

Run with `flutter test`. Every snippet in this document compiles and its assertions pass on 3.44.6 unless explicitly marked as a deliberately-bad example.

---

## 1. `StatelessWidget` subclass vs a build-returning helper method

This is the single most-repeated rule in Flutter and the single most poorly explained. Here is the authoritative source, the actual mechanism, and — importantly — **what the rule does and does not buy you**, measured.

### 1.1 The authoritative source

There are exactly three first-party statements, and they all say the same thing.

**(a) The performance best-practices page.** Verbatim from `sites/docs/src/content/perf/best-practices.md` lines 84–86:

> * To create reusable pieces of UIs,
>   prefer using a [`StatelessWidget`][]
>   rather than a function.

Source: <https://github.com/flutter/flutter-website/blob/main/sites/docs/src/content/perf/best-practices.md> — rendered at <https://docs.flutter.dev/perf/best-practices#control-build-cost>

**(b) The framework dartdoc.** This is the strongest source, because it is a `{@template}` deliberately shared between `StatelessWidget` and `StatefulWidget`. Verbatim from `packages/flutter/lib/src/widgets/framework.dart` lines 455–463:

```
/// {@template flutter.flutter.widgets.framework.prefer_const_over_helper}
///  * When trying to create a reusable piece of UI, prefer using a widget
///    rather than a helper method. For example, if there was a function used to
///    build a widget, a [State.setState] call would require Flutter to entirely
///    rebuild the returned wrapping widget. If a [Widget] was used instead,
///    Flutter would be able to efficiently re-render only those parts that
///    really need to be updated. Even better, if the created widget is `const`,
///    Flutter would short-circuit most of the rebuild work.
/// {@endtemplate}
```

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/framework.dart#L455-L463>
It is macro-expanded into `StatefulWidget`'s docs at line 686 of the same file.

**(c) The official video.** Both of the above link `https://www.youtube.com/watch?v=IOyq-eTRhvo` — *"Widgets vs helper methods"*, from the official Flutter YouTube channel (the *Decoding Flutter* series). The link appears in `framework.dart` at lines 468 and 691 as a `{@youtube}` directive, and in `best-practices.md` line 105. I could not watch the video, but its ID is verified as present in two independent primary sources.

There is **no lint rule** for this. I checked: no rule name resembling `prefer_widget_over_function` is recognised by the Dart 3.12.2 analyzer (probed by feeding candidate names to `dart analyze`, which reports `undefined_lint` for unrecognised names).

### 1.2 The actual mechanism

Three separate things are going on. People conflate them and then argue past each other.

#### Mechanism 1 — the element-tree identity short-circuit

`Element.updateChild` is *the* core of the widget system. Verbatim, `framework.dart` lines 4014–4022:

```dart
if (hasSameSuperclass && child.widget == newWidget) {
  // We don't insert a timeline event here, because otherwise it's
  // confusing that widgets that "don't update" (because they didn't
  // change) get "charged" on the timeline.
  if (child.slot != newSlot) {
    updateSlotForChild(child, newSlot);
  }
  newChild = child;
} else if (hasSameSuperclass && Widget.canUpdate(child.widget, newWidget)) {
```

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/framework.dart#L4014-L4022>

The critical detail: **`child.widget == newWidget` is an identity check, not a value check.** `Widget.operator ==` is declared:

```dart
@override
@nonVirtual
bool operator ==(Object other) => super == other;

@override
@nonVirtual
int get hashCode => super.hashCode;
```

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/framework.dart#L364-L370>

`super ==` is `Object.==`, i.e. `identical()`. So the branch is taken **only when the exact same Dart object instance is handed back**. When it is taken, the entire subtree below that element is skipped — no `update()`, no `build()`, no `markNeedsLayout`, no `markNeedsPaint`. That is the "short-circuit most of the rebuild work" the docs mean.

The only two ways to get the same instance back are:
1. a `const` constructor (Dart canonicalises const expressions), or
2. caching the widget in a `final` field and reusing it.

**[MEASURED]** — const canonicalisation is real and observable:

```dart
// test/const_identity_test.dart  -- PASSES on 3.44.6
class Box extends StatelessWidget {
  const Box({super.key, this.n = 1});
  final int n;
  @override
  Widget build(BuildContext context) => SizedBox(height: n.toDouble());
}

Widget makeConst() => const Box(n: 3);
Widget makeNew()   => Box(n: 3);

test('const constructors are canonicalized to one instance', () {
  expect(identical(makeConst(), makeConst()), isTrue);   // same object
  expect(identical(makeNew(),   makeNew()),   isFalse);  // new object each call
  expect(Widget.canUpdate(makeNew(), makeNew()), isTrue); // still "updatable"
  expect(makeNew()   == makeNew(),   isFalse);           // Widget== is identity
  expect(makeConst() == makeConst(), isTrue);
});
```

#### Mechanism 2 — `BuildContext` scoping of `InheritedWidget` dependencies

**This is the mechanism nobody talks about, and it is the one that is unconditionally true.**

A helper method has no `BuildContext` of its own. It uses the *caller's* context. So `Theme.of(context)`, `MediaQuery.sizeOf(context)`, `Localizations.of(context)`, `ref.watch` via a `Consumer`'s context — every one of these registers **the parent element** as the dependent. When the inherited value changes, the framework dirties the parent, and the parent's *entire* build method runs.

A widget subclass gets its own `Element`, therefore its own `BuildContext`, therefore its own dependency registration. Only it rebuilds.

**[MEASURED]** — this is the decisive experiment. `test/inherited_test.dart`, passes on 3.44.6:

```dart
class Tint extends InheritedWidget {
  const Tint({super.key, required this.value, required super.child});
  final int value;
  static int of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<Tint>()!.value;
  @override
  bool updateShouldNotify(Tint old) => old.value != value;
}

// ---- helper-method version ----
class HelperHost extends StatelessWidget {
  const HelperHost({super.key});

  Widget _banner(BuildContext context) {
    final int v = Tint.of(context);          // uses the HOST's context
    bannerBuilds++;
    return SizedBox(width: v.toDouble(), height: 1);
  }

  @override
  Widget build(BuildContext context) {
    hostBuilds++;
    return Column(children: [const Sibling(), _banner(context)]);
  }
}

// ---- widget-class version ----
class Banner2 extends StatelessWidget {
  const Banner2({super.key});
  @override
  Widget build(BuildContext context) {
    final int v = Tint.of(context);          // uses its OWN context
    bannerBuilds++;
    return SizedBox(width: v.toDouble(), height: 1);
  }
}

class ClassHost extends StatelessWidget {
  const ClassHost({super.key});
  @override
  Widget build(BuildContext context) {
    hostBuilds++;
    return Column(children: const [Sibling(), Banner2()]);
  }
}
```

Result when `Tint.value` changes by one:

```
HELPER initial : host=1 banner=1 sibling=1
HELPER after   : host=2 banner=2 sibling=1     <-- host rebuilt
CLASS  initial : host=1 banner=1 sibling=1
CLASS  after   : host=1 banner=2 sibling=1     <-- host did NOT rebuild
```

**The helper method dragged its parent into the rebuild. The widget class did not.** For this app that means: a helper method that touches `AppLocalizations.of(context)` or `Theme.of(context)` anywhere in a screen makes the *whole screen* rebuild on every locale or theme change. With six locales and an RTL flip, that is not academic.

#### Mechanism 3 — everything else an `Element` gives you

A widget class also gets: a stable position in the element tree (so `State` is preserved, so keys work), a name in DevTools' widget tree and in `Track Widget Builds` timeline events, its own `dispose`/`initState` lifecycle if it becomes stateful, and the ability to be wrapped in `RepaintBoundary` meaningfully. A closure returning widgets gets none of that.

### 1.3 The honest nuance — where the rule is oversold

**[MEASURED]** — I built the exact comparison the rule implies, with both sides *non-const*:

```
EXP2  helper: subtree=3 leaf=1 | non-const class: subtree=3 leaf=1
```

Identical. **A non-const widget subclass rebuilds exactly as often as a helper method under `setState`.** The framework calls `child.update(newWidget)` → `StatelessElement` marks itself dirty → `build()` runs. You gained an `Element` allocation and nothing else on the rebuild-count axis.

Equally, **a helper method that returns a fully-`const` expression is short-circuited just like a const widget** — my first attempt at this experiment "failed" for exactly that reason, because `_buildStatic() => const Padding(padding: EdgeInsets.all(4), child: Leaf())` returns the canonicalised instance every time.

So the accurate statement of the rule is:

> Extracting to a `StatelessWidget` **enables** the const short-circuit and **always** scopes inherited-widget dependencies. Extracting to a widget you then instantiate non-const, from a parent that has no inherited dependencies, buys you approximately nothing at runtime.

### 1.4 Where credible sources disagree, and my call

The disagreement is real: the Flutter team's position (docs + framework dartdoc + video) is unconditional — "prefer a widget". A recurring counter-argument in the community is that the rule is cargo-culted, that helper methods are cheaper to write, and that for a subtree that is rebuilt anyway there is no measurable difference. My measurement in §1.3 shows the counter-argument is *partly correct on the rebuild-count axis alone*.

**My recommendation for this app: follow the Flutter team's rule, without exception, and here is the reasoning that survives my own measurements.**

- Mechanism 2 (dependency scoping) is unconditional and is the dominant cost in a six-locale RTL app. You cannot predict at authoring time whether a helper will later gain a `Theme.of` call.
- Mechanism 1 is only available if you extract. You can add `const` later; you cannot add an `Element` later without a refactor.
- The `Track Widget Builds` DevTools view and the widget inspector are useless for finding hot spots if half your UI is anonymous closures. On a 1.2 s cold-start budget you will need those tools.
- The cost of the rule is one class declaration. That is a rounding error.

**Practical shape.** Private widget classes in the same file are fine and idiomatic — that is what the framework itself does (`_MyKey extends GlobalObjectKey` at `framework.dart` L236 is the same instinct). Do not create a file per widget.

```dart
// lib/features/measure/measure_screen.dart
class MeasureScreen extends ConsumerWidget {
  const MeasureScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Column(children: [_Header(), _RulerPane(), _Footer()]),
    );
  }
}

class _Header extends StatelessWidget {   // private, same file, const-able
  const _Header();
  @override
  Widget build(BuildContext context) => Text(AppLocalizations.of(context)!.measureTitle);
}
```

Note `const _Header()` has no `key` parameter — a private single-use widget does not need one, and omitting it keeps the constructor const-able and satisfies `use_key_in_widget_constructors` only for public widgets (the lint exempts private classes).

### 1.5 Composition over inheritance — the official framing

The `/ui/widgets-intro` URL named in the brief **no longer exists**. It is a `301` redirect to `/ui` — verified in `firebase.json` of the website repo:

```json
{ "source": "/ui/widgets-intro", "destination": "/ui", "type": 301 },
{ "source": "/widgets-intro",    "destination": "/ui", "type": 301 },
```

The composition guidance now lives in the architectural overview. Verbatim, `sites/docs/src/content/resources/architectural-overview.md` lines 359–367:

> The class hierarchy is deliberately shallow and broad to maximize the possible
> number of combinations, focusing on small, composable widgets that each do one
> thing well. Core features are abstract, with even basic features like padding
> and alignment being implemented as separate components rather than being built
> into the core. […] So, for
> example, to center a widget, rather than adjusting a notional `Align` property,
> you wrap it in a `Center` widget.

And lines 383–387:

> A defining characteristic of Flutter is that
> you can drill down into the source for any widget and examine it. So, rather
> than subclassing `Container` to produce a customized effect, you can compose it
> and other widgets in novel ways, or just create a new widget using
> `Container` as inspiration.

Source: <https://docs.flutter.dev/resources/architectural-overview#composition>

**The operational rule:** never `extends` a concrete widget (`class MyCard extends Card` is wrong). Extend only `StatelessWidget` / `StatefulWidget` / `RenderObjectWidget` and *contain* the thing you wanted to specialise.

The `StatelessWidget` performance dartdoc gives the other half of the composition rule — **minimise node count**, `framework.dart` L431–437:

> * Minimize the number of nodes transitively created by the build method and
>   any widgets it creates. For example, instead of an elaborate arrangement
>   of `Row`s, `Column`s, `Padding`s, and `SizedBox`es to position a single
>   child in a particularly fancy manner, consider using just an `Align` or a
>   `CustomSingleChildLayout`. Instead of an intricate layering of multiple
>   `Container`s and with `Decoration`s to draw just the right graphical
>   effect, consider a single `CustomPaint` widget.

---

## 2. `const` — what it actually saves and how to force it

### 2.1 What it saves

Three distinct wins, in decreasing order of importance:

1. **The `updateChild` identity short-circuit** (§1.2). This is the big one — it skips an arbitrarily deep subtree, not just one build call.
   **[MEASURED]**: `EXP1  const child Leaf.build calls = 1 | non-const = 2` after one `setState`. Extrapolate: a `const` header in a screen that rebuilds 60×/s during a drag saves 60 subtree rebuilds per second.
2. **Zero allocation per build.** Canonicalised const objects are created once at compile time and live in the read-only heap segment. No allocation → no GC pressure. On a low-end Android device with a small heap this is the difference between a smooth scroll and a young-gen collection mid-frame.
3. **Smaller code / better AOT.** Constant folding lets the AOT compiler treat the tree as data.

### 2.2 How to enforce it — and the trap

**`flutter_lints` does NOT enable `prefer_const_constructors`.** This is a real gap and the docs are misleading about it. `best-practices.md` L79–81 says:

> To be automatically reminded
> to use `const` when possible, enable the
> recommended lints from the [`flutter_lints`][] package.

But here is the actual, complete content of `flutter_lints` 6.0.0 (published 2025-05-27), fetched from `flutter/packages`:

```yaml
# packages/flutter_lints/lib/flutter.yaml
include: package:lints/recommended.yaml

linter:
  rules:
    - avoid_print
    - avoid_unnecessary_containers
    - avoid_web_libraries_in_flutter
    - no_logic_in_create_state
    - prefer_const_constructors_in_immutables
    - sized_box_for_whitespace
    - sort_child_properties_last
    - use_build_context_synchronously
    - use_full_hex_values_for_flutter_colors
    - use_key_in_widget_constructors
```

Source: <https://github.com/flutter/packages/blob/main/packages/flutter_lints/lib/flutter.yaml>

`prefer_const_constructors_in_immutables` only makes you *declare* your own constructors `const`. It says nothing about *call sites*. And `package:lints/recommended.yaml` (which `flutter_lints` includes) enables `unnecessary_const` — a rule that **removes** redundant `const` keywords — but not `prefer_const_constructors`.

**Do this.** Add to `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # flutter_lints does NOT include these. They are what actually
    # produces the updateChild identity short-circuit.
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_const_declarations
```

All three names are verified as recognised by the Dart 3.12.2 analyzer. I validated the probe by also feeding a bogus name and confirming the analyzer reports it:

```
warning - analysis_options.yaml:4:7 - 'definitely_not_a_real_rule_xyz' isn't a
recognized lint rule. Try using the name of a recognized lint rule. - undefined_lint
```

`prefer_const_literals_to_create_immutables` matters more than people think — it catches `children: [ const A(), const B() ]` and makes it `children: const [ A(), B() ]`, which canonicalises the *list* too, so `Column`'s `children` field compares identical.

**Make it an error, not a warning**, so CI enforces it:

```yaml
analyzer:
  errors:
    prefer_const_constructors: error
    prefer_const_literals_to_create_immutables: error
```

(The `lints-analysis.md` sibling document owns the full `analysis_options.yaml`; this section is only the const-relevant subset. Coordinate to avoid two conflicting files.)

### 2.3 When `const` is impossible, cache instead

Straight from `StatefulWidget`'s dartdoc, `framework.dart` L659–668:

> * If a subtree does not change, cache the widget that represents that
>   subtree and re-use it each time it can be used. To do this, assign
>   a widget to a `final` state variable and re-use it in the build method. It
>   is massively more efficient for a widget to be re-used than for a new (but
>   identically-configured) widget to be created. […]
> * Use `const` widgets where possible. (This is equivalent to caching a
>   widget and re-using it.)

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/framework.dart#L659-L668>

```dart
class _RulerPaneState extends State<_RulerPane> {
  // Built once. Identity is stable -> updateChild short-circuits it forever.
  late final Widget _legend = _RulerLegend(unit: widget.unit);

  @override
  Widget build(BuildContext context) => Column(children: [_legend, _liveRuler()]);
}
```

---

## 3. Keys — when required, when harmful, and the real cost of `GlobalKey`

### 3.1 The mechanism

`Widget.canUpdate`, `framework.dart` L382–384:

```dart
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType && oldWidget.key == newWidget.key;
}
```

And `Widget.key`'s doc, L332–333:

> Generally, a widget that is the only child of another widget does not need
> an explicit key.

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/framework.dart#L316-L338>

### 3.2 When keys are REQUIRED

**Rule: you need a key when a list of *same-type siblings* can be reordered, inserted into, or removed from, AND those siblings own state (a `State`, a scroll offset, an animation, a text-field selection).**

Without a key, `canUpdate` matches purely on type + position, so the `Element` (and its `State`) stays put and the *data* slides past it.

**[MEASURED]** — `test/keys_test.dart`, passes on 3.44.6. Three `Tracked` widgets `A, B, C`; I set `counter = 100` on the first one; then reorder to `C, B, A`:

```
NO-KEY  first slot now shows id=C counter=100  (State stayed in slot 0, the DATA moved)
        log=[initState A, initState B, initState C]        <-- no re-init at all

VALUEKEY first slot id=C counter=0; last slot id=A counter=100
        log=[initState A, initState B, initState C]        <-- State followed the item
```

That first line is a genuine data-corruption bug shape: the counter that belonged to A is now displayed on C. In this app that is a saved measurement rendered against the wrong reference-DB row.

### 3.3 `ValueKey` vs `ObjectKey` vs `UniqueKey`

| Key | Equality | Use it for |
|---|---|---|
| `ValueKey<T>(v)` | `v == other.v` | The **stable domain identity** of the row — a drift primary key. `ValueKey(row.id)`. This is what you want 95% of the time. |
| `ObjectKey(o)` | `identical(o, other.o)` | When the item has no stable id and you are keying on the *instance*. Source: `framework.dart` L89–105 — it uses `identical()` and `identityHashCode`. Dangerous with drift: a re-query returns a *new* row object, so `ObjectKey` will mismatch and destroy state. **Avoid in this app.** |
| `UniqueKey()` | never equal to anything | Deliberately forcing a teardown/rebuild, e.g. resetting a form. Never call it inside `build()` on a widget you want to persist. |

**Opinionated call for this app:** always `ValueKey(<drift primary key>)`. Never `ObjectKey`. `UniqueKey` only in an explicit "reset" action.

### 3.4 `GlobalKey` — the real cost

Verbatim from `framework.dart` L122–152:

> Widgets that have global keys reparent their subtrees when they are moved
> from one location in the tree to another location in the tree. In order to
> reparent its subtree, a widget must arrive at its new location in the tree
> in the same animation frame in which it was removed from its old location in
> the tree.
>
> **Reparenting an `Element` using a global key is relatively expensive, as
> this operation will trigger a call to `State.deactivate` on the associated
> `State` and all of its descendants; then force all widgets that depends
> on an `InheritedWidget` to rebuild.**
>
> If you don't need any of the features listed above, consider using a `Key`,
> `ValueKey`, `ObjectKey`, or `UniqueKey` instead.
>
> ## Pitfalls
>
> GlobalKeys should not be re-created on every build. They should usually be
> long-lived objects owned by a `State` object, for example.
>
> Creating a new GlobalKey on every build will throw away the state of the
> subtree associated with the old key and create a new fresh subtree for the
> new key. Besides harming performance, this can also cause unexpected
> behavior in widgets in the subtree. For example, a `GestureDetector` in the
> subtree will be unable to track ongoing gestures since it will be recreated
> on each build.

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/framework.dart#L116-L157>

**[MEASURED]** — both halves of that warning, confirmed:

```
GLOBALKEY counter survived = 42; events during reparent = [deactivate G, activate G]
FRESH-GLOBALKEY-PER-BUILD log = [initState G, initState G, deactivate G, dispose G]
```

The second line is the killer. A `GlobalKey` created inside `build()` causes: a brand-new `initState` on a *second* instance, then `deactivate` + `dispose` of the original. All state gone, every frame.

Also note there are two extra hidden costs the docs do not spell out:
- Every `GlobalKey` lives in a process-wide registry (`buildOwner._globalKeyRegistry`, `framework.dart` L173), so it is a permanent map entry and a GC root path.
- Two widgets with the same `GlobalKey` in the tree simultaneously **assert at runtime** (L136–137). With six locales and RTL you can hit this via a mis-scoped key during a route transition.

**Opinionated call for this app:**
- The only legitimate `GlobalKey` uses are: `GlobalKey<FormState>` for form validation, `GlobalKey<ScaffoldState>` (prefer `ScaffoldMessenger.of(context)` instead), and `GlobalKey` on a `RepaintBoundary` to capture a `ui.Image` for **PDF export**. That last one you *will* need.
- Own it in `State`, create it in the field initialiser or `initState`, never in `build`.

```dart
class _ExportableRulerState extends State<ExportableRuler> {
  // Long-lived, owned by State. Never recreated.
  final GlobalKey _boundaryKey = GlobalKey(debugLabel: 'ruler-capture');

  Future<Uint8List> capture({double pixelRatio = 3.0}) async {
    final boundary =
        _boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) =>
      RepaintBoundary(key: _boundaryKey, child: const RulerView());
}
```

---

## 4. Rebuild scoping

### 4.1 The rule from the docs

`best-practices.md` L59–64, verbatim:

> * When `setState()` is called on a `State` object,
>   all descendent widgets rebuild. Therefore,
>   localize the `setState()` call to the part of
>   the subtree whose UI actually needs to change.
>   Avoid calling `setState()` high up in the tree
>   if the change is contained to a small part of the tree.

And `framework.dart` L648–651:

> * Push the state to the leaves. For example, if your page has a ticking
>   clock, rather than putting the state at the top of the page and
>   rebuilding the entire page each time the clock ticks, create a dedicated
>   clock widget that only updates itself.

### 4.2 The five techniques, in the order you should reach for them

**(1) Push state to the leaf.** Not "lift state up" — that is a React idiom and it is wrong for Flutter's rebuild model.

**(2) `const` children.** §2. Free, and it is the only thing that stops a rebuild *dead* rather than merely making it cheap.

**(3) The `child` escape hatch on builders.** Verbatim from `ListenableBuilder`'s dartdoc (macro `flutter.widgets.transitions.ListenableBuilder.optimizations`, shared with `AnimatedBuilder` and `ValueListenableBuilder`), `transitions.dart` L1102–1115:

> If the `builder` function contains a subtree that does not depend on the
> `listenable`, it is more efficient to build that subtree once instead
> of rebuilding it on every change of the `listenable`.
>
> Performance is therefore improved by specifying any widgets that don't need
> to change using the prebuilt `child` attribute. The `ListenableBuilder`
> passes this `child` back to the `builder` callback so that it can be
> incorporated into the build.

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/transitions.dart#L1100-L1115>

```dart
// The ruler face is expensive and static. The cursor is cheap and animates.
AnimatedBuilder(
  animation: _cursorAnimation,
  child: const RulerFace(),                    // built ONCE
  builder: (context, child) => Stack(
    children: [
      child!,                                  // reused instance -> short-circuits
      Positioned(left: _cursorAnimation.value, child: const _Cursor()),
    ],
  ),
)
```

`best-practices.md` L408–416 states the anti-pattern side of this explicitly.

**(4) `Builder` to create a narrower `BuildContext`.** `Builder` is a `StatelessWidget` whose only job is to give you a child element, and therefore a child context. Use it when you need a context *below* an inherited widget you just introduced, and to stop a `.of(context)` lookup from dirtying the parent:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Builder(
      // This context is BELOW the Scaffold, so ScaffoldMessenger.of() works,
      // and a MediaQuery change dirties only this Builder, not the Scaffold.
      builder: (context) => TextButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(...)),
        child: const Text('Save'),
      ),
    ),
  );
}
```

Be aware: `Builder`'s callback is a closure returning widgets — i.e. exactly the "helper method" shape from §1. It buys you the *context* scoping (mechanism 2) because it *is* a widget, but the closure's return value is rebuilt whenever `Builder` rebuilds. Keep it small.

**(5) Riverpod-specific.** (Detail belongs to the `state-management.md` lane; the widget-side rules are:)
- Prefer a small `Consumer` widget wrapping only the reactive leaf over making the whole screen a `ConsumerWidget`.
- Use `Consumer`'s `child:` parameter exactly like §4.2(3).
- `ref.watch(p.select((s) => s.field))` so the rebuild is gated on the field, not the object.

```dart
Consumer(
  child: const _StaticRulerChrome(),            // built once
  builder: (context, ref, child) {
    final mm = ref.watch(measurementProvider.select((m) => m.millimetres));
    return Stack(children: [child!, _Readout(mm)]);
  },
)
```

### 4.3 Do not override `operator ==` on a Widget — and you literally cannot

`best-practices.md` L426–437 warns against it and cites O(N²) behaviour. **This advice is now enforced by the analyzer and is effectively dead letter**: `Widget.operator ==` and `Widget.hashCode` have been `@nonVirtual` since PR #46900 (2020-01-06, commit `7fee0c52d39`).

**[MEASURED]** — writing the override produces analyzer warnings:

```
warning - bad_eq.dart:7:17 - The member '==' is declared non-virtual in 'Widget'
          and can't be overridden in subclasses. - invalid_override_of_non_virtual_member
warning - bad_eq.dart:9:11 - The member 'hashCode' is declared non-virtual in 'Widget'
          and can't be overridden in subclasses. - invalid_override_of_non_virtual_member
```

Promote `invalid_override_of_non_virtual_member` to `error` in `analysis_options.yaml` and the advice becomes unbreakable.

---

## 5. `RepaintBoundary` — when it helps and when it hurts

### 5.1 The mechanism, verbatim

From `basic.dart`, the `RepaintBoundary` dartdoc:

> This widget creates a separate display list for its child, which
> can improve performance if the subtree repaints at different times than
> the surrounding parts of the tree.
>
> This is useful since `RenderObject.paint` may be triggered even if its
> associated `Widget` instances did not change or rebuild. A `RenderObject`
> will repaint whenever any `RenderObject` that shares the same `Layer` is
> marked as being dirty and needing paint […]
>
> When a `RenderObject` is flagged as needing to paint via
> `RenderObject.markNeedsPaint`, the nearest ancestor `RenderObject` with
> `RenderObject.isRepaintBoundary`, up to possibly the root of the application,
> is requested to repaint. That nearest ancestor's `RenderObject.paint` method
> will cause _all_ of its descendant `RenderObject`s to repaint in the same
> layer.

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/basic.dart#L7642> (class declaration; dartdoc immediately above)

**Read that twice.** Repaint propagation is a *render-tree* concern and is completely independent of `build`. A `const` widget that never rebuilds will still be **repainted** every frame if an animating sibling shares its layer.

### 5.2 [MEASURED] — the exact scenario in this app

A static ruler face plus a cursor sliding over it. `test/boundary_test.dart`, passes on 3.44.6:

```dart
Widget ruler = CustomPaint(
  size: const Size(300, 40),
  painter: CountingPainter(() => staticPaints++),   // shouldRepaint => false
);
if (widget.boundary) ruler = RepaintBoundary(child: ruler);

return Stack(children: [
  Positioned(left: 0,  top: 0, child: ruler),
  Positioned(left: dx, top: 0, child: CustomPaint(
    size: const Size(2, 40),
    painter: CountingPainter(() => movingPaints++))),
]);
```

Five `setState` frames moving the cursor:

```
RepaintBoundary=false  staticPaints: first=1 total=6  movingPaints=6
RepaintBoundary=true   staticPaints: first=1 total=1  movingPaints=6
```

**6× → 1×.** Note the painter's `shouldRepaint` returns `false` in both runs; that did not help, because the repaint was propagating through the shared layer, not through the painter delegate. Over a one-second 60 fps drag this is 60 full re-rasterisations of the ruler that you simply do not do.

### 5.3 When it HURTS

`RepaintBoundary` is not free. Each one:
- allocates a dedicated `Layer` and an offscreen texture the size of the subtree,
- adds a composite step to the raster thread,
- costs GPU memory (width × height × 4 bytes, at device pixel ratio — a full-screen boundary on a 1080×2400 phone is ~10 MB).

**Do not** wrap every widget "just in case". On a low-end Android device, layer explosion is a more common cause of jank than overdraw.

**Rules I would enforce in review:**
- Add a `RepaintBoundary` only around a subtree that is **expensive to paint** AND **static** AND has an **animating neighbour**. All three.
- The ruler face: yes.
- Each row of a `ListView`: **no, and never** — `ListView`/`SliverList` already inserts one per child (`addRepaintBoundaries` defaults to `true`, `scroll_view.dart` L1322, L1405). Adding your own doubles the layers.
- Verify with `debugRepaintRainbowEnabled = true` (`rendering/debug.dart` L67) in debug, and **Track Paints** in DevTools' enhance-tracing dropdown.

---

## 6. Lists — what actually breaks at 10 000 rows

### 6.1 The docs' claim

`best-practices.md` L258–263:

> #### Be lazy!
>
> When building a large grid or list,
> use the lazy builder methods, with callbacks.
> That ensures that only the visible portion of the
> screen is built at startup time.

And the `ListView` dartdoc, `scroll_view.dart` L954–966:

> If non-null, the `itemExtent` forces the children to have the given extent
> in the scroll direction.
>
> If non-null, the `prototypeItem` forces the children to have the same extent
> as the given widget in the scroll direction.
>
> **Specifying an `itemExtent` or an `prototypeItem` is more efficient than
> letting the children determine their own extent because the scrolling
> machinery can make use of the foreknowledge of the children's extent to save
> work, for example when the scroll position changes drastically.**
>
> You can't specify both `itemExtent` and `prototypeItem`, only one or none of
> them.

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/scroll_view.dart#L946-L990>

### 6.2 [MEASURED] — the numbers, and one big surprise

`test/list_test.dart`, 10 000 rows of a 40 px-tall `Row1` widget, passes on 3.44.6:

```
EAGER    ListView(children:)   rowBuilds=22  pump=66ms
LAZY     ListView.builder      rowBuilds=22  pump= 9ms
LAZY+EXT itemExtent:40         rowBuilds=22  pump=10ms

JUMP no-extent : builds first=22 total-after-jump=10000
JUMP itemExtent: builds first=22 total-after-jump=22
```

Two findings, one of them counter-intuitive:

**Finding A — the eager `ListView` cost is NOT extra `build()` calls.** All three variants call `Row1.build` exactly 22 times on first frame. `SliverChildListDelegate` still only *inflates* the visible children. The 66 ms vs 9 ms gap (**7×**) is the cost of `List.generate` constructing 10 000 `Row1` **objects** plus the `List` itself, on the UI thread, inside the first frame. That is pure allocation and GC pressure. This is why `best-practices.md` L421–424 says:

> * Avoid using constructors with a concrete `List`
>   of children (such as `Column()` or `ListView()`)
>   if most of the children are not visible
>   on screen to avoid the build cost.

**Finding B — this is the one that will bite you.** Jumping to the end of a 10 000-row list:

| | rows built |
|---|---|
| `ListView.builder` without `itemExtent` | **10 000** |
| `ListView.builder` with `itemExtent: 40` | **22** |

**A 450× difference.** Without a known extent, `SliverList` must build children sequentially to discover where the target offset lands. Every `jumpTo`, every restored scroll position, every "scroll to selected item" deep-link pays this. On a low-end device that is a multi-second freeze.

### 6.3 Opinionated rules for this app

1. **`ListView.builder` always.** `ListView(children: [...])` only for a genuinely fixed, small (< ~15) set — a settings page.
2. **`itemExtent` whenever rows are uniform height.** Free 450× on jumps. Your reference-DB browse list is uniform: use it.
3. **`prototypeItem` when the height is uniform but you don't want to hard-code it** — it survives text-scale and locale changes (Arabic line height differs from Latin), which a literal `itemExtent: 56` does not. For a six-locale app with dynamic type, `prototypeItem` is the safer default:
   ```dart
   ListView.builder(
     prototypeItem: const _ReferenceRow.prototype(),  // measured once
     itemCount: rows.length,
     itemBuilder: (context, i) => _ReferenceRow(key: ValueKey(rows[i].id), row: rows[i]),
   )
   ```
   There is also `itemExtentBuilder` (per-index extents) since the constructor asserts `You can only pass one of itemExtent, prototypeItem and itemExtentBuilder` (`scroll_view.dart` L1339–1342).
4. **Slivers when the screen mixes content.** `ListView` is documented as "basically a `CustomScrollView` with a single `SliverList`" (`scroll_view.dart` L1145–1146). The moment you want a header + a grid + a list in one scroll view, go to `CustomScrollView` — do **not** nest scrollables or use `shrinkWrap: true`.
   Mapping given verbatim at `scroll_view.dart` L1157–1160: `SliverList` if neither is set, `SliverFixedExtentList` for `itemExtent`, `SliverPrototypeExtentList` for `prototypeItem`.
5. **`shrinkWrap: true` is a performance bug.** It forces the sliver to lay out *all* children to compute its own size. It is the list equivalent of an intrinsic pass. Fix by using slivers.
6. **Never use intrinsics with lists.** `best-practices.md` L300–316 explains the two-pass cost; enable **Track layouts** in DevTools to detect it (events labelled `'$runtimeType intrinsics'`).
7. **State in list children dies on scroll-out.** `scroll_view.dart` L1094–1099:
   > When a child is scrolled out of view, the associated element subtree,
   > states and render objects are destroyed.

   The documented fix (L1106–1112) is to move the state out of the list, into your data model — which in this app means drift + Riverpod, not `AutomaticKeepAliveClientMixin`. Keep-alives pin memory and are the wrong default.

---

## 7. `CustomPainter` — the on-screen ruler

### 7.1 The contract, verbatim

From `custom_paint.dart` L246–271, on `shouldRepaint`:

> Called whenever a new instance of the custom painter delegate class is
> provided to the `RenderCustomPaint` object […]
>
> If the new instance represents different information than the old
> instance, then the method should return true, otherwise it should return
> false.
>
> If the method returns false, then the `paint` call might be optimized
> away.
>
> **It's possible that the `paint` method will get called even if
> `shouldRepaint` returns false** (e.g. if an ancestor or descendant needed to
> be repainted). It's also possible that the `paint` method will get called
> without `shouldRepaint` being called at all (e.g. if the box changes
> size).
>
> If a custom delegate has a particularly expensive paint function such that
> repaints should be avoided as much as possible, a `RepaintBoundary` or
> `RenderRepaintBoundary` […] might be helpful.

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/rendering/custom_paint.dart#L246-L271>

That bolded sentence is why `shouldRepaint => false` is **not** a substitute for `RepaintBoundary` — confirmed by my measurement in §5.2.

And L45–56, the most-missed piece of guidance in the whole class:

> The most efficient way to trigger a repaint is to either:
>
> * Extend this class and supply a `repaint` argument to the constructor of
>   the `CustomPainter`, where that object notifies its listeners when it is
>   time to repaint.
> * Extend `Listenable` (e.g. via `ChangeNotifier`) and implement
>   `CustomPainter`, so that the object itself provides the notifications
>   directly.
>
> In either case, the `CustomPaint` widget or `RenderCustomPaint`
> render object will listen to the `Listenable` and repaint whenever the
> animation ticks, **avoiding both the build and layout phases of the pipeline.**

For a ruler with a draggable cursor this is the correct architecture: drive it from an `Animation`/`ValueNotifier` via `repaint:`, not from `setState`.

### 7.2 The real painter (verified: compiles and all its tests pass)

`lib/ruler.dart`:

```dart
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

class RulerPainter extends CustomPainter {
  RulerPainter({
    required this.pixelsPerMm,
    required this.textDirection,
    required this.tickColor,
    required this.labelStyle,
    super.repaint,                 // <-- drive repaints without build/layout
  });

  final double pixelsPerMm;
  final TextDirection textDirection;
  final Color tickColor;
  final TextStyle labelStyle;

  // Allocated ONCE per painter instance, never inside paint().
  late final Paint _minorTick = Paint()
    ..color = tickColor
    ..strokeWidth = 1.0
    ..isAntiAlias = false;         // hairlines: AA costs and blurs them

  late final Paint _majorTick = Paint()
    ..color = tickColor
    ..strokeWidth = 2.0
    ..isAntiAlias = false;

  // One reusable TextPainter. layout() runs per label, but the object and its
  // paragraph machinery are not reallocated 200 times a frame.
  late final TextPainter _labelPainter =
      TextPainter(textDirection: textDirection, maxLines: 1);

  @override
  void paint(Canvas canvas, Size size) {
    final bool rtl = textDirection == TextDirection.rtl;
    final int totalMm = (size.width / pixelsPerMm).floor();

    for (var mm = 0; mm <= totalMm; mm++) {
      final double raw = mm * pixelsPerMm;
      final double x = rtl ? size.width - raw : raw;   // RTL mirrors the origin

      final bool isCm     = mm % 10 == 0;
      final bool isHalfCm = mm % 5 == 0;
      final double len = isCm ? size.height * 0.5
                       : isHalfCm ? size.height * 0.3
                       : size.height * 0.18;

      canvas.drawLine(Offset(x, 0), Offset(x, len), isCm ? _majorTick : _minorTick);

      if (isCm && mm > 0) {
        _labelPainter
          ..text = TextSpan(text: '${mm ~/ 10}', style: labelStyle)
          ..layout();
        _labelPainter.paint(canvas, Offset(x - _labelPainter.width / 2, len + 2));
      }
    }
  }

  @override
  bool shouldRepaint(RulerPainter old) =>
      old.pixelsPerMm   != pixelsPerMm   ||
      old.textDirection != textDirection ||
      old.tickColor     != tickColor     ||
      old.labelStyle    != labelStyle;

  @override
  SemanticsBuilderCallback get semanticsBuilder => (Size size) => <CustomPainterSemantics>[
    CustomPainterSemantics(
      rect: Offset.zero & size,
      properties: SemanticsProperties(
        label: 'Ruler, ${(size.width / pixelsPerMm / 10).toStringAsFixed(1)} centimetres',
        textDirection: textDirection,
      ),
    ),
  ];

  @override
  bool shouldRebuildSemantics(RulerPainter old) => old.pixelsPerMm != pixelsPerMm;
}
```

Design points and why:

| Decision | Why |
|---|---|
| `super.repaint` | Repaints skip build **and** layout (`custom_paint.dart` L54–56). |
| `late final Paint` fields | `paint()` runs up to 120×/s. Allocating a `Paint` per tick per frame is the #1 `CustomPainter` mistake. `Paint` is a heavyweight object wrapping engine state. |
| One `TextPainter`, reused | `TextPainter` construction sets up a paragraph builder; reuse it and only call `layout()`. |
| `isAntiAlias = false` on hairlines | 1 px vertical lines snapped to the pixel grid need no AA; AA makes them grey and costs fill rate. |
| `shouldRepaint` compares **every** field | Missing one → stale pixels. Returning `true` unconditionally → wasted raster work every frame. |
| `shouldRebuildSemantics` narrower than `shouldRepaint` | It defaults to `shouldRepaint` (`custom_paint.dart` L242–244). Semantics rebuilds are expensive and only the scale changes the label. |
| `semanticsBuilder` | A `CustomPaint` is a black hole to TalkBack/VoiceOver otherwise. §10. |
| RTL handled by mirroring `x` | Do **not** wrap the `CustomPaint` in a `Transform.scale(scaleX: -1)` — it mirrors the digit glyphs too. |

### 7.3 Sizing and clipping

From the `CustomPaint` dartdoc, `basic.dart` L781–786:

> The painters are expected to paint within a rectangle starting at the origin and
> encompassing a region of the given size. (If the painters paint outside
> those bounds, there might be insufficient memory allocated to rasterize the
> painting commands and the resulting behavior is undefined.) To enforce
> painting within those bounds, consider wrapping this `CustomPaint` with a
> `ClipRect` widget.

and L796–798:

> Custom painters normally size themselves to their `child`. If they do not
> have a child, they attempt to size themselves to the specified `size`, which
> defaults to `Size.zero`.

**Gotcha:** a `CustomPaint` with no `child` and no `size` is 0×0 and silently paints nothing. Always pass `size:` or a `child`, or wrap in a `SizedBox`/`LayoutBuilder`.

`custom_paint.dart` L181–184 also recommends `canvas.clipRect` at the top of `paint()` if bounds are input-driven.

### 7.4 `isComplex` / `willChange`

`basic.dart` L858–880:

> **isComplex** — Whether the painting is complex enough to benefit from caching.
> The compositor contains a raster cache that holds bitmaps of layers in
> order to avoid the cost of repeatedly rendering those layers on each
> frame. If this flag is not set, then the compositor will apply its own
> heuristics […]
>
> **willChange** — Whether the raster cache should be told that this painting is likely
> to change in the next frame. This hint tells the compositor not to cache the layer […]

For the ruler: `CustomPaint(isComplex: true, willChange: false, ...)` — hundreds of `drawLine` calls, static content. That is exactly what the raster cache is for. For the cursor overlay: `willChange: true`.

### 7.5 `CustomPaint` vs a nest of widgets

Reiterating `framework.dart` L435–437: prefer one `CustomPaint` over "an intricate layering of multiple `Container`s and with `Decoration`s". For a ruler with ~200 ticks, the widget-tree version would be 200 `Positioned` + 200 `Container` = 400 elements + 400 render objects per frame. The painter version is **one** render object. This is not a micro-optimisation; it is two orders of magnitude.

---

## 8. Testing a `CustomPainter`

**Do not reach for golden files first.** Goldens for a painter are slow, font-dependent, platform-dependent, and tell you *that* something changed, not *what*. Test the display list instead. (The `testing.md` sibling doc owns golden-test infrastructure; this section is the painter-specific technique.)

`flutter_test` exports `mock_canvas.dart` (`packages/flutter_test/lib/flutter_test.dart` L78), which gives you `paints`, `paintsNothing`, `paintsAssertion`, and `paintsExactlyCountTimes`. From `mock_canvas.dart` L24–54:

> Matches objects or functions that paint a display list that matches the
> canvas calls described by the pattern.
>
> Specifically, this can be applied to `RenderObject`s, `Finder`s that
> correspond to a single `RenderObject`, and functions that have either of the
> following signatures:
>
> ```dart
> void exampleOne(PaintingContext context, Offset offset) { }
> void exampleTwo(Canvas canvas) { }
> ```

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_test/lib/src/mock_canvas.dart#L24-L66>

### 8.1 The full, verified test file

All of the following **passes on 3.44.6** (8 passed, 1 skipped):

```dart
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:probe/ruler.dart';

const TextStyle kLabel = TextStyle(fontSize: 10, color: Color(0xFF000000));

RulerPainter makePainter({double ppm = 4.0, TextDirection td = TextDirection.ltr}) =>
    RulerPainter(
      pixelsPerMm: ppm, textDirection: td,
      tickColor: const Color(0xFF112233), labelStyle: kLabel,
    );

Widget host(CustomPainter p, {Size size = const Size(200, 40)}) => Directionality(
  textDirection: TextDirection.ltr,
  child: Center(child: CustomPaint(size: size, painter: p)),
);

void main() {
  // 1. Assert on the display list, via the render object.
  testWidgets('ruler paints the expected primitives', (t) async {
    await t.pumpWidget(host(makePainter(ppm: 10)));
    final RenderCustomPaint rcp = t.renderObject(find.byType(CustomPaint).last);
    expect(rcp, paints
      ..line(p1: const Offset(0, 0), p2: const Offset(0, 20),
             strokeWidth: 2.0, color: const Color(0xFF112233))
      // GOTCHA: `paints..line` compares Offsets with ==. Never hard-code a
      // coordinate you derived with floating point (40 * 0.18 is
      // 7.200000000000001, not 7.2). Assert on p1/strokeWidth instead.
      ..line(p1: const Offset(10, 0), strokeWidth: 1.0));
  });

  // 2. Count primitives -- catches "I accidentally draw twice as many ticks".
  testWidgets('exactly 21 lines for a 200px / 10ppm ruler', (t) async {
    await t.pumpWidget(host(makePainter(ppm: 10)));
    expect(t.renderObject(find.byType(CustomPaint).last),
           paintsExactlyCountTimes(#drawLine, 21));
  });

  // 3. RTL is a painter concern, not a widget concern -- test it here.
  testWidgets('RTL mirrors the ruler', (t) async {
    await t.pumpWidget(host(makePainter(ppm: 10, td: TextDirection.rtl)));
    expect(t.renderObject(find.byType(CustomPaint).last),
           paints..line(p1: const Offset(200, 0), p2: const Offset(200, 20)));
  });

  // 4. shouldRepaint is a pure function. Test it as one. Microseconds.
  test('shouldRepaint false for equal config, true when scale changes', () {
    expect(makePainter(ppm: 4).shouldRepaint(makePainter(ppm: 4)), isFalse);
    expect(makePainter(ppm: 4).shouldRepaint(makePainter(ppm: 5)), isTrue);
  });

  // 5. Prove paint() allocates nothing: run it twice, assert Paint identity.
  testWidgets('paint() reuses its Paint objects across calls', (t) async {
    final painter = makePainter(ppm: 10);
    final a = _capturePaints(painter, const Size(200, 40));
    final b = _capturePaints(painter, const Size(200, 40));
    expect(a.length, greaterThan(1));
    expect(a.length, b.length);
    for (var i = 0; i < a.length; i++) {
      expect(identical(a[i], b[i]), isTrue, reason: 'Paint #$i was reallocated');
    }
  });

  // 6. Semantics from semanticsBuilder.
  testWidgets('painter exposes a semantic label', (t) async {
    final SemanticsHandle handle = t.ensureSemantics();
    await t.pumpWidget(host(makePainter(ppm: 10)));
    // GOTCHA: CustomPainterSemantics produces SemanticsNodes, NOT widgets, so
    // find.bySemanticsLabel() does NOT see them. Walk the semantics tree.
    final labels = <String>[];
    void visit(SemanticsNode n) {
      final SemanticsData d = n.getSemanticsData();
      if (d.label.isNotEmpty) labels.add(d.label);
      n.visitChildren((c) { visit(c); return true; });
    }
    visit(t.binding.pipelineOwner.semanticsOwner!.rootSemanticsNode!);
    expect(labels, contains(startsWith('Ruler,')));
    handle.dispose();
  });
}

/// Minimal fake Canvas that records the Paint instances handed to drawLine.
class _PaintSpy implements Canvas {
  final List<Paint> paints = <Paint>[];
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) => paints.add(paint);
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

List<Paint> _capturePaints(CustomPainter p, Size size) {
  final spy = _PaintSpy();
  p.paint(spy, size);
  return spy.paints;
}
```

### 8.2 Two gotchas I hit, that you will hit

1. **`paints..line(p2: ...)` uses exact `Offset` equality.** My first version failed with:
   `It called drawLine with p2 endpoint, Offset(10.0, 7.2), which was not exactly the expected endpoint (Offset(10.0, 7.2)).`
   because `40 * 0.18 == 7.200000000000001`. Assert on `p1`/`strokeWidth`/`color`, or recompute the expected value with the identical expression.
2. **`find.bySemanticsLabel` does not see `CustomPainterSemantics`.** Those become `SemanticsNode`s directly, bypassing the widget tree. Walk `pipelineOwner.semanticsOwner.rootSemanticsNode`.

### 8.3 Where goldens still earn their keep

Only for the *composite* look — ruler + labels + theme + locale. One golden per locale, of the whole pane, at a fixed `TextScaler`. Not one per painter primitive.

---

## 9. Cold start under 1.2 s on a low-end Android device

### 9.1 Measure it, don't guess

`flutter run --profile --trace-startup` is the tool. Its help text, from the 3.44.6 CLI:

> Trace application startup, then exit, saving the trace to a file. By default, this will be saved in the "build" directory. If the FLUTTER_TEST_OUTPUTS_DIR environment variable is set, the file will be written there instead.

It writes `build/start_up_info.json`. The exact keys, read from `packages/flutter_tools/lib/src/tracing.dart` L116–209:

```json
{
  "engineEnterTimestampMicros":        <t0>,
  "timeToFrameworkInitMicros":         <framework init - t0>,
  "timeToFirstFrameRasterizedMicros":  <first frame RASTERIZED - t0>,
  "timeToFirstFrameMicros":            <first frame BUILT - t0>,
  "timeAfterFrameworkInitMicros":      <first frame built - framework init>
}
```

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_tools/lib/src/tracing.dart#L116-L209>

**`timeToFirstFrameRasterizedMicros` is your 1.2 s budget number** — it is when a pixel actually appears. `timeToFirstFrameMicros` is when the framework *finished building*, which is earlier and flattering. The code comment says so explicitly (L190–193): the built-timestamp is preserved "to keep our old benchmarks valid" and the rasterized one was added "for a more accurate benchmark".

Two more relevant flags, verified present in `flutter run --help` on 3.44.6:
- `--cache-startup-profile` — "Caches the CPU profile collected before the first frame for startup analysis." Feed the result to the DevTools CPU profiler to see *which Dart functions* ate your budget.
- `--endless-trace-buffer` — combine with `--trace-startup` for large traces.
- Note: `--trace-startup` **disables hot reload** (`final bool shouldUseHotMode = hotArg && !traceStartup;`, `commands/run.dart` L250).

Run it against the actual low-end device, in **profile** mode, repeatedly (cold start varies 20 %+ run to run). `perf/ui-performance.md` L77–83:

> Flutter's profile mode compiles and launches your application
> almost identically to release mode, but with just enough additional
> functionality to allow debugging performance problems.

### 9.2 What must NOT happen before the first frame

**The budget rule:** everything between `main()` and the first `Scaffold` being rasterized is on the critical path. Anything you `await` there directly adds to the 1.2 s.

Forbidden in `main()`:
- `await` on opening either drift database.
- `await` on extracting the pre-seeded reference DB asset (§9.4).
- `await rootBundle.loadString` of anything large.
- Reading `SharedPreferences`/`path_provider` *before* `runApp`.
- Constructing the Riverpod container eagerly with `.read` on async providers.
- Any `Firebase`-style init (irrelevant here — the app is offline — but the pattern leaks in from templates).

Allowed in `main()`:
- `WidgetsFlutterBinding.ensureInitialized()`.
- `SystemChrome.setPreferredOrientations` (fire-and-forget, do not `await`).
- Synchronous, allocation-free configuration.

The shape:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));   // first frame ASAP
}
```

Then do the expensive work *after* the first frame, in a Riverpod async provider whose UI shows a real skeleton, not a spinner-on-white.

### 9.3 The `deferFirstFrame` / `allowFirstFrame` escape hatch — and why NOT to use it here

`packages/flutter/lib/src/rendering/binding.dart` L544–576:

> **deferFirstFrame** — Tell the framework to not send the first frames to the engine until there
> is a corresponding call to `allowFirstFrame`.
>
> Call this to perform asynchronous initialization work before the first
> frame is rendered (which takes down the splash screen). The framework
> will still do all the work to produce frames, but those frames are never
> sent to the engine and will not appear on screen.
>
> **allowFirstFrame** — Called after `deferFirstFrame` to tell the framework that it is ok to
> send the first frame to the engine now. For best performance, this method should only be called while the
> `schedulerPhase` is `SchedulerPhase.idle`.

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/rendering/binding.dart#L544-L576>

This holds the *native* splash screen up. It is the right tool when you must not flash a half-built UI. **It is the wrong tool for this app**, because holding the splash for a multi-MB SQLite extraction directly consumes the 1.2 s budget — the user stares at a static image. Prefer: render the real chrome immediately, run extraction behind a determinate progress UI.

### 9.4 The one-time SQLite asset extraction, without jank

Constraints established from primary sources:

- **`rootBundle` does not work in a spawned isolate.** `perf/isolates.md` L315–320: *"you can't access assets using `rootBundle` in spawned isolates, nor can you perform any widget […]"*. The mechanism: `PlatformAssetBundle.load` goes through `ServicesBinding.instance.defaultBinaryMessenger.send('flutter/assets', …)` (`services/asset_bundle.dart`), and there is no `ServicesBinding` in a background isolate.
- Platform *plugins* can work in a background isolate via `BackgroundIsolateBinaryMessenger.ensureInitialized(RootIsolateToken.instance!)` (verified present at `services/_background_isolate_binary_messenger_io.dart` L14, L43). Whether that also revives `rootBundle` is **unverified** — I could not test it without a device. Do not rely on it.
- `compute(fun, msg)` is documented as equivalent to `Isolate.run(() => fun(msg))` on mobile (`perf/isolates.md` L303–308).

**The pattern I recommend:**

```dart
/// Runs AFTER the first frame. Never awaited from main().
Future<void> ensureReferenceDb(Directory dir) async {
  final marker = File(p.join(dir.path, 'ref.v${kRefDbVersion}.ok'));
  if (marker.existsSync()) return;                     // hot path: one stat()

  // 1. rootBundle MUST run on the root isolate.
  final ByteData bytes = await rootBundle.load('assets/db/reference.sqlite');

  // 2. The write is dart:io async -> it runs on the IO thread pool, NOT on the
  //    Dart UI isolate. It does not block frames. Do NOT use writeAsBytesSync.
  final target = File(p.join(dir.path, 'reference.sqlite'));
  await target.writeAsBytes(
    bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    flush: true,
  );

  await marker.writeAsString(DateTime.now().toIso8601String());
}
```

Rules:
- **`await`, never `*Sync`.** `writeAsBytesSync` blocks the UI isolate for the full write. `writeAsBytes` does not.
- **Version the marker file**, not just "exists" — you will ship a new reference DB.
- **Do not** `rootBundle.load` a 50 MB asset in one shot; that is 50 MB resident on the UI isolate heap plus a platform-channel copy. If the DB is large, ship it split into chunks (`reference.000`, `reference.001`, …) and append them, so peak memory is one chunk.
- **Do not compress the asset yourself and decompress at runtime** unless you measure it wins. Android already stores APK assets compressed; you would be paying double.
- Drive the whole thing from a Riverpod `FutureProvider` and render a real determinate progress bar. Zero-network app → this is the *only* slow path the user ever sees; make it look deliberate.

### 9.5 Assets and images on the critical path

- **`precacheImage`** — `Future<void> precacheImage(ImageProvider provider, BuildContext context, {Size? size, ImageErrorListener? onError})`, `widgets/image.dart` L121–126. It resolves the image into the `ImageCache` so the first paint does not decode. Call it from `didChangeDependencies`, not `initState` (it needs an inherited-widget-bearing context). Its dartdoc (L105–109) warns:
  > Callers should be cautious about pinning large images or a large number of
  > images in memory, as this can result in running out of memory and being
  > killed by the operating system. […] These issues
  > manifest as immediate process death, sometimes with no other error messages.

  Precache **only** what is on the first screen. On a low-end device this is a real OOM risk.
- **Precompile your SVGs.** See §11.3. Parsing SVG XML at runtime, on the UI isolate, during the first frame, is exactly the kind of thing that eats 200 ms.
- **`AssetManifest.loadFromAssetBundle(rootBundle)`** (`services/asset_manifest.dart` L24–27) is the supported API for enumerating assets. Do not hand-parse `AssetManifest.json`; that is a pre-Flutter-3.7 pattern and the underlying format is now binary.

### 9.6 Shader compilation jank is dead — do not implement the old workaround

`perf/rendering-performance.md`:

> **Jank on First Animation Run:**
> If you notice jank only on the first run of an animation, ensure you're using **Impeller** (Flutter's default graphic renderer).

The dedicated page is **gone**: `firebase.json` in the website repo has
`{ "source": "/perf/shader", "destination": "/perf/rendering-performance", "type": 301 }`.

And I verified the tooling is gone too: `--bundle-sksl-path` and `--cache-sksl` **do not appear** in `flutter run --help` or `flutter build --help` on 3.44.6. Grepping `packages/flutter_tools/lib` for `sksl` finds only one vestigial `'cacheSkSL': false` in `device.dart` L1327.

**If you find a guide telling you to capture SkSL warm-up files, it predates Flutter 3.27 and is dead code.** Do not do it.

---

## 10. Impeller — what actually applies to this app

Verbatim from `sites/docs/src/content/perf/impeller.md` L6–11 and L55–65:

> As of the 3.27 release, Impeller is the default
> rendering engine for both iOS and Android API 29+.
>
> ### iOS
> Impeller is the **only supported** rendering engine on iOS with
> no ability to switch to Skia.
>
> ### Android
> Impeller is **available and enabled by default on Android API 29+**.
> On devices running lower versions of Android or don't support Vulkan,
> Impeller falls back to the legacy OpenGL renderer.
> No action on your part is necessary for this fallback behavior.

Source: <https://docs.flutter.dev/perf/impeller>

⚠️ **Warning about this page:** when I fetched the rendered `docs.flutter.dev/perf/impeller` through a summarising fetcher, it produced a plausible-looking "Version History" table containing `| 3.44 | Latest stable version (current) |`. **That table does not exist in the source.** It was hallucinated. I only caught it by diffing against `sites/docs/src/content/perf/impeller.md`. This is a concrete reason to read source markdown, not summaries.

**What it means for a low-end-Android target:**

- Your low-end test device is very likely **below API 29 or without Vulkan**, so it runs the **OpenGL ES fallback**, not Vulkan. Your perf numbers on a modern phone will not transfer. Profile on the actual target.
- `flutter run --no-enable-impeller` on Android lets you A/B the renderer when a fidelity/perf bug looks renderer-specific.
- To disable in production (only if you hit a hard Impeller bug), `AndroidManifest.xml` under `<application>`:
  ```xml
  <meta-data
      android:name="io.flutter.embedding.android.EnableImpeller"
      android:value="false" />
  ```
- The general `saveLayer`/opacity/clip advice in `best-practices.md` is written for the Skia era but the *reasons* still hold on Impeller: `saveLayer` allocates an offscreen buffer and forces a render-target switch. `best-practices.md` L132–139:
  > Calling `saveLayer()` allocates an offscreen buffer
  > and drawing content into the offscreen buffer might
  > trigger a render target switch.
  > The GPU wants to run like a firehose,
  > and a render target switch forces the GPU
  > to redirect that stream temporarily and then
  > direct it back again. On mobile GPUs this is
  > particularly disruptive to rendering throughput.

  Widgets that may trigger it (L200–205): `ShaderMask`, `ColorFilter`, `Chip` when `disabledColorAlpha != 0xff`, `Text` with an `overflowShader`.

---

## 11. App size

### 11.1 `--analyze-size` — and two gotchas the docs omit

The docs page (`perf/app-size.md` L124–132) lists the commands. What it does **not** say, but the 3.44.6 CLI help does:

> `--[no-]analyze-size`   Whether to produce additional profile information for artifact output size. **This flag is only supported on "--release" builds. When building for Android, a single ABI must be specified at a time with the "--target-platform" flag.** When building for iOS, only the symbols from the arm64 architecture are used to analyze code size.
> **This flag cannot be combined with "--split-debug-info".**

> `--split-debug-info=<dir>`  … **This flag cannot be combined with "--analyze-size".**

So the two commands you actually run are *different builds*:

```bash
# (a) Measure the breakdown. Single ABI, release, no split-debug-info.
flutter build apk --release --analyze-size --target-platform android-arm64

# (b) Ship it. split-debug-info (+ obfuscate) for the real size win.
flutter build appbundle --release \
  --obfuscate --split-debug-info=build/symbols
```

`--analyze-size` emits a terminal summary plus a `*-code-size-analysis_*.json`. Load it in DevTools (`dart devtools` → **Open app size tool**) for a treemap down to function level, and **diff two JSONs** to see what a dependency cost you (`perf/app-size.md` L142–144).

`--obfuscate` "must always be combined with `--split-debug-info`", and note the warning in the CLI help: *"methods like `Object.runtimeType`, `Type.toString`, `Enum.toString`, `Stacktrace.toString`, `Symbol.toString` … will return obfuscated results."* If your rule-engine domain package switches on `Enum.toString()` or persists `runtimeType`, obfuscation will silently break it. Persist explicit string codes instead.

Also relevant, `flutter/flutter` style guide L995:
> Avoid using `$runtimeType`, since it adds a non-trivial cost even in release and profile mode.

### 11.2 Deferred components — **do not use them in this app**

`perf/deferred-components.md` L10–29:

> With Flutter, **Android and web** apps have the capability to download deferred
> components […]
>
> When building for Android, though you can defer loading modules,
> you must build the entire app and upload that app as a single
> [Android App Bundle][] (AAB).
> Flutter doesn't support dispatching partial updates without re-uploading
> new Android App Bundles for the entire application.

Source: <https://docs.flutter.dev/perf/deferred-components>

**Reasons to skip:** (1) **iOS is not supported at all** — you would maintain two code paths. (2) It requires the Play Core library and `FlutterPlayStoreSplitApplication`, i.e. a *network* dependency on the Play Store, in an app whose entire premise is "100 % offline, no network code". (3) Debug mode treats deferred imports as regular imports, so you cannot test it locally without a release build.

### 11.3 SVG vs raster — precompile, always

Verified package status (pub.dev API, 2026-07-27) — all three are **actively maintained inside `flutter/packages`**, which is the Flutter team's own monorepo:

| Package | Latest | Published | Home |
|---|---|---|---|
| `flutter_svg` | 2.3.0 | 2026-05-08 | `flutter/packages/third_party/packages/flutter_svg` |
| `vector_graphics` | 1.2.2 | 2026-05-18 | `flutter/packages/packages/vector_graphics` |
| `vector_graphics_compiler` | 1.2.6 | 2026-06-17 | `flutter/packages/packages/vector_graphics_compiler` |

None are abandoned; none have gone commercial.

**Do this** — build-time transformation, which is the officially documented mechanism (`ui/assets/asset-transformation.md`):

```yaml
# pubspec.yaml
flutter:
  assets:
    - path: assets/icons/caliper.svg
      transformers:
        - package: vector_graphics_compiler
```

```dart
import 'package:vector_graphics/vector_graphics.dart';

const Widget caliper = VectorGraphic(loader: AssetBytesLoader('assets/icons/caliper.svg'));
```

Note the asset key stays `.svg` — the transformer replaces the bytes in place. And `const` works, which matters (§2).

Why, from the `flutter_svg` README:

> The vector_graphics backend supports SVG compilation which produces a binary
> format that is faster to parse and can optimize SVGs to reduce the amount of
> clipping, masking, and overdraw.

Source: <https://github.com/flutter/packages/blob/main/third_party/packages/flutter_svg/README.md#precompiling-and-optimizing-svgs>

Validate an SVG is compatible before shipping:
```bash
dart run vector_graphics_compiler -i icon.svg -o /tmp/out.vec \
  --no-optimize-masks --no-optimize-clips --no-optimize-overdraw --no-tessellate
```

**SVG vs raster, my call:** SVG (precompiled) for icons and line art — one asset, all densities, tiny, and RTL-flippable via a `Transform` without resampling artefacts. Raster (WebP) for photographic content only. Never ship `@2x`/`@3x` PNG icon sets in a six-locale app; the size adds up and you get worse results.

### 11.4 Other size levers, all verified in the 3.44.6 CLI

- `--tree-shake-icons` (default **on**): "Tree shake icon fonts so that only glyphs used by the application remain." Verified at `runner/flutter_command.dart` L977 and `build_system/targets/icon_tree_shaker.dart`. It breaks if you construct `IconData` dynamically — don't.
- `--split-per-abi` for APKs. Irrelevant if you ship an AAB (Play splits for you).
- Platform-conditional dead-code elimination, `perf/app-size.md` L188–193:
  > The Dart compiler removes code that is unreachable on the target platform.
  > For example, if you have code that is specific to Windows, you can wrap it in a
  > check using the `Platform` class from `dart:io`, like `if (Platform.isWindows)`.
- Remember: **an upload AAB/IPA is not the download size**. Use Play Console → Android vitals → App size, and Xcode's `App Thinning Size Report.txt` (`perf/app-size.md` L40–109).

---

## 12. Accessibility as a code concern

Six locales including RTL, a custom-painted ruler, and a PDF export flow means a11y is not a checkbox — it is a correctness property. Treat the `flutter_test` guideline matchers as **unit tests that fail the build**.

### 12.1 The matchers, verbatim

From `packages/flutter_test/lib/src/matchers.dart` L1273–1296:

```
/// Asserts that the currently rendered widget meets the provided accessibility
/// `guideline`.
///
/// This matcher requires the result to be awaited and for semantics to be
/// enabled first.
///
/// ## Sample code
///
/// ```dart
/// testWidgets('isSemantics', (WidgetTester tester) async {
///   final SemanticsHandle handle = tester.ensureSemantics();
///   // ...
///   await expectLater(tester, meetsGuideline(textContrastGuideline));
///   handle.dispose();
/// });
/// ```
///
/// Supported accessibility guidelines:
///
///   * [androidTapTargetGuideline], for Android minimum tappable area guidelines.
///   * [iOSTapTargetGuideline], for iOS minimum tappable area guidelines.
///   * [textContrastGuideline], for WCAG minimum text contrast guidelines.
///   * [labeledTapTargetGuideline], for enforcing labels on tappable areas.
AsyncMatcher meetsGuideline(AccessibilityGuideline guideline) {
```

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_test/lib/src/matchers.dart#L1273-L1296>

The concrete thresholds, from `packages/flutter_test/lib/src/accessibility.dart`:

| Guideline | Threshold | Source line |
|---|---|---|
| `androidTapTargetGuideline` | 48 × 48 logical px | L785–788 |
| `iOSTapTargetGuideline` | 44 × 44 logical px | L800–804 |
| `textContrastGuideline` | WCAG **AA**: 4.5:1 normal, 3.0:1 large (≥18 pt, or ≥14 pt bold) | L292–308 |
| `MinimumTextContrastGuidelineAAA` | WCAG AAA | L525 |
| `CustomMinimumContrastGuideline({minimumRatio, tolerance})` | your own | L559–583 |
| `labeledTapTargetGuideline` | every node with tap/long-press has a label | L820–825 |

Source: <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_test/lib/src/accessibility.dart#L775-L826>

Note `textContrastGuideline`'s own dartdoc admits it is approximate (L808–814): *"it performs a very naive partitioning of the colors into 'light' and 'dark' and then chooses the most frequently occurring color in each partition"*. It catches real regressions but do not treat a pass as a design audit.

### 12.2 A verified, runnable a11y test

**Passes on 3.44.6** (from my `test/ruler_test.dart`):

```dart
testWidgets('meets the Android tap-target and text-contrast guidelines', (t) async {
  final SemanticsHandle handle = t.ensureSemantics();     // REQUIRED
  await t.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFFFFFFFF),
        alignment: Alignment.center,
        child: Semantics(
          container: true, button: true, label: 'Measure',
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 48, height: 48,                       // >= androidTapTarget
              color: const Color(0xFFFFFFFF),
              alignment: Alignment.center,
              child: const Text('Go',
                  style: TextStyle(color: Color(0xFF000000), fontSize: 14)),
            ),
          ),
        ),
      ),
    ),
  );
  await expectLater(t, meetsGuideline(androidTapTargetGuideline));
  await expectLater(t, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(t, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(t, meetsGuideline(textContrastGuideline));
  handle.dispose();
});
```

Three things that trip people up:
- **`tester.ensureSemantics()` is mandatory.** Without it the semantics tree does not exist and the matcher silently evaluates nothing meaningful. Always `handle.dispose()`.
- **`await expectLater`**, not `expect` — these are `AsyncMatcher`s. `textContrastGuideline` actually rasterises the scene (`layer.toImage(...)`, `accessibility.dart` L317–333), so it is slow. Budget for it.
- Run these **per locale**. Arabic strings are longer and can shrink a tap target below 48 dp inside a `Row`. That is precisely the bug this catches.

### 12.3 The four widgets you actually need

| Widget | Use it when | Why |
|---|---|---|
| `Semantics(label: …)` | Annotating something with no intrinsic text — an icon button, the ruler pane. | Screen readers read `label`. Prefer the widget's own `semanticLabel:` parameter (`Image`, `Icon`, `IconButton`) when it exists — fewer nodes. |
| `MergeSemantics` | A row of `Icon` + `Text` + `Text` that is conceptually **one** thing. | Without it, TalkBack stops on three separate nodes and the user swipes three times per row. Merging is also *cheaper* — fewer `SemanticsNode`s to build and ship over the platform channel. |
| `ExcludeSemantics` | Purely decorative graphics — the ruler's hairline grid, a background flourish. | A `CustomPaint` with hundreds of primitives should expose **one** node (via `semanticsBuilder`), not zero and not many. |
| `CustomPainterSemantics` via `semanticsBuilder` | Inside a painter. §7.2. | The only way to give painted content meaning. Pair with `shouldRebuildSemantics` narrower than `shouldRepaint` (`custom_paint.dart` L242–244). |

```dart
// One node per reference row, not four.
MergeSemantics(
  child: Row(children: [
    const ExcludeSemantics(child: Icon(Icons.straighten)),   // decorative
    Expanded(child: Text(row.name)),
    Text(row.formattedValue),
  ]),
)
```

### 12.4 RTL is a code concern, not a translation concern

- Never write `EdgeInsets.only(left: 16)`. Write `EdgeInsetsDirectional.only(start: 16)`. Same for `Alignment` → `AlignmentDirectional`, `BorderRadius` → `BorderRadiusDirectional`, `Positioned` → `PositionedDirectional`.
- In a `CustomPainter`, take `TextDirection` as a **constructor field** (as `RulerPainter` does) and include it in `shouldRepaint`. A painter has no `BuildContext`, so it cannot ask.
- Test it: my `RTL mirrors the ruler` test in §8.1 is the pattern — assert the *painted geometry*, not a screenshot.

---

## 13. DevTools workflow — the five switches that matter

All from `sites/docs/src/content/tools/devtools/performance.md`.

1. **Frames chart / jank threshold.** L111–118: *"A frame is considered to be janky if it takes more than ~16 ms to complete (for 60 FPS devices)."* Red overlay = janky frame.
2. **Frame analysis tab.** L134–140: select a red frame and DevTools *tells you* what it detected — *"These hints help you diagnose jank in your app, and notify you of any expensive operations that we have detected that might have contributed to the slow frame time."* Start here, not in the flame chart.
3. **Enhance tracing → Track Widget Builds / Track Layouts / Track Paints.** L180–206. `Track Layouts` is how you find intrinsic passes (`best-practices.md` L320–326: events are labelled `'$runtimeType intrinsics'`). Note L170–172: *"Frame times might be negatively affected when these options are enabled."*
4. **More debugging options → Render Clip layers / Render Opacity layers / Render Physical Shape layers.** L223–241. Toggling a layer type **off** and re-measuring is the fastest A/B for "is clipping/opacity/elevation my problem?" — *"If raster time has significantly decreased, excessive use of the effects you disabled might be contributing to the jank you saw in your app."*
5. **`checkerboardOffscreenLayers`** for `saveLayer` hunting (`best-practices.md` L152–156).

Code-side equivalents you can toggle from Dart in debug builds (`rendering/debug.dart`, `widgets/debug.dart`):

| Flag | File:line | What it shows |
|---|---|---|
| `debugRepaintRainbowEnabled` | `rendering/debug.dart:67` | Layer borders cycle colour on repaint. **The fastest way to find a missing `RepaintBoundary`.** |
| `debugProfilePaintsEnabled` | `rendering/debug.dart:172` | Paint events in the DevTools timeline. |
| `debugProfileLayoutsEnabled` | `rendering/debug.dart:143` | Layout events (intrinsics). |
| `debugProfileBuildsEnabled` / `…UserWidgets` | `widgets/debug.dart:135,151` | Build events; the `UserWidgets` variant excludes framework widgets — use it. |
| `debugPrintRebuildDirtyWidgets` | `widgets/debug.dart:52` | Console log of every dirty widget built. Overwhelming; use for a targeted 3-second window. |
| `debugPrintScheduleBuildForStacks` | `widgets/debug.dart:101` | **Stack traces of what marked a widget dirty.** This is how you find the rogue `setState`. |
| `debugDisableClipLayers` / `…OpacityLayers` / `…PhysicalShapeLayers` | `rendering/debug.dart:245,256,270` | The Dart-side equivalent of DevTools' toggles. |

**Always profile in `--profile` mode.** `perf/rendering-performance.md`: *"Always profile performance with an app built in profile mode"* — debug mode is meaningless (asserts on, JIT, no AOT).

**Frame budget.** `best-practices.md` L353–362:
> Since there are two separate threads for building
> and rendering, you have 16ms for building,
> and 16ms for rendering on a 60Hz display.
> If latency is a concern,
> build and display a frame in 16ms _or less_.
> Note that means built in 8ms or less,
> and rendered in 8ms or less,
> for a total of 16ms or less.

For a low-end target, aim at **8 ms UI / 8 ms raster** and treat 16 ms as the failure line, per L371–377 (battery, thermals, and 120 Hz headroom).

---

## 14. Anti-patterns, with the fix for each

| # | Anti-pattern | Why it's bad | Fix |
|---|---|---|---|
| 1 | `Widget _buildHeader() => …` returning a non-const tree | No `Element`, so no const short-circuit and — worse — any `Theme.of`/`MediaQuery.of`/`AppLocalizations.of` inside it registers **the parent** as the dependent. **[MEASURED]**: host rebuilt on every inherited change vs. not rebuilding at all. | Extract to a private `StatelessWidget` in the same file. §1. |
| 2 | Omitting `const` at call sites because "flutter_lints will tell me" | It won't. `flutter_lints` 6.0.0 has `prefer_const_constructors_in_immutables` only. | Explicitly enable `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `prefer_const_declarations`, and set them to `error`. §2.2. |
| 3 | `ListView(children: List.generate(n, …))` for a big `n` | **[MEASURED]** 66 ms vs 9 ms first pump at n=10 000 — all of it allocating widget objects on the UI thread inside frame 1. | `ListView.builder`. §6. |
| 4 | `ListView.builder` with variable row heights and a `jumpTo` / restored scroll offset | **[MEASURED]** 10 000 builds vs 22 on a jump to the end. A multi-second freeze. | `itemExtent:` for fixed heights, `prototypeItem:` when the height is uniform but locale/text-scale dependent. §6.3. |
| 5 | `shrinkWrap: true` | Forces layout of every child to size the sliver. | `CustomScrollView` + slivers. Never nest scrollables. |
| 6 | Allocating `Paint`, `TextPainter`, `Path`, or `TextStyle` inside `paint()` | `paint()` runs up to 120×/s; each allocation is GC pressure on a small-heap device. | `late final` fields on the painter. Verified by an identity test. §7.2, §8.1(5). |
| 7 | `shouldRepaint(...) => true` | Repaints every frame regardless. | Compare every field that affects drawing. |
| 8 | `shouldRepaint(...) => false` used *as* a repaint optimisation | It doesn't stop layer-level repaints. **[MEASURED]**: static painter still painted 6× when a sibling moved. | Add a `RepaintBoundary`. `shouldRepaint` and `RepaintBoundary` solve different problems. §5. |
| 9 | `RepaintBoundary` sprinkled everywhere | Each one is a `Layer` + an offscreen texture (≈10 MB full-screen at 1080×2400). Layer explosion is a top jank cause on low-end Android. | Only around expensive + static + has-an-animating-neighbour subtrees. Never per list row (`ListView` already adds them). §5.3. |
| 10 | `GlobalKey` created inside `build()` | **[MEASURED]** `[initState G, initState G, deactivate G, dispose G]` — the entire subtree is destroyed and rebuilt every frame; gestures cannot be tracked. | Own it in `State`, create in the field initialiser. §3.4. |
| 11 | `GlobalKey` used where a `ValueKey` would do | Reparenting calls `deactivate` on the whole subtree and forces all `InheritedWidget` dependents to rebuild (framework dartdoc), plus a permanent registry entry. | `ValueKey(row.id)`. §3.3. |
| 12 | No keys on a reorderable list of stateful rows | **[MEASURED]** State stays with the *slot*; the data slides past it. Silent data-display corruption. | `key: ValueKey(<drift primary key>)`. §3.2. |
| 13 | `ObjectKey` on drift rows | Uses `identical()`. A re-query returns a new object → key mismatch → state destroyed. | `ValueKey(row.id)`. |
| 14 | `AnimatedBuilder`/`ValueListenableBuilder`/`Consumer` with the whole subtree inside `builder:` | Every tick rebuilds widgets that do not depend on the animation. | Pass the static part as `child:` and reuse it. §4.2(3). |
| 15 | `Opacity` widget in an animation | Documented as expensive; may force `saveLayer`. | `AnimatedOpacity`, `FadeInImage`, or a semi-transparent colour drawn directly. `best-practices.md` L402–406. |
| 16 | `ClipRRect` for rounded corners | Clipping is costly even without `saveLayer`. | `borderRadius` on the decoration/widget. `best-practices.md` L242–245. |
| 17 | Overriding `operator ==` on a `Widget` | Documented O(N²); **and the analyzer rejects it** — `invalid_override_of_non_virtual_member` since 2020. | Cache the widget or make it `const`. Promote that diagnostic to `error`. §4.3. |
| 18 | `await`ing DB open / asset extraction in `main()` before `runApp` | Directly added to `timeToFirstFrameRasterizedMicros`. | `runApp` immediately; do the work after the first frame behind a Riverpod async provider with a real progress UI. §9.2. |
| 19 | `File.writeAsBytesSync` for the DB extraction | Blocks the UI isolate for the whole multi-MB write. | `await file.writeAsBytes(..., flush: true)` — dart:io async I/O runs off the UI isolate. §9.4. |
| 20 | Calling `rootBundle` inside `Isolate.run` / `compute` | Documented as unsupported — `rootBundle` goes through `ServicesBinding.defaultBinaryMessenger`, which does not exist there. | Load on the root isolate, pass bytes to the isolate. §9.4. |
| 21 | `precacheImage` on everything at startup | Documented OOM risk: *"immediate process death, sometimes with no other error messages."* | Precache only first-screen images. §9.5. |
| 22 | Runtime SVG parsing of many icons on the first screen | XML parse on the UI isolate during frame 1. | `vector_graphics_compiler` as a pubspec `transformers:` entry; load with `VectorGraphic(loader: AssetBytesLoader(...))`, which is `const`-able. §11.3. |
| 23 | Implementing SkSL shader warm-up | Dead since Impeller. The flags no longer exist in the 3.44.6 CLI and the doc page is a 301 redirect. | Delete it. §9.6. |
| 24 | Deferred components in this app | Android-only (no iOS), requires Play Core + a network round-trip, in a 100 %-offline app. | Don't. Cut size with `--split-debug-info`, `--obfuscate`, tree-shaken icons, precompiled SVG. §11.2. |
| 25 | `--analyze-size` combined with `--split-debug-info` | The CLI rejects it outright. | Two separate builds. §11.1. |
| 26 | `--obfuscate` with code that switches on `Enum.toString()` / `runtimeType` | Obfuscation renames them; behaviour silently changes. | Persist explicit string codes. §11.1. |
| 27 | `EdgeInsets.only(left:)`, `Alignment.centerLeft`, `Positioned(left:)` | Break in Arabic. | `EdgeInsetsDirectional`, `AlignmentDirectional`, `PositionedDirectional`. §12.4. |
| 28 | `Icon` + two `Text`s in a row with no `MergeSemantics` | TalkBack stops three times per row; also three `SemanticsNode`s to build and marshal. | `MergeSemantics` + `ExcludeSemantics` on decoration. §12.3. |
| 29 | A `CustomPaint` with no `semanticsBuilder` | Invisible to assistive tech. | Supply `semanticsBuilder`; keep `shouldRebuildSemantics` narrower than `shouldRepaint`. §7.2. |
| 30 | Profiling in debug mode | Meaningless: asserts on, JIT, no AOT. | `flutter run --profile`, on the actual low-end device. §13. |
| 31 | Intrinsic-sizing widgets (`IntrinsicHeight`, `IntrinsicWidth`) inside lists/grids | Two layout passes over **all** cells, including off-screen ones. | Fixed sizes, or an anchor cell, or a custom `RenderObject`. `best-practices.md` L328–338. |
| 32 | Golden-testing a painter primitive-by-primitive | Slow, font/platform-fragile, tells you *that* not *what*. | `paints..line(...)` / `paintsExactlyCountTimes(#drawLine, n)` on the display list. Goldens only for the composite look, one per locale. §8. |

---

## 15. Advice that is STALE or SUPERSEDED — flag these in review

| Stale advice | Status on Flutter 3.44.6 | Evidence |
|---|---|---|
| "Capture SkSL with `--cache-sksl` / ship `--bundle-sksl-path` to fix first-run animation jank" | **Dead.** Flags absent from `flutter run --help`; only a vestigial `'cacheSkSL': false` remains in `flutter_tools/lib/src/device.dart:1327`. The docs page `/perf/shader` is a 301 to `/perf/rendering-performance`. | Verified via CLI + `firebase.json` redirects. |
| "Enable Impeller with `--enable-impeller` on iOS/Android" | Superseded. Default since **3.27**; on iOS there is **no** way to use Skia. Only `--no-enable-impeller` (Android, debugging) and `--enable-impeller` (macOS) remain meaningful. | `perf/impeller.md` L6–11, L55–68, L89–100. |
| "Avoid overriding `operator ==` on Widget" (as a *style* tip) | Superseded by enforcement: `@nonVirtual` since PR #46900, 2020-01-06. The analyzer emits `invalid_override_of_non_virtual_member`. The docs page still phrases it as advice. | `framework.dart` L364–370; verified by running `dart analyze`. |
| "`flutter_lints` reminds you to use `const`" (`best-practices.md` L79–81) | **Misleading.** It enables `prefer_const_constructors_in_immutables` only, and its base `package:lints/recommended.yaml` enables `unnecessary_const` (which *removes* const) but not `prefer_const_constructors`. | `flutter/packages/packages/flutter_lints/lib/flutter.yaml`, verified 2026-07-27. |
| "Read `/ui/widgets-intro` for composition guidance" | The page no longer exists; 301 → `/ui`. Composition guidance now lives in `/resources/architectural-overview#composition`. | `firebase.json` in `flutter/website`. |
| "Parse `AssetManifest.json` with `json.decode`" | Superseded by `AssetManifest.loadFromAssetBundle(rootBundle)` (Flutter 3.7+). The on-disk format is now binary. | `services/asset_manifest.dart` L24–27. |
| "Use `RaisedButton`/`FlatButton`; use `Colors.x.withOpacity()`" | Long removed / deprecated (`withValues(alpha:)` replaced `withOpacity`). Any guide using them predates Flutter 3.22 and should be distrusted wholesale. | Not in the 3.44.6 API surface. |
| "Wrap every list item in a `RepaintBoundary`" | Redundant: `ListView`/`SliverChildDelegate` set `addRepaintBoundaries = true` by default. | `scroll_view.dart` L1322, L1405. |
| Any pre-Dart-3 advice using `dynamic` dispatch / manual `is` chains for view-state | Superseded by sealed classes + exhaustive `switch` patterns (Dart 3.0+). Model your ruler/measurement view state as a sealed hierarchy and let the compiler prove exhaustiveness. | Dart 3 language. |

---

## 16. The short version — 12 rules to enforce in code review

1. Every reusable piece of UI is a `StatelessWidget`/`StatefulWidget` subclass. Private classes in the same file are fine. Zero widget-returning helper methods.
2. `prefer_const_constructors` + `prefer_const_literals_to_create_immutables` are **errors**, not warnings.
3. `ListView.builder` + (`itemExtent` | `prototypeItem`) for anything over ~15 rows. Never `shrinkWrap`.
4. `ValueKey(<drift primary key>)` on every row of a mutable list. Never `ObjectKey`.
5. `GlobalKey` only for `FormState` and PDF-capture `RepaintBoundary`; owned by `State`, created outside `build`.
6. Exactly one `RepaintBoundary` around the ruler face. Justify every other one in the PR description.
7. `CustomPainter`: `late final` Paints/TextPainters, full-field `shouldRepaint`, `semanticsBuilder`, `TextDirection` as a constructor field, driven by `repaint:` not `setState`.
8. Painter tests assert on the display list (`paints`, `paintsExactlyCountTimes`), not on goldens.
9. `main()` is three lines. Nothing async before `runApp`.
10. DB extraction: after first frame, `await` (never `Sync`), version-marker guarded, `rootBundle` on the root isolate only.
11. Every screen has an a11y test with all four `meetsGuideline` matchers, run per locale.
12. Perf numbers only from `--profile` on the real low-end device; cold start measured by `timeToFirstFrameRasterizedMicros` from `build/start_up_info.json`.

---

## 17. Source index — everything cited, verified reachable 2026-07-27

**Framework source (permalinks pinned to tag `3.44.6` = `ee80f08bbf97172ec030b8751ceab557177a34a6`):**

- `widgets/framework.dart` — Keys, `Widget.key`, `canUpdate`, `@nonVirtual ==`, `StatelessWidget`/`StatefulWidget` performance dartdoc, `prefer_const_over_helper` template, `Element.updateChild`
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/framework.dart>
- `widgets/basic.dart` — `CustomPaint`, `isComplex`/`willChange`, `RepaintBoundary`
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/basic.dart>
- `widgets/scroll_view.dart` — `ListView` constructors, `itemExtent`/`prototypeItem`, child-elements lifecycle, `CustomScrollView` mapping
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/scroll_view.dart>
- `widgets/transitions.dart` — `ListenableBuilder`/`AnimatedBuilder` `child:` optimisation template
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/transitions.dart>
- `widgets/image.dart` — `precacheImage`
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/image.dart#L121>
- `widgets/debug.dart`, `rendering/debug.dart` — debug flags
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/widgets/debug.dart> ·
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/rendering/debug.dart>
- `rendering/custom_paint.dart` — `CustomPainter`, `shouldRepaint`, `shouldRebuildSemantics`, `CustomPainterSemantics`
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/rendering/custom_paint.dart>
- `rendering/binding.dart` — `deferFirstFrame` / `allowFirstFrame`
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter/lib/src/rendering/binding.dart#L544-L576>
- `services/asset_bundle.dart`, `services/asset_manifest.dart`, `services/_background_isolate_binary_messenger_io.dart`
- `flutter_test/lib/src/accessibility.dart` — the four guideline constants and thresholds
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_test/lib/src/accessibility.dart>
- `flutter_test/lib/src/matchers.dart` — `meetsGuideline`
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_test/lib/src/matchers.dart#L1273-L1296>
- `flutter_test/lib/src/mock_canvas.dart` — `paints`, `paintsNothing`, `paintsExactlyCountTimes`
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_test/lib/src/mock_canvas.dart>
- `flutter_tools/lib/src/tracing.dart` — `start_up_info.json` keys
  <https://github.com/flutter/flutter/blob/3.44.6/packages/flutter_tools/lib/src/tracing.dart#L116-L209>
- `flutter_tools/lib/src/commands/run.dart` — `--trace-startup` help text and hot-mode interaction

**Official docs (read as source markdown from `flutter/website`, `sites/docs/src/content/…`):**

- <https://docs.flutter.dev/perf/best-practices>
- <https://docs.flutter.dev/perf/rendering-performance>
- <https://docs.flutter.dev/perf/ui-performance>
- <https://docs.flutter.dev/perf/impeller>
- <https://docs.flutter.dev/perf/app-size>
- <https://docs.flutter.dev/perf/deferred-components>
- <https://docs.flutter.dev/perf/isolates>
- <https://docs.flutter.dev/tools/devtools/performance>
- <https://docs.flutter.dev/tools/devtools/cpu-profiler>
- <https://docs.flutter.dev/tools/devtools/app-size>
- <https://docs.flutter.dev/resources/architectural-overview#composition>
- <https://docs.flutter.dev/ui/assets/asset-transformation>
- <https://docs.flutter.dev/ui/accessibility/accessibility-testing>
- Website redirect table (proves `/ui/widgets-intro` and `/perf/shader` are gone):
  <https://github.com/flutter/website/blob/main/firebase.json>

**Official video (Flutter YouTube channel, referenced by both the docs and the framework dartdoc):**

- "Widgets vs helper methods" — <https://www.youtube.com/watch?v=IOyq-eTRhvo>
  *(cited in `perf/best-practices.md` L105 and `framework.dart` L468/L691; content not independently verified — I could not watch it.)*

**Packages (pub.dev API, 2026-07-27):**

- `flutter_lints` 6.0.0, published 2025-05-27 — rule list read from `flutter/packages/packages/flutter_lints/lib/flutter.yaml`
- `lints` 6.1.0, published 2026-01-30
- `flutter_svg` 2.3.0 (2026-05-08), `vector_graphics` 1.2.2 (2026-05-18), `vector_graphics_compiler` 1.2.6 (2026-06-17) — all in `flutter/packages`, all actively maintained
- `flutter_riverpod` / `riverpod` / `hooks_riverpod` 3.4.1, published 2026-07-26 (context only; owned by the state-management lane)

**Explicitly NOT used:** Medium, dev.to, SEO listicles, Stack Overflow, Reddit.

### Unverified / open items

- The content of the "Widgets vs helper methods" video (link verified in two primary sources; video not watched).
- Whether `ui.ImmutableBuffer.fromAsset` (the non-platform-channel asset path used by `PlatformAssetBundle.loadBuffer`) works inside a spawned isolate. The isolates doc says `dart:ui` methods are unavailable there; I could not test without a device. **Do not rely on it** — use the root-isolate-load pattern in §9.4.
- Real cold-start timings on your specific low-end Android device. Every number here is a widget-test measurement on a host machine; they demonstrate *mechanisms and ratios*, not device wall-clock. Measure with `--trace-startup` on the target before committing to the 1.2 s budget.
