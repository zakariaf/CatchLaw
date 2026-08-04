import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/log/view_models/catch_log_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S8 — what this place has landed today.
///
/// **A tally, not a feed.** The rows are grouped by species in SQL, because the
/// question a fisher asks at the end of a tide is "how many hake do I have",
/// never "what was the eleventh thing I caught". A chronological list answers
/// the second question and makes him count the first by hand, on a wet phone.
///
/// **Counts, and no bag-limit judgement.** This screen states how many were
/// recorded and how many were kept, and stops. Whether that number breaks a
/// limit is a verdict, verdicts carry citations, and a citation belongs on the
/// result surface where the instrument can be named — a red number here would
/// be an uncited finding, which invariant 3 makes unrepresentable everywhere
/// else and which this screen must not smuggle back in.
///
/// **Everything stays on this phone.** No export, no share, no submit. `SPEC.md`
/// §5 refuses presenting the log as satisfying a declaration duty: it is a
/// private complement to the EU's `RecFishing` app, never a substitute.
class TodayScreen extends ConsumerWidget {
  /// Opens the day's tally.
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AsyncValue<List<SpeciesTallyEntry>> tally = ref.watch(dayTallyProvider);
    final hasPlace = ref.watch(activePlaceProvider) != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(tokens.density.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.todayHeadline, style: type.title),
              const SizedBox(height: LonjaSpace.s1),
              Text(
                ref.watch(todayIsoProvider),
                style: type.datum.copyWith(color: tokens.onSurfaceMuted),
              ),
              const SizedBox(height: LonjaSpace.s5),
              Expanded(
                // `.value`, not `.when`. A reload keeps the last rows on screen
                // instead of replacing them with a loading state: this provider
                // is rebuilt whenever the place stream re-emits, and `.when`
                // turned every one of those into a blank page — which is exactly
                // what a fisher saw after recording a fish that WAS written.
                child: switch (tally) {
                  AsyncError<List<SpeciesTallyEntry>>(:final Object error) when !tally.hasValue =>
                    Text('$error', style: type.legal),
                  AsyncValue<List<SpeciesTallyEntry>>(:final List<SpeciesTallyEntry>? value)
                      when value != null && value.isNotEmpty =>
                    ListView.separated(
                      itemCount: value.length,
                      separatorBuilder: (BuildContext _, int _) => const LonjaRule.row(),
                      itemBuilder: (BuildContext context, int i) => _TallyLine(entry: value[i]),
                    ),
                  AsyncValue<List<SpeciesTallyEntry>>(hasValue: true) => _TodayEmptyState(
                    hasPlace: hasPlace,
                  ),
                  // Before the first event only. The heading and date are already
                  // drawn above, so this is never a wholly blank screen.
                  _ => const SizedBox.shrink(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TallyLine extends ConsumerWidget {
  const _TallyLine({required this.entry});

  final SpeciesTallyEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final ({String jurisdiction, String zone})? place = ref.watch(activePlaceProvider);
    final String isoDay = ref.watch(todayIsoProvider);

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: tokens.density.rowHeight),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // The binomial, because the log denormalises it and never joins
            // back to reference.db for a name — which is what lets a record
            // written under one pack still read correctly under the next.
            Text(entry.scientificName, style: type.binomial),
            const SizedBox(height: LonjaSpace.s1),
            Text(
              l10n.todayCountKept(entry.count, entry.kept),
              style: type.datum.copyWith(color: tokens.onSurfaceMuted),
            ),
            if (place != null) ...<Widget>[
              const SizedBox(height: LonjaSpace.s2),
              // Two actions, both on the MOST RECENT row of this species.
              // "Remove one" undoes a double tap; clearing the whole species
              // would throw away a morning to fix a slip. "Kept" is authored,
              // never inferred from a verdict — a legal fish put back is still
              // a legal fish, and a log that decided that for him would be a
              // record about the rules rather than about his morning.
              Row(
                children: <Widget>[
                  LonjaButton.secondary(
                    label: l10n.todayMarkKept,
                    onPressed: () => ref
                        .read(catchLogRepositoryProvider)
                        .setLatestKept(
                          speciesId: entry.speciesId,
                          isoDay: isoDay,
                          jurisdictionCode: place.jurisdiction,
                          zoneCode: place.zone,
                          kept: true,
                        ),
                  ),
                  const SizedBox(width: LonjaSpace.s2),
                  LonjaButton.secondary(
                    label: l10n.todayUndoOne,
                    onPressed: () => ref
                        .read(catchLogRepositoryProvider)
                        .removeLatest(
                          speciesId: entry.speciesId,
                          isoDay: isoDay,
                          jurisdictionCode: place.jurisdiction,
                          zoneCode: place.zone,
                        ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState({required this.hasPlace});

  final bool hasPlace;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Two different emptinesses, and collapsing them would be the defect:
        // "nothing today" is a fact about the day, "no place set" is a fact
        // about the app, and only one of them is something he can act on.
        Text(hasPlace ? l10n.todayNothingRecorded : l10n.todayNoPlace, style: type.subtitle),
        const SizedBox(height: LonjaSpace.s2),
        Text(l10n.todayNothingBody, style: type.legal.copyWith(color: tokens.onSurfaceMuted)),
      ],
    );
  }
}
