import 'package:rule_engine/src/models/closed_season.dart';
import 'package:rule_engine/src/models/rule.dart';
import 'package:rule_engine/src/models/zone.dart';
import 'package:rule_engine/src/resolve/candidate.dart';
import 'package:rule_engine/src/resolve/zone_match.dart';

/// Whether [a] and [b] say the same thing about the fish.
///
/// SUBSTANCE ONLY. Compared: protection, both size thresholds, the measurement
/// method, the bag limit with its unit and period, the vessel limit, and the
/// closure windows. Never compared: `id`, `validFrom`, `validTo`, `citation`,
/// `citationLineageId`, `zoneId` or row order.
///
/// `resolution-algorithm.md` gives the reason in one sentence: *two
/// identically-worded rules from two instruments are not an ambiguity; they are
/// corroboration.* A national decision and a local order that both say 45 cm
/// total length are two citations for one fact, and raising the conflict dialog
/// over them teaches a fisher to dismiss it — after which it is worth nothing on
/// the day it means something.
///
/// [Rule]'s own `==` is deliberately NOT used here. It includes `id` and
/// `citation`, so it would report corroboration as a conflict: the exact
/// inversion of the feature.
bool outcomeEquals(Rule a, Rule b) =>
    a.isProtected == b.isProtected &&
    a.minSizeMm == b.minSizeMm &&
    a.maxSizeMm == b.maxSizeMm &&
    // The method is part of the outcome, not decoration: 65 cm fork length is
    // roughly 71 cm total, so the same number under two methods is two
    // different rules.
    a.measurementMethod == b.measurementMethod &&
    a.bagLimit == b.bagLimit &&
    a.bagLimitUnit == b.bagLimitUnit &&
    a.bagLimitPeriod == b.bagLimitPeriod &&
    a.vesselLimit == b.vesselLimit &&
    _sameWindows(a.closedSeasons, b.closedSeasons);

/// The candidates that disagree at the top of the ladder, or an empty list.
///
/// Returns EVERY candidate at the top specificity when any two of them
/// disagree, in the source order [matchAndRank] preserved. Returning only the
/// pair that differs would drop a third citation the fisher is entitled to read
/// aloud, and would make the output depend on which pair the implementation
/// compared first.
///
/// Only the top rung is examined. A zone rule plus a national rule is not an
/// ambiguity — T04 already settled it, and that settlement is legitimate
/// because a narrower instrument beating a wider one is what the instruments
/// themselves say. Candidates lower down become secondary findings in E03/T09.
///
/// **Every tie-break is refused, by name, so that none of them gets
/// reinvented:** `.first`, newest wins, strictest wins, most permissive wins,
/// and expired loses. All five produce a verdict no instrument supports.
///
/// "Expired loses" is the subtle one, because it feels like careful engineering
/// — prefer the rule still in force. It is E03/T03's deletion semantics wearing
/// a tie-break costume: it means that on the day one of two conflicting
/// instruments lapses, the app silently starts reporting the other one, with no
/// warning and no second citation. `resolution-algorithm.md`'s tie matrix has
/// the row in as many words: equal specificity, one expired, outcomes differ →
/// return both, because expiry is not a tie-breaker.
///
/// This returns candidates rather than a verdict. E03/T10 wraps the output in
/// `Ambiguous`, so that type has exactly one construction site.
List<Candidate> findConflict(List<Candidate> ranked, List<Zone> zonePath) {
  if (ranked.length < 2) return const <Candidate>[];

  final int top = specificityOf(ranked.first.rule, zonePath);
  final atTop = <Candidate>[
    for (final Candidate c in ranked)
      if (specificityOf(c.rule, zonePath) == top) c,
  ];
  if (atTop.length < 2) return const <Candidate>[];

  final bool anyDisagree = atTop
      .skip(1)
      .any((Candidate c) => !outcomeEquals(atTop.first.rule, c.rule));
  return anyDisagree ? atTop : const <Candidate>[];
}

bool _sameWindows(List<ClosedSeason> a, List<ClosedSeason> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    final ClosedSeason x = a[i];
    final ClosedSeason y = b[i];
    // The citation is excluded here for the same reason it is excluded above: a
    // closure is the same closure whichever instrument records it.
    if (x.recurrence != y.recurrence ||
        x.startMonth != y.startMonth ||
        x.startDay != y.startDay ||
        x.endMonth != y.endMonth ||
        x.endDay != y.endDay ||
        x.startDate != y.startDate ||
        x.endDate != y.endDate) {
      return false;
    }
  }
  return true;
}
