import 'package:catchlaw/data/services/reference_install_progress.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/bootstrap/view_models/first_run_stage.dart';
import 'package:catchlaw/ui/bootstrap/widgets/first_run_manifest.dart';
import 'package:catchlaw/ui/bootstrap/widgets/first_run_progress_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_silhouette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S-first-run — the one-time extraction, while it is running.
///
/// **A state, not a gate.** `main()` is synchronous and nothing is awaited
/// before `runApp` (`catchlaw-conventions-index` rule 8), so this is not a
/// splash standing in front of the app: `reference.db` is extracted inside the
/// `LazyDatabase` callback on the first QUERY, and the Check branch — which is
/// what asked the question — draws this while its own stream has not answered.
/// A route pushed ahead of the tree would put the whole app behind the slowest
/// thing in it, which is the failure §13 budgets against.
///
/// **It never says `downloading`.** The payload shipped inside the binary and
/// there is no network code path to fail; a wait that used the wrong verb would
/// teach the one thing about this product that must not be learned wrongly, at
/// the one moment a reader is most likely to believe it. The footer states the
/// three refusals of `SPEC.md` §5 for the same reason.
///
/// The mast here is deliberately **not** `LonjaMasthead`: that one names the
/// place the answers below it are for, and at first launch there is no place,
/// no zone chip, no pack currency and nothing to change. What it carries
/// instead is the wordmark and a mono note saying how often this happens.
class FirstRunScreen extends ConsumerWidget {
  /// Draws whatever the installer has most recently reported.
  const FirstRunScreen({super.key});

  /// The engraved line art at the head of the screen.
  ///
  /// A silhouette and never a plate: a plate is a historical engraving and
  /// ships only when its illustrator's death year clears the longest term among
  /// the bundled jurisdictions, which today is none of them.
  static const String kSilhouetteAsset = 'sil/epinephelus-marginatus.svg';

  /// How tall that art is drawn — two steps of the 4pt spine, edge to edge.
  static const double kSilhouetteHeight = LonjaSpace.s8 + LonjaSpace.s6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ReferenceInstallReporter reporter = ref.watch(referenceInstallReporterProvider);
    return ValueListenableBuilder<ReferenceInstallProgress>(
      valueListenable: reporter.listenable,
      builder: (BuildContext context, ReferenceInstallProgress progress, Widget? _) =>
          _FirstRun(progress: progress),
    );
  }
}

/// The screen, once it has a report to draw.
class _FirstRun extends StatelessWidget {
  const _FirstRun({required this.progress});

  final ReferenceInstallProgress progress;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Scaffold(
      body: SafeArea(
        // The footer sinks to the foot of a tall device while everything above
        // it stays top-anchored, and the band between the two scrolls rather
        // than overflowing at 200 % text scale.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _OfflineBadgeLine(),
            const _FirstRunMast(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.density.gutter),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const _FirstRunPlate(),
                    const SizedBox(height: LonjaSpace.s5),
                    const _FirstRunHeadline(),
                    const SizedBox(height: LonjaSpace.s5),
                    _FirstRunProgress(progress: progress),
                    const SizedBox(height: LonjaSpace.s6),
                    const _InstallingLabel(),
                    const SizedBox(height: LonjaSpace.s3),
                    FirstRunManifest(progress: progress),
                    const SizedBox(height: LonjaSpace.s4),
                    _FirstRunNote(progress: progress),
                    const SizedBox(height: LonjaSpace.s5),
                  ],
                ),
              ),
            ),
            const _FirstRunFooter(),
          ],
        ),
      ),
    );
  }
}

/// The boxed offline badge, on the only screen that carries it.
///
/// The mockup draws it inside the device's own status bar beside a clock and a
/// battery. The clock and the battery belong to the OS and are not redrawn
/// here — a painted status bar is a lie about the device — but the badge is the
/// app's own statement and is the one line on this screen that answers the
/// question a progress bar always raises.
class _OfflineBadgeLine extends StatelessWidget {
  const _OfflineBadgeLine();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: tokens.density.gutter,
        end: tokens.density.gutter,
        top: LonjaSpace.s2,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: tokens.hairline, width: LonjaRules.rule),
            borderRadius: LonjaRadii.none,
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(LonjaSpace.s1),
            child: Text(
              l10n.firstRunOfflineBadge.toUpperCase(), // lonja-type: ok
              style: type.microLabel.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.end,
            ),
          ),
        ),
      ),
    );
  }
}

/// The first-run mast: the wordmark, its strapline, and how often this happens.
class _FirstRunMast extends StatelessWidget {
  const _FirstRunMast();

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
        bottom: LonjaSpace.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      // The product name, uncased in the ARB because it is a
                      // name; the mast is where it is set in capitals.
                      l10n.appTitle.toUpperCase(), // lonja-type: ok
                      style: type.subtitle,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: LonjaSpace.s1),
                    Text(
                      l10n.firstRunTagline,
                      style: type.binomial.copyWith(color: tokens.onSurfaceMuted),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: LonjaSpace.s4),
              const _MastMeta(),
            ],
          ),
          const SizedBox(height: LonjaSpace.s4),
          // The heavy rule, not the hairline: this closes a masthead rather
          // than separating two rows of a table.
          const LonjaRule.section(),
        ],
      ),
    );
  }
}

/// The two stacked mono lines at the trailing edge of the mast.
///
/// A widget class rather than a helper method: a helper has no `BuildContext`
/// of its own, so the token read inside it would register the mast's element as
/// the dependent and rebuild the whole band on a theme or density change.
class _MastMeta extends StatelessWidget {
  const _MastMeta();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final TextStyle style = type.articleNumber.copyWith(color: tokens.onSurfaceMuted);

    return Column(
      // Resolved against the ambient direction, so the block sits at the
      // trailing margin in `ar` as it does in `en`.
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          l10n.firstRunMetaFirstRun.toUpperCase(), // lonja-type: ok
          style: style,
          textAlign: TextAlign.end,
        ),
        const SizedBox(height: LonjaSpace.s1),
        Text(
          l10n.firstRunMetaOnceOnly.toUpperCase(), // lonja-type: ok
          style: style,
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}

/// The engraved line art, drawn edge to edge with no frame and no plate number.
class _FirstRunPlate extends StatelessWidget {
  const _FirstRunPlate();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: LonjaSpace.s4),
      child: LonjaSilhouette(
        assetKey: FirstRunScreen.kSilhouetteAsset,
        semanticsLabel: l10n.firstRunSilhouetteLabel,
        height: FirstRunScreen.kSilhouetteHeight,
      ),
    );
  }
}

/// The headline and the lede under it.
class _FirstRunHeadline extends StatelessWidget {
  const _FirstRunHeadline();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(l10n.firstRunHeadline, style: type.title, textAlign: TextAlign.start),
        ),
        const SizedBox(height: LonjaSpace.s2),
        Text(
          l10n.firstRunLede,
          style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}

/// The determinate bar and the two figures under it.
class _FirstRunProgress extends StatelessWidget {
  const _FirstRunProgress({required this.progress});

  final ReferenceInstallProgress progress;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final Locale locale = Localizations.localeOf(context);
    // Not bidi-isolated, and deliberately: the figure and its sign are one
    // run with no strong character between them, and the per-cent glyph is
    // authored per locale so `ar` sets U+066A on the side its readers expect.
    final String percent = l10n.firstRunProgressPercent(
      numberFormatFor(locale).format((progress.fraction * 100).round()),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Semantics(
          label: l10n.firstRunHeadline,
          value: percent,
          // The bar is a drawing of the two figures below it and has nothing
          // of its own to say; announcing its rules and its fill would read
          // the same fact three times.
          child: ExcludeSemantics(child: FirstRunProgressBar(fraction: progress.fraction)),
        ),
        const SizedBox(height: LonjaSpace.s2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.firstRunProgressBytes(
                  numberFormatFor(locale).format(kilobytesOf(progress.bytesWritten)),
                  numberFormatFor(locale).format(kilobytesOf(progress.bytesTotal)),
                ),
                style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: LonjaSpace.s2),
            Text(percent, style: type.articleNumber, textAlign: TextAlign.end),
          ],
        ),
      ],
    );
  }
}

/// The section label over the manifest.
class _InstallingLabel extends StatelessWidget {
  const _InstallingLabel();

  @override
  Widget build(BuildContext context) => LonjaSectionLabel(
    text: AppLocalizations.of(context).firstRunSectionInstalling.toUpperCase(), // lonja-type: ok
  );
}

/// The estimate, and the sentence that says why there is nothing to fail.
class _FirstRunNote extends StatelessWidget {
  const _FirstRunNote({required this.progress});

  final ReferenceInstallProgress progress;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final TextStyle style = type.uiSmall.copyWith(color: tokens.onSurfaceMuted);
    final Duration? remaining = progress.remaining;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Absent until the stream has a rate to divide by. An estimate printed
        // before there is one is a number the device invented, and this screen
        // prints no number it did not measure.
        if (remaining != null) ...<Widget>[
          Text(
            l10n.firstRunTimeRemaining(
              numberFormatFor(Localizations.localeOf(context)).format(_secondsCeiling(remaining)),
            ),
            style: style,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: LonjaSpace.s1),
        ],
        Text(l10n.firstRunNoDownload, style: style, textAlign: TextAlign.start),
      ],
    );
  }

  /// Rounded up, so a wait of 400 ms prints one second rather than none.
  int _secondsCeiling(Duration remaining) => (remaining.inMilliseconds / 1000).ceil();
}

/// The pinned footer: a hairline, and the three refusals under it.
class _FirstRunFooter extends StatelessWidget {
  const _FirstRunFooter();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: tokens.density.gutter,
        end: tokens.density.gutter,
        bottom: LonjaSpace.s5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const LonjaRule.block(),
          const SizedBox(height: LonjaSpace.s3),
          Text(
            l10n.firstRunFooterNote,
            style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
