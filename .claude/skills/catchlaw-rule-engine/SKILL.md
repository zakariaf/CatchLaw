---
name: catchlaw-rule-engine
description: >-
  Governs the pure-Dart rule_engine package shared by the app and content CLI: resolution filtered
  on jurisdiction, species_id and water_type with valid_from at or before the injected date,
  collapsed to the greatest valid_from per zone_id and citation_lineage_id, matched against NULL,
  equal or ancestor zones, ranked by the specificity ladder exclusion 40, reserve 30, bank 20,
  subzone 10, region 0, expiry TAGGED and never filtered so a lapsed orden de vedas still evaluates,
  disagreeing ties returned as Resolution.ambiguous rather than chosen, FindingKind precedence
  protected, closedSeason, maxSize, minSize, bagLimit and vesselLimit, and one NFKC-first
  normaliseSpeciesTerm. Use when writing a resolution query, touching valid_to or isExpired, adding
  a FindingKind or Resolution variant, replacing DateTime.now with an injected Clock, indexing
  species_alias rows, debugging hamour against هامور search, or reviewing rule_resolver.dart in a
  diff.
---

# Catchlaw Rule Engine

The engine never decides what a fisher should do; it states which rules were found, which one bites
first, and which instrument says so. This skill owns the pure-Dart `rule_engine` package — the
resolution pipeline, specificity ladder, tie contract, expiry tagging, finding precedence, the
no-rule-found state and the species normalisation contract. It owns neither the `Result` spine,
sealed-class style and reference schema, nor the sentence printed from a finding.

Read the reference for the task at hand:
- `references/resolution-algorithm.md` — selection predicate, lineage collapse, zone ancestry,
  specificity ladder, tie matrix, expiry axis, finding precedence, worked traces, edge cases.
- `references/normalisation-contract.md` — nfkc ordering, tatweel and harakat, alef and ya folding,
  ta-marbuta collapse, definite-article dual indexing, Arabic-Indic digits, acceptance test.

Run `scripts/check_rule_engine.sh` before a PR.

Rows arrive as plain Dart records: DAOs and indices belong to `catchlaw-reference-database`, the
content that fills them to `catchlaw-content-pipeline`, the `Result` spine to
`error-handling-typed-results`, sealed-class and complexity policy to
`dart3-idioms-and-coding-standards`, and the printed sentence to `catchlaw-verdict-contract`.

## Non-negotiable rules

1. **An expired ruleset is TAGGED, never filtered away.** No resolution query may mention `valid_to`
   in a `WHERE`, and no Dart pipeline may `.where((r) => r.validTo!.isAfter(now))`; compute
   `isExpired = validTo != null && validTo!.isBefore(req.on)` onto every `RuleFinding`. **WHY:** the
   day an annual orden de vedas or piracema portaria lapses, filtering wipes every rule it carried,
   every species falls to "no rule recorded", and a frozen snapshot silently becomes the live-data
   product this app can never be offline.

2. **The domain package has NO Flutter dependency, at all.** `packages/rule_engine/pubspec.yaml`
   declares no `flutter:` sdk dependency, so `import 'package:flutter/...'` or `dart:ui` is a COMPILE
   error, not a lint someone can `// ignore:`; no `Color`, `Locale` or `BuildContext` crosses.
   **WHY:** the content CLI compiles this package under plain `dart run`, and one Flutter symbol
   stops the whole content build.

3. **The evaluation date is a parameter, never a reading.** `Resolution resolve(EvaluationRequest
   req)` takes `req.on` from an injected `Clock`; `DateTime.now()` appears NOWHERE under
   `packages/rule_engine/lib/`. **WHY:** a closure that opens tomorrow is untestable against a wall
   clock, and a frozen fixture for 2026-03-14 is the only way the Sha'ri closure is ever proved.

4. **Resolution runs in ONE fixed order and never reorders.** Select on `jurisdiction` +
   `species_id` + `water_type` with `valid_from <= req.on`; collapse to the greatest `valid_from`
   per `(zone_id, citation_lineage_id)`; keep `zone_id` NULL, equal or ancestor; sort DESC by
   specificity. **WHY:** any other order lets a superseded 2011 amendment outrank the 2015 instrument
   that replaced it, in a jurisdiction where only one of them is law.

5. **The specificity ladder is a closed integer table.** exclusion 40, reserve 30, bank 20, subzone
   10, region 0 — declared once on `ZoneScope`, never re-derived from path depth or string prefixes.
   **WHY:** a depth heuristic ranks `banco-de-cambados` above a no-take exclusion drawn INSIDE it,
   handing the permissive rule to a fisher standing where the strict one applies.

6. **A tie that disagrees is returned, never broken.** When the top rows share a specificity and
   their outcomes differ, return `Ambiguous(rules: [a, b])` — never `.first`, "most recent wins",
   "strictest wins" or "expired loses". **WHY:** choosing silently produces a verdict no instrument
   supports; printing both gives him two citations he can read aloud to an inspector.

7. **Finding precedence is fixed, total, and applied exactly once.** `FindingKind.protected` over
   `.closedSeason` over `.maxSize` over `.minSize` over `.bagLimit` over `.vesselLimit`; the first
   failure headlines, the rest ride in `Resolution.secondary`, and NO surface re-ranks them. **WHY:**
   a screen that re-sorts headlines "below the minimum" for a protected sawfish — different offence,
   different penalty, landed fish.

8. **"No rule found" NEVER implies legality.** `NoRuleFound(searched:, checkedOn:)` is its own
   variant listing the instruments consulted, never mapped to a permissive verdict and never confused
   with `NoLimitInInstrument`, a positive statement carrying its own `Citation`. **WHY:** absence of
   evidence stamped as permission fails silently in exactly the zones with the thinnest content.

9. **Every finding carries a non-null Citation.** `RuleFinding({required Citation citation})` with
   instrument, article, `publishedOn` and `checkedOn` — never `Citation?`, never a default, never
   `citation ?? Citation.unknown()`. **WHY:** an uncited finding is an opinion, and the one moment it
   matters is at 06:00 with an inspector asking which article the number came from.

10. **Normalisation exists in exactly ONE function.** `normaliseSpeciesTerm(String)` in
    `lib/src/search/normalise.dart`: NFKC FIRST because Presentation Forms are what OCR emits, then
    tatweel and harakat stripped, alef/waw/ya folded, final ta-marbuta, ha and alef-maqsura collapsed,
    Arabic-Indic digits mapped. **WHY:** a near-copy in the CLI indexer drifts, and the index then
    holds keys the query can never produce — a search that silently returns nothing.

11. **The definite article is stripped AND kept — both forms indexed.** `الهامور` indexes under
    `هامور` and under `الهامور`, query included. Acceptance, in `normalise_test.dart`: `hamour`,
    `هامور`, `هامورة`, `الهامور` and `Epinephelus coioides` all resolve to ONE species id. **WHY:**
    stripping only at index time makes the article-typed query miss, and Khalid types the article.

12. **A measurement is compared ONLY against its own method.** `MeasurementMethod.tl`, `.fl`, `.cw`
    and `.shl` must MATCH between reading and rule; a mismatch returns `methodMismatch`, never a
    silent comparison and never a conversion factor. **WHY:** 65 cm fork length on Kanaad is roughly
    71 cm total length — crossing methods manufactures a pass at the centimetre that costs AED 3,000.

## The resolution pipeline, in one fixed order

Four stages in this exact sequence, over rows the DAO already fetched. Nothing here reads a clock,
opens a database, or touches `valid_to`.

```dart
// WRONG — reads the wall clock, filters on valid_to, takes whatever came back first.
final rows = await db.rulesFor(speciesId).get();
return rows.where((r) => r.validTo == null || r.validTo!.isAfter(DateTime.now())).first;

// RIGHT — one pure pipeline; the date arrives with the request, expiry is never consulted.
Resolution resolve(EvaluationRequest req, List<RuleRow> rows) {
  final applicable = rows.where((r) =>
      r.jurisdiction == req.jurisdiction &&
      r.speciesId == req.speciesId &&
      r.waterType == req.waterType &&
      !r.validFrom.isAfter(req.on)); // valid_to is deliberately absent
  final latest = <(String?, String), RuleRow>{}; // greatest valid_from per zone + lineage
  for (final r in applicable) {
    final k = (r.zoneId, r.citationLineageId); // an amendment supersedes only its own ancestor
    if (!latest.containsKey(k) || r.validFrom.isAfter(latest[k]!.validFrom)) latest[k] = r;
  }
  final ranked = latest.values
      .where((r) => r.zoneId == null || req.zonePath.contains(r.zoneId)) // NULL, equal, ancestor
      .toList()
    ..sort((a, b) => b.scope.specificity.compareTo(a.scope.specificity));
  return _decide(ranked, req);
}
```

Full worked file: `examples/rule_resolution.dart`.

## Expiry tags a rule; it never removes one

`valid_to` is metadata printed on the ochre bar, not a predicate. An expired instrument is still the
last verified wording, and at sea that is everything he has.

```dart
// WRONG — on 2026-05-01 the Galician orden de vedas lapses, this query returns nothing, and
// Ameixa babosa reports "no rule recorded" as if Galicia had stopped regulating shellfish.
final rows = await (select(rules)..where((t) => t.validTo.isBiggerThanValue(now))).get();

// RIGHT — nothing is dropped; expiry becomes a flag computed from the injected date.
RuleFinding _toFinding(RuleRow r, DateTime on) => RuleFinding(
      kind: r.kind,
      citation: r.citation, // required, non-null, always
      isExpired: r.validTo != null && r.validTo!.isBefore(on),
      expiredOn: r.validTo, // '2026-06-30' — printed verbatim on the stale bar
    );
// The surface renders StaleRuleBar from isExpired and leaves the verdict beneath it ungated.
```

Full worked file: `examples/rule_resolution.dart`.

## A tie is reported, not broken

Two instruments at equal specificity that disagree is a real state of the world, and the engine's job
is to say so. Every tie-break anyone proposes — newest, strictest, non-expired — invents a verdict
the sources do not support.

```dart
Resolution _decide(List<RuleRow> ranked, EvaluationRequest req) {
  if (ranked.isEmpty) return NoRuleFound(searched: req.searched, checkedOn: req.contentCheckedOn);
  final top = ranked.first;
  final rivals = ranked.where((r) => r.scope.specificity == top.scope.specificity).toList();
  // WRONG — `return Decided(rule: top);` right here: no warning, second citation never seen.
  // RIGHT — equal specificity plus a differing outcome is surfaced with BOTH citations.
  if (rivals.length > 1 && rivals.any((r) => !r.outcomeEquals(top))) {
    return Ambiguous(rules: rivals); // expiry does NOT break the tie either
  }
  return Decided(rule: top, secondary: ranked.skip(1).toList());
}
```

Full worked file: `examples/rule_resolution.dart`.

## Finding precedence and the headline

Several rules can bite at once. The order they are reported in is legal, not cosmetic, and it is
settled here so that no surface ever has to.

```dart
// WRONG — whatever order the query returned; a protected species headlines "below the minimum".
findings.sort((a, b) => a.ruleId.compareTo(b.ruleId));
// RIGHT — one closed, total ordering declared beside the enum and applied exactly once.
enum FindingKind { protected, closedSeason, maxSize, minSize, bagLimit, vesselLimit }
const _precedence = <FindingKind, int>{
  FindingKind.protected: 60, FindingKind.closedSeason: 50, FindingKind.maxSize: 40,
  FindingKind.minSize: 30, FindingKind.bagLimit: 20, FindingKind.vesselLimit: 10,
};
List<RuleFinding> rankFailures(List<RuleFinding> all) => all.where((f) => f.fails).toList()
  ..sort((a, b) => _precedence[b.kind]!.compareTo(_precedence[a.kind]!));
// Sha'ri, 52 cm, 14 March: closedSeason headlines, minSize rides as a secondary finding — the
// rule table prints both, the stamp states only one.
```

Full worked file: `examples/rule_resolution.dart`.

## Silence in the sources is not permission

Three outcomes look alike from the caller's seat and are legally miles apart. Three variants, never
one nullable rule, and only one of them is something an instrument actually says.

```dart
sealed class Resolution { const Resolution(); }
/// The instrument states a limit — Hamour 45 cm TL, Ministerial Decision 580/2015 Art. 3.
final class Decided extends Resolution { /* rule, secondary findings, citation */ }
/// The instrument WAS searched and positively records no size limit for this species.
final class NoLimitInInstrument extends Resolution {
  const NoLimitInInstrument({required this.citation});
  final Citation citation; // still cited: this is a statement the instrument makes
}
/// The reference DB holds no rule for this species in this zone. NOT a permission.
final class NoRuleFound extends Resolution {
  const NoRuleFound({required this.searched, required this.checkedOn});
  final List<Citation> searched; // what was looked in, so he can say what was looked in
  final DateTime checkedOn;
}
// WRONG — collapses all three and turns thin content into a legal green light:
// if (findings.isEmpty) return const Decided.meets();
```

Full worked file: `examples/rule_resolution.dart`.

## The normalisation contract, in one place

One function, called by both the CLI indexer and the runtime query, so an index key and a query key
can never disagree. NFKC runs first because scanned Gulf gazettes arrive as Presentation Forms.

```dart
// WRONG — a second, near-identical copy in the CLI indexer; الهامور then matches nothing.
String key(String s) => s.replaceAll('ـ', '').toLowerCase();

// RIGHT — one function; both sides call it; the acceptance test pins the behaviour.
String normaliseSpeciesTerm(String input) {
  var s = nfkc(input);                          // Presentation Forms FIRST — OCR emits them
  s = s.replaceAll('ـ', '');                          // tatweel
  s = s.replaceAll(RegExp('[ً-ْٰ]'), '');   // harakat + dagger alef
  s = s.replaceAll(RegExp('[آأإٱ]'), 'ا'); // alef forms
  s = s.replaceAll('ؤ', 'و').replaceAll('ئ', 'ي'); // hamza on waw / ya
  s = s.replaceAll('ى', 'ي');                    // alef maqsura
  s = s.replaceAll(RegExp('[ةه]\$'), '');        // word-final ta-marbuta / ha
  s = mapArabicIndicDigits(s);                             // ٠-٩ to 0-9
  return s.toLowerCase().trim();
}
// Indexed BOTH with and without a leading ال, so هامور and الهامور hit the same species id.
```

Full worked file: `examples/species_normalisation.dart`.

## Anti-patterns

- **`where((t) => t.validTo.isBiggerThanValue(now))`** — the day the ruleset lapses, every species in
  it reports "no rule recorded". The failure this whole skill exists to prevent.
- **`import 'package:flutter/foundation.dart';` for `@immutable`** — drags Flutter into the shared
  package and breaks the CLI content build; use `package:meta`.
- **`DateTime.now()` inside `resolve()`** — the Sha'ri closure becomes untestable and CI flaps.
- **`ranked.first` straight after the sort, or `rivals.firstWhere((r) => !r.isExpired)`** — a
  confident verdict neither instrument supports, and rule 1's deletion semantics in disguise.
- **`zoneId.split('/').length` as specificity** — ranks a bank above the no-take exclusion drawn
  inside it, and returns the permissive rule where the strict one applies.
- **`Citation? citation` on `RuleFinding`** — the first finding built without one ships an uncited
  number, and nobody finds out until an inspector asks.
- **`findings.isEmpty ? meets : ...`** — absence of evidence stamped as permission.
- **`minCm` compared against a fork-length reading** — 65 cm FL read as 65 cm TL passes a Kanaad
  short by roughly six centimetres.
- **A private `_normalise()` in the search DAO, or `replaceAll('أ', 'ا')` before NFKC** — the second
  copy, and a fold that misses the Presentation Forms the OCR actually emitted.
- **Passing a drift `RuleData` row into `resolve()`** — pins the pure package to the database
  package, and the CLI can no longer build a fixture without opening SQLite.

## Definition of done

- [ ] `scripts/check_rule_engine.sh` is clean over `lib/` and over `packages/rule_engine/lib/`.
- [ ] `packages/rule_engine/pubspec.yaml` declares no `flutter:` dependency and `dart analyze
      packages/rule_engine` passes with zero Flutter or `dart:ui` imports (rule 2).
- [ ] `validTo` appears only as a tag or a printed date, never in a filter, and a test proves a rule
      with `validTo` in the past still resolves and arrives with `isExpired` true (rule 1).
- [ ] No `DateTime.now()` under `packages/rule_engine/lib/`, and a frozen-clock test asserts the
      Sha'ri closure on 2026-03-14 and its absence on 2026-05-01 (rule 3).
- [ ] Two rules at specificity 20 with opposite outcomes yield `Ambiguous` with both citations,
      including when one of them is expired (rules 5, 6).
- [ ] A protected species carrying a size rule headlines `FindingKind.protected` with the size
      finding in `secondary`, and `NoRuleFound` and `NoLimitInInstrument` are separate variants,
      switched with no `default:` arm, neither mapping to a permissive verdict (rules 7, 8).
- [ ] `normalise_test.dart` asserts `hamour`, `هامور`, `هامورة`, `الهامور` and `Epinephelus coioides`
      all resolve to one species id, and a fork-length reading against a total-length rule returns
      `methodMismatch` (rules 10, 11, 12).

## Related skills

- See `catchlaw-reference-database` for the read-only asset DB, the `rules` and `species_alias`
  schemas, the DAOs and indices that feed rows into this package.
- See `catchlaw-content-pipeline` for the CLI that builds those rows and shares this package through
  pub workspaces without a Flutter SDK.
- See `catchlaw-verdict-contract` for the sentence printed from a finding — statement-of-fact grammar
  and the banned imperative lexicon this engine never generates.
- See `catchlaw-offline-guarantee` for why an expired ruleset is shown rather than withheld, and why
  no refresh or sync affordance may exist to "fix" it.
- See `catchlaw-measurement-ruler` for TL, FL, CW and SHL capture and rounding before a reading
  reaches `EvaluationRequest`.
- See `error-handling-typed-results` for the `Result` spine and why a resolution failure is never an
  exception, and `catchlaw-conventions-index` for where this package sits in the whole.
- See `dart3-idioms-and-coding-standards` for sealed-class shape, exhaustive switches and the
  complexity numbers every function here is held to.
- See `lonja-verdict-and-status` for how a `Resolution` and the ochre stale bar are typeset.

## References

- Dart language — class modifiers and sealed classes: https://dart.dev/language/class-modifiers
- Dart language — patterns and exhaustive switches: https://dart.dev/language/patterns
- Dart — pub workspaces: https://dart.dev/tools/pub/workspaces
- Dart API — DateTime: https://api.dart.dev/stable/dart-core/DateTime-class.html
- Unicode Standard Annex 15 — Normalization Forms: https://www.unicode.org/reports/tr15/
- Unicode — Arabic Presentation Forms-B chart: https://www.unicode.org/charts/PDF/UFE70.pdf
