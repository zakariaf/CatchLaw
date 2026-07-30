# Verdict Copy Rules

Scope: the sentence skeleton every finding is built from, the per-state wording table, the full grep
lexicon behind `check_verdict_contract.sh`, ARB key and `@description` authoring, the six locales
and the traps each one carries, and the numbers, units and dates a verdict string may contain.

## The sentence skeleton

```
<state> — <measured> <unit> measured, minimum <threshold> <unit> (<method>)
```

Four slots, in that order, nothing appended. No leading "Result:", no trailing "!", no emoji, no
"Sorry". The state phrase comes from the fixed set below; the numbers come from the engine; the
method is spelled out in words.

| Slot | Source | Rule |
|---|---|---|
| state | fixed phrase set | never invented per screen, never abbreviated |
| measured | engine, as measured | the user's own number, never rounded silently |
| threshold | reference DB | the instrument's number, in the instrument's unit |
| unit | reference DB | follows the instrument, never the locale |
| method | reference DB | spelled out: total length, fork length, carapace width, shell length |

## Per-state wording

| State | Sentence | Notes |
|---|---|---|
| meets | "Meets the minimum — 70 cm measured, minimum 65 cm (fork length)" | never "You can keep it" |
| below minimum | "Below the minimum — 38 cm measured, minimum 45 cm (total length)" | shortfall may be added: "Short by 7 cm" |
| closed season | "Closed season — 1 March to 30 April. In force today, day 14 of 61." | no measurement slot; a closure applies to all sizes |
| protected | "Protected species — taking prohibited." | no measurement slot at all; a measurement implies a threshold |
| no rule recorded | "No rule recorded for this species here. This does not mean it is legal." | both sentences, verbatim, every locale |
| ambiguous | "Two rules of equal standing apply here." + both rules in full | no ranking, no recommendation |
| stale pack | "Rule data expired 2026-06-30 — still shown, verify before relying on it" | additive; the finding above is unchanged |
| disclaimer | "CatchLaw quotes published instruments. It is not legal advice and does not authorise any catch. Verify with <authority> before relying on it." | authority per jurisdiction |

Worked non-Gulf cases: "Below the minimum — 34 mm measured, minimum 38 mm (shell length)" for
Ameixa babosa (*Venerupis corrugata*) at Banco de Cambados; "Meets the minimum — 70 cm measured,
minimum 65 cm (fork length)" for Kanaad (*Scomberomorus commerson*).

## BAD → GOOD, English

Every BAD string below has shipped in some fishing app. Each GOOD string is the same information,
re-shaped as a fact the reader can check against a ruler and a published article.

| # | BAD | GOOD |
|---|---|---|
| 1 | "Keep it" / "Legal — keep" | "Meets the minimum — 47 cm measured, minimum 45 cm (total length)" |
| 2 | "Throw it back" / "Put it back" | "Below the minimum — 38 cm measured, minimum 45 cm (total length)" |
| 3 | "You may keep this fish" | "Meets the minimum — 70 cm measured, minimum 65 cm (fork length)" |
| 4 | "Too small" / "Undersize" | "Below the minimum — 34 mm measured, minimum 38 mm (shell length)" |
| 5 | "Minimum 65 cm" (no method) | "Below the minimum — 61 cm measured, minimum 65 cm (fork length)" |
| 6 | "Don't fish for this now" | "Closed season — 1 March to 30 April. In force today, day 14 of 61." |
| 7 | "Closed — check back in 46 days" | "Closed season — 1 March to 30 April. In force today, day 14 of 61." |
| 8 | "Release — protected" | "Protected species — taking prohibited." |
| 9 | "No restrictions found" | "No rule recorded for this species here. This does not mean it is legal." |
| 10 | "Probably a grouper, treat as 45 cm" | "No rule recorded for this species here. This does not mean it is legal." |
| 11 | "The stricter rule applies: 50 cm" | "Two rules of equal standing apply here." + both rules, both citations, source order |
| 12 | "Rules out of date — check again later" | "Rule data expired 2026-06-30 — still shown, verify before relying on it" |
| 13 | "Safe to eat once bled" | *(deleted — nothing replaces it; food safety is not this app's domain)* |
| 14 | "Not legal advice" + "Got it" | "CatchLaw quotes published instruments. It is not legal advice and does not authorise any catch. Verify with the Ministry of Climate Change and Environment before relying on it." |

## BAD → GOOD, Arabic

The Arabic imperative is one short word — أعِدْه, احتفظ — and it is fluent, natural, exactly what a
translator asked for good Arabic will produce, and invisible to every English-language grep in CI.
Verdicts are written in the indicative: a nominal or verbal statement about the fish, never a
command to the reader and never the second-person suffix ـك.

| # | BAD (ar) | GOOD (ar) |
|---|---|---|
| 1 | «احتفظ به» *keep it* | «يستوفي الحد الأدنى — 47 سم مُقاسة، الحد الأدنى 45 سم (الطول الكلي)» |
| 2 | «أعِدْه إلى البحر» *return it to the sea* | «دون الحد الأدنى — 38 سم مُقاسة، الحد الأدنى 45 سم (الطول الكلي)» |
| 3 | «يمكنك الاحتفاظ بهذه السمكة» *you may keep this fish* | «يستوفي الحد الأدنى — 70 سم مُقاسة، الحد الأدنى 65 سم (طول الشوكة)» |
| 4 | «صغيرة جدًا» *too small* | «دون الحد الأدنى — 34 مم مُقاسة، الحد الأدنى 38 مم (طول الصدفة)» |
| 5 | «لا تصطد الشعري الآن» *do not fish for sha'ri now* | «موسم إغلاق — من 1 مارس إلى 30 أبريل. ساري اليوم، اليوم 14 من 61.» |
| 6 | «أطلقه، نوع محمي» *release it, protected species* | «نوع محمي — الصيد محظور.» |
| 7 | «لا توجد قيود» *no restrictions* | «لا توجد قاعدة مسجّلة لهذا النوع هنا. هذا لا يعني أنه قانوني.» |
| 8 | «تحقق لاحقًا» *check again later* | «انتهت صلاحية بيانات القواعد في 2026-06-30 — لا تزال معروضة، تحقق قبل الاعتماد عليها» |
| 9 | «آمنة للأكل» *safe to eat* | *(محذوف — لا بديل)* |

Rows 1–3 and 6 are the ones a fluent translator produces unprompted; rows 4–5 are the ones a
well-meaning product edit produces. Both are caught only by the `@description` shipping with the
key and by `examples/verdict_strings_test.dart` carrying the Arabic tokens in its const lexicon.

## The grep lexicon

Five families. Family A and B are hard failures in Dart and in every ARB; C, D and E are hard
failures everywhere including test fixtures.

| Family | Tokens | Where it fails |
|---|---|---|
| A — imperative verbs | keep, return, release, discard, throw, toss, retain, land it, put it back, do not keep, throw it back | Dart string literals, all `*.arb` values |
| B — second person / permission | you, your, you may, you can, you must, it is legal to, allowed to, permitted to, feel free | Dart string literals, all `*.arb` values |
| C — inference | probably, likely, should be, appears to, seems, similar to, counts as, we think, in our view, typically, usually, close enough | everywhere |
| D — health / edibility | safe to eat, edible, inedible, poisonous, toxic, venomous, ciguatera, scombroid, histamine, mercury, allergen, do not consume | everywhere |
| E — softened absence | no restrictions, nothing applies, no rules apply, you are fine, all clear, good to go | everywhere |

Escape hatch: a trailing `// verdict-contract-ok` on a Dart line that is provably not user-facing
verdict copy — an enum name, a test fixture asserting the ban, a code comment. **No ARB value is
ever exempt**, and nothing else is exempt. If a line needs the hatch twice, the string is wrong.

## ARB authoring

| Rule | Detail |
|---|---|
| Key prefix | `verdict*`, `finding*`, `citation*`, `disclaimer*` — the script keys off these |
| Numbers | always placeholders, never baked into the English string |
| `@description` opener | "STATEMENT OF FACT. No imperative mood, no second person, no permission verb." |
| `@description` body | what the reader is looking at, which placeholders are mandatory, and that word order may change but no slot may be dropped |
| Plurals | ICU `plural` where the count varies (`day 1 of 61`); mechanics owned by `i18n-rtl-l10n` |
| Instrument names | never translated — "Ministerial Decision 580/2015" stays Latin script in `app_ar.arb`, bidi-isolated |
| Dates | ISO `2026-07-14` in citations; formatted month names only in season prose |

```json
"verdictNoRuleRecorded": "No rule recorded for this species here. This does not mean it is legal.",
"@verdictNoRuleRecorded": {
  "description": "STATEMENT OF FACT. No imperative mood, no second person, no permission verb. TWO sentences are mandatory: the second one prevents the absence of a rule from being read as permission. Do not merge, shorten or soften it."
}
```

## The six locales

| Locale | Trap |
|---|---|
| `en` | "you may" slips in through friendly product copy |
| `ar` | Arabic imperative (أعِدْه، احتفظ به) is short, natural and invisible to an English grep — the `@description` is the only defence; verdicts must use the indicative (دون الحد الأدنى) |
| `es` | the imperative and the polite subjunctive both read as instructions ("devuélvalo", "que lo devuelva") |
| `gl` | same imperative risk as `es`; the authority named is Consellería do Mar, not a ministry |
| `pt` | "pode ficar com ele" is a permission verb with no English cognate in the grep |
| `fr` | "vous pouvez" is second person plus permission in three words |

Every locale gets the same skeleton, the same slots and the same two sentences in the no-rule case.
A translator may reorder slots for grammar; a translator may not drop one, merge the two no-rule
sentences, or turn a nominal phrase into a verb phrase.

## Numbers, units and dates

- The measured value is the user's own number, echoed back unchanged; rounding and unit conversion
  are owned by `catchlaw-measurement-ruler`.
- The unit follows the instrument, never the device locale: a Galician shell length stays in mm on
  an Arabic phone.
- Latin digits with tabular figures for measurements and dates; numeral-system policy is owned by
  `i18n-rtl-l10n`.
- Citation dates are ISO-8601, unlocalised, so `published 2015-11-03 · checked 2026-07-14` is the
  same string everywhere and can be compared against a printed instrument by eye.
- Season boundaries print as day and month ("1 March to 30 April") plus the progress fact ("day 14
  of 61"), never as a countdown ("46 days left") which invites planning advice.

## Review checklist for any new user-facing string

1. Can it be prefixed with "It is recorded that" and still parse? If not, rewrite.
2. Does it contain a number the reader could check against a ruler or a published article?
3. Is the measurement method spelled out in words in the same sentence?
4. Does the screen it lands on carry the citation quadruple and the disclaimer?
5. Does it appear in `app_en.arb` with a constraint-carrying `@description`?
6. Would a translator with only the English string and the description produce an imperative?
7. Does `scripts/check_verdict_contract.sh` pass, and does the string test still assert it?
