import 'package:catchlaw/domain/models/species_search_state.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/species/view_models/species_search_view_model.dart';
import 'package:catchlaw/ui/species/widgets/species_search_field.dart';
import 'package:catchlaw/ui/species/widgets/species_search_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S5 — the species picker, as a screen of its own.
///
/// **A composition and not a container.** The field and the results are two
/// widgets because S1 sets them at different heights of its own page, with the
/// recents strip between them; this screen is what they look like when the
/// search is the whole page.
///
/// Which is why it heads itself with a ruled bar and S1 does not: a pushed
/// screen has somewhere to go back to and a masthead has not, so the chrome
/// over the same two widgets differs by exactly one band.
class SpeciesSearchScreen extends ConsumerWidget {
  /// Opens the picker.
  const SpeciesSearchScreen({
    required this.onSpeciesChosen,
    required this.onIdentify,
    required this.onBrowseByShape,
    super.key,
  });

  /// Where a chosen species goes — S2.
  final void Function(int speciesId) onSpeciesChosen;

  /// S7's key. One of the three entry points §4.3 requires.
  final VoidCallback onIdentify;

  /// S6.
  final VoidCallback onBrowseByShape;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // One selector and not the whole state: the bar and the field do not move
    // when a keystroke changes the list, and this screen rebuilds only when
    // the pack's currency does.
    final bool isPackExpired = ref.watch(
      speciesSearchViewModelProvider.select((SpeciesSearchState state) => state.isPackExpired),
    );
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.speciesSearchLabel,
        onBack: navigator.canPop() ? navigator.pop : null,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Non-blocking and above the list, not over it: invariant 5 shows
            // the finding anyway, so the bar never covers what it warns about.
            if (isPackExpired) LonjaStaleBar(message: l10n.rulePackExpired),
            const SpeciesSearchField(),
            // The match count is drawn by `SpeciesSearchResults`, at the head
            // of the list it counts. Both hosts of that widget then carry it in
            // the same place, and neither can print a number the list beneath
            // it disagrees with.
            Expanded(
              child: SpeciesSearchResults(
                onSpeciesChosen: onSpeciesChosen,
                onIdentify: onIdentify,
                onBrowseByShape: onBrowseByShape,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
