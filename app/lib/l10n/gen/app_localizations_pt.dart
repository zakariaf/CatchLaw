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
}
