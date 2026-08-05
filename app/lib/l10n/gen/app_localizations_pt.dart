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
  String identifyKeyStamp(int couplet) {
    return 'Chave · passo $couplet';
  }

  @override
  String get identifyAnswersSoFar => 'Respostas até agora';

  @override
  String identifyCoupletLabel(int couplet) {
    return 'Passo $couplet';
  }

  @override
  String identifySpeciesRemain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'restam $count espécies',
      many: 'restam $count espécies',
      one: 'resta $count espécie',
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
      other: 'Leva a $count espécies · $names',
      many: 'Leva a $count espécies · $names',
      one: 'Leva a $count espécie · $names',
    );
    return '$_temp0';
  }

  @override
  String get identifyLeadNoSpecies => 'Não há espécies registadas além desta resposta.';

  @override
  String get identifyBackOneStep => 'Voltar um passo';

  @override
  String get identifyDamagedHeading => 'Se o caráter não se vê';

  @override
  String get identifyDamagedNote =>
      'Um caráter danificado ou ausente não pode ser respondido. Em vez disso, são listadas, desenhadas e nomeadas, todas as espécies que este passo ainda permite.';

  @override
  String get identifyListWhatRemains => 'Listar o que resta';

  @override
  String get identifyProvenanceNote =>
      'Nenhuma fotografia é tirada e nada sai do dispositivo. A chave é a impressa da secção de referência, percorrida passo a passo.';

  @override
  String get identifyRemainingHeading => 'Espécies que a chave ainda permite';

  @override
  String get identifyNoKeyHeadline => 'Nenhuma chave neste pacote';

  @override
  String get identifyNoKeyBody =>
      'Esta jurisdição não tem nenhuma chave de identificação transcrita. As espécies que este pacote leva alcançam-se pelo nome.';

  @override
  String get identifyNoCandidatesHeadline => 'Nenhuma espécie registada aqui';

  @override
  String get identifyNoCandidatesBody =>
      'A chave não alcança nenhuma espécie com as respostas dadas. Além deste ponto nada está transcrito neste pacote.';

  @override
  String get identifyKeyUnreadableHeadline => 'Não foi possível ler a chave';

  @override
  String get identifyKeyUnreadableBody =>
      'A chave do pacote incluído não abriu neste dispositivo. As espécies que leva alcançam-se pelo nome.';

  @override
  String get identifySearchByName => 'Procurar pelo nome';

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
  String speciesSearchMatchCount(int count) {
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
  String get speciesSearchClear => 'Limpar a pesquisa';

  @override
  String get browseByShapeTitle => 'Explorar por forma';

  @override
  String get browseNoSpeciesHeadline => 'Nenhuma espécie neste pacote';

  @override
  String get browseNoSpeciesBody => 'Esta jurisdição ainda não tem espécies transcritas.';

  @override
  String browseSpeciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espécies',
      many: '$count espécies',
      one: '$count espécie',
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
    return 'mais em $family';
  }

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
  String get verdictStampMeetsMinimum => 'Atende ao mínimo';

  @override
  String get verdictStampBelowMinimum => 'Abaixo do mínimo';

  @override
  String get verdictStampWithinMaximum => 'Dentro do máximo';

  @override
  String get verdictStampAboveMaximum => 'Acima do máximo';

  @override
  String get verdictStampNotMeasured => 'Sem medição';

  @override
  String get verdictStampMethodMismatch => 'Medido por outro método';

  @override
  String verdictStampClosedSeason(String starts, String ends) {
    return 'Defeso — de $starts a $ends';
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
    return 'Nada medido · mínimo $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximumUnmeasured(String threshold, String unit, String method) {
    return 'Nada medido · máximo $threshold $unit · $method';
  }

  @override
  String verdictDetailClosedSeasonInForce(String day, String total) {
    return 'Em vigor hoje, dia $day de $total · aplica-se a todos os tamanhos';
  }

  @override
  String get verdictDetailClosedSeasonNotInForce => 'Hoje não está em vigor';

  @override
  String speciesBinomialFamily(String binomial, String family) {
    return '$binomial — $family';
  }

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
  String get ambiguityEyebrow => 'Conflito de instrumentos';

  @override
  String get ambiguityBothInForce =>
      'Ambos os instrumentos estão em vigor neste ponto. O CatchLaw imprime o texto de cada um com a sua própria data de verificação e não coloca nenhum acima do outro.';

  @override
  String get findingFactMeasured => 'Medido';

  @override
  String get findingFactMinimum => 'Mínimo';

  @override
  String get findingFactMaximum => 'Máximo';

  @override
  String get findingFactShortfall => 'Diferença';

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
  String get penaltiesTitle => 'Sanções';

  @override
  String get penaltiesEntryNote => 'O que acarreta o incumprimento das regras registadas.';

  @override
  String penaltiesLede(String jurisdiction) {
    return 'O que acarreta o incumprimento das regras de tamanho, defeso, proteção ou arte em $jurisdiction.';
  }

  @override
  String get penaltiesColumnOffence => 'Infração';

  @override
  String get penaltiesColumnFine => 'Coima';

  @override
  String get penaltiesColumnLicence => 'Licença';

  @override
  String get penaltiesOccurrenceFirst => 'Primeira infração';

  @override
  String get penaltiesOccurrenceSecond => 'Segunda infração';

  @override
  String get penaltiesOccurrenceSubsequent => 'Infração posterior';

  @override
  String get penaltiesOffenceListLabel => 'Infrações registadas';

  @override
  String penaltiesFineAmount(String currency, String amount) {
    return '$amount $currency';
  }

  @override
  String penaltiesFineRange(String currency, String lower, String upper) {
    return '$lower–$upper $currency';
  }

  @override
  String get penaltiesFineNotRecorded => 'Sem valor registado';

  @override
  String get penaltiesConsequenceNotRecorded => 'Sem consequência registada para a licença';

  @override
  String get penaltiesWorkedExampleLabel => 'Exemplo resolvido';

  @override
  String penaltiesWorkedExampleFirst(String offence, String jurisdiction, String fine) {
    return 'A primeira infração de $offence consta em $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleSecond(String offence, String jurisdiction, String fine) {
    return 'A segunda infração de $offence consta em $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleSubsequent(String offence, String jurisdiction, String fine) {
    return 'A infração posterior de $offence consta em $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleConsequence(String consequence) {
    return 'A consequência registada para a licença é $consequence.';
  }

  @override
  String get penaltiesNoneRecordedHeadline => 'Sem sanção registada';

  @override
  String penaltiesNoneRecordedBody(String jurisdiction) {
    return 'O pacote de regras incluído não contém nenhuma sanção transcrita para $jurisdiction. É uma ausência na transcrição, não uma afirmação de que os instrumentos não contenham nenhuma.';
  }

  @override
  String get penaltiesPackCaveat =>
      'Os valores são os registados no pacote de regras incluído. Os tribunais e os inspetores podem aplicar outras disposições.';

  @override
  String penaltiesCitationDates(String published, String checked) {
    return 'publicado $published · verificado $checked';
  }

  @override
  String get disclaimerNotDismissable => 'Não pode ser dispensado.';

  @override
  String get zonePickerTitle => 'Onde você pesca?';

  @override
  String get zoneLevelCountry => 'País';

  @override
  String get zoneLevelRegion => 'Região';

  @override
  String get tripsKeptHere => 'Guardado apenas neste dispositivo';

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
  String get tripsOpenMark => '· em curso';

  @override
  String get tripsOpenStamp => 'Em curso';

  @override
  String tripsDuration(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get tripsLoadFailed => 'Não foi possível ler as saídas deste dispositivo.';

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
  String get settingsGroupLanguage => 'Idioma e algarismos';

  @override
  String get settingsGroupPlace => 'Onde pescas';

  @override
  String get settingsGroupReading => 'Condições de leitura';

  @override
  String get settingsDigitsNote => 'Algarismos ocidentais ou árabe-índicos';

  @override
  String get settingsLengthUnitNote => 'Comprimentos nas normas e nas leituras';

  @override
  String get settingsZone => 'Zona';

  @override
  String get settingsZoneNote => 'As normas, a lista de espécies e os limites seguem isto';

  @override
  String get settingsZoneUnset => 'Nenhum lugar escolhido';

  @override
  String settingsRulerScale(String px) {
    return '$px px / 10 milímetros';
  }

  @override
  String get settingsCoordinates => 'Captura de coordenadas';

  @override
  String get settingsCoordinatesNote => 'Guardadas só neste telemóvel, nunca transmitidas';

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
  String todayTripOpenSince(String started) {
    return 'Saída em curso desde as $started';
  }

  @override
  String get todayNoTripOpen => 'Nenhuma saída em curso';

  @override
  String get todaySummaryRecorded => 'Peixes registados';

  @override
  String get todaySummaryKept => 'Guardados';

  @override
  String get todaySummarySpecies => 'Espécies';

  @override
  String todayKeptOfCount(String kept, String count) {
    return '$kept de $count';
  }

  @override
  String get todayBySpeciesLabel => 'Por espécie';

  @override
  String get todayLoadFailed => 'Não foi possível ler a contagem de hoje deste dispositivo.';

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
  String get measureSup => 'Régua';

  @override
  String measureCalibrationProvenance(String on, String pxPer10mm) {
    return 'Calibrado em $on · $pxPer10mm píxeis por centímetro';
  }

  @override
  String get measureStepAndMark => 'Marcar por troços';

  @override
  String get measureRunningTotalUnit => 'cm até agora';

  @override
  String measureStepPill(String count) {
    return 'Troço $count';
  }

  @override
  String get measureStepNote =>
      'Encosta a borda do ecrã ao focinho, marca, desliza o telemóvel ao longo do peixe e marca outra vez.';

  @override
  String get measureTypeInstead => 'Escrever a medida';

  @override
  String get measureRecalibrate => 'Recalibrar com um cartão';

  @override
  String get measurePrivacyNote =>
      'O peixe na tábua, o telemóvel sobre o peixe. Não é tirada nenhuma fotografia nem é lida nenhuma coordenada a não ser que a captura de coordenadas esteja ligada nas Definições.';

  @override
  String get measureManualTitle => 'Escrever o comprimento';

  @override
  String get calibrateSup => 'Uma vez por dispositivo';

  @override
  String calibrateCardConstant(String width, String height) {
    return 'Todos os cartões deste formato são idênticos: ISO/IEC 7810 ID-1 — $width × $height milímetros';
  }

  @override
  String calibrateDimension(String mm) {
    return '$mm milímetros';
  }

  @override
  String get calibrateDragHandleNote => 'Arrasta a pega preenchida.';

  @override
  String get calibrateScaleLabel => 'Escala resultante';

  @override
  String get calibrateRowScale => 'Píxeis por centímetro';

  @override
  String get calibrateRowDensity => 'Densidade do ecrã';

  @override
  String get calibrateRowError => 'Erro esperado';

  @override
  String get calibrateRowLastCalibrated => 'Última calibração';

  @override
  String calibrateDensityValue(String dp, String ratio) {
    return '$dp dp · $ratio×';
  }

  @override
  String calibrateErrorValue(String mm) {
    return '± $mm milímetros em 30 centímetros';
  }

  @override
  String get calibrateNotYet => 'Ainda sem calibração';

  @override
  String get calibrateReset => 'Repor o valor do ecrã';

  @override
  String get calibrateGlassNote =>
      'Uma capa ou uma película não mudam nada: o cartão assenta no vidro e o vidro é o que está a ser medido.';

  @override
  String get measureBackspace => 'Apagar';

  @override
  String get navBack => 'Voltar';

  @override
  String get navToday => 'Hoje';

  @override
  String get navTrips => 'Pescarias';

  @override
  String get navReference => 'Referência';

  @override
  String get referenceContentsLabel => 'Índice';

  @override
  String get referenceHubLede =>
      'Tudo aquilo de que um veredicto é extraído, guardado por inteiro neste dispositivo e legível sem rede.';

  @override
  String get referenceEntryRuleText => 'Texto normativo';

  @override
  String get referenceEntryRuleTextNote =>
      'Os instrumentos tal como foram publicados, artigo a artigo, na língua de publicação';

  @override
  String get ruleTextSearchHint => 'Pesquisar no texto integral';

  @override
  String get ruleTextAllArticles => 'Todos os artigos';

  @override
  String get ruleTextPublishedLabel => 'Publicado';

  @override
  String get ruleTextCheckedLabel => 'Verificado';

  @override
  String get ruleTextCompleteNote =>
      'Este texto está guardado na íntegra neste dispositivo e não está abreviado.';

  @override
  String get ruleTextNoneRecordedHeadline => 'Sem texto transcrito';

  @override
  String ruleTextNoneRecordedBody(String instrument) {
    return 'Esta cópia não contém o texto dos artigos de $instrument. A citação acima nomeia o instrumento e as datas de publicação e da última verificação.';
  }

  @override
  String get ruleTextNoMatchHeadline => 'Nenhum artigo corresponde';

  @override
  String get ruleTextNoMatchBody => 'Nenhum artigo deste instrumento contém essa redação.';

  @override
  String get referenceEntryProtected => 'Espécies protegidas';

  @override
  String get referenceEntryProtectedNote =>
      'Estampas, traços distintivos e o que a proteção abrange';

  @override
  String get referenceEntryGear => 'Artes e métodos';

  @override
  String get referenceEntryGearNote =>
      'Malha, linha de mão, comprimento de rede, métodos proibidos';

  @override
  String get referenceEntryPenalties => 'Sanções';

  @override
  String get referenceEntryPenaltiesNote => 'Coimas e consequências para a licença, por infração';

  @override
  String get referenceEntryLicences => 'Licenças';

  @override
  String get referenceEntryLicencesNote =>
      'Licenças de embarcação, de pescador e de arte, e o que cada uma abrange';

  @override
  String get referenceEntryGlossary => 'Glossário';

  @override
  String get referenceEntryGlossaryNote => 'TL · FL · SL · CW · SHL · ML e os termos locais';

  @override
  String get referenceEntryChangelog => 'Registo de alterações';

  @override
  String get referenceEntryChangelogNote => 'O que mudou em cada pacote e quando foi verificado';

  @override
  String get referenceEntryPlates => 'Estampas de espécies';

  @override
  String get referenceEntryPlatesNote =>
      'Silhuetas agrupadas por família, para um peixe conhecido pela forma';

  @override
  String get referenceEntryNotPrinted => 'não impresso';

  @override
  String get referenceSectionNotPrinted =>
      'Esta secção não está impressa neste exemplar. Esta versão responde se um peixe cumpre as regras no local onde foi desembarcado, e cita o instrumento lido.';

  @override
  String get referenceHeldLabel => 'Guardado neste dispositivo';

  @override
  String referenceHeldPack(String version, String checkedOn) {
    return 'pacote $version · verificado $checkedOn';
  }

  @override
  String get referenceHeldNote => 'Este livro cita os instrumentos que guarda. Não os resume.';

  @override
  String get referenceHeldEmpty => 'Este exemplar não guarda nenhuma jurisdição.';

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
  String get firstRunOfflineBadge => 'Sem sinal · sem rede, por definição';

  @override
  String get firstRunTagline => 'Isto é legal?';

  @override
  String get firstRunMetaFirstRun => 'Primeira execução';

  @override
  String get firstRunMetaOnceOnly => 'Uma única vez';

  @override
  String get firstRunHeadline => 'Compondo o livro de regras';

  @override
  String get firstRunLede =>
      'O pacote de regras incluído, as estampas e o texto legal estão sendo desempacotados, para que daqui em diante tudo abra na hora.';

  @override
  String get firstRunSilhouetteLabel => 'Silhueta gravada de uma garoupa';

  @override
  String firstRunProgressBytes(String written, String total) {
    return '$written de $total kB';
  }

  @override
  String firstRunProgressPercent(String percent) {
    return '$percent%';
  }

  @override
  String get firstRunSectionInstalling => 'Em instalação';

  @override
  String get firstRunStageRulePack => 'Pacote de regras';

  @override
  String get firstRunStageLegalText => 'Texto legal';

  @override
  String get firstRunStagePlates => 'Estampas de espécies';

  @override
  String get firstRunStageGlossary => 'Glossário e chave';

  @override
  String get firstRunStageDone => '· pronto';

  @override
  String get firstRunStageInProgress => 'Em andamento…';

  @override
  String get firstRunStagePending => 'Ainda não desempacotado';

  @override
  String firstRunTimeRemaining(String seconds) {
    return 'Faltam cerca de $seconds s';
  }

  @override
  String get firstRunNoDownload =>
      'Isto acontece uma única vez. Nada está sendo baixado: tudo já estava dentro do aplicativo na instalação, e não há nenhuma requisição de rede que possa falhar.';

  @override
  String get firstRunFooterNote =>
      'Sem conta. Sem início de sessão. Sem sincronização. Quando isto terminar, o CatchLaw nunca mais espera por nada.';

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
  String identifyKeyStamp(int couplet) {
    return 'Chave · passo $couplet';
  }

  @override
  String get identifyAnswersSoFar => 'Respostas até agora';

  @override
  String identifyCoupletLabel(int couplet) {
    return 'Passo $couplet';
  }

  @override
  String identifySpeciesRemain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'restam $count espécies',
      many: 'restam $count espécies',
      one: 'resta $count espécie',
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
      other: 'Leva a $count espécies · $names',
      many: 'Leva a $count espécies · $names',
      one: 'Leva a $count espécie · $names',
    );
    return '$_temp0';
  }

  @override
  String get identifyLeadNoSpecies => 'Não há espécies registradas além desta resposta.';

  @override
  String get identifyBackOneStep => 'Voltar um passo';

  @override
  String get identifyDamagedHeading => 'Se o caractere não é visível';

  @override
  String get identifyDamagedNote =>
      'Um caractere danificado ou ausente não pode ser respondido. Em vez disso, são listadas, desenhadas e nomeadas, todas as espécies que este passo ainda permite.';

  @override
  String get identifyListWhatRemains => 'Listar o que resta';

  @override
  String get identifyProvenanceNote =>
      'Nenhuma fotografia é tirada e nada sai do dispositivo. A chave é a impressa da seção de referência, percorrida passo a passo.';

  @override
  String get identifyRemainingHeading => 'Espécies que a chave ainda permite';

  @override
  String get identifyNoKeyHeadline => 'Nenhuma chave neste pacote';

  @override
  String get identifyNoKeyBody =>
      'Esta jurisdição não tem nenhuma chave de identificação transcrita. As espécies que este pacote leva são alcançadas pelo nome.';

  @override
  String get identifyNoCandidatesHeadline => 'Nenhuma espécie registrada aqui';

  @override
  String get identifyNoCandidatesBody =>
      'A chave não alcança nenhuma espécie com as respostas dadas. Além deste ponto nada está transcrito neste pacote.';

  @override
  String get identifyKeyUnreadableHeadline => 'Não foi possível ler a chave';

  @override
  String get identifyKeyUnreadableBody =>
      'A chave do pacote incluído não abriu neste dispositivo. As espécies que ele leva são alcançadas pelo nome.';

  @override
  String get identifySearchByName => 'Buscar pelo nome';

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
  String speciesSearchMatchCount(int count) {
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
  String get speciesSearchClear => 'Limpar a busca';

  @override
  String get browseByShapeTitle => 'Explorar por forma';

  @override
  String get browseNoSpeciesHeadline => 'Nenhuma espécie neste pacote';

  @override
  String get browseNoSpeciesBody => 'Esta jurisdição ainda não tem espécies transcritas.';

  @override
  String browseSpeciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count espécies',
      many: '$count espécies',
      one: '$count espécie',
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
    return 'mais em $family';
  }

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
  String get verdictStampMeetsMinimum => 'Atende ao mínimo';

  @override
  String get verdictStampBelowMinimum => 'Abaixo do mínimo';

  @override
  String get verdictStampWithinMaximum => 'Dentro do máximo';

  @override
  String get verdictStampAboveMaximum => 'Acima do máximo';

  @override
  String get verdictStampNotMeasured => 'Sem medição';

  @override
  String get verdictStampMethodMismatch => 'Medido por outro método';

  @override
  String verdictStampClosedSeason(String starts, String ends) {
    return 'Defeso — de $starts a $ends';
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
    return 'Nada medido · mínimo $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximumUnmeasured(String threshold, String unit, String method) {
    return 'Nada medido · máximo $threshold $unit · $method';
  }

  @override
  String verdictDetailClosedSeasonInForce(String day, String total) {
    return 'Em vigor hoje, dia $day de $total · aplica-se a todos os tamanhos';
  }

  @override
  String get verdictDetailClosedSeasonNotInForce => 'Hoje não está em vigor';

  @override
  String speciesBinomialFamily(String binomial, String family) {
    return '$binomial — $family';
  }

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
  String get ambiguityEyebrow => 'Conflito de instrumentos';

  @override
  String get ambiguityBothInForce =>
      'Os dois instrumentos estão em vigor neste ponto. O CatchLaw imprime o texto de cada um com a sua própria data de verificação e não coloca nenhum acima do outro.';

  @override
  String get findingFactMeasured => 'Medido';

  @override
  String get findingFactMinimum => 'Mínimo';

  @override
  String get findingFactMaximum => 'Máximo';

  @override
  String get findingFactShortfall => 'Diferença';

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
  String get penaltiesTitle => 'Penalidades';

  @override
  String get penaltiesEntryNote => 'O que acarreta o descumprimento das regras registradas.';

  @override
  String penaltiesLede(String jurisdiction) {
    return 'O que acarreta o descumprimento das regras de tamanho, defeso, proteção ou petrecho em $jurisdiction.';
  }

  @override
  String get penaltiesColumnOffence => 'Infração';

  @override
  String get penaltiesColumnFine => 'Multa';

  @override
  String get penaltiesColumnLicence => 'Licença';

  @override
  String get penaltiesOccurrenceFirst => 'Primeira infração';

  @override
  String get penaltiesOccurrenceSecond => 'Segunda infração';

  @override
  String get penaltiesOccurrenceSubsequent => 'Infração posterior';

  @override
  String get penaltiesOffenceListLabel => 'Infrações registradas';

  @override
  String penaltiesFineAmount(String currency, String amount) {
    return '$amount $currency';
  }

  @override
  String penaltiesFineRange(String currency, String lower, String upper) {
    return '$lower–$upper $currency';
  }

  @override
  String get penaltiesFineNotRecorded => 'Sem valor registrado';

  @override
  String get penaltiesConsequenceNotRecorded => 'Sem consequência registrada para a licença';

  @override
  String get penaltiesWorkedExampleLabel => 'Exemplo resolvido';

  @override
  String penaltiesWorkedExampleFirst(String offence, String jurisdiction, String fine) {
    return 'A primeira infração de $offence consta em $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleSecond(String offence, String jurisdiction, String fine) {
    return 'A segunda infração de $offence consta em $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleSubsequent(String offence, String jurisdiction, String fine) {
    return 'A infração posterior de $offence consta em $jurisdiction como $fine.';
  }

  @override
  String penaltiesWorkedExampleConsequence(String consequence) {
    return 'A consequência registrada para a licença é $consequence.';
  }

  @override
  String get penaltiesNoneRecordedHeadline => 'Sem penalidade registrada';

  @override
  String penaltiesNoneRecordedBody(String jurisdiction) {
    return 'O pacote de regras embarcado não contém nenhuma penalidade transcrita para $jurisdiction. É uma ausência na transcrição, não uma afirmação de que os instrumentos não contenham nenhuma.';
  }

  @override
  String get penaltiesPackCaveat =>
      'Os valores são os registrados no pacote de regras embarcado. Tribunais e fiscais podem aplicar outras disposições.';

  @override
  String penaltiesCitationDates(String published, String checked) {
    return 'publicado $published · verificado $checked';
  }

  @override
  String get disclaimerNotDismissable => 'Não pode ser dispensado.';

  @override
  String get zonePickerTitle => 'Onde você pesca?';

  @override
  String get zoneLevelCountry => 'País';

  @override
  String get zoneLevelRegion => 'Região';

  @override
  String get tripsKeptHere => 'Guardado apenas neste aparelho';

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
  String get tripsOpenMark => '· em andamento';

  @override
  String get tripsOpenStamp => 'Em andamento';

  @override
  String tripsDuration(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get tripsLoadFailed => 'Não foi possível ler as saídas deste aparelho.';

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
  String get settingsGroupLanguage => 'Idioma e algarismos';

  @override
  String get settingsGroupPlace => 'Onde você pesca';

  @override
  String get settingsGroupReading => 'Condições de leitura';

  @override
  String get settingsDigitsNote => 'Algarismos ocidentais ou árabe-índicos';

  @override
  String get settingsLengthUnitNote => 'Comprimentos nas normas e nas leituras';

  @override
  String get settingsZone => 'Zona';

  @override
  String get settingsZoneNote => 'As normas, a lista de espécies e os limites seguem isto';

  @override
  String get settingsZoneUnset => 'Nenhum lugar escolhido';

  @override
  String settingsRulerScale(String px) {
    return '$px px / 10 milímetros';
  }

  @override
  String get settingsCoordinates => 'Captura de coordenadas';

  @override
  String get settingsCoordinatesNote => 'Guardadas só neste celular, nunca transmitidas';

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
  String todayTripOpenSince(String started) {
    return 'Saída em andamento desde as $started';
  }

  @override
  String get todayNoTripOpen => 'Nenhuma saída em andamento';

  @override
  String get todaySummaryRecorded => 'Peixes registrados';

  @override
  String get todaySummaryKept => 'Guardados';

  @override
  String get todaySummarySpecies => 'Espécies';

  @override
  String todayKeptOfCount(String kept, String count) {
    return '$kept de $count';
  }

  @override
  String get todayBySpeciesLabel => 'Por espécie';

  @override
  String get todayLoadFailed => 'Não foi possível ler a contagem de hoje deste aparelho.';

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
  String get measureSup => 'Régua';

  @override
  String measureCalibrationProvenance(String on, String pxPer10mm) {
    return 'Calibrado em $on · $pxPer10mm pixels por centímetro';
  }

  @override
  String get measureStepAndMark => 'Marcar por trechos';

  @override
  String get measureRunningTotalUnit => 'cm até agora';

  @override
  String measureStepPill(String count) {
    return 'Trecho $count';
  }

  @override
  String get measureStepNote =>
      'Encoste a borda da tela no focinho, marque, deslize o celular ao longo do peixe e marque de novo.';

  @override
  String get measureTypeInstead => 'Digitar a medida';

  @override
  String get measureRecalibrate => 'Recalibrar com um cartão';

  @override
  String get measurePrivacyNote =>
      'O peixe na tábua, o celular sobre o peixe. Nenhuma fotografia é tirada e nenhuma coordenada é lida a menos que a captura de coordenadas esteja ligada nas Configurações.';

  @override
  String get measureManualTitle => 'Digitar o comprimento';

  @override
  String get calibrateSup => 'Uma vez por aparelho';

  @override
  String calibrateCardConstant(String width, String height) {
    return 'Todos os cartões deste formato são idênticos: ISO/IEC 7810 ID-1 — $width × $height milímetros';
  }

  @override
  String calibrateDimension(String mm) {
    return '$mm milímetros';
  }

  @override
  String get calibrateDragHandleNote => 'Arraste a alça preenchida.';

  @override
  String get calibrateScaleLabel => 'Escala resultante';

  @override
  String get calibrateRowScale => 'Pixels por centímetro';

  @override
  String get calibrateRowDensity => 'Densidade da tela';

  @override
  String get calibrateRowError => 'Erro esperado';

  @override
  String get calibrateRowLastCalibrated => 'Última calibração';

  @override
  String calibrateDensityValue(String dp, String ratio) {
    return '$dp dp · $ratio×';
  }

  @override
  String calibrateErrorValue(String mm) {
    return '± $mm milímetros em 30 centímetros';
  }

  @override
  String get calibrateNotYet => 'Ainda sem calibração';

  @override
  String get calibrateReset => 'Restaurar o valor da tela';

  @override
  String get calibrateGlassNote =>
      'Uma capa ou uma película não mudam nada: o cartão fica sobre o vidro e o vidro é o que está sendo medido.';

  @override
  String get measureBackspace => 'Apagar';

  @override
  String get navBack => 'Voltar';

  @override
  String get navToday => 'Hoje';

  @override
  String get navTrips => 'Pescarias';

  @override
  String get navReference => 'Referência';

  @override
  String get referenceContentsLabel => 'Índice';

  @override
  String get referenceHubLede =>
      'Tudo de que um veredicto é extraído, guardado por inteiro neste aparelho e legível sem sinal.';

  @override
  String get referenceEntryRuleText => 'Texto normativo';

  @override
  String get referenceEntryRuleTextNote =>
      'Os instrumentos como foram publicados, artigo por artigo, no idioma de publicação';

  @override
  String get ruleTextSearchHint => 'Buscar no texto integral';

  @override
  String get ruleTextAllArticles => 'Todos os artigos';

  @override
  String get ruleTextPublishedLabel => 'Publicado';

  @override
  String get ruleTextCheckedLabel => 'Verificado';

  @override
  String get ruleTextCompleteNote =>
      'Este texto está guardado na íntegra neste aparelho e não está abreviado.';

  @override
  String get ruleTextNoneRecordedHeadline => 'Sem texto transcrito';

  @override
  String ruleTextNoneRecordedBody(String instrument) {
    return 'Esta cópia não contém o texto dos artigos de $instrument. A citação acima nomeia o instrumento e as datas de publicação e da última verificação.';
  }

  @override
  String get ruleTextNoMatchHeadline => 'Nenhum artigo corresponde';

  @override
  String get ruleTextNoMatchBody => 'Nenhum artigo deste instrumento contém essa redação.';

  @override
  String get referenceEntryProtected => 'Espécies protegidas';

  @override
  String get referenceEntryProtectedNote =>
      'Pranchas, traços distintivos e o que a proteção abrange';

  @override
  String get referenceEntryGear => 'Petrechos e métodos';

  @override
  String get referenceEntryGearNote =>
      'Malha, linha de mão, comprimento de rede, métodos proibidos';

  @override
  String get referenceEntryPenalties => 'Penalidades';

  @override
  String get referenceEntryPenaltiesNote => 'Multas e consequências para a licença, por infração';

  @override
  String get referenceEntryLicences => 'Licenças';

  @override
  String get referenceEntryLicencesNote =>
      'Licenças de embarcação, de pescador e de petrecho, e o que cada uma abrange';

  @override
  String get referenceEntryGlossary => 'Glossário';

  @override
  String get referenceEntryGlossaryNote => 'TL · FL · SL · CW · SHL · ML e os termos locais';

  @override
  String get referenceEntryChangelog => 'Registro de alterações';

  @override
  String get referenceEntryChangelogNote => 'O que mudou em cada pacote e quando foi verificado';

  @override
  String get referenceEntryPlates => 'Pranchas de espécies';

  @override
  String get referenceEntryPlatesNote =>
      'Silhuetas agrupadas por família, para um peixe conhecido pela forma';

  @override
  String get referenceEntryNotPrinted => 'não impresso';

  @override
  String get referenceSectionNotPrinted =>
      'Esta seção não está impressa neste exemplar. Esta versão responde se um peixe cumpre as regras no local onde foi desembarcado, e cita o instrumento lido.';

  @override
  String get referenceHeldLabel => 'Guardado neste aparelho';

  @override
  String referenceHeldPack(String version, String checkedOn) {
    return 'pacote $version · verificado $checkedOn';
  }

  @override
  String get referenceHeldNote => 'Este livro cita os instrumentos que guarda. Não os resume.';

  @override
  String get referenceHeldEmpty => 'Este exemplar não guarda nenhuma jurisdição.';

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
  String get firstRunOfflineBadge => 'Sem sinal · sem rede, por definição';

  @override
  String get firstRunTagline => 'Isto é legal?';

  @override
  String get firstRunMetaFirstRun => 'Primeira execução';

  @override
  String get firstRunMetaOnceOnly => 'Uma única vez';

  @override
  String get firstRunHeadline => 'Compondo o livro de regras';

  @override
  String get firstRunLede =>
      'O pacote de regras incluído, as estampas e o texto legal estão sendo desempacotados, para que daqui em diante tudo abra na hora.';

  @override
  String get firstRunSilhouetteLabel => 'Silhueta gravada de uma garoupa';

  @override
  String firstRunProgressBytes(String written, String total) {
    return '$written de $total kB';
  }

  @override
  String firstRunProgressPercent(String percent) {
    return '$percent%';
  }

  @override
  String get firstRunSectionInstalling => 'Em instalação';

  @override
  String get firstRunStageRulePack => 'Pacote de regras';

  @override
  String get firstRunStageLegalText => 'Texto legal';

  @override
  String get firstRunStagePlates => 'Estampas de espécies';

  @override
  String get firstRunStageGlossary => 'Glossário e chave';

  @override
  String get firstRunStageDone => '· pronto';

  @override
  String get firstRunStageInProgress => 'Em andamento…';

  @override
  String get firstRunStagePending => 'Ainda não desempacotado';

  @override
  String firstRunTimeRemaining(String seconds) {
    return 'Faltam cerca de $seconds s';
  }

  @override
  String get firstRunNoDownload =>
      'Isto acontece uma única vez. Nada está sendo baixado: tudo já estava dentro do aplicativo na instalação, e não há nenhuma requisição de rede que possa falhar.';

  @override
  String get firstRunFooterNote =>
      'Sem conta. Sem início de sessão. Sem sincronização. Quando isto terminar, o CatchLaw nunca mais espera por nada.';

  @override
  String measureManualReading(String mm) {
    return '$mm milímetros';
  }
}
