import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:rule_engine/rule_engine.dart' show FindingKind, FindingOutcome;

/// The four states the stamp can take, and there is no fifth.
///
/// The category chooses the signal set — ink, glyph, and whether a measurement
/// sub-line is printed at all. It does **not** choose the sentence: the six
/// `FindingKind`s do. Collapsing the two would print *Below the minimum* over a
/// 122 cm fish that failed a slot rule, which is a confident, wrong and legally
/// distinct statement about a different offence.
///
/// [belowMinimum] carries every adverse measurement outcome — a maximum, a bag
/// limit and a vessel limit as well as a minimum — because those four share one
/// signal set and differ only in wording, and `lonja-verdict-and-status` rule 2
/// forbids inventing a fifth value to hold them.
enum VerdictCategory {
  /// Every rule that fired is met.
  meets,

  /// A measurement rule fired against this individual.
  belowMinimum,

  /// A closure is in force, and it applies at every size.
  closedSeason,

  /// The species may not be taken at all.
  protected,
}

/// Why the screen carries a note instead of a stamp.
///
/// All four are states in which stamping anything would be a claim the sources
/// do not support. Three are absences the engine keeps apart and this keeps
/// apart too; the fourth is a question nobody has answered yet.
enum NoteKind {
  /// Nothing was transcribed for this species here. **Not permission.**
  noRuleRecorded,

  /// The instrument was read and positively records no limit. Cited.
  noLimitInInstrument,

  /// The species is not in this jurisdiction's reference at all.
  unknownSpecies,

  /// A rule was found and could not be evaluated on the facts to hand.
  openQuestion,
}

/// The instrument a finding rests on, as the footnote prints it.
///
/// Four fields, all required. A nullable one would be invariant 3 broken in the
/// layer that renders it, after the engine spent a sealed hierarchy making it
/// unrepresentable.
@immutable
class CitationDisplay {
  /// Instrument, article, published, checked.
  const CitationDisplay({
    required this.instrument,
    required this.article,
    required this.publishedOn,
    required this.checkedOn,
  });

  /// The decision or order itself.
  final String instrument;

  /// The article within it.
  final String article;

  /// When it was published, ISO-8601.
  ///
  /// **Unlocalised, in every locale.** It quotes a printed instrument, so it is
  /// the same string everywhere and can be compared against the gazette by eye.
  /// The numeral lever does not reach it: it is carried through as the stored
  /// string rather than passed through a number formatter.
  final String publishedOn;

  /// When a human last verified the wording, ISO-8601.
  final String checkedOn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CitationDisplay &&
          other.instrument == instrument &&
          other.article == article &&
          other.publishedOn == publishedOn &&
          other.checkedOn == checkedOn;

  @override
  int get hashCode => Object.hash(instrument, article, publishedOn, checkedOn);
}

/// One labelled fact in the rule table.
///
/// Both halves are already localised and already formatted. Nothing downstream
/// looks up a key or formats a number, which is what keeps every legal sentence
/// inside one file and inside `check_verdict_contract.sh`'s reach.
///
/// Named `RuleFact` rather than the `RuleFactRow` E10/T01 asks for, because
/// `layering_test.dart` bans every `*Row` identifier outside `lib/data`: drift
/// names its generated row classes that way, and a boundary that has to tell a
/// real one from a lookalike is not a boundary.
@immutable
class RuleFact {
  /// A label and the fact under it.
  const RuleFact({required this.label, required this.value, this.isOutcome = false});

  /// The row label.
  final String label;

  /// The fact, with its unit where it has one.
  final String value;

  /// Whether this cell states a rule OUTCOME rather than a number.
  ///
  /// Only an outcome cell takes the semantic ink. A table where every value is
  /// coloured turns the verdict inks into decoration, and once an ordinary cell
  /// can look like a verdict, no colour on the screen is evidence of anything.
  final bool isOutcome;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RuleFact &&
          other.label == label &&
          other.value == value &&
          other.isOutcome == isOutcome;

  @override
  int get hashCode => Object.hash(label, value, isOutcome);
}

/// One rule that fired, as the screen states it.
@immutable
class FindingDisplay {
  /// A rule, what it says, and where it says it.
  const FindingDisplay({
    required this.sentence,
    required this.kind,
    required this.outcome,
    required this.citation,
    required this.citationIndex,
    required this.facts,
  });

  /// Already localised, and a statement of fact.
  final String sentence;

  /// Which of the six kinds this is, carried from the engine.
  final FindingKind kind;

  /// Met, breached, or unanswerable — carried from the engine, never re-derived.
  ///
  /// [FindingOutcome.indeterminate] prints as an open question and never as a
  /// pass. An unmeasured fish has not met the minimum; nobody has checked.
  final FindingOutcome outcome;

  /// The instrument it rests on. Required, and never null (invariant 3).
  final CitationDisplay citation;

  /// Which footnote this row points at, 1-based.
  ///
  /// Assigned ONCE, in the presenter, by de-duplicating the citations in
  /// first-appearance order — so the marker on a row and the footnote under the
  /// page cannot disagree. Two markers for one instrument would say two
  /// instruments were read; a marker computed twice is how they come to differ.
  final int citationIndex;

  /// The numbers behind the sentence.
  final List<RuleFact> facts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FindingDisplay &&
          other.sentence == sentence &&
          other.kind == kind &&
          other.outcome == outcome &&
          other.citation == citation &&
          other.citationIndex == citationIndex &&
          listEquals(other.facts, facts);

  @override
  int get hashCode =>
      Object.hash(sentence, kind, outcome, citation, citationIndex, Object.hashAll(facts));
}

/// The one thing at the top of the screen.
@immutable
class VerdictStampDisplay {
  /// The headline finding, dressed for the stamp.
  const VerdictStampDisplay({
    required this.headline,
    required this.category,
    required this.kind,
    required this.citation,
    this.subLine,
  });

  /// The whole sentence, already localised: state, both numbers, the method.
  final String headline;

  /// Which signal set the surface spends.
  final VerdictCategory category;

  /// Which rule produced the headline.
  ///
  /// Beside [category] rather than folded into it, because four categories
  /// cannot hold six kinds and the surface must be able to tell a maximum from
  /// a minimum without re-reading the sentence.
  final FindingKind kind;

  /// The instrument the headline rests on.
  final CitationDisplay citation;

  /// The numeric margin, or `null` where a measurement does not apply.
  ///
  /// Null for [VerdictCategory.protected] and [VerdictCategory.closedSeason],
  /// and that is a rule rather than a coincidence: a measurement printed beside
  /// a prohibition implies a threshold that does not exist, and a reader who
  /// sees one goes looking for a bigger individual of a species that may never
  /// be taken.
  final String? subLine;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerdictStampDisplay &&
          other.headline == headline &&
          other.category == category &&
          other.kind == kind &&
          other.citation == citation &&
          other.subLine == subLine;

  @override
  int get hashCode => Object.hash(headline, category, kind, citation, subLine);
}

/// The serif note that stands where a stamp would, and never beside one.
@immutable
class NoteDisplay {
  /// A state in which nothing may be stamped.
  const NoteDisplay({required this.sentence, required this.kind, required this.citations});

  /// Already localised. Two sentences where the wording has two.
  final String sentence;

  /// Which of the four unstampable states this is.
  final NoteKind kind;

  /// What was searched, or what was read and found silent. Never empty.
  ///
  /// An absence stays cited: the fisher can say what was looked in, which is
  /// the difference between a gap in the reference and a claim about the law.
  final List<CitationDisplay> citations;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteDisplay &&
          other.sentence == sentence &&
          other.kind == kind &&
          listEquals(other.citations, citations);

  @override
  int get hashCode => Object.hash(sentence, kind, Object.hashAll(citations));
}

/// One of the conflicting rules, as a table of facts.
///
/// Facts rather than a sentence, and no ranking of any kind. Prose comparing
/// two instruments would have to put one first, and any ordering the app
/// imposed on a genuine legal conflict reads as a recommendation.
@immutable
class AmbiguousRuleDisplay {
  /// What this rule states, and where.
  const AmbiguousRuleDisplay({required this.facts, required this.citation});

  /// What the rule states, already localised and formatted.
  final List<RuleFact> facts;

  /// The instrument it comes from.
  final CitationDisplay citation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmbiguousRuleDisplay && listEquals(other.facts, facts) && other.citation == citation;

  @override
  int get hashCode => Object.hash(Object.hashAll(facts), citation);
}

/// Two or more instruments of equal standing disagree.
@immutable
class AmbiguityDisplay {
  /// States the disagreement, and lists both.
  const AmbiguityDisplay({required this.sentence, required this.rules});

  /// Already localised. It says that the instruments disagree and stops there.
  final String sentence;

  /// The conflicting rules, in the SOURCE order the engine handed down.
  ///
  /// Not re-sorted here or anywhere downstream. The engine ranks once; a second
  /// sort in the app is a second, untested opinion, and on this arm it would be
  /// the app choosing after the engine refused to.
  final List<AmbiguousRuleDisplay> rules;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmbiguityDisplay && other.sentence == sentence && listEquals(other.rules, rules);

  @override
  int get hashCode => Object.hash(sentence, Object.hashAll(rules));
}

/// The non-blocking bar that states the data passed its end date.
@immutable
class StaleDisplay {
  /// States the expiry, and nothing else.
  const StaleDisplay({required this.sentence});

  /// Already localised, and about the data rather than about the fish.
  final String sentence;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StaleDisplay && other.sentence == sentence;

  @override
  int get hashCode => sentence.hashCode;
}

/// Everything the result screen draws, in six languages, with no lookups left.
///
/// Exactly one of [stamp], [note] and [ambiguity] is non-null. The three are
/// separate fields rather than one sealed value because the surface reads them
/// independently — the disclaimer and the citations are drawn the same way
/// under all three — and because a fourth state added later must fail to
/// compile in the presenter rather than fall into a neighbour's branch.
@immutable
class ResultDisplay {
  /// One answer, fully localised.
  const ResultDisplay({
    required this.findings,
    required this.disclaimer,
    this.stamp,
    this.note,
    this.ambiguity,
    this.stale,
  });

  /// The stamp, or `null` where nothing may be stamped.
  final VerdictStampDisplay? stamp;

  /// The note that stands where a stamp would, or `null`.
  final NoteDisplay? note;

  /// The conflicting instruments, or `null`.
  final AmbiguityDisplay? ambiguity;

  /// Every finding, headline first, in the order the engine ranked them.
  ///
  /// Passes and open questions included. The stamp states one thing; the table
  /// states everything, so a closed-season stamp still carries the size rule
  /// beneath it and the fisher sees the whole picture without the stamp
  /// equivocating.
  final List<FindingDisplay> findings;

  /// Everything the stamp or the note does not already say.
  ///
  /// The first finding is the headline, and the headline is already on screen
  /// in the stamp — or, for an open question, in the note. Printing it twice
  /// reads as two separate rules biting.
  List<FindingDisplay> get secondary =>
      findings.isEmpty ? const <FindingDisplay>[] : findings.sublist(1);

  /// Present only when an instrument behind this answer had lapsed.
  ///
  /// A flag beside the findings and never a filter over them: an expired
  /// ruleset is still evaluated and still shown, so the numbers are all still
  /// here and the bar sits above them.
  final StaleDisplay? stale;

  /// The sentence that is always drawn and cannot be dismissed.
  final String disclaimer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultDisplay &&
          other.stamp == stamp &&
          other.note == note &&
          other.ambiguity == ambiguity &&
          listEquals(other.findings, findings) &&
          other.stale == stale &&
          other.disclaimer == disclaimer;

  @override
  int get hashCode =>
      Object.hash(stamp, note, ambiguity, Object.hashAll(findings), stale, disclaimer);
}
