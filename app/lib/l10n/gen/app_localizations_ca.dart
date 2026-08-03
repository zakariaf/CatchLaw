// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'CatchLaw';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coincidències',
      many: '$count coincidències',
      one: '$count coincidència',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystemDefault => 'Idioma del dispositiu';

  @override
  String get settingsNumeralSystem => 'Xifres';

  @override
  String get settingsNumeralSystemAuto => 'Valor predeterminat de l’idioma';

  @override
  String get settingsNumeralSystemLatn => 'Occidentals — 0 1 2 3';

  @override
  String get settingsNumeralSystemArab => 'Aràbigo-índiques — ٠ ١ ٢ ٣';

  @override
  String legalTextLanguageNotice(String language) {
    return 'El text literal d’aquest instrument existeix únicament en $language.';
  }

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ar': 'àrab',
      'en': 'anglès',
      'es': 'castellà',
      'gl': 'gallec',
      'ca': 'català',
      'ptBR': 'portuguès del Brasil',
      'other': 'anglès',
    });
    return '$_temp0';
  }

  @override
  String get speciesSearchLabel => 'Espècies';

  @override
  String get speciesSearchHint => 'anfós, mero, Epinephelus';

  @override
  String get speciesGroupInYourZone => 'A la teva zona';

  @override
  String get speciesGroupElsewhere => 'En un altre lloc d’aquesta jurisdicció';

  @override
  String get speciesHintProtected => 'protegida';

  @override
  String get speciesHintClosed => 'veda';

  @override
  String get speciesNoMatchHeadline => 'Cap espècie amb aquest nom';

  @override
  String get speciesNoMatchBody =>
      'El nom es pot escriure d’una altra manera aquí, o l’espècie pot no estar transcrita encara.';

  @override
  String get identifyThisFish => 'Identificar aquest peix';

  @override
  String get browseByShape => 'Explorar per forma';

  @override
  String get rulePackExpired =>
      'Aquestes normes han superat la data de fi declarada. Es mostren tal com es van publicar.';

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
  String get browseByShapeTitle => 'Explorar per forma';

  @override
  String get browseNoSpeciesHeadline => 'Cap espècie en aquest paquet';

  @override
  String get browseNoSpeciesBody => 'Aquesta jurisdicció encara no té espècies transcrites.';

  @override
  String get speciesOtherNames => 'Altres noms';

  @override
  String get speciesScientificName => 'Nom científic';

  @override
  String get speciesFamilyLabel => 'Família';

  @override
  String get speciesPlateSemanticLabel => 'Làmina gravada';

  @override
  String get speciesProtectedAnywhere => 'Protegida en algun lloc d’aquesta jurisdicció';

  @override
  String get lookAlikeSectionLabel => 'Es confon fàcilment amb';

  @override
  String get lookAlikeConfusedWith => 'Què les diferencia';

  @override
  String get recentsStripLabel => 'Recents aquí';

  @override
  String get recentsEmptyBody => 'Les espècies que obris en aquesta zona apareixen aquí.';

  @override
  String get calibrationTitle => 'Mesura la pantalla';

  @override
  String get calibrationCardExplainer =>
      'Posa qualsevol targeta bancària, carnet o DNI sobre el vidre i arrossega la vora fins a fer-la coincidir.';

  @override
  String get calibrationHandleLabel => 'Vora de la targeta';

  @override
  String calibrationVerifyExplainer(String measurement) {
    return 'Aquesta barra fa $measurement. Compara-la amb el costat curt de la mateixa targeta.';
  }

  @override
  String calibrationVerifyBarLabel(String measurement) {
    return '$measurement';
  }

  @override
  String get calibrationSaveAction => 'Desa aquesta mesura';

  @override
  String get calibrationCancelAction => 'Un pas enrere';

  @override
  String get calibrationTooSmallScreen =>
      'Aquesta pantalla és més estreta que una targeta. L’entrada manual està disponible.';

  @override
  String calibrationImplausible(String measurement) {
    return 'Aquest arrossegament ha mesurat $measurement de pantalla, que no és una targeta.';
  }

  @override
  String get unitMillimetres => 'mm';

  @override
  String get unitCentimetres => 'cm';

  @override
  String rulerSemanticLabel(String measurement) {
    return 'Regle. Lectura $measurement.';
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
    return '$value polz ($method)';
  }

  @override
  String massKg(String value) {
    return '$value kg';
  }

  @override
  String get limitPeriodDay => 'dia';

  @override
  String get limitPeriodTrip => 'marea';

  @override
  String get limitPeriodSeason => 'temporada';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'gener',
      '2': 'febrer',
      '3': 'març',
      '4': 'abril',
      '5': 'maig',
      '6': 'juny',
      '7': 'juliol',
      '8': 'agost',
      '9': 'setembre',
      '10': 'octubre',
      '11': 'novembre',
      '12': 'desembre',
      'other': '$month',
    });
    return '$_temp0';
  }

  @override
  String dateDayMonth(String day, String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'abril': '$day d\'abril',
      'agost': '$day d\'agost',
      'octubre': '$day d\'octubre',
      'other': '$day de $month',
    });
    return '$_temp0';
  }

  @override
  String verdictMeetsMinimum(String measured, String unit, String threshold, String method) {
    return 'Compleix el mínim — $measured $unit mesurats, mínim $threshold $unit ($method)';
  }

  @override
  String verdictBelowMinimum(String measured, String unit, String threshold, String method) {
    return 'Per sota del mínim — $measured $unit mesurats, mínim $threshold $unit ($method)';
  }

  @override
  String verdictWithinMaximum(String measured, String unit, String threshold, String method) {
    return 'Dins del màxim — $measured $unit mesurats, màxim $threshold $unit ($method)';
  }

  @override
  String verdictAboveMaximum(String measured, String unit, String threshold, String method) {
    return 'Per sobre del màxim — $measured $unit mesurats, màxim $threshold $unit ($method)';
  }

  @override
  String verdictMinimumNotMeasured(String threshold, String unit, String method) {
    return 'Sense mesura — el mínim és $threshold $unit ($method)';
  }

  @override
  String verdictMaximumNotMeasured(String threshold, String unit, String method) {
    return 'Sense mesura — el màxim és $threshold $unit ($method)';
  }

  @override
  String verdictSizeMethodMismatch(
    String measuredMethod,
    String threshold,
    String unit,
    String method,
  ) {
    return 'Mesurat per $measuredMethod — la norma indica $threshold $unit ($method). No es fa cap comparació.';
  }

  @override
  String verdictMarginShortOfMinimum(String margin, String unit) {
    return 'Per sota del mínim en $margin $unit';
  }

  @override
  String verdictMarginOverMinimum(String margin, String unit) {
    return 'Per sobre del mínim en $margin $unit';
  }

  @override
  String verdictMarginOverMaximum(String margin, String unit) {
    return 'Per sobre del màxim en $margin $unit';
  }

  @override
  String verdictMarginUnderMaximum(String margin, String unit) {
    return 'Per sota del màxim en $margin $unit';
  }

  @override
  String verdictClosedSeasonInForce(String starts, String ends, String day, String total) {
    return 'Veda — del $starts al $ends. Vigent avui, dia $day de $total.';
  }

  @override
  String verdictClosedSeasonNotInForce(String starts, String ends) {
    return 'Veda — del $starts al $ends. Avui no és vigent.';
  }

  @override
  String get verdictProtected => 'Espècie protegida — captura prohibida.';

  @override
  String verdictWithinBagLimit(String recorded, String limit, String period) {
    return 'Dins de la quota — $recorded registrats, límit $limit per $period';
  }

  @override
  String verdictAboveBagLimit(String recorded, String limit, String period) {
    return 'Per sobre de la quota — $recorded registrats, límit $limit per $period';
  }

  @override
  String verdictBagLimitNotRecorded(String limit, String period) {
    return 'Res registrat en aquest període — la quota és $limit per $period';
  }

  @override
  String verdictWithinVesselLimit(String recorded, String limit) {
    return 'Dins del límit per embarcació — $recorded registrats, límit $limit';
  }

  @override
  String verdictAboveVesselLimit(String recorded, String limit) {
    return 'Per sobre del límit per embarcació — $recorded registrats, límit $limit';
  }

  @override
  String verdictVesselLimitNotRecorded(String limit) {
    return 'Res registrat per a aquesta embarcació — el límit és $limit';
  }

  @override
  String get verdictNoRuleRecorded =>
      'No hi ha cap norma registrada per a aquesta espècie aquí. Això no vol dir que sigui legal.';

  @override
  String get verdictNoLimitInInstrument =>
      'La norma s\'ha consultat i no registra cap límit per a aquesta espècie aquí.';

  @override
  String get verdictUnknownSpecies =>
      'Aquesta espècie no està registrada en aquesta jurisdicció. Això no vol dir que sigui legal.';

  @override
  String get verdictAmbiguous => 'Aquí s\'apliquen dues normes del mateix rang.';

  @override
  String get findingFactMeasured => 'Mesurat';

  @override
  String get findingFactMinimum => 'Mínim';

  @override
  String get findingFactMaximum => 'Màxim';

  @override
  String get findingFactDates => 'Dates';

  @override
  String get findingFactToday => 'Avui';

  @override
  String get findingFactRecorded => 'Registrat';

  @override
  String get findingFactLimit => 'Límit';

  @override
  String get findingFactPeriod => 'Període';

  @override
  String findingDayOfWindow(String day, String total) {
    return 'dia $day de $total';
  }

  @override
  String findingWindowRange(String starts, String ends) {
    return 'del $starts al $ends';
  }

  @override
  String disclaimerVerdict(String authority) {
    return 'CatchLaw cita normes publicades. No és assessorament jurídic ni autoritza cap captura. Convé verificar-ho amb $authority abans de confiar-hi.';
  }

  @override
  String get citationCopyAction => 'Copia la citació';

  @override
  String rulePackExpiredOn(String date) {
    return 'Aquestes normes van passar la seva data de fi el $date. Es mostren tal com es van publicar.';
  }

  @override
  String rulePackProvenance(String pack, String date) {
    return 'El paquet de normes inclòs $pack va passar la seva data de validesa el $date. El text anterior és l’última redacció verificada.';
  }

  @override
  String get staleDetailClose => 'Tanca aquesta nota';

  @override
  String get flagRuleAction => 'Marca aquesta norma';

  @override
  String get flagRuleNoteLabel => 'Què diu la norma';

  @override
  String get flagRuleSaveAction => 'Desa aquesta nota en aquest dispositiu';

  @override
  String get flagRuleRecorded => 'Desada en aquest dispositiu.';

  @override
  String get flagRuleEmptyNote => 'La nota és buida.';

  @override
  String get disclaimerNotDismissable => 'No es pot descartar.';
}
