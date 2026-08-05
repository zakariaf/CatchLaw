import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_keypad.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/ruler/view_models/manual_entry_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Typing the length, on a screen of its own.
///
/// **Its own screen, because the mockup's ruler has no keypad on it.** S3 gives
/// manual entry one quiet button — *Type instead* — and the whole of the ruler
/// page to the instrument. A keypad parked under the scale took half the page
/// from the thing the page is for, and put eleven targets where the fisher's
/// hand rests on the glass.
///
/// **A demotion in weight, never in standing.** Manual entry works before any
/// calibration exists (`catchlaw-measurement-ruler` rule 6) and it is not a
/// fallback: a fisher on a wet morning who has never lined a bank card up
/// against the glass still has a tape in his hand, and this is the path he
/// takes by choice.
///
/// Returns the length in millimetres to whoever pushed it, and interprets
/// nothing: what a number means against a rule is the result surface's job,
/// because that is where a citation can be printed beside it.
class ManualLengthScreen extends ConsumerWidget {
  /// Opens manual entry.
  const ManualLengthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final ManualEntryState manual = ref.watch(manualEntryViewModelProvider);
    final ManualEntryViewModel vm = ref.read(manualEntryViewModelProvider.notifier);

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.measureManualTitle,
        sup: l10n.measureSup,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsetsDirectional.all(tokens.density.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LonjaSectionLabel(text: l10n.measureManualLabel),
              const SizedBox(height: LonjaSpace.s3),
              // Spelled out through the ARB rather than a bare unit token: this
              // number carries no measurement METHOD yet — it is what the
              // fisher typed, not a measurement stated against an instrument —
              // and check_measurement is right to refuse the abbreviation on a
              // figure that has no method beside it.
              Text(
                l10n.measureManualReading(
                  numberFormatFor(Localizations.localeOf(context)).format(manual.millimetres),
                ),
                style: type.measure,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: LonjaSpace.s5),
              LonjaKeypad(
                onDigit: vm.digit,
                onBackspace: vm.backspace,
                backspaceLabel: l10n.measureBackspace,
              ),
              const Spacer(),
              LonjaButton.primary(
                label: l10n.measureUse,
                // Disabled on a number that could not be a fish, not merely on
                // zero: a slipped thumb that entered 3 mm is a mistype, and a
                // length nobody could have measured must not travel to a
                // surface that will compare it against a limit.
                onPressed: manual.isPlausible
                    ? () => Navigator.of(context).pop(manual.millimetres)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
