import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:catchlaw/ui/zones/widgets/zone_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The places he fishes, one tap from active.
///
/// **One tap, and the verdict behind it changes.** §4.4: switching zone
/// re-evaluates instantly. Nothing here navigates — the place is written, the
/// scope stream re-emits, and whatever is on screen re-answers.
///
/// Absent when he has saved none. An empty strip at the top of the picker is
/// chrome that teaches him a feature exists before he has any use for it.
class SavedZoneStrip extends ConsumerWidget {
  /// The saved places, above the country level.
  const SavedZoneStrip({required this.onSelected, super.key});

  /// Makes a saved place active.
  final void Function(SavedZone zone) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<SavedZone> saved = ref
        .watch(savedZonesProvider)
        .maybeWhen(data: (List<SavedZone> z) => z, orElse: () => const <SavedZone>[]);
    if (saved.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final SavedZone zone in saved)
          ZoneLine(
            // His own name for it when he gave one; the code when he did not.
            // A generated label would be the app naming a place it has never
            // been.
            label: zone.label ?? zone.zoneCode,
            selected: false,
            onTap: () => onSelected(zone),
          ),
        const SizedBox(height: LonjaSpace.s5),
      ],
    );
  }
}
