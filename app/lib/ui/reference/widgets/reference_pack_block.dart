import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/reference/view_models/reference_hub_view_model.dart';
import 'package:flutter/material.dart';

/// One bundled pack, set as a quoted block.
///
/// The inline-start rule is the printed convention for a passage that came from
/// somewhere else, and it is the one place on this screen where the accent ink
/// is used: the block says *this is not the app talking*. Two non-colour
/// signals carry it as well as the ink does — the rule itself and the indent —
/// so it survives greyscale and glare, which invariant 4 requires of anything
/// that means something.
class ReferencePackBlock extends StatelessWidget {
  /// Prints [pack].
  const ReferencePackBlock({required this.pack, super.key});

  /// The jurisdiction, its authority and its printing.
  final HeldPack pack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final String? authority = pack.authority;

    return DecoratedBox(
      decoration: BoxDecoration(
        // Directional, so the rule stands at the start margin in `ar` too.
        border: BorderDirectional(
          start: BorderSide(color: tokens.accent, width: LonjaRules.strong),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: LonjaSpace.s3, bottom: LonjaSpace.s2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              // Cased here and never in the ARB: the mockup's transform has no
              // Dart equivalent, and on Arabic it is a silent no-op — which is
              // why the tracked micro face carries the hierarchy in every
              // locale alike.
              pack.name.toUpperCase(), // lonja-type: ok
              style: type.microLabel.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: LonjaSpace.s1),
            if (authority != null)
              Text(authority, style: type.legalSmall, textAlign: TextAlign.start),
            const SizedBox(height: LonjaSpace.s1),
            Text(
              // ISO and unlocalised, like every other date this app quotes from
              // an instrument: the same string in six languages, comparable
              // against the printed pack by eye.
              l10n.referenceHeldPack(pack.packVersion, pack.checkedOn),
              style: type.citation.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
