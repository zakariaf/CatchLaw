/// The values every migration test writes.
///
/// **Hostile on purpose.** `'test1'` survives everything and proves nothing.
/// These are the values a `columnTransformer` or a hand-rolled
/// `INSERT … SELECT` mangles silently: an apostrophe that ends a quoted literal
/// early, Arabic that a byte-oriented copy truncates mid-codepoint, an em dash
/// that a Latin-1 round trip flattens, a backslash that a naive escape doubles,
/// and a whitespace-only note that a `TRIM`-then-`NULLIF` quietly discards.
library;

import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/domain/models/catch_record.dart';

/// A trip label carrying an apostrophe and an em dash.
const String kHostileTripLabel = "O'Sullivan's mark — the far bank";

/// Notes that are only whitespace. Not null, and not empty.
const String kHostileTripNotes = '   ';

/// An Arabic species name with a backslash in the outcome detail.
const String kHostileScientificName = 'Epinephelus coioides';

/// The vernacular a Gulf fisher would recognise.
const String kHostileVernacular = 'هامور';

/// A finding sentence carrying a backslash and an em dash.
const String kHostileOutcomeDetail = r'Below the minimum — 380 mm \ minimum 450 mm (total length)';

/// A citation reference with an apostrophe.
const String kHostileCitationRef = "Orde do 27 de xullo de 2012, Anexo II — 'ameixa babosa'";

/// A catch ready to be recorded, carrying every hostile value above.
///
/// One draft, reused across the repository and mapper suites: a fixture per
/// test drifts, and two fixtures that differ in the field under test are how a
/// round-trip suite passes while the round trip is broken.
const CatchDraft kCatchDraftAmeixa = CatchDraft(
  jurisdictionCode: 'ES-GA',
  zoneCode: 'RIA-AROUSA',
  speciesId: 1,
  scientificName: kHostileScientificName,
  lengthMm: 380,
  measurementCode: 'TL',
  outcome: CatchOutcome.fails,
  outcomeDetail: kHostileOutcomeDetail,
  ruleCitationRef: kHostileCitationRef,
  contentVersion: 'es-ga@1',
  createdAt: '2026-08-01T05:40:00Z',
);

/// The unit the settings fakes are asked to write.
const LengthUnit kFixtureLengthUnit = LengthUnit.mm;
