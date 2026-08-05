import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_search_field.dart';
import 'package:catchlaw/ui/species/view_models/species_search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The entry line, wired to the search, and the one instrument on S1.
///
/// **A widget of its own because two screens set it at different heights of
/// the page.** On Check it sits directly under the masthead, above the recents
/// strip, which is the mockup's order and was the app's the other way round;
/// on S5 it heads the results. Both need the same controller lifetime and the
/// same keystroke seam, and a screen that rebuilt one of them differently is a
/// screen where the same typing produces a different list.
///
/// It carries **no standing label**. The mockup puts nothing above the box: the
/// placeholder inside it names the field for a sighted reader, and
/// [LonjaSearchField]'s own `Semantics` names it for a screen reader — so the
/// label was a line of chrome that cost the strip below it a row of height and
/// told nobody anything.
class SpeciesSearchField extends ConsumerStatefulWidget {
  /// The entry line.
  const SpeciesSearchField({super.key});

  @override
  ConsumerState<SpeciesSearchField> createState() => _SpeciesSearchFieldState();
}

class _SpeciesSearchFieldState extends ConsumerState<SpeciesSearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      child: LonjaSearchField(
        controller: _controller,
        hint: l10n.speciesSearchHint,
        semanticLabel: l10n.speciesSearchLabel,
        onChanged: (String value) =>
            ref.read(speciesSearchViewModelProvider.notifier).search(value),
      ),
    );
  }
}
