import 'package:catchlaw/domain/models/rule_hint.dart';
import 'package:catchlaw/domain/models/species_search_state.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_silhouette.dart';
import 'package:catchlaw/ui/core/ui/lonja_species_line.dart';
import 'package:catchlaw/ui/species/view_models/species_search_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the typing found.
///
/// Two groups, **in your zone** first, because that is the answer to the
/// question actually being asked; **elsewhere in this jurisdiction** second and
/// never hidden, because a fisher who has picked the wrong zone must be able to
/// see that his fish exists rather than being told it does not.
///
/// Separated from the field above it so the page between them belongs to the
/// screen: Check stands its recents strip there while nothing is typed, and the
/// mockup's S1 stands its day tally there too.
class SpeciesSearchResults extends ConsumerWidget {
  /// The results for whatever is in the field.
  const SpeciesSearchResults({
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
    final SpeciesSearchState state = ref.watch(speciesSearchViewModelProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (state.query.isEmpty) return const SizedBox.shrink();
    if (state.isEmpty) {
      return _SearchEmptyState(
        onIdentify: onIdentify,
        onBrowseByShape: onBrowseByShape,
        jurisdictionCount: state.jurisdictionSpeciesCount,
      );
    }

    return CustomScrollView(
      // Slivers rather than an eager ListView: the two groups are separate
      // sections with their own headings, and a jurisdiction carries 400
      // species — building every line that could match is work nobody scrolls
      // to.
      slivers: <Widget>[
        // How many the name matched, directly under the field and above the
        // first group — a sentence set as an eyebrow beside a rule, not a
        // ratio set as a figure. `4 of 412` is a measurement; the reader is
        // asking how many rows are under his thumb.
        SliverToBoxAdapter(child: _MatchCount(count: state.inZone.length + state.elsewhere.length)),
        if (state.inZone.isNotEmpty)
          _ResultGroup(
            heading: l10n.speciesGroupInYourZone,
            listings: state.inZone,
            onChosen: onSpeciesChosen,
          ),
        if (state.elsewhere.isNotEmpty)
          _ResultGroup(
            heading: l10n.speciesGroupElsewhere,
            listings: state.elsewhere,
            onChosen: onSpeciesChosen,
          ),
      ],
    );
  }
}

/// The label over the results: how many the typed name matched.
class _MatchCount extends StatelessWidget {
  const _MatchCount({required this.count});

  final int count;

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
      child: LonjaSectionLabel(text: l10n.speciesSearchMatchCount(count)),
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
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.density.gutter,
              end: tokens.density.gutter,
              top: LonjaSpace.s5,
              bottom: LonjaSpace.s3,
            ),
            // The gazette device — a tracked label with a rule running to the
            // margin — and not a heading over a full-width section rule. The
            // rule beside the words is what says "the rows under this belong
            // to it"; a bar across the page says "a new section starts here",
            // which is the wrong sentence for the second of two groups the
            // fisher is comparing.
            child: LonjaSectionLabel(text: heading),
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
              // The shape, at the leading edge of every row. A search result
              // that is only a name is a row a fisher has to read; a row with
              // the drawing on it is one he can recognise before he reads,
              // which is the whole reason S6 exists and the reason this list
              // carried the slot and never filled it.
              art: LonjaSilhouette(
                assetKey: listing.hit.silhouetteAsset,
                semanticsLabel: l10n.speciesSilhouetteSemanticLabel,
                height: LonjaSpace.s6,
              ),
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
