import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/log/view_models/catch_log_providers.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S9 — the outings, and the one still running.
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
/// screen offers no affordance that could be read as filing one.
class TripsScreen extends ConsumerWidget {
  /// Opens the outings.
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AsyncValue<List<Trip>> trips = ref.watch(tripsProvider);
    final Trip? open = ref.watch(openTripProvider).value;
    final EvaluationScope? place = ref.watch(evaluationScopeProvider).value;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(tokens.density.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.tripsHeadline, style: type.title),
              const SizedBox(height: LonjaSpace.s4),
              if (open != null)
                LonjaButton.secondary(
                  label: l10n.tripsEnd,
                  onPressed: () => ref
                      .read(catchLogRepositoryProvider)
                      .endTrip(open.id, DateTime.now().toIso8601String()),
                )
              else if (place != null)
                LonjaButton.primary(
                  label: l10n.tripsStart,
                  onPressed: () => ref
                      .read(catchLogRepositoryProvider)
                      .startTrip(
                        startedAt: DateTime.now().toIso8601String(),
                        jurisdictionCode: place.jurisdictionCode,
                        zoneCode: place.zoneCode,
                      ),
                ),
              const SizedBox(height: LonjaSpace.s5),
              Expanded(
                child: trips.when(
                  loading: () => const SizedBox.shrink(),
                  error: (Object e, StackTrace _) => Text('$e', style: type.legal),
                  data: (List<Trip> rows) => rows.isEmpty
                      ? _TripsEmptyState()
                      : ListView.separated(
                          itemCount: rows.length,
                          separatorBuilder: (BuildContext _, int _) => const LonjaRule.row(),
                          itemBuilder: (BuildContext context, int i) => _TripLine(trip: rows[i]),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One outing.
///
/// Named _TripLine and not the obvious alternative: layering_test bans every
/// drift-shaped type name outside lib/data, because such a type escaping into
/// the UI is how a screen ends up bound to the database schema. The ban is a
/// grep, so a widget that merely LOOKS like one trips it — and the answer is to
/// rename the widget, never to loosen a rule protecting a real boundary.
class _TripLine extends StatelessWidget {
  const _TripLine({required this.trip});

  final Trip trip;

  /// The date part of an ISO instant.
  ///
  /// Substring rather than `DateFormat`: the stored value is canonical ISO-8601
  /// and the day is its first ten characters in every locale. Parsing it to
  /// re-render a date the fisher already reads as a date buys nothing and adds
  /// a timezone to a value that has none.
  static String _day(String iso) => iso.length >= 10 ? iso.substring(0, 10) : iso;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final String? ended = trip.endedAt;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: tokens.density.rowHeight),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(trip.label ?? trip.zoneCode, style: type.subtitle),
            const SizedBox(height: LonjaSpace.s1),
            Text(
              ended == null
                  ? l10n.tripsRunning(_day(trip.startedAt))
                  : l10n.tripsEnded(_day(trip.startedAt), _day(ended)),
              style: type.datum.copyWith(color: tokens.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _TripsEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(l10n.tripsNone, style: type.subtitle),
        const SizedBox(height: LonjaSpace.s2),
        Text(l10n.tripsNoneBody, style: type.legal.copyWith(color: tokens.onSurfaceMuted)),
      ],
    );
  }
}
