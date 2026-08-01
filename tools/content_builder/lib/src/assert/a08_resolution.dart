import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/model/regulation.dart';
import 'package:content_builder/src/resolve/resolution_grid.dart';
import 'package:content_builder/src/resolve/rule_set_adapter.dart';
import 'package:rule_engine/rule_engine.dart' hide Failure;
// The engine's Result error arm is also called Failure. Prefixed rather than
// renamed on either side: `Failure` is the build's failure line everywhere else
// in this package, and the engine's is the one E03 settled.
import 'package:rule_engine/rule_engine.dart' as engine show Failure;

/// What one A8 sweep measured, so the cost is a number somebody can act on
/// rather than a claim in a document.
typedef GridReport = ({int cells, int rules, int milliseconds});

/// A8 — the shipped engine resolves the authored grid without contradiction.
///
/// **Row-level assertions cannot see a contradiction.** A1 through A7 each look
/// at one row, and two rows that each validate perfectly can still say 380 mm
/// and 400 mm about the same clam on the same bank in the same month.
/// `catchlaw-content-pipeline` rule 10 states the consequence: the tie is broken
/// at sea, offline, in favour of whichever row the query returned first.
///
/// The engine is **imported**, so a precedence change in E03 re-runs here for
/// free rather than needing a second model of the rules kept in step by hand.
/// Nothing in this file re-implements `SPEC.md` §7.3: no specificity table, no
/// zone-ancestry rule, no tie-break.
///
/// **Expiry is not a failure, and that is invariant 5.** The Galician *orde de
/// vedas* is reissued annually and typically lapses on 30 April. §7.3 records
/// what filtering on `valid_to` did to the first draft: every rule sourced from
/// a lapsed instrument vanished and every species fell through to "no rule
/// recorded". An assertion that failed on an expired row would do the same
/// damage a year earlier and more permanently, by making the corpus unshippable
/// until somebody deleted the rows. `isExpired` appears nowhere in this file.
///
/// **A genuine ambiguity stays shippable, or D4 is dead code.**
/// `build-assertions.md` prescribes `supersedes:` and that is the right first
/// answer. But §7.3 step 4 and §6 D4 require the app to render **both** rules
/// when two instruments at equal specificity genuinely disagree. If A8 failed on
/// every ambiguity, no such pair could be authored, D4 would be unreachable, and
/// the first real legal conflict would have nowhere to go but a `supersedes:`
/// the sources do not support — which is precisely the silent choice §7.3
/// forbids. So A8 fails on an **unacknowledged** ambiguity.
final class ResolutionAssertion implements Assertion {
  /// The A8 assertion, resolving the grid as at [on].
  ///
  /// The date is a parameter because the engine reads no clock
  /// (`catchlaw-rule-engine` rule 3) and T01 already made `--build-date`
  /// required input.
  const ResolutionAssertion({this.on});

  /// The date to resolve at, or `null` to take it from the corpus.
  final DateTime? on;

  /// What the most recent sweep measured. Printed with the build summary.
  static GridReport? lastReport;

  @override
  String get id => 'A8';

  @override
  Iterable<Failure> run(ContentSource source) sync* {
    final rows = <String, RuleRow>{
      for (final RuleRow r in source.typedRows.whereType<RuleRow>()) r.id: r,
    };
    // No rules is not a contradiction, and a corpus with none needs no date.
    if (rows.isEmpty) return;

    final DateTime? date = on ?? source.buildDate;
    if (date == null) {
      // Resolving at no date would drop every rule whose valid_from is compared
      // against nothing, and report the corpus as empty.
      yield const Failure(_id, 'content', 0, 'no date to resolve at; pass --build-date');
      return;
    }

    final adapter = RuleSetAdapter.of(source);
    final Map<({Species species, WaterType waterType}), List<GridCell>> grid = ResolutionGrid.of(
      source,
      adapter,
    );
    // Stopwatch, not DateTime.now(): T01 bans the clock from this package's
    // lib/ so nothing can quietly supply a retrieved_on or a build date, and an
    // elapsed measurement is neither.
    final clock = Stopwatch()..start();
    final reached = <String>{};
    final reported = <String>{};
    var cells = 0;

    for (final MapEntry<({Species species, WaterType waterType}), List<GridCell>> group
        in grid.entries) {
      final Species species = group.key.species;

      // ONCE per (species, water type). SPEC.md §13 budgets one evaluation at
      // under 10 ms over at most twenty candidate rows, and that budget includes
      // the device's row read; re-collecting per cell would multiply the
      // expensive half by the whole grid. The sweep below is pure in-memory
      // evaluation with no row read at all.
      final List<Rule> candidates = adapter.collect(species.id, group.key.waterType);
      if (candidates.isEmpty) continue;

      // A property of the candidate SET, not of one cell: checked once per
      // group. build-assertions.md's resolution is "delete the size rule" —
      // protected admits no threshold, the ladder headlines `protected`, and
      // the size would never be read. Two rows that each pass A1 can still say
      // this between them.
      yield* _protectedWithThreshold(candidates, adapter, rows);

      for (final GridCell cell in group.value) {
        cells++;
        final EvaluationRequest request = _requestFor(cell, species, adapter, date);

        // Reachability comes from the engine's own selection, not from a second
        // model of which rules apply where.
        final Result<List<Candidate>> selected = selectCandidates(request, candidates);
        if (selected case Ok<List<Candidate>>(:final List<Candidate> value)) {
          for (final Candidate c in matchAndRank(request, value)) {
            reached.add(adapter.ruleIdOf[c.rule.id] ?? '');
          }
        }

        switch (evaluate(request, candidates)) {
          case engine.Failure<Resolution>(:final Exception exception):
            if (reported.add('$exception')) {
              yield Failure(_id, 'content', 0, '$cell $exception');
            }
          case Ok<Resolution>(:final Resolution value):
            yield* _inspect(value, adapter, rows, reported);
        }
      }
    }

    // A rule nobody can reach is indistinguishable from a rule nobody wrote —
    // unless another rule supersedes it, which is exactly why it resolves
    // nowhere. A superseded row stays in the corpus because the changelog and
    // the citation lineage both need it.
    final superseded = <String>{
      for (final RuleRow r in rows.values)
        if (r.supersedes != null) r.supersedes!,
    };
    for (final RuleRow row in rows.values) {
      if (reached.contains(row.id) || superseded.contains(row.id)) continue;
      yield Failure(
        _id,
        row.path,
        row.line,
        "rule '${row.id}' resolves in no cell of the grid — "
        'check its zone_id, valid_from and water_type',
      );
    }

    lastReport = (
      cells: cells,
      rules: rows.length,
      milliseconds: (clock..stop()).elapsedMilliseconds,
    );
  }

  EvaluationRequest _requestFor(
    GridCell cell,
    Species species,
    RuleSetAdapter adapter,
    DateTime date,
  ) => EvaluationRequest(
    jurisdictionId: adapter.jurisdictions[cell.jurisdictionId] ?? -1,
    speciesId: species.id,
    species: species,
    waterType: cell.waterType,
    zonePath: cell.zonePath,
    on: cell.isoDate(date.year),
    contentCheckedOn: _iso(date),
    // A8 is about contradictions between rules, not about one fish. No length
    // and no tally: a size finding with nothing to compare against is
    // indeterminate, which is the honest answer and not a failure.
    landing: const Landing(lengthMm: null, method: null),
    tally: const CatchTally(),
    searched: adapter.citations.values.toList(),
  );

  /// A species that is protected somewhere and size-limited somewhere else.
  Iterable<Failure> _protectedWithThreshold(
    List<Rule> candidates,
    RuleSetAdapter adapter,
    Map<String, RuleRow> rows,
  ) sync* {
    final bool anyProtected = candidates.any((Rule r) => r.isProtected);
    if (!anyProtected) return;
    for (final rule in candidates) {
      if (rule.isProtected || (rule.minSizeMm == null && rule.maxSizeMm == null)) continue;
      final RuleRow? row = rows[adapter.ruleIdOf[rule.id]];
      yield Failure(
        _id,
        row?.path ?? 'content',
        row?.line ?? 0,
        "rule '${row?.id}' carries a size threshold for a species another rule "
        'protects — protected admits no threshold, so the size would never be read',
      );
    }
  }

  Iterable<Failure> _inspect(
    Resolution resolution,
    RuleSetAdapter adapter,
    Map<String, RuleRow> rows,
    Set<String> reported,
  ) sync* {
    // No `default:` arm. NoRuleFound and NoLimitInInstrument are different
    // answers and a default would fuse them — as it would silently fuse any
    // variant E03 adds later.
    switch (resolution) {
      case Ambiguous(:final List<Rule> rules):
        final ids = <String>[for (final Rule r in rules) adapter.ruleIdOf[r.id] ?? '${r.id}']
          ..sort();
        if (_acknowledged(ids, rows) || _incomparable(rules)) return;
        if (!reported.add(ids.join('|'))) return;
        final RuleRow? at = rows[ids.first];
        yield Failure(
          _id,
          at?.path ?? 'content',
          at?.line ?? 0,
          'two rules bite at equal specificity and disagree: ${ids.join(', ')} — '
          'author supersedes: on the newer, or ambiguity_ack on both',
        );

      case Decided():
      // Resolved cleanly. Whether the instrument behind it has lapsed is not
      // this assertion's business: invariant 5.

      case NoLimitInInstrument():
      // Positively recorded, and cited. A valid answer.

      case NoRuleFound():
      // Silence in the sources is not permission, and this is a legitimate
      // state. The unreachable-rule sweep after the grid is what catches a rule
      // that resolves nowhere at all.

      case UnknownSpecies():
      // Unreachable by construction: the grid is generated from the species
      // rows, so every request carries a species the corpus declares. The arm
      // exists because the switch is exhaustive, which is the point — if E03
      // adds a variant, this file stops compiling rather than silently
      // ignoring it.
    }
  }

  /// Whether the disagreement is only that the rules measure different things.
  ///
  /// `min_size_mm: 450 TL` and `min_size_mm: 400 FL` are not a contradiction —
  /// they are two measurements of different parts of the fish, and
  /// `build-assertions.md` classifies them as legal with both shown. A1
  /// guarantees both carry a method. This is exactly the shape a naive
  /// contradiction check flags, so it is named rather than left to the engine,
  /// which correctly reports them as ambiguous because the app must render both.
  ///
  /// Narrow on purpose: the rules must agree on everything **except** the size
  /// pair, and their methods must all differ. Two rules with different methods
  /// AND different bag limits are a real contradiction wearing a method.
  bool _incomparable(List<Rule> rules) {
    final methods = <MeasurementMethod?>{for (final Rule r in rules) r.measurementMethod};
    if (methods.length != rules.length || methods.contains(null)) return false;

    final Rule first = rules.first;
    return rules
        .skip(1)
        .every(
          (Rule r) => outcomeEquals(
            first,
            r.copyWith(
              minSizeMm: first.minSizeMm,
              maxSizeMm: first.maxSizeMm,
              measurementMethod: first.measurementMethod,
            ),
          ),
        );
  }

  /// Whether every rule of the pair acknowledges another one of it, with a
  /// reason.
  ///
  /// A half-acknowledged pair is an author who stopped halfway, and D4 would
  /// render one citation where the law offers two.
  ///
  /// [ids] always holds at least two: `Ambiguous` is only returned for a tie.
  bool _acknowledged(List<String> ids, Map<String, RuleRow> rows) {
    for (final id in ids) {
      final RuleRow? row = rows[id];
      final String? ack = row?.ambiguityAckWith;
      if (ack == null || ack == id || !ids.contains(ack)) return false;
      if (row!.ambiguityAckReasonKey == null) return false;
    }
    return true;
  }

  static String _iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static const String _id = 'A8';
}
