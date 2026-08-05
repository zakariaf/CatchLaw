import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_silhouette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The species he has opened HERE before, six at most.
///
/// **Recency is per zone**, which is what "here" carries: the one unusual fish
/// he looked up in another place does not reshuffle this one, and a fisher
/// working two banks gets two different strips.
///
/// Absent when it is empty. A labelled empty strip is chrome that teaches him a
/// feature exists before he has any use for it, and it costs him the vertical
/// space the search box wants.
class RecentsStrip extends ConsumerWidget {
  /// The recents for [place].
  const RecentsStrip({
    required this.place,
    required this.onSpeciesChosen,
    this.whenEmpty,
    super.key,
  });

  /// Where he is.
  final EvaluationScope place;

  /// Opens one.
  final void Function(int speciesId) onSpeciesChosen;

  /// What stands here on a first launch in this place.
  ///
  /// Supplied by the caller rather than built in, because the strip is a strip
  /// and the sentence belongs to the screen it sits on.
  final Widget? whenEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    final AsyncValue<List<RecentSpeciesEntry>> recents = ref.watch(
      recentsProvider((jurisdictionCode: place.jurisdictionCode, zoneCode: place.zoneCode)),
    );
    final List<RecentSpeciesEntry> entries = recents.value ?? const <RecentSpeciesEntry>[];
    // The strip's empty state is its ABSENCE, and the gate's hatch is used
    // rather than worked around: this is a strip above a screen that has its
    // own authored empty state, and a labelled empty strip would tell the
    // fisher a feature exists before he has any use for it while taking the
    // vertical space the search box wants. // lonja-list-ok
    if (entries.isEmpty) return whenEmpty ?? const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // The label and its rule stop at the gutter, like every other ruled
        // label on the page — it was running to the bare edge of the glass.
        // The air above it is what separates the strip from the entry line now
        // sitting over it.
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: tokens.density.gutter,
            end: tokens.density.gutter,
            top: LonjaSpace.s5,
            bottom: LonjaSpace.s3,
          ),
          child: LonjaSectionLabel(text: l10n.checkRecentsLabel),
        ),
        SizedBox(
          // The TILE class, and not a row: the mockup's `.rec` is a ruled card
          // 126 × 118 in glove mode, drawn as a card because the art has to be
          // recognisable at arm's length before the name under it is read.
          height: tokens.density.tileHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.only(
              start: tokens.density.gutter,
              end: tokens.density.gutter,
            ),
            itemCount: entries.length,
            separatorBuilder: (BuildContext context, int _) =>
                SizedBox(width: tokens.density.tapGap),
            itemBuilder: (BuildContext context, int index) =>
                _RecentTile(entry: entries[index], onTap: onSpeciesChosen),
          ),
        ),
      ],
    );
  }
}

/// One tile: the drawing over the name, framed, on sunk stock.
///
/// A widget class and never a `Widget _buildTile()` helper: a helper has no
/// `BuildContext` of its own, so the `LonjaTokens.of(context)` inside it would
/// register the STRIP's element as the dependent and rebuild every tile on a
/// theme change, a density toggle or an RTL flip (`FLUTTER_GUIDE.md` §8.1
/// mechanism 2).
class _RecentTile extends StatelessWidget {
  const _RecentTile({required this.entry, required this.onTap});

  final RecentSpeciesEntry entry;
  final void Function(int speciesId) onTap;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Semantics(
      button: true,
      label: entry.displayName,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onTap(entry.speciesId),
        child: SizedBox(
          width: tokens.density.tileWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.surfaceSunk,
              border: Border.all(color: tokens.hairline, width: LonjaRules.rule),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(LonjaSpace.s2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // The art takes whatever the name leaves, so the tile grows
                  // its drawing with the density instead of carrying a second
                  // number that drifts from the tile's own height.
                  Expanded(
                    child: LonjaSilhouette(
                      assetKey: entry.silhouetteAsset,
                      semanticsLabel: entry.displayName,
                    ),
                  ),
                  const SizedBox(height: LonjaSpace.s1),
                  Text(
                    entry.displayName,
                    style: type.uiSmall.copyWith(color: tokens.onSurface),
                    textAlign: TextAlign.start,
                    maxLines: 2,
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

/// The recents for one place, six at most.
final recentsProvider = StreamProvider.autoDispose
    .family<List<RecentSpeciesEntry>, ({String jurisdictionCode, String zoneCode})>(
      (Ref ref, ({String jurisdictionCode, String zoneCode}) place) => ref
          .watch(speciesRecentRepositoryProvider)
          .watchRecents(
            jurisdictionCode: place.jurisdictionCode,
            zoneCode: place.zoneCode,
            limit: 6,
          ),
    );
