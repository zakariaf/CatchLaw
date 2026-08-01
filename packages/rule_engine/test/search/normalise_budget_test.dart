// SPEC.md §13's < 50 ms for species search, spent entirely on the half E02 owns.
//
// §13's figure is END TO END at 400 species / 2,400 names, including the indexed
// prefix query over search_norm capped at 40 results. Neither the database nor
// that query exists until E05. So this asserts the WHOLE ceiling against the
// normalisation half alone: if the fold fits inside the entire budget with an
// order of magnitude to spare, E05 and E08 inherit headroom rather than a budget
// already spent.
//
// THIS IS A REGRESSION GUARD, NOT A DEVICE MEASUREMENT. It runs in the Dart VM
// on whatever CI hardware is going. The device number is §14's dynamic checklist
// and belongs to E21. To keep it from flapping: a warm-up pass before the timed
// pass, Stopwatch rather than DateTime.now() — which check_rule_engine.sh check
// 3 bans in this package anyway — and one aggregate assertion rather than a
// per-call microsecond figure.

import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

import '../../testing/models/species_corpus.dart';
import '../../testing/species_index.dart';

/// `SPEC.md` §13. Not "fast", and not a percentage of the last run: a
/// percentage threshold has no fixed point and drifts upward one commit at a
/// time.
const _budget = Duration(milliseconds: 50);

// MEASURED, on the machine this was written on, so the next reader does not
// have to re-derive what the headroom actually is:
//
//   index side   12.2 ms   2,400 names folded once
//   query side    9.5 ms   2,400 folds of one query  (~4 us per fold)
//
// Both pass, and the task's framing — "spend the whole ceiling on the part E02
// owns, so E05 inherits headroom" — is conservative in a way worth spelling
// out, because the two figures are not comparable and only one of them competes
// with §13's search budget.
//
// The index-side 12.2 ms is a BUILD cost. E04 pays it once per rebuild of
// reference.db, off the device, and it never happens while a fisher is waiting.
// It does not consume §13's 50 ms at all.
//
// The number that DOES compete is the per-fold cost of a single query: about
// 4 microseconds. §13's budget is one of those plus the indexed prefix query,
// so E05 and E08 inherit essentially the whole 50 ms rather than 38 ms of it.
// If a later change makes the fold allocate per call, this file is where it
// shows up first.

/// Runs [body] once to warm the JIT, then times a second run.
Duration _timed(void Function() body) {
  body();
  final sw = Stopwatch()..start();
  body();
  return (sw..stop()).elapsed;
}

void main() {
  final List<String> names = kSpeciesCorpus.keys.toList();
  final index = SpeciesIndex(kSpeciesCorpus);

  test('The corpus holds 2,400 names', () {
    // Without this, every budget test below passes instantly over an empty list.
    expect(names, hasLength(kCorpusSpeciesCount * kCorpusNamesPerSpecies));
  });

  test('normaliseSpeciesTerm folds the 2,400-name corpus in under 50 ms', () {
    // What E04's build loop costs per rebuild.
    final Duration elapsed = _timed(() {
      for (final n in names) {
        normaliseSpeciesTerm(n);
      }
    });
    expect(elapsed, lessThan(_budget), reason: 'index side took $elapsed');
  });

  test('normaliseSpeciesTerm folds one query 2,400 times in under 50 ms', () {
    // The query side. A per-keystroke fold costing 20 microseconds would fit
    // §13 four hundred times over; this pins the order of magnitude.
    final Duration elapsed = _timed(() {
      for (var i = 0; i < names.length; i++) {
        normaliseSpeciesTerm('الهامور');
      }
    });
    expect(elapsed, lessThan(_budget), reason: 'query side took $elapsed');
  });

  test('SpeciesIndex.lookup answers 400 queries against the index in under 50 ms', () {
    // The two halves together, and the guard against someone making indexKeys
    // allocate a List per call on the hot path.
    final queries = <String>[
      for (var i = 0; i < kCorpusSpeciesCount; i++) 'ال${_arabicQueryStem(i)}$i',
    ];
    final Duration elapsed = _timed(() {
      for (final q in queries) {
        index.lookup(q);
      }
    });
    expect(elapsed, lessThan(_budget), reason: 'lookup took $elapsed');
  });
}

/// Mirrors the corpus's stem rotation so the queries actually hit.
String _arabicQueryStem(int i) => const <String>['هامور', 'شعري', 'صافي', 'بدح', 'كنعد'][i % 5];
