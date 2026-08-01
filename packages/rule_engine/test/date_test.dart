import 'package:rule_engine/rule_engine.dart';
import 'package:test/test.dart';

void main() {
  group('parseIsoDate', () {
    test('returns a UTC midnight date', () {
      // DateTime.parse('2026-07-30') returns LOCAL midnight. Every comparison
      // in the engine would then depend on the machine's timezone, and a rule
      // commencing today would be in force or not depending on which side of
      // the date line the phone is.
      final DateTime d = parseIsoDate('2026-07-30');
      expect(d.isUtc, isTrue);
      expect(d, DateTime.utc(2026, 7, 30));
    });

    test('rejects a value that is not a date', () {
      // A mapper defect, not a content defect: E05 must never hand the engine a
      // non-date. A silent fallback would date a rule to the epoch, which reads
      // as "in force since 1970" and is in force for everything.
      expect(() => parseIsoDate('not-a-date'), throwsFormatException);
    });

    test('rejects a date carrying a time component', () {
      // §7.1 stores dates. A time would make midnight comparisons ambiguous and
      // is a sign the mapper is passing something it did not read from the
      // schema.
      expect(() => parseIsoDate('2026-07-30T12:00:00Z'), throwsFormatException);
    });
  });
}
