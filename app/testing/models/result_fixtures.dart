/// The six worked cases every reference file in this repository argues from.
///
/// Built by hand rather than by running the evaluator: a fixture that came out
/// of `evaluate` would make a presenter test pass whenever the two agreed, and
/// the sentence would still be wrong. The numbers here are the ones in
/// `verdict-copy-rules.md` and `states-and-signals.md`, so a change to either
/// document lands as a failing test rather than as a silent divergence.
library;

import 'package:catchlaw/domain/models/content_strings.dart';
import 'package:catchlaw/ui/result/view_models/result_context.dart';
import 'package:rule_engine/rule_engine.dart';

/// Ministerial Decision 580/2015, Art. 3 — the Gulf instrument.
const Citation kCitationMd580 = Citation(
  instrument: 'Ministerial Decision 580/2015',
  article: 'Art. 3',
  publishedOn: '2015-11-03',
  checkedOn: '2026-07-14',
);

/// The Galician order behind the Cambados shell length.
const Citation kCitationXunta = Citation(
  instrument: 'Orde do 27 de xullo de 2012',
  article: 'Art. 4',
  publishedOn: '2012-08-06',
  checkedOn: '2026-08-12',
);

/// A second Galician instrument, for the ambiguity case.
const Citation kCitationXuntaBank = Citation(
  instrument: 'Plan de explotación Cambados 2026',
  article: 'Anexo I',
  publishedOn: '2026-01-15',
  checkedOn: '2026-08-12',
);

/// Hamour, 380 mm total length, against a 450 mm total-length minimum.
const Resolution kResolutionHamourBelowMinimum = Decided(
  headline: MinimumSizeFinding(
    citation: kCitationMd580,
    isExpired: false,
    thresholdMm: 450,
    method: MeasurementMethod.totalLength,
    measuredMm: 380,
    measuredMethod: MeasurementMethod.totalLength,
  ),
  secondary: <Finding>[],
);

/// Kanaad, 700 mm fork length, against a 650 mm fork-length minimum.
///
/// 65 cm fork length is not 65 cm total length, which is the whole reason the
/// method is in the sentence.
const Resolution kResolutionKanaadMeetsMinimum = Decided(
  headline: MinimumSizeFinding(
    citation: kCitationMd580,
    isExpired: false,
    thresholdMm: 650,
    method: MeasurementMethod.forkLength,
    measuredMm: 700,
    measuredMethod: MeasurementMethod.forkLength,
  ),
  secondary: <Finding>[],
);

/// Ameixa babosa, 34 mm shell length, against a 38 mm shell-length minimum.
const Resolution kResolutionAmeixaBelowMinimum = Decided(
  headline: MinimumSizeFinding(
    citation: kCitationXunta,
    isExpired: false,
    thresholdMm: 38,
    method: MeasurementMethod.shellLength,
    measuredMm: 34,
    measuredMethod: MeasurementMethod.shellLength,
  ),
  secondary: <Finding>[],
);

/// The same finding, from an instrument that has passed its end date.
///
/// Identical in every other field, so a test can assert that expiry changes the
/// bar and changes nothing else (invariant 5).
const Resolution kResolutionAmeixaExpired = Decided(
  headline: MinimumSizeFinding(
    citation: kCitationXunta,
    isExpired: true,
    thresholdMm: 38,
    method: MeasurementMethod.shellLength,
    measuredMm: 34,
    measuredMethod: MeasurementMethod.shellLength,
  ),
  secondary: <Finding>[],
);

/// A grouper measured to a tenth of a centimetre, against a 450 mm minimum.
const Resolution kResolutionHamourMeasured386 = Decided(
  headline: MinimumSizeFinding(
    citation: kCitationMd580,
    isExpired: false,
    thresholdMm: 450,
    method: MeasurementMethod.totalLength,
    measuredMm: 386,
    measuredMethod: MeasurementMethod.totalLength,
  ),
  secondary: <Finding>[],
);

/// 1 220 mm total length against a 1 200 mm maximum — a slot rule.
const Resolution kResolutionAboveMaximum = Decided(
  headline: MaximumSizeFinding(
    citation: kCitationMd580,
    isExpired: false,
    thresholdMm: 1200,
    method: MeasurementMethod.totalLength,
    measuredMm: 1220,
    measuredMethod: MeasurementMethod.totalLength,
  ),
  secondary: <Finding>[],
);

/// A species picked but never measured.
const Resolution kResolutionHamourUnmeasured = Decided(
  headline: MinimumSizeFinding(
    citation: kCitationMd580,
    isExpired: false,
    thresholdMm: 450,
    method: MeasurementMethod.totalLength,
    measuredMm: null,
    measuredMethod: null,
  ),
  secondary: <Finding>[],
);

/// A reading taken by total length against a fork-length instrument.
const Resolution kResolutionMethodMismatch = Decided(
  headline: MinimumSizeFinding(
    citation: kCitationMd580,
    isExpired: false,
    thresholdMm: 650,
    method: MeasurementMethod.forkLength,
    measuredMm: 700,
    measuredMethod: MeasurementMethod.totalLength,
  ),
  secondary: <Finding>[],
);

/// Sawfish — protected, and nothing else applies.
const Resolution kResolutionSawfishProtected = Decided(
  headline: ProtectedFinding(citation: kCitationMd580, isExpired: false),
  secondary: <Finding>[],
);

/// A protected species that is also short, so precedence has something to do.
const Resolution kResolutionProtectedAndShort = Decided(
  headline: ProtectedFinding(citation: kCitationMd580, isExpired: false),
  secondary: <Finding>[
    MinimumSizeFinding(
      citation: kCitationMd580,
      isExpired: false,
      thresholdMm: 450,
      method: MeasurementMethod.totalLength,
      measuredMm: 380,
      measuredMethod: MeasurementMethod.totalLength,
    ),
  ],
);

/// A closure headlining, with a size rule and a bag limit beneath it.
const Resolution kResolutionShariClosedSeason = Decided(
  headline: ClosedSeasonFinding(
    citation: kCitationMd580,
    isExpired: false,
    recurrence: Recurrence.annual,
    inForce: true,
    startsOn: '2026-03-01',
    endsOn: '2026-04-30',
    dayOfClosure: 14,
    lengthInDays: 61,
  ),
  secondary: <Finding>[
    MinimumSizeFinding(
      citation: kCitationMd580,
      isExpired: false,
      thresholdMm: 450,
      method: MeasurementMethod.totalLength,
      measuredMm: 520,
      measuredMethod: MeasurementMethod.totalLength,
    ),
    BagLimitFinding(
      citation: kCitationMd580,
      isExpired: false,
      limit: 6,
      unit: LimitUnit.count,
      period: LimitPeriod.day,
      recorded: 9,
    ),
  ],
);

/// The species is transcribed here; no rule row covers it.
const Resolution kResolutionNoRuleFound = NoRuleFound(
  searched: <Citation>[kCitationMd580],
  checkedOn: '2026-07-14',
  isExpired: false,
);

/// The instrument was read and positively records no limit.
const Resolution kResolutionNoLimitInInstrument = NoLimitInInstrument(
  citation: kCitationMd580,
  isExpired: false,
);

/// A species id this jurisdiction does not carry at all.
const Resolution kResolutionUnknownSpecies = UnknownSpecies(
  speciesId: 9999,
  searched: <Citation>[kCitationXunta],
  checkedOn: '2026-08-12',
);

/// Two Galician instruments of equal standing, 38 mm and 40 mm, in source order.
const Resolution kResolutionAmbiguousBank = Ambiguous(
  isExpired: false,
  rules: <Rule>[
    Rule(
      id: 1,
      jurisdictionId: 1,
      zoneId: 2,
      speciesId: 7,
      waterType: WaterType.salt,
      citation: kCitationXunta,
      citationLineageId: 'es-ga-orde-2012-07-27',
      validFrom: '2012-08-06',
      minSizeMm: 38,
      measurementMethod: MeasurementMethod.shellLength,
    ),
    Rule(
      id: 2,
      jurisdictionId: 1,
      zoneId: 2,
      speciesId: 7,
      waterType: WaterType.salt,
      citation: kCitationXuntaBank,
      citationLineageId: 'es-ga-plan-cambados-2026',
      validFrom: '2026-01-15',
      minSizeMm: 40,
      measurementMethod: MeasurementMethod.shellLength,
    ),
  ],
);

/// Ras Al Khaimah, as the result screen sees it.
const ResultContext kContextRasAlKhaimah = ResultContext(
  authorityKey: 'jurisdiction.ae_rak.authority',
);

/// Banco de Cambados, as the result screen sees it.
const ResultContext kContextCambados = ResultContext(authorityKey: 'jurisdiction.es_ga.authority');

/// The tier-two words an English result screen needs.
///
/// Spelled exactly as `content/shared/strings.yaml` spells them, capital and
/// all: the presenter renders a `content_string` value verbatim, and a test
/// seeded with a tidied-up copy would prove the presenter tidies too.
const ContentStrings kContentEn = ContentStrings(<String, String>{
  'measurement.tl.name': 'Total length',
  'measurement.fl.name': 'Fork length',
  'measurement.shl.name': 'Shell length',
  'jurisdiction.ae_rak.authority': 'Ministry of Climate Change and Environment',
  'jurisdiction.es_ga.authority': 'Xunta de Galicia — Department of the Sea',
});

/// The same words, in Arabic.
const ContentStrings kContentAr = ContentStrings(<String, String>{
  'measurement.tl.name': 'الطول الكلي',
  'measurement.fl.name': 'طول الشوكة',
  'measurement.shl.name': 'طول الصدفة',
  'jurisdiction.ae_rak.authority': 'وزارة التغير المناخي والبيئة',
  'jurisdiction.es_ga.authority': 'حكومة غاليسيا — وزارة البحر',
});
