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

  @override
  String massKg(String value) {
    return '$value kg';
  }

  @override
  String get limitPeriodDay => 'day';

  @override
  String get limitPeriodTrip => 'trip';

  @override
  String get limitPeriodSeason => 'season';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'January',
      '2': 'February',
      '3': 'March',
      '4': 'April',
      '5': 'May',
      '6': 'June',
      '7': 'July',
      '8': 'August',
      '9': 'September',
      '10': 'October',
      '11': 'November',
      '12': 'December',
      'other': '$month',
    });
    return '$_temp0';
  }

  @override
  String dateDayMonth(String day, String month) {
    return '$day $month';
  }

  @override
  String verdictMeetsMinimum(String measured, String unit, String threshold, String method) {
    return 'Meets the minimum — $measured $unit measured, minimum $threshold $unit ($method)';
  }

  @override
  String verdictBelowMinimum(String measured, String unit, String threshold, String method) {
    return 'Below the minimum — $measured $unit measured, minimum $threshold $unit ($method)';
  }

  @override
  String verdictWithinMaximum(String measured, String unit, String threshold, String method) {
    return 'Within the maximum — $measured $unit measured, maximum $threshold $unit ($method)';
  }

  @override
  String verdictAboveMaximum(String measured, String unit, String threshold, String method) {
    return 'Above the maximum — $measured $unit measured, maximum $threshold $unit ($method)';
  }

  @override
  String verdictMinimumNotMeasured(String threshold, String unit, String method) {
    return 'Not measured — the minimum is $threshold $unit ($method)';
  }

  @override
  String verdictMaximumNotMeasured(String threshold, String unit, String method) {
    return 'Not measured — the maximum is $threshold $unit ($method)';
  }

  @override
  String verdictSizeMethodMismatch(
    String measuredMethod,
    String threshold,
    String unit,
    String method,
  ) {
    return 'Measured by $measuredMethod — the instrument states $threshold $unit ($method). No comparison is made.';
  }

  @override
  String verdictMarginShortOfMinimum(String margin, String unit) {
    return 'Short of the minimum by $margin $unit';
  }

  @override
  String verdictMarginOverMinimum(String margin, String unit) {
    return 'Over the minimum by $margin $unit';
  }

  @override
  String verdictMarginOverMaximum(String margin, String unit) {
    return 'Over the maximum by $margin $unit';
  }

  @override
  String verdictMarginUnderMaximum(String margin, String unit) {
    return 'Under the maximum by $margin $unit';
  }

  @override
  String verdictClosedSeasonInForce(String starts, String ends, String day, String total) {
    return 'Closed season — $starts to $ends. In force today, day $day of $total.';
  }

  @override
  String verdictClosedSeasonNotInForce(String starts, String ends) {
    return 'Closed season — $starts to $ends. Not in force today.';
  }

  @override
  String get verdictProtected => 'Protected species — taking prohibited.';

  @override
  String verdictWithinBagLimit(String recorded, String limit, String period) {
    return 'Within the bag limit — $recorded recorded, limit $limit per $period';
  }

  @override
  String verdictAboveBagLimit(String recorded, String limit, String period) {
    return 'Above the bag limit — $recorded recorded, limit $limit per $period';
  }

  @override
  String verdictBagLimitNotRecorded(String limit, String period) {
    return 'Nothing recorded for this period — the bag limit is $limit per $period';
  }

  @override
  String verdictWithinVesselLimit(String recorded, String limit) {
    return 'Within the vessel limit — $recorded recorded, limit $limit';
  }

  @override
  String verdictAboveVesselLimit(String recorded, String limit) {
    return 'Above the vessel limit — $recorded recorded, limit $limit';
  }

  @override
  String verdictVesselLimitNotRecorded(String limit) {
    return 'Nothing recorded for this vessel — the limit is $limit';
  }

  @override
  String get verdictNoRuleRecorded =>
      'No rule recorded for this species here. This does not mean it is legal.';

  @override
  String get verdictNoLimitInInstrument =>
      'The instrument was read and records no limit for this species here.';

  @override
  String get verdictUnknownSpecies =>
      'This species is not recorded for this jurisdiction. This does not mean it is legal.';

  @override
  String get verdictAmbiguous => 'Two rules of equal standing apply here.';

  @override
  String get findingFactMeasured => 'Measured';

  @override
  String get findingFactMinimum => 'Minimum';

  @override
  String get findingFactMaximum => 'Maximum';

  @override
  String get findingFactDates => 'Dates';

  @override
  String get findingFactToday => 'Today';

  @override
  String get findingFactRecorded => 'Recorded';

  @override
  String get findingFactLimit => 'Limit';

  @override
  String get findingFactPeriod => 'Period';

  @override
  String findingDayOfWindow(String day, String total) {
    return 'day $day of $total';
  }

  @override
  String findingWindowRange(String starts, String ends) {
    return '$starts to $ends';
  }

  @override
  String disclaimerVerdict(String authority) {
    return 'CatchLaw quotes published instruments. It is not legal advice and does not authorise any catch. Verify with $authority before relying on it.';
  }

  @override
  String get citationCopyAction => 'Copy the citation';

  @override
  String rulePackExpiredOn(String date) {
    return 'These rules passed their stated end date on $date. They are shown as published.';
  }

  @override
  String rulePackProvenance(String pack, String date) {
    return 'Bundled rule pack $pack passed its validity date on $date. The text above is the last verified wording.';
  }

  @override
  String get staleDetailClose => 'Close this note';

  @override
  String get flagRuleAction => 'Flag this rule';

  @override
  String get flagRuleNoteLabel => 'What the instrument says';

  @override
  String get flagRuleSaveAction => 'Save this note on this device';

  @override
  String get flagRuleRecorded => 'Saved on this device.';

  @override
  String get flagRuleEmptyNote => 'The note is empty.';

  @override
  String get disclaimerNotDismissable => 'It cannot be dismissed.';

  @override
  String get zonePickerTitle => 'Where are you fishing?';

  @override
  String get zoneLevelCountry => 'Country';

  @override
  String get zoneLevelRegion => 'Region';

  @override
  String get zoneLevelSubZone => 'Sub-zone';

  @override
  String get zoneWaterSalt => 'Sea';

  @override
  String get zoneWaterFresh => 'Inland water';

  @override
  String get zonePickerConfirm => 'Use this place';

  @override
  String get zonePickerEmptyHeadline => 'No rules bundled for this country';

  @override
  String get zonePickerEmptyBody =>
      'This build carries no transcribed instrument for it. That does not mean there are none.';

  @override
  String get zonePickerLoadFailed => 'The bundled rule pack could not be read.';

  @override
  String countryName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ES': 'Spain',
      'AE': 'United Arab Emirates',
      'BR': 'Brazil',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String zoneNoPublishedBoundaries(String authority) {
    return '$authority publishes no coordinate boundaries. The rules recorded here apply across the whole jurisdiction.';
  }
}
