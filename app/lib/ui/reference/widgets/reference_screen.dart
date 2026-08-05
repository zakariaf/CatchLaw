import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/family_group.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/reference/view_models/reference_hub_view_model.dart';
import 'package:catchlaw/ui/reference/widgets/penalties_screen.dart';
import 'package:catchlaw/ui/reference/widgets/reference_contents_line.dart';
import 'package:catchlaw/ui/reference/widgets/reference_entry.dart';
import 'package:catchlaw/ui/reference/widgets/reference_masthead.dart';
import 'package:catchlaw/ui/reference/widgets/reference_pack_block.dart';
import 'package:catchlaw/ui/reference/widgets/reference_section_screen.dart';
import 'package:catchlaw/ui/species/view_models/species_browse_view_model.dart';
import 'package:catchlaw/ui/species/widgets/species_browse_screen.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_screen.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S12 — the reference, set as a table of contents.
///
/// **A contents list, not a grid of cards.** This branch used to open straight
/// into S6, which is one section of the book standing in for the whole of it: a
/// fisher who came here for the penalties, the closed-season text or the
/// glossary was shown a plate of silhouettes and no way to anything else. The
/// hub answers *what is in this book* first, and the browse plate is one entry
/// in it.
///
/// **Seven of the eight entries are not printed in this release and say so.**
/// The alternative was to list only the one that works, which would state that
/// this book contains a plate of silhouettes and nothing more — a claim about
/// the product that is not true. `SPEC.md` §6 enumerates the sections; E15
/// sets them; until then each names itself, says what it will hold and opens a
/// page stating plainly that this copy does not print it.
class ReferenceScreen extends ConsumerWidget {
  /// Opens the reference.
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    // The place, for the mast's trailing block only. `null` is a real state —
    // a fisher who has not chosen a place yet still gets the contents, because
    // what this book HOLDS does not depend on where he is standing.
    final EvaluationScope? place = ref.watch(evaluationScopeProvider).value;
    final AsyncValue<List<HeldPack>> packs = ref.watch(heldPacksProvider);
    // The one entry with a figure behind it. Absent until the read returns:
    // a count of nothing printed while the query is still in flight would
    // state something about the pack that nothing has yet looked at.
    final List<FamilyGroup>? families = ref.watch(speciesBrowseViewModelProvider).value;
    final int? drawn = families?.fold<int>(
      0,
      (int sum, FamilyGroup family) => sum + family.species.length,
    );

    // Whether THIS copy sets the section, which for one entry depends on the
    // place. `ReferenceEntry.isPrinted` is a fact about the release; IV is a
    // fact about the release AND about whether a jurisdiction has been chosen,
    // because a penalty schedule belongs to an authority and there is no such
    // thing as one for nowhere.
    bool printed(ReferenceEntry entry) => switch (entry) {
      ReferenceEntry.penalties => place != null,
      _ => entry.isPrinted,
    };

    void openEntry(ReferenceEntry entry) {
      Navigator.of(context).push<void>(
        // Pushed onto the Reference branch's own Navigator, which is what keeps
        // the ledger strip lit on Reference while the section is on screen and
        // gives a second tap on that destination somewhere to pop back to.
        MaterialPageRoute<void>(
          builder: (BuildContext context) => switch (entry) {
            ReferenceEntry.plates => SpeciesBrowseScreen(
              onSpeciesChosen: (int speciesId) => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => SpeciesDetailScreen(speciesId: speciesId),
                ),
              ),
            ),
            // IV — S20. Set in this release, and the second entry of the eight
            // that opens something other than a statement that it is not.
            ReferenceEntry.penalties when place != null => PenaltiesScreen(
              jurisdictionCode: place.jurisdictionCode,
            ),
            _ => ReferenceSectionScreen(entry: entry),
          },
        ),
      );
    }

    String? figureFor(ReferenceEntry entry) => switch (entry) {
      // A real count from the pack, or nothing at all. An invented figure on a
      // page about what this device holds is the one thing this screen may not
      // print.
      ReferenceEntry.plates => drawn == null ? null : l10n.browseSpeciesCount(drawn),
      _ => printed(entry) ? null : l10n.referenceEntryNotPrinted,
    };

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ReferenceMasthead(
            // Cased at the call site on the LOCALISED word, never authored
            // shouting into the ARB — where it would shout in five locales and
            // do nothing in the sixth.
            wordmark: l10n.navReference.toUpperCase(), // lonja-type: ok
            subline: l10n.referenceContentsLabel,
            zoneCode: place?.zoneCode,
            packVersion: place?.packVersion,
          ),
          Expanded(
            // Slivers rather than a column in a scroll view: the contents and
            // the packs are both built lazily, and both live in ONE scrollable
            // so the page scrolls as one sheet.
            child: CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      tokens.density.gutter,
                      LonjaSpace.s4,
                      tokens.density.gutter,
                      LonjaSpace.s5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          l10n.referenceHubLede,
                          style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: LonjaSpace.s5),
                        LonjaSectionLabel(text: l10n.referenceContentsLabel),
                      ],
                    ),
                  ),
                ),
                // The rule that opens the contents, at the section weight.
                const SliverToBoxAdapter(child: LonjaRule.section()),
                SliverList.builder(
                  itemCount: ReferenceEntry.values.length,
                  itemBuilder: (BuildContext context, int index) {
                    final ReferenceEntry entry = ReferenceEntry.values[index];
                    return ReferenceContentsLine(
                      numeral: entry.numeral,
                      title: entry.title(l10n),
                      note: entry.note(l10n),
                      count: figureFor(entry),
                      onTap: () => openEntry(entry),
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      tokens.density.gutter,
                      LonjaSpace.s6,
                      tokens.density.gutter,
                      LonjaSpace.s4,
                    ),
                    child: LonjaSectionLabel(text: l10n.referenceHeldLabel),
                  ),
                ),
                ...packs.when(
                  // A page that says which branch it is before the read
                  // returns, and nothing where the blocks will be: a skeleton
                  // for two rows costs more than it tells.
                  loading: () => const <Widget>[SliverToBoxAdapter(child: SizedBox.shrink())],
                  // A failed read is not an empty shelf, and the two are not
                  // merged: what is printed is that this copy holds nothing
                  // that could be read, never that a place is unregulated.
                  error: (Object _, StackTrace _) => <Widget>[
                    SliverToBoxAdapter(child: _HeldEmpty(message: l10n.referenceHeldEmpty)),
                  ],
                  data: (List<HeldPack> held) => held.isEmpty
                      ? <Widget>[
                          SliverToBoxAdapter(child: _HeldEmpty(message: l10n.referenceHeldEmpty)),
                        ]
                      : <Widget>[
                          SliverList.builder(
                            itemCount: held.length,
                            itemBuilder: (BuildContext context, int index) => Padding(
                              padding: EdgeInsetsDirectional.only(
                                start: tokens.density.gutter,
                                end: tokens.density.gutter,
                                bottom: LonjaSpace.s4,
                              ),
                              child: ReferencePackBlock(pack: held[index]),
                            ),
                          ),
                        ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      tokens.density.gutter,
                      LonjaSpace.s2,
                      tokens.density.gutter,
                      LonjaSpace.s8,
                    ),
                    child: Text(
                      l10n.referenceHeldNote,
                      style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// What stands where the packs would be.
///
/// A sentence and not a blank band: a page that simply stops after a rubric is
/// indistinguishable from one that failed to load, which is the defect every
/// list on this product authors an empty state against.
class _HeldEmpty extends StatelessWidget {
  const _HeldEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.density.gutter),
      child: Text(message, style: type.legalSmall, textAlign: TextAlign.start),
    );
  }
}
