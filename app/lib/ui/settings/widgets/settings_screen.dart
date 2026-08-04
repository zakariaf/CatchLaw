import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_segmented.dart';
import 'package:catchlaw/ui/core/ui/lonja_switch.dart';
import 'package:catchlaw/ui/ruler/widgets/calibration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the fisher can change about how the book is shown to him.
///
/// **Every setting here already had a column and a writer.** `user.db` has
/// carried `locale_override`, `numeral_system`, `length_unit`, the ruler
/// calibration pair and the three flags since E05, and `SettingsRepository` has
/// had a setter for each since E05/T09. This branch showed a placeholder because
/// nothing routed to it — the same reason Reference did.
///
/// **Nothing here is a preference about the LAW.** There is no "hide expired
/// rulesets", no "only show rules I care about", no severity filter. Invariant 5
/// makes an expired ruleset still evaluated and still shown, and a switch that
/// let a fisher turn a rule off would be a switch that turns off the reason the
/// app exists. Everything on this screen changes presentation: language, digits,
/// unit, contrast, target size.
///
/// **No account row, no sync row, no backup row, and no export.** `SPEC.md` §5
/// refuses all four outright, and Settings is exactly where a reader looks for
/// them — so their absence is stated once, at the foot, as a fact about what the
/// app contains rather than as a feature list it lacks.
class SettingsScreen extends ConsumerWidget {
  /// Opens Settings.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AsyncValue<UserProfile> profile = ref.watch(settingsProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: profile.when(
          // The heading, not a blank page. `watchProfile` emits on the first
          // frame in practice, but a stream that stalled would leave this
          // branch indistinguishable from the placeholder it replaced — and a
          // screen that renders nothing is the whole defect this round of work
          // is about.
          loading: () => Padding(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Text(l10n.navSettings, style: type.title),
          ),
          error: (Object e, StackTrace _) => Padding(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Text('$e', style: type.legal),
          ),
          // A scrolled column, not a ListView: `check_lonja_lists.sh` bans the
          // eager list constructor because a list of DATA must be built lazily.
          // This is a fixed page of controls, not a list, so it is a column that
          // happens to scroll — which keeps the gate's rule intact rather than
          // reaching for its escape hatch.
          data: (UserProfile p) => SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(l10n.navSettings, style: type.title),
                const SizedBox(height: LonjaSpace.s5),

                LonjaSectionLabel(text: l10n.settingsLanguage),
                const SizedBox(height: LonjaSpace.s2),
                _LanguageChoice(current: p.localeOverride),
                const SizedBox(height: LonjaSpace.s5),

                LonjaSectionLabel(text: l10n.settingsDigits),
                const SizedBox(height: LonjaSpace.s2),
                LonjaSegmented<NumeralSystem>(
                  value: p.numeralSystem,
                  onChanged: (NumeralSystem v) =>
                      ref.read(settingsRepositoryProvider).setNumeralSystem(v),
                  options: <LonjaSegment<NumeralSystem>>[
                    LonjaSegment<NumeralSystem>(
                      value: NumeralSystem.auto,
                      label: l10n.settingsDigitsAuto,
                    ),
                    LonjaSegment<NumeralSystem>(
                      value: NumeralSystem.latn,
                      label: l10n.settingsDigitsLatn,
                    ),
                    LonjaSegment<NumeralSystem>(
                      value: NumeralSystem.arab,
                      label: l10n.settingsDigitsArab,
                    ),
                  ],
                ),
                const SizedBox(height: LonjaSpace.s5),

                LonjaSectionLabel(text: l10n.settingsLengthUnit),
                const SizedBox(height: LonjaSpace.s2),
                LonjaSegmented<LengthUnit>(
                  value: p.lengthUnit,
                  onChanged: (LengthUnit v) =>
                      ref.read(settingsRepositoryProvider).setLengthUnit(v),
                  options: <LonjaSegment<LengthUnit>>[
                    // Through the ARB even though cm and mm are identical in five
                    // of the six: Arabic abbreviates them in its own script, and a
                    // Latin 'cm' beside Arabic-Indic digits is the machine-
                    // translated register this app cannot afford.
                    LonjaSegment<LengthUnit>(value: LengthUnit.cm, label: l10n.settingsUnitCm),
                    LonjaSegment<LengthUnit>(value: LengthUnit.mm, label: l10n.settingsUnitMm),
                    LonjaSegment<LengthUnit>(value: LengthUnit.inches, label: l10n.settingsUnitIn),
                  ],
                ),
                const SizedBox(height: LonjaSpace.s5),

                const LonjaRule.row(),
                LonjaSwitch(
                  label: l10n.settingsSunlightMode,
                  note: l10n.settingsSunlightNote,
                  value: p.sunlightMode,
                  onChanged: (bool v) =>
                      ref.read(settingsRepositoryProvider).setFlags(sunlightMode: v),
                ),
                const LonjaRule.row(),
                LonjaSwitch(
                  label: l10n.settingsGloveMode,
                  note: l10n.settingsGloveNote,
                  value: p.gloveMode,
                  onChanged: (bool v) =>
                      ref.read(settingsRepositoryProvider).setFlags(gloveMode: v),
                ),
                const LonjaRule.row(),
                const SizedBox(height: LonjaSpace.s5),

                LonjaSectionLabel(text: l10n.settingsRuler),
                const SizedBox(height: LonjaSpace.s2),
                Text(
                  p.rulerCalibratedAt == null
                      ? l10n.settingsRulerUncalibrated
                      : l10n.settingsRulerCalibrated(p.rulerCalibratedAt!),
                  style: type.datum,
                ),
                const SizedBox(height: LonjaSpace.s3),
                // "Not calibrated" was a dead statement: it named a state with
                // no way out of it. The screen that fixes it has existed since
                // E09 and was reachable from nowhere.
                LonjaButton.secondary(
                  label: l10n.calibrateAction,
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const CalibrationScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: LonjaSpace.s6),

                const LonjaRule.row(),
                const SizedBox(height: LonjaSpace.s3),
                Text(
                  l10n.settingsOfflineNote,
                  style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The six shipped locales plus "follow the device".
///
/// A list rather than a [LonjaSegmented]: seven cells in a row would truncate
/// every label to an initial, and a language a fisher cannot read the name of is
/// a language he cannot choose.
class _LanguageChoice extends ConsumerWidget {
  const _LanguageChoice({required this.current});

  final String? current;

  /// Each locale named in ITSELF, never in the reader's current language.
  ///
  /// A fisher switching away from a language he cannot read has to find the one
  /// he can, and "Galician" is no help to someone who only reads galego.
  static const Map<String?, String> _names = <String?, String>{
    null: '',
    'en': 'English',
    'es': 'Español',
    'gl': 'Galego',
    'ca': 'Català',
    'pt': 'Português',
    'ar': 'العربية',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final MapEntry<String?, String> e in _names.entries) ...<Widget>[
          Semantics(
            button: true,
            selected: e.key == current,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => ref.read(settingsRepositoryProvider).setLocaleOverride(e.key),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: tokens.density.tapMin),
                child: Row(
                  children: <Widget>[
                    // A drawn bar, not a colour: selected reads in greyscale and
                    // in glare, which invariant 4 requires everywhere.
                    SizedBox(
                      width: LonjaSpace.s3,
                      child: e.key == current
                          ? Text('—', style: type.ui.copyWith(fontWeight: FontWeight.w700))
                          : null,
                    ),
                    const SizedBox(width: LonjaSpace.s2),
                    Expanded(
                      child: Text(
                        e.key == null ? l10n.settingsLanguageDevice : e.value,
                        style: e.key == current
                            ? type.ui.copyWith(fontWeight: FontWeight.w700)
                            : type.ui,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The fisher's settings, as a stream.
///
/// A stream and not a one-shot read: every control on this screen writes through
/// the repository and the screen must show the new value without re-reading by
/// hand. `watchProfile` already emits on write, so the screen is a pure function
/// of it and no control holds local state that could disagree with the database.
final StreamProvider<UserProfile> settingsProfileProvider = StreamProvider<UserProfile>(
  (Ref ref) => ref.watch(settingsRepositoryProvider).watchProfile(),
);
