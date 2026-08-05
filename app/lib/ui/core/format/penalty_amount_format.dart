import 'package:intl/intl.dart';

/// The three localised patterns a recorded fine can be printed with.
///
/// Passed in rather than looked up, so this function needs no `BuildContext`
/// and its rows run with no pump. The currency and the figure are separate
/// arguments because the two go on different sides of the line in different
/// languages — `AED 3,000` in English, `3.000 AED` in Galician.
typedef PenaltyAmountPatterns = ({
  String Function(String currency, String amount) amount,
  String Function(String currency, String lower, String upper) range,
  String notRecorded,
});

/// The fine the pack records, printed.
///
/// **Nothing is inferred and nothing is converted.** A row with no figure
/// prints [PenaltyAmountPatterns.notRecorded] rather than a zero, a dash or the
/// figure from the row above it: an invented fine is the worst sentence this
/// product could print, and a plausible-looking one is worse than an obvious
/// one. The currency is the instrument's own — a dirham amount rendered in
/// euros is a number no inspector will recognise.
///
/// A band is printed with **both** its bounds. Quoting only the lower one reads
/// as a flat fine, which is a different legal fact.
String formatPenaltyAmount({
  required int? amountMin,
  required int? amountMax,
  required String? currency,
  required NumberFormat numbers,
  required PenaltyAmountPatterns patterns,
}) {
  final lower = amountMin;
  final upper = amountMax;
  if (lower == null && upper == null) return patterns.notRecorded;

  // Trimmed, because a pack that records a figure and no currency still has a
  // figure worth printing, and the pattern leaves a space where the code would
  // have gone.
  final String unit = currency ?? '';
  if (lower != null && upper != null && lower != upper) {
    return patterns.range(unit, numbers.format(lower), numbers.format(upper)).trim();
  }
  return patterns.amount(unit, numbers.format(lower ?? upper!)).trim();
}
