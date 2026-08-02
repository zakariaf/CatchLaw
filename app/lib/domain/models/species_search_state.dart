import 'dart:collection';

import 'package:catchlaw/domain/models/species_facts.dart';
import 'package:catchlaw/domain/models/species_search_hit.dart';
import 'package:meta/meta.dart';

/// One species as S5 renders it: the hit, and what the rules say about it here.
///
/// **Not `SpeciesResultRow`,** and both halves of that name were wrong. `Row` is
/// drift's suffix, and `layering_test.dart` scans for it precisely so a view
/// model cannot end up holding a table's knowledge; a domain type wearing the
/// same suffix is indistinguishable from one that does. And `result` is a
/// banned domain word — CLAUDE.md keeps **verdict** and **finding** for what
/// this app produces, and reserves nothing for a list entry.
@immutable
class SpeciesListing {
  /// Pairs a hit with its facts.
  const SpeciesListing({required this.hit, required this.facts});

  /// The species and the name that matched.
  final SpeciesSearchHit hit;

  /// `null` when no rule in this pack reaches this species at all.
  ///
  /// **Not the same as "no limit in instrument".** A species with no rule row
  /// is a species nothing was transcribed for, and the row says so rather than
  /// implying permission — `SPEC.md`'s three states are kept apart here as
  /// everywhere.
  final SpeciesFacts? facts;

  @override
  bool operator ==(Object other) =>
      other is SpeciesListing && other.hit == hit && other.facts == facts;

  @override
  int get hashCode => Object.hash(hit, facts);
}

/// Everything S5 draws, in one immutable value.
@immutable
class SpeciesSearchState {
  /// Builds the state.
  SpeciesSearchState({
    required this.query,
    required List<SpeciesListing> inZone,
    required List<SpeciesListing> elsewhere,
    required this.jurisdictionSpeciesCount,
    required this.isPackExpired,
  }) : inZone = UnmodifiableListView<SpeciesListing>(inZone),
       elsewhere = UnmodifiableListView<SpeciesListing>(elsewhere);

  /// The empty state, before anything is typed.
  SpeciesSearchState.initial({this.jurisdictionSpeciesCount = 0, this.isPackExpired = false})
    : query = '',
      inZone = UnmodifiableListView<SpeciesListing>(const <SpeciesListing>[]),
      elsewhere = UnmodifiableListView<SpeciesListing>(const <SpeciesListing>[]);

  /// What the fisher typed, unfolded.
  final String query;

  /// **In your zone** — shown first, because it is the answer to the question
  /// actually being asked.
  final UnmodifiableListView<SpeciesListing> inZone;

  /// **Elsewhere in this jurisdiction** — shown second and never hidden: a
  /// fisher who has picked the wrong zone must be able to see that his fish
  /// exists, rather than being told it does not.
  final UnmodifiableListView<SpeciesListing> elsewhere;

  /// How many species the active jurisdiction carries.
  ///
  /// The empty state says the list covers this jurisdiction only, and that
  /// sentence is dishonest without a number behind it.
  final int jurisdictionSpeciesCount;

  /// Whether the pack's rules have passed their `valid_to`.
  ///
  /// A **flag**, never a filter. §7.3 step 1 is explicit that `valid_to` does
  /// not filter, and invariant 5 says a stale ruleset is still evaluated and
  /// still shown — behind a non-blocking ochre bar, which T03 draws.
  final bool isPackExpired;

  /// Whether anything at all matched.
  bool get isEmpty => inZone.isEmpty && elsewhere.isEmpty;
}
