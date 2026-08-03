import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';

/// The first launch in a place: nothing has been checked here yet.
///
/// **It states what this DEVICE has done, never what the reader should do.**
/// "Search for a species to get started" is an instruction, and this app does
/// not instruct — not about fish, and not about itself. The body explains the
/// mechanism instead: he is not being asked to look anything up, he is being
/// told what happens when he does.
///
/// No illustration and no action. The search field is directly below it and is
/// the only thing to do on this screen; a button here would be a second way to
/// reach a control already on the same page.
class CheckEmptyState extends StatelessWidget {
  /// The no-recents state.
  const CheckEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.all(tokens.density.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(l10n.checkNoRecentsHeadline, style: type.subtitle, textAlign: TextAlign.start),
          const SizedBox(height: LonjaSpace.s1),
          Text(
            l10n.checkNoRecentsBody,
            style: type.ui.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
