import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:flutter/material.dart';

/// The six species this zone has actually seen.
///
/// **Per zone, and ordered by frequency before recency.** The six species a
/// fisher catches should stay at the top of the screen; a strip ordered only by
/// recency is reshuffled by the one unusual fish he looked up last week. And
/// the six of the Ría de Arousa are not the six of Ras Al Khaimah, so mixing
/// zones would put a fish that does not live here one tap from his thumb.
class RecentsStrip extends StatelessWidget {
  /// Offers [entries].
  const RecentsStrip({required this.entries, required this.onOpenSpecies, super.key});

  /// Most used first.
  final List<RecentSpeciesEntry> entries;

  /// Opens a species' account.
  final void Function(int speciesId) onOpenSpecies;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LonjaSectionLabel(text: l10n.recentsStripLabel),
        const SizedBox(height: LonjaSpace.s2),
        if (entries.isEmpty)
          const _RecentsEmptyState()
        else
          SizedBox(
            height: tokens.density.rowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: entries.length,
              separatorBuilder: (BuildContext context, int _) =>
                  SizedBox(width: tokens.density.tapGap),
              itemBuilder: (BuildContext context, int index) =>
                  _RecentChip(entry: entries[index], onOpen: onOpenSpecies),
            ),
          ),
      ],
    );
  }
}

/// What will fill the strip.
///
/// A named widget and not an inline branch, because `check_lonja_lists.sh`
/// rule 6 is that a blank screen is a defect — and a branch nobody can point at
/// is a branch that gets deleted in a refactor. It describes the MECHANISM
/// rather than telling the reader to go and use it.
class _RecentsEmptyState extends StatelessWidget {
  const _RecentsEmptyState();

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    return Text(
      AppLocalizations.of(context).recentsEmptyBody,
      style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
      textAlign: TextAlign.start,
    );
  }
}

/// One species, one tap.
class _RecentChip extends StatelessWidget {
  const _RecentChip({required this.entry, required this.onOpen});

  final RecentSpeciesEntry entry;
  final void Function(int speciesId) onOpen;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Semantics(
      button: true,
      label: entry.displayName,
      child: InkWell(
        onTap: () => onOpen(entry.speciesId),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: tokens.density.tapMin,
            minHeight: tokens.density.tapMin,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.surfaceSunk,
              // The chip is the one place LonjaRadii.hair is spent: it is a
              // chip, and the ceiling exists so that spending it stays a
              // decision rather than a habit.
              borderRadius: LonjaRadii.hair,
              border: Border.all(color: tokens.hairline, width: LonjaRules.rule),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: LonjaSpace.s3,
                vertical: LonjaSpace.s2,
              ),
              child: Center(
                child: Text(
                  entry.displayName,
                  style: type.uiSmall,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
