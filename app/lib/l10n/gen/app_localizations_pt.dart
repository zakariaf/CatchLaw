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
}
