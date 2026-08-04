// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'CatchLaw';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count correspondências',
      many: '$count correspondências',
      one: '$count correspondência',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystemDefault => 'Idioma do dispositivo';

  @override
  String get settingsNumeralSystem => 'Algarismos';

  @override
  String get settingsNumeralSystemAuto => 'Padrão do idioma';

  @override
  String get settingsNumeralSystemLatn => 'Ocidentais — 0 1 2 3';

  @override
  String get settingsNumeralSystemArab => 'Arábico-índicos — ٠ ١ ٢ ٣';

  @override
  String legalTextLanguageNotice(String language) {
    return 'O texto literal deste instrumento existe apenas em $language.';
  }

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ar': 'árabe',
      'en': 'inglês',
      'es': 'espanhol',
      'gl': 'galego',
      'ca': 'catalão',
      'ptBR': 'português do Brasil',
      'other': 'inglês',
    });
    return '$_temp0';
  }

  @override
  String get speciesSearchLabel => 'Espécies';

  @override
  String get speciesSearchHint => 'garoupa, mero, Epinephelus';

  @override
  String get speciesGroupInYourZone => 'Na sua zona';

  @override
  String get speciesGroupElsewhere => 'Em outro lugar desta jurisdição';

  @override
  String get speciesHintProtected => 'protegida';

  @override
  String get speciesHintClosed => 'defeso';

  @override
  String get speciesNoMatchHeadline => 'Nenhuma espécie com esse nome';

  @override
  String get speciesNoMatchBody =>
      'O nome pode ser escrito de outra forma aqui, ou a espécie pode ainda não estar transcrita.';

  @override
  String get identifyThisFish => 'Identificar este peixe';

  @override
  String get browseByShape => 'Explorar por forma';

  @override
  String get rulePackExpired =>
      'Estas regras passaram da data de término declarada. São exibidas como publicadas.';

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
  String get browseNoSpeciesHeadline => 'Nenhuma espécie neste pacote';

  @override
  String get browseNoSpeciesBody => 'Esta jurisdição ainda não tem espécies transcritas.';

  @override
  String get speciesOtherNames => 'Outros nomes';

  @override
  String get speciesScientificName => 'Nome científico';

  @override
  String get speciesFamilyLabel => 'Família';

  @override
  String get speciesPlateSemanticLabel => 'Prancha gravada';

  @override
  String get speciesSilhouetteSemanticLabel => 'Desenho de linha';

  @override
  String get speciesProtectedAnywhere => 'Protegida em algum lugar desta jurisdição';

  @override
  String get lookAlikeSectionLabel => 'Confundida facilmente com';

  @override
  String get lookAlikeConfusedWith => 'O que as diferencia';

  @override
  String get recentsStripLabel => 'Recentes aqui';

  @override
  String get recentsEmptyBody => 'As espécies que você abrir nesta zona aparecem aqui.';

  @override
  String get calibrationTitle => 'Meça sua tela';

  @override
  String get calibrationCardExplainer =>
      'Coloque qualquer cartão bancário, carteira ou documento sobre o vidro e arraste a borda até coincidir.';

  @override
  String get calibrationHandleLabel => 'Borda do cartão';

  @override
  String calibrationVerifyExplainer(String measurement) {
    return 'Esta barra tem $measurement. Compare com o lado curto do mesmo cartão.';
  }

  @override
  String calibrationVerifyBarLabel(String measurement) {
    return '$measurement';
  }

  @override
  String get calibrationSaveAction => 'Salvar esta medida';

  @override
  String get calibrationCancelAction => 'Um passo atrás';

  @override
  String get calibrationTooSmallScreen =>
      'Esta tela é mais estreita que um cartão. A entrada manual está disponível.';

  @override
  String calibrationImplausible(String measurement) {
    return 'Esse arraste mediu $measurement de tela, o que não é um cartão.';
  }

  @override
  String get unitMillimetres => 'mm';

  @override
  String get unitCentimetres => 'cm';

  @override
  String rulerSemanticLabel(String measurement) {
    return 'Régua. Leitura $measurement.';
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
  String get limitPeriodDay => 'dia';

  @override
  String get limitPeriodTrip => 'pescaria';

  @override
  String get limitPeriodSeason => 'temporada';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'janeiro',
      '2': 'fevereiro',
      '3': 'março',
      '4': 'abril',
      '5': 'maio',
      '6': 'junho',
      '7': 'julho',
      '8': 'agosto',
      '9': 'setembro',
      '10': 'outubro',
      '11': 'novembro',
      '12': 'dezembro',
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
    return 'Atende ao mínimo — $measured $unit medidos, mínimo $threshold $unit ($method)';
  }

  @override
  String verdictBelowMinimum(String measured, String unit, String threshold, String method) {
    return 'Abaixo do mínimo — $measured $unit medidos, mínimo $threshold $unit ($method)';
  }

  @override
  String verdictWithinMaximum(String measured, String unit, String threshold, String method) {
    return 'Dentro do máximo — $measured $unit medidos, máximo $threshold $unit ($method)';
  }

  @override
  String verdictAboveMaximum(String measured, String unit, String threshold, String method) {
    return 'Acima do máximo — $measured $unit medidos, máximo $threshold $unit ($method)';
  }

  @override
  String verdictMinimumNotMeasured(String threshold, String unit, String method) {
    return 'Sem medição — o mínimo é $threshold $unit ($method)';
  }

  @override
  String verdictMaximumNotMeasured(String threshold, String unit, String method) {
    return 'Sem medição — o máximo é $threshold $unit ($method)';
  }

  @override
  String verdictSizeMethodMismatch(
    String measuredMethod,
    String threshold,
    String unit,
    String method,
  ) {
    return 'Medido por $measuredMethod — a norma indica $threshold $unit ($method). Nenhuma comparação é feita.';
  }

  @override
  String verdictMarginShortOfMinimum(String margin, String unit) {
    return 'Abaixo do mínimo em $margin $unit';
  }

  @override
  String verdictMarginOverMinimum(String margin, String unit) {
    return 'Acima do mínimo em $margin $unit';
  }

  @override
  String verdictMarginOverMaximum(String margin, String unit) {
    return 'Acima do máximo em $margin $unit';
  }

  @override
  String verdictMarginUnderMaximum(String margin, String unit) {
    return 'Abaixo do máximo em $margin $unit';
  }

  @override
  String verdictClosedSeasonInForce(String starts, String ends, String day, String total) {
    return 'Defeso — de $starts a $ends. Em vigor hoje, dia $day de $total.';
  }

  @override
  String verdictClosedSeasonNotInForce(String starts, String ends) {
    return 'Defeso — de $starts a $ends. Hoje não está em vigor.';
  }

  @override
  String get verdictProtected => 'Espécie protegida — captura proibida.';

  @override
  String verdictWithinBagLimit(String recorded, String limit, String period) {
    return 'Dentro da cota — $recorded registrados, limite $limit por $period';
  }

  @override
  String verdictAboveBagLimit(String recorded, String limit, String period) {
    return 'Acima da cota — $recorded registrados, limite $limit por $period';
  }

  @override
  String verdictBagLimitNotRecorded(String limit, String period) {
    return 'Nada registrado neste período — a cota é $limit por $period';
  }

  @override
  String verdictWithinVesselLimit(String recorded, String limit) {
    return 'Dentro do limite por embarcação — $recorded registrados, limite $limit';
  }

  @override
  String verdictAboveVesselLimit(String recorded, String limit) {
    return 'Acima do limite por embarcação — $recorded registrados, limite $limit';
  }

  @override
  String verdictVesselLimitNotRecorded(String limit) {
    return 'Nada registrado para esta embarcação — o limite é $limit';
  }

  @override
  String get verdictNoRuleRecorded =>
      'Nenhuma norma registrada para esta espécie aqui. Isso não significa que seja legal.';

  @override
  String get verdictNoLimitInInstrument =>
      'A norma foi consultada e não registra nenhum limite para esta espécie aqui.';

  @override
  String get verdictUnknownSpecies =>
      'Esta espécie não está registrada nesta jurisdição. Isso não significa que seja legal.';

  @override
  String get verdictAmbiguous => 'Aqui se aplicam duas normas de mesma hierarquia.';

  @override
  String get findingFactMeasured => 'Medido';

  @override
  String get findingFactMinimum => 'Mínimo';

  @override
  String get findingFactMaximum => 'Máximo';

  @override
  String get findingFactDates => 'Datas';

  @override
  String get findingFactToday => 'Hoje';

  @override
  String get findingFactRecorded => 'Registrado';

  @override
  String get findingFactLimit => 'Limite';

  @override
  String get findingFactPeriod => 'Período';

  @override
  String findingDayOfWindow(String day, String total) {
    return 'dia $day de $total';
  }

  @override
  String findingWindowRange(String starts, String ends) {
    return 'de $starts a $ends';
  }

  @override
  String disclaimerVerdict(String authority) {
    return 'O CatchLaw cita normas publicadas. Não é aconselhamento jurídico e não autoriza nenhuma captura. Convém verificar com $authority antes de se basear nele.';
  }

  @override
  String get citationCopyAction => 'Copiar a citação';

  @override
  String rulePackExpiredOn(String date) {
    return 'Estas normas passaram a sua data final em $date. São exibidas como foram publicadas.';
  }

  @override
  String rulePackProvenance(String pack, String date) {
    return 'O pacote de normas incluído $pack passou a sua data de validade em $date. O texto acima é a última redação verificada.';
  }

  @override
  String get staleDetailClose => 'Fechar esta nota';

  @override
  String get flagRuleAction => 'Sinalizar esta norma';

  @override
  String get flagRuleNoteLabel => 'O que a norma diz';

  @override
  String get flagRuleSaveAction => 'Salvar esta nota neste dispositivo';

  @override
  String get flagRuleRecorded => 'Salva neste dispositivo.';

  @override
  String get flagRuleEmptyNote => 'A nota está vazia.';

  @override
  String get disclaimerNotDismissable => 'Não pode ser dispensado.';

  @override
  String get zonePickerTitle => 'Onde você pesca?';

  @override
  String get zoneLevelCountry => 'País';

  @override
  String get zoneLevelRegion => 'Região';

  @override
  String get zoneLevelSubZone => 'Sub-zona';

  @override
  String get zoneWaterSalt => 'Mar';

  @override
  String get zoneWaterFresh => 'Águas interiores';

  @override
  String get zonePickerConfirm => 'Usar este lugar';

  @override
  String get zonePickerEmptyHeadline => 'Nenhuma norma incluída para este país';

  @override
  String get zonePickerEmptyBody =>
      'Esta versão não traz nenhuma norma transcrita. Isso não significa que não existam.';

  @override
  String get zonePickerLoadFailed => 'Não foi possível ler o pacote de normas incluído.';

  @override
  String countryName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ES': 'Espanha',
      'AE': 'Emirados Árabes Unidos',
      'BR': 'Brasil',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String zoneNoPublishedBoundaries(String authority) {
    return '$authority não publica limites de coordenadas. As normas registradas aqui se aplicam a toda a jurisdição.';
  }

  @override
  String get zoneWaterChoiceRequired =>
      'É preciso escolher mar ou águas interiores antes que este lugar possa responder.';

  @override
  String get navCheck => 'Verificar';

  @override
  String get destinationNotBuiltYet =>
      'Esta versão responde a uma única pergunta: se um peixe cumpre as regras no local onde foi desembarcado. Esta parte ainda não foi construída.';

  @override
  String get settingsLanguageDevice => 'Seguir o aparelho';

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
  String get settingsUnitIn => 'pol';

  @override
  String get settingsLengthUnit => 'Comprimento em';

  @override
  String get settingsSunlightMode => 'Modo sol';

  @override
  String get settingsSunlightNote => 'Contraste máximo, para um ecrã molhado ao sol.';

  @override
  String get settingsGloveMode => 'Modo luvas';

  @override
  String get settingsGloveNote => 'Alvos maiores e mais espaçados.';

  @override
  String get settingsRuler => 'Régua';

  @override
  String get settingsRulerUncalibrated => 'Não calibrada';

  @override
  String settingsRulerCalibrated(String on) {
    return 'Calibrada em $on';
  }

  @override
  String get settingsAboutPack => 'Livro de regras';

  @override
  String get settingsOfflineNote =>
      'A CatchLaw guarda neste telemóvel tudo o que precisa. Não tem conta nem código de rede.';

  @override
  String get todayHeadline => 'Hoje';

  @override
  String get todayNothingRecorded => 'Nada registado hoje';

  @override
  String get todayNothingBody =>
      'A espécie que registares a partir da sua página aparece aqui, com a contagem deste local.';

  @override
  String get todayNoPlace => 'Sem local';

  @override
  String todayCountKept(int count, int kept) {
    return '$count registados · $kept guardados';
  }

  @override
  String get tripsHeadline => 'Saídas';

  @override
  String get tripsNone => 'Ainda não há saídas';

  @override
  String get tripsNoneBody =>
      'Iniciar uma saída agrupa o que registares numa só jornada. Tudo fica neste telemóvel.';

  @override
  String get tripsStart => 'Iniciar saída';

  @override
  String get tripsEnd => 'Terminar saída';

  @override
  String tripsRunning(String since) {
    return 'Em curso desde $since';
  }

  @override
  String tripsEnded(String started, String ended) {
    return '$started — $ended';
  }

  @override
  String get catchRecord => 'Registar esta captura';

  @override
  String get catchRecorded => 'Registado';

  @override
  String get measureTitle => 'Medir';

  @override
  String get measureUncalibrated => 'Este ecrã não está calibrado';

  @override
  String get measureUncalibratedBody =>
      'Um telemóvel informa píxeis, não milímetros, e a proporção varia com o modelo. Até calibrar, o ecrã não pode desenhar uma régua em tamanho real. Escrever um comprimento funciona à mesma.';

  @override
  String get measureManualLabel => 'Ou escreve o comprimento';

  @override
  String get measureUse => 'Usar este comprimento';

  @override
  String get calibrateAction => 'Calibrar o ecrã';

  @override
  String get calibrateTitle => 'Calibrar';

  @override
  String get calibrateFitBody =>
      'Coloca um cartão bancário sobre o ecrã, com o bordo esquerdo contra o bordo esquerdo da caixa, e arrasta a linha preta até ao seu bordo direito.';

  @override
  String get calibrateVerifyBody =>
      'Verifica a linha contra o cartão mais uma vez. Se assentar no bordo, guarda.';

  @override
  String get calibrateVerifyAction => 'Verificar';

  @override
  String get calibrateSaveAction => 'Guardar a calibração';

  @override
  String calibrateCardWidth(String mm) {
    return 'Um cartão bancário tem $mm milímetros de largura (ISO/IEC 7810 ID-1).';
  }

  @override
  String get calibrateImplausible =>
      'Essa escala está fora do intervalo plausível para um ecrã de telemóvel, por isso não foi guardada.';

  @override
  String get todayRemove => 'Remover';

  @override
  String get todayMarkKept => 'Guardado';

  @override
  String get todayUndoOne => 'Remover um';

  @override
  String get measureBackspace => 'Apagar';

  @override
  String get navToday => 'Hoje';

  @override
  String get navTrips => 'Pescarias';

  @override
  String get navReference => 'Referência';

  @override
  String get navSettings => 'Configurações';

  @override
  String get checkPlaceLabel => 'Respondendo para';

  @override
  String get checkChangePlace => 'Mudar de lugar';

  @override
  String get checkRecentsLabel => 'Recentes aqui';

  @override
  String checkPackChecked(String date) {
    return 'verificado $date';
  }

  @override
  String get checkNoRecentsHeadline => 'Nada verificado aqui ainda';

  @override
  String get checkNoRecentsBody =>
      'As espécies que você buscar neste lugar aparecem aqui, e a próxima fica a um toque.';

  @override
  String measureManualReading(String mm) {
    return '$mm milímetros';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'CatchLaw';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count correspondências',
      many: '$count correspondências',
      one: '$count correspondência',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystemDefault => 'Idioma do dispositivo';

  @override
  String get settingsNumeralSystem => 'Algarismos';

  @override
  String get settingsNumeralSystemAuto => 'Padrão do idioma';

  @override
  String get settingsNumeralSystemLatn => 'Ocidentais — 0 1 2 3';

  @override
  String get settingsNumeralSystemArab => 'Arábico-índicos — ٠ ١ ٢ ٣';

  @override
  String legalTextLanguageNotice(String language) {
    return 'O texto literal deste instrumento existe apenas em $language.';
  }

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ar': 'árabe',
      'en': 'inglês',
      'es': 'espanhol',
      'gl': 'galego',
      'ca': 'catalão',
      'ptBR': 'português do Brasil',
      'other': 'inglês',
    });
    return '$_temp0';
  }

  @override
  String get speciesSearchLabel => 'Espécies';

  @override
  String get speciesSearchHint => 'garoupa, mero, Epinephelus';

  @override
  String get speciesGroupInYourZone => 'Na sua zona';

  @override
  String get speciesGroupElsewhere => 'Em outro lugar desta jurisdição';

  @override
  String get speciesHintProtected => 'protegida';

  @override
  String get speciesHintClosed => 'defeso';

  @override
  String get speciesNoMatchHeadline => 'Nenhuma espécie com esse nome';

  @override
  String get speciesNoMatchBody =>
      'O nome pode ser escrito de outra forma aqui, ou a espécie pode ainda não estar transcrita.';

  @override
  String get identifyThisFish => 'Identificar este peixe';

  @override
  String get browseByShape => 'Explorar por forma';

  @override
  String get rulePackExpired =>
      'Estas regras passaram da data de término declarada. São exibidas como publicadas.';

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
  String get browseNoSpeciesHeadline => 'Nenhuma espécie neste pacote';

  @override
  String get browseNoSpeciesBody => 'Esta jurisdição ainda não tem espécies transcritas.';

  @override
  String get speciesOtherNames => 'Outros nomes';

  @override
  String get speciesScientificName => 'Nome científico';

  @override
  String get speciesFamilyLabel => 'Família';

  @override
  String get speciesPlateSemanticLabel => 'Prancha gravada';

  @override
  String get speciesSilhouetteSemanticLabel => 'Desenho de linha';

  @override
  String get speciesProtectedAnywhere => 'Protegida em algum lugar desta jurisdição';

  @override
  String get lookAlikeSectionLabel => 'Confundida facilmente com';

  @override
  String get lookAlikeConfusedWith => 'O que as diferencia';

  @override
  String get recentsStripLabel => 'Recentes aqui';

  @override
  String get recentsEmptyBody => 'As espécies que você abrir nesta zona aparecem aqui.';

  @override
  String get calibrationTitle => 'Meça sua tela';

  @override
  String get calibrationCardExplainer =>
      'Coloque qualquer cartão bancário, carteira ou documento sobre o vidro e arraste a borda até coincidir.';

  @override
  String get calibrationHandleLabel => 'Borda do cartão';

  @override
  String calibrationVerifyExplainer(String measurement) {
    return 'Esta barra tem $measurement. Compare com o lado curto do mesmo cartão.';
  }

  @override
  String calibrationVerifyBarLabel(String measurement) {
    return '$measurement';
  }

  @override
  String get calibrationSaveAction => 'Salvar esta medida';

  @override
  String get calibrationCancelAction => 'Um passo atrás';

  @override
  String get calibrationTooSmallScreen =>
      'Esta tela é mais estreita que um cartão. A entrada manual está disponível.';

  @override
  String calibrationImplausible(String measurement) {
    return 'Esse arraste mediu $measurement de tela, o que não é um cartão.';
  }

  @override
  String get unitMillimetres => 'mm';

  @override
  String get unitCentimetres => 'cm';

  @override
  String rulerSemanticLabel(String measurement) {
    return 'Régua. Leitura $measurement.';
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
  String get limitPeriodDay => 'dia';

  @override
  String get limitPeriodTrip => 'pescaria';

  @override
  String get limitPeriodSeason => 'temporada';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'janeiro',
      '2': 'fevereiro',
      '3': 'março',
      '4': 'abril',
      '5': 'maio',
      '6': 'junho',
      '7': 'julho',
      '8': 'agosto',
      '9': 'setembro',
      '10': 'outubro',
      '11': 'novembro',
      '12': 'dezembro',
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
    return 'Atende ao mínimo — $measured $unit medidos, mínimo $threshold $unit ($method)';
  }

  @override
  String verdictBelowMinimum(String measured, String unit, String threshold, String method) {
    return 'Abaixo do mínimo — $measured $unit medidos, mínimo $threshold $unit ($method)';
  }

  @override
  String verdictWithinMaximum(String measured, String unit, String threshold, String method) {
    return 'Dentro do máximo — $measured $unit medidos, máximo $threshold $unit ($method)';
  }

  @override
  String verdictAboveMaximum(String measured, String unit, String threshold, String method) {
    return 'Acima do máximo — $measured $unit medidos, máximo $threshold $unit ($method)';
  }

  @override
  String verdictMinimumNotMeasured(String threshold, String unit, String method) {
    return 'Sem medição — o mínimo é $threshold $unit ($method)';
  }

  @override
  String verdictMaximumNotMeasured(String threshold, String unit, String method) {
    return 'Sem medição — o máximo é $threshold $unit ($method)';
  }

  @override
  String verdictSizeMethodMismatch(
    String measuredMethod,
    String threshold,
    String unit,
    String method,
  ) {
    return 'Medido por $measuredMethod — a norma indica $threshold $unit ($method). Nenhuma comparação é feita.';
  }

  @override
  String verdictMarginShortOfMinimum(String margin, String unit) {
    return 'Abaixo do mínimo em $margin $unit';
  }

  @override
  String verdictMarginOverMinimum(String margin, String unit) {
    return 'Acima do mínimo em $margin $unit';
  }

  @override
  String verdictMarginOverMaximum(String margin, String unit) {
    return 'Acima do máximo em $margin $unit';
  }

  @override
  String verdictMarginUnderMaximum(String margin, String unit) {
    return 'Abaixo do máximo em $margin $unit';
  }

  @override
  String verdictClosedSeasonInForce(String starts, String ends, String day, String total) {
    return 'Defeso — de $starts a $ends. Em vigor hoje, dia $day de $total.';
  }

  @override
  String verdictClosedSeasonNotInForce(String starts, String ends) {
    return 'Defeso — de $starts a $ends. Hoje não está em vigor.';
  }

  @override
  String get verdictProtected => 'Espécie protegida — captura proibida.';

  @override
  String verdictWithinBagLimit(String recorded, String limit, String period) {
    return 'Dentro da cota — $recorded registrados, limite $limit por $period';
  }

  @override
  String verdictAboveBagLimit(String recorded, String limit, String period) {
    return 'Acima da cota — $recorded registrados, limite $limit por $period';
  }

  @override
  String verdictBagLimitNotRecorded(String limit, String period) {
    return 'Nada registrado neste período — a cota é $limit por $period';
  }

  @override
  String verdictWithinVesselLimit(String recorded, String limit) {
    return 'Dentro do limite por embarcação — $recorded registrados, limite $limit';
  }

  @override
  String verdictAboveVesselLimit(String recorded, String limit) {
    return 'Acima do limite por embarcação — $recorded registrados, limite $limit';
  }

  @override
  String verdictVesselLimitNotRecorded(String limit) {
    return 'Nada registrado para esta embarcação — o limite é $limit';
  }

  @override
  String get verdictNoRuleRecorded =>
      'Nenhuma norma registrada para esta espécie aqui. Isso não significa que seja legal.';

  @override
  String get verdictNoLimitInInstrument =>
      'A norma foi consultada e não registra nenhum limite para esta espécie aqui.';

  @override
  String get verdictUnknownSpecies =>
      'Esta espécie não está registrada nesta jurisdição. Isso não significa que seja legal.';

  @override
  String get verdictAmbiguous => 'Aqui se aplicam duas normas de mesma hierarquia.';

  @override
  String get findingFactMeasured => 'Medido';

  @override
  String get findingFactMinimum => 'Mínimo';

  @override
  String get findingFactMaximum => 'Máximo';

  @override
  String get findingFactDates => 'Datas';

  @override
  String get findingFactToday => 'Hoje';

  @override
  String get findingFactRecorded => 'Registrado';

  @override
  String get findingFactLimit => 'Limite';

  @override
  String get findingFactPeriod => 'Período';

  @override
  String findingDayOfWindow(String day, String total) {
    return 'dia $day de $total';
  }

  @override
  String findingWindowRange(String starts, String ends) {
    return 'de $starts a $ends';
  }

  @override
  String disclaimerVerdict(String authority) {
    return 'O CatchLaw cita normas publicadas. Não é aconselhamento jurídico e não autoriza nenhuma captura. Convém verificar com $authority antes de se basear nele.';
  }

  @override
  String get citationCopyAction => 'Copiar a citação';

  @override
  String rulePackExpiredOn(String date) {
    return 'Estas normas passaram a sua data final em $date. São exibidas como foram publicadas.';
  }

  @override
  String rulePackProvenance(String pack, String date) {
    return 'O pacote de normas incluído $pack passou a sua data de validade em $date. O texto acima é a última redação verificada.';
  }

  @override
  String get staleDetailClose => 'Fechar esta nota';

  @override
  String get flagRuleAction => 'Sinalizar esta norma';

  @override
  String get flagRuleNoteLabel => 'O que a norma diz';

  @override
  String get flagRuleSaveAction => 'Salvar esta nota neste dispositivo';

  @override
  String get flagRuleRecorded => 'Salva neste dispositivo.';

  @override
  String get flagRuleEmptyNote => 'A nota está vazia.';

  @override
  String get disclaimerNotDismissable => 'Não pode ser dispensado.';

  @override
  String get zonePickerTitle => 'Onde você pesca?';

  @override
  String get zoneLevelCountry => 'País';

  @override
  String get zoneLevelRegion => 'Região';

  @override
  String get zoneLevelSubZone => 'Sub-zona';

  @override
  String get zoneWaterSalt => 'Mar';

  @override
  String get zoneWaterFresh => 'Águas interiores';

  @override
  String get zonePickerConfirm => 'Usar este lugar';

  @override
  String get zonePickerEmptyHeadline => 'Nenhuma norma incluída para este país';

  @override
  String get zonePickerEmptyBody =>
      'Esta versão não traz nenhuma norma transcrita. Isso não significa que não existam.';

  @override
  String get zonePickerLoadFailed => 'Não foi possível ler o pacote de normas incluído.';

  @override
  String countryName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ES': 'Espanha',
      'AE': 'Emirados Árabes Unidos',
      'BR': 'Brasil',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String zoneNoPublishedBoundaries(String authority) {
    return '$authority não publica limites de coordenadas. As normas registradas aqui se aplicam a toda a jurisdição.';
  }

  @override
  String get zoneWaterChoiceRequired =>
      'É preciso escolher mar ou águas interiores antes que este lugar possa responder.';

  @override
  String get navCheck => 'Verificar';

  @override
  String get destinationNotBuiltYet =>
      'Esta versão responde a uma única pergunta: se um peixe cumpre as regras no local onde foi desembarcado. Esta parte ainda não foi construída.';

  @override
  String get settingsLanguageDevice => 'Seguir o aparelho';

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
  String get settingsUnitIn => 'pol';

  @override
  String get settingsLengthUnit => 'Comprimento em';

  @override
  String get settingsSunlightMode => 'Modo sol';

  @override
  String get settingsSunlightNote => 'Contraste máximo, para uma tela molhada no sol.';

  @override
  String get settingsGloveMode => 'Modo luvas';

  @override
  String get settingsGloveNote => 'Alvos maiores e mais espaçados.';

  @override
  String get settingsRuler => 'Régua';

  @override
  String get settingsRulerUncalibrated => 'Não calibrada';

  @override
  String settingsRulerCalibrated(String on) {
    return 'Calibrada em $on';
  }

  @override
  String get settingsAboutPack => 'Livro de regras';

  @override
  String get settingsOfflineNote =>
      'O CatchLaw guarda neste celular tudo o que precisa. Não tem conta nem código de rede.';

  @override
  String get todayHeadline => 'Hoje';

  @override
  String get todayNothingRecorded => 'Nada registrado hoje';

  @override
  String get todayNothingBody =>
      'A espécie que você registrar na página dela aparece aqui, com a contagem deste local.';

  @override
  String get todayNoPlace => 'Sem local';

  @override
  String todayCountKept(int count, int kept) {
    return '$count registrados · $kept guardados';
  }

  @override
  String get tripsHeadline => 'Saídas';

  @override
  String get tripsNone => 'Ainda não há saídas';

  @override
  String get tripsNoneBody =>
      'Iniciar uma saída agrupa o que você registrar em uma só jornada. Tudo fica neste celular.';

  @override
  String get tripsStart => 'Iniciar saída';

  @override
  String get tripsEnd => 'Encerrar saída';

  @override
  String tripsRunning(String since) {
    return 'Em andamento desde $since';
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
  String get measureUncalibrated => 'Esta tela não está calibrada';

  @override
  String get measureUncalibratedBody =>
      'Um celular informa pixels, não milímetros, e a proporção varia conforme o modelo. Até calibrar, a tela não pode desenhar uma régua em tamanho real. Digitar um comprimento funciona do mesmo jeito.';

  @override
  String get measureManualLabel => 'Ou digite o comprimento';

  @override
  String get measureUse => 'Usar este comprimento';

  @override
  String get calibrateAction => 'Calibrar a tela';

  @override
  String get calibrateTitle => 'Calibrar';

  @override
  String get calibrateFitBody =>
      'Coloque um cartão bancário sobre a tela, com a borda esquerda contra a borda esquerda da caixa, e arraste a linha preta até a borda direita dele.';

  @override
  String get calibrateVerifyBody =>
      'Confira a linha contra o cartão mais uma vez. Se estiver na borda, salve.';

  @override
  String get calibrateVerifyAction => 'Conferir';

  @override
  String get calibrateSaveAction => 'Salvar a calibração';

  @override
  String calibrateCardWidth(String mm) {
    return 'Um cartão bancário tem $mm milímetros de largura (ISO/IEC 7810 ID-1).';
  }

  @override
  String get calibrateImplausible =>
      'Essa escala está fora da faixa plausível para uma tela de celular, então não foi salva.';

  @override
  String get todayRemove => 'Remover';

  @override
  String get todayMarkKept => 'Guardado';

  @override
  String get todayUndoOne => 'Remover um';

  @override
  String get measureBackspace => 'Apagar';

  @override
  String get navToday => 'Hoje';

  @override
  String get navTrips => 'Pescarias';

  @override
  String get navReference => 'Referência';

  @override
  String get navSettings => 'Configurações';

  @override
  String get checkPlaceLabel => 'Respondendo para';

  @override
  String get checkChangePlace => 'Mudar de lugar';

  @override
  String get checkRecentsLabel => 'Recentes aqui';

  @override
  String checkPackChecked(String date) {
    return 'verificado $date';
  }

  @override
  String get checkNoRecentsHeadline => 'Nada verificado aqui ainda';

  @override
  String get checkNoRecentsBody =>
      'As espécies que você buscar neste lugar aparecem aqui, e a próxima fica a um toque.';

  @override
  String measureManualReading(String mm) {
    return '$mm milímetros';
  }
}
