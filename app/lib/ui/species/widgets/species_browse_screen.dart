import 'package:catchlaw/domain/models/family_group.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_silhouette.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/species/view_models/species_browse_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How many compartments one family's plate carries before it offers the rest.
///
/// One row of the three-column plate, exactly as a field guide sets a section:
/// the point of S6 is that the body plans are comparable at a glance, and an
/// eleven-species family that floods the screen buries the next plan under a
/// scroll nobody performs at 05:40.
const int _cellsPerFamily = 3;

/// S6 — browse by shape.
///
/// A grid of black-on-white silhouettes grouped by family, with **the family
/// names in the reader's own language**. A Galician grid says *Vieiras*, not
/// *Pectinidae*: a mariscadora browsing by shape is looking for a scallop, and
/// the Latin is a label she has no reason to know.
///
/// **A printed plate, not a wall of cards.** The compartments sit on one sheet,
/// separated by hairline seams and closed top and bottom by a rule, which is
/// how a plate section is set. A boxed thumbnail per species reads as fifteen
/// photographs that failed to load — on the one screen whose whole claim is
/// that it is a printed reference.
class SpeciesBrowseScreen extends ConsumerWidget {
  /// Opens the grid.
  const SpeciesBrowseScreen({required this.onSpeciesChosen, super.key});

  /// Where a chosen species goes — S2.
  final void Function(int speciesId) onSpeciesChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<FamilyGroup>> groups = ref.watch(speciesBrowseViewModelProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<FamilyGroup>? families = groups.value;
    // The stamp counts what this page draws, and it is absent until there is a
    // page to count: a bar reading "0 species" while the read is still in
    // flight states something about the pack that nothing has yet looked at.
    final int? drawn = families?.fold<int>(
      0,
      (int sum, FamilyGroup family) => sum + family.species.length,
    );
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.browseByShapeTitle,
        sup: drawn == null ? null : l10n.browseSpeciesCount(drawn),
        // Absent on the Reference branch, where there is nowhere to go back to
        // and a dead chevron reads as a broken control.
        onBack: navigator.canPop() ? navigator.pop : null,
      ),
      body: SafeArea(
        // The bar has already taken the status bar; taking it twice prints the
        // first family's heading a band lower than the plate it heads.
        top: false,
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
          data: (List<FamilyGroup> loaded) => loaded.isEmpty
              ? LonjaEmptyState(
                  headline: l10n.browseNoSpeciesHeadline,
                  body: l10n.browseNoSpeciesBody,
                  primary: const SizedBox.shrink(),
                )
              : CustomScrollView(
                  slivers: <Widget>[
                    for (final (int index, FamilyGroup family) in loaded.indexed)
                      _FamilySliver(
                        family: family,
                        // The first plan opens the page; the rest are tightened
                        // against the plate above them, so a heading reads as
                        // belonging to the grid under it rather than floating
                        // between two.
                        opensThePage: index == 0,
                        onChosen: onSpeciesChosen,
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// One family heading, and the plate of silhouettes under it.
///
/// Stateful because the overflow compartment has somewhere to go: taking it
/// opens the rest of the family **in place**. A cell that counted species the
/// fisher could not then reach would be a grid hiding the pack behind a number.
class _FamilySliver extends StatefulWidget {
  const _FamilySliver({required this.family, required this.opensThePage, required this.onChosen});

  final FamilyGroup family;
  final bool opensThePage;
  final void Function(int speciesId) onChosen;

  @override
  State<_FamilySliver> createState() => _FamilySliverState();
}

class _FamilySliverState extends State<_FamilySliver> {
  bool _openedInFull = false;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<SpeciesTile> all = widget.family.species;
    final bool overflowing = !_openedInFull && all.length > _cellsPerFamily;
    // The overflow cell takes the last place in the row, so the row is always
    // whole and the figure on it is the truth about what is not drawn.
    final List<SpeciesTile> shown = overflowing ? all.take(_cellsPerFamily - 1).toList() : all;
    final int hidden = all.length - shown.length;

    return SliverMainAxisGroup(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.density.gutter,
              end: tokens.density.gutter,
              top: widget.opensThePage ? LonjaSpace.s6 : LonjaSpace.s5,
              bottom: LonjaSpace.s3,
            ),
            // The name as authored, in whatever case the content carries, and
            // the family's count beside it. An upper-casing transform here is a
            // silent no-op on Arabic, so a heading that relied on it would
            // shout VIEIRAS in Galician and be indistinguishable from body text
            // in `ar`. The hierarchy comes from the microLabel step and the
            // rule running to the margin instead.
            child: LonjaSectionLabel(
              text: l10n.browseFamilyHeading(widget.family.localisedFamilyName, all.length),
            ),
          ),
        ),
        // The plate is closed top and bottom, and the seams between its
        // compartments are the same hairline: one sheet ruled into cells, which
        // is what a field guide's plate section is.
        const SliverToBoxAdapter(child: LonjaRule.block()),
        DecoratedSliver(
          // The seam ink, showing through the one-pixel gaps the delegate
          // leaves between cells. Each cell paints its own paper over it.
          decoration: BoxDecoration(color: tokens.hairline),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              // Three, and not an extent that floats the column count with the
              // width: the grid is read as a plate of comparable shapes, and a
              // plan that runs three abreast on one phone and four on another
              // is a different plate each time.
              crossAxisCount: _cellsPerFamily,
              mainAxisSpacing: LonjaRules.rule,
              crossAxisSpacing: LonjaRules.rule,
              childAspectRatio: 0.82,
            ),
            itemCount: shown.length + (overflowing ? 1 : 0),
            itemBuilder: (BuildContext context, int index) => index < shown.length
                ? _SilhouetteTile(tile: shown[index], onChosen: widget.onChosen)
                : _MoreCell(
                    hidden: hidden,
                    family: widget.family.localisedFamilyName,
                    onOpen: () => setState(() => _openedInFull = true),
                  ),
          ),
        ),
        const SliverToBoxAdapter(child: LonjaRule.block()),
      ],
    );
  }
}

/// One species, as a silhouette with its two names under it.
class _SilhouetteTile extends StatelessWidget {
  const _SilhouetteTile({required this.tile, required this.onChosen});

  final SpeciesTile tile;
  final void Function(int speciesId) onChosen;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Semantics(
      button: true,
      label: tile.displayName,
      child: ColoredBox(
        color: tokens.surface,
        child: InkWell(
          onTap: () => onChosen(tile.speciesId),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.density.tapMin),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LonjaSpace.s1,
                vertical: LonjaSpace.s2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // Centred, because a plate compartment is read as a drawing
                // with a caption under it, not as a list row.
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // The drawing IS the tile: this grid is S6, the shape entry
                  // point, and a grid of empty boxes is a browse screen with
                  // nothing to browse. It shipped empty for one release because
                  // the resolver was unbuilt and `assets/sil/` was unbundled.
                  //
                  // On the paper directly, with no frame of its own: the seam
                  // between two compartments is the only boundary a plate has.
                  Expanded(
                    child: LonjaSilhouette(
                      assetKey: tile.silhouetteAsset,
                      semanticsLabel: l10n.speciesSilhouetteSemanticLabel,
                    ),
                  ),
                  Text(
                    tile.displayName,
                    style: type.uiSmall,
                    textAlign: TextAlign.center,
                    // A name, not legal prose: it wraps once and then gives
                    // way, because a caption that grows takes the drawing's
                    // room. `check_lonja_type.sh` check 7 guards the steps
                    // where truncation would hide a rule; this is not one.
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    // Set small and last: the one name that is the same
                    // everywhere, and the one Khalid does not read.
                    tile.scientificName,
                    style: type.binomial.copyWith(color: tokens.onSurfaceMuted),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The last compartment of a full row: what the plate is not showing yet.
class _MoreCell extends StatelessWidget {
  const _MoreCell({required this.hidden, required this.family, required this.onOpen});

  /// How many species of this family the grid has not drawn.
  final int hidden;

  /// The family's name in the reader's own language.
  final String family;

  /// Opens the rest of the family in place.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String phrase = l10n.browseMoreInFamily(family);

    return Semantics(
      button: true,
      label: phrase,
      child: ColoredBox(
        color: tokens.surface,
        child: InkWell(
          onTap: onOpen,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: tokens.density.tapMin),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LonjaSpace.s1,
                vertical: LonjaSpace.s2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    // A figure, so it takes the mono step and its tabular
                    // spine: it is read against the family count in the
                    // heading above it.
                    l10n.browseMoreCount(hidden),
                    style: type.datum,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: LonjaSpace.s1),
                  Text(
                    phrase,
                    style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
