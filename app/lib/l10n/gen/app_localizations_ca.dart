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
}
