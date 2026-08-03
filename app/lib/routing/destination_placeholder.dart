import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_destination.dart';
import 'package:flutter/material.dart';

/// A branch this release does not build.
///
/// **One class for all four**, not four classes.
///
/// It carried the destination's label and nothing else, on the reasoning that a
/// label-only screen adds no ARB key for E13, E15 or E16 to delete. That was one
/// key saved and four screens that looked broken: a single grey word on an empty
/// page reads as a screen that failed to load, not as one this release does not
/// build — and the reader cannot tell the difference, which is the whole point
/// of saying so.
///
/// So it states the fact instead, in one key those epics delete along with this
/// file. The sentence does not apologise, does not promise a date and does not
/// tell the reader to do anything; it says what this version contains.
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(destination.label(l10n), style: type.title, textAlign: TextAlign.start),
              SizedBox(height: tokens.density.tapGap),
              Text(
                l10n.destinationNotBuiltYet,
                style: type.legal.copyWith(color: tokens.onSurfaceMuted),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
