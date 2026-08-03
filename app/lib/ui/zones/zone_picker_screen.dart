import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/zones/view_models/zone_picker_state.dart';
import 'package:catchlaw/ui/zones/view_models/zone_picker_view_model.dart';
import 'package:catchlaw/ui/zones/widgets/zone_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S9 — where the fisher says where he is.
///
/// **Three levels, read from two tables.** `SPEC.md` §7.1 has no `country`
/// table, so a country is `jurisdiction.country_iso2` grouped, the region is
/// the jurisdiction row, and the sub-zone is its `zone` rows — offered only
/// where the pack printed coordinates.
///
/// Asked once and remembered. The place decides which instrument applies, so a
/// fisher who never answers it gets no verdict at all — which is why E12/T05
/// makes this the first thing a new install shows.
class ZonePickerScreen extends ConsumerWidget {
  /// Opens the picker.
  const ZonePickerScreen({this.onConfirmed, super.key});

  /// The route name E12 registers.
  static const String routeName = 'zone-picker';

  /// Called once the place is stored.
  final VoidCallback? onConfirmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final AsyncValue<ZonePickerState> picker = ref.watch(zonePickerViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.zonePickerTitle, textAlign: TextAlign.start)),
      body: SafeArea(
        child: picker.when(
          // A skeleton and not a spinner. `lonja-buttons` bans the spinner
          // outright: a rotating disc is an app telling the reader it is busy,
          // and this screen's whole register is a printed page that either has
          // the list or does not.
          loading: () => const LonjaListSkeleton(rows: 4),
          // Said plainly, and never as an empty list: a picker showing no
          // countries because a file was locked reads as a claim that this app
          // ships nowhere.
          error: (Object error, StackTrace _) => Padding(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Text(l10n.zonePickerLoadFailed, textAlign: TextAlign.start),
          ),
          data: (ZonePickerState state) => _Levels(state: state, onConfirmed: onConfirmed),
        ),
      ),
    );
  }
}

class _Levels extends ConsumerWidget {
  const _Levels({required this.state, required this.onConfirmed});

  final ZonePickerState state;
  final VoidCallback? onConfirmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ZonePickerViewModel picker = ref.read(zonePickerViewModelProvider.notifier);
    final bool countryIsEmpty = state.selectedCountry != null && state.jurisdictions.isEmpty;

    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ZoneLevel(
                  label: l10n.zoneLevelCountry,
                  children: <Widget>[
                    for (final String code in state.countries)
                      ZoneLine(
                        label: l10n.countryName(code),
                        selected: code == state.selectedCountry,
                        onTap: () => picker.selectCountry(code),
                      ),
                  ],
                ),
                if (countryIsEmpty)
                  // Two sentences and no action, rather than `LonjaEmptyState`
                  // and an invented one: the way out of this state is to tap a
                  // different country in the list still above it, and a button
                  // that only scrolls is a button that promises a route.
                  Padding(
                    padding: const EdgeInsetsDirectional.all(LonjaSpace.s4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(l10n.zonePickerEmptyHeadline, textAlign: TextAlign.start),
                        const SizedBox(height: LonjaSpace.s1),
                        // The second sentence is the point: an absence in the
                        // pack is not an absence of law.
                        Text(l10n.zonePickerEmptyBody, textAlign: TextAlign.start),
                      ],
                    ),
                  ),
                if (state.jurisdictions.isNotEmpty)
                  ZoneLevel(
                    label: l10n.zoneLevelRegion,
                    children: <Widget>[
                      for (final Jurisdiction j in state.jurisdictions)
                        ZoneLine(
                          label: j.code,
                          selected: j.code == state.selectedJurisdictionCode,
                          onTap: () => picker.selectJurisdiction(j.code),
                        ),
                    ],
                  ),
                // Absent, not disabled, where the pack printed no coordinates:
                // there is no subdivision the app can stand behind, and an
                // empty level would invite the fisher to look for one.
                if (state.offersSubZone)
                  ZoneLevel(
                    label: l10n.zoneLevelSubZone,
                    children: <Widget>[
                      for (final Zone z in state.subZones)
                        ZoneLine(
                          label: z.code,
                          selected: z.code == state.selectedZoneCode,
                          onTap: () => picker.selectZone(z.code),
                        ),
                    ],
                  ),
                if (state.offersWaterChoice)
                  ZoneLevel(
                    label: l10n.zoneLevelRegion,
                    children: <Widget>[
                      ZoneLine(
                        label: l10n.zoneWaterSalt,
                        selected: state.water == WaterKind.salt,
                        onTap: () => picker.selectWater(WaterKind.salt),
                      ),
                      ZoneLine(
                        label: l10n.zoneWaterFresh,
                        selected: state.water == WaterKind.fresh,
                        onTap: () => picker.selectWater(WaterKind.fresh),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.all(LonjaTokens.of(context).density.gutter),
          child: LonjaButton.primary(
            label: l10n.zonePickerConfirm,
            onPressed: state.isComplete
                ? () async {
                    await picker.confirmSelection();
                    onConfirmed?.call();
                  }
                : null,
          ),
        ),
      ],
    );
  }
}
