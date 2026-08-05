import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/services/reference_install_progress.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/species_search_state.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/ui/bootstrap/first_run_screen.dart';
import 'package:catchlaw/ui/check/widgets/check_actions.dart';
import 'package:catchlaw/ui/check/widgets/check_empty_state.dart';
import 'package:catchlaw/ui/check/widgets/check_place_chips.dart';
import 'package:catchlaw/ui/check/widgets/recents_strip.dart';
import 'package:catchlaw/ui/core/ui/lonja_masthead.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/identify/widgets/identify_screen.dart';
import 'package:catchlaw/ui/species/view_models/species_search_view_model.dart';
import 'package:catchlaw/ui/species/widgets/species_browse_screen.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_screen.dart';
import 'package:catchlaw/ui/species/widgets/species_search_field.dart';
import 'package:catchlaw/ui/species/widgets/species_search_results.dart';
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
      loading: () => const _WhileThePlaceResolves(),
      // A place that could not be read is not a place that was never chosen,
      // and the picker states the difference.
      error: (Object error, StackTrace _) => const ZonePickerScreen(),
      data: (EvaluationScope? place) =>
          place == null ? const ZonePickerScreen() : _Check(place: place),
    );
  }
}

/// What the Check branch draws before its stream has answered.
///
/// **The first-run takeover is keyed on bytes, not on `loading`.** The place
/// stream is unresolved for a moment on EVERY launch, and a screen reading
/// *Setting out the rule book* on the second one would be a sentence about an
/// extraction that is not happening. `ReferenceInstaller` reports nothing at all
/// when the marker already names this build, so this stays blank until the first
/// chunk lands — which is also the frame at which the wait becomes long enough
/// to be worth explaining.
///
/// The listenable is subscribed here rather than read: the extraction reports
/// once per 64 KiB and the place stream emits once at the end, so a widget that
/// only rebuilt with the stream would show whichever figure happened to be
/// current on the frame it mounted.
class _WhileThePlaceResolves extends ConsumerWidget {
  const _WhileThePlaceResolves();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReferenceInstallReporter reporter = ref.watch(referenceInstallReporterProvider);
    return ValueListenableBuilder<ReferenceInstallProgress>(
      valueListenable: reporter.listenable,
      builder: (BuildContext context, ReferenceInstallProgress progress, Widget? _) =>
          progress.isInstalling ? const FirstRunScreen() : const Scaffold(body: SizedBox.shrink()),
    );
  }
}

/// Check, once the app knows where he is.
///
/// **The order is the mockup's, top to bottom:** the mast, the chips band that
/// stamps which printing this is and offers another place, the entry line, what
/// he opened here before, and the two other ways in. It ran short and out of
/// order — the strip above the box, the checked date hanging off the mast, and
/// the shape grid and the key reachable only by first typing a name that
/// matched nothing.
class _Check extends ConsumerWidget {
  const _Check({required this.place});

  final EvaluationScope place;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Two selectors and not the whole state: the band below the field swaps
    // between the strip and the results on the FIRST keystroke and on no
    // other, and a screen that watched the list itself would rebuild the
    // masthead on every one of them.
    final bool isPackExpired = ref.watch(
      speciesSearchViewModelProvider.select((SpeciesSearchState state) => state.isPackExpired),
    );
    final bool isSearching = ref.watch(
      speciesSearchViewModelProvider.select((SpeciesSearchState state) => state.query.isNotEmpty),
    );

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

    void identify() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => IdentifyScreen(onSpeciesChosen: open),
      ),
    );

    void browseByShape() => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SpeciesBrowseScreen(onSpeciesChosen: open),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LonjaMasthead(
              place: place.zoneCode,
              // The mast's own hand at the trailing margin: WHICH PRINTING of
              // the rules this device is holding. Two devices held side by side
              // at the quay differ in exactly this line.
              //
              // The block's other line is the zone code, and it is left empty
              // on purpose: until the place above resolves to a display name,
              // the code IS the place line, and a mast that printed
              // `rias-baixas` twice would read as two different facts.
              packVersion: place.packVersion,
            ),
            // Under the mast and above everything it qualifies. Non-blocking:
            // invariant 5 evaluates and shows an expired pack anyway, and the
            // bar says so rather than standing in front of the answer.
            if (isPackExpired) LonjaStaleBar(message: l10n.rulePackExpired),
            CheckPlaceChips(
              checkedOn: place.checkedOn,
              onChangePlace: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      ZonePickerScreen(onConfirmed: () => Navigator.of(context).pop()),
                ),
              ),
            ),
            const SpeciesSearchField(),
            Expanded(
              child: isSearching
                  ? SpeciesSearchResults(
                      onSpeciesChosen: open,
                      // S7's key, reachable at last. It was a no-op for a
                      // release — the entry point existed so the layout was
                      // the one that ships, and it led nowhere, which is
                      // exactly the dead end §4.3 wants three ways out of.
                      onIdentify: identify,
                      onBrowseByShape: browseByShape,
                    )
                  : SingleChildScrollView(
                      // The strip and the two rungs under it are the whole
                      // band while nothing is typed. Scrollable rather than
                      // clipped: at a large textScaler, in a locale whose
                      // labels run long, the second rung would otherwise fall
                      // off the bottom of the glass.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          RecentsStrip(
                            place: place,
                            onSpeciesChosen: open,
                            // Absent when he has recents, authored when he does
                            // not: a first launch that showed a blank band would
                            // read as a strip that failed to load.
                            whenEmpty: const CheckEmptyState(),
                          ),
                          // Standing, and not behind a search that found
                          // nothing: a fisher who cannot name the fish cannot
                          // type it either, and both of these were reachable
                          // only by typing.
                          CheckActions(onBrowseByShape: browseByShape, onIdentify: identify),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
