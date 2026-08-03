import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/ui/check/widgets/recents_strip.dart';
import 'package:catchlaw/ui/core/ui/lonja_masthead.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_screen.dart';
import 'package:catchlaw/ui/species/widgets/species_search_screen.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:catchlaw/ui/zones/zone_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S1 — the front door.
///
/// **The place first, and only once.** A fisher with no place stored is shown
/// S9 rather than a search box: every answer behind this screen is answered
/// against a jurisdiction, and a species picked before one is chosen is a tap
/// that leads nowhere. E12/T05 owns that state; this is where it is decided.
///
/// It opens straight to the search, with no splash, no login, no onboarding and
/// no what's-new. §3 budgets five seconds from pocket to verdict, and every
/// screen between the two spends it.
class CheckScreen extends ConsumerWidget {
  /// Opens Check.
  const CheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<EvaluationScope?> scope = ref.watch(evaluationScopeProvider);

    return scope.when(
      loading: () => const Scaffold(body: SizedBox.shrink()),
      // A place that could not be read is not a place that was never chosen,
      // and the picker states the difference.
      error: (Object error, StackTrace _) => const ZonePickerScreen(),
      data: (EvaluationScope? place) =>
          place == null ? const ZonePickerScreen() : _Check(place: place),
    );
  }
}

/// Check, once the app knows where he is.
class _Check extends ConsumerWidget {
  const _Check({required this.place});

  final EvaluationScope place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void open(int speciesId) {
      // Recorded before the push, so the strip the fisher comes back to
      // already has the fish he just opened. Fire-and-forget on purpose: a
      // recents row that failed to write must not stand between him and the
      // rules.
      ref
          .read(speciesRecentRepositoryProvider)
          .recordUse(
            speciesId,
            jurisdictionCode: place.jurisdictionCode,
            zoneCode: place.zoneCode,
            at: place.checkedOn,
          )
          .ignore();
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => SpeciesDetailScreen(speciesId: speciesId),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            LonjaMasthead(
              place: place.zoneCode,
              checkedOn: place.checkedOn,
              onChangePlace: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      ZonePickerScreen(onConfirmed: () => Navigator.of(context).pop()),
                ),
              ),
            ),
            RecentsStrip(place: place, onSpeciesChosen: open),
            Expanded(
              child: SpeciesSearchScreen(
                onSpeciesChosen: open,
                // S7's key is E14's and S6's shapes are E08's. Both entry
                // points exist so the layout is the one that ships; the one
                // that is built is reachable.
                onIdentify: () {},
                onBrowseByShape: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
