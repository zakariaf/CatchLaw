# E22/T02 — The Gulf gazette test — R1

| | |
|---|---|
| **Epic** | E22 — Content authoring at scale |
| **Release** | **v2 — deferred.** Not built for v1; see `epics/RELEASES.md` |
| **Branch** | `epic/22-content/T02-gazette-test` (cut from a current `main`) |
| **Commit** | `feat(content_builder): add the OCR yield audit and record the R1 gazette test` |
| **Depends on** | T01 (`content/AUTHORING.md`, the sourcing rules an audited document has to satisfy) |
| **Size** | L |
| **Spec** | `SPEC.md` §16 R1 (in full), §8 Gulf licence row and the transcriber budget line, §9.4 step 1, §9.1 `ar` row |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rule 12 — the gazette and nothing else — and `references/licence-provenance.md` "Sourcing", which names what a `source_url` may and may not point at. This task builds the ledger that rule 12 will be checked against |
| `catchlaw-rule-engine` | Rule 10 and `normaliseSpeciesTerm`: **NFKC first, because Presentation Forms are what OCR emits.** The audit must fold with the shipped function, not a private copy, or it will count rows the app can never find |
| `catchlaw-conventions-index` | Invariant 1 — no network code path. A human fetches the PDF; the tool reads a local file and never opens a socket, and this is the task where somebody would be tempted otherwise |
| `catchlaw-reference-database` | Rule 8 — the citation text an audited row eventually produces is denormalised onto a fisher's catch row forever, which is why a "probably right" transcription is not good enough |
| `testing-strategy` | Pure Dart `package:test` over inline Arabic fixtures; no widget binding, no file-system fixture that a gate would scan |
| `dependency-hygiene` | The audit shells out to nothing and adds no dependency: `ocrmypdf` and Tesseract run in a human's terminal, not in this package |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §16 R1, whole | The one-day test, the two candidate PDFs that could **not** be text-extracted (FAOLEX `uae165183.pdf`, EAD `Fishing-Law-2023.pdf`), the pass bar **≥ 80 species rows in a day with twenty cross-checked**, and the mitigation that does not remove Arabic |
| `SPEC.md` | §8, Gulf rule-rows row | The licence basis and its ⚠ status, and the sourcing rule: *never from FAOLEX's abstract or any FAO-commissioned translation, which are FAO works under FAO terms* |
| `SPEC.md` | §8, authoring-volume paragraph | The named budget line for a paid Arabic-speaking transcriber working from the official gazette |
| `SPEC.md` | §9.4, Arabic steps 1–6 | NFKC first, tatweel and harakat, the alef/waw/ya folds, and the Arabic-Indic digit mapping the audit needs to read a minimum length at all |
| `SPEC.md` | §9.1, `ar` row | Why this is the moat, and the zero-result store evidence that makes it one |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "Sourcing: the gazette, and nothing else" | The accepted host per jurisdiction, the rejected classes, and the `sha256` + human `retrieved_on` pair |
| `.claude/skills/catchlaw-rule-engine/SKILL.md` | Rule 10, "The normalisation contract, in one place" | `normaliseSpeciesTerm` is the one function; a second copy in an audit tool is the documented anti-pattern |
| `epics/CONVENTIONS.md` | §9, invariant 1 | The invariant this tool is most likely to break, and the one it must prove it does not |
| `epics/DECISIONS.md` | D-4, D-7 | The builder's one name; and that the engine holds no user-visible sentence — the audit reads Arabic, it does not author it |
| `FLUTTER_GUIDE.md` | §2.4 | A second executable in the same workspace member; the CLI and the app provably share one `rule_engine` version |
| `FLUTTER_GUIDE.md` | §6.1, §6.4 | Test naming with receipts, and why this is `dart test` in milliseconds rather than anything heavier |

## What this delivers

- `content/ae/sources.yaml` — the document ledger. One block per fetched PDF: instrument, gazette
  issue, `source_url`, `sha256`, `retrieved_on`, page range, language, and the OCR invocation and
  tool versions actually used.
- `content/ae/R1-GAZETTE-TEST.md` — the protocol, the recorded run, the measured yield, the twenty
  cross-checks with their second source, and **the decision**: proceed to T03, or open the §8
  transcriber budget line.
- `content/ae/R1-YIELD.json` — the audit's machine output, committed so the number in the prose can
  be re-derived.
- `tools/content_builder/lib/src/audit/ocr_yield.dart` — `OcrYield.scan(String text)` returning
  `CandidateRow`s and a `YieldReport`.
- `tools/content_builder/lib/src/audit/candidate_row.dart` — the row value.
- `tools/content_builder/bin/ocr_audit.dart` — the second executable,
  `dart run content_builder:ocr_audit --text <dir> --sources content/ae/sources.yaml --cross-checks
  content/ae/cross_checks.yaml --out content/ae/R1-YIELD.json`.
- `content/ae/cross_checks.yaml` — the twenty rows checked against a second published source, each
  naming that source and whether it agreed.
- `tools/content_builder/testing/fixtures/ocr_fixtures.dart` — inline Arabic OCR fixtures.
- `tools/content_builder/test/audit/ocr_yield_test.dart`,
  `test/audit/cross_checks_test.dart`, `test/audit/no_network_test.dart`.

The audit is a **second executable**. `dart run content_builder:build` never calls it, never reads
`R1-YIELD.json`, and fails no differently because of it.

## Why it is built this way

**This is the riskiest assumption in the project and it is tested before anything is authored.**
`SPEC.md` §16 R1: neither candidate PDF could be text-extracted during research, and *Arabic is the
moat*. The test is one day of work and it decides how the Gulf content is obtained — by OCR or by a
paid transcriber. Running it after three jurisdictions of authoring would mean discovering the answer
with no schedule left to act on it.

**The source is the official gazette or ministry PDF. FAOLEX abstracts and FAO translations are
rejected by name.** §8 states it and `licence-provenance.md` repeats it: an abstract is both
copyrighted and paraphrased, and *a paraphrased minimum size is a wrong number*. An FAO-commissioned
translation is worse — it is an FAO work under FAO terms, so using it is a licence violation on top
of a transcription error. `sources.yaml` therefore rejects a `source_url` whose host is an FAO or
FAOLEX domain **by name**, with a message that says why, in the same pattern E04/T01 uses for
`--force`. Somebody will paste the FAOLEX link, because it is the one that comes up first.
**Rejected:** accepting FAOLEX "just to bootstrap" — a bootstrap row is a row, and it ships.

**The audit folds with `normaliseSpeciesTerm`, imported from `package:rule_engine`.** `SPEC.md` §9.4
step 1 says NFKC comes first *because it folds Arabic Presentation Forms (U+FB50–U+FEFF), which is
exactly what OCR of the gazette PDFs emits* — this task is the reason that step exists.
`catchlaw-rule-engine` rule 10 and the A7 parity pass both forbid a second copy. An audit that counts
rows using a different fold would report a yield the app cannot reproduce, which is the worst
possible outcome here: a green light for content that searches as empty. **Rejected:** a private
regex in the audit tool, which is `check_content_pipeline.sh` check 4's exact target.

**"Clean" is defined mechanically, and the twenty cross-checks are human.** §16 R1 asks how many
species rows *come out clean*. A tool cannot judge whether a transcription is right, so it judges
what it can, and the file records what a person judged. A candidate row counts as **clean** when all
four hold:

1. after the shared fold, the species term is at least two Arabic letters and contains no Latin
   letter — a mixed-script term is an OCR artefact, not a name;
2. the row carries exactly one numeric value with a length unit token (`سم`, `مم`, `cm`, `mm`), with
   Arabic-Indic and Eastern Arabic-Indic digits mapped to ASCII per §9.4 step 6;
3. the row contains no `U+FFFD` replacement character and no unmapped Presentation Form after NFKC;
4. the value falls in a plausible length range, so a page number or a decision number cannot be
   counted as a minimum size.

Two numbers on one row is **not** clean, because "45–65" and "45 cm, 65 cm" are indistinguishable to
a scanner and the difference is a min/max pair versus two species. `build-assertions.md` already
records the sibling failure at authoring time: *a size copied from a PDF table without its column
header*.

**The tool refuses to report a pass on fewer than twenty cross-checks.** §16 R1's bar has two halves
and the second is the one that is easy to skip. `YieldReport.verdict` is `pass` only when
`cleanRows >= 80` **and** `crossChecks.confirmed >= 20`; otherwise it is `fail`, and a
`crossChecks` file with nineteen rows produces `fail` with a message naming the shortfall rather than
a near-miss. **Rejected:** a `--assume-cross-checks` flag, for the reason
`catchlaw-content-pipeline` rule 2 gives about every flag of that shape.

**Nothing in this task opens a socket.** `ocrmypdf` and Tesseract run in a human's terminal; the PDF
is fetched by a human; the tool reads text files off disk. Invariant 1 is about `app/lib/` and
`pubspec.yaml`, but the honest reading covers a tool in this workspace too, and this is the one task
whose subject matter makes "just download it in the tool" sound reasonable. `test/audit/
no_network_test.dart` greps the package's own source for the banned symbols so the ban is proved by
the suite, not only by review.

**The exact invocation and tool versions are recorded, not asserted here.** A protocol that does not
record `ocrmypdf --version` and the Tesseract `ara` traineddata version cannot be re-run, and this
plan does not know what versions the machine will have. `R1-GAZETTE-TEST.md` carries the invocation
as run — the `-l ara` language selection, whether `--redo-ocr` was needed on a PDF that already had a
bad text layer, and the text-extraction step — together with the versions printed on the day.

**If the test fails, the mitigation is written into the same file, and it is not a release phase.**
§16 R1 rejects the first draft's "ship Galicia + Spain + Brazil first and treat Arabic as a content
problem" in terms: *that is a release phase that deletes the only RTL locale and the stated moat*.
The correct mitigation is §8's named budget line for a paid Arabic-speaking transcriber working from
the official gazette, and **the app does not ship until Arabic rule rows exist**.
`R1-GAZETTE-TEST.md` records which path was taken and, if it was the transcriber, the engagement
reference that will appear on the T03 rows' review sign-off (T01's A11, scope `legal_text`).

## Tests first

Write every row before touching `ocr_yield.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `OcrYield.scan counts a row carrying an Arabic term and one minimum length` | `هامور ٤٥ سم` | one clean row, `45` mm-equivalent value, unit `سم` | The headline case the whole test exists to count |
| 2 | `ar - OcrYield.scan folds Presentation Forms before matching` | the same row written in U+FB50–U+FEFF forms | one clean row, identical to case 1 | §9.4 step 1's stated reason: this is exactly what OCR of a gazette PDF emits |
| 3 | `ar - OcrYield.scan maps Arabic-Indic digits to ASCII` | `٤٥` | value `45` | §9.4 step 6; without it every Gulf minimum reads as zero rows |
| 4 | `ar - OcrYield.scan maps Eastern Arabic-Indic digits to ASCII` | `۴۵` | value `45` | The second digit block §9.4 step 6 names, and the one nobody remembers |
| 5 | `OcrYield.scan rejects a row containing a replacement character` | `هام�ور ٤٥ سم` | zero clean rows | `U+FFFD` is the scanner telling you it failed; counting it is counting a guess |
| 6 | `OcrYield.scan rejects a row whose term mixes Arabic and Latin letters` | `هامoور ٤٥ سم` | zero clean rows | A Latin `o` inside an Arabic word is an OCR substitution, and the name will never match a query |
| 7 | `OcrYield.scan rejects a row with two numeric values` | `هامور ٤٥ ٦٥ سم` | zero clean rows | A min/max pair and two species are indistinguishable to a scanner; §8's recorded cause is a size copied without its column header |
| 8 | `OcrYield.scan rejects a row with a number and no unit token` | `هامور ٤٥` | zero clean rows | A page number, a decision number and a minimum length all look like `45` |
| 9 | `OcrYield.scan rejects a numeric value outside the plausible length range` | `هامور ٥٨٠ سم` | zero clean rows | `580` is Ministerial Decision 580/2015 bleeding in from the header |
| 10 | `OcrYield.scan rejects a term shorter than two Arabic letters` | `ه ٤٥ سم` | zero clean rows | A one-letter term is a fragment of a broken ligature |
| 11 | `OcrYield.scan accepts a millimetre unit token` | `ربيان ٨٠ مم` | one clean row | Shellfish minima are published in millimetres and the audit must not be finfish-only |
| 12 | `OcrYield.scan reports the source line of every candidate row` | a three-row fixture | lines 1, 2, 3 | The human cross-check has to find the row in the OCR output |
| 13 | `OcrYield.scan uses the engine normaliser for the species term` | a term with tatweel and harakat | folded identically to `normaliseSpeciesTerm` | Rule 10; a yield the app cannot reproduce is a false green light |
| 14 | `YieldReport.verdict is pass with 80 clean rows and 20 confirmed cross-checks` | 80 / 20 | `pass` | §16 R1's bar, on the boundary |
| 15 | `YieldReport.verdict is fail with 79 clean rows` | 79 / 20 | `fail`, message naming the shortfall | The off-by-one that would declare the moat safe a row early |
| 16 | `YieldReport.verdict is fail with 80 clean rows and 19 confirmed cross-checks` | 80 / 19 | `fail`, message naming the cross-check shortfall | The half of the bar that is easy to skip |
| 17 | `CrossChecks.load reports a row whose second source is absent` | entry with `agrees:` and no `second_source:` | one failure at the entry's line | "Cross-checked" against nothing is the failure mode of a checklist |
| 18 | `Sources.load rejects a source_url on an FAOLEX host by name` | `source_url` on the FAOLEX domain | usage failure naming the host and the reason | §8: never from FAOLEX's abstract; it is the first link anybody finds |
| 19 | `Sources.load rejects an FAO-commissioned translation by name` | `origin: fao_translation` | usage failure quoting "an FAO work under FAO terms" | §8's second rejection, and the one that is a licence violation as well as an error |
| 20 | `Sources.load reports a document with no sha256` | block without `sha256` | one failure | `licence-provenance.md`: the digest is what makes "we read this document" checkable later |
| 21 | `content_builder declares no network symbol` | the package's own `lib/` and `bin/` | no match for `HttpClient`, `Socket`, `Uri.https`, `package:http` | Invariant 1, proved by the suite in the one task where downloading in-tool sounds reasonable |
| 22 | `content_builder:build does not reference the OCR audit` | `lib/src/cli/run.dart` | no import of `src/audit/` | The audit must not become a build step; a build that depends on a scanner is a build nobody can run |

```dart
// tools/content_builder/test/audit/ocr_yield_test.dart
import 'package:content_builder/src/audit/ocr_yield.dart';
import 'package:content_builder/testing/fixtures/ocr_fixtures.dart';
import 'package:rule_engine/rule_engine.dart' show normaliseSpeciesTerm;
import 'package:test/test.dart';

void main() {
  group('OcrYield.scan', () {
    test('counts a row carrying an Arabic term and one minimum length', () {
      final rows = OcrYield.scan('هامور ٤٥ سم').cleanRows;

      expect(rows, hasLength(1));
      expect(rows.single.valueMm, 450);
      expect(rows.single.term, normaliseSpeciesTerm('هامور'));
    });

    test('ar - folds Presentation Forms before matching', () {
      final presentationForm = OcrYield.scan(kHamourPresentationFormRow).cleanRows;

      expect(presentationForm.single.term, normaliseSpeciesTerm('هامور'));
    });

    test('rejects a row with two numeric values', () {
      expect(OcrYield.scan('هامور ٤٥ ٦٥ سم').cleanRows, isEmpty);
    });

    // … one test per row above, one behaviour each
  });

  group('YieldReport.verdict', () {
    test('is fail with 80 clean rows and 19 confirmed cross-checks', () {
      final report = YieldReport(cleanRows: 80, confirmedCrossChecks: 19);

      expect(report.verdict, Verdict.fail);
      expect(report.message, contains('19 of 20'));
    });
  });
}
```

```dart
// tools/content_builder/test/audit/no_network_test.dart
import 'dart:io';
import 'package:test/test.dart';

void main() {
  test('content_builder declares no network symbol', () {
    const banned = ['package:http', 'HttpClient', 'Socket', 'Uri.https', 'Uri.http'];
    final sources = [
      ...Directory('lib').listSync(recursive: true),
      ...Directory('bin').listSync(recursive: true),
    ].whereType<File>().where((f) => f.path.endsWith('.dart'));

    for (final file in sources) {
      final text = file.readAsStringSync();
      for (final symbol in banned) {
        expect(text, isNot(contains(symbol)), reason: '${file.path} names $symbol');
      }
    }
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/audit/)` → 22 failures. If case 21 passes now,
it is the one case that is allowed to — the package has no network symbol today, and the test exists
to keep it that way. Every other case must be red; case 2 in particular passes trivially against an
implementation that never folds, so check the fixture really is in Presentation Forms before
believing it.

## Implementation outline

1. `CandidateRow` — `line`, `rawTerm`, `term` (folded), `valueMm`, `unit`, `rejectReason`. Rejected
   rows are kept with their reason, because the interesting output of a failed R1 is *why* the rows
   were dirty.
2. `OcrYield.scan(String)` — split on line breaks; for each line apply `normaliseSpeciesTerm` from
   `package:rule_engine/rule_engine.dart` to the term span and the four clean-ness rules above.
   No regex touches an Arabic letter before NFKC has run.
3. `YieldReport` — counts, the verdict, and a message that names both halves of the bar. `toJson()`
   for `R1-YIELD.json`, keys sorted so the committed file is stable.
4. `Sources.load` and `CrossChecks.load` — the two ledgers, with the host rejections and the required
   fields. The FAO/FAOLEX rejection carries its own message, not a generic "host not allowed".
5. `bin/ocr_audit.dart` — options, run, write the JSON, print the report to `stdout`. `stdout.writeln`
   is the correct channel for a CLI; `print` is still not (`CONVENTIONS.md` §8).
6. **Then do the actual test**: fetch the gazette or ministry PDFs by hand, record each in
   `sources.yaml` with its sha256 and the date a human fetched it, run `ocrmypdf` with Tesseract
   `ara`, extract the text, run the audit, and write up `R1-GAZETTE-TEST.md` — including the
   invocation, the tool versions printed on the day, the yield, the twenty cross-checks with their
   second source, and the decision.
7. If the verdict is `fail`, `R1-GAZETTE-TEST.md` records the §8 transcriber budget line as the
   mitigation, names the engagement, and states that Arabic rule rows remain a release blocker. It
   does **not** propose a Gulf-less first release.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 22 rows pass, and each failed first (case 21 excepted, and the exception is stated in the
      commit body).
- [ ] 100 % branch coverage on `ocr_yield.dart`, including every one of the four clean-ness rules and
      both halves of the pass bar.
- [ ] `content/ae/sources.yaml` names only official gazette or ministry documents, each with a
      `sha256` and a human `retrieved_on`; no FAOLEX and no FAO-commissioned translation.
- [ ] `content/ae/R1-GAZETTE-TEST.md` records the invocation, the tool versions as printed, the
      measured yield, the twenty cross-checks and the decision — and states the pass bar it was
      measured against.
- [ ] `content/ae/R1-YIELD.json` is committed and re-running the audit over the same text reproduces
      it byte for byte.
- [ ] `dart run content_builder:build` behaves identically with and without `R1-YIELD.json` present.
- [ ] No `dart:io` socket, no `package:http`, no `Uri.https` anywhere in `tools/content_builder/`.
- [ ] `grep -rn "String normalise" tools/content_builder/lib` returns nothing — the fold is imported.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
.claude/skills/catchlaw-rule-engine/scripts/check_rule_engine.sh packages/rule_engine/lib
```

The rule-engine gate runs here because this task imports the fold: if the audit tempted anybody into
"just adding one more step" to `normaliseSpeciesTerm`, that is where it shows.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): add the OCR yield audit and record the R1 gazette test

SPEC.md §16 R1 is the riskiest assumption in the project: neither candidate PDF
could be text-extracted during research, and Arabic is the moat. The one-day
test is ocrmypdf plus Tesseract ara over the official gazette or ministry PDFs,
and the bar is 80 species rows with a numeric minimum length transcribed with
confidence in a day, twenty of them cross-checked against a second published
source. It runs now, before a single Gulf row is authored, because finding the
answer later leaves no schedule to act on it.

FAOLEX abstracts and FAO-commissioned translations are rejected by name, with
the reason in the message: an abstract is paraphrased and a paraphrased minimum
size is a wrong number, and an FAO translation is an FAO work under FAO terms.
The FAOLEX link is the first one anybody finds.

The audit folds with normaliseSpeciesTerm imported from package:rule_engine.
§9.4 step 1 puts NFKC first precisely because Presentation Forms are what OCR
of these PDFs emits, and a yield counted under a different fold is a green
light for content the app can never search.

"Clean" is mechanical — one Arabic term of two letters or more with no Latin
substitution, exactly one numeric value with a length unit, no replacement
character, and a plausible range — and the twenty cross-checks are human. The
report refuses to say pass on nineteen.

Nothing here opens a socket: a human fetches the PDF and records its sha256,
and a test greps this package's own source for the banned symbols. If the
verdict is fail, the mitigation is §8's named budget line for a paid Arabic
transcriber working from the official gazette. It is not a Gulf-less first
release: the app does not ship until Arabic rule rows exist.

Task: E22/T02
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
