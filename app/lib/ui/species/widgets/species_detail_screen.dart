import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/species_account.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_plate.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/species/view_models/species_detail_view_model.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_placeholders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S2 — the species account, static half.
///
/// **The local name is large and the binomial is last**, and the ordering is
/// the whole design. Khalid does not read Latin: a header that led with
/// *Epinephelus coioides* would put the one string he cannot check at the top
/// of a screen he has ten seconds for. The other-locale names sit under it,
/// small, because a fisher working a Spanish market off a Galician boat needs
/// both words.
///
/// E09 fills the measurement slot and E10 the verdict; both are named, empty
/// slots here rather than absent, so the page's shape is the one that ships.
class SpeciesDetailScreen extends ConsumerWidget {
  /// Opens the account for [speciesId].
  const SpeciesDetailScreen({required this.speciesId, super.key});

  /// Which species.
  final int speciesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<SpeciesAccount> account = ref.watch(speciesAccountProvider(speciesId));
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Scaffold(
      body: SafeArea(
        child: account.when(
          loading: () => const LonjaListSkeleton(rows: 3),
          error: (Object error, StackTrace _) => Padding(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Text('$error', textAlign: TextAlign.start),
          ),
          // A scrolling COLUMN and not a ListView: this page is a fixed handful
          // of blocks, not a list, and `check_lonja_lists.sh` fails an eager
          // list constructor because a list is the thing that grows. The one
          // repeating part — the other-locale names — is bounded by the six
          // shipped locales.
          data: (SpeciesAccount value) => SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SpeciesHeader(account: value),
                const SizedBox(height: LonjaSpace.s4),
                _SpeciesArtPanel(account: value),
                const SizedBox(height: LonjaSpace.s5),
                if (value.otherNames.isNotEmpty) _OtherNamesBlock(names: value.otherNames),
                const SizedBox(height: LonjaSpace.s5),
                const SpeciesMeasurementSlot(),
                const SizedBox(height: LonjaSpace.s4),
                const SpeciesVerdictSlot(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The local name large, the family, then the binomial.
class _SpeciesHeader extends StatelessWidget {
  const _SpeciesHeader({required this.account});

  final SpeciesAccount account;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(account.primaryName, style: type.display, textAlign: TextAlign.start),
        const SizedBox(height: LonjaSpace.s1),
        Text(
          '${l10n.speciesFamilyLabel} ${account.familyName}',
          style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: LonjaSpace.s1),
        // Last, and in the app's only italic. The binomial is the one name that
        // is the same everywhere and the one a reader cannot check.
        Text(
          account.scientificName,
          style: type.binomial.copyWith(color: tokens.onSurfaceMuted),
          textAlign: TextAlign.start,
        ),
        if (account.isProtectedAnywhere) ...<Widget>[
          const SizedBox(height: LonjaSpace.s2),
          // A statement about where a protection exists, not a verdict about
          // this catch: the page is reached before a zone is known, so it says
          // SOMEWHERE. E10's finding is what states the rule with its citation.
          Text(
            l10n.speciesProtectedAnywhere,
            style: type.datum.copyWith(color: tokens.onSurface),
            textAlign: TextAlign.start,
          ),
        ],
      ],
    );
  }
}

/// The plate, or the silhouette when no plate cleared.
class _SpeciesArtPanel extends StatelessWidget {
  const _SpeciesArtPanel({required this.account});

  final SpeciesAccount account;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    // `null` is the NORMAL case: a plate ships only when its illustrator died
    // long enough ago to clear the longest term among the four jurisdictions
    // this app bundles, and an unattributable plate is dropped rather than
    // bundled pending.
    return Semantics(
      image: true,
      label: account.plateAsset == null ? null : l10n.speciesPlateSemanticLabel,
      child: LonjaPlateSurface(
        child: SizedBox(
          height: 160,
          child: DecoratedBox(
            decoration: BoxDecoration(color: tokens.surface),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// Every other name the pack carries.
class _OtherNamesBlock extends StatelessWidget {
  const _OtherNamesBlock({required this.names});

  final List<SpeciesName> names;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LonjaSectionLabel(text: l10n.speciesOtherNames),
        const SizedBox(height: LonjaSpace.s2),
        for (final SpeciesName name in names) ...<Widget>[
          Text(
            name.regionHint == null ? name.name : '${name.name} (${name.regionHint})',
            style: type.legal.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: LonjaSpace.s1),
        ],
        const LonjaRule.row(),
      ],
    );
  }
}
