import 'package:catchlaw/data/services/reference_install_progress.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/bootstrap/view_models/first_run_stage.dart';
import 'package:catchlaw/ui/core/format/bidi_isolate.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/widgets.dart';

/// What the extraction is writing, itemised as a ruled two-column sheet.
///
/// **The bar says how far; this says how far through what.** A determinate bar
/// on its own answers one question and raises another — a fisher who can see
/// 68 % and nothing else cannot tell a slow install from a stalled one, and the
/// sheet under it is what turns a number into a description.
///
/// A `Column` of private line widgets, not a Material `DataTable`: the table
/// brings physical, non-directional padding and a fixed line height that breaks
/// at 200 % text scale, and a ruled sheet wants neither.
class FirstRunManifest extends StatelessWidget {
  /// Itemises [progress] across [FirstRunStage.values].
  const FirstRunManifest({required this.progress, super.key});

  /// The latest report from the installer.
  final ReferenceInstallProgress progress;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      // The sheet OPENS on a heavier rule and separates on hairlines, so the
      // first line does not read as a continuation of the label above it.
      const LonjaRule.section(),
      for (final FirstRunStage stage in FirstRunStage.values) ...<Widget>[
        _ManifestLine(stage: stage, progress: progress),
        const LonjaRule.row(),
      ],
    ],
  );
}

/// One stage, and where the stream has left it.
class _ManifestLine extends StatelessWidget {
  const _ManifestLine({required this.stage, required this.progress});

  final FirstRunStage stage;

  final ReferenceInstallProgress progress;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final FirstRunStageState state = stage.stateIn(progress);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 44 against 56, the ruled sheet's own proportion — the same one the
          // result screen's fact sheet uses, so two ruled sheets in one app do
          // not set to two different measures.
          Expanded(
            flex: 44,
            child: Text(
              // Cased at the call site, never in the ARB: the ARB holds one
              // wording per key, and the same four words are sentence case in
              // E18's account of what the pack contains.
              _label(l10n).toUpperCase(), // lonja-type: ok
              style: type.microLabel.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: LonjaSpace.s2),
          Expanded(
            flex: 56,
            child: _StageValue(stage: stage, state: state, progress: progress),
          ),
        ],
      ),
    );
  }

  String _label(AppLocalizations l10n) => switch (stage) {
    FirstRunStage.rulePack => l10n.firstRunStageRulePack,
    FirstRunStage.legalText => l10n.firstRunStageLegalText,
    FirstRunStage.speciesPlates => l10n.firstRunStagePlates,
    FirstRunStage.glossary => l10n.firstRunStageGlossary,
  };
}

/// The trailing cell: a figure and a marker, or a state in words.
///
/// **The three states differ by wording, never by colour.** A finished line
/// carries a number and a word; a running line carries a different word; a line
/// the stream has not reached carries a third. Nothing here is a tick, a tint or
/// a spinner, so the sheet reads the same in greyscale, in sunlight and to a
/// screen reader.
class _StageValue extends StatelessWidget {
  const _StageValue({required this.stage, required this.state, required this.progress});

  final FirstRunStage stage;

  final FirstRunStageState state;

  final ReferenceInstallProgress progress;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return switch (state) {
      FirstRunStageState.pending => Text(
        l10n.firstRunStagePending,
        style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
        textAlign: TextAlign.end,
      ),
      FirstRunStageState.running => Text(
        l10n.firstRunStageInProgress,
        style: type.legalSmall,
        textAlign: TextAlign.end,
      ),
      FirstRunStageState.done => Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              // Isolated, because a Latin-digit run inside an Arabic line is
              // reordered without it — and the figure is the half of this cell
              // a reader would compare against another device.
              text: isolate(
                numberFormatFor(
                  Localizations.localeOf(context),
                ).format(kilobytesOf(stage.shareOf(progress.bytesTotal))),
              ),
              // Tabular figures, from the ramp: four lines of kilobytes only
              // align on a shared spine, and a column that does not align is
              // read at arm's length in glare as noise.
              style: type.datum,
            ),
            const TextSpan(text: ' '),
            TextSpan(
              text: l10n.firstRunStageDone,
              style: type.binomial.copyWith(color: tokens.onSurfaceMuted),
            ),
          ],
        ),
        textAlign: TextAlign.end,
      ),
    };
  }
}
