# E04/T03 — Every key resolves, in every shipped locale

| | |
|---|---|
| **Epic** | E04 — Content builder and the Galicia seed |
| **Branch** | `epic/04-content-build` (shared) |
| **Commit** | `feat(content_builder): fail the build on a *_key that misses any of the six locales` |
| **Depends on** | T01 (the loader and the registry) |
| **Size** | M |
| **Spec** | `SPEC.md` §8 bullet 2, §9.2 (two-tier translation and the fallback chain), §9.6, §13 "Localisation completeness" |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-content-pipeline` | Rule 4 (every `*_key` resolves in every shipped locale, no fallback chain) and rule 11 (verbatim legal text is single-locale and may not be keyed into `content_string`) |
| `catchlaw-conventions-index` | Rule 12 — six locales ship together or the feature does not ship; and D-3 corrects which six |
| `catchlaw-reference-database` | `content_string` is content, replaced wholesale and never patched: a missing row cannot be filled in later |
| `testing-strategy` | The loop-generated test naming rule — the locale must be interpolated into the description |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §8, bullet 2 | The named columns: `family.name_key`, `citation.instrument_type_key`, `gear_rule.gear_name_key`, "and the rest" |
| `SPEC.md` | §7.1 | The complete list of `*_key` columns — this task enumerates them from the schema, not from memory |
| `SPEC.md` | §9.2 | Tier 1 versus tier 2, and the fallback chain that exists **at runtime** precisely because the build fails first |
| `SPEC.md` | §9.6 | Verbatim legal text is single-locale; it is not `content_string` and is not translated |
| `SPEC.md` | §13, "Localisation completeness" | "The content build fails on any missing `content_string` key in any shipped locale" |
| `.claude/skills/catchlaw-content-pipeline/references/build-assertions.md` | A2 row, "A2 and A3 — locale coverage and gender" | The failure message shape and "There is no fallback chain: a key resolves in every one or the build dies" |
| `.claude/skills/catchlaw-content-pipeline/references/licence-provenance.md` | "The two translation tiers" | Why no `content_string` row may key a `legal_text.*` id |
| `.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh` | checks 1 and 6 | The gate's `DEFS` are built from `key:` lines in YAML — which fixes how `strings.yaml` must be shaped |
| `epics/DECISIONS.md` | D-3 | `ar`, `en`, `es`, `gl`, `ca`, `pt_BR`. Never `ur`, never `app_pt` |

## What this delivers

- `tools/content_builder/lib/src/locales.dart` — `const kShippedLocales = <String>['ar', 'ca', 'en',
  'es', 'gl', 'pt_BR'];` the single list every later assertion reads.
- `tools/content_builder/lib/src/assert/a02_locale_coverage.dart` — `LocaleCoverageAssertion`.
- `tools/content_builder/lib/src/model/key_reference.dart` — `KeyReference(key, path, line, column)`,
  emitted by the loader for every `*_key` column in `SPEC.md` §7.1.
- `content/shared/strings.yaml` and `content/es-ga/strings.yaml` — the authored `content_string`
  format, one block per key with all six locales beneath it.
- `tools/content_builder/test/assert/a02_locale_coverage_test.dart`.

The `*_key` columns this assertion covers, read out of `SPEC.md` §7.1: `jurisdiction.name_key`,
`jurisdiction.authority_key`, `zone.name_key`, `family.name_key`, `measurement_method.name_key`,
`measurement_method.definition_key`, `citation.instrument_type_key`, `rule.notes_key`,
`closed_season.notes_key`, `licence_type.name_key`, `licence_type.description_key`,
`gear_rule.gear_name_key`, `gear_rule.constraint_key`, `penalty.offence_key`,
`penalty.secondary_key`, `lookalike.difference_key`, `glossary_term.term_key`,
`glossary_term.definition_key`, `content_change.summary_key`, `content_change.detail_key`,
`key_node.question_key`, `key_option.label_key`. Nullable columns are checked when present.

The authored shape, chosen so `check_content_pipeline.sh` check 1 can see the definitions:

```yaml
# content/shared/strings.yaml
strings:
  - key: family.veneridae
    values:
      ar: …
      ca: …
      en: Venus clams
      es: …
      gl: Ameixas
      pt_BR: …
```

## Why it is built this way

**Six locales, D-3, and the skill is wrong about one of them.**
`catchlaw-content-pipeline` rule 4 and `build-assertions.md` both list `ur`. D-3 settles it: Catalan
ships because Catalonia, Valencia and the Balearics publish their fishing orders in Catalan, and Urdu
appears nowhere in `SPEC.md` and has no bundled instrument. `kShippedLocales` is declared once, in
`lib/src/locales.dart`, and T04, T05, T09 and T10 all read it — six copies of a locale list is how one
of them keeps `ur` after the correction lands.

**No fallback at build time, and a fallback chain at runtime.** These are not in tension.
`SPEC.md` §9.2 ends: *A missing Tier-2 string never renders a raw key or an empty string, because the
build fails first (§8).* The runtime chain — requested locale → jurisdiction `default_locale` → `en` →
scientific name — exists for locale *selection*, not for gaps in the corpus. If the build let `en`
stand in for `ca`, the chain would silently render Spanish law in English to a Catalan speaker and
nobody would ever see a defect. **Rejected:** a `--allow-missing-locale` flag for authoring in
progress. T01 rejects that name explicitly; a partially translated key is authored into a branch, not
into `main`.

**A placeholder value is a missing string wearing a disguise.** A2 fails on an empty value, on a
whitespace-only value, and on a value byte-identical to its own key. `TODO`, `TBD` and `???` are
caught by the same rule as any other string that is not a translation — the check is that the value is
non-empty and differs from the key, and the review that catches `TODO` is the human one. Without this,
`value: gear.trawl` resolves, renders, and looks like a Catalan gear name to a build.

**The second half of A2 is the `legal_text.` ban.** `SPEC.md` §9.6 and
`licence-provenance.md` agree: verbatim legal text is bundled in the language the authority published
it in, and an unofficial translation of a penal instrument is a liability that also falls outside
Spain's Art. 13 LPI carve-out, which covers *official* translations only. So no `content_string` key
may begin `legal_text.`, and A2 fails on one. `check_content_pipeline.sh` check 6 greps for the same
thing, which is a floor: the grep matches `key: legal_text.…` and a key assembled from a variable
would slip past it. The build's check reads the loaded corpus and cannot.

**An unreferenced key is not a failure.** Shared glossary and family strings are authored ahead of the
rows that use them, and E22 will add jurisdictions that consume them. A2 reports unreferenced keys on
stdout as a count, and fails on none of them. **Rejected:** failing on orphans. It would force E22 to
author a rule and its strings in the same commit, which is the opposite of the parallel-authoring
shape `SPEC.md` §15 step 19 asks for.

**`strings.yaml` uses `- key:` because the gate greps for it.**
`check_content_pipeline.sh` builds its `DEFS` set from lines matching `^\s*(- )?key:`. A tidier
mapping — `family.veneridae: {ar: …}` — would leave `DEFS` empty and make check 1 report every
reference in the corpus as undefined. `DECISIONS.md` D-2's rule of thumb applies: the gate script
beats the prose whenever they disagree about a shape.

## Tests first

Write every row before touching `a02_locale_coverage.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LocaleCoverageAssertion reports A2 when a key is missing for $locale` (loop over the six) | a key defined in five locales, missing `$locale` | one `A2` naming `$locale` | Every locale is load-bearing; a loop that names only the first proves nothing about `pt_BR` |
| 2 | `LocaleCoverageAssertion names every missing locale in one failure` | a key defined only in `en` | one `A2` listing `ar, ca, es, gl, pt_BR` | Five failures for one key buries the twenty other keys; the message shape in `build-assertions.md` lists them |
| 3 | `LocaleCoverageAssertion accepts a key defined in all six locales` | complete block | no failures | The green path |
| 4 | `LocaleCoverageAssertion reports A2 when a referenced key is defined nowhere` | `name_key: family.ghost` | one `A2` at the referencing line | The message must point at the row that referenced it, not at `strings.yaml` — the author fixes the reference or adds the key, and needs to see which row asked |
| 5 | `LocaleCoverageAssertion reports A2 when a value is the empty string` | `ca: ''` | one `A2` | An empty value resolves and renders a blank line under the verdict stamp |
| 6 | `LocaleCoverageAssertion reports A2 when a value is whitespace only` | `ca: '   '` | one `A2` | A blank that survives a diff review |
| 7 | `LocaleCoverageAssertion reports A2 when a value equals its own key` | `ca: gear.trawl` | one `A2` | The placeholder that looks like a translation |
| 8 | `LocaleCoverageAssertion reports A2 when a content_string key begins legal_text.` | `key: legal_text.dog_2012_art4` | one `A2` | `SPEC.md` §9.6 — a translated penal instrument is a liability, and the grep gate misses an assembled key |
| 9 | `LocaleCoverageAssertion covers every nullable *_key column when present` (loop over `rule.notes_key`, `gear_rule.constraint_key`, `penalty.secondary_key`, `content_change.detail_key`) | `$column` set to an undefined key | one `A2` per case | Nullable does not mean unchecked; these four are the ones an author sets last and translates never |
| 10 | `LocaleCoverageAssertion ignores a nullable *_key column that is absent` | `rule.notes_key` omitted | no failures | The other half of case 9 — the check must not require an optional column |
| 11 | `LocaleCoverageAssertion reports an unreferenced key as a count and not a failure` | one orphan key | no failures, count 1 in the report | E22 authors strings ahead of rows; failing here would forbid that |
| 12 | `LocaleCoverageAssertion reports A2 when the same key is defined in two files` | key in `shared/strings.yaml` and `es-ga/strings.yaml` | one `A2` naming both lines | Two definitions means the winner depends on directory walk order, which is not a translation decision |
| 13 | `LocaleCoverageAssertion reports A2 when a key carries an unknown locale` | `values: {ur: …}` | one `A2` naming `ur` | D-3 removed Urdu; a leftover `ur` block would otherwise sit in the corpus looking translated |
| 14 | `kShippedLocales holds exactly ar, ca, en, es, gl and pt_BR` | — | the six, sorted | D-3, pinned in a test so a seventh cannot be added without a decision |

```dart
// tools/content_builder/test/assert/a02_locale_coverage_test.dart
import 'package:content_builder/src/assert/a02_locale_coverage.dart';
import 'package:content_builder/src/locales.dart';
import 'package:content_builder/testing/fixtures/yaml_fixtures.dart';
import 'package:test/test.dart';

void main() {
  group('LocaleCoverageAssertion', () {
    for (final locale in kShippedLocales) {
      test('reports A2 when a key is missing for $locale', () {
        final source = contentSourceMissing(locale: locale, key: 'gear.trawl');
        final failures = const LocaleCoverageAssertion().run(source).toList();

        expect(failures, hasLength(1));
        expect(failures.single.id, 'A2');
        expect(failures.single.message, contains(locale));
      });
    }

    test('reports A2 when a content_string key begins legal_text.', () {
      final source = contentSourceWithString(key: 'legal_text.dog_2012_art4');
      final failures = const LocaleCoverageAssertion().run(source).toList();

      expect(failures.single.message, contains('legal_text'));
    });

    test('kShippedLocales holds exactly ar, ca, en, es, gl and pt_BR', () {
      expect(kShippedLocales, ['ar', 'ca', 'en', 'es', 'gl', 'pt_BR']);
    });

    // … one test per row above, one behaviour each
  });
}
```

**Run:** `(cd tools/content_builder && dart test test/assert/a02_locale_coverage_test.dart)` → every
case red, six of them from the locale loop alone. If any passes now, the test is wrong.

## Implementation outline

1. `lib/src/locales.dart` with `kShippedLocales`, sorted, `const`, documented with a pointer to D-3.
2. Extend the loader (T01) to emit a `KeyReference` for every `*_key` column it parses, carrying the
   referencing file, line and column name. Do not scan text for `_key` — walk the typed rows, so a
   column added later is a compile-time change rather than a silent miss.
3. `LocaleCoverageAssertion.run` builds `Map<String, Map<String, String>>` from the `strings` blocks,
   failing on a duplicate key across files as it goes.
4. For each `KeyReference`: missing key → one failure at the reference; present but incomplete → one
   failure listing every missing locale, sorted.
5. Value checks — empty, whitespace-only, equal to the key — on every locale of every defined key.
6. Unknown locale in a `values` block → one failure naming it.
7. Any defined key starting `legal_text.` → one failure.
8. Unreferenced keys counted and printed on stdout with the corpus summary; never a failure.
9. Register in `ContentSource.assertions` after A1.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All cases pass, and each failed first.
- [ ] 100 % branch coverage on `lib/src/assert/a02_locale_coverage.dart`.
- [ ] Every `*_key` column listed in `SPEC.md` §7.1 appears in the loader's `KeyReference` emission,
      proved by a test that counts them.
- [ ] `grep -rn "'ur'" tools/content_builder/lib` returns nothing (D-3).
- [ ] `kShippedLocales` is the only locale list in the package.
- [ ] `check_content_pipeline.sh content` check 1 is clean against `content/shared/strings.yaml`,
      proving the authored shape is the one the gate can read.

## Gates

```bash
dart format --set-exit-if-changed tools/content_builder
dart analyze tools/content_builder
(cd tools/content_builder && dart test)
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh tools/content_builder
.claude/skills/catchlaw-content-pipeline/scripts/check_content_pipeline.sh content
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(content_builder): fail the build on a *_key that misses any of the six locales

SPEC.md §8 bullet 2 and §13 both say it: the content build fails on any
missing content_string key in any shipped locale. There is no build-time
fallback. §9.2's runtime chain — requested locale, jurisdiction default, en,
scientific name — is for locale selection, not for gaps in the corpus; if the
build let en stand in for ca, a Catalan speaker would be served Spanish law in
English and no defect would ever surface.

The six are ar, ca, en, es, gl and pt_BR per D-4's sibling decision D-3. The
skill's reference files still say ur; kShippedLocales is declared once so the
correction cannot be half-applied.

An empty value, a whitespace-only value and a value equal to its own key all
fail: each resolves, renders, and leaves a blank line or a raw key under the
verdict stamp. No content_string key may begin legal_text. — §9.6 keeps
verbatim law single-locale, and an unofficial translation of a penal
instrument sits outside Spain's Art. 13 LPI carve-out entirely.

strings.yaml uses `- key:` blocks because check_content_pipeline.sh builds its
definition set from exactly that line shape.

Task: E04/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
