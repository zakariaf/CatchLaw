/// The fixtures E03's ~80 resolution tests vary one field of at a time.
///
/// All `const`, all built from the real rows `SPEC.md` and
/// `catchlaw-content-pipeline` calibrate against, and all `k`-prefixed per
/// `CONVENTIONS.md` §6 — the narrower rule for `testing/models/`, which wins
/// over `FLUTTER_GUIDE.md` §3.1's general ban for fixtures and only fixtures.
library;

import 'package:rule_engine/rule_engine.dart';

/// UAE Ministerial Decision 580/2015, Art. 3 — the citation every Gulf example
/// in the spec and the skills is written around.
const kCitationMd580 = Citation(
  instrument: 'Ministerial Decision 580/2015',
  article: 'Art. 3',
  publishedOn: '2015-11-03',
  checkedOn: '2026-07-14',
);

/// A second, separately-constructed instance of the same citation.
///
/// Exists so an equality test compares two objects rather than one object with
/// itself, which would pass under identity equality and prove nothing.
const kCitationMd580Copy = Citation(
  instrument: 'Ministerial Decision 580/2015',
  article: 'Art. 3',
  publishedOn: '2015-11-03',
  checkedOn: '2026-07-14',
);

/// A different instrument, for tests that need two citations to disagree.
const kCitationRakLocal = Citation(
  instrument: 'RAK Local Order 4/2018',
  article: 'Art. 7',
  publishedOn: '2018-02-11',
  checkedOn: '2026-07-14',
);

/// *Epinephelus coioides* — هامور, the orange-spotted grouper.
const kSpeciesHamour = Species(
  id: 42,
  scientificName: 'Epinephelus coioides',
  taxonGroup: TaxonGroup.finfish,
  colId: '4QZ7T',
);

/// *Lethrinus nebulosus* — شعري, the spangled emperor.
const kSpeciesShari = Species(
  id: 43,
  scientificName: 'Lethrinus nebulosus',
  taxonGroup: TaxonGroup.finfish,
);

/// The Ras Al Khaimah region — a root zone, so its parent is null.
const kZoneRasAlKhaimah = Zone(
  id: 1,
  jurisdictionId: 7,
  parentZoneId: null,
  code: 'ae-rak',
  waterType: WaterType.salt,
  zoneKind: ZoneKind.region,
);

/// A bank inside [kZoneRasAlKhaimah], for the ancestry ladder of T04.
const kZoneRakBank = Zone(
  id: 2,
  jurisdictionId: 7,
  parentZoneId: 1,
  code: 'ae-rak-bank',
  waterType: WaterType.salt,
  zoneKind: ZoneKind.bank,
);

/// Hamour, minimum 45 cm total length — `min_size: 450`, method `TL`.
///
/// `validTo` is null: no expiry, which `product-invariants.md` §5 says is valid
/// and never expired.
const kRuleHamourMinSize = Rule(
  id: 100,
  jurisdictionId: 7,
  zoneId: 1,
  speciesId: 42,
  waterType: WaterType.salt,
  citation: kCitationMd580,
  citationLineageId: 'ae-md-580-2015',
  validFrom: '2015-11-03',
  minSizeMm: 450,
  measurementMethod: MeasurementMethod.totalLength,
);

/// A second, separately-constructed instance of [kRuleHamourMinSize].
const kRuleHamourMinSizeCopy = Rule(
  id: 100,
  jurisdictionId: 7,
  zoneId: 1,
  speciesId: 42,
  waterType: WaterType.salt,
  citation: kCitationMd580,
  citationLineageId: 'ae-md-580-2015',
  validFrom: '2015-11-03',
  minSizeMm: 450,
  measurementMethod: MeasurementMethod.totalLength,
);

/// A rule with no zone: the whole jurisdiction, ranked 0 by T04's ladder.
const kRuleWholeJurisdiction = Rule(
  id: 101,
  jurisdictionId: 7,
  zoneId: null,
  speciesId: 42,
  waterType: WaterType.both,
  citation: kCitationMd580,
  citationLineageId: 'ae-md-580-2015',
  validFrom: '2015-11-03',
  minSizeMm: 400,
  measurementMethod: MeasurementMethod.totalLength,
);

/// Sha'ri, closed 1 March to 30 April, annually.
const kRuleShariClosedSeason = Rule(
  id: 102,
  jurisdictionId: 7,
  zoneId: 1,
  speciesId: 43,
  waterType: WaterType.salt,
  citation: kCitationMd580,
  citationLineageId: 'ae-md-580-2015',
  validFrom: '2015-11-03',
  closedSeasons: <ClosedSeason>[
    ClosedSeason(
      recurrence: Recurrence.annual,
      startMonth: 3,
      startDay: 1,
      endMonth: 4,
      endDay: 30,
      citation: kCitationMd580,
    ),
  ],
);
