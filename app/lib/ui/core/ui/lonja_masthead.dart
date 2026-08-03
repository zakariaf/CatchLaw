import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';

/// The masthead: which place the answers below are for, and how current it is.
///
/// **A verdict read without knowing which jurisdiction produced it is a verdict
/// about nowhere.** The place is on screen before the search box, not behind a
/// settings screen, because the fisher who most needs to see it is the one who
/// drove two hours and did not think to check.
class LonjaMasthead extends StatelessWidget {
  /// Names [place], transcribed on [checkedOn].
  const LonjaMasthead({
    required this.place,
    required this.checkedOn,
    required this.onChangePlace,
    super.key,
  });

  /// The place, already localised.
  final String place;

  /// When a human last verified the transcription, ISO-8601.
  final String checkedOn;

  /// Reopens S9.
  final VoidCallback onChangePlace;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LonjaSpace.s4,
            vertical: LonjaSpace.s2,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      l10n.checkPlaceLabel,
                      style: type.eyebrow.copyWith(color: tokens.onSurfaceMuted),
                      textAlign: TextAlign.start,
                    ),
                    Text(place, style: type.subtitle, textAlign: TextAlign.start),
                    Text(
                      // ISO and unlocalised, like every other date quoted from
                      // an instrument: the same string in six languages, and
                      // comparable against the gazette by eye.
                      l10n.checkPackChecked(checkedOn),
                      style: type.citation.copyWith(color: tokens.onSurfaceMuted),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: tokens.density.tapMin),
                child: TextButton(
                  onPressed: onChangePlace,
                  child: Text(l10n.checkChangePlace, textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
        const LonjaRule.section(),
      ],
    );
  }
}
