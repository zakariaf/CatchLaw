import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/enums.dart';

/// A1 — every row satisfies the `SPEC.md` §7.1 constraint that governs it.
///
/// `SPEC.md` §8 bullet 1 names one build error: a rule with `min_size_mm` and no
/// `measurement_method_id`. The reason is that TL and FL differ by 6–9 cm on a
/// *Scomberomorus commerson*, so an inferred method turns a legal fish into a
/// fine and a fine into a false acquittal. The same argument covers every other
/// `CHECK` in §7.1, so A1 validates all of them.
///
/// **At load, not at insert.** SQLite would reject a bad `water_type` too —
/// after writing every earlier row, with `CHECK constraint failed: zone` and no
/// line number, and naming only the first offender. A1 collects every failure
/// and sorts them, so one build round-trip tells the author everything wrong
/// with the corpus.
final class RowSchemaAssertion implements Assertion {
  /// The A1 assertion. Stateless: the corpus is the argument.
  const RowSchemaAssertion();

  @override
  String get id => 'A1';

  @override
  Iterable<Failure> run(ContentSource source) sync* {
    final taxonGroups = <String, String?>{
      for (final YamlRow row in source.section('species')) row.id: row.string('taxon_group'),
    };

    for (final YamlRow row in source.rows) {
      // Set membership first, so a row with an unknown water_type does not also
      // report a spurious range error derived from it.
      yield* _enumMembership(row);
      yield* switch (row.section) {
        'rules' => _rule(row, taxonGroups),
        'closed_seasons' => _closedSeason(row),
        _ => const <Failure>[],
      };
    }
  }

  /// Every closed-set column, checked through the enum that owns it.
  Iterable<Failure> _enumMembership(YamlRow row) sync* {
    final Map<String, List<SqlEnum>>? columns = kEnumColumns[row.section];
    if (columns == null) return;
    for (final MapEntry<String, List<SqlEnum>> column in columns.entries) {
      final String? value = row.string(column.key);
      if (value == null || bySql(column.value, value) != null) continue;
      yield Failure(
        _id,
        row.path,
        row.line,
        "${column.key} '$value' is outside the §7.1 set (${legalSet(column.value)})",
      );
    }
  }

  Iterable<Failure> _rule(YamlRow row, Map<String, String?> taxonGroups) sync* {
    // The required-when matrix, mirroring build-assertions.md row for row. A
    // new trigger adds a line here rather than an `else if` somewhere.
    for (final MapEntry<String, Set<String>> rule in kRequiredWhen.entries) {
      if (!row.has(rule.key)) continue;
      for (final String required in rule.value) {
        if (!row.has(required)) {
          yield Failure(_id, row.path, row.line, '${rule.key} without $required');
        }
      }
    }

    final int? min = row.integer('min_size_mm');
    final int? max = row.integer('max_size_mm');
    final bool hasSize = min != null || max != null;

    if ((row.boolean('is_protected') ?? false) && hasSize) {
      // The precedence ladder headlines `protected`, so the threshold would
      // never be read — and a measurement implies a limit that does not exist.
      yield Failure(_id, row.path, row.line, 'a protected row carries a size threshold');
    }

    if (min != null && max != null && max < min) {
      yield Failure(_id, row.path, row.line, 'max_size_mm $max is below min_size_mm $min');
    }

    final String? from = row.string('valid_from');
    final String? to = row.string('valid_to');
    if (from != null && to != null && to.compareTo(from) < 0) {
      // ISO-8601 dates sort lexicographically, which is the whole reason §7.1
      // stores them as TEXT.
      yield Failure(_id, row.path, row.line, 'valid_from $from is after valid_to $to');
    }

    // The taxon-scoped range check last: it needs the species join.
    if (min != null &&
        min < kMinimumFinfishSizeMm &&
        taxonGroups[row.string('species_id')] == TaxonGroup.finfish.sql &&
        !(row.boolean(kSizeConfirmedField) ?? false)) {
      yield Failure(
        _id,
        row.path,
        row.line,
        'min_size_mm $min is under $kMinimumFinfishSizeMm on a finfish — '
        'centimetres authored as millimetres? Clear it with $kSizeConfirmedField',
      );
    }
  }

  Iterable<Failure> _closedSeason(YamlRow row) sync* {
    if (!row.has('recurrence')) {
      // The recurrence decides WHICH pair of columns §7.1 requires, so a row
      // without one cannot be checked further — and reporting four missing
      // bounds nobody could have known to author would bury the real defect.
      // §7.1 has it `NOT NULL`; without this the emitter reports
      // `NOT NULL constraint failed: closed_season.recurrence` and no line.
      yield Failure(_id, row.path, row.line, 'a closed_season without recurrence');
      return;
    }

    final Recurrence? recurrence = bySql(Recurrence.values, row.string('recurrence') ?? '');
    if (recurrence == null) return; // the value is wrong, and _enumMembership said so

    switch (recurrence) {
      case Recurrence.annual:
        const bounds = <String>['start_month', 'start_day', 'end_month', 'end_day'];
        final List<String> missing = bounds.where((String b) => !row.has(b)).toList();
        if (missing.isNotEmpty) {
          // A closure with no window applies for zero days or for ever.
          yield Failure(_id, row.path, row.line, 'an annual closure without ${missing.join(', ')}');
          return;
        }
        yield* _annualBounds(row);
      case Recurrence.fixed:
        const bounds = <String>['start_date', 'end_date'];
        final List<String> missing = bounds.where((String b) => !row.has(b)).toList();
        if (missing.isNotEmpty) {
          yield Failure(_id, row.path, row.line, 'a fixed closure without ${missing.join(', ')}');
          return;
        }
        final String start = row.string('start_date')!;
        final String end = row.string('end_date')!;
        if (end.compareTo(start) < 0) {
          yield Failure(_id, row.path, row.line, 'a fixed closure ending $end before it starts');
        }
    }
  }

  Iterable<Failure> _annualBounds(YamlRow row) sync* {
    final int startMonth = row.integer('start_month')!;
    final int startDay = row.integer('start_day')!;
    final int endMonth = row.integer('end_month')!;
    final int endDay = row.integer('end_day')!;

    // Three years in four there is no such date, and the engine would have to
    // invent 02-28 or 03-01 — either of which adds or removes a day of closure
    // no instrument declared. Written twice rather than looped over the two
    // bounds: a loop over a two-element literal carries an exit branch that
    // cannot be taken, and an assertion with an unreachable branch in it is an
    // assertion nobody can prove is exercised.
    if (startMonth == 2 && startDay == 29) yield _leapDayBound(row, 'start_day');
    if (endMonth == 2 && endDay == 29) yield _leapDayBound(row, 'end_day');

    final bool inverted = endMonth < startMonth || (endMonth == startMonth && endDay < startDay);
    if (inverted && !(row.boolean('wraps_year') ?? false)) {
      // A wrapping closure is legal and an inverted one is a typo, and the two
      // look identical. Declared, never inferred.
      yield Failure(
        _id,
        row.path,
        row.line,
        'an annual closure ending before it starts without wraps_year',
      );
    }
  }

  Failure _leapDayBound(YamlRow row, String bound) =>
      Failure(_id, row.path, row.line, '$bound 29 in February — author 02-28 or 03-01');

  static const String _id = 'A1';
}

/// Every closed-set column, by the section that carries it.
///
/// A table rather than a chain of `if`s: `build-assertions.md` publishes the
/// constraints as a table, and a new section adds a row here rather than a
/// branch somewhere.
const Map<String, Map<String, List<SqlEnum>>> kEnumColumns = <String, Map<String, List<SqlEnum>>>{
  'rules': <String, List<SqlEnum>>{
    'water_type': WaterType.values,
    'bag_limit_unit': LimitUnit.values,
    'bag_limit_period': LimitPeriod.values,
    'measurement_method_id': MeasurementCode.values,
  },
  'zones': <String, List<SqlEnum>>{'water_type': WaterType.values, 'zone_kind': ZoneKind.values},
  'species': <String, List<SqlEnum>>{'taxon_group': TaxonGroup.values},
  'key_nodes': <String, List<SqlEnum>>{'taxon_group': TaxonGroup.values},
  'species_names': <String, List<SqlEnum>>{'gender': Gender.values},
  'closed_seasons': <String, List<SqlEnum>>{'recurrence': Recurrence.values},
  'licence_types': <String, List<SqlEnum>>{'water_type': WaterType.values},
  'measurement_methods': <String, List<SqlEnum>>{'code': MeasurementCode.values},
};

/// `build-assertions.md` "A1 — the required-when matrix": a field is not
/// optional, it is required conditionally, and the condition is checked.
const Map<String, Set<String>> kRequiredWhen = <String, Set<String>>{
  // TL and FL differ by 6–9 cm on a Kanaad.
  'min_size_mm': <String>{'measurement_method_id'},
  'max_size_mm': <String>{'measurement_method_id'},
  // "5" per what, and over what period?
  'bag_limit': <String>{'bag_limit_unit', 'bag_limit_period'},
};

/// A finfish `min_size_mm` below this is flagged as centimetres authored as
/// millimetres. `build-assertions.md` "Edge cases already caught".
const int kMinimumFinfishSizeMm = 100;

/// The audited escape for a genuine sub-100 mm finfish threshold.
///
/// It keeps the check fatal — `catchlaw-content-pipeline` rule 2 has no warning
/// tier to put it in — while leaving a trail in the diff. Without it the check
/// would eventually be deleted rather than answered.
const String kSizeConfirmedField = 'min_size_mm_confirmed';
