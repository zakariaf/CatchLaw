import 'package:catchlaw/domain/models/rule_hint.dart';
import 'package:catchlaw/domain/models/species_search_state.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_search_field.dart';
import 'package:catchlaw/ui/core/ui/lonja_species_line.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/species/view_models/species_search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S5 — the species picker.
///
/// Two groups, **in your zone** first, because that is the answer to the
/// question actually being asked; **elsewhere in this jurisdiction** second and
/// never hidden, because a fisher who has picked the wrong zone must be able to
/// see that his fish exists rather than being told it does not.
class SpeciesSearchScreen extends ConsumerStatefulWidget {
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
  ConsumerState<SpeciesSearchScreen> createState() => _SpeciesSearchScreenState();
}

class _SpeciesSearchScreenState extends ConsumerState<SpeciesSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SpeciesSearchState state = ref.watch(speciesSearchViewModelProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Non-blocking and above the list, not over it: invariant 5 shows
            // the finding anyway, so the bar never covers what it warns about.
            if (state.isPackExpired) LonjaStaleBar(message: l10n.rulePackExpired),
            Padding(
              padding: EdgeInsetsDirectional.all(tokens.density.gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(l10n.speciesSearchLabel, style: type.eyebrow, textAlign: TextAlign.start),
                  const SizedBox(height: LonjaSpace.s1),
                  LonjaSearchField(
                    controller: _controller,
                    hint: l10n.speciesSearchHint,
                    semanticLabel: l10n.speciesSearchLabel,
                    onChanged: (String value) =>
                        ref.read(speciesSearchViewModelProvider.notifier).search(value),
                  ),
                  if (!state.isEmpty) ...<Widget>[
                    const SizedBox(height: LonjaSpace.s2),
                    Text(
                      l10n.speciesSearchResultCount(
                        state.inZone.length + state.elsewhere.length,
                        state.jurisdictionSpeciesCount,
                      ),
                      style: type.datum.copyWith(color: tokens.onSurfaceMuted),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: state.query.isEmpty
                  ? const SizedBox.shrink()
                  : state.isEmpty
                  ? _SearchEmptyState(
                      onIdentify: widget.onIdentify,
                      onBrowseByShape: widget.onBrowseByShape,
                      jurisdictionCount: state.jurisdictionSpeciesCount,
                    )
                  : CustomScrollView(
                      // Slivers rather than an eager ListView: the two groups
                      // are separate sections with their own headings, and a
                      // jurisdiction carries 400 species — building every line
                      // that could match is work nobody scrolls to.
                      slivers: <Widget>[
                        if (state.inZone.isNotEmpty)
                          _ResultGroup(
                            heading: l10n.speciesGroupInYourZone,
                            listings: state.inZone,
                            onChosen: widget.onSpeciesChosen,
                          ),
                        if (state.elsewhere.isNotEmpty)
                          _ResultGroup(
                            heading: l10n.speciesGroupElsewhere,
                            listings: state.elsewhere,
                            onChosen: widget.onSpeciesChosen,
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One group of results, under its heading.
class _ResultGroup extends StatelessWidget {
  const _ResultGroup({required this.heading, required this.listings, required this.onChosen});

  final String heading;
  final List<SpeciesListing> listings;
  final void Function(int speciesId) onChosen;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: LonjaSpace.s4,
                  end: LonjaSpace.s4,
                  top: LonjaSpace.s4,
                  bottom: LonjaSpace.s1,
                ),
                child: Text(
                  heading,
                  style: type.eyebrow.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
              ),
              const LonjaRule.section(),
            ],
          ),
        ),
        // Built lazily. A jurisdiction carries 400 species, so building every
        // line that could match is work nobody scrolls to — and
        // `check_lonja_lists.sh` fails an eager list constructor for exactly
        // that reason.
        SliverList.builder(
          itemCount: listings.length,
          itemBuilder: (BuildContext context, int index) {
            final SpeciesListing listing = listings[index];
            return LonjaSpeciesLine(
              name: listing.hit.matchedName,
              scientificName: listing.hit.scientificName,
              hint: _hintWord(listing, l10n),
              onTap: () => onChosen(listing.hit.speciesId),
            );
          },
        ),
      ],
    );
  }

  /// The one-word hint, localised here and nowhere else.
  ///
  /// `RuleHint` carries numbers and enums; the word is an ARB value. That split
  /// is what keeps every legal sentence inside `check_verdict_contract.sh`'s
  /// reach instead of scattered through the domain layer.
  String? _hintWord(SpeciesListing listing, AppLocalizations l10n) => switch (listing.facts?.hint) {
    ProtectedHint() => l10n.speciesHintProtected,
    ClosedSeasonHint() => l10n.speciesHintClosed,
    // The size is rendered by E10's finding row with its citation; a bare
    // number here would be a legal claim with no instrument beside it.
    MinimumSizeHint() || NoHint() || null => null,
  };
}

/// Nothing matched — and the two ways onward.
class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.onIdentify,
    required this.onBrowseByShape,
    required this.jurisdictionCount,
  });

  final VoidCallback onIdentify;
  final VoidCallback onBrowseByShape;
  final int jurisdictionCount;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return LonjaEmptyState(
      headline: l10n.speciesNoMatchHeadline,
      body: l10n.speciesNoMatchBody,
      // The count makes the claim honest: "this list covers the active
      // jurisdiction only" is a sentence nobody can check without a number.
      note: l10n.speciesSearchResultCount(0, jurisdictionCount),
      primary: LonjaButton.primary(label: l10n.identifyThisFish, onPressed: onIdentify),
      secondary: LonjaButton.secondary(label: l10n.browseByShape, onPressed: onBrowseByShape),
    );
  }
}
