import 'package:catchlaw/domain/models/family_group.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/species/view_models/species_browse_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S6 — browse by shape.
///
/// A grid of black-on-white silhouettes grouped by family, with **the family
/// names in the reader's own language**. A Galician grid says *Vieiras*, not
/// *Pectinidae*: a mariscadora browsing by shape is looking for a scallop, and
/// the Latin is a label she has no reason to know.
class SpeciesBrowseScreen extends ConsumerWidget {
  /// Opens the grid.
  const SpeciesBrowseScreen({required this.onSpeciesChosen, super.key});

  /// Where a chosen species goes — S2.
  final void Function(int speciesId) onSpeciesChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FamilyGroup>> groups = ref.watch(speciesBrowseViewModelProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsetsDirectional.all(tokens.density.gutter),
              child: Text(l10n.browseByShapeTitle, style: type.title, textAlign: TextAlign.start),
            ),
            Expanded(
              child: groups.when(
                // A skeleton and not a spinner: a spinner says "something is
                // happening", a skeleton says "a grid is coming, and it will be
                // this shape".
                loading: () => const LonjaListSkeleton(),
                error: (Object _, StackTrace _) => LonjaEmptyState(
                  headline: l10n.browseNoSpeciesHeadline,
                  body: l10n.browseNoSpeciesBody,
                  primary: const SizedBox.shrink(),
                ),
                data: (List<FamilyGroup> families) => families.isEmpty
                    ? LonjaEmptyState(
                        headline: l10n.browseNoSpeciesHeadline,
                        body: l10n.browseNoSpeciesBody,
                        primary: const SizedBox.shrink(),
                      )
                    : CustomScrollView(
                        slivers: <Widget>[
                          for (final FamilyGroup family in families)
                            _FamilySliver(family: family, onChosen: onSpeciesChosen),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One family heading and its silhouettes.
class _FamilySliver extends StatelessWidget {
  const _FamilySliver({required this.family, required this.onChosen});

  final FamilyGroup family;
  final void Function(int speciesId) onChosen;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.density.gutter,
              end: tokens.density.gutter,
              top: LonjaSpace.s4,
              bottom: LonjaSpace.s2,
            ),
            // The name as authored, in whatever case the content carries. An
            // upper-casing transform here is a silent no-op on Arabic, so a
            // heading that relied on it would shout VIEIRAS in Galician and be
            // indistinguishable from body text in `ar`. The hierarchy comes
            // from the microLabel step and the rule beside it instead.
            child: LonjaSectionLabel(text: family.localisedFamilyName),
          ),
        ),
        SliverPadding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.density.gutter),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              // A silhouette needs to be recognisable at arm's length on a wet
              // screen, so the tile is sized by extent rather than by a column
              // count that would shrink it on a small phone.
              maxCrossAxisExtent: 132,
              mainAxisSpacing: tokens.density.tapGap,
              crossAxisSpacing: tokens.density.tapGap,
              childAspectRatio: 0.85,
            ),
            itemCount: family.species.length,
            itemBuilder: (BuildContext context, int index) =>
                _SilhouetteTile(tile: family.species[index], onChosen: onChosen),
          ),
        ),
      ],
    );
  }
}

/// One species, as a silhouette with its name under it.
class _SilhouetteTile extends StatelessWidget {
  const _SilhouetteTile({required this.tile, required this.onChosen});

  final SpeciesTile tile;
  final void Function(int speciesId) onChosen;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Semantics(
      button: true,
      label: tile.displayName,
      child: InkWell(
        onTap: () => onChosen(tile.speciesId),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.density.tapMin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // The art itself is E08/T05's resolver and the icon family nobody
              // owns yet; the tile reserves the box so the grid's geometry is
              // the one that ships.
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: tokens.surfaceSunk,
                    border: Border.all(color: tokens.hairline, width: LonjaRules.rule),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: LonjaSpace.s1),
              Text(
                tile.displayName,
                style: type.uiSmall,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
