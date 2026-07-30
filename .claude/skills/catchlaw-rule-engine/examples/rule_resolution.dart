// Demonstrates the CatchLaw resolution algorithm in pure Dart with ZERO Flutter imports: the
// four-stage pipeline (select, lineage collapse, zone ancestry, specificity rank), an expired
// ruleset TAGGED rather than filtered, a disagreeing tie returned as Ambiguous instead of chosen,
// the fixed FindingKind precedence, and the three distinct "nothing applies" states.
// Every date is injected; DateTime.now() is absent. Runs under `dart run`, no Flutter SDK.
// Species search normalisation lives in examples/species_normalisation.dart.

enum WaterType { marine, brackish, fresh }

enum MeasurementMethod {
  tl('total length'), fl('fork length'), cw('carapace width'), shl('shell length');

  const MeasurementMethod(this.label);
  final String label;
}

enum ZoneScope {
  exclusion(40), reserve(30), bank(20), subzone(10), region(0);

  const ZoneScope(this.specificity);
  final int specificity;
}

enum FindingKind { protected, closedSeason, maxSize, minSize, bagLimit, vesselLimit }

const _precedence = <FindingKind, int>{
  FindingKind.protected: 60, FindingKind.closedSeason: 50, FindingKind.maxSize: 40,
  FindingKind.minSize: 30, FindingKind.bagLimit: 20, FindingKind.vesselLimit: 10,
};

class Citation {
  const Citation(this.instrument, this.article, this.publishedOn, this.checkedOn);
  final String instrument, article;
  final DateTime publishedOn, checkedOn;
  @override
  String toString() => '$instrument, $article (published ${_d(publishedOn)})';
}

typedef Measurement = ({double value, String unit, MeasurementMethod method});
typedef Request = ({
  String speciesId, String jurisdiction, WaterType waterType, List<String> zonePath,
  DateTime on, List<Citation> searched, DateTime checkedOn, Measurement? reading,
});
typedef Finding = ({
  FindingKind kind, Citation citation, bool fails, bool isExpired, DateTime? expiredOn,
  String? statement, // a STATEMENT OF FACT; never an instruction
});

/// A plain row, deliberately NOT a drift data class: the CLI must build fixtures without SQLite.
class RuleRow {
  const RuleRow(this.ruleId, this.speciesId, this.zoneId, this.scope, this.kind,
      this.citationLineageId, this.citation, this.validFrom,
      {this.jurisdiction = 'AE', this.waterType = WaterType.marine, this.validTo, this.threshold,
      this.unit, this.method});

  final String ruleId, speciesId, citationLineageId, jurisdiction;
  final String? zoneId, unit; // zoneId null means "the whole jurisdiction"
  final ZoneScope scope;
  final FindingKind kind;
  final WaterType waterType;
  final Citation citation;
  final DateTime validFrom;
  final DateTime? validTo; // metadata for the stale bar — NEVER a filter predicate
  final double? threshold;
  final MeasurementMethod? method;

  /// Substance only. Never ruleId, validFrom or citation: two identically worded rules from two
  /// instruments are corroboration, not an ambiguity.
  bool outcomeEquals(RuleRow o) =>
      kind == o.kind && threshold == o.threshold && unit == o.unit && method == o.method;
}

sealed class Resolution {
  const Resolution();
}

final class Decided extends Resolution {
  const Decided(this.headline, this.secondary);
  final Finding headline;
  final List<Finding> secondary; // rules that did not decide still print in the rule table
}

/// Equal specificity, differing outcomes. The engine refuses to choose; BOTH citations print.
final class Ambiguous extends Resolution {
  const Ambiguous(this.rules);
  final List<RuleRow> rules;
}

/// The instrument WAS searched and positively records no limit. A statement, and it is cited.
final class NoLimitInInstrument extends Resolution {
  const NoLimitInInstrument(this.citation);
  final Citation citation;
}

/// The reference DB holds no rule here. NOT permission, and never rendered as one.
final class NoRuleFound extends Resolution {
  const NoRuleFound(this.searched, this.checkedOn);
  final List<Citation> searched;
  final DateTime checkedOn;
}

/// A fork-length reading against a total-length rule. Never compared, never converted.
final class MethodMismatch extends Resolution {
  const MethodMismatch(this.read, this.wanted, this.citation);
  final MeasurementMethod read, wanted;
  final Citation citation;
}

Resolution resolve(Request req, List<RuleRow> rows) {
  // 1. Select. valid_to is deliberately absent: expiry never removes a row.
  final applicable = rows.where((r) =>
      r.jurisdiction == req.jurisdiction &&
      r.speciesId == req.speciesId &&
      r.waterType == req.waterType &&
      !r.validFrom.isAfter(req.on));
  // 2. Greatest valid_from per (zone, lineage): an amendment supersedes only its own ancestor.
  final latest = <(String?, String), RuleRow>{};
  for (final r in applicable) {
    final k = (r.zoneId, r.citationLineageId);
    if (!latest.containsKey(k) || r.validFrom.isAfter(latest[k]!.validFrom)) latest[k] = r;
  }
  // 3. Zone: NULL, equal, or an ancestor of the active zone.  4. Rank by specificity.
  final ranked = latest.values
      .where((r) => r.zoneId == null || req.zonePath.contains(r.zoneId))
      .toList()
    ..sort((a, b) => b.scope.specificity.compareTo(a.scope.specificity));
  if (ranked.isEmpty) return NoRuleFound(req.searched, req.checkedOn);

  final top = ranked.first;
  final rivals = ranked.where((r) => r.scope.specificity == top.scope.specificity).toList();
  if (rivals.length > 1 && rivals.any((r) => !r.outcomeEquals(top))) {
    return Ambiguous(rivals); // expiry does NOT break the tie
  }
  final read = req.reading;
  if (read != null && top.method != null && read.method != top.method) {
    return MethodMismatch(read.method, top.method!, top.citation);
  }
  final findings = ranked.map((r) => _finding(r, req.on, read)).toList();
  final failures = findings.where((f) => f.fails).toList()
    ..sort((a, b) => _precedence[b.kind]!.compareTo(_precedence[a.kind]!));
  final headline = failures.isNotEmpty ? failures.first : findings.first;
  return Decided(headline, findings.where((f) => f != headline).toList());
}

/// Expiry becomes a FLAG computed from the injected date. Nothing is ever dropped.
Finding _finding(RuleRow r, DateTime on, Measurement? read) {
  final fails = switch (r.kind) {
    FindingKind.protected => true,
    FindingKind.minSize => read != null && read.value < (r.threshold ?? 0),
    FindingKind.maxSize => read != null && read.value > (r.threshold ?? double.infinity),
    _ => false, // closures and bag limits need calendar and log inputs omitted here
  };
  return (
    kind: r.kind,
    citation: r.citation,
    fails: fails,
    isExpired: r.validTo != null && r.validTo!.isBefore(on),
    expiredOn: r.validTo,
    // No "keep", no "return", no "throw it back" (catchlaw-verdict-contract).
    statement: fails && r.kind == FindingKind.minSize && read != null
        ? 'Below the minimum — ${read.value.toStringAsFixed(0)} ${r.unit}, minimum '
            '${r.threshold!.toStringAsFixed(0)} ${r.unit} (${r.method!.label})'
        : null,
  );
}

String _d(DateTime d) => d.toIso8601String().substring(0, 10);

final _md580 = Citation('Ministerial Decision 580/2015', 'Art. 3', DateTime.utc(2015, 11, 3),
    DateTime.utc(2026, 7, 14));

/// Hamour, Ras Al Khaimah, minimum 45 cm total length, on a ruleset that lapsed on 2026-06-30.
final hamourMinSize = RuleRow('ae-rk-hamour-min', 'epinephelus-coioides', 'AE-RK', ZoneScope.region,
    FindingKind.minSize, 'ae-md-580-2015', _md580, DateTime.utc(2015, 11, 3),
    validTo: DateTime.utc(2026, 6, 30), // LAPSED — still resolved, tagged isExpired
    threshold: 45, unit: 'cm', method: MeasurementMethod.tl);

void main() {
  final req = (
    speciesId: 'epinephelus-coioides',
    jurisdiction: 'AE',
    waterType: WaterType.marine,
    zonePath: const ['AE', 'AE-RK'],
    on: DateTime.utc(2026, 7, 30), // injected, never DateTime.now()
    searched: [_md580],
    checkedOn: DateTime.utc(2026, 7, 14),
    reading: (value: 38.0, unit: 'cm', method: MeasurementMethod.tl),
  );

  // Prints: Below the minimum — 38 cm, minimum 45 cm (total length) | stale since 2026-06-30 | ...
  switch (resolve(req, [hamourMinSize])) {
    case Decided(:final headline):
      final age = headline.isExpired ? 'stale since ${_d(headline.expiredOn!)}' : 'current';
      print('${headline.statement} | $age | ${headline.citation}');
    case Ambiguous(:final rules):
      print('Two rules apply and disagree: ${rules.map((r) => r.citation).join(" / ")}');
    case NoLimitInInstrument(:final citation):
      print('No size limit recorded in $citation');
    case NoRuleFound(:final searched, :final checkedOn): // NOT permission
      print('No rule recorded. Searched ${searched.length} instrument(s), ${_d(checkedOn)}.');
    case MethodMismatch(:final read, :final wanted):
      print('Measured as ${read.label}; the rule is stated in ${wanted.label}. Not compared.');
  }
}
