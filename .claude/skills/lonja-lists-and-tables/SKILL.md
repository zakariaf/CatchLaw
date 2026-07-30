---
name: lonja-lists-and-tables
description: >-
  Governs every CatchLaw row, ledger table and non-happy state — species row anatomy of engraved
  silhouette, local name, italic binomial and a compact rule line, hairline dotted rule dividers at
  C2C5BB instead of card gaps, elevation or zebra stripes, tabular-figure numerics end-aligned so they
  mirror in Arabic, the whole row as one 64dp InkWell target rising to 76dp in glove mode, ListTile and
  DataTable banned in favour of LonjaSpeciesRow, LonjaLogRow and LonjaLedgerTable, Dismissible guarded
  by confirmDismiss and an undo, and the four mandatory states every list authors — empty, loading
  skeleton, error and the ochre STALE bar when the bundled rule pack has expired. Use when building a
  species or trip list, writing a bag-limit or penalties ledger, styling a divider, wiring
  swipe-to-dismiss, authoring an empty or stale state, choosing between Column and a builder list, or
  reviewing any _row.dart or _list_screen.dart in a diff.
---

# Lonja Lists and Tables

A CatchLaw list is a **ruled column of a printed register**, not a stack of cards: rows sit shoulder to shoulder, a hairline is the only thing between them, and the page — never the row — carries the margin. This skill owns row anatomy, the ledger table, the divider ladder, swipe actions, and the four non-happy states every list must author. It does not own how the list is *constructed*.

Read the reference for the task at hand:
- `references/row-and-table-anatomy.md` — species/log/settings row slots, ledger column classes, divider ladder, numeric alignment and RTL mirroring, glove and sunlight density.
- `references/the-four-states.md` — empty, loading skeleton, error, stale; state precedence, ochre bar geometry, copy rules, golden coverage matrix.

Run `scripts/check_lonja_lists.sh` before a PR.

Lazy `.builder` construction, `Key` policy and sized image decode live in `widget-composition` and `flutter-performance`; keyset pagination lives in `persistence-drift`. This skill governs what a row and a table LOOK like, and what a list does when it has nothing to show.

## Non-negotiable rules

1. **The whole row is ONE tap target.** Wrap the entire row in a single `InkWell` sized to the full row rect at `rowMinHeight` (64dp paper, 76dp glove); a trailing chevron is inert decoration and NEVER carries its own `onTap`. **WHY:** Khalid taps with a wet neoprene finger at 05:40 — a 15dp chevron hit box means the row silently does nothing, and he taps twice more and gives up.

2. **Rows are separated by a hairline rule, NEVER by a card gap.** Sibling rows share a 1px dotted `rule` (#C2C5BB) bottom `BorderSide`; the group opens with a 1px solid `ink` (#16201C) top rule. No `Card`, no `elevation`, no `BorderRadius`, no shadow, no vertical gap. **WHY:** a floating card is a screen, a ruled column is a register — the app's authority comes from looking like the booklet it quotes, and rounded shadows read as a consumer app whose numbers are opinions.

3. **`ListTile` and `DataTable` are banned.** Build `LonjaSpeciesRow`, `LonjaLogRow` and `LonjaLedgerTable` from `Row`, `Table` and `DecoratedBox`. `ListTile` hardcodes Material paddings, a splash colour and a three-line cap; `DataTable` hardcodes a 56dp header, sort chrome and LTR column maths. **WHY:** both override the Lonja type roles you set and neither mirrors correctly in Arabic — you will spend longer defeating them than authoring the row.

4. **EVERY numeric column is tabular and end-aligned.** Mono role with `fontFeatures: [FontFeature.tabularFigures()]`, `textAlign: TextAlign.end`, `EdgeInsetsDirectional` padding. **WHY:** proportional digits make `41 kg` and `402 kg` wobble down the column so they cannot be compared at a glance in swell, and `TextAlign.right` pins the number to the START edge in Arabic — the number lands under the label.

5. **Ledger tables are ruled, NEVER zebra-striped.** Header cells: sans 9.5sp, 0.14em tracking, uppercase, `ink-faint`, over a 1.5px solid `ink` rule. Body rows: 1px dotted `rule`, no fill. **WHY:** an alternating `paper-sunk` background is decoration that survives neither sunlight mode — where every grey is deleted — nor a screenshot handed to an inspector.

6. **EVERY list that can be empty ships an AUTHORED empty state.** `SizedBox.shrink()`, a bare `Center(child: Text('No data'))`, or nothing at all is a defect and fails `scripts/check_lonja_lists.sh`. The state names what is absent and the ONE action that changes it. **WHY:** a blank page at sea is indistinguishable from a crash, and Khalid's next move is to reinstall the app and lose a trip log that exists on no other device.

7. **The four states are mandatory and only three are exclusive.** `empty`, `loading` and `error` are mutually exclusive bodies; `stale` is an ORTHOGONAL ochre bar that rides above real data and blocks nothing. **WHY:** a stale rule still beats no rule at sea — replacing the list because the rule pack expired removes the only information the fisher has.

8. **A row STATES, it never instructs.** End slots read `2 of 5 remaining`, `Below the minimum`, `PROTECTED` — never `Keep`, `Return`, `Throw it back`, and never an exclamation mark. The wording contract itself is owned by `catchlaw-verdict-contract`; this rule binds the row's end slot to it. **WHY:** an imperative in a list is legal advice, and the AED 3,000 attaches to the fisher, not to the app.

9. **Status in a row is glyph AND word AND colour.** A `LonjaPill` carries an engraved glyph, an uppercase mono word (`PROTECTED`, `STALE DATA`, `OPEN`) and the semantic colour together. **WHY:** sunlight mode deletes every colour but the verdict and the never-colour-alone floor is owned by `accessibility-as-code` — a bare oxblood dot communicates nothing to either.

10. **Destructive row actions need `confirmDismiss` AND an undo.** `Dismissible` with `direction: DismissDirection.endToStart`, a `confirmDismiss` that returns a typed answer, a soft delete, and a `LonjaUndoBar`. **WHY:** a swipe across a wet screen is indistinguishable from a scroll, and the trip log has no sync and no backup — an unconfirmed dismiss destroys the only copy that exists anywhere.

11. **The species row slot order is FIXED and never reordered per screen.** Silhouette (52x30 engraved) → local name (arabic 19sp / serif 16sp semibold) → italic binomial (`ink-faint` 12.5sp) → rule line (sans 11.5sp `ink-muted`) → mono end slot → optional chevron. **WHY:** Khalid scans the silhouette first and the binomial last; a screen that reshuffles the slots resets the five-second recognition he has built everywhere else in the app.

12. **Glove mode raises rows, it does not re-lay them out.** `rowMinHeight` 64dp → 76dp and inter-target separation 8dp → 12dp; slot order, type roles, rule weights and column widths are unchanged. **WHY:** re-flowing under an orthogonal density switch doubles the golden matrix and ships a layout no reviewer has ever seen.

## The species row

One `InkWell` over the whole rect, a fixed slot order, and a dotted hairline the row draws itself. Nothing here is a `ListTile`, and the chevron never owns a gesture.

```dart
class LonjaSpeciesRow extends StatelessWidget {
  const LonjaSpeciesRow({required this.species, required this.onTap, super.key});
  final SpeciesSummary species;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = LonjaTheme.of(context);
    // WRONG — ListTile(title: ..., trailing: IconButton(onPressed: onTap, ...))
    // RIGHT — the whole row is the target; the chevron is inert decoration.
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: l.density.rowMinHeight), // 64 · 76 glove
        padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
        decoration: BoxDecoration(border: BorderDirectional(bottom: l.rules.hairlineDotted)),
        child: Row(children: [
          SpeciesSilhouette(species.plate, width: 52, height: 30), // engraved line art
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(species.localName, style: l.type.rowName),      // هامور · Hamour
            Text(species.binomial, style: l.type.rowBinomial),   // Epinephelus coioides
            Text(species.ruleLine, style: l.type.rowDetail),     // min 45 cm total length
          ])),
          Text(species.endSlot, style: l.type.mono, textAlign: TextAlign.end),
        ]),
      ),
    );
  }
}
```

Full worked file: `examples/lonja_species_row.dart`.

## The ledger table

Penalties, bag limits and trip totals are a `Table` with fixed column classes: a start-aligned label column and end-aligned numeric columns. Header over a 1.5px ink rule, body rows on dotted hairlines, and not one drop of fill.

```dart
Table(
  columnWidths: const {0: FlexColumnWidth(34), 1: FlexColumnWidth(33), 2: FlexColumnWidth(33)},
  defaultVerticalAlignment: TableCellVerticalAlignment.top,
  children: [
    TableRow(
      decoration: BoxDecoration(border: Border(bottom: l.rules.ledgerHead)), // 1.5px ink
      children: [
        LedgerHeadCell(text.offence),                       // sans 9.5 · .14em · uppercase
        LedgerHeadCell(text.fine, numeric: true),
        LedgerHeadCell(text.licence, numeric: true),
      ],
    ),
    // WRONG — TableRow(decoration: BoxDecoration(color: i.isEven ? l.colour.paperSunk : null))
    // RIGHT — one dotted hairline per row and no fill at all.
    for (final p in penalties)
      TableRow(
        decoration: BoxDecoration(border: Border(bottom: l.rules.hairlineDotted)),
        children: [
          LedgerCell(p.offence),                                     // serif 14 · "First offence"
          LedgerCell(p.fine, numeric: true, tone: l.colour.oxblood), // mono · "AED 3,000"
          LedgerCell(p.licence, numeric: true),                      // "Suspension for 6 months"
        ],
      ),
  ],
)
```

Full worked file: `examples/lonja_ledger_table.dart`.

## Dividers, section rules and grouping

Four rule weights, all token `BorderSide`s, none of them whitespace. A row draws its own bottom rule; the group draws the opening rule; the page draws the structural rule between sections.

```dart
// The ladder, as slots on the LonjaRules extension (owned by `lonja-design-tokens`):
//   hairlineDotted — 1px   rule        #C2C5BB  between sibling rows
//   groupOpen      — 1px   ink         #16201C  above a row group
//   ledgerHead     — 1.5px ink         #16201C  under a ledger header
//   structural     — 1px   rule-strong #A9AC9F  between page sections

// WRONG — separation by whitespace and elevation.
Column(children: [for (final t in trips) Card(elevation: 2, child: LonjaLogRow(trip: t))]);

// WRONG — a token value copied by hand into a Material Divider; it will not follow night or sunlight.
const Divider(height: 1, color: Color(0xFFC2C5BB));

// RIGHT — the group opens with an ink rule, each row closes with its own hairline.
DecoratedBox(
  decoration: BoxDecoration(border: BorderDirectional(top: l.rules.groupOpen)),
  child: Column(children: [for (final t in trips) LonjaLogRow(trip: t)]),
);
```

Full worked file: `examples/lonja_ledger_table.dart`.

## The empty state

An empty list names the absence in the user's own terms and offers the single next move. It uses engraved plate art, never a rounded three-dimensional illustration, and it never apologises.

```dart
// WRONG — if (trips.isEmpty) return const SizedBox.shrink();
// WRONG — if (trips.isEmpty) return const Center(child: Text('No data'));
// RIGHT — an authored state: what is absent, why it is absent, and the one action.
if (trips.isEmpty) {
  return LonjaEmptyState(
    plate: LonjaPlates.emptyCreel,      // engraved line art, ink on paper
    headline: text.noTripsHeadline,     // "No trips recorded on this device"
    body: text.noTripsBody,             // "Trips are kept here only. Nothing is uploaded."
    action: LonjaButton.primary(
      label: text.startTrip,            // the ONE next move — never two competing actions
      onPressed: () => ref.read(tripLogProvider.notifier).open(),
    ),
  );
}
```

Full worked file: `examples/lonja_species_row.dart`.

## The stale bar

When the bundled rule pack is past its checked date, the list still renders in full. The stale bar sits above it in ochre — never oxblood — and blocks nothing.

```dart
// WRONG — if (pack.isExpired) return const RuleDataExpiredScreen();  // hides the only rules he has
// RIGHT — a non-blocking ochre bar over a fully usable list.
Column(children: [
  if (pack.isExpired)
    LonjaStaleBar(
      glyph: LonjaGlyphs.warn,                     // glyph AND word AND colour (rule 9)
      label: text.ruleDataExpired,                 // "Rule data expired"
      detail: text.checkedOn(pack.checkedAt),      // "checked 2026-07-14"
      tone: l.colour.ochre,                        // #8A6A16 — oxblood means the FISH fails
    ),
  Expanded(child: LonjaSpeciesList(species: species)),
]);
```

Full worked file: `examples/lonja_species_row.dart`.

## Swipe, dismiss and undo

Only user-authored rows (trip entries, saved species) are dismissible; a rule-pack row never is. Every dismiss is confirmed, soft, and undoable.

```dart
Dismissible(
  key: ValueKey(entry.id),
  direction: DismissDirection.endToStart,        // mirrors automatically under Directionality
  background: const LonjaDismissBackground(),    // oxblood ground + glyph + the WORD
  // WRONG — onDismissed: (_) => dao.delete(entry.id)   no confirm, no undo, no second copy anywhere
  confirmDismiss: (_) => showLonjaConfirm(
    context,
    headline: text.removeCheckHeadline,          // "Remove this check from the trip?"
    body: text.removeCheckBody,                  // states what is lost; no imperative
  ),
  onDismissed: (_) async {
    await ref.read(tripLogProvider.notifier).softDelete(entry.id);
    LonjaUndoBar.show(context, label: text.checkRemoved, onUndo: restore);
  },
  child: LonjaLogRow(entry: entry),
)
```

Full worked file: `examples/lonja_species_row.dart`.

## Anti-patterns

- **`ListTile(title: ..., subtitle: ...)`** — hardcodes Material's paddings, splash and three-line cap, and silently overrides every Lonja type role the row sets.
- **`DataTable` / `DataColumn` / `DataRow`** — a 56dp Material header, sort chrome nobody asked for, and column maths that pins numerics to the physical right in Arabic.
- **`Card(elevation: 2)` around each row** — turns a register into a stack of floating screens; nothing in the printed booklet has a shadow.
- **Zebra striping via `i.isEven ? paperSunk : paper`** — decorative fill that vanishes in sunlight mode and prints as noise on a screenshot.
- **`Divider(color: Color(0xFFC2C5BB))`** — a token value copied by hand; it will not follow night or sunlight mode and fails `scripts/check_lonja_lists.sh`.
- **`trailing: IconButton(icon: Icon(Icons.chevron_right), onPressed: onTap)`** — shrinks a 64dp target to 15dp and leaves 92% of the row inert.
- **`Icons.chevron_right`** — a physical-direction glyph pointing the wrong way in Arabic; use a mirrored plate glyph or `Icons.adaptive.arrow_forward` (`i18n-rtl-l10n`).
- **`TextAlign.right` on a numeric cell** — pins `41 kg` to the physical right, which is the START of the row in Arabic, landing the figure under its own label.
- **`if (items.isEmpty) return const SizedBox.shrink()`** — the exact defect this skill exists to kill: a blank screen that reads as a crash to a fisher with no signal.
- **`CircularProgressIndicator` as a list's loading body** — a spinner is network language in an app that has no network; use a ruled skeleton of the real row shape.
- **An oxblood banner for expired rule data** — oxblood means the fish fails the rule, ochre means the paper is old; conflating them makes every stale pack look like a violation.
- **`SingleChildScrollView(child: Column(children: [for (final s in species) LonjaSpeciesRow(...)]))`** — builds all 3,180 rule-pack entries at once (`flutter-performance` and `widget-composition` own the fix).

## Definition of done

- [ ] `scripts/check_lonja_lists.sh` is clean over `lib/`.
- [ ] Every row's tap target is the full row rect at `rowMinHeight`; a widget test taps the row's start edge and the callback fires (rule 1).
- [ ] No `Card`, `elevation`, `BorderRadius` or vertical gap separates two sibling rows — separation is a token `BorderSide` (rule 2).
- [ ] `grep -rn 'ListTile\|DataTable\|DataColumn\|DataRow' lib/` returns nothing (rule 3).
- [ ] Every numeric cell carries `FontFeature.tabularFigures()` and `TextAlign.end`, and its golden passes in the `ar` RTL lane (rules 4, 11).
- [ ] No ledger `TableRow` sets a background `color`; every separation is a `BorderSide` (rule 5).
- [ ] Each list screen has an authored empty state naming the absence and exactly one action, with a golden (rule 6).
- [ ] Each list screen renders all four states, and the stale bar coexists with data instead of replacing it (rule 7).
- [ ] No row end slot contains an imperative verb — `grep -riE '\b(keep|return|discard|throw)\b'` over `*_row.dart` is clean (rule 8).
- [ ] Every `Dismissible` over user data has both `confirmDismiss` and an undo path (rule 10).

## Related skills

- See `lonja-design-tokens` for the `rule`, `rule-strong`, `paper-sunk` and `ochre` colour slots, the `LonjaRules` `BorderSide` set, and the glove-mode density switch every row reads.
- See `lonja-typography` for the serif, sans, mono and arabic role definitions and the `FontFeature.tabularFigures()` mono role every ledger column depends on.
- See `lonja-verdict-and-status` for the `LonjaPill` glyph-plus-word-plus-colour status token a row's end slot renders and the ochre stale tone.
- See `lonja-icons-and-plates` for the engraved species silhouette, the plate sizing scale and the empty-state art these rows embed.
- See `widget-composition` for extracting `LonjaSpeciesRow` as a `const` widget class rather than a `Widget _buildRow()`, plus the `.builder` requirement and `Key` policy this skill assumes.
- See `flutter-performance` for lazy slivers, `.select` rebuild scoping and sized image decode on the silhouette plates.
- See `persistence-drift` for keyset pagination and the `.watch` streams that feed these lists.
- See `i18n-rtl-l10n` for `EdgeInsetsDirectional`, `TextAlign.end` and the Arabic-Indic numeral formatting a ledger column must respect.
- See `catchlaw-verdict-contract` for the statement-of-fact wording contract a row's end slot and every empty-state headline must satisfy.

## References

- Flutter API — `Table`: https://api.flutter.dev/flutter/widgets/Table-class.html
- Flutter API — `Dismissible`: https://api.flutter.dev/flutter/widgets/Dismissible-class.html
- Flutter API — `FontFeature.tabularFigures`: https://api.flutter.dev/flutter/dart-ui/FontFeature/FontFeature.tabularFigures.html
- Flutter API — `BorderDirectional`: https://api.flutter.dev/flutter/painting/BorderDirectional-class.html
- Flutter API — `SliverChildBuilderDelegate`: https://api.flutter.dev/flutter/widgets/SliverChildBuilderDelegate-class.html
- Flutter docs — Slivers and long lists: https://docs.flutter.dev/ui/layout/scrolling/slivers
- Material 3 — Lists guidelines: https://m3.material.io/components/lists/guidelines
- W3C WAI — Tables tutorial: https://www.w3.org/WAI/tutorials/tables/
