import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_destination.dart';
import 'package:flutter/material.dart';

/// A branch this release does not build.
///
/// **One class for all four**, not four classes: it renders the destination's
/// own translated label and nothing else, so it adds no ARB key that E13, E15
/// or E16 will have to delete when they replace it.
///
/// Today and Trips are E13's, Reference is E15's, Settings is E16's — all v2
/// (`epics/RELEASES.md`). The strip carries five cells in v1 because §6
/// enumerates five and a strip that grew from two to five between releases
/// would move every target the fisher had learned.
class DestinationPlaceholder extends StatelessWidget {
  /// Stands in for [destination].
  const DestinationPlaceholder({required this.destination, super.key});

  /// Which branch.
  final LonjaDestination destination;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(tokens.density.gutter),
          child: Text(
            destination.label(l10n),
            style: type.title.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ),
      ),
    );
  }
}
