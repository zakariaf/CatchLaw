import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';

/// Why there is no sub-zone level, said in the authority's name.
///
/// **`SPEC.md` §8 ends that row with four words: we do not invent boundaries.**
/// Emirate maritime limits are not published as coordinate polygons in MD
/// 580/2015 or its successors, and Galicia's pack prints none either. An
/// administrative boundary borrowed from a public dataset would render
/// beautifully and would attribute a rule to a zone the decision never
/// mentions — which is the one failure this product cannot survive.
///
/// The notice states what the AUTHORITY publishes, never what the app could not
/// load. Those are different facts, and only one of them is about the law.
class NoSubZoneNotice extends StatelessWidget {
  /// Names [authority] as the one that published no boundaries.
  const NoSubZoneNotice({required this.authority, super.key});

  /// The already-localised authority.
  final String authority;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: LonjaSpace.s4,
        vertical: LonjaSpace.s2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const LonjaRule.section(),
          const SizedBox(height: LonjaSpace.s2),
          Text(
            l10n.zoneNoPublishedBoundaries(authority),
            style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
