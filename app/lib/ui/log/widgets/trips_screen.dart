import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/log/view_models/catch_log_providers.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S9 in `SPEC.md` §6, S10 in the mockup — the outings, and the one still
/// running.
///
/// **A landings ledger, read from the top down.** The mockup's order is the
/// order a printed ledger has and it is not decoration: the head says what this
/// page is and how many entries it holds, the months are ruled rubrics, the
/// entries hang under them newest first, and the one control sits at the foot
/// where a ledger's actions go. The screen this replaces opened with a primary
/// button, which put a control where the fisher's eye lands before he has seen
/// a single row.
///
/// **A trip is a bracket around a day, not a document.** It exists so the
/// catches of one tide group together; it has a start, an end and a place, and
/// nothing else is required of the fisher. Making him name it, or fill a form
/// before he can record a fish, is how a log stops being used at 05:40.
///
/// **Starting one closes whatever was open.** `TripDao.startTrip` does that in
/// the same transaction, because two open trips is a state with no correct
/// answer for "which one does this catch belong to" — and the phone that ends
/// up in that state is the one whose owner forgot to close yesterday's.
///
/// **Nothing leaves the phone.** No export, no share sheet, no submit. §5
/// refuses presenting the log as satisfying any declaration duty, so this
/// screen offers no affordance that could be read as filing one. The mockup's
/// foot carries an "Export as CSV to this phone" button and a note beneath it;
/// `SPEC.md` §10 admits `share_plus` through E17/T05 and §5 refuses the reading
/// that would make it a filing. The two have to be settled as a `D-n` before
/// either is built, so neither is built here.
class TripsScreen extends ConsumerWidget {
  /// Opens the outings.
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);
    final List<Trip> rows = trips.value ?? const <Trip>[];

    return Scaffold(
      // The band, not a `Text` in the body's first slot. It is the same chrome
      // every other head in this app is about to use, and it is what puts the
      // count stamp at the trailing margin where the mast-meta belongs.
      appBar: LonjaScreenBar(
        title: l10n.tripsHeadline,
        // Absent rather than "0 trips": a stamp counting nothing is a figure
        // that has to be read before it can be discarded.
        sup: rows.isEmpty ? null : l10n.tripsCountStamp(rows.length),
      ),
      body: SafeArea(
        top: false,
        child: switch (trips) {
          // `.hasValue` guards, exactly as S8 does: this provider re-emits
          // whenever the log is written, and a bare `.when` turns every write
          // into a blank page over rows that are still correct.
          AsyncError<List<Trip>>() when !trips.hasValue => Padding(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Text(l10n.tripsLoadFailed, style: type.legal),
          ),
          // Six ruled rows and no spinner. The screen this replaces rendered
          // `SizedBox.shrink()` here, which is the blank frame
          // `lonja-lists-and-tables` names as a defect: indistinguishable from
          // a crash on a phone with no signal.
          AsyncLoading<List<Trip>>() when !trips.hasValue => const LonjaListSkeleton(),
          _ => _TripsLedger(trips: rows),
        },
      ),
    );
  }
}

/// The ledger itself: the subline, the month rubrics, the entries, the foot.
///
/// One scroll view over the whole column, because the mockup's foot scrolls
/// with the last row rather than sitting pinned above it — a pinned control at
/// the bottom of a list is a control that covers the row under the thumb.
class _TripsLedger extends StatelessWidget {
  const _TripsLedger({required this.trips});

  /// Newest first, as `watchTrips` orders them.
  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final List<_LedgerEntry> entries = _ledger(context, trips);

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.density.gutter,
              end: tokens.density.gutter,
              top: LonjaSpace.s3,
            ),
            child: Text(
              l10n.tripsKeptHere,
              style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
        ),
        if (trips.isEmpty)
          const SliverToBoxAdapter(child: _TripsEmptyState())
        else
          SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int i) => switch (entries[i]) {
              _MonthHead(:final String label) => _MonthRubric(label: label),
              _TripEntry(:final Trip trip) => _TripLine(trip: trip),
            },
          ),
        const SliverToBoxAdapter(child: _TripsFoot()),
      ],
    );
  }
}

/// The rows flattened into what the ledger prints: a rubric whenever the month
/// changes, then the trips filed under it.
///
/// Built here rather than in the provider: which month a trip belongs to is a
/// question about the reader's calendar and his locale, and neither is
/// something `user.db` knows.
List<_LedgerEntry> _ledger(BuildContext context, List<Trip> trips) {
  final MaterialLocalizations dates = MaterialLocalizations.of(context);
  final entries = <_LedgerEntry>[];
  String? month;
  for (final trip in trips) {
    final DateTime? at = _instant(trip.startedAt);
    // An unparseable start gets no rubric rather than a wrong one. The row
    // itself still prints, because a trip the fisher recorded is a trip he can
    // see even when its stamp is malformed.
    final String label = at == null ? '' : dates.formatMonthYear(at);
    if (label.isNotEmpty && label != month) {
      month = label;
      entries.add(_MonthHead(label));
    }
    entries.add(_TripEntry(trip));
  }
  return entries;
}

/// An ISO instant as the fisher's own wall clock.
///
/// `toLocal()` is a no-op on the local-time strings `TripDao` is handed today
/// and the right conversion on a UTC one, so the ledger reads the same either
/// way — which matters because the day a trip is filed under must not move
/// when the storage format is tightened.
DateTime? _instant(String iso) => DateTime.tryParse(iso)?.toLocal();

/// One line of the flattened ledger.
sealed class _LedgerEntry {
  const _LedgerEntry();
}

/// A month, printed once above the trips that fall in it.
class _MonthHead extends _LedgerEntry {
  const _MonthHead(this.label);

  /// Already localised.
  final String label;
}

/// One outing.
class _TripEntry extends _LedgerEntry {
  const _TripEntry(this.trip);

  /// The outing.
  final Trip trip;
}

/// The gazette rubric over a month's entries, and the rule the entries hang
/// from.
///
/// Two rules, and the mockup has both: the section label's own hairline runs
/// out to the margin beside the word, and the `.rows` block underneath opens
/// with a full-bleed rule of its own. The second is what makes the first row
/// look filed rather than floating.
class _MonthRubric extends StatelessWidget {
  const _MonthRubric({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: LonjaSpace.s5),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.density.gutter),
          child: LonjaSectionLabel(text: label),
        ),
        const SizedBox(height: LonjaSpace.s3),
        const LonjaRule.block(),
      ],
    );
  }
}

/// One outing, as a ledger row.
///
/// **The date leads and the place follows.** The screen this replaces led with
/// the place at the serif sub-head step and demoted the dates to a mono line
/// under it — which reads as a list of harbours, when the question a fisher
/// brings to a ledger is always "which morning". The mockup inverts it, and so
/// does this: the date in the serif step, the place and the clock times in the
/// quiet sans line beneath.
///
/// **The open trip is marked twice and neither mark is a colour.** The word
/// beside the date says it in prose, the ruled stamp at the trailing edge says
/// it again in the mono step, and both survive greyscale, glare and a
/// screen reader (invariant 4).
///
/// Named _TripLine and not the obvious alternative: layering_test bans every
/// drift-shaped type name outside lib/data, because such a type escaping into
/// the UI is how a screen ends up bound to the database schema. The ban is a
/// grep, so a widget that merely LOOKS like one trips it — and the answer is to
/// rename the widget, never to loosen a rule protecting a real boundary.
///
/// A leading underscore does not exempt it: `\w` matches `_`, so `_TripRow`
/// trips the same grep `TripRow` does — and `TripRow` is a real drift row type
/// in lib/data. `Line` is the suffix this layer already uses for the same
/// shape, as LonjaSpeciesLine does.
class _TripLine extends StatelessWidget {
  const _TripLine({required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final MaterialLocalizations dates = MaterialLocalizations.of(context);
    final bool hours24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final DateTime? startedAt = _instant(trip.startedAt);
    final String? endedIso = trip.endedAt;
    final DateTime? endedAt = endedIso == null ? null : _instant(endedIso);
    final String place = trip.label ?? trip.zoneCode;

    String clock(DateTime? at, String fallback) => at == null
        ? fallback
        : dates.formatTimeOfDay(TimeOfDay.fromDateTime(at), alwaysUse24HourFormat: hours24);

    final String date = startedAt == null ? trip.startedAt : dates.formatMediumDate(startedAt);
    final String detail = endedIso == null
        ? l10n.tripsRowSpanOpen(place, clock(startedAt, trip.startedAt))
        : l10n.tripsRowSpan(place, clock(startedAt, trip.startedAt), clock(endedAt, endedIso));

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
                // Excluded rather than labelled: the glyph repeats what the row
                // already says in words, and a screen reader that announced
                // "boat" before every date would make the ledger slower to hear
                // than to read.
                ExcludeSemantics(
                  child: LonjaIcon(
                    LonjaIcons.boat,
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
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(date, style: type.subtitle, textAlign: TextAlign.start),
                          ),
                          if (trip.isOpen) ...<Widget>[
                            const SizedBox(width: LonjaSpace.s2),
                            Text(
                              l10n.tripsOpenMark,
                              style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: LonjaSpace.s1),
                      Text(
                        detail,
                        style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: LonjaSpace.s4),
                _TripEnd(trip: trip, startedAt: startedAt, endedAt: endedAt),
              ],
            ),
          ),
        ),
        // On every row and not only between them: the mockup rules each entry
        // off underneath, which is what makes the last one look filed rather
        // than cut off.
        const LonjaRule.row(),
      ],
    );
  }
}

/// The trailing slot: the open stamp, or how long the outing ran.
///
/// Never both and never neither-with-a-gap. The mockup gives this slot a
/// stamp, an elapsed figure or nothing, and each of the three is a different
/// fact about the same row.
class _TripEnd extends StatelessWidget {
  const _TripEnd({required this.trip, required this.startedAt, required this.endedAt});

  final Trip trip;

  final DateTime? startedAt;

  final DateTime? endedAt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    if (trip.isOpen) return _TripStamp(label: l10n.tripsOpenStamp);

    final DateTime? from = startedAt;
    final DateTime? to = endedAt;
    // No figure rather than a wrong one: a trip whose stamps do not parse, or
    // whose end precedes its start, has no elapsed time this screen can state
    // as a fact.
    if (from == null || to == null || to.isBefore(from)) return const SizedBox.shrink();
    final Duration ran = to.difference(from);

    return Text(
      l10n.tripsDuration(ran.inHours, ran.inMinutes.remainder(Duration.minutesPerHour)),
      style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
      textAlign: TextAlign.end,
    );
  }
}

/// A word inside a ruled frame — the mockup's `.pill`.
///
/// The frame carries [LonjaTokens.accent] and the word carries it too, which is
/// the only place on this screen a colour appears. It is never the signal: the
/// word inside the frame is, the inline marker beside the date repeats it, and
/// the frame itself reads as a frame in greyscale.
class _TripStamp extends StatelessWidget {
  const _TripStamp({required this.label});

  /// Already localised.
  final String label;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tokens.accent, width: LonjaRules.rule),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LonjaSpace.s1,
          vertical: LonjaSpace.s1,
        ),
        child: Text(
          label,
          style: type.articleNumber.copyWith(color: tokens.accent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// The foot of the column: the one control this screen has.
///
/// **At the foot, and never a primary.** The mockup puts an action here at
/// ghost weight and puts none at the head; `lonja-buttons` allows one primary
/// per screen and this one competes with nothing, so it takes the outline. The
/// screen this replaces opened with `LonjaButton.primary`, which is a control
/// standing where the first row should be.
class _TripsFoot extends ConsumerWidget {
  const _TripsFoot();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final Trip? open = ref.watch(openTripProvider).value;
    final EvaluationScope? place = ref.watch(evaluationScopeProvider).value;

    // No open trip and no place set: there is nothing to start and nothing to
    // end, and an empty ruled foot would read as a control that failed to draw.
    if (open == null && place == null) return const SizedBox(height: LonjaSpace.s6);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: tokens.density.gutter,
        end: tokens.density.gutter,
        top: LonjaSpace.s5,
        bottom: LonjaSpace.s6,
      ),
      child: open != null
          ? LonjaButton.secondary(
              label: l10n.tripsEnd,
              onPressed: () => ref
                  .read(catchLogRepositoryProvider)
                  .endTrip(open.id, DateTime.now().toIso8601String()),
            )
          : LonjaButton.secondary(
              label: l10n.tripsStart,
              onPressed: () => ref
                  .read(catchLogRepositoryProvider)
                  .startTrip(
                    startedAt: DateTime.now().toIso8601String(),
                    jurisdictionCode: place!.jurisdictionCode,
                    zoneCode: place.zoneCode,
                  ),
            ),
    );
  }
}

/// No outings yet.
///
/// The mockup authors no empty state for this screen, because its ledger is
/// full. This one is kept: `lonja-lists-and-tables` requires all four list
/// states, and a fisher on his first morning would otherwise meet a heading
/// with nothing under it.
class _TripsEmptyState extends StatelessWidget {
  const _TripsEmptyState();

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
          Text(l10n.tripsNone, style: type.subtitle, textAlign: TextAlign.start),
          const SizedBox(height: LonjaSpace.s2),
          Text(
            l10n.tripsNoneBody,
            style: type.legal.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
