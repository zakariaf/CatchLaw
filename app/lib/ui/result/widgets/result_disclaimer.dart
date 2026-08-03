import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';

/// What this screen is, and is not.
///
/// **Structural, and there is no way to hide it.** No `bool` parameter, no
/// callback, no dismiss affordance and no conditional around it at the call
/// site: a disclaimer the reader can put away is, in the record of what he was
/// shown, one that was never shown at all. `check_app_invariants.sh` check 5
/// greps for exactly the shapes that would make it conditional.
///
/// **The authority is per-jurisdiction.** A generic "not legal advice" tells a
/// fisher nothing about who to ask instead, and the whole sentence exists to
/// point at somebody who can answer.
class ResultDisclaimer extends StatelessWidget {
  /// States the disclaimer, naming [authority].
  const ResultDisclaimer({required this.authority, super.key});

  /// The already-localised authority — `Xunta de Galicia — Consellería do Mar`.
  final String authority;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          l10n.disclaimerVerdict(authority),
          style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: LonjaSpace.s1),
        Text(
          // Printed rather than implied: it makes the disclaimer's absence
          // legible in a screenshot, which is the form this screen travels in
          // when it is quoted back at the publisher.
          l10n.disclaimerNotDismissable,
          style: type.citation.copyWith(color: tokens.onSurfaceFaint),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
