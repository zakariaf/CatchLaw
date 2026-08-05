import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
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
    final LonjaTypeScale type = LonjaType.of(context);

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
          height: tokens.density.rowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: LonjaSpace.s4),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              final RecentSpeciesEntry entry = entries[index];
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: LonjaSpace.s2),
                child: ConstrainedBox(
                  // One tap target per tile, at the density's own floor: these
                  // are the fastest path to a verdict and the one most likely
                  // to be taken with a wet glove.
                  constraints: BoxConstraints(minWidth: tokens.density.tapMin),
                  child: InkWell(
                    onTap: () => onSpeciesChosen(entry.speciesId),
                    child: Center(
                      child: Text(
                        entry.displayName,
                        style: type.ui.copyWith(color: tokens.onSurface),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
