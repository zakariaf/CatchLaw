# Arabic and Other Scripts

Scope: how the Lonja ramp resolves per script — the Naskh stack, the optical uplift, the zero
tracking rule, numeral faces, line-height headroom, and mixed-script rows. Layout direction, ARB
authoring, ICU plurals and numeral-system selection belong to `i18n-rtl-l10n`.

## The six locales

`ar` (Arabic, RTL) · `en` · `es` · `gl` (Galician) · `pt-BR` · `fr`. Only `ar` changes the type
resolution; the five Latin locales share the ramp verbatim. `gl` and `pt-BR` carry diacritics
(`ría`, `Ameixa`, `Jurumirim`) that the serif stack renders natively — no fallback needed.

## Arabic resolution rules

The ramp is not one table with a swapped `fontFamily`. For `ar`, `LonjaType.of(context)` returns a
variant where four things change together.

| Property        | Latin                 | Arabic                          | Why                                                            |
|-----------------|-----------------------|---------------------------------|-----------------------------------------------------------------|
| Face            | serif / sans / mono   | `LonjaFaces.arabic` for all text | Naskh forms; the Latin serif has no Arabic coverage             |
| Size            | tabled value          | tabled value × 1.12             | Arabic reads a size smaller at the same nominal size            |
| `height`        | tabled value          | `legal` 1.80, others +0.15      | Ascenders, descenders and dot stacks need vertical headroom     |
| `letterSpacing` | tabled px value       | ALWAYS `0`                      | Positive tracking severs cursive joins                          |

`legal` in `ar` is therefore 17.9px on the Naskh stack, `height: 1.80`, `letterSpacing: 0`.
`verdict` is 44.8px, `height: 1.15`, `letterSpacing: 0`.

## Zero tracking is not a preference

Arabic is a joining script. Latin tracking inserts space between glyphs; in Arabic it inserts space
into a connected word, so `هامور` renders as `ه ا م و ر`. A native reader has to reassemble the
word letter by letter, which destroys the five-second read the product exists to deliver. There is
no acceptable positive `letterSpacing` on Arabic text at any size, in any theme.

Consequences for the ramp:

- `eyebrow` and `microLabel` have no Arabic form as designed. In `ar` they render at the same size,
  weight w700, in `ink-muted`, above a 1px `rule` hairline. Hierarchy comes from weight, colour and
  the rule — never from tracking, never from a case transform.
- `.toUpperCase()` on Arabic is a silent no-op, so an eyebrow that relies on it looks identical to
  body text. See rule 10 in SKILL.md.

## Italic

There is no true italic master in the Arabic stack. `fontStyle: FontStyle.italic` triggers a
synthetic oblique that slants a right-to-left cursive script into unreadability. The `binomial`
step exists for scientific names, which are Latin binomials in every locale including `ar` — so
`binomial` keeps the Latin serif stack and stays italic even under `ar`, embedded in the Arabic
paragraph. It is the ONLY step that does not swap face in `ar`.

## Numerals

`intl`'s `NumberFormat` for the `ar` locale emits Arabic-Indic digits (`٤٥`, `٦٥`, `٣٨`) by
default. Which system CATCHLAW ships is decided in `i18n-rtl-l10n`. The typographic consequences
here are fixed either way:

1. Arabic-Indic digits have **no tabular figure coverage** in the mono stack. `FontFeature.
   tabularFigures()` is a no-op on them, so digits fall back to the Naskh face at proportional
   widths and a species table loses its decimal spine.
2. Therefore any numeral column in `ar` is pinned with `LonjaMeasure.digitColumn` and
   `textAlign: TextAlign.end`. Do not rely on figure widths.
3. Units stay in the localised script and are glued to the value with a non-breaking space in the
   ARB: `٤٥ سم`, never a hand-placed space plus a line break.
4. The big `measure` readout in `ar` uses the Arabic face at 34 × 1.12 = 38.1px, `height: 1.10`
   (not 1.0 — the dots need the room), `letterSpacing: 0`.
5. Dates in citations (`2015-11-03`, `2026-07-14`) stay Western-digit ISO in every locale, because
   they are quoting a publication record, not presenting a number to read.

## Mixed-script rows

The species header is inherently bilingual: `هامور Hamour · Epinephelus coioides`. Three faces meet
in one line.

- Do not build it from one `Text` with a single style. Use `Text.rich` with one `TextSpan` per
  script run, each carrying its own ramp step.
- Wrap each run in a bidi isolate so the `·` separators and the Latin binomial do not reorder
  around the Arabic. The isolate characters and directionality machinery are `i18n-rtl-l10n`'s.
- Vertical alignment: the Arabic run sits 1.12× larger, so set the row's
  `textBaseline: TextBaseline.alphabetic` and let the baseline do the work. Never nudge with
  `Padding` — it drifts at every textScaler value.

```dart
Text.rich(TextSpan(children: [
  TextSpan(text: 'هامور', style: t.display),        // arabic face, 33.6px, tracking 0
  const TextSpan(text: '  Hamour  ·  '),
  TextSpan(text: 'Epinephelus coioides', style: t.binomial),  // latin serif italic, always
]), style: t.display);
```

## Line-height headroom, concretely

Arabic diacritics and dot stacks overflow a Latin-tuned line box, so glyph tops clip against the
line above at tight heights. The `+0.15` uplift is a floor, not a suggestion.

| Step        | Latin height | Arabic height |
|-------------|--------------|----------------|
| `verdict`   | 1.02         | 1.15           |
| `display`   | 1.10         | 1.25           |
| `title`     | 1.15         | 1.30           |
| `legal`     | 1.62         | 1.80           |
| `datum`     | 1.30         | 1.45           |
| `citation`  | 1.50         | 1.65           |

## Review checklist for an `ar` diff

- [ ] No `letterSpacing` other than `0` appears on any Arabic-rendered style.
- [ ] No `.toUpperCase()` anywhere in the changed files.
- [ ] Every numeral column in a table or list has a pinned width.
- [ ] `binomial` still resolves to the Latin serif italic under `ar`.
- [ ] The verdict screen golden exists for `ar` at textScaler 1.0 and 2.0 and shows no clipping.
- [ ] Values and units are glued with a non-breaking space in the ARB, not in Dart.
