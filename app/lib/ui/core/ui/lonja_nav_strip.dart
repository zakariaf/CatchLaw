import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_destination.dart';
import 'package:flutter/material.dart';

/// The five destinations, along the bottom.
///
/// **A glyph AND a word on every cell**, always. §4.9 and invariant 4: a strip
/// whose destinations differ only by icon is unreadable to a reader who does
/// not know the icons yet, which is every reader on the first launch — and the
/// selected cell is marked by weight and by a rule, not by hue alone.
///
/// A ruled strip and not a Material `NavigationBar`: the bar brings an
/// indicator pill, a tint and an elevation, and a printed page has none of the
/// three.
class LonjaNavStrip extends StatelessWidget {
  /// Shows [current] as selected.
  const LonjaNavStrip({required this.current, required this.onSelected, super.key});

  /// Which branch is on screen.
  final LonjaDestination current;

  /// Switches branch.
  final void Function(LonjaDestination destination) onSelected;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(
          top: BorderSide(color: tokens.hairlineStrong, width: LonjaRules.rule),
        ),
      ),
      // The system inset is applied HERE and not by the branch above it, so a
      // gesture bar cannot cover a target and no branch has to know about it.
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            for (final LonjaDestination destination in LonjaDestination.shipped)
              Expanded(
                child: _NavCell(
                  destination: destination,
                  selected: destination == current,
                  onTap: () => onSelected(destination),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One destination.
class _NavCell extends StatelessWidget {
  const _NavCell({required this.destination, required this.selected, required this.onTap});

  final LonjaDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final Color ink = selected ? tokens.onSurface : tokens.onSurfaceMuted;
    final String label = destination.label(l10n);

    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          // The glove floor is the density's own, so the strip grows with the
          // setting rather than carrying a second number that drifts from it.
          constraints: BoxConstraints(minHeight: tokens.density.tapMin),
          padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s1),
          decoration: BoxDecoration(
            border: BorderDirectional(
              // The selected mark is a RULE, not a tint: in sunlight the tint
              // is the first thing to go, and the rule is still there. Absent
              // rather than transparent on the others — a raw colour outside
              // `lib/theme/` is a second palette, even when it is invisible.
              top: selected
                  ? BorderSide(color: tokens.onSurface, width: LonjaRules.strong)
                  : BorderSide.none,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Excluded here rather than relying on the cell's own
              // `excludeSemantics` three lines up: the glyph repeats the word
              // below it, and `check_lonja_icons` reads a short window.
              ExcludeSemantics(
                child: LonjaIcon(destination.glyph, size: LonjaIconSize.ui, color: ink),
              ),
              const SizedBox(height: LonjaSpace.s1),
              Text(
                label,
                style: type.microLabel.copyWith(color: ink),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
