import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Citation;

/// One line of a jurisdiction's penalty ledger, exactly as the pack records it.
///
/// **Nothing here is computed and nothing here is defaulted.** A fine is a
/// legal fact: an amount the transcription does not carry stays `null` and the
/// screen says so, because a zero, a dash or a borrowed figure from a
/// neighbouring jurisdiction is an invented penalty — the worst sentence this
/// product could print.
///
/// [citation] is required and non-nullable (invariant 3). A penalty with no
/// instrument behind it is not a penalty this app has any business showing.
@immutable
class PenaltyTier {
  /// One `penalty` row, resolved into the reader's language.
  const PenaltyTier({
    required this.offence,
    required this.occurrence,
    required this.citation,
    this.amountMin,
    this.amountMax,
    this.currency,
    this.consequence,
  });

  /// What the instrument treats as the breach, through the §9.2 chain.
  final String offence;

  /// First, second or subsequent occurrence — the instrument's own scale.
  final int occurrence;

  /// The instrument, article, publication date and the date it was checked.
  final Citation citation;

  /// The lower bound of the fine, in the smallest whole unit the pack records.
  final int? amountMin;

  /// The upper bound, where the instrument states a band rather than a figure.
  final int? amountMax;

  /// The currency the instrument itself states.
  ///
  /// **Never converted.** An instrument states a figure in one currency, and a
  /// dirham amount rendered in euros is a number no inspector will recognise.
  final String? currency;

  /// The secondary consequence — a licence suspension, a revocation.
  final String? consequence;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenaltyTier &&
          other.offence == offence &&
          other.occurrence == occurrence &&
          other.amountMin == amountMin &&
          other.amountMax == amountMax &&
          other.currency == currency &&
          other.consequence == consequence;

  @override
  int get hashCode => Object.hash(offence, occurrence, amountMin, amountMax, currency, consequence);
}

/// What one jurisdiction's bundled pack records about the cost of a breach.
///
/// **An empty [tiers] is a real, positively-stated answer** and is not an
/// error: it means nothing was transcribed, which the screen says in those
/// words. It is never rendered as "there is no penalty", because the two are
/// different facts and merging them is how a reference tool starts giving
/// permission.
@immutable
class PenaltySchedule {
  /// The ledger for one jurisdiction.
  const PenaltySchedule({
    required this.jurisdictionName,
    required this.authority,
    required this.tiers,
  });

  /// The jurisdiction's own localised name.
  final String jurisdictionName;

  /// The authority named in the standing notice at the foot of the page.
  final String authority;

  /// Every recorded tier, by offence and then by occurrence.
  final List<PenaltyTier> tiers;

  /// The distinct offences the pack records a penalty against, each with the
  /// instrument that records it, in ledger order.
  ///
  /// Derived rather than stored: the offence list and the ledger are two views
  /// of one set of rows, and a second field would be a second source of truth
  /// about what the pack carries. The citation travels with the offence
  /// because naming an offence is a claim about the law, and invariant 3 does
  /// not stop applying because the claim is short.
  List<({String offence, Citation citation})> get offencesCited {
    final seen = <String>{};
    final offences = <({String offence, Citation citation})>[];
    for (final PenaltyTier tier in tiers) {
      if (seen.add(tier.offence)) {
        offences.add((offence: tier.offence, citation: tier.citation));
      }
    }
    return offences;
  }
}
