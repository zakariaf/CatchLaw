import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';

/// The band over a pushed screen: the way back, what this page is, and where
/// it applies.
///
/// **Not the gazette masthead.** `LonjaMasthead` opens a branch and names the
/// place the answers below it are for; this is the hairline band a *pushed*
/// route carries — a species account, the ruler, the article text. The
/// difference is load-bearing: a masthead has nowhere to go back to, and a
/// pushed screen with no back affordance is a screen the fisher is stuck on.
///
/// The trailing [sup] is the second half of that job. A species name alone
/// answers "which fish"; the zone stamp beside it answers "checked against
/// what", which is the question a verdict read two hours from home turns on.
///
/// A `PreferredSizeWidget`, so it mounts as `Scaffold.appBar` rather than as
/// the first row of a body `Column` — the Scaffold is what reserves the status
/// bar above it and keeps the band still while the body scrolls under it.
class LonjaScreenBar extends StatelessWidget implements PreferredSizeWidget {
  /// Heads the screen with [title], stamped [sup], returning through [onBack].
  const LonjaScreenBar({required this.title, this.sup, this.onBack, super.key});

  /// The screen's name, already localised.
  final String title;

  /// The zone or context this screen is read against, already localised and
  /// already cased.
  ///
  /// **Cased by the caller, never here.** The mockup's `text-transform` has no
  /// Dart equivalent, and a case transform in UI code is banned under `lib/` by
  /// `check_lonja_type.sh` check 6 for the reason that makes it worth banning:
  /// on Arabic it is a silent no-op, so a stamp whose legibility came from
  /// casing would read as ordinary body text in exactly one locale. What marks
  /// it in every locale alike is the mono face, the tracking and the quiet ink.
  final String? sup;

  /// Returns to the screen this one was pushed from, or absent on a root
  /// branch, where a dead chevron would read as a broken control.
  final VoidCallback? onBack;

  /// The band's height, and the same in both densities.
  ///
  /// A `PreferredSizeWidget` answers before it has a `BuildContext`, so this
  /// cannot be read from the density in scope. It is authored at the *gloved*
  /// floor plus the block padding, so the gloved target fits inside it and the
  /// band does not change height when the setting does — a chrome band that
  /// resized under the thumb would move the title mid-read.
  static final double _extent = LonjaDensity.glove.tapMin + LonjaSpace.s2 * 2 + LonjaRules.rule;

  @override
  Size get preferredSize => Size.fromHeight(_extent);

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final VoidCallback? back = onBack;
    final String? stamp = sup;

    return ColoredBox(
      color: tokens.surface,
      // The status-bar inset is applied HERE and not by the screen above it:
      // the Scaffold reserves the room for a preferred-size bar but does not
      // consume it, so a band that skipped this would print its title under
      // the clock.
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: _extent,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.density.gutter),
                  child: Row(
                    children: <Widget>[
                      if (back != null) ...<Widget>[
                        _BackTarget(onBack: back),
                        const SizedBox(width: LonjaSpace.s2),
                      ],
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            title,
                            style: type.subtitle,
                            textAlign: TextAlign.start,
                            // The band is one printed line and the name is
                            // repeated in full on the page below it. Legal
                            // prose is never treated this way — see
                            // check_lonja_type.sh check 7.
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (stamp != null) ...<Widget>[
                        const SizedBox(width: LonjaSpace.s4),
                        Text(
                          stamp,
                          style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // A hairline and not the masthead's 2 pt section rule: a pushed
              // screen is a page of the same document, not the head of a new
              // one.
              const LonjaRule.block(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The way back, sized by the density in scope.
class _BackTarget extends StatelessWidget {
  const _BackTarget({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    return IconButton(
      // The accessible name first, ahead of any argument whose own closing
      // paren ends a line: check_lonja_buttons reads a short window and stops
      // at the first one it finds, and a chevron silent to TalkBack is the
      // failure that check is for.
      tooltip: l10n.navBack,
      icon: LonjaIcon(
        LonjaIcons.back,
        size: LonjaIconSize.ui,
        color: tokens.onSurface,
        // A chevron is the one glyph in the family with no word beside it, so
        // the name is carried on the glyph itself and not left to the tooltip:
        // a control announced as "button" is a control a blind reader has to
        // activate to identify.
        semanticLabel: l10n.navBack,
      ),
      onPressed: onBack,
      constraints: BoxConstraints(
        minWidth: tokens.density.tapMin,
        minHeight: tokens.density.tapMin,
      ),
    );
  }
}
