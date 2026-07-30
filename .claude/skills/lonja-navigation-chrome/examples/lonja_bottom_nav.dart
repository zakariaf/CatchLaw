// Demonstrates the Lonja navigation chrome: the frozen five-destination enum, the ruled ledger
// strip (2dp ink top rule, paper-sunk ground, per-cell hairlines, zero elevation and radius),
// the four-signal selected encoding whose first three survive with colour deleted, the mirrored
// back affordance, and the verdict takeover that suppresses the strip entirely.
// EVERY visible string resolves through an AppLocalizations-shaped lookup, never a literal.
// Colour consts and `glove` stand in for the LonjaTokens ThemeExtension, NavStrings for gen-l10n,
// Material icons for the engraved LonjaGlyphs set. Conceptually compiles against flutter.

import 'package:flutter/material.dart';

// Token values; in the app these are slots on the LonjaTokens ThemeExtension.
const Color kPaper = Color(0xFFE6E4DC), kPaperSunk = Color(0xFFDEDBD1); // grounds
const Color kInk = Color(0xFF16201C), kInkFaint = Color(0xFF6C7871); // selected, unselected
const Color kRule = Color(0xFFC2C5BB); // cell hairlines
const Color kHarbour = Color(0xFF1B4D5E); // chrome accent — NEVER a verdict colour

/// Stand-in for `LonjaGlyphs.back`. The engraved face does NOT set `matchTextDirection`, so the
/// mirroring below is explicit (rule 6). Material's `Icons.arrow_back` is the opposite trap: it
/// ships `matchTextDirection: true`, so wrapping THAT in a `Transform.flip` mirrors it twice and
/// leaves the Arabic chevron pointing back into the text it is meant to leave.
const IconData kBackGlyph = IconData(0xE801, fontFamily: 'LonjaGlyphs');

/// Stand-in for gen-l10n over `app_en.arb` and its five siblings, including `app_ar.arb`.
abstract class NavStrings {
  String get navCheck;
  String get navToday;
  String get navTrips;
  String get navReference;
  String get navSettings;
  String get backTooltip;
}

/// Frozen at five, in this order (rule 1): the gate asserts the count.
enum LonjaDestination {
  check(Icons.set_meal, Icons.set_meal_outlined),
  today(Icons.receipt_long, Icons.receipt_long_outlined),
  trips(Icons.route, Icons.route_outlined),
  reference(Icons.menu_book, Icons.menu_book_outlined),
  settings(Icons.tune, Icons.tune_outlined);

  const LonjaDestination(this.filled, this.outline);

  final IconData filled, outline; // signal three of the selected encoding
  IconData glyph({required bool on}) => on ? filled : outline;

  String label(NavStrings s) => switch (this) {
        LonjaDestination.check => s.navCheck,
        LonjaDestination.today => s.navToday,
        LonjaDestination.trips => s.navTrips,
        LonjaDestination.reference => s.navReference,
        LonjaDestination.settings => s.navSettings,
      };
}

/// Pass to `Scaffold.bottomNavigationBar`. Routes and the shell owning `current` belong to
/// `navigation-and-routing`; `glove` is the density switch (rule 12) — sizes only, never order.
class LonjaNavStrip extends StatelessWidget {
  const LonjaNavStrip({required this.current, required this.strings,
      required this.onSelect, this.glove = false, super.key});

  final LonjaDestination current;
  final NavStrings strings;
  final ValueChanged<LonjaDestination> onSelect;
  final bool glove;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          color: kPaperSunk,
          border: Border(top: BorderSide(color: kInk, width: 2)), // no radius, no shadow
        ),
        child: Padding(
          // Vertical system inset only; a physical left/right inset strands the hairlines (rule 5).
          padding: EdgeInsets.only(bottom: MediaQuery.viewPaddingOf(context).bottom),
          child: SizedBox(
            height: glove ? 76 : 62,
            child: Row(children: [
              for (final d in LonjaDestination.values)
                Expanded(
                    child: _NavCell(d, d == current, d == LonjaDestination.values.last, strings,
                        glove, () => onSelect(d))),
            ]),
          ),
        ),
      );
}

class _NavCell extends StatelessWidget {
  const _NavCell(this.destination, this.on, this.isLast, this.strings, this.glove, this.onTap);

  final LonjaDestination destination;
  final bool on, isLast, glove;
  final NavStrings strings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final labelSize = glove ? 10.0 : 9.0;
    return Semantics(
      selected: on, button: true,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: on ? kPaper : kPaperSunk, // 1. the ground lifts
            border: BorderDirectional(
              // 2. the rail sits on the TOP edge; a bottom rail hides under the thumb
              top: BorderSide(color: on ? kHarbour : Colors.transparent, width: 3),
              end: isLast ? BorderSide.none : const BorderSide(color: kRule),
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(destination.glyph(on: on), // 3. filled vs outline
                size: glove ? 24 : 21, color: on ? kInk : kInkFaint),
            const SizedBox(height: 4),
            Text(destination.label(strings), // resolved, never a literal (rule 4)
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: labelSize, letterSpacing: 0.11 * labelSize,
                    fontWeight: on ? FontWeight.w600 : FontWeight.w500, // 4. weight
                    color: on ? kInk : kInkFaint)), // colour is signal five, and last
          ]),
        ),
      ),
    );
  }
}

/// The result route owns the whole surface. COST, stated: four one-tap destinations disappear
/// until the user backs out. Accepted because the verdict must be read in ten seconds with wet
/// hands — so back must never require a scroll.
class LonjaVerdictScaffold extends StatelessWidget {
  const LonjaVerdictScaffold({required this.strings, required this.child,
      this.glove = false, super.key});

  final NavStrings strings;
  final Widget child;
  final bool glove;

  @override
  Widget build(BuildContext context) {
    final side = glove ? 56.0 : 44.0;
    return Scaffold(
      backgroundColor: kPaper,
      bottomNavigationBar: null, // deliberate suppression (rule 10)
      appBar: AppBar(
        backgroundColor: kPaper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0, // the masthead holds one tone at every scroll offset
        shape: const Border(bottom: BorderSide(color: kInk, width: 2)),
        leading: IconButton(
          tooltip: strings.backTooltip,
          constraints: BoxConstraints.tightFor(width: side, height: side),
          padding: const EdgeInsetsDirectional.only(start: 4),
          icon: Transform.flip(
              flipX: Directionality.of(context) == TextDirection.rtl,
              child: const Icon(kBackGlyph, size: 22, color: kInk)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: child, // the stamp, the citation, and the non-dismissable disclaimer
    );
  }
}
