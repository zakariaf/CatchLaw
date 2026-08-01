// SPEC.md §13's < 10 ms for rule evaluation.
//
// A REGRESSION GUARD, NOT A PROOF. §13 names a Snapdragon 665 for the launch
// targets and names no device for rule evaluation; this runs in the Dart VM on
// whatever CI hardware is going, which is faster than the phone. E21 measures
// the same fixture on a physical low-end device as part of the §14 walkthrough.
//
// Warm-up pass before the timed pass, Stopwatch rather than a wall-clock
// reading — which check_rule_engine.sh check 3 bans in this package anyway.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../testing/models/fixtures.dart';

const _budget = Duration(milliseconds: 10);

/// Twenty candidate rows across four lineages, so stage 2 has real work: the
/// collapse groups them, and stage 3 ranks the survivors.
List<Rule> _twentyRows() => <Rule>[
  for (var i = 0; i < 20; i++)
    kRuleHamourMinSize.copyWith(
      id: i,
      validFrom: '201${5 + (i % 5)}-01-01',
      citationLineageId: 'lineage-${i % 4}',
      zoneId: i.isEven ? kZoneRasAlKhaimah.id : kZoneUae.id,
    ),
];

void main() {
  const request = EvaluationRequest(
    jurisdictionId: 7,
    speciesId: 42,
    species: kSpeciesHamour,
    waterType: WaterType.salt,
    zonePath: <Zone>[kZoneUae, kZoneRasAlKhaimah],
    on: '2026-07-30',
    contentCheckedOn: '2026-07-14',
    landing: kLandingUndersize,
    tally: kTallyEmpty,
  );
  final List<Rule> rows = _twentyRows();

  test('The latency fixture holds twenty candidate rows', () {
    // Without this the budget test below passes instantly over an empty list.
    expect(rows, hasLength(20));
  });

  test('evaluate resolves 20 candidate rows in under 10 ms', () {
    evaluate(request, rows); // warm-up
    final sw = Stopwatch()..start();
    evaluate(request, rows);
    sw.stop();
    expect(sw.elapsed, lessThan(_budget), reason: 'evaluate took ${sw.elapsed}');
  });
}
