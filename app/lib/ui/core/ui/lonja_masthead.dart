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
///
/// The optional meta block at the trailing edge answers the same question one
/// register down, in the gazette's own hand: the code the rows were filed
/// under and the version of the pack they came out of, so a fisher comparing
/// two devices at the quay can see in one glance which of them is behind.
class LonjaMasthead extends StatelessWidget {
  /// Names [place], transcribed on [checkedOn].
  const LonjaMasthead({
    required this.place,
    required this.checkedOn,
    required this.onChangePlace,
    this.zoneCode,
    this.packVersion,
    super.key,
  });

  /// The place, already localised.
  final String place;

  /// When a human last verified the transcription, ISO-8601.
  final String checkedOn;

  /// Reopens S9.
  final VoidCallback onChangePlace;

  /// The zone's code — the first meta line, or absent.
  ///
  /// **Printed as authored, and never re-cased here.** A code is an identifier
  /// rather than a sentence: it is the same string in all six locales, it is
  /// what a fisher reads off the printed pack to compare, and `v2026.2` shouted
  /// into `V2026.2` is a version nobody published.
  final String? zoneCode;

  /// The pack's version — the second meta line, or absent.
  final String? packVersion;

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
              if (zoneCode != null || packVersion != null) ...<Widget>[
                const SizedBox(width: LonjaSpace.s4),
                _MastheadMeta(zoneCode: zoneCode, packVersion: packVersion),
              ],
            ],
          ),
        ),
        const LonjaRule.section(),
      ],
    );
  }
}

/// The two stacked lines at the trailing edge of the mast.
///
/// A widget class rather than a `Widget _buildMeta()` helper: a helper has no
/// `BuildContext` of its own, so the `LonjaTokens.of(context)` inside it would
/// register the masthead's element as the dependent and rebuild the whole band
/// on a theme change, a density toggle or an RTL flip (`FLUTTER_GUIDE.md`
/// §8.1 mechanism 2).
class _MastheadMeta extends StatelessWidget {
  const _MastheadMeta({this.zoneCode, this.packVersion});

  final String? zoneCode;

  final String? packVersion;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    // The mono ramp step, because these are figures and codes to be compared
    // character by character against a printed pack — and quiet, because the
    // place above them is the line that has to be read first.
    final TextStyle style = type.articleNumber.copyWith(color: tokens.onSurfaceMuted);
    final String? zone = zoneCode;
    final String? version = packVersion;

    return Column(
      // Resolved against the ambient direction, so the block sits at the
      // trailing margin in `ar` as it does in `en`.
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (zone != null) Text(zone, style: style, textAlign: TextAlign.end),
        if (version != null) Text(version, style: style, textAlign: TextAlign.end),
      ],
    );
  }
}
