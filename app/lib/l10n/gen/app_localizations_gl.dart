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
}
