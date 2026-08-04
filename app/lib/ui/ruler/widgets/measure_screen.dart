import 'package:catchlaw/domain/models/ruler_calibration.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/ruler/view_models/manual_entry_viewmodel.dart';
import 'package:catchlaw/ui/ruler/view_models/ruler_viewmodel.dart';
import 'package:catchlaw/ui/ruler/widgets/calibration_screen.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S3 — measure the fish on the glass.
///
/// **The ruler has existed since E09 and was reachable from nowhere.** The
/// painter, the calibration flow, the step-and-mark draft and the manual keypad
/// were all built, tested and unrouted — so a fisher asking how to measure a
/// fish had no answer at all, on a product whose whole claim is that it
/// replaces a booklet WITH A RULER ON THE BACK COVER. This screen is the route.
///
/// **Manual entry works before any calibration exists.** That is
/// `catchlaw-measurement-ruler` rule 6 and it is not a fallback: a fisher on a
/// wet morning who has never lined a bank card up against the glass still has a
/// tape in his hand, and a screen that demanded calibration first would be a
/// screen he closes.
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

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final RulerState ruler = ref.watch(rulerViewModelProvider);
    final ManualEntryState manual = ref.watch(manualEntryViewModelProvider);
    final RulerCalibration? calibration = ruler.calibration;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.measureTitle)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(tokens.density.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (calibration == null) ...<Widget>[
                // Stated, not hidden. A ruler drawn at a guessed scale is worse
                // than no ruler: it produces a number that looks measured.
                Text(l10n.measureUncalibrated, style: type.subtitle),
                const SizedBox(height: LonjaSpace.s2),
                Text(
                  l10n.measureUncalibratedBody,
                  style: type.legal.copyWith(color: tokens.onSurfaceMuted),
                ),
                const SizedBox(height: LonjaSpace.s3),
                LonjaButton.secondary(
                  label: l10n.calibrateAction,
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const CalibrationScreen(),
                    ),
                  ),
                ),
              ] else
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints c) => GestureDetector(
                      onHorizontalDragUpdate: (DragUpdateDetails d) =>
                          ref.read(rulerViewModelProvider.notifier).dragTo(d.localPosition.dx),
                      child: RulerView(
                        calibration: calibration,
                        cursorMm: ref.read(rulerViewModelProvider.notifier).cursorMm,
                        spanPx: c.maxWidth,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: LonjaSpace.s4),
              const LonjaRule.section(),
              const SizedBox(height: LonjaSpace.s3),
              Text(l10n.measureManualLabel, style: type.uiSmall),
              const SizedBox(height: LonjaSpace.s2),
              // Spelled out through the ARB rather than a bare unit token:
              // this number carries no measurement METHOD yet — it is what the
              // fisher typed, not a measurement stated against an instrument —
              // and check_measurement.sh is right to refuse the abbreviation on
              // a figure that has no method beside it.
              Text(
                l10n.measureManualReading(
                  numberFormatFor(Localizations.localeOf(context)).format(manual.millimetres),
                ),
                style: type.measure,
              ),
              const SizedBox(height: LonjaSpace.s3),
              _Keypad(),
              const SizedBox(height: LonjaSpace.s4),
              LonjaButton.primary(
                label: l10n.measureUse,
                onPressed: manual.millimetres == 0
                    ? null
                    : () => Navigator.of(context).pop(manual.millimetres),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ten digits and a backspace, sized for a gloved thumb.
///
/// `LonjaKeypad` is what `lonja-forms-and-controls` rule 6 names, and it does
/// not exist yet; this is the same shape built from `LonjaButton` so the route
/// is usable now. Replacing it with the authored keypad is a straight swap.
class _Keypad extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ManualEntryViewModel vm = ref.read(manualEntryViewModelProvider.notifier);
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Through the locale's own formatter, never a Latin literal: an Arabic
    // keypad reads ٠١٢٣, and a Latin '7' beside Arabic-Indic digits in the
    // readout above is the machine-translated register this app cannot afford.
    // `check_lonja_nav.sh` caught exactly that.

    return Wrap(
      spacing: LonjaSpace.s2,
      runSpacing: LonjaSpace.s2,
      children: <Widget>[
        for (int d = 1; d <= 9; d++)
          SizedBox(
            width: 64,
            child: LonjaButton.secondary(
              label: numberFormatFor(Localizations.localeOf(context)).format(d),
              onPressed: () => vm.digit(d),
            ),
          ),
        SizedBox(
          width: 64,
          child: LonjaButton.secondary(
            label: numberFormatFor(Localizations.localeOf(context)).format(0),
            onPressed: () => vm.digit(0),
          ),
        ),
        SizedBox(
          width: 96,
          child: LonjaButton.secondary(label: l10n.measureBackspace, onPressed: vm.backspace),
        ),
      ],
    );
  }
}
