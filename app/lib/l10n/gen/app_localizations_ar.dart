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
  String identifyKeyStamp(int couplet) {
    return 'المفتاح · الخطوة $couplet';
  }

  @override
  String get identifyAnswersSoFar => 'الإجابات حتى الآن';

  @override
  String identifyCoupletLabel(int couplet) {
    return 'الخطوة $couplet';
  }

  @override
  String identifySpeciesRemain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يبقى $count نوع',
      many: 'يبقى $count نوعًا',
      few: 'تبقى $count أنواع',
      two: 'يبقى نوعان',
      one: 'يبقى نوع واحد',
      zero: 'يبقى $count نوع',
    );
    return '$_temp0';
  }

  @override
  String identifyLeadMark(int couplet, int lead) {
    return '$couplet · $lead';
  }

  @override
  String identifyLeadConsequence(int count, String names) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يؤدي إلى $count نوع · $names',
      many: 'يؤدي إلى $count نوعًا · $names',
      few: 'يؤدي إلى $count أنواع · $names',
      two: 'يؤدي إلى نوعين · $names',
      one: 'يؤدي إلى نوع واحد · $names',
      zero: 'يؤدي إلى $count نوع · $names',
    );
    return '$_temp0';
  }

  @override
  String get identifyLeadNoSpecies => 'لا توجد أنواع مُدوَّنة بعد هذه الإجابة.';

  @override
  String get identifyBackOneStep => 'الرجوع خطوة واحدة';

  @override
  String get identifyDamagedHeading => 'إذا تعذَّرت رؤية الصفة';

  @override
  String get identifyDamagedNote =>
      'الصفة التالفة أو الغائبة لا يمكن الإجابة عنها. تُدرج بدلًا من ذلك كل الأنواع التي ما زالت هذه الخطوة تسمح بها، مرسومةً ومسمّاة.';

  @override
  String get identifyListWhatRemains => 'إدراج ما تبقّى';

  @override
  String get identifyProvenanceNote =>
      'لا تُلتقط أي صورة ولا يغادر الجهازَ أي شيء. المفتاح هو المفتاح المطبوع من قسم المراجع، يُسار فيه خطوةً خطوة.';

  @override
  String get identifyRemainingHeading => 'الأنواع التي ما زال المفتاح يسمح بها';

  @override
  String get identifyNoKeyHeadline => 'لا يوجد مفتاح في هذه الحزمة';

  @override
  String get identifyNoKeyBody =>
      'لم يُدوَّن أي مفتاح تعريف لهذه الولاية. الأنواع التي تحملها هذه الحزمة تُبلغ بالاسم.';

  @override
  String get identifyNoCandidatesHeadline => 'لا توجد أنواع مُدوَّنة هنا';

  @override
  String get identifyNoCandidatesBody =>
      'لا يبلغ المفتاح أي نوع بالإجابات المعطاة. لم يُدوَّن شيء بعد هذه النقطة في هذه الحزمة.';

  @override
  String get identifyKeyUnreadableHeadline => 'تعذَّرت قراءة المفتاح';

  @override
  String get identifyKeyUnreadableBody =>
      'لم يُفتح مفتاح الحزمة المرفقة على هذا الجهاز. الأنواع التي تحملها تُبلغ بالاسم.';

  @override
  String get identifySearchByName => 'البحث بالاسم';

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
  String speciesSearchMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة مطابقة',
      many: '$count نتيجة مطابقة',
      few: '$count نتائج مطابقة',
      two: 'نتيجتان مطابقتان',
      one: 'نتيجة واحدة مطابقة',
      zero: '$count نتيجة مطابقة',
    );
    return '$_temp0';
  }

  @override
  String get speciesSearchClear => 'مسح البحث';

  @override
  String get browseByShapeTitle => 'التصفح حسب الشكل';

  @override
  String get browseNoSpeciesHeadline => 'لا توجد أنواع في هذه الحزمة';

  @override
  String get browseNoSpeciesBody => 'لم تُدوَّن أنواع لهذه الولاية بعد.';

  @override
  String browseSpeciesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نوع',
      many: '$count نوعًا',
      few: '$count أنواع',
      two: 'نوعان',
      one: 'نوع واحد',
      zero: '$count نوع',
    );
    return '$_temp0';
  }

  @override
  String browseFamilyHeading(String family, int count) {
    return '$family · $count';
  }

  @override
  String browseMoreCount(int count) {
    return '+$count';
  }

  @override
  String browseMoreInFamily(String family) {
    return 'المزيد في $family';
  }

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
  String get verdictStampMeetsMinimum => 'يستوفي الحد الأدنى';

  @override
  String get verdictStampBelowMinimum => 'أقل من الحد الأدنى';

  @override
  String get verdictStampWithinMaximum => 'ضمن الحد الأقصى';

  @override
  String get verdictStampAboveMaximum => 'أعلى من الحد الأقصى';

  @override
  String get verdictStampNotMeasured => 'غير مُقاس';

  @override
  String get verdictStampMethodMismatch => 'مُقاس بطريقة أخرى';

  @override
  String verdictStampClosedSeason(String starts, String ends) {
    return 'موسم إغلاق — من $starts إلى $ends';
  }

  @override
  String verdictDetailMinimum(String measured, String unit, String threshold, String method) {
    return '$measured $unit مُقاسة · الحد الأدنى $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximum(String measured, String unit, String threshold, String method) {
    return '$measured $unit مُقاسة · الحد الأقصى $threshold $unit · $method';
  }

  @override
  String verdictDetailMinimumUnmeasured(String threshold, String unit, String method) {
    return 'لا يوجد قياس · الحد الأدنى $threshold $unit · $method';
  }

  @override
  String verdictDetailMaximumUnmeasured(String threshold, String unit, String method) {
    return 'لا يوجد قياس · الحد الأقصى $threshold $unit · $method';
  }

  @override
  String verdictDetailClosedSeasonInForce(String day, String total) {
    return 'ساري اليوم، اليوم $day من $total · ينطبق على جميع الأحجام';
  }

  @override
  String get verdictDetailClosedSeasonNotInForce => 'غير ساري اليوم';

  @override
  String speciesBinomialFamily(String binomial, String family) {
    return '$binomial — $family';
  }

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
  String get ambiguityEyebrow => 'تعارض بين النصّين';

  @override
  String get ambiguityBothInForce =>
      'كلا النصّين ساريان في هذا الموقع. يطبع CatchLaw نصّ كلٍّ منهما بتاريخ التحقّق الخاص به، ولا يقدّم أحدهما على الآخر.';

  @override
  String get findingFactMeasured => 'المقاس';

  @override
  String get findingFactMinimum => 'الحد الأدنى';

  @override
  String get findingFactMaximum => 'الحد الأقصى';

  @override
  String get findingFactShortfall => 'الفارق عن الحد';

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
  String get penaltiesTitle => 'العقوبات';

  @override
  String get penaltiesEntryNote => 'ما يترتب على مخالفة القواعد المسجَّلة.';

  @override
  String penaltiesLede(String jurisdiction) {
    return 'ما يترتب على مخالفة قواعد الحجم أو الموسم أو الحماية أو أدوات الصيد في $jurisdiction.';
  }

  @override
  String get penaltiesColumnOffence => 'المخالفة';

  @override
  String get penaltiesColumnFine => 'الغرامة';

  @override
  String get penaltiesColumnLicence => 'الرخصة';

  @override
  String get penaltiesOccurrenceFirst => 'المخالفة الأولى';

  @override
  String get penaltiesOccurrenceSecond => 'المخالفة الثانية';

  @override
  String get penaltiesOccurrenceSubsequent => 'المخالفة اللاحقة';

  @override
  String get penaltiesOffenceListLabel => 'المخالفات المسجَّلة';

  @override
  String penaltiesFineAmount(String currency, String amount) {
    return '$currency $amount';
  }

  @override
  String penaltiesFineRange(String currency, String lower, String upper) {
    return '$currency $lower–$upper';
  }

  @override
  String get penaltiesFineNotRecorded => 'لا مبلغ مسجَّل';

  @override
  String get penaltiesConsequenceNotRecorded => 'لا أثر مسجَّل على الرخصة';

  @override
  String get penaltiesWorkedExampleLabel => 'مثال محسوب';

  @override
  String penaltiesWorkedExampleFirst(String offence, String jurisdiction, String fine) {
    return 'المخالفة الأولى من $offence مسجَّلة في $jurisdiction بمبلغ $fine.';
  }

  @override
  String penaltiesWorkedExampleSecond(String offence, String jurisdiction, String fine) {
    return 'المخالفة الثانية من $offence مسجَّلة في $jurisdiction بمبلغ $fine.';
  }

  @override
  String penaltiesWorkedExampleSubsequent(String offence, String jurisdiction, String fine) {
    return 'المخالفة اللاحقة من $offence مسجَّلة في $jurisdiction بمبلغ $fine.';
  }

  @override
  String penaltiesWorkedExampleConsequence(String consequence) {
    return 'الأثر المسجَّل على الرخصة هو $consequence.';
  }

  @override
  String get penaltiesNoneRecordedHeadline => 'لا عقوبة مسجَّلة';

  @override
  String penaltiesNoneRecordedBody(String jurisdiction) {
    return 'حزمة القواعد المرفقة لا تحمل أي عقوبة منسوخة عن $jurisdiction. هذا غياب في النسخ، وليس تقريرًا بأن النصوص لا تحمل عقوبة.';
  }

  @override
  String get penaltiesPackCaveat =>
      'المبالغ هي المسجَّلة في حزمة القواعد المرفقة. وقد تطبّق المحاكم وجهات التفتيش أحكامًا أخرى.';

  @override
  String penaltiesCitationDates(String published, String checked) {
    return 'نُشر $published · روجع $checked';
  }

  @override
  String get disclaimerNotDismissable => 'لا يمكن إخفاء هذا التنبيه.';

  @override
  String get zonePickerTitle => 'أين تصطاد؟';

  @override
  String get zoneLevelCountry => 'الدولة';

  @override
  String get zoneLevelRegion => 'المنطقة';

  @override
  String get tripsKeptHere => 'محفوظة على هذا الجهاز وحده';

  @override
  String tripsCountStamp(int count) {
    return '$count رحلة';
  }

  @override
  String tripsRowSpan(String zone, String started, String ended) {
    return '$zone · $started — $ended';
  }

  @override
  String tripsRowSpanOpen(String zone, String started) {
    return '$zone · $started — الآن';
  }

  @override
  String get tripsOpenMark => '· جارية';

  @override
  String get tripsOpenStamp => 'جارية';

  @override
  String tripsDuration(int hours, int minutes) {
    return '$hours س $minutes د';
  }

  @override
  String get tripsLoadFailed => 'تعذّرت قراءة الرحلات المحفوظة على هذا الجهاز.';

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
  String get settingsGroupLanguage => 'اللغة والأرقام';

  @override
  String get settingsGroupPlace => 'مكان الصيد';

  @override
  String get settingsGroupReading => 'ظروف القراءة';

  @override
  String get settingsDigitsNote => 'أرقام غربية أو عربية-هندية';

  @override
  String get settingsLengthUnitNote => 'الأطوال في القواعد والقياسات';

  @override
  String get settingsZone => 'المنطقة';

  @override
  String get settingsZoneNote => 'القواعد وقائمة الأنواع والحدود تتبع هذا';

  @override
  String get settingsZoneUnset => 'لم يُختَر مكان';

  @override
  String settingsRulerScale(String px) {
    return '$px بكسل / 10 مليمترات';
  }

  @override
  String get settingsCoordinates => 'التقاط الإحداثيات';

  @override
  String get settingsCoordinatesNote => 'تُحفظ على هذا الهاتف وحده، ولا تُرسل أبدًا';

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
  String get todayHeadline => 'اليوم';

  @override
  String get todayNothingRecorded => 'لا شيء مسجَّل اليوم';

  @override
  String get todayNothingBody => 'يظهر هنا النوع الذي تسجّله من صفحته، مع العدد لهذا المكان.';

  @override
  String get todayNoPlace => 'لا مكان محدَّد';

  @override
  String todayCountKept(int count, int kept) {
    return '$count مسجَّل · $kept محتفَظ به';
  }

  @override
  String todayTripOpenSince(String started) {
    return 'رحلة مفتوحة منذ $started';
  }

  @override
  String get todayNoTripOpen => 'لا توجد رحلة مفتوحة';

  @override
  String get todaySummaryRecorded => 'أسماك مسجَّلة';

  @override
  String get todaySummaryKept => 'محتفَظ به';

  @override
  String get todaySummarySpecies => 'الأنواع';

  @override
  String todayKeptOfCount(String kept, String count) {
    return '$kept من $count';
  }

  @override
  String get todayBySpeciesLabel => 'حسب النوع';

  @override
  String get todayLoadFailed => 'تعذّرت قراءة حصيلة اليوم المحفوظة على هذا الجهاز.';

  @override
  String get tripsHeadline => 'الرحلات';

  @override
  String get tripsNone => 'لا رحلات بعد';

  @override
  String get tripsNoneBody => 'بدء رحلة يجمع ما تسجّله في خرجة واحدة. كل شيء يبقى على هذا الهاتف.';

  @override
  String get tripsStart => 'ابدأ رحلة';

  @override
  String get tripsEnd => 'أنهِ هذه الرحلة';

  @override
  String tripsRunning(String since) {
    return 'جارية منذ $since';
  }

  @override
  String tripsEnded(String started, String ended) {
    return '$started — $ended';
  }

  @override
  String get catchRecord => 'سجّل هذا الصيد';

  @override
  String get catchRecorded => 'تم التسجيل';

  @override
  String get measureTitle => 'قياس';

  @override
  String get measureUncalibrated => 'هذه الشاشة غير معايَرة';

  @override
  String get measureUncalibratedBody =>
      'يبلّغ الهاتف بالبكسل لا بالمليمتر، والنسبة تختلف بين الطُرز. قبل المعايرة لا تستطيع الشاشة رسم مسطرة بالحجم الحقيقي. إدخال الطول يدويًا يعمل في الحالتين.';

  @override
  String get measureManualLabel => 'أو اكتب الطول';

  @override
  String get measureUse => 'استخدم هذا الطول';

  @override
  String get calibrateAction => 'عايِر الشاشة';

  @override
  String get calibrateTitle => 'المعايرة';

  @override
  String get calibrateFitBody =>
      'ضع بطاقة مصرفية على الشاشة، حافتها اليسرى عند الحافة اليسرى للمربع، ثم اسحب الخط الأسود إلى حافتها اليمنى.';

  @override
  String get calibrateVerifyBody =>
      'تحقّق من الخط مقابل البطاقة مرة أخرى. إن كان على الحافة، فاحفظ.';

  @override
  String get calibrateVerifyAction => 'تحقّق';

  @override
  String get calibrateSaveAction => 'احفظ المعايرة';

  @override
  String calibrateCardWidth(String mm) {
    return 'عرض البطاقة المصرفية $mm مليمتر (ISO/IEC 7810 ID-1).';
  }

  @override
  String get calibrateImplausible => 'هذا المقياس خارج النطاق المعقول لشاشة هاتف، لذلك لم يُحفظ.';

  @override
  String get todayRemove => 'إزالة';

  @override
  String get todayMarkKept => 'محتفَظ به';

  @override
  String get todayUndoOne => 'أزل واحدًا';

  @override
  String get measureSup => 'المسطرة';

  @override
  String measureCalibrationProvenance(String on, String pxPer10mm) {
    return 'معايَرة في $on · $pxPer10mm بكسل لكل سنتيمتر';
  }

  @override
  String get measureStepAndMark => 'خطوة وعلامة';

  @override
  String get measureRunningTotalUnit => 'سم حتى الآن';

  @override
  String measureStepPill(String count) {
    return 'الخطوة $count';
  }

  @override
  String get measureStepNote =>
      'توضع حافة الشاشة عند مقدمة السمكة، ثم تُعلَّم، ثم يُزلَق الهاتف بمحاذاة السمكة وتُعلَّم مرة أخرى.';

  @override
  String get measureTypeInstead => 'كتابة الطول بدلاً من ذلك';

  @override
  String get measureRecalibrate => 'إعادة المعايرة ببطاقة';

  @override
  String get measurePrivacyNote =>
      'السمكة على اللوح، والهاتف على السمكة. لا تُلتقط أي صورة ولا تُقرأ أي إحداثية ما لم يكن التقاط الإحداثيات مفعّلاً في الإعدادات.';

  @override
  String get measureManualTitle => 'كتابة الطول';

  @override
  String get calibrateSup => 'مرة واحدة لكل جهاز';

  @override
  String calibrateCardConstant(String width, String height) {
    return 'كل بطاقة بهذا المقاس متطابقة: ISO/IEC 7810 ID-1 — $width × $height مليمتر';
  }

  @override
  String calibrateDimension(String mm) {
    return '$mm مليمتر';
  }

  @override
  String get calibrateDragHandleNote => 'يُسحب المقبض المصمت.';

  @override
  String get calibrateScaleLabel => 'المقياس الناتج';

  @override
  String get calibrateRowScale => 'بكسل لكل سنتيمتر';

  @override
  String get calibrateRowDensity => 'كثافة الشاشة';

  @override
  String get calibrateRowError => 'الخطأ المتوقع';

  @override
  String get calibrateRowLastCalibrated => 'آخر معايرة';

  @override
  String calibrateDensityValue(String dp, String ratio) {
    return '$dp dp · $ratio×';
  }

  @override
  String calibrateErrorValue(String mm) {
    return '± $mm مليمتر على 30 سنتيمترًا';
  }

  @override
  String get calibrateNotYet => 'لم تُعايَر بعد';

  @override
  String get calibrateReset => 'استعادة القيمة الافتراضية للشاشة';

  @override
  String get calibrateGlassNote =>
      'الغلاف أو واقي الشاشة لا يغيّر شيئاً — البطاقة تستقر على الزجاج، والزجاج هو ما يُقاس.';

  @override
  String get measureBackspace => 'حذف';

  @override
  String get navBack => 'رجوع';

  @override
  String get navToday => 'اليوم';

  @override
  String get navTrips => 'الرحلات';

  @override
  String get navReference => 'المرجع';

  @override
  String get referenceContentsLabel => 'المحتويات';

  @override
  String get referenceHubLede =>
      'كل ما يُستند إليه الحكم، محفوظ بالكامل على هذا الجهاز ويُقرأ دون شبكة.';

  @override
  String get referenceEntryRuleText => 'نص القرار';

  @override
  String get referenceEntryRuleTextNote => 'النصوص كما نُشرت، مادة بمادة، بلغة النشر';

  @override
  String get ruleTextSearchHint => 'البحث في النص الكامل';

  @override
  String get ruleTextAllArticles => 'كل المواد';

  @override
  String get ruleTextPublishedLabel => 'نُشر في';

  @override
  String get ruleTextCheckedLabel => 'روجع في';

  @override
  String get ruleTextCompleteNote => 'هذا النص محفوظ بالكامل على هذا الجهاز وغير مختصر.';

  @override
  String get ruleTextNoneRecordedHeadline => 'لا يوجد نص منسوخ';

  @override
  String ruleTextNoneRecordedBody(String instrument) {
    return 'لا تحمل هذه النسخة نص مواد $instrument. والاستشهاد أعلاه يذكر الصك وتاريخ نشره وتاريخ آخر مراجعة له.';
  }

  @override
  String get ruleTextNoMatchHeadline => 'لا تطابق أي مادة';

  @override
  String get ruleTextNoMatchBody => 'لا تحمل أي مادة من هذا الصك تلك الصيغة.';

  @override
  String get referenceEntryProtected => 'الأنواع المحمية';

  @override
  String get referenceEntryProtectedNote => 'اللوحات والعلامات المميِّزة ونطاق الحماية';

  @override
  String get referenceEntryGear => 'المعدات وطرق الصيد';

  @override
  String get referenceEntryGearNote => 'فتحة الشبكة، الخيط اليدوي، طول الشبكة، الطرق المحظورة';

  @override
  String get referenceEntryPenalties => 'العقوبات';

  @override
  String get referenceEntryPenaltiesNote => 'الغرامات وأثرها في الرخصة، حسب المخالفة';

  @override
  String get referenceEntryLicences => 'الرخص';

  @override
  String get referenceEntryLicencesNote => 'رخص السفينة والصياد والمعدات، ونطاق كل منها';

  @override
  String get referenceEntryGlossary => 'المسرد';

  @override
  String get referenceEntryGlossaryNote => 'TL · FL · SL · CW · SHL · ML والمصطلحات المحلية';

  @override
  String get referenceEntryChangelog => 'سجل التغييرات';

  @override
  String get referenceEntryChangelogNote => 'ما الذي تغيّر في كل حزمة، ومتى جرى التحقق منها';

  @override
  String get referenceEntryPlates => 'لوحات الأنواع';

  @override
  String get referenceEntryPlatesNote => 'ظلال مجمّعة حسب الفصيلة، لسمكة تُعرف بشكلها';

  @override
  String get referenceEntryNotPrinted => 'غير مطبوع';

  @override
  String get referenceSectionNotPrinted =>
      'هذا القسم غير مطبوع في هذه النسخة. تجيب هذه النسخة عمّا إذا كانت السمكة تستوفي القواعد في المكان الذي أُنزلت فيه، وتذكر النص الذي قرأته.';

  @override
  String get referenceHeldLabel => 'محفوظ على هذا الجهاز';

  @override
  String referenceHeldPack(String version, String checkedOn) {
    return 'حزمة $version · روجعت $checkedOn';
  }

  @override
  String get referenceHeldNote => 'يقتبس هذا الكتاب النصوص التي يحفظها، ولا يلخّصها.';

  @override
  String get referenceHeldEmpty => 'لا تحفظ هذه النسخة أي ولاية قضائية.';

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

  @override
  String get firstRunOfflineBadge => 'لا إشارة · بلا شبكة بحكم التصميم';

  @override
  String get firstRunTagline => 'هل هذا قانوني؟';

  @override
  String get firstRunMetaFirstRun => 'التشغيل الأول';

  @override
  String get firstRunMetaOnceOnly => 'مرة واحدة فقط';

  @override
  String get firstRunHeadline => 'ترتيب كتاب الأحكام';

  @override
  String get firstRunLede =>
      'يجري فك حزمة الأحكام المرفقة واللوحات والنص القانوني، ليفتح كل شيء فورًا من الآن فصاعدًا.';

  @override
  String get firstRunSilhouetteLabel => 'ظل محفور لسمكة هامور';

  @override
  String firstRunProgressBytes(String written, String total) {
    return '$written من $total ك.ب';
  }

  @override
  String firstRunProgressPercent(String percent) {
    return '$percent٪';
  }

  @override
  String get firstRunSectionInstalling => 'قيد التثبيت';

  @override
  String get firstRunStageRulePack => 'حزمة الأحكام';

  @override
  String get firstRunStageLegalText => 'النص القانوني';

  @override
  String get firstRunStagePlates => 'لوحات الأنواع';

  @override
  String get firstRunStageGlossary => 'المسرد والمفتاح';

  @override
  String get firstRunStageDone => '· تم';

  @override
  String get firstRunStageInProgress => 'قيد التنفيذ…';

  @override
  String get firstRunStagePending => 'لم تُفك بعد';

  @override
  String firstRunTimeRemaining(String seconds) {
    return 'يتبقى نحو $seconds ث';
  }

  @override
  String get firstRunNoDownload =>
      'يحدث هذا مرة واحدة. لا يجري تنزيل أي شيء — كان كل ذلك داخل التطبيق منذ تثبيته، ولا يوجد طلب شبكة يمكن أن يفشل.';

  @override
  String get firstRunFooterNote =>
      'بلا حساب. بلا تسجيل دخول. بلا مزامنة. حين ينتهي هذا، لا ينتظر CatchLaw شيئًا بعده أبدًا.';

  @override
  String measureManualReading(String mm) {
    return '$mm مليمتر';
  }
}
