// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CatchLaw';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '$count match',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystemDefault => 'Device language';

  @override
  String get settingsNumeralSystem => 'Digits';

  @override
  String get settingsNumeralSystemAuto => 'Device language default';

  @override
  String get settingsNumeralSystemLatn => 'Western — 0 1 2 3';

  @override
  String get settingsNumeralSystemArab => 'Arabic-Indic — ٠ ١ ٢ ٣';

  @override
  String legalTextLanguageNotice(String language) {
    return 'The verbatim text of this instrument exists only in $language.';
  }

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ar': 'Arabic',
      'en': 'English',
      'es': 'Spanish',
      'gl': 'Galician',
      'ca': 'Catalan',
      'ptBR': 'Brazilian Portuguese',
      'other': 'English',
    });
    return '$_temp0';
  }
}
