# E08/T06 — The look-alike card

| | |
|---|---|
| **Epic** | E08 — Species: search, browse and the static detail |
| **Branch** | `epic/08-species` (shared) |
| **Commit** | `feat(species): state the confusable species and the character that separates them` |
| **Depends on** | T05 (S2's static half and its section layout) |
| **Size** | S |
| **Spec** | `SPEC.md` §4.3 "Look-alike warnings", §6 S2 (look-alike card), §7.1 `lookalike`, §9.2 (Tier 2) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `lonja-icons-and-plates` | Both members of a look-alike pair carry a plate, never a silhouette — and the reference tabulates the four pairs and the character each plate must draw |
| `lonja-lists-and-tables` | The card is a ruled block, not a `Card` with elevation; rule 8 binds what it may say |
| `lonja-typography` | The difference sentence is bundled content quoting a diagnostic character, so it is set in the serif legal step, not in the UI sans |
| `catchlaw-reference-database` | `lookalike` is a fourth read inside `reference.db`; `difference_key` resolves through `content_string` |
| `catchlaw-conventions-index` | Invariant 2: the card states a character, it never tells the fisher what to do about it |
| `widget-composition` | One widget class, `const`-constructible, with the tap resolving the confused-with id rather than a captured value |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.3 "Look-alike warnings" row | "Per species, 'commonly confused with X' with the difference stated. Every protected species carries one if a legal look-alike exists" |
| `SPEC.md` | §6 S2 "Elements" | The look-alike card's place in the element order |
| `SPEC.md` | §7.1 `lookalike` | `species_id`, `confused_with`, `difference_key`, `UNIQUE (species_id, confused_with)`, `ON DELETE CASCADE` |
| `SPEC.md` | §9.2 Tier 2 and the fallback chain | `difference_key` is bundled content; the build fails on a missing key before the app ever sees one |
| `SPEC.md` | §5.2 point 2 | "A wrong confident classification on a protected species is the worst failure this app could have" — the card exists because of this |
| `.claude/skills/lonja-icons-and-plates/references/engraved-plates.md` | "Look-alike pairs", "When a plate is REQUIRED" | The four pairs and their distinguishing characters; both members get a plate |
| `.claude/skills/lonja-lists-and-tables/references/row-and-table-anatomy.md` | "The divider ladder" | `structural` between page sections; `groupOpen` above a group |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | Invariant 2 and the banned lexicon | What the difference sentence may not become |
| `FLUTTER_GUIDE.md` | §8.1 | A private widget class in the screen's file, not a helper method |
| `epics/DECISIONS.md` | D-3, D-7 | Six locales; the word comes from `content_string`, never from the engine |

## What this delivers

- `app/lib/domain/models/look_alike.dart` — an immutable value: `confusedWithSpeciesId`,
  `confusedWithName`, `confusedWithScientificName`, `confusedWithPlateAsset`,
  `confusedWithSilhouetteAsset`, `difference` (the resolved sentence), `confusedWithIsProtected`.
- `app/lib/data/repositories/look_alike_repository.dart` (+ `_drift.dart`) —
  `Future<Result<List<LookAlike>>> forSpecies(int speciesId, {required String locale})`.
- `app/lib/data/services/dao/look_alike_dao.dart` — one statement joining `lookalike` to `species`
  and `species_name`.
- `app/lib/ui/species/widgets/look_alike_card.dart` — the card: a `LonjaSectionLabel`, the
  confused-with species' art and name, the difference sentence, and a tap that opens that species'
  own S2.
- ARB keys in all six files: `lookAlikeSectionLabel`, `lookAlikeConfusedWith`.
- Tests: `app/test/ui/species/look_alike_card_test.dart`,
  `app/test/data/repositories/look_alike_repository_test.dart`,
  `app/test/data/content/look_alike_content_test.dart`.

## Why it is built this way

**The card exists because the key is auditable and a classifier is not.** §5.2 point 2 is the
argument for the whole identification design, and its second half is this card: *"A wrong confident
classification on a protected species is the worst failure this app could have."* The card is the
place where the app admits that two fish look alike and says, in one sentence, which character
separates them. It is the cheapest possible defence against the most expensive possible error.

**Both members carry a plate, and the pairs are already tabulated.**
`engraved-plates.md` names the four pairs and the character each plate must draw:
`lethrinus_nebulosus` vs `lethrinus_lentjan` (blue spangles and the red opercular margin),
`epinephelus_coioides` vs `epinephelus_malabaricus` (orange spot density and the caudal blotch
field), `scomberomorus_commerson` vs `scomberomorus_guttatus` (bar count and continuity versus
discrete spots), `venerupis_corrugata` vs `ruditapes_decussatus` (concentric versus crossed
sculpture, and siphon separation). The card renders the confused-with species with the same
`SpeciesArt` resolver T03 built, which returns a plate for a look-alike pair member — because a
smudge of outline cannot separate two emperors, which is the exact failure the card is warning
about. When `plate_asset` is null the resolver falls back to the silhouette (`epic.md` risk 5); the
sentence still states the character, so the card degrades to words rather than to nothing.

**The difference is a complete authored phrase, not a template.** `difference_key` resolves through
`content_string` in the active locale with §9.2's chain. §9.5 is explicit that content strings are
authored as complete phrases and never assembled from fragments, and an adjective is never
concatenated onto a name at runtime — which matters here because the sentence names an anatomical
character whose word order and gender agreement differ across all five gendered locales.

**It states a character; it never instructs.** Invariant 2 and the banned lexicon apply to this
sentence as much as to a verdict. `Blue spangles on the scale centres; L. lentjan has a red
opercular margin.` is a statement. `Check the gill cover before you keep it.` is advice, and advice
that is wrong is our liability. The test asserts the rendered text against the banned lexicon rather
than against the source, because the ARB and `content_string` are where an imperative would enter.

**The "every protected species carries one" half is a content assertion, not an app one.** §4.3's
acceptance condition says every protected species carries a look-alike card *if a legal look-alike
exists*. The app cannot decide whether one exists — that is a taxonomic and jurisdictional judgment
made while authoring the content. §8's builder assertion list does not currently contain it, and
`epic.md` risk 5 records that with E22 named as the owner. What this task *can* assert, and does, is
the half that is checkable from the shipped data: every `lookalike` row in the Galicia seed resolves
to a real species, and its `difference_key` resolves in all six locales. A row pointing at a retired
species, or a key that renders blank in Catalan, is a shipped defect this test catches.

**Rejected: a warning tone.** `lonja-verdict-and-status` owns the semantic tones and
`product-invariants.md` assigns them meanings: oxblood means the fish fails the rule, ochre means the
paper is old. A look-alike is neither. The card is `ink` on `paper` with the standard section rules,
and the *confused-with* species' own protected pill carries the only colour on it — which is the
signal that actually matters, because being confused with a protected species is the dangerous
direction.

**Rejected: rendering the pair as a two-column comparison table.**
`row-and-table-anatomy.md`'s `pair` class is for label/value pairs of known length. A look-alike is
one species and one sentence, and a two-column layout invites a second sentence for symmetry that
the content does not have. One block, one sentence, one tap through.

## Tests first

Write every row before touching `look_alike_card.dart`. Run them. **They must fail.**

| # | Test name | Case | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `LookAlikeRepository.forSpecies returns the confused-with species and its difference` | `venerupis_corrugata` | one row, `ruditapes_decussatus`, sentence non-empty | The baseline, using the seeded Galician pair from `engraved-plates.md` |
| 2 | `LookAlikeRepository.forSpecies returns an empty list for a species with no pair` | an unpaired species | `[]` | Most species have no look-alike, so the card's absence is the common case and must not throw |
| 3 | `LookAlikeRepository.forSpecies returns more than one pair when more than one is recorded` | 2 rows | 2 results | `UNIQUE (species_id, confused_with)` allows many rows per species; a `getSingle` here would crash on real content |
| 4 | `LookAlikeRepository.forSpecies resolves the difference in the active locale` | locale `gl` | Galician sentence | §9.2 Tier 2; the character is described in the reader's language or it is not read |
| 5 | `LookAlikeRepository.forSpecies falls back to en when the active locale lacks the key` | locale `ca` | the `en` sentence | The chain's second-to-last link — never a raw key on a legal surface |
| 6 | `LookAlikeRepository.forSpecies carries the confused-with species protected flag` | protected partner | flag true | The dangerous direction: being confused with a protected species is what the card is warning about |
| 7 | `LookAlikeCard states the confused-with species name` | seeded pair | name rendered | §4.3's "commonly confused with X" |
| 8 | `LookAlikeCard states the difference` | seeded pair | sentence rendered | §4.3's "with the difference stated" — the half that makes the card useful rather than alarming |
| 9 | `LookAlikeCard renders a plate for the confused-with species` | plate present | `LonjaPlate` | `engraved-plates.md`: both pair members get the drawing, because a silhouette cannot separate two emperors |
| 10 | `LookAlikeCard falls back to a silhouette when the confused-with species has no plate` | `plateAsset` null | `LonjaSilhouette`, sentence still rendered | §8 drops uncleared plates; the card degrades to words, not to nothing |
| 11 | `LookAlikeCard marks a protected confused-with species with a glyph and a word` | protected partner | glyph and word present | Invariant 4, on the one piece of colour this card carries |
| 12 | `LookAlikeCard renders no imperative` | seeded pair | no word from the banned lexicon | Invariant 2, asserted on the rendered text because the ARB and `content_string` are where it would enter |
| 13 | `LookAlikeCard opens the confused-with species detail when tapped` | tap | route pushed with the confused-with id | The card is a route onward, and the partner's own card points back |
| 14 | `LookAlikeCard passes the confused-with id to its callback, not the model` | tap after a rebuild | callback receives the id | `rebuild-mechanics.md`'s stale-closure hole |
| 15 | `SpeciesDetailScreen omits the look-alike section when no pair is recorded` | unpaired species | section label absent | An empty section with a heading reads as a failed load |
| 16 | `SpeciesDetailScreen places the look-alike card after the species header` | paired species | card `dy` > header `dy` | §6 S2's element order; the card qualifies an identification the header has already made |
| 17 | `ar - LookAlikeCard renders the difference in the serif legal step at zero letter spacing` | locale `ar` | style is `legal`, `letterSpacing == 0` | The sentence quotes a diagnostic character, so it is legal prose; tracking would sever the joins |
| 18 | `Every lookalike row in the Galicia seed resolves to an existing species` | the committed fixture | no dangling `confused_with` | A row pointing at a retired species renders a blank card on a device with no way to refetch |
| 19 | `Every lookalike difference_key in the Galicia seed resolves in all six locales` | the committed fixture | six values per key | §9.2's build contract, asserted against the shipped artefact rather than trusted |

```dart
// app/test/ui/species/look_alike_card_test.dart
import 'package:catchlaw/ui/species/widgets/look_alike_card.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/harness.dart';
import '../../../testing/models/k_species.dart';

void main() {
  testWidgets('LookAlikeCard renders a plate for the confused-with species', (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(LookAlikeCard(lookAlike: kLookAlikeAmeixa, onOpen: (_) {}));

    // engraved-plates.md: both members of a pair carry a plate. A silhouette
    // cannot separate concentric from crossed shell sculpture.
    expect(find.byType(LonjaPlate), findsOneWidget);
    expect(find.byType(LonjaSilhouette), findsNothing);
  });

  testWidgets('LookAlikeCard renders no imperative', (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(LookAlikeCard(lookAlike: kLookAlikeAmeixa, onOpen: (_) {}));

    // Invariant 2, asserted on rendered text: the ARB and content_string are
    // where an imperative would enter, not the Dart source.
    const banned = ['keep', 'return', 'release', 'discard', 'throw it back', 'retain'];
    final rendered = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => (t.data ?? '').toLowerCase())
        .join(' ');
    for (final word in banned) {
      expect(rendered, isNot(contains(word)));
    }
  });

  testWidgets('LookAlikeCard falls back to a silhouette when the confused-with species has no plate',
      (tester) async {
    useDevice(Device.small360);
    await tester.pumpApp(
      LookAlikeCard(lookAlike: kLookAlikeNoPlate, onOpen: (_) {}),
    );

    // SPEC §8 drops any plate whose artist cannot be identified. The card
    // degrades to words, never to nothing.
    expect(find.byType(LonjaSilhouette), findsOneWidget);
    expect(find.text(kLookAlikeNoPlate.difference), findsOneWidget);
  });

  // … one test per row in the table above, one behaviour each
}
```

```dart
// app/test/data/content/look_alike_content_test.dart
import 'package:flutter_test/flutter_test.dart';

import '../../support/reference_fixture.dart';

void main() {
  test('Every lookalike row in the Galicia seed resolves to an existing species', () async {
    final db = await openCommittedGaliciaFixture(); // catchlaw-db-ok: read-only fixture
    addTearDown(db.close);

    final dangling = await db.customSelect(
      'SELECT l.id FROM lookalike l '
      'LEFT JOIN species s ON s.id = l.confused_with '
      'WHERE s.id IS NULL',
    ).get();

    expect(dangling, isEmpty);
  });

  test('Every lookalike difference_key in the Galicia seed resolves in all six locales', () async {
    final db = await openCommittedGaliciaFixture(); // catchlaw-db-ok: read-only fixture
    addTearDown(db.close);

    const locales = ['ar', 'en', 'es', 'gl', 'ca', 'pt_BR']; // DECISIONS D-3
    final missing = await db.customSelect(
      'SELECT l.difference_key, x.locale FROM lookalike l '
      "CROSS JOIN (SELECT ? AS locale UNION SELECT ? UNION SELECT ? "
      'UNION SELECT ? UNION SELECT ? UNION SELECT ?) x '
      'LEFT JOIN content_string c '
      '  ON c.key = l.difference_key AND c.locale = x.locale '
      'WHERE c.value IS NULL',
      variables: locales.map(Variable.withString).toList(),
    ).get();

    expect(missing, isEmpty);
  });
}
```

**Run:** `cd app && flutter test test/ui/species/look_alike_card_test.dart test/data/` → 19
failures. If tests 18 or 19 pass immediately, that is the one legitimate early pass in this epic —
they assert a property of E04's shipped seed rather than of code this task writes. Confirm they
*would* fail by pointing them at a deliberately broken fixture before accepting them.

## Implementation outline

1. `LookAlike` first, `const`, with value equality.
2. `LookAlikeDao.forSpecies(int speciesId)` — one statement joining `lookalike` to `species` and to
   `species_name`. `lookalike` has no index beyond its `UNIQUE (species_id, confused_with)`, which
   leads with `species_id`, so the filter is served by it; assert that in the query-plan test rather
   than adding an index the schema does not need.
3. The repository resolves `difference_key` through E06's `content_string` resolver, and resolves
   the confused-with species' display name through the same §9.2 chain T05 uses.
4. `LookAlikeCard` as one `const`-constructible widget class: `LonjaSectionLabel`, then a row of
   `SpeciesArt` plus the name and the protected pill, then the difference in `t.legal` inside a
   `ConstrainedBox` at the scaled reading measure. The whole card is one `InkWell` at
   `LonjaTargets.control` / `gloveControl`.
5. Mount it in `SpeciesDetailScreen` after the header, conditionally on a non-empty list. No
   heading when there is nothing under it.
6. Add two ARB keys to all six files.
7. Re-run the suite. All 19 green, T01–T05 still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 19 tests pass, and each failed first — including the two fixture tests, verified against a
      deliberately broken fixture.
- [ ] The card renders the confused-with species' name **and** the difference sentence; neither
      alone is the feature.
- [ ] The confused-with species resolves through `SpeciesArt`, which returns a plate for a pair
      member and falls back to the silhouette when `plate_asset` is null.
- [ ] The difference sentence is `content_string` content resolved through §9.2's chain — not an
      ARB string, and not assembled from fragments.
- [ ] No imperative reaches the rendered card, asserted against the banned lexicon on rendered text.
- [ ] The card carries no semantic tone of its own; the only colour on it is the confused-with
      species' protected pill.
- [ ] The section is absent, heading included, when no pair is recorded.
- [ ] Two ARB keys exist in all six locales (D-3).
- [ ] `epic.md` risk 5's content assertion is *not* silently implemented here — the app asserts what
      is checkable from the shipped data, and the rest stays E22's.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
.claude/skills/lonja-typography/scripts/check_lonja_type.sh                 app/lib
.claude/skills/lonja-icons-and-plates/scripts/check_lonja_icons.sh          app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/catchlaw-reference-database/scripts/check_reference_db.sh    app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(species): state the confusable species and the character that separates them

SPEC §5.2 point 2 is the argument for the whole identification design: a wrong
confident classification on a protected species is the worst failure this app
could have. This card is the cheapest defence against it — it names the species
that gets confused and states, in one authored phrase, the character that
separates them.

Both members of a pair get the plate, per engraved-plates.md, because a
silhouette cannot separate concentric from crossed shell sculpture. When a plate
was dropped for want of an identified illustrator (§8), the card degrades to
words rather than to nothing.

The "every protected species carries one" half of §4.3 is a content assertion
and stays with E22; what is checkable from the shipped seed — no dangling
confused_with, and difference_key resolving in all six locales — is asserted
here against the committed fixture.

Task: E08/T06
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
