import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_chip.dart';
import 'package:flutter/material.dart';

/// The band between the mast and the entry line: which printing, and the way
/// to a different place.
///
/// **The mockup's `.chips`, and the two things it stands them for.** The
/// checked date used to hang off the bottom of the mast as a third stacked
/// line, where it read as a subtitle of the place rather than as a stamp on the
/// pack; the way to another place used to be a `TextButton` wedged into the
/// mast row, which is the one row on the page that must stay a masthead. Both
/// are chips here, on the floor of the glove target set with the glove
/// separation between them.
class CheckPlaceChips extends StatelessWidget {
  /// Stamps [checkedOn], and offers the way to another place.
  const CheckPlaceChips({required this.checkedOn, required this.onChangePlace, super.key});

  /// When a human last verified the transcription, ISO-8601.
  final String checkedOn;

  /// Reopens S9.
  final VoidCallback onChangePlace;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: tokens.density.gutter,
        end: tokens.density.gutter,
        top: LonjaSpace.s4,
      ),
      child: Wrap(
        // Wrapped rather than laid out in a fixed line: at a large textScaler
        // the two chips no longer share a line, and a band that overflowed
        // would take the entry line down with it.
        spacing: tokens.density.tapGap,
        runSpacing: tokens.density.tapGap,
        children: <Widget>[
          LonjaChip.action(
            label: l10n.checkChangePlace,
            glyph: LonjaIcons.adjust,
            onTap: onChangePlace,
          ),
          LonjaChip.fact(
            // ISO and unlocalised, like every other date quoted from an
            // instrument: the same string in six languages, and comparable
            // against the gazette by eye.
            label: l10n.checkPackChecked(checkedOn),
            glyph: LonjaIcons.tick,
          ),
        ],
      ),
    );
  }
}
