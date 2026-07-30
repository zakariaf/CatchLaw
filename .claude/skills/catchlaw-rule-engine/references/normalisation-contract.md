# Normalisation Contract

The exact, ordered string transform behind every species lookup — Arabic and Latin — plus the
acceptance test that pins it. One function, `normaliseSpeciesTerm`, called by the CLI indexer and by
the runtime query, so an index key and a query key can never disagree.

## The pipeline, in order

Order matters. NFKC must run FIRST; every later step assumes canonical code points.

| # | Step | Transform | Why here |
|---|---|---|---|
| 1 | NFKC | compatibility-compose the whole string | scanned gazettes and pasted PDFs arrive as Arabic Presentation Forms (U+FB50-FDFF, U+FE70-FEFF); folding them later means the earlier steps never see them |
| 2 | Tatweel | delete U+0640 | a typographic stretch, never a letter; `هــامور` is `هامور` |
| 3 | Harakat | delete U+064B-U+0652 and U+0670 | vowel marks are optional in practice; keeping them makes every voweled alias unreachable |
| 4 | Alef fold | U+0622 آ, U+0623 أ, U+0625 إ, U+0671 ٱ to U+0627 ا | hamza placement is inconsistent across sources and keyboards |
| 5 | Waw / ya hamza | U+0624 ؤ to U+0648 و, U+0626 ئ to U+064A ي | same instability, different carrier |
| 6 | Alef maqsura | U+0649 ى to U+064A ي | Gulf typing and Egyptian typing differ; both must land together |
| 7 | Final ta-marbuta / ha | delete a word-final U+0629 ة or U+0647 ه | `هامورة` and `هامور` are the same fish |
| 8 | Arabic-Indic digits | U+0660-U+0669 and U+06F0-U+06F9 to ASCII 0-9 | zone codes and sizes are typed in either numeral set |
| 9 | Latin fold | NFD, drop combining marks, recompose, lowercase | `Ameixa babosa`, `ameixa babosa` and a mis-accented paste all match |
| 10 | Whitespace | collapse runs to one space, trim | OCR loves double spaces |

Steps 4-7 are lossy on purpose. They are safe because the output is a SEARCH KEY, never display text:
the row's `display_name_ar` is stored unmodified and is what the plate prints.

## Character reference

| Class | Code points | Action |
|---|---|---|
| Presentation Forms-A | U+FB50-U+FDFF | folded by NFKC (step 1) |
| Presentation Forms-B | U+FE70-U+FEFF | folded by NFKC (step 1) |
| Tatweel | U+0640 | deleted |
| Harakat | U+064B-U+0652 | deleted |
| Superscript alef | U+0670 | deleted |
| Alef family | U+0622, U+0623, U+0625, U+0627, U+0671 | all to U+0627 |
| Ya family | U+0649, U+064A, U+0626 | all to U+064A |
| Waw family | U+0648, U+0624 | all to U+0648 |
| Ta marbuta / final ha | U+0629, U+0647 | deleted word-finally ONLY |
| Arabic-Indic digits | U+0660-U+0669 | to 0-9 |
| Extended Arabic-Indic | U+06F0-U+06F9 | to 0-9 |
| ZWJ / ZWNJ / RLM / LRM | U+200C-U+200F | deleted |

Step 7 is word-final only. Deleting a medial ه would merge unrelated names; anchor the pattern with
a word boundary or apply it per token, never with a global `replaceAll`.

## The definite article: strip AND keep

`ال` is stripped for one index key and retained for another. BOTH keys point at the same species id.

| Alias as authored | Key A (as normalised) | Key B (article stripped) |
|---|---|---|
| `الهامور` | `الهامور` | `هامور` |
| `هامور` | `هامور` | `هامور` |
| `هامورة` | `هامور` (step 7) | `هامور` |
| `الشعري` | `الشعري` | `شعري` |
| `كنعد` | `كنعد` | `كنعد` |

The query is normalised through the same function and looked up against both key columns. Stripping
only at index time is the classic bug: the fisher types `الهامور`, the index holds `هامور`, and the
search returns nothing at 05:40 with the fish still moving.

Do not strip `ال` when the remainder is under three characters — that is a real word, not an article.

## Latin and scientific names

| Input | Normalised key |
|---|---|
| `Epinephelus coioides` | `epinephelus coioides` |
| `EPINEPHELUS COIOIDES` | `epinephelus coioides` |
| `Hamour` / `hamour` / `hammour` | `hamour` / `hamour` / `hammour` |
| `Orange-spotted grouper` | `orange-spotted grouper` |
| `Ameixa babosa` | `ameixa babosa` |
| `Venerupis corrugata` | `venerupis corrugata` |

Spelling variants such as `hammour` are NOT produced by normalisation. They are rows in
`species_alias`, authored by the content pipeline, and each row is indexed through this same
function. Normalisation folds orthography; it never guesses transliteration.

## Acceptance test

`normalise_test.dart`, run in CI, must assert exactly this:

| Query | Expected |
|---|---|
| `hamour` | `epinephelus-coioides` |
| `هامور` | `epinephelus-coioides` |
| `هامورة` | `epinephelus-coioides` |
| `الهامور` | `epinephelus-coioides` |
| `هــامور` (tatweel) | `epinephelus-coioides` |
| `Epinephelus coioides` | `epinephelus-coioides` |
| `epinephelus  coioides` (double space) | `epinephelus-coioides` |
| Presentation-Form paste of `هامور` | `epinephelus-coioides` |

One species id, eight inputs. A second assertion proves separation: `شعري` must resolve to
`lethrinus-nebulosus` and never to `epinephelus-coioides`, so the folds above are not over-merging.

## What normalisation is NOT

| Not this | Where it lives instead |
|---|---|
| Fuzzy or trigram matching | a separate FTS index, `catchlaw-reference-database` |
| Stemming or lemmatisation | nowhere — legal names are not stemmed |
| Transliteration generation | authored alias rows, `catchlaw-content-pipeline` |
| Bidi isolation or display shaping | `i18n-rtl-l10n`, on the presentation side |
| Numeral rendering for the user | `i18n-rtl-l10n`; this maps digits for KEYS only |
| Locale-sensitive casing | never — use invariant lowercase; the Turkish dotless i is a real hazard |

Use `String.toLowerCase()` without a locale, and never `toLowerCase()` on a display string. The
normalised form exists only to find a row; every character the fisher reads comes back from the row
itself, unmodified.

## Failure modes this contract prevents

| Symptom | Cause |
|---|---|
| Arabic search returns nothing, Latin search works | NFKC skipped; index holds Presentation Forms |
| `الهامور` misses but `هامور` hits | article stripped at index time only |
| `هامورة` misses | step 7 missing, or applied globally instead of word-finally |
| Results appear then vanish after a content rebuild | a second normalise copy in the CLI drifted |
| Two species collapse into one | step 7 applied medially, or `ال` stripped from a short word |
| A voweled paste from a PDF misses | harakat not stripped |
