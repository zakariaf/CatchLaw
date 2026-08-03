import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:rule_engine/rule_engine.dart' show parseIsoDate;

/// A12 — every authored date is one a human could have established.
///
/// **A4 holds the citation pair and nothing else held the rest.** `retrieved_on`
/// must parse, must not precede `published_on` and must not follow the build
/// date — all three checked since E04/T05. Every other authored date had no
/// check at all, and the corpus shipped proving it: `jurisdiction.checked_on:
/// '2026-08-12'` against an 2026-08-03 build, a claim that a human read the Orde
/// nine days from now.
///
/// **That field is not decorative.** `checked_on` is what the Check screen
/// prints under the place — "checked 2026-08-12" — and it is the fisher's only
/// handle on whether the rule book is current. A future value says the book was
/// verified more recently than it can have been, which is the one direction the
/// error must never point: it reads as fresher than it is, and the whole purpose
/// of showing the date is to let him distrust a stale one.
///
/// **Two classes of date, deliberately treated differently.** A date recording a
/// HUMAN ACT — checked, changed, published — cannot be in the future, because
/// the act has not happened. A date stating an INSTRUMENT'S REACH —
/// `valid_from`, `valid_to` — routinely is: a closure authored in July that
/// bites in September is correct data, and refusing it would leave the corpus
/// unable to state a season before it starts. So the future check applies to the
/// first class only, and the second gets format and ordering instead.
///
/// **Absence is A1's problem.** A missing field is a schema violation and is
/// reported there; firing here as well would double the failure list without
/// adding a fact.
final class AuthoredDateAssertion implements Assertion {
  /// The A12 assertion.
  const AuthoredDateAssertion();

  @override
  String get id => 'A12';

  /// Fields recording a human act, which therefore cannot be in the future.
  ///
  /// `(section, field)`. `citations` is absent on purpose: A4 owns that pair,
  /// and two assertions on one field means two failures for one typo.
  static const List<(String, String)> humanActs = <(String, String)>[
    ('jurisdiction', 'published_on'),
    ('jurisdiction', 'checked_on'),
    ('changes', 'changed_on'),
  ];

  /// Fields naming an instrument's reach, which may legitimately be ahead of the
  /// build. Checked for format and order only.
  static const List<(String, String)> windows = <(String, String)>[
    ('rules', 'valid_from'),
    ('rules', 'valid_to'),
  ];

  /// Pairs that must be in order: the second may not precede the first.
  static const List<(String, String, String)> orderedPairs = <(String, String, String)>[
    ('jurisdiction', 'published_on', 'checked_on'),
    ('rules', 'valid_from', 'valid_to'),
  ];

  @override
  Iterable<Failure> run(ContentSource source) sync* {
    for (final (String section, String field) in <(String, String)>[...humanActs, ...windows]) {
      for (final YamlRow row in source.section(section)) {
        yield* _wellFormed(row, section, field);
      }
    }

    for (final (String section, String field) in humanActs) {
      for (final YamlRow row in source.section(section)) {
        yield* _notAfterBuild(row, field, source.buildDate);
      }
    }

    for (final (String section, String first, String second) in orderedPairs) {
      for (final YamlRow row in source.section(section)) {
        yield* _ordered(row, first, second);
      }
    }
  }

  Iterable<Failure> _wellFormed(YamlRow row, String section, String field) sync* {
    final String? raw = row.string(field);
    if (raw == null) return; // A1 owns presence.
    if (_parse(raw) != null) return;

    // '27/07/2012' is the format the DOG prints, and therefore the format an
    // author copies. Parsed as ISO it is not a date at all, and every later
    // check on it silently passes because there is nothing to compare.
    yield Failure(id, row.path, row.line, "$section $field '$raw' is not an ISO date");
  }

  Iterable<Failure> _notAfterBuild(YamlRow row, String field, DateTime? buildDate) sync* {
    if (buildDate == null) return;
    final DateTime? date = _date(row, field);
    if (date == null || !date.isAfter(buildDate)) return;

    yield Failure(
      id,
      row.path,
      row.line,
      "$field '${row.string(field)}' is after the build date ${_iso(buildDate)} — "
      'no human can have done this yet',
    );
  }

  Iterable<Failure> _ordered(YamlRow row, String first, String second) sync* {
    final DateTime? a = _date(row, first);
    final DateTime? b = _date(row, second);
    if (a == null || b == null || !b.isBefore(a)) return;

    yield Failure(
      id,
      row.path,
      row.line,
      "$second '${row.string(second)}' precedes $first '${row.string(first)}'",
    );
  }

  DateTime? _date(YamlRow row, String field) {
    final String? raw = row.string(field);
    return raw == null ? null : _parse(raw);
  }

  /// [raw] as a date, or null when it is not one.
  ///
  /// `parseIsoDate` THROWS on a malformed value rather than returning null, so
  /// an unguarded call turns the one failure this assertion exists to report
  /// into an uncaught FormatException — which kills the whole build with a stack
  /// trace instead of `A12 jurisdiction.yaml:31 …`, and tells the author
  /// nothing about which of thirty dates is wrong.
  DateTime? _parse(String raw) {
    try {
      return parseIsoDate(raw);
    } on FormatException {
      return null;
    }
  }

  String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
