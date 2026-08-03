/// Total `String` ↔ `enum` conversions for every `CHECK`ed column of
/// `SPEC.md` §7.1 and §7.2.
///
/// **Total, with an explicit unknown case.** A `values.byName(s)` throws on an
/// unrecognised string, and the string comes out of a file a content update
/// replaces wholesale — so the throw lands on a fisher's phone, at 05:40, on a
/// row that was written by a build of the pack this build has never seen. Each
/// codec instead returns the enum's own `unknown` member, and the caller decides
/// what to do with it.
///
/// `unknown` is never rendered as a verdict. It is what makes "we do not
/// recognise this value" a state the UI can carry, rather than an exception it
/// cannot.
library;

import 'package:rule_engine/rule_engine.dart' show MeasurementMethod;

/// `water_type` on `zone`, `rule` and `licence_type`.
enum WaterKind {
  /// The sea.
  salt('salt'),

  /// Rivers, reservoirs and lakes.
  fresh('fresh'),

  /// A property of a rule, never of a request.
  both('both'),

  /// A value this build does not recognise.
  unknown('');

  const WaterKind(this.sql);

  /// The spelling §7.1 stores.
  final String sql;
}

/// `catch.outcome`.
enum CatchOutcome {
  /// The fish meets every rule that fired.
  meets('meets'),

  /// At least one rule fired against it.
  fails('fails'),

  /// A rule fired and the answer needs a human — an ambiguity, or a
  /// measurement the record does not carry.
  attention('attention'),

  /// Nothing was recorded, which is **not** the same as permission.
  unknown('unknown');

  const CatchOutcome(this.sql);

  /// The spelling §7.2 stores.
  final String sql;
}

/// `user_profile.numeral_system`.
enum NumeralSystem {
  /// Defer to the locale. CLDR 48 gives `ar` Western digits, and that is the
  /// correct default for Khalid in RAK.
  auto('auto'),

  /// Western digits, always.
  latn('latn'),

  /// Arabic-Indic digits, always.
  arab('arab');

  const NumeralSystem(this.sql);

  /// The spelling §7.2 stores.
  final String sql;
}

/// `user_profile.length_unit`. Display only: everything is stored as integer
/// millimetres.
enum LengthUnit {
  /// Centimetres, the default everywhere.
  cm('cm'),

  /// Millimetres.
  mm('mm'),

  /// Inches. Default only for `en` with a US device region.
  inches('in');

  const LengthUnit(this.sql);

  /// The spelling §7.2 stores.
  final String sql;
}

/// `species_name.gender`.
enum NameGender {
  /// Masculine.
  m('m'),

  /// Feminine.
  f('f'),

  /// Neuter.
  n('n'),

  /// Absent, which is legal only in `en`.
  none('');

  const NameGender(this.sql);

  /// The spelling §7.1 stores.
  final String sql;
}

/// [WaterKind] for [sql], or [WaterKind.unknown].
WaterKind waterKindOf(String? sql) => _decode(WaterKind.values, sql, WaterKind.unknown);

/// [CatchOutcome] for [sql], or [CatchOutcome.unknown].
CatchOutcome catchOutcomeOf(String? sql) => _decode(CatchOutcome.values, sql, CatchOutcome.unknown);

/// [NumeralSystem] for [sql], or [NumeralSystem.auto].
///
/// The fallback is `auto` rather than an `unknown` member: the setting has a
/// correct default and a screen that cannot render numbers is worse than one
/// that renders them the way CLDR says.
NumeralSystem numeralSystemOf(String? sql) =>
    _decode(NumeralSystem.values, sql, NumeralSystem.auto);

/// [LengthUnit] for [sql], or [LengthUnit.cm].
LengthUnit lengthUnitOf(String? sql) => _decode(LengthUnit.values, sql, LengthUnit.cm);

/// [NameGender] for [sql], or [NameGender.none].
NameGender nameGenderOf(String? sql) => _decode(NameGender.values, sql, NameGender.none);

T _decode<T>(List<T> values, String? sql, T fallback) {
  if (sql == null) return fallback;
  for (final value in values) {
    if ((value as dynamic).sql == sql) return value;
  }
  return fallback;
}

/// `measurement_method.code` as the engine's enum.
///
/// **By CODE, never by id.** The content build assigns `measurement_method.id`
/// by insertion order, so a pack declaring one method gives it id 1 — and an
/// id-to-enum map reads id 1 as total length. A shell-length rule then states a
/// total-length threshold, which is `catchlaw-rule-engine` rule 12's failure
/// exactly: 65 cm fork length is roughly 71 cm total length, and the difference
/// is a fine. §7.1 makes `code` `UNIQUE` because it is the stable key.
///
/// This was live in two call sites and was caught by running the app against a
/// real pack, not by a test: every fixture in the suite happened to number its
/// methods the way the old map assumed.
///
/// Null rather than a fallback for an unrecognised code. The engine emits NO
/// size finding without a method, which is the safe direction — a size rule the
/// app cannot state the method for is a size rule it does not state.
MeasurementMethod? measurementMethodOfCode(String? code) =>
    code == null ? null : MeasurementMethod.fromCode(code);
