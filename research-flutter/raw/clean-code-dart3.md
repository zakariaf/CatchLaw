# Clean Code in Modern Dart (Dart 3.12 / Flutter 3.44.6)

**Research date:** 2026-07-27
**Toolchain this document targets:** Flutter 3.44.6 stable (released 2026-07-08) → **Dart 3.12.2**, DevTools 2.57.0
*(verified locally: `flutter --version` → `Flutter 3.44.6 • channel stable ... Tools • Dart 3.12.2`)*

**Verification method.** Every non-trivial code snippet in this document was compiled and run against
the local Dart 3.12.2 SDK (`dart analyze` with `strict-casts`/`strict-inference`/`strict-raw-types`
enabled, then `dart run`). Build-time numbers were measured on this machine, not quoted from blogs.
Package versions were read from the pub.dev JSON API on 2026-07-27. Where I could not verify
something, it says **unverified**.

**Target app bias.** 100% offline Android+iOS app; two drift SQLite DBs (one read-only asset, one
writable); `flutter_riverpod`; six locales incl. Arabic RTL; a **pure-Dart rule-engine package with
zero Flutter imports** shared with a CLI content-build tool; custom painting, SVG, PDF, camera,
single-shot GPS, a11y, golden tests; **cold start budget < 1.2 s on low-end Android**.

---

## 0. Version baseline — what is actually available to you

This is the single most useful table in this document, because most Dart advice on the open web is
pinned to Dart 2.x or early Dart 3.0 and is now wrong.

| Feature | Landed in | Available on Flutter 3.44.6 (Dart 3.12.2)? | Source |
|---|---|---|---|
| Sealed classes, class modifiers, patterns, records, exhaustive `switch` expressions | Dart 3.0 (2023-05-10) | ✅ Yes | [Dart SDK CHANGELOG 3.0.0](https://github.com/dart-lang/sdk/blob/main/CHANGELOG.md) |
| Extension types (zero-cost value objects) | Dart 3.3 | ✅ Yes | [dart.dev/language/extension-types](https://dart.dev/language/extension-types) |
| Pub workspaces (monorepo, one lockfile) | Dart 3.6 | ✅ Yes | [dart.dev/tools/pub/workspaces](https://dart.dev/tools/pub/workspaces) |
| Null-aware collection elements `[?maybeNull]` | Dart 3.8 (2025-05-20) | ✅ Yes | [dart.dev/language/collections](https://dart.dev/language/collections) |
| Null-safety-aware flow analysis (better promotion / dead-code) | Dart 3.9 (2025-08-13) | ✅ Yes | SDK CHANGELOG 3.9.0 |
| **Dot shorthands** (`.start`, `.a4`) | Dart 3.10 (2025-11-12) | ✅ Yes | [feature spec](https://github.com/dart-lang/language/blob/main/accepted/3.10/dot-shorthands/feature-specification.md) |
| Pub workspace **globs** (`workspace: [packages/*]`) | Dart 3.11 (2026-02-11) | ✅ Yes | SDK CHANGELOG 3.11.0 |
| **Private named parameters** (`Point({required this._x})`) | Dart 3.12 (2026-05-20) | ✅ Yes | [dart.dev/to/private-named-parameters](https://dart.dev/to/private-named-parameters) |
| **Primary constructors** (`class Point(var int x, var int y);`) | Dart 3.13 | ❌ **NOT YET** — 3.13 is unreleased as of 2026-07-27 | SDK CHANGELOG 3.13.0 ("Released on: Unreleased") |
| `no_raw_types` / `no_dynamic_casts` lints replacing `strict-raw-types`/`strict-casts` | Dart 3.13 | ❌ Not yet — keep using `analyzer: language:` strict modes | SDK CHANGELOG 3.13.0 |

**Do not write primary-constructor syntax yet.** It is in the unreleased 3.13 changelog and freezed
already has a `4.0.0-dev` line supporting it, but it will not compile on your toolchain. Design your
model classes so that adopting it later is a mechanical edit (see §4.2).

### Set your SDK floor deliberately

```yaml
# pubspec.yaml — every package in the workspace
environment:
  sdk: ^3.12.0
```

**Why:** Dart language features are **language-versioned per package**. If your lower bound says
`^3.0.0`, dot shorthands and private named parameters are *compile errors* in your files even though
the SDK supports them. This is the #1 "why doesn't this feature work for me" trap.
Source: [dart.dev/to/language-version](https://dart.dev/to/language-version).

---

## 1. Dart 3 language features that changed best practice

### 1.1 Sealed classes + exhaustive `switch` — the single biggest change

**WHAT:** Model any closed set of alternatives as a `sealed` supertype with `final` subtypes, then
consume it with a `switch` *expression*. Never with `if (x is A) ... else if (x is B)`.

**WHY:** `sealed` makes exhaustiveness a **compile-time error**, not a warning, not a runtime
`StateError`. I verified this — here is the literal analyzer output from the local SDK when a case is
missing:

```
error - b.dart:25:25 - The type 'Shape' isn't exhaustively matched by the switch cases since it
doesn't match the pattern 'Triangle()'. Try adding a wildcard pattern or cases that match
'Triangle()'. - non_exhaustive_switch_expression
```

and the compiler (not just the analyzer) refuses to build it:

```
lib/b.dart:25:33: Error: The type 'Shape' is not exhaustively matched by the switch cases
since it doesn't match 'Triangle()'.
```

That is the whole value proposition: **adding a new rule type to your rule engine breaks the build in
every place that needs updating.** For a rule engine shared between an app and a CLI tool, this is
worth more than any test suite.

**REAL EXAMPLE** (verified compiles + runs on Dart 3.12.2):

```dart
sealed class MeasureFailure {
  const MeasureFailure();
}

final class OutOfRange extends MeasureFailure {
  const OutOfRange({required this.value, required this.max});
  final double value;
  final double max;
}

final class MissingCalibration extends MeasureFailure {
  const MissingCalibration(this.deviceId);
  final String deviceId;
}

final class RuleConflict extends MeasureFailure {
  const RuleConflict({required this.ruleIds});
  final List<String> ruleIds;
}

// Exhaustive. Add a 4th subtype and this line stops compiling.
String describe(MeasureFailure f) => switch (f) {
  OutOfRange(:final value, :final max) => 'value $value exceeds $max',
  MissingCalibration(:final deviceId) => 'device $deviceId not calibrated',
  RuleConflict(:final ruleIds) => 'rules conflict: ${ruleIds.join(", ")}',
};
```

Note `OutOfRange(:final value, :final max)` — that is an **object pattern with the getter-name
shorthand**. It matches the type *and* destructures two fields in one token-efficient line.

**Sources:** [dart.dev/language/branches#exhaustiveness-checking](https://dart.dev/language/branches),
[dart.dev/language/patterns](https://dart.dev/language/patterns),
[dart.dev/language/class-modifiers](https://dart.dev/language/class-modifiers).

**This is not theoretical framework advice — Flutter itself does it.** Real `sealed class`
declarations in `flutter/flutter` today (found via `gh search code`):
`packages/flutter/lib/src/gestures/monodrag.dart` (`sealed class DragGestureRecognizer`),
`packages/flutter/lib/src/widgets/widget_state.dart` (`@immutable sealed class _WidgetStateCombo`),
`packages/flutter/lib/src/rendering/viewport.dart`, `packages/flutter/lib/src/semantics/semantics.dart`.

#### SUPERSEDED: freezed unions / `when` / `map`

Freezed's own README says this explicitly, in a warning box:

> **As of Dart 3, Dart now has built-in pattern-matching using sealed classes. As such, you no-longer
> need to rely on Freezed's generated methods for pattern matching. Instead of using `when`/`map`, use
> the official Dart syntax. ... in the long term, you should stop relying on them and migrate to
> `switch` expressions.**
> — [freezed README, "(Legacy) Pattern matching utilities"](https://github.com/rrousselGit/freezed/blob/master/packages/freezed/README.md)

This is authoritative: it is the package maintainer (Rémi Rousselet) telling you not to use his own
API. **If the only thing you wanted from freezed was a union type, delete freezed and write a sealed
class by hand.** Freezed unions still buy you `copyWith` on each variant and generated `==`, which is
sometimes worth it — see §5.4.

#### SUPERSEDED: `enum` + a giant `switch` on `runtimeType`, the Visitor pattern, `Object` + `is` chains

All three were workarounds for the absence of ADTs. They are dead. Also dead: `break` at the end of
every non-empty `case` — Dart 3 switch statements do not fall through. Enable
[`unnecessary_breaks`](https://dart.dev/tools/linter-rules/unnecessary_breaks).

#### Opinionated rule for `sealed` hierarchy shape

```dart
sealed class X {}          // the closed set
final class A extends X {} // leaves are `final` so nobody outside can subclass them
final class B extends X {}
```

Use `final` (not bare `class`) on leaves. **Why:** `final` closes the type for extension *and*
implementation outside the library, so the exhaustiveness guarantee cannot be diluted by a downstream
package, and you keep the freedom to add members later without breaking anyone
([dart.dev/language/class-modifiers](https://dart.dev/language/class-modifiers)). Flutter's official
`Result` does exactly this (`sealed class Result<T>` + `final class Ok<T>` + `final class Error<T>`).

### 1.2 Patterns and destructuring

**WHAT:** Use patterns in four places: `switch` (statement + expression), `if-case`, variable
declarations, and `for-in`.

**WHY:** They collapse "check the shape, then dig the values out" into one construct that cannot get
out of sync with itself.

**REAL EXAMPLES** (verified):

```dart
// 1. if-case: match one shape, ignore the rest. Replaces `is` + cast + null checks.
if (r case Ok(:final value) when value > 0.5) {
  print('high $value');
}

// 2. Declaration pattern with named-record destructuring.
final (:min, :max) = bounds([3, 1, 4]);

// 3. Swap without a temp variable (assignment pattern).
var a = 1;
var b = 2;
(a, b) = (b, a);

// 4. Validate a whole JSON shape — types, keys, and nesting — in one expression.
Result<RulerTick, String> parseTick(Object? json) {
  if (json case {'dx': final double dx, 'index': final int i, 'major': final bool m}) {
    return Result.ok((dx: dx, index: i, isMajor: m));
  }
  return const Result.err('bad tick');
}
```

Example 4 is the pattern to use for your **CLI content-build tool** parsing hand-authored YAML/JSON
into the reference DB: it is total (returns a `Result`, never throws on malformed input), it validates
types without `as` casts, and it needs no codegen. `dart.dev` shows the same idiom
([patterns § JSON validation](https://dart.dev/language/patterns)).

`for-in` destructuring, straight from the official docs, is the idiomatic map iteration:

```dart
for (var MapEntry(:key, value: count) in hist.entries) {
  print('$key occurred $count times');
}
```

**Do not** use `case var x` when you mean `case final x`. Prefer `final` in patterns —
`prefer_final_locals` covers ordinary locals, and `final` in a pattern says "this binding is a
read-only view of matched data", which is what you almost always want.

Dart 3.11 added the [`simplify_variable_pattern`](https://dart.dev/tools/linter-rules) lint which
pushes you toward `(:final name)` over `(name: final name)`. Turn it on.

### 1.3 Records — replace tuple classes and out-params

**WHAT:** A record is "an anonymous, immutable, aggregate type" with **structural typing and
structural equality**. Use it when a value has no identity and no behaviour and does not cross a
public API boundary.

**WHY (verified, not asserted):**

```
record ==: true    record identical: true
record hash equal: true
```

Two separately-written `const (x: 1, y: 2)` records are `==`, have equal `hashCode`, *and* are
canonicalized to the same instance. You get free value semantics with zero code and zero codegen.
The analyzer even catches duplicates statically — my test file produced
`warning - Two elements in a set literal shouldn't be equal - equal_elements_in_set` for
`{p1, p2}`.

**REAL EXAMPLE** — multiple returns without a throwaway class:

```dart
({double min, double max}) bounds(List<double> xs) {
  var lo = xs.first;
  var hi = xs.first;
  for (final x in xs) {
    if (x < lo) lo = x;
    if (x > hi) hi = x;
  }
  return (min: lo, max: hi);
}

final (:min, :max) = bounds([3, 1, 4]);   // 1.0..4.0
```

**Name your record types with a typedef** when they recur:

```dart
typedef RulerTick = ({double dx, int index, bool isMajor});
typedef Millimetres = double;
```

Official docs endorse this: *"You can use typedefs to alias record types for easier maintenance and
potential future refactoring."* ([dart.dev/language/records](https://dart.dev/language/records))

**DANGER — verified failure mode.** Records give you *shallow* structural equality. A record with a
`List` field is **not** deeply equal:

```
record w/ list: false      //  (tags: ["a"]) == (tags: ["a"])  →  FALSE
```

This bites hard with Riverpod (which uses `==` to decide whether to rebuild) and with golden tests.
**Rule: never put a `List`, `Map`, or `Set` field in a record you intend to compare.** Use a class
with `ListEquality`, `equatable`, or freezed for those (§4.4).

**When NOT to use records:**
- Anything crossing a package boundary (your rule-engine package's public API). A record has no name
  in a stack trace, no doc comment, no invariants, and no room to grow a method later.
- Anything with more than ~3 fields — positional records become unreadable, and at that point you
  want a named class anyway.
- Anything you want to pattern-match *by type*. `sealed class` for that.

**SUPERSEDED by records:** `package:tuple` (do not add it), hand-rolled `Pair<A,B>` classes, "return
a `Map<String, dynamic>`", and out-parameters via mutable holder objects.

### 1.4 Class modifiers — an actual policy, not a menu

Everyone reads [dart.dev/language/class-modifiers](https://dart.dev/language/class-modifiers), gets
overwhelmed, and writes bare `class` forever. Here is a decision policy for an app of this size:

| Situation | Declaration | Why |
|---|---|---|
| A closed set of alternatives (rule kinds, failures, UI states) | `sealed class` + `final class` leaves | Compile-time exhaustiveness |
| A concrete immutable value/data class | `final class` | Nobody can subclass and break your `==`/`hashCode` contract; you can add fields later without breaking downstream code |
| A contract you want fakes/mocks for (repositories, DAO seams) | `abstract interface class` | Callers may `implements` (so `mocktail` fakes work) but not `extends`, so you can never be broken by someone inheriting your partial implementation |
| A widget | plain `class ... extends StatelessWidget` | Flutter's own convention; don't fight it |
| Shared behaviour with no state, applied to several types | `mixin` | — |
| You genuinely intend an inheritance hierarchy (rare in app code) | `base class` | Forces subtypes to be `base`/`final`/`sealed`, so private members are guaranteed present |

**REAL EXAMPLE** (verified):

```dart
// Repository seam: implementable (for fakes), not extendable.
abstract interface class ReferenceDao {
  Future<List<String>> tagsFor(String id);
}

// Inheritance intended, closed to outside implementation.
base class Rule {
  const Rule(this.id);
  final String id;
}

final class Threshold extends Rule {
  const Threshold(super.id, {required this.limit});
  final double limit;
}
```

Note `super.id` — **super-initializer parameters**, cheaper than `Threshold(String id, ...) : super(id)`.
Enforced by [`use_super_parameters`](https://dart.dev/tools/linter-rules/use_super_parameters), which
is already in `package:lints/recommended.yaml`.

**Opinion:** `abstract interface class` for every repository/service seam is the single highest-value
modifier choice in an app like yours. Flutter's own architecture recommendations rate "Use abstract
repository classes" as **Strongly recommend**
([docs.flutter.dev/app-architecture/recommendations](https://docs.flutter.dev/app-architecture/recommendations)),
and `interface` is strictly better than bare `abstract` because it blocks `extends`.

### 1.5 Enhanced enums (Dart 2.17+) — use them, they are underused

**WHAT:** Enums with `final` fields, `const` constructors, getters, methods, and interface
implementations.

**WHY:** They replace the "enum + a parallel `Map<MyEnum, Config>` lookup table" anti-pattern, which
can silently go stale when you add a value.

**REAL EXAMPLE** (verified; directly usable for your PDF export):

```dart
enum PaperSize {
  a4(widthMm: 210, heightMm: 297),
  letter(widthMm: 215.9, heightMm: 279.4);

  const PaperSize({required this.widthMm, required this.heightMm});
  final double widthMm;
  final double heightMm;

  double get aspect => widthMm / heightMm;
  bool get isMetric => this == PaperSize.a4;
}
```

Constraints (from [dart.dev/language/enums](https://dart.dev/language/enums)): instance variables must
be `final`, all generative constructors must be `const`, you cannot override `index`, `hashCode`, or
`==`, and you cannot declare a member named `values`.

**For localized enums, do NOT put translated strings in the enum.** Put an ARB key or a
`String Function(AppLocalizations)` accessor there instead, or better, keep the mapping in a
presentation-layer extension. Your enum lives in the pure-Dart rule package, which must not import
`flutter_localizations`.

```dart
// in the Flutter layer, NOT in the pure-Dart package
extension PaperSizeL10n on PaperSize {
  String label(AppLocalizations l10n) => switch (this) {
    PaperSize.a4 => l10n.paperA4,
    PaperSize.letter => l10n.paperLetter,
  };
}
```

That `switch` is exhaustive over the enum — add `PaperSize.legal` and every locale mapping breaks the
build. That is exactly what you want with six locales.

### 1.6 Extension types (Dart 3.3+) — zero-cost value objects

**WHAT:** `extension type const Mm(double value) { ... }` — a compile-time-only wrapper over a
representation type. Officially: *"they don't require the creation of an extra run-time object, which
can get expensive when you need to wrap lots of objects ... essentially zero cost."*
([dart.dev/language/extension-types](https://dart.dev/language/extension-types))

**WHY it matters for you:** your rule engine and your on-screen ruler traffic in bare `double`s that
mean different things (millimetres, pixels, pixels-per-mm). A wrapper class would allocate on every
tick of a `CustomPainter`; an extension type does not.

**REAL EXAMPLE** (verified compiles + runs):

```dart
extension type const Mm(double value) {
  double get cm => value / 10;
  Mm operator +(Mm other) => Mm(value + other.value);
}

const a = Mm(10);
const b = Mm(5);
print((a + b).cm); // 1.5
```

**Honest limitation (state it, do not hide it):** extension types are *erased*. `n is int` is `true`
for an `Mm`, pattern matching sees the representation type, and generics erase. The docs call them
"somewhat protected" rather than encapsulated. So:

- ✅ Use for unit-safety inside a single package where the compiler is your only audience.
- ❌ Do **not** use where you need runtime type dispatch, `switch` on type, or serialization identity.
- ❌ Do **not** use as your public API type for a package consumed by others who might cast around it.

**Opinionated verdict:** for a ruler app, `extension type const Mm(double)` / `Px(double)` /
`PxPerMm(double)` is a genuinely good trade. For a "UserId" wrapping a `String` in a small app it is
usually ceremony — see §9.

### 1.7 Dot shorthands (Dart 3.10) — new, and you should use them

```dart
Column(
  crossAxisAlignment: .start,
  mainAxisSize: .min,
  children: widgets,
)

PaperSize pick(bool metric) => metric ? .a4 : .letter;   // verified
```

**WHY:** it removes the single most repetitive noise in Flutter widget trees. It is a *pure* brevity
feature — no new semantics. Requires `sdk: ^3.10.0` or higher in the consuming package.
Source: [dot-shorthands feature spec](https://github.com/dart-lang/language/blob/main/accepted/3.10/dot-shorthands/feature-specification.md),
SDK CHANGELOG 3.10.0.

**Caveat:** almost every code sample, blog post, and LLM output you will find predates this. If you
adopt it, adopt it consistently, and be aware that copy-pasted examples will use the long form.

### 1.8 Null-aware elements (Dart 3.8) and private named parameters (Dart 3.12)

```dart
// Null-aware elements: `?x` omits the element if x is null.
List<String> lines(String? header, String body) => [?header, body];
```
Replaces `[if (header != null) header, body]`. Works in list, set, and map literals (keys *and*
values). Lint: `use_null_aware_elements` (already in `package:lints/recommended.yaml`).

```dart
// Private named parameters (Dart 3.12) — verified.
final class Session {
  const Session({required this._startedAt, required this._locale});
  final DateTime _startedAt;
  final String _locale;
  Duration get age => DateTime.now().difference(_startedAt);
  String get locale => _locale;
}

// Call site uses the PUBLIC name:
Session(startedAt: DateTime.now(), locale: 'ar');
```

I verified the call-site behaviour by writing it wrong first; the analyzer said:

```
error - The named parameter '_startedAt' should use the corresponding public name 'startedAt'
at the callsite. - undefined_named_parameter
```

**WHY it matters:** it kills the `Point({required int x}) : _x = x` initializer-list boilerplate that
was the only way to have a private final field with a named constructor parameter. Dart 3.12 also
added the [`prefer_initializing_formals`](https://dart.dev/tools/linter-rules) fix that rewrites the
old form for you: `dart fix --code=prefer_initializing_formals --apply`.

---

## 2. Error handling: exceptions vs Result

### 2.1 What Flutter officially recommends

Flutter has a dedicated page in its architecture guidance:
**[docs.flutter.dev/app-architecture/design-patterns/result](https://docs.flutter.dev/app-architecture/design-patterns/result)**.
The `Result` class it ships is this (verbatim from
`flutter/samples` → `compass_app/app/lib/utils/result.dart`, read via the GitHub API):

```dart
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result], completed with the specified [value].
  const factory Result.ok(T value) = Ok._;

  /// Creates an error [Result], completed with the specified [error].
  const factory Result.error(Exception error) = Error._;
}

final class Ok<T> extends Result<T> {
  const Ok._(this.value);
  final T value;
  @override
  String toString() => 'Result<$T>.ok($value)';
}

final class Error<T> extends Result<T> {
  const Error._(this.error);
  final Exception error;
  @override
  String toString() => 'Result<$T>.error($error)';
}
```

The stated rationale: Dart exceptions are unchecked, so *"methods don't need to declare them, and
callers aren't required to catch them"*, which leads to *"undocumented exceptions propagating through
application layers"*. `Result` makes the failure path part of the type signature.

Note the design details worth copying: `sealed` supertype, `final` subtypes, **private** subtype
constructors (`Ok._`) forcing everyone through `Result.ok` / `Result.error`, and `const factory`
redirects so `const Result.error(...)` works.

### 2.2 Where I disagree with the official version, and what I recommend instead

**Flutter's `Result<T>` types the error as `Exception`.** That is a strict improvement over nothing,
but for a rule engine it throws away the whole benefit: you can't exhaustively switch on *which*
failure occurred, so you end up doing `if (result.error is OutOfRangeException)` — an `is`-chain,
i.e. exactly the pattern Dart 3 was designed to kill.

**Recommendation: use a two-parameter `Result<T, E>` with a sealed error type.** This is what the
official version would be if it were written for a domain layer rather than an HTTP client.

**REAL EXAMPLE** (verified compiles + runs on Dart 3.12.2):

```dart
sealed class Result<T, E> {
  const Result();
  const factory Result.ok(T value) = Ok<T, E>._;
  const factory Result.err(E error) = Err<T, E>._;
}

final class Ok<T, E> extends Result<T, E> {
  const Ok._(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err._(this.error);
  final E error;
}

Result<double, MeasureFailure> normalize(double raw, {required double max}) {
  if (raw > max) return Result.err(OutOfRange(value: raw, max: max));
  return Result.ok(raw / max);
}
```

Consumption is a *doubly* exhaustive switch — over `Ok`/`Err`, and then over the sealed failure:

```dart
final r = normalize(12, max: 10);
switch (r) {
  case Ok(:final value):
    print(value);
  case Err(:final error):
    print(describe(error)); // describe() is itself an exhaustive switch over MeasureFailure
}
```

**Trade-off, stated honestly:** `Result<T, E>` is more verbose at every declaration site, and it does
not compose as nicely as `Either` in a language with do-notation. If you find yourself writing five
levels of nested `switch`, add small helpers rather than reaching for a monad library:

```dart
extension ResultX<T, E> on Result<T, E> {
  T? get valueOrNull => switch (this) { Ok(:final value) => value, Err() => null };
  E? get errorOrNull => switch (this) { Ok() => null, Err(:final error) => error };
  Result<R, E> map<R>(R Function(T) f) =>
      switch (this) { Ok(:final value) => Result.ok(f(value)), Err(:final error) => Result.err(error) };
}
```

### 2.3 The decision rule: throw vs return

This is the part most guides fudge. Be concrete.

| Situation | Do this | Why |
|---|---|---|
| A **bug** — precondition violated, impossible state, index out of bounds, `null` where the type says non-null | **`throw` an `Error` subtype** (`ArgumentError`, `StateError`, `UnimplementedError`) and let it crash | Effective Dart: *"DO throw objects that implement Error only for programmatic errors"* and *"DON'T explicitly catch Error or types that implement it"*. You want the stack trace, not a graceful degradation that hides the bug. |
| An **expected, modeled domain failure** — measurement out of range, no matching rule, calibration missing, PDF page overflow | **Return `Result<T, DomainFailure>`** | It is part of your API contract. The caller must handle it (the switch won't compile otherwise). |
| An **expected I/O failure** — SQLite constraint violation, missing asset, camera permission denied, GPS timeout, filesystem full | **Catch at the boundary, convert to a `Result` with a sealed failure** | The failure is expected but the mechanism (an exception) is imposed by the platform API. Convert once, at the lowest layer that knows what the exception means. |
| Something you genuinely cannot handle and cannot model | **`rethrow`** | Effective Dart: *"DO use rethrow to rethrow a caught exception"*. Never `throw e` — that resets the stack trace. |

**Boundary conversion, real code** (verified):

```dart
Future<Result<int, MeasureFailure>> guarded(Future<int> Function() body) async {
  try {
    return Result.ok(await body());
  } on FormatException {
    return const Result.err(MissingCalibration('unknown'));
  }
}
```

For drift specifically, the boundary is your DAO:

```dart
// data/dao/measurement_dao.dart
Future<Result<int, StorageFailure>> insert(MeasurementsCompanion row) async {
  try {
    return Result.ok(await into(measurements).insert(row));
  } on SqliteException catch (e) {
    // 2067 == SQLITE_CONSTRAINT_UNIQUE
    return Result.err(e.extendedResultCode == 2067
        ? const DuplicateRow()
        : StorageFailure.unknown(e.message));
  }
}
```
*(The `SqliteException`/`extendedResultCode` API comes from `package:sqlite3`, which drift depends on.
Verify the exact code against your schema before shipping — I did not verify the numeric constant.)*

### 2.4 Anti-patterns in error handling

| ❌ Anti-pattern | Why it's wrong | ✅ Fix |
|---|---|---|
| `try { ... } catch (e) { }` | Swallows `Error`s (i.e. your bugs) and gives you nothing to debug | `on SpecificException catch (e)`. Lint: [`avoid_catches_without_on_clauses`](https://dart.dev/tools/linter-rules/avoid_catches_without_on_clauses) |
| `throw 'something went wrong';` | Throwing a `String` gives no type to catch on and no stack context | Throw an `Exception`/`Error` subtype. Lint: [`only_throw_errors`](https://dart.dev/tools/linter-rules/only_throw_errors) |
| `catch (e) { throw e; }` | Destroys the original stack trace | `rethrow`. Lint: `use_rethrow_when_possible` (already in `lints/recommended`) |
| `Result` everywhere, including for bugs | You end up handling `Result.err(ArgumentError(...))` in the UI, which is meaningless to the user | Bugs throw. Domain failures return. |
| `Exception` as the error type in `Result<T>` | Forces `is`-chains, defeats exhaustiveness | `Result<T, SealedFailure>` |
| Using `package:dartz` for `Either` | **Abandoned — last published 2021-12-03** (pub.dev API, checked 2026-07-27) | Write the 20-line sealed `Result` above. If you truly want an FP toolkit, `fpdart` 1.2.0 (2025-10-29) is alive — but for one app you don't need it. |

---

## 3. Immutability

### 3.1 `const` — measured, not asserted

**WHAT:** Mark constructors `const`, and use `const` at call sites wherever the arguments are compile-time constants.

**WHY (verified locally):**

```
const identical: true        // const Circle(1) and const Circle(1) are the SAME object
non-const identical: false
non-const ==: false
```

`const` gives you three things:
1. **Canonicalization** — one heap object for all identical `const` values. Fewer allocations, less GC.
   For a `CustomPainter` running at 60–120 Hz, this is not micro-optimization.
2. **Rebuild short-circuiting in Flutter.** Flutter's official perf page: *"Use `const` constructors as
   much as possible ... The framework short-circuits rebuilds when it encounters the same widget
   instance (using `operator ==`)."*
   ([docs.flutter.dev/perf/best-practices](https://docs.flutter.dev/perf/best-practices))
3. **Compile-time evaluation** — zero cold-start cost. Relevant to your 1.2 s budget.

Enable the lints (not in `flutter_lints` by default — you must add them):

```yaml
linter:
  rules:
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables   # already in flutter_lints
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
```
Then `dart fix --apply` will insert thousands of `const`s for you in one shot.

### 3.2 `final` fields, `@immutable`, and the hand-written value class

**Baseline** — this is what a value class looks like with no packages, no codegen (verified):

```dart
final class Calibration {
  const Calibration({required this.pixelsPerMm, required this.deviceId});

  final double pixelsPerMm;
  final String deviceId;

  Calibration copyWith({double? pixelsPerMm, String? deviceId}) => Calibration(
    pixelsPerMm: pixelsPerMm ?? this.pixelsPerMm,
    deviceId: deviceId ?? this.deviceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Calibration &&
          other.pixelsPerMm == pixelsPerMm &&
          other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(pixelsPerMm, deviceId);

  @override
  String toString() => 'Calibration($pixelsPerMm, $deviceId)';
}
```

Points that matter:
- `identical(this, other) ||` first — a free fast path, and it makes `const` canonicalization pay off.
- `Object.hash(...)` — the built-in combiner. For collections use `Object.hashAll(list)` (verified:
  `Object.hashAll(["a"]) == Object.hashAll(["a"])` → `true`).
- Parameter is `Object`, **not** `Object?`. Effective Dart: *"DON'T make the parameter to == nullable."*
- `final class`, so nobody can subclass and break symmetry of `==`.
- Effective Dart: *"AVOID defining custom equality for mutable classes"* — equality contracts assume
  immutability. Never put `==` on a class with non-`final` fields.

### 3.3 `copyWith` and the null-clearing bug

**The bug everyone ships:** `copyWith({String? note})` with `note ?? this.note` **cannot set `note` to
null.** Calling `copyWith(note: null)` is indistinguishable from `copyWith()`.

**FIX — sentinel object** (verified: prints `null`, i.e. the field really was cleared):

```dart
final class Draft {
  const Draft({required this.title, this.note});
  final String title;
  final String? note;

  static const _unset = Object();

  Draft copyWith({String? title, Object? note = _unset}) => Draft(
    title: title ?? this.title,
    note: identical(note, _unset) ? this.note : note as String?,
  );
}

const Draft(title: 't', note: 'n').copyWith(note: null).note;  // → null  ✅
```

This is ugly. It is also exactly why freezed exists: freezed generates `copyWith` with the sentinel
trick automatically, correctly, for every nullable field. **If your model has ≥2 nullable fields that
users legitimately clear, that is a real argument for freezed** — not "boilerplate reduction" in the
abstract, but "the hand-written version is wrong and the generated one isn't."

### 3.4 Equality options compared — with verified behaviour

| Approach | Deep list/map equality? | `copyWith`? | Codegen? | Version / status (2026-07-27) |
|---|---|---|---|---|
| **Record** `({int x, int y})` | ❌ **No** — verified `(tags: ["a"]) == (tags: ["a"])` is `false` | ❌ (spread a new literal instead) | No | Language feature, Dart 3.0+ |
| Hand-written `==` + `Object.hash` | Only if you use `ListEquality` yourself — verified naive version returns `false` | Hand-written (and usually buggy for nullables) | No | — |
| **`equatable`** | ✅ **Yes** — verified: `List` and `Map` props deep-compare `true`, hashCodes match, set dedupes | ❌ Not provided | No | **2.1.0, published 2026-07-05. Actively maintained.** 2.1.0 deprecates `EquatableMixin` in favour of `with Equatable`. |
| **`freezed`** | ✅ Yes | ✅ Yes (correct null-clearing, deep copy) | **Yes** | **3.2.5, published 2026-02-03; 4.0.0-dev.3 (2026-06-13) already supports Dart 3.13 primary constructors. Actively maintained, Flutter Favorite.** |
| **`built_value`** | ✅ Yes | ✅ Yes (builders) | Yes | 8.12.6, published 2026-04-30. Maintained, but a heavier idiom; Dart 3 has closed most of its lead. |
| **drift-generated row class** | ✅ Yes (drift generates `==`/`hashCode`/`copyWith`/`toString`/`toJson`) | ✅ Yes | Yes (you're already running it) | drift 2.34.2 (2026-07-14) / drift_dev 2.34.5 (2026-07-22). Very actively maintained. |
| `dart_mappable` | ✅ Yes | ✅ Yes | Yes | 4.8.0 (2026-04-20). Alive; a credible freezed alternative but a smaller ecosystem. |

Verified `equatable` behaviour on the local SDK:
```
equatable deep list/map ==: true
hashCode equal: true
toString: Tagged([x], {k: 1})
set size: 1
```

```dart
class Tagged extends Equatable {
  const Tagged(this.tags, this.meta);
  final List<String> tags;
  final Map<String, int> meta;
  @override
  List<Object?> get props => [tags, meta];
  @override
  bool get stringify => true;
}
```

**Opinionated recommendation for this app:**

1. **Rule-engine package (pure Dart, no Flutter):** hand-written `final class` + `const` + `==`.
   No `equatable`, no `freezed`. Reason: these types are few, stable, and heavily unit-tested; the
   package should have the smallest possible dependency surface so the CLI tool stays fast to boot,
   and a dependency-free package is trivially shareable. Records for internal intermediates.
2. **drift row classes:** use what drift generates. **Do not wrap drift rows in freezed classes.**
   Drift already gives you `==`, `hashCode`, `copyWith`, `toString`, `toJson`/`fromJson` on every row
   ([drift docs, "Generated table rows"](https://drift.simonbinder.eu/dart_api/rows/)). Adding a
   parallel freezed mirror doubles your model count, doubles build time, and adds a mapping layer
   that will drift out of sync. If you dislike drift's default names, use `@DataClassName('Category')`
   or `@UseRowClass(MyClass)` — and drift even supports `@UseRowClass(Record)`.
3. **UI state classes held in Riverpod notifiers:** `equatable` (2.1.0) **or** freezed. Riverpod
   compares with `==` to decide whether to rebuild; a class without value equality causes rebuild
   storms. `equatable` is the cheaper choice — no build step at all.
4. **Only reach for freezed** where you need generated `copyWith` on models with several nullable
   fields, or JSON ser/des on non-drift models.

Flutter's own recommendation table rates *"Use immutable data models"* as **Strongly recommend** and
*"Use freezed or built_value to generate immutable data models"* as **Recommend**, with the explicit
caveat: *"These code generation packages can add significant build time to your applications if you
have a lot of models."*
([docs.flutter.dev/app-architecture/recommendations](https://docs.flutter.dev/app-architecture/recommendations))

### 3.5 Do NOT override `==` on Widgets

Flutter's perf page is blunt about this: *"Don't override `operator ==` on Widgets — results in
O(N²) behavior and prevents compiler optimizations. Only exception: leaf widgets where comparison is
significantly cheaper than rebuilding."*
([docs.flutter.dev/perf/best-practices](https://docs.flutter.dev/perf/best-practices))

So: `extends Equatable` on a `StatelessWidget` is an anti-pattern, even though it "looks consistent".
Use `const` constructors + `Key`s instead.

---

## 4. Code generation: real numbers

### 4.1 STALE ADVICE ALERT: "build_runner is slow" is out of date

The received wisdom ("codegen costs you 2 minutes per build") is based on build_runner ~2.4.x. It has
been substantially rewritten in 2026:

- **2.13.0 (2026-03-17):** *"Performance: speedup of between 1.4x for small initial builds to 4x for
  large incremental builds."*
- **2.14.0 (2026-04-22):** *"Performance: default to AOT compilation for commands other than `run`.
  This costs more initial startup time but gives faster builds afterwards."*
- **2.15.0 (2026-04-30):** *"Remove `--low-resources-mode` as default memory usage has been improved."*
- **2.15.3 published 2026-07-27** (today) — this package is under heavy active development.

Source: [dart-lang/build build_runner/CHANGELOG.md](https://github.com/dart-lang/build/blob/master/build_runner/CHANGELOG.md).

### 4.2 Measured on this machine, 2026-07-27

I built a throwaway package: 30 models, each `@freezed` + `fromJson`, with `freezed 3.2.5`,
`json_serializable 6.14.0`, `build_runner 2.15.3`, Dart 3.12.2.

| Scenario | Wall time | Output |
|---|---|---|
| `dart pub get` (50 deps, warm pub cache) | **1.7 s** | — |
| First-ever build (compiles builder AOT snapshot too) | **18.1 s** | 90 files |
| Cold build after `rm -rf .dart_tool/build` (snapshot cached) | **12.7 s** | 90 files |
| No-op rebuild | **0.59 s** | 0 files |
| One-file change rebuild | **0.62 s** | 3 files |

Log line confirming the AOT path: `Built with build_runner/aot in 12s; wrote 90 outputs.`

**Code amplification:** 452 hand-written lines → **9,510 generated lines** (21×), 600 KB in `lib/`.

**Conclusion:** for 30 models, codegen costs ~13 s once on a clean checkout/CI and **~0.6 s** during
development. That is not a reason to avoid it. **The real cost of freezed is not build time — it is
the 21× code amplification in your repo, the IDE indexing cost, and the fact that a single analyzer
version bump can block your whole pipeline.**

Scale linearly with care: your app will also run `drift_dev` (schema generation is heavier than
freezed) and possibly `riverpod_generator`. Budget ~30–60 s cold on CI, still sub-second incremental.

### 4.3 What to check into git — settled by evidence, not opinion

**Check generated files IN.** This is the ecosystem convention, verified by reading real repos today:

| Repo | `.g.dart` files committed | Root `.gitignore` mentions them? |
|---|---|---|
| `flutter/samples` (compass_app, the official architecture reference) | ✅ Yes — `activity.freezed.dart`, `activity.g.dart`, etc. all present in the tree | ❌ No |
| `rrousselGit/riverpod` | ✅ **170** `.g.dart` files | ❌ No |
| `simolus3/drift` | ✅ **31** `.g.dart` files | Only `docs/**/*.g.dart` |
| `felangel/bloc` | — | ❌ No |
| `flutter/packages` | — | ❌ No (only native plugin registrants) |

**WHY check them in:**
- A fresh `git clone` + `flutter run` works without a 13 s build step and without a network round-trip
  to pub for `build_runner`'s own dependencies.
- Code review shows you what the generator actually produced — you catch generator regressions.
- Golden tests and CI don't need a codegen stage.
- IDE analysis works immediately on clone.

**The one legitimate counter-argument** is merge conflicts in generated files. The fix is a
`.gitattributes`, not `.gitignore`:

```gitattributes
# .gitattributes
*.g.dart       linguist-generated=true -diff
*.freezed.dart linguist-generated=true -diff
```
This collapses them in GitHub diffs. On conflict, take either side and re-run the generator.

**DO gitignore:** `.dart_tool/` (which contains `.dart_tool/build/`, the incremental cache — this is
already in the standard `flutter create` `.gitignore`).

**DO NOT** add `*.g.dart` to `.gitignore`. If you do, `flutter analyze` on a clean CI checkout fails
before your build step runs, and every contributor's first experience is a wall of red.

### 4.4 build_runner ergonomics

```bash
# The command you actually run. --delete-conflicting-outputs is required after
# renaming/deleting a source file, and harmless otherwise.
dart run build_runner build --delete-conflicting-outputs

# During development:
dart run build_runner watch --delete-conflicting-outputs

# Only regenerate one file (huge win in a big project):
dart run build_runner build --build-filter="lib/domain/models/rule.*"

# Monorepo: build every workspace member in one pass (2.14+, no longer experimental)
dart run build_runner build --workspace

# Kill a stray watcher (2.14+)
dart run build_runner stop
```

`build.yaml` — turn off generators you are not using, per package. Every enabled builder is scanned
against every input:

```yaml
# build.yaml at the package root
targets:
  $default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true
          field_rename: snake
        generate_for:
          - lib/data/models/**.dart      # don't scan the whole package
      freezed:
        generate_for:
          - lib/domain/models/**.dart
```

**Pub workspace layout for your rule-engine + CLI + app** (Dart 3.6+, globs need 3.11+):

```yaml
# ./pubspec.yaml  (repo root, not a real package)
name: _
publish_to: none
environment:
  sdk: ^3.12.0
workspace:
  - packages/*        # rule_engine, content_tool
  - app
```
```yaml
# packages/rule_engine/pubspec.yaml
name: rule_engine
environment:
  sdk: ^3.12.0
resolution: workspace
dependencies:
  meta: ^1.19.0        # and NOTHING from Flutter
```

**WHY a workspace and not melos:** one `pubspec.lock`, one `.dart_tool/package_config.json`, one
`dart pub get`, and `build_runner --workspace` builds everything in a single process. Built into the
SDK, no extra tool to keep alive. Source:
[dart.dev/tools/pub/workspaces](https://dart.dev/tools/pub/workspaces).

**Enforcing "no Flutter imports" in the rule engine:** the pubspec is the enforcement. If
`rule_engine` does not depend on `flutter`, `import 'package:flutter/...'` is an analyzer error
(`depend_on_referenced_packages` / unresolved URI) and the CLI tool can `dart run` it without a
Flutter SDK. Do not rely on convention or a lint — rely on the dependency graph. Add a CI check:

```bash
dart pub -C packages/rule_engine get && dart analyze packages/rule_engine
# fails if anything Flutter-shaped crept in
```

### 4.5 When codegen is worth it — my rules

**Worth it:**
- **drift.** Non-negotiable. Hand-writing type-safe SQL mapping is madness, and `drift_dev` also gives
  you compile-time-verified SQL (`.drift` files) and migration stepping. You are running build_runner
  anyway, which changes the freezed calculus — the marginal cost of adding freezed is now small.
- **json_serializable**, *if* you have non-drift JSON models (e.g. your CLI tool ingesting authored
  content). `explicit_to_json: true` and `field_rename` remove a whole class of typo bugs.
- **freezed**, for models with several nullable fields where `copyWith` must be able to clear them,
  and for anything with >6 fields where the hand-written `==` is a code-review liability.
- **`riverpod_generator` (4.0.6, 2026-07-26):** optional. Riverpod 3's own docs present codegen and
  manual providers as equal alternatives, not codegen-first
  ([riverpod.dev/docs/whats_new](https://riverpod.dev/docs/whats_new)). Since you're already
  build_runner-bound, codegen removes provider-type-selection mistakes. Either is defensible.

**NOT worth it:**
- freezed for a 2-field immutable pair → use a **record** or a 15-line `final class`.
- freezed for **union types alone** → use a hand-written `sealed class` (freezed's own README tells
  you to).
- freezed mirrors of drift row classes → duplication for nothing.
- `copy_with_extension` (15.0.1, 2026-05-01) — an entire builder for one method. Just write it, or use
  freezed which you may already have.
- `injectable` / codegen DI — you have Riverpod. Two DI systems is one too many.
- `auto_route` — you don't have deep navigation needs stated; Flutter recommends `go_router`
  (Recommend rating), which needs no codegen.

---

## 5. Null safety done well

### 5.1 Avoid `!` — it is a runtime cast, not a comment

The official docs are explicit: *"any cast must be checked at runtime to preserve soundness and it may
fail and throw an exception. Reserve this for cases where static analysis cannot prove safety."*
([dart.dev/null-safety/understanding-null-safety](https://dart.dev/null-safety/understanding-null-safety))

Three replacements, in order of preference:

```dart
// 1. Let flow analysis promote. Zero cost, zero risk.
String describeNote(String? note) {
  if (note == null) return 'none';
  return note.toUpperCase();   // promoted to String, no `!`
}

// 2. Switch on null explicitly — handles empty/other cases in one expression.
String describeNote2(String? note) => switch (note) {
  null => 'none',
  final s when s.isEmpty => 'empty',
  final s => s.toUpperCase(),
};

// 3. Null-aware elements / operators for collections and chains.
List<String> lines(String? header, String body) => [?header, body];
```
(All three verified: `none`, `A`, `[b]`.)

Note from Dart 3.2+, **private final fields** also promote — so `_controller?.dispose()` inside the
class can often just be `if (_controller != null) _controller.dispose()`. Dart 3.9 further improved
promotion/reachability by assuming null safety
(SDK CHANGELOG 3.9.0), which means more `dead_code` warnings that are actually correct.

Interesting corollary from Flutter's own `Result` usage in
`compass_app/booking_create_use_case.dart`: even the official sample uses `!` where a nullable field
was just checked (`itineraryConfig.destination!`). That's the honest reality — `!` after an early
`if (x == null) return ...` on a *field* (which doesn't promote across an `await`) is acceptable. The
cleaner fix is to destructure once:

```dart
// instead of `if (cfg.destination == null) return ...;` then `cfg.destination!` twice:
if (cfg.destination case final String destination) {
  // `destination` is non-nullable and promoted, use it freely
} else {
  return Result.err(const NoDestination());
}
```

### 5.2 `late` vs nullable

| Use | When |
|---|---|
| `late final X x;` assigned in `initState`/`onInit` | The value is genuinely never observable as null. E.g. an `AnimationController` created in `initState`. |
| `late final x = expensive();` | **Lazy initialization.** Runs on first read, never if unread. Great for your cold-start budget. |
| `X? x;` | Null is a **meaningful domain state** ("no note attached", "GPS not yet fixed"). |

**Do NOT use `late` to silence the compiler.** Verified failure mode:

```
late final reassign -> LateInitializationError: Field 'x' has already been initialized.
```

A `late final` field assigned twice throws at runtime — you converted a compile error into a
production crash. Same for reading before assignment.

Effective Dart: *"DON'T use `late` when a constructor initializer list will do"*, and
*"AVOID public `late final` fields without initializers"* (make it private with a public getter).
Lint: `unnecessary_late` (already in `lints/recommended`).

### 5.3 Cold-start relevance: Dart statics are lazy

Verified on the local SDK:

```dart
int _expensive() { print('  >> expensive ran'); return 42; }
final topLevel = _expensive();
class Holder { static final cached = _expensive(); }

void main() {
  print('main started');            // prints FIRST
  print(Holder.cached);             // ">> expensive ran" prints HERE
  print(topLevel);                  // ">> expensive ran" prints HERE
}
```
Output:
```
main started (nothing computed yet?)
  >> expensive ran
touching Holder.cached: 42
  >> expensive ran
touching topLevel: 42
```

**Top-level and static `final`s are initialized lazily on first read, not at program start.** This is
a direct lever for your <1.2 s budget: putting your rule tables, `Paint` objects, `TextStyle`s, and
locale data in top-level `final`s costs nothing until first touch. It also means you must *not* rely
on a top-level initializer for side effects (registering something) — it may never run.

### 5.4 `required` named parameters

Default to `required` named parameters for anything with >2 arguments or any `bool`.

```dart
// ❌
Rule(true, false, 3);
// ✅
Rule(enabled: true, strict: false, priority: 3);
```
Effective Dart: *"AVOID positional boolean parameters."* Lint:
[`avoid_positional_boolean_parameters`](https://dart.dev/tools/linter-rules/avoid_positional_boolean_parameters).

---

## 6. Extensions, typedefs, enums-with-members

### 6.1 Extensions — when they help

**HELP:**
- Adding presentation concerns to a domain type **without polluting the domain package**. This is the
  key one for you: `PaperSizeL10n` (§1.5) lives in the Flutter layer and keeps `PaperSize` pure.
- Adding `Result` combinators (`map`, `valueOrNull`) without bloating the sealed class.
- Small, local, `extension on BuildContext` conveniences:
  ```dart
  extension ContextX on BuildContext {
    AppLocalizations get l10n => AppLocalizations.of(this)!;
    TextTheme get textTheme => Theme.of(this).textTheme;
    bool get isRtl => Directionality.of(this) == TextDirection.rtl;
  }
  ```
  `context.isRtl` is worth having when you're shipping Arabic.

**HURT:**
- **Extensions are statically resolved.** From the docs: *"You can't invoke extension methods on
  variables of type `dynamic`"* — it's a runtime `NoSuchMethodError`. Combined with `strict-casts`
  this is mostly a non-issue, but never extend `dynamic` or `Object?`.
- Extensions on `Object`/`Object?` pollute autocomplete for the entire codebase. Don't.
- Extensions are **not polymorphic**. `extension on Shape { double area }` will not dispatch to
  `Circle` — it resolves on the static type. If you want dispatch, put the method on the sealed class
  or use a `switch`.
- Two extensions defining the same member on the same type = an ambiguity error the user must resolve
  with `hide`/prefixes. Keep extensions in one place per type.

**Rule:** an extension is for **convenience over a type you don't own**. If you own the type, put the
member on the class.

### 6.2 Typedefs

```dart
typedef Millimetres = double;                                  // documentation only, NO type safety
typedef RulerTick = ({double dx, int index, bool isMajor});    // ✅ names a record shape
typedef TickPainter = void Function(Canvas canvas, RulerTick tick);
typedef CommandAction0<T> = Future<Result<T>> Function();      // from flutter/samples command.dart
```

- ✅ Name **record shapes**. This is the killer use in Dart 3 (endorsed by dart.dev/language/records).
- ✅ Name recurring **function types**, especially callbacks in a public API.
- ⚠️ `typedef Millimetres = double` gives you **no safety at all** — `Millimetres x = 5.0;` and
  `double y = x;` both compile. If you want real unit safety, use an **extension type** (§1.6).
- ❌ Never use the legacy `typedef int Comparison(T a, T b);` syntax. Effective Dart:
  *"DON'T use the legacy typedef syntax."* Lint: `use_function_type_syntax_for_parameters`
  (already in `lints/recommended`).
- ⚠️ Effective Dart also says *"PREFER inline function types over typedefs"* for single-use cases —
  a one-off `bool Function(Event)` reads fine inline.

---

## 7. Async

### 7.1 `Future` vs `Stream` — for an offline app, the answer is mostly `Stream`

Your data source is drift, and drift's `watch()`/`watchSingle()` return `Stream`s that re-emit when
the underlying tables change. That is the correct backbone:

- **`Future`** — one-shot commands: insert a measurement, export a PDF, take a photo, `getCurrentPosition()`.
- **`Stream`** — continuous reads: "the list of measurements", "the current calibration". Let drift
  push, don't poll.

With Riverpod, a drift `Stream` maps directly onto a `StreamProvider` / async notifier, and you never
manually `notifyListeners()`.

**Always cancel.** Enable [`cancel_subscriptions`](https://dart.dev/tools/linter-rules) and
`close_sinks`. In a `StatefulWidget`, `_sub?.cancel()` in `dispose()`. In Riverpod, use
`ref.onDispose`.

### 7.2 `unawaited()` and the two futures lints

```dart
import 'dart:async';

void fireAndForget(Future<void> f) {
  unawaited(f);   // explicitly says "I know, and I don't care"
}
```
[`unawaited`](https://api.dart.dev/dart-async/unawaited.html) is in `dart:async`. It exists so that
[`unawaited_futures`](https://dart.dev/tools/linter-rules/unawaited_futures) can flag every *accidental*
un-awaited future while you opt out of the ones you meant.

Two related lints, choose deliberately:
- **`unawaited_futures`** — flags un-awaited futures *inside `async` bodies*. **Turn this on.**
- **`discarded_futures`** — flags un-awaited futures *anywhere, including sync bodies*. Stricter;
  very noisy in Flutter callbacks (`onPressed: () { doAsyncThing(); }`). **Opinion: on for your
  pure-Dart rule-engine and CLI packages, off for the Flutter app.**

Dart 3.9 added `@awaitNotRequired` (for APIs whose futures are legitimately ignorable) and the
[`unnecessary_unawaited`](https://dart.dev/tools/linter-rules) lint for `unawaited()` calls that
aren't needed (SDK CHANGELOG 3.9.0 / 3.13.0).

### 7.3 Don't use `async` when it has no effect

```dart
// ❌ adds a microtask hop and an extra Future allocation for nothing
Future<int> passthroughBad(Future<int> f) async => await f;
// ✅
Future<int> passthroughGood(Future<int> f) => f;
```
Effective Dart: *"DON'T use `async` when it has no useful effect."* Lint:
`unnecessary_await_in_return`. Dart 3.13 adds `async_return_with_no_await` for the inverse.

**Also:** *"AVOID using `Completer` directly."* Use `async`/`await`. `Completer` is legitimate only
when you are **bridging a callback-based API** into a Future — e.g. a platform channel, or a
`CustomPainter`'s `PictureRecorder` → image callback:

```dart
// Legitimate Completer use: bridging a callback API (image decode) to a Future.
Future<ui.Image> decodeAsset(Uint8List bytes) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, completer.complete);
  return completer.future;
}
```

### 7.4 Error handling in async

```dart
// try/catch works normally inside async functions.
Future<Result<Reading, StorageFailure>> load(String id) async {
  try {
    return Result.ok(await _dao.byId(id));
  } on SqliteException catch (e, st) {
    _log.warning('load($id) failed', e, st);   // keep the stack trace
    return Result.err(StorageFailure.unknown(e.message));
  }
}
```

Gotchas:
- An exception thrown in an **un-awaited** future becomes an *unhandled async error* and will not be
  caught by an enclosing `try`. This is precisely what `unawaited_futures` protects you from.
- `Stream` errors do **not** go through `try/catch` around a `listen()` call. Use
  `stream.listen(onData, onError: ...)` or `await for` inside a `try`.
- `Future.wait` throws on the *first* error and discards the others; use `eagerError: false` plus
  per-future `.catchError` if you need all results (e.g. exporting 20 PDF pages).

### 7.5 Never `async` in `build()`

`build()` must be **pure, synchronous, and cheap** — it is called on every frame that touches the
subtree. Flutter's perf page: *"Avoid repetitive and costly work in `build()` methods."*

```dart
// ❌ NEVER
Widget build(BuildContext context) {
  final rows = await db.allRows();   // doesn't even compile; the async workaround is worse
}

// ❌ ALSO WRONG — creates a NEW future on every rebuild, so FutureBuilder restarts forever
Widget build(BuildContext context) =>
    FutureBuilder(future: db.allRows(), builder: ...);

// ✅ Riverpod: the provider owns the async work and caches it across rebuilds
Widget build(BuildContext context, WidgetRef ref) {
  final rows = ref.watch(measurementsProvider);
  return rows.when(
    data: (r) => MeasurementList(r),
    loading: () => const CircularProgressIndicator(),
    error: (e, _) => ErrorView(e),
  );
}
```

The middle case is the most common real bug in Flutter apps. If you must use `FutureBuilder`, hoist
the future into a `late final` field of a `State`.

**Cold-start note:** don't `await` your writable DB open before the first frame. Open the read-only
asset DB lazily, show a shell frame, and let Riverpod stream the data in. `runApp()` should be reached
with the minimum possible synchronous work in front of it.

---

## 8. DDD in a small app: where it helps, where it's cargo cult

Opinionated, since you asked for opinions.

### Genuinely helps

**1. A pure-Dart domain package with zero Flutter imports.** You already planned this and it is
correct — not because of DDD ideology, but because:
- The CLI content-build tool can `dart run` it with no Flutter SDK, in ~200 ms instead of seconds.
- Its unit tests run under `dart test` (fast, no widget binding).
- The dependency direction is enforced by the pubspec, so it *cannot* rot.

**2. Repositories as `abstract interface class` seams.** Rated **Strongly recommend** by Flutter.
With two databases (read-only reference + writable user) you need a seam anyway to hide "which DB does
this come from" from the UI. And it makes golden tests across six locales feasible: inject a fake
repository with fixed data so goldens are deterministic.

**3. Value objects — but as `extension type`, not as classes.** `Mm`, `Px`, `PxPerMm` in a ruler app
prevent an entire category of bug, at zero runtime cost. This is the *good* version of a value object.

**4. Sealed domain failures.** `MeasureFailure` above is DDD's "domain errors are part of the model"
idea, expressed in a language feature rather than a framework.

### Cargo cult — do not do these

**1. A `UserId` extension type / value class wrapping `String` for every ID in the app.** In an app
with no network and a handful of tables, the compile-time win is near zero and you pay for it at every
drift boundary (drift gives you `int`/`String` columns; you'd write converters both ways). Skip it.

**2. Use-cases / interactors for every operation.** Flutter's own guidance rates a domain layer as
**Conditional**: *"A domain layer is only needed if your application has exceeding complex logic that
crowds your ViewModels, or if you find yourself repeating logic in ViewModels. In very large apps,
use-cases are useful, but in most apps they add unnecessary overhead."* Your **rule engine** is a
legitimate domain layer. `GetMeasurementsUseCase` that forwards one call to one repository is not.

**3. Separate "API model" and "domain model" classes.** Rated **Conditional** by Flutter, and you have
*no network at all*. Your drift row classes *are* your persistence models; map them to domain types
only where the rule engine's types genuinely differ.

**4. `Entity` base classes with an `id` and identity `==`.** This is Java/C# DDD scaffolding.
In Dart, `final class` + `Object.hash` + a plain `id` field does the job.

**5. Aggregate roots / repositories-per-aggregate / domain events.** For a single-user offline app
with a handful of tables, this is pure overhead. You have transactions (drift gives you
`db.transaction { ... }`); that is your consistency boundary.

**Litmus test I use:** *"If I delete this layer, does a specific class of bug become possible?"*
If you can't name the bug, delete the layer.

---

## 9. Common Dart/Flutter code smells, with the fix

| # | Smell | Why it's bad | Fix |
|---|---|---|---|
| 1 | `if (x is A) ... else if (x is B) ...` over a family of types | No exhaustiveness; adding a type silently falls through | `sealed class` + `switch` expression (§1.1) |
| 2 | `value!` sprinkled through a file | Each one is an unchecked runtime cast | Promote via `if (x == null) return`, `switch (x) { null => ..., final v => ... }`, or `if (x case final String v)` (§5.1) |
| 3 | `late` used to silence "must be initialized" | Turns a compile error into a `LateInitializationError` in production | Nullable field, or a constructor initializer list |
| 4 | `Map<String, dynamic>` passed between layers | `dynamic` disables all checking; typos become runtime nulls | Parse once at the boundary with a **map pattern** into a typed record/class (§1.2). Enable `strict-casts` + `avoid_dynamic_calls` |
| 5 | `catch (e) {}` / `catch (e) { print(e); }` | Swallows bugs, no stack trace | `on X catch (e, st)` + `rethrow` or a typed `Result` (§2.4) |
| 6 | `FutureBuilder(future: fetch(), ...)` inline in `build()` | New future per rebuild → infinite reload loop | Hoist to `late final` in `State`, or use a Riverpod provider (§7.5) |
| 7 | Helper methods returning widgets (`Widget _buildHeader()`) | The whole subtree rebuilds with the parent; can't be `const` | Extract a `StatelessWidget` with a `const` constructor. Flutter perf page says so explicitly |
| 8 | Missing `const` on widget constructors | Loses rebuild short-circuiting and canonicalization | `prefer_const_constructors` + `dart fix --apply` (§3.1) |
| 9 | Class with `List`/`Map` fields and hand-written `==` | Verified: `["a"] == ["a"]` is `false` → equality silently broken | `ListEquality`/`Object.hashAll`, or `equatable`, or freezed (§3.4) |
| 10 | `copyWith({String? note})` with `note ?? this.note` | Cannot clear a nullable field | Sentinel `_unset` (§3.3) or freezed |
| 11 | `extends Equatable` on a `StatelessWidget` | O(N²) diffing; Flutter explicitly warns against `==` on Widgets | `const` constructor + `Key` (§3.5) |
| 12 | `enum` + a parallel `Map<E, Config>` lookup | Adding an enum value silently produces a null lookup | Enhanced enum with fields (§1.5) |
| 13 | `Future<void> f() async => await g();` | Pointless async hop and Future allocation | `Future<void> f() => g();` — lint `unnecessary_await_in_return` |
| 14 | Un-awaited future with no `unawaited()` | Errors become unhandled async errors, invisible in tests | `await` it, or `unawaited(...)`; enable `unawaited_futures` |
| 15 | `Completer` used where `async`/`await` works | Manual state machine you can leak or double-complete | `async`/`await`; keep `Completer` only for callback→Future bridges (§7.3) |
| 16 | `package:tuple`, `Pair<A,B>` | Superseded by records; extra dep, worse ergonomics | `({double min, double max})` (§1.3) |
| 17 | `freezed` wrapper mirroring a drift row class | Doubles model count and build time for zero gain | Use drift's generated row class, `@DataClassName` to rename (§3.4) |
| 18 | `*.g.dart` in `.gitignore` | `flutter analyze` fails on a clean clone; CI needs a codegen stage | Commit them; use `.gitattributes` `-diff` (§4.3) |
| 19 | `break;` at the end of every switch case | Dart 3 switch statements don't fall through | Delete. Lint `unnecessary_breaks` |
| 20 | `dynamic` return types / missing return types on public API | Kills inference for every caller | `always_declare_return_types`, `type_annotate_public_apis`, `strict-inference` |
| 21 | `identical(a, b)` used to compare value objects | Only true for `const`-canonicalized or same-instance | `==` |
| 22 | Business logic inside a Widget | Untestable without a widget test; Flutter rates "Do not put logic in widgets" **Strongly recommend** | Move to the notifier/view-model or the rule-engine package |
| 23 | Top-level mutable `var` as global state | Untestable, race-prone, invisible to Riverpod | A Riverpod provider, or a `final` injected dependency |
| 24 | `String` concatenation with `+` in a loop | O(n²) allocation | `StringBuffer` (Flutter perf page) |

---

## 10. Anti-patterns / what NOT to do (summary)

1. **Don't reach for `freezed` reflexively.** Records, `final class`, and `equatable` cover most of it
   now, and freezed's own maintainer tells you to stop using `when`/`map`.
2. **Don't use `package:dartz`.** Last published **2021-12-03** — effectively abandoned. Don't use
   `package:tuple` either — records replace it.
3. **Don't `.gitignore` generated files.** No major Dart repo does (verified: riverpod 170 committed
   `.g.dart`, drift 31, flutter/samples' official architecture app).
4. **Don't write primary-constructor syntax** (`class Point(var int x);`) — Dart 3.13 is unreleased on
   2026-07-27 and it will not compile on Flutter 3.44.6.
5. **Don't override `==` on Widgets** (Flutter perf docs: O(N²)).
6. **Don't put `List`/`Map` fields in records** you compare — verified `false`.
7. **Don't `throw` for expected domain failures**, and **don't `Result`** for programming bugs.
8. **Don't catch `Error`** or use bare `catch (e)`.
9. **Don't use `!` to make the analyzer quiet.** Every `!` is a possible production crash.
10. **Don't build helper-method widgets.** `StatelessWidget` + `const`.
11. **Don't do async work in `build()`**, and don't construct futures there.
12. **Don't add a use-case class per repository call.** Flutter rates the domain layer "Conditional".
13. **Don't cite Medium posts from 2022-2023** for Dart advice — they predate sealed classes, records,
    pattern matching, extension types, dot shorthands, and the rewritten build_runner.

---

## 11. Copy-paste `analysis_options.yaml`

This is my recommendation for the **Flutter app package**. Everything here was verified to be a real
rule name against `dart-lang/sdk/pkg/linter/lib/src/rules` (264 rules) on 2026-07-27.
Note: `sort_pub_dependencies` no longer exists — don't add it.

```yaml
include: package:flutter_lints/flutter.yaml   # 6.0.0, published 2025-05-27
                                              # (which includes package:lints/recommended.yaml)

analyzer:
  language:
    strict-casts: true        # no implicit dynamic -> T
    strict-inference: true    # no silent dynamic from failed inference
    strict-raw-types: true    # no bare List / Map / Future
  errors:
    invalid_annotation_target: ignore   # required if you use freezed + json_annotation
    todo: ignore
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/generated_plugin_registrant.dart"
    - "lib/l10n/generated/**"

linter:
  rules:
    # --- immutability / const ---
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_final_locals
    - prefer_final_in_for_each
    - avoid_final_parameters          # `final` on params is noise; Dart 3.13 bans it in primary ctors

    # --- Dart 3 idioms ---
    - unnecessary_breaks              # switch doesn't fall through
    - exhaustive_cases
    - simplify_variable_pattern       # (:final x) over (x: final x)
    - switch_on_type
    - use_super_parameters
    - prefer_initializing_formals

    # --- types ---
    - always_declare_return_types
    - type_annotate_public_apis
    - avoid_dynamic_calls
    - omit_local_variable_types
    - unnecessary_null_checks
    - avoid_positional_boolean_parameters

    # --- errors ---
    - only_throw_errors
    - avoid_catches_without_on_clauses

    # --- async ---
    - unawaited_futures
    - unnecessary_await_in_return
    - avoid_slow_async_io
    - cancel_subscriptions
    - close_sinks

    # --- hygiene ---
    - directives_ordering
    - combinators_ordering
    - prefer_relative_imports         # matches flutter/samples compass_app
    - require_trailing_commas
    - unnecessary_parenthesis
    - unnecessary_lambdas
    - no_self_assignments
    - no_literal_bool_comparisons
```

For the **pure-Dart rule-engine and CLI packages**, swap the include and add one more rule:

```yaml
include: package:lints/recommended.yaml   # 6.1.0, published 2026-01-30
linter:
  rules:
    # ...same as above, plus:
    - discarded_futures     # stricter; viable outside Flutter callback code
```

`flutter_lints` 6.0.0 (2025-05-27) is the newest release — it has not been bumped in over a year while
`lints` reached 6.1.0 (2026-01-30). Not abandoned (it's a `flutter/packages` first-party package), but
**it is conservative and thin**: it adds only 10 rules on top of `lints/recommended` (`avoid_print`,
`avoid_unnecessary_containers`, `avoid_web_libraries_in_flutter`, `no_logic_in_create_state`,
`prefer_const_constructors_in_immutables`, `sized_box_for_whitespace`, `sort_child_properties_last`,
`use_build_context_synchronously`, `use_full_hex_values_for_flutter_colors`,
`use_key_in_widget_constructors` — verified by reading `flutter/packages/packages/flutter_lints/lib/flutter.yaml`).
**Notably it does NOT include `prefer_const_constructors`.** Add it yourself.

Alternative: `very_good_analysis` 10.3.0 (2026-06-18, actively maintained by Very Good Ventures) is a
much stricter preset. Credible, but it will bury you in warnings on day one and it is a third-party
opinion, not Flutter's. **My recommendation: start from `flutter_lints` + the explicit list above**,
so every strict rule in your project is one you chose.

Run `dart fix --apply` after any lint change — most of these have automated fixes.

---

## 12. Genuine disagreements between credible sources

| Question | Position A | Position B | My recommendation |
|---|---|---|---|
| Error type in `Result` | Flutter's official `Result<T>` uses `Exception` ([design-patterns/result](https://docs.flutter.dev/app-architecture/design-patterns/result)) | A sealed domain-error type gives exhaustive handling | **`Result<T, E>` with a sealed `E`** for domain/rule-engine code; Flutter's single-parameter version is fine for thin I/O wrappers. Reason: the whole point is compile-time coverage, and `Exception` throws it away. |
| freezed vs plain Dart 3 | Flutter recommends freezed/built_value for immutable models (**Recommend**) | freezed's own README says Dart 3 supersedes its union/pattern-matching features | **Both are right about different features.** Use Dart 3 sealed classes for unions; use freezed only for generated `copyWith` (with correct null-clearing) and JSON on non-drift models. |
| Codegen build cost | Flutter's recommendation page warns codegen "can add significant build time" | Measured today: 12.7 s cold / 0.6 s incremental for 30 models on build_runner 2.15.3 | **The warning is now largely stale for small/medium model counts.** The real cost is 21× code amplification and analyzer-version coupling, not wall-clock. |
| `discarded_futures` | dart.dev's async page recommends both `discarded_futures` and `unawaited_futures` | It is extremely noisy in Flutter widget callbacks | **On for pure-Dart packages, off for the Flutter app.** Keep `unawaited_futures` everywhere. |
| Riverpod codegen | riverpod_generator 4.0.6 is actively developed | Riverpod 3 docs present manual and codegen as equal | **Either.** Since you're already running build_runner for drift, codegen is nearly free and removes provider-type mistakes. Not a hill to die on. |
| Extension types for value objects | dart.dev: zero-cost, enforce discipline | dart.dev also: erased at runtime, "somewhat protected" | **Use for units in hot paths (`Mm`, `Px`).** Do not use for IDs in an offline CRUD app — pure ceremony. |

---

## 13. Sources (all fetched or read on 2026-07-27)

**Official Dart language docs**
- https://dart.dev/language/patterns
- https://dart.dev/language/branches
- https://dart.dev/language/records
- https://dart.dev/language/class-modifiers
- https://dart.dev/language/enums
- https://dart.dev/language/extension-methods
- https://dart.dev/language/extension-types
- https://dart.dev/language/error-handling
- https://dart.dev/language/collections (null-aware elements)
- https://dart.dev/null-safety/understanding-null-safety
- https://dart.dev/to/private-named-parameters
- https://dart.dev/effective-dart/design
- https://dart.dev/effective-dart/usage
- https://dart.dev/tools/analysis
- https://dart.dev/tools/build_runner
- https://dart.dev/tools/pub/workspaces
- https://dart.dev/libraries/async/async-await
- https://dart.dev/tools/linter-rules/… (individual rules, each verified to return HTTP 200)

**Official Flutter docs**
- https://docs.flutter.dev/app-architecture/guide
- https://docs.flutter.dev/app-architecture/recommendations
- https://docs.flutter.dev/app-architecture/design-patterns/result
- https://docs.flutter.dev/app-architecture/design-patterns/command
- https://docs.flutter.dev/perf/best-practices

**Official repos read directly (GitHub API)**
- `dart-lang/sdk` → `CHANGELOG.md` (language features per version), `pkg/linter/lib/src/rules` (264 real rule names)
- `flutter/samples` → `compass_app/app/lib/utils/result.dart`, `utils/command.dart`,
  `domain/use_cases/booking/booking_create_use_case.dart`, `domain/models/itinerary_config/…`,
  `analysis_options.yaml`, `pubspec.yaml`, `.gitignore`
- `flutter/flutter` → `packages/flutter/lib/src/widgets/widget_state.dart`,
  `packages/flutter/lib/src/gestures/monodrag.dart` (real `sealed class` usage)
- `flutter/packages` → `packages/flutter_lints/lib/flutter.yaml`
- `dart-lang/core` → `pkgs/lints/lib/recommended.yaml`
- `dart-lang/build` → `build_runner/CHANGELOG.md` (perf history 2.12→2.15)
- `rrousselGit/freezed` → `README.md`, `CHANGELOG.md`
- `felangel/equatable` → `README.md`, `CHANGELOG.md`

**Package metadata (pub.dev JSON API, 2026-07-27)**

| Package | Latest | Published | Status |
|---|---|---|---|
| build_runner | 2.15.3 | 2026-07-27 | Very active |
| freezed | 3.2.5 (4.0.0-dev.3) | 2026-02-03 | Active, Flutter Favorite |
| freezed_annotation | 3.1.0 | 2025-07-02 | Active |
| json_serializable | 6.14.0 | 2026-05-15 | Active (Google) |
| json_annotation | 4.12.0 | 2026-05-15 | Active |
| equatable | 2.1.0 | 2026-07-05 | Active |
| drift / drift_dev | 2.34.2 / 2.34.5 | 2026-07-14 / 2026-07-22 | Very active |
| riverpod / flutter_riverpod | 3.4.1 | 2026-07-26 | Very active |
| riverpod_generator | 4.0.6 | 2026-07-26 | Active |
| riverpod_lint | 3.1.6 | 2026-07-26 | Active |
| built_value | 8.12.6 | 2026-04-30 | Active |
| dart_mappable | 4.8.0 | 2026-04-20 | Active |
| very_good_analysis | 10.3.0 | 2026-06-18 | Active |
| flutter_lints | 6.0.0 | 2025-05-27 | First-party, but 14 months stale |
| lints | 6.1.0 | 2026-01-30 | Active |
| meta | 1.19.0 | 2026-07-09 | Active |
| collection | 1.19.1 | 2024-10-21 | Stable/low-churn (core lib) |
| custom_lint | 0.8.1 | 2025-09-09 | Slowing |
| fpdart | 1.2.0 | 2025-10-29 | Active |
| rxdart | 0.28.0 | 2024-06-14 | Low activity — **you don't need it**, drift + Riverpod cover streams |
| **dartz** | **0.10.1** | **2021-12-03** | ⚠️ **ABANDONED — do not use** |

**Not verified / no evidence found**
- The exact SQLite extended result code for a unique-constraint violation used in the §2.3 drift
  snippet (`2067`) — verify against `package:sqlite3` before shipping.
- Whether `flutter_lints` 7.0.0 is planned — no evidence found.
- Any claim about cold-start impact of specific codegen output size — I measured build time and code
  volume, not app startup. Codegen output is compiled AOT and should not affect startup, but I did not
  measure that.
