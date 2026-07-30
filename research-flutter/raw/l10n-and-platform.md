# Localisation, RTL, and Platform/Build Engineering

**Target toolchain:** Flutter **3.44.6 stable** (released 2026-07-08), Dart **3.12.2**, DevTools 2.57.0.
**Researched:** 2026-07-27.
**Target app:** 100% offline Android + iOS, two drift/SQLite DBs, flutter_riverpod, 6 locales incl. Arabic RTL, pure-Dart domain package, custom-painted ruler, SVG, PDF, camera, GPS, golden tests, cold start < 1.2 s.

Everything marked **[VERIFIED]** was executed on this machine against Flutter 3.44.6 and the output is reproduced verbatim. Everything marked **[DOC]** comes from an official page. Anything I could not confirm is marked **unverified**.

---

## 0. Version facts you must pin your mental model to

| Fact | Value | Source |
|---|---|---|
| `flutter_localizations` pins `intl` **exactly** | `intl: 0.20.2` (not a caret range) | `$FLUTTER_ROOT/packages/flutter_localizations/pubspec.yaml` **[VERIFIED]** |
| Latest `intl` on pub.dev | 0.20.3 (2026-06-25) — **you cannot use it** while depending on `flutter_localizations` | `https://pub.dev/api/packages/intl` **[VERIFIED]** |
| `gen-l10n` `synthetic-package` flag | **DEPRECATED — "This flag cannot be enabled and should be removed."** | `flutter gen-l10n --help` **[VERIFIED]** |
| Languages Flutter auto-resolves to RTL | exactly 6: `ar`, `fa`, `he`, `ps`, `sd`, `ur` | `packages/flutter_localizations/lib/src/widgets_localizations.dart` L28-34 **[VERIFIED]** |
| Analyzer AST API | `analyzer` **13.0.0** renamed `NamedType.name2`→`name`, replaced `NamedExpression` with sealed `Argument`/`NamedArgument` | `~/.pub-cache/.../analyzer-13.0.0/lib/src/dart/ast/ast.dart` L1020, L20174 **[VERIFIED]** |

`flutter pub get` output **[VERIFIED]**:

```
intl 0.20.2 (0.20.3 available)
...
5 packages have newer versions incompatible with dependency constraints.
```

**WHAT:** Declare `intl: any` in `pubspec.yaml`, never a pinned version.
**WHY:** `flutter_localizations` hard-pins `intl` to one exact version. Writing `intl: ^0.20.3` makes your app unresolvable. `any` defers to the SDK's pin, and the generated `app_localizations.dart` header itself tells you to do this ("`intl: any # Use the pinned version from flutter_localizations`").
**SOURCE:** https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization

> ### ⚠️ The official i18n docs page is STALE on one point
> https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization still documents `synthetic-package` as "`true` by default" and tells you to "set the `synthetic-package` flag to false" to use `output-dir`. **That is wrong for Flutter 3.44.6.** The flag is deprecated and cannot be enabled; generation always writes into `arb-dir`/`output-dir`. Any tutorial that mentions `package:flutter_gen/gen_l10n/app_localizations.dart` predates Flutter 3.22 and is dead — the import is now a normal relative path into your own `lib/`.

---

## 1. `l10n.yaml` — copy-pasteable, opinionated

This is the exact file I ran successfully against 3.44.6 **[VERIFIED]**:

```yaml
# l10n.yaml — project root, next to pubspec.yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-dir: lib/l10n
output-localization-file: app_localizations.dart
output-class: AppL10n

# Generated getters are non-null: AppL10n.of(context).foo, no `!`.
nullable-getter: false

# Every message must carry an @-metadata block. Forces descriptions for translators.
required-resource-attributes: true

# Lets you write literal { } in messages by wrapping in single quotes.
use-escaping: true

# Machine-readable completeness report. THE hook for CI. See §6.
untranslated-messages-file: l10n_untranslated.json

# Run `dart format` on generated output so the format check in CI stays green.
format: true
```

And in `pubspec.yaml`:

```yaml
flutter:
  generate: true          # REQUIRED, or gen-l10n exits 1
  uses-material-design: true
```

**[VERIFIED]** Omitting `generate: true` fails with exit code 1 and:
```
Attempted to generate localizations code without having the flutter: generate flag turned on.
```

### Option reference (authoritative, from `flutter gen-l10n --help` on 3.44.6) **[VERIFIED]**

| Option | Default | Use it? |
|---|---|---|
| `arb-dir` | `lib/l10n` | yes |
| `output-dir` | same as `arb-dir` | yes, set explicitly |
| `template-arb-file` | `app_en.arb` | yes |
| `output-localization-file` | `app_localizations.dart` | yes |
| `output-class` | `AppLocalizations` | shorten to `AppL10n` — you type it everywhere |
| `untranslated-messages-file` | none | **yes — this is your CI gate** |
| `nullable-getter` | `true` | **set `false`** — kills `!` at every call site |
| `required-resource-attributes` | `false` | **set `true`** — forces translator context |
| `use-escaping` | `false` | set `true` |
| `relax-syntax` | `false` | **leave false** — you want `{` typos to be errors |
| `use-named-parameters` | `false` | optional; named params read better for 3+ placeholders |
| `format` | `false` | set `true` |
| `preferred-supported-locales` | alphabetical | set `[en]` so `en` wins ties |
| `header` / `header-file` | none | useful to add `// coverage:ignore-file` |
| `use-deferred-loading` | `false` | **web only — irrelevant to you, leave off** |
| `synthetic-package` | — | **DEPRECATED, remove it** |
| `gen-inputs-and-outputs-list` | none | skip |
| `project-dir` | cwd | skip |
| `suppress-warnings` | `false` | **never enable** |

> **Gotcha [VERIFIED]:** if `l10n.yaml` exists, command-line flags are *ignored entirely*:
> `Because l10n.yaml exists, the options defined there will be used instead.`
> So `flutter gen-l10n --untranslated-messages-file=x.json` silently does nothing when you have an `l10n.yaml`. Put it in the YAML.

---

## 2. ARB files: format, metadata, and writing for translators

ARB = [App Resource Bundle](https://github.com/google/app-resource-bundle), a JSON dialect. Flutter uses a subset.

### 2.1 The template file

```json
{
  "@@locale": "en",

  "appTitle": "Ruler",
  "@appTitle": {
    "description": "Application name shown in the Android task switcher and iOS app switcher. Max 20 chars."
  },

  "nItems": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@nItems": {
    "description": "Number of saved measurements shown on the history screen header.",
    "placeholders": {
      "count": { "type": "num", "format": "decimalPattern" }
    }
  },

  "measuredOn": "Measured on {date} at {len}",
  "@measuredOn": {
    "description": "Subtitle of a saved measurement row. {date} is the capture date, {len} is the length in the user's chosen unit.",
    "placeholders": {
      "date": { "type": "DateTime", "format": "yMMMd" },
      "len":  { "type": "double", "format": "decimalPatternDigits",
                "optionalParameters": { "decimalDigits": 1 } }
    }
  }
}
```

**Recognised keys** (from `packages/flutter_tools/lib/src/localizations/gen_l10n_types.dart`) **[VERIFIED]**:

- Top level: `@@locale` (L636), and `@<key>` metadata blocks.
- Inside `@<key>`: `description` (L478), `placeholders`.
- Inside a placeholder: `example`, `type`, `format`, `optionalParameters`, `isCustomDateFormat` (L234-238).

`@@context`, `@@last_modified`, `@@author` are ARB-spec keys that Flutter's tool **ignores** — do not rely on them.

### 2.2 `@@locale` must match the filename **[VERIFIED]**

`gen_l10n_types.dart` L663-683:

```
The locale specified in @@locale and the arb filename do not match.
Current @@locale value: ...
```

**WHAT:** Always write `@@locale` explicitly in every ARB, including the template.
**WHY:** Filename parsing is the fallback; an explicit `@@locale` turns a silent mis-file into a hard build error. My CI script in §6 asserts both.

### 2.3 Descriptions become dartdoc — this is the real payoff

The `description` is emitted as the doc comment on the generated member **[VERIFIED]**, so your IDE shows it at every call site:

```dart
  /// Number of saved measurements.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String nItems(num count);
```

**WHAT:** Write descriptions that state (a) where the string appears, (b) what each placeholder is, (c) any length constraint.
**WHY:** Translators receive the ARB with no screenshots. "Save" is a verb on a button and a noun in a settings header, and Arabic renders them completely differently. `required-resource-attributes: true` makes an empty description a build failure for plurals and my script (§6) makes it a failure for all messages.

**Only translate the template's `@` blocks.** Translated ARBs (`app_ar.arb`) should contain `@@locale` + plain keys, no `@key` metadata. Metadata in a translated file is ignored, and duplicating it means it drifts.

### 2.4 Plurals — and the Arabic trap

ICU syntax: `{count, plural, =0{...} =1{...} zero{...} one{...} two{...} few{...} many{...} other{...}}`. Only `other` is required.

**`=0` is an exact-value match. `zero` is a CLDR *category*.** They are not the same thing, and the difference bites in Arabic.

**English template** — two forms are enough, plus an `=0` special case for nicer copy:
```json
"nItems": "{count, plural, =0{No items} =1{1 item} other{{count} items}}"
```

**Arabic** needs **all six** CLDR categories:
```json
"nItems": "{count, plural, zero{لا عناصر} one{عنصر واحد} two{عنصران} few{{count} عناصر} many{{count} عنصرًا} other{{count} عنصر}}"
```

**[VERIFIED]** — real widget-test output from Flutter 3.44.6 with the generated `AppL10n`:

```
ar nItems(0)   = لا عناصر
ar nItems(1)   = عنصر واحد
ar nItems(2)   = عنصران
ar nItems(3)   = 3 عناصر
ar nItems(11)  = 11 عنصرًا
ar nItems(100) = 100 عنصر
```

The generated Arabic code **[VERIFIED]** (`lib/l10n/app_localizations_ar.dart`):

```dart
  @override
  String nItems(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString عنصر',
      many: '$countString عنصرًا',
      few: '$countString عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا عناصر',
    );
    return '$_temp0';
  }
```

**WHAT:** Give translators of Arabic (and Russian, Polish, Welsh) all six slots. Do not assume the English shape transfers.
**WHY:** If Arabic only supplies `other`, `nItems(2)` reads "2 عنصر" which is ungrammatical. CLDR is the authority; `Intl.pluralLogic` implements it.
**SOURCE:** https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization (Placeholders, plurals, and selects)

### 2.5 Select

```json
"pronoun": "{gender, select, male{he} female{she} other{they}}",
"@pronoun": { "description": "...", "placeholders": { "gender": {"type": "String"} } }
```
Comparison is **case-sensitive** — `pronoun("Male")` falls through to `other`. **[DOC]**

### 2.6 Escaping literal braces

Requires `use-escaping: true`. Wrap in single quotes; a literal apostrophe is two single quotes:

```json
{ "helloWorld": "Hello! '{Isn''t}' this a wonderful day?" }
```
→ `"Hello! {Isn't} this a wonderful day?"` **[DOC]**

**Watch out:** turning on `use-escaping` changes the meaning of *every existing apostrophe*. French and Italian ARBs are full of them (`l'application`). Turn it on at project start, not midway.

### 2.7 Number and date formats — the exact allowed values

The tool validates `format` against a hard-coded allowlist and generates a `NumberFormat`/`DateFormat` constructor call. Anything else is a build error.

**`_validNumberFormats`** (`gen_l10n_types.dart` L93-114) **[VERIFIED]**:
`compact`, `compactCurrency`, `compactSimpleCurrency`, `compactLong`, `currency`, `decimalPattern`, `decimalPatternDigits`, `decimalPercentPattern`, `percentPattern`, `scientificPattern`, `simpleCurrency`

**Those accepting `optionalParameters`** (`_numberFormatsWithNamedParameters`, L119-128) **[VERIFIED]**:
`compact`, `compactCurrency`, `compactSimpleCurrency`, `compactLong`, `currency`, `decimalPatternDigits`, `decimalPercentPattern`, `simpleCurrency`
— note `decimalPattern`, `percentPattern` and `scientificPattern` take **positional** args and will reject `optionalParameters`.

**`validDateFormats`** (L31-81) **[VERIFIED]** — 41 entries:
`d, E, EEEE, LLL, LLLL, M, Md, MEd, MMM, MMMd, MMMEd, MMMM, MMMMd, MMMMEEEEd, QQQ, QQQQ, y, yM, yMd, yMEd, yMMM, yMMMd, yMMMEd, yMMMM, yMMMMd, yMMMMEEEEd, yQQQ, yQQQQ, H, Hm, Hms, j, jm, jms, jmv, jmz, jv, jz, m, ms, s`

Two extras the docs barely mention **[VERIFIED from source]**:
- **Combine formats with `+`**: `_dateFormatPartsDelimiter = '+'` (L83), e.g. `"format": "yMMMd+jm"`.
- **`isCustomDateFormat: true`** (L238, used at `gen_l10n.dart` L161-178) lets you pass a raw ICU skeleton not on the allowlist. Error message: *"...or set `isCustomDateFormat` attribute..."*.

**Recommendation:** prefer `j` / `jm` over `H` / `Hm` for times. `j` resolves to 12- or 24-hour based on locale; hard-coding `H` gives Americans a 24-hour clock.

---

## 3. Numbering systems: the single biggest localisation trap in Dart

This is the finding that will most affect your Arabic build, and it contradicts what most people assume.

### 3.1 Dart's `intl` has **no numbering-system API**. `-u-nu-` is silently ignored.

**[VERIFIED]** — real output, intl 0.20.2 under Dart 3.12.2:

```
en     num=1,234,567.89        date=Jul 27, 2026     time=2:05 PM
ar     num=1,234,567.89        date=27 يوليو 2026     time=2:05 م
ar_EG  num=١٬٢٣٤٬٥٦٧٫٨٩         date=٢٧ يوليو ٢٠٢٦     time=٢:٠٥ م
ar_DZ  num=1.234.567,89        date=27 جويلية 2026    time=2:05 م
ar_SA  num=1,234,567.89        date=27 يوليو 2026     time=2:05 م   (resolved -> ar)
ar_MA  num=1,234,567.89        date=27 يوليو 2026     time=2:05 م   (resolved -> ar)
fa     num=۱٬۲۳۴٬۵۶۷٫۸۹         date=۲۷ ژوئیه ۲۰۲۶     time=۱۴:۰۵
bn     num=১২,৩৪,৫৬৭.৮৯          date=২৭ জুল, ২০২৬

--- Unicode -u-nu- extension probe ---
ar-u-nu-arab -> 1,234,567  (resolved locale: ar)     <-- IGNORED
ar_u_nu_arab -> 1,234,567  (resolved locale: ar)     <-- IGNORED
en-u-nu-arab -> 1,234,567  (resolved locale: en)     <-- IGNORED
ar@numbers=arab -> ERROR: Invalid argument(s): Invalid locale "ar@numbers=arab"
```

**Conclusions, all verified:**

1. **Plain `ar` uses LATIN digits** (`1,234,567.89`), not Arabic-Indic. This is correct per CLDR (modern `ar` root defaults to `latn`), and it surprises almost everyone.
2. **Only `ar_EG` in Dart's data uses Arabic-Indic digits** (`٠١٢٣`, U+0660), with U+066C group and U+066B decimal separators.
3. **`ar_DZ` uses Latin digits with European separators** (`1.234.567,89`) and a *different month name* (`جويلية` vs `يوليو`).
4. **`ar_SA`, `ar_MA`, `ar_AE`… silently fall back to `ar`.** Dart's `number_symbols_data.dart` contains **only three** Arabic entries: `ar`, `ar_DZ`, `ar_EG` **[VERIFIED by enumerating the file: 118 locales total]**.
5. **The `-u-nu-` Unicode extension is accepted as a string and then discarded.** No error, no effect. There is no `numberingSystem` parameter on `NumberFormat` or `DateFormat`.

Locales in Dart intl 0.20.2 whose *default* digits are non-Latin **[VERIFIED, complete list]**:
`ar_EG` (٠), `as` (০), `bn` (০), `fa` (۰), `mr` (०), `my` (၀), `ne` (०), `ps` (۰).

### 3.2 How to actually choose a numbering system

`numberFormatSymbols` is a **public, mutable top-level `Map`**. That is the supported lever. **[VERIFIED — both approaches produce `١٬٢٣٤٬٥٦٧٫٨٩`]**

```dart
import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

/// Call once during bootstrap, before any NumberFormat is constructed.
/// Makes locale `ar` render Arabic-Indic digits by aliasing it to ar_EG's symbols.
void useArabicIndicDigits() {
  numberFormatSymbols['ar'] = numberFormatSymbols['ar_EG']!;
}
```

Or register a brand-new symbol set (verified working):

```dart
final base = numberFormatSymbols['ar'] as NumberSymbols;
numberFormatSymbols['ar_Arab_custom'] = NumberSymbols(
  NAME: 'ar_Arab_custom',
  DECIMAL_SEP: '٫', GROUP_SEP: '٬', PERCENT: '٪؜',
  ZERO_DIGIT: '٠',                       // <-- this is the whole mechanism
  PLUS_SIGN: '؜+', MINUS_SIGN: '؜-',
  EXP_SYMBOL: base.EXP_SYMBOL, PERMILL: base.PERMILL,
  INFINITY: base.INFINITY, NAN: base.NAN,
  DECIMAL_PATTERN: base.DECIMAL_PATTERN,
  SCIENTIFIC_PATTERN: base.SCIENTIFIC_PATTERN,
  PERCENT_PATTERN: base.PERCENT_PATTERN,
  CURRENCY_PATTERN: base.CURRENCY_PATTERN,
  DEF_CURRENCY_CODE: base.DEF_CURRENCY_CODE,
);
```

`NumberFormat` computes `zeroOffset = symbols.ZERO_DIGIT.codeUnitAt(0) - asciiZero` and offsets every digit (`intl-0.20.2/lib/src/intl/number_format.dart` L369-370) **[VERIFIED]**. `ZERO_DIGIT` *is* the numbering system.

### 3.3 My recommendation for your app

**Ship Latin digits for `ar` (i.e. do nothing), and expose an in-app "Numerals: Western / Arabic" toggle only if user research demands it.**

**WHY:**
- Plain `ar` → Latin digits is what CLDR says and what Android/iOS system UIs do for most Arabic regions. Egypt is the notable exception.
- Your app is a **ruler**. Measurement readouts, tick labels and a numeric scale are being compared against a physical object. Arabic-Indic digits on a custom-painted ruler add glyph-width and baseline problems in the painter for zero user benefit outside Egypt.
- Mutating the global `numberFormatSymbols` map is process-wide and order-dependent — it must happen before the first `NumberFormat` is built, and it will silently corrupt golden tests that run in a shared isolate. If you do it, do it in `main()` before `runApp`, and reset it in `setUp`/`tearDown` of any test that depends on digits.

If you must transliterate for display only (never for parsing), this is the whole job **[VERIFIED]**:

```dart
String toArabicIndic(String s) => s.replaceAllMapped(
    RegExp(r'[0-9]'),
    (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x30 + 0x0660));
```

**Do not** apply this to strings you later `int.parse`. And never apply it to your drift SQL or PDF metadata.

---

## 4. RTL

### 4.1 How direction is decided

`GlobalWidgetsLocalizations` maps locale → `TextDirection`. **All locales are LTR except these six language codes** **[VERIFIED, `widgets_localizations.dart` L28-34]**:

```
ar - Arabic     fa - Farsi      he - Hebrew
ps - Pashto     sd - Sindhi     ur - Urdu
```

Note what is *absent*: `ckb` (Sorani Kurdish), `dv` (Dhivehi), `yi` (Yiddish), and the legacy code `iw`. If one of your six locales is in that set you must supply direction yourself.

**[VERIFIED]** widget test — `MaterialApp(locale: Locale('ar'))` with `AppL10n.localizationsDelegates` yields `Directionality.of(context) == TextDirection.rtl` with no extra code.

### 4.2 Directional vs physical geometry — measured, not asserted

**[VERIFIED]** widget test output:

```
EdgeInsetsDirectional(start:40)  ltr.left=40.0  rtl.left=0.0    <-- flips
EdgeInsets(left:40)              ltr.left=40.0  rtl.left=40.0   <-- never flips
```

| Physical (avoid) | Directional (use) |
|---|---|
| `EdgeInsets.only(left:, right:)` | `EdgeInsetsDirectional.only(start:, end:)` |
| `Alignment.centerLeft` | `AlignmentDirectional.centerStart` |
| `BorderRadius.only(topLeft:)` | `BorderRadiusDirectional.only(topStart:)` |
| `Positioned(left:, right:)` | `PositionedDirectional(start:, end:)` |
| `MainAxisAlignment.start` on a `Row` | already direction-aware — fine |
| `Icons.arrow_back` | `Icons.arrow_back` + `matchTextDirection`, or `Directionality`-aware icon choice |

All four directional classes confirmed present in 3.44.6: `EdgeInsetsDirectional` (`painting/edge_insets.dart:742`), `AlignmentDirectional` (`painting/alignment.dart:509`), `BorderRadiusDirectional` (`painting/border_radius.dart:603`), `PositionedDirectional` (`widgets/basic.dart:5256`) **[VERIFIED]**.

**WHAT:** Ban `EdgeInsets.only(left:/right:)` and `Alignment.*Left/*Right` in UI code by lint (§6.3). Use symmetric/all `EdgeInsets` freely — `EdgeInsets.all(8)` and `EdgeInsets.symmetric(horizontal: 8)` are direction-neutral and fine.
**WHY:** A physical `left` inset is a bug that only manifests for 1 of your 6 locales and will not be caught by any test that runs in `en`.

### 4.3 Forcing an LTR island — your ruler

**[VERIFIED]** widget test: nesting `Directionality` inside an Arabic `MaterialApp` gives `outer=TextDirection.rtl inner=TextDirection.ltr`.

```dart
/// The measuring surface is a physical instrument: its zero is always at the
/// left edge and it always reads left-to-right, exactly like the real object
/// the user is holding it against. Locale must not mirror it.
class RulerSurface extends StatelessWidget {
  const RulerSurface({super.key, required this.lengthMm});
  final double lengthMm;

  @override
  Widget build(BuildContext context) {
    // Capture the app's real direction BEFORE overriding, so chrome that
    // should still mirror (labels, callouts) can opt back in.
    final appDirection = Directionality.of(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: CustomPaint(
        painter: RulerPainter(
          lengthMm: lengthMm,
          // Digits in tick labels follow the *app* locale, not the forced LTR.
          numberFormat: NumberFormat.decimalPattern(
            Localizations.localeOf(context).toString(),
          ),
        ),
        child: Semantics(
          // Screen-reader description must stay in the app's direction.
          textDirection: appDirection,
          label: AppL10n.of(context).rulerSemanticLabel(lengthMm),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
```

**WHY this, not a `Transform`:** `Directionality` is an `InheritedWidget` (specifically `_UbiquitousInheritedWidget` in 3.44.6). Overriding it changes *layout* semantics for the subtree — `EdgeInsetsDirectional`, `Row` child order, text alignment — with **zero** effect on hit-testing coordinates. A `Transform` with a flip matrix mirrors pixels but leaves hit-test geometry inverted-but-transformed, and mirrors your tick *labels* into unreadable text. For a ruler you want unmirrored geometry AND unmirrored glyphs — that is exactly `Directionality`.

**Important:** `Directionality` does **not** affect a `CustomPainter`'s canvas. `paint(Canvas, Size)` gives you a raw canvas whose origin is always top-left. If you want a painter to mirror, you must do it yourself.

### 4.4 Mirroring inside a `CustomPainter` — the canonical SDK pattern

Flutter's own framework does this in exactly two places. Copy them, don't invent.

`painting/decoration_image.dart` L711-716 **[VERIFIED]**:
```dart
  if (flipHorizontally) {
    final double dx = -(rect.left + rect.width / 2.0);
    canvas.translate(-dx, 0.0);
    canvas.scale(-1.0, 1.0);
    canvas.translate(dx, 0.0);
  }
```

`material/progress_indicator.dart` L743-745 **[VERIFIED]**:
```dart
        canvas.save();
        canvas.scale(-1, 1);
        canvas.translate(-size.width, 0);
        // ... draw ...
        canvas.restore();
```

So, if you ever *do* want a mirrored painter:

```dart
@override
void paint(Canvas canvas, Size size) {
  if (textDirection == TextDirection.rtl) {
    canvas.save();
    canvas.scale(-1, 1);
    canvas.translate(-size.width, 0);
  }
  _drawTicks(canvas, size);
  if (textDirection == TextDirection.rtl) canvas.restore();
  // Draw TEXT AFTER restore, or every glyph comes out mirrored.
  _drawLabels(canvas, size);
}
```

**Pass `textDirection` into the painter explicitly and include it in `shouldRepaint`.** A painter cannot read `Directionality` — it has no `BuildContext`.

```dart
@override
bool shouldRepaint(RulerPainter old) =>
    old.lengthMm != lengthMm || old.textDirection != textDirection;
```

`Matrix4.rotationY(math.pi)` appears in **zero** places in the framework source **[VERIFIED grep]** — it is a blog-post idiom, it introduces a perspective-capable 4×4 transform where a 2D scale suffices, and it moves the subtree onto a separate layer. Prefer `canvas.scale(-1, 1)`, or `Transform(transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0), alignment: Alignment.center, ...)` at the widget level.

### 4.5 Testing RTL

The framework's own convention is a `buildFrame(TextDirection)` helper reused across both directions — e.g. `packages/flutter/test/material/list_tile_test.dart` L344-349 **[VERIFIED]**:

```dart
    Widget buildFrame(TextDirection textDirection) {
      return MediaQuery(
        data: const MediaQueryData(),
        child: Directionality(
          textDirection: textDirection,
          child: Material(...),
```

Your version, parameterised over locales, with golden names carrying the locale — the framework names goldens `...icon.rtl.png` / `...icon.ltr.png` (`material/animated_icons_test.dart` L243, L268) **[VERIFIED]**:

```dart
// test/golden/measurement_screen_golden_test.dart
const goldenLocales = <Locale>[
  Locale('en'), Locale('ar'), Locale('fr'),
  Locale('es'), Locale('de'), Locale('ur'),
];

Widget harness(Locale locale, Widget child) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: child,
    );

void main() {
  for (final locale in goldenLocales) {
    testWidgets('measurement screen — ${locale.languageCode}', (tester) async {
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(harness(locale, const MeasurementScreen()));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MeasurementScreen),
        matchesGoldenFile('goldens/measurement_${locale.languageCode}.png'),
      );
    });
  }

  testWidgets('ruler stays LTR in Arabic', (tester) async {
    late TextDirection rulerDir;
    await tester.pumpWidget(harness(const Locale('ar'), Builder(
      builder: (c) => RulerSurface(
        lengthMm: 150,
        // probe injected for the test
      ),
    )));
    // assert via a Builder placed inside RulerSurface, or:
    rulerDir = Directionality.of(
      tester.element(find.byType(CustomPaint).first),
    );
    expect(rulerDir, TextDirection.ltr);
  });
}
```

**Two hard-won practical points:**

1. **Goldens need a font, or every locale renders identical empty boxes.** `flutter test` uses a test font (Ahem-like) that has no Arabic coverage. You must load a real font with Arabic glyphs in `flutter_test_config.dart` via `FontLoader`, otherwise your `ar` golden is indistinguishable from your `en` golden and the test is worthless. *(Mechanism is `FontLoader` + `loadFontFromList`; exact setup is unverified here — validate before relying on it.)*
2. **Goldens are host-platform-dependent.** Generate and verify them on one platform in CI (Linux) and mark the job as the only source of truth, or they will churn on every developer's macOS machine.

### 4.6 `intl`'s `Bidi` helpers (rarely needed, occasionally essential)

**[VERIFIED]** available on `Bidi` in intl 0.20.2:
```
Bidi.isRtlLanguage('ar') = true    ('he','fa','ur' = true; 'en' = false)
Bidi.detectRtlDirectionality('مرحبا') = true
Bidi.enforceLtrInText(s)  -> wraps in U+202A LRE ... U+202C PDF
Bidi.enforceRtlInText(s)  -> wraps in U+202B RLE ... U+202C PDF
Bidi.estimateDirectionOfText(s), startsWithRtl, endsWithRtl, hasAnyRtl,
Bidi.guardBracketInText(s), Bidi.normalizeHebrewQuote(s), Bidi.stripHtmlIfNeeded(s)
```
API surface confirmed at `intl-0.20.2/lib/src/intl/bidi.dart` L60-317. Note the casing: `enforceLtrInText`, **not** `enforceLTRInText` (I hit that compile error).

**Use case for you:** a user-entered measurement label ("Kitchen wall 2") shown inside Arabic UI chrome will scramble bracket/number ordering. `Bidi.enforceLtrInText` around user-supplied Latin content inside an RTL paragraph fixes it. Do **not** blanket-apply it — Flutter's text engine already does full UBA bidi correctly for well-formed content.

---

## 5. Accessibility (adjacent, but it interacts with l10n)

The accessibility docs were reorganised; the old single page is now a hub with `/ui/accessibility/ui-design-and-styling`, `/ui/accessibility/assistive-technologies`, `/ui/accessibility/accessibility-testing`.

The Guideline API, straight from the docs **[DOC]** (https://docs.flutter.dev/ui/accessibility/accessibility-testing):

```dart
// test/a11y_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Follows a11y guidelines', (tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(const AccessibleApp());

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));  // 48x48
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));      // 44x44
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));      // 3:1 @18pt+
    handle.dispose();
  });
}
```

**Run this per locale.** German and Arabic strings are longer than English; a button that is 48 dp tall in `en` can wrap and break the tap-target guideline in `de`, and `labeledTapTargetGuideline` will catch any icon button whose `tooltip`/`semanticLabel` you forgot to localise.

Release checklist from the docs **[DOC]**: active interactions do something; screen-reader (TalkBack/VoiceOver) describes every control; contrast ≥ 4.5:1; no context switching while typing; tap targets ≥ 48×48; errors undoable with suggested corrections; usable in colourblind/greyscale; legible at very large text scale.

**For your custom-painted ruler specifically:** a `CustomPaint` contributes **no** semantics. You must wrap it in a `Semantics` node with a `label` that reads the current measurement, or the ruler is completely invisible to TalkBack/VoiceOver. Make that label a localised message with a `double` placeholder.

---

## 6. Enforcing localisation completeness in CI

### 6.1 The critical fact: `gen-l10n` does NOT fail on missing translations

**[VERIFIED]** I deleted one key from `app_ar.arb` and ran `flutter gen-l10n`:

```
=== EXIT CODE: 0 ===
--- untranslated file ---
{
  "ar": [
    "onlyInEnglish"
  ]
}
```

And the generated Arabic class **silently hard-codes the English string** **[VERIFIED]**:

```dart
  @override
  String get onlyInEnglish => 'This key is deliberately missing from Arabic';
```

Confirmed in the tool source (`gen_l10n.dart` L1445-1465): untranslated messages go through `logger.printStatus` — **info level, exit code 0**.

> **This is the most important operational finding in this document.** Nothing in the default Flutter toolchain will ever tell you your Arabic build is 40% English. A widget test in `ar` will pass. A golden test in `ar` will pass (it will just show English text). You must build the gate yourself.

### 6.2 ARB completeness gate — `tool/check_arb.dart` **[VERIFIED WORKING]**

Ran against my probe project; correctly caught the missing key and exited 1:
```
lib/l10n/app_ar.arb: MISSING key "onlyInEnglish"

1 ARB problem(s).
EXIT=1
```

```dart
// tool/check_arb.dart
// Fails CI when any locale is missing a key that exists in the template ARB,
// when a locale has keys the template doesn't, or when a message lacks a description.
// Usage: dart run tool/check_arb.dart lib/l10n
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final dir = Directory(args.isEmpty ? 'lib/l10n' : args.first);
  final template = File('${dir.path}/app_en.arb');
  final tpl = jsonDecode(template.readAsStringSync()) as Map<String, dynamic>;

  final templateKeys = tpl.keys.where((k) => !k.startsWith('@')).toSet();
  final errors = <String>[];

  // 1. every template message must carry a description for translators
  for (final k in templateKeys) {
    final meta = tpl['@$k'];
    if (meta is! Map || (meta['description'] as String?)?.trim().isEmpty != false) {
      errors.add('${template.path}: "$k" has no @$k.description');
    }
  }

  for (final f in dir.listSync().whereType<File>()
      .where((f) => f.path.endsWith('.arb') && !f.path.endsWith('app_en.arb'))) {
    final m = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    final keys = m.keys.where((k) => !k.startsWith('@')).toSet();
    final declared = m['@@locale'] as String?;
    final fromName = RegExp(r'app_(.+)\.arb$').firstMatch(f.path)?.group(1);
    if (declared == null) {
      errors.add('${f.path}: missing "@@locale"');
    } else if (declared != fromName) {
      errors.add('${f.path}: @@locale "$declared" != filename "$fromName"');
    }

    for (final k in templateKeys.difference(keys)) {
      errors.add('${f.path}: MISSING key "$k"');
    }
    for (final k in keys.difference(templateKeys)) {
      errors.add('${f.path}: ORPHAN key "$k" (not in template)');
    }
  }

  if (errors.isEmpty) {
    print('ARB check passed.');
    return;
  }
  errors.forEach(stderr.writeln);
  stderr.writeln('\n${errors.length} ARB problem(s).');
  exit(1);
}
```

**Cheaper alternative if you prefer zero Dart:** after `flutter gen-l10n`, assert the report file is empty.
```bash
flutter gen-l10n
test "$(jq -c . l10n_untranslated.json)" = '{}' \
  || { echo "::error::Untranslated messages:"; cat l10n_untranslated.json; exit 1; }
```
This is one line and catches the missing-key case, but **not** orphan keys, missing `@@locale`, or missing descriptions. Use the Dart script.

### 6.3 Catching hardcoded user-facing strings

**There is no built-in lint for this.** **[VERIFIED]** — I searched the entire Dart linter rule registry (`dart-lang/sdk/pkg/linter/lib/src/rules.dart`, 545 lines, every registered rule) for `intl|localiz|hardcod`; the only match is `PreferIntLiterals`, which is about `1.0` vs `1` and unrelated. `flutter_lints` 6.0.0 adds nothing here either.

So write one. `tool/check_hardcoded_strings.dart` **[VERIFIED WORKING]** — run against the stock `flutter create` counter app it produced:

```
lib/main.dart:33: hardcoded user-facing string in MyHomePage(title:) -> 'Flutter Demo Home Page'
lib/main.dart:107: hardcoded user-facing string in Text() -> 'You have pushed the button this many times:'

2 hardcoded user-facing string(s).
EXIT=1
```

```dart
// tool/check_hardcoded_strings.dart
// Flags string literals passed to user-facing widget parameters.
// Run: dart run tool/check_hardcoded_strings.dart lib
// Requires: dev_dependencies: analyzer: ^13.0.0
import 'dart:io';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// Widgets whose first positional String arg is shown to the user.
const _positionalTextWidgets = {'Text', 'SelectableText'};

/// Named args that are shown to the user on any widget.
const _userFacingNamed = {
  'label', 'labelText', 'hintText', 'helperText', 'errorText', 'tooltip',
  'title', 'subtitle', 'semanticLabel', 'semanticsLabel', 'message',
};

class _Visitor extends RecursiveAstVisitor<void> {
  _Visitor(this.unit, this.path, this.hits);
  final CompilationUnit unit;
  final String path;
  final List<String> hits;

  void _report(AstNode n, String what) {
    final line = unit.lineInfo.getLocation(n.offset).lineNumber;
    hits.add('$path:$line: hardcoded user-facing string in $what -> ${n.toSource()}');
  }

  bool _isNonEmptyLiteral(Expression e) =>
      e is StringLiteral && (e.stringValue ?? 'x').trim().isNotEmpty;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // analyzer >=13: NamedType.name (was name2), Argument is a sealed class
    // whose subtypes expose `argumentExpression`; NamedArgument.name is a Token.
    final name = node.constructorName.type.name.lexeme;
    for (final arg in node.argumentList.arguments) {
      final expr = arg.argumentExpression;
      if (arg is NamedArgument) {
        if (_userFacingNamed.contains(arg.name.lexeme) && _isNonEmptyLiteral(expr)) {
          _report(expr, '$name(${arg.name.lexeme}:)');
        }
      } else if (_positionalTextWidgets.contains(name) && _isNonEmptyLiteral(expr)) {
        _report(expr, '$name()');
      }
    }
    super.visitInstanceCreationExpression(node);
  }
}

Future<void> main(List<String> args) async {
  final root = Directory(args.isEmpty ? 'lib' : args.first).absolute;
  final collection = AnalysisContextCollection(includedPaths: [root.path]);
  final hits = <String>[];
  for (final ctx in collection.contexts) {
    for (final file in ctx.contextRoot.analyzedFiles()) {
      if (!file.endsWith('.dart')) continue;
      if (file.contains('/l10n/app_localizations') ||
          file.endsWith('.g.dart') ||
          file.endsWith('.freezed.dart')) continue;   // generated code is exempt
      final result = ctx.currentSession.getParsedUnit(file);
      if (result is! ParsedUnitResult) continue;
      result.unit.accept(
          _Visitor(result.unit, file.substring(root.parent.path.length + 1), hits));
    }
  }
  if (hits.isEmpty) {
    print('No hardcoded user-facing strings found.');
    return;
  }
  hits.forEach(stderr.writeln);
  stderr.writeln('\n${hits.length} hardcoded user-facing string(s).');
  exit(1);
}
```

> **Analyzer 13 API note [VERIFIED]:** every tutorial you will find uses `NamedExpression`, `arg.name.label.name` and `NamedType.name2`. **All three were removed in analyzer 13.0.0.** The AST was refactored onto Dart 3 sealed classes: `sealed class Argument { Expression get argumentExpression; }` with `abstract final class NamedArgument implements Argument { Token get name; }`. Pin `analyzer: ^13.0.0` and use the code above.

Uses `getParsedUnit` (syntax only, no resolution) so it runs in ~1 s on a large `lib/`. If you want to distinguish `Text('literal')` from `Text(someVar)` more precisely, switch to `getResolvedUnit` — 10-50× slower but type-aware.

### 6.4 `analysis_options.yaml`

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-raw-types: true
  errors:
    # Missing translations are already handled by tool/check_arb.dart.
    # Make anything the analyzer *can* see fatal.
    todo: ignore
    unused_import: error
    unused_local_variable: error
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.drift.dart"
    - "lib/l10n/app_localizations*.dart"
    - "lib/gen/**"

linter:
  rules:
    - always_use_package_imports
    - avoid_print
    - prefer_const_constructors
    - prefer_const_declarations
    - unawaited_futures
    - use_build_context_synchronously
```

`flutter_lints` is at **6.0.0** in the local cache alongside `lints` 6.1.0 **[VERIFIED]**.

For genuinely custom lints (e.g. "ban `EdgeInsets.only(left:)` in `lib/ui/`"), the live option is **`custom_lint`** (invertase) — **0.8.1, published 2025-09-09** **[VERIFIED via pub.dev API]**. It is ~10 months since last release; maintained but not fast-moving. Weigh that against a 60-line grep in CI.

> ### 🪦 ABANDONED: `dart_code_metrics`
> Last pub.dev release **5.7.6 on 2023-07-16**. The GitHub repo `dart-code-checker/dart-code-metrics` is **`archived=true`, last push 2023-07-16** **[VERIFIED via `gh api`]**. It went commercial as DCM (dcm.dev). **Do not add the open-source package to a new 2026 project.** Any guide recommending it is ≥3 years stale.

---

## 7. Build and release engineering

### 7.1 Build modes

| Mode | Compilation | Use |
|---|---|---|
| `--debug` | JIT, assertions on, hot reload, observatory | development only |
| `--profile` | AOT, tracing kept, DevTools attachable | **your cold-start budget must be measured here, on a real low-end device** |
| `--release` | AOT, assertions stripped, no VM service | ship |

`--release` is the default for `flutter build` **[VERIFIED from `flutter build apk --help`]**.

**Cold start must be measured in `--profile` on physical hardware.** Debug-mode startup on an emulator is 5-10× slower and tells you nothing about a 1.2 s budget.

### 7.2 `--dart-define` and `--dart-define-from-file`

From `flutter build apk --help` **[VERIFIED verbatim]**:

```
-D, --dart-define=<foo=bar>
      Additional key-value pairs that will be available as constants from the
      String.fromEnvironment, bool.fromEnvironment, and int.fromEnvironment constructors.
      Multiple defines can be passed by repeating "--dart-define" multiple times.

    --dart-define-from-file=<use-define-config.json|.env>
      The path of a .json or .env file containing key-value pairs that will be available
      as environment variables. These can be accessed using the String.fromEnvironment,
      bool.fromEnvironment, and int.fromEnvironment constructors.
      Multiple defines can be passed by repeating "--dart-define-from-file" multiple times.
      Entries from "--dart-define" with identical keys take precedence over entries from these files.
```

**[VERIFIED end-to-end]** — `config/prod.json`:
```json
{
  "APP_ENV": "prod",
  "ENABLE_DEV_TOOLS": false,
  "REFERENCE_DB_VERSION": 7
}
```
```bash
flutter test --dart-define-from-file=config/prod.json test/define_test.dart
```
Output: `APP_ENV=prod ENABLE_DEV_TOOLS=false REFERENCE_DB_VERSION=7` — all three assertions passed. **Note that JSON booleans and integers are typed correctly**, which is the main reason to prefer `.json` over `.env` (where everything is a string).

Consume them in a single typed config class:

```dart
// lib/core/build_config.dart
abstract final class BuildConfig {
  static const env = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
  static const enableDevTools =
      bool.fromEnvironment('ENABLE_DEV_TOOLS', defaultValue: true);
  static const referenceDbVersion =
      int.fromEnvironment('REFERENCE_DB_VERSION', defaultValue: 0);

  static bool get isProd => env == 'prod';
}
```

**WHY a single class:** `String.fromEnvironment` is only const-folded when written as a `const` initialiser. Scattering `String.fromEnvironment` calls through the codebase defeats tree-shaking of dev-only branches; centralising them lets the AOT compiler drop whole subtrees in release.

**WHAT NOT TO DO:** never put a secret in a dart-define. It is a plaintext constant in the binary; `strings libapp.so` finds it. (Not that your offline app has any secrets — which is a nice property, keep it.)

**Gotcha:** changing a dart-define changes the build fingerprint. Run `flutter clean` if you ever see stale values; incremental builds have historically been unreliable about this. Also remember dart-defines must be passed identically to `flutter test`, or your tests exercise the defaults.

### 7.3 Flavors

**[DOC]** https://docs.flutter.dev/deployment/flavors

`android/app/build.gradle.kts`:
```kotlin
android {
    flavorDimensions += "default"
    productFlavors {
        create("dev") {
            dimension = "default"
            applicationIdSuffix = ".dev"
            resValue(type = "string", name = "app_name", value = "Ruler dev")
        }
        create("production") {
            dimension = "default"
            resValue(type = "string", name = "app_name", value = "Ruler")
        }
    }
}
```
with `android:label="@string/app_name"` in `main/AndroidManifest.xml`.

Read the flavor at runtime — no plugin needed:
```dart
import 'package:flutter/services.dart';   // exports `appFlavor`

void main() {
  if (appFlavor == 'production') { /* ... */ }
  runApp(const MyApp());
}
```
`appFlavor` is `null` when built without `--flavor`. **[DOC]**

**Newer pubspec capabilities worth knowing [DOC]:** per-flavor assets and a default flavor:
```yaml
flutter:
  assets:
    - assets/common/
    - path: assets/dev/
      flavors: [dev]
default-flavor: production
```

**iOS** uses schemes + build configurations rather than product flavors; `--flavor <name>` maps to the Xcode **scheme** of that name, and you need matching `Debug-<flavor>`/`Release-<flavor>`/`Profile-<flavor>` configurations. **Opinion: for a two-flavor offline app, flavors are probably not worth the Xcode maintenance burden.** `--dart-define-from-file` plus a single flavor gets you build-time config with zero Xcode surgery. Add flavors only when you need *different bundle IDs installed side by side*.

### 7.4 Obfuscation

**[DOC]** https://docs.flutter.dev/deployment/obfuscate + `flutter build apk --help` **[VERIFIED]**

```bash
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info=build/symbols/1.4.0 \
  --dart-define-from-file=config/prod.json
```

Facts:
- `--obfuscate` **must** be combined with `--split-debug-info`. **[VERIFIED from help text]**
- Release builds only. Web unsupported (minified instead).
- Supported targets: `aar, apk, appbundle, ios, ios-framework, ipa, linux, macos, macos-framework, windows`.
- **`--split-debug-info` cannot be combined with `--analyze-size`.** **[VERIFIED from help text]** — so your size-audit build and your shipping build are two different invocations.
- Symbolize crashes: `flutter symbolize -i <trace> -d build/symbols/1.4.0/app.android-arm64.symbols`.
- **Archive the symbols directory per release**, keyed by version. Without it, every production stack trace is garbage forever.

**Caveats that will bite you [DOC + help text]:**
- `Object.runtimeType`, `Type.toString`, **`Enum.toString`**, `Symbol.toString` all return obfuscated results. *(The docs page claims "Enum names are not obfuscated" while the CLI help explicitly lists `Enum.toString` as affected — the CLI help is generated from the tool and is the more reliable source. **Do not persist `enum.toString()` into SQLite either way.**)*
- Anything comparing `runtimeType.toString()` to a literal breaks.

**Direct relevance to your drift schema:** if you store enum values by *name* in SQLite, obfuscation can rename them and your read-back breaks in release only — a bug that never reproduces in debug. Store enums by **index** or by an explicit `const String` code you control. drift's `TypeConverter` with an explicit mapping is the safe pattern.

`--split-debug-info` alone (without `--obfuscate`) is worth it regardless: it strips Dart symbols out of the binary and measurably shrinks the app.

### 7.5 Removing `android.permission.INTERNET` in release — fully verified

#### First, the thing nobody tells you

**`flutter create` never puts INTERNET in `main`.** It ships it in the `debug` and `profile` source sets only. **[VERIFIED — `packages/flutter_tools/templates/app/android.tmpl/app/src/{debug,profile}/AndroidManifest.xml.tmpl`]**:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

`ls android/app/src/` on a fresh project → `debug main profile` **[VERIFIED]**. So **if no plugin contributes INTERNET, your release build already has none and you need to do nothing.** Verify before you engineer.

#### When you *do* need `tools:node="remove"`

Third-party plugin AARs merge their own manifests into yours. A camera/PDF/analytics dependency can silently add INTERNET. Then you need to strip it — **in a `release` source set**, so debug hot reload keeps working.

**The experiment [VERIFIED]:** I added INTERNET + ACCESS_NETWORK_STATE to `main/AndroidManifest.xml` (simulating a plugin), created `android/app/src/release/AndroidManifest.xml`, and built both variants.

`android/app/src/release/AndroidManifest.xml`:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.INTERNET" tools:node="remove"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" tools:node="remove"/>
</manifest>
```

**Result — release APK [VERIFIED via `aapt2 dump permissions`]:**
```
package: com.example.l10nprobe
permission: com.example.l10nprobe.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
uses-permission: name='com.example.l10nprobe.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
```
**No INTERNET. No ACCESS_NETWORK_STATE.**

**Control — debug APK, same source tree [VERIFIED]:**
```
package: com.example.l10nprobe
uses-permission: name='android.permission.INTERNET'
uses-permission: name='android.permission.ACCESS_NETWORK_STATE'
permission: com.example.l10nprobe.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION
uses-permission: name='com.example.l10nprobe.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
```

**And the merger's own blame report proves the mechanism [VERIFIED]** — `build/app/outputs/logs/manifest-merger-release-report.txt`:
```
uses-permission#android.permission.INTERNET
ADDED from .../android/app/src/main/AndroidManifest.xml:3:5-66
REJECTED from .../android/app/src/main/AndroidManifest.xml:3:5-66
	tools:node
		ADDED from .../android/app/src/release/AndroidManifest.xml:3:65-84
```

**Answers to your specific questions:**
- **Which source set?** `android/app/src/release/AndroidManifest.xml`. Build-type source sets are merged per variant, so `release` applies to release only. If you use flavors, `src/productionRelease/` is more specific and also works.
- **How does `tools:node="remove"` work?** The merger processes higher-priority manifests last. A `remove` marker on a matching node (matched by `android:name` for `uses-permission`) causes the merged node to be `REJECTED`. You must declare the `tools` namespace on `<manifest>`. `tools:` attributes are stripped from the final manifest.
- **Does it need `tools:node="remove"` on the app or a `<uses-permission>` re-declaration?** You re-declare the `<uses-permission>` element with the same `android:name` and add the marker. That is exactly what the snippet above does.

**Make it a permanent CI assertion**, because a dependency bump can reintroduce it:
```bash
flutter build apk --release
AAPT=$(ls $ANDROID_HOME/build-tools/*/aapt2 | tail -1)
if "$AAPT" dump permissions build/app/outputs/flutter-apk/app-release.apk \
     | grep -q 'android.permission.INTERNET'; then
  echo "::error::Release APK requests INTERNET. This app must be fully offline."
  exit 1
fi
```

**iOS equivalent:** there is no INTERNET permission to remove — iOS grants network access implicitly. Your offline guarantee on iOS is a *code* property, not a manifest one. Enforce it by (a) shipping no networking plugins, (b) a CI check that `pubspec.lock` contains no `http`/`dio`/`web_socket_channel`, and (c) `grep -r "dart:io.*HttpClient\|package:http" lib/` failing the build. Optionally add App Transport Security denial in `Info.plist` as defence-in-depth (`NSAllowsArbitraryLoads=false` is already the default; there is no "block all" switch — *unverified whether any ATS key fully disables networking*).

### 7.6 App Bundle vs APK

| | `flutter build appbundle` | `flutter build apk` |
|---|---|---|
| Play Store | **required** since Aug 2021 | not accepted for new apps |
| Per-device ABI/density/language splitting | yes, done by Play | no (one fat APK) |
| `--split-per-abi` | n/a | yes, produces one APK per ABI |
| Direct sideload / F-Droid / enterprise MDM | needs `bundletool` | yes |

My fat universal release APK measured **43.4 MB** with three ABIs bundled; `lib/arm64-v8a/libflutter.so` alone is 11.5 MB and `lib/x86_64/libflutter.so` is 12.9 MB **[VERIFIED from `unzip -v`]**.

**Recommendation:** ship **`appbundle`** to Play (Play strips the unused ABIs, roughly halving the download), and build `apk --split-per-abi` only for direct-distribution builds. **Never ship a universal APK** — you are forcing every user to download an x86_64 engine they will never execute.

> **Warning for your app:** Play's App Bundle **language splitting** will strip locale resources the device does not use. That applies to Android `res/` resources, not to Flutter's `flutter_assets`, so your ARB-generated Dart is safe. But if you ever add Android-side localized `res/values-ar/strings.xml` (e.g. for the launcher label per §7.3), a user who switches their phone to Arabic *after* install may not have that split. Disable language splitting in `android { bundle { language { enableSplit = false } } }` if the launcher name must always be correct. *(Mechanism per AGP docs; not empirically verified here.)*

---

## 8. CI: a real GitHub Actions workflow

### 8.1 What the reputable repos actually do

**`flutter/samples`** — `.github/workflows/main.yml` **[VERIFIED via `gh api`]**. It pins actions by **commit SHA**, matrixes over ubuntu + macos, and delegates to a Dart script:

```yaml
name: Main Branch CI
permissions: read-all
on:
  push: { branches: [ main ] }
  pull_request: { branches: [ main ] }
  workflow_dispatch:
  schedule:
    - cron: "0 0 * * *"
defaults:
  run: { shell: bash }
jobs:
  flutter-tests:
    runs-on: ${{ matrix.os }}
    strategy:
      fail-fast: false
      matrix:
        flutter_version: [stable]
        os: [ubuntu-latest, macos-latest]
    steps:
      - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1
      - uses: actions/setup-java@03ad4de0992f5dab5e18fcb136590ce7c4a0ac95
        with: { distribution: 'zulu', java-version: '17' }
      - uses: subosito/flutter-action@e938fdf56512cc96ef2f93601a5a40bde3801046
        with: { channel: ${{ matrix.flutter_version }} }
      - run: flutter pub get && dart tool/ci_script.dart
```

Its `tool/ci_script.dart` runs, per package **[VERIFIED]**:
```dart
    await _runCommand('dart', ['analyze', '--fatal-infos', '--fatal-warnings'], ...);
    await _runCommand('dart', ['format', '.'], ...);
    await _runCommand('flutter', ['test', '--no-pub'], ...);
```

**`localsend/localsend`** — a large, well-regarded production Flutter app. `.github/workflows/ci.yml` **[VERIFIED via `gh api`]** pins the Flutter version in `env`, splits format/test into separate jobs, and — the detail worth stealing — **deletes generated code before the format check**:
```yaml
      - name: Remove gen directory (app)
        working-directory: app
        run: rm -rf lib/gen
      - name: Check format (app)
        working-directory: app
        run: dart format --set-exit-if-changed lib test
```

**Note the disagreement between them:** `flutter/samples` runs bare `dart format .` (which *rewrites* files and always exits 0 — it does not gate anything); `localsend` runs `dart format --set-exit-if-changed`. **`localsend` is right.** Use `--set-exit-if-changed`.

Latest action versions **[VERIFIED via `gh api .../releases/latest`]**: `subosito/flutter-action` **v2.23.0**, `actions/checkout` **v7.0.1**, `actions/setup-java` **v5.6.0**, `actions/upload-artifact` **v7.0.1**.

### 8.2 The workflow I recommend for this app

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push: { branches: [main] }
  pull_request: { branches: [main] }
  workflow_dispatch:

permissions: read-all

env:
  FLUTTER_VERSION: "3.44.6"

defaults:
  run: { shell: bash }

jobs:
  # ---------------------------------------------------------------- analyse
  static:
    name: Format, analyze, l10n gates
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - run: flutter pub get

      # Regenerate l10n + drift/riverpod codegen so we test what we ship.
      - run: flutter gen-l10n
      - run: dart run build_runner build --delete-conflicting-outputs

      # GATE 1: gen-l10n exits 0 on missing translations, so assert explicitly.
      - name: Localisation completeness
        run: dart run tool/check_arb.dart lib/l10n

      # GATE 2: no untranslated messages slipped through gen-l10n itself.
      - name: gen-l10n untranslated report must be empty
        run: |
          test -f l10n_untranslated.json || { echo "report missing"; exit 1; }
          if [ "$(jq -c . l10n_untranslated.json)" != "{}" ]; then
            echo "::error::Untranslated messages:"; cat l10n_untranslated.json; exit 1
          fi

      # GATE 3: no hardcoded user-facing strings.
      - name: Hardcoded string scan
        run: dart run tool/check_hardcoded_strings.dart lib

      # GATE 4: this app is 100% offline — no networking packages, ever.
      - name: Forbid networking dependencies
        run: |
          if grep -nE '^\s+(http|dio|web_socket_channel|grpc|firebase_[a-z_]+):' pubspec.lock; then
            echo "::error::Networking package in dependency graph."; exit 1
          fi

      # Generated code must not be reformatted by hand; check the rest.
      - name: Format check
        run: |
          dart format --set-exit-if-changed \
            $(git ls-files '*.dart' \
              | grep -v -e '\.g\.dart$' -e '\.freezed\.dart$' -e '\.drift\.dart$' \
                        -e '^lib/l10n/app_localizations' -e '^lib/gen/')

      - name: Analyze
        run: flutter analyze --fatal-infos --fatal-warnings

  # ------------------------------------------------------------------ tests
  test:
    name: Unit, widget, golden
    runs-on: ubuntu-latest   # goldens are host-dependent: ONE platform only
    steps:
      - uses: actions/checkout@v7
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - run: flutter pub get
      - run: flutter gen-l10n
      - run: dart run build_runner build --delete-conflicting-outputs

      # The pure-Dart domain package has no Flutter dependency: test it with `dart`.
      - name: Domain package tests
        working-directory: packages/rule_engine
        run: dart pub get && dart test

      - name: App tests with coverage
        run: flutter test --coverage --dart-define-from-file=config/prod.json

      # Strip generated code from coverage. Using `lcov` rather than the
      # `remove_from_coverage` package: that package's last pub.dev release is
      # 2.0.0 on 2021-04-17 [VERIFIED] — 5 years stale, do not adopt it.
      - name: Strip generated code from coverage
        run: |
          sudo apt-get update -qq && sudo apt-get install -y lcov
          lcov --remove coverage/lcov.info \
            '*.g.dart' '*.freezed.dart' '*.drift.dart' \
            '*/l10n/app_localizations*.dart' '*/gen/*' \
            -o coverage/lcov.info --ignore-errors unused

      - uses: actions/upload-artifact@v7
        if: failure()
        with:
          name: golden-failures
          path: "**/failures/**"

  # ------------------------------------------------------------------ build
  build-android:
    name: Android release bundle
    runs-on: ubuntu-latest
    needs: [static, test]
    steps:
      - uses: actions/checkout@v7
      - uses: actions/setup-java@v5
        with: { distribution: zulu, java-version: '17' }
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true
      - run: flutter pub get

      - name: Build app bundle
        run: |
          flutter build appbundle --release \
            --obfuscate --split-debug-info=build/symbols \
            --dart-define-from-file=config/prod.json

      # Offline guarantee, asserted on the real artifact.
      - name: Assert release APK has no INTERNET permission
        run: |
          flutter build apk --release --target-platform=android-arm64 \
            --dart-define-from-file=config/prod.json
          AAPT=$(ls $ANDROID_HOME/build-tools/*/aapt2 | tail -1)
          "$AAPT" dump permissions build/app/outputs/flutter-apk/app-release.apk | tee perms.txt
          if grep -q 'android.permission.INTERNET' perms.txt; then
            echo "::error::Release build requests INTERNET."; exit 1
          fi

      - uses: actions/upload-artifact@v7
        with:
          name: symbols
          path: build/symbols       # keep forever; needed to symbolize crashes
```

**Design notes / why:**
- **`--fatal-infos --fatal-warnings`** matches what `flutter/samples` enforces. Infos become errors, so `prefer_const_constructors` violations cannot accumulate.
- **Goldens run on exactly one OS.** Font rasterisation differs between Linux and macOS; a matrix over both guarantees permanent golden churn.
- **Codegen runs in CI**, so a stale checked-in `.g.dart` cannot mask a broken build. (Decide separately whether to commit generated files; if you do, add a job that fails when `git diff --exit-code` is dirty after codegen.)
- **The offline assertion is on the artifact, not the source.** That is the only check a transitive dependency cannot defeat.
- Pin `FLUTTER_VERSION` exactly (3.44.6), not `stable`. `stable` moves under you and will break a build on a random Tuesday.

---

## 9. Assets

### 9.1 Declaration and variants **[DOC]**

```yaml
flutter:
  assets:
    - assets/icons/          # trailing slash = files DIRECTLY in this dir only
    - assets/icons/tools/    # subdirectories need their own entry
    - assets/db/reference.db
```

Resolution variants are the one exception — declare only the base asset and Flutter bundles `2.0x/`, `3.0x/` automatically:
```
assets/images/ruler_bg.png
assets/images/2.0x/ruler_bg.png
assets/images/3.0x/ruler_bg.png
```
**SOURCE:** https://docs.flutter.dev/ui/assets/assets-and-images

**For your SVG assets this is irrelevant and that is the point** — an SVG is resolution-independent, so ship one file and skip the `2.0x`/`3.0x` ladder entirely. `flutter_svg` is now **2.3.0 (2026-05-08)** and lives at **`flutter/packages/third_party/packages/flutter_svg`** **[VERIFIED via `gh api`]** — i.e. it has been adopted into the official Flutter packages monorepo. That is a strong maintenance signal. The sibling package `flutter_svg_test` exists in the same tree and gives you SVG-aware test matchers.

### 9.2 `flutter_gen` — maintenance check passed

**[VERIFIED]**
- `flutter_gen` / `flutter_gen_runner` **5.15.0, published 2026-07-13** (2 weeks before this research).
- Recent commits include *"upgrade: update flutter to 3.44.4"* (2026-06-27) — actively tracking your exact Flutter line.
- Repo: `github.com/FlutterGen/flutter_gen`.

**Verdict: safe to adopt.** Configuration **[VERIFIED from repo README]**:

```yaml
dev_dependencies:
  build_runner: ^2.12.0     # required: flutter_gen_runner now uses post-process builders
  flutter_gen_runner:

flutter_gen:
  output: lib/gen/
  line_length: 120
  integrations:
    flutter_svg: true       # gives Assets.icons.foo.svg() returning SvgPicture
    image: true
  assets:
    exclude:
      - assets/db/**        # keep the 800 KB DB out of the generated class
```

Usage: `dart run build_runner build` → `Assets.icons.ruler.svg()` instead of `SvgPicture.asset('assets/icons/ruler.svg')`.

**WHY adopt it:** a typo in an asset path is a *runtime* exception (`Unable to load asset:`) that only fires when that screen is opened. `flutter_gen` turns it into a compile error. With SVG + custom painting + PDF templates you will have dozens of asset paths.

**WHY exclude the DB:** you never load the DB via `Image`/`SvgPicture`; you load it once via `rootBundle.load` behind a repository. A generated accessor adds noise and encourages loading it from the widget tree.

**Alternative:** if you do not want `build_runner` in the loop, `flutter_gen` also ships a standalone CLI (`flutter_gen` package, `fluttergen` command). Given you already run `build_runner` for **drift** and **riverpod_generator**, the runner integration is free.

### 9.3 Shipping the pre-seeded SQLite file — measured trade-off

**[VERIFIED experiment]** I generated an 827,392-byte SQLite file, declared it as a Flutter asset, and built release APKs with and without AGP's `noCompress`:

| Config | Method in APK | Stored size | APK size |
|---|---|---|---|
| default | `Defl:N` | 87,819 B (**89% smaller**) | 43.5 MB |
| `androidResources { noCompress += "db" }` | `Stored` | 827,392 B | 44.2 MB |

For reference, in the same APK **[VERIFIED]** all `flutter_assets` are `Defl:N` while native libraries are `Stored`:
```
11581856  Stored  11581856   0%  lib/arm64-v8a/libflutter.so
 3146640  Stored   3146640   0%  lib/arm64-v8a/libapp.so
     117  Defl:N        58  50%  assets/flutter_assets/AssetManifest.bin
  257628  Defl:N    115944  55%  assets/flutter_assets/packages/cupertino_icons/assets/CupertinoIcons.ttf
```

**Recommendation: keep the default (compressed), and copy the DB out on first run.**

**WHY:**
- SQLite files are mostly zeroes and repeated page headers — 89% compression is real and free download savings.
- You **cannot open a SQLite database directly from a Flutter asset** regardless of compression. `rootBundle.load()` hands you a `ByteData` in memory; SQLite needs a seekable file on disk. So you are copying it to `getApplicationSupportDirectory()` on first launch either way, and `noCompress` buys you nothing.
- `noCompress` only pays off if you plan to `mmap` the file through Android's `AssetManager` file descriptor (offset+length) from native code — a path drift does not expose.

**Cold-start implications for your 1.2 s budget:**
1. `rootBundle.load('assets/db/reference.db')` materialises the **entire file in memory** as a `ByteData`. There is no streaming asset API. An 80 MB reference DB is an 80 MB transient allocation and a likely OOM on a low-end device. Keep the shipped DB small, or split it into chunked assets you concatenate to disk.
2. **Do the copy exactly once**, guarded by a version marker, not a file-exists check:
   ```dart
   // Bump REFERENCE_DB_VERSION via --dart-define-from-file when the asset changes.
   final marker = File('${dir.path}/reference.v${BuildConfig.referenceDbVersion}');
   if (!marker.existsSync()) { await _copyFromAsset(); marker.createSync(); }
   ```
   A plain `exists()` check means a shipped DB update never lands on upgraded installs.
3. **Never do the copy on the platform thread during the first frame.** Run it in an isolate (`Isolate.run`) or behind a Riverpod `AsyncNotifier` that renders a splash, or you will blow the budget on exactly the devices you care about.
4. Mark the copied DB **excluded from iOS/Android backup** — it is reproducible from the asset and only bloats iCloud/Google backups. On iOS that is the `NSURLIsExcludedFromBackupKey` resource value; use `getApplicationSupportDirectory()` (not Documents) so it is not surfaced in Files.app. *(API-level details unverified here.)*

---

## 10. Anti-patterns — what NOT to do

**Localisation**

1. **Do not trust `flutter gen-l10n`'s exit code.** It returns **0** with missing translations and bakes English into the translated class. **[VERIFIED]** Gate on `l10n_untranslated.json` or `tool/check_arb.dart`.
2. **Do not import `package:flutter_gen/gen_l10n/app_localizations.dart`.** That was the synthetic-package path, removed. Use a relative import into `lib/l10n/`.
3. **Do not set `synthetic-package:` in `l10n.yaml`.** Deprecated: *"This flag cannot be enabled and should be removed."* **[VERIFIED]**
4. **Do not pin `intl`.** `flutter_localizations` pins it exactly (0.20.2); write `intl: any`. **[VERIFIED]**
5. **Do not enable `relax-syntax` or `suppress-warnings`.** They convert your ICU typos into silently wrong strings.
6. **Do not put `@key` metadata in translated ARBs.** Template only.
7. **Do not ship an Arabic plural with only `other`.** Arabic uses all six CLDR categories. **[VERIFIED]**
8. **Do not concatenate localised fragments** (`'${l10n.you_have} $n ${l10n.items}'`). Word order differs per language and it is unfixable by translators. Use one message with placeholders.
9. **Do not enable `use-escaping` mid-project.** It retroactively changes the meaning of every apostrophe in French/Italian ARBs.
10. **Do not assume `ar` means Arabic-Indic digits.** It means Latin digits in Dart intl. **[VERIFIED]**
11. **Do not pass `ar-u-nu-arab`.** It is silently ignored. **[VERIFIED]** There is no numbering-system API.
12. **Do not use `Intl.message()` / `intl_translation`** for new code. That is the pre-gen-l10n workflow the docs keep for historical reasons; `intl_translation` is a separate legacy package. Use ARB + `flutter gen-l10n`.

**RTL**

13. **Do not use `EdgeInsets.only(left:/right:)`, `Alignment.centerLeft`, `Positioned(left:)`, or `BorderRadius.only(topLeft:)`** in localised UI. Verified: `EdgeInsets.only(left:40)` stays at `left=40` in RTL; `EdgeInsetsDirectional.only(start:40)` correctly moves to `left=0`. **[VERIFIED]**
14. **Do not use `Matrix4.rotationY(math.pi)` to mirror.** It appears **zero** times in the Flutter framework **[VERIFIED grep]**. Use `canvas.scale(-1, 1)` (painter) or a 2D scale `Transform` (widget).
15. **Do not expect `Directionality` to mirror a `CustomPainter`.** Painters get a raw canvas; pass `textDirection` in explicitly and include it in `shouldRepaint`.
16. **Do not draw text inside a mirrored canvas transform** — every glyph comes out backwards. Restore first, then draw labels.
17. **Do not test only in English.** Every golden and every a11y guideline test should run across all six locales.
18. **Do not run golden tests on a matrix of OSes.** Pick one.
19. **Do not assume Flutter knows your RTL language.** Only `ar, fa, he, ps, sd, ur` resolve to RTL automatically. **[VERIFIED]**

**Build / platform**

20. **Do not add `tools:node="remove"` for INTERNET without checking first.** `flutter create` already keeps INTERNET out of `main` — it lives in `debug`/`profile` only. **[VERIFIED]** Removing a permission that was never there is cargo cult.
21. **Do not put the `remove` marker in `main`** — that kills hot reload. Put it in `src/release/`. **[VERIFIED working]**
22. **Do not ship a universal APK.** `libflutter.so` for x86_64 alone is 12.9 MB of dead weight. **[VERIFIED]** Use `appbundle`.
23. **Do not put secrets in `--dart-define`.** They are plaintext in the binary.
24. **Do not use `--obfuscate` without archiving `--split-debug-info` output per release.** Every crash report becomes permanently unreadable.
25. **Do not persist `enum.toString()` or `runtimeType.toString()` into SQLite** — obfuscation renames them, breaking release builds only.
26. **Do not combine `--split-debug-info` with `--analyze-size`.** Rejected by the tool. **[VERIFIED]**
27. **Do not run `dart format .` in CI without `--set-exit-if-changed`.** It rewrites files and always passes, gating nothing.
28. **Do not format- or analyze-check generated files.** Exclude `*.g.dart`, `*.drift.dart`, `*.freezed.dart`, `lib/l10n/app_localizations*`, `lib/gen/`.
29. **Do not measure cold start in debug mode or on an emulator.** Use `--profile` on the real low-end device.
30. **Do not add `dart_code_metrics`.** Archived since 2023-07-16; went commercial. **[VERIFIED]**
31. **Do not `flutter gen-l10n --some-flag` when `l10n.yaml` exists** — CLI flags are ignored entirely. **[VERIFIED]**

---

## 11. Source index

**Official documentation**
- Internationalization: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization *(stale on `synthetic-package` — see §0)*
- Accessibility hub: https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility
- Accessibility testing: https://docs.flutter.dev/ui/accessibility/accessibility-testing
- Flavors: https://docs.flutter.dev/deployment/flavors
- Obfuscation: https://docs.flutter.dev/deployment/obfuscate
- Assets and images: https://docs.flutter.dev/ui/assets/assets-and-images
- ARB spec: https://github.com/google/app-resource-bundle

**Primary source read directly (local Flutter 3.44.6 SDK)**
- `packages/flutter_tools/lib/src/localizations/gen_l10n_types.dart` — ARB metadata keys, `validDateFormats`, `_validNumberFormats`, `_numberFormatsWithNamedParameters`, `@@locale` validation
- `packages/flutter_tools/lib/src/localizations/gen_l10n.dart` — untranslated-message handling (L1445-1465), `isCustomDateFormat`
- `packages/flutter_tools/templates/app/android.tmpl/app/src/{debug,profile,main}/AndroidManifest.xml.tmpl`
- `packages/flutter_localizations/pubspec.yaml` — the `intl: 0.20.2` pin
- `packages/flutter_localizations/lib/src/widgets_localizations.dart` — the six RTL languages
- `packages/flutter/lib/src/painting/decoration_image.dart` L711-716, `packages/flutter/lib/src/material/progress_indicator.dart` L743-745 — canonical canvas mirroring
- `packages/flutter/test/material/list_tile_test.dart` L344-349 — `buildFrame(TextDirection)` test idiom
- `~/.pub-cache/hosted/pub.dev/intl-0.20.2/lib/number_symbols_data.dart`, `lib/src/intl/number_format.dart` L369-370, `lib/src/intl/bidi.dart`
- `~/.pub-cache/hosted/pub.dev/analyzer-13.0.0/lib/src/dart/ast/ast.dart` L1020, L20174

**Repositories read via `gh`**
- `flutter/samples` — `.github/workflows/main.yml`, `tool/ci_script.dart`
- `localsend/localsend` — `.github/workflows/ci.yml`
- `FlutterGen/flutter_gen` — README, commit history
- `flutter/packages/third_party/packages/flutter_svg`
- `dart-code-checker/dart-code-metrics` — confirmed archived
- `dart-lang/sdk` — `pkg/linter/lib/src/rules.dart` (lint rule registry)

**pub.dev API** (`https://pub.dev/api/packages/<name>`) — version and publish dates for `intl`, `flutter_gen`, `flutter_gen_runner`, `custom_lint`, `dart_code_metrics`, `slang`, `easy_localization`, `intl_utils`, `arb_utils`, `flutter_svg`, `drift`.

**Not consulted:** Medium, dev.to, SEO listicles. No blog is cited in this document.
