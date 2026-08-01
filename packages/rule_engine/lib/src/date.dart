/// The one place an ISO-8601 date string becomes a [DateTime] in this package.
///
/// Always UTC midnight. `DateTime.parse('2026-07-30')` returns LOCAL midnight,
/// which would make every comparison in the engine depend on the machine's
/// timezone: a rule commencing today would be in force or not according to
/// which side of the date line the phone is on.
///
/// Throws a [FormatException] rather than falling back. A silent fallback dates
/// the rule to the epoch, which reads as "in force since 1970" and is therefore
/// in force for everything. E05's mapper handing the engine a non-date is a
/// mapper defect, not a content defect, so it does not travel through the
/// `Result` channel — nothing downstream could act on it.
DateTime parseIsoDate(String value) {
  final RegExpMatch? m = _isoDate.firstMatch(value);
  if (m == null) {
    throw FormatException('expected an ISO-8601 date with no time component', value);
  }
  final int year = int.parse(m.group(1)!);
  final int month = int.parse(m.group(2)!);
  final int day = int.parse(m.group(3)!);
  final parsed = DateTime.utc(year, month, day);
  // DateTime.utc rolls a bad day over into the next month rather than
  // rejecting it, so 2026-02-30 becomes 2 March. Comparing back is what makes
  // that a FormatException instead of a rule that quietly commences two days
  // late.
  if (parsed.year != year || parsed.month != month || parsed.day != day) {
    throw FormatException('not a real calendar date', value);
  }
  return parsed;
}

final RegExp _isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
