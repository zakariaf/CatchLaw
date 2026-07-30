---
name: lonja-navigation-chrome
description: >-
  Governs the Lonja navigation chrome in CatchLaw — the frozen five destinations Check, Today,
  Trips, Reference and Settings; the bottom bar drawn as a ruled ledger strip with a 2dp ink
  #16201C top rule, paper-sunk #DEDBD1 ground and hairline BorderDirectional cells instead of a
  floating Material pill; a selected state encoded by a 3dp harbour #1B4D5E rail, a lifted paper
  ground, a filled glyph and a 600-weight label before colour ever counts; the gazette masthead app
  bar carrying the wordmark, the dated mast-meta line, the zone chip and the rules-checked currency
  chip; the back affordance mirrored under Directionality; and the verdict takeover that suppresses
  the bar. Use when adding a destination, building LonjaNavBar or LonjaMasthead, wiring
  selectedIndex, styling the zone or stale-rules chip, translating a nav label through
  AppLocalizations, mirroring a chevron for Arabic, or reviewing bottom nav or app bar code in a
  diff.
---

# Lonja Navigation Chrome

Chrome is everything on the page that is not the article: the masthead, the running head, the folio
strip along the foot. CatchLaw's chrome must be quiet enough that Khalid never reads it and fixed
enough that his thumb finds Check in the dark, in gloves, at 05:40. This skill owns **the values and
the Lonja treatment** of the five-item bottom bar, the masthead app bar, the back affordance and the
zone and currency chips — never the routes behind them.

Read the reference for the task at hand:
- `references/nav-anatomy-and-states.md` — the five destinations, bar metrics, selected-state signal
  stack, glove mode, night and sunlight values, masthead anatomy, verdict takeover.
- `references/chips-and-currency.md` — zone chip, rules-checked chip, staleness escalation, date
  formats, chip metrics, chevron mirroring, banned chip copy.

Run `scripts/check_lonja_nav.sh` before a PR.

Routes, redirects, deep links and `StatefulShellRoute` live in `navigation-and-routing`; the
NavigationBar-to-NavigationRail-to-Drawer breakpoints live in `adaptive-layout`. This skill governs
only what those surfaces look like, what they measure, and what they are allowed to say.

## Non-negotiable rules

1. **Five destinations. Frozen at five, in this order.** `check, today, trips, reference, settings`,
   declared once as an `enum LonjaDestination` that `scripts/check_lonja_nav.sh` counts; a sixth item
   is a redesign proposal, never an append. **WHY:** thumb memory is built in the dark and destroyed
   by re-ordering, and five is the LAST count keeping every cell 56dp wide on a 320dp screen.

2. **The bar is a ruled ledger strip, never a floating bar.** 2dp ink `#16201C` top rule, paper-sunk
   `#DEDBD1` ground, 1dp rule `#C2C5BB` hairline on each cell's inline-end, `elevation: 0`, zero
   corner radius, zero shadow, full-bleed to both screen edges, bottom-padded only by
   `MediaQuery.viewPaddingOf(context).bottom`. **WHY:** a shadowed pill reads as an app; a ruled
   strip reads as the foot of a printed page, which is the product's entire authority claim.

3. **The selected destination carries at least THREE non-colour signals.** A 3dp harbour `#1B4D5E`
   rail on the cell's top edge, the ground lifting from `#DEDBD1` to paper `#E6E4DC`, the filled
   glyph variant, and label weight 600 against 500; colour is the fourth signal, never the first, and
   `Semantics(selected: true)` is mandatory. **WHY:** the sunlight theme deletes harbour entirely, so
   a colour-only selection state simply vanishes on the deck at noon.

4. **EVERY chrome string resolves through `AppLocalizations`.** Destination labels, the back tooltip,
   the zone chip, the currency chip and the masthead kicker all come from `app_en.arb` and its five
   siblings — a bare `label: 'Check'` or `Text('Reference')` fails `scripts/check_lonja_nav.sh`.
   **WHY:** a hardcoded label ships English chrome into the Arabic build, and Khalid cannot navigate
   a document written in a language he does not read.

5. **Chrome geometry is directional-only.** `EdgeInsetsDirectional`, `BorderDirectional(start:,
   end:)` and `AlignmentDirectional` under a known `Directionality` — NEVER `EdgeInsets.only(left:)`
   or `right:` in a nav, app bar or chip widget. **WHY:** a physically pinned inset puts the back
   affordance and the cell hairlines on the wrong side in Arabic, half of CatchLaw's launch surface.

6. **The back affordance is explicit, mirrored and 44dp.** A leading `IconButton` with a translated
   tooltip on every pushed route, glyph flipped via `Transform.flip(flipX: true)` when
   `Directionality.of(context) == TextDirection.rtl`, 56dp in glove mode; the system gesture is a
   supplement, never the only exit. **WHY:** wet gloves defeat edge swipes, and an unmirrored chevron
   points back into the text it is meant to leave.

7. **The app bar is a masthead, not a Material `AppBar`.** Serif wordmark at 19sp / 0.16em tracking
   uppercase, a mono `mast-meta` date at 9.5sp on the trailing side, a 2dp ink bottom rule, and
   `elevation: 0` with `scrolledUnderElevation: 0`. **WHY:** Material's scrolled-under tint recolours
   the paper mid-scroll, and a masthead that changes tone under the thumb stops reading as print.

8. **The currency chip is present on EVERY screen that states a rule.** Seal glyph plus the words
   `Rules checked` plus the ISO date `2026-07-14` in mono tabular figures, verdant `#2E5E3A` when
   fresh, escalating to ochre `#8A6A16` with a changed word when stale — chrome, not a setting, and
   it NEVER blocks. **WHY:** an undated legal statement is an unverifiable one, and a stale rule
   still beats no rule at sea.

9. **The zone chip states place and nothing else.** Pin glyph, the zone name from the user database
   (`Ras Al Khaimah`, `Rias Baixas - Banco de Cambados`, `Represa de Jurumirim`), a mirrored trailing
   chevron, harbour `#1B4D5E` border — never GPS accuracy, a locating spinner or a signal bar.
   **WHY:** zone is a chosen jurisdiction, not a sensor reading, and animating it implies a lookup
   that never happens.

10. **The verdict surface may take over the whole screen and suppress the bar.** The result route
    sets `bottomNavigationBar: null` and drops the masthead to a bare back row. The COST, stated
    honestly: the destinations disappear and back becomes the only exit, so back must be visible
    without scrolling. **WHY:** the verdict is the product; anything competing with it costs AED 3,000.

11. **Chrome NEVER draws connectivity, sync, refresh or account.** No cloud, `Icons.sync`,
    `Icons.wifi_off`, pull-to-refresh, avatar, badge count or "last synced" line anywhere in the bar,
    masthead or chips. The only status text permitted is the offline-by-design kicker. **WHY:** every
    such affordance is a promise of a network CatchLaw does not have and will never acquire.

12. **Glove mode is a density switch on chrome, not a relayout.** The strip grows 62dp to 76dp, chips
    38dp to 56dp, icon buttons 44dp to 56dp, inter-target separation to at least 8dp — the
    destinations, order, glyphs and copy are byte-identical. **WHY:** a layout that also reshuffles
    under glove mode retrains the thumb exactly when the user has least attention to spare.

## The frozen five, drawn as a ledger strip

The destination set is an `enum`, never a list literal, so the count is a compile-time fact the gate
can read. The strip is a `DecoratedBox` over a `Row` of `Expanded` cells that bleeds to both screen
edges and pads only its own content, so the ink rule sits flush against the trim.

```dart
// RIGHT — one enum is the contract; scripts/check_lonja_nav.sh asserts exactly five values.
enum LonjaDestination { check, today, trips, reference, settings }

// Labels: an exhaustive switch over AppLocalizations (rule 4) — check => l10n.navCheck, and four
// more. A new value is a compile error until it is translated; a literal is never one.

// The printed strip: 2dp ink rule on top, sunk ground, hairline between the cells.
final t = LonjaTokens.of(context);
return DecoratedBox(
  decoration: BoxDecoration(
    color: t.paperSunk,                                        // #DEDBD1
    border: Border(top: BorderSide(color: t.ink, width: 2)),   // #16201C
  ),
  child: Padding(
    // Vertical system inset only. NEVER EdgeInsets.only(left:/right:) here (rule 5).
    padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
    child: SizedBox(
      height: t.gloveMode ? 76 : 62,
      child: Row(children: [
        for (final d in LonjaDestination.values)
          Expanded(child: LonjaNavCell(destination: d, selected: d == current)),
      ]),
    ),
  ),
);

// WRONG — a list literal that grows by one in a PR, inside Material's floating pill.
// NavigationBar(elevation: 3, indicatorShape: const StadiumBorder(), destinations: [...])
```

Full worked file: `examples/lonja_bottom_nav.dart`.

## Encoding the selected destination

Four signals stack, and the first three survive with colour deleted. Verify in the sunlight theme,
where harbour is gone and the rail falls back to `sun-ink` `#000000`: the selected cell must still be
unmistakable.

```dart
// RIGHT — ground + rail + filled glyph + weight; colour is the last of four.
Semantics(
  selected: selected, button: true,
  child: DecoratedBox(
    decoration: BoxDecoration(
      color: selected ? t.paper : t.paperSunk,                       // 1. ground lifts
      border: BorderDirectional(
        top: BorderSide(color: selected ? t.harbour : t.hairlineOff, width: 3),  // 2. rail
        end: BorderSide(color: t.rule, width: 1),                    // hairline, mirrors in RTL
      ),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(destination.glyph(selected: selected), size: 21, color: t.inkFor(selected)),  // 3.
      const SizedBox(height: 4),
      Text(destination.label(l10n),                                  // 4. weight
          style: t.navLabel.copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w500)),
    ]),
  ),
);

// WRONG — colour-only selection; invisible in the sunlight theme (rule 3).
// Icon(glyph, color: selected ? t.harbour : t.inkFaint)
```

Full worked file: `examples/lonja_bottom_nav.dart`.

## The masthead and its currency chip

The masthead is a `PreferredSizeWidget` carrying the wordmark, the dated mast-meta line, a 2dp ink
rule and — on any rule-stating screen — the zone and currency chips. The chips wrap; they never
scroll horizontally and never collapse into an overflow menu.

```dart
// RIGHT — gazette masthead: flat, ruled, dated, always showing its provenance.
// LonjaMasthead implements PreferredSizeWidget; preferredSize = Size.fromHeight(112).
DecoratedBox(
  decoration: BoxDecoration(
    color: t.paper,
    border: Border(bottom: BorderSide(color: t.ink, width: 2)),   // 2dp ink, no shadow
  ),
  child: Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 9),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LonjaWordmark(meta: t.mastMetaDate(context, DateTime.now())),  // "MON 27 JUL 2026"
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [      // wraps; never a horizontal scroller
        LonjaZoneChip(zone: zone),                     // "Ras Al Khaimah", mirrored chevron
        LonjaCurrencyChip(checkedOn: checkedOn),       // seal glyph + word + 2026-07-14
      ]),
    ]),
  ),
);
// WRONG — AppBar(title: Text('CatchLaw')) tints and lifts on scroll (rule 7).
```

Full worked file: `examples/lonja_bottom_nav.dart`.

## Back, mirroring, and the verdict takeover

One leading icon button, translated tooltip, mirrored glyph, 44dp target — and on the result route,
no strip at all. The takeover's cost is real and accepted deliberately: the five destinations are
gone until the user backs out, so back must be reachable without scrolling.

```dart
// RIGHT — the glyph mirrors, the padding is directional, the tooltip is translated.
final rtl = Directionality.of(context) == TextDirection.rtl;
final side = t.gloveMode ? 56.0 : 44.0;
final back = IconButton(
  tooltip: l10n.backTooltip,                                  // never a bare 'Back'
  constraints: BoxConstraints.tightFor(width: side, height: side),
  padding: const EdgeInsetsDirectional.only(start: 4),
  icon: rtl
      ? Transform.flip(flipX: true, child: const Icon(LonjaGlyphs.back, size: 22))
      : const Icon(LonjaGlyphs.back, size: 22),
  onPressed: () => Navigator.of(context).maybePop(),
);

// RIGHT — full-surface takeover: the strip is suppressed, back is the stated exit.
return Scaffold(
  backgroundColor: t.paper,
  bottomNavigationBar: null,            // deliberate: the verdict owns the surface (rule 10)
  appBar: LonjaBackRow(leading: back,   // no wordmark competes with the stamp
      trailing: LonjaCurrencyChip(checkedOn: verdict.checkedOn)),
  body: Column(children: [
    LonjaVerdictStamp(verdict: verdict),  // "Below the minimum — 38 cm, minimum 45 cm"
    LonjaCitation(text: l10n.citationMinisterialDecision580),  // Art. 3, published 2015-11-03
    const LonjaDisclaimerBlock(),         // non-dismissable, on this screen, always
  ]),
);

// WRONG — EdgeInsets.only(left: 4) with an unmirrored chevron, and the strip kept
// under the stamp so the screen "feels consistent" (rules 5, 6, 10).
```

Full worked file: `examples/lonja_bottom_nav.dart`.

## Anti-patterns

- **`NavigationBar(elevation: 3, indicatorShape: StadiumBorder())`** — the shadow floats the strip
  off the paper and the pill replaces the top rail, the one signal surviving the sunlight theme.
- **`NavigationDestination(label: 'Check')`** — an untranslated literal ships English chrome into
  the Arabic, Galician and Portuguese builds; fails `scripts/check_lonja_nav.sh`.
- **A sixth destination named `Map`, `More` or `Profile`** — breaks the 56dp cell floor at 320dp and
  invalidates every thumb position learned in the dark.
- **`EdgeInsets.only(left: 16)` inside a nav, chip or app bar widget** — pins the back affordance to
  the physical left; in Arabic it lands under the wrong thumb.
- **`Badge(label: Text('3'))` on a destination** — a count implies something arrived; nothing
  arrives, because there is no network and no account.
- **`Icons.cloud_off`, `Icons.sync`, `Icons.wifi_off` or a refresh spinner in the masthead** —
  advertises an absent network and invites the user to wait for a fetch that will never run.
- **A currency chip that turns ochre without changing its words** — colour-only staleness fails in
  the sunlight theme and for colour-vision-deficient users; the word must change too.
- **`Text('Rules checked ${DateTime.now()}')`** — stamps the render time, not the data's checked
  date, converting the trust signal into a lie.
- **Making the strip scrollable, collapsible or auto-hiding on scroll** — a target that moves is a
  target a gloved thumb misses; the strip is fixed furniture.

## Definition of done

- [ ] `scripts/check_lonja_nav.sh` is clean over `lib/`.
- [ ] `LonjaDestination` declares exactly five values, ordered check, today, trips, reference,
      settings (rule 1).
- [ ] The strip renders a 2dp ink top rule, `#DEDBD1` ground, cell hairlines, and zero elevation,
      radius and shadow (rule 2).
- [ ] A sunlight-theme golden shows the selected cell distinguishable with colour removed, and
      `Semantics(selected: true)` set on it (rule 3).
- [ ] No string literal appears as a label, tooltip or chip text in a chrome widget; every one
      resolves through `AppLocalizations` (rule 4).
- [ ] An `ar` golden shows cell hairlines, the zone chevron and the back glyph mirrored (rules 5, 6).
- [ ] The masthead is flat at scroll offset 0 and 400 and carries the zone and currency chips on every
      rule-stating screen (rules 7, 8, 9).
- [ ] The verdict route sets `bottomNavigationBar: null` and shows back plus the non-dismissable
      disclaimer without scrolling (rule 10).
- [ ] Grepping chrome widgets for cloud, sync, wifi, refresh, avatar and badge returns nothing
      (rule 11).
- [ ] With glove mode on, every chrome target measures at least 56dp with 8dp separation and the
      destination order is unchanged (rule 12).

## Related skills

- See `navigation-and-routing` for GoRouter, `StatefulShellRoute`, redirects and deep links — this
  skill never declares a route, only what the shell renders.
- See `adaptive-layout` for the NavigationBar-to-NavigationRail-to-Drawer breakpoints this chrome
  switches at, and for the safe-area contract.
- See `lonja-design-tokens` for the token names and the `LonjaTokens.of(context)` accessor whose
  values this skill spends.
- See `lonja-typography` for the serif, sans and mono role stacks and the tabular figures the
  mast-meta line and the checked date depend on.
- See `lonja-icons-and-plates` for the engraved glyph set and the filled/outline pair that carries
  selection signal three.
- See `lonja-verdict-and-status` for the stamp, semantic colours and statement-of-fact copy the
  takeover screen renders once the strip is gone.
- See `catchlaw-offline-guarantee` for why no connectivity, sync or account affordance may appear.
- See `accessibility-as-code` for the 44dp target floor, `Semantics(selected:)` and the
  never-colour-alone rule this skill merely instantiates.
- See `i18n-rtl-l10n` for ARB authoring, gen-l10n and the bidi handling behind every chrome string.

## References

- Flutter API — `NavigationBar`: https://api.flutter.dev/flutter/material/NavigationBar-class.html
- Flutter API — `BorderDirectional`: https://api.flutter.dev/flutter/painting/BorderDirectional-class.html
- Flutter API — `Directionality`: https://api.flutter.dev/flutter/widgets/Directionality-class.html
- Flutter API — `MediaQuery.viewPaddingOf`: https://api.flutter.dev/flutter/widgets/MediaQuery/viewPaddingOf.html
- Flutter API — `PreferredSizeWidget`: https://api.flutter.dev/flutter/widgets/PreferredSizeWidget-class.html
- Flutter API — `Transform.flip`: https://api.flutter.dev/flutter/widgets/Transform/Transform.flip.html
- Material 3 — navigation bar guidelines: https://m3.material.io/components/navigation-bar/guidelines
- W3C WAI — WCAG 2.2 target size (minimum): https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html
