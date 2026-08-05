import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_branch_masthead.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/log/view_models/catch_log_providers.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_rule_facts_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S8 — what this place has landed today.
///
/// **A tally, not a feed.** The rows are grouped by species in SQL, because the
/// question a fisher asks at the end of a tide is "how many hake do I have",
/// never "what was the eleventh thing I caught". A chronological list answers
/// the second question and makes him count the first by hand, on a wet phone.
///
/// **The order is the printed one, and it is not decoration.** The mast says
/// which day and which place; the summary sheet totals the day in three ruled
/// lines; the rubric opens the species; the entries hang under it; the one
/// control sits at the foot. The screen this replaces led with a serif heading
/// and an ISO date, then put two buttons inside every row — so the visual
/// weight of a tally was its controls rather than its figures.
///
/// **Counts, and no bag-limit judgement.** This screen states how many were
/// recorded and how many were kept, and stops. Whether that number breaks a
/// limit is a verdict, verdicts carry citations, and a citation belongs on the
/// result surface where the instrument can be named — a red number here would
/// be an uncited finding, which invariant 3 makes unrepresentable everywhere
/// else and which this screen must not smuggle back in.
///
/// **What the mockup prints and this does not, and why.** Its summary sheet
/// carries a vessel limit and a gear line; its rows carry a local name, a
/// silhouette, a per-species limit, a minimum size and a method; its foot
/// carries a bag-limit citation and a PROTECTED stamp. Every one of those is a
/// fact about the law or about the species, `SpeciesTallyEntry` carries the
/// binomial and two integers, and `user.db` cannot join `reference.db` to find
/// the rest. Printing a limit this screen cannot cite is the one thing it may
/// not do, so it prints what the log knows and no more.
///
/// **Everything stays on this phone.** No export, no share, no submit. `SPEC.md`
/// §5 refuses presenting the log as satisfying a declaration duty: it is a
/// private complement to the EU's `RecFishing` app, never a substitute.
class TodayScreen extends ConsumerWidget {
  /// Opens the day's tally.
  const TodayScreen({super.key});

  /// The sheet's own scroll view, for tests that drive it.
  static const Key scrollKey = Key('today-scroll');

  /// The [index]th box of an entry's struck tally, struck or blank.
  ///
  /// Keyed so the non-colour redundancy can be asserted as a fact about the
  /// tree rather than as a pixel: a test that could only compare colours would
  /// pass on a build where the boxes had stopped being drawn at all.
  static Key pipKey(int index, {required bool struck}) =>
      ValueKey<String>('today-pip-$index-${struck ? 'struck' : 'blank'}');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AsyncValue<List<SpeciesTallyEntry>> tally = ref.watch(dayTallyProvider);
    final hasPlace = ref.watch(activePlaceProvider) != null;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // The mast, and not a `Text` in the body's first slot: it is the head
          // of a branch, so it carries the wordmark, the day and the place
          // above a 2 pt rule, which is what makes the sheet under it read as a
          // page rather than as a column of widgets.
          const _TodayMast(),
          Expanded(
            // `.value`, not `.when`. A reload keeps the last rows on screen
            // instead of replacing them with a loading state: this provider
            // is rebuilt whenever the place stream re-emits, and `.when`
            // turned every one of those into a blank page — which is exactly
            // what a fisher saw after recording a fish that WAS written.
            child: switch (tally) {
              // The failure stated in the app's own words, never the exception.
              // A raw `'$error'` on a wet phone at 05:40 is a sentence written
              // for a developer, printed for a fisher.
              AsyncError<List<SpeciesTallyEntry>>() when !tally.hasValue => Padding(
                padding: EdgeInsetsDirectional.all(tokens.density.gutter),
                child: Text(l10n.todayLoadFailed, style: type.legal, textAlign: TextAlign.start),
              ),
              // Ruled rows and no spinner. The screen this replaces rendered
              // `SizedBox.shrink()` before the first event, which is the blank
              // frame `lonja-lists-and-tables` names as a defect: on a phone
              // with no signal it is indistinguishable from a crash.
              AsyncLoading<List<SpeciesTallyEntry>>() when !tally.hasValue =>
                const LonjaListSkeleton(rows: 3),
              _ => _TodaySheet(
                entries: tally.value ?? const <SpeciesTallyEntry>[],
                hasPlace: hasPlace,
              ),
            },
          ),
        ],
      ),
    );
  }
}

/// The mast: the branch's name, the trip still running, the day and the place.
///
/// A `ConsumerWidget` of its own rather than three `ref.watch` calls in the
/// screen: the trip re-emits on every start and end, and a mast that read it
/// through the screen's `ref` would rebuild the tally list beneath it for a
/// clock time in the sub-line.
class _TodayMast extends ConsumerWidget {
  const _TodayMast();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MaterialLocalizations dates = MaterialLocalizations.of(context);
    final bool hours24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final String isoDay = ref.watch(todayIsoProvider);
    final ({String jurisdiction, String zone})? place = ref.watch(activePlaceProvider);
    final Trip? open = ref.watch(openTripProvider).value;

    // The stored day as the reader's own calendar. An unparseable stamp prints
    // as it was stored rather than as a wrong date: the mast is where a fisher
    // checks WHICH morning he is looking at.
    final DateTime? day = DateTime.tryParse(isoDay);
    final String stamp = day == null
        ? isoDay
        // Cased at the call site on the LOCALISED date, never authored
        // shouting: the transform is a silent no-op on Arabic, where the mono
        // face and the trailing margin do the work instead.
        : dates.formatMediumDate(day).toUpperCase(); // lonja-type: ok

    final String? startedIso = open?.startedAt;
    final DateTime? startedAt = startedIso == null
        ? null
        : DateTime.tryParse(startedIso)?.toLocal();
    // Two states and never one blank line. "Trip open since 04:55" and "No trip
    // open" are different facts about the morning, and a mast that printed
    // nothing for the second would read as a sub-line that failed to draw.
    final String subline = startedIso == null
        ? l10n.todayNoTripOpen
        : l10n.todayTripOpenSince(
            startedAt == null
                ? startedIso
                : dates.formatTimeOfDay(
                    TimeOfDay.fromDateTime(startedAt),
                    alwaysUse24HourFormat: hours24,
                  ),
          );

    return LonjaBranchMasthead(
      wordmark: l10n.todayHeadline.toUpperCase(), // lonja-type: ok
      subline: subline,
      // The day, then the place. A tally with no place stamped on it is a
      // tally of somebody else's morning, and the code is printed as authored
      // because it is what he compares against the printed pack.
      meta: <String>[stamp, if (place != null) place.zone],
    );
  }
}

/// The sheet under the mast: the day's totals, the species, the foot.
///
/// One scroll view over the whole column, because the foot scrolls with the
/// last row rather than sitting pinned above it — a pinned control at the
/// bottom of a list is a control that covers the row under the thumb.
class _TodaySheet extends StatelessWidget {
  const _TodaySheet({required this.entries, required this.hasPlace});

  /// One line per species, as `watchDay` groups them.
  final List<SpeciesTallyEntry> entries;

  /// Whether a place has been chosen, which is a different emptiness.
  final bool hasPlace;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final Locale locale = Localizations.localeOf(context);
    // Constructed at the point of use and never retained: a `NumberFormat` held
    // in a field captures its symbols at construction and survives every later
    // `applyNumeralSystem` call, so a fisher who switches the numeral lever
    // would see the sheet keep the digits it was built with.
    String figure(int n) => numberFormatFor(locale).format(n);

    final int recorded = entries.fold<int>(
      0,
      (int sum, SpeciesTallyEntry entry) => sum + entry.count,
    );
    final int kept = entries.fold<int>(0, (int sum, SpeciesTallyEntry entry) => sum + entry.kept);

    return CustomScrollView(
      key: TodayScreen.scrollKey,
      slivers: <Widget>[
        if (entries.isEmpty)
          SliverToBoxAdapter(child: _TodayEmptyState(hasPlace: hasPlace))
        else ...<Widget>[
          // The ruled summary sheet, first and directly under the mast — the
          // same two-column device the result surface sets its numbers in, so
          // a figure reads the same way wherever this app prints one.
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: tokens.density.gutter,
                end: tokens.density.gutter,
                top: LonjaSpace.s4,
              ),
              child: ResultRuleFactsTable(
                facts: <RuleFact>[
                  RuleFact(label: l10n.todaySummaryRecorded, value: figure(recorded)),
                  RuleFact(
                    label: l10n.todaySummaryKept,
                    value: l10n.todayKeptOfCount(figure(kept), figure(recorded)),
                  ),
                  RuleFact(label: l10n.todaySummarySpecies, value: figure(entries.length)),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: _TallyRubric()),
          // Lazy, and the one thing on this page that grows: a morning is a
          // handful of species and a season is not.
          SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int i) => _TallyLine(entry: entries[i]),
          ),
        ],
        const SliverToBoxAdapter(child: _TodayFoot()),
      ],
    );
  }
}

/// The rubric over the species, and the rule they hang from.
///
/// Two rules, and the mockup has both: the section label's own hairline runs
/// out to the margin beside the word, and the block underneath opens with a
/// full-bleed rule of its own. The second is what makes the first entry look
/// filed rather than floating.
class _TallyRubric extends StatelessWidget {
  const _TallyRubric();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: LonjaSpace.s5),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.density.gutter),
          child: LonjaSectionLabel(
            // Cased at the call site on the localised word: the ARB holds one
            // wording per key, and the same words are set sentence-case
            // elsewhere.
            text: l10n.todayBySpeciesLabel.toUpperCase(), // lonja-type: ok
          ),
        ),
        const SizedBox(height: LonjaSpace.s3),
        const LonjaRule.block(),
      ],
    );
  }
}

/// One species' contribution to the day, as a ledger entry.
///
/// **One horizontal line, and no control on it.** The mockup's entry is a
/// glyph, a name block and a figure block, in that order across the row; the
/// screen this replaces stacked a name over a count over a full-width pair of
/// buttons, so four species filled the page with eight controls and the tally
/// itself was the smallest thing on it.
///
/// **The count is stated twice and neither statement is a colour.** The figures
/// say it in the mono step and the pips print it as a struck tally, which is
/// invariant 4 in one row: the state survives greyscale, glare and a cracked
/// screen (`SPEC.md` §4 — the pips are the caption's own example).
///
/// **The binomial leads, because it is what the log stores.** The mockup keys
/// its entries on the local name with the Arabic beside it; `catches` carries
/// the binomial denormalised, and that is precisely what lets a record written
/// under one pack still read correctly under the next. A local name here would
/// have to be joined out of `reference.db`, which is a separate, replaceable
/// file this repository is not allowed to join against.
///
/// Named `_TallyLine` and not the obvious alternative: `layering_test` bans
/// every drift-shaped type name outside `lib/data`, the ban is a grep, and `\w`
/// matches `_` — so a private `_TallyRow` trips it exactly as `TallyRow` does.
/// `Line` is the suffix this layer already uses for the shape, as
/// `LonjaSpeciesLine` does.
class _TallyLine extends StatelessWidget {
  const _TallyLine({required this.entry});

  final SpeciesTallyEntry entry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.density.rowHeight),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.density.gutter,
              vertical: LonjaSpace.s3,
            ),
            child: Row(
              children: <Widget>[
                // The species art's slot, carrying the family glyph until a
                // silhouette can be resolved: `SpeciesTallyEntry` has no
                // `silhouette_asset`, and inventing one per binomial is a
                // drawing of the wrong fish. Excluded from semantics because
                // the name beside it already says which species this is.
                ExcludeSemantics(
                  child: LonjaIcon(
                    LonjaIcons.fish,
                    size: LonjaIconSize.ui,
                    color: tokens.onSurfaceMuted,
                  ),
                ),
                const SizedBox(width: LonjaSpace.s4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(entry.scientificName, style: type.binomial, textAlign: TextAlign.start),
                      const SizedBox(height: LonjaSpace.s1),
                      Text(
                        l10n.todayCountKept(entry.count, entry.kept),
                        // The mono step, because the line is two figures and a
                        // separator: tabular digits are what let four entries
                        // be compared down the column rather than read one at
                        // a time.
                        style: type.citation.copyWith(color: tokens.onSurfaceMuted),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: LonjaSpace.s4),
                _TallyPips(count: entry.count, filled: entry.kept),
              ],
            ),
          ),
        ),
        // On every entry and not only between them: the mockup rules each one
        // off underneath, which is what makes the last look filed rather than
        // cut off.
        const LonjaRule.row(),
      ],
    );
  }
}

/// The struck tally: one box per fish recorded, filled for each one kept.
///
/// **A redundancy, never the signal.** The figures beside it state the same two
/// numbers in words, so a reader who cannot resolve eight small boxes at arm's
/// length has lost nothing — which is the only condition under which a
/// graphical count is allowed to exist here at all.
///
/// **It stops rather than shrinking.** Past [_max] the boxes would be narrower
/// than the rule that draws them and the strip would read as a smudge, so a
/// long morning prints the figures alone. A tally that becomes unreadable at
/// the moment the day gets good is worse than no tally.
class _TallyPips extends StatelessWidget {
  const _TallyPips({required this.count, required this.filled});

  /// The widest strip that still reads at arm's length on a 360 dp screen.
  static const int _max = 8;

  /// How many were recorded.
  final int count;

  /// How many of them were kept.
  final int filled;

  @override
  Widget build(BuildContext context) {
    if (count > _max) return const SizedBox.shrink();
    final LonjaTokens tokens = LonjaTokens.of(context);

    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (int i = 0; i < count; i++)
            Padding(
              key: TodayScreen.pipKey(i, struck: i < filled),
              padding: const EdgeInsetsDirectional.only(start: LonjaSpace.s1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: tokens.onSurface, width: LonjaRules.rule),
                  color: i < filled ? tokens.onSurface : null,
                ),
                child: const SizedBox(width: LonjaSpace.s2, height: LonjaSpace.s3),
              ),
            ),
        ],
      ),
    );
  }
}

/// The foot of the sheet: the one control this screen has.
///
/// **One, and never a primary.** The mockup's foot pairs "Record another" with
/// "End trip"; recording happens on a species page, where the length, the
/// method and the verdict that the record denormalises all exist, and a
/// "Record another" here would open a screen that could not answer any of them.
/// So the pair reduces to the control this branch can honestly wire, at the
/// outline weight `lonja-buttons` gives a control that competes with nothing.
///
/// Absent, not disabled, when no trip is running: a dead button at the foot of
/// a tally is a control that reads as broken rather than as inapplicable.
class _TodayFoot extends ConsumerWidget {
  const _TodayFoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final Trip? open = ref.watch(openTripProvider).value;

    if (open == null) return const SizedBox(height: LonjaSpace.s6);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: tokens.density.gutter,
        end: tokens.density.gutter,
        top: LonjaSpace.s5,
        bottom: LonjaSpace.s6,
      ),
      child: LonjaButton.secondary(
        label: l10n.tripsEnd,
        onPressed: () =>
            ref.read(catchLogRepositoryProvider).endTrip(open.id, DateTime.now().toIso8601String()),
      ),
    );
  }
}

/// Nothing recorded here today.
///
/// The mockup authors no empty state for S8, because its tally is full. This
/// one is kept: `lonja-lists-and-tables` requires all four list states, and a
/// fisher on his first morning would otherwise meet a mast with a blank page
/// under it.
class _TodayEmptyState extends StatelessWidget {
  const _TodayEmptyState({required this.hasPlace});

  final bool hasPlace;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: tokens.density.gutter,
        end: tokens.density.gutter,
        top: LonjaSpace.s5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const LonjaRule.block(),
          const SizedBox(height: LonjaSpace.s4),
          // Two different emptinesses, and collapsing them would be the defect:
          // "nothing today" is a fact about the day, "no place set" is a fact
          // about the app, and only one of them is something he can act on.
          Text(
            hasPlace ? l10n.todayNothingRecorded : l10n.todayNoPlace,
            style: type.subtitle,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: LonjaSpace.s2),
          Text(
            l10n.todayNothingBody,
            style: type.legal.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
