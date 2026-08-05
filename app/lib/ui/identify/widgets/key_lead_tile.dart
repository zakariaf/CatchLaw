import 'package:catchlaw/domain/models/key_step.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_silhouette.dart';
import 'package:flutter/material.dart';

/// One answer to a couplet, set as a printed lead.
///
/// **The figure is half the control.** A key answered by reading alone is a key
/// answered by whoever already knows the vocabulary; the drawing beside the
/// character is what a fisher with wet hands at 05:40 actually compares the
/// fish in front of him against — and it is the reason `figure_asset` is a
/// column on `key_option` rather than a nicety.
///
/// **Framed at the bearing weight, not the hairline.** The whole rectangle is
/// the tap target and its only boundary is that rule, so it takes the tone with
/// the 3:1 floor rather than the ornamental one.
class KeyLeadTile extends StatelessWidget {
  /// Draws [lead] as the answer numbered [lead.mark] of couplet [couplet].
  const KeyLeadTile({required this.lead, required this.couplet, required this.onTaken, super.key});

  /// The answer this tile offers.
  final KeyLead lead;

  /// Which couplet it belongs to, so the mark reads as the key prints it.
  final int couplet;

  /// Takes the answer.
  final ValueChanged<KeyLead> onTaken;

  /// The card's floor, and the figure's box inside it.
  ///
  /// Composed from the spacing spine rather than authored: a lead is read as a
  /// plate compartment with a caption beside it, and a card that shrank to its
  /// text would put two drawings at two different sizes on one page.
  static const double _extent = LonjaSpace.s8 + LonjaSpace.s7;

  /// How many candidate names the consequence line prints.
  ///
  /// Three, because the line is a hint about which way the key runs and not the
  /// candidate list — that list is a screen of its own, one answer further on.
  static const int _namesShown = 3;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? figure = lead.figureAsset;

    return Semantics(
      button: true,
      label: lead.label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceSunk,
          border: Border.fromBorderSide(
            BorderSide(color: tokens.ruleBearing, width: LonjaRules.rule),
          ),
        ),
        child: InkWell(
          onTap: () => onTaken(lead),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _extent),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(LonjaSpace.s4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  if (figure != null) ...<Widget>[
                    SizedBox(
                      width: _extent,
                      height: LonjaSpace.s8,
                      child: LonjaSilhouette(
                        assetKey: figure,
                        semanticsLabel: l10n.speciesSilhouetteSemanticLabel,
                      ),
                    ),
                    const SizedBox(width: LonjaSpace.s4),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          l10n.identifyLeadMark(couplet, lead.mark),
                          style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: LonjaSpace.s1),
                        // The character itself, in the serif the rest of the
                        // key's prose is set in. Never truncated: a lead cut
                        // off mid-clause is a question the reader answers on
                        // half its wording.
                        Text(lead.label, style: type.legal, textAlign: TextAlign.start),
                        const SizedBox(height: LonjaSpace.s1),
                        Text(
                          _consequence(l10n),
                          style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// What taking this answer still allows.
  String _consequence(AppLocalizations l10n) {
    if (lead.candidates.isEmpty) return l10n.identifyLeadNoSpecies;
    return l10n.identifyLeadConsequence(
      lead.candidates.length,
      lead.candidates.take(_namesShown).map((KeyCandidate c) => c.displayName).join(' · '),
    );
  }
}
