import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/length_display.dart';
import 'package:catchlaw/domain/models/measurement_draft.dart';
import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/ruler/view_models/ruler_viewmodel.dart';
import 'package:catchlaw/ui/ruler/widgets/calibration_screen.dart';
import 'package:catchlaw/ui/ruler/widgets/manual_length_screen.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_band.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S3 — measure the fish on the glass.
///
/// **The order is the design.** The instrument is at the top, running to both
/// edges, because the fisher's hand is already on the glass; the running total
/// is under it in the mono figure step, large enough to read at arm's length;
/// the actions come after the number they act on; and the notes close the page.
/// Everything above the fold is the measurement.
///
/// **Step and mark is the instrument, not a draft feature.** A fish longer than
/// the phone is measured in segments — mark at the snout, slide the phone along
/// the fish, mark again — and `RulerViewModel.mark()` existed from E09 with no
/// widget calling it, so the ruler could only measure a fish shorter than a
/// phone. The primary action on this screen is that mark.
///
/// **Manual entry works before any calibration exists.** That is
/// `catchlaw-measurement-ruler` rule 6 and it is not a fallback: a fisher on a
/// wet morning who has never lined a bank card up against the glass still has a
/// tape in his hand. It is one quiet button here and a screen of its own,
/// because a keypad under the scale took the page from the instrument.
///
/// **The reading is returned, never interpreted here.** This screen produces
/// millimetres and pops. What that number means against a rule is the result
/// surface's job, because that is where a citation can be printed beside it —
/// and a length without its instrument is the defect the whole skill exists to
/// prevent.
class MeasureScreen extends ConsumerStatefulWidget {
  /// Opens the ruler.
  const MeasureScreen({super.key});

  @override
  ConsumerState<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends ConsumerState<MeasureScreen> {
  @override
  void initState() {
    super.initState();
    // After the first frame, not in build: `load()` reads the calibration from
    // user.db and a read started during build is a provider mutation mid-build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rulerViewModelProvider.notifier).load();
    });
  }

  /// Opens calibration, then re-reads the scale it may have written.
  Future<void> _calibrate() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext context) => const CalibrationScreen()),
    );
    if (!mounted) return;
    await ref.read(rulerViewModelProvider.notifier).load();
  }

  /// Opens manual entry, and carries whatever it returns straight out of the
  /// ruler.
  ///
  /// A typed length is a finished measurement: stopping here to show it again
  /// on a scale it was never taken from would invite the fisher to check one
  /// number against another that means nothing.
  Future<void> _typeInstead() async {
    final int? millimetres = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(builder: (BuildContext context) => const ManualLengthScreen()),
    );
    if (!mounted || millimetres == null) return;
    Navigator.of(context).pop(millimetres);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final RulerState ruler = ref.watch(rulerViewModelProvider);
    final RulerViewModel vm = ref.read(rulerViewModelProvider.notifier);
    final RulerCalibration? calibration = ruler.calibration;

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.measureTitle,
        sup: l10n.measureSup,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            if (calibration == null)
              const _UncalibratedBand()
            else
              RulerBand(calibration: calibration, cursorMm: vm.cursorMm, onDrag: vm.dragTo),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (calibration != null)
                      Padding(
                        padding: EdgeInsetsDirectional.symmetric(horizontal: tokens.density.gutter),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: LonjaSpace.s5),
                            LonjaSectionLabel(text: l10n.measureStepAndMark),
                            const SizedBox(height: LonjaSpace.s4),
                            _Readout(draft: ruler.draft, cursorMm: vm.cursorMm),
                            if (!ruler.draft.isEmpty) ...<Widget>[
                              const SizedBox(height: LonjaSpace.s4),
                              _StepPips(marks: ruler.draft.segmentsMm.length),
                            ],
                            const SizedBox(height: LonjaSpace.s3),
                            Text(
                              l10n.measureStepNote,
                              style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        tokens.density.gutter,
                        LonjaSpace.s5,
                        tokens.density.gutter,
                        0,
                      ),
                      child: _Actions(
                        draft: ruler.draft,
                        cursorMm: vm.cursorMm,
                        isCalibrated: calibration != null,
                        onMark: vm.mark,
                        onCalibrate: _calibrate,
                        onTypeInstead: _typeInstead,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        tokens.density.gutter,
                        LonjaSpace.s5,
                        tokens.density.gutter,
                        LonjaSpace.s5,
                      ),
                      child: Text(
                        l10n.measurePrivacyNote,
                        style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                        textAlign: TextAlign.start,
                      ),
                    ),
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

/// What stands where the scale would, before the screen has been measured.
///
/// **Stated, not hidden, and never replaced by a guessed scale.** A ruler drawn
/// at a nominal ratio is worse than no ruler: it produces a number that looks
/// measured. The band keeps its place in the order so the page does not
/// reshuffle the moment a calibration lands.
class _UncalibratedBand extends StatelessWidget {
  const _UncalibratedBand();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ColoredBox(
          color: tokens.surfaceSunk,
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: tokens.density.gutter,
              vertical: LonjaSpace.s4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(l10n.measureUncalibrated, style: type.subtitle, textAlign: TextAlign.start),
                const SizedBox(height: LonjaSpace.s2),
                Text(
                  l10n.measureUncalibratedBody,
                  style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ),
        const LonjaRule.section(),
      ],
    );
  }
}

/// The running total, in the mono figure step, with its unit beside it.
///
/// **A running total and it says so.** The number is the sum of the marks plus
/// whatever the cursor stands at, so it changes under the thumb; a figure
/// presented as final would be read against a limit before the fish had been
/// measured.
class _Readout extends StatelessWidget {
  const _Readout({required this.draft, required this.cursorMm});

  final MeasurementDraft draft;

  final ValueListenable<double> cursorMm;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        ValueListenableBuilder<double>(
          valueListenable: cursorMm,
          builder: (BuildContext context, double mark, Widget? _) => Text(
            // Through the one conversion point, so a length shown here and the
            // same length shown in the log cannot round differently.
            LengthDisplay.format(draft.totalMm + mark.round(), LengthUnit.cm),
            style: type.measure,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: LonjaSpace.s2),
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: LonjaSpace.s1),
          child: Text(
            l10n.measureRunningTotalUnit,
            style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ),
        const Spacer(),
        if (!draft.isEmpty) _StepStamp(marks: draft.segmentsMm.length),
      ],
    );
  }
}

/// How many marks stand in the running total.
class _StepStamp extends StatelessWidget {
  const _StepStamp({required this.marks});

  final int marks;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tokens.accent, width: LonjaRules.rule),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LonjaSpace.s2,
          vertical: LonjaSpace.s1,
        ),
        child: Text(
          l10n.measureStepPill(numberFormatFor(Localizations.localeOf(context)).format(marks)),
          style: type.articleNumber.copyWith(color: tokens.accent),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}

/// One filled box per mark, as a tally along the line.
///
/// **A tally, and never a progress bar.** How many segments a fish takes is not
/// knowable before it is measured, so there is no total to fill towards and the
/// row grows as the marks are made.
class _StepPips extends StatelessWidget {
  const _StepPips({required this.marks});

  final int marks;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return ExcludeSemantics(
      // The count is already stated in words beside the total. A row of boxes
      // read out one at a time is noise on the one screen a reader is counting.
      child: Row(
        children: <Widget>[
          for (var mark = 0; mark < marks; mark++) ...<Widget>[
            if (mark > 0) const SizedBox(width: LonjaSpace.s1),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.onSurface,
                  border: Border.all(color: tokens.onSurface, width: LonjaRules.rule),
                ),
                child: const SizedBox(height: LonjaSpace.s2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The action ladder: mark, use, type, re-calibrate.
///
/// **One primary, and its label follows the state of the screen.** Two
/// `LonjaButton.primary` in one file trips `check_lonja_buttons.sh` even in
/// mutually exclusive branches — and the gate has the better shape: there is
/// one way forward from this screen at any moment, so there is one button.
/// Before the screen has been measured that way is calibration; after it, it is
/// the mark.
class _Actions extends StatelessWidget {
  const _Actions({
    required this.draft,
    required this.cursorMm,
    required this.isCalibrated,
    required this.onMark,
    required this.onCalibrate,
    required this.onTypeInstead,
  });

  final MeasurementDraft draft;

  final ValueListenable<double> cursorMm;

  final bool isCalibrated;

  final VoidCallback onMark;

  final VoidCallback onCalibrate;

  final VoidCallback onTypeInstead;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ValueListenableBuilder<double>(
          valueListenable: cursorMm,
          builder: (BuildContext context, double mark, Widget? _) => LonjaButton.primary(
            label: isCalibrated ? l10n.measureStepAndMark : l10n.calibrateAction,
            // A mark at zero would add a segment of no length, so the button
            // stays down until the cursor has been moved off the snout.
            onPressed: !isCalibrated
                ? onCalibrate
                : mark.round() > 0
                ? onMark
                : null,
          ),
        ),
        // Only once there is something to use. A length of nothing carried to
        // the result surface would still be compared against a limit.
        if (!draft.isEmpty) ...<Widget>[
          SizedBox(height: tokens.density.tapGap),
          LonjaButton.secondary(
            label: l10n.measureUse,
            onPressed: () => Navigator.of(context).pop(draft.totalMm),
          ),
        ],
        SizedBox(height: tokens.density.tapGap),
        LonjaButton.secondary(label: l10n.measureTypeInstead, onPressed: onTypeInstead),
        if (isCalibrated) ...<Widget>[
          SizedBox(height: tokens.density.tapGap),
          LonjaButton.secondary(label: l10n.measureRecalibrate, onPressed: onCalibrate),
        ],
      ],
    );
  }
}
