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
  String identifyKeyStamp(int couplet) {
    return 'Clau · pas $couplet';
  }

  @override
  String get identifyAnswersSoFar => 'Respostes fins ara';

  @override
  String identifyCoupletLabel(int couplet) {
    return 'Pas $couplet';
  }

  @override
  String identifySpeciesRemain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'queden $count espècies',
      many: 'queden $count espècies',
      one: 'queda $count espècie',
    );
    return '$_temp0';
  }

  @override
  String identifyLeadMark(int couplet, int lead) {
    return '$couplet · $lead';
  }

  @override
  String identifyLeadConsequence(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Porta a $count espècies · $names',
      many: 'Porta a $count espècies · $names',
      one: 'Porta a $count espècie · $names',
    );
    return '$_temp0';
  }

  @override
  String get identifyLeadNoSpecies =>
      'No hi ha espècies registrades més enllà d\'aquesta resposta.';

  @override
  String get identifyBackOneStep => 'Retrocedir un pas';

  @override
  String get identifyDamagedHeading => 'Si el caràcter no es veu';

  @override
  String get identifyDamagedNote =>
      'Un caràcter malmès o absent no es pot respondre. En el seu lloc s\'enumeren, dibuixades i anomenades, totes les espècies que aquest pas encara permet.';

  @override
  String get identifyListWhatRemains => 'Enumerar el que queda';

  @override
  String get identifyProvenanceNote =>
      'No es pren cap fotografia i res no surt del dispositiu. La clau és la impresa de la secció de referència, recorreguda pas a pas.';

  @override
  String get identifyRemainingHeading => 'Espècies que la clau encara permet';

  @override
  String get identifyNoKeyHeadline => 'Cap clau en aquest paquet';

  @override
  String get identifyNoKeyBody =>
      'Aquesta jurisdicció no té cap clau d\'identificació transcrita. Les espècies que porta aquest paquet s\'assoleixen pel seu nom.';

  @override
  String get identifyNoCandidatesHeadline => 'Cap espècie registrada aquí';

  @override
  String get identifyNoCandidatesBody =>
      'La clau no assoleix cap espècie amb les respostes donades. Més enllà d\'aquest punt no hi ha res transcrit en aquest paquet.';

  @override
  String get identifyKeyUnreadableHeadline => 'No s\'ha pogut llegir la clau';

  @override
  String get identifyKeyUnreadableBody =>
      'La clau del paquet inclòs no s\'ha obert en aquest dispositiu. Les espècies que porta s\'assoleixen pel seu nom.';

  @override
  String get identifySearchByName => 'Cercar pel nom';

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
  String speciesSearchMatchCount(int count) {
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
  String get speciesSearchClear => 'Esborrar la cerca';

  @override
  String get browseByShapeTitle => 'Explorar per forma';

  @override
  String get browseNoSpeciesHeadline => 'Cap espècie en aquest paquet';

  @override
  String get browseNoSpeciesBody => 'Aquesta jurisdicció encara no té espècies transcrites.';

  @override
  String browseSpeciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espècies',
      many: '$count espècies',
      one: '$count espècie',
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
    return 'més a $family';
  }

  @override
  String get speciesOtherNames => 'Altres noms';

  @override
  String get speciesScientificName => 'Nom científic';

  @override
  String get speciesFamilyLabel => 'Família';

  @override
  String get speciesPlateSemanticLabel => 'Làmina gravada';

  @override
  String get speciesSilhouetteSemanticLabel => 'Dibuix lineal';

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
  String get verdictStampMeetsMinimum => 'Compleix el mínim';

  @override
  String get verdictStampBelowMinimum => 'Per sota del mínim';

  @override
  String get verdictStampWithinMaximum => 'Dins del màxim';

  @override
  String get verdictStampAboveMaximum => 'Per sobre del màxim';

  @override
  String get verdictStampNotMeasured => 'Sense mesurar';

  @override
  String get verdictStampMethodMismatch => 'Mesurat amb un altre mètode';

  @override
  String verdictStampClosedSeason(String starts, String ends) {
    return 'Veda — del $starts al $ends';
  }

  @override
  String verdictDetailMinimum(String measured, String unit, String threshold, String method) {
    return '$measured $unit mesurats · mínim $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximum(String measured, String unit, String threshold, String method) {
    return '$measured $unit mesurats · màxim $threshold $unit · $method';
  }

  @override
  String verdictDetailMinimumUnmeasured(String threshold, String unit, String method) {
    return 'Sense mesura · mínim $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximumUnmeasured(String threshold, String unit, String method) {
    return 'Sense mesura · màxim $threshold $unit · $method';
  }

  @override
  String verdictDetailClosedSeasonInForce(String day, String total) {
    return 'Vigent avui, dia $day de $total · s\'aplica a totes les talles';
  }

  @override
  String get verdictDetailClosedSeasonNotInForce => 'Avui no és vigent';

  @override
  String speciesBinomialFamily(String binomial, String family) {
    return '$binomial — $family';
  }

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
  String get ambiguityEyebrow => 'Conflicte d\'instruments';

  @override
  String get ambiguityBothInForce =>
      'Tots dos instruments són en vigor en aquest punt. CatchLaw imprimeix el text de cadascun amb la seva pròpia data de comprovació i no situa cap per damunt de l\'altre.';

  @override
  String get findingFactMeasured => 'Mesurat';

  @override
  String get findingFactMinimum => 'Mínim';

  @override
  String get findingFactMaximum => 'Màxim';

  @override
  String get findingFactShortfall => 'Diferència';

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
  String get penaltiesTitle => 'Sancions';

  @override
  String get penaltiesEntryNote => 'El que comporta l\'incompliment de les regles registrades.';

  @override
  String penaltiesLede(String jurisdiction) {
    return 'El que comporta l\'incompliment de les regles de talla, veda, protecció o art a $jurisdiction.';
  }

  @override
  String get penaltiesColumnOffence => 'Infracció';

  @override
  String get penaltiesColumnFine => 'Multa';

  @override
  String get penaltiesColumnLicence => 'Llicència';

  @override
  String get penaltiesOccurrenceFirst => 'Primera infracció';

  @override
  String get penaltiesOccurrenceSecond => 'Segona infracció';

  @override
  String get penaltiesOccurrenceSubsequent => 'Infracció posterior';

  @override
  String get penaltiesOffenceListLabel => 'Infraccions registrades';

  @override
  String penaltiesFineAmount(String currency, String amount) {
    return '$amount $currency';
  }

  @override
  String penaltiesFineRange(String currency, String lower, String upper) {
    return '$lower–$upper $currency';
  }

  @override
  String get penaltiesFineNotRecorded => 'Sense import registrat';

  @override
  String get penaltiesConsequenceNotRecorded => 'Sense conseqüència registrada per a la llicència';

  @override
  String get penaltiesWorkedExampleLabel => 'Exemple resolt';

  @override
  String penaltiesWorkedExampleFirst(String offence, String jurisdiction, String fine) {
    return 'La primera infracció de $offence consta a $jurisdiction com a $fine.';
  }

  @override
  String penaltiesWorkedExampleSecond(String offence, String jurisdiction, String fine) {
    return 'La segona infracció de $offence consta a $jurisdiction com a $fine.';
  }

  @override
  String penaltiesWorkedExampleSubsequent(String offence, String jurisdiction, String fine) {
    return 'La infracció posterior de $offence consta a $jurisdiction com a $fine.';
  }

  @override
  String penaltiesWorkedExampleConsequence(String consequence) {
    return 'La conseqüència registrada per a la llicència és $consequence.';
  }

  @override
  String get penaltiesNoneRecordedHeadline => 'Sense sanció registrada';

  @override
  String penaltiesNoneRecordedBody(String jurisdiction) {
    return 'El paquet de regles inclòs no conté cap sanció transcrita per a $jurisdiction. És una absència en la transcripció, no una afirmació que els instruments no en continguin cap.';
  }

  @override
  String get penaltiesPackCaveat =>
      'Els imports són els registrats al paquet de regles inclòs. Els tribunals i els inspectors poden aplicar altres disposicions.';

  @override
  String penaltiesCitationDates(String published, String checked) {
    return 'publicat $published · revisat $checked';
  }

  @override
  String get disclaimerNotDismissable => 'No es pot descartar.';

  @override
  String get zonePickerTitle => 'On pesques?';

  @override
  String get zoneLevelCountry => 'País';

  @override
  String get zoneLevelRegion => 'Regió';

  @override
  String get tripsKeptHere => 'Es desa només en aquest dispositiu';

  @override
  String tripsCountStamp(int count) {
    return '$count sortides';
  }

  @override
  String tripsRowSpan(String zone, String started, String ended) {
    return '$zone · $started — $ended';
  }

  @override
  String tripsRowSpanOpen(String zone, String started) {
    return '$zone · $started — ara';
  }

  @override
  String get tripsOpenMark => '· en curs';

  @override
  String get tripsOpenStamp => 'En curs';

  @override
  String tripsDuration(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get tripsLoadFailed => 'No s\'han pogut llegir les sortides d\'aquest dispositiu.';

  @override
  String get zoneLevelSubZone => 'Subzona';

  @override
  String get zoneWaterSalt => 'Mar';

  @override
  String get zoneWaterFresh => 'Aigües continentals';

  @override
  String get zonePickerConfirm => 'Usa aquest lloc';

  @override
  String get zonePickerEmptyHeadline => 'No hi ha normes incloses per a aquest país';

  @override
  String get zonePickerEmptyBody =>
      'Aquesta versió no porta cap norma transcrita. Això no vol dir que no n’hi hagi.';

  @override
  String get zonePickerLoadFailed => 'No s’ha pogut llegir el paquet de normes inclòs.';

  @override
  String countryName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ES': 'Espanya',
      'AE': 'Emirats Àrabs Units',
      'BR': 'Brasil',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String zoneNoPublishedBoundaries(String authority) {
    return '$authority no publica límits de coordenades. Les normes registrades aquí s’apliquen a tota la jurisdicció.';
  }

  @override
  String get zoneWaterChoiceRequired =>
      'Cal triar mar o aigües continentals abans que aquest lloc pugui respondre.';

  @override
  String get navCheck => 'Comprova';

  @override
  String get destinationNotBuiltYet =>
      'Aquesta versió respon una sola pregunta: si un peix compleix les normes al lloc on es va desembarcar. Aquesta part encara no està construïda.';

  @override
  String get settingsLanguageDevice => 'Segueix el dispositiu';

  @override
  String get settingsDigits => 'Dígits';

  @override
  String get settingsDigitsAuto => 'Automàtic';

  @override
  String get settingsDigitsLatn => '0123';

  @override
  String get settingsDigitsArab => '٠١٢٣';

  @override
  String get settingsUnitCm => 'cm';

  @override
  String get settingsUnitMm => 'mm';

  @override
  String get settingsUnitIn => 'polz';

  @override
  String get settingsLengthUnit => 'Longitud en';

  @override
  String get settingsSunlightMode => 'Mode sol';

  @override
  String get settingsSunlightNote => 'Contrast màxim, per a una pantalla mullada sota el sol.';

  @override
  String get settingsGloveMode => 'Mode guants';

  @override
  String get settingsGloveNote => 'Objectius més grans i més espaiats.';

  @override
  String get settingsGroupLanguage => 'Idioma i xifres';

  @override
  String get settingsGroupPlace => 'On pesques';

  @override
  String get settingsGroupReading => 'Condicions de lectura';

  @override
  String get settingsDigitsNote => 'Xifres occidentals o aràbigues índies';

  @override
  String get settingsLengthUnitNote => 'Longituds en normes i lectures';

  @override
  String get settingsZone => 'Zona';

  @override
  String get settingsZoneNote => 'Les normes, la llista d’espècies i els límits segueixen això';

  @override
  String get settingsZoneUnset => 'Cap lloc triat';

  @override
  String settingsRulerScale(String px) {
    return '$px px / 10 mil·límetres';
  }

  @override
  String get settingsCoordinates => 'Captura de coordenades';

  @override
  String get settingsCoordinatesNote => 'Es guarden només en aquest telèfon, mai no es transmeten';

  @override
  String get settingsRuler => 'Regla';

  @override
  String get settingsRulerUncalibrated => 'Sense calibrar';

  @override
  String settingsRulerCalibrated(String on) {
    return 'Calibrada el $on';
  }

  @override
  String get settingsAboutPack => 'Llibre de normes';

  @override
  String get settingsOfflineNote =>
      'CatchLaw guarda en aquest telèfon tot el que necessita. No té compte ni codi de xarxa.';

  @override
  String get todayHeadline => 'Avui';

  @override
  String get todayNothingRecorded => 'Res registrat avui';

  @override
  String get todayNothingBody =>
      'L\'espècie que registris des de la seva pàgina apareix aquí, amb el recompte d\'aquest lloc.';

  @override
  String get todayNoPlace => 'Sense lloc';

  @override
  String todayCountKept(int count, int kept) {
    return '$count registrats · $kept conservats';
  }

  @override
  String todayTripOpenSince(String started) {
    return 'Sortida en curs des de les $started';
  }

  @override
  String get todayNoTripOpen => 'Cap sortida en curs';

  @override
  String get todaySummaryRecorded => 'Peixos registrats';

  @override
  String get todaySummaryKept => 'Conservats';

  @override
  String get todaySummarySpecies => 'Espècies';

  @override
  String todayKeptOfCount(String kept, String count) {
    return '$kept de $count';
  }

  @override
  String get todayBySpeciesLabel => 'Per espècie';

  @override
  String get todayLoadFailed => 'No s\'ha pogut llegir el recompte d\'avui d\'aquest dispositiu.';

  @override
  String get tripsHeadline => 'Sortides';

  @override
  String get tripsNone => 'Encara no hi ha sortides';

  @override
  String get tripsNoneBody =>
      'Iniciar una sortida agrupa el que registris en una sola jornada. Tot es queda en aquest telèfon.';

  @override
  String get tripsStart => 'Inicia sortida';

  @override
  String get tripsEnd => 'Finalitza la sortida';

  @override
  String tripsRunning(String since) {
    return 'En curs des de $since';
  }

  @override
  String tripsEnded(String started, String ended) {
    return '$started — $ended';
  }

  @override
  String get catchRecord => 'Registra aquesta captura';

  @override
  String get catchRecorded => 'Registrat';

  @override
  String get measureTitle => 'Mesura';

  @override
  String get measureUncalibrated => 'Aquesta pantalla no està calibrada';

  @override
  String get measureUncalibratedBody =>
      'Un telèfon informa de píxels, no de mil·límetres, i la proporció varia segons el model. Fins que no es calibra, la pantalla no pot dibuixar un regle a mida real. Escriure una longitud funciona igualment.';

  @override
  String get measureManualLabel => 'O escriu la longitud';

  @override
  String get measureUse => 'Usa aquesta longitud';

  @override
  String get calibrateAction => 'Calibra la pantalla';

  @override
  String get calibrateTitle => 'Calibra';

  @override
  String get calibrateFitBody =>
      'Posa una targeta bancària sobre la pantalla, amb la vora esquerra contra la vora esquerra del requadre, i arrossega la línia negra fins a la seva vora dreta.';

  @override
  String get calibrateVerifyBody =>
      'Comprova la línia contra la targeta un cop més. Si coincideix amb la vora, desa.';

  @override
  String get calibrateVerifyAction => 'Comprova';

  @override
  String get calibrateSaveAction => 'Desa el calibratge';

  @override
  String calibrateCardWidth(String mm) {
    return 'Una targeta bancària fa $mm mil·límetres d\'amplada (ISO/IEC 7810 ID-1).';
  }

  @override
  String get calibrateImplausible =>
      'Aquesta escala queda fora del rang plausible per a una pantalla de telèfon, així que no s\'ha desat.';

  @override
  String get todayRemove => 'Elimina';

  @override
  String get todayMarkKept => 'Conservat';

  @override
  String get todayUndoOne => 'N\'elimina un';

  @override
  String get measureSup => 'Regle';

  @override
  String measureCalibrationProvenance(String on, String pxPer10mm) {
    return 'Calibrat el $on · $pxPer10mm píxels per centímetre';
  }

  @override
  String get measureStepAndMark => 'Marcar per trams';

  @override
  String get measureRunningTotalUnit => 'cm fins ara';

  @override
  String measureStepPill(String count) {
    return 'Tram $count';
  }

  @override
  String get measureStepNote =>
      'Recolza la vora de la pantalla al morro, marca, llisca el telèfon al llarg del peix i torna a marcar.';

  @override
  String get measureTypeInstead => 'Escriure la mesura';

  @override
  String get measureRecalibrate => 'Recalibrar amb una targeta';

  @override
  String get measurePrivacyNote =>
      'El peix a la taula, el telèfon sobre el peix. No es pren cap fotografia ni es llegeix cap coordenada llevat que la captura de coordenades estigui activada a Configuració.';

  @override
  String get measureManualTitle => 'Escriure la longitud';

  @override
  String get calibrateSup => 'Una vegada per dispositiu';

  @override
  String calibrateCardConstant(String width, String height) {
    return 'Tota targeta d\'aquest format és idèntica: ISO/IEC 7810 ID-1 — $width × $height mil·límetres';
  }

  @override
  String calibrateDimension(String mm) {
    return '$mm mil·límetres';
  }

  @override
  String get calibrateDragHandleNote => 'Arrossega la nansa plena.';

  @override
  String get calibrateScaleLabel => 'Escala resultant';

  @override
  String get calibrateRowScale => 'Píxels per centímetre';

  @override
  String get calibrateRowDensity => 'Densitat de pantalla';

  @override
  String get calibrateRowError => 'Error esperat';

  @override
  String get calibrateRowLastCalibrated => 'Última calibració';

  @override
  String calibrateDensityValue(String dp, String ratio) {
    return '$dp dp · $ratio×';
  }

  @override
  String calibrateErrorValue(String mm) {
    return '± $mm mil·límetres en 30 centímetres';
  }

  @override
  String get calibrateNotYet => 'Encara sense calibrar';

  @override
  String get calibrateReset => 'Restablir el valor de pantalla';

  @override
  String get calibrateGlassNote =>
      'Una funda o un protector de pantalla no canvien res: la targeta es recolza sobre el vidre i el vidre és el que es mesura.';

  @override
  String get measureBackspace => 'Esborra';

  @override
  String get navBack => 'Enrere';

  @override
  String get navToday => 'Avui';

  @override
  String get navTrips => 'Sortides';

  @override
  String get navReference => 'Referència';

  @override
  String get referenceContentsLabel => 'Índex';

  @override
  String get referenceHubLede =>
      'Tot allò d\'on s\'extreu un dictamen, desat íntegre en aquest dispositiu i llegible sense cobertura.';

  @override
  String get referenceEntryRuleText => 'Text normatiu';

  @override
  String get referenceEntryRuleTextNote =>
      'Els instruments tal com es van publicar, article per article, en la llengua de publicació';

  @override
  String get ruleTextSearchHint => 'Cerca al text complet';

  @override
  String get ruleTextAllArticles => 'Tots els articles';

  @override
  String get ruleTextPublishedLabel => 'Publicat';

  @override
  String get ruleTextCheckedLabel => 'Comprovat';

  @override
  String get ruleTextCompleteNote =>
      'Aquest text es conserva íntegre en aquest dispositiu i no està abreujat.';

  @override
  String get ruleTextNoneRecordedHeadline => 'Sense text transcrit';

  @override
  String ruleTextNoneRecordedBody(String instrument) {
    return 'Aquesta còpia no conté el text dels articles de $instrument. La citació anterior anomena l’instrument i les dates de publicació i de la darrera comprovació.';
  }

  @override
  String get ruleTextNoMatchHeadline => 'Cap article coincideix';

  @override
  String get ruleTextNoMatchBody => 'Cap article d’aquest instrument conté aquesta redacció.';

  @override
  String get referenceEntryProtected => 'Espècies protegides';

  @override
  String get referenceEntryProtectedNote => 'Làmines, trets distintius i què abasta la protecció';

  @override
  String get referenceEntryGear => 'Arts i mètodes';

  @override
  String get referenceEntryGearNote => 'Malla, línia de mà, llargada de xarxa, mètodes prohibits';

  @override
  String get referenceEntryPenalties => 'Sancions';

  @override
  String get referenceEntryPenaltiesNote =>
      'Multes i conseqüències sobre la llicència, per infracció';

  @override
  String get referenceEntryLicences => 'Llicències';

  @override
  String get referenceEntryLicencesNote =>
      'Llicències d\'embarcació, de pescador i d\'art, i què abasta cadascuna';

  @override
  String get referenceEntryGlossary => 'Glossari';

  @override
  String get referenceEntryGlossaryNote => 'TL · FL · SL · CW · SHL · ML i els termes locals';

  @override
  String get referenceEntryChangelog => 'Registre de canvis';

  @override
  String get referenceEntryChangelogNote => 'Què va canviar en cada paquet i quan es va verificar';

  @override
  String get referenceEntryPlates => 'Làmines d\'espècies';

  @override
  String get referenceEntryPlatesNote =>
      'Siluetes agrupades per família, per a un peix conegut per la forma';

  @override
  String get referenceEntryNotPrinted => 'no imprès';

  @override
  String get referenceSectionNotPrinted =>
      'Aquesta secció no està impresa en aquest exemplar. Aquesta versió respon si un peix compleix les normes al lloc on es va desembarcar, i cita l\'instrument llegit.';

  @override
  String get referenceHeldLabel => 'Desat en aquest dispositiu';

  @override
  String referenceHeldPack(String version, String checkedOn) {
    return 'paquet $version · verificat $checkedOn';
  }

  @override
  String get referenceHeldNote => 'Aquest llibre cita els instruments que desa. No els resumeix.';

  @override
  String get referenceHeldEmpty => 'Aquest exemplar no desa cap jurisdicció.';

  @override
  String get navSettings => 'Configuració';

  @override
  String get checkPlaceLabel => 'Responent per a';

  @override
  String get checkChangePlace => 'Canvia el lloc';

  @override
  String get checkRecentsLabel => 'Recents aquí';

  @override
  String checkPackChecked(String date) {
    return 'verificat $date';
  }

  @override
  String get checkNoRecentsHeadline => 'Encara no s’ha comprovat res aquí';

  @override
  String get checkNoRecentsBody =>
      'Les espècies que cerquis en aquest lloc apareixen aquí, així el següent és un sol toc.';

  @override
  String get firstRunOfflineBadge => 'Sense senyal · sense xarxa per disseny';

  @override
  String get firstRunTagline => 'Això és legal?';

  @override
  String get firstRunMetaFirstRun => 'Primera arrencada';

  @override
  String get firstRunMetaOnceOnly => 'Una sola vegada';

  @override
  String get firstRunHeadline => 'Component el llibre de regles';

  @override
  String get firstRunLede =>
      'Es desempaqueta el paquet de regles inclòs, les làmines i el text legal, perquè a partir d’ara tot s’obri a l’instant.';

  @override
  String get firstRunSilhouetteLabel => 'Silueta gravada d’un anfós';

  @override
  String firstRunProgressBytes(String written, String total) {
    return '$written de $total kB';
  }

  @override
  String firstRunProgressPercent(String percent) {
    return '$percent %';
  }

  @override
  String get firstRunSectionInstalling => 'En instal·lació';

  @override
  String get firstRunStageRulePack => 'Paquet de regles';

  @override
  String get firstRunStageLegalText => 'Text legal';

  @override
  String get firstRunStagePlates => 'Làmines d’espècies';

  @override
  String get firstRunStageGlossary => 'Glossari i clau';

  @override
  String get firstRunStageDone => '· fet';

  @override
  String get firstRunStageInProgress => 'En curs…';

  @override
  String get firstRunStagePending => 'Encara sense desempaquetar';

  @override
  String firstRunTimeRemaining(String seconds) {
    return 'Queden uns $seconds s';
  }

  @override
  String get firstRunNoDownload =>
      'Això passa una sola vegada. No es descarrega res: tot ja era dins de l’aplicació en instal·lar-la, i no hi ha cap petició de xarxa que pugui fallar.';

  @override
  String get firstRunFooterNote =>
      'Sense compte. Sense inici de sessió. Sense sincronització. Quan això acabi, CatchLaw no torna a esperar res.';

  @override
  String measureManualReading(String mm) {
    return '$mm mil·límetres';
  }
}
