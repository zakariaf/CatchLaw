// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get appTitle => 'CatchLaw';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coincidencias',
      one: '$count coincidencia',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystemDefault => 'Idioma do dispositivo';

  @override
  String get settingsNumeralSystem => 'Cifras';

  @override
  String get settingsNumeralSystemAuto => 'Valor predeterminado do idioma';

  @override
  String get settingsNumeralSystemLatn => 'Occidentais — 0 1 2 3';

  @override
  String get settingsNumeralSystemArab => 'Arábigo-índicas — ٠ ١ ٢ ٣';

  @override
  String legalTextLanguageNotice(String language) {
    return 'O texto literal deste instrumento existe unicamente en $language.';
  }

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ar': 'árabe',
      'en': 'inglés',
      'es': 'castelán',
      'gl': 'galego',
      'ca': 'catalán',
      'ptBR': 'portugués do Brasil',
      'other': 'inglés',
    });
    return '$_temp0';
  }

  @override
  String get speciesSearchLabel => 'Especies';

  @override
  String get speciesSearchHint => 'mero, ameixa, Epinephelus';

  @override
  String get speciesGroupInYourZone => 'Na túa zona';

  @override
  String get speciesGroupElsewhere => 'Noutro lugar desta xurisdición';

  @override
  String get speciesHintProtected => 'protexida';

  @override
  String get speciesHintClosed => 'veda';

  @override
  String get speciesNoMatchHeadline => 'Ningunha especie con ese nome';

  @override
  String get speciesNoMatchBody =>
      'O nome pode escribirse doutro xeito aquí, ou a especie pode non estar transcrita aínda.';

  @override
  String get identifyThisFish => 'Identificar este peixe';

  @override
  String get browseByShape => 'Explorar por forma';

  @override
  String get rulePackExpired =>
      'Estas normas superaron a súa data de fin declarada. Amósanse tal como se publicaron.';

  @override
  String speciesSearchResultCount(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de $total',
      one: '$count de $total',
    );
    return '$_temp0';
  }

  @override
  String get browseByShapeTitle => 'Explorar por forma';

  @override
  String get browseNoSpeciesHeadline => 'Ningunha especie neste paquete';

  @override
  String get browseNoSpeciesBody => 'Esta xurisdición aínda non ten especies transcritas.';

  @override
  String get speciesOtherNames => 'Outros nomes';

  @override
  String get speciesScientificName => 'Nome científico';

  @override
  String get speciesFamilyLabel => 'Familia';

  @override
  String get speciesPlateSemanticLabel => 'Lámina gravada';

  @override
  String get speciesProtectedAnywhere => 'Protexida nalgún lugar desta xurisdición';

  @override
  String get lookAlikeSectionLabel => 'Confúndese doadamente con';

  @override
  String get lookAlikeConfusedWith => 'Que as diferencia';

  @override
  String get recentsStripLabel => 'Recentes aquí';

  @override
  String get recentsEmptyBody => 'As especies que abras nesta zona aparecen aquí.';

  @override
  String get calibrationTitle => 'Mide a túa pantalla';

  @override
  String get calibrationCardExplainer =>
      'Pon calquera tarxeta bancaria, carné ou DNI sobre o cristal e arrastra o bordo ata facelo coincidir.';

  @override
  String get calibrationHandleLabel => 'Bordo da tarxeta';

  @override
  String calibrationVerifyExplainer(String measurement) {
    return 'Esta barra mide $measurement. Compáraa co lado curto da mesma tarxeta.';
  }

  @override
  String calibrationVerifyBarLabel(String measurement) {
    return '$measurement';
  }

  @override
  String get calibrationSaveAction => 'Gardar esta medida';

  @override
  String get calibrationCancelAction => 'Un paso atrás';

  @override
  String get calibrationTooSmallScreen =>
      'Esta pantalla é máis estreita ca unha tarxeta. A entrada manual está dispoñible.';

  @override
  String calibrationImplausible(String measurement) {
    return 'Ese arrastre mediu $measurement de pantalla, que non é unha tarxeta.';
  }

  @override
  String get unitMillimetres => 'mm';

  @override
  String get unitCentimetres => 'cm';

  @override
  String rulerSemanticLabel(String measurement) {
    return 'Regra. Lectura $measurement.';
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
    return '$value pol ($method)';
  }

  @override
  String massKg(String value) {
    return '$value kg';
  }

  @override
  String get limitPeriodDay => 'día';

  @override
  String get limitPeriodTrip => 'marea';

  @override
  String get limitPeriodSeason => 'temporada';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'xaneiro',
      '2': 'febreiro',
      '3': 'marzo',
      '4': 'abril',
      '5': 'maio',
      '6': 'xuño',
      '7': 'xullo',
      '8': 'agosto',
      '9': 'setembro',
      '10': 'outubro',
      '11': 'novembro',
      '12': 'decembro',
      'other': '$month',
    });
    return '$_temp0';
  }

  @override
  String dateDayMonth(String day, String month) {
    return '$day de $month';
  }

  @override
  String verdictMeetsMinimum(String measured, String unit, String threshold, String method) {
    return 'Cumpre o mínimo — $measured $unit medidos, mínimo $threshold $unit ($method)';
  }

  @override
  String verdictBelowMinimum(String measured, String unit, String threshold, String method) {
    return 'Por debaixo do mínimo — $measured $unit medidos, mínimo $threshold $unit ($method)';
  }

  @override
  String verdictWithinMaximum(String measured, String unit, String threshold, String method) {
    return 'Dentro do máximo — $measured $unit medidos, máximo $threshold $unit ($method)';
  }

  @override
  String verdictAboveMaximum(String measured, String unit, String threshold, String method) {
    return 'Por riba do máximo — $measured $unit medidos, máximo $threshold $unit ($method)';
  }

  @override
  String verdictMinimumNotMeasured(String threshold, String unit, String method) {
    return 'Sen medición — o mínimo é $threshold $unit ($method)';
  }

  @override
  String verdictMaximumNotMeasured(String threshold, String unit, String method) {
    return 'Sen medición — o máximo é $threshold $unit ($method)';
  }

  @override
  String verdictSizeMethodMismatch(
    String measuredMethod,
    String threshold,
    String unit,
    String method,
  ) {
    return 'Medido por $measuredMethod — a norma indica $threshold $unit ($method). Non se fai ningunha comparación.';
  }

  @override
  String verdictMarginShortOfMinimum(String margin, String unit) {
    return 'Por debaixo do mínimo en $margin $unit';
  }

  @override
  String verdictMarginOverMinimum(String margin, String unit) {
    return 'Por riba do mínimo en $margin $unit';
  }

  @override
  String verdictMarginOverMaximum(String margin, String unit) {
    return 'Por riba do máximo en $margin $unit';
  }

  @override
  String verdictMarginUnderMaximum(String margin, String unit) {
    return 'Por debaixo do máximo en $margin $unit';
  }

  @override
  String verdictClosedSeasonInForce(String starts, String ends, String day, String total) {
    return 'Veda — do $starts ao $ends. En vigor hoxe, día $day de $total.';
  }

  @override
  String verdictClosedSeasonNotInForce(String starts, String ends) {
    return 'Veda — do $starts ao $ends. Hoxe non está en vigor.';
  }

  @override
  String get verdictProtected => 'Especie protexida — captura prohibida.';

  @override
  String verdictWithinBagLimit(String recorded, String limit, String period) {
    return 'Dentro do cupo — $recorded rexistrados, límite $limit por $period';
  }

  @override
  String verdictAboveBagLimit(String recorded, String limit, String period) {
    return 'Por riba do cupo — $recorded rexistrados, límite $limit por $period';
  }

  @override
  String verdictBagLimitNotRecorded(String limit, String period) {
    return 'Nada rexistrado neste período — o cupo é $limit por $period';
  }

  @override
  String verdictWithinVesselLimit(String recorded, String limit) {
    return 'Dentro do límite por embarcación — $recorded rexistrados, límite $limit';
  }

  @override
  String verdictAboveVesselLimit(String recorded, String limit) {
    return 'Por riba do límite por embarcación — $recorded rexistrados, límite $limit';
  }

  @override
  String verdictVesselLimitNotRecorded(String limit) {
    return 'Nada rexistrado para esta embarcación — o límite é $limit';
  }

  @override
  String get verdictNoRuleRecorded =>
      'Non hai ningunha norma rexistrada para esta especie aquí. Isto non significa que sexa legal.';

  @override
  String get verdictNoLimitInInstrument =>
      'A norma foi consultada e non rexistra ningún límite para esta especie aquí.';

  @override
  String get verdictUnknownSpecies =>
      'Esta especie non está rexistrada nesta xurisdición. Isto non significa que sexa legal.';

  @override
  String get verdictAmbiguous => 'Aquí aplícanse dúas normas do mesmo rango.';

  @override
  String get findingFactMeasured => 'Medido';

  @override
  String get findingFactMinimum => 'Mínimo';

  @override
  String get findingFactMaximum => 'Máximo';

  @override
  String get findingFactDates => 'Datas';

  @override
  String get findingFactToday => 'Hoxe';

  @override
  String get findingFactRecorded => 'Rexistrado';

  @override
  String get findingFactLimit => 'Límite';

  @override
  String get findingFactPeriod => 'Período';

  @override
  String findingDayOfWindow(String day, String total) {
    return 'día $day de $total';
  }

  @override
  String findingWindowRange(String starts, String ends) {
    return 'do $starts ao $ends';
  }

  @override
  String disclaimerVerdict(String authority) {
    return 'CatchLaw cita normas publicadas. Non é asesoramento xurídico nin autoriza ningunha captura. Convén verificalo con $authority antes de confiar nel.';
  }

  @override
  String get citationCopyAction => 'Copiar a cita';

  @override
  String rulePackExpiredOn(String date) {
    return 'Estas normas pasaron a súa data de fin o $date. Amósanse tal como se publicaron.';
  }

  @override
  String rulePackProvenance(String pack, String date) {
    return 'O paquete de normas incluído $pack pasou a súa data de validez o $date. O texto anterior é a última redacción verificada.';
  }

  @override
  String get staleDetailClose => 'Pechar esta nota';

  @override
  String get flagRuleAction => 'Marcar esta norma';

  @override
  String get flagRuleNoteLabel => 'Que di a norma';

  @override
  String get flagRuleSaveAction => 'Gardar esta nota neste dispositivo';

  @override
  String get flagRuleRecorded => 'Gardada neste dispositivo.';

  @override
  String get flagRuleEmptyNote => 'A nota está baleira.';

  @override
  String get disclaimerNotDismissable => 'Non se pode descartar.';

  @override
  String get zonePickerTitle => 'Onde pescas?';

  @override
  String get zoneLevelCountry => 'País';

  @override
  String get zoneLevelRegion => 'Rexión';

  @override
  String get zoneLevelSubZone => 'Subzona';

  @override
  String get zoneWaterSalt => 'Mar';

  @override
  String get zoneWaterFresh => 'Augas continentais';

  @override
  String get zonePickerConfirm => 'Usar este lugar';

  @override
  String get zonePickerEmptyHeadline => 'Non hai normas incluídas para este país';

  @override
  String get zonePickerEmptyBody =>
      'Esta versión non leva ningunha norma transcrita. Isto non significa que non existan.';

  @override
  String get zonePickerLoadFailed => 'Non se puido ler o paquete de normas incluído.';

  @override
  String countryName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ES': 'España',
      'AE': 'Emiratos Árabes Unidos',
      'BR': 'Brasil',
      'other': '$code',
    });
    return '$_temp0';
  }
}
