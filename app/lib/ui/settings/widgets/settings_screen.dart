import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/user_profile.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/format/bidi_isolate.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_segmented.dart';
import 'package:catchlaw/ui/core/ui/lonja_setting_line.dart';
import 'package:catchlaw/ui/core/ui/lonja_switch.dart';
import 'package:catchlaw/ui/ruler/widgets/calibration_screen.dart';
import 'package:catchlaw/ui/zones/zone_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the fisher can change about how the book is shown to him.
///
/// **A ledger, not a form.** Every setting is one full-bleed row: the key in
/// serif, what it reaches in sans under it, and what it is set to at the end of
/// the same line — with a hairline between rows and a tracked rubric over each
/// group. That is the shape of the page this app replaces, and it is also the
/// shape that answers "what is this copy set to" in one downward read rather
/// than in four screens of stacked label-then-control blocks.
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
/// app exists. Everything on this screen changes presentation, or names the
/// place the presentation is read against.
///
/// **No account row, no sync row, no backup row.** `SPEC.md` §5 refuses all
/// three outright, and Settings is exactly where a reader looks for them — so
/// their absence is stated once, at the foot, as a fact about what the app
/// contains rather than as a feature list it lacks.
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
      // The mast is outside the `when`, so the branch is named on every frame:
      // a screen that printed its own heading only once the stream had emitted
      // would read as a page that failed to load.
      appBar: LonjaScreenBar(title: l10n.navSettings, sup: l10n.appTitle),
      body: profile.when(
        loading: () => const SizedBox.shrink(),
        error: (Object e, StackTrace _) => Padding(
          padding: EdgeInsetsDirectional.all(tokens.density.gutter),
          child: Text('$e', style: type.legal),
        ),
        // A scrolled column, not a ListView: `check_lonja_lists.sh` bans the
        // eager list constructor because a list of DATA must be built lazily.
        // This is a fixed page of controls, not a list, so it is a column that
        // happens to scroll — which keeps the gate's rule intact rather than
        // reaching for its escape hatch.
        //
        // No page padding, either: the rows and their hairlines run to both
        // margins, and each row carries the gutter inside itself.
        data: (UserProfile p) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _Group(
                title: l10n.settingsGroupLanguage,
                rows: <Widget>[
                  _LanguageLine(current: p.localeOverride),
                  LonjaSettingLine(
                    label: l10n.settingsDigits,
                    note: l10n.settingsDigitsNote,
                    below: LonjaSegmented<NumeralSystem>(
                      value: p.numeralSystem,
                      onChanged: (NumeralSystem v) =>
                          ref.read(settingsRepositoryProvider).setNumeralSystem(v),
                      options: <LonjaSegment<NumeralSystem>>[
                        // `auto` and `latn` render the same digits under CLDR 48
                        // and are still two cells: one defers to the device and
                        // one states a preference, and collapsing them would
                        // turn every fisher's deference into a preference behind
                        // his back (`numeral_system.dart`).
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
                  ),
                  LonjaSettingLine(
                    label: l10n.settingsLengthUnit,
                    note: l10n.settingsLengthUnitNote,
                    below: LonjaSegmented<LengthUnit>(
                      value: p.lengthUnit,
                      onChanged: (LengthUnit v) =>
                          ref.read(settingsRepositoryProvider).setLengthUnit(v),
                      options: <LonjaSegment<LengthUnit>>[
                        // Through the ARB even though cm and mm are identical in
                        // five of the six: Arabic abbreviates them in its own
                        // script, and a Latin 'cm' beside Arabic-Indic digits is
                        // the machine-translated register this app cannot afford.
                        LonjaSegment<LengthUnit>(value: LengthUnit.cm, label: l10n.settingsUnitCm),
                        LonjaSegment<LengthUnit>(value: LengthUnit.mm, label: l10n.settingsUnitMm),
                        LonjaSegment<LengthUnit>(
                          value: LengthUnit.inches,
                          label: l10n.settingsUnitIn,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _Group(
                title: l10n.settingsGroupPlace,
                rows: <Widget>[
                  LonjaSettingLine(
                    label: l10n.settingsZone,
                    note: l10n.settingsZoneNote,
                    // The code as authored, exactly as the mast on Check prints
                    // it: it is the string a fisher reads off the printed pack.
                    value: p.activeZoneCode ?? l10n.settingsZoneUnset,
                    chevron: true,
                    onTap: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            ZonePickerScreen(onConfirmed: () => Navigator.of(context).pop()),
                      ),
                    ),
                  ),
                  _RulerLine(pxPerMm: p.rulerPxPerMm, calibratedAt: p.rulerCalibratedAt),
                  _SwitchLine(
                    child: LonjaSwitch(
                      label: l10n.settingsCoordinates,
                      note: l10n.settingsCoordinatesNote,
                      value: p.captureCoordinates,
                      onChanged: (bool v) =>
                          ref.read(settingsRepositoryProvider).setFlags(captureCoordinates: v),
                    ),
                  ),
                ],
              ),
              _Group(
                title: l10n.settingsGroupReading,
                rows: <Widget>[
                  _SwitchLine(
                    child: LonjaSwitch(
                      label: l10n.settingsSunlightMode,
                      note: l10n.settingsSunlightNote,
                      value: p.sunlightMode,
                      onChanged: (bool v) =>
                          ref.read(settingsRepositoryProvider).setFlags(sunlightMode: v),
                    ),
                  ),
                  _SwitchLine(
                    child: LonjaSwitch(
                      label: l10n.settingsGloveMode,
                      note: l10n.settingsGloveNote,
                      value: p.gloveMode,
                      onChanged: (bool v) =>
                          ref.read(settingsRepositoryProvider).setFlags(gloveMode: v),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  tokens.density.gutter,
                  LonjaSpace.s5,
                  tokens.density.gutter,
                  LonjaSpace.s6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const LonjaRule.row(),
                    const SizedBox(height: LonjaSpace.s3),
                    // Sans and quiet, not serif: this is a note about the app,
                    // and the serif ramp in this product is what quotes the law.
                    Text(
                      l10n.settingsOfflineNote,
                      style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One ruled group of the ledger: a tracked rubric, then its rows.
///
/// The hairline sits **between** rows and not under the last of them: the next
/// group opens with a rubric carrying its own rule to the margin, and two rules
/// a few pixels apart read as a printing fault rather than as a boundary.
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.rows});

  final String title;

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            tokens.density.gutter,
            LonjaSpace.s5,
            tokens.density.gutter,
            LonjaSpace.s2,
          ),
          child: LonjaSectionLabel(text: title),
        ),
        for (final (int i, Widget row) in rows.indexed) ...<Widget>[
          if (i > 0) const LonjaRule.row(),
          row,
        ],
      ],
    );
  }
}

/// A [LonjaSwitch] held to the ledger's measure.
///
/// The switch carries its own row height and its own trailing control, so it is
/// already a ledger line — what it does not carry is the gutter, because the
/// same control is used inside padded blocks elsewhere.
class _SwitchLine extends StatelessWidget {
  const _SwitchLine({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.symmetric(horizontal: LonjaTokens.of(context).density.gutter),
    child: child,
  );
}

/// The language row: what it is set to now, and the way to the six.
///
/// A row that opens a picker rather than seven rows in place. Seven stacked
/// choices push every other setting off the first screen, and the question this
/// row answers — *which language is this book in* — is answered by one word at
/// the end of one line.
class _LanguageLine extends ConsumerWidget {
  const _LanguageLine({required this.current});

  final String? current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return LonjaSettingLine(
      label: l10n.settingsLanguage,
      // Each name isolated, because the run mixes scripts: an Arabic endonym
      // beside Latin ones reorders the whole line otherwise, and the list would
      // read differently in `ar` than in `en`.
      note: languageEndonyms.values.map(isolate).join(' · '),
      value: current == null ? l10n.settingsLanguageDevice : languageEndonyms[current]!,
      chevron: true,
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (BuildContext context) => const _LanguagePicker()),
      ),
    );
  }
}

/// The ruler row: the scale this screen was measured at, and when.
///
/// The figure is the point. "Not calibrated" on its own named a state with no
/// way out of it and no number in it; the scale is what a fisher compares
/// against another phone when two rulers disagree about the same fish.
class _RulerLine extends StatelessWidget {
  const _RulerLine({required this.pxPerMm, required this.calibratedAt});

  final double? pxPerMm;

  final String? calibratedAt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double? scale = pxPerMm;
    final String? on = calibratedAt;

    return LonjaSettingLine(
      label: l10n.settingsRuler,
      // ISO and unlocalised, like every other date this app quotes.
      note: on == null ? null : l10n.settingsRulerCalibrated(on),
      value: scale == null
          ? l10n.settingsRulerUncalibrated
          // Isolated: the reading is a Latin run of figures and a unit, and in
          // Arabic the unit would otherwise cross to the wrong end of it.
          : isolateLtr(
              l10n.settingsRulerScale(
                // The formatter is built at the point of use and retained
                // nowhere: it captures its digit symbols at construction, so a
                // held one prints the digits of whenever it was built
                // (`numeral_system.dart`).
                numberFormatFor(
                  Localizations.localeOf(context),
                ).format(double.parse((scale * 10).toStringAsFixed(1))),
              ),
            ),
      onTap: () => Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (BuildContext context) => const CalibrationScreen()),
      ),
    );
  }
}

/// The six shipped locales plus "follow the device", on a page of their own.
///
/// A list rather than a [LonjaSegmented]: seven cells in a row would truncate
/// every label to an initial, and a language a fisher cannot read the name of is
/// a language he cannot choose.
class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<UserProfile> profile = ref.watch(settingsProfileProvider);
    final String? current = profile.value?.localeOverride;

    void choose(String? locale) {
      // Not awaited, and the pop does not wait for it either: the write is a
      // single row in `user.db`, the screen is a pure function of the stream it
      // emits on, and a fisher held on a picker until a local write acknowledged
      // would be waiting on nothing he can see.
      ref.read(settingsRepositoryProvider).setLocaleOverride(locale).ignore();
      // Straight back to the ledger, where the row now reads the new language.
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.settingsLanguage,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            LonjaSettingLine(
              label: l10n.settingsLanguageDevice,
              trailing: _ChosenMark(chosen: current == null),
              onTap: () => choose(null),
            ),
            for (final MapEntry<String, String> e in languageEndonyms.entries) ...<Widget>[
              const LonjaRule.row(),
              LonjaSettingLine(
                label: e.value,
                trailing: _ChosenMark(chosen: e.key == current),
                onTap: () => choose(e.key),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The mark against the language in force.
///
/// A drawn rule, not a colour and not a tint: chosen has to read in greyscale
/// and in glare, which invariant 4 requires everywhere in this app.
class _ChosenMark extends StatelessWidget {
  const _ChosenMark({required this.chosen});

  final bool chosen;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: LonjaSpace.s5, child: chosen ? const LonjaRule.section() : null);
}

/// Each shipped locale named in ITSELF, never in the reader's current language.
///
/// A fisher switching away from a language he cannot read has to find the one
/// he can, and "Galician" is no help to someone who only reads galego. The tags
/// are D-3's, and this map is the one place they are spelled for a reader.
const Map<String, String> languageEndonyms = <String, String>{
  'en': 'English',
  'es': 'Español',
  'gl': 'Galego',
  'ca': 'Català',
  'pt': 'Português',
  'ar': 'العربية',
};

/// The fisher's settings, as a stream.
///
/// A stream and not a one-shot read: every control on this screen writes through
/// the repository and the screen must show the new value without re-reading by
/// hand. `watchProfile` already emits on write, so the screen is a pure function
/// of it and no control holds local state that could disagree with the database.
final StreamProvider<UserProfile> settingsProfileProvider = StreamProvider<UserProfile>(
  (Ref ref) => ref.watch(settingsRepositoryProvider).watchProfile(),
);
