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
  String get browseByShapeTitle => 'Explorar por forma';

  @override
  String get browseNoSpeciesHeadline => 'Ningunha especie neste paquete';

  @override
  String get browseNoSpeciesBody => 'Esta xurisdición aínda non ten especies transcritas.';

  @override
  String get speciesOtherNames => 'Outros nomes';

  @override
  String get speciesScientificName => 'Nome científico';

  @override
  String get speciesFamilyLabel => 'Familia';

  @override
  String get speciesPlateSemanticLabel => 'Lámina gravada';

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
}
