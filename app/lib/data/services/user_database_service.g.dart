// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_database_service.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL CHECK (id = 1)',
  );
  static const VerificationMeta _localeOverrideMeta = const VerificationMeta('localeOverride');
  @override
  late final GeneratedColumn<String> localeOverride = GeneratedColumn<String>(
    'locale_override',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numeralSystemMeta = const VerificationMeta('numeralSystem');
  @override
  late final GeneratedColumn<String> numeralSystem = GeneratedColumn<String>(
    'numeral_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NOT NULL DEFAULT \'auto\' CHECK (numeral_system IN (\'auto\',\'latn\',\'arab\'))',
    defaultValue: const CustomExpression('\'auto\''),
  );
  static const VerificationMeta _lengthUnitMeta = const VerificationMeta('lengthUnit');
  @override
  late final GeneratedColumn<String> lengthUnit = GeneratedColumn<String>(
    'length_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'cm\' CHECK (length_unit IN (\'cm\',\'mm\',\'in\'))',
    defaultValue: const CustomExpression('\'cm\''),
  );
  static const VerificationMeta _activeJurisdictionMeta = const VerificationMeta(
    'activeJurisdiction',
  );
  @override
  late final GeneratedColumn<String> activeJurisdiction = GeneratedColumn<String>(
    'active_jurisdiction',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeZoneCodeMeta = const VerificationMeta('activeZoneCode');
  @override
  late final GeneratedColumn<String> activeZoneCode = GeneratedColumn<String>(
    'active_zone_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rulerPxPerMmMeta = const VerificationMeta('rulerPxPerMm');
  @override
  late final GeneratedColumn<double> rulerPxPerMm = GeneratedColumn<double>(
    'ruler_px_per_mm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rulerCalibratedAtMeta = const VerificationMeta(
    'rulerCalibratedAt',
  );
  @override
  late final GeneratedColumn<String> rulerCalibratedAt = GeneratedColumn<String>(
    'ruler_calibrated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captureCoordinatesMeta = const VerificationMeta(
    'captureCoordinates',
  );
  @override
  late final GeneratedColumn<bool> captureCoordinates = GeneratedColumn<bool>(
    'capture_coordinates',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _sunlightModeMeta = const VerificationMeta('sunlightMode');
  @override
  late final GeneratedColumn<bool> sunlightMode = GeneratedColumn<bool>(
    'sunlight_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _gloveModeMeta = const VerificationMeta('gloveMode');
  @override
  late final GeneratedColumn<bool> gloveMode = GeneratedColumn<bool>(
    'glove_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    localeOverride,
    numeralSystem,
    lengthUnit,
    activeJurisdiction,
    activeZoneCode,
    rulerPxPerMm,
    rulerCalibratedAt,
    captureCoordinates,
    sunlightMode,
    gloveMode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('locale_override')) {
      context.handle(
        _localeOverrideMeta,
        localeOverride.isAcceptableOrUnknown(data['locale_override']!, _localeOverrideMeta),
      );
    }
    if (data.containsKey('numeral_system')) {
      context.handle(
        _numeralSystemMeta,
        numeralSystem.isAcceptableOrUnknown(data['numeral_system']!, _numeralSystemMeta),
      );
    }
    if (data.containsKey('length_unit')) {
      context.handle(
        _lengthUnitMeta,
        lengthUnit.isAcceptableOrUnknown(data['length_unit']!, _lengthUnitMeta),
      );
    }
    if (data.containsKey('active_jurisdiction')) {
      context.handle(
        _activeJurisdictionMeta,
        activeJurisdiction.isAcceptableOrUnknown(
          data['active_jurisdiction']!,
          _activeJurisdictionMeta,
        ),
      );
    }
    if (data.containsKey('active_zone_code')) {
      context.handle(
        _activeZoneCodeMeta,
        activeZoneCode.isAcceptableOrUnknown(data['active_zone_code']!, _activeZoneCodeMeta),
      );
    }
    if (data.containsKey('ruler_px_per_mm')) {
      context.handle(
        _rulerPxPerMmMeta,
        rulerPxPerMm.isAcceptableOrUnknown(data['ruler_px_per_mm']!, _rulerPxPerMmMeta),
      );
    }
    if (data.containsKey('ruler_calibrated_at')) {
      context.handle(
        _rulerCalibratedAtMeta,
        rulerCalibratedAt.isAcceptableOrUnknown(
          data['ruler_calibrated_at']!,
          _rulerCalibratedAtMeta,
        ),
      );
    }
    if (data.containsKey('capture_coordinates')) {
      context.handle(
        _captureCoordinatesMeta,
        captureCoordinates.isAcceptableOrUnknown(
          data['capture_coordinates']!,
          _captureCoordinatesMeta,
        ),
      );
    }
    if (data.containsKey('sunlight_mode')) {
      context.handle(
        _sunlightModeMeta,
        sunlightMode.isAcceptableOrUnknown(data['sunlight_mode']!, _sunlightModeMeta),
      );
    }
    if (data.containsKey('glove_mode')) {
      context.handle(
        _gloveModeMeta,
        gloveMode.isAcceptableOrUnknown(data['glove_mode']!, _gloveModeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      localeOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_override'],
      ),
      numeralSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}numeral_system'],
      )!,
      lengthUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}length_unit'],
      )!,
      activeJurisdiction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_jurisdiction'],
      ),
      activeZoneCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_zone_code'],
      ),
      rulerPxPerMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ruler_px_per_mm'],
      ),
      rulerCalibratedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruler_calibrated_at'],
      ),
      captureCoordinates: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}capture_coordinates'],
      )!,
      sunlightMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sunlight_mode'],
      )!,
      gloveMode: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}glove_mode'],
      )!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final int id;

  /// One of D-3's six locale tags. Never `ur`, never bare `pt`.
  final String? localeOverride;

  /// `auto`, `latn` or `arab`. Implemented by swapping `numberFormatSymbols`
  /// at bootstrap, not by a locale extension — `intl` accepts `-u-nu-` as a
  /// string and silently discards it (§9.3).
  final String numeralSystem;

  /// The **unit a length is displayed in**, not a length. `SPEC.md` §7.2 types
  /// it `TEXT` because it holds `cm`, `mm` or `in`; every length in this
  /// database is an integer millimetre count, and conversion is display-only.
  ///
  /// `check_measurement.sh` matches the identifier `length` against a `String`
  /// column and cannot tell a unit code from a measurement, so the declaration
  /// carries the gate's one documented hatch.
  final String lengthUnit;

  /// The jurisdiction code, not an id: `reference.db` is a separate file and a
  /// content update renumbers it.
  final String? activeJurisdiction;

  /// The zone code, for the same reason.
  final String? activeZoneCode;

  /// The calibration S4 measured. `null` until the fisher has calibrated, and
  /// manual entry works before that (E09).
  final double? rulerPxPerMm;

  /// When they calibrated. A stale calibration is shown, never silently reused.
  final String? rulerCalibratedAt;

  /// Opt-in. A catch carries no coordinates unless this is set.
  final bool captureCoordinates;

  /// The §4.9 high-contrast lane.
  final bool sunlightMode;

  /// The §4.9 larger-target lane.
  final bool gloveMode;
  const UserProfileRow({
    required this.id,
    this.localeOverride,
    required this.numeralSystem,
    required this.lengthUnit,
    this.activeJurisdiction,
    this.activeZoneCode,
    this.rulerPxPerMm,
    this.rulerCalibratedAt,
    required this.captureCoordinates,
    required this.sunlightMode,
    required this.gloveMode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || localeOverride != null) {
      map['locale_override'] = Variable<String>(localeOverride);
    }
    map['numeral_system'] = Variable<String>(numeralSystem);
    map['length_unit'] = Variable<String>(lengthUnit);
    if (!nullToAbsent || activeJurisdiction != null) {
      map['active_jurisdiction'] = Variable<String>(activeJurisdiction);
    }
    if (!nullToAbsent || activeZoneCode != null) {
      map['active_zone_code'] = Variable<String>(activeZoneCode);
    }
    if (!nullToAbsent || rulerPxPerMm != null) {
      map['ruler_px_per_mm'] = Variable<double>(rulerPxPerMm);
    }
    if (!nullToAbsent || rulerCalibratedAt != null) {
      map['ruler_calibrated_at'] = Variable<String>(rulerCalibratedAt);
    }
    map['capture_coordinates'] = Variable<bool>(captureCoordinates);
    map['sunlight_mode'] = Variable<bool>(sunlightMode);
    map['glove_mode'] = Variable<bool>(gloveMode);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      localeOverride: localeOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(localeOverride),
      numeralSystem: Value(numeralSystem),
      lengthUnit: Value(lengthUnit),
      activeJurisdiction: activeJurisdiction == null && nullToAbsent
          ? const Value.absent()
          : Value(activeJurisdiction),
      activeZoneCode: activeZoneCode == null && nullToAbsent
          ? const Value.absent()
          : Value(activeZoneCode),
      rulerPxPerMm: rulerPxPerMm == null && nullToAbsent
          ? const Value.absent()
          : Value(rulerPxPerMm),
      rulerCalibratedAt: rulerCalibratedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(rulerCalibratedAt),
      captureCoordinates: Value(captureCoordinates),
      sunlightMode: Value(sunlightMode),
      gloveMode: Value(gloveMode),
    );
  }

  factory UserProfileRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<int>(json['id']),
      localeOverride: serializer.fromJson<String?>(json['localeOverride']),
      numeralSystem: serializer.fromJson<String>(json['numeralSystem']),
      lengthUnit: serializer.fromJson<String>(json['lengthUnit']),
      activeJurisdiction: serializer.fromJson<String?>(json['activeJurisdiction']),
      activeZoneCode: serializer.fromJson<String?>(json['activeZoneCode']),
      rulerPxPerMm: serializer.fromJson<double?>(json['rulerPxPerMm']),
      rulerCalibratedAt: serializer.fromJson<String?>(json['rulerCalibratedAt']),
      captureCoordinates: serializer.fromJson<bool>(json['captureCoordinates']),
      sunlightMode: serializer.fromJson<bool>(json['sunlightMode']),
      gloveMode: serializer.fromJson<bool>(json['gloveMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'localeOverride': serializer.toJson<String?>(localeOverride),
      'numeralSystem': serializer.toJson<String>(numeralSystem),
      'lengthUnit': serializer.toJson<String>(lengthUnit),
      'activeJurisdiction': serializer.toJson<String?>(activeJurisdiction),
      'activeZoneCode': serializer.toJson<String?>(activeZoneCode),
      'rulerPxPerMm': serializer.toJson<double?>(rulerPxPerMm),
      'rulerCalibratedAt': serializer.toJson<String?>(rulerCalibratedAt),
      'captureCoordinates': serializer.toJson<bool>(captureCoordinates),
      'sunlightMode': serializer.toJson<bool>(sunlightMode),
      'gloveMode': serializer.toJson<bool>(gloveMode),
    };
  }

  UserProfileRow copyWith({
    int? id,
    Value<String?> localeOverride = const Value.absent(),
    String? numeralSystem,
    String? lengthUnit,
    Value<String?> activeJurisdiction = const Value.absent(),
    Value<String?> activeZoneCode = const Value.absent(),
    Value<double?> rulerPxPerMm = const Value.absent(),
    Value<String?> rulerCalibratedAt = const Value.absent(),
    bool? captureCoordinates,
    bool? sunlightMode,
    bool? gloveMode,
  }) => UserProfileRow(
    id: id ?? this.id,
    localeOverride: localeOverride.present ? localeOverride.value : this.localeOverride,
    numeralSystem: numeralSystem ?? this.numeralSystem,
    lengthUnit: lengthUnit ?? this.lengthUnit,
    activeJurisdiction: activeJurisdiction.present
        ? activeJurisdiction.value
        : this.activeJurisdiction,
    activeZoneCode: activeZoneCode.present ? activeZoneCode.value : this.activeZoneCode,
    rulerPxPerMm: rulerPxPerMm.present ? rulerPxPerMm.value : this.rulerPxPerMm,
    rulerCalibratedAt: rulerCalibratedAt.present ? rulerCalibratedAt.value : this.rulerCalibratedAt,
    captureCoordinates: captureCoordinates ?? this.captureCoordinates,
    sunlightMode: sunlightMode ?? this.sunlightMode,
    gloveMode: gloveMode ?? this.gloveMode,
  );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      localeOverride: data.localeOverride.present ? data.localeOverride.value : this.localeOverride,
      numeralSystem: data.numeralSystem.present ? data.numeralSystem.value : this.numeralSystem,
      lengthUnit: data.lengthUnit.present ? data.lengthUnit.value : this.lengthUnit,
      activeJurisdiction: data.activeJurisdiction.present
          ? data.activeJurisdiction.value
          : this.activeJurisdiction,
      activeZoneCode: data.activeZoneCode.present ? data.activeZoneCode.value : this.activeZoneCode,
      rulerPxPerMm: data.rulerPxPerMm.present ? data.rulerPxPerMm.value : this.rulerPxPerMm,
      rulerCalibratedAt: data.rulerCalibratedAt.present
          ? data.rulerCalibratedAt.value
          : this.rulerCalibratedAt,
      captureCoordinates: data.captureCoordinates.present
          ? data.captureCoordinates.value
          : this.captureCoordinates,
      sunlightMode: data.sunlightMode.present ? data.sunlightMode.value : this.sunlightMode,
      gloveMode: data.gloveMode.present ? data.gloveMode.value : this.gloveMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('localeOverride: $localeOverride, ')
          ..write('numeralSystem: $numeralSystem, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('activeJurisdiction: $activeJurisdiction, ')
          ..write('activeZoneCode: $activeZoneCode, ')
          ..write('rulerPxPerMm: $rulerPxPerMm, ')
          ..write('rulerCalibratedAt: $rulerCalibratedAt, ')
          ..write('captureCoordinates: $captureCoordinates, ')
          ..write('sunlightMode: $sunlightMode, ')
          ..write('gloveMode: $gloveMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    localeOverride,
    numeralSystem,
    lengthUnit,
    activeJurisdiction,
    activeZoneCode,
    rulerPxPerMm,
    rulerCalibratedAt,
    captureCoordinates,
    sunlightMode,
    gloveMode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.localeOverride == this.localeOverride &&
          other.numeralSystem == this.numeralSystem &&
          other.lengthUnit == this.lengthUnit &&
          other.activeJurisdiction == this.activeJurisdiction &&
          other.activeZoneCode == this.activeZoneCode &&
          other.rulerPxPerMm == this.rulerPxPerMm &&
          other.rulerCalibratedAt == this.rulerCalibratedAt &&
          other.captureCoordinates == this.captureCoordinates &&
          other.sunlightMode == this.sunlightMode &&
          other.gloveMode == this.gloveMode);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<int> id;
  final Value<String?> localeOverride;
  final Value<String> numeralSystem;
  final Value<String> lengthUnit;
  final Value<String?> activeJurisdiction;
  final Value<String?> activeZoneCode;
  final Value<double?> rulerPxPerMm;
  final Value<String?> rulerCalibratedAt;
  final Value<bool> captureCoordinates;
  final Value<bool> sunlightMode;
  final Value<bool> gloveMode;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.localeOverride = const Value.absent(),
    this.numeralSystem = const Value.absent(),
    this.lengthUnit = const Value.absent(),
    this.activeJurisdiction = const Value.absent(),
    this.activeZoneCode = const Value.absent(),
    this.rulerPxPerMm = const Value.absent(),
    this.rulerCalibratedAt = const Value.absent(),
    this.captureCoordinates = const Value.absent(),
    this.sunlightMode = const Value.absent(),
    this.gloveMode = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    this.id = const Value.absent(),
    this.localeOverride = const Value.absent(),
    this.numeralSystem = const Value.absent(),
    this.lengthUnit = const Value.absent(),
    this.activeJurisdiction = const Value.absent(),
    this.activeZoneCode = const Value.absent(),
    this.rulerPxPerMm = const Value.absent(),
    this.rulerCalibratedAt = const Value.absent(),
    this.captureCoordinates = const Value.absent(),
    this.sunlightMode = const Value.absent(),
    this.gloveMode = const Value.absent(),
  });
  static Insertable<UserProfileRow> custom({
    Expression<int>? id,
    Expression<String>? localeOverride,
    Expression<String>? numeralSystem,
    Expression<String>? lengthUnit,
    Expression<String>? activeJurisdiction,
    Expression<String>? activeZoneCode,
    Expression<double>? rulerPxPerMm,
    Expression<String>? rulerCalibratedAt,
    Expression<bool>? captureCoordinates,
    Expression<bool>? sunlightMode,
    Expression<bool>? gloveMode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localeOverride != null) 'locale_override': localeOverride,
      if (numeralSystem != null) 'numeral_system': numeralSystem,
      if (lengthUnit != null) 'length_unit': lengthUnit,
      if (activeJurisdiction != null) 'active_jurisdiction': activeJurisdiction,
      if (activeZoneCode != null) 'active_zone_code': activeZoneCode,
      if (rulerPxPerMm != null) 'ruler_px_per_mm': rulerPxPerMm,
      if (rulerCalibratedAt != null) 'ruler_calibrated_at': rulerCalibratedAt,
      if (captureCoordinates != null) 'capture_coordinates': captureCoordinates,
      if (sunlightMode != null) 'sunlight_mode': sunlightMode,
      if (gloveMode != null) 'glove_mode': gloveMode,
    });
  }

  UserProfilesCompanion copyWith({
    Value<int>? id,
    Value<String?>? localeOverride,
    Value<String>? numeralSystem,
    Value<String>? lengthUnit,
    Value<String?>? activeJurisdiction,
    Value<String?>? activeZoneCode,
    Value<double?>? rulerPxPerMm,
    Value<String?>? rulerCalibratedAt,
    Value<bool>? captureCoordinates,
    Value<bool>? sunlightMode,
    Value<bool>? gloveMode,
  }) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      localeOverride: localeOverride ?? this.localeOverride,
      numeralSystem: numeralSystem ?? this.numeralSystem,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      activeJurisdiction: activeJurisdiction ?? this.activeJurisdiction,
      activeZoneCode: activeZoneCode ?? this.activeZoneCode,
      rulerPxPerMm: rulerPxPerMm ?? this.rulerPxPerMm,
      rulerCalibratedAt: rulerCalibratedAt ?? this.rulerCalibratedAt,
      captureCoordinates: captureCoordinates ?? this.captureCoordinates,
      sunlightMode: sunlightMode ?? this.sunlightMode,
      gloveMode: gloveMode ?? this.gloveMode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localeOverride.present) {
      map['locale_override'] = Variable<String>(localeOverride.value);
    }
    if (numeralSystem.present) {
      map['numeral_system'] = Variable<String>(numeralSystem.value);
    }
    if (lengthUnit.present) {
      map['length_unit'] = Variable<String>(lengthUnit.value);
    }
    if (activeJurisdiction.present) {
      map['active_jurisdiction'] = Variable<String>(activeJurisdiction.value);
    }
    if (activeZoneCode.present) {
      map['active_zone_code'] = Variable<String>(activeZoneCode.value);
    }
    if (rulerPxPerMm.present) {
      map['ruler_px_per_mm'] = Variable<double>(rulerPxPerMm.value);
    }
    if (rulerCalibratedAt.present) {
      map['ruler_calibrated_at'] = Variable<String>(rulerCalibratedAt.value);
    }
    if (captureCoordinates.present) {
      map['capture_coordinates'] = Variable<bool>(captureCoordinates.value);
    }
    if (sunlightMode.present) {
      map['sunlight_mode'] = Variable<bool>(sunlightMode.value);
    }
    if (gloveMode.present) {
      map['glove_mode'] = Variable<bool>(gloveMode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('localeOverride: $localeOverride, ')
          ..write('numeralSystem: $numeralSystem, ')
          ..write('lengthUnit: $lengthUnit, ')
          ..write('activeJurisdiction: $activeJurisdiction, ')
          ..write('activeZoneCode: $activeZoneCode, ')
          ..write('rulerPxPerMm: $rulerPxPerMm, ')
          ..write('rulerCalibratedAt: $rulerCalibratedAt, ')
          ..write('captureCoordinates: $captureCoordinates, ')
          ..write('sunlightMode: $sunlightMode, ')
          ..write('gloveMode: $gloveMode')
          ..write(')'))
        .toString();
  }
}

class $SavedZonesTable extends SavedZones with TableInfo<$SavedZonesTable, SavedZoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _jurisdictionCodeMeta = const VerificationMeta('jurisdictionCode');
  @override
  late final GeneratedColumn<String> jurisdictionCode = GeneratedColumn<String>(
    'jurisdiction_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneCodeMeta = const VerificationMeta('zoneCode');
  @override
  late final GeneratedColumn<String> zoneCode = GeneratedColumn<String>(
    'zone_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, jurisdictionCode, zoneCode, label, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_zone';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedZoneRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_code')) {
      context.handle(
        _jurisdictionCodeMeta,
        jurisdictionCode.isAcceptableOrUnknown(data['jurisdiction_code']!, _jurisdictionCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionCodeMeta);
    }
    if (data.containsKey('zone_code')) {
      context.handle(
        _zoneCodeMeta,
        zoneCode.isAcceptableOrUnknown(data['zone_code']!, _zoneCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneCodeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedZoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedZoneRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurisdiction_code'],
      )!,
      zoneCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_code'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SavedZonesTable createAlias(String alias) {
    return $SavedZonesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class SavedZoneRow extends DataClass implements Insertable<SavedZoneRow> {
  final int id;

  /// Codes, never ids: `reference.db` is a separate file that a content update
  /// replaces wholesale.
  final String jurisdictionCode;
  final String zoneCode;

  /// What the fisher calls it, which may not be what the instrument calls it.
  final String? label;
  final int sortOrder;
  const SavedZoneRow({
    required this.id,
    required this.jurisdictionCode,
    required this.zoneCode,
    this.label,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jurisdiction_code'] = Variable<String>(jurisdictionCode);
    map['zone_code'] = Variable<String>(zoneCode);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SavedZonesCompanion toCompanion(bool nullToAbsent) {
    return SavedZonesCompanion(
      id: Value(id),
      jurisdictionCode: Value(jurisdictionCode),
      zoneCode: Value(zoneCode),
      label: label == null && nullToAbsent ? const Value.absent() : Value(label),
      sortOrder: Value(sortOrder),
    );
  }

  factory SavedZoneRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedZoneRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionCode: serializer.fromJson<String>(json['jurisdictionCode']),
      zoneCode: serializer.fromJson<String>(json['zoneCode']),
      label: serializer.fromJson<String?>(json['label']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionCode': serializer.toJson<String>(jurisdictionCode),
      'zoneCode': serializer.toJson<String>(zoneCode),
      'label': serializer.toJson<String?>(label),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  SavedZoneRow copyWith({
    int? id,
    String? jurisdictionCode,
    String? zoneCode,
    Value<String?> label = const Value.absent(),
    int? sortOrder,
  }) => SavedZoneRow(
    id: id ?? this.id,
    jurisdictionCode: jurisdictionCode ?? this.jurisdictionCode,
    zoneCode: zoneCode ?? this.zoneCode,
    label: label.present ? label.value : this.label,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  SavedZoneRow copyWithCompanion(SavedZonesCompanion data) {
    return SavedZoneRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionCode: data.jurisdictionCode.present
          ? data.jurisdictionCode.value
          : this.jurisdictionCode,
      zoneCode: data.zoneCode.present ? data.zoneCode.value : this.zoneCode,
      label: data.label.present ? data.label.value : this.label,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedZoneRow(')
          ..write('id: $id, ')
          ..write('jurisdictionCode: $jurisdictionCode, ')
          ..write('zoneCode: $zoneCode, ')
          ..write('label: $label, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jurisdictionCode, zoneCode, label, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedZoneRow &&
          other.id == this.id &&
          other.jurisdictionCode == this.jurisdictionCode &&
          other.zoneCode == this.zoneCode &&
          other.label == this.label &&
          other.sortOrder == this.sortOrder);
}

class SavedZonesCompanion extends UpdateCompanion<SavedZoneRow> {
  final Value<int> id;
  final Value<String> jurisdictionCode;
  final Value<String> zoneCode;
  final Value<String?> label;
  final Value<int> sortOrder;
  const SavedZonesCompanion({
    this.id = const Value.absent(),
    this.jurisdictionCode = const Value.absent(),
    this.zoneCode = const Value.absent(),
    this.label = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SavedZonesCompanion.insert({
    this.id = const Value.absent(),
    required String jurisdictionCode,
    required String zoneCode,
    this.label = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : jurisdictionCode = Value(jurisdictionCode),
       zoneCode = Value(zoneCode);
  static Insertable<SavedZoneRow> custom({
    Expression<int>? id,
    Expression<String>? jurisdictionCode,
    Expression<String>? zoneCode,
    Expression<String>? label,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionCode != null) 'jurisdiction_code': jurisdictionCode,
      if (zoneCode != null) 'zone_code': zoneCode,
      if (label != null) 'label': label,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SavedZonesCompanion copyWith({
    Value<int>? id,
    Value<String>? jurisdictionCode,
    Value<String>? zoneCode,
    Value<String?>? label,
    Value<int>? sortOrder,
  }) {
    return SavedZonesCompanion(
      id: id ?? this.id,
      jurisdictionCode: jurisdictionCode ?? this.jurisdictionCode,
      zoneCode: zoneCode ?? this.zoneCode,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionCode.present) {
      map['jurisdiction_code'] = Variable<String>(jurisdictionCode.value);
    }
    if (zoneCode.present) {
      map['zone_code'] = Variable<String>(zoneCode.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedZonesCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionCode: $jurisdictionCode, ')
          ..write('zoneCode: $zoneCode, ')
          ..write('label: $label, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, TripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<String> startedAt = GeneratedColumn<String>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<String> endedAt = GeneratedColumn<String>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionCodeMeta = const VerificationMeta('jurisdictionCode');
  @override
  late final GeneratedColumn<String> jurisdictionCode = GeneratedColumn<String>(
    'jurisdiction_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneCodeMeta = const VerificationMeta('zoneCode');
  @override
  late final GeneratedColumn<String> zoneCode = GeneratedColumn<String>(
    'zone_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    jurisdictionCode,
    zoneCode,
    label,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip';
  @override
  VerificationContext validateIntegrity(Insertable<TripRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta, endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('jurisdiction_code')) {
      context.handle(
        _jurisdictionCodeMeta,
        jurisdictionCode.isAcceptableOrUnknown(data['jurisdiction_code']!, _jurisdictionCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionCodeMeta);
    }
    if (data.containsKey('zone_code')) {
      context.handle(
        _zoneCodeMeta,
        zoneCode.isAcceptableOrUnknown(data['zone_code']!, _zoneCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneCodeMeta);
    }
    if (data.containsKey('label')) {
      context.handle(_labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(_notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ended_at'],
      ),
      jurisdictionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurisdiction_code'],
      )!,
      zoneCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_code'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class TripRow extends DataClass implements Insertable<TripRow> {
  final int id;

  /// ISO-8601 UTC `TEXT`, per §7.2 and §12's export format. It sorts
  /// lexicographically in chronological order, so `idx_trip_started` serves
  /// `ORDER BY started_at DESC` exactly as an integer column would.
  final String startedAt;

  /// `null` while the trip is open.
  final String? endedAt;
  final String jurisdictionCode;
  final String zoneCode;
  final String? label;
  final String? notes;
  const TripRow({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.jurisdictionCode,
    required this.zoneCode,
    this.label,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<String>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<String>(endedAt);
    }
    map['jurisdiction_code'] = Variable<String>(jurisdictionCode);
    map['zone_code'] = Variable<String>(zoneCode);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent ? const Value.absent() : Value(endedAt),
      jurisdictionCode: Value(jurisdictionCode),
      zoneCode: Value(zoneCode),
      label: label == null && nullToAbsent ? const Value.absent() : Value(label),
      notes: notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory TripRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripRow(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<String>(json['startedAt']),
      endedAt: serializer.fromJson<String?>(json['endedAt']),
      jurisdictionCode: serializer.fromJson<String>(json['jurisdictionCode']),
      zoneCode: serializer.fromJson<String>(json['zoneCode']),
      label: serializer.fromJson<String?>(json['label']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<String>(startedAt),
      'endedAt': serializer.toJson<String?>(endedAt),
      'jurisdictionCode': serializer.toJson<String>(jurisdictionCode),
      'zoneCode': serializer.toJson<String>(zoneCode),
      'label': serializer.toJson<String?>(label),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  TripRow copyWith({
    int? id,
    String? startedAt,
    Value<String?> endedAt = const Value.absent(),
    String? jurisdictionCode,
    String? zoneCode,
    Value<String?> label = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => TripRow(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    jurisdictionCode: jurisdictionCode ?? this.jurisdictionCode,
    zoneCode: zoneCode ?? this.zoneCode,
    label: label.present ? label.value : this.label,
    notes: notes.present ? notes.value : this.notes,
  );
  TripRow copyWithCompanion(TripsCompanion data) {
    return TripRow(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      jurisdictionCode: data.jurisdictionCode.present
          ? data.jurisdictionCode.value
          : this.jurisdictionCode,
      zoneCode: data.zoneCode.present ? data.zoneCode.value : this.zoneCode,
      label: data.label.present ? data.label.value : this.label,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripRow(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('jurisdictionCode: $jurisdictionCode, ')
          ..write('zoneCode: $zoneCode, ')
          ..write('label: $label, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startedAt, endedAt, jurisdictionCode, zoneCode, label, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripRow &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.jurisdictionCode == this.jurisdictionCode &&
          other.zoneCode == this.zoneCode &&
          other.label == this.label &&
          other.notes == this.notes);
}

class TripsCompanion extends UpdateCompanion<TripRow> {
  final Value<int> id;
  final Value<String> startedAt;
  final Value<String?> endedAt;
  final Value<String> jurisdictionCode;
  final Value<String> zoneCode;
  final Value<String?> label;
  final Value<String?> notes;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.jurisdictionCode = const Value.absent(),
    this.zoneCode = const Value.absent(),
    this.label = const Value.absent(),
    this.notes = const Value.absent(),
  });
  TripsCompanion.insert({
    this.id = const Value.absent(),
    required String startedAt,
    this.endedAt = const Value.absent(),
    required String jurisdictionCode,
    required String zoneCode,
    this.label = const Value.absent(),
    this.notes = const Value.absent(),
  }) : startedAt = Value(startedAt),
       jurisdictionCode = Value(jurisdictionCode),
       zoneCode = Value(zoneCode);
  static Insertable<TripRow> custom({
    Expression<int>? id,
    Expression<String>? startedAt,
    Expression<String>? endedAt,
    Expression<String>? jurisdictionCode,
    Expression<String>? zoneCode,
    Expression<String>? label,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (jurisdictionCode != null) 'jurisdiction_code': jurisdictionCode,
      if (zoneCode != null) 'zone_code': zoneCode,
      if (label != null) 'label': label,
      if (notes != null) 'notes': notes,
    });
  }

  TripsCompanion copyWith({
    Value<int>? id,
    Value<String>? startedAt,
    Value<String?>? endedAt,
    Value<String>? jurisdictionCode,
    Value<String>? zoneCode,
    Value<String?>? label,
    Value<String?>? notes,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      jurisdictionCode: jurisdictionCode ?? this.jurisdictionCode,
      zoneCode: zoneCode ?? this.zoneCode,
      label: label ?? this.label,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<String>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<String>(endedAt.value);
    }
    if (jurisdictionCode.present) {
      map['jurisdiction_code'] = Variable<String>(jurisdictionCode.value);
    }
    if (zoneCode.present) {
      map['zone_code'] = Variable<String>(zoneCode.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('jurisdictionCode: $jurisdictionCode, ')
          ..write('zoneCode: $zoneCode, ')
          ..write('label: $label, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $CatchesTable extends Catches with TableInfo<$CatchesTable, CatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<int> tripId = GeneratedColumn<int>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES trip(id) ON DELETE SET NULL',
  );
  static const VerificationMeta _jurisdictionCodeMeta = const VerificationMeta('jurisdictionCode');
  @override
  late final GeneratedColumn<String> jurisdictionCode = GeneratedColumn<String>(
    'jurisdiction_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneCodeMeta = const VerificationMeta('zoneCode');
  @override
  late final GeneratedColumn<String> zoneCode = GeneratedColumn<String>(
    'zone_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta('scientificName');
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthMmMeta = const VerificationMeta('lengthMm');
  @override
  late final GeneratedColumn<int> lengthMm = GeneratedColumn<int>(
    'length_mm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _measurementCodeMeta = const VerificationMeta('measurementCode');
  @override
  late final GeneratedColumn<String> measurementCode = GeneratedColumn<String>(
    'measurement_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta('outcome');
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (outcome IN (\'meets\',\'fails\',\'attention\',\'unknown\'))',
  );
  static const VerificationMeta _outcomeDetailMeta = const VerificationMeta('outcomeDetail');
  @override
  late final GeneratedColumn<String> outcomeDetail = GeneratedColumn<String>(
    'outcome_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleCitationRefMeta = const VerificationMeta('ruleCitationRef');
  @override
  late final GeneratedColumn<String> ruleCitationRef = GeneratedColumn<String>(
    'rule_citation_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta('contentVersion');
  @override
  late final GeneratedColumn<String> contentVersion = GeneratedColumn<String>(
    'content_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasKeptMeta = const VerificationMeta('wasKept');
  @override
  late final GeneratedColumn<bool> wasKept = GeneratedColumn<bool>(
    'was_kept',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    jurisdictionCode,
    zoneCode,
    speciesId,
    scientificName,
    lengthMm,
    measurementCode,
    outcome,
    outcomeDetail,
    ruleCitationRef,
    contentVersion,
    wasKept,
    photoPath,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catch';
  @override
  VerificationContext validateIntegrity(Insertable<CatchRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trip_id')) {
      context.handle(_tripIdMeta, tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta));
    }
    if (data.containsKey('jurisdiction_code')) {
      context.handle(
        _jurisdictionCodeMeta,
        jurisdictionCode.isAcceptableOrUnknown(data['jurisdiction_code']!, _jurisdictionCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionCodeMeta);
    }
    if (data.containsKey('zone_code')) {
      context.handle(
        _zoneCodeMeta,
        zoneCode.isAcceptableOrUnknown(data['zone_code']!, _zoneCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneCodeMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(data['scientific_name']!, _scientificNameMeta),
      );
    } else if (isInserting) {
      context.missing(_scientificNameMeta);
    }
    if (data.containsKey('length_mm')) {
      context.handle(
        _lengthMmMeta,
        lengthMm.isAcceptableOrUnknown(data['length_mm']!, _lengthMmMeta),
      );
    }
    if (data.containsKey('measurement_code')) {
      context.handle(
        _measurementCodeMeta,
        measurementCode.isAcceptableOrUnknown(data['measurement_code']!, _measurementCodeMeta),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(_outcomeMeta, outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta));
    } else if (isInserting) {
      context.missing(_outcomeMeta);
    }
    if (data.containsKey('outcome_detail')) {
      context.handle(
        _outcomeDetailMeta,
        outcomeDetail.isAcceptableOrUnknown(data['outcome_detail']!, _outcomeDetailMeta),
      );
    }
    if (data.containsKey('rule_citation_ref')) {
      context.handle(
        _ruleCitationRefMeta,
        ruleCitationRef.isAcceptableOrUnknown(data['rule_citation_ref']!, _ruleCitationRefMeta),
      );
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(data['content_version']!, _contentVersionMeta),
      );
    }
    if (data.containsKey('was_kept')) {
      context.handle(_wasKeptMeta, wasKept.isAcceptableOrUnknown(data['was_kept']!, _wasKeptMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatchRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trip_id'],
      ),
      jurisdictionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurisdiction_code'],
      )!,
      zoneCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_code'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      )!,
      lengthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}length_mm'],
      ),
      measurementCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}measurement_code'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      )!,
      outcomeDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome_detail'],
      ),
      ruleCitationRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_citation_ref'],
      ),
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_version'],
      ),
      wasKept: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_kept'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CatchesTable createAlias(String alias) {
    return $CatchesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class CatchRow extends DataClass implements Insertable<CatchRow> {
  final int id;
  final int? tripId;

  /// On the catch, so zone filtering works for a quick-add with no trip.
  final String jurisdictionCode;
  final String zoneCode;

  /// A soft reference. See the class doc.
  final int speciesId;

  /// Denormalised: history survives a content update.
  final String scientificName;

  /// Integer millimetres, always. Conversion is display-only.
  final int? lengthMm;

  /// `TL`, `FL`, `SHL` — the method the length was measured by, without which
  /// the number means nothing.
  final String? measurementCode;
  final String outcome;

  /// The factual finding **as shown**. Not regenerated: the sentence the fisher
  /// read is the sentence the record keeps.
  final String? outcomeDetail;
  final String? ruleCitationRef;

  /// Which pack produced the verdict.
  final String? contentVersion;
  final bool wasKept;

  /// In-app camera only (E13), so photos never enter the shared camera roll.
  final String? photoPath;

  /// `null` unless the fisher opted in.
  final double? latitude;

  /// `null` unless the fisher opted in.
  final double? longitude;
  final String createdAt;
  final String updatedAt;
  const CatchRow({
    required this.id,
    this.tripId,
    required this.jurisdictionCode,
    required this.zoneCode,
    required this.speciesId,
    required this.scientificName,
    this.lengthMm,
    this.measurementCode,
    required this.outcome,
    this.outcomeDetail,
    this.ruleCitationRef,
    this.contentVersion,
    required this.wasKept,
    this.photoPath,
    this.latitude,
    this.longitude,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<int>(tripId);
    }
    map['jurisdiction_code'] = Variable<String>(jurisdictionCode);
    map['zone_code'] = Variable<String>(zoneCode);
    map['species_id'] = Variable<int>(speciesId);
    map['scientific_name'] = Variable<String>(scientificName);
    if (!nullToAbsent || lengthMm != null) {
      map['length_mm'] = Variable<int>(lengthMm);
    }
    if (!nullToAbsent || measurementCode != null) {
      map['measurement_code'] = Variable<String>(measurementCode);
    }
    map['outcome'] = Variable<String>(outcome);
    if (!nullToAbsent || outcomeDetail != null) {
      map['outcome_detail'] = Variable<String>(outcomeDetail);
    }
    if (!nullToAbsent || ruleCitationRef != null) {
      map['rule_citation_ref'] = Variable<String>(ruleCitationRef);
    }
    if (!nullToAbsent || contentVersion != null) {
      map['content_version'] = Variable<String>(contentVersion);
    }
    map['was_kept'] = Variable<bool>(wasKept);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  CatchesCompanion toCompanion(bool nullToAbsent) {
    return CatchesCompanion(
      id: Value(id),
      tripId: tripId == null && nullToAbsent ? const Value.absent() : Value(tripId),
      jurisdictionCode: Value(jurisdictionCode),
      zoneCode: Value(zoneCode),
      speciesId: Value(speciesId),
      scientificName: Value(scientificName),
      lengthMm: lengthMm == null && nullToAbsent ? const Value.absent() : Value(lengthMm),
      measurementCode: measurementCode == null && nullToAbsent
          ? const Value.absent()
          : Value(measurementCode),
      outcome: Value(outcome),
      outcomeDetail: outcomeDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(outcomeDetail),
      ruleCitationRef: ruleCitationRef == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleCitationRef),
      contentVersion: contentVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(contentVersion),
      wasKept: Value(wasKept),
      photoPath: photoPath == null && nullToAbsent ? const Value.absent() : Value(photoPath),
      latitude: latitude == null && nullToAbsent ? const Value.absent() : Value(latitude),
      longitude: longitude == null && nullToAbsent ? const Value.absent() : Value(longitude),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CatchRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatchRow(
      id: serializer.fromJson<int>(json['id']),
      tripId: serializer.fromJson<int?>(json['tripId']),
      jurisdictionCode: serializer.fromJson<String>(json['jurisdictionCode']),
      zoneCode: serializer.fromJson<String>(json['zoneCode']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      scientificName: serializer.fromJson<String>(json['scientificName']),
      lengthMm: serializer.fromJson<int?>(json['lengthMm']),
      measurementCode: serializer.fromJson<String?>(json['measurementCode']),
      outcome: serializer.fromJson<String>(json['outcome']),
      outcomeDetail: serializer.fromJson<String?>(json['outcomeDetail']),
      ruleCitationRef: serializer.fromJson<String?>(json['ruleCitationRef']),
      contentVersion: serializer.fromJson<String?>(json['contentVersion']),
      wasKept: serializer.fromJson<bool>(json['wasKept']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tripId': serializer.toJson<int?>(tripId),
      'jurisdictionCode': serializer.toJson<String>(jurisdictionCode),
      'zoneCode': serializer.toJson<String>(zoneCode),
      'speciesId': serializer.toJson<int>(speciesId),
      'scientificName': serializer.toJson<String>(scientificName),
      'lengthMm': serializer.toJson<int?>(lengthMm),
      'measurementCode': serializer.toJson<String?>(measurementCode),
      'outcome': serializer.toJson<String>(outcome),
      'outcomeDetail': serializer.toJson<String?>(outcomeDetail),
      'ruleCitationRef': serializer.toJson<String?>(ruleCitationRef),
      'contentVersion': serializer.toJson<String?>(contentVersion),
      'wasKept': serializer.toJson<bool>(wasKept),
      'photoPath': serializer.toJson<String?>(photoPath),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  CatchRow copyWith({
    int? id,
    Value<int?> tripId = const Value.absent(),
    String? jurisdictionCode,
    String? zoneCode,
    int? speciesId,
    String? scientificName,
    Value<int?> lengthMm = const Value.absent(),
    Value<String?> measurementCode = const Value.absent(),
    String? outcome,
    Value<String?> outcomeDetail = const Value.absent(),
    Value<String?> ruleCitationRef = const Value.absent(),
    Value<String?> contentVersion = const Value.absent(),
    bool? wasKept,
    Value<String?> photoPath = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => CatchRow(
    id: id ?? this.id,
    tripId: tripId.present ? tripId.value : this.tripId,
    jurisdictionCode: jurisdictionCode ?? this.jurisdictionCode,
    zoneCode: zoneCode ?? this.zoneCode,
    speciesId: speciesId ?? this.speciesId,
    scientificName: scientificName ?? this.scientificName,
    lengthMm: lengthMm.present ? lengthMm.value : this.lengthMm,
    measurementCode: measurementCode.present ? measurementCode.value : this.measurementCode,
    outcome: outcome ?? this.outcome,
    outcomeDetail: outcomeDetail.present ? outcomeDetail.value : this.outcomeDetail,
    ruleCitationRef: ruleCitationRef.present ? ruleCitationRef.value : this.ruleCitationRef,
    contentVersion: contentVersion.present ? contentVersion.value : this.contentVersion,
    wasKept: wasKept ?? this.wasKept,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CatchRow copyWithCompanion(CatchesCompanion data) {
    return CatchRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      jurisdictionCode: data.jurisdictionCode.present
          ? data.jurisdictionCode.value
          : this.jurisdictionCode,
      zoneCode: data.zoneCode.present ? data.zoneCode.value : this.zoneCode,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      scientificName: data.scientificName.present ? data.scientificName.value : this.scientificName,
      lengthMm: data.lengthMm.present ? data.lengthMm.value : this.lengthMm,
      measurementCode: data.measurementCode.present
          ? data.measurementCode.value
          : this.measurementCode,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      outcomeDetail: data.outcomeDetail.present ? data.outcomeDetail.value : this.outcomeDetail,
      ruleCitationRef: data.ruleCitationRef.present
          ? data.ruleCitationRef.value
          : this.ruleCitationRef,
      contentVersion: data.contentVersion.present ? data.contentVersion.value : this.contentVersion,
      wasKept: data.wasKept.present ? data.wasKept.value : this.wasKept,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatchRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('jurisdictionCode: $jurisdictionCode, ')
          ..write('zoneCode: $zoneCode, ')
          ..write('speciesId: $speciesId, ')
          ..write('scientificName: $scientificName, ')
          ..write('lengthMm: $lengthMm, ')
          ..write('measurementCode: $measurementCode, ')
          ..write('outcome: $outcome, ')
          ..write('outcomeDetail: $outcomeDetail, ')
          ..write('ruleCitationRef: $ruleCitationRef, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('wasKept: $wasKept, ')
          ..write('photoPath: $photoPath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    jurisdictionCode,
    zoneCode,
    speciesId,
    scientificName,
    lengthMm,
    measurementCode,
    outcome,
    outcomeDetail,
    ruleCitationRef,
    contentVersion,
    wasKept,
    photoPath,
    latitude,
    longitude,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatchRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.jurisdictionCode == this.jurisdictionCode &&
          other.zoneCode == this.zoneCode &&
          other.speciesId == this.speciesId &&
          other.scientificName == this.scientificName &&
          other.lengthMm == this.lengthMm &&
          other.measurementCode == this.measurementCode &&
          other.outcome == this.outcome &&
          other.outcomeDetail == this.outcomeDetail &&
          other.ruleCitationRef == this.ruleCitationRef &&
          other.contentVersion == this.contentVersion &&
          other.wasKept == this.wasKept &&
          other.photoPath == this.photoPath &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CatchesCompanion extends UpdateCompanion<CatchRow> {
  final Value<int> id;
  final Value<int?> tripId;
  final Value<String> jurisdictionCode;
  final Value<String> zoneCode;
  final Value<int> speciesId;
  final Value<String> scientificName;
  final Value<int?> lengthMm;
  final Value<String?> measurementCode;
  final Value<String> outcome;
  final Value<String?> outcomeDetail;
  final Value<String?> ruleCitationRef;
  final Value<String?> contentVersion;
  final Value<bool> wasKept;
  final Value<String?> photoPath;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const CatchesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.jurisdictionCode = const Value.absent(),
    this.zoneCode = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.lengthMm = const Value.absent(),
    this.measurementCode = const Value.absent(),
    this.outcome = const Value.absent(),
    this.outcomeDetail = const Value.absent(),
    this.ruleCitationRef = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.wasKept = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CatchesCompanion.insert({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    required String jurisdictionCode,
    required String zoneCode,
    required int speciesId,
    required String scientificName,
    this.lengthMm = const Value.absent(),
    this.measurementCode = const Value.absent(),
    required String outcome,
    this.outcomeDetail = const Value.absent(),
    this.ruleCitationRef = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.wasKept = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : jurisdictionCode = Value(jurisdictionCode),
       zoneCode = Value(zoneCode),
       speciesId = Value(speciesId),
       scientificName = Value(scientificName),
       outcome = Value(outcome),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CatchRow> custom({
    Expression<int>? id,
    Expression<int>? tripId,
    Expression<String>? jurisdictionCode,
    Expression<String>? zoneCode,
    Expression<int>? speciesId,
    Expression<String>? scientificName,
    Expression<int>? lengthMm,
    Expression<String>? measurementCode,
    Expression<String>? outcome,
    Expression<String>? outcomeDetail,
    Expression<String>? ruleCitationRef,
    Expression<String>? contentVersion,
    Expression<bool>? wasKept,
    Expression<String>? photoPath,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (jurisdictionCode != null) 'jurisdiction_code': jurisdictionCode,
      if (zoneCode != null) 'zone_code': zoneCode,
      if (speciesId != null) 'species_id': speciesId,
      if (scientificName != null) 'scientific_name': scientificName,
      if (lengthMm != null) 'length_mm': lengthMm,
      if (measurementCode != null) 'measurement_code': measurementCode,
      if (outcome != null) 'outcome': outcome,
      if (outcomeDetail != null) 'outcome_detail': outcomeDetail,
      if (ruleCitationRef != null) 'rule_citation_ref': ruleCitationRef,
      if (contentVersion != null) 'content_version': contentVersion,
      if (wasKept != null) 'was_kept': wasKept,
      if (photoPath != null) 'photo_path': photoPath,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CatchesCompanion copyWith({
    Value<int>? id,
    Value<int?>? tripId,
    Value<String>? jurisdictionCode,
    Value<String>? zoneCode,
    Value<int>? speciesId,
    Value<String>? scientificName,
    Value<int?>? lengthMm,
    Value<String?>? measurementCode,
    Value<String>? outcome,
    Value<String?>? outcomeDetail,
    Value<String?>? ruleCitationRef,
    Value<String?>? contentVersion,
    Value<bool>? wasKept,
    Value<String?>? photoPath,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return CatchesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      jurisdictionCode: jurisdictionCode ?? this.jurisdictionCode,
      zoneCode: zoneCode ?? this.zoneCode,
      speciesId: speciesId ?? this.speciesId,
      scientificName: scientificName ?? this.scientificName,
      lengthMm: lengthMm ?? this.lengthMm,
      measurementCode: measurementCode ?? this.measurementCode,
      outcome: outcome ?? this.outcome,
      outcomeDetail: outcomeDetail ?? this.outcomeDetail,
      ruleCitationRef: ruleCitationRef ?? this.ruleCitationRef,
      contentVersion: contentVersion ?? this.contentVersion,
      wasKept: wasKept ?? this.wasKept,
      photoPath: photoPath ?? this.photoPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<int>(tripId.value);
    }
    if (jurisdictionCode.present) {
      map['jurisdiction_code'] = Variable<String>(jurisdictionCode.value);
    }
    if (zoneCode.present) {
      map['zone_code'] = Variable<String>(zoneCode.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (lengthMm.present) {
      map['length_mm'] = Variable<int>(lengthMm.value);
    }
    if (measurementCode.present) {
      map['measurement_code'] = Variable<String>(measurementCode.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (outcomeDetail.present) {
      map['outcome_detail'] = Variable<String>(outcomeDetail.value);
    }
    if (ruleCitationRef.present) {
      map['rule_citation_ref'] = Variable<String>(ruleCitationRef.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<String>(contentVersion.value);
    }
    if (wasKept.present) {
      map['was_kept'] = Variable<bool>(wasKept.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatchesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('jurisdictionCode: $jurisdictionCode, ')
          ..write('zoneCode: $zoneCode, ')
          ..write('speciesId: $speciesId, ')
          ..write('scientificName: $scientificName, ')
          ..write('lengthMm: $lengthMm, ')
          ..write('measurementCode: $measurementCode, ')
          ..write('outcome: $outcome, ')
          ..write('outcomeDetail: $outcomeDetail, ')
          ..write('ruleCitationRef: $ruleCitationRef, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('wasKept: $wasKept, ')
          ..write('photoPath: $photoPath, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SpeciesRecentsTable extends SpeciesRecents
    with TableInfo<$SpeciesRecentsTable, SpeciesRecentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesRecentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _speciesIdMeta = const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jurisdictionCodeMeta = const VerificationMeta('jurisdictionCode');
  @override
  late final GeneratedColumn<String> jurisdictionCode = GeneratedColumn<String>(
    'jurisdiction_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneCodeMeta = const VerificationMeta('zoneCode');
  @override
  late final GeneratedColumn<String> zoneCode = GeneratedColumn<String>(
    'zone_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _useCountMeta = const VerificationMeta('useCount');
  @override
  late final GeneratedColumn<int> useCount = GeneratedColumn<int>(
    'use_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(1),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<String> lastUsedAt = GeneratedColumn<String>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    speciesId,
    jurisdictionCode,
    zoneCode,
    useCount,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_recent';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesRecentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('jurisdiction_code')) {
      context.handle(
        _jurisdictionCodeMeta,
        jurisdictionCode.isAcceptableOrUnknown(data['jurisdiction_code']!, _jurisdictionCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionCodeMeta);
    }
    if (data.containsKey('zone_code')) {
      context.handle(
        _zoneCodeMeta,
        zoneCode.isAcceptableOrUnknown(data['zone_code']!, _zoneCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneCodeMeta);
    }
    if (data.containsKey('use_count')) {
      context.handle(
        _useCountMeta,
        useCount.isAcceptableOrUnknown(data['use_count']!, _useCountMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(data['last_used_at']!, _lastUsedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {speciesId, jurisdictionCode, zoneCode};
  @override
  SpeciesRecentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesRecentRow(
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      jurisdictionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jurisdiction_code'],
      )!,
      zoneCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_code'],
      )!,
      useCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}use_count'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $SpeciesRecentsTable createAlias(String alias) {
    return $SpeciesRecentsTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get isStrict => true;
}

class SpeciesRecentRow extends DataClass implements Insertable<SpeciesRecentRow> {
  final int speciesId;
  final String jurisdictionCode;
  final String zoneCode;
  final int useCount;
  final String lastUsedAt;
  const SpeciesRecentRow({
    required this.speciesId,
    required this.jurisdictionCode,
    required this.zoneCode,
    required this.useCount,
    required this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['species_id'] = Variable<int>(speciesId);
    map['jurisdiction_code'] = Variable<String>(jurisdictionCode);
    map['zone_code'] = Variable<String>(zoneCode);
    map['use_count'] = Variable<int>(useCount);
    map['last_used_at'] = Variable<String>(lastUsedAt);
    return map;
  }

  SpeciesRecentsCompanion toCompanion(bool nullToAbsent) {
    return SpeciesRecentsCompanion(
      speciesId: Value(speciesId),
      jurisdictionCode: Value(jurisdictionCode),
      zoneCode: Value(zoneCode),
      useCount: Value(useCount),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory SpeciesRecentRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesRecentRow(
      speciesId: serializer.fromJson<int>(json['speciesId']),
      jurisdictionCode: serializer.fromJson<String>(json['jurisdictionCode']),
      zoneCode: serializer.fromJson<String>(json['zoneCode']),
      useCount: serializer.fromJson<int>(json['useCount']),
      lastUsedAt: serializer.fromJson<String>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'speciesId': serializer.toJson<int>(speciesId),
      'jurisdictionCode': serializer.toJson<String>(jurisdictionCode),
      'zoneCode': serializer.toJson<String>(zoneCode),
      'useCount': serializer.toJson<int>(useCount),
      'lastUsedAt': serializer.toJson<String>(lastUsedAt),
    };
  }

  SpeciesRecentRow copyWith({
    int? speciesId,
    String? jurisdictionCode,
    String? zoneCode,
    int? useCount,
    String? lastUsedAt,
  }) => SpeciesRecentRow(
    speciesId: speciesId ?? this.speciesId,
    jurisdictionCode: jurisdictionCode ?? this.jurisdictionCode,
    zoneCode: zoneCode ?? this.zoneCode,
    useCount: useCount ?? this.useCount,
    lastUsedAt: lastUsedAt ?? this.lastUsedAt,
  );
  SpeciesRecentRow copyWithCompanion(SpeciesRecentsCompanion data) {
    return SpeciesRecentRow(
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      jurisdictionCode: data.jurisdictionCode.present
          ? data.jurisdictionCode.value
          : this.jurisdictionCode,
      zoneCode: data.zoneCode.present ? data.zoneCode.value : this.zoneCode,
      useCount: data.useCount.present ? data.useCount.value : this.useCount,
      lastUsedAt: data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesRecentRow(')
          ..write('speciesId: $speciesId, ')
          ..write('jurisdictionCode: $jurisdictionCode, ')
          ..write('zoneCode: $zoneCode, ')
          ..write('useCount: $useCount, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(speciesId, jurisdictionCode, zoneCode, useCount, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesRecentRow &&
          other.speciesId == this.speciesId &&
          other.jurisdictionCode == this.jurisdictionCode &&
          other.zoneCode == this.zoneCode &&
          other.useCount == this.useCount &&
          other.lastUsedAt == this.lastUsedAt);
}

class SpeciesRecentsCompanion extends UpdateCompanion<SpeciesRecentRow> {
  final Value<int> speciesId;
  final Value<String> jurisdictionCode;
  final Value<String> zoneCode;
  final Value<int> useCount;
  final Value<String> lastUsedAt;
  const SpeciesRecentsCompanion({
    this.speciesId = const Value.absent(),
    this.jurisdictionCode = const Value.absent(),
    this.zoneCode = const Value.absent(),
    this.useCount = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
  });
  SpeciesRecentsCompanion.insert({
    required int speciesId,
    required String jurisdictionCode,
    required String zoneCode,
    this.useCount = const Value.absent(),
    required String lastUsedAt,
  }) : speciesId = Value(speciesId),
       jurisdictionCode = Value(jurisdictionCode),
       zoneCode = Value(zoneCode),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<SpeciesRecentRow> custom({
    Expression<int>? speciesId,
    Expression<String>? jurisdictionCode,
    Expression<String>? zoneCode,
    Expression<int>? useCount,
    Expression<String>? lastUsedAt,
  }) {
    return RawValuesInsertable({
      if (speciesId != null) 'species_id': speciesId,
      if (jurisdictionCode != null) 'jurisdiction_code': jurisdictionCode,
      if (zoneCode != null) 'zone_code': zoneCode,
      if (useCount != null) 'use_count': useCount,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
    });
  }

  SpeciesRecentsCompanion copyWith({
    Value<int>? speciesId,
    Value<String>? jurisdictionCode,
    Value<String>? zoneCode,
    Value<int>? useCount,
    Value<String>? lastUsedAt,
  }) {
    return SpeciesRecentsCompanion(
      speciesId: speciesId ?? this.speciesId,
      jurisdictionCode: jurisdictionCode ?? this.jurisdictionCode,
      zoneCode: zoneCode ?? this.zoneCode,
      useCount: useCount ?? this.useCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (jurisdictionCode.present) {
      map['jurisdiction_code'] = Variable<String>(jurisdictionCode.value);
    }
    if (zoneCode.present) {
      map['zone_code'] = Variable<String>(zoneCode.value);
    }
    if (useCount.present) {
      map['use_count'] = Variable<int>(useCount.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<String>(lastUsedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesRecentsCompanion(')
          ..write('speciesId: $speciesId, ')
          ..write('jurisdictionCode: $jurisdictionCode, ')
          ..write('zoneCode: $zoneCode, ')
          ..write('useCount: $useCount, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }
}

class $RuleFlagsTable extends RuleFlags with TableInfo<$RuleFlagsTable, RuleFlagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RuleFlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _citationRefMeta = const VerificationMeta('citationRef');
  @override
  late final GeneratedColumn<String> citationRef = GeneratedColumn<String>(
    'citation_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, ruleId, citationRef, note, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule_flag';
  @override
  VerificationContext validateIntegrity(
    Insertable<RuleFlagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rule_id')) {
      context.handle(_ruleIdMeta, ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta));
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('citation_ref')) {
      context.handle(
        _citationRefMeta,
        citationRef.isAcceptableOrUnknown(data['citation_ref']!, _citationRefMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleFlagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleFlagRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      )!,
      citationRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}citation_ref'],
      ),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RuleFlagsTable createAlias(String alias) {
    return $RuleFlagsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class RuleFlagRow extends DataClass implements Insertable<RuleFlagRow> {
  final int id;

  /// A soft reference into the pack that was installed at the time.
  final int ruleId;
  final String? citationRef;
  final String note;
  final String createdAt;
  const RuleFlagRow({
    required this.id,
    required this.ruleId,
    this.citationRef,
    required this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rule_id'] = Variable<int>(ruleId);
    if (!nullToAbsent || citationRef != null) {
      map['citation_ref'] = Variable<String>(citationRef);
    }
    map['note'] = Variable<String>(note);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  RuleFlagsCompanion toCompanion(bool nullToAbsent) {
    return RuleFlagsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      citationRef: citationRef == null && nullToAbsent ? const Value.absent() : Value(citationRef),
      note: Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory RuleFlagRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleFlagRow(
      id: serializer.fromJson<int>(json['id']),
      ruleId: serializer.fromJson<int>(json['ruleId']),
      citationRef: serializer.fromJson<String?>(json['citationRef']),
      note: serializer.fromJson<String>(json['note']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ruleId': serializer.toJson<int>(ruleId),
      'citationRef': serializer.toJson<String?>(citationRef),
      'note': serializer.toJson<String>(note),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  RuleFlagRow copyWith({
    int? id,
    int? ruleId,
    Value<String?> citationRef = const Value.absent(),
    String? note,
    String? createdAt,
  }) => RuleFlagRow(
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    citationRef: citationRef.present ? citationRef.value : this.citationRef,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  RuleFlagRow copyWithCompanion(RuleFlagsCompanion data) {
    return RuleFlagRow(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      citationRef: data.citationRef.present ? data.citationRef.value : this.citationRef,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleFlagRow(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('citationRef: $citationRef, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ruleId, citationRef, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleFlagRow &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.citationRef == this.citationRef &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class RuleFlagsCompanion extends UpdateCompanion<RuleFlagRow> {
  final Value<int> id;
  final Value<int> ruleId;
  final Value<String?> citationRef;
  final Value<String> note;
  final Value<String> createdAt;
  const RuleFlagsCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.citationRef = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RuleFlagsCompanion.insert({
    this.id = const Value.absent(),
    required int ruleId,
    this.citationRef = const Value.absent(),
    required String note,
    required String createdAt,
  }) : ruleId = Value(ruleId),
       note = Value(note),
       createdAt = Value(createdAt);
  static Insertable<RuleFlagRow> custom({
    Expression<int>? id,
    Expression<int>? ruleId,
    Expression<String>? citationRef,
    Expression<String>? note,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (citationRef != null) 'citation_ref': citationRef,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RuleFlagsCompanion copyWith({
    Value<int>? id,
    Value<int>? ruleId,
    Value<String?>? citationRef,
    Value<String>? note,
    Value<String>? createdAt,
  }) {
    return RuleFlagsCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      citationRef: citationRef ?? this.citationRef,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<int>(ruleId.value);
    }
    if (citationRef.present) {
      map['citation_ref'] = Variable<String>(citationRef.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RuleFlagsCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('citationRef: $citationRef, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppMetasTable extends AppMetas with TableInfo<$AppMetasTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetasTable createAlias(String alias) {
    return $AppMetasTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String key;
  final String value;
  const AppMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetasCompanion toCompanion(bool nullToAbsent) {
    return AppMetasCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) =>
      AppMetaRow(key: key ?? this.key, value: value ?? this.value);
  AppMetaRow copyWithCompanion(AppMetasCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow && other.key == this.key && other.value == this.value);
}

class AppMetasCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetasCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetasCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetasCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppMetasCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetasCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserDatabase extends GeneratedDatabase {
  _$UserDatabase(QueryExecutor e) : super(e);
  $UserDatabaseManager get managers => $UserDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $SavedZonesTable savedZones = $SavedZonesTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $CatchesTable catches = $CatchesTable(this);
  late final $SpeciesRecentsTable speciesRecents = $SpeciesRecentsTable(this);
  late final $RuleFlagsTable ruleFlags = $RuleFlagsTable(this);
  late final $AppMetasTable appMetas = $AppMetasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfiles,
    savedZones,
    trips,
    catches,
    speciesRecents,
    ruleFlags,
    appMetas,
  ];
}

typedef $$UserProfilesTableCreateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String?> localeOverride,
      Value<String> numeralSystem,
      Value<String> lengthUnit,
      Value<String?> activeJurisdiction,
      Value<String?> activeZoneCode,
      Value<double?> rulerPxPerMm,
      Value<String?> rulerCalibratedAt,
      Value<bool> captureCoordinates,
      Value<bool> sunlightMode,
      Value<bool> gloveMode,
    });
typedef $$UserProfilesTableUpdateCompanionBuilder =
    UserProfilesCompanion Function({
      Value<int> id,
      Value<String?> localeOverride,
      Value<String> numeralSystem,
      Value<String> lengthUnit,
      Value<String?> activeJurisdiction,
      Value<String?> activeZoneCode,
      Value<double?> rulerPxPerMm,
      Value<String?> rulerCalibratedAt,
      Value<bool> captureCoordinates,
      Value<bool> sunlightMode,
      Value<bool> gloveMode,
    });

class $$UserProfilesTableFilterComposer extends Composer<_$UserDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localeOverride =>
      $composableBuilder(column: $table.localeOverride, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get numeralSystem =>
      $composableBuilder(column: $table.numeralSystem, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lengthUnit =>
      $composableBuilder(column: $table.lengthUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeJurisdiction => $composableBuilder(
    column: $table.activeJurisdiction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeZoneCode =>
      $composableBuilder(column: $table.activeZoneCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rulerPxPerMm =>
      $composableBuilder(column: $table.rulerPxPerMm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rulerCalibratedAt => $composableBuilder(
    column: $table.rulerCalibratedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get captureCoordinates => $composableBuilder(
    column: $table.captureCoordinates,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sunlightMode =>
      $composableBuilder(column: $table.sunlightMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get gloveMode =>
      $composableBuilder(column: $table.gloveMode, builder: (column) => ColumnFilters(column));
}

class $$UserProfilesTableOrderingComposer extends Composer<_$UserDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localeOverride => $composableBuilder(
    column: $table.localeOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numeralSystem => $composableBuilder(
    column: $table.numeralSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lengthUnit =>
      $composableBuilder(column: $table.lengthUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeJurisdiction => $composableBuilder(
    column: $table.activeJurisdiction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeZoneCode => $composableBuilder(
    column: $table.activeZoneCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rulerPxPerMm =>
      $composableBuilder(column: $table.rulerPxPerMm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rulerCalibratedAt => $composableBuilder(
    column: $table.rulerCalibratedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get captureCoordinates => $composableBuilder(
    column: $table.captureCoordinates,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sunlightMode =>
      $composableBuilder(column: $table.sunlightMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get gloveMode =>
      $composableBuilder(column: $table.gloveMode, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer extends Composer<_$UserDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localeOverride =>
      $composableBuilder(column: $table.localeOverride, builder: (column) => column);

  GeneratedColumn<String> get numeralSystem =>
      $composableBuilder(column: $table.numeralSystem, builder: (column) => column);

  GeneratedColumn<String> get lengthUnit =>
      $composableBuilder(column: $table.lengthUnit, builder: (column) => column);

  GeneratedColumn<String> get activeJurisdiction =>
      $composableBuilder(column: $table.activeJurisdiction, builder: (column) => column);

  GeneratedColumn<String> get activeZoneCode =>
      $composableBuilder(column: $table.activeZoneCode, builder: (column) => column);

  GeneratedColumn<double> get rulerPxPerMm =>
      $composableBuilder(column: $table.rulerPxPerMm, builder: (column) => column);

  GeneratedColumn<String> get rulerCalibratedAt =>
      $composableBuilder(column: $table.rulerCalibratedAt, builder: (column) => column);

  GeneratedColumn<bool> get captureCoordinates =>
      $composableBuilder(column: $table.captureCoordinates, builder: (column) => column);

  GeneratedColumn<bool> get sunlightMode =>
      $composableBuilder(column: $table.sunlightMode, builder: (column) => column);

  GeneratedColumn<bool> get gloveMode =>
      $composableBuilder(column: $table.gloveMode, builder: (column) => column);
}

class $$UserProfilesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $UserProfilesTable,
          UserProfileRow,
          $$UserProfilesTableFilterComposer,
          $$UserProfilesTableOrderingComposer,
          $$UserProfilesTableAnnotationComposer,
          $$UserProfilesTableCreateCompanionBuilder,
          $$UserProfilesTableUpdateCompanionBuilder,
          (UserProfileRow, BaseReferences<_$UserDatabase, $UserProfilesTable, UserProfileRow>),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfilesTableTableManager(_$UserDatabase db, $UserProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> localeOverride = const Value.absent(),
                Value<String> numeralSystem = const Value.absent(),
                Value<String> lengthUnit = const Value.absent(),
                Value<String?> activeJurisdiction = const Value.absent(),
                Value<String?> activeZoneCode = const Value.absent(),
                Value<double?> rulerPxPerMm = const Value.absent(),
                Value<String?> rulerCalibratedAt = const Value.absent(),
                Value<bool> captureCoordinates = const Value.absent(),
                Value<bool> sunlightMode = const Value.absent(),
                Value<bool> gloveMode = const Value.absent(),
              }) => UserProfilesCompanion(
                id: id,
                localeOverride: localeOverride,
                numeralSystem: numeralSystem,
                lengthUnit: lengthUnit,
                activeJurisdiction: activeJurisdiction,
                activeZoneCode: activeZoneCode,
                rulerPxPerMm: rulerPxPerMm,
                rulerCalibratedAt: rulerCalibratedAt,
                captureCoordinates: captureCoordinates,
                sunlightMode: sunlightMode,
                gloveMode: gloveMode,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> localeOverride = const Value.absent(),
                Value<String> numeralSystem = const Value.absent(),
                Value<String> lengthUnit = const Value.absent(),
                Value<String?> activeJurisdiction = const Value.absent(),
                Value<String?> activeZoneCode = const Value.absent(),
                Value<double?> rulerPxPerMm = const Value.absent(),
                Value<String?> rulerCalibratedAt = const Value.absent(),
                Value<bool> captureCoordinates = const Value.absent(),
                Value<bool> sunlightMode = const Value.absent(),
                Value<bool> gloveMode = const Value.absent(),
              }) => UserProfilesCompanion.insert(
                id: id,
                localeOverride: localeOverride,
                numeralSystem: numeralSystem,
                lengthUnit: lengthUnit,
                activeJurisdiction: activeJurisdiction,
                activeZoneCode: activeZoneCode,
                rulerPxPerMm: rulerPxPerMm,
                rulerCalibratedAt: rulerCalibratedAt,
                captureCoordinates: captureCoordinates,
                sunlightMode: sunlightMode,
                gloveMode: gloveMode,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $UserProfilesTable,
      UserProfileRow,
      $$UserProfilesTableFilterComposer,
      $$UserProfilesTableOrderingComposer,
      $$UserProfilesTableAnnotationComposer,
      $$UserProfilesTableCreateCompanionBuilder,
      $$UserProfilesTableUpdateCompanionBuilder,
      (UserProfileRow, BaseReferences<_$UserDatabase, $UserProfilesTable, UserProfileRow>),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$SavedZonesTableCreateCompanionBuilder =
    SavedZonesCompanion Function({
      Value<int> id,
      required String jurisdictionCode,
      required String zoneCode,
      Value<String?> label,
      Value<int> sortOrder,
    });
typedef $$SavedZonesTableUpdateCompanionBuilder =
    SavedZonesCompanion Function({
      Value<int> id,
      Value<String> jurisdictionCode,
      Value<String> zoneCode,
      Value<String?> label,
      Value<int> sortOrder,
    });

class $$SavedZonesTableFilterComposer extends Composer<_$UserDatabase, $SavedZonesTable> {
  $$SavedZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jurisdictionCode => $composableBuilder(
    column: $table.jurisdictionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$SavedZonesTableOrderingComposer extends Composer<_$UserDatabase, $SavedZonesTable> {
  $$SavedZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jurisdictionCode => $composableBuilder(
    column: $table.jurisdictionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$SavedZonesTableAnnotationComposer extends Composer<_$UserDatabase, $SavedZonesTable> {
  $$SavedZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jurisdictionCode =>
      $composableBuilder(column: $table.jurisdictionCode, builder: (column) => column);

  GeneratedColumn<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$SavedZonesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $SavedZonesTable,
          SavedZoneRow,
          $$SavedZonesTableFilterComposer,
          $$SavedZonesTableOrderingComposer,
          $$SavedZonesTableAnnotationComposer,
          $$SavedZonesTableCreateCompanionBuilder,
          $$SavedZonesTableUpdateCompanionBuilder,
          (SavedZoneRow, BaseReferences<_$UserDatabase, $SavedZonesTable, SavedZoneRow>),
          SavedZoneRow,
          PrefetchHooks Function()
        > {
  $$SavedZonesTableTableManager(_$UserDatabase db, $SavedZonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SavedZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SavedZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> jurisdictionCode = const Value.absent(),
                Value<String> zoneCode = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SavedZonesCompanion(
                id: id,
                jurisdictionCode: jurisdictionCode,
                zoneCode: zoneCode,
                label: label,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String jurisdictionCode,
                required String zoneCode,
                Value<String?> label = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SavedZonesCompanion.insert(
                id: id,
                jurisdictionCode: jurisdictionCode,
                zoneCode: zoneCode,
                label: label,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $SavedZonesTable,
      SavedZoneRow,
      $$SavedZonesTableFilterComposer,
      $$SavedZonesTableOrderingComposer,
      $$SavedZonesTableAnnotationComposer,
      $$SavedZonesTableCreateCompanionBuilder,
      $$SavedZonesTableUpdateCompanionBuilder,
      (SavedZoneRow, BaseReferences<_$UserDatabase, $SavedZonesTable, SavedZoneRow>),
      SavedZoneRow,
      PrefetchHooks Function()
    >;
typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      Value<int> id,
      required String startedAt,
      Value<String?> endedAt,
      required String jurisdictionCode,
      required String zoneCode,
      Value<String?> label,
      Value<String?> notes,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<int> id,
      Value<String> startedAt,
      Value<String?> endedAt,
      Value<String> jurisdictionCode,
      Value<String> zoneCode,
      Value<String?> label,
      Value<String?> notes,
    });

class $$TripsTableFilterComposer extends Composer<_$UserDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jurisdictionCode => $composableBuilder(
    column: $table.jurisdictionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$TripsTableOrderingComposer extends Composer<_$UserDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jurisdictionCode => $composableBuilder(
    column: $table.jurisdictionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$TripsTableAnnotationComposer extends Composer<_$UserDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<String> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get jurisdictionCode =>
      $composableBuilder(column: $table.jurisdictionCode, builder: (column) => column);

  GeneratedColumn<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $TripsTable,
          TripRow,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (TripRow, BaseReferences<_$UserDatabase, $TripsTable, TripRow>),
          TripRow,
          PrefetchHooks Function()
        > {
  $$TripsTableTableManager(_$UserDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> startedAt = const Value.absent(),
                Value<String?> endedAt = const Value.absent(),
                Value<String> jurisdictionCode = const Value.absent(),
                Value<String> zoneCode = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                jurisdictionCode: jurisdictionCode,
                zoneCode: zoneCode,
                label: label,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String startedAt,
                Value<String?> endedAt = const Value.absent(),
                required String jurisdictionCode,
                required String zoneCode,
                Value<String?> label = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                jurisdictionCode: jurisdictionCode,
                zoneCode: zoneCode,
                label: label,
                notes: notes,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $TripsTable,
      TripRow,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (TripRow, BaseReferences<_$UserDatabase, $TripsTable, TripRow>),
      TripRow,
      PrefetchHooks Function()
    >;
typedef $$CatchesTableCreateCompanionBuilder =
    CatchesCompanion Function({
      Value<int> id,
      Value<int?> tripId,
      required String jurisdictionCode,
      required String zoneCode,
      required int speciesId,
      required String scientificName,
      Value<int?> lengthMm,
      Value<String?> measurementCode,
      required String outcome,
      Value<String?> outcomeDetail,
      Value<String?> ruleCitationRef,
      Value<String?> contentVersion,
      Value<bool> wasKept,
      Value<String?> photoPath,
      Value<double?> latitude,
      Value<double?> longitude,
      required String createdAt,
      required String updatedAt,
    });
typedef $$CatchesTableUpdateCompanionBuilder =
    CatchesCompanion Function({
      Value<int> id,
      Value<int?> tripId,
      Value<String> jurisdictionCode,
      Value<String> zoneCode,
      Value<int> speciesId,
      Value<String> scientificName,
      Value<int?> lengthMm,
      Value<String?> measurementCode,
      Value<String> outcome,
      Value<String?> outcomeDetail,
      Value<String?> ruleCitationRef,
      Value<String?> contentVersion,
      Value<bool> wasKept,
      Value<String?> photoPath,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$CatchesTableFilterComposer extends Composer<_$UserDatabase, $CatchesTable> {
  $$CatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jurisdictionCode => $composableBuilder(
    column: $table.jurisdictionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scientificName =>
      $composableBuilder(column: $table.scientificName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lengthMm =>
      $composableBuilder(column: $table.lengthMm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get measurementCode => $composableBuilder(
    column: $table.measurementCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get outcomeDetail =>
      $composableBuilder(column: $table.outcomeDetail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleCitationRef => $composableBuilder(
    column: $table.ruleCitationRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentVersion =>
      $composableBuilder(column: $table.contentVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get wasKept =>
      $composableBuilder(column: $table.wasKept, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CatchesTableOrderingComposer extends Composer<_$UserDatabase, $CatchesTable> {
  $$CatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jurisdictionCode => $composableBuilder(
    column: $table.jurisdictionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lengthMm =>
      $composableBuilder(column: $table.lengthMm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get measurementCode => $composableBuilder(
    column: $table.measurementCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get outcomeDetail => $composableBuilder(
    column: $table.outcomeDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleCitationRef => $composableBuilder(
    column: $table.ruleCitationRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasKept =>
      $composableBuilder(column: $table.wasKept, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CatchesTableAnnotationComposer extends Composer<_$UserDatabase, $CatchesTable> {
  $$CatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<String> get jurisdictionCode =>
      $composableBuilder(column: $table.jurisdictionCode, builder: (column) => column);

  GeneratedColumn<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get scientificName =>
      $composableBuilder(column: $table.scientificName, builder: (column) => column);

  GeneratedColumn<int> get lengthMm =>
      $composableBuilder(column: $table.lengthMm, builder: (column) => column);

  GeneratedColumn<String> get measurementCode =>
      $composableBuilder(column: $table.measurementCode, builder: (column) => column);

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get outcomeDetail =>
      $composableBuilder(column: $table.outcomeDetail, builder: (column) => column);

  GeneratedColumn<String> get ruleCitationRef =>
      $composableBuilder(column: $table.ruleCitationRef, builder: (column) => column);

  GeneratedColumn<String> get contentVersion =>
      $composableBuilder(column: $table.contentVersion, builder: (column) => column);

  GeneratedColumn<bool> get wasKept =>
      $composableBuilder(column: $table.wasKept, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CatchesTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $CatchesTable,
          CatchRow,
          $$CatchesTableFilterComposer,
          $$CatchesTableOrderingComposer,
          $$CatchesTableAnnotationComposer,
          $$CatchesTableCreateCompanionBuilder,
          $$CatchesTableUpdateCompanionBuilder,
          (CatchRow, BaseReferences<_$UserDatabase, $CatchesTable, CatchRow>),
          CatchRow,
          PrefetchHooks Function()
        > {
  $$CatchesTableTableManager(_$UserDatabase db, $CatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                Value<String> jurisdictionCode = const Value.absent(),
                Value<String> zoneCode = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<String> scientificName = const Value.absent(),
                Value<int?> lengthMm = const Value.absent(),
                Value<String?> measurementCode = const Value.absent(),
                Value<String> outcome = const Value.absent(),
                Value<String?> outcomeDetail = const Value.absent(),
                Value<String?> ruleCitationRef = const Value.absent(),
                Value<String?> contentVersion = const Value.absent(),
                Value<bool> wasKept = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => CatchesCompanion(
                id: id,
                tripId: tripId,
                jurisdictionCode: jurisdictionCode,
                zoneCode: zoneCode,
                speciesId: speciesId,
                scientificName: scientificName,
                lengthMm: lengthMm,
                measurementCode: measurementCode,
                outcome: outcome,
                outcomeDetail: outcomeDetail,
                ruleCitationRef: ruleCitationRef,
                contentVersion: contentVersion,
                wasKept: wasKept,
                photoPath: photoPath,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> tripId = const Value.absent(),
                required String jurisdictionCode,
                required String zoneCode,
                required int speciesId,
                required String scientificName,
                Value<int?> lengthMm = const Value.absent(),
                Value<String?> measurementCode = const Value.absent(),
                required String outcome,
                Value<String?> outcomeDetail = const Value.absent(),
                Value<String?> ruleCitationRef = const Value.absent(),
                Value<String?> contentVersion = const Value.absent(),
                Value<bool> wasKept = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => CatchesCompanion.insert(
                id: id,
                tripId: tripId,
                jurisdictionCode: jurisdictionCode,
                zoneCode: zoneCode,
                speciesId: speciesId,
                scientificName: scientificName,
                lengthMm: lengthMm,
                measurementCode: measurementCode,
                outcome: outcome,
                outcomeDetail: outcomeDetail,
                ruleCitationRef: ruleCitationRef,
                contentVersion: contentVersion,
                wasKept: wasKept,
                photoPath: photoPath,
                latitude: latitude,
                longitude: longitude,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $CatchesTable,
      CatchRow,
      $$CatchesTableFilterComposer,
      $$CatchesTableOrderingComposer,
      $$CatchesTableAnnotationComposer,
      $$CatchesTableCreateCompanionBuilder,
      $$CatchesTableUpdateCompanionBuilder,
      (CatchRow, BaseReferences<_$UserDatabase, $CatchesTable, CatchRow>),
      CatchRow,
      PrefetchHooks Function()
    >;
typedef $$SpeciesRecentsTableCreateCompanionBuilder =
    SpeciesRecentsCompanion Function({
      required int speciesId,
      required String jurisdictionCode,
      required String zoneCode,
      Value<int> useCount,
      required String lastUsedAt,
    });
typedef $$SpeciesRecentsTableUpdateCompanionBuilder =
    SpeciesRecentsCompanion Function({
      Value<int> speciesId,
      Value<String> jurisdictionCode,
      Value<String> zoneCode,
      Value<int> useCount,
      Value<String> lastUsedAt,
    });

class $$SpeciesRecentsTableFilterComposer extends Composer<_$UserDatabase, $SpeciesRecentsTable> {
  $$SpeciesRecentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jurisdictionCode => $composableBuilder(
    column: $table.jurisdictionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get useCount =>
      $composableBuilder(column: $table.useCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastUsedAt =>
      $composableBuilder(column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));
}

class $$SpeciesRecentsTableOrderingComposer extends Composer<_$UserDatabase, $SpeciesRecentsTable> {
  $$SpeciesRecentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jurisdictionCode => $composableBuilder(
    column: $table.jurisdictionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get useCount =>
      $composableBuilder(column: $table.useCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastUsedAt =>
      $composableBuilder(column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));
}

class $$SpeciesRecentsTableAnnotationComposer
    extends Composer<_$UserDatabase, $SpeciesRecentsTable> {
  $$SpeciesRecentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get jurisdictionCode =>
      $composableBuilder(column: $table.jurisdictionCode, builder: (column) => column);

  GeneratedColumn<String> get zoneCode =>
      $composableBuilder(column: $table.zoneCode, builder: (column) => column);

  GeneratedColumn<int> get useCount =>
      $composableBuilder(column: $table.useCount, builder: (column) => column);

  GeneratedColumn<String> get lastUsedAt =>
      $composableBuilder(column: $table.lastUsedAt, builder: (column) => column);
}

class $$SpeciesRecentsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $SpeciesRecentsTable,
          SpeciesRecentRow,
          $$SpeciesRecentsTableFilterComposer,
          $$SpeciesRecentsTableOrderingComposer,
          $$SpeciesRecentsTableAnnotationComposer,
          $$SpeciesRecentsTableCreateCompanionBuilder,
          $$SpeciesRecentsTableUpdateCompanionBuilder,
          (
            SpeciesRecentRow,
            BaseReferences<_$UserDatabase, $SpeciesRecentsTable, SpeciesRecentRow>,
          ),
          SpeciesRecentRow,
          PrefetchHooks Function()
        > {
  $$SpeciesRecentsTableTableManager(_$UserDatabase db, $SpeciesRecentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SpeciesRecentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SpeciesRecentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesRecentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> speciesId = const Value.absent(),
                Value<String> jurisdictionCode = const Value.absent(),
                Value<String> zoneCode = const Value.absent(),
                Value<int> useCount = const Value.absent(),
                Value<String> lastUsedAt = const Value.absent(),
              }) => SpeciesRecentsCompanion(
                speciesId: speciesId,
                jurisdictionCode: jurisdictionCode,
                zoneCode: zoneCode,
                useCount: useCount,
                lastUsedAt: lastUsedAt,
              ),
          createCompanionCallback:
              ({
                required int speciesId,
                required String jurisdictionCode,
                required String zoneCode,
                Value<int> useCount = const Value.absent(),
                required String lastUsedAt,
              }) => SpeciesRecentsCompanion.insert(
                speciesId: speciesId,
                jurisdictionCode: jurisdictionCode,
                zoneCode: zoneCode,
                useCount: useCount,
                lastUsedAt: lastUsedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SpeciesRecentsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $SpeciesRecentsTable,
      SpeciesRecentRow,
      $$SpeciesRecentsTableFilterComposer,
      $$SpeciesRecentsTableOrderingComposer,
      $$SpeciesRecentsTableAnnotationComposer,
      $$SpeciesRecentsTableCreateCompanionBuilder,
      $$SpeciesRecentsTableUpdateCompanionBuilder,
      (SpeciesRecentRow, BaseReferences<_$UserDatabase, $SpeciesRecentsTable, SpeciesRecentRow>),
      SpeciesRecentRow,
      PrefetchHooks Function()
    >;
typedef $$RuleFlagsTableCreateCompanionBuilder =
    RuleFlagsCompanion Function({
      Value<int> id,
      required int ruleId,
      Value<String?> citationRef,
      required String note,
      required String createdAt,
    });
typedef $$RuleFlagsTableUpdateCompanionBuilder =
    RuleFlagsCompanion Function({
      Value<int> id,
      Value<int> ruleId,
      Value<String?> citationRef,
      Value<String> note,
      Value<String> createdAt,
    });

class $$RuleFlagsTableFilterComposer extends Composer<_$UserDatabase, $RuleFlagsTable> {
  $$RuleFlagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get citationRef =>
      $composableBuilder(column: $table.citationRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RuleFlagsTableOrderingComposer extends Composer<_$UserDatabase, $RuleFlagsTable> {
  $$RuleFlagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get citationRef =>
      $composableBuilder(column: $table.citationRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RuleFlagsTableAnnotationComposer extends Composer<_$UserDatabase, $RuleFlagsTable> {
  $$RuleFlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get citationRef =>
      $composableBuilder(column: $table.citationRef, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RuleFlagsTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $RuleFlagsTable,
          RuleFlagRow,
          $$RuleFlagsTableFilterComposer,
          $$RuleFlagsTableOrderingComposer,
          $$RuleFlagsTableAnnotationComposer,
          $$RuleFlagsTableCreateCompanionBuilder,
          $$RuleFlagsTableUpdateCompanionBuilder,
          (RuleFlagRow, BaseReferences<_$UserDatabase, $RuleFlagsTable, RuleFlagRow>),
          RuleFlagRow,
          PrefetchHooks Function()
        > {
  $$RuleFlagsTableTableManager(_$UserDatabase db, $RuleFlagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RuleFlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RuleFlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RuleFlagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ruleId = const Value.absent(),
                Value<String?> citationRef = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => RuleFlagsCompanion(
                id: id,
                ruleId: ruleId,
                citationRef: citationRef,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ruleId,
                Value<String?> citationRef = const Value.absent(),
                required String note,
                required String createdAt,
              }) => RuleFlagsCompanion.insert(
                id: id,
                ruleId: ruleId,
                citationRef: citationRef,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RuleFlagsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $RuleFlagsTable,
      RuleFlagRow,
      $$RuleFlagsTableFilterComposer,
      $$RuleFlagsTableOrderingComposer,
      $$RuleFlagsTableAnnotationComposer,
      $$RuleFlagsTableCreateCompanionBuilder,
      $$RuleFlagsTableUpdateCompanionBuilder,
      (RuleFlagRow, BaseReferences<_$UserDatabase, $RuleFlagsTable, RuleFlagRow>),
      RuleFlagRow,
      PrefetchHooks Function()
    >;
typedef $$AppMetasTableCreateCompanionBuilder =
    AppMetasCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$AppMetasTableUpdateCompanionBuilder =
    AppMetasCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$AppMetasTableFilterComposer extends Composer<_$UserDatabase, $AppMetasTable> {
  $$AppMetasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppMetasTableOrderingComposer extends Composer<_$UserDatabase, $AppMetasTable> {
  $$AppMetasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppMetasTableAnnotationComposer extends Composer<_$UserDatabase, $AppMetasTable> {
  $$AppMetasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetasTableTableManager
    extends
        RootTableManager<
          _$UserDatabase,
          $AppMetasTable,
          AppMetaRow,
          $$AppMetasTableFilterComposer,
          $$AppMetasTableOrderingComposer,
          $$AppMetasTableAnnotationComposer,
          $$AppMetasTableCreateCompanionBuilder,
          $$AppMetasTableUpdateCompanionBuilder,
          (AppMetaRow, BaseReferences<_$UserDatabase, $AppMetasTable, AppMetaRow>),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetasTableTableManager(_$UserDatabase db, $AppMetasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AppMetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AppMetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetasCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppMetasCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetasTableProcessedTableManager =
    ProcessedTableManager<
      _$UserDatabase,
      $AppMetasTable,
      AppMetaRow,
      $$AppMetasTableFilterComposer,
      $$AppMetasTableOrderingComposer,
      $$AppMetasTableAnnotationComposer,
      $$AppMetasTableCreateCompanionBuilder,
      $$AppMetasTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$UserDatabase, $AppMetasTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;

class $UserDatabaseManager {
  final _$UserDatabase _db;
  $UserDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$SavedZonesTableTableManager get savedZones =>
      $$SavedZonesTableTableManager(_db, _db.savedZones);
  $$TripsTableTableManager get trips => $$TripsTableTableManager(_db, _db.trips);
  $$CatchesTableTableManager get catches => $$CatchesTableTableManager(_db, _db.catches);
  $$SpeciesRecentsTableTableManager get speciesRecents =>
      $$SpeciesRecentsTableTableManager(_db, _db.speciesRecents);
  $$RuleFlagsTableTableManager get ruleFlags => $$RuleFlagsTableTableManager(_db, _db.ruleFlags);
  $$AppMetasTableTableManager get appMetas => $$AppMetasTableTableManager(_db, _db.appMetas);
}
