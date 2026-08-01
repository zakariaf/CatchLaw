# E11/T05 — No polygons means no sub-zone level

| | |
|---|---|
| **Epic** | E11 — Zones and point-in-polygon |
| **Branch** | `epic/11-zones` (shared) |
| **Commit** | `feat(zones): hide the sub-zone level where no coordinate boundaries are published` |
| **Depends on** | T04 (the three levels and the view model) |
| **Size** | S |
| **Spec** | `SPEC.md` §4.4 ("Jurisdictions with no polygons"), §6 S9 (the note), §8 (the Gulf zone-polygon row), §7.1 (`jurisdiction.has_zone_polygons`, `zone.geometry_source`), §7.3 step 2 (what "jurisdiction-wide" means to resolution) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Invariant 2 — this screen gains a sentence, and a sentence about missing data is exactly where an instruction sneaks in. Also the routing rule: the *wording* contract is `catchlaw-verdict-contract`'s and is cited, not restated |
| `lonja-lists-and-tables` | Rule 8 (a row states, it never instructs) and `references/the-four-states.md`'s rule that an absence carries no semantic colour — an unpublished boundary is not a verdict |
| `lonja-navigation-chrome` | Rule 4: the new line resolves through `AppLocalizations` in all six locales, like every other chrome string |
| `catchlaw-rule-engine` | `references/resolution-algorithm.md`'s zone-match stage: with a two-element `zonePath`, only `NULL` and jurisdiction-scoped rows match — which is precisely "rules apply jurisdiction-wide" |
| `state-management-riverpod` | Rule 4, derive-don't-store: whether the level renders is derived from the jurisdiction row on read, never mirrored into the picker state |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §4.4, "Jurisdictions with no polygons" | "Where an authority publishes no coordinate boundaries, rules apply jurisdiction-wide. Zone picker hides the sub-zone level rather than inventing boundaries (§8)" |
| `SPEC.md` | §6 S9, the closing note | "jurisdictions with no published polygons show no sub-zone level at all (§4.4)" |
| `SPEC.md` | §8, the "Zone polygons — Gulf" row | The whole sentence: Emirate maritime boundaries are not published as coordinate polygons in MD 580/2015 or its successors; `has_zone_polygons = 0`; **we do not invent boundaries** |
| `SPEC.md` | §7.1, `jurisdiction.has_zone_polygons` | The column, its default of 0, and its inline comment `0 => S9 hides the sub-zone level` |
| `SPEC.md` | §7.1, `zone.geometry_source` | `NULL` when no polygon — the per-zone counterpart of the per-jurisdiction flag |
| `SPEC.md` | §7.3 step 2 | "Keep rows whose `zone_id` is NULL, equals the zone, or is an ancestor of the zone" — the mechanism that makes a two-element `zonePath` mean jurisdiction-wide |
| `.claude/skills/catchlaw-rule-engine/references/resolution-algorithm.md` | "Edge cases", first row | "`zonePath` has one element (jurisdiction only) — only `NULL` and jurisdiction-scoped rows match; still a valid answer" |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | invariant 2, the banned lexicon | The forbidden verbs, and the note that there is no exemption for a "friendly" hint or a tooltip |
| `.claude/skills/lonja-lists-and-tables/references/the-four-states.md` | "Empty", the Colour row | "no semantic colour — an empty list is not a verdict" |
| `.claude/skills/lonja-lists-and-tables/SKILL.md` | rule 8 | A row states, it never instructs |
| `epics/DECISIONS.md` | D-3 | The new key lands in all six ARB files |
| `epics/E11-zones/T04-s9-country-region-subzone.md` | "What this delivers" | The widgets and providers this task modifies rather than replaces |

## What this delivers

- Changes to `app/lib/ui/zones/zone_picker_screen.dart` — the sub-zone `ZoneLevel` is omitted from the
  tree when the selected jurisdiction's `has_zone_polygons` is 0. Omitted, not disabled and not
  rendered empty.
- `app/lib/ui/zones/widgets/no_subzone_notice.dart` — `NoSubZoneNotice`, a one-line note in
  `ink-muted` under a `structural` rule, naming the authority.
- Changes to `app/lib/ui/zones/view_models/zone_picker_view_model.dart` — `confirmSelection` under a
  zero-polygon jurisdiction sets `active_zone_code` to that jurisdiction's `region`-kind zone code, and
  the derived `zonePath` is two elements.
- `app/lib/domain/models/zone_selection.dart` gains `List<String> zonePath` derived from
  `parent_zone_id`, capped at the region when the flag is 0.
- `app/lib/l10n/app_*.arb` × 6 — `zoneNoPublishedBoundaries`, an ICU message taking the authority name:
  *"{authority} publishes no coordinate boundaries. The rules recorded here apply across the whole
  jurisdiction."*
- `app/test/ui/zones/no_subzone_notice_test.dart` and additions to
  `app/test/ui/zones/zone_picker_screen_test.dart` and
  `app/test/ui/zones/view_models/zone_picker_view_model_test.dart`.

## Why it is built this way

**The sentence is the task.** §8 records, in the table where every other row states a licence, that
Emirate maritime boundaries **are not published as coordinate polygons** in MD 580/2015 or its
successors, and it ends the row with four words: *we do not invent boundaries*. Everything else in this
task follows from refusing to draw a line nobody printed. The temptation is real and cheap — an
administrative boundary from a public dataset would render beautifully and would attribute a rule to a
zone the decision never mentions, which is the one failure this product cannot survive.

**The flag is the authority, not the ring count.** The level is hidden on
`jurisdiction.has_zone_polygons = 0`, never on "this jurisdiction has no `zone_ring` rows". Content is
authored incrementally: a jurisdiction mid-transcription can easily hold one ring for one bank while the
rest is unwritten, and a picker that counted rings would grow a sub-zone level containing exactly one
half-finished entry and imply that the other zones are simply absent. One column, authored deliberately
by the content builder, decides. Test 5 puts a stray ring in front of a zero flag and asserts the level
stays hidden.

**Omitted, not disabled and not empty.** A greyed-out level invites a tap that does nothing; an empty
level with a "nothing here" state says the sub-zones exist and were not found. Neither is true. The
level is absent and one line explains the absence, which is `the-four-states.md`'s empty contract
applied to a level rather than to a list: name the absence as a fact and say what is held instead.

**It carries no semantic colour.** Ochre means the paper is old and oxblood means the fish fails the
rule (`the-four-states.md`, "Stale"). An authority that publishes its regulations without coordinate
annexes is neither: it is how that authority writes law. The notice is `ink-muted` under a `structural`
rule and looks like a footnote, because that is what it is. Rendering it in ochre would teach a fisher
that Ras Al Khaimah's rules are stale when they are current.

**It states and does not instruct.** Invariant 2's banned lexicon is about fishing verbs, but the
principle in `product-invariants.md` is broader and its note is explicit that there is no exemption for a
friendly hint. So the line is *"{authority} publishes no coordinate boundaries. The rules recorded here
apply across the whole jurisdiction."* — not "contact the authority", not "choose the nearest zone", and
not an apology. There is also deliberately no link: `url_launcher` and `AndroidIntent` are grep-banned by
§14, `authority_url` is selectable text only (§5.3), and a screen that offered to open one would fail the
build.

**Jurisdiction-wide is a fact about the `zonePath`, not a special case in the engine.** §7.3 step 2 keeps
rules whose `zone_id` is NULL, equals the zone, or is an ancestor. With a two-element path — country and
the region-kind zone — the surviving set is exactly the NULL-scoped rules plus the region's, which is
what "rules apply jurisdiction-wide" means.
`catchlaw-rule-engine/references/resolution-algorithm.md` already lists the short path as a valid answer
in its edge-case table, so nothing in the engine changes and no branch is added to `resolve()`. A special
case there would be a second definition of jurisdiction-wide that could drift from this one.

**`active_zone_code` still gets a real code.** §7.2 types it `TEXT` and nullable, but `trip.zone_code`
and `catch.zone_code` are both `TEXT NOT NULL`, so a null active zone would make a catch unrecordable in
exactly the jurisdictions with the thinnest content. The content builder authors one `region`-kind zone
per jurisdiction — it must, because `rule.zone_id` referencing a region is how §7.3's specificity 0 rung
is reachable — and that is the code stored. Test 6 asserts it, and if a fixture jurisdiction lacks one
the test fails here rather than three epics later at a `NOT NULL` violation.

**Rejected: substituting an administrative boundary from a public dataset.** §8's Brazil row already
records that IBGE and ANA cartographic products are **not** covered by Lei 9.610 art. 8 and need their
own clearance, with Natural Earth named as the safe default *for admin boundaries*. None of that makes an
administrative boundary a *fishing* zone: a rule that MD 580/2015 states for the Emirate does not become
a rule for a polygon somebody else drew around the Emirate. The licence question is the smaller problem.

**Rejected: hiding "Use my location" for a zero-polygon jurisdiction.** A control that disappears is a
mystery, and the fisher may be near a jurisdiction that *does* publish boundaries. The button stays; a
fix that matches no ring produces T06's factual no-match line. The two tasks meet there deliberately.

## Tests first

Write every row before touching the screen. Run them. **They must fail.**

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ZonePickerScreen omits the sub-zone level when has_zone_polygons is 0` | `AE-RK`, flag 0 | no third `ZoneLevel` in the tree | §4.4 and §6 S9's note, as a structural fact |
| 2 | `ZonePickerScreen renders the sub-zone level when has_zone_polygons is 1` | `ES-GA`, flag 1 | three `ZoneLevel`s | The control case; a screen that always hides the level would pass test 1 |
| 3 | `ZonePickerScreen renders NoSubZoneNotice when has_zone_polygons is 0` | `AE-RK` | the notice found | An absent level with no explanation reads as a bug |
| 4 | `ZonePickerScreen omits NoSubZoneNotice when has_zone_polygons is 1` | `ES-GA` | not found | A footnote on every jurisdiction is a footnote nobody reads |
| 5 | `ZonePickerScreen omits the sub-zone level when has_zone_polygons is 0 and zone_ring rows exist` | flag 0, one authored ring | still no third level | The flag is the authority; a half-transcribed jurisdiction must not grow a one-entry level |
| 6 | `ZonePickerNotifier.confirmSelection stores the region zone code under a zero-polygon jurisdiction` | `AE-RK` confirmed | `setActiveZone('AE-RK', 'ae-rk')` | `trip.zone_code` and `catch.zone_code` are `NOT NULL`; a null here is unrecordable catches three epics later |
| 7 | `ZoneSelection.zonePath holds two elements under a zero-polygon jurisdiction` | `AE-RK` | `['AE', 'ae-rk']` | §7.3 step 2 turns a short path into jurisdiction-wide with no engine branch |
| 8 | `ZoneSelection.zonePath holds three elements under a jurisdiction with polygons` | `ES-GA` / Rías Baixas | `['ES', 'es-ga', 'rias-baixas']` | The contrast that proves the path is derived and not hardcoded |
| 9 | `NoSubZoneNotice names the authority from the jurisdiction row` | `authority_key` resolving to a Ministry name | that name appears | An unnamed authority makes the statement unverifiable |
| 10 | `NoSubZoneNotice carries no semantic verdict colour` | rendered in the paper theme | no ochre and no oxblood in the subtree | Ochre means the paper is old; this is how that authority writes law |
| 11 | `ar - NoSubZoneNotice renders from AppLocalizations` | locale `ar` | the Arabic string, no Latin literal | D-3, and `lonja-navigation-chrome` rule 4 |
| 12 | `zoneNoPublishedBoundaries contains no imperative in any of the six locales` | the six ARB values | no banned-lexicon verb, no exclamation mark | Invariant 2, asserted where the string actually lives |
| 13 | `ZonePickerScreen renders Use my location under a zero-polygon jurisdiction` | `AE-RK` | the action is present and enabled | A control that vanishes is a mystery; the no-match answer is T06's |

```dart
// app/test/ui/zones/zone_picker_screen_test.dart — additions
void main() {
  testWidgets('ZonePickerScreen omits the sub-zone level when has_zone_polygons is 0 '
      'and zone_ring rows exist', (tester) async {
    await tester.pumpZonePicker(reference: kReferenceRasAlKhaimahWithOneStrayRing);
    await tester.tap(find.byKey(const ValueKey('zone-row-AE')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('zone-row-AE-RK')));
    await tester.pumpAndSettle();

    expect(find.byType(ZoneLevel), findsNWidgets(2),
        reason: 'SPEC 8: has_zone_polygons is the authority, not the ring count — a '
            'half-transcribed jurisdiction must not grow a one-entry sub-zone level');
    expect(find.byType(NoSubZoneNotice), findsOneWidget);
  });
}
```

```dart
// app/test/ui/zones/no_subzone_notice_test.dart
void main() {
  test('zoneNoPublishedBoundaries contains no imperative in any of the six locales', () async {
    const banned = <String>[
      'keep', 'return', 'release', 'discard', 'throw', 'contact', 'choose', 'select', 'tap', 'go to',
    ];

    for (final locale in kShippedLocales) {
      final l10n = await AppLocalizations.delegate.load(locale);
      final message = l10n.zoneNoPublishedBoundaries('Ministry of Climate Change and Environment');

      expect(message, isNot(contains('!')), reason: 'locale $locale');
      for (final verb in banned) {
        expect(message.toLowerCase(), isNot(contains(verb)),
            reason: 'invariant 2: "$verb" is an instruction, in locale $locale');
      }
    }
  });
}
```

**Run:** `cd app && flutter test test/ui/zones/` → 13 new failures, T04's 22 still green. If any new one
passes now, the test is wrong.

## Implementation outline

1. Add `bool get hasZonePolygons` to the jurisdiction value object in `app/lib/data/model/` if T04 did
   not already map the column, and thread it onto `ZonePickerState` as a derived getter — read from the
   jurisdiction row, never stored twice (`state-management-riverpod` rule 4).
2. In `zone_picker_screen.dart`, build the sub-zone level inside an `if (state.hasZonePolygons)` in the
   slivers list, and the `NoSubZoneNotice` in the `else`. Omission, not an `Opacity`, not an
   `IgnorePointer`.
3. `no_subzone_notice.dart`: a `const StatelessWidget` — a `structural` `BorderSide` above,
   `EdgeInsetsDirectional` padding, one `Text` in `l.type.rowDetail` and `l.colour.inkMuted`. No glyph,
   no ground, no border colour from the semantic set.
4. `confirmSelection`: when the flag is 0, resolve the jurisdiction's `region`-kind zone through
   `ReferenceRepository` and store its code; when it is 1, store the selected sub-zone's code.
5. `zone_selection.dart`: `zonePath` walks `parent_zone_id` upward from the selected zone and prepends
   `country_iso2`, stopping at the region when the flag is 0.
6. Add `zoneNoPublishedBoundaries` to all six ARB files with the `{authority}` placeholder, and run
   E06's completeness check.
7. Re-run the whole app suite.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 13 tests pass, and each failed first.
- [ ] The sub-zone level is decided by `jurisdiction.has_zone_polygons` and by nothing else — no code
      path counts `zone_ring` rows to make this decision.
- [ ] The level is omitted from the widget tree, not disabled, dimmed or rendered as an empty state.
- [ ] `zoneNoPublishedBoundaries` exists in all six locales (D-3), names the authority, and contains no
      banned-lexicon verb and no exclamation mark in any of them.
- [ ] The notice renders no ochre, no oxblood and no verdant.
- [ ] No URL, no link affordance and no `authority_url` tap target is added anywhere by this task.
- [ ] `active_zone_code` is a real zone code under a zero-polygon jurisdiction, never null.
- [ ] `packages/rule_engine/` is unchanged: jurisdiction-wide is a two-element `zonePath`, not a branch
      in `resolve()`.
- [ ] `check_verdict_contract.sh app/lib` and `check_app_invariants.sh app/lib` are clean.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh  app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh   app/lib
.claude/skills/lonja-lists-and-tables/scripts/check_lonja_lists.sh          app/lib
.claude/skills/lonja-navigation-chrome/scripts/check_lonja_nav.sh           app/lib
.claude/skills/lonja-design-tokens/scripts/check_lonja_tokens.sh            app/lib
tools/gates/no_directional_geometry.sh                                      app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(zones): hide the sub-zone level where no coordinate boundaries are published

SPEC 8 records that Emirate maritime boundaries are not published as
coordinate polygons in MD 580/2015 or its successors, sets
has_zone_polygons = 0 for such a jurisdiction, and ends the row with four
words: we do not invent boundaries. This commit is those four words.

The level is omitted rather than disabled or rendered empty — a greyed level
invites a tap that does nothing and an empty one claims the sub-zones exist
and were not found — and one ink-muted footnote names the authority and
states that the rules recorded here apply across the whole jurisdiction. It
carries no semantic colour: ochre means the paper is old, and an authority
that publishes without coordinate annexes is not stale, it is how that
authority writes law. There is no link, because authority_url is selectable
text only and url_launcher is grep-banned by SPEC 14.

The decision reads has_zone_polygons and never counts zone_ring rows: a
half-transcribed jurisdiction holding one bank would otherwise grow a
one-entry level and imply the rest are simply absent.

Jurisdiction-wide needs no engine branch. SPEC 7.3 step 2 keeps rules whose
zone_id is NULL, equal or an ancestor, so a two-element zonePath already
means exactly that; resolve() is untouched.

Task: E11/T05
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
