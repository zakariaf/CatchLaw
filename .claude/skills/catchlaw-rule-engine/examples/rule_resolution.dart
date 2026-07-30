// Demonstrates the CatchLaw resolution algorithm in pure Dart with ZERO Flutter imports: select on
// jurisdiction + species + water type with valid_from <= the date, collapse to the greatest
// valid_from per (zone, citation lineage), keep NULL/equal/ancestor zones, rank by specificity;
// return BOTH rules when the top two tie and disagree; headline by the fixed FindingKind precedence
// with the rest as secondary findings; and the behaviour the whole engine turns on — AN EXPIRED
// RULE IS TAGGED, NEVER FILTERED AWAY. The date comes from an injected Clock, never DateTime.now().

/// A test wires a fixed date and proves the Sha'ri closure on 2026-03-14; the wall-clock
/// implementation lives in the app layer, never in this package.
abstract interface class Clock {
  DateTime today();
}
class FixedClock implements Clock {
  const FixedClock(this.date);
  final DateTime date;
  @override
  DateTime today() => date;
}

enum WaterType { marine, brackish, fresh }
enum MeasurementMethod { tl, fl, cw, shl } // total, fork, carapace width, shell length
enum FindingKind { protected, closedSeason, maxSize, minSize, bagLimit, vesselLimit }
/// A closed integer table, never re-derived from path depth or string prefixes.
enum ZoneScope {
  exclusion(40), reserve(30), bank(20), subzone(10), region(0);
  const ZoneScope(this.specificity);
  final int specificity;
}
const _precedence = <FindingKind, int>{FindingKind.protected: 60, FindingKind.closedSeason: 50,
  FindingKind.maxSize: 40, FindingKind.minSize: 30, FindingKind.bagLimit: 20,
  FindingKind.vesselLimit: 10};

typedef Citation = ({String instrument, String article, DateTime publishedOn, DateTime checkedOn});
typedef Measurement = ({double value, String unit, MeasurementMethod method});
typedef Request = ({String speciesId, String jurisdiction, WaterType waterType,
  List<String> zonePath, DateTime on, DateTime checkedOn, Measurement? reading});
typedef Finding = ({FindingKind kind, Citation citation, bool fails, bool isExpired, DateTime? on});
/// A plain row, NOT a drift data class (the CLI builds fixtures without SQLite). `zoneId` null
/// means the whole jurisdiction; `validTo` is stale-bar metadata, NEVER a filter predicate.
typedef Rule = ({String speciesId, String jurisdiction, WaterType waterType, String? zoneId,
  ZoneScope scope, FindingKind kind, String lineageId, Citation citation, DateTime validFrom,
  DateTime? validTo, double? threshold, String? unit, MeasurementMethod? method});
/// Substance only: two identically worded rules from two instruments are corroboration.
bool _sameOutcome(Rule a, Rule b) =>
    a.kind == b.kind && a.threshold == b.threshold && a.unit == b.unit && a.method == b.method;

sealed class Resolution {
  const Resolution();
}
final class Decided extends Resolution {
  const Decided(this.headline, this.secondary);
  final Finding headline;
  final List<Finding> secondary; // rules that did not decide still print in the rule table
}
/// Equal specificity, differing outcomes: the engine refuses to choose and BOTH citations print.
final class Ambiguous extends Resolution {
  const Ambiguous(this.rules);
  final List<Rule> rules;
}
/// NOT permission, and distinct from a NoLimitInInstrument variant: a positive, cited statement.
final class NoRuleFound extends Resolution {
  const NoRuleFound(this.checkedOn);
  final DateTime checkedOn;
}

Resolution resolve(Request req, List<Rule> rows) {
  // 1. Select. NOTE WHAT IS ABSENT: there is no valid_to predicate, and there must never be one.
  //    Filtering expired rows out would empty the result set the day an annual instrument lapses —
  //    the Galician orden de vedas on 1 May, the Jurumirim piracema portaria on 1 March — and every
  //    species it carried would fall to "no rule recorded", as if the region had stopped regulating
  //    fishing. That silently converts a defensible frozen snapshot with a known as-of date into a
  //    de facto live-data product, which an app with no network can never be. Tag, never delete.
  final applicable = rows.where((r) =>
      r.jurisdiction == req.jurisdiction &&
      r.speciesId == req.speciesId &&
      r.waterType == req.waterType &&
      !r.validFrom.isAfter(req.on));
  // 2. Greatest valid_from per (zone, lineage): an amendment supersedes only its own ancestor.
  final latest = <(String?, String), Rule>{};
  for (final r in applicable) {
    final k = (r.zoneId, r.lineageId);
    if (!latest.containsKey(k) || r.validFrom.isAfter(latest[k]!.validFrom)) latest[k] = r;
  }
  // 3. Zone: NULL, equal, or an ancestor of where he stands.  4. Rank by specificity, descending.
  final ranked = latest.values
      .where((r) => r.zoneId == null || req.zonePath.contains(r.zoneId))
      .toList()
    ..sort((a, b) => b.scope.specificity.compareTo(a.scope.specificity));
  if (ranked.isEmpty) return NoRuleFound(req.checkedOn);
  // A tie that disagrees is a real state of the world: never .first, never "newest wins", never
  // "strictest wins", never "expired loses" — that last one is deletion semantics in disguise.
  final top = ranked.first;
  final rivals = ranked.where((r) => r.scope.specificity == top.scope.specificity).toList();
  if (rivals.length > 1 && rivals.any((r) => !_sameOutcome(r, top))) return Ambiguous(rivals);
  // Precedence is applied exactly once, here. The first failure headlines; nothing is discarded.
  final findings = [for (final r in ranked) _finding(r, req.on, req.reading)];
  final failures = findings.where((f) => f.fails).toList()
    ..sort((a, b) => _precedence[b.kind]!.compareTo(_precedence[a.kind]!));
  final headline = failures.isNotEmpty ? failures.first : findings.first;
  return Decided(headline, findings.where((f) => f != headline).toList());
}

Finding _finding(Rule r, DateTime on, Measurement? read) {
  // Compared ONLY against its own method: 65 cm fork length is roughly 71 cm total length, and
  // crossing the two manufactures a pass at the centimetre that costs AED 3,000. Never converted.
  final ok = read != null && read.method == r.method;
  final fails = switch (r.kind) {
    FindingKind.protected => true,
    FindingKind.minSize => ok && read.value < r.threshold!,
    FindingKind.maxSize => ok && read.value > r.threshold!,
    _ => false, // closures and bag limits need calendar and log inputs omitted here
  };
  // Expiry becomes a FLAG computed from the injected date; the row itself is never dropped.
  return (kind: r.kind, citation: r.citation, fails: fails, on: r.validTo,
      isExpired: r.validTo != null && r.validTo!.isBefore(on));
}

/// Every finding carries a non-null Citation, because an uncited number is an opinion.
Rule _minSize(String species, String zone, ZoneScope scope, String lineage, String instrument,
        DateTime published, double size, String unit, MeasurementMethod method,
        {String juris = 'AE', String article = 'Art. 3', DateTime? until}) =>
    (speciesId: species, jurisdiction: juris, waterType: WaterType.marine, zoneId: zone,
        scope: scope, kind: FindingKind.minSize, lineageId: lineage, validFrom: published,
        citation: (instrument: instrument, article: article, publishedOn: published,
            checkedOn: DateTime.utc(2026, 7, 14)),
        validTo: until, threshold: size, unit: unit, method: method);

void main() {
  final clock = FixedClock(DateTime.utc(2026, 7, 30)); // injected; resolve() reads no clock at all
  Request req(String species, String juris, List<String> path, Measurement m) => (
        speciesId: species, jurisdiction: juris, waterType: WaterType.marine, zonePath: path,
        on: clock.today(), checkedOn: DateTime.utc(2026, 7, 14), reading: m);
  // Hamour / هامور, 38 cm TL at Ras Al Khaimah, on a pack that LAPSED on 2026-06-30 — resolves anyway.
  final hamour = _minSize('epinephelus-coioides', 'AE-RK', ZoneScope.region, 'ae-md-580-2015',
      'Ministerial Decision 580/2015', DateTime.utc(2015, 11, 3), 45, 'cm', MeasurementMethod.tl,
      until: DateTime.utc(2026, 6, 30));
  _show(resolve(req('epinephelus-coioides', 'AE', const ['AE', 'AE-RK'],
      (value: 38, unit: 'cm', method: MeasurementMethod.tl)), [hamour]));
  // Ameixa babosa, Banco de Cambados: two instruments at bank 20, 38 mm vs 40 mm, one lapsed.
  Rule galicia(String lineage, String instrument, double mm, {DateTime? until}) =>
      _minSize('venerupis-corrugata', 'banco-de-cambados', ZoneScope.bank, lineage, instrument,
          DateTime.utc(2024, 12, 30), mm, 'mm', MeasurementMethod.shl,
          juris: 'ES', article: 'Anexo I', until: until);
  _show(resolve(req('venerupis-corrugata', 'ES', const ['ES', 'ES-GA', 'banco-de-cambados'],
      (value: 34, unit: 'mm', method: MeasurementMethod.shl)), [
    galicia('ga-vedas-2025', 'Orde do 30/12/2024', 38, until: DateTime.utc(2026, 4, 30)),
    galicia('ga-plan-cambados', 'Plan de xestión de Cambados', 40),
  ]));
}

void _show(Resolution r) => print(switch (r) {
      Decided(:final headline) => '${headline.kind.name} ${headline.fails ? 'FAILS' : 'passes'} | '
          '${headline.isExpired ? 'stale since ${_d(headline.on!)}, evaluated anyway' : 'current'}'
          ' | ${headline.citation.instrument}, ${headline.citation.article}',
      Ambiguous(:final rules) => 'Two rules apply and disagree; both cited: '
          '${rules.map((x) => '${x.threshold} ${x.unit} — ${x.citation.instrument}').join(' / ')}',
      NoRuleFound(:final checkedOn) => // absence of a rule is NOT permission
        'No rule recorded for this species here. Content checked ${_d(checkedOn)}.',
    });
String _d(DateTime d) => d.toIso8601String().substring(0, 10);
