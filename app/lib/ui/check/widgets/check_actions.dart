import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:flutter/material.dart';

/// The two other ways in, standing under the strip and never hidden.
///
/// **§4.3 wants three ways to a species and S1 used to offer one.** The name is
/// the fast path, and it is the path that fails first: a fisher who does not
/// know what he is holding cannot type it, and one who knows it only in a
/// dialect the pack did not transcribe types it and gets nothing. Both labels
/// existed in the app already — inside the search results' empty state, which
/// is reachable only by typing a name that matches nothing, so the two ways out
/// of "I cannot name this fish" were behind naming the fish.
///
/// **Both rungs are secondary.** Neither is the primary action of S1: the entry
/// line above them is, and `lonja-buttons` allows exactly one filled box per
/// screen. Two full-width outlined boxes at the ACTION height — 66 dp in glove
/// mode — separated by the glove separation, which is what the mockup draws.
class CheckActions extends StatelessWidget {
  /// Offers the shape grid and the key.
  const CheckActions({required this.onBrowseByShape, required this.onIdentify, super.key});

  /// S6 — the browse grid.
  final VoidCallback onBrowseByShape;

  /// S7 — the couplet key.
  final VoidCallback onIdentify;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: tokens.density.gutter,
        end: tokens.density.gutter,
        top: LonjaSpace.s5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LonjaButton.secondary(
            label: l10n.browseByShape,
            onPressed: onBrowseByShape,
            leading: const ExcludeSemantics(child: LonjaIcon(LonjaIcons.fish)),
          ),
          SizedBox(height: tokens.density.tapGap),
          LonjaButton.secondary(
            label: l10n.identifyThisFish,
            onPressed: onIdentify,
            leading: const ExcludeSemantics(child: LonjaIcon(LonjaIcons.openQuestion)),
          ),
        ],
      ),
    );
  }
}
