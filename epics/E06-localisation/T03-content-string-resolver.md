# E06/T03 — The `content_string` resolver and the fallback chain

| | |
|---|---|
| **Epic** | E06 — Localisation infrastructure |
| **Branch** | `epic/06-localisation` (shared) |
| **Commit** | `feat(l10n): resolve content_string through the four-step fallback chain` |
| **Depends on** | T01 (the resolved locale is one of the six `supportedLocales`) |
| **Size** | M |
| **Spec** | `SPEC.md` §9.2 "Fallback chain"; §7.1 `content_string`, `jurisdiction.default_locale`; §8 build assertions; §13 search latency |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Rule 6, the one-way layer map: this joins `reference.db` rows with the resolved locale, so it is a **use case**, not a repository method and not engine code (D-7) |
| `catchlaw-reference-database` | Owns the read-only `reference.db` contract — `content_string` is `WITHOUT ROWID`, keyed `(key, locale)`, opened `readOnly: true` (D-6) |
| `i18n-rtl-l10n` | Tier 2 is **not** ARB. `references/arb-and-icu.md` draws the line this task must not cross: chrome goes through `AppLocalizations`, bundled content through here |
| `persistence-drift` | The DAO shape and the single-statement query; a per-locale query would be four round trips per label |
| `testing-strategy` | Rule 4 — the data layer is tested against `NativeDatabase.memory()`, never a mocked DAO; rule 3 — the "never returns the key" claim is universal and therefore a seeded fuzz |
| `naming-conventions` | `Repository` for the data seam, a verb suffix for the pure type, `Failure` for the sealed error |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §9.2 "Fallback chain" | The four steps, in order, and the sentence that ends the argument: a missing string never renders a raw key **because the build fails first** |
| `SPEC.md` | §9.2 tiers 1 and 2 | The full list of what is Tier 2: species and family names, measurement definitions, rule notes, gear names, licence and penalty descriptions, glossary, key questions, jurisdiction and zone names, instrument-type labels |
| `SPEC.md` | §7.1 | `content_string(key, locale, value)` `WITHOUT ROWID`; `jurisdiction.default_locale`; `species.scientific_name` |
| `SPEC.md` | §8, "The content pipeline is a first-class deliverable" | The assertion that makes step 4 unreachable: every `*_key` resolves in `content_string` for **every** shipped locale, or the build fails |
| `SPEC.md` | §13 | < 50 ms at 400 species / 2 400 names — why the query shape matters when S5 renders 40 rows |
| `epics/DECISIONS.md` | D-3 | The six locale values the `locale` column may hold |
| `epics/DECISIONS.md` | D-6 | `reference.db` is opened read-only; this task never writes |
| `epics/DECISIONS.md` | D-7 | The engine returns types; the app owns every word. This resolver is app-side and stays there |
| `FLUTTER_GUIDE.md` | §1.5, §2.5 | Abstract repository with a `_drift` implementation and a fixture; joins across repositories live in `domain/use_cases/` |
| `FLUTTER_GUIDE.md` | §7.5 | `Result`/`Failure` inside the data layer; `rethrow`, never `throw e` |
| `.claude/skills/i18n-rtl-l10n/references/arb-and-icu.md` | "Pitfalls" | Why a silent fallback is the defect, not the safety net |

## What this delivers

- `app/lib/data/repositories/content_string_repository.dart` — the abstract seam.
  `Future<Map<String, String>> valuesFor(String key)` returns every locale row for one key, in one
  statement.
- `app/lib/data/repositories/content_string_repository_drift.dart` — the drift implementation over the
  read-only `reference.db`.
- `app/testing/fakes/fake_content_string_repository.dart` — a bare-`implements` fake with an in-memory
  map and a call counter (`testing-strategy` rule 5; `FLUTTER_GUIDE.md` §2.5 rule 4).
- `app/lib/domain/use_cases/content_string_resolver.dart` — `ContentStringResolver`, the four-step
  chain. Pure over its inputs: no `BuildContext`, no clock, no global.
- `app/lib/domain/models/content_string_missing.dart` — `ContentStringMissing`, the failure type
  carrying the key it could not resolve.
- `app/test/domain/content_string_resolver_test.dart`,
  `app/test/data/content_string_repository_drift_test.dart`.

## Why it is built this way

**The chain is `SPEC.md` §9.2's, in its order, and the order carries meaning.** Requested locale first,
because that is what the user asked for. Then the jurisdiction's `default_locale`, because a Galician
rule written in Galician is closer to the source than an English gloss of it — this is the §9.1
argument about not presenting a Galician legal text in translation to a Galician-speaking mariscadora,
applied at the row level. Then `en`, the only language with a cross-jurisdiction vernacular source
(Catalogue of Life, §9.2 point 2). Then, for a species, the scientific name — which is Latin, present
in every locale, and never wrong.

**Step 4 is species-only, and the method signature says so.** `resolve(key, {String? scientificName})`.
For a gear name or a penalty description there is no binomial to fall back to, so the chain ends at
`en`. `SPEC.md` §9.2's four-step chain is written for the case it is illustrated with; nothing else has
a fourth step to take.

**A missing string throws, and it throws with its key.** This is the one place this epic chooses to
fail loudly, so the reasoning is written out. The only way to exhaust the chain is a `reference.db`
that violates the §8 build assertion — a database we did not build, or one that arrived corrupted. The
alternatives are all worse:

- *Return the key.* `SPEC.md` §9.2 forbids it in as many words. `species.hamour.name` on a result
  screen is a defect that looks like a design choice and survives review.
- *Return an empty string.* Forbidden in the same sentence, and it produces a blank cell that reads as
  "not recorded" — which is a real, different state (`SPEC.md` §6, S18–S23).
- *Return a value from whatever locale happens to have one.* Renders Galician inside an Arabic
  sentence, silently. A wrong vernacular name is worse than no name because it produces a confident
  wrong finding (`SPEC.md` §9.2 point 3).

There is no network and no crash upload (`CONVENTIONS.md` §9.1), so the thrown message is the only
diagnostic anyone will ever get — hence the key travels in it.

**This does not weaken invariant 5.** "An expired ruleset is still evaluated and still shown" is about
*stale* data. An unresolvable `content_string` is not stale, it is absent from a database that asserts
at build time that it is present. The two states are distinguished in
`product-invariants.md`'s stale-versus-absent matrix, and this task sits on the absent side.

**One query per key, not one per locale.** `valuesFor(key)` selects all rows for the key and the chain
runs in Dart. S5 renders up to 40 species rows (`SPEC.md` §13, capped at 40 results); a four-step chain
issuing a statement per step is 160 round trips against a `WITHOUT ROWID` table for one screen. The
counting fake in row 9 is what keeps that shape from regressing.

**Rejected: putting the chain in `packages/rule_engine/`.** D-7 is explicit — the engine returns
types carrying numbers, enums and a `Citation`, and holds no user-visible sentence in any language.
A resolver that returns "Mero moteado" is the definition of what may not live there.

**Rejected: a `content_string` cache keyed by locale.** Premature. `reference.db` is local, read-only
and indexed by a `WITHOUT ROWID` primary key; §13's budget is 50 ms for a whole search. A cache adds an
invalidation question (T06 changes the locale live) for a cost nobody has measured. If E08's list
profiling shows it is needed, it is E08's to add with a number attached.

**Rejected: making the resolver a Riverpod provider in this task.** It is a pure function of
(key, requested locale, jurisdiction default locale, row map). Keeping it pure means its 12 rows run
under `flutter test` with no container and no pump. T06 wires the provider that feeds it the resolved
locale.

## Tests first

Write every row before `content_string_resolver.dart` exists. Run them. **They must fail.** A row that
passes early is asserting the fake, not the resolver.

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ContentStringResolver.resolve returns the requested-locale value when it exists` | key with a `gl` row, requested `gl` | the `gl` value | Step 1. The case that must never take a fallback |
| 2 | `ContentStringResolver.resolve falls back to the jurisdiction default_locale when the requested locale has no row` | requested `ca`, default `gl` | the `gl` value | Step 2 — and the §9.1 argument: the jurisdiction's own publication language beats English |
| 3 | `ContentStringResolver.resolve falls back to en when neither the requested locale nor default_locale has a row` | requested `ca`, default `gl`, only `en` present | the `en` value | Step 3 |
| 4 | `ContentStringResolver.resolve returns the scientific name when no locale has a row` | no rows, `scientificName: 'Epinephelus coioides'` | `Epinephelus coioides` | Step 4, species only. Latin is present in every locale and is never wrong |
| 5 | `ContentStringResolver.resolve throws ContentStringMissing when no locale has a row and no scientific name is supplied` | no rows, no binomial | throws | A gear or penalty key has no fourth step. Loud beats a raw key on a legal statement |
| 6 | `ContentStringMissing names the key it could not resolve` | `'gear.trammel_net.name'` | message contains the key | No network, no crash upload — the message is the only diagnostic that will ever exist |
| 7 | `ContentStringResolver.resolve prefers the requested locale over default_locale when both exist` | both `ar` and `en` rows, requested `ar` | the `ar` value | Order is the contract. A `Map` iteration that happens to start at `en` would pass rows 1–3 and fail this one |
| 8 | `ContentStringResolver.resolve treats pt_BR as distinct from pt` | only a `pt` row, requested `pt_BR` | falls through to `en` | D-3: the region is carried because the content is Brazilian, not Iberian. A prefix match here would ship Iberian wording to Brazil |
| 9 | `ContentStringResolver.resolve queries the repository once per key` | one key, chain reaching step 3 | fake call count is 1 | §13: S5 renders 40 rows. One statement per chain step is 160 round trips for one screen |
| 10 | `ContentStringResolver.resolve never returns the key itself` | seeded fuzz, 200 generated keys with random partial locale coverage | never equal to the key | `SPEC.md` §9.2's flat prohibition, asserted as a universal rather than an example (`testing-strategy` rule 3). The generated key goes in `reason:` so a failure is its own repro |
| 11 | `ContentStringResolver.resolve returns the gl value for a gl request on a jurisdiction whose default_locale is es` | requested `gl`, default `es`, both rows present | the `gl` value | The §9.1 headline case, stated as a test: a Galician user is not handed the Spanish translation of a Galician instrument |
| 12 | `ContentStringRepositoryDrift.valuesFor returns every locale row for one key` | in-memory DB, six rows | six entries | Against a real `NativeDatabase.memory()`, never a mocked DAO (`testing-strategy` rule 4) |
| 13 | `ContentStringRepositoryDrift.valuesFor returns an empty map for an unknown key` | in-memory DB | `{}` | The resolver's step-5 path must be reachable from real SQL, not only from the fake |
| 14 | `ContentStringRepositoryDrift opens reference.db read-only` | in-memory DB configured read-only | a write throws | D-6. A writable open lets drift run `onCreate` against shipped content and breaks every later sha256 check |
| 15 | `every content_string key in the fixture reference.db resolves for all six locales` | fixture DB from E04 | no throw | The §8 build assertion, mirrored on the app side. Catches a `reference.db` built by an older builder |

```dart
// app/test/domain/content_string_resolver_test.dart
import 'dart:math';

import 'package:catchlaw/domain/models/content_string_missing.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes/fake_content_string_repository.dart';

void main() {
  group('ContentStringResolver', () {
    test('.resolve falls back to the jurisdiction default_locale when the requested '
        'locale has no row', () async {
      final repo = FakeContentStringRepository({
        'species.hamour.name': {'gl': 'Mero', 'en': 'Orange-spotted grouper'},
      });
      final resolver = ContentStringResolver(repo);

      final value = await resolver.resolve(
        'species.hamour.name',
        requestedLocale: 'ca',
        defaultLocale: 'gl',
      );

      expect(value, 'Mero');
    });

    test('.resolve treats pt_BR as distinct from pt', () async {
      final repo = FakeContentStringRepository({
        'gear.rede.name': {'pt': 'Rede de emalhar', 'en': 'Gillnet'},
      });
      final resolver = ContentStringResolver(repo);

      final value = await resolver.resolve(
        'gear.rede.name',
        requestedLocale: 'pt_BR',
        defaultLocale: 'pt_BR',
      );

      expect(value, 'Gillnet');
    });

    test('.resolve queries the repository once per key', () async {
      final repo = FakeContentStringRepository({
        'gear.rede.name': {'en': 'Gillnet'},
      });
      final resolver = ContentStringResolver(repo);

      await resolver.resolve('gear.rede.name',
          requestedLocale: 'ar', defaultLocale: 'es');

      expect(repo.callCount, 1);
    });

    test('.resolve throws ContentStringMissing when no locale has a row and no '
        'scientific name is supplied', () async {
      final resolver = ContentStringResolver(FakeContentStringRepository(const {}));
      await expectLater(
        resolver.resolve('gear.trammel_net.name',
            requestedLocale: 'ar', defaultLocale: 'ar'),
        throwsA(isA<ContentStringMissing>()
            .having((e) => e.key, 'key', 'gear.trammel_net.name')),
      );
    });

    // Universal claim -> seeded fuzz against generated coverage, per
    // testing-strategy rule 3. The generated input is its own minimal repro.
    test('.resolve never returns the key itself', () async {
      final rng = Random(0xCA7C41);
      const locales = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR'];
      for (var seed = 0; seed < 200; seed++) {
        final key = 'k$seed.${rng.nextInt(1 << 20)}';
        final present = <String, String>{
          for (final l in locales)
            if (rng.nextBool()) l: '$l value $seed',
        };
        final resolver = ContentStringResolver(
          FakeContentStringRepository({key: present}),
        );
        final requested = locales[rng.nextInt(locales.length)];
        final fallback = locales[rng.nextInt(locales.length)];
        try {
          final value = await resolver.resolve(key,
              requestedLocale: requested,
              defaultLocale: fallback,
              scientificName: 'Epinephelus coioides');
          expect(value, isNot(key),
              reason: 'seed=$seed present=${present.keys} '
                  'requested=$requested default=$fallback');
        } on ContentStringMissing {
          fail('seed=$seed threw with a scientific name available');
        }
      }
    });
  });
}
```

**Run:** `cd app && flutter test test/domain/content_string_resolver_test.dart test/data/content_string_repository_drift_test.dart`
→ 15 rows red. If row 10 passes before the resolver exists, the fuzz loop is not calling anything.

## Implementation outline

1. Write the abstract `ContentStringRepository` with the single `valuesFor(String key)` method, and
   `FakeContentStringRepository` implementing it bare (`implements`, no `noSuchMethod` superclass) with
   a `callCount` field. An interface change must be a compile error, not a runtime surprise.
2. Write `ContentStringMissing` — a `Failure` type carrying `key`, with a `toString` that names it.
3. Write `ContentStringResolver.resolve`. Four explicit steps in `SPEC.md` §9.2's order, evaluated over
   the single map returned by `valuesFor`. No early return before the map is fetched; no second fetch.
4. Make rows 1–11 green.
5. Write the drift DAO and `ContentStringRepositoryDrift` against `NativeDatabase.memory()`. Row 14
   asserts the read-only open (D-6) — write it as a failing write, not as an inspection of a flag.
6. Row 15 walks the E04 fixture database. If E04's fixture is not yet importable from `app/`, the row
   uses the smallest fixture that E05's tests already build and says so in a comment — it does not get
   dropped.
7. Re-run the whole suite: T01's tests must still be green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 15 rows pass, and each failed first.
- [ ] `resolve` can return neither the key nor an empty string on any path — proved by row 10's fuzz,
      not by reading the function.
- [ ] Exactly one repository call per `resolve`, asserted by the counting fake.
- [ ] `packages/rule_engine/` is untouched (D-7) — no sentence, in any language, was added to it.
- [ ] `reference.db` is opened `readOnly: true` and nothing in this commit writes to it (D-6).
- [ ] `ContentStringResolver` imports no Flutter widget library and takes no `BuildContext`.
- [ ] The four chain steps appear in `SPEC.md` §9.2's order, and the doc comment cites §9.2 rather than
      restating it.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh  app/lib
```

`check_reference_db.sh` is the gate that proves the read-only open and the untouched launch path — the
contract is enforced by its owning skill rather than re-derived here.

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(l10n): resolve content_string through the four-step fallback chain

Requested locale, then the jurisdiction's default_locale, then en, then the
scientific name (SPEC.md §9.2). The second step is not politeness: a Galician
rule written in Galician is closer to the source than an English gloss, which
is the §9.1 argument applied one row at a time.

Exhausting the chain throws with the key rather than returning it. §9.2
forbids a raw key and an empty string, and the only way to get there is a
reference.db that violates the §8 build assertion — a database we did not
build. There is no crash upload, so the thrown key is the only diagnostic
anyone will ever have.

One statement per key, not one per chain step: S5 renders 40 rows and a
per-step query would be 160 round trips for one screen (§13).

Task: E06/T03
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
