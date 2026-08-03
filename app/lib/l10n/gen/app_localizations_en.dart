// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CatchLaw';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '$count match',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystemDefault => 'Device language';

  @override
  String get settingsNumeralSystem => 'Digits';

  @override
  String get settingsNumeralSystemAuto => 'Device language default';

  @override
  String get settingsNumeralSystemLatn => 'Western — 0 1 2 3';

  @override
  String get settingsNumeralSystemArab => 'Arabic-Indic — ٠ ١ ٢ ٣';

  @override
  String legalTextLanguageNotice(String language) {
    return 'The verbatim text of this instrument exists only in $language.';
  }

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ar': 'Arabic',
      'en': 'English',
      'es': 'Spanish',
      'gl': 'Galician',
      'ca': 'Catalan',
      'ptBR': 'Brazilian Portuguese',
      'other': 'English',
    });
    return '$_temp0';
  }

  @override
  String get speciesSearchLabel => 'Species';

  @override
  String get speciesSearchHint => 'hamour, mero, Epinephelus';

  @override
  String get speciesGroupInYourZone => 'In your zone';

  @override
  String get speciesGroupElsewhere => 'Elsewhere in this jurisdiction';

  @override
  String get speciesHintProtected => 'protected';

  @override
  String get speciesHintClosed => 'closed';

  @override
  String get speciesNoMatchHeadline => 'No species by that name';

  @override
  String get speciesNoMatchBody =>
      'The name may be spelled differently here, or the species may not be transcribed yet.';

  @override
  String get identifyThisFish => 'Identify this fish';

  @override
  String get browseByShape => 'Browse by shape';

  @override
  String get rulePackExpired =>
      'These rules passed their stated end date. They are shown as published.';

  @override
  String speciesSearchResultCount(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of $total',
      one: '$count of $total',
    );
    return '$_temp0';
  }

  @override
  String get browseByShapeTitle => 'Browse by shape';

  @override
  String get browseNoSpeciesHeadline => 'No species in this pack';

  @override
  String get browseNoSpeciesBody => 'This jurisdiction has no species transcribed yet.';

  @override
  String get speciesOtherNames => 'Other names';

  @override
  String get speciesScientificName => 'Scientific name';

  @override
  String get speciesFamilyLabel => 'Family';

  @override
  String get speciesPlateSemanticLabel => 'Engraved plate';

  @override
  String get speciesProtectedAnywhere => 'Protected somewhere in this jurisdiction';

  @override
  String get lookAlikeSectionLabel => 'Easily confused with';

  @override
  String get lookAlikeConfusedWith => 'How to tell them apart';

  @override
  String get recentsStripLabel => 'Recent here';

  @override
  String get recentsEmptyBody => 'Species you open in this zone appear here.';

  @override
  String get calibrationTitle => 'Measure your screen';

  @override
  String get calibrationCardExplainer =>
      'Lay any bank card, licence or ID on the glass and drag the edge to match it.';

  @override
  String get calibrationHandleLabel => 'Card edge';

  @override
  String calibrationVerifyExplainer(String measurement) {
    return 'This bar is $measurement. Check it against the short side of the same card.';
  }

  @override
  String calibrationVerifyBarLabel(String measurement) {
    return '$measurement';
  }

  @override
  String get calibrationSaveAction => 'Save this measurement';

  @override
  String get calibrationCancelAction => 'Back one step';

  @override
  String get calibrationTooSmallScreen =>
      'This screen is narrower than a card. Manual entry is available.';

  @override
  String calibrationImplausible(String measurement) {
    return 'That drag measured $measurement across the screen, which is not a card.';
  }

  @override
  String get unitMillimetres => 'mm';

  @override
  String get unitCentimetres => 'cm';

  @override
  String rulerSemanticLabel(String measurement) {
    return 'Ruler. Reading $measurement.';
  }

  @override
  String get rulerZeroLabel => '0';

  @override
  String measurementCm(String value, String method) {
    return '$value cm ($method)';
  }

  @override
  String measurementMm(String value, String method) {
    return '$value mm ($method)';
  }

  @override
  String measurementInch(String value, String method) {
    return '$value in ($method)';
  }
}
