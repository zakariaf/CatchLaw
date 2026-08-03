// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'CatchLaw';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coincidencias',
      many: '$count coincidencias',
      one: '$count coincidencia',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystemDefault => 'Idioma del dispositivo';

  @override
  String get settingsNumeralSystem => 'Cifras';

  @override
  String get settingsNumeralSystemAuto => 'Valor predeterminado del idioma';

  @override
  String get settingsNumeralSystemLatn => 'Occidentales — 0 1 2 3';

  @override
  String get settingsNumeralSystemArab => 'Arábigo-índicas — ٠ ١ ٢ ٣';

  @override
  String legalTextLanguageNotice(String language) {
    return 'El texto literal de este instrumento existe únicamente en $language.';
  }

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ar': 'árabe',
      'en': 'inglés',
      'es': 'español',
      'gl': 'gallego',
      'ca': 'catalán',
      'ptBR': 'portugués de Brasil',
      'other': 'inglés',
    });
    return '$_temp0';
  }

  @override
  String get speciesSearchLabel => 'Especies';

  @override
  String get speciesSearchHint => 'mero, hamour, Epinephelus';

  @override
  String get speciesGroupInYourZone => 'En tu zona';

  @override
  String get speciesGroupElsewhere => 'En otro lugar de esta jurisdicción';

  @override
  String get speciesHintProtected => 'protegida';

  @override
  String get speciesHintClosed => 'veda';

  @override
  String get speciesNoMatchHeadline => 'Ninguna especie con ese nombre';

  @override
  String get speciesNoMatchBody =>
      'El nombre puede escribirse de otra forma aquí, o la especie puede no estar transcrita todavía.';

  @override
  String get identifyThisFish => 'Identificar este pez';

  @override
  String get browseByShape => 'Explorar por forma';

  @override
  String get rulePackExpired =>
      'Estas normas superaron su fecha de fin declarada. Se muestran tal como se publicaron.';

  @override
  String speciesSearchResultCount(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de $total',
      many: '$count de $total',
      one: '$count de $total',
    );
    return '$_temp0';
  }

  @override
  String get browseByShapeTitle => 'Explorar por forma';

  @override
  String get browseNoSpeciesHeadline => 'Ninguna especie en este paquete';

  @override
  String get browseNoSpeciesBody => 'Esta jurisdicción todavía no tiene especies transcritas.';

  @override
  String get speciesOtherNames => 'Otros nombres';

  @override
  String get speciesScientificName => 'Nombre científico';

  @override
  String get speciesFamilyLabel => 'Familia';

  @override
  String get speciesPlateSemanticLabel => 'Lámina grabada';

  @override
  String get speciesProtectedAnywhere => 'Protegida en algún lugar de esta jurisdicción';

  @override
  String get lookAlikeSectionLabel => 'Se confunde fácilmente con';

  @override
  String get lookAlikeConfusedWith => 'Qué las diferencia';

  @override
  String get recentsStripLabel => 'Recientes aquí';

  @override
  String get recentsEmptyBody => 'Las especies que abras en esta zona aparecen aquí.';

  @override
  String get calibrationTitle => 'Mide tu pantalla';

  @override
  String get calibrationCardExplainer =>
      'Coloca cualquier tarjeta bancaria, carné o DNI sobre el cristal y arrastra el borde hasta hacerlo coincidir.';

  @override
  String get calibrationHandleLabel => 'Borde de la tarjeta';

  @override
  String calibrationVerifyExplainer(String measurement) {
    return 'Esta barra mide $measurement. Compárala con el lado corto de la misma tarjeta.';
  }

  @override
  String calibrationVerifyBarLabel(String measurement) {
    return '$measurement';
  }

  @override
  String get calibrationSaveAction => 'Guardar esta medida';

  @override
  String get calibrationCancelAction => 'Un paso atrás';

  @override
  String get calibrationTooSmallScreen =>
      'Esta pantalla es más estrecha que una tarjeta. La entrada manual está disponible.';

  @override
  String calibrationImplausible(String measurement) {
    return 'Ese arrastre midió $measurement de pantalla, que no es una tarjeta.';
  }

  @override
  String get unitMillimetres => 'mm';

  @override
  String get unitCentimetres => 'cm';

  @override
  String rulerSemanticLabel(String measurement) {
    return 'Regla. Lectura $measurement.';
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
    return '$value pulg ($method)';
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
      '1': 'enero',
      '2': 'febrero',
      '3': 'marzo',
      '4': 'abril',
      '5': 'mayo',
      '6': 'junio',
      '7': 'julio',
      '8': 'agosto',
      '9': 'septiembre',
      '10': 'octubre',
      '11': 'noviembre',
      '12': 'diciembre',
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
    return 'Cumple el mínimo — $measured $unit medidos, mínimo $threshold $unit ($method)';
  }

  @override
  String verdictBelowMinimum(String measured, String unit, String threshold, String method) {
    return 'Por debajo del mínimo — $measured $unit medidos, mínimo $threshold $unit ($method)';
  }

  @override
  String verdictWithinMaximum(String measured, String unit, String threshold, String method) {
    return 'Dentro del máximo — $measured $unit medidos, máximo $threshold $unit ($method)';
  }

  @override
  String verdictAboveMaximum(String measured, String unit, String threshold, String method) {
    return 'Por encima del máximo — $measured $unit medidos, máximo $threshold $unit ($method)';
  }

  @override
  String verdictMinimumNotMeasured(String threshold, String unit, String method) {
    return 'Sin medición — el mínimo es $threshold $unit ($method)';
  }

  @override
  String verdictMaximumNotMeasured(String threshold, String unit, String method) {
    return 'Sin medición — el máximo es $threshold $unit ($method)';
  }

  @override
  String verdictSizeMethodMismatch(
    String measuredMethod,
    String threshold,
    String unit,
    String method,
  ) {
    return 'Medido por $measuredMethod — la norma indica $threshold $unit ($method). No se realiza ninguna comparación.';
  }

  @override
  String verdictMarginShortOfMinimum(String margin, String unit) {
    return 'Por debajo del mínimo en $margin $unit';
  }

  @override
  String verdictMarginOverMinimum(String margin, String unit) {
    return 'Por encima del mínimo en $margin $unit';
  }

  @override
  String verdictMarginOverMaximum(String margin, String unit) {
    return 'Por encima del máximo en $margin $unit';
  }

  @override
  String verdictMarginUnderMaximum(String margin, String unit) {
    return 'Por debajo del máximo en $margin $unit';
  }

  @override
  String verdictClosedSeasonInForce(String starts, String ends, String day, String total) {
    return 'Veda — del $starts al $ends. En vigor hoy, día $day de $total.';
  }

  @override
  String verdictClosedSeasonNotInForce(String starts, String ends) {
    return 'Veda — del $starts al $ends. Hoy no está en vigor.';
  }

  @override
  String get verdictProtected => 'Especie protegida — captura prohibida.';

  @override
  String verdictWithinBagLimit(String recorded, String limit, String period) {
    return 'Dentro del cupo — $recorded registrados, límite $limit por $period';
  }

  @override
  String verdictAboveBagLimit(String recorded, String limit, String period) {
    return 'Por encima del cupo — $recorded registrados, límite $limit por $period';
  }

  @override
  String verdictBagLimitNotRecorded(String limit, String period) {
    return 'Nada registrado en este periodo — el cupo es $limit por $period';
  }

  @override
  String verdictWithinVesselLimit(String recorded, String limit) {
    return 'Dentro del límite por embarcación — $recorded registrados, límite $limit';
  }

  @override
  String verdictAboveVesselLimit(String recorded, String limit) {
    return 'Por encima del límite por embarcación — $recorded registrados, límite $limit';
  }

  @override
  String verdictVesselLimitNotRecorded(String limit) {
    return 'Nada registrado para esta embarcación — el límite es $limit';
  }

  @override
  String get verdictNoRuleRecorded =>
      'No hay ninguna norma registrada para esta especie aquí. Esto no significa que sea legal.';

  @override
  String get verdictNoLimitInInstrument =>
      'La norma fue consultada y no registra ningún límite para esta especie aquí.';

  @override
  String get verdictUnknownSpecies =>
      'Esta especie no está registrada en esta jurisdicción. Esto no significa que sea legal.';

  @override
  String get verdictAmbiguous => 'Aquí se aplican dos normas del mismo rango.';

  @override
  String get findingFactMeasured => 'Medido';

  @override
  String get findingFactMinimum => 'Mínimo';

  @override
  String get findingFactMaximum => 'Máximo';

  @override
  String get findingFactDates => 'Fechas';

  @override
  String get findingFactToday => 'Hoy';

  @override
  String get findingFactRecorded => 'Registrado';

  @override
  String get findingFactLimit => 'Límite';

  @override
  String get findingFactPeriod => 'Periodo';

  @override
  String findingDayOfWindow(String day, String total) {
    return 'día $day de $total';
  }

  @override
  String findingWindowRange(String starts, String ends) {
    return 'del $starts al $ends';
  }

  @override
  String disclaimerVerdict(String authority) {
    return 'CatchLaw cita normas publicadas. No es asesoramiento jurídico ni autoriza ninguna captura. Conviene verificarlo con $authority antes de basarse en ello.';
  }
}
