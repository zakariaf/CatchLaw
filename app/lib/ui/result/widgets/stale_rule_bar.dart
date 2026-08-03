import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/view_models/stale_detail_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The ochre bar: the rules behind this answer passed their end date.
///
/// **Non-blocking, non-dismissable, and it changes nothing below it.** Invariant
/// 5: an expired ruleset is still evaluated and still shown, with every number
/// intact. The bar states a fact about the data; it does not hide the finding,
/// refuse to answer, disable a control or ask for a confirmation. A fisher in
/// front of an inspector needs the finding he has, not a modal telling him it
/// might be old.
///
/// **No retry and no refresh, and not as an omission.** There is no network in
/// this app by design, so there is nothing to fetch and nothing to try again —
/// an affordance offering either would be a lie about what the app can do.
class StaleRuleBar extends ConsumerWidget {
  /// States [stale], for [packId].
  const StaleRuleBar({required this.stale, required this.packId, super.key});

  /// The close control on the DETAIL. There is none on the bar.
  static const Key closeDetailKey = Key('stale-detail-close');

  /// The sentence and the provenance, already localised.
  final StaleDisplay stale;

  /// Which pack, so a closed detail is closed for that pack and no other.
  final String packId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final bool detailOpen = ref.watch(
      staleDetailSessionProvider.select((Set<String> closed) => !closed.contains(packId)),
    );

    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceSunk,
          border: BorderDirectional(
            start: BorderSide(color: tokens.verdictWarn, width: LonjaRules.stamp),
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LonjaSpace.s3,
            vertical: LonjaSpace.s2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // A glyph and a word beside the ochre. Amber alone is
                  // invisible in greyscale and to eight percent of readers, and
                  // ochre47 fails 4.5:1 as text — so the colour is the third
                  // signal here, never the first.
                  ExcludeSemantics(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: LonjaSpace.s2),
                      child: LonjaIcon(
                        LonjaIcons.openQuestion,
                        size: LonjaIconSize.caption,
                        color: tokens.verdictWarn,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      stale.sentence,
                      style: type.ui.copyWith(color: tokens.onSurface),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              if (detailOpen) _StaleRuleDetail(stale: stale, packId: packId),
            ],
          ),
        ),
      ),
    );
  }
}

/// The paragraph under the bar, which the reader may put away for this session.
class _StaleRuleDetail extends ConsumerWidget {
  const _StaleRuleDetail({required this.stale, required this.packId});

  final StaleDisplay stale;
  final String packId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: LonjaSpace.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            stale.provenance,
            style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            // The secondary rung, not a raw Material button: the ladder does
            // the ranking, and this is the least important control on a screen
            // whose most important thing is a sentence about the law.
            child: LonjaButton.secondary(
              key: StaleRuleBar.closeDetailKey,
              label: l10n.staleDetailClose,
              onPressed: () => ref.read(staleDetailSessionProvider.notifier).close(packId),
            ),
          ),
        ],
      ),
    );
  }
}
