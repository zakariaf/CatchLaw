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
  String identifyKeyStamp(int couplet) {
    return 'Clave · paso $couplet';
  }

  @override
  String get identifyAnswersSoFar => 'Respostas ata agora';

  @override
  String identifyCoupletLabel(int couplet) {
    return 'Paso $couplet';
  }

  @override
  String identifySpeciesRemain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'quedan $count especies',
      one: 'queda $count especie',
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
      other: 'Leva a $count especies · $names',
      one: 'Leva a $count especie · $names',
    );
    return '$_temp0';
  }

  @override
  String get identifyLeadNoSpecies => 'Non hai especies rexistradas alén desta resposta.';

  @override
  String get identifyBackOneStep => 'Retroceder un paso';

  @override
  String get identifyDamagedHeading => 'Se o carácter non se ve';

  @override
  String get identifyDamagedNote =>
      'Un carácter danado ou ausente non se pode responder. No seu lugar enuméranse, debuxadas e nomeadas, todas as especies que este paso aínda permite.';

  @override
  String get identifyListWhatRemains => 'Enumerar o que queda';

  @override
  String get identifyProvenanceNote =>
      'Non se toma ningunha fotografía e nada sae do dispositivo. A clave é a impresa da sección de referencia, percorrida paso a paso.';

  @override
  String get identifyRemainingHeading => 'Especies que a clave aínda permite';

  @override
  String get identifyNoKeyHeadline => 'Ningunha clave neste paquete';

  @override
  String get identifyNoKeyBody =>
      'Esta xurisdición non ten ningunha clave de identificación transcrita. As especies que leva este paquete alcánzanse polo seu nome.';

  @override
  String get identifyNoCandidatesHeadline => 'Ningunha especie rexistrada aquí';

  @override
  String get identifyNoCandidatesBody =>
      'A clave non alcanza ningunha especie coas respostas dadas. Alén deste punto non hai nada transcrito neste paquete.';

  @override
  String get identifyKeyUnreadableHeadline => 'Non se puido ler a clave';

  @override
  String get identifyKeyUnreadableBody =>
      'A clave do paquete incluído non abriu neste dispositivo. As especies que leva alcánzanse polo seu nome.';

  @override
  String get identifySearchByName => 'Buscar por nome';

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
  String speciesSearchMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coincidencias',
      one: '$count coincidencia',
    );
    return '$_temp0';
  }

  @override
  String get speciesSearchClear => 'Borrar a busca';

  @override
  String get browseByShapeTitle => 'Explorar por forma';

  @override
  String get browseNoSpeciesHeadline => 'Ningunha especie neste paquete';

  @override
  String get browseNoSpeciesBody => 'Esta xurisdición aínda non ten especies transcritas.';

  @override
  String browseSpeciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count especies',
      one: '$count especie',
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
    return 'máis en $family';
  }

  @override
  String get speciesOtherNames => 'Outros nomes';

  @override
  String get speciesScientificName => 'Nome científico';

  @override
  String get speciesFamilyLabel => 'Familia';

  @override
  String get speciesPlateSemanticLabel => 'Lámina gravada';

  @override
  String get speciesSilhouetteSemanticLabel => 'Debuxo lineal';

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
  String get verdictStampMeetsMinimum => 'Cumpre o mínimo';

  @override
  String get verdictStampBelowMinimum => 'Por debaixo do mínimo';

  @override
  String get verdictStampWithinMaximum => 'Dentro do máximo';

  @override
  String get verdictStampAboveMaximum => 'Por riba do máximo';

  @override
  String get verdictStampNotMeasured => 'Sen medir';

  @override
  String get verdictStampMethodMismatch => 'Medido con outro método';

  @override
  String verdictStampClosedSeason(String starts, String ends) {
    return 'Veda — do $starts ao $ends';
  }

  @override
  String verdictDetailMinimum(String measured, String unit, String threshold, String method) {
    return '$measured $unit medidos · mínimo $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximum(String measured, String unit, String threshold, String method) {
    return '$measured $unit medidos · máximo $threshold $unit · $method';
  }

  @override
  String verdictDetailMinimumUnmeasured(String threshold, String unit, String method) {
    return 'Sen medición · mínimo $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximumUnmeasured(String threshold, String unit, String method) {
    return 'Sen medición · máximo $threshold $unit · $method';
  }

  @override
  String verdictDetailClosedSeasonInForce(String day, String total) {
    return 'En vigor hoxe, día $day de $total · aplícase a todos os tamaños';
  }

  @override
  String get verdictDetailClosedSeasonNotInForce => 'Hoxe non está en vigor';

  @override
  String speciesBinomialFamily(String binomial, String family) {
    return '$binomial — $family';
  }

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
  String get ambiguityEyebrow => 'Conflito de instrumentos';

  @override
  String get ambiguityBothInForce =>
      'Ambos os instrumentos están en vigor neste punto. CatchLaw imprime o texto de cada un coa súa propia data de comprobación e non sitúa ningún por riba do outro.';

  @override
  String get findingFactMeasured => 'Medido';

  @override
  String get findingFactMinimum => 'Mínimo';

  @override
  String get findingFactMaximum => 'Máximo';

  @override
  String get findingFactShortfall => 'Diferenza';

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
  String get penaltiesTitle => 'Sancións';

  @override
  String get penaltiesEntryNote => 'O que acarrea o incumprimento das regras rexistradas.';

  @override
  String penaltiesLede(String jurisdiction) {
    return 'O que acarrea o incumprimento das regras de talla, veda, protección ou arte en $jurisdiction.';
  }

  @override
  String get penaltiesColumnOffence => 'Infracción';

  @override
  String get penaltiesColumnFine => 'Multa';

  @override
  String get penaltiesColumnLicence => 'Licenza';

  @override
  String get penaltiesOccurrenceFirst => 'Primeira infracción';

  @override
  String get penaltiesOccurrenceSecond => 'Segunda infracción';

  @override
  String get penaltiesOccurrenceSubsequent => 'Infracción posterior';

  @override
  String get penaltiesOffenceListLabel => 'Infraccións rexistradas';

  @override
  String penaltiesFineAmount(String currency, String amount) {
    return '$amount $currency';
  }

  @override
  String penaltiesFineRange(String currency, String lower, String upper) {
    return '$lower–$upper $currency';
  }

  @override
  String get penaltiesFineNotRecorded => 'Sen importe rexistrado';

  @override
  String get penaltiesConsequenceNotRecorded => 'Sen consecuencia rexistrada para a licenza';

  @override
  String get penaltiesWorkedExampleLabel => 'Exemplo resolto';

  @override
  String penaltiesWorkedExampleFirst(String offence, String jurisdiction, String fine) {
    return 'A primeira infracción de $offence consta en $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleSecond(String offence, String jurisdiction, String fine) {
    return 'A segunda infracción de $offence consta en $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleSubsequent(String offence, String jurisdiction, String fine) {
    return 'A infracción posterior de $offence consta en $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleConsequence(String consequence) {
    return 'A consecuencia rexistrada para a licenza é $consequence.';
  }

  @override
  String get penaltiesNoneRecordedHeadline => 'Sen sanción rexistrada';

  @override
  String penaltiesNoneRecordedBody(String jurisdiction) {
    return 'O paquete de regras incluído non contén ningunha sanción transcrita para $jurisdiction. É unha ausencia na transcrición, non unha afirmación de que os instrumentos non conteñan ningunha.';
  }

  @override
  String get penaltiesPackCaveat =>
      'Os importes son os rexistrados no paquete de regras incluído. Os tribunais e os inspectores poden aplicar outras disposicións.';

  @override
  String penaltiesCitationDates(String published, String checked) {
    return 'publicado $published · revisado $checked';
  }

  @override
  String get disclaimerNotDismissable => 'Non se pode descartar.';

  @override
  String get zonePickerTitle => 'Onde pescas?';

  @override
  String get zoneLevelCountry => 'País';

  @override
  String get zoneLevelRegion => 'Rexión';

  @override
  String get tripsKeptHere => 'Gárdase só neste dispositivo';

  @override
  String tripsCountStamp(int count) {
    return '$count saídas';
  }

  @override
  String tripsRowSpan(String zone, String started, String ended) {
    return '$zone · $started — $ended';
  }

  @override
  String tripsRowSpanOpen(String zone, String started) {
    return '$zone · $started — agora';
  }

  @override
  String get tripsOpenMark => '· en curso';

  @override
  String get tripsOpenStamp => 'En curso';

  @override
  String tripsDuration(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get tripsLoadFailed => 'Non foi posible ler as saídas deste dispositivo.';

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

  @override
  String zoneNoPublishedBoundaries(String authority) {
    return '$authority non publica límites de coordenadas. As normas rexistradas aquí aplícanse a toda a xurisdición.';
  }

  @override
  String get zoneWaterChoiceRequired =>
      'Hai que escoller mar ou augas continentais antes de que este lugar poida responder.';

  @override
  String get navCheck => 'Comprobar';

  @override
  String get destinationNotBuiltYet =>
      'Esta versión responde a unha soa pregunta: se un peixe cumpre as normas no lugar onde foi desembarcado. Esta parte aínda non está construída.';

  @override
  String get settingsLanguageDevice => 'Seguir o dispositivo';

  @override
  String get settingsDigits => 'Díxitos';

  @override
  String get settingsDigitsAuto => 'Automático';

  @override
  String get settingsDigitsLatn => '0123';

  @override
  String get settingsDigitsArab => '٠١٢٣';

  @override
  String get settingsUnitCm => 'cm';

  @override
  String get settingsUnitMm => 'mm';

  @override
  String get settingsUnitIn => 'pol';

  @override
  String get settingsLengthUnit => 'Lonxitude en';

  @override
  String get settingsSunlightMode => 'Modo sol';

  @override
  String get settingsSunlightNote => 'Contraste máximo, para unha pantalla mollada baixo o sol.';

  @override
  String get settingsGloveMode => 'Modo luvas';

  @override
  String get settingsGloveNote => 'Obxectivos máis grandes e máis espazados.';

  @override
  String get settingsGroupLanguage => 'Idioma e cifras';

  @override
  String get settingsGroupPlace => 'Onde pescas';

  @override
  String get settingsGroupReading => 'Condicións de lectura';

  @override
  String get settingsDigitsNote => 'Cifras occidentais ou arábigo-índicas';

  @override
  String get settingsLengthUnitNote => 'Lonxitudes en normas e lecturas';

  @override
  String get settingsZone => 'Zona';

  @override
  String get settingsZoneNote => 'As normas, a lista de especies e os límites seguen isto';

  @override
  String get settingsZoneUnset => 'Ningún lugar elixido';

  @override
  String settingsRulerScale(String px) {
    return '$px px / 10 milímetros';
  }

  @override
  String get settingsCoordinates => 'Captura de coordenadas';

  @override
  String get settingsCoordinatesNote => 'Gárdanse só neste teléfono, nunca se transmiten';

  @override
  String get settingsRuler => 'Regra';

  @override
  String get settingsRulerUncalibrated => 'Sen calibrar';

  @override
  String settingsRulerCalibrated(String on) {
    return 'Calibrada o $on';
  }

  @override
  String get settingsAboutPack => 'Libro de normas';

  @override
  String get settingsOfflineNote =>
      'CatchLaw garda neste teléfono todo o que precisa. Non ten conta nin código de rede.';

  @override
  String get todayHeadline => 'Hoxe';

  @override
  String get todayNothingRecorded => 'Nada rexistrado hoxe';

  @override
  String get todayNothingBody =>
      'A especie que rexistres desde a súa páxina aparece aquí, co reconto deste lugar.';

  @override
  String get todayNoPlace => 'Sen lugar';

  @override
  String todayCountKept(int count, int kept) {
    return '$count rexistrados · $kept conservados';
  }

  @override
  String todayTripOpenSince(String started) {
    return 'Saída en curso desde as $started';
  }

  @override
  String get todayNoTripOpen => 'Ningunha saída en curso';

  @override
  String get todaySummaryRecorded => 'Peixes rexistrados';

  @override
  String get todaySummaryKept => 'Conservados';

  @override
  String get todaySummarySpecies => 'Especies';

  @override
  String todayKeptOfCount(String kept, String count) {
    return '$kept de $count';
  }

  @override
  String get todayBySpeciesLabel => 'Por especie';

  @override
  String get todayLoadFailed => 'Non foi posible ler o reconto de hoxe deste dispositivo.';

  @override
  String get tripsHeadline => 'Saídas';

  @override
  String get tripsNone => 'Aínda non hai saídas';

  @override
  String get tripsNoneBody =>
      'Iniciar unha saída agrupa o que rexistres nunha soa xornada. Todo permanece neste teléfono.';

  @override
  String get tripsStart => 'Iniciar saída';

  @override
  String get tripsEnd => 'Rematar saída';

  @override
  String tripsRunning(String since) {
    return 'En curso desde $since';
  }

  @override
  String tripsEnded(String started, String ended) {
    return '$started — $ended';
  }

  @override
  String get catchRecord => 'Rexistrar esta captura';

  @override
  String get catchRecorded => 'Rexistrado';

  @override
  String get measureTitle => 'Medir';

  @override
  String get measureUncalibrated => 'Esta pantalla non está calibrada';

  @override
  String get measureUncalibratedBody =>
      'Un teléfono informa de píxeles, non de milímetros, e a proporción varía segundo o modelo. Ata calibrar, a pantalla non pode debuxar unha regra a tamaño real. Escribir unha lonxitude funciona igualmente.';

  @override
  String get measureManualLabel => 'Ou escribe a lonxitude';

  @override
  String get measureUse => 'Usar esta lonxitude';

  @override
  String get calibrateAction => 'Calibrar a pantalla';

  @override
  String get calibrateTitle => 'Calibrar';

  @override
  String get calibrateFitBody =>
      'Pon unha tarxeta bancaria sobre a pantalla, co bordo esquerdo contra o bordo esquerdo do recadro, e arrastra a liña negra ata o seu bordo dereito.';

  @override
  String get calibrateVerifyBody =>
      'Comproba a liña contra a tarxeta unha vez máis. Se coincide co bordo, garda.';

  @override
  String get calibrateVerifyAction => 'Comprobar';

  @override
  String get calibrateSaveAction => 'Gardar a calibración';

  @override
  String calibrateCardWidth(String mm) {
    return 'Unha tarxeta bancaria mide $mm milímetros de ancho (ISO/IEC 7810 ID-1).';
  }

  @override
  String get calibrateImplausible =>
      'Esa escala queda fóra do rango plausible para unha pantalla de teléfono, así que non se gardou.';

  @override
  String get todayRemove => 'Quitar';

  @override
  String get todayMarkKept => 'Conservado';

  @override
  String get todayUndoOne => 'Quitar un';

  @override
  String get measureSup => 'Regra';

  @override
  String measureCalibrationProvenance(String on, String pxPer10mm) {
    return 'Calibrado o $on · $pxPer10mm píxeles por centímetro';
  }

  @override
  String get measureStepAndMark => 'Marcar por tramos';

  @override
  String get measureRunningTotalUnit => 'cm ata agora';

  @override
  String measureStepPill(String count) {
    return 'Tramo $count';
  }

  @override
  String get measureStepNote =>
      'Apoia o bordo da pantalla no fociño, marca, desliza o teléfono ao longo do peixe e marca de novo.';

  @override
  String get measureTypeInstead => 'Escribir a medida';

  @override
  String get measureRecalibrate => 'Recalibrar cunha tarxeta';

  @override
  String get measurePrivacyNote =>
      'O peixe na táboa, o teléfono sobre o peixe. Non se toma ningunha fotografía nin se le ningunha coordenada agás que a captura de coordenadas estea activada en Axustes.';

  @override
  String get measureManualTitle => 'Escribir a lonxitude';

  @override
  String get calibrateSup => 'Unha vez por dispositivo';

  @override
  String calibrateCardConstant(String width, String height) {
    return 'Toda tarxeta deste formato é idéntica: ISO/IEC 7810 ID-1 — $width × $height milímetros';
  }

  @override
  String calibrateDimension(String mm) {
    return '$mm milímetros';
  }

  @override
  String get calibrateDragHandleNote => 'Arrastra o tirador cheo.';

  @override
  String get calibrateScaleLabel => 'Escala resultante';

  @override
  String get calibrateRowScale => 'Píxeles por centímetro';

  @override
  String get calibrateRowDensity => 'Densidade de pantalla';

  @override
  String get calibrateRowError => 'Erro esperado';

  @override
  String get calibrateRowLastCalibrated => 'Última calibración';

  @override
  String calibrateDensityValue(String dp, String ratio) {
    return '$dp dp · $ratio×';
  }

  @override
  String calibrateErrorValue(String mm) {
    return '± $mm milímetros en 30 centímetros';
  }

  @override
  String get calibrateNotYet => 'Sen calibrar aínda';

  @override
  String get calibrateReset => 'Restablecer o valor de pantalla';

  @override
  String get calibrateGlassNote =>
      'Unha funda ou un protector de pantalla non cambian nada: a tarxeta apóiase no cristal e o cristal é o que se mide.';

  @override
  String get measureBackspace => 'Borrar';

  @override
  String get navBack => 'Atrás';

  @override
  String get navToday => 'Hoxe';

  @override
  String get navTrips => 'Mareas';

  @override
  String get navReference => 'Referencia';

  @override
  String get referenceContentsLabel => 'Índice';

  @override
  String get referenceHubLede =>
      'Todo aquilo do que se extrae un ditame, gardado íntegro neste dispositivo e lexible sen cobertura.';

  @override
  String get referenceEntryRuleText => 'Texto normativo';

  @override
  String get referenceEntryRuleTextNote =>
      'Os instrumentos tal como se publicaron, artigo por artigo, na lingua de publicación';

  @override
  String get ruleTextSearchHint => 'Buscar no texto completo';

  @override
  String get ruleTextAllArticles => 'Todos os artigos';

  @override
  String get ruleTextPublishedLabel => 'Publicado';

  @override
  String get ruleTextCheckedLabel => 'Comprobado';

  @override
  String get ruleTextCompleteNote =>
      'Este texto consérvase íntegro neste dispositivo e non está abreviado.';

  @override
  String get ruleTextNoneRecordedHeadline => 'Sen texto transcrito';

  @override
  String ruleTextNoneRecordedBody(String instrument) {
    return 'Esta copia non contén o texto dos artigos de $instrument. A cita anterior nomea o instrumento e as datas de publicación e da última comprobación.';
  }

  @override
  String get ruleTextNoMatchHeadline => 'Ningún artigo coincide';

  @override
  String get ruleTextNoMatchBody => 'Ningún artigo deste instrumento contén esa redacción.';

  @override
  String get referenceEntryProtected => 'Especies protexidas';

  @override
  String get referenceEntryProtectedNote =>
      'Láminas, trazos distintivos e que abrangue a protección';

  @override
  String get referenceEntryGear => 'Artes e métodos';

  @override
  String get referenceEntryGearNote => 'Malla, liña de man, lonxitude de rede, métodos prohibidos';

  @override
  String get referenceEntryPenalties => 'Sancións';

  @override
  String get referenceEntryPenaltiesNote =>
      'Multas e consecuencias sobre a licenza, por infracción';

  @override
  String get referenceEntryLicences => 'Licenzas';

  @override
  String get referenceEntryLicencesNote =>
      'Licenzas de embarcación, de pescador e de arte, e que abrangue cada unha';

  @override
  String get referenceEntryGlossary => 'Glosario';

  @override
  String get referenceEntryGlossaryNote => 'TL · FL · SL · CW · SHL · ML e os termos locais';

  @override
  String get referenceEntryChangelog => 'Rexistro de cambios';

  @override
  String get referenceEntryChangelogNote => 'Que cambiou en cada paquete e cando se verificou';

  @override
  String get referenceEntryPlates => 'Láminas de especies';

  @override
  String get referenceEntryPlatesNote =>
      'Siluetas agrupadas por familia, para un peixe coñecido pola súa forma';

  @override
  String get referenceEntryNotPrinted => 'non impreso';

  @override
  String get referenceSectionNotPrinted =>
      'Esta sección non está impresa neste exemplar. Esta versión responde se un peixe cumpre as normas no lugar onde se desembarcou, e cita o instrumento lido.';

  @override
  String get referenceHeldLabel => 'Gardado neste dispositivo';

  @override
  String referenceHeldPack(String version, String checkedOn) {
    return 'paquete $version · verificado $checkedOn';
  }

  @override
  String get referenceHeldNote => 'Este libro cita os instrumentos que garda. Non os resume.';

  @override
  String get referenceHeldEmpty => 'Este exemplar non garda ningunha xurisdición.';

  @override
  String get navSettings => 'Axustes';

  @override
  String get checkPlaceLabel => 'Respondendo para';

  @override
  String get checkChangePlace => 'Cambiar lugar';

  @override
  String get checkRecentsLabel => 'Recentes aquí';

  @override
  String checkPackChecked(String date) {
    return 'verificado $date';
  }

  @override
  String get checkNoRecentsHeadline => 'Aínda non se comprobou nada aquí';

  @override
  String get checkNoRecentsBody =>
      'As especies que busques neste lugar aparecen aquí, así o seguinte é un só toque.';

  @override
  String get firstRunOfflineBadge => 'Sen sinal · sen rede por deseño';

  @override
  String get firstRunTagline => 'Isto é legal?';

  @override
  String get firstRunMetaFirstRun => 'Primeiro arranque';

  @override
  String get firstRunMetaOnceOnly => 'Unha soa vez';

  @override
  String get firstRunHeadline => 'Compoñendo o libro de regras';

  @override
  String get firstRunLede =>
      'Desempaquétase o paquete de regras incluído, as láminas e o texto legal, para que a partir de agora todo abra ao instante.';

  @override
  String get firstRunSilhouetteLabel => 'Silueta gravada dun mero';

  @override
  String firstRunProgressBytes(String written, String total) {
    return '$written de $total kB';
  }

  @override
  String firstRunProgressPercent(String percent) {
    return '$percent %';
  }

  @override
  String get firstRunSectionInstalling => 'En instalación';

  @override
  String get firstRunStageRulePack => 'Paquete de regras';

  @override
  String get firstRunStageLegalText => 'Texto legal';

  @override
  String get firstRunStagePlates => 'Láminas de especies';

  @override
  String get firstRunStageGlossary => 'Glosario e clave';

  @override
  String get firstRunStageDone => '· feito';

  @override
  String get firstRunStageInProgress => 'En curso…';

  @override
  String get firstRunStagePending => 'Aínda sen desempaquetar';

  @override
  String firstRunTimeRemaining(String seconds) {
    return 'Quedan uns $seconds s';
  }

  @override
  String get firstRunNoDownload =>
      'Isto ocorre unha soa vez. Non se descarga nada: todo estaba xa dentro da aplicación ao instalala, e non hai ningunha petición de rede que poida fallar.';

  @override
  String get firstRunFooterNote =>
      'Sen conta. Sen inicio de sesión. Sen sincronización. Cando isto remate, CatchLaw non volve agardar por nada.';

  @override
  String measureManualReading(String mm) {
    return '$mm milímetros';
  }
}
