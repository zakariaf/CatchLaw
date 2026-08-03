import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/ui/zones/view_models/zone_picker_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// S9 — where the fisher says where he is.
///
/// **The place is asked once and remembered.** §4.4: switching zone
/// re-evaluates instantly, and nothing about a verdict is recomputed from a
/// coordinate the app did not have.
///
/// A failed read is an ERROR and never an empty list. A picker showing no
/// countries because a file was locked reads as "this app ships nowhere", which
/// is a claim about the product rather than about the disk.
final class ZonePickerViewModel extends AsyncNotifier<ZonePickerState> {
  @override
  Future<ZonePickerState> build() async {
    final Result<List<Jurisdiction>> read = await ref
        .watch(referenceRepositoryProvider)
        .jurisdictions();
    final List<Jurisdiction> all = switch (read) {
      Ok<List<Jurisdiction>>(:final List<Jurisdiction> value) => value,
      Failure<List<Jurisdiction>>(:final Exception exception) => throw exception,
    };
    return ZonePickerState(all: all, zonesOfSelected: const <Zone>[]);
  }

  /// Narrows the region level to [iso2] and clears everything below it.
  void selectCountry(String iso2) {
    final ZonePickerState? current = state.value;
    if (current == null) return;
    state = AsyncData<ZonePickerState>(
      current.copyWith(
        selectedCountry: iso2,
        zonesOfSelected: const <Zone>[],
        clearJurisdiction: true,
        clearZone: true,
      ),
    );
  }

  /// Selects [code] and loads its zones.
  ///
  /// `void` and not `Future`, because a View may not await an intent
  /// (`FLUTTER_GUIDE.md` §1.2): the notifier owns its own asynchrony and the
  /// screen watches the state.
  void selectJurisdiction(String code) {
    final ZonePickerState? current = state.value;
    if (current == null) return;
    state = AsyncData<ZonePickerState>(
      current.copyWith(selectedJurisdictionCode: code, clearZone: true),
    );
    _loadZones(code);
  }

  Future<void> _loadZones(String code) async {
    final ZonePickerState? current = state.value;
    final Jurisdiction? j = current?.jurisdiction;
    if (current == null || j == null) return;

    final Result<List<Zone>> read = await ref.read(referenceRepositoryProvider).zones(j.id);
    // A zone read that failed leaves the jurisdiction selected and the sub-zone
    // level unoffered, which is the same state as a jurisdiction that printed
    // no coordinates. That is the honest merge: in both cases the app knows of
    // no subdivision it can stand behind.
    final List<Zone> zones = switch (read) {
      Ok<List<Zone>>(:final List<Zone> value) => value,
      Failure<List<Zone>>() => const <Zone>[],
    };
    if (state.value?.selectedJurisdictionCode != code) return;
    state = AsyncData<ZonePickerState>(state.value!.copyWith(zonesOfSelected: zones));
  }

  /// Selects a sub-zone.
  void selectZone(String code) {
    final ZonePickerState? current = state.value;
    if (current == null) return;
    state = AsyncData<ZonePickerState>(current.copyWith(selectedZoneCode: code));
  }

  /// Chooses salt or fresh, where the authority publishes both.
  void selectWater(WaterKind water) {
    final ZonePickerState? current = state.value;
    if (current == null) return;
    state = AsyncData<ZonePickerState>(current.copyWith(water: water));
  }

  /// Writes the place, so the next launch opens already knowing it.
  Future<void> confirmSelection() async {
    final ZonePickerState? current = state.value;
    if (current == null || !current.isComplete) return;
    // The write's own Result is inspected rather than dropped: a place that
    // silently failed to store is a picker the fisher fills in again on every
    // launch, and he will read that as the app forgetting rather than as a
    // disk refusing.
    final Result<void> written = await ref
        .read(settingsRepositoryProvider)
        .setActivePlace(
          jurisdictionCode: current.selectedJurisdictionCode,
          zoneCode: current.selectedZoneCode,
        );
    if (written case Failure<void>(:final Exception exception)) {
      state = AsyncError<ZonePickerState>(exception, StackTrace.current);
    }
  }
}

/// S9's state.
final AsyncNotifierProvider<ZonePickerViewModel, ZonePickerState> zonePickerViewModelProvider =
    AsyncNotifierProvider<ZonePickerViewModel, ZonePickerState>(ZonePickerViewModel.new);
