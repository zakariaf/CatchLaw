# E22/T03 — Gulf rule rows and verbatim text

| | |
|---|---|
| **Epic** | E22 — Content authoring at scale |
| **Branch** | `epic/22-content/T03-gulf-rule-rows` (cut from a current `main`) |
| **Commit** | `feat(content): author the Gulf rule rows and verbatim text, with the exclusion provision quoted per state` |
| **Depends on** | T02 (the transcription source is decided and recorded), T01 (the authoring guide and A11) |
| **Size** | L |
| **Spec** | `SPEC.md` §8 Gulf licence row and its ⚠ status, §7.1, §9.6, §4.4 "Jurisdictions with no polygons", §16 R1, §9.1 `ar` row |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rules 6, 11 and 12 — the citation contract, verbatim text single-locale, and gazette-only sourcing — plus `references/licence-provenance.md`'s UAE row, which names the statute and what it does *not* cover |
| `catchlaw-rule-engine` | Rules 4, 6 and 12: the resolution order these rows will be resolved by, that a disagreeing tie is *returned* rather than broken, and that a size is compared only against its own method. An author who does not know this authors two rules that tie |
| `catchlaw-reference-database` | Rule 8 — `citation_text` is denormalised onto the fisher's catch row forever, so an instrument reference is written as printed and never abbreviated |
| `catchlaw-conventions-index` | Invariant 3 (a required, non-nullable citation) and invariant 5 (an expired ruleset still evaluates) — the two an authored Gulf row can quietly break |
| `catchlaw-measurement-ruler` | What TL, FL, CW and SHL mean at the fish; the Kanaad FL/TL gap is the difference between a legal fish and AED 3,000 |
| `testing-strategy` | Corpus tests are the level here: pure Dart over the real `content/ae-rk/` tree, not a widget test and not a fixture that duplicates the corpus |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, Gulf rule-rows row, whole cell | The instruments — UAE Ministerial Decisions 580/2015, 471/2016, 500/2014, Abu Dhabi EAD Fishing Law, equivalents per state — the statute, and the ⚠ requirement that the provision be quoted per state **before that state's content ships** |
| `SPEC.md` | §8, Gulf zone-polygon row | Emirate maritime boundaries are not published as coordinate polygons; `has_zone_polygons = 0`; **we do not invent boundaries** |
| `SPEC.md` | §7.1 | `jurisdiction`, `citation`, `rule`, `closed_season`, `gear_rule`, `penalty`, `legal_text` — the columns these rows fill, and `code` written as `'AE-RK'` |
| `SPEC.md` | §9.6 | Verbatim law exists only in the language the authority published it in; `legal_text_locales`; the §9.2 fallback chain never substitutes a different language of law |
| `SPEC.md` | §4.4, last row | Where no coordinate boundaries are published, rules apply jurisdiction-wide and the picker hides the sub-zone level |
| `SPEC.md` | §16 R1 | Where the rows come from, and the release blocker if they do not |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "The statutory carve-outs, and their edges"; "Sourcing" | The UAE row — official documents, laws, regulations, decisions and their **official** translations — and what it excludes: private commentary, third-party abstracts, commissioned translations |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | "rules.yaml schema"; the calibrated real rows | The field list, and the three Gulf rows the schema was calibrated against: Hamour 450 TL, Kanaad 650 FL, Sha'ri closed 03-01 to 04-30 |
| `epics/DECISIONS.md` | D-3, D-7 | Six locales; and that no user-visible sentence lands in the engine — every Arabic string this task writes goes to `content_string` or `legal_text` |
| `epics/E22-content/T02-gulf-gazette-test-r1.md` | whole | Which transcription path was taken, and the `sources.yaml` blocks these citations must match |
| `FLUTTER_GUIDE.md` | §6.1, §6.4 | Test naming with receipts, and the budget: a corpus test is a pure-Dart unit test — there is no network here to justify an integration layer |

## What this delivers

- `content/ae-rk/` — the first Gulf jurisdiction, complete: `jurisdiction.yaml`, `citations.yaml`,
  `rules.yaml`, `closed_seasons.yaml`, `gear_rules.yaml`, `penalties.yaml`, `licence_types.yaml`,
  `legal_text.yaml`, `strings.yaml`, `changes.yaml`, `snapshot.json`.
- `content/ae-az/`, `content/ae-du/` and one sibling per further emirate or Gulf state, each shipping
  only once its exclusion provision is quoted.
- `content/CHANGELOG/ae-rk.md` and one per sibling, generated.
- `tools/content_builder/lib/src/provenance/accepted_hosts.dart` — extended: `JurisdictionProvenance`
  gains `provision`, `provisionRef`, `provisionUrl`, `verifiedOn` and `verifiedBy`, and `verified:
  true` without a quoted provision is a contradiction the type refuses to represent.
- `tools/content_builder/lib/src/load/rule_expansion.dart` — `applies_to:` on an authored federal
  rule, expanded into one emitted `rule` row per jurisdiction.
- `content/ATTRIBUTIONS/licence-basis.md` — generated: one section per jurisdiction, quoting the
  provision that permits the reproduction, with its instrument reference and the date a human
  verified it. E18 assembles it into `ATTRIBUTIONS.md`.
- `tools/content_builder/test/provenance/jurisdiction_provenance_test.dart`,
  `test/load/rule_expansion_test.dart`, `test/content/ae_rk_corpus_test.dart`.

## Why it is built this way

**The code is `AE-RK`, and it is written down here once.** `SPEC.md` §7.1 writes
`code TEXT NOT NULL UNIQUE, -- 'AE-RK', 'ES-GA', 'BR-SP'`. `build-assertions.md` and
`licence-provenance.md` write `AE-RAK` and `content/CHANGELOG/ae-rak.md`. §7.1 is authoritative for
the schema, so the jurisdiction code is **`AE-RK`**, the directory is `content/ae-rk/` and the
changelog is `content/CHANGELOG/ae-rk.md`. Left unstated, the two spellings would end up in the
`accepted_hosts` key and the changelog filename respectively, and A10 would fail with a message that
looks like a bug in the diff.

**No state ships until its exclusion provision is quoted.** `SPEC.md` §8 marks the Gulf licence basis
— UAE Federal Decree-Law No. 38 of 2021, Art. 3, successor to Federal Law 7/2002 Art. 3 — as *cited
but not independently verified in this session*, and requires an equivalent provision for each
additional Gulf state before that state's content ships. E04/T05 already turned that into a
`verified: true|false` flag that fails A9 for every citation in an unverified jurisdiction. This task
makes the flag carry its evidence: `provision` is the quoted text, `provisionRef` is the instrument
and article it comes from, `verifiedOn` and `verifiedBy` say who checked. `verified: true` with an
empty `provision` is unrepresentable — the constructor requires the pair. **Rejected:** a boolean plus
a comment. A comment is not evidence, does not appear in `ATTRIBUTIONS.md`, and cannot be reviewed by
anyone who is not reading the Dart.

**A federal decision is authored once and expanded, not pasted seven times.** §7.1 gives `citation`
and `rule` a `jurisdiction_id NOT NULL`, and the resolver selects on an exact jurisdiction match
(`catchlaw-rule-engine` rule 4). MD 580/2015 applies across the UAE, so the *emitted* rows are
necessarily per emirate — but the *authored* row must not be, or 100+ rows become 700+ and the diff
becomes unreviewable. An authored federal rule carries `applies_to: [AE-RK, AE-DU, AE-AZ, …]` and one
`lineage_id`; `rule_expansion.dart` emits one row per jurisdiction, each tagged `authored_from` with
the authored id. Expansion runs **after load and before the assertions**, so A8 resolves the expanded
grid and can see a federal rule contradicting an emirate one; `snapshot.json` projects the
**authored** form, so A10 reports one change for one edit rather than seven.
**Rejected:** expanding at emit time only — A8 would then never compare a federal rule against an
emirate rule, which is precisely the contradiction class the Gulf has.
**Rejected:** copy-pasting per emirate — the second copy is amended and the first is not.

**Every Gulf rule's `zone_id` is NULL, and that is a decision, not a gap.** §8 states that emirate
maritime boundaries are not published as coordinate polygons in MD 580/2015 or its successors, and
§4.4 gives the behaviour: rules apply jurisdiction-wide and the zone picker hides the sub-zone level.
`jurisdiction.has_zone_polygons = 0`. The corpus test asserts both together, because the failure mode
is a well-meaning author drawing an approximate emirate boundary from a coastline shapefile — an
invented boundary that produces a confident wrong verdict for a fisher standing near the line. T09
turns the same rule into A15 for every jurisdiction.

**The verbatim text is Arabic and stays Arabic.** §9.6: bundled law exists only in the language the
authority published it in; we do not translate legal text, because an unofficial translation of a
penal instrument is a liability. `jurisdiction.legal_text_locales = 'ar'` and every `legal_text` row
carries `locale: ar`. No `content_string` key may name a `legal_text.*` id —
`check_content_pipeline.sh` check 6 greps for exactly that, and it has no escape hatch. The
**editorial summary** is different: it is our prose, it is keyed and translated into all six locales
(D-3), and it is rendered under a heading that says it is a summary.

**`body_norm` is written by the shared fold, and Arabic FTS depends on it.** §7.1's comment says why:
FTS5 `unicode61` does **not** fold Arabic orthographic variants. The build already asserts parity
(A7, E04/T07), and §14's dynamic checklist requires `هامور` and `الهامور` to both hit in airplane
mode. The corpus test asserts the article-stripped and unstripped forms are both reachable for at
least one real transcribed article, because that is the §9.4 step 5 behaviour the Gulf text is the
reason for.

**Instrument references are written as printed.** `product-invariants.md` invariant 3: *`Ministerial
Decision 580/2015` — as printed, never abbreviated to "MD 580"*. The citation string is denormalised
onto the catch row (`catchlaw-reference-database` rule 8), so an abbreviation authored today is
permanent in a fisher's record and cannot be corrected by a content update.

**An expired Gulf instrument is authored with its real `valid_to` and ships.** Invariant 5. If a
decision has been superseded, the superseding instrument gets its own row with a shared `lineage_id`
and a later `valid_from`, and the resolver's lineage collapse picks it (`catchlaw-rule-engine`
rule 4). Deleting the old row loses the wording a fisher may still be judged under, and extending a
`valid_to` to keep the ochre bar off the screen is the authoring mistake T01's guide names as
forbidden.

## Tests first

Write every row before authoring a single YAML row or touching `accepted_hosts.dart`. Run them.
**They must fail** — the corpus tests because `content/ae-rk/` does not exist, the unit tests because
the machinery does not.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `JurisdictionProvenance requires a quoted provision when verified is true` | `verified: true`, `provision: ''` | does not construct | §8's requirement made unrepresentable rather than checked |
| 2 | `CitationAssertion reports A9 for every citation in a jurisdiction with no quoted provision` | two citations, provision absent | two `A9` | §8: an equivalent provision quoted **before** that state's content ships |
| 3 | `CitationAssertion accepts a citation in a jurisdiction with a quoted provision` | the UAE block, complete | no failures | The green path, and the shape a new Gulf state copies |
| 4 | `CitationAssertion reports A9 when verifiedBy is absent` | provision quoted, no `verified_by` | one `A9` | "Independently verified" names a person who did it, or it is a claim nobody made |
| 5 | `RuleExpansion emits one rule row per jurisdiction in applies_to` | one federal row, three jurisdictions | three emitted rows, one `authored_from` | The federal instrument, authored once |
| 6 | `RuleExpansion gives every expanded row the authored lineage_id` | same | one distinct `lineage_id` | Lineage collapse must treat the three as one instrument amended together |
| 7 | `RuleExpansion reports a failure when applies_to names an unknown jurisdiction` | `applies_to: [AE-ZZ]` | one failure at the row's line | A typo'd emirate silently drops the rule for a real one |
| 8 | `RuleExpansion runs before the assertion registry` | a federal row contradicting an emirate row | A8 fires | The whole reason expansion is not an emit-time step |
| 9 | `snapshot.json projects the authored rule, not the expansion` | one federal row over three jurisdictions | one snapshot entry | One edit must produce one changelog line, not seven |
| 10 | `AE-RK corpus carries a measurement_method on every size rule` | `content/ae-rk/rules.yaml` | no `A1` | A1's recorded cause is a size copied from a PDF table without its column header — the Gulf tables are exactly that shape |
| 11 | `AE-RK corpus records Kanaad as fork length` | *Scomberomorus commerson* | `min_size: 650`, `measurement_method: FL` | `build-assertions.md`'s calibrated row; TL would pass a fish roughly six centimetres short |
| 12 | `AE-RK corpus records Hamour as total length` | *Epinephelus coioides* | `min_size: 450`, `measurement_method: TL` | The other calibrated row, and the one every screen in this repo uses as its worked example |
| 13 | `AE-RK corpus sets has_zone_polygons to 0` | `jurisdiction.yaml` | `0` | §8: no published coordinate polygons; §4.4: the picker hides the sub-zone level |
| 14 | `AE-RK corpus leaves zone_id null on every rule` | `rules.yaml` | every `zone_id` absent | The other half of case 13; a zone id with no polygon is a boundary somebody invented |
| 15 | `AE-RK corpus declares legal_text_locales as ar` | `jurisdiction.yaml` | `'ar'` | §9.6; S13 renders the language-availability notice from this column |
| 16 | `AE-RK corpus ships every legal_text row in ar` | `legal_text.yaml` | every `locale: ar` | An English rendering of a penal instrument is the liability §9.6 forbids |
| 17 | `AE-RK corpus keys no content_string to a legal_text id` | `strings.yaml` | no match | `check_content_pipeline.sh` check 6, proved by the suite as well as the grep |
| 18 | `ar - AE-RK legal_text body_norm matches the shared fold` | one transcribed article | `body_norm == normaliseSpeciesTerm(body)` per §9.4 | A7's parity, on the text FTS5 cannot fold itself |
| 19 | `ar - AE-RK corpus reaches one species from هامور and from الهامور` | both queries against `search_norm` | one species id | §9.4 step 5 and §14's dynamic check; the definite article is what a fisher types |
| 20 | `AE-RK corpus cites every rule to an instrument written as printed` | `citations.yaml` | no `instrument` matching `^MD ` | Invariant 3; the string is permanent on a catch row |
| 21 | `AE-RK corpus resolves every citation to a document in content/ae/sources.yaml` | `citations.yaml` × `sources.yaml` | every `source_url` and `sha256` matches a T02 ledger block | A citation to a document nobody fetched is a footnote claiming a check nobody made |
| 22 | `AE-RK corpus carries between 100 and 150 rule rows` | authored rows | in range | `SPEC.md` §8 sizes it — *the UAE decisions alone carry 100+* — and a corpus of twelve rows would pass every other assertion |
| 23 | `AE-RK corpus records an expired instrument rather than deleting it` | a superseded decision | the row is present with its real `valid_to` | Invariant 5; and the superseding row shares its `lineage_id` |

```dart
// tools/content_builder/test/content/ae_rk_corpus_test.dart
import 'package:content_builder/src/load/content_source.dart';
import 'package:test/test.dart';

void main() {
  late ContentSource corpus;

  setUpAll(() async {
    corpus = await ContentSource.load(Directory('../../content'));
  });

  group('AE-RK corpus', () {
    test('sets has_zone_polygons to 0', () {
      expect(corpus.jurisdiction('AE-RK').hasZonePolygons, 0);
    });

    test('leaves zone_id null on every rule', () {
      expect(corpus.rulesFor('AE-RK').map((r) => r.zoneId), everyElement(isNull));
    });

    test('records Kanaad as fork length', () {
      final rule = corpus.ruleFor('AE-RK', species: 'scomberomorus-commerson', kind: 'min_size');

      expect(rule.minSizeMm, 650);
      expect(rule.measurementMethod, 'FL');
    });

    test('carries between 100 and 150 rule rows', () {
      expect(corpus.rulesFor('AE-RK'), hasLength(inInclusiveRange(100, 150)));
    });

    // … one test per row above, one behaviour each
  });
}
```

```dart
// tools/content_builder/test/load/rule_expansion_test.dart
import 'package:content_builder/src/load/rule_expansion.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('RuleExpansion', () {
    test('emits one rule row per jurisdiction in applies_to', () {
      final expanded = RuleExpansion.expand(kFederalRuleOverThreeEmirates);

      expect(expanded, hasLength(3));
      expect(expanded.map((r) => r.jurisdiction), ['AE-AZ', 'AE-DU', 'AE-RK']);
      expect(expanded.map((r) => r.authoredFrom).toSet(), {'ae-md-580-2015-hamour-min'});
    });

    test('reports a failure when applies_to names an unknown jurisdiction', () {
      final failures = RuleExpansion.expand(kFederalRuleWithUnknownEmirate).failures;

      expect(failures.single.message, contains('AE-ZZ'));
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/content/ae_rk_corpus_test.dart
test/load/rule_expansion_test.dart test/provenance/jurisdiction_provenance_test.dart)` → 23
failures; the corpus cases fail at `ContentSource.load` because `content/ae-rk/` does not exist. If
case 13 or 14 passes now, the loader is defaulting rather than reading — a jurisdiction that
silently defaults `has_zone_polygons` to 0 would hide the opposite mistake in T09.

## Implementation outline

1. Extend `JurisdictionProvenance` with the five evidence fields; make `verified: true` require
   `provision` and `provisionRef` in the constructor, not in a validator.
2. Fill the UAE entry from `SPEC.md` §8: Federal Decree-Law No. 38 of 2021, Art. 3, with the quoted
   exclusion, the article reference, and `verifiedOn`/`verifiedBy` filled in by whoever reads it.
   Until somebody has, the entry stays `verified: false` and A9 keeps the jurisdiction out of the
   bundle — which is the requirement, working.
3. `rule_expansion.dart`: expand `applies_to` after `ContentSource.load` and before the assertion
   registry runs; tag every emitted row `authoredFrom`; fail on an unknown jurisdiction.
4. Teach E04/T09's snapshot projection to read `authoredFrom` when present, so the diff stays one
   line per authored change.
5. Emit `content/ATTRIBUTIONS/licence-basis.md` from the provenance table, sorted by jurisdiction
   code, written only after every assertion passes (T01's four-phase contract, E04/T01).
6. **Then author the content**: transcribe MD 580/2015, 471/2016 and 500/2014 from the documents
   recorded in `content/ae/sources.yaml`; author the citation blocks; author the rule rows with their
   measurement methods; transcribe the verbatim articles into `legal_text.yaml` as `ar`; write the
   editorial summaries as keys and get their six translations (A2); author `changes.yaml`.
7. Add each further emirate or Gulf state as its **own** PR, with its own provision quoted, its own
   sources block, and its own review sign-off. A state whose provision cannot be quoted is left out
   and named in `content/ae/R1-GAZETTE-TEST.md` as outstanding.
8. Record the `legal_text` review sign-off in `content/reviewers.yaml` (T01's A11, scope
   `legal_text`) — a transcription is checked against the gazette by a reader of Arabic, not by the
   person who typed it.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 23 rows pass, and each failed first.
- [ ] `dart run content_builder:build` exits 0 over the whole `content/` tree with `content/ae-rk/`
      present, and `content/CHANGELOG/ae-rk.md` is current under `--check`.
- [ ] Every jurisdiction with content in this PR has `verified: true` **and** a quoted provision, an
      instrument reference, a `verified_on` date and a `verified_by`.
- [ ] `content/ATTRIBUTIONS/licence-basis.md` is generated, committed, and regenerates with no diff.
- [ ] `has_zone_polygons = 0` and every rule's `zone_id` is NULL for every Gulf jurisdiction; no
      `zone_ring` row exists for any of them.
- [ ] Every `legal_text` row is `ar`; `legal_text_locales` is `'ar'`; no `content_string` key names a
      `legal_text.*` id.
- [ ] Every citation's `source_url` and `sha256` match a block in `content/ae/sources.yaml`.
- [ ] `content/reviewers.yaml` carries a `legal_text` sign-off for `ar` covering this corpus hash.
- [ ] 100 % branch coverage on `rule_expansion.dart`.
- [ ] The `AE-RK` / `AE-RAK` decision is written in `content/README.md`, citing `SPEC.md` §7.1.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
dart run content_builder:build --in content/ --out app/assets/db/reference.db \
  --build-date "$(date -u +%F)" --generator-commit "$(git rev-parse --short HEAD)" --check
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
```

`check_content_pipeline.sh content` will report check 5 on any row using a `SPEC.md` §7.1 measurement
code outside `TL`, `FL`, `CW`, `SHL`, and checks 2, 3 and 5 honour no escape hatch. That gap is
recorded in E04's risks and in this epic's; the builder validates against the full §7.1 list and is
authoritative. **Do not re-code a measurement to quiet the grep** — that changes a legal measurement
to make a heuristic happy.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content): author the Gulf rule rows and verbatim text, with the exclusion provision quoted per state

SPEC.md §8 marks the Gulf licence basis — UAE Federal Decree-Law 38/2021 Art. 3
— as cited but not independently verified, and requires an equivalent provision
quoted for each additional Gulf state before that state's content ships. The
verified flag now carries its evidence: the quoted provision, the instrument it
comes from, and who checked it on what date. verified: true with an empty
provision does not construct.

A federal decision is authored once with applies_to and expanded into one row
per emirate. §7.1 gives citation and rule a non-null jurisdiction_id and the
resolver matches a jurisdiction exactly, so the emitted rows must be per
emirate; pasting them would turn 100+ rows into 700+ and make the diff
unreviewable. Expansion runs before the assertions so A8 can see a federal rule
contradict an emirate one, and snapshot.json projects the authored form so one
edit is one changelog line.

Every Gulf rule's zone_id is NULL and has_zone_polygons is 0. §8 says the
emirate maritime boundaries are not published as coordinate polygons and §4.4
says the picker hides the sub-zone level. We do not invent boundaries, and the
corpus test is what stops somebody tracing one from a coastline shapefile.

The verbatim text is Arabic and stays Arabic (§9.6). The editorial summary is
our own prose, keyed and translated into all six locales, and labelled a
summary. body_norm is written by the shared fold because FTS5 unicode61 does
not fold Arabic orthographic variants, and هامور and الهامور must both hit.

The jurisdiction code is AE-RK, per SPEC.md §7.1. build-assertions.md and
licence-provenance.md write AE-RAK; §7.1 is authoritative for the schema, and
the two spellings would otherwise land in the provenance key and the changelog
filename respectively.

Task: E22/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
