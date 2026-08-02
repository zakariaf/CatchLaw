// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'CatchLaw';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا نتائج',
    );
    return '$_temp0';
  }

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSystemDefault => 'لغة الجهاز';

  @override
  String get settingsNumeralSystem => 'الأرقام';

  @override
  String get settingsNumeralSystemAuto => 'الإعداد الافتراضي للغة';

  @override
  String get settingsNumeralSystemLatn => 'غربية — 0 1 2 3';

  @override
  String get settingsNumeralSystemArab => 'عربية هندية — ٠ ١ ٢ ٣';

  @override
  String legalTextLanguageNotice(String language) {
    return 'النص الحرفي لهذا الصك موجود بـ$language فقط.';
  }

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ar': 'العربية',
      'en': 'الإنجليزية',
      'es': 'الإسبانية',
      'gl': 'الغاليسية',
      'ca': 'الكتالونية',
      'ptBR': 'البرتغالية البرازيلية',
      'other': 'الإنجليزية',
    });
    return '$_temp0';
  }
}
