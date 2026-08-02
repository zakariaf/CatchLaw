import 'package:catchlaw/domain/models/look_alike.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_panel.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:flutter/material.dart';

/// The species this one is mistaken for, and the character that separates them.
///
/// **The cheapest defence against the most expensive error.** `SPEC.md` §5.2
/// point 2: a wrong confident classification on a protected species is the
/// worst failure this app could have. The card does not classify — it states
/// that two fish look alike, quotes one physical character from the pack, and
/// lets the reader look at the fish in his hand.
class LookAlikeCard extends StatelessWidget {
  /// Warns about [lookAlikes].
  const LookAlikeCard({required this.lookAlikes, required this.onOpenSpecies, super.key});

  /// The confusable species, in both directions.
  final List<LookAlike> lookAlikes;

  /// Opens the other species' own S2.
  final void Function(int speciesId) onOpenSpecies;

  @override
  Widget build(BuildContext context) {
    if (lookAlikes.isEmpty) return const SizedBox.shrink();
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LonjaSectionLabel(text: l10n.lookAlikeSectionLabel),
        const SizedBox(height: LonjaSpace.s2),
        for (final LookAlike other in lookAlikes) ...<Widget>[
          _LookAlikeEntry(lookAlike: other, onOpen: onOpenSpecies),
          const SizedBox(height: LonjaSpace.s3),
        ],
      ],
    );
  }
}

/// One confusable species.
class _LookAlikeEntry extends StatelessWidget {
  const _LookAlikeEntry({required this.lookAlike, required this.onOpen});

  final LookAlike lookAlike;
  final void Function(int speciesId) onOpen;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: lookAlike.confusedWithName,
      child: InkWell(
        onTap: () => onOpen(lookAlike.confusedWithSpeciesId),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.density.tapMin),
          child: LonjaPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(lookAlike.confusedWithName, style: type.subtitle, textAlign: TextAlign.start),
                Text(
                  lookAlike.confusedWithScientificName,
                  style: type.binomial.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
                if (lookAlike.confusedWithIsProtected) ...<Widget>[
                  const SizedBox(height: LonjaSpace.s1),
                  // The whole reason the card matters: mistaking an unprotected
                  // fish for a protected one costs nothing, and the reverse
                  // costs a licence.
                  Text(
                    l10n.speciesProtectedAnywhere,
                    style: type.datum.copyWith(color: tokens.onSurface),
                    textAlign: TextAlign.start,
                  ),
                ],
                const SizedBox(height: LonjaSpace.s2),
                Text(
                  l10n.lookAlikeConfusedWith,
                  style: type.microLabel.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: LonjaSpace.s1),
                // A sentence from the pack, describing a physical character.
                // Never what to do about it.
                Text(lookAlike.difference, style: type.legal, textAlign: TextAlign.start),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
