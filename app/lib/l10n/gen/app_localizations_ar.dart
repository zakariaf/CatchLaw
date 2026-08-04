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

  @override
  String get speciesSearchLabel => 'الأنواع';

  @override
  String get speciesSearchHint => 'هامور، كنعد، Epinephelus';

  @override
  String get speciesGroupInYourZone => 'في منطقتك';

  @override
  String get speciesGroupElsewhere => 'في مكان آخر ضمن هذه الولاية';

  @override
  String get speciesHintProtected => 'محمي';

  @override
  String get speciesHintClosed => 'موسم مغلق';

  @override
  String get speciesNoMatchHeadline => 'لا يوجد نوع بهذا الاسم';

  @override
  String get speciesNoMatchBody =>
      'قد يُكتب الاسم بصورة مختلفة هنا، أو قد لا يكون النوع مُدوَّنًا بعد.';

  @override
  String get identifyThisFish => 'تحديد هذه السمكة';

  @override
  String get browseByShape => 'التصفح حسب الشكل';

  @override
  String get rulePackExpired => 'انقضى تاريخ انتهاء هذه القواعد المعلن. تُعرض كما نُشرت.';

  @override
  String speciesSearchResultCount(int count, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count من $total',
      many: '$count من $total',
      few: '$count من $total',
      two: '$count من $total',
      one: '$count من $total',
      zero: '$count من $total',
    );
    return '$_temp0';
  }

  @override
  String get browseByShapeTitle => 'التصفح حسب الشكل';

  @override
  String get browseNoSpeciesHeadline => 'لا توجد أنواع في هذه الحزمة';

  @override
  String get browseNoSpeciesBody => 'لم تُدوَّن أنواع لهذه الولاية بعد.';

  @override
  String get speciesOtherNames => 'أسماء أخرى';

  @override
  String get speciesScientificName => 'الاسم العلمي';

  @override
  String get speciesFamilyLabel => 'الفصيلة';

  @override
  String get speciesPlateSemanticLabel => 'لوحة محفورة';

  @override
  String get speciesSilhouetteSemanticLabel => 'رسم خطي';

  @override
  String get speciesProtectedAnywhere => 'محمي في مكان ما ضمن هذه الولاية';

  @override
  String get lookAlikeSectionLabel => 'يُخلط بسهولة مع';

  @override
  String get lookAlikeConfusedWith => 'ما يفرّق بينهما';

  @override
  String get recentsStripLabel => 'الأخيرة هنا';

  @override
  String get recentsEmptyBody => 'تظهر هنا الأنواع التي تفتحها في هذه المنطقة.';

  @override
  String get calibrationTitle => 'قياس شاشتك';

  @override
  String get calibrationCardExplainer =>
      'ضع أي بطاقة مصرفية أو رخصة أو هوية على الزجاج واسحب الحافة لتطابقها.';

  @override
  String get calibrationHandleLabel => 'حافة البطاقة';

  @override
  String calibrationVerifyExplainer(String measurement) {
    return 'طول هذا الشريط $measurement. قارنه بالضلع القصير للبطاقة نفسها.';
  }

  @override
  String calibrationVerifyBarLabel(String measurement) {
    return '$measurement';
  }

  @override
  String get calibrationSaveAction => 'حفظ هذا القياس';

  @override
  String get calibrationCancelAction => 'خطوة للخلف';

  @override
  String get calibrationTooSmallScreen => 'هذه الشاشة أضيق من بطاقة. الإدخال اليدوي متاح.';

  @override
  String calibrationImplausible(String measurement) {
    return 'قاس هذا السحب $measurement عبر الشاشة، وهذا ليس بطاقة.';
  }

  @override
  String get unitMillimetres => 'مم';

  @override
  String get unitCentimetres => 'سم';

  @override
  String rulerSemanticLabel(String measurement) {
    return 'مسطرة. القراءة $measurement.';
  }

  @override
  String get rulerZeroLabel => '٠';

  @override
  String measurementCm(String value, String method) {
    return '$value سم ($method)';
  }

  @override
  String measurementMm(String value, String method) {
    return '$value مم ($method)';
  }

  @override
  String measurementInch(String value, String method) {
    return '$value بوصة ($method)';
  }

  @override
  String massKg(String value) {
    return '$value كجم';
  }

  @override
  String get limitPeriodDay => 'يوم';

  @override
  String get limitPeriodTrip => 'رحلة';

  @override
  String get limitPeriodSeason => 'موسم';

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'يناير',
      '2': 'فبراير',
      '3': 'مارس',
      '4': 'أبريل',
      '5': 'مايو',
      '6': 'يونيو',
      '7': 'يوليو',
      '8': 'أغسطس',
      '9': 'سبتمبر',
      '10': 'أكتوبر',
      '11': 'نوفمبر',
      '12': 'ديسمبر',
      'other': '$month',
    });
    return '$_temp0';
  }

  @override
  String dateDayMonth(String day, String month) {
    return '$day $month';
  }

  @override
  String verdictMeetsMinimum(String measured, String unit, String threshold, String method) {
    return 'يستوفي الحد الأدنى — $measured $unit مُقاسة، الحد الأدنى $threshold $unit ($method)';
  }

  @override
  String verdictBelowMinimum(String measured, String unit, String threshold, String method) {
    return 'دون الحد الأدنى — $measured $unit مُقاسة، الحد الأدنى $threshold $unit ($method)';
  }

  @override
  String verdictWithinMaximum(String measured, String unit, String threshold, String method) {
    return 'ضمن الحد الأقصى — $measured $unit مُقاسة، الحد الأقصى $threshold $unit ($method)';
  }

  @override
  String verdictAboveMaximum(String measured, String unit, String threshold, String method) {
    return 'فوق الحد الأقصى — $measured $unit مُقاسة، الحد الأقصى $threshold $unit ($method)';
  }

  @override
  String verdictMinimumNotMeasured(String threshold, String unit, String method) {
    return 'لا يوجد قياس — الحد الأدنى $threshold $unit ($method)';
  }

  @override
  String verdictMaximumNotMeasured(String threshold, String unit, String method) {
    return 'لا يوجد قياس — الحد الأقصى $threshold $unit ($method)';
  }

  @override
  String verdictSizeMethodMismatch(
    String measuredMethod,
    String threshold,
    String unit,
    String method,
  ) {
    return 'القياس بطريقة $measuredMethod — والنص يذكر $threshold $unit ($method). لا تجرى أي مقارنة.';
  }

  @override
  String verdictMarginShortOfMinimum(String margin, String unit) {
    return 'أقل من الحد الأدنى بـ $margin $unit';
  }

  @override
  String verdictMarginOverMinimum(String margin, String unit) {
    return 'أعلى من الحد الأدنى بـ $margin $unit';
  }

  @override
  String verdictMarginOverMaximum(String margin, String unit) {
    return 'أعلى من الحد الأقصى بـ $margin $unit';
  }

  @override
  String verdictMarginUnderMaximum(String margin, String unit) {
    return 'أقل من الحد الأقصى بـ $margin $unit';
  }

  @override
  String verdictClosedSeasonInForce(String starts, String ends, String day, String total) {
    return 'موسم إغلاق — من $starts إلى $ends. ساري اليوم، اليوم $day من $total.';
  }

  @override
  String verdictClosedSeasonNotInForce(String starts, String ends) {
    return 'موسم إغلاق — من $starts إلى $ends. غير ساري اليوم.';
  }

  @override
  String get verdictProtected => 'نوع محمي — الصيد محظور.';

  @override
  String verdictWithinBagLimit(String recorded, String limit, String period) {
    return 'ضمن حد الحصة — $recorded مسجّلة، الحد $limit لكل $period';
  }

  @override
  String verdictAboveBagLimit(String recorded, String limit, String period) {
    return 'فوق حد الحصة — $recorded مسجّلة، الحد $limit لكل $period';
  }

  @override
  String verdictBagLimitNotRecorded(String limit, String period) {
    return 'لا يوجد شيء مسجّل لهذه المدة — حد الحصة $limit لكل $period';
  }

  @override
  String verdictWithinVesselLimit(String recorded, String limit) {
    return 'ضمن حد القارب — $recorded مسجّلة، الحد $limit';
  }

  @override
  String verdictAboveVesselLimit(String recorded, String limit) {
    return 'فوق حد القارب — $recorded مسجّلة، الحد $limit';
  }

  @override
  String verdictVesselLimitNotRecorded(String limit) {
    return 'لا يوجد شيء مسجّل لهذا القارب — الحد $limit';
  }

  @override
  String get verdictNoRuleRecorded =>
      'لا توجد قاعدة مسجّلة لهذا النوع هنا. هذا لا يعني أنه قانوني.';

  @override
  String get verdictNoLimitInInstrument => 'قُرئ النص ولا يسجّل أي حد لهذا النوع هنا.';

  @override
  String get verdictUnknownSpecies => 'هذا النوع غير مسجّل في هذه الولاية. هذا لا يعني أنه قانوني.';

  @override
  String get verdictAmbiguous => 'تنطبق هنا قاعدتان متساويتان في المرتبة.';

  @override
  String get findingFactMeasured => 'المقاس';

  @override
  String get findingFactMinimum => 'الحد الأدنى';

  @override
  String get findingFactMaximum => 'الحد الأقصى';

  @override
  String get findingFactDates => 'التواريخ';

  @override
  String get findingFactToday => 'اليوم';

  @override
  String get findingFactRecorded => 'المسجّل';

  @override
  String get findingFactLimit => 'الحد';

  @override
  String get findingFactPeriod => 'الفترة';

  @override
  String findingDayOfWindow(String day, String total) {
    return 'اليوم $day من $total';
  }

  @override
  String findingWindowRange(String starts, String ends) {
    return 'من $starts إلى $ends';
  }

  @override
  String disclaimerVerdict(String authority) {
    return 'يقتبس CatchLaw نصوصًا منشورة. ليست استشارة قانونية ولا تصرّح بأي صيد. يجب التحقق من $authority قبل الاعتماد عليها.';
  }

  @override
  String get citationCopyAction => 'نسخ الاستشهاد';

  @override
  String rulePackExpiredOn(String date) {
    return 'انتهت صلاحية هذه القواعد في $date. وهي معروضة كما نُشرت.';
  }

  @override
  String rulePackProvenance(String pack, String date) {
    return 'حزمة القواعد المضمّنة $pack انتهت صلاحيتها في $date. النص أعلاه هو آخر صيغة تم التحقق منها.';
  }

  @override
  String get staleDetailClose => 'إغلاق هذه الملاحظة';

  @override
  String get flagRuleAction => 'الإبلاغ عن هذه القاعدة';

  @override
  String get flagRuleNoteLabel => 'ما ينص عليه النص';

  @override
  String get flagRuleSaveAction => 'حفظ هذه الملاحظة على هذا الجهاز';

  @override
  String get flagRuleRecorded => 'حُفظت على هذا الجهاز.';

  @override
  String get flagRuleEmptyNote => 'الملاحظة فارغة.';

  @override
  String get disclaimerNotDismissable => 'لا يمكن إخفاء هذا التنبيه.';

  @override
  String get zonePickerTitle => 'أين تصطاد؟';

  @override
  String get zoneLevelCountry => 'الدولة';

  @override
  String get zoneLevelRegion => 'المنطقة';

  @override
  String get zoneLevelSubZone => 'المنطقة الفرعية';

  @override
  String get zoneWaterSalt => 'البحر';

  @override
  String get zoneWaterFresh => 'المياه الداخلية';

  @override
  String get zonePickerConfirm => 'استخدام هذا المكان';

  @override
  String get zonePickerEmptyHeadline => 'لا توجد قواعد مضمّنة لهذه الدولة';

  @override
  String get zonePickerEmptyBody => 'لا يحمل هذا الإصدار أي نص منقول عنها. هذا لا يعني عدم وجودها.';

  @override
  String get zonePickerLoadFailed => 'تعذّرت قراءة حزمة القواعد المضمّنة.';

  @override
  String countryName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ES': 'إسبانيا',
      'AE': 'الإمارات العربية المتحدة',
      'BR': 'البرازيل',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String zoneNoPublishedBoundaries(String authority) {
    return 'لا تنشر $authority حدودًا إحداثية. القواعد المسجّلة هنا تسري على الولاية بأكملها.';
  }

  @override
  String get zoneWaterChoiceRequired =>
      'يجب اختيار البحر أو المياه الداخلية قبل أن يجيب هذا المكان.';

  @override
  String get navCheck => 'فحص';

  @override
  String get destinationNotBuiltYet =>
      'هذا الإصدار يجيب عن سؤال واحد: هل تستوفي السمكة القواعد في المكان الذي جرى إنزالها فيه. هذا الجزء لم يُبنَ بعد.';

  @override
  String get settingsLanguageDevice => 'اتّباع الجهاز';

  @override
  String get settingsDigits => 'الأرقام';

  @override
  String get settingsDigitsAuto => 'تلقائي';

  @override
  String get settingsDigitsLatn => '0123';

  @override
  String get settingsDigitsArab => '٠١٢٣';

  @override
  String get settingsUnitCm => 'سم';

  @override
  String get settingsUnitMm => 'مم';

  @override
  String get settingsUnitIn => 'بوصة';

  @override
  String get settingsLengthUnit => 'وحدة الطول';

  @override
  String get settingsSunlightMode => 'وضع الشمس';

  @override
  String get settingsSunlightNote => 'أقصى تباين، لشاشة مبللة تحت وهج الشمس.';

  @override
  String get settingsGloveMode => 'وضع القفازات';

  @override
  String get settingsGloveNote => 'أهداف أكبر وتباعد أوسع.';

  @override
  String get settingsRuler => 'المسطرة';

  @override
  String get settingsRulerUncalibrated => 'غير معايَرة';

  @override
  String settingsRulerCalibrated(String on) {
    return 'معايَرة في $on';
  }

  @override
  String get settingsAboutPack => 'كتاب القواعد';

  @override
  String get settingsOfflineNote =>
      'يحتفظ CatchLaw بكل ما يحتاجه على هذا الهاتف. لا حساب فيه ولا شيفرة شبكة.';

  @override
  String get navToday => 'اليوم';

  @override
  String get navTrips => 'الرحلات';

  @override
  String get navReference => 'المرجع';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get checkPlaceLabel => 'الإجابة عن';

  @override
  String get checkChangePlace => 'تغيير المكان';

  @override
  String get checkRecentsLabel => 'الأحدث هنا';

  @override
  String checkPackChecked(String date) {
    return 'تم التحقق $date';
  }

  @override
  String get checkNoRecentsHeadline => 'لم يُفحص شيء هنا بعد';

  @override
  String get checkNoRecentsBody =>
      'الأنواع التي تبحث عنها في هذا المكان تظهر هنا، فيصبح التالي بلمسة واحدة.';
}
