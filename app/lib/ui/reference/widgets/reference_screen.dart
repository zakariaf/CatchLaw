import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/species/widgets/species_browse_screen.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_screen.dart';
import 'package:flutter/material.dart';

/// The rule book, browsed rather than asked.
///
/// **This screen builds almost nothing.** `SpeciesBrowseScreen` is S6 and has
/// been complete, tested and unreachable since E08: a grid of silhouettes
/// grouped by family, sized by extent so it stays recognisable at arm's length.
/// The Reference branch renders a placeholder for a release because nothing
/// routed to it — not because the screen did not exist.
///
/// **Check asks a question; Reference answers browsing.** `SPEC.md` §4.3 wants
/// three ways into a species and the difference is the entry, not the content:
/// Check starts from a name the fisher already has, Reference starts from a
/// shape he does not. Both land on the same S2, which is why this file adds a
/// route and no second copy of the detail screen.
class ReferenceScreen extends StatelessWidget {
  /// Opens the browse grid.
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    void open(int speciesId) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => SpeciesDetailScreen(speciesId: speciesId),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: tokens.density.gutter,
                end: tokens.density.gutter,
                top: tokens.density.gutter,
              ),
              child: Text(l10n.navReference, style: type.title),
            ),
            Expanded(child: SpeciesBrowseScreen(onSpeciesChosen: open)),
          ],
        ),
      ),
    );
  }
}
