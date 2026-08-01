/// How a length was taken, per `SPEC.md` §7.1's `measurement_method.code` list.
///
/// A measurement is only ever compared against a threshold expressed in the
/// SAME method: total length and fork length differ by 6-9 cm on a Kanaad, so
/// an inferred method turns a legal fish into a fine.
enum MeasurementMethod {
  /// `TL` — snout to the tip of the tail.
  totalLength('TL'),

  /// `FL` — snout to the fork of the tail.
  forkLength('FL'),

  /// `SL` — standard length.
  standardLength('SL'),

  /// `CW` — carapace width.
  carapaceWidth('CW'),

  /// `CL` — carapace length.
  carapaceLength('CL'),

  /// `ML` — mantle length.
  mantleLength('ML'),

  /// `DW` — disc width.
  discWidth('DW'),

  /// `SHL` — shell length.
  shellLength('SHL'),

  /// `CUSTOM` — a per-jurisdiction method (`SPEC.md` §4.2).
  ///
  /// Two jurisdictions' custom methods are equal under `==`, because §7.1 gives
  /// them one shared code. Comparing them is only sound after the candidate set
  /// has been filtered to a single jurisdiction, which stage 1 does. E04 is
  /// where a distinct code per jurisdiction would close it.
  custom('CUSTOM');

  const MeasurementMethod(this.code);

  /// The `measurement_method.code` this member round-trips through.
  final String code;

  /// The member for [code], or `null` if no member has it.
  ///
  /// Null rather than a throw: a content typo must reach the failure channel,
  /// not blow up inside a mapper.
  static MeasurementMethod? fromCode(String code) {
    for (final MeasurementMethod m in values) {
      if (m.code == code) return m;
    }
    return null;
  }
}
