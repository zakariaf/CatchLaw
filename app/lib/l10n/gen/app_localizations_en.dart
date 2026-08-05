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
  String speciesSearchMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matching results',
      one: '$count matching result',
    );
    return '$_temp0';
  }

  @override
  String get speciesSearchClear => 'Clear the search';

  @override
  String get browseByShapeTitle => 'Browse by shape';

  @override
  String get browseNoSpeciesHeadline => 'No species in this pack';

  @override
  String get browseNoSpeciesBody => 'This jurisdiction has no species transcribed yet.';

  @override
  String browseSpeciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count species',
      one: '$count species',
    );
    return '$_temp0';
  }

  @override
  String browseFamilyHeading(String family, int count) {
    return '$family · $count';
  }

  @override
  String browseMoreCount(int count) {
    return '+$count';
  }

  @override
  String browseMoreInFamily(String family) {
    return 'more in $family';
  }

  @override
  String get speciesOtherNames => 'Other names';

  @override
  String get speciesScientificName => 'Scientific name';

  @override
  String get speciesFamilyLabel => 'Family';

  @override
  String get speciesPlateSemanticLabel => 'Engraved plate';

  @override
  String get speciesSilhouetteSemanticLabel => 'Line drawing';

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
  String get verdictStampMeetsMinimum => 'Meets the minimum';

  @override
  String get verdictStampBelowMinimum => 'Below the minimum';

  @override
  String get verdictStampWithinMaximum => 'Within the maximum';

  @override
  String get verdictStampAboveMaximum => 'Above the maximum';

  @override
  String get verdictStampNotMeasured => 'Not measured';

  @override
  String get verdictStampMethodMismatch => 'Measured by another method';

  @override
  String verdictStampClosedSeason(String starts, String ends) {
    return 'Closed season — $starts to $ends';
  }

  @override
  String verdictDetailMinimum(String measured, String unit, String threshold, String method) {
    return '$measured $unit measured · minimum $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximum(String measured, String unit, String threshold, String method) {
    return '$measured $unit measured · maximum $threshold $unit · $method';
  }

  @override
  String verdictDetailMinimumUnmeasured(String threshold, String unit, String method) {
    return 'Nothing measured · minimum $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximumUnmeasured(String threshold, String unit, String method) {
    return 'Nothing measured · maximum $threshold $unit · $method';
  }

  @override
  String verdictDetailClosedSeasonInForce(String day, String total) {
    return 'In force today, day $day of $total · applies at every size';
  }

  @override
  String get verdictDetailClosedSeasonNotInForce => 'Not in force today';

  @override
  String speciesBinomialFamily(String binomial, String family) {
    return '$binomial — $family';
  }

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
  String get tripsKeptHere => 'Kept on this device only';

  @override
  String tripsCountStamp(int count) {
    return '$count trips';
  }

  @override
  String tripsRowSpan(String zone, String started, String ended) {
    return '$zone · $started — $ended';
  }

  @override
  String tripsRowSpanOpen(String zone, String started) {
    return '$zone · $started — now';
  }

  @override
  String get tripsOpenMark => '· open';

  @override
  String get tripsOpenStamp => 'Open';

  @override
  String tripsDuration(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get tripsLoadFailed => 'The trips on this device could not be read.';

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

  @override
  String get zoneWaterChoiceRequired =>
      'Sea or inland water has to be chosen before this place can answer.';

  @override
  String get navCheck => 'Check';

  @override
  String get destinationNotBuiltYet =>
      'This version answers one question: whether a fish meets the rules in the place it was landed. This part is not built yet.';

  @override
  String get settingsLanguageDevice => 'Follow the device';

  @override
  String get settingsDigits => 'Digits';

  @override
  String get settingsDigitsAuto => 'Automatic';

  @override
  String get settingsDigitsLatn => '0123';

  @override
  String get settingsDigitsArab => '٠١٢٣';

  @override
  String get settingsUnitCm => 'cm';

  @override
  String get settingsUnitMm => 'mm';

  @override
  String get settingsUnitIn => 'in';

  @override
  String get settingsLengthUnit => 'Length shown in';

  @override
  String get settingsSunlightMode => 'Sunlight mode';

  @override
  String get settingsSunlightNote => 'Maximum contrast, for a wet screen in glare.';

  @override
  String get settingsGloveMode => 'Glove mode';

  @override
  String get settingsGloveNote => 'Larger targets and wider spacing.';

  @override
  String get settingsGroupLanguage => 'Language and figures';

  @override
  String get settingsGroupPlace => 'Where you fish';

  @override
  String get settingsGroupReading => 'Reading conditions';

  @override
  String get settingsDigitsNote => 'Western or Arabic-Indic digits';

  @override
  String get settingsLengthUnitNote => 'Lengths on rules and readings';

  @override
  String get settingsZone => 'Zone';

  @override
  String get settingsZoneNote => 'Rules, species list and limits follow this';

  @override
  String get settingsZoneUnset => 'No place chosen';

  @override
  String settingsRulerScale(String px) {
    return '$px px / 10 millimetres';
  }

  @override
  String get settingsCoordinates => 'Coordinate capture';

  @override
  String get settingsCoordinatesNote => 'Held on this device only, never transmitted';

  @override
  String get settingsRuler => 'Ruler';

  @override
  String get settingsRulerUncalibrated => 'Not calibrated';

  @override
  String settingsRulerCalibrated(String on) {
    return 'Calibrated $on';
  }

  @override
  String get settingsAboutPack => 'Rule book';

  @override
  String get settingsOfflineNote =>
      'CatchLaw holds everything it needs on this phone. It has no account and no network code.';

  @override
  String get todayHeadline => 'Today';

  @override
  String get todayNothingRecorded => 'Nothing recorded today';

  @override
  String get todayNothingBody =>
      'A species you record from its page appears here, with the count for this place.';

  @override
  String get todayNoPlace => 'No place set';

  @override
  String todayCountKept(int count, int kept) {
    return '$count recorded · $kept kept';
  }

  @override
  String get tripsHeadline => 'Trips';

  @override
  String get tripsNone => 'No trips yet';

  @override
  String get tripsNoneBody =>
      'Starting a trip groups what you record into one outing. Everything stays on this phone.';

  @override
  String get tripsStart => 'Start a trip';

  @override
  String get tripsEnd => 'End this trip';

  @override
  String tripsRunning(String since) {
    return 'Running since $since';
  }

  @override
  String tripsEnded(String started, String ended) {
    return '$started — $ended';
  }

  @override
  String get catchRecord => 'Record this catch';

  @override
  String get catchRecorded => 'Recorded';

  @override
  String get measureTitle => 'Measure';

  @override
  String get measureUncalibrated => 'This screen is not calibrated';

  @override
  String get measureUncalibratedBody =>
      'A phone reports pixels, not millimetres, and the ratio differs by model. Until the screen is calibrated it cannot draw a ruler at true size. Typing a length works either way.';

  @override
  String get measureManualLabel => 'Or type the length';

  @override
  String get measureUse => 'Use this length';

  @override
  String get calibrateAction => 'Calibrate the screen';

  @override
  String get calibrateTitle => 'Calibrate';

  @override
  String get calibrateFitBody =>
      'Lay a bank card flat on the screen, left edge against the left edge of the box, and drag the black line to its right edge.';

  @override
  String get calibrateVerifyBody =>
      'Check the line against the card once more. If it sits on the edge, save.';

  @override
  String get calibrateVerifyAction => 'Check it';

  @override
  String get calibrateSaveAction => 'Save the calibration';

  @override
  String calibrateCardWidth(String mm) {
    return 'A bank card is $mm millimetres wide (ISO/IEC 7810 ID-1).';
  }

  @override
  String get calibrateImplausible =>
      'That scale is outside the plausible range for a phone screen, so it was not saved.';

  @override
  String get todayRemove => 'Remove';

  @override
  String get todayMarkKept => 'Kept';

  @override
  String get todayUndoOne => 'Remove one';

  @override
  String get measureSup => 'Ruler';

  @override
  String measureCalibrationProvenance(String on, String pxPer10mm) {
    return 'Calibrated $on · $pxPer10mm pixels per centimetre';
  }

  @override
  String get measureStepAndMark => 'Step and mark';

  @override
  String get measureRunningTotalUnit => 'cm so far';

  @override
  String measureStepPill(String count) {
    return 'Step $count';
  }

  @override
  String get measureStepNote =>
      'Lay the screen edge at the snout, mark, slide the phone along the fish and mark again.';

  @override
  String get measureTypeInstead => 'Type instead';

  @override
  String get measureRecalibrate => 'Re-calibrate with a card';

  @override
  String get measurePrivacyNote =>
      'Fish on the board, phone on the fish. No photograph is taken and no coordinate is read unless coordinate capture is switched on in Settings.';

  @override
  String get measureManualTitle => 'Type the length';

  @override
  String get calibrateSup => 'Once per device';

  @override
  String calibrateCardConstant(String width, String height) {
    return 'Every card of this format is identical: ISO/IEC 7810 ID-1 — $width × $height millimetres';
  }

  @override
  String calibrateDimension(String mm) {
    return '$mm millimetres';
  }

  @override
  String get calibrateDragHandleNote => 'Drag the filled handle.';

  @override
  String get calibrateScaleLabel => 'Resulting scale';

  @override
  String get calibrateRowScale => 'Pixels per centimetre';

  @override
  String get calibrateRowDensity => 'Screen density';

  @override
  String get calibrateRowError => 'Expected error';

  @override
  String get calibrateRowLastCalibrated => 'Last calibrated';

  @override
  String calibrateDensityValue(String dp, String ratio) {
    return '$dp dp · $ratio×';
  }

  @override
  String calibrateErrorValue(String mm) {
    return '± $mm millimetres over 30 centimetres';
  }

  @override
  String get calibrateNotYet => 'Not yet calibrated';

  @override
  String get calibrateReset => 'Reset to screen default';

  @override
  String get calibrateGlassNote =>
      'A case or a screen protector changes nothing — the card sits on the glass and the glass is what is being measured.';

  @override
  String get measureBackspace => 'Back';

  @override
  String get navBack => 'Back';

  @override
  String get navToday => 'Today';

  @override
  String get navTrips => 'Trips';

  @override
  String get navReference => 'Reference';

  @override
  String get navSettings => 'Settings';

  @override
  String get checkPlaceLabel => 'Answering for';

  @override
  String get checkChangePlace => 'Change place';

  @override
  String get checkRecentsLabel => 'Recent here';

  @override
  String checkPackChecked(String date) {
    return 'checked $date';
  }

  @override
  String get checkNoRecentsHeadline => 'Nothing checked here yet';

  @override
  String get checkNoRecentsBody =>
      'Species you look up in this place appear here, so the next one is one tap.';

  @override
  String measureManualReading(String mm) {
    return '$mm millimetres';
  }
}
