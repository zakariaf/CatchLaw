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
  String identifyKeyStamp(int couplet) {
    return 'Clave · paso $couplet';
  }

  @override
  String get identifyAnswersSoFar => 'Respuestas hasta ahora';

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
      many: 'quedan $count especies',
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
      other: 'Lleva a $count especies · $names',
      many: 'Lleva a $count especies · $names',
      one: 'Lleva a $count especie · $names',
    );
    return '$_temp0';
  }

  @override
  String get identifyLeadNoSpecies => 'No hay especies registradas más allá de esta respuesta.';

  @override
  String get identifyBackOneStep => 'Retroceder un paso';

  @override
  String get identifyDamagedHeading => 'Si el carácter no se ve';

  @override
  String get identifyDamagedNote =>
      'Un carácter dañado o ausente no se puede responder. En su lugar se enumeran, dibujadas y nombradas, todas las especies que este paso aún permite.';

  @override
  String get identifyListWhatRemains => 'Enumerar lo que queda';

  @override
  String get identifyProvenanceNote =>
      'No se toma ninguna fotografía y nada sale del dispositivo. La clave es la impresa de la sección de referencia, recorrida paso a paso.';

  @override
  String get identifyRemainingHeading => 'Especies que la clave aún permite';

  @override
  String get identifyNoKeyHeadline => 'Ninguna clave en este paquete';

  @override
  String get identifyNoKeyBody =>
      'Esta jurisdicción no tiene ninguna clave de identificación transcrita. Las especies que lleva este paquete se alcanzan por su nombre.';

  @override
  String get identifyNoCandidatesHeadline => 'Ninguna especie registrada aquí';

  @override
  String get identifyNoCandidatesBody =>
      'La clave no alcanza ninguna especie con las respuestas dadas. Más allá de este punto no hay nada transcrito en este paquete.';

  @override
  String get identifyKeyUnreadableHeadline => 'No se pudo leer la clave';

  @override
  String get identifyKeyUnreadableBody =>
      'La clave del paquete incluido no se abrió en este dispositivo. Las especies que lleva se alcanzan por su nombre.';

  @override
  String get identifySearchByName => 'Buscar por nombre';

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
  String speciesSearchMatchCount(int count) {
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
  String get speciesSearchClear => 'Borrar la búsqueda';

  @override
  String get browseByShapeTitle => 'Explorar por forma';

  @override
  String get browseNoSpeciesHeadline => 'Ninguna especie en este paquete';

  @override
  String get browseNoSpeciesBody => 'Esta jurisdicción todavía no tiene especies transcritas.';

  @override
  String browseSpeciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count especies',
      many: '$count especies',
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
    return 'más en $family';
  }

  @override
  String get speciesOtherNames => 'Otros nombres';

  @override
  String get speciesScientificName => 'Nombre científico';

  @override
  String get speciesFamilyLabel => 'Familia';

  @override
  String get speciesPlateSemanticLabel => 'Lámina grabada';

  @override
  String get speciesSilhouetteSemanticLabel => 'Dibujo lineal';

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
  String get verdictStampMeetsMinimum => 'Cumple el mínimo';

  @override
  String get verdictStampBelowMinimum => 'Por debajo del mínimo';

  @override
  String get verdictStampWithinMaximum => 'Dentro del máximo';

  @override
  String get verdictStampAboveMaximum => 'Por encima del máximo';

  @override
  String get verdictStampNotMeasured => 'Sin medir';

  @override
  String get verdictStampMethodMismatch => 'Medido con otro método';

  @override
  String verdictStampClosedSeason(String starts, String ends) {
    return 'Veda — del $starts al $ends';
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
    return 'Sin medición · mínimo $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximumUnmeasured(String threshold, String unit, String method) {
    return 'Sin medición · máximo $threshold $unit · $method';
  }

  @override
  String verdictDetailClosedSeasonInForce(String day, String total) {
    return 'En vigor hoy, día $day de $total · se aplica a todas las tallas';
  }

  @override
  String get verdictDetailClosedSeasonNotInForce => 'Hoy no está en vigor';

  @override
  String speciesBinomialFamily(String binomial, String family) {
    return '$binomial — $family';
  }

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
  String get ambiguityEyebrow => 'Conflicto de instrumentos';

  @override
  String get ambiguityBothInForce =>
      'Ambos instrumentos están en vigor en este punto. CatchLaw imprime el texto de cada uno con su propia fecha de comprobación y no sitúa ninguno por encima del otro.';

  @override
  String get findingFactMeasured => 'Medido';

  @override
  String get findingFactMinimum => 'Mínimo';

  @override
  String get findingFactMaximum => 'Máximo';

  @override
  String get findingFactShortfall => 'Diferencia';

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

  @override
  String get citationCopyAction => 'Copiar la cita';

  @override
  String rulePackExpiredOn(String date) {
    return 'Estas normas pasaron su fecha de fin el $date. Se muestran tal como se publicaron.';
  }

  @override
  String rulePackProvenance(String pack, String date) {
    return 'El paquete de normas incluido $pack pasó su fecha de validez el $date. El texto anterior es la última redacción verificada.';
  }

  @override
  String get staleDetailClose => 'Cerrar esta nota';

  @override
  String get flagRuleAction => 'Marcar esta norma';

  @override
  String get flagRuleNoteLabel => 'Qué dice la norma';

  @override
  String get flagRuleSaveAction => 'Guardar esta nota en este dispositivo';

  @override
  String get flagRuleRecorded => 'Guardada en este dispositivo.';

  @override
  String get flagRuleEmptyNote => 'La nota está vacía.';

  @override
  String get penaltiesTitle => 'Sanciones';

  @override
  String get penaltiesEntryNote => 'Lo que acarrea el incumplimiento de las reglas registradas.';

  @override
  String penaltiesLede(String jurisdiction) {
    return 'Lo que acarrea el incumplimiento de las reglas de talla, veda, protección o arte en $jurisdiction.';
  }

  @override
  String get penaltiesColumnOffence => 'Infracción';

  @override
  String get penaltiesColumnFine => 'Multa';

  @override
  String get penaltiesColumnLicence => 'Licencia';

  @override
  String get penaltiesOccurrenceFirst => 'Primera infracción';

  @override
  String get penaltiesOccurrenceSecond => 'Segunda infracción';

  @override
  String get penaltiesOccurrenceSubsequent => 'Infracción posterior';

  @override
  String get penaltiesOffenceListLabel => 'Infracciones registradas';

  @override
  String penaltiesFineAmount(String currency, String amount) {
    return '$amount $currency';
  }

  @override
  String penaltiesFineRange(String currency, String lower, String upper) {
    return '$lower–$upper $currency';
  }

  @override
  String get penaltiesFineNotRecorded => 'Sin importe registrado';

  @override
  String get penaltiesConsequenceNotRecorded => 'Sin consecuencia registrada para la licencia';

  @override
  String get penaltiesWorkedExampleLabel => 'Ejemplo resuelto';

  @override
  String penaltiesWorkedExampleFirst(String offence, String jurisdiction, String fine) {
    return 'La primera infracción de $offence consta en $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleSecond(String offence, String jurisdiction, String fine) {
    return 'La segunda infracción de $offence consta en $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleSubsequent(String offence, String jurisdiction, String fine) {
    return 'La infracción posterior de $offence consta en $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleConsequence(String consequence) {
    return 'La consecuencia registrada para la licencia es $consequence.';
  }

  @override
  String get penaltiesNoneRecordedHeadline => 'Sin sanción registrada';

  @override
  String penaltiesNoneRecordedBody(String jurisdiction) {
    return 'El paquete de reglas incluido no contiene ninguna sanción transcrita para $jurisdiction. Es una ausencia en la transcripción, no una afirmación de que los instrumentos no contengan ninguna.';
  }

  @override
  String get penaltiesPackCaveat =>
      'Los importes son los registrados en el paquete de reglas incluido. Los tribunales y los inspectores pueden aplicar otras disposiciones.';

  @override
  String penaltiesCitationDates(String published, String checked) {
    return 'publicado $published · revisado $checked';
  }

  @override
  String get disclaimerNotDismissable => 'No se puede descartar.';

  @override
  String get zonePickerTitle => '¿Dónde pescas?';

  @override
  String get zoneLevelCountry => 'País';

  @override
  String get zoneLevelRegion => 'Región';

  @override
  String get tripsKeptHere => 'Se guarda solo en este dispositivo';

  @override
  String tripsCountStamp(int count) {
    return '$count salidas';
  }

  @override
  String tripsRowSpan(String zone, String started, String ended) {
    return '$zone · $started — $ended';
  }

  @override
  String tripsRowSpanOpen(String zone, String started) {
    return '$zone · $started — ahora';
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
  String get tripsLoadFailed => 'No se han podido leer las salidas de este dispositivo.';

  @override
  String get zoneLevelSubZone => 'Subzona';

  @override
  String get zoneWaterSalt => 'Mar';

  @override
  String get zoneWaterFresh => 'Aguas continentales';

  @override
  String get zonePickerConfirm => 'Usar este lugar';

  @override
  String get zonePickerEmptyHeadline => 'No hay normas incluidas para este país';

  @override
  String get zonePickerEmptyBody =>
      'Esta versión no lleva ninguna norma transcrita. Esto no significa que no existan.';

  @override
  String get zonePickerLoadFailed => 'No se pudo leer el paquete de normas incluido.';

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
    return '$authority no publica límites de coordenadas. Las normas registradas aquí se aplican a toda la jurisdicción.';
  }

  @override
  String get zoneWaterChoiceRequired =>
      'Hay que elegir mar o aguas continentales antes de que este lugar pueda responder.';

  @override
  String get navCheck => 'Comprobar';

  @override
  String get destinationNotBuiltYet =>
      'Esta versión responde a una sola pregunta: si un pez cumple las normas en el lugar donde se desembarcó. Esta parte aún no está construida.';

  @override
  String get settingsLanguageDevice => 'Seguir el dispositivo';

  @override
  String get settingsDigits => 'Dígitos';

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
  String get settingsUnitIn => 'pulg';

  @override
  String get settingsLengthUnit => 'Longitud en';

  @override
  String get settingsSunlightMode => 'Modo sol';

  @override
  String get settingsSunlightNote => 'Contraste máximo, para una pantalla mojada a pleno sol.';

  @override
  String get settingsGloveMode => 'Modo guantes';

  @override
  String get settingsGloveNote => 'Objetivos más grandes y más espaciados.';

  @override
  String get settingsGroupLanguage => 'Idioma y cifras';

  @override
  String get settingsGroupPlace => 'Dónde pescas';

  @override
  String get settingsGroupReading => 'Condiciones de lectura';

  @override
  String get settingsDigitsNote => 'Cifras occidentales o arábigo-índicas';

  @override
  String get settingsLengthUnitNote => 'Longitudes en normas y lecturas';

  @override
  String get settingsZone => 'Zona';

  @override
  String get settingsZoneNote => 'Las normas, la lista de especies y los límites siguen esto';

  @override
  String get settingsZoneUnset => 'Ningún lugar elegido';

  @override
  String settingsRulerScale(String px) {
    return '$px px / 10 milímetros';
  }

  @override
  String get settingsCoordinates => 'Captura de coordenadas';

  @override
  String get settingsCoordinatesNote => 'Se guardan solo en este teléfono, nunca se transmiten';

  @override
  String get settingsRuler => 'Regla';

  @override
  String get settingsRulerUncalibrated => 'Sin calibrar';

  @override
  String settingsRulerCalibrated(String on) {
    return 'Calibrada el $on';
  }

  @override
  String get settingsAboutPack => 'Libro de normas';

  @override
  String get settingsOfflineNote =>
      'CatchLaw guarda en este teléfono todo lo que necesita. No tiene cuenta ni código de red.';

  @override
  String get todayHeadline => 'Hoy';

  @override
  String get todayNothingRecorded => 'Nada registrado hoy';

  @override
  String get todayNothingBody =>
      'La especie que registres desde su página aparece aquí, con el recuento de este lugar.';

  @override
  String get todayNoPlace => 'Sin lugar';

  @override
  String todayCountKept(int count, int kept) {
    return '$count registrados · $kept conservados';
  }

  @override
  String todayTripOpenSince(String started) {
    return 'Salida en curso desde las $started';
  }

  @override
  String get todayNoTripOpen => 'Ninguna salida en curso';

  @override
  String get todaySummaryRecorded => 'Peces registrados';

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
  String get todayLoadFailed => 'No se ha podido leer el recuento de hoy de este dispositivo.';

  @override
  String get tripsHeadline => 'Salidas';

  @override
  String get tripsNone => 'Aún no hay salidas';

  @override
  String get tripsNoneBody =>
      'Iniciar una salida agrupa lo que registres en una sola jornada. Todo permanece en este teléfono.';

  @override
  String get tripsStart => 'Iniciar salida';

  @override
  String get tripsEnd => 'Terminar salida';

  @override
  String tripsRunning(String since) {
    return 'En curso desde $since';
  }

  @override
  String tripsEnded(String started, String ended) {
    return '$started — $ended';
  }

  @override
  String get catchRecord => 'Registrar esta captura';

  @override
  String get catchRecorded => 'Registrado';

  @override
  String get measureTitle => 'Medir';

  @override
  String get measureUncalibrated => 'Esta pantalla no está calibrada';

  @override
  String get measureUncalibratedBody =>
      'Un teléfono informa de píxeles, no de milímetros, y la proporción varía según el modelo. Hasta calibrar la pantalla no puede dibujar una regla a tamaño real. Escribir una longitud funciona igualmente.';

  @override
  String get measureManualLabel => 'O escribe la longitud';

  @override
  String get measureUse => 'Usar esta longitud';

  @override
  String get calibrateAction => 'Calibrar la pantalla';

  @override
  String get calibrateTitle => 'Calibrar';

  @override
  String get calibrateFitBody =>
      'Coloca una tarjeta bancaria sobre la pantalla, con el borde izquierdo contra el borde izquierdo del recuadro, y arrastra la línea negra hasta su borde derecho.';

  @override
  String get calibrateVerifyBody =>
      'Comprueba la línea contra la tarjeta una vez más. Si coincide con el borde, guarda.';

  @override
  String get calibrateVerifyAction => 'Comprobar';

  @override
  String get calibrateSaveAction => 'Guardar la calibración';

  @override
  String calibrateCardWidth(String mm) {
    return 'Una tarjeta bancaria mide $mm milímetros de ancho (ISO/IEC 7810 ID-1).';
  }

  @override
  String get calibrateImplausible =>
      'Esa escala queda fuera del rango plausible para una pantalla de teléfono, así que no se guardó.';

  @override
  String get todayRemove => 'Quitar';

  @override
  String get todayMarkKept => 'Conservado';

  @override
  String get todayUndoOne => 'Quitar uno';

  @override
  String get measureSup => 'Regla';

  @override
  String measureCalibrationProvenance(String on, String pxPer10mm) {
    return 'Calibrado el $on · $pxPer10mm píxeles por centímetro';
  }

  @override
  String get measureStepAndMark => 'Marcar por tramos';

  @override
  String get measureRunningTotalUnit => 'cm hasta ahora';

  @override
  String measureStepPill(String count) {
    return 'Tramo $count';
  }

  @override
  String get measureStepNote =>
      'Apoya el borde de la pantalla en el morro, marca, desliza el teléfono a lo largo del pez y vuelve a marcar.';

  @override
  String get measureTypeInstead => 'Escribir la medida';

  @override
  String get measureRecalibrate => 'Recalibrar con una tarjeta';

  @override
  String get measurePrivacyNote =>
      'El pez en la tabla, el teléfono sobre el pez. No se toma ninguna fotografía ni se lee ninguna coordenada salvo que la captura de coordenadas esté activada en Ajustes.';

  @override
  String get measureManualTitle => 'Escribir la longitud';

  @override
  String get calibrateSup => 'Una vez por dispositivo';

  @override
  String calibrateCardConstant(String width, String height) {
    return 'Toda tarjeta de este formato es idéntica: ISO/IEC 7810 ID-1 — $width × $height milímetros';
  }

  @override
  String calibrateDimension(String mm) {
    return '$mm milímetros';
  }

  @override
  String get calibrateDragHandleNote => 'Arrastra el tirador relleno.';

  @override
  String get calibrateScaleLabel => 'Escala resultante';

  @override
  String get calibrateRowScale => 'Píxeles por centímetro';

  @override
  String get calibrateRowDensity => 'Densidad de pantalla';

  @override
  String get calibrateRowError => 'Error esperado';

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
  String get calibrateNotYet => 'Sin calibrar todavía';

  @override
  String get calibrateReset => 'Restablecer el valor de pantalla';

  @override
  String get calibrateGlassNote =>
      'Una funda o un protector de pantalla no cambian nada: la tarjeta se apoya en el cristal y el cristal es lo que se mide.';

  @override
  String get measureBackspace => 'Borrar';

  @override
  String get navBack => 'Atrás';

  @override
  String get navToday => 'Hoy';

  @override
  String get navTrips => 'Mareas';

  @override
  String get navReference => 'Referencia';

  @override
  String get referenceContentsLabel => 'Índice';

  @override
  String get referenceHubLede =>
      'Todo aquello de lo que se extrae un dictamen, guardado íntegro en este dispositivo y legible sin cobertura.';

  @override
  String get referenceEntryRuleText => 'Texto normativo';

  @override
  String get referenceEntryRuleTextNote =>
      'Los instrumentos tal como se publicaron, artículo por artículo, en la lengua de publicación';

  @override
  String get ruleTextSearchHint => 'Buscar en el texto completo';

  @override
  String get ruleTextAllArticles => 'Todos los artículos';

  @override
  String get ruleTextPublishedLabel => 'Publicado';

  @override
  String get ruleTextCheckedLabel => 'Comprobado';

  @override
  String get ruleTextCompleteNote =>
      'Este texto se conserva íntegro en este dispositivo y no está abreviado.';

  @override
  String get ruleTextNoneRecordedHeadline => 'Sin texto transcrito';

  @override
  String ruleTextNoneRecordedBody(String instrument) {
    return 'Esta copia no contiene el texto de los artículos de $instrument. La cita anterior nombra el instrumento y las fechas de publicación y de la última comprobación.';
  }

  @override
  String get ruleTextNoMatchHeadline => 'Ningún artículo coincide';

  @override
  String get ruleTextNoMatchBody => 'Ningún artículo de este instrumento contiene esa redacción.';

  @override
  String get referenceEntryProtected => 'Especies protegidas';

  @override
  String get referenceEntryProtectedNote =>
      'Láminas, rasgos distintivos y qué abarca la protección';

  @override
  String get referenceEntryGear => 'Artes y métodos';

  @override
  String get referenceEntryGearNote => 'Malla, línea de mano, longitud de red, métodos prohibidos';

  @override
  String get referenceEntryPenalties => 'Sanciones';

  @override
  String get referenceEntryPenaltiesNote =>
      'Multas y consecuencias sobre la licencia, por infracción';

  @override
  String get referenceEntryLicences => 'Licencias';

  @override
  String get referenceEntryLicencesNote =>
      'Licencias de embarcación, de pescador y de arte, y qué abarca cada una';

  @override
  String get referenceEntryGlossary => 'Glosario';

  @override
  String get referenceEntryGlossaryNote => 'TL · FL · SL · CW · SHL · ML y los términos locales';

  @override
  String get referenceEntryChangelog => 'Registro de cambios';

  @override
  String get referenceEntryChangelogNote => 'Qué cambió en cada paquete y cuándo se verificó';

  @override
  String get referenceEntryPlates => 'Láminas de especies';

  @override
  String get referenceEntryPlatesNote =>
      'Siluetas agrupadas por familia, para un pez conocido por su forma';

  @override
  String get referenceEntryNotPrinted => 'no impreso';

  @override
  String get referenceSectionNotPrinted =>
      'Esta sección no está impresa en este ejemplar. Esta versión responde si un pez cumple las normas en el lugar donde se desembarcó, y cita el instrumento leído.';

  @override
  String get referenceHeldLabel => 'Guardado en este dispositivo';

  @override
  String referenceHeldPack(String version, String checkedOn) {
    return 'paquete $version · verificado $checkedOn';
  }

  @override
  String get referenceHeldNote => 'Este libro cita los instrumentos que guarda. No los resume.';

  @override
  String get referenceHeldEmpty => 'Este ejemplar no guarda ninguna jurisdicción.';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get checkPlaceLabel => 'Respondiendo para';

  @override
  String get checkChangePlace => 'Cambiar lugar';

  @override
  String get checkRecentsLabel => 'Recientes aquí';

  @override
  String checkPackChecked(String date) {
    return 'verificado $date';
  }

  @override
  String get checkNoRecentsHeadline => 'Todavía no se ha comprobado nada aquí';

  @override
  String get checkNoRecentsBody =>
      'Las especies que busques en este lugar aparecen aquí, así el siguiente es un solo toque.';

  @override
  String get firstRunOfflineBadge => 'Sin señal · sin red por diseño';

  @override
  String get firstRunTagline => '¿Esto es legal?';

  @override
  String get firstRunMetaFirstRun => 'Primer arranque';

  @override
  String get firstRunMetaOnceOnly => 'Una sola vez';

  @override
  String get firstRunHeadline => 'Componiendo el libro de reglas';

  @override
  String get firstRunLede =>
      'Se desempaqueta el paquete de reglas incluido, las láminas y el texto legal, para que a partir de ahora todo abra al instante.';

  @override
  String get firstRunSilhouetteLabel => 'Silueta grabada de un mero';

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
  String get firstRunStageRulePack => 'Paquete de reglas';

  @override
  String get firstRunStageLegalText => 'Texto legal';

  @override
  String get firstRunStagePlates => 'Láminas de especies';

  @override
  String get firstRunStageGlossary => 'Glosario y clave';

  @override
  String get firstRunStageDone => '· hecho';

  @override
  String get firstRunStageInProgress => 'En curso…';

  @override
  String get firstRunStagePending => 'Aún sin desempaquetar';

  @override
  String firstRunTimeRemaining(String seconds) {
    return 'Quedan unos $seconds s';
  }

  @override
  String get firstRunNoDownload =>
      'Esto ocurre una sola vez. No se descarga nada: todo estaba ya dentro de la aplicación al instalarla, y no hay ninguna petición de red que pueda fallar.';

  @override
  String get firstRunFooterNote =>
      'Sin cuenta. Sin inicio de sesión. Sin sincronización. Cuando esto termine, CatchLaw no vuelve a esperar por nada.';

  @override
  String measureManualReading(String mm) {
    return '$mm milímetros';
  }
}
