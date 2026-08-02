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
  String get browseByShapeTitle => 'Explorar por forma';

  @override
  String get browseNoSpeciesHeadline => 'Ninguna especie en este paquete';

  @override
  String get browseNoSpeciesBody => 'Esta jurisdicción todavía no tiene especies transcritas.';

  @override
  String get speciesOtherNames => 'Otros nombres';

  @override
  String get speciesScientificName => 'Nombre científico';

  @override
  String get speciesFamilyLabel => 'Familia';

  @override
  String get speciesPlateSemanticLabel => 'Lámina grabada';

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
}
