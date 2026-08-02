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
}
