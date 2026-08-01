// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_database_service.dart';

// ignore_for_file: type=lint
class $JurisdictionsTable extends Jurisdictions
    with TableInfo<$JurisdictionsTable, JurisdictionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JurisdictionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _countryIso2Meta = const VerificationMeta('countryIso2');
  @override
  late final GeneratedColumn<String> countryIso2 = GeneratedColumn<String>(
    'country_iso2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta('nameKey');
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorityKeyMeta = const VerificationMeta('authorityKey');
  @override
  late final GeneratedColumn<String> authorityKey = GeneratedColumn<String>(
    'authority_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorityUrlMeta = const VerificationMeta('authorityUrl');
  @override
  late final GeneratedColumn<String> authorityUrl = GeneratedColumn<String>(
    'authority_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hasFreshwaterMeta = const VerificationMeta('hasFreshwater');
  @override
  late final GeneratedColumn<bool> hasFreshwater = GeneratedColumn<bool>(
    'has_freshwater',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("has_freshwater" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _hasSaltwaterMeta = const VerificationMeta('hasSaltwater');
  @override
  late final GeneratedColumn<bool> hasSaltwater = GeneratedColumn<bool>(
    'has_saltwater',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("has_saltwater" IN (0, 1))'),
    defaultValue: const Constant<bool>(true),
  );
  static const VerificationMeta _hasZonePolygonsMeta = const VerificationMeta('hasZonePolygons');
  @override
  late final GeneratedColumn<bool> hasZonePolygons = GeneratedColumn<bool>(
    'has_zone_polygons',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("has_zone_polygons" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _defaultLocaleMeta = const VerificationMeta('defaultLocale');
  @override
  late final GeneratedColumn<String> defaultLocale = GeneratedColumn<String>(
    'default_locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legalTextLocalesMeta = const VerificationMeta('legalTextLocales');
  @override
  late final GeneratedColumn<String> legalTextLocales = GeneratedColumn<String>(
    'legal_text_locales',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentVersionMeta = const VerificationMeta('contentVersion');
  @override
  late final GeneratedColumn<String> contentVersion = GeneratedColumn<String>(
    'content_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedOnMeta = const VerificationMeta('publishedOn');
  @override
  late final GeneratedColumn<String> publishedOn = GeneratedColumn<String>(
    'published_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedOnMeta = const VerificationMeta('checkedOn');
  @override
  late final GeneratedColumn<String> checkedOn = GeneratedColumn<String>(
    'checked_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validUntilMeta = const VerificationMeta('validUntil');
  @override
  late final GeneratedColumn<String> validUntil = GeneratedColumn<String>(
    'valid_until',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    countryIso2,
    nameKey,
    authorityKey,
    authorityUrl,
    hasFreshwater,
    hasSaltwater,
    hasZonePolygons,
    defaultLocale,
    legalTextLocales,
    contentVersion,
    publishedOn,
    checkedOn,
    validUntil,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jurisdiction';
  @override
  VerificationContext validateIntegrity(
    Insertable<JurisdictionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(_codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('country_iso2')) {
      context.handle(
        _countryIso2Meta,
        countryIso2.isAcceptableOrUnknown(data['country_iso2']!, _countryIso2Meta),
      );
    } else if (isInserting) {
      context.missing(_countryIso2Meta);
    }
    if (data.containsKey('name_key')) {
      context.handle(_nameKeyMeta, nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta));
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('authority_key')) {
      context.handle(
        _authorityKeyMeta,
        authorityKey.isAcceptableOrUnknown(data['authority_key']!, _authorityKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_authorityKeyMeta);
    }
    if (data.containsKey('authority_url')) {
      context.handle(
        _authorityUrlMeta,
        authorityUrl.isAcceptableOrUnknown(data['authority_url']!, _authorityUrlMeta),
      );
    }
    if (data.containsKey('has_freshwater')) {
      context.handle(
        _hasFreshwaterMeta,
        hasFreshwater.isAcceptableOrUnknown(data['has_freshwater']!, _hasFreshwaterMeta),
      );
    }
    if (data.containsKey('has_saltwater')) {
      context.handle(
        _hasSaltwaterMeta,
        hasSaltwater.isAcceptableOrUnknown(data['has_saltwater']!, _hasSaltwaterMeta),
      );
    }
    if (data.containsKey('has_zone_polygons')) {
      context.handle(
        _hasZonePolygonsMeta,
        hasZonePolygons.isAcceptableOrUnknown(data['has_zone_polygons']!, _hasZonePolygonsMeta),
      );
    }
    if (data.containsKey('default_locale')) {
      context.handle(
        _defaultLocaleMeta,
        defaultLocale.isAcceptableOrUnknown(data['default_locale']!, _defaultLocaleMeta),
      );
    } else if (isInserting) {
      context.missing(_defaultLocaleMeta);
    }
    if (data.containsKey('legal_text_locales')) {
      context.handle(
        _legalTextLocalesMeta,
        legalTextLocales.isAcceptableOrUnknown(data['legal_text_locales']!, _legalTextLocalesMeta),
      );
    } else if (isInserting) {
      context.missing(_legalTextLocalesMeta);
    }
    if (data.containsKey('content_version')) {
      context.handle(
        _contentVersionMeta,
        contentVersion.isAcceptableOrUnknown(data['content_version']!, _contentVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_contentVersionMeta);
    }
    if (data.containsKey('published_on')) {
      context.handle(
        _publishedOnMeta,
        publishedOn.isAcceptableOrUnknown(data['published_on']!, _publishedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_publishedOnMeta);
    }
    if (data.containsKey('checked_on')) {
      context.handle(
        _checkedOnMeta,
        checkedOn.isAcceptableOrUnknown(data['checked_on']!, _checkedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_checkedOnMeta);
    }
    if (data.containsKey('valid_until')) {
      context.handle(
        _validUntilMeta,
        validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JurisdictionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JurisdictionRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      countryIso2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country_iso2'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      authorityKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authority_key'],
      )!,
      authorityUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authority_url'],
      ),
      hasFreshwater: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_freshwater'],
      )!,
      hasSaltwater: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_saltwater'],
      )!,
      hasZonePolygons: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_zone_polygons'],
      )!,
      defaultLocale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_locale'],
      )!,
      legalTextLocales: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_text_locales'],
      )!,
      contentVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_version'],
      )!,
      publishedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}published_on'],
      )!,
      checkedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checked_on'],
      )!,
      validUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_until'],
      ),
    );
  }

  @override
  $JurisdictionsTable createAlias(String alias) {
    return $JurisdictionsTable(attachedDatabase, alias);
  }
}

class JurisdictionRow extends DataClass implements Insertable<JurisdictionRow> {
  /// Assigned by the content build from sorted authored ids, never by SQLite:
  /// a rowid the writer chose makes the emitted file depend on insert order.
  final int id;

  /// `AE-RK`, `ES-GA`, `BR-SP`.
  final String code;

  /// ISO 3166-1 alpha-2 of the state the authority belongs to.
  final String countryIso2;

  /// Localised jurisdiction name, resolved through `content_string`.
  final String nameKey;

  /// Localised name of the authority itself.
  final String authorityKey;

  /// **Selectable text only, never launched.** An `ACTION_VIEW` fetches under
  /// the browser's own permission and defeats the Android guarantee.
  final String? authorityUrl;

  /// Whether the jurisdiction regulates fresh water.
  final bool hasFreshwater;

  /// Whether the jurisdiction regulates salt water.
  final bool hasSaltwater;

  /// `false` hides the sub-zone level in S9. Where no coordinate list is printed
  /// in the instrument we do not invent boundaries.
  final bool hasZonePolygons;

  /// The locale the §9.2 fallback chain drops to before `en`.
  final String defaultLocale;

  /// CSV of the languages the authority published its law in, e.g. `gl,es`.
  /// S13 renders a language-availability notice when the reader's locale is not
  /// among them.
  final String legalTextLocales;

  /// The pack version. `catch.content_version` names it so a three-year-old
  /// record can still say which ruleset produced its verdict.
  final String contentVersion;

  /// When the instrument set was published.
  final String publishedOn;

  /// When a human last read the published text.
  final String checkedOn;

  /// When the pack goes stale. Passing it raises the non-blocking ochre bar; it
  /// never withholds a verdict (invariant 5).
  final String? validUntil;
  const JurisdictionRow({
    required this.id,
    required this.code,
    required this.countryIso2,
    required this.nameKey,
    required this.authorityKey,
    this.authorityUrl,
    required this.hasFreshwater,
    required this.hasSaltwater,
    required this.hasZonePolygons,
    required this.defaultLocale,
    required this.legalTextLocales,
    required this.contentVersion,
    required this.publishedOn,
    required this.checkedOn,
    this.validUntil,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['country_iso2'] = Variable<String>(countryIso2);
    map['name_key'] = Variable<String>(nameKey);
    map['authority_key'] = Variable<String>(authorityKey);
    if (!nullToAbsent || authorityUrl != null) {
      map['authority_url'] = Variable<String>(authorityUrl);
    }
    map['has_freshwater'] = Variable<bool>(hasFreshwater);
    map['has_saltwater'] = Variable<bool>(hasSaltwater);
    map['has_zone_polygons'] = Variable<bool>(hasZonePolygons);
    map['default_locale'] = Variable<String>(defaultLocale);
    map['legal_text_locales'] = Variable<String>(legalTextLocales);
    map['content_version'] = Variable<String>(contentVersion);
    map['published_on'] = Variable<String>(publishedOn);
    map['checked_on'] = Variable<String>(checkedOn);
    if (!nullToAbsent || validUntil != null) {
      map['valid_until'] = Variable<String>(validUntil);
    }
    return map;
  }

  JurisdictionsCompanion toCompanion(bool nullToAbsent) {
    return JurisdictionsCompanion(
      id: Value(id),
      code: Value(code),
      countryIso2: Value(countryIso2),
      nameKey: Value(nameKey),
      authorityKey: Value(authorityKey),
      authorityUrl: authorityUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(authorityUrl),
      hasFreshwater: Value(hasFreshwater),
      hasSaltwater: Value(hasSaltwater),
      hasZonePolygons: Value(hasZonePolygons),
      defaultLocale: Value(defaultLocale),
      legalTextLocales: Value(legalTextLocales),
      contentVersion: Value(contentVersion),
      publishedOn: Value(publishedOn),
      checkedOn: Value(checkedOn),
      validUntil: validUntil == null && nullToAbsent ? const Value.absent() : Value(validUntil),
    );
  }

  factory JurisdictionRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JurisdictionRow(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      countryIso2: serializer.fromJson<String>(json['countryIso2']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      authorityKey: serializer.fromJson<String>(json['authorityKey']),
      authorityUrl: serializer.fromJson<String?>(json['authorityUrl']),
      hasFreshwater: serializer.fromJson<bool>(json['hasFreshwater']),
      hasSaltwater: serializer.fromJson<bool>(json['hasSaltwater']),
      hasZonePolygons: serializer.fromJson<bool>(json['hasZonePolygons']),
      defaultLocale: serializer.fromJson<String>(json['defaultLocale']),
      legalTextLocales: serializer.fromJson<String>(json['legalTextLocales']),
      contentVersion: serializer.fromJson<String>(json['contentVersion']),
      publishedOn: serializer.fromJson<String>(json['publishedOn']),
      checkedOn: serializer.fromJson<String>(json['checkedOn']),
      validUntil: serializer.fromJson<String?>(json['validUntil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'countryIso2': serializer.toJson<String>(countryIso2),
      'nameKey': serializer.toJson<String>(nameKey),
      'authorityKey': serializer.toJson<String>(authorityKey),
      'authorityUrl': serializer.toJson<String?>(authorityUrl),
      'hasFreshwater': serializer.toJson<bool>(hasFreshwater),
      'hasSaltwater': serializer.toJson<bool>(hasSaltwater),
      'hasZonePolygons': serializer.toJson<bool>(hasZonePolygons),
      'defaultLocale': serializer.toJson<String>(defaultLocale),
      'legalTextLocales': serializer.toJson<String>(legalTextLocales),
      'contentVersion': serializer.toJson<String>(contentVersion),
      'publishedOn': serializer.toJson<String>(publishedOn),
      'checkedOn': serializer.toJson<String>(checkedOn),
      'validUntil': serializer.toJson<String?>(validUntil),
    };
  }

  JurisdictionRow copyWith({
    int? id,
    String? code,
    String? countryIso2,
    String? nameKey,
    String? authorityKey,
    Value<String?> authorityUrl = const Value.absent(),
    bool? hasFreshwater,
    bool? hasSaltwater,
    bool? hasZonePolygons,
    String? defaultLocale,
    String? legalTextLocales,
    String? contentVersion,
    String? publishedOn,
    String? checkedOn,
    Value<String?> validUntil = const Value.absent(),
  }) => JurisdictionRow(
    id: id ?? this.id,
    code: code ?? this.code,
    countryIso2: countryIso2 ?? this.countryIso2,
    nameKey: nameKey ?? this.nameKey,
    authorityKey: authorityKey ?? this.authorityKey,
    authorityUrl: authorityUrl.present ? authorityUrl.value : this.authorityUrl,
    hasFreshwater: hasFreshwater ?? this.hasFreshwater,
    hasSaltwater: hasSaltwater ?? this.hasSaltwater,
    hasZonePolygons: hasZonePolygons ?? this.hasZonePolygons,
    defaultLocale: defaultLocale ?? this.defaultLocale,
    legalTextLocales: legalTextLocales ?? this.legalTextLocales,
    contentVersion: contentVersion ?? this.contentVersion,
    publishedOn: publishedOn ?? this.publishedOn,
    checkedOn: checkedOn ?? this.checkedOn,
    validUntil: validUntil.present ? validUntil.value : this.validUntil,
  );
  JurisdictionRow copyWithCompanion(JurisdictionsCompanion data) {
    return JurisdictionRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      countryIso2: data.countryIso2.present ? data.countryIso2.value : this.countryIso2,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      authorityKey: data.authorityKey.present ? data.authorityKey.value : this.authorityKey,
      authorityUrl: data.authorityUrl.present ? data.authorityUrl.value : this.authorityUrl,
      hasFreshwater: data.hasFreshwater.present ? data.hasFreshwater.value : this.hasFreshwater,
      hasSaltwater: data.hasSaltwater.present ? data.hasSaltwater.value : this.hasSaltwater,
      hasZonePolygons: data.hasZonePolygons.present
          ? data.hasZonePolygons.value
          : this.hasZonePolygons,
      defaultLocale: data.defaultLocale.present ? data.defaultLocale.value : this.defaultLocale,
      legalTextLocales: data.legalTextLocales.present
          ? data.legalTextLocales.value
          : this.legalTextLocales,
      contentVersion: data.contentVersion.present ? data.contentVersion.value : this.contentVersion,
      publishedOn: data.publishedOn.present ? data.publishedOn.value : this.publishedOn,
      checkedOn: data.checkedOn.present ? data.checkedOn.value : this.checkedOn,
      validUntil: data.validUntil.present ? data.validUntil.value : this.validUntil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JurisdictionRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('countryIso2: $countryIso2, ')
          ..write('nameKey: $nameKey, ')
          ..write('authorityKey: $authorityKey, ')
          ..write('authorityUrl: $authorityUrl, ')
          ..write('hasFreshwater: $hasFreshwater, ')
          ..write('hasSaltwater: $hasSaltwater, ')
          ..write('hasZonePolygons: $hasZonePolygons, ')
          ..write('defaultLocale: $defaultLocale, ')
          ..write('legalTextLocales: $legalTextLocales, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('publishedOn: $publishedOn, ')
          ..write('checkedOn: $checkedOn, ')
          ..write('validUntil: $validUntil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    countryIso2,
    nameKey,
    authorityKey,
    authorityUrl,
    hasFreshwater,
    hasSaltwater,
    hasZonePolygons,
    defaultLocale,
    legalTextLocales,
    contentVersion,
    publishedOn,
    checkedOn,
    validUntil,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JurisdictionRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.countryIso2 == this.countryIso2 &&
          other.nameKey == this.nameKey &&
          other.authorityKey == this.authorityKey &&
          other.authorityUrl == this.authorityUrl &&
          other.hasFreshwater == this.hasFreshwater &&
          other.hasSaltwater == this.hasSaltwater &&
          other.hasZonePolygons == this.hasZonePolygons &&
          other.defaultLocale == this.defaultLocale &&
          other.legalTextLocales == this.legalTextLocales &&
          other.contentVersion == this.contentVersion &&
          other.publishedOn == this.publishedOn &&
          other.checkedOn == this.checkedOn &&
          other.validUntil == this.validUntil);
}

class JurisdictionsCompanion extends UpdateCompanion<JurisdictionRow> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> countryIso2;
  final Value<String> nameKey;
  final Value<String> authorityKey;
  final Value<String?> authorityUrl;
  final Value<bool> hasFreshwater;
  final Value<bool> hasSaltwater;
  final Value<bool> hasZonePolygons;
  final Value<String> defaultLocale;
  final Value<String> legalTextLocales;
  final Value<String> contentVersion;
  final Value<String> publishedOn;
  final Value<String> checkedOn;
  final Value<String?> validUntil;
  const JurisdictionsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.countryIso2 = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.authorityKey = const Value.absent(),
    this.authorityUrl = const Value.absent(),
    this.hasFreshwater = const Value.absent(),
    this.hasSaltwater = const Value.absent(),
    this.hasZonePolygons = const Value.absent(),
    this.defaultLocale = const Value.absent(),
    this.legalTextLocales = const Value.absent(),
    this.contentVersion = const Value.absent(),
    this.publishedOn = const Value.absent(),
    this.checkedOn = const Value.absent(),
    this.validUntil = const Value.absent(),
  });
  JurisdictionsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String countryIso2,
    required String nameKey,
    required String authorityKey,
    this.authorityUrl = const Value.absent(),
    this.hasFreshwater = const Value.absent(),
    this.hasSaltwater = const Value.absent(),
    this.hasZonePolygons = const Value.absent(),
    required String defaultLocale,
    required String legalTextLocales,
    required String contentVersion,
    required String publishedOn,
    required String checkedOn,
    this.validUntil = const Value.absent(),
  }) : code = Value(code),
       countryIso2 = Value(countryIso2),
       nameKey = Value(nameKey),
       authorityKey = Value(authorityKey),
       defaultLocale = Value(defaultLocale),
       legalTextLocales = Value(legalTextLocales),
       contentVersion = Value(contentVersion),
       publishedOn = Value(publishedOn),
       checkedOn = Value(checkedOn);
  static Insertable<JurisdictionRow> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? countryIso2,
    Expression<String>? nameKey,
    Expression<String>? authorityKey,
    Expression<String>? authorityUrl,
    Expression<bool>? hasFreshwater,
    Expression<bool>? hasSaltwater,
    Expression<bool>? hasZonePolygons,
    Expression<String>? defaultLocale,
    Expression<String>? legalTextLocales,
    Expression<String>? contentVersion,
    Expression<String>? publishedOn,
    Expression<String>? checkedOn,
    Expression<String>? validUntil,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (countryIso2 != null) 'country_iso2': countryIso2,
      if (nameKey != null) 'name_key': nameKey,
      if (authorityKey != null) 'authority_key': authorityKey,
      if (authorityUrl != null) 'authority_url': authorityUrl,
      if (hasFreshwater != null) 'has_freshwater': hasFreshwater,
      if (hasSaltwater != null) 'has_saltwater': hasSaltwater,
      if (hasZonePolygons != null) 'has_zone_polygons': hasZonePolygons,
      if (defaultLocale != null) 'default_locale': defaultLocale,
      if (legalTextLocales != null) 'legal_text_locales': legalTextLocales,
      if (contentVersion != null) 'content_version': contentVersion,
      if (publishedOn != null) 'published_on': publishedOn,
      if (checkedOn != null) 'checked_on': checkedOn,
      if (validUntil != null) 'valid_until': validUntil,
    });
  }

  JurisdictionsCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? countryIso2,
    Value<String>? nameKey,
    Value<String>? authorityKey,
    Value<String?>? authorityUrl,
    Value<bool>? hasFreshwater,
    Value<bool>? hasSaltwater,
    Value<bool>? hasZonePolygons,
    Value<String>? defaultLocale,
    Value<String>? legalTextLocales,
    Value<String>? contentVersion,
    Value<String>? publishedOn,
    Value<String>? checkedOn,
    Value<String?>? validUntil,
  }) {
    return JurisdictionsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      countryIso2: countryIso2 ?? this.countryIso2,
      nameKey: nameKey ?? this.nameKey,
      authorityKey: authorityKey ?? this.authorityKey,
      authorityUrl: authorityUrl ?? this.authorityUrl,
      hasFreshwater: hasFreshwater ?? this.hasFreshwater,
      hasSaltwater: hasSaltwater ?? this.hasSaltwater,
      hasZonePolygons: hasZonePolygons ?? this.hasZonePolygons,
      defaultLocale: defaultLocale ?? this.defaultLocale,
      legalTextLocales: legalTextLocales ?? this.legalTextLocales,
      contentVersion: contentVersion ?? this.contentVersion,
      publishedOn: publishedOn ?? this.publishedOn,
      checkedOn: checkedOn ?? this.checkedOn,
      validUntil: validUntil ?? this.validUntil,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (countryIso2.present) {
      map['country_iso2'] = Variable<String>(countryIso2.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (authorityKey.present) {
      map['authority_key'] = Variable<String>(authorityKey.value);
    }
    if (authorityUrl.present) {
      map['authority_url'] = Variable<String>(authorityUrl.value);
    }
    if (hasFreshwater.present) {
      map['has_freshwater'] = Variable<bool>(hasFreshwater.value);
    }
    if (hasSaltwater.present) {
      map['has_saltwater'] = Variable<bool>(hasSaltwater.value);
    }
    if (hasZonePolygons.present) {
      map['has_zone_polygons'] = Variable<bool>(hasZonePolygons.value);
    }
    if (defaultLocale.present) {
      map['default_locale'] = Variable<String>(defaultLocale.value);
    }
    if (legalTextLocales.present) {
      map['legal_text_locales'] = Variable<String>(legalTextLocales.value);
    }
    if (contentVersion.present) {
      map['content_version'] = Variable<String>(contentVersion.value);
    }
    if (publishedOn.present) {
      map['published_on'] = Variable<String>(publishedOn.value);
    }
    if (checkedOn.present) {
      map['checked_on'] = Variable<String>(checkedOn.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<String>(validUntil.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JurisdictionsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('countryIso2: $countryIso2, ')
          ..write('nameKey: $nameKey, ')
          ..write('authorityKey: $authorityKey, ')
          ..write('authorityUrl: $authorityUrl, ')
          ..write('hasFreshwater: $hasFreshwater, ')
          ..write('hasSaltwater: $hasSaltwater, ')
          ..write('hasZonePolygons: $hasZonePolygons, ')
          ..write('defaultLocale: $defaultLocale, ')
          ..write('legalTextLocales: $legalTextLocales, ')
          ..write('contentVersion: $contentVersion, ')
          ..write('publishedOn: $publishedOn, ')
          ..write('checkedOn: $checkedOn, ')
          ..write('validUntil: $validUntil')
          ..write(')'))
        .toString();
  }
}

class $ZonesTable extends Zones with TableInfo<$ZonesTable, ZoneRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta('jurisdictionId');
  @override
  late final GeneratedColumn<int> jurisdictionId = GeneratedColumn<int>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdiction(id)',
  );
  static const VerificationMeta _parentZoneIdMeta = const VerificationMeta('parentZoneId');
  @override
  late final GeneratedColumn<int> parentZoneId = GeneratedColumn<int>(
    'parent_zone_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES zone(id)',
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta('nameKey');
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _waterTypeMeta = const VerificationMeta('waterType');
  @override
  late final GeneratedColumn<String> waterType = GeneratedColumn<String>(
    'water_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (water_type IN (\'salt\',\'fresh\',\'both\'))',
  );
  static const VerificationMeta _zoneKindMeta = const VerificationMeta('zoneKind');
  @override
  late final GeneratedColumn<String> zoneKind = GeneratedColumn<String>(
    'zone_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (zone_kind IN (\'region\',\'subzone\',\'bank\',\'basin\', \'reserve\',\'exclusion\'))',
  );
  static const VerificationMeta _geometrySourceMeta = const VerificationMeta('geometrySource');
  @override
  late final GeneratedColumn<String> geometrySource = GeneratedColumn<String>(
    'geometry_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minLatMeta = const VerificationMeta('minLat');
  @override
  late final GeneratedColumn<double> minLat = GeneratedColumn<double>(
    'min_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minLonMeta = const VerificationMeta('minLon');
  @override
  late final GeneratedColumn<double> minLon = GeneratedColumn<double>(
    'min_lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxLatMeta = const VerificationMeta('maxLat');
  @override
  late final GeneratedColumn<double> maxLat = GeneratedColumn<double>(
    'max_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxLonMeta = const VerificationMeta('maxLon');
  @override
  late final GeneratedColumn<double> maxLon = GeneratedColumn<double>(
    'max_lon',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jurisdictionId,
    parentZoneId,
    code,
    nameKey,
    waterType,
    zoneKind,
    geometrySource,
    minLat,
    minLon,
    maxLat,
    maxLon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zone';
  @override
  VerificationContext validateIntegrity(Insertable<ZoneRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(data['jurisdiction_id']!, _jurisdictionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('parent_zone_id')) {
      context.handle(
        _parentZoneIdMeta,
        parentZoneId.isAcceptableOrUnknown(data['parent_zone_id']!, _parentZoneIdMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(_codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(_nameKeyMeta, nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta));
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('water_type')) {
      context.handle(
        _waterTypeMeta,
        waterType.isAcceptableOrUnknown(data['water_type']!, _waterTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_waterTypeMeta);
    }
    if (data.containsKey('zone_kind')) {
      context.handle(
        _zoneKindMeta,
        zoneKind.isAcceptableOrUnknown(data['zone_kind']!, _zoneKindMeta),
      );
    } else if (isInserting) {
      context.missing(_zoneKindMeta);
    }
    if (data.containsKey('geometry_source')) {
      context.handle(
        _geometrySourceMeta,
        geometrySource.isAcceptableOrUnknown(data['geometry_source']!, _geometrySourceMeta),
      );
    }
    if (data.containsKey('min_lat')) {
      context.handle(_minLatMeta, minLat.isAcceptableOrUnknown(data['min_lat']!, _minLatMeta));
    }
    if (data.containsKey('min_lon')) {
      context.handle(_minLonMeta, minLon.isAcceptableOrUnknown(data['min_lon']!, _minLonMeta));
    }
    if (data.containsKey('max_lat')) {
      context.handle(_maxLatMeta, maxLat.isAcceptableOrUnknown(data['max_lat']!, _maxLatMeta));
    }
    if (data.containsKey('max_lon')) {
      context.handle(_maxLonMeta, maxLon.isAcceptableOrUnknown(data['max_lon']!, _maxLonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZoneRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZoneRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      parentZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_zone_id'],
      ),
      code: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      waterType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}water_type'],
      )!,
      zoneKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_kind'],
      )!,
      geometrySource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}geometry_source'],
      ),
      minLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_lat'],
      ),
      minLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_lon'],
      ),
      maxLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_lat'],
      ),
      maxLon: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_lon'],
      ),
    );
  }

  @override
  $ZonesTable createAlias(String alias) {
    return $ZonesTable(attachedDatabase, alias);
  }
}

class ZoneRow extends DataClass implements Insertable<ZoneRow> {
  final int id;
  final int jurisdictionId;

  /// A self-reference, expressed as a custom constraint rather than
  /// `references(Zones, #id)`: the latter asks the generator to order a table
  /// against itself.
  final int? parentZoneId;
  final String code;
  final String nameKey;

  /// `salt`, `fresh` or `both`. The `CHECK` is what keeps §7.3's resolution from
  /// matching nothing.
  final String waterType;

  /// The specificity ladder §7.3 step 3 sorts on: exclusion 40, reserve 30,
  /// bank/basin 20, subzone 10, region 0.
  final String zoneKind;

  /// Attribution key for the polygon source; `null` when there is no polygon.
  final String? geometrySource;

  /// The bounding box E11's point-in-polygon runs behind.
  final double? minLat;

  /// Bounding box south-west longitude.
  final double? minLon;

  /// Bounding box north-east latitude.
  final double? maxLat;

  /// Bounding box north-east longitude.
  final double? maxLon;
  const ZoneRow({
    required this.id,
    required this.jurisdictionId,
    this.parentZoneId,
    required this.code,
    required this.nameKey,
    required this.waterType,
    required this.zoneKind,
    this.geometrySource,
    this.minLat,
    this.minLon,
    this.maxLat,
    this.maxLon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jurisdiction_id'] = Variable<int>(jurisdictionId);
    if (!nullToAbsent || parentZoneId != null) {
      map['parent_zone_id'] = Variable<int>(parentZoneId);
    }
    map['code'] = Variable<String>(code);
    map['name_key'] = Variable<String>(nameKey);
    map['water_type'] = Variable<String>(waterType);
    map['zone_kind'] = Variable<String>(zoneKind);
    if (!nullToAbsent || geometrySource != null) {
      map['geometry_source'] = Variable<String>(geometrySource);
    }
    if (!nullToAbsent || minLat != null) {
      map['min_lat'] = Variable<double>(minLat);
    }
    if (!nullToAbsent || minLon != null) {
      map['min_lon'] = Variable<double>(minLon);
    }
    if (!nullToAbsent || maxLat != null) {
      map['max_lat'] = Variable<double>(maxLat);
    }
    if (!nullToAbsent || maxLon != null) {
      map['max_lon'] = Variable<double>(maxLon);
    }
    return map;
  }

  ZonesCompanion toCompanion(bool nullToAbsent) {
    return ZonesCompanion(
      id: Value(id),
      jurisdictionId: Value(jurisdictionId),
      parentZoneId: parentZoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentZoneId),
      code: Value(code),
      nameKey: Value(nameKey),
      waterType: Value(waterType),
      zoneKind: Value(zoneKind),
      geometrySource: geometrySource == null && nullToAbsent
          ? const Value.absent()
          : Value(geometrySource),
      minLat: minLat == null && nullToAbsent ? const Value.absent() : Value(minLat),
      minLon: minLon == null && nullToAbsent ? const Value.absent() : Value(minLon),
      maxLat: maxLat == null && nullToAbsent ? const Value.absent() : Value(maxLat),
      maxLon: maxLon == null && nullToAbsent ? const Value.absent() : Value(maxLon),
    );
  }

  factory ZoneRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZoneRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionId: serializer.fromJson<int>(json['jurisdictionId']),
      parentZoneId: serializer.fromJson<int?>(json['parentZoneId']),
      code: serializer.fromJson<String>(json['code']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      waterType: serializer.fromJson<String>(json['waterType']),
      zoneKind: serializer.fromJson<String>(json['zoneKind']),
      geometrySource: serializer.fromJson<String?>(json['geometrySource']),
      minLat: serializer.fromJson<double?>(json['minLat']),
      minLon: serializer.fromJson<double?>(json['minLon']),
      maxLat: serializer.fromJson<double?>(json['maxLat']),
      maxLon: serializer.fromJson<double?>(json['maxLon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionId': serializer.toJson<int>(jurisdictionId),
      'parentZoneId': serializer.toJson<int?>(parentZoneId),
      'code': serializer.toJson<String>(code),
      'nameKey': serializer.toJson<String>(nameKey),
      'waterType': serializer.toJson<String>(waterType),
      'zoneKind': serializer.toJson<String>(zoneKind),
      'geometrySource': serializer.toJson<String?>(geometrySource),
      'minLat': serializer.toJson<double?>(minLat),
      'minLon': serializer.toJson<double?>(minLon),
      'maxLat': serializer.toJson<double?>(maxLat),
      'maxLon': serializer.toJson<double?>(maxLon),
    };
  }

  ZoneRow copyWith({
    int? id,
    int? jurisdictionId,
    Value<int?> parentZoneId = const Value.absent(),
    String? code,
    String? nameKey,
    String? waterType,
    String? zoneKind,
    Value<String?> geometrySource = const Value.absent(),
    Value<double?> minLat = const Value.absent(),
    Value<double?> minLon = const Value.absent(),
    Value<double?> maxLat = const Value.absent(),
    Value<double?> maxLon = const Value.absent(),
  }) => ZoneRow(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    parentZoneId: parentZoneId.present ? parentZoneId.value : this.parentZoneId,
    code: code ?? this.code,
    nameKey: nameKey ?? this.nameKey,
    waterType: waterType ?? this.waterType,
    zoneKind: zoneKind ?? this.zoneKind,
    geometrySource: geometrySource.present ? geometrySource.value : this.geometrySource,
    minLat: minLat.present ? minLat.value : this.minLat,
    minLon: minLon.present ? minLon.value : this.minLon,
    maxLat: maxLat.present ? maxLat.value : this.maxLat,
    maxLon: maxLon.present ? maxLon.value : this.maxLon,
  );
  ZoneRow copyWithCompanion(ZonesCompanion data) {
    return ZoneRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionId: data.jurisdictionId.present ? data.jurisdictionId.value : this.jurisdictionId,
      parentZoneId: data.parentZoneId.present ? data.parentZoneId.value : this.parentZoneId,
      code: data.code.present ? data.code.value : this.code,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      waterType: data.waterType.present ? data.waterType.value : this.waterType,
      zoneKind: data.zoneKind.present ? data.zoneKind.value : this.zoneKind,
      geometrySource: data.geometrySource.present ? data.geometrySource.value : this.geometrySource,
      minLat: data.minLat.present ? data.minLat.value : this.minLat,
      minLon: data.minLon.present ? data.minLon.value : this.minLon,
      maxLat: data.maxLat.present ? data.maxLat.value : this.maxLat,
      maxLon: data.maxLon.present ? data.maxLon.value : this.maxLon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZoneRow(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('parentZoneId: $parentZoneId, ')
          ..write('code: $code, ')
          ..write('nameKey: $nameKey, ')
          ..write('waterType: $waterType, ')
          ..write('zoneKind: $zoneKind, ')
          ..write('geometrySource: $geometrySource, ')
          ..write('minLat: $minLat, ')
          ..write('minLon: $minLon, ')
          ..write('maxLat: $maxLat, ')
          ..write('maxLon: $maxLon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jurisdictionId,
    parentZoneId,
    code,
    nameKey,
    waterType,
    zoneKind,
    geometrySource,
    minLat,
    minLon,
    maxLat,
    maxLon,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZoneRow &&
          other.id == this.id &&
          other.jurisdictionId == this.jurisdictionId &&
          other.parentZoneId == this.parentZoneId &&
          other.code == this.code &&
          other.nameKey == this.nameKey &&
          other.waterType == this.waterType &&
          other.zoneKind == this.zoneKind &&
          other.geometrySource == this.geometrySource &&
          other.minLat == this.minLat &&
          other.minLon == this.minLon &&
          other.maxLat == this.maxLat &&
          other.maxLon == this.maxLon);
}

class ZonesCompanion extends UpdateCompanion<ZoneRow> {
  final Value<int> id;
  final Value<int> jurisdictionId;
  final Value<int?> parentZoneId;
  final Value<String> code;
  final Value<String> nameKey;
  final Value<String> waterType;
  final Value<String> zoneKind;
  final Value<String?> geometrySource;
  final Value<double?> minLat;
  final Value<double?> minLon;
  final Value<double?> maxLat;
  final Value<double?> maxLon;
  const ZonesCompanion({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.parentZoneId = const Value.absent(),
    this.code = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.waterType = const Value.absent(),
    this.zoneKind = const Value.absent(),
    this.geometrySource = const Value.absent(),
    this.minLat = const Value.absent(),
    this.minLon = const Value.absent(),
    this.maxLat = const Value.absent(),
    this.maxLon = const Value.absent(),
  });
  ZonesCompanion.insert({
    this.id = const Value.absent(),
    required int jurisdictionId,
    this.parentZoneId = const Value.absent(),
    required String code,
    required String nameKey,
    required String waterType,
    required String zoneKind,
    this.geometrySource = const Value.absent(),
    this.minLat = const Value.absent(),
    this.minLon = const Value.absent(),
    this.maxLat = const Value.absent(),
    this.maxLon = const Value.absent(),
  }) : jurisdictionId = Value(jurisdictionId),
       code = Value(code),
       nameKey = Value(nameKey),
       waterType = Value(waterType),
       zoneKind = Value(zoneKind);
  static Insertable<ZoneRow> custom({
    Expression<int>? id,
    Expression<int>? jurisdictionId,
    Expression<int>? parentZoneId,
    Expression<String>? code,
    Expression<String>? nameKey,
    Expression<String>? waterType,
    Expression<String>? zoneKind,
    Expression<String>? geometrySource,
    Expression<double>? minLat,
    Expression<double>? minLon,
    Expression<double>? maxLat,
    Expression<double>? maxLon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (parentZoneId != null) 'parent_zone_id': parentZoneId,
      if (code != null) 'code': code,
      if (nameKey != null) 'name_key': nameKey,
      if (waterType != null) 'water_type': waterType,
      if (zoneKind != null) 'zone_kind': zoneKind,
      if (geometrySource != null) 'geometry_source': geometrySource,
      if (minLat != null) 'min_lat': minLat,
      if (minLon != null) 'min_lon': minLon,
      if (maxLat != null) 'max_lat': maxLat,
      if (maxLon != null) 'max_lon': maxLon,
    });
  }

  ZonesCompanion copyWith({
    Value<int>? id,
    Value<int>? jurisdictionId,
    Value<int?>? parentZoneId,
    Value<String>? code,
    Value<String>? nameKey,
    Value<String>? waterType,
    Value<String>? zoneKind,
    Value<String?>? geometrySource,
    Value<double?>? minLat,
    Value<double?>? minLon,
    Value<double?>? maxLat,
    Value<double?>? maxLon,
  }) {
    return ZonesCompanion(
      id: id ?? this.id,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      parentZoneId: parentZoneId ?? this.parentZoneId,
      code: code ?? this.code,
      nameKey: nameKey ?? this.nameKey,
      waterType: waterType ?? this.waterType,
      zoneKind: zoneKind ?? this.zoneKind,
      geometrySource: geometrySource ?? this.geometrySource,
      minLat: minLat ?? this.minLat,
      minLon: minLon ?? this.minLon,
      maxLat: maxLat ?? this.maxLat,
      maxLon: maxLon ?? this.maxLon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId.value);
    }
    if (parentZoneId.present) {
      map['parent_zone_id'] = Variable<int>(parentZoneId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (waterType.present) {
      map['water_type'] = Variable<String>(waterType.value);
    }
    if (zoneKind.present) {
      map['zone_kind'] = Variable<String>(zoneKind.value);
    }
    if (geometrySource.present) {
      map['geometry_source'] = Variable<String>(geometrySource.value);
    }
    if (minLat.present) {
      map['min_lat'] = Variable<double>(minLat.value);
    }
    if (minLon.present) {
      map['min_lon'] = Variable<double>(minLon.value);
    }
    if (maxLat.present) {
      map['max_lat'] = Variable<double>(maxLat.value);
    }
    if (maxLon.present) {
      map['max_lon'] = Variable<double>(maxLon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZonesCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('parentZoneId: $parentZoneId, ')
          ..write('code: $code, ')
          ..write('nameKey: $nameKey, ')
          ..write('waterType: $waterType, ')
          ..write('zoneKind: $zoneKind, ')
          ..write('geometrySource: $geometrySource, ')
          ..write('minLat: $minLat, ')
          ..write('minLon: $minLon, ')
          ..write('maxLat: $maxLat, ')
          ..write('maxLon: $maxLon')
          ..write(')'))
        .toString();
  }
}

class $ZoneRingsTable extends ZoneRings with TableInfo<$ZoneRingsTable, ZoneRingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ZoneRingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<int> zoneId = GeneratedColumn<int>(
    'zone_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES zone(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _ringIndexMeta = const VerificationMeta('ringIndex');
  @override
  late final GeneratedColumn<int> ringIndex = GeneratedColumn<int>(
    'ring_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isHoleMeta = const VerificationMeta('isHole');
  @override
  late final GeneratedColumn<bool> isHole = GeneratedColumn<bool>(
    'is_hole',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_hole" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _pointCountMeta = const VerificationMeta('pointCount');
  @override
  late final GeneratedColumn<int> pointCount = GeneratedColumn<int>(
    'point_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coordsMeta = const VerificationMeta('coords');
  @override
  late final GeneratedColumn<Uint8List> coords = GeneratedColumn<Uint8List>(
    'coords',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, zoneId, ringIndex, isHole, pointCount, coords];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'zone_ring';
  @override
  VerificationContext validateIntegrity(
    Insertable<ZoneRingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('zone_id')) {
      context.handle(_zoneIdMeta, zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta));
    } else if (isInserting) {
      context.missing(_zoneIdMeta);
    }
    if (data.containsKey('ring_index')) {
      context.handle(
        _ringIndexMeta,
        ringIndex.isAcceptableOrUnknown(data['ring_index']!, _ringIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_ringIndexMeta);
    }
    if (data.containsKey('is_hole')) {
      context.handle(_isHoleMeta, isHole.isAcceptableOrUnknown(data['is_hole']!, _isHoleMeta));
    }
    if (data.containsKey('point_count')) {
      context.handle(
        _pointCountMeta,
        pointCount.isAcceptableOrUnknown(data['point_count']!, _pointCountMeta),
      );
    } else if (isInserting) {
      context.missing(_pointCountMeta);
    }
    if (data.containsKey('coords')) {
      context.handle(_coordsMeta, coords.isAcceptableOrUnknown(data['coords']!, _coordsMeta));
    } else if (isInserting) {
      context.missing(_coordsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ZoneRingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ZoneRingRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone_id'],
      )!,
      ringIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ring_index'],
      )!,
      isHole: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hole'],
      )!,
      pointCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}point_count'],
      )!,
      coords: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}coords'],
      )!,
    );
  }

  @override
  $ZoneRingsTable createAlias(String alias) {
    return $ZoneRingsTable(attachedDatabase, alias);
  }
}

class ZoneRingRow extends DataClass implements Insertable<ZoneRingRow> {
  final int id;
  final int zoneId;

  /// Rings are ordered; ring 0 is the outer boundary.
  final int ringIndex;

  /// Whether this ring cuts a hole out of the zone.
  final bool isHole;

  /// Derived by the build from `coords`. A hand-kept count and a hand-kept list
  /// disagree the first time a coordinate is added.
  final int pointCount;
  final Uint8List coords;
  const ZoneRingRow({
    required this.id,
    required this.zoneId,
    required this.ringIndex,
    required this.isHole,
    required this.pointCount,
    required this.coords,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['zone_id'] = Variable<int>(zoneId);
    map['ring_index'] = Variable<int>(ringIndex);
    map['is_hole'] = Variable<bool>(isHole);
    map['point_count'] = Variable<int>(pointCount);
    map['coords'] = Variable<Uint8List>(coords);
    return map;
  }

  ZoneRingsCompanion toCompanion(bool nullToAbsent) {
    return ZoneRingsCompanion(
      id: Value(id),
      zoneId: Value(zoneId),
      ringIndex: Value(ringIndex),
      isHole: Value(isHole),
      pointCount: Value(pointCount),
      coords: Value(coords),
    );
  }

  factory ZoneRingRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ZoneRingRow(
      id: serializer.fromJson<int>(json['id']),
      zoneId: serializer.fromJson<int>(json['zoneId']),
      ringIndex: serializer.fromJson<int>(json['ringIndex']),
      isHole: serializer.fromJson<bool>(json['isHole']),
      pointCount: serializer.fromJson<int>(json['pointCount']),
      coords: serializer.fromJson<Uint8List>(json['coords']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'zoneId': serializer.toJson<int>(zoneId),
      'ringIndex': serializer.toJson<int>(ringIndex),
      'isHole': serializer.toJson<bool>(isHole),
      'pointCount': serializer.toJson<int>(pointCount),
      'coords': serializer.toJson<Uint8List>(coords),
    };
  }

  ZoneRingRow copyWith({
    int? id,
    int? zoneId,
    int? ringIndex,
    bool? isHole,
    int? pointCount,
    Uint8List? coords,
  }) => ZoneRingRow(
    id: id ?? this.id,
    zoneId: zoneId ?? this.zoneId,
    ringIndex: ringIndex ?? this.ringIndex,
    isHole: isHole ?? this.isHole,
    pointCount: pointCount ?? this.pointCount,
    coords: coords ?? this.coords,
  );
  ZoneRingRow copyWithCompanion(ZoneRingsCompanion data) {
    return ZoneRingRow(
      id: data.id.present ? data.id.value : this.id,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      ringIndex: data.ringIndex.present ? data.ringIndex.value : this.ringIndex,
      isHole: data.isHole.present ? data.isHole.value : this.isHole,
      pointCount: data.pointCount.present ? data.pointCount.value : this.pointCount,
      coords: data.coords.present ? data.coords.value : this.coords,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ZoneRingRow(')
          ..write('id: $id, ')
          ..write('zoneId: $zoneId, ')
          ..write('ringIndex: $ringIndex, ')
          ..write('isHole: $isHole, ')
          ..write('pointCount: $pointCount, ')
          ..write('coords: $coords')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, zoneId, ringIndex, isHole, pointCount, $driftBlobEquality.hash(coords));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZoneRingRow &&
          other.id == this.id &&
          other.zoneId == this.zoneId &&
          other.ringIndex == this.ringIndex &&
          other.isHole == this.isHole &&
          other.pointCount == this.pointCount &&
          $driftBlobEquality.equals(other.coords, this.coords));
}

class ZoneRingsCompanion extends UpdateCompanion<ZoneRingRow> {
  final Value<int> id;
  final Value<int> zoneId;
  final Value<int> ringIndex;
  final Value<bool> isHole;
  final Value<int> pointCount;
  final Value<Uint8List> coords;
  const ZoneRingsCompanion({
    this.id = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.ringIndex = const Value.absent(),
    this.isHole = const Value.absent(),
    this.pointCount = const Value.absent(),
    this.coords = const Value.absent(),
  });
  ZoneRingsCompanion.insert({
    this.id = const Value.absent(),
    required int zoneId,
    required int ringIndex,
    this.isHole = const Value.absent(),
    required int pointCount,
    required Uint8List coords,
  }) : zoneId = Value(zoneId),
       ringIndex = Value(ringIndex),
       pointCount = Value(pointCount),
       coords = Value(coords);
  static Insertable<ZoneRingRow> custom({
    Expression<int>? id,
    Expression<int>? zoneId,
    Expression<int>? ringIndex,
    Expression<bool>? isHole,
    Expression<int>? pointCount,
    Expression<Uint8List>? coords,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (zoneId != null) 'zone_id': zoneId,
      if (ringIndex != null) 'ring_index': ringIndex,
      if (isHole != null) 'is_hole': isHole,
      if (pointCount != null) 'point_count': pointCount,
      if (coords != null) 'coords': coords,
    });
  }

  ZoneRingsCompanion copyWith({
    Value<int>? id,
    Value<int>? zoneId,
    Value<int>? ringIndex,
    Value<bool>? isHole,
    Value<int>? pointCount,
    Value<Uint8List>? coords,
  }) {
    return ZoneRingsCompanion(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      ringIndex: ringIndex ?? this.ringIndex,
      isHole: isHole ?? this.isHole,
      pointCount: pointCount ?? this.pointCount,
      coords: coords ?? this.coords,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<int>(zoneId.value);
    }
    if (ringIndex.present) {
      map['ring_index'] = Variable<int>(ringIndex.value);
    }
    if (isHole.present) {
      map['is_hole'] = Variable<bool>(isHole.value);
    }
    if (pointCount.present) {
      map['point_count'] = Variable<int>(pointCount.value);
    }
    if (coords.present) {
      map['coords'] = Variable<Uint8List>(coords.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ZoneRingsCompanion(')
          ..write('id: $id, ')
          ..write('zoneId: $zoneId, ')
          ..write('ringIndex: $ringIndex, ')
          ..write('isHole: $isHole, ')
          ..write('pointCount: $pointCount, ')
          ..write('coords: $coords')
          ..write(')'))
        .toString();
  }
}

class $FamiliesTable extends Families with TableInfo<$FamiliesTable, FamilyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamiliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scientificMeta = const VerificationMeta('scientific');
  @override
  late final GeneratedColumn<String> scientific = GeneratedColumn<String>(
    'scientific',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta('nameKey');
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, scientific, nameKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scientific')) {
      context.handle(
        _scientificMeta,
        scientific.isAcceptableOrUnknown(data['scientific']!, _scientificMeta),
      );
    } else if (isInserting) {
      context.missing(_scientificMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(_nameKeyMeta, nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta));
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      scientific: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
    );
  }

  @override
  $FamiliesTable createAlias(String alias) {
    return $FamiliesTable(attachedDatabase, alias);
  }
}

class FamilyRow extends DataClass implements Insertable<FamilyRow> {
  final int id;

  /// `Lethrinidae`. Not translated; the localised name is [nameKey].
  final String scientific;
  final String nameKey;
  const FamilyRow({required this.id, required this.scientific, required this.nameKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scientific'] = Variable<String>(scientific);
    map['name_key'] = Variable<String>(nameKey);
    return map;
  }

  FamiliesCompanion toCompanion(bool nullToAbsent) {
    return FamiliesCompanion(id: Value(id), scientific: Value(scientific), nameKey: Value(nameKey));
  }

  factory FamilyRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyRow(
      id: serializer.fromJson<int>(json['id']),
      scientific: serializer.fromJson<String>(json['scientific']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scientific': serializer.toJson<String>(scientific),
      'nameKey': serializer.toJson<String>(nameKey),
    };
  }

  FamilyRow copyWith({int? id, String? scientific, String? nameKey}) => FamilyRow(
    id: id ?? this.id,
    scientific: scientific ?? this.scientific,
    nameKey: nameKey ?? this.nameKey,
  );
  FamilyRow copyWithCompanion(FamiliesCompanion data) {
    return FamilyRow(
      id: data.id.present ? data.id.value : this.id,
      scientific: data.scientific.present ? data.scientific.value : this.scientific,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyRow(')
          ..write('id: $id, ')
          ..write('scientific: $scientific, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, scientific, nameKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyRow &&
          other.id == this.id &&
          other.scientific == this.scientific &&
          other.nameKey == this.nameKey);
}

class FamiliesCompanion extends UpdateCompanion<FamilyRow> {
  final Value<int> id;
  final Value<String> scientific;
  final Value<String> nameKey;
  const FamiliesCompanion({
    this.id = const Value.absent(),
    this.scientific = const Value.absent(),
    this.nameKey = const Value.absent(),
  });
  FamiliesCompanion.insert({
    this.id = const Value.absent(),
    required String scientific,
    required String nameKey,
  }) : scientific = Value(scientific),
       nameKey = Value(nameKey);
  static Insertable<FamilyRow> custom({
    Expression<int>? id,
    Expression<String>? scientific,
    Expression<String>? nameKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scientific != null) 'scientific': scientific,
      if (nameKey != null) 'name_key': nameKey,
    });
  }

  FamiliesCompanion copyWith({Value<int>? id, Value<String>? scientific, Value<String>? nameKey}) {
    return FamiliesCompanion(
      id: id ?? this.id,
      scientific: scientific ?? this.scientific,
      nameKey: nameKey ?? this.nameKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scientific.present) {
      map['scientific'] = Variable<String>(scientific.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamiliesCompanion(')
          ..write('id: $id, ')
          ..write('scientific: $scientific, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }
}

class $SpeciesTableTable extends SpeciesTable with TableInfo<$SpeciesTableTable, SpeciesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scientificNameMeta = const VerificationMeta('scientificName');
  @override
  late final GeneratedColumn<String> scientificName = GeneratedColumn<String>(
    'scientific_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colIdMeta = const VerificationMeta('colId');
  @override
  late final GeneratedColumn<String> colId = GeneratedColumn<String>(
    'col_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _familyIdMeta = const VerificationMeta('familyId');
  @override
  late final GeneratedColumn<int> familyId = GeneratedColumn<int>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES family(id)',
  );
  static const VerificationMeta _taxonGroupMeta = const VerificationMeta('taxonGroup');
  @override
  late final GeneratedColumn<String> taxonGroup = GeneratedColumn<String>(
    'taxon_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (taxon_group IN (\'finfish\',\'crustacean\',\'bivalve\', \'gastropod\',\'cephalopod\',\'echinoderm\',\'elasmobranch\',\'other\'))',
  );
  static const VerificationMeta _silhouetteAssetMeta = const VerificationMeta('silhouetteAsset');
  @override
  late final GeneratedColumn<String> silhouetteAsset = GeneratedColumn<String>(
    'silhouette_asset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plateAssetMeta = const VerificationMeta('plateAsset');
  @override
  late final GeneratedColumn<String> plateAsset = GeneratedColumn<String>(
    'plate_asset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scientificName,
    colId,
    familyId,
    taxonGroup,
    silhouetteAsset,
    plateAsset,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('scientific_name')) {
      context.handle(
        _scientificNameMeta,
        scientificName.isAcceptableOrUnknown(data['scientific_name']!, _scientificNameMeta),
      );
    } else if (isInserting) {
      context.missing(_scientificNameMeta);
    }
    if (data.containsKey('col_id')) {
      context.handle(_colIdMeta, colId.isAcceptableOrUnknown(data['col_id']!, _colIdMeta));
    }
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('taxon_group')) {
      context.handle(
        _taxonGroupMeta,
        taxonGroup.isAcceptableOrUnknown(data['taxon_group']!, _taxonGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_taxonGroupMeta);
    }
    if (data.containsKey('silhouette_asset')) {
      context.handle(
        _silhouetteAssetMeta,
        silhouetteAsset.isAcceptableOrUnknown(data['silhouette_asset']!, _silhouetteAssetMeta),
      );
    } else if (isInserting) {
      context.missing(_silhouetteAssetMeta);
    }
    if (data.containsKey('plate_asset')) {
      context.handle(
        _plateAssetMeta,
        plateAsset.isAcceptableOrUnknown(data['plate_asset']!, _plateAssetMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      scientificName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scientific_name'],
      )!,
      colId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}col_id'],
      ),
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}family_id'],
      )!,
      taxonGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxon_group'],
      )!,
      silhouetteAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}silhouette_asset'],
      )!,
      plateAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate_asset'],
      ),
    );
  }

  @override
  $SpeciesTableTable createAlias(String alias) {
    return $SpeciesTableTable(attachedDatabase, alias);
  }
}

class SpeciesRow extends DataClass implements Insertable<SpeciesRow> {
  final int id;
  final String scientificName;

  /// Catalogue of Life taxon id, attributed CC BY 4.0 in S17.
  final String? colId;
  final int familyId;

  /// §7.1 splits molluscs into `bivalve`, `gastropod` and `cephalopod`.
  /// Collapsing them loses S7's entry point.
  final String taxonGroup;

  /// Originated SVG line art. Required: a verdict with no picture is usable, a
  /// picture with no verdict is not.
  final String silhouetteAsset;

  /// Optional, cleared per §8's illustrator death-year test.
  final String? plateAsset;
  const SpeciesRow({
    required this.id,
    required this.scientificName,
    this.colId,
    required this.familyId,
    required this.taxonGroup,
    required this.silhouetteAsset,
    this.plateAsset,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['scientific_name'] = Variable<String>(scientificName);
    if (!nullToAbsent || colId != null) {
      map['col_id'] = Variable<String>(colId);
    }
    map['family_id'] = Variable<int>(familyId);
    map['taxon_group'] = Variable<String>(taxonGroup);
    map['silhouette_asset'] = Variable<String>(silhouetteAsset);
    if (!nullToAbsent || plateAsset != null) {
      map['plate_asset'] = Variable<String>(plateAsset);
    }
    return map;
  }

  SpeciesTableCompanion toCompanion(bool nullToAbsent) {
    return SpeciesTableCompanion(
      id: Value(id),
      scientificName: Value(scientificName),
      colId: colId == null && nullToAbsent ? const Value.absent() : Value(colId),
      familyId: Value(familyId),
      taxonGroup: Value(taxonGroup),
      silhouetteAsset: Value(silhouetteAsset),
      plateAsset: plateAsset == null && nullToAbsent ? const Value.absent() : Value(plateAsset),
    );
  }

  factory SpeciesRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesRow(
      id: serializer.fromJson<int>(json['id']),
      scientificName: serializer.fromJson<String>(json['scientificName']),
      colId: serializer.fromJson<String?>(json['colId']),
      familyId: serializer.fromJson<int>(json['familyId']),
      taxonGroup: serializer.fromJson<String>(json['taxonGroup']),
      silhouetteAsset: serializer.fromJson<String>(json['silhouetteAsset']),
      plateAsset: serializer.fromJson<String?>(json['plateAsset']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'scientificName': serializer.toJson<String>(scientificName),
      'colId': serializer.toJson<String?>(colId),
      'familyId': serializer.toJson<int>(familyId),
      'taxonGroup': serializer.toJson<String>(taxonGroup),
      'silhouetteAsset': serializer.toJson<String>(silhouetteAsset),
      'plateAsset': serializer.toJson<String?>(plateAsset),
    };
  }

  SpeciesRow copyWith({
    int? id,
    String? scientificName,
    Value<String?> colId = const Value.absent(),
    int? familyId,
    String? taxonGroup,
    String? silhouetteAsset,
    Value<String?> plateAsset = const Value.absent(),
  }) => SpeciesRow(
    id: id ?? this.id,
    scientificName: scientificName ?? this.scientificName,
    colId: colId.present ? colId.value : this.colId,
    familyId: familyId ?? this.familyId,
    taxonGroup: taxonGroup ?? this.taxonGroup,
    silhouetteAsset: silhouetteAsset ?? this.silhouetteAsset,
    plateAsset: plateAsset.present ? plateAsset.value : this.plateAsset,
  );
  SpeciesRow copyWithCompanion(SpeciesTableCompanion data) {
    return SpeciesRow(
      id: data.id.present ? data.id.value : this.id,
      scientificName: data.scientificName.present ? data.scientificName.value : this.scientificName,
      colId: data.colId.present ? data.colId.value : this.colId,
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      taxonGroup: data.taxonGroup.present ? data.taxonGroup.value : this.taxonGroup,
      silhouetteAsset: data.silhouetteAsset.present
          ? data.silhouetteAsset.value
          : this.silhouetteAsset,
      plateAsset: data.plateAsset.present ? data.plateAsset.value : this.plateAsset,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesRow(')
          ..write('id: $id, ')
          ..write('scientificName: $scientificName, ')
          ..write('colId: $colId, ')
          ..write('familyId: $familyId, ')
          ..write('taxonGroup: $taxonGroup, ')
          ..write('silhouetteAsset: $silhouetteAsset, ')
          ..write('plateAsset: $plateAsset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, scientificName, colId, familyId, taxonGroup, silhouetteAsset, plateAsset);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesRow &&
          other.id == this.id &&
          other.scientificName == this.scientificName &&
          other.colId == this.colId &&
          other.familyId == this.familyId &&
          other.taxonGroup == this.taxonGroup &&
          other.silhouetteAsset == this.silhouetteAsset &&
          other.plateAsset == this.plateAsset);
}

class SpeciesTableCompanion extends UpdateCompanion<SpeciesRow> {
  final Value<int> id;
  final Value<String> scientificName;
  final Value<String?> colId;
  final Value<int> familyId;
  final Value<String> taxonGroup;
  final Value<String> silhouetteAsset;
  final Value<String?> plateAsset;
  const SpeciesTableCompanion({
    this.id = const Value.absent(),
    this.scientificName = const Value.absent(),
    this.colId = const Value.absent(),
    this.familyId = const Value.absent(),
    this.taxonGroup = const Value.absent(),
    this.silhouetteAsset = const Value.absent(),
    this.plateAsset = const Value.absent(),
  });
  SpeciesTableCompanion.insert({
    this.id = const Value.absent(),
    required String scientificName,
    this.colId = const Value.absent(),
    required int familyId,
    required String taxonGroup,
    required String silhouetteAsset,
    this.plateAsset = const Value.absent(),
  }) : scientificName = Value(scientificName),
       familyId = Value(familyId),
       taxonGroup = Value(taxonGroup),
       silhouetteAsset = Value(silhouetteAsset);
  static Insertable<SpeciesRow> custom({
    Expression<int>? id,
    Expression<String>? scientificName,
    Expression<String>? colId,
    Expression<int>? familyId,
    Expression<String>? taxonGroup,
    Expression<String>? silhouetteAsset,
    Expression<String>? plateAsset,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scientificName != null) 'scientific_name': scientificName,
      if (colId != null) 'col_id': colId,
      if (familyId != null) 'family_id': familyId,
      if (taxonGroup != null) 'taxon_group': taxonGroup,
      if (silhouetteAsset != null) 'silhouette_asset': silhouetteAsset,
      if (plateAsset != null) 'plate_asset': plateAsset,
    });
  }

  SpeciesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? scientificName,
    Value<String?>? colId,
    Value<int>? familyId,
    Value<String>? taxonGroup,
    Value<String>? silhouetteAsset,
    Value<String?>? plateAsset,
  }) {
    return SpeciesTableCompanion(
      id: id ?? this.id,
      scientificName: scientificName ?? this.scientificName,
      colId: colId ?? this.colId,
      familyId: familyId ?? this.familyId,
      taxonGroup: taxonGroup ?? this.taxonGroup,
      silhouetteAsset: silhouetteAsset ?? this.silhouetteAsset,
      plateAsset: plateAsset ?? this.plateAsset,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (scientificName.present) {
      map['scientific_name'] = Variable<String>(scientificName.value);
    }
    if (colId.present) {
      map['col_id'] = Variable<String>(colId.value);
    }
    if (familyId.present) {
      map['family_id'] = Variable<int>(familyId.value);
    }
    if (taxonGroup.present) {
      map['taxon_group'] = Variable<String>(taxonGroup.value);
    }
    if (silhouetteAsset.present) {
      map['silhouette_asset'] = Variable<String>(silhouetteAsset.value);
    }
    if (plateAsset.present) {
      map['plate_asset'] = Variable<String>(plateAsset.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesTableCompanion(')
          ..write('id: $id, ')
          ..write('scientificName: $scientificName, ')
          ..write('colId: $colId, ')
          ..write('familyId: $familyId, ')
          ..write('taxonGroup: $taxonGroup, ')
          ..write('silhouetteAsset: $silhouetteAsset, ')
          ..write('plateAsset: $plateAsset')
          ..write(')'))
        .toString();
  }
}

class $SpeciesNamesTable extends SpeciesNames with TableInfo<$SpeciesNamesTable, SpeciesNameRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesNamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES species(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _searchNormMeta = const VerificationMeta('searchNorm');
  @override
  late final GeneratedColumn<String> searchNorm = GeneratedColumn<String>(
    'search_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (gender IN (\'m\',\'f\',\'n\'))',
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta('isPrimary');
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_primary" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _regionHintMeta = const VerificationMeta('regionHint');
  @override
  late final GeneratedColumn<String> regionHint = GeneratedColumn<String>(
    'region_hint',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    speciesId,
    locale,
    name,
    searchNorm,
    gender,
    isPrimary,
    regionHint,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_name';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesNameRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta, locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('search_norm')) {
      context.handle(
        _searchNormMeta,
        searchNorm.isAcceptableOrUnknown(data['search_norm']!, _searchNormMeta),
      );
    } else if (isInserting) {
      context.missing(_searchNormMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta, gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('region_hint')) {
      context.handle(
        _regionHintMeta,
        regionHint.isAcceptableOrUnknown(data['region_hint']!, _regionHintMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesNameRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesNameRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      searchNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_norm'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      regionHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_hint'],
      ),
    );
  }

  @override
  $SpeciesNamesTable createAlias(String alias) {
    return $SpeciesNamesTable(attachedDatabase, alias);
  }
}

class SpeciesNameRow extends DataClass implements Insertable<SpeciesNameRow> {
  final int id;
  final int speciesId;

  /// One of D-3's six: `ar`, `ca`, `en`, `es`, `gl`, `pt_BR`.
  final String locale;
  final String name;

  /// Computed by the build from the engine's own `normaliseSpeciesTerm`, never
  /// authored: a second normaliser means the index and the query disagree and
  /// Arabic search silently returns nothing.
  final String searchNorm;

  /// `m`, `f` or `n`. Required in every locale but `en` — "la mero" destroys the
  /// printed-document register the verdict is believed through.
  final String? gender;

  /// The one name S2 prints. Exactly one per (species, locale).
  final bool isPrimary;

  /// `RAK`, `Rías Baixas` — where this name is the one people use.
  final String? regionHint;
  const SpeciesNameRow({
    required this.id,
    required this.speciesId,
    required this.locale,
    required this.name,
    required this.searchNorm,
    this.gender,
    required this.isPrimary,
    this.regionHint,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['species_id'] = Variable<int>(speciesId);
    map['locale'] = Variable<String>(locale);
    map['name'] = Variable<String>(name);
    map['search_norm'] = Variable<String>(searchNorm);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    map['is_primary'] = Variable<bool>(isPrimary);
    if (!nullToAbsent || regionHint != null) {
      map['region_hint'] = Variable<String>(regionHint);
    }
    return map;
  }

  SpeciesNamesCompanion toCompanion(bool nullToAbsent) {
    return SpeciesNamesCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      locale: Value(locale),
      name: Value(name),
      searchNorm: Value(searchNorm),
      gender: gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      isPrimary: Value(isPrimary),
      regionHint: regionHint == null && nullToAbsent ? const Value.absent() : Value(regionHint),
    );
  }

  factory SpeciesNameRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesNameRow(
      id: serializer.fromJson<int>(json['id']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      locale: serializer.fromJson<String>(json['locale']),
      name: serializer.fromJson<String>(json['name']),
      searchNorm: serializer.fromJson<String>(json['searchNorm']),
      gender: serializer.fromJson<String?>(json['gender']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      regionHint: serializer.fromJson<String?>(json['regionHint']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speciesId': serializer.toJson<int>(speciesId),
      'locale': serializer.toJson<String>(locale),
      'name': serializer.toJson<String>(name),
      'searchNorm': serializer.toJson<String>(searchNorm),
      'gender': serializer.toJson<String?>(gender),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'regionHint': serializer.toJson<String?>(regionHint),
    };
  }

  SpeciesNameRow copyWith({
    int? id,
    int? speciesId,
    String? locale,
    String? name,
    String? searchNorm,
    Value<String?> gender = const Value.absent(),
    bool? isPrimary,
    Value<String?> regionHint = const Value.absent(),
  }) => SpeciesNameRow(
    id: id ?? this.id,
    speciesId: speciesId ?? this.speciesId,
    locale: locale ?? this.locale,
    name: name ?? this.name,
    searchNorm: searchNorm ?? this.searchNorm,
    gender: gender.present ? gender.value : this.gender,
    isPrimary: isPrimary ?? this.isPrimary,
    regionHint: regionHint.present ? regionHint.value : this.regionHint,
  );
  SpeciesNameRow copyWithCompanion(SpeciesNamesCompanion data) {
    return SpeciesNameRow(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      locale: data.locale.present ? data.locale.value : this.locale,
      name: data.name.present ? data.name.value : this.name,
      searchNorm: data.searchNorm.present ? data.searchNorm.value : this.searchNorm,
      gender: data.gender.present ? data.gender.value : this.gender,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      regionHint: data.regionHint.present ? data.regionHint.value : this.regionHint,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesNameRow(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('locale: $locale, ')
          ..write('name: $name, ')
          ..write('searchNorm: $searchNorm, ')
          ..write('gender: $gender, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('regionHint: $regionHint')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, speciesId, locale, name, searchNorm, gender, isPrimary, regionHint);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesNameRow &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.locale == this.locale &&
          other.name == this.name &&
          other.searchNorm == this.searchNorm &&
          other.gender == this.gender &&
          other.isPrimary == this.isPrimary &&
          other.regionHint == this.regionHint);
}

class SpeciesNamesCompanion extends UpdateCompanion<SpeciesNameRow> {
  final Value<int> id;
  final Value<int> speciesId;
  final Value<String> locale;
  final Value<String> name;
  final Value<String> searchNorm;
  final Value<String?> gender;
  final Value<bool> isPrimary;
  final Value<String?> regionHint;
  const SpeciesNamesCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.locale = const Value.absent(),
    this.name = const Value.absent(),
    this.searchNorm = const Value.absent(),
    this.gender = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.regionHint = const Value.absent(),
  });
  SpeciesNamesCompanion.insert({
    this.id = const Value.absent(),
    required int speciesId,
    required String locale,
    required String name,
    required String searchNorm,
    this.gender = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.regionHint = const Value.absent(),
  }) : speciesId = Value(speciesId),
       locale = Value(locale),
       name = Value(name),
       searchNorm = Value(searchNorm);
  static Insertable<SpeciesNameRow> custom({
    Expression<int>? id,
    Expression<int>? speciesId,
    Expression<String>? locale,
    Expression<String>? name,
    Expression<String>? searchNorm,
    Expression<String>? gender,
    Expression<bool>? isPrimary,
    Expression<String>? regionHint,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (locale != null) 'locale': locale,
      if (name != null) 'name': name,
      if (searchNorm != null) 'search_norm': searchNorm,
      if (gender != null) 'gender': gender,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (regionHint != null) 'region_hint': regionHint,
    });
  }

  SpeciesNamesCompanion copyWith({
    Value<int>? id,
    Value<int>? speciesId,
    Value<String>? locale,
    Value<String>? name,
    Value<String>? searchNorm,
    Value<String?>? gender,
    Value<bool>? isPrimary,
    Value<String?>? regionHint,
  }) {
    return SpeciesNamesCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      locale: locale ?? this.locale,
      name: name ?? this.name,
      searchNorm: searchNorm ?? this.searchNorm,
      gender: gender ?? this.gender,
      isPrimary: isPrimary ?? this.isPrimary,
      regionHint: regionHint ?? this.regionHint,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (searchNorm.present) {
      map['search_norm'] = Variable<String>(searchNorm.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (regionHint.present) {
      map['region_hint'] = Variable<String>(regionHint.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesNamesCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('locale: $locale, ')
          ..write('name: $name, ')
          ..write('searchNorm: $searchNorm, ')
          ..write('gender: $gender, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('regionHint: $regionHint')
          ..write(')'))
        .toString();
  }
}

class $MeasurementMethodsTable extends MeasurementMethods
    with TableInfo<$MeasurementMethodsTable, MeasurementMethodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta('nameKey');
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionKeyMeta = const VerificationMeta('definitionKey');
  @override
  late final GeneratedColumn<String> definitionKey = GeneratedColumn<String>(
    'definition_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diagramAssetMeta = const VerificationMeta('diagramAsset');
  @override
  late final GeneratedColumn<String> diagramAsset = GeneratedColumn<String>(
    'diagram_asset',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, code, nameKey, definitionKey, diagramAsset];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_method';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementMethodRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(_codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(_nameKeyMeta, nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta));
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('definition_key')) {
      context.handle(
        _definitionKeyMeta,
        definitionKey.isAcceptableOrUnknown(data['definition_key']!, _definitionKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionKeyMeta);
    }
    if (data.containsKey('diagram_asset')) {
      context.handle(
        _diagramAssetMeta,
        diagramAsset.isAcceptableOrUnknown(data['diagram_asset']!, _diagramAssetMeta),
      );
    } else if (isInserting) {
      context.missing(_diagramAssetMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementMethodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementMethodRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      definitionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_key'],
      )!,
      diagramAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diagram_asset'],
      )!,
    );
  }

  @override
  $MeasurementMethodsTable createAlias(String alias) {
    return $MeasurementMethodsTable(attachedDatabase, alias);
  }
}

class MeasurementMethodRow extends DataClass implements Insertable<MeasurementMethodRow> {
  final int id;

  /// `TL`, `FL`, `SL`, `CW`, `CL`, `ML`, `DW`, `SHL`, `CUSTOM`.
  final String code;
  final String nameKey;

  /// Where on the fish the measurement starts and ends.
  final String definitionKey;

  /// Originated SVG. It does not mirror in RTL: a fork-length arrow must point
  /// at the actual fork.
  final String diagramAsset;
  const MeasurementMethodRow({
    required this.id,
    required this.code,
    required this.nameKey,
    required this.definitionKey,
    required this.diagramAsset,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name_key'] = Variable<String>(nameKey);
    map['definition_key'] = Variable<String>(definitionKey);
    map['diagram_asset'] = Variable<String>(diagramAsset);
    return map;
  }

  MeasurementMethodsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementMethodsCompanion(
      id: Value(id),
      code: Value(code),
      nameKey: Value(nameKey),
      definitionKey: Value(definitionKey),
      diagramAsset: Value(diagramAsset),
    );
  }

  factory MeasurementMethodRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementMethodRow(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      definitionKey: serializer.fromJson<String>(json['definitionKey']),
      diagramAsset: serializer.fromJson<String>(json['diagramAsset']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'nameKey': serializer.toJson<String>(nameKey),
      'definitionKey': serializer.toJson<String>(definitionKey),
      'diagramAsset': serializer.toJson<String>(diagramAsset),
    };
  }

  MeasurementMethodRow copyWith({
    int? id,
    String? code,
    String? nameKey,
    String? definitionKey,
    String? diagramAsset,
  }) => MeasurementMethodRow(
    id: id ?? this.id,
    code: code ?? this.code,
    nameKey: nameKey ?? this.nameKey,
    definitionKey: definitionKey ?? this.definitionKey,
    diagramAsset: diagramAsset ?? this.diagramAsset,
  );
  MeasurementMethodRow copyWithCompanion(MeasurementMethodsCompanion data) {
    return MeasurementMethodRow(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      definitionKey: data.definitionKey.present ? data.definitionKey.value : this.definitionKey,
      diagramAsset: data.diagramAsset.present ? data.diagramAsset.value : this.diagramAsset,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementMethodRow(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nameKey: $nameKey, ')
          ..write('definitionKey: $definitionKey, ')
          ..write('diagramAsset: $diagramAsset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, nameKey, definitionKey, diagramAsset);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementMethodRow &&
          other.id == this.id &&
          other.code == this.code &&
          other.nameKey == this.nameKey &&
          other.definitionKey == this.definitionKey &&
          other.diagramAsset == this.diagramAsset);
}

class MeasurementMethodsCompanion extends UpdateCompanion<MeasurementMethodRow> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> nameKey;
  final Value<String> definitionKey;
  final Value<String> diagramAsset;
  const MeasurementMethodsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.definitionKey = const Value.absent(),
    this.diagramAsset = const Value.absent(),
  });
  MeasurementMethodsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String nameKey,
    required String definitionKey,
    required String diagramAsset,
  }) : code = Value(code),
       nameKey = Value(nameKey),
       definitionKey = Value(definitionKey),
       diagramAsset = Value(diagramAsset);
  static Insertable<MeasurementMethodRow> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? nameKey,
    Expression<String>? definitionKey,
    Expression<String>? diagramAsset,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (nameKey != null) 'name_key': nameKey,
      if (definitionKey != null) 'definition_key': definitionKey,
      if (diagramAsset != null) 'diagram_asset': diagramAsset,
    });
  }

  MeasurementMethodsCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? nameKey,
    Value<String>? definitionKey,
    Value<String>? diagramAsset,
  }) {
    return MeasurementMethodsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      nameKey: nameKey ?? this.nameKey,
      definitionKey: definitionKey ?? this.definitionKey,
      diagramAsset: diagramAsset ?? this.diagramAsset,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (definitionKey.present) {
      map['definition_key'] = Variable<String>(definitionKey.value);
    }
    if (diagramAsset.present) {
      map['diagram_asset'] = Variable<String>(diagramAsset.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementMethodsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('nameKey: $nameKey, ')
          ..write('definitionKey: $definitionKey, ')
          ..write('diagramAsset: $diagramAsset')
          ..write(')'))
        .toString();
  }
}

class $CitationsTable extends Citations with TableInfo<$CitationsTable, CitationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CitationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta('jurisdictionId');
  @override
  late final GeneratedColumn<int> jurisdictionId = GeneratedColumn<int>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdiction(id)',
  );
  static const VerificationMeta _instrumentTypeKeyMeta = const VerificationMeta(
    'instrumentTypeKey',
  );
  @override
  late final GeneratedColumn<String> instrumentTypeKey = GeneratedColumn<String>(
    'instrument_type_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instrumentRefMeta = const VerificationMeta('instrumentRef');
  @override
  late final GeneratedColumn<String> instrumentRef = GeneratedColumn<String>(
    'instrument_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleRefMeta = const VerificationMeta('articleRef');
  @override
  late final GeneratedColumn<String> articleRef = GeneratedColumn<String>(
    'article_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedOnMeta = const VerificationMeta('publishedOn');
  @override
  late final GeneratedColumn<String> publishedOn = GeneratedColumn<String>(
    'published_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta('sourceUrl');
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retrievedOnMeta = const VerificationMeta('retrievedOn');
  @override
  late final GeneratedColumn<String> retrievedOn = GeneratedColumn<String>(
    'retrieved_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jurisdictionId,
    instrumentTypeKey,
    instrumentRef,
    articleRef,
    publishedOn,
    sourceUrl,
    retrievedOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'citation';
  @override
  VerificationContext validateIntegrity(
    Insertable<CitationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(data['jurisdiction_id']!, _jurisdictionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('instrument_type_key')) {
      context.handle(
        _instrumentTypeKeyMeta,
        instrumentTypeKey.isAcceptableOrUnknown(
          data['instrument_type_key']!,
          _instrumentTypeKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instrumentTypeKeyMeta);
    }
    if (data.containsKey('instrument_ref')) {
      context.handle(
        _instrumentRefMeta,
        instrumentRef.isAcceptableOrUnknown(data['instrument_ref']!, _instrumentRefMeta),
      );
    } else if (isInserting) {
      context.missing(_instrumentRefMeta);
    }
    if (data.containsKey('article_ref')) {
      context.handle(
        _articleRefMeta,
        articleRef.isAcceptableOrUnknown(data['article_ref']!, _articleRefMeta),
      );
    }
    if (data.containsKey('published_on')) {
      context.handle(
        _publishedOnMeta,
        publishedOn.isAcceptableOrUnknown(data['published_on']!, _publishedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_publishedOnMeta);
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('retrieved_on')) {
      context.handle(
        _retrievedOnMeta,
        retrievedOn.isAcceptableOrUnknown(data['retrieved_on']!, _retrievedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_retrievedOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CitationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CitationRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      instrumentTypeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_type_key'],
      )!,
      instrumentRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instrument_ref'],
      )!,
      articleRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_ref'],
      ),
      publishedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}published_on'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      retrievedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retrieved_on'],
      )!,
    );
  }

  @override
  $CitationsTable createAlias(String alias) {
    return $CitationsTable(attachedDatabase, alias);
  }
}

class CitationRow extends DataClass implements Insertable<CitationRow> {
  final int id;
  final int jurisdictionId;

  /// Localised label for the kind of instrument — decision, orde, portaria.
  final String instrumentTypeKey;

  /// `MD 580/2015`, `Orde 27/07/2012`.
  final String instrumentRef;

  /// `Art. 3`, `Anexo II`.
  final String? articleRef;
  final String publishedOn;

  /// **Selectable text only**, and always an official gazette.
  final String? sourceUrl;

  /// The day a human opened the gazette. The footnote claims exactly that, so
  /// it is authored and never a clock reading.
  final String retrievedOn;
  const CitationRow({
    required this.id,
    required this.jurisdictionId,
    required this.instrumentTypeKey,
    required this.instrumentRef,
    this.articleRef,
    required this.publishedOn,
    this.sourceUrl,
    required this.retrievedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jurisdiction_id'] = Variable<int>(jurisdictionId);
    map['instrument_type_key'] = Variable<String>(instrumentTypeKey);
    map['instrument_ref'] = Variable<String>(instrumentRef);
    if (!nullToAbsent || articleRef != null) {
      map['article_ref'] = Variable<String>(articleRef);
    }
    map['published_on'] = Variable<String>(publishedOn);
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    map['retrieved_on'] = Variable<String>(retrievedOn);
    return map;
  }

  CitationsCompanion toCompanion(bool nullToAbsent) {
    return CitationsCompanion(
      id: Value(id),
      jurisdictionId: Value(jurisdictionId),
      instrumentTypeKey: Value(instrumentTypeKey),
      instrumentRef: Value(instrumentRef),
      articleRef: articleRef == null && nullToAbsent ? const Value.absent() : Value(articleRef),
      publishedOn: Value(publishedOn),
      sourceUrl: sourceUrl == null && nullToAbsent ? const Value.absent() : Value(sourceUrl),
      retrievedOn: Value(retrievedOn),
    );
  }

  factory CitationRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CitationRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionId: serializer.fromJson<int>(json['jurisdictionId']),
      instrumentTypeKey: serializer.fromJson<String>(json['instrumentTypeKey']),
      instrumentRef: serializer.fromJson<String>(json['instrumentRef']),
      articleRef: serializer.fromJson<String?>(json['articleRef']),
      publishedOn: serializer.fromJson<String>(json['publishedOn']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      retrievedOn: serializer.fromJson<String>(json['retrievedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionId': serializer.toJson<int>(jurisdictionId),
      'instrumentTypeKey': serializer.toJson<String>(instrumentTypeKey),
      'instrumentRef': serializer.toJson<String>(instrumentRef),
      'articleRef': serializer.toJson<String?>(articleRef),
      'publishedOn': serializer.toJson<String>(publishedOn),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'retrievedOn': serializer.toJson<String>(retrievedOn),
    };
  }

  CitationRow copyWith({
    int? id,
    int? jurisdictionId,
    String? instrumentTypeKey,
    String? instrumentRef,
    Value<String?> articleRef = const Value.absent(),
    String? publishedOn,
    Value<String?> sourceUrl = const Value.absent(),
    String? retrievedOn,
  }) => CitationRow(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    instrumentTypeKey: instrumentTypeKey ?? this.instrumentTypeKey,
    instrumentRef: instrumentRef ?? this.instrumentRef,
    articleRef: articleRef.present ? articleRef.value : this.articleRef,
    publishedOn: publishedOn ?? this.publishedOn,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    retrievedOn: retrievedOn ?? this.retrievedOn,
  );
  CitationRow copyWithCompanion(CitationsCompanion data) {
    return CitationRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionId: data.jurisdictionId.present ? data.jurisdictionId.value : this.jurisdictionId,
      instrumentTypeKey: data.instrumentTypeKey.present
          ? data.instrumentTypeKey.value
          : this.instrumentTypeKey,
      instrumentRef: data.instrumentRef.present ? data.instrumentRef.value : this.instrumentRef,
      articleRef: data.articleRef.present ? data.articleRef.value : this.articleRef,
      publishedOn: data.publishedOn.present ? data.publishedOn.value : this.publishedOn,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      retrievedOn: data.retrievedOn.present ? data.retrievedOn.value : this.retrievedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CitationRow(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('instrumentTypeKey: $instrumentTypeKey, ')
          ..write('instrumentRef: $instrumentRef, ')
          ..write('articleRef: $articleRef, ')
          ..write('publishedOn: $publishedOn, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('retrievedOn: $retrievedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jurisdictionId,
    instrumentTypeKey,
    instrumentRef,
    articleRef,
    publishedOn,
    sourceUrl,
    retrievedOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CitationRow &&
          other.id == this.id &&
          other.jurisdictionId == this.jurisdictionId &&
          other.instrumentTypeKey == this.instrumentTypeKey &&
          other.instrumentRef == this.instrumentRef &&
          other.articleRef == this.articleRef &&
          other.publishedOn == this.publishedOn &&
          other.sourceUrl == this.sourceUrl &&
          other.retrievedOn == this.retrievedOn);
}

class CitationsCompanion extends UpdateCompanion<CitationRow> {
  final Value<int> id;
  final Value<int> jurisdictionId;
  final Value<String> instrumentTypeKey;
  final Value<String> instrumentRef;
  final Value<String?> articleRef;
  final Value<String> publishedOn;
  final Value<String?> sourceUrl;
  final Value<String> retrievedOn;
  const CitationsCompanion({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.instrumentTypeKey = const Value.absent(),
    this.instrumentRef = const Value.absent(),
    this.articleRef = const Value.absent(),
    this.publishedOn = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.retrievedOn = const Value.absent(),
  });
  CitationsCompanion.insert({
    this.id = const Value.absent(),
    required int jurisdictionId,
    required String instrumentTypeKey,
    required String instrumentRef,
    this.articleRef = const Value.absent(),
    required String publishedOn,
    this.sourceUrl = const Value.absent(),
    required String retrievedOn,
  }) : jurisdictionId = Value(jurisdictionId),
       instrumentTypeKey = Value(instrumentTypeKey),
       instrumentRef = Value(instrumentRef),
       publishedOn = Value(publishedOn),
       retrievedOn = Value(retrievedOn);
  static Insertable<CitationRow> custom({
    Expression<int>? id,
    Expression<int>? jurisdictionId,
    Expression<String>? instrumentTypeKey,
    Expression<String>? instrumentRef,
    Expression<String>? articleRef,
    Expression<String>? publishedOn,
    Expression<String>? sourceUrl,
    Expression<String>? retrievedOn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (instrumentTypeKey != null) 'instrument_type_key': instrumentTypeKey,
      if (instrumentRef != null) 'instrument_ref': instrumentRef,
      if (articleRef != null) 'article_ref': articleRef,
      if (publishedOn != null) 'published_on': publishedOn,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (retrievedOn != null) 'retrieved_on': retrievedOn,
    });
  }

  CitationsCompanion copyWith({
    Value<int>? id,
    Value<int>? jurisdictionId,
    Value<String>? instrumentTypeKey,
    Value<String>? instrumentRef,
    Value<String?>? articleRef,
    Value<String>? publishedOn,
    Value<String?>? sourceUrl,
    Value<String>? retrievedOn,
  }) {
    return CitationsCompanion(
      id: id ?? this.id,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      instrumentTypeKey: instrumentTypeKey ?? this.instrumentTypeKey,
      instrumentRef: instrumentRef ?? this.instrumentRef,
      articleRef: articleRef ?? this.articleRef,
      publishedOn: publishedOn ?? this.publishedOn,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      retrievedOn: retrievedOn ?? this.retrievedOn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId.value);
    }
    if (instrumentTypeKey.present) {
      map['instrument_type_key'] = Variable<String>(instrumentTypeKey.value);
    }
    if (instrumentRef.present) {
      map['instrument_ref'] = Variable<String>(instrumentRef.value);
    }
    if (articleRef.present) {
      map['article_ref'] = Variable<String>(articleRef.value);
    }
    if (publishedOn.present) {
      map['published_on'] = Variable<String>(publishedOn.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (retrievedOn.present) {
      map['retrieved_on'] = Variable<String>(retrievedOn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CitationsCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('instrumentTypeKey: $instrumentTypeKey, ')
          ..write('instrumentRef: $instrumentRef, ')
          ..write('articleRef: $articleRef, ')
          ..write('publishedOn: $publishedOn, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('retrievedOn: $retrievedOn')
          ..write(')'))
        .toString();
  }
}

class $RulesTable extends Rules with TableInfo<$RulesTable, RuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta('jurisdictionId');
  @override
  late final GeneratedColumn<int> jurisdictionId = GeneratedColumn<int>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdiction(id)',
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<int> zoneId = GeneratedColumn<int>(
    'zone_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES zone(id)',
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES species(id)',
  );
  static const VerificationMeta _waterTypeMeta = const VerificationMeta('waterType');
  @override
  late final GeneratedColumn<String> waterType = GeneratedColumn<String>(
    'water_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (water_type IN (\'salt\',\'fresh\',\'both\'))',
  );
  static const VerificationMeta _minSizeMmMeta = const VerificationMeta('minSizeMm');
  @override
  late final GeneratedColumn<int> minSizeMm = GeneratedColumn<int>(
    'min_size_mm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxSizeMmMeta = const VerificationMeta('maxSizeMm');
  @override
  late final GeneratedColumn<int> maxSizeMm = GeneratedColumn<int>(
    'max_size_mm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _measurementMethodIdMeta = const VerificationMeta(
    'measurementMethodId',
  );
  @override
  late final GeneratedColumn<int> measurementMethodId = GeneratedColumn<int>(
    'measurement_method_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES measurement_method(id)',
  );
  static const VerificationMeta _bagLimitMeta = const VerificationMeta('bagLimit');
  @override
  late final GeneratedColumn<int> bagLimit = GeneratedColumn<int>(
    'bag_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bagLimitUnitMeta = const VerificationMeta('bagLimitUnit');
  @override
  late final GeneratedColumn<String> bagLimitUnit = GeneratedColumn<String>(
    'bag_limit_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (bag_limit_unit IN (\'count\',\'kg\'))',
  );
  static const VerificationMeta _bagLimitPeriodMeta = const VerificationMeta('bagLimitPeriod');
  @override
  late final GeneratedColumn<String> bagLimitPeriod = GeneratedColumn<String>(
    'bag_limit_period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (bag_limit_period IN (\'day\',\'trip\',\'season\'))',
  );
  static const VerificationMeta _vesselLimitMeta = const VerificationMeta('vesselLimit');
  @override
  late final GeneratedColumn<int> vesselLimit = GeneratedColumn<int>(
    'vessel_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isProtectedMeta = const VerificationMeta('isProtected');
  @override
  late final GeneratedColumn<bool> isProtected = GeneratedColumn<bool>(
    'is_protected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_protected" IN (0, 1))'),
    defaultValue: const Constant<bool>(false),
  );
  static const VerificationMeta _licenceTypeIdMeta = const VerificationMeta('licenceTypeId');
  @override
  late final GeneratedColumn<int> licenceTypeId = GeneratedColumn<int>(
    'licence_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES licence_type(id)',
  );
  static const VerificationMeta _notesKeyMeta = const VerificationMeta('notesKey');
  @override
  late final GeneratedColumn<String> notesKey = GeneratedColumn<String>(
    'notes_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _citationIdMeta = const VerificationMeta('citationId');
  @override
  late final GeneratedColumn<int> citationId = GeneratedColumn<int>(
    'citation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES citation(id)',
  );
  static const VerificationMeta _validFromMeta = const VerificationMeta('validFrom');
  @override
  late final GeneratedColumn<String> validFrom = GeneratedColumn<String>(
    'valid_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validToMeta = const VerificationMeta('validTo');
  @override
  late final GeneratedColumn<String> validTo = GeneratedColumn<String>(
    'valid_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specificityMeta = const VerificationMeta('specificity');
  @override
  late final GeneratedColumn<int> specificity = GeneratedColumn<int>(
    'specificity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jurisdictionId,
    zoneId,
    speciesId,
    waterType,
    minSizeMm,
    maxSizeMm,
    measurementMethodId,
    bagLimit,
    bagLimitUnit,
    bagLimitPeriod,
    vesselLimit,
    isProtected,
    licenceTypeId,
    notesKey,
    citationId,
    validFrom,
    validTo,
    specificity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rule';
  @override
  VerificationContext validateIntegrity(Insertable<RuleRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(data['jurisdiction_id']!, _jurisdictionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(_zoneIdMeta, zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('water_type')) {
      context.handle(
        _waterTypeMeta,
        waterType.isAcceptableOrUnknown(data['water_type']!, _waterTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_waterTypeMeta);
    }
    if (data.containsKey('min_size_mm')) {
      context.handle(
        _minSizeMmMeta,
        minSizeMm.isAcceptableOrUnknown(data['min_size_mm']!, _minSizeMmMeta),
      );
    }
    if (data.containsKey('max_size_mm')) {
      context.handle(
        _maxSizeMmMeta,
        maxSizeMm.isAcceptableOrUnknown(data['max_size_mm']!, _maxSizeMmMeta),
      );
    }
    if (data.containsKey('measurement_method_id')) {
      context.handle(
        _measurementMethodIdMeta,
        measurementMethodId.isAcceptableOrUnknown(
          data['measurement_method_id']!,
          _measurementMethodIdMeta,
        ),
      );
    }
    if (data.containsKey('bag_limit')) {
      context.handle(
        _bagLimitMeta,
        bagLimit.isAcceptableOrUnknown(data['bag_limit']!, _bagLimitMeta),
      );
    }
    if (data.containsKey('bag_limit_unit')) {
      context.handle(
        _bagLimitUnitMeta,
        bagLimitUnit.isAcceptableOrUnknown(data['bag_limit_unit']!, _bagLimitUnitMeta),
      );
    }
    if (data.containsKey('bag_limit_period')) {
      context.handle(
        _bagLimitPeriodMeta,
        bagLimitPeriod.isAcceptableOrUnknown(data['bag_limit_period']!, _bagLimitPeriodMeta),
      );
    }
    if (data.containsKey('vessel_limit')) {
      context.handle(
        _vesselLimitMeta,
        vesselLimit.isAcceptableOrUnknown(data['vessel_limit']!, _vesselLimitMeta),
      );
    }
    if (data.containsKey('is_protected')) {
      context.handle(
        _isProtectedMeta,
        isProtected.isAcceptableOrUnknown(data['is_protected']!, _isProtectedMeta),
      );
    }
    if (data.containsKey('licence_type_id')) {
      context.handle(
        _licenceTypeIdMeta,
        licenceTypeId.isAcceptableOrUnknown(data['licence_type_id']!, _licenceTypeIdMeta),
      );
    }
    if (data.containsKey('notes_key')) {
      context.handle(
        _notesKeyMeta,
        notesKey.isAcceptableOrUnknown(data['notes_key']!, _notesKeyMeta),
      );
    }
    if (data.containsKey('citation_id')) {
      context.handle(
        _citationIdMeta,
        citationId.isAcceptableOrUnknown(data['citation_id']!, _citationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_citationIdMeta);
    }
    if (data.containsKey('valid_from')) {
      context.handle(
        _validFromMeta,
        validFrom.isAcceptableOrUnknown(data['valid_from']!, _validFromMeta),
      );
    } else if (isInserting) {
      context.missing(_validFromMeta);
    }
    if (data.containsKey('valid_to')) {
      context.handle(_validToMeta, validTo.isAcceptableOrUnknown(data['valid_to']!, _validToMeta));
    }
    if (data.containsKey('specificity')) {
      context.handle(
        _specificityMeta,
        specificity.isAcceptableOrUnknown(data['specificity']!, _specificityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RuleRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone_id'],
      ),
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      waterType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}water_type'],
      )!,
      minSizeMm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_size_mm'],
      ),
      maxSizeMm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_size_mm'],
      ),
      measurementMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measurement_method_id'],
      ),
      bagLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bag_limit'],
      ),
      bagLimitUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bag_limit_unit'],
      ),
      bagLimitPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bag_limit_period'],
      ),
      vesselLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vessel_limit'],
      ),
      isProtected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_protected'],
      )!,
      licenceTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}licence_type_id'],
      ),
      notesKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes_key'],
      ),
      citationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}citation_id'],
      )!,
      validFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_from'],
      )!,
      validTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valid_to'],
      ),
      specificity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}specificity'],
      )!,
    );
  }

  @override
  $RulesTable createAlias(String alias) {
    return $RulesTable(attachedDatabase, alias);
  }
}

class RuleRow extends DataClass implements Insertable<RuleRow> {
  final int id;
  final int jurisdictionId;

  /// `null` means the whole jurisdiction.
  final int? zoneId;
  final int speciesId;
  final String waterType;

  /// Millimetres, always. A `45` meant as centimetres is wrong by a factor of
  /// ten and validates cleanly, which is why A1 range-checks it by taxon group.
  final int? minSizeMm;
  final int? maxSizeMm;
  final int? measurementMethodId;
  final int? bagLimit;
  final String? bagLimitUnit;
  final String? bagLimitPeriod;

  /// A per-vessel cap, distinct from the per-person bag limit.
  final int? vesselLimit;
  final bool isProtected;
  final int? licenceTypeId;
  final String? notesKey;
  final int citationId;
  final String validFrom;

  /// **Expiry does not delete** (§7.3). A lapsed *orde de vedas* is still
  /// evaluated and still shown, behind the ochre bar.
  final String? validTo;
  final int specificity;
  const RuleRow({
    required this.id,
    required this.jurisdictionId,
    this.zoneId,
    required this.speciesId,
    required this.waterType,
    this.minSizeMm,
    this.maxSizeMm,
    this.measurementMethodId,
    this.bagLimit,
    this.bagLimitUnit,
    this.bagLimitPeriod,
    this.vesselLimit,
    required this.isProtected,
    this.licenceTypeId,
    this.notesKey,
    required this.citationId,
    required this.validFrom,
    this.validTo,
    required this.specificity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jurisdiction_id'] = Variable<int>(jurisdictionId);
    if (!nullToAbsent || zoneId != null) {
      map['zone_id'] = Variable<int>(zoneId);
    }
    map['species_id'] = Variable<int>(speciesId);
    map['water_type'] = Variable<String>(waterType);
    if (!nullToAbsent || minSizeMm != null) {
      map['min_size_mm'] = Variable<int>(minSizeMm);
    }
    if (!nullToAbsent || maxSizeMm != null) {
      map['max_size_mm'] = Variable<int>(maxSizeMm);
    }
    if (!nullToAbsent || measurementMethodId != null) {
      map['measurement_method_id'] = Variable<int>(measurementMethodId);
    }
    if (!nullToAbsent || bagLimit != null) {
      map['bag_limit'] = Variable<int>(bagLimit);
    }
    if (!nullToAbsent || bagLimitUnit != null) {
      map['bag_limit_unit'] = Variable<String>(bagLimitUnit);
    }
    if (!nullToAbsent || bagLimitPeriod != null) {
      map['bag_limit_period'] = Variable<String>(bagLimitPeriod);
    }
    if (!nullToAbsent || vesselLimit != null) {
      map['vessel_limit'] = Variable<int>(vesselLimit);
    }
    map['is_protected'] = Variable<bool>(isProtected);
    if (!nullToAbsent || licenceTypeId != null) {
      map['licence_type_id'] = Variable<int>(licenceTypeId);
    }
    if (!nullToAbsent || notesKey != null) {
      map['notes_key'] = Variable<String>(notesKey);
    }
    map['citation_id'] = Variable<int>(citationId);
    map['valid_from'] = Variable<String>(validFrom);
    if (!nullToAbsent || validTo != null) {
      map['valid_to'] = Variable<String>(validTo);
    }
    map['specificity'] = Variable<int>(specificity);
    return map;
  }

  RulesCompanion toCompanion(bool nullToAbsent) {
    return RulesCompanion(
      id: Value(id),
      jurisdictionId: Value(jurisdictionId),
      zoneId: zoneId == null && nullToAbsent ? const Value.absent() : Value(zoneId),
      speciesId: Value(speciesId),
      waterType: Value(waterType),
      minSizeMm: minSizeMm == null && nullToAbsent ? const Value.absent() : Value(minSizeMm),
      maxSizeMm: maxSizeMm == null && nullToAbsent ? const Value.absent() : Value(maxSizeMm),
      measurementMethodId: measurementMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(measurementMethodId),
      bagLimit: bagLimit == null && nullToAbsent ? const Value.absent() : Value(bagLimit),
      bagLimitUnit: bagLimitUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(bagLimitUnit),
      bagLimitPeriod: bagLimitPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(bagLimitPeriod),
      vesselLimit: vesselLimit == null && nullToAbsent ? const Value.absent() : Value(vesselLimit),
      isProtected: Value(isProtected),
      licenceTypeId: licenceTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(licenceTypeId),
      notesKey: notesKey == null && nullToAbsent ? const Value.absent() : Value(notesKey),
      citationId: Value(citationId),
      validFrom: Value(validFrom),
      validTo: validTo == null && nullToAbsent ? const Value.absent() : Value(validTo),
      specificity: Value(specificity),
    );
  }

  factory RuleRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RuleRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionId: serializer.fromJson<int>(json['jurisdictionId']),
      zoneId: serializer.fromJson<int?>(json['zoneId']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      waterType: serializer.fromJson<String>(json['waterType']),
      minSizeMm: serializer.fromJson<int?>(json['minSizeMm']),
      maxSizeMm: serializer.fromJson<int?>(json['maxSizeMm']),
      measurementMethodId: serializer.fromJson<int?>(json['measurementMethodId']),
      bagLimit: serializer.fromJson<int?>(json['bagLimit']),
      bagLimitUnit: serializer.fromJson<String?>(json['bagLimitUnit']),
      bagLimitPeriod: serializer.fromJson<String?>(json['bagLimitPeriod']),
      vesselLimit: serializer.fromJson<int?>(json['vesselLimit']),
      isProtected: serializer.fromJson<bool>(json['isProtected']),
      licenceTypeId: serializer.fromJson<int?>(json['licenceTypeId']),
      notesKey: serializer.fromJson<String?>(json['notesKey']),
      citationId: serializer.fromJson<int>(json['citationId']),
      validFrom: serializer.fromJson<String>(json['validFrom']),
      validTo: serializer.fromJson<String?>(json['validTo']),
      specificity: serializer.fromJson<int>(json['specificity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionId': serializer.toJson<int>(jurisdictionId),
      'zoneId': serializer.toJson<int?>(zoneId),
      'speciesId': serializer.toJson<int>(speciesId),
      'waterType': serializer.toJson<String>(waterType),
      'minSizeMm': serializer.toJson<int?>(minSizeMm),
      'maxSizeMm': serializer.toJson<int?>(maxSizeMm),
      'measurementMethodId': serializer.toJson<int?>(measurementMethodId),
      'bagLimit': serializer.toJson<int?>(bagLimit),
      'bagLimitUnit': serializer.toJson<String?>(bagLimitUnit),
      'bagLimitPeriod': serializer.toJson<String?>(bagLimitPeriod),
      'vesselLimit': serializer.toJson<int?>(vesselLimit),
      'isProtected': serializer.toJson<bool>(isProtected),
      'licenceTypeId': serializer.toJson<int?>(licenceTypeId),
      'notesKey': serializer.toJson<String?>(notesKey),
      'citationId': serializer.toJson<int>(citationId),
      'validFrom': serializer.toJson<String>(validFrom),
      'validTo': serializer.toJson<String?>(validTo),
      'specificity': serializer.toJson<int>(specificity),
    };
  }

  RuleRow copyWith({
    int? id,
    int? jurisdictionId,
    Value<int?> zoneId = const Value.absent(),
    int? speciesId,
    String? waterType,
    Value<int?> minSizeMm = const Value.absent(),
    Value<int?> maxSizeMm = const Value.absent(),
    Value<int?> measurementMethodId = const Value.absent(),
    Value<int?> bagLimit = const Value.absent(),
    Value<String?> bagLimitUnit = const Value.absent(),
    Value<String?> bagLimitPeriod = const Value.absent(),
    Value<int?> vesselLimit = const Value.absent(),
    bool? isProtected,
    Value<int?> licenceTypeId = const Value.absent(),
    Value<String?> notesKey = const Value.absent(),
    int? citationId,
    String? validFrom,
    Value<String?> validTo = const Value.absent(),
    int? specificity,
  }) => RuleRow(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    zoneId: zoneId.present ? zoneId.value : this.zoneId,
    speciesId: speciesId ?? this.speciesId,
    waterType: waterType ?? this.waterType,
    minSizeMm: minSizeMm.present ? minSizeMm.value : this.minSizeMm,
    maxSizeMm: maxSizeMm.present ? maxSizeMm.value : this.maxSizeMm,
    measurementMethodId: measurementMethodId.present
        ? measurementMethodId.value
        : this.measurementMethodId,
    bagLimit: bagLimit.present ? bagLimit.value : this.bagLimit,
    bagLimitUnit: bagLimitUnit.present ? bagLimitUnit.value : this.bagLimitUnit,
    bagLimitPeriod: bagLimitPeriod.present ? bagLimitPeriod.value : this.bagLimitPeriod,
    vesselLimit: vesselLimit.present ? vesselLimit.value : this.vesselLimit,
    isProtected: isProtected ?? this.isProtected,
    licenceTypeId: licenceTypeId.present ? licenceTypeId.value : this.licenceTypeId,
    notesKey: notesKey.present ? notesKey.value : this.notesKey,
    citationId: citationId ?? this.citationId,
    validFrom: validFrom ?? this.validFrom,
    validTo: validTo.present ? validTo.value : this.validTo,
    specificity: specificity ?? this.specificity,
  );
  RuleRow copyWithCompanion(RulesCompanion data) {
    return RuleRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionId: data.jurisdictionId.present ? data.jurisdictionId.value : this.jurisdictionId,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      waterType: data.waterType.present ? data.waterType.value : this.waterType,
      minSizeMm: data.minSizeMm.present ? data.minSizeMm.value : this.minSizeMm,
      maxSizeMm: data.maxSizeMm.present ? data.maxSizeMm.value : this.maxSizeMm,
      measurementMethodId: data.measurementMethodId.present
          ? data.measurementMethodId.value
          : this.measurementMethodId,
      bagLimit: data.bagLimit.present ? data.bagLimit.value : this.bagLimit,
      bagLimitUnit: data.bagLimitUnit.present ? data.bagLimitUnit.value : this.bagLimitUnit,
      bagLimitPeriod: data.bagLimitPeriod.present ? data.bagLimitPeriod.value : this.bagLimitPeriod,
      vesselLimit: data.vesselLimit.present ? data.vesselLimit.value : this.vesselLimit,
      isProtected: data.isProtected.present ? data.isProtected.value : this.isProtected,
      licenceTypeId: data.licenceTypeId.present ? data.licenceTypeId.value : this.licenceTypeId,
      notesKey: data.notesKey.present ? data.notesKey.value : this.notesKey,
      citationId: data.citationId.present ? data.citationId.value : this.citationId,
      validFrom: data.validFrom.present ? data.validFrom.value : this.validFrom,
      validTo: data.validTo.present ? data.validTo.value : this.validTo,
      specificity: data.specificity.present ? data.specificity.value : this.specificity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RuleRow(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('zoneId: $zoneId, ')
          ..write('speciesId: $speciesId, ')
          ..write('waterType: $waterType, ')
          ..write('minSizeMm: $minSizeMm, ')
          ..write('maxSizeMm: $maxSizeMm, ')
          ..write('measurementMethodId: $measurementMethodId, ')
          ..write('bagLimit: $bagLimit, ')
          ..write('bagLimitUnit: $bagLimitUnit, ')
          ..write('bagLimitPeriod: $bagLimitPeriod, ')
          ..write('vesselLimit: $vesselLimit, ')
          ..write('isProtected: $isProtected, ')
          ..write('licenceTypeId: $licenceTypeId, ')
          ..write('notesKey: $notesKey, ')
          ..write('citationId: $citationId, ')
          ..write('validFrom: $validFrom, ')
          ..write('validTo: $validTo, ')
          ..write('specificity: $specificity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jurisdictionId,
    zoneId,
    speciesId,
    waterType,
    minSizeMm,
    maxSizeMm,
    measurementMethodId,
    bagLimit,
    bagLimitUnit,
    bagLimitPeriod,
    vesselLimit,
    isProtected,
    licenceTypeId,
    notesKey,
    citationId,
    validFrom,
    validTo,
    specificity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RuleRow &&
          other.id == this.id &&
          other.jurisdictionId == this.jurisdictionId &&
          other.zoneId == this.zoneId &&
          other.speciesId == this.speciesId &&
          other.waterType == this.waterType &&
          other.minSizeMm == this.minSizeMm &&
          other.maxSizeMm == this.maxSizeMm &&
          other.measurementMethodId == this.measurementMethodId &&
          other.bagLimit == this.bagLimit &&
          other.bagLimitUnit == this.bagLimitUnit &&
          other.bagLimitPeriod == this.bagLimitPeriod &&
          other.vesselLimit == this.vesselLimit &&
          other.isProtected == this.isProtected &&
          other.licenceTypeId == this.licenceTypeId &&
          other.notesKey == this.notesKey &&
          other.citationId == this.citationId &&
          other.validFrom == this.validFrom &&
          other.validTo == this.validTo &&
          other.specificity == this.specificity);
}

class RulesCompanion extends UpdateCompanion<RuleRow> {
  final Value<int> id;
  final Value<int> jurisdictionId;
  final Value<int?> zoneId;
  final Value<int> speciesId;
  final Value<String> waterType;
  final Value<int?> minSizeMm;
  final Value<int?> maxSizeMm;
  final Value<int?> measurementMethodId;
  final Value<int?> bagLimit;
  final Value<String?> bagLimitUnit;
  final Value<String?> bagLimitPeriod;
  final Value<int?> vesselLimit;
  final Value<bool> isProtected;
  final Value<int?> licenceTypeId;
  final Value<String?> notesKey;
  final Value<int> citationId;
  final Value<String> validFrom;
  final Value<String?> validTo;
  final Value<int> specificity;
  const RulesCompanion({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.waterType = const Value.absent(),
    this.minSizeMm = const Value.absent(),
    this.maxSizeMm = const Value.absent(),
    this.measurementMethodId = const Value.absent(),
    this.bagLimit = const Value.absent(),
    this.bagLimitUnit = const Value.absent(),
    this.bagLimitPeriod = const Value.absent(),
    this.vesselLimit = const Value.absent(),
    this.isProtected = const Value.absent(),
    this.licenceTypeId = const Value.absent(),
    this.notesKey = const Value.absent(),
    this.citationId = const Value.absent(),
    this.validFrom = const Value.absent(),
    this.validTo = const Value.absent(),
    this.specificity = const Value.absent(),
  });
  RulesCompanion.insert({
    this.id = const Value.absent(),
    required int jurisdictionId,
    this.zoneId = const Value.absent(),
    required int speciesId,
    required String waterType,
    this.minSizeMm = const Value.absent(),
    this.maxSizeMm = const Value.absent(),
    this.measurementMethodId = const Value.absent(),
    this.bagLimit = const Value.absent(),
    this.bagLimitUnit = const Value.absent(),
    this.bagLimitPeriod = const Value.absent(),
    this.vesselLimit = const Value.absent(),
    this.isProtected = const Value.absent(),
    this.licenceTypeId = const Value.absent(),
    this.notesKey = const Value.absent(),
    required int citationId,
    required String validFrom,
    this.validTo = const Value.absent(),
    this.specificity = const Value.absent(),
  }) : jurisdictionId = Value(jurisdictionId),
       speciesId = Value(speciesId),
       waterType = Value(waterType),
       citationId = Value(citationId),
       validFrom = Value(validFrom);
  static Insertable<RuleRow> custom({
    Expression<int>? id,
    Expression<int>? jurisdictionId,
    Expression<int>? zoneId,
    Expression<int>? speciesId,
    Expression<String>? waterType,
    Expression<int>? minSizeMm,
    Expression<int>? maxSizeMm,
    Expression<int>? measurementMethodId,
    Expression<int>? bagLimit,
    Expression<String>? bagLimitUnit,
    Expression<String>? bagLimitPeriod,
    Expression<int>? vesselLimit,
    Expression<bool>? isProtected,
    Expression<int>? licenceTypeId,
    Expression<String>? notesKey,
    Expression<int>? citationId,
    Expression<String>? validFrom,
    Expression<String>? validTo,
    Expression<int>? specificity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (zoneId != null) 'zone_id': zoneId,
      if (speciesId != null) 'species_id': speciesId,
      if (waterType != null) 'water_type': waterType,
      if (minSizeMm != null) 'min_size_mm': minSizeMm,
      if (maxSizeMm != null) 'max_size_mm': maxSizeMm,
      if (measurementMethodId != null) 'measurement_method_id': measurementMethodId,
      if (bagLimit != null) 'bag_limit': bagLimit,
      if (bagLimitUnit != null) 'bag_limit_unit': bagLimitUnit,
      if (bagLimitPeriod != null) 'bag_limit_period': bagLimitPeriod,
      if (vesselLimit != null) 'vessel_limit': vesselLimit,
      if (isProtected != null) 'is_protected': isProtected,
      if (licenceTypeId != null) 'licence_type_id': licenceTypeId,
      if (notesKey != null) 'notes_key': notesKey,
      if (citationId != null) 'citation_id': citationId,
      if (validFrom != null) 'valid_from': validFrom,
      if (validTo != null) 'valid_to': validTo,
      if (specificity != null) 'specificity': specificity,
    });
  }

  RulesCompanion copyWith({
    Value<int>? id,
    Value<int>? jurisdictionId,
    Value<int?>? zoneId,
    Value<int>? speciesId,
    Value<String>? waterType,
    Value<int?>? minSizeMm,
    Value<int?>? maxSizeMm,
    Value<int?>? measurementMethodId,
    Value<int?>? bagLimit,
    Value<String?>? bagLimitUnit,
    Value<String?>? bagLimitPeriod,
    Value<int?>? vesselLimit,
    Value<bool>? isProtected,
    Value<int?>? licenceTypeId,
    Value<String?>? notesKey,
    Value<int>? citationId,
    Value<String>? validFrom,
    Value<String?>? validTo,
    Value<int>? specificity,
  }) {
    return RulesCompanion(
      id: id ?? this.id,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      zoneId: zoneId ?? this.zoneId,
      speciesId: speciesId ?? this.speciesId,
      waterType: waterType ?? this.waterType,
      minSizeMm: minSizeMm ?? this.minSizeMm,
      maxSizeMm: maxSizeMm ?? this.maxSizeMm,
      measurementMethodId: measurementMethodId ?? this.measurementMethodId,
      bagLimit: bagLimit ?? this.bagLimit,
      bagLimitUnit: bagLimitUnit ?? this.bagLimitUnit,
      bagLimitPeriod: bagLimitPeriod ?? this.bagLimitPeriod,
      vesselLimit: vesselLimit ?? this.vesselLimit,
      isProtected: isProtected ?? this.isProtected,
      licenceTypeId: licenceTypeId ?? this.licenceTypeId,
      notesKey: notesKey ?? this.notesKey,
      citationId: citationId ?? this.citationId,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      specificity: specificity ?? this.specificity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<int>(zoneId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (waterType.present) {
      map['water_type'] = Variable<String>(waterType.value);
    }
    if (minSizeMm.present) {
      map['min_size_mm'] = Variable<int>(minSizeMm.value);
    }
    if (maxSizeMm.present) {
      map['max_size_mm'] = Variable<int>(maxSizeMm.value);
    }
    if (measurementMethodId.present) {
      map['measurement_method_id'] = Variable<int>(measurementMethodId.value);
    }
    if (bagLimit.present) {
      map['bag_limit'] = Variable<int>(bagLimit.value);
    }
    if (bagLimitUnit.present) {
      map['bag_limit_unit'] = Variable<String>(bagLimitUnit.value);
    }
    if (bagLimitPeriod.present) {
      map['bag_limit_period'] = Variable<String>(bagLimitPeriod.value);
    }
    if (vesselLimit.present) {
      map['vessel_limit'] = Variable<int>(vesselLimit.value);
    }
    if (isProtected.present) {
      map['is_protected'] = Variable<bool>(isProtected.value);
    }
    if (licenceTypeId.present) {
      map['licence_type_id'] = Variable<int>(licenceTypeId.value);
    }
    if (notesKey.present) {
      map['notes_key'] = Variable<String>(notesKey.value);
    }
    if (citationId.present) {
      map['citation_id'] = Variable<int>(citationId.value);
    }
    if (validFrom.present) {
      map['valid_from'] = Variable<String>(validFrom.value);
    }
    if (validTo.present) {
      map['valid_to'] = Variable<String>(validTo.value);
    }
    if (specificity.present) {
      map['specificity'] = Variable<int>(specificity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulesCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('zoneId: $zoneId, ')
          ..write('speciesId: $speciesId, ')
          ..write('waterType: $waterType, ')
          ..write('minSizeMm: $minSizeMm, ')
          ..write('maxSizeMm: $maxSizeMm, ')
          ..write('measurementMethodId: $measurementMethodId, ')
          ..write('bagLimit: $bagLimit, ')
          ..write('bagLimitUnit: $bagLimitUnit, ')
          ..write('bagLimitPeriod: $bagLimitPeriod, ')
          ..write('vesselLimit: $vesselLimit, ')
          ..write('isProtected: $isProtected, ')
          ..write('licenceTypeId: $licenceTypeId, ')
          ..write('notesKey: $notesKey, ')
          ..write('citationId: $citationId, ')
          ..write('validFrom: $validFrom, ')
          ..write('validTo: $validTo, ')
          ..write('specificity: $specificity')
          ..write(')'))
        .toString();
  }
}

class $ClosedSeasonsTable extends ClosedSeasons
    with TableInfo<$ClosedSeasonsTable, ClosedSeasonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClosedSeasonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<int> ruleId = GeneratedColumn<int>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES rule(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta('recurrence');
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (recurrence IN (\'annual\',\'fixed\'))',
  );
  static const VerificationMeta _startMonthMeta = const VerificationMeta('startMonth');
  @override
  late final GeneratedColumn<int> startMonth = GeneratedColumn<int>(
    'start_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDayMeta = const VerificationMeta('startDay');
  @override
  late final GeneratedColumn<int> startDay = GeneratedColumn<int>(
    'start_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMonthMeta = const VerificationMeta('endMonth');
  @override
  late final GeneratedColumn<int> endMonth = GeneratedColumn<int>(
    'end_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDayMeta = const VerificationMeta('endDay');
  @override
  late final GeneratedColumn<int> endDay = GeneratedColumn<int>(
    'end_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesKeyMeta = const VerificationMeta('notesKey');
  @override
  late final GeneratedColumn<String> notesKey = GeneratedColumn<String>(
    'notes_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _citationIdMeta = const VerificationMeta('citationId');
  @override
  late final GeneratedColumn<int> citationId = GeneratedColumn<int>(
    'citation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES citation(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ruleId,
    recurrence,
    startMonth,
    startDay,
    endMonth,
    endDay,
    startDate,
    endDate,
    notesKey,
    citationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'closed_season';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClosedSeasonRow> instance, {
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
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    } else if (isInserting) {
      context.missing(_recurrenceMeta);
    }
    if (data.containsKey('start_month')) {
      context.handle(
        _startMonthMeta,
        startMonth.isAcceptableOrUnknown(data['start_month']!, _startMonthMeta),
      );
    }
    if (data.containsKey('start_day')) {
      context.handle(
        _startDayMeta,
        startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta),
      );
    }
    if (data.containsKey('end_month')) {
      context.handle(
        _endMonthMeta,
        endMonth.isAcceptableOrUnknown(data['end_month']!, _endMonthMeta),
      );
    }
    if (data.containsKey('end_day')) {
      context.handle(_endDayMeta, endDay.isAcceptableOrUnknown(data['end_day']!, _endDayMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta, endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('notes_key')) {
      context.handle(
        _notesKeyMeta,
        notesKey.isAcceptableOrUnknown(data['notes_key']!, _notesKeyMeta),
      );
    }
    if (data.containsKey('citation_id')) {
      context.handle(
        _citationIdMeta,
        citationId.isAcceptableOrUnknown(data['citation_id']!, _citationIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClosedSeasonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClosedSeasonRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rule_id'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      startMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_month'],
      ),
      startDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_day'],
      ),
      endMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_month'],
      ),
      endDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_day'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      ),
      notesKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes_key'],
      ),
      citationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}citation_id'],
      ),
    );
  }

  @override
  $ClosedSeasonsTable createAlias(String alias) {
    return $ClosedSeasonsTable(attachedDatabase, alias);
  }
}

class ClosedSeasonRow extends DataClass implements Insertable<ClosedSeasonRow> {
  final int id;
  final int ruleId;
  final String recurrence;
  final int? startMonth;
  final int? startDay;
  final int? endMonth;
  final int? endDay;
  final String? startDate;
  final String? endDate;
  final String? notesKey;
  final int? citationId;
  const ClosedSeasonRow({
    required this.id,
    required this.ruleId,
    required this.recurrence,
    this.startMonth,
    this.startDay,
    this.endMonth,
    this.endDay,
    this.startDate,
    this.endDate,
    this.notesKey,
    this.citationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rule_id'] = Variable<int>(ruleId);
    map['recurrence'] = Variable<String>(recurrence);
    if (!nullToAbsent || startMonth != null) {
      map['start_month'] = Variable<int>(startMonth);
    }
    if (!nullToAbsent || startDay != null) {
      map['start_day'] = Variable<int>(startDay);
    }
    if (!nullToAbsent || endMonth != null) {
      map['end_month'] = Variable<int>(endMonth);
    }
    if (!nullToAbsent || endDay != null) {
      map['end_day'] = Variable<int>(endDay);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    if (!nullToAbsent || notesKey != null) {
      map['notes_key'] = Variable<String>(notesKey);
    }
    if (!nullToAbsent || citationId != null) {
      map['citation_id'] = Variable<int>(citationId);
    }
    return map;
  }

  ClosedSeasonsCompanion toCompanion(bool nullToAbsent) {
    return ClosedSeasonsCompanion(
      id: Value(id),
      ruleId: Value(ruleId),
      recurrence: Value(recurrence),
      startMonth: startMonth == null && nullToAbsent ? const Value.absent() : Value(startMonth),
      startDay: startDay == null && nullToAbsent ? const Value.absent() : Value(startDay),
      endMonth: endMonth == null && nullToAbsent ? const Value.absent() : Value(endMonth),
      endDay: endDay == null && nullToAbsent ? const Value.absent() : Value(endDay),
      startDate: startDate == null && nullToAbsent ? const Value.absent() : Value(startDate),
      endDate: endDate == null && nullToAbsent ? const Value.absent() : Value(endDate),
      notesKey: notesKey == null && nullToAbsent ? const Value.absent() : Value(notesKey),
      citationId: citationId == null && nullToAbsent ? const Value.absent() : Value(citationId),
    );
  }

  factory ClosedSeasonRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClosedSeasonRow(
      id: serializer.fromJson<int>(json['id']),
      ruleId: serializer.fromJson<int>(json['ruleId']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      startMonth: serializer.fromJson<int?>(json['startMonth']),
      startDay: serializer.fromJson<int?>(json['startDay']),
      endMonth: serializer.fromJson<int?>(json['endMonth']),
      endDay: serializer.fromJson<int?>(json['endDay']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      notesKey: serializer.fromJson<String?>(json['notesKey']),
      citationId: serializer.fromJson<int?>(json['citationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ruleId': serializer.toJson<int>(ruleId),
      'recurrence': serializer.toJson<String>(recurrence),
      'startMonth': serializer.toJson<int?>(startMonth),
      'startDay': serializer.toJson<int?>(startDay),
      'endMonth': serializer.toJson<int?>(endMonth),
      'endDay': serializer.toJson<int?>(endDay),
      'startDate': serializer.toJson<String?>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'notesKey': serializer.toJson<String?>(notesKey),
      'citationId': serializer.toJson<int?>(citationId),
    };
  }

  ClosedSeasonRow copyWith({
    int? id,
    int? ruleId,
    String? recurrence,
    Value<int?> startMonth = const Value.absent(),
    Value<int?> startDay = const Value.absent(),
    Value<int?> endMonth = const Value.absent(),
    Value<int?> endDay = const Value.absent(),
    Value<String?> startDate = const Value.absent(),
    Value<String?> endDate = const Value.absent(),
    Value<String?> notesKey = const Value.absent(),
    Value<int?> citationId = const Value.absent(),
  }) => ClosedSeasonRow(
    id: id ?? this.id,
    ruleId: ruleId ?? this.ruleId,
    recurrence: recurrence ?? this.recurrence,
    startMonth: startMonth.present ? startMonth.value : this.startMonth,
    startDay: startDay.present ? startDay.value : this.startDay,
    endMonth: endMonth.present ? endMonth.value : this.endMonth,
    endDay: endDay.present ? endDay.value : this.endDay,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    notesKey: notesKey.present ? notesKey.value : this.notesKey,
    citationId: citationId.present ? citationId.value : this.citationId,
  );
  ClosedSeasonRow copyWithCompanion(ClosedSeasonsCompanion data) {
    return ClosedSeasonRow(
      id: data.id.present ? data.id.value : this.id,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      recurrence: data.recurrence.present ? data.recurrence.value : this.recurrence,
      startMonth: data.startMonth.present ? data.startMonth.value : this.startMonth,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
      endMonth: data.endMonth.present ? data.endMonth.value : this.endMonth,
      endDay: data.endDay.present ? data.endDay.value : this.endDay,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      notesKey: data.notesKey.present ? data.notesKey.value : this.notesKey,
      citationId: data.citationId.present ? data.citationId.value : this.citationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClosedSeasonRow(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('recurrence: $recurrence, ')
          ..write('startMonth: $startMonth, ')
          ..write('startDay: $startDay, ')
          ..write('endMonth: $endMonth, ')
          ..write('endDay: $endDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notesKey: $notesKey, ')
          ..write('citationId: $citationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ruleId,
    recurrence,
    startMonth,
    startDay,
    endMonth,
    endDay,
    startDate,
    endDate,
    notesKey,
    citationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClosedSeasonRow &&
          other.id == this.id &&
          other.ruleId == this.ruleId &&
          other.recurrence == this.recurrence &&
          other.startMonth == this.startMonth &&
          other.startDay == this.startDay &&
          other.endMonth == this.endMonth &&
          other.endDay == this.endDay &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.notesKey == this.notesKey &&
          other.citationId == this.citationId);
}

class ClosedSeasonsCompanion extends UpdateCompanion<ClosedSeasonRow> {
  final Value<int> id;
  final Value<int> ruleId;
  final Value<String> recurrence;
  final Value<int?> startMonth;
  final Value<int?> startDay;
  final Value<int?> endMonth;
  final Value<int?> endDay;
  final Value<String?> startDate;
  final Value<String?> endDate;
  final Value<String?> notesKey;
  final Value<int?> citationId;
  const ClosedSeasonsCompanion({
    this.id = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endMonth = const Value.absent(),
    this.endDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notesKey = const Value.absent(),
    this.citationId = const Value.absent(),
  });
  ClosedSeasonsCompanion.insert({
    this.id = const Value.absent(),
    required int ruleId,
    required String recurrence,
    this.startMonth = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endMonth = const Value.absent(),
    this.endDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.notesKey = const Value.absent(),
    this.citationId = const Value.absent(),
  }) : ruleId = Value(ruleId),
       recurrence = Value(recurrence);
  static Insertable<ClosedSeasonRow> custom({
    Expression<int>? id,
    Expression<int>? ruleId,
    Expression<String>? recurrence,
    Expression<int>? startMonth,
    Expression<int>? startDay,
    Expression<int>? endMonth,
    Expression<int>? endDay,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? notesKey,
    Expression<int>? citationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ruleId != null) 'rule_id': ruleId,
      if (recurrence != null) 'recurrence': recurrence,
      if (startMonth != null) 'start_month': startMonth,
      if (startDay != null) 'start_day': startDay,
      if (endMonth != null) 'end_month': endMonth,
      if (endDay != null) 'end_day': endDay,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (notesKey != null) 'notes_key': notesKey,
      if (citationId != null) 'citation_id': citationId,
    });
  }

  ClosedSeasonsCompanion copyWith({
    Value<int>? id,
    Value<int>? ruleId,
    Value<String>? recurrence,
    Value<int?>? startMonth,
    Value<int?>? startDay,
    Value<int?>? endMonth,
    Value<int?>? endDay,
    Value<String?>? startDate,
    Value<String?>? endDate,
    Value<String?>? notesKey,
    Value<int?>? citationId,
  }) {
    return ClosedSeasonsCompanion(
      id: id ?? this.id,
      ruleId: ruleId ?? this.ruleId,
      recurrence: recurrence ?? this.recurrence,
      startMonth: startMonth ?? this.startMonth,
      startDay: startDay ?? this.startDay,
      endMonth: endMonth ?? this.endMonth,
      endDay: endDay ?? this.endDay,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notesKey: notesKey ?? this.notesKey,
      citationId: citationId ?? this.citationId,
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
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (startMonth.present) {
      map['start_month'] = Variable<int>(startMonth.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<int>(startDay.value);
    }
    if (endMonth.present) {
      map['end_month'] = Variable<int>(endMonth.value);
    }
    if (endDay.present) {
      map['end_day'] = Variable<int>(endDay.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (notesKey.present) {
      map['notes_key'] = Variable<String>(notesKey.value);
    }
    if (citationId.present) {
      map['citation_id'] = Variable<int>(citationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClosedSeasonsCompanion(')
          ..write('id: $id, ')
          ..write('ruleId: $ruleId, ')
          ..write('recurrence: $recurrence, ')
          ..write('startMonth: $startMonth, ')
          ..write('startDay: $startDay, ')
          ..write('endMonth: $endMonth, ')
          ..write('endDay: $endDay, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('notesKey: $notesKey, ')
          ..write('citationId: $citationId')
          ..write(')'))
        .toString();
  }
}

class $LicenceTypesTable extends LicenceTypes with TableInfo<$LicenceTypesTable, LicenceTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LicenceTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta('jurisdictionId');
  @override
  late final GeneratedColumn<int> jurisdictionId = GeneratedColumn<int>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdiction(id)',
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<int> zoneId = GeneratedColumn<int>(
    'zone_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES zone(id)',
  );
  static const VerificationMeta _waterTypeMeta = const VerificationMeta('waterType');
  @override
  late final GeneratedColumn<String> waterType = GeneratedColumn<String>(
    'water_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (water_type IN (\'salt\',\'fresh\',\'both\'))',
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta('nameKey');
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionKeyMeta = const VerificationMeta('descriptionKey');
  @override
  late final GeneratedColumn<String> descriptionKey = GeneratedColumn<String>(
    'description_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _citationIdMeta = const VerificationMeta('citationId');
  @override
  late final GeneratedColumn<int> citationId = GeneratedColumn<int>(
    'citation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES citation(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jurisdictionId,
    zoneId,
    waterType,
    code,
    nameKey,
    descriptionKey,
    citationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'licence_type';
  @override
  VerificationContext validateIntegrity(
    Insertable<LicenceTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(data['jurisdiction_id']!, _jurisdictionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(_zoneIdMeta, zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta));
    }
    if (data.containsKey('water_type')) {
      context.handle(
        _waterTypeMeta,
        waterType.isAcceptableOrUnknown(data['water_type']!, _waterTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_waterTypeMeta);
    }
    if (data.containsKey('code')) {
      context.handle(_codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(_nameKeyMeta, nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta));
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('description_key')) {
      context.handle(
        _descriptionKeyMeta,
        descriptionKey.isAcceptableOrUnknown(data['description_key']!, _descriptionKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_descriptionKeyMeta);
    }
    if (data.containsKey('citation_id')) {
      context.handle(
        _citationIdMeta,
        citationId.isAcceptableOrUnknown(data['citation_id']!, _citationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_citationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LicenceTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LicenceTypeRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone_id'],
      ),
      waterType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}water_type'],
      )!,
      code: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      descriptionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description_key'],
      )!,
      citationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}citation_id'],
      )!,
    );
  }

  @override
  $LicenceTypesTable createAlias(String alias) {
    return $LicenceTypesTable(attachedDatabase, alias);
  }
}

class LicenceTypeRow extends DataClass implements Insertable<LicenceTypeRow> {
  final int id;
  final int jurisdictionId;
  final int? zoneId;
  final String waterType;
  final String code;
  final String nameKey;

  /// It states what the instrument says and never what to do about it.
  final String descriptionKey;
  final int citationId;
  const LicenceTypeRow({
    required this.id,
    required this.jurisdictionId,
    this.zoneId,
    required this.waterType,
    required this.code,
    required this.nameKey,
    required this.descriptionKey,
    required this.citationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jurisdiction_id'] = Variable<int>(jurisdictionId);
    if (!nullToAbsent || zoneId != null) {
      map['zone_id'] = Variable<int>(zoneId);
    }
    map['water_type'] = Variable<String>(waterType);
    map['code'] = Variable<String>(code);
    map['name_key'] = Variable<String>(nameKey);
    map['description_key'] = Variable<String>(descriptionKey);
    map['citation_id'] = Variable<int>(citationId);
    return map;
  }

  LicenceTypesCompanion toCompanion(bool nullToAbsent) {
    return LicenceTypesCompanion(
      id: Value(id),
      jurisdictionId: Value(jurisdictionId),
      zoneId: zoneId == null && nullToAbsent ? const Value.absent() : Value(zoneId),
      waterType: Value(waterType),
      code: Value(code),
      nameKey: Value(nameKey),
      descriptionKey: Value(descriptionKey),
      citationId: Value(citationId),
    );
  }

  factory LicenceTypeRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LicenceTypeRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionId: serializer.fromJson<int>(json['jurisdictionId']),
      zoneId: serializer.fromJson<int?>(json['zoneId']),
      waterType: serializer.fromJson<String>(json['waterType']),
      code: serializer.fromJson<String>(json['code']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      descriptionKey: serializer.fromJson<String>(json['descriptionKey']),
      citationId: serializer.fromJson<int>(json['citationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionId': serializer.toJson<int>(jurisdictionId),
      'zoneId': serializer.toJson<int?>(zoneId),
      'waterType': serializer.toJson<String>(waterType),
      'code': serializer.toJson<String>(code),
      'nameKey': serializer.toJson<String>(nameKey),
      'descriptionKey': serializer.toJson<String>(descriptionKey),
      'citationId': serializer.toJson<int>(citationId),
    };
  }

  LicenceTypeRow copyWith({
    int? id,
    int? jurisdictionId,
    Value<int?> zoneId = const Value.absent(),
    String? waterType,
    String? code,
    String? nameKey,
    String? descriptionKey,
    int? citationId,
  }) => LicenceTypeRow(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    zoneId: zoneId.present ? zoneId.value : this.zoneId,
    waterType: waterType ?? this.waterType,
    code: code ?? this.code,
    nameKey: nameKey ?? this.nameKey,
    descriptionKey: descriptionKey ?? this.descriptionKey,
    citationId: citationId ?? this.citationId,
  );
  LicenceTypeRow copyWithCompanion(LicenceTypesCompanion data) {
    return LicenceTypeRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionId: data.jurisdictionId.present ? data.jurisdictionId.value : this.jurisdictionId,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      waterType: data.waterType.present ? data.waterType.value : this.waterType,
      code: data.code.present ? data.code.value : this.code,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      descriptionKey: data.descriptionKey.present ? data.descriptionKey.value : this.descriptionKey,
      citationId: data.citationId.present ? data.citationId.value : this.citationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LicenceTypeRow(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('zoneId: $zoneId, ')
          ..write('waterType: $waterType, ')
          ..write('code: $code, ')
          ..write('nameKey: $nameKey, ')
          ..write('descriptionKey: $descriptionKey, ')
          ..write('citationId: $citationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, jurisdictionId, zoneId, waterType, code, nameKey, descriptionKey, citationId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LicenceTypeRow &&
          other.id == this.id &&
          other.jurisdictionId == this.jurisdictionId &&
          other.zoneId == this.zoneId &&
          other.waterType == this.waterType &&
          other.code == this.code &&
          other.nameKey == this.nameKey &&
          other.descriptionKey == this.descriptionKey &&
          other.citationId == this.citationId);
}

class LicenceTypesCompanion extends UpdateCompanion<LicenceTypeRow> {
  final Value<int> id;
  final Value<int> jurisdictionId;
  final Value<int?> zoneId;
  final Value<String> waterType;
  final Value<String> code;
  final Value<String> nameKey;
  final Value<String> descriptionKey;
  final Value<int> citationId;
  const LicenceTypesCompanion({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.waterType = const Value.absent(),
    this.code = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.descriptionKey = const Value.absent(),
    this.citationId = const Value.absent(),
  });
  LicenceTypesCompanion.insert({
    this.id = const Value.absent(),
    required int jurisdictionId,
    this.zoneId = const Value.absent(),
    required String waterType,
    required String code,
    required String nameKey,
    required String descriptionKey,
    required int citationId,
  }) : jurisdictionId = Value(jurisdictionId),
       waterType = Value(waterType),
       code = Value(code),
       nameKey = Value(nameKey),
       descriptionKey = Value(descriptionKey),
       citationId = Value(citationId);
  static Insertable<LicenceTypeRow> custom({
    Expression<int>? id,
    Expression<int>? jurisdictionId,
    Expression<int>? zoneId,
    Expression<String>? waterType,
    Expression<String>? code,
    Expression<String>? nameKey,
    Expression<String>? descriptionKey,
    Expression<int>? citationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (zoneId != null) 'zone_id': zoneId,
      if (waterType != null) 'water_type': waterType,
      if (code != null) 'code': code,
      if (nameKey != null) 'name_key': nameKey,
      if (descriptionKey != null) 'description_key': descriptionKey,
      if (citationId != null) 'citation_id': citationId,
    });
  }

  LicenceTypesCompanion copyWith({
    Value<int>? id,
    Value<int>? jurisdictionId,
    Value<int?>? zoneId,
    Value<String>? waterType,
    Value<String>? code,
    Value<String>? nameKey,
    Value<String>? descriptionKey,
    Value<int>? citationId,
  }) {
    return LicenceTypesCompanion(
      id: id ?? this.id,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      zoneId: zoneId ?? this.zoneId,
      waterType: waterType ?? this.waterType,
      code: code ?? this.code,
      nameKey: nameKey ?? this.nameKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      citationId: citationId ?? this.citationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<int>(zoneId.value);
    }
    if (waterType.present) {
      map['water_type'] = Variable<String>(waterType.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (descriptionKey.present) {
      map['description_key'] = Variable<String>(descriptionKey.value);
    }
    if (citationId.present) {
      map['citation_id'] = Variable<int>(citationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LicenceTypesCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('zoneId: $zoneId, ')
          ..write('waterType: $waterType, ')
          ..write('code: $code, ')
          ..write('nameKey: $nameKey, ')
          ..write('descriptionKey: $descriptionKey, ')
          ..write('citationId: $citationId')
          ..write(')'))
        .toString();
  }
}

class $GearRulesTable extends GearRules with TableInfo<$GearRulesTable, GearRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GearRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta('jurisdictionId');
  @override
  late final GeneratedColumn<int> jurisdictionId = GeneratedColumn<int>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdiction(id)',
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<int> zoneId = GeneratedColumn<int>(
    'zone_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES zone(id)',
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES species(id)',
  );
  static const VerificationMeta _gearCodeMeta = const VerificationMeta('gearCode');
  @override
  late final GeneratedColumn<String> gearCode = GeneratedColumn<String>(
    'gear_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gearNameKeyMeta = const VerificationMeta('gearNameKey');
  @override
  late final GeneratedColumn<String> gearNameKey = GeneratedColumn<String>(
    'gear_name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isAllowedMeta = const VerificationMeta('isAllowed');
  @override
  late final GeneratedColumn<bool> isAllowed = GeneratedColumn<bool>(
    'is_allowed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_allowed" IN (0, 1))'),
  );
  static const VerificationMeta _constraintKeyMeta = const VerificationMeta('constraintKey');
  @override
  late final GeneratedColumn<String> constraintKey = GeneratedColumn<String>(
    'constraint_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _citationIdMeta = const VerificationMeta('citationId');
  @override
  late final GeneratedColumn<int> citationId = GeneratedColumn<int>(
    'citation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES citation(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jurisdictionId,
    zoneId,
    speciesId,
    gearCode,
    gearNameKey,
    isAllowed,
    constraintKey,
    citationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gear_rule';
  @override
  VerificationContext validateIntegrity(
    Insertable<GearRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(data['jurisdiction_id']!, _jurisdictionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(_zoneIdMeta, zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    }
    if (data.containsKey('gear_code')) {
      context.handle(
        _gearCodeMeta,
        gearCode.isAcceptableOrUnknown(data['gear_code']!, _gearCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_gearCodeMeta);
    }
    if (data.containsKey('gear_name_key')) {
      context.handle(
        _gearNameKeyMeta,
        gearNameKey.isAcceptableOrUnknown(data['gear_name_key']!, _gearNameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_gearNameKeyMeta);
    }
    if (data.containsKey('is_allowed')) {
      context.handle(
        _isAllowedMeta,
        isAllowed.isAcceptableOrUnknown(data['is_allowed']!, _isAllowedMeta),
      );
    } else if (isInserting) {
      context.missing(_isAllowedMeta);
    }
    if (data.containsKey('constraint_key')) {
      context.handle(
        _constraintKeyMeta,
        constraintKey.isAcceptableOrUnknown(data['constraint_key']!, _constraintKeyMeta),
      );
    }
    if (data.containsKey('citation_id')) {
      context.handle(
        _citationIdMeta,
        citationId.isAcceptableOrUnknown(data['citation_id']!, _citationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_citationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GearRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GearRuleRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zone_id'],
      ),
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      ),
      gearCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gear_code'],
      )!,
      gearNameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gear_name_key'],
      )!,
      isAllowed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_allowed'],
      )!,
      constraintKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}constraint_key'],
      ),
      citationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}citation_id'],
      )!,
    );
  }

  @override
  $GearRulesTable createAlias(String alias) {
    return $GearRulesTable(attachedDatabase, alias);
  }
}

class GearRuleRow extends DataClass implements Insertable<GearRuleRow> {
  final int id;
  final int jurisdictionId;
  final int? zoneId;

  /// `null` means every species.
  final int? speciesId;
  final String gearCode;
  final String gearNameKey;
  final bool isAllowed;

  /// Localised constraint, e.g. a minimum mesh.
  final String? constraintKey;
  final int citationId;
  const GearRuleRow({
    required this.id,
    required this.jurisdictionId,
    this.zoneId,
    this.speciesId,
    required this.gearCode,
    required this.gearNameKey,
    required this.isAllowed,
    this.constraintKey,
    required this.citationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jurisdiction_id'] = Variable<int>(jurisdictionId);
    if (!nullToAbsent || zoneId != null) {
      map['zone_id'] = Variable<int>(zoneId);
    }
    if (!nullToAbsent || speciesId != null) {
      map['species_id'] = Variable<int>(speciesId);
    }
    map['gear_code'] = Variable<String>(gearCode);
    map['gear_name_key'] = Variable<String>(gearNameKey);
    map['is_allowed'] = Variable<bool>(isAllowed);
    if (!nullToAbsent || constraintKey != null) {
      map['constraint_key'] = Variable<String>(constraintKey);
    }
    map['citation_id'] = Variable<int>(citationId);
    return map;
  }

  GearRulesCompanion toCompanion(bool nullToAbsent) {
    return GearRulesCompanion(
      id: Value(id),
      jurisdictionId: Value(jurisdictionId),
      zoneId: zoneId == null && nullToAbsent ? const Value.absent() : Value(zoneId),
      speciesId: speciesId == null && nullToAbsent ? const Value.absent() : Value(speciesId),
      gearCode: Value(gearCode),
      gearNameKey: Value(gearNameKey),
      isAllowed: Value(isAllowed),
      constraintKey: constraintKey == null && nullToAbsent
          ? const Value.absent()
          : Value(constraintKey),
      citationId: Value(citationId),
    );
  }

  factory GearRuleRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GearRuleRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionId: serializer.fromJson<int>(json['jurisdictionId']),
      zoneId: serializer.fromJson<int?>(json['zoneId']),
      speciesId: serializer.fromJson<int?>(json['speciesId']),
      gearCode: serializer.fromJson<String>(json['gearCode']),
      gearNameKey: serializer.fromJson<String>(json['gearNameKey']),
      isAllowed: serializer.fromJson<bool>(json['isAllowed']),
      constraintKey: serializer.fromJson<String?>(json['constraintKey']),
      citationId: serializer.fromJson<int>(json['citationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionId': serializer.toJson<int>(jurisdictionId),
      'zoneId': serializer.toJson<int?>(zoneId),
      'speciesId': serializer.toJson<int?>(speciesId),
      'gearCode': serializer.toJson<String>(gearCode),
      'gearNameKey': serializer.toJson<String>(gearNameKey),
      'isAllowed': serializer.toJson<bool>(isAllowed),
      'constraintKey': serializer.toJson<String?>(constraintKey),
      'citationId': serializer.toJson<int>(citationId),
    };
  }

  GearRuleRow copyWith({
    int? id,
    int? jurisdictionId,
    Value<int?> zoneId = const Value.absent(),
    Value<int?> speciesId = const Value.absent(),
    String? gearCode,
    String? gearNameKey,
    bool? isAllowed,
    Value<String?> constraintKey = const Value.absent(),
    int? citationId,
  }) => GearRuleRow(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    zoneId: zoneId.present ? zoneId.value : this.zoneId,
    speciesId: speciesId.present ? speciesId.value : this.speciesId,
    gearCode: gearCode ?? this.gearCode,
    gearNameKey: gearNameKey ?? this.gearNameKey,
    isAllowed: isAllowed ?? this.isAllowed,
    constraintKey: constraintKey.present ? constraintKey.value : this.constraintKey,
    citationId: citationId ?? this.citationId,
  );
  GearRuleRow copyWithCompanion(GearRulesCompanion data) {
    return GearRuleRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionId: data.jurisdictionId.present ? data.jurisdictionId.value : this.jurisdictionId,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      gearCode: data.gearCode.present ? data.gearCode.value : this.gearCode,
      gearNameKey: data.gearNameKey.present ? data.gearNameKey.value : this.gearNameKey,
      isAllowed: data.isAllowed.present ? data.isAllowed.value : this.isAllowed,
      constraintKey: data.constraintKey.present ? data.constraintKey.value : this.constraintKey,
      citationId: data.citationId.present ? data.citationId.value : this.citationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GearRuleRow(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('zoneId: $zoneId, ')
          ..write('speciesId: $speciesId, ')
          ..write('gearCode: $gearCode, ')
          ..write('gearNameKey: $gearNameKey, ')
          ..write('isAllowed: $isAllowed, ')
          ..write('constraintKey: $constraintKey, ')
          ..write('citationId: $citationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jurisdictionId,
    zoneId,
    speciesId,
    gearCode,
    gearNameKey,
    isAllowed,
    constraintKey,
    citationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GearRuleRow &&
          other.id == this.id &&
          other.jurisdictionId == this.jurisdictionId &&
          other.zoneId == this.zoneId &&
          other.speciesId == this.speciesId &&
          other.gearCode == this.gearCode &&
          other.gearNameKey == this.gearNameKey &&
          other.isAllowed == this.isAllowed &&
          other.constraintKey == this.constraintKey &&
          other.citationId == this.citationId);
}

class GearRulesCompanion extends UpdateCompanion<GearRuleRow> {
  final Value<int> id;
  final Value<int> jurisdictionId;
  final Value<int?> zoneId;
  final Value<int?> speciesId;
  final Value<String> gearCode;
  final Value<String> gearNameKey;
  final Value<bool> isAllowed;
  final Value<String?> constraintKey;
  final Value<int> citationId;
  const GearRulesCompanion({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.gearCode = const Value.absent(),
    this.gearNameKey = const Value.absent(),
    this.isAllowed = const Value.absent(),
    this.constraintKey = const Value.absent(),
    this.citationId = const Value.absent(),
  });
  GearRulesCompanion.insert({
    this.id = const Value.absent(),
    required int jurisdictionId,
    this.zoneId = const Value.absent(),
    this.speciesId = const Value.absent(),
    required String gearCode,
    required String gearNameKey,
    required bool isAllowed,
    this.constraintKey = const Value.absent(),
    required int citationId,
  }) : jurisdictionId = Value(jurisdictionId),
       gearCode = Value(gearCode),
       gearNameKey = Value(gearNameKey),
       isAllowed = Value(isAllowed),
       citationId = Value(citationId);
  static Insertable<GearRuleRow> custom({
    Expression<int>? id,
    Expression<int>? jurisdictionId,
    Expression<int>? zoneId,
    Expression<int>? speciesId,
    Expression<String>? gearCode,
    Expression<String>? gearNameKey,
    Expression<bool>? isAllowed,
    Expression<String>? constraintKey,
    Expression<int>? citationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (zoneId != null) 'zone_id': zoneId,
      if (speciesId != null) 'species_id': speciesId,
      if (gearCode != null) 'gear_code': gearCode,
      if (gearNameKey != null) 'gear_name_key': gearNameKey,
      if (isAllowed != null) 'is_allowed': isAllowed,
      if (constraintKey != null) 'constraint_key': constraintKey,
      if (citationId != null) 'citation_id': citationId,
    });
  }

  GearRulesCompanion copyWith({
    Value<int>? id,
    Value<int>? jurisdictionId,
    Value<int?>? zoneId,
    Value<int?>? speciesId,
    Value<String>? gearCode,
    Value<String>? gearNameKey,
    Value<bool>? isAllowed,
    Value<String?>? constraintKey,
    Value<int>? citationId,
  }) {
    return GearRulesCompanion(
      id: id ?? this.id,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      zoneId: zoneId ?? this.zoneId,
      speciesId: speciesId ?? this.speciesId,
      gearCode: gearCode ?? this.gearCode,
      gearNameKey: gearNameKey ?? this.gearNameKey,
      isAllowed: isAllowed ?? this.isAllowed,
      constraintKey: constraintKey ?? this.constraintKey,
      citationId: citationId ?? this.citationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<int>(zoneId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (gearCode.present) {
      map['gear_code'] = Variable<String>(gearCode.value);
    }
    if (gearNameKey.present) {
      map['gear_name_key'] = Variable<String>(gearNameKey.value);
    }
    if (isAllowed.present) {
      map['is_allowed'] = Variable<bool>(isAllowed.value);
    }
    if (constraintKey.present) {
      map['constraint_key'] = Variable<String>(constraintKey.value);
    }
    if (citationId.present) {
      map['citation_id'] = Variable<int>(citationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GearRulesCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('zoneId: $zoneId, ')
          ..write('speciesId: $speciesId, ')
          ..write('gearCode: $gearCode, ')
          ..write('gearNameKey: $gearNameKey, ')
          ..write('isAllowed: $isAllowed, ')
          ..write('constraintKey: $constraintKey, ')
          ..write('citationId: $citationId')
          ..write(')'))
        .toString();
  }
}

class $PenaltiesTable extends Penalties with TableInfo<$PenaltiesTable, PenaltyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PenaltiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta('jurisdictionId');
  @override
  late final GeneratedColumn<int> jurisdictionId = GeneratedColumn<int>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdiction(id)',
  );
  static const VerificationMeta _offenceKeyMeta = const VerificationMeta('offenceKey');
  @override
  late final GeneratedColumn<String> offenceKey = GeneratedColumn<String>(
    'offence_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceMeta = const VerificationMeta('occurrence');
  @override
  late final GeneratedColumn<int> occurrence = GeneratedColumn<int>(
    'occurrence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(1),
  );
  static const VerificationMeta _amountMinMeta = const VerificationMeta('amountMin');
  @override
  late final GeneratedColumn<int> amountMin = GeneratedColumn<int>(
    'amount_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMaxMeta = const VerificationMeta('amountMax');
  @override
  late final GeneratedColumn<int> amountMax = GeneratedColumn<int>(
    'amount_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondaryKeyMeta = const VerificationMeta('secondaryKey');
  @override
  late final GeneratedColumn<String> secondaryKey = GeneratedColumn<String>(
    'secondary_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _citationIdMeta = const VerificationMeta('citationId');
  @override
  late final GeneratedColumn<int> citationId = GeneratedColumn<int>(
    'citation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES citation(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jurisdictionId,
    offenceKey,
    occurrence,
    amountMin,
    amountMax,
    currency,
    secondaryKey,
    citationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'penalty';
  @override
  VerificationContext validateIntegrity(
    Insertable<PenaltyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(data['jurisdiction_id']!, _jurisdictionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('offence_key')) {
      context.handle(
        _offenceKeyMeta,
        offenceKey.isAcceptableOrUnknown(data['offence_key']!, _offenceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_offenceKeyMeta);
    }
    if (data.containsKey('occurrence')) {
      context.handle(
        _occurrenceMeta,
        occurrence.isAcceptableOrUnknown(data['occurrence']!, _occurrenceMeta),
      );
    }
    if (data.containsKey('amount_min')) {
      context.handle(
        _amountMinMeta,
        amountMin.isAcceptableOrUnknown(data['amount_min']!, _amountMinMeta),
      );
    }
    if (data.containsKey('amount_max')) {
      context.handle(
        _amountMaxMeta,
        amountMax.isAcceptableOrUnknown(data['amount_max']!, _amountMaxMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('secondary_key')) {
      context.handle(
        _secondaryKeyMeta,
        secondaryKey.isAcceptableOrUnknown(data['secondary_key']!, _secondaryKeyMeta),
      );
    }
    if (data.containsKey('citation_id')) {
      context.handle(
        _citationIdMeta,
        citationId.isAcceptableOrUnknown(data['citation_id']!, _citationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_citationIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PenaltyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PenaltyRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      offenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}offence_key'],
      )!,
      occurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence'],
      )!,
      amountMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_min'],
      ),
      amountMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_max'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      secondaryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_key'],
      ),
      citationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}citation_id'],
      )!,
    );
  }

  @override
  $PenaltiesTable createAlias(String alias) {
    return $PenaltiesTable(attachedDatabase, alias);
  }
}

class PenaltyRow extends DataClass implements Insertable<PenaltyRow> {
  final int id;
  final int jurisdictionId;
  final String offenceKey;

  /// First, second or subsequent occurrence — instruments scale by it.
  final int occurrence;
  final int? amountMin;
  final int? amountMax;

  /// Never converted: an instrument states a figure in one currency.
  final String? currency;

  /// Localised secondary consequence, e.g. a licence suspension.
  final String? secondaryKey;
  final int citationId;
  const PenaltyRow({
    required this.id,
    required this.jurisdictionId,
    required this.offenceKey,
    required this.occurrence,
    this.amountMin,
    this.amountMax,
    this.currency,
    this.secondaryKey,
    required this.citationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jurisdiction_id'] = Variable<int>(jurisdictionId);
    map['offence_key'] = Variable<String>(offenceKey);
    map['occurrence'] = Variable<int>(occurrence);
    if (!nullToAbsent || amountMin != null) {
      map['amount_min'] = Variable<int>(amountMin);
    }
    if (!nullToAbsent || amountMax != null) {
      map['amount_max'] = Variable<int>(amountMax);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    if (!nullToAbsent || secondaryKey != null) {
      map['secondary_key'] = Variable<String>(secondaryKey);
    }
    map['citation_id'] = Variable<int>(citationId);
    return map;
  }

  PenaltiesCompanion toCompanion(bool nullToAbsent) {
    return PenaltiesCompanion(
      id: Value(id),
      jurisdictionId: Value(jurisdictionId),
      offenceKey: Value(offenceKey),
      occurrence: Value(occurrence),
      amountMin: amountMin == null && nullToAbsent ? const Value.absent() : Value(amountMin),
      amountMax: amountMax == null && nullToAbsent ? const Value.absent() : Value(amountMax),
      currency: currency == null && nullToAbsent ? const Value.absent() : Value(currency),
      secondaryKey: secondaryKey == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryKey),
      citationId: Value(citationId),
    );
  }

  factory PenaltyRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PenaltyRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionId: serializer.fromJson<int>(json['jurisdictionId']),
      offenceKey: serializer.fromJson<String>(json['offenceKey']),
      occurrence: serializer.fromJson<int>(json['occurrence']),
      amountMin: serializer.fromJson<int?>(json['amountMin']),
      amountMax: serializer.fromJson<int?>(json['amountMax']),
      currency: serializer.fromJson<String?>(json['currency']),
      secondaryKey: serializer.fromJson<String?>(json['secondaryKey']),
      citationId: serializer.fromJson<int>(json['citationId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionId': serializer.toJson<int>(jurisdictionId),
      'offenceKey': serializer.toJson<String>(offenceKey),
      'occurrence': serializer.toJson<int>(occurrence),
      'amountMin': serializer.toJson<int?>(amountMin),
      'amountMax': serializer.toJson<int?>(amountMax),
      'currency': serializer.toJson<String?>(currency),
      'secondaryKey': serializer.toJson<String?>(secondaryKey),
      'citationId': serializer.toJson<int>(citationId),
    };
  }

  PenaltyRow copyWith({
    int? id,
    int? jurisdictionId,
    String? offenceKey,
    int? occurrence,
    Value<int?> amountMin = const Value.absent(),
    Value<int?> amountMax = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    Value<String?> secondaryKey = const Value.absent(),
    int? citationId,
  }) => PenaltyRow(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    offenceKey: offenceKey ?? this.offenceKey,
    occurrence: occurrence ?? this.occurrence,
    amountMin: amountMin.present ? amountMin.value : this.amountMin,
    amountMax: amountMax.present ? amountMax.value : this.amountMax,
    currency: currency.present ? currency.value : this.currency,
    secondaryKey: secondaryKey.present ? secondaryKey.value : this.secondaryKey,
    citationId: citationId ?? this.citationId,
  );
  PenaltyRow copyWithCompanion(PenaltiesCompanion data) {
    return PenaltyRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionId: data.jurisdictionId.present ? data.jurisdictionId.value : this.jurisdictionId,
      offenceKey: data.offenceKey.present ? data.offenceKey.value : this.offenceKey,
      occurrence: data.occurrence.present ? data.occurrence.value : this.occurrence,
      amountMin: data.amountMin.present ? data.amountMin.value : this.amountMin,
      amountMax: data.amountMax.present ? data.amountMax.value : this.amountMax,
      currency: data.currency.present ? data.currency.value : this.currency,
      secondaryKey: data.secondaryKey.present ? data.secondaryKey.value : this.secondaryKey,
      citationId: data.citationId.present ? data.citationId.value : this.citationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PenaltyRow(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('offenceKey: $offenceKey, ')
          ..write('occurrence: $occurrence, ')
          ..write('amountMin: $amountMin, ')
          ..write('amountMax: $amountMax, ')
          ..write('currency: $currency, ')
          ..write('secondaryKey: $secondaryKey, ')
          ..write('citationId: $citationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jurisdictionId,
    offenceKey,
    occurrence,
    amountMin,
    amountMax,
    currency,
    secondaryKey,
    citationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PenaltyRow &&
          other.id == this.id &&
          other.jurisdictionId == this.jurisdictionId &&
          other.offenceKey == this.offenceKey &&
          other.occurrence == this.occurrence &&
          other.amountMin == this.amountMin &&
          other.amountMax == this.amountMax &&
          other.currency == this.currency &&
          other.secondaryKey == this.secondaryKey &&
          other.citationId == this.citationId);
}

class PenaltiesCompanion extends UpdateCompanion<PenaltyRow> {
  final Value<int> id;
  final Value<int> jurisdictionId;
  final Value<String> offenceKey;
  final Value<int> occurrence;
  final Value<int?> amountMin;
  final Value<int?> amountMax;
  final Value<String?> currency;
  final Value<String?> secondaryKey;
  final Value<int> citationId;
  const PenaltiesCompanion({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.offenceKey = const Value.absent(),
    this.occurrence = const Value.absent(),
    this.amountMin = const Value.absent(),
    this.amountMax = const Value.absent(),
    this.currency = const Value.absent(),
    this.secondaryKey = const Value.absent(),
    this.citationId = const Value.absent(),
  });
  PenaltiesCompanion.insert({
    this.id = const Value.absent(),
    required int jurisdictionId,
    required String offenceKey,
    this.occurrence = const Value.absent(),
    this.amountMin = const Value.absent(),
    this.amountMax = const Value.absent(),
    this.currency = const Value.absent(),
    this.secondaryKey = const Value.absent(),
    required int citationId,
  }) : jurisdictionId = Value(jurisdictionId),
       offenceKey = Value(offenceKey),
       citationId = Value(citationId);
  static Insertable<PenaltyRow> custom({
    Expression<int>? id,
    Expression<int>? jurisdictionId,
    Expression<String>? offenceKey,
    Expression<int>? occurrence,
    Expression<int>? amountMin,
    Expression<int>? amountMax,
    Expression<String>? currency,
    Expression<String>? secondaryKey,
    Expression<int>? citationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (offenceKey != null) 'offence_key': offenceKey,
      if (occurrence != null) 'occurrence': occurrence,
      if (amountMin != null) 'amount_min': amountMin,
      if (amountMax != null) 'amount_max': amountMax,
      if (currency != null) 'currency': currency,
      if (secondaryKey != null) 'secondary_key': secondaryKey,
      if (citationId != null) 'citation_id': citationId,
    });
  }

  PenaltiesCompanion copyWith({
    Value<int>? id,
    Value<int>? jurisdictionId,
    Value<String>? offenceKey,
    Value<int>? occurrence,
    Value<int?>? amountMin,
    Value<int?>? amountMax,
    Value<String?>? currency,
    Value<String?>? secondaryKey,
    Value<int>? citationId,
  }) {
    return PenaltiesCompanion(
      id: id ?? this.id,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      offenceKey: offenceKey ?? this.offenceKey,
      occurrence: occurrence ?? this.occurrence,
      amountMin: amountMin ?? this.amountMin,
      amountMax: amountMax ?? this.amountMax,
      currency: currency ?? this.currency,
      secondaryKey: secondaryKey ?? this.secondaryKey,
      citationId: citationId ?? this.citationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId.value);
    }
    if (offenceKey.present) {
      map['offence_key'] = Variable<String>(offenceKey.value);
    }
    if (occurrence.present) {
      map['occurrence'] = Variable<int>(occurrence.value);
    }
    if (amountMin.present) {
      map['amount_min'] = Variable<int>(amountMin.value);
    }
    if (amountMax.present) {
      map['amount_max'] = Variable<int>(amountMax.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (secondaryKey.present) {
      map['secondary_key'] = Variable<String>(secondaryKey.value);
    }
    if (citationId.present) {
      map['citation_id'] = Variable<int>(citationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PenaltiesCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('offenceKey: $offenceKey, ')
          ..write('occurrence: $occurrence, ')
          ..write('amountMin: $amountMin, ')
          ..write('amountMax: $amountMax, ')
          ..write('currency: $currency, ')
          ..write('secondaryKey: $secondaryKey, ')
          ..write('citationId: $citationId')
          ..write(')'))
        .toString();
  }
}

class $LookalikesTable extends Lookalikes with TableInfo<$LookalikesTable, LookalikeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LookalikesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES species(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _confusedWithMeta = const VerificationMeta('confusedWith');
  @override
  late final GeneratedColumn<int> confusedWith = GeneratedColumn<int>(
    'confused_with',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES species(id)',
  );
  static const VerificationMeta _differenceKeyMeta = const VerificationMeta('differenceKey');
  @override
  late final GeneratedColumn<String> differenceKey = GeneratedColumn<String>(
    'difference_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, speciesId, confusedWith, differenceKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lookalike';
  @override
  VerificationContext validateIntegrity(
    Insertable<LookalikeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('confused_with')) {
      context.handle(
        _confusedWithMeta,
        confusedWith.isAcceptableOrUnknown(data['confused_with']!, _confusedWithMeta),
      );
    } else if (isInserting) {
      context.missing(_confusedWithMeta);
    }
    if (data.containsKey('difference_key')) {
      context.handle(
        _differenceKeyMeta,
        differenceKey.isAcceptableOrUnknown(data['difference_key']!, _differenceKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_differenceKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LookalikeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LookalikeRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      confusedWith: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}confused_with'],
      )!,
      differenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difference_key'],
      )!,
    );
  }

  @override
  $LookalikesTable createAlias(String alias) {
    return $LookalikesTable(attachedDatabase, alias);
  }
}

class LookalikeRow extends DataClass implements Insertable<LookalikeRow> {
  final int id;
  final int speciesId;
  final int confusedWith;
  final String differenceKey;
  const LookalikeRow({
    required this.id,
    required this.speciesId,
    required this.confusedWith,
    required this.differenceKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['species_id'] = Variable<int>(speciesId);
    map['confused_with'] = Variable<int>(confusedWith);
    map['difference_key'] = Variable<String>(differenceKey);
    return map;
  }

  LookalikesCompanion toCompanion(bool nullToAbsent) {
    return LookalikesCompanion(
      id: Value(id),
      speciesId: Value(speciesId),
      confusedWith: Value(confusedWith),
      differenceKey: Value(differenceKey),
    );
  }

  factory LookalikeRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LookalikeRow(
      id: serializer.fromJson<int>(json['id']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      confusedWith: serializer.fromJson<int>(json['confusedWith']),
      differenceKey: serializer.fromJson<String>(json['differenceKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speciesId': serializer.toJson<int>(speciesId),
      'confusedWith': serializer.toJson<int>(confusedWith),
      'differenceKey': serializer.toJson<String>(differenceKey),
    };
  }

  LookalikeRow copyWith({int? id, int? speciesId, int? confusedWith, String? differenceKey}) =>
      LookalikeRow(
        id: id ?? this.id,
        speciesId: speciesId ?? this.speciesId,
        confusedWith: confusedWith ?? this.confusedWith,
        differenceKey: differenceKey ?? this.differenceKey,
      );
  LookalikeRow copyWithCompanion(LookalikesCompanion data) {
    return LookalikeRow(
      id: data.id.present ? data.id.value : this.id,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      confusedWith: data.confusedWith.present ? data.confusedWith.value : this.confusedWith,
      differenceKey: data.differenceKey.present ? data.differenceKey.value : this.differenceKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LookalikeRow(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('confusedWith: $confusedWith, ')
          ..write('differenceKey: $differenceKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, speciesId, confusedWith, differenceKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LookalikeRow &&
          other.id == this.id &&
          other.speciesId == this.speciesId &&
          other.confusedWith == this.confusedWith &&
          other.differenceKey == this.differenceKey);
}

class LookalikesCompanion extends UpdateCompanion<LookalikeRow> {
  final Value<int> id;
  final Value<int> speciesId;
  final Value<int> confusedWith;
  final Value<String> differenceKey;
  const LookalikesCompanion({
    this.id = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.confusedWith = const Value.absent(),
    this.differenceKey = const Value.absent(),
  });
  LookalikesCompanion.insert({
    this.id = const Value.absent(),
    required int speciesId,
    required int confusedWith,
    required String differenceKey,
  }) : speciesId = Value(speciesId),
       confusedWith = Value(confusedWith),
       differenceKey = Value(differenceKey);
  static Insertable<LookalikeRow> custom({
    Expression<int>? id,
    Expression<int>? speciesId,
    Expression<int>? confusedWith,
    Expression<String>? differenceKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speciesId != null) 'species_id': speciesId,
      if (confusedWith != null) 'confused_with': confusedWith,
      if (differenceKey != null) 'difference_key': differenceKey,
    });
  }

  LookalikesCompanion copyWith({
    Value<int>? id,
    Value<int>? speciesId,
    Value<int>? confusedWith,
    Value<String>? differenceKey,
  }) {
    return LookalikesCompanion(
      id: id ?? this.id,
      speciesId: speciesId ?? this.speciesId,
      confusedWith: confusedWith ?? this.confusedWith,
      differenceKey: differenceKey ?? this.differenceKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (confusedWith.present) {
      map['confused_with'] = Variable<int>(confusedWith.value);
    }
    if (differenceKey.present) {
      map['difference_key'] = Variable<String>(differenceKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LookalikesCompanion(')
          ..write('id: $id, ')
          ..write('speciesId: $speciesId, ')
          ..write('confusedWith: $confusedWith, ')
          ..write('differenceKey: $differenceKey')
          ..write(')'))
        .toString();
  }
}

class $GlossaryTermsTable extends GlossaryTerms
    with TableInfo<$GlossaryTermsTable, GlossaryTermRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlossaryTermsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta('jurisdictionId');
  @override
  late final GeneratedColumn<int> jurisdictionId = GeneratedColumn<int>(
    'jurisdiction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES jurisdiction(id)',
  );
  static const VerificationMeta _termKeyMeta = const VerificationMeta('termKey');
  @override
  late final GeneratedColumn<String> termKey = GeneratedColumn<String>(
    'term_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionKeyMeta = const VerificationMeta('definitionKey');
  @override
  late final GeneratedColumn<String> definitionKey = GeneratedColumn<String>(
    'definition_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [id, jurisdictionId, termKey, definitionKey, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'glossary_term';
  @override
  VerificationContext validateIntegrity(
    Insertable<GlossaryTermRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(data['jurisdiction_id']!, _jurisdictionIdMeta),
      );
    }
    if (data.containsKey('term_key')) {
      context.handle(_termKeyMeta, termKey.isAcceptableOrUnknown(data['term_key']!, _termKeyMeta));
    } else if (isInserting) {
      context.missing(_termKeyMeta);
    }
    if (data.containsKey('definition_key')) {
      context.handle(
        _definitionKeyMeta,
        definitionKey.isAcceptableOrUnknown(data['definition_key']!, _definitionKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_definitionKeyMeta);
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
  GlossaryTermRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlossaryTermRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jurisdiction_id'],
      ),
      termKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}term_key'],
      )!,
      definitionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_key'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $GlossaryTermsTable createAlias(String alias) {
    return $GlossaryTermsTable(attachedDatabase, alias);
  }
}

class GlossaryTermRow extends DataClass implements Insertable<GlossaryTermRow> {
  final int id;

  /// `null` means the term is global.
  final int? jurisdictionId;
  final String termKey;
  final String definitionKey;
  final int sortOrder;
  const GlossaryTermRow({
    required this.id,
    this.jurisdictionId,
    required this.termKey,
    required this.definitionKey,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || jurisdictionId != null) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId);
    }
    map['term_key'] = Variable<String>(termKey);
    map['definition_key'] = Variable<String>(definitionKey);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GlossaryTermsCompanion toCompanion(bool nullToAbsent) {
    return GlossaryTermsCompanion(
      id: Value(id),
      jurisdictionId: jurisdictionId == null && nullToAbsent
          ? const Value.absent()
          : Value(jurisdictionId),
      termKey: Value(termKey),
      definitionKey: Value(definitionKey),
      sortOrder: Value(sortOrder),
    );
  }

  factory GlossaryTermRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlossaryTermRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionId: serializer.fromJson<int?>(json['jurisdictionId']),
      termKey: serializer.fromJson<String>(json['termKey']),
      definitionKey: serializer.fromJson<String>(json['definitionKey']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionId': serializer.toJson<int?>(jurisdictionId),
      'termKey': serializer.toJson<String>(termKey),
      'definitionKey': serializer.toJson<String>(definitionKey),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  GlossaryTermRow copyWith({
    int? id,
    Value<int?> jurisdictionId = const Value.absent(),
    String? termKey,
    String? definitionKey,
    int? sortOrder,
  }) => GlossaryTermRow(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId.present ? jurisdictionId.value : this.jurisdictionId,
    termKey: termKey ?? this.termKey,
    definitionKey: definitionKey ?? this.definitionKey,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  GlossaryTermRow copyWithCompanion(GlossaryTermsCompanion data) {
    return GlossaryTermRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionId: data.jurisdictionId.present ? data.jurisdictionId.value : this.jurisdictionId,
      termKey: data.termKey.present ? data.termKey.value : this.termKey,
      definitionKey: data.definitionKey.present ? data.definitionKey.value : this.definitionKey,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlossaryTermRow(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('termKey: $termKey, ')
          ..write('definitionKey: $definitionKey, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jurisdictionId, termKey, definitionKey, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlossaryTermRow &&
          other.id == this.id &&
          other.jurisdictionId == this.jurisdictionId &&
          other.termKey == this.termKey &&
          other.definitionKey == this.definitionKey &&
          other.sortOrder == this.sortOrder);
}

class GlossaryTermsCompanion extends UpdateCompanion<GlossaryTermRow> {
  final Value<int> id;
  final Value<int?> jurisdictionId;
  final Value<String> termKey;
  final Value<String> definitionKey;
  final Value<int> sortOrder;
  const GlossaryTermsCompanion({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.termKey = const Value.absent(),
    this.definitionKey = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  GlossaryTermsCompanion.insert({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    required String termKey,
    required String definitionKey,
    this.sortOrder = const Value.absent(),
  }) : termKey = Value(termKey),
       definitionKey = Value(definitionKey);
  static Insertable<GlossaryTermRow> custom({
    Expression<int>? id,
    Expression<int>? jurisdictionId,
    Expression<String>? termKey,
    Expression<String>? definitionKey,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (termKey != null) 'term_key': termKey,
      if (definitionKey != null) 'definition_key': definitionKey,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  GlossaryTermsCompanion copyWith({
    Value<int>? id,
    Value<int?>? jurisdictionId,
    Value<String>? termKey,
    Value<String>? definitionKey,
    Value<int>? sortOrder,
  }) {
    return GlossaryTermsCompanion(
      id: id ?? this.id,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      termKey: termKey ?? this.termKey,
      definitionKey: definitionKey ?? this.definitionKey,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId.value);
    }
    if (termKey.present) {
      map['term_key'] = Variable<String>(termKey.value);
    }
    if (definitionKey.present) {
      map['definition_key'] = Variable<String>(definitionKey.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlossaryTermsCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('termKey: $termKey, ')
          ..write('definitionKey: $definitionKey, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ContentChangesTable extends ContentChanges
    with TableInfo<$ContentChangesTable, ContentChangeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta('jurisdictionId');
  @override
  late final GeneratedColumn<int> jurisdictionId = GeneratedColumn<int>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdiction(id)',
  );
  static const VerificationMeta _fromVersionMeta = const VerificationMeta('fromVersion');
  @override
  late final GeneratedColumn<String> fromVersion = GeneratedColumn<String>(
    'from_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toVersionMeta = const VerificationMeta('toVersion');
  @override
  late final GeneratedColumn<String> toVersion = GeneratedColumn<String>(
    'to_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryKeyMeta = const VerificationMeta('summaryKey');
  @override
  late final GeneratedColumn<String> summaryKey = GeneratedColumn<String>(
    'summary_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailKeyMeta = const VerificationMeta('detailKey');
  @override
  late final GeneratedColumn<String> detailKey = GeneratedColumn<String>(
    'detail_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changedOnMeta = const VerificationMeta('changedOn');
  @override
  late final GeneratedColumn<String> changedOn = GeneratedColumn<String>(
    'changed_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jurisdictionId,
    fromVersion,
    toVersion,
    summaryKey,
    detailKey,
    changedOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_change';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentChangeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(data['jurisdiction_id']!, _jurisdictionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('from_version')) {
      context.handle(
        _fromVersionMeta,
        fromVersion.isAcceptableOrUnknown(data['from_version']!, _fromVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_fromVersionMeta);
    }
    if (data.containsKey('to_version')) {
      context.handle(
        _toVersionMeta,
        toVersion.isAcceptableOrUnknown(data['to_version']!, _toVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_toVersionMeta);
    }
    if (data.containsKey('summary_key')) {
      context.handle(
        _summaryKeyMeta,
        summaryKey.isAcceptableOrUnknown(data['summary_key']!, _summaryKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryKeyMeta);
    }
    if (data.containsKey('detail_key')) {
      context.handle(
        _detailKeyMeta,
        detailKey.isAcceptableOrUnknown(data['detail_key']!, _detailKeyMeta),
      );
    }
    if (data.containsKey('changed_on')) {
      context.handle(
        _changedOnMeta,
        changedOn.isAcceptableOrUnknown(data['changed_on']!, _changedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_changedOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContentChangeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentChangeRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      fromVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_version'],
      )!,
      toVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_version'],
      )!,
      summaryKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_key'],
      )!,
      detailKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail_key'],
      ),
      changedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changed_on'],
      )!,
    );
  }

  @override
  $ContentChangesTable createAlias(String alias) {
    return $ContentChangesTable(attachedDatabase, alias);
  }
}

class ContentChangeRow extends DataClass implements Insertable<ContentChangeRow> {
  final int id;
  final int jurisdictionId;
  final String fromVersion;
  final String toVersion;
  final String summaryKey;
  final String? detailKey;
  final String changedOn;
  const ContentChangeRow({
    required this.id,
    required this.jurisdictionId,
    required this.fromVersion,
    required this.toVersion,
    required this.summaryKey,
    this.detailKey,
    required this.changedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jurisdiction_id'] = Variable<int>(jurisdictionId);
    map['from_version'] = Variable<String>(fromVersion);
    map['to_version'] = Variable<String>(toVersion);
    map['summary_key'] = Variable<String>(summaryKey);
    if (!nullToAbsent || detailKey != null) {
      map['detail_key'] = Variable<String>(detailKey);
    }
    map['changed_on'] = Variable<String>(changedOn);
    return map;
  }

  ContentChangesCompanion toCompanion(bool nullToAbsent) {
    return ContentChangesCompanion(
      id: Value(id),
      jurisdictionId: Value(jurisdictionId),
      fromVersion: Value(fromVersion),
      toVersion: Value(toVersion),
      summaryKey: Value(summaryKey),
      detailKey: detailKey == null && nullToAbsent ? const Value.absent() : Value(detailKey),
      changedOn: Value(changedOn),
    );
  }

  factory ContentChangeRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentChangeRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionId: serializer.fromJson<int>(json['jurisdictionId']),
      fromVersion: serializer.fromJson<String>(json['fromVersion']),
      toVersion: serializer.fromJson<String>(json['toVersion']),
      summaryKey: serializer.fromJson<String>(json['summaryKey']),
      detailKey: serializer.fromJson<String?>(json['detailKey']),
      changedOn: serializer.fromJson<String>(json['changedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionId': serializer.toJson<int>(jurisdictionId),
      'fromVersion': serializer.toJson<String>(fromVersion),
      'toVersion': serializer.toJson<String>(toVersion),
      'summaryKey': serializer.toJson<String>(summaryKey),
      'detailKey': serializer.toJson<String?>(detailKey),
      'changedOn': serializer.toJson<String>(changedOn),
    };
  }

  ContentChangeRow copyWith({
    int? id,
    int? jurisdictionId,
    String? fromVersion,
    String? toVersion,
    String? summaryKey,
    Value<String?> detailKey = const Value.absent(),
    String? changedOn,
  }) => ContentChangeRow(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    fromVersion: fromVersion ?? this.fromVersion,
    toVersion: toVersion ?? this.toVersion,
    summaryKey: summaryKey ?? this.summaryKey,
    detailKey: detailKey.present ? detailKey.value : this.detailKey,
    changedOn: changedOn ?? this.changedOn,
  );
  ContentChangeRow copyWithCompanion(ContentChangesCompanion data) {
    return ContentChangeRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionId: data.jurisdictionId.present ? data.jurisdictionId.value : this.jurisdictionId,
      fromVersion: data.fromVersion.present ? data.fromVersion.value : this.fromVersion,
      toVersion: data.toVersion.present ? data.toVersion.value : this.toVersion,
      summaryKey: data.summaryKey.present ? data.summaryKey.value : this.summaryKey,
      detailKey: data.detailKey.present ? data.detailKey.value : this.detailKey,
      changedOn: data.changedOn.present ? data.changedOn.value : this.changedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentChangeRow(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('fromVersion: $fromVersion, ')
          ..write('toVersion: $toVersion, ')
          ..write('summaryKey: $summaryKey, ')
          ..write('detailKey: $detailKey, ')
          ..write('changedOn: $changedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, jurisdictionId, fromVersion, toVersion, summaryKey, detailKey, changedOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentChangeRow &&
          other.id == this.id &&
          other.jurisdictionId == this.jurisdictionId &&
          other.fromVersion == this.fromVersion &&
          other.toVersion == this.toVersion &&
          other.summaryKey == this.summaryKey &&
          other.detailKey == this.detailKey &&
          other.changedOn == this.changedOn);
}

class ContentChangesCompanion extends UpdateCompanion<ContentChangeRow> {
  final Value<int> id;
  final Value<int> jurisdictionId;
  final Value<String> fromVersion;
  final Value<String> toVersion;
  final Value<String> summaryKey;
  final Value<String?> detailKey;
  final Value<String> changedOn;
  const ContentChangesCompanion({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.fromVersion = const Value.absent(),
    this.toVersion = const Value.absent(),
    this.summaryKey = const Value.absent(),
    this.detailKey = const Value.absent(),
    this.changedOn = const Value.absent(),
  });
  ContentChangesCompanion.insert({
    this.id = const Value.absent(),
    required int jurisdictionId,
    required String fromVersion,
    required String toVersion,
    required String summaryKey,
    this.detailKey = const Value.absent(),
    required String changedOn,
  }) : jurisdictionId = Value(jurisdictionId),
       fromVersion = Value(fromVersion),
       toVersion = Value(toVersion),
       summaryKey = Value(summaryKey),
       changedOn = Value(changedOn);
  static Insertable<ContentChangeRow> custom({
    Expression<int>? id,
    Expression<int>? jurisdictionId,
    Expression<String>? fromVersion,
    Expression<String>? toVersion,
    Expression<String>? summaryKey,
    Expression<String>? detailKey,
    Expression<String>? changedOn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (fromVersion != null) 'from_version': fromVersion,
      if (toVersion != null) 'to_version': toVersion,
      if (summaryKey != null) 'summary_key': summaryKey,
      if (detailKey != null) 'detail_key': detailKey,
      if (changedOn != null) 'changed_on': changedOn,
    });
  }

  ContentChangesCompanion copyWith({
    Value<int>? id,
    Value<int>? jurisdictionId,
    Value<String>? fromVersion,
    Value<String>? toVersion,
    Value<String>? summaryKey,
    Value<String?>? detailKey,
    Value<String>? changedOn,
  }) {
    return ContentChangesCompanion(
      id: id ?? this.id,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      fromVersion: fromVersion ?? this.fromVersion,
      toVersion: toVersion ?? this.toVersion,
      summaryKey: summaryKey ?? this.summaryKey,
      detailKey: detailKey ?? this.detailKey,
      changedOn: changedOn ?? this.changedOn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId.value);
    }
    if (fromVersion.present) {
      map['from_version'] = Variable<String>(fromVersion.value);
    }
    if (toVersion.present) {
      map['to_version'] = Variable<String>(toVersion.value);
    }
    if (summaryKey.present) {
      map['summary_key'] = Variable<String>(summaryKey.value);
    }
    if (detailKey.present) {
      map['detail_key'] = Variable<String>(detailKey.value);
    }
    if (changedOn.present) {
      map['changed_on'] = Variable<String>(changedOn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentChangesCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('fromVersion: $fromVersion, ')
          ..write('toVersion: $toVersion, ')
          ..write('summaryKey: $summaryKey, ')
          ..write('detailKey: $detailKey, ')
          ..write('changedOn: $changedOn')
          ..write(')'))
        .toString();
  }
}

class $KeyNodesTable extends KeyNodes with TableInfo<$KeyNodesTable, KeyNodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyNodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxonGroupMeta = const VerificationMeta('taxonGroup');
  @override
  late final GeneratedColumn<String> taxonGroup = GeneratedColumn<String>(
    'taxon_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentNodeIdMeta = const VerificationMeta('parentNodeId');
  @override
  late final GeneratedColumn<int> parentNodeId = GeneratedColumn<int>(
    'parent_node_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES key_node(id)',
  );
  static const VerificationMeta _questionKeyMeta = const VerificationMeta('questionKey');
  @override
  late final GeneratedColumn<String> questionKey = GeneratedColumn<String>(
    'question_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, taxonGroup, parentNodeId, questionKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_node';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyNodeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('taxon_group')) {
      context.handle(
        _taxonGroupMeta,
        taxonGroup.isAcceptableOrUnknown(data['taxon_group']!, _taxonGroupMeta),
      );
    } else if (isInserting) {
      context.missing(_taxonGroupMeta);
    }
    if (data.containsKey('parent_node_id')) {
      context.handle(
        _parentNodeIdMeta,
        parentNodeId.isAcceptableOrUnknown(data['parent_node_id']!, _parentNodeIdMeta),
      );
    }
    if (data.containsKey('question_key')) {
      context.handle(
        _questionKeyMeta,
        questionKey.isAcceptableOrUnknown(data['question_key']!, _questionKeyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KeyNodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyNodeRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taxonGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taxon_group'],
      )!,
      parentNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_node_id'],
      ),
      questionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_key'],
      ),
    );
  }

  @override
  $KeyNodesTable createAlias(String alias) {
    return $KeyNodesTable(attachedDatabase, alias);
  }
}

class KeyNodeRow extends DataClass implements Insertable<KeyNodeRow> {
  final int id;
  final String taxonGroup;

  /// Self-referential, so a custom constraint rather than `references`.
  final int? parentNodeId;

  /// `null` on a leaf.
  final String? questionKey;
  const KeyNodeRow({
    required this.id,
    required this.taxonGroup,
    this.parentNodeId,
    this.questionKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['taxon_group'] = Variable<String>(taxonGroup);
    if (!nullToAbsent || parentNodeId != null) {
      map['parent_node_id'] = Variable<int>(parentNodeId);
    }
    if (!nullToAbsent || questionKey != null) {
      map['question_key'] = Variable<String>(questionKey);
    }
    return map;
  }

  KeyNodesCompanion toCompanion(bool nullToAbsent) {
    return KeyNodesCompanion(
      id: Value(id),
      taxonGroup: Value(taxonGroup),
      parentNodeId: parentNodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentNodeId),
      questionKey: questionKey == null && nullToAbsent ? const Value.absent() : Value(questionKey),
    );
  }

  factory KeyNodeRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyNodeRow(
      id: serializer.fromJson<int>(json['id']),
      taxonGroup: serializer.fromJson<String>(json['taxonGroup']),
      parentNodeId: serializer.fromJson<int?>(json['parentNodeId']),
      questionKey: serializer.fromJson<String?>(json['questionKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taxonGroup': serializer.toJson<String>(taxonGroup),
      'parentNodeId': serializer.toJson<int?>(parentNodeId),
      'questionKey': serializer.toJson<String?>(questionKey),
    };
  }

  KeyNodeRow copyWith({
    int? id,
    String? taxonGroup,
    Value<int?> parentNodeId = const Value.absent(),
    Value<String?> questionKey = const Value.absent(),
  }) => KeyNodeRow(
    id: id ?? this.id,
    taxonGroup: taxonGroup ?? this.taxonGroup,
    parentNodeId: parentNodeId.present ? parentNodeId.value : this.parentNodeId,
    questionKey: questionKey.present ? questionKey.value : this.questionKey,
  );
  KeyNodeRow copyWithCompanion(KeyNodesCompanion data) {
    return KeyNodeRow(
      id: data.id.present ? data.id.value : this.id,
      taxonGroup: data.taxonGroup.present ? data.taxonGroup.value : this.taxonGroup,
      parentNodeId: data.parentNodeId.present ? data.parentNodeId.value : this.parentNodeId,
      questionKey: data.questionKey.present ? data.questionKey.value : this.questionKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyNodeRow(')
          ..write('id: $id, ')
          ..write('taxonGroup: $taxonGroup, ')
          ..write('parentNodeId: $parentNodeId, ')
          ..write('questionKey: $questionKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taxonGroup, parentNodeId, questionKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyNodeRow &&
          other.id == this.id &&
          other.taxonGroup == this.taxonGroup &&
          other.parentNodeId == this.parentNodeId &&
          other.questionKey == this.questionKey);
}

class KeyNodesCompanion extends UpdateCompanion<KeyNodeRow> {
  final Value<int> id;
  final Value<String> taxonGroup;
  final Value<int?> parentNodeId;
  final Value<String?> questionKey;
  const KeyNodesCompanion({
    this.id = const Value.absent(),
    this.taxonGroup = const Value.absent(),
    this.parentNodeId = const Value.absent(),
    this.questionKey = const Value.absent(),
  });
  KeyNodesCompanion.insert({
    this.id = const Value.absent(),
    required String taxonGroup,
    this.parentNodeId = const Value.absent(),
    this.questionKey = const Value.absent(),
  }) : taxonGroup = Value(taxonGroup);
  static Insertable<KeyNodeRow> custom({
    Expression<int>? id,
    Expression<String>? taxonGroup,
    Expression<int>? parentNodeId,
    Expression<String>? questionKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taxonGroup != null) 'taxon_group': taxonGroup,
      if (parentNodeId != null) 'parent_node_id': parentNodeId,
      if (questionKey != null) 'question_key': questionKey,
    });
  }

  KeyNodesCompanion copyWith({
    Value<int>? id,
    Value<String>? taxonGroup,
    Value<int?>? parentNodeId,
    Value<String?>? questionKey,
  }) {
    return KeyNodesCompanion(
      id: id ?? this.id,
      taxonGroup: taxonGroup ?? this.taxonGroup,
      parentNodeId: parentNodeId ?? this.parentNodeId,
      questionKey: questionKey ?? this.questionKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taxonGroup.present) {
      map['taxon_group'] = Variable<String>(taxonGroup.value);
    }
    if (parentNodeId.present) {
      map['parent_node_id'] = Variable<int>(parentNodeId.value);
    }
    if (questionKey.present) {
      map['question_key'] = Variable<String>(questionKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyNodesCompanion(')
          ..write('id: $id, ')
          ..write('taxonGroup: $taxonGroup, ')
          ..write('parentNodeId: $parentNodeId, ')
          ..write('questionKey: $questionKey')
          ..write(')'))
        .toString();
  }
}

class $KeyLeafSpeciesTable extends KeyLeafSpecies
    with TableInfo<$KeyLeafSpeciesTable, KeyLeafSpeciesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyLeafSpeciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<int> nodeId = GeneratedColumn<int>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES key_node(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta('speciesId');
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES species(id)',
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<int> rank = GeneratedColumn<int>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant<int>(0),
  );
  @override
  List<GeneratedColumn> get $columns => [nodeId, speciesId, rank];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_leaf_species';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyLeafSpeciesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('node_id')) {
      context.handle(_nodeIdMeta, nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta));
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('rank')) {
      context.handle(_rankMeta, rank.isAcceptableOrUnknown(data['rank']!, _rankMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {nodeId, speciesId};
  @override
  KeyLeafSpeciesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyLeafSpeciesRow(
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}node_id'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      rank: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}rank'])!,
    );
  }

  @override
  $KeyLeafSpeciesTable createAlias(String alias) {
    return $KeyLeafSpeciesTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class KeyLeafSpeciesRow extends DataClass implements Insertable<KeyLeafSpeciesRow> {
  final int nodeId;
  final int speciesId;

  /// A leaf with several candidates is an honest outcome, not a failure of the
  /// key.
  final int rank;
  const KeyLeafSpeciesRow({required this.nodeId, required this.speciesId, required this.rank});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['node_id'] = Variable<int>(nodeId);
    map['species_id'] = Variable<int>(speciesId);
    map['rank'] = Variable<int>(rank);
    return map;
  }

  KeyLeafSpeciesCompanion toCompanion(bool nullToAbsent) {
    return KeyLeafSpeciesCompanion(
      nodeId: Value(nodeId),
      speciesId: Value(speciesId),
      rank: Value(rank),
    );
  }

  factory KeyLeafSpeciesRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyLeafSpeciesRow(
      nodeId: serializer.fromJson<int>(json['nodeId']),
      speciesId: serializer.fromJson<int>(json['speciesId']),
      rank: serializer.fromJson<int>(json['rank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nodeId': serializer.toJson<int>(nodeId),
      'speciesId': serializer.toJson<int>(speciesId),
      'rank': serializer.toJson<int>(rank),
    };
  }

  KeyLeafSpeciesRow copyWith({int? nodeId, int? speciesId, int? rank}) => KeyLeafSpeciesRow(
    nodeId: nodeId ?? this.nodeId,
    speciesId: speciesId ?? this.speciesId,
    rank: rank ?? this.rank,
  );
  KeyLeafSpeciesRow copyWithCompanion(KeyLeafSpeciesCompanion data) {
    return KeyLeafSpeciesRow(
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      rank: data.rank.present ? data.rank.value : this.rank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyLeafSpeciesRow(')
          ..write('nodeId: $nodeId, ')
          ..write('speciesId: $speciesId, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(nodeId, speciesId, rank);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyLeafSpeciesRow &&
          other.nodeId == this.nodeId &&
          other.speciesId == this.speciesId &&
          other.rank == this.rank);
}

class KeyLeafSpeciesCompanion extends UpdateCompanion<KeyLeafSpeciesRow> {
  final Value<int> nodeId;
  final Value<int> speciesId;
  final Value<int> rank;
  const KeyLeafSpeciesCompanion({
    this.nodeId = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.rank = const Value.absent(),
  });
  KeyLeafSpeciesCompanion.insert({
    required int nodeId,
    required int speciesId,
    this.rank = const Value.absent(),
  }) : nodeId = Value(nodeId),
       speciesId = Value(speciesId);
  static Insertable<KeyLeafSpeciesRow> custom({
    Expression<int>? nodeId,
    Expression<int>? speciesId,
    Expression<int>? rank,
  }) {
    return RawValuesInsertable({
      if (nodeId != null) 'node_id': nodeId,
      if (speciesId != null) 'species_id': speciesId,
      if (rank != null) 'rank': rank,
    });
  }

  KeyLeafSpeciesCompanion copyWith({Value<int>? nodeId, Value<int>? speciesId, Value<int>? rank}) {
    return KeyLeafSpeciesCompanion(
      nodeId: nodeId ?? this.nodeId,
      speciesId: speciesId ?? this.speciesId,
      rank: rank ?? this.rank,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nodeId.present) {
      map['node_id'] = Variable<int>(nodeId.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(rank.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyLeafSpeciesCompanion(')
          ..write('nodeId: $nodeId, ')
          ..write('speciesId: $speciesId, ')
          ..write('rank: $rank')
          ..write(')'))
        .toString();
  }
}

class $KeyOptionsTable extends KeyOptions with TableInfo<$KeyOptionsTable, KeyOptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KeyOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<int> nodeId = GeneratedColumn<int>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES key_node(id) ON DELETE CASCADE',
  );
  static const VerificationMeta _optionIndexMeta = const VerificationMeta('optionIndex');
  @override
  late final GeneratedColumn<int> optionIndex = GeneratedColumn<int>(
    'option_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelKeyMeta = const VerificationMeta('labelKey');
  @override
  late final GeneratedColumn<String> labelKey = GeneratedColumn<String>(
    'label_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _figureAssetMeta = const VerificationMeta('figureAsset');
  @override
  late final GeneratedColumn<String> figureAsset = GeneratedColumn<String>(
    'figure_asset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextNodeIdMeta = const VerificationMeta('nextNodeId');
  @override
  late final GeneratedColumn<int> nextNodeId = GeneratedColumn<int>(
    'next_node_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES key_node(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nodeId,
    optionIndex,
    labelKey,
    figureAsset,
    nextNodeId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'key_option';
  @override
  VerificationContext validateIntegrity(
    Insertable<KeyOptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('node_id')) {
      context.handle(_nodeIdMeta, nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta));
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('option_index')) {
      context.handle(
        _optionIndexMeta,
        optionIndex.isAcceptableOrUnknown(data['option_index']!, _optionIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_optionIndexMeta);
    }
    if (data.containsKey('label_key')) {
      context.handle(
        _labelKeyMeta,
        labelKey.isAcceptableOrUnknown(data['label_key']!, _labelKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_labelKeyMeta);
    }
    if (data.containsKey('figure_asset')) {
      context.handle(
        _figureAssetMeta,
        figureAsset.isAcceptableOrUnknown(data['figure_asset']!, _figureAssetMeta),
      );
    }
    if (data.containsKey('next_node_id')) {
      context.handle(
        _nextNodeIdMeta,
        nextNodeId.isAcceptableOrUnknown(data['next_node_id']!, _nextNodeIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KeyOptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KeyOptionRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}node_id'],
      )!,
      optionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}option_index'],
      )!,
      labelKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_key'],
      )!,
      figureAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}figure_asset'],
      ),
      nextNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_node_id'],
      ),
    );
  }

  @override
  $KeyOptionsTable createAlias(String alias) {
    return $KeyOptionsTable(attachedDatabase, alias);
  }
}

class KeyOptionRow extends DataClass implements Insertable<KeyOptionRow> {
  final int id;
  final int nodeId;
  final int optionIndex;
  final String labelKey;
  final String? figureAsset;

  /// `null` is a dead end — S7's terminal state, and a real answer rather than
  /// an error.
  final int? nextNodeId;
  const KeyOptionRow({
    required this.id,
    required this.nodeId,
    required this.optionIndex,
    required this.labelKey,
    this.figureAsset,
    this.nextNodeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['node_id'] = Variable<int>(nodeId);
    map['option_index'] = Variable<int>(optionIndex);
    map['label_key'] = Variable<String>(labelKey);
    if (!nullToAbsent || figureAsset != null) {
      map['figure_asset'] = Variable<String>(figureAsset);
    }
    if (!nullToAbsent || nextNodeId != null) {
      map['next_node_id'] = Variable<int>(nextNodeId);
    }
    return map;
  }

  KeyOptionsCompanion toCompanion(bool nullToAbsent) {
    return KeyOptionsCompanion(
      id: Value(id),
      nodeId: Value(nodeId),
      optionIndex: Value(optionIndex),
      labelKey: Value(labelKey),
      figureAsset: figureAsset == null && nullToAbsent ? const Value.absent() : Value(figureAsset),
      nextNodeId: nextNodeId == null && nullToAbsent ? const Value.absent() : Value(nextNodeId),
    );
  }

  factory KeyOptionRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KeyOptionRow(
      id: serializer.fromJson<int>(json['id']),
      nodeId: serializer.fromJson<int>(json['nodeId']),
      optionIndex: serializer.fromJson<int>(json['optionIndex']),
      labelKey: serializer.fromJson<String>(json['labelKey']),
      figureAsset: serializer.fromJson<String?>(json['figureAsset']),
      nextNodeId: serializer.fromJson<int?>(json['nextNodeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nodeId': serializer.toJson<int>(nodeId),
      'optionIndex': serializer.toJson<int>(optionIndex),
      'labelKey': serializer.toJson<String>(labelKey),
      'figureAsset': serializer.toJson<String?>(figureAsset),
      'nextNodeId': serializer.toJson<int?>(nextNodeId),
    };
  }

  KeyOptionRow copyWith({
    int? id,
    int? nodeId,
    int? optionIndex,
    String? labelKey,
    Value<String?> figureAsset = const Value.absent(),
    Value<int?> nextNodeId = const Value.absent(),
  }) => KeyOptionRow(
    id: id ?? this.id,
    nodeId: nodeId ?? this.nodeId,
    optionIndex: optionIndex ?? this.optionIndex,
    labelKey: labelKey ?? this.labelKey,
    figureAsset: figureAsset.present ? figureAsset.value : this.figureAsset,
    nextNodeId: nextNodeId.present ? nextNodeId.value : this.nextNodeId,
  );
  KeyOptionRow copyWithCompanion(KeyOptionsCompanion data) {
    return KeyOptionRow(
      id: data.id.present ? data.id.value : this.id,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      optionIndex: data.optionIndex.present ? data.optionIndex.value : this.optionIndex,
      labelKey: data.labelKey.present ? data.labelKey.value : this.labelKey,
      figureAsset: data.figureAsset.present ? data.figureAsset.value : this.figureAsset,
      nextNodeId: data.nextNodeId.present ? data.nextNodeId.value : this.nextNodeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KeyOptionRow(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('optionIndex: $optionIndex, ')
          ..write('labelKey: $labelKey, ')
          ..write('figureAsset: $figureAsset, ')
          ..write('nextNodeId: $nextNodeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nodeId, optionIndex, labelKey, figureAsset, nextNodeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KeyOptionRow &&
          other.id == this.id &&
          other.nodeId == this.nodeId &&
          other.optionIndex == this.optionIndex &&
          other.labelKey == this.labelKey &&
          other.figureAsset == this.figureAsset &&
          other.nextNodeId == this.nextNodeId);
}

class KeyOptionsCompanion extends UpdateCompanion<KeyOptionRow> {
  final Value<int> id;
  final Value<int> nodeId;
  final Value<int> optionIndex;
  final Value<String> labelKey;
  final Value<String?> figureAsset;
  final Value<int?> nextNodeId;
  const KeyOptionsCompanion({
    this.id = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.optionIndex = const Value.absent(),
    this.labelKey = const Value.absent(),
    this.figureAsset = const Value.absent(),
    this.nextNodeId = const Value.absent(),
  });
  KeyOptionsCompanion.insert({
    this.id = const Value.absent(),
    required int nodeId,
    required int optionIndex,
    required String labelKey,
    this.figureAsset = const Value.absent(),
    this.nextNodeId = const Value.absent(),
  }) : nodeId = Value(nodeId),
       optionIndex = Value(optionIndex),
       labelKey = Value(labelKey);
  static Insertable<KeyOptionRow> custom({
    Expression<int>? id,
    Expression<int>? nodeId,
    Expression<int>? optionIndex,
    Expression<String>? labelKey,
    Expression<String>? figureAsset,
    Expression<int>? nextNodeId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeId != null) 'node_id': nodeId,
      if (optionIndex != null) 'option_index': optionIndex,
      if (labelKey != null) 'label_key': labelKey,
      if (figureAsset != null) 'figure_asset': figureAsset,
      if (nextNodeId != null) 'next_node_id': nextNodeId,
    });
  }

  KeyOptionsCompanion copyWith({
    Value<int>? id,
    Value<int>? nodeId,
    Value<int>? optionIndex,
    Value<String>? labelKey,
    Value<String?>? figureAsset,
    Value<int?>? nextNodeId,
  }) {
    return KeyOptionsCompanion(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      optionIndex: optionIndex ?? this.optionIndex,
      labelKey: labelKey ?? this.labelKey,
      figureAsset: figureAsset ?? this.figureAsset,
      nextNodeId: nextNodeId ?? this.nextNodeId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<int>(nodeId.value);
    }
    if (optionIndex.present) {
      map['option_index'] = Variable<int>(optionIndex.value);
    }
    if (labelKey.present) {
      map['label_key'] = Variable<String>(labelKey.value);
    }
    if (figureAsset.present) {
      map['figure_asset'] = Variable<String>(figureAsset.value);
    }
    if (nextNodeId.present) {
      map['next_node_id'] = Variable<int>(nextNodeId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KeyOptionsCompanion(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('optionIndex: $optionIndex, ')
          ..write('labelKey: $labelKey, ')
          ..write('figureAsset: $figureAsset, ')
          ..write('nextNodeId: $nextNodeId')
          ..write(')'))
        .toString();
  }
}

class $ContentStringsTable extends ContentStrings
    with TableInfo<$ContentStringsTable, ContentStringRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentStringsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
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
  List<GeneratedColumn> get $columns => [key, locale, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_string';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentStringRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta, locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key, locale};
  @override
  ContentStringRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentStringRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $ContentStringsTable createAlias(String alias) {
    return $ContentStringsTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class ContentStringRow extends DataClass implements Insertable<ContentStringRow> {
  final String key;
  final String locale;
  final String value;
  const ContentStringRow({required this.key, required this.locale, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['locale'] = Variable<String>(locale);
    map['value'] = Variable<String>(value);
    return map;
  }

  ContentStringsCompanion toCompanion(bool nullToAbsent) {
    return ContentStringsCompanion(key: Value(key), locale: Value(locale), value: Value(value));
  }

  factory ContentStringRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentStringRow(
      key: serializer.fromJson<String>(json['key']),
      locale: serializer.fromJson<String>(json['locale']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'locale': serializer.toJson<String>(locale),
      'value': serializer.toJson<String>(value),
    };
  }

  ContentStringRow copyWith({String? key, String? locale, String? value}) => ContentStringRow(
    key: key ?? this.key,
    locale: locale ?? this.locale,
    value: value ?? this.value,
  );
  ContentStringRow copyWithCompanion(ContentStringsCompanion data) {
    return ContentStringRow(
      key: data.key.present ? data.key.value : this.key,
      locale: data.locale.present ? data.locale.value : this.locale,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentStringRow(')
          ..write('key: $key, ')
          ..write('locale: $locale, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, locale, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentStringRow &&
          other.key == this.key &&
          other.locale == this.locale &&
          other.value == this.value);
}

class ContentStringsCompanion extends UpdateCompanion<ContentStringRow> {
  final Value<String> key;
  final Value<String> locale;
  final Value<String> value;
  const ContentStringsCompanion({
    this.key = const Value.absent(),
    this.locale = const Value.absent(),
    this.value = const Value.absent(),
  });
  ContentStringsCompanion.insert({
    required String key,
    required String locale,
    required String value,
  }) : key = Value(key),
       locale = Value(locale),
       value = Value(value);
  static Insertable<ContentStringRow> custom({
    Expression<String>? key,
    Expression<String>? locale,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (locale != null) 'locale': locale,
      if (value != null) 'value': value,
    });
  }

  ContentStringsCompanion copyWith({
    Value<String>? key,
    Value<String>? locale,
    Value<String>? value,
  }) {
    return ContentStringsCompanion(
      key: key ?? this.key,
      locale: locale ?? this.locale,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentStringsCompanion(')
          ..write('key: $key, ')
          ..write('locale: $locale, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

class $LegalTextsTable extends LegalTexts with TableInfo<$LegalTextsTable, LegalTextRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LegalTextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jurisdictionIdMeta = const VerificationMeta('jurisdictionId');
  @override
  late final GeneratedColumn<int> jurisdictionId = GeneratedColumn<int>(
    'jurisdiction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES jurisdiction(id)',
  );
  static const VerificationMeta _citationIdMeta = const VerificationMeta('citationId');
  @override
  late final GeneratedColumn<int> citationId = GeneratedColumn<int>(
    'citation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES citation(id)',
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleRefMeta = const VerificationMeta('articleRef');
  @override
  late final GeneratedColumn<String> articleRef = GeneratedColumn<String>(
    'article_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyNormMeta = const VerificationMeta('bodyNorm');
  @override
  late final GeneratedColumn<String> bodyNorm = GeneratedColumn<String>(
    'body_norm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jurisdictionId,
    citationId,
    locale,
    articleRef,
    body,
    bodyNorm,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'legal_text';
  @override
  VerificationContext validateIntegrity(
    Insertable<LegalTextRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jurisdiction_id')) {
      context.handle(
        _jurisdictionIdMeta,
        jurisdictionId.isAcceptableOrUnknown(data['jurisdiction_id']!, _jurisdictionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jurisdictionIdMeta);
    }
    if (data.containsKey('citation_id')) {
      context.handle(
        _citationIdMeta,
        citationId.isAcceptableOrUnknown(data['citation_id']!, _citationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_citationIdMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta, locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('article_ref')) {
      context.handle(
        _articleRefMeta,
        articleRef.isAcceptableOrUnknown(data['article_ref']!, _articleRefMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('body_norm')) {
      context.handle(
        _bodyNormMeta,
        bodyNorm.isAcceptableOrUnknown(data['body_norm']!, _bodyNormMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyNormMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LegalTextRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LegalTextRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      jurisdictionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jurisdiction_id'],
      )!,
      citationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}citation_id'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      articleRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}article_ref'],
      ),
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      bodyNorm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_norm'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $LegalTextsTable createAlias(String alias) {
    return $LegalTextsTable(attachedDatabase, alias);
  }
}

class LegalTextRow extends DataClass implements Insertable<LegalTextRow> {
  final int id;
  final int jurisdictionId;
  final int citationId;
  final String locale;
  final String? articleRef;
  final String body;
  final String bodyNorm;
  final int sortOrder;
  const LegalTextRow({
    required this.id,
    required this.jurisdictionId,
    required this.citationId,
    required this.locale,
    this.articleRef,
    required this.body,
    required this.bodyNorm,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jurisdiction_id'] = Variable<int>(jurisdictionId);
    map['citation_id'] = Variable<int>(citationId);
    map['locale'] = Variable<String>(locale);
    if (!nullToAbsent || articleRef != null) {
      map['article_ref'] = Variable<String>(articleRef);
    }
    map['body'] = Variable<String>(body);
    map['body_norm'] = Variable<String>(bodyNorm);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  LegalTextsCompanion toCompanion(bool nullToAbsent) {
    return LegalTextsCompanion(
      id: Value(id),
      jurisdictionId: Value(jurisdictionId),
      citationId: Value(citationId),
      locale: Value(locale),
      articleRef: articleRef == null && nullToAbsent ? const Value.absent() : Value(articleRef),
      body: Value(body),
      bodyNorm: Value(bodyNorm),
      sortOrder: Value(sortOrder),
    );
  }

  factory LegalTextRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LegalTextRow(
      id: serializer.fromJson<int>(json['id']),
      jurisdictionId: serializer.fromJson<int>(json['jurisdictionId']),
      citationId: serializer.fromJson<int>(json['citationId']),
      locale: serializer.fromJson<String>(json['locale']),
      articleRef: serializer.fromJson<String?>(json['articleRef']),
      body: serializer.fromJson<String>(json['body']),
      bodyNorm: serializer.fromJson<String>(json['bodyNorm']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jurisdictionId': serializer.toJson<int>(jurisdictionId),
      'citationId': serializer.toJson<int>(citationId),
      'locale': serializer.toJson<String>(locale),
      'articleRef': serializer.toJson<String?>(articleRef),
      'body': serializer.toJson<String>(body),
      'bodyNorm': serializer.toJson<String>(bodyNorm),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  LegalTextRow copyWith({
    int? id,
    int? jurisdictionId,
    int? citationId,
    String? locale,
    Value<String?> articleRef = const Value.absent(),
    String? body,
    String? bodyNorm,
    int? sortOrder,
  }) => LegalTextRow(
    id: id ?? this.id,
    jurisdictionId: jurisdictionId ?? this.jurisdictionId,
    citationId: citationId ?? this.citationId,
    locale: locale ?? this.locale,
    articleRef: articleRef.present ? articleRef.value : this.articleRef,
    body: body ?? this.body,
    bodyNorm: bodyNorm ?? this.bodyNorm,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  LegalTextRow copyWithCompanion(LegalTextsCompanion data) {
    return LegalTextRow(
      id: data.id.present ? data.id.value : this.id,
      jurisdictionId: data.jurisdictionId.present ? data.jurisdictionId.value : this.jurisdictionId,
      citationId: data.citationId.present ? data.citationId.value : this.citationId,
      locale: data.locale.present ? data.locale.value : this.locale,
      articleRef: data.articleRef.present ? data.articleRef.value : this.articleRef,
      body: data.body.present ? data.body.value : this.body,
      bodyNorm: data.bodyNorm.present ? data.bodyNorm.value : this.bodyNorm,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LegalTextRow(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('citationId: $citationId, ')
          ..write('locale: $locale, ')
          ..write('articleRef: $articleRef, ')
          ..write('body: $body, ')
          ..write('bodyNorm: $bodyNorm, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, jurisdictionId, citationId, locale, articleRef, body, bodyNorm, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LegalTextRow &&
          other.id == this.id &&
          other.jurisdictionId == this.jurisdictionId &&
          other.citationId == this.citationId &&
          other.locale == this.locale &&
          other.articleRef == this.articleRef &&
          other.body == this.body &&
          other.bodyNorm == this.bodyNorm &&
          other.sortOrder == this.sortOrder);
}

class LegalTextsCompanion extends UpdateCompanion<LegalTextRow> {
  final Value<int> id;
  final Value<int> jurisdictionId;
  final Value<int> citationId;
  final Value<String> locale;
  final Value<String?> articleRef;
  final Value<String> body;
  final Value<String> bodyNorm;
  final Value<int> sortOrder;
  const LegalTextsCompanion({
    this.id = const Value.absent(),
    this.jurisdictionId = const Value.absent(),
    this.citationId = const Value.absent(),
    this.locale = const Value.absent(),
    this.articleRef = const Value.absent(),
    this.body = const Value.absent(),
    this.bodyNorm = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  LegalTextsCompanion.insert({
    this.id = const Value.absent(),
    required int jurisdictionId,
    required int citationId,
    required String locale,
    this.articleRef = const Value.absent(),
    required String body,
    required String bodyNorm,
    required int sortOrder,
  }) : jurisdictionId = Value(jurisdictionId),
       citationId = Value(citationId),
       locale = Value(locale),
       body = Value(body),
       bodyNorm = Value(bodyNorm),
       sortOrder = Value(sortOrder);
  static Insertable<LegalTextRow> custom({
    Expression<int>? id,
    Expression<int>? jurisdictionId,
    Expression<int>? citationId,
    Expression<String>? locale,
    Expression<String>? articleRef,
    Expression<String>? body,
    Expression<String>? bodyNorm,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jurisdictionId != null) 'jurisdiction_id': jurisdictionId,
      if (citationId != null) 'citation_id': citationId,
      if (locale != null) 'locale': locale,
      if (articleRef != null) 'article_ref': articleRef,
      if (body != null) 'body': body,
      if (bodyNorm != null) 'body_norm': bodyNorm,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  LegalTextsCompanion copyWith({
    Value<int>? id,
    Value<int>? jurisdictionId,
    Value<int>? citationId,
    Value<String>? locale,
    Value<String?>? articleRef,
    Value<String>? body,
    Value<String>? bodyNorm,
    Value<int>? sortOrder,
  }) {
    return LegalTextsCompanion(
      id: id ?? this.id,
      jurisdictionId: jurisdictionId ?? this.jurisdictionId,
      citationId: citationId ?? this.citationId,
      locale: locale ?? this.locale,
      articleRef: articleRef ?? this.articleRef,
      body: body ?? this.body,
      bodyNorm: bodyNorm ?? this.bodyNorm,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jurisdictionId.present) {
      map['jurisdiction_id'] = Variable<int>(jurisdictionId.value);
    }
    if (citationId.present) {
      map['citation_id'] = Variable<int>(citationId.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (articleRef.present) {
      map['article_ref'] = Variable<String>(articleRef.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (bodyNorm.present) {
      map['body_norm'] = Variable<String>(bodyNorm.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LegalTextsCompanion(')
          ..write('id: $id, ')
          ..write('jurisdictionId: $jurisdictionId, ')
          ..write('citationId: $citationId, ')
          ..write('locale: $locale, ')
          ..write('articleRef: $articleRef, ')
          ..write('body: $body, ')
          ..write('bodyNorm: $bodyNorm, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ContentMetasTable extends ContentMetas with TableInfo<$ContentMetasTable, ContentMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentMetasTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'content_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentMetaRow> instance, {
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
  ContentMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentMetaRow(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $ContentMetasTable createAlias(String alias) {
    return $ContentMetasTable(attachedDatabase, alias);
  }
}

class ContentMetaRow extends DataClass implements Insertable<ContentMetaRow> {
  final String key;
  final String value;
  const ContentMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  ContentMetasCompanion toCompanion(bool nullToAbsent) {
    return ContentMetasCompanion(key: Value(key), value: Value(value));
  }

  factory ContentMetaRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentMetaRow(
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

  ContentMetaRow copyWith({String? key, String? value}) =>
      ContentMetaRow(key: key ?? this.key, value: value ?? this.value);
  ContentMetaRow copyWithCompanion(ContentMetasCompanion data) {
    return ContentMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentMetaRow(')
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
      (other is ContentMetaRow && other.key == this.key && other.value == this.value);
}

class ContentMetasCompanion extends UpdateCompanion<ContentMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const ContentMetasCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentMetasCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<ContentMetaRow> custom({
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

  ContentMetasCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return ContentMetasCompanion(
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
    return (StringBuffer('ContentMetasCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ReferenceDatabase extends GeneratedDatabase {
  _$ReferenceDatabase(QueryExecutor e) : super(e);
  $ReferenceDatabaseManager get managers => $ReferenceDatabaseManager(this);
  late final $JurisdictionsTable jurisdictions = $JurisdictionsTable(this);
  late final $ZonesTable zones = $ZonesTable(this);
  late final $ZoneRingsTable zoneRings = $ZoneRingsTable(this);
  late final $FamiliesTable families = $FamiliesTable(this);
  late final $SpeciesTableTable speciesTable = $SpeciesTableTable(this);
  late final $SpeciesNamesTable speciesNames = $SpeciesNamesTable(this);
  late final $MeasurementMethodsTable measurementMethods = $MeasurementMethodsTable(this);
  late final $CitationsTable citations = $CitationsTable(this);
  late final $RulesTable rules = $RulesTable(this);
  late final $ClosedSeasonsTable closedSeasons = $ClosedSeasonsTable(this);
  late final $LicenceTypesTable licenceTypes = $LicenceTypesTable(this);
  late final $GearRulesTable gearRules = $GearRulesTable(this);
  late final $PenaltiesTable penalties = $PenaltiesTable(this);
  late final $LookalikesTable lookalikes = $LookalikesTable(this);
  late final $GlossaryTermsTable glossaryTerms = $GlossaryTermsTable(this);
  late final $ContentChangesTable contentChanges = $ContentChangesTable(this);
  late final $KeyNodesTable keyNodes = $KeyNodesTable(this);
  late final $KeyLeafSpeciesTable keyLeafSpecies = $KeyLeafSpeciesTable(this);
  late final $KeyOptionsTable keyOptions = $KeyOptionsTable(this);
  late final $ContentStringsTable contentStrings = $ContentStringsTable(this);
  late final $LegalTextsTable legalTexts = $LegalTextsTable(this);
  late final $ContentMetasTable contentMetas = $ContentMetasTable(this);
  late final Index idxZoneJuris = Index(
    'idx_zone_juris',
    'CREATE INDEX idx_zone_juris ON zone (jurisdiction_id)',
  );
  late final Index idxZoneBbox = Index(
    'idx_zone_bbox',
    'CREATE INDEX idx_zone_bbox ON zone (min_lat, max_lat, min_lon, max_lon)',
  );
  late final Index idxSpeciesFamily = Index(
    'idx_species_family',
    'CREATE INDEX idx_species_family ON species (family_id)',
  );
  late final Index idxNameSearch = Index(
    'idx_name_search',
    'CREATE INDEX idx_name_search ON species_name (search_norm)',
  );
  late final Index idxNameSpecies = Index(
    'idx_name_species',
    'CREATE INDEX idx_name_species ON species_name (species_id, locale)',
  );
  late final Index idxRuleLookup = Index(
    'idx_rule_lookup',
    'CREATE INDEX idx_rule_lookup ON rule (jurisdiction_id, species_id, water_type, valid_from)',
  );
  late final Index idxRuleZone = Index(
    'idx_rule_zone',
    'CREATE INDEX idx_rule_zone ON rule (zone_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jurisdictions,
    zones,
    zoneRings,
    families,
    speciesTable,
    speciesNames,
    measurementMethods,
    citations,
    rules,
    closedSeasons,
    licenceTypes,
    gearRules,
    penalties,
    lookalikes,
    glossaryTerms,
    contentChanges,
    keyNodes,
    keyLeafSpecies,
    keyOptions,
    contentStrings,
    legalTexts,
    contentMetas,
    idxZoneJuris,
    idxZoneBbox,
    idxSpeciesFamily,
    idxNameSearch,
    idxNameSpecies,
    idxRuleLookup,
    idxRuleZone,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('zone', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('zone_ring', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('species', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('species_name', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('rule', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('closed_season', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('species', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('lookalike', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('key_node', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('key_leaf_species', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('key_node', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('key_option', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$JurisdictionsTableCreateCompanionBuilder =
    JurisdictionsCompanion Function({
      Value<int> id,
      required String code,
      required String countryIso2,
      required String nameKey,
      required String authorityKey,
      Value<String?> authorityUrl,
      Value<bool> hasFreshwater,
      Value<bool> hasSaltwater,
      Value<bool> hasZonePolygons,
      required String defaultLocale,
      required String legalTextLocales,
      required String contentVersion,
      required String publishedOn,
      required String checkedOn,
      Value<String?> validUntil,
    });
typedef $$JurisdictionsTableUpdateCompanionBuilder =
    JurisdictionsCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> countryIso2,
      Value<String> nameKey,
      Value<String> authorityKey,
      Value<String?> authorityUrl,
      Value<bool> hasFreshwater,
      Value<bool> hasSaltwater,
      Value<bool> hasZonePolygons,
      Value<String> defaultLocale,
      Value<String> legalTextLocales,
      Value<String> contentVersion,
      Value<String> publishedOn,
      Value<String> checkedOn,
      Value<String?> validUntil,
    });

class $$JurisdictionsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $JurisdictionsTable> {
  $$JurisdictionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get countryIso2 =>
      $composableBuilder(column: $table.countryIso2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorityKey =>
      $composableBuilder(column: $table.authorityKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorityUrl =>
      $composableBuilder(column: $table.authorityUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasFreshwater =>
      $composableBuilder(column: $table.hasFreshwater, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasSaltwater =>
      $composableBuilder(column: $table.hasSaltwater, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasZonePolygons => $composableBuilder(
    column: $table.hasZonePolygons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultLocale =>
      $composableBuilder(column: $table.defaultLocale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get legalTextLocales => $composableBuilder(
    column: $table.legalTextLocales,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentVersion =>
      $composableBuilder(column: $table.contentVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publishedOn =>
      $composableBuilder(column: $table.publishedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checkedOn =>
      $composableBuilder(column: $table.checkedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get validUntil =>
      $composableBuilder(column: $table.validUntil, builder: (column) => ColumnFilters(column));
}

class $$JurisdictionsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $JurisdictionsTable> {
  $$JurisdictionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get countryIso2 =>
      $composableBuilder(column: $table.countryIso2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorityKey =>
      $composableBuilder(column: $table.authorityKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorityUrl =>
      $composableBuilder(column: $table.authorityUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasFreshwater => $composableBuilder(
    column: $table.hasFreshwater,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasSaltwater =>
      $composableBuilder(column: $table.hasSaltwater, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasZonePolygons => $composableBuilder(
    column: $table.hasZonePolygons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultLocale => $composableBuilder(
    column: $table.defaultLocale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalTextLocales => $composableBuilder(
    column: $table.legalTextLocales,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentVersion => $composableBuilder(
    column: $table.contentVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publishedOn =>
      $composableBuilder(column: $table.publishedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checkedOn =>
      $composableBuilder(column: $table.checkedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get validUntil =>
      $composableBuilder(column: $table.validUntil, builder: (column) => ColumnOrderings(column));
}

class $$JurisdictionsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $JurisdictionsTable> {
  $$JurisdictionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get countryIso2 =>
      $composableBuilder(column: $table.countryIso2, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get authorityKey =>
      $composableBuilder(column: $table.authorityKey, builder: (column) => column);

  GeneratedColumn<String> get authorityUrl =>
      $composableBuilder(column: $table.authorityUrl, builder: (column) => column);

  GeneratedColumn<bool> get hasFreshwater =>
      $composableBuilder(column: $table.hasFreshwater, builder: (column) => column);

  GeneratedColumn<bool> get hasSaltwater =>
      $composableBuilder(column: $table.hasSaltwater, builder: (column) => column);

  GeneratedColumn<bool> get hasZonePolygons =>
      $composableBuilder(column: $table.hasZonePolygons, builder: (column) => column);

  GeneratedColumn<String> get defaultLocale =>
      $composableBuilder(column: $table.defaultLocale, builder: (column) => column);

  GeneratedColumn<String> get legalTextLocales =>
      $composableBuilder(column: $table.legalTextLocales, builder: (column) => column);

  GeneratedColumn<String> get contentVersion =>
      $composableBuilder(column: $table.contentVersion, builder: (column) => column);

  GeneratedColumn<String> get publishedOn =>
      $composableBuilder(column: $table.publishedOn, builder: (column) => column);

  GeneratedColumn<String> get checkedOn =>
      $composableBuilder(column: $table.checkedOn, builder: (column) => column);

  GeneratedColumn<String> get validUntil =>
      $composableBuilder(column: $table.validUntil, builder: (column) => column);
}

class $$JurisdictionsTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $JurisdictionsTable,
          JurisdictionRow,
          $$JurisdictionsTableFilterComposer,
          $$JurisdictionsTableOrderingComposer,
          $$JurisdictionsTableAnnotationComposer,
          $$JurisdictionsTableCreateCompanionBuilder,
          $$JurisdictionsTableUpdateCompanionBuilder,
          (
            JurisdictionRow,
            BaseReferences<_$ReferenceDatabase, $JurisdictionsTable, JurisdictionRow>,
          ),
          JurisdictionRow,
          PrefetchHooks Function()
        > {
  $$JurisdictionsTableTableManager(_$ReferenceDatabase db, $JurisdictionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$JurisdictionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JurisdictionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JurisdictionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> countryIso2 = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> authorityKey = const Value.absent(),
                Value<String?> authorityUrl = const Value.absent(),
                Value<bool> hasFreshwater = const Value.absent(),
                Value<bool> hasSaltwater = const Value.absent(),
                Value<bool> hasZonePolygons = const Value.absent(),
                Value<String> defaultLocale = const Value.absent(),
                Value<String> legalTextLocales = const Value.absent(),
                Value<String> contentVersion = const Value.absent(),
                Value<String> publishedOn = const Value.absent(),
                Value<String> checkedOn = const Value.absent(),
                Value<String?> validUntil = const Value.absent(),
              }) => JurisdictionsCompanion(
                id: id,
                code: code,
                countryIso2: countryIso2,
                nameKey: nameKey,
                authorityKey: authorityKey,
                authorityUrl: authorityUrl,
                hasFreshwater: hasFreshwater,
                hasSaltwater: hasSaltwater,
                hasZonePolygons: hasZonePolygons,
                defaultLocale: defaultLocale,
                legalTextLocales: legalTextLocales,
                contentVersion: contentVersion,
                publishedOn: publishedOn,
                checkedOn: checkedOn,
                validUntil: validUntil,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String countryIso2,
                required String nameKey,
                required String authorityKey,
                Value<String?> authorityUrl = const Value.absent(),
                Value<bool> hasFreshwater = const Value.absent(),
                Value<bool> hasSaltwater = const Value.absent(),
                Value<bool> hasZonePolygons = const Value.absent(),
                required String defaultLocale,
                required String legalTextLocales,
                required String contentVersion,
                required String publishedOn,
                required String checkedOn,
                Value<String?> validUntil = const Value.absent(),
              }) => JurisdictionsCompanion.insert(
                id: id,
                code: code,
                countryIso2: countryIso2,
                nameKey: nameKey,
                authorityKey: authorityKey,
                authorityUrl: authorityUrl,
                hasFreshwater: hasFreshwater,
                hasSaltwater: hasSaltwater,
                hasZonePolygons: hasZonePolygons,
                defaultLocale: defaultLocale,
                legalTextLocales: legalTextLocales,
                contentVersion: contentVersion,
                publishedOn: publishedOn,
                checkedOn: checkedOn,
                validUntil: validUntil,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JurisdictionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $JurisdictionsTable,
      JurisdictionRow,
      $$JurisdictionsTableFilterComposer,
      $$JurisdictionsTableOrderingComposer,
      $$JurisdictionsTableAnnotationComposer,
      $$JurisdictionsTableCreateCompanionBuilder,
      $$JurisdictionsTableUpdateCompanionBuilder,
      (JurisdictionRow, BaseReferences<_$ReferenceDatabase, $JurisdictionsTable, JurisdictionRow>),
      JurisdictionRow,
      PrefetchHooks Function()
    >;
typedef $$ZonesTableCreateCompanionBuilder =
    ZonesCompanion Function({
      Value<int> id,
      required int jurisdictionId,
      Value<int?> parentZoneId,
      required String code,
      required String nameKey,
      required String waterType,
      required String zoneKind,
      Value<String?> geometrySource,
      Value<double?> minLat,
      Value<double?> minLon,
      Value<double?> maxLat,
      Value<double?> maxLon,
    });
typedef $$ZonesTableUpdateCompanionBuilder =
    ZonesCompanion Function({
      Value<int> id,
      Value<int> jurisdictionId,
      Value<int?> parentZoneId,
      Value<String> code,
      Value<String> nameKey,
      Value<String> waterType,
      Value<String> zoneKind,
      Value<String?> geometrySource,
      Value<double?> minLat,
      Value<double?> minLon,
      Value<double?> maxLat,
      Value<double?> maxLon,
    });

final class $$ZonesTableReferences
    extends BaseReferences<_$ReferenceDatabase, $ZonesTable, ZoneRow> {
  $$ZonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ZoneRingsTable, List<ZoneRingRow>> _zoneRingsRefsTable(
    _$ReferenceDatabase db,
  ) => MultiTypedResultKey.fromTable(db.zoneRings, aliasName: 'zone__id__zone_ring__zone_id');

  $$ZoneRingsTableProcessedTableManager get zoneRingsRefs {
    final manager = $$ZoneRingsTableTableManager(
      $_db,
      $_db.zoneRings,
    ).filter((f) => f.zoneId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_zoneRingsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ZonesTableFilterComposer extends Composer<_$ReferenceDatabase, $ZonesTable> {
  $$ZonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentZoneId =>
      $composableBuilder(column: $table.parentZoneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get waterType =>
      $composableBuilder(column: $table.waterType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get zoneKind =>
      $composableBuilder(column: $table.zoneKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get geometrySource =>
      $composableBuilder(column: $table.geometrySource, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minLat =>
      $composableBuilder(column: $table.minLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minLon =>
      $composableBuilder(column: $table.minLon, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxLat =>
      $composableBuilder(column: $table.maxLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxLon =>
      $composableBuilder(column: $table.maxLon, builder: (column) => ColumnFilters(column));

  Expression<bool> zoneRingsRefs(Expression<bool> Function($$ZoneRingsTableFilterComposer f) f) {
    final $$ZoneRingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zoneRings,
      getReferencedColumn: (t) => t.zoneId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ZoneRingsTableFilterComposer(
            $db: $db,
            $table: $db.zoneRings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZonesTableOrderingComposer extends Composer<_$ReferenceDatabase, $ZonesTable> {
  $$ZonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentZoneId =>
      $composableBuilder(column: $table.parentZoneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get waterType =>
      $composableBuilder(column: $table.waterType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get zoneKind =>
      $composableBuilder(column: $table.zoneKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geometrySource => $composableBuilder(
    column: $table.geometrySource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minLat =>
      $composableBuilder(column: $table.minLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minLon =>
      $composableBuilder(column: $table.minLon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxLat =>
      $composableBuilder(column: $table.maxLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxLon =>
      $composableBuilder(column: $table.maxLon, builder: (column) => ColumnOrderings(column));
}

class $$ZonesTableAnnotationComposer extends Composer<_$ReferenceDatabase, $ZonesTable> {
  $$ZonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => column);

  GeneratedColumn<int> get parentZoneId =>
      $composableBuilder(column: $table.parentZoneId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get waterType =>
      $composableBuilder(column: $table.waterType, builder: (column) => column);

  GeneratedColumn<String> get zoneKind =>
      $composableBuilder(column: $table.zoneKind, builder: (column) => column);

  GeneratedColumn<String> get geometrySource =>
      $composableBuilder(column: $table.geometrySource, builder: (column) => column);

  GeneratedColumn<double> get minLat =>
      $composableBuilder(column: $table.minLat, builder: (column) => column);

  GeneratedColumn<double> get minLon =>
      $composableBuilder(column: $table.minLon, builder: (column) => column);

  GeneratedColumn<double> get maxLat =>
      $composableBuilder(column: $table.maxLat, builder: (column) => column);

  GeneratedColumn<double> get maxLon =>
      $composableBuilder(column: $table.maxLon, builder: (column) => column);

  Expression<T> zoneRingsRefs<T extends Object>(
    Expression<T> Function($$ZoneRingsTableAnnotationComposer a) f,
  ) {
    final $$ZoneRingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.zoneRings,
      getReferencedColumn: (t) => t.zoneId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ZoneRingsTableAnnotationComposer(
            $db: $db,
            $table: $db.zoneRings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ZonesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $ZonesTable,
          ZoneRow,
          $$ZonesTableFilterComposer,
          $$ZonesTableOrderingComposer,
          $$ZonesTableAnnotationComposer,
          $$ZonesTableCreateCompanionBuilder,
          $$ZonesTableUpdateCompanionBuilder,
          (ZoneRow, $$ZonesTableReferences),
          ZoneRow,
          PrefetchHooks Function({bool zoneRingsRefs})
        > {
  $$ZonesTableTableManager(_$ReferenceDatabase db, $ZonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ZonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ZonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ZonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jurisdictionId = const Value.absent(),
                Value<int?> parentZoneId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> waterType = const Value.absent(),
                Value<String> zoneKind = const Value.absent(),
                Value<String?> geometrySource = const Value.absent(),
                Value<double?> minLat = const Value.absent(),
                Value<double?> minLon = const Value.absent(),
                Value<double?> maxLat = const Value.absent(),
                Value<double?> maxLon = const Value.absent(),
              }) => ZonesCompanion(
                id: id,
                jurisdictionId: jurisdictionId,
                parentZoneId: parentZoneId,
                code: code,
                nameKey: nameKey,
                waterType: waterType,
                zoneKind: zoneKind,
                geometrySource: geometrySource,
                minLat: minLat,
                minLon: minLon,
                maxLat: maxLat,
                maxLon: maxLon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jurisdictionId,
                Value<int?> parentZoneId = const Value.absent(),
                required String code,
                required String nameKey,
                required String waterType,
                required String zoneKind,
                Value<String?> geometrySource = const Value.absent(),
                Value<double?> minLat = const Value.absent(),
                Value<double?> minLon = const Value.absent(),
                Value<double?> maxLat = const Value.absent(),
                Value<double?> maxLon = const Value.absent(),
              }) => ZonesCompanion.insert(
                id: id,
                jurisdictionId: jurisdictionId,
                parentZoneId: parentZoneId,
                code: code,
                nameKey: nameKey,
                waterType: waterType,
                zoneKind: zoneKind,
                geometrySource: geometrySource,
                minLat: minLat,
                minLon: minLon,
                maxLat: maxLat,
                maxLon: maxLon,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$ZonesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({zoneRingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (zoneRingsRefs) db.zoneRings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (zoneRingsRefs)
                    await $_getPrefetchedData<ZoneRow, $ZonesTable, ZoneRingRow>(
                      currentTable: table,
                      referencedTable: $$ZonesTableReferences._zoneRingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ZonesTableReferences(db, table, p0).zoneRingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.zoneId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ZonesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $ZonesTable,
      ZoneRow,
      $$ZonesTableFilterComposer,
      $$ZonesTableOrderingComposer,
      $$ZonesTableAnnotationComposer,
      $$ZonesTableCreateCompanionBuilder,
      $$ZonesTableUpdateCompanionBuilder,
      (ZoneRow, $$ZonesTableReferences),
      ZoneRow,
      PrefetchHooks Function({bool zoneRingsRefs})
    >;
typedef $$ZoneRingsTableCreateCompanionBuilder =
    ZoneRingsCompanion Function({
      Value<int> id,
      required int zoneId,
      required int ringIndex,
      Value<bool> isHole,
      required int pointCount,
      required Uint8List coords,
    });
typedef $$ZoneRingsTableUpdateCompanionBuilder =
    ZoneRingsCompanion Function({
      Value<int> id,
      Value<int> zoneId,
      Value<int> ringIndex,
      Value<bool> isHole,
      Value<int> pointCount,
      Value<Uint8List> coords,
    });

final class $$ZoneRingsTableReferences
    extends BaseReferences<_$ReferenceDatabase, $ZoneRingsTable, ZoneRingRow> {
  $$ZoneRingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ZonesTable _zoneIdTable(_$ReferenceDatabase db) =>
      db.zones.createAlias('zone_ring__zone_id__zone__id');

  $$ZonesTableProcessedTableManager get zoneId {
    final $_column = $_itemColumn<int>('zone_id')!;

    final manager = $$ZonesTableTableManager(
      $_db,
      $_db.zones,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_zoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ZoneRingsTableFilterComposer extends Composer<_$ReferenceDatabase, $ZoneRingsTable> {
  $$ZoneRingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ringIndex =>
      $composableBuilder(column: $table.ringIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isHole =>
      $composableBuilder(column: $table.isHole, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pointCount =>
      $composableBuilder(column: $table.pointCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get coords =>
      $composableBuilder(column: $table.coords, builder: (column) => ColumnFilters(column));

  $$ZonesTableFilterComposer get zoneId {
    final $$ZonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ZonesTableFilterComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZoneRingsTableOrderingComposer extends Composer<_$ReferenceDatabase, $ZoneRingsTable> {
  $$ZoneRingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ringIndex =>
      $composableBuilder(column: $table.ringIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isHole =>
      $composableBuilder(column: $table.isHole, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pointCount =>
      $composableBuilder(column: $table.pointCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get coords =>
      $composableBuilder(column: $table.coords, builder: (column) => ColumnOrderings(column));

  $$ZonesTableOrderingComposer get zoneId {
    final $$ZonesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ZonesTableOrderingComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZoneRingsTableAnnotationComposer extends Composer<_$ReferenceDatabase, $ZoneRingsTable> {
  $$ZoneRingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ringIndex =>
      $composableBuilder(column: $table.ringIndex, builder: (column) => column);

  GeneratedColumn<bool> get isHole =>
      $composableBuilder(column: $table.isHole, builder: (column) => column);

  GeneratedColumn<int> get pointCount =>
      $composableBuilder(column: $table.pointCount, builder: (column) => column);

  GeneratedColumn<Uint8List> get coords =>
      $composableBuilder(column: $table.coords, builder: (column) => column);

  $$ZonesTableAnnotationComposer get zoneId {
    final $$ZonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.zoneId,
      referencedTable: $db.zones,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ZonesTableAnnotationComposer(
            $db: $db,
            $table: $db.zones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ZoneRingsTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $ZoneRingsTable,
          ZoneRingRow,
          $$ZoneRingsTableFilterComposer,
          $$ZoneRingsTableOrderingComposer,
          $$ZoneRingsTableAnnotationComposer,
          $$ZoneRingsTableCreateCompanionBuilder,
          $$ZoneRingsTableUpdateCompanionBuilder,
          (ZoneRingRow, $$ZoneRingsTableReferences),
          ZoneRingRow,
          PrefetchHooks Function({bool zoneId})
        > {
  $$ZoneRingsTableTableManager(_$ReferenceDatabase db, $ZoneRingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ZoneRingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ZoneRingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ZoneRingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> zoneId = const Value.absent(),
                Value<int> ringIndex = const Value.absent(),
                Value<bool> isHole = const Value.absent(),
                Value<int> pointCount = const Value.absent(),
                Value<Uint8List> coords = const Value.absent(),
              }) => ZoneRingsCompanion(
                id: id,
                zoneId: zoneId,
                ringIndex: ringIndex,
                isHole: isHole,
                pointCount: pointCount,
                coords: coords,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int zoneId,
                required int ringIndex,
                Value<bool> isHole = const Value.absent(),
                required int pointCount,
                required Uint8List coords,
              }) => ZoneRingsCompanion.insert(
                id: id,
                zoneId: zoneId,
                ringIndex: ringIndex,
                isHole: isHole,
                pointCount: pointCount,
                coords: coords,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$ZoneRingsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({zoneId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (zoneId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.zoneId,
                                referencedTable: $$ZoneRingsTableReferences._zoneIdTable(db),
                                referencedColumn: $$ZoneRingsTableReferences._zoneIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ZoneRingsTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $ZoneRingsTable,
      ZoneRingRow,
      $$ZoneRingsTableFilterComposer,
      $$ZoneRingsTableOrderingComposer,
      $$ZoneRingsTableAnnotationComposer,
      $$ZoneRingsTableCreateCompanionBuilder,
      $$ZoneRingsTableUpdateCompanionBuilder,
      (ZoneRingRow, $$ZoneRingsTableReferences),
      ZoneRingRow,
      PrefetchHooks Function({bool zoneId})
    >;
typedef $$FamiliesTableCreateCompanionBuilder =
    FamiliesCompanion Function({
      Value<int> id,
      required String scientific,
      required String nameKey,
    });
typedef $$FamiliesTableUpdateCompanionBuilder =
    FamiliesCompanion Function({Value<int> id, Value<String> scientific, Value<String> nameKey});

final class $$FamiliesTableReferences
    extends BaseReferences<_$ReferenceDatabase, $FamiliesTable, FamilyRow> {
  $$FamiliesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SpeciesTableTable, List<SpeciesRow>> _speciesTableRefsTable(
    _$ReferenceDatabase db,
  ) => MultiTypedResultKey.fromTable(db.speciesTable, aliasName: 'family__id__species__family_id');

  $$SpeciesTableTableProcessedTableManager get speciesTableRefs {
    final manager = $$SpeciesTableTableTableManager(
      $_db,
      $_db.speciesTable,
    ).filter((f) => f.familyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_speciesTableRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FamiliesTableFilterComposer extends Composer<_$ReferenceDatabase, $FamiliesTable> {
  $$FamiliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scientific =>
      $composableBuilder(column: $table.scientific, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnFilters(column));

  Expression<bool> speciesTableRefs(
    Expression<bool> Function($$SpeciesTableTableFilterComposer f) f,
  ) {
    final $$SpeciesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.familyId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableFilterComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FamiliesTableOrderingComposer extends Composer<_$ReferenceDatabase, $FamiliesTable> {
  $$FamiliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scientific =>
      $composableBuilder(column: $table.scientific, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnOrderings(column));
}

class $$FamiliesTableAnnotationComposer extends Composer<_$ReferenceDatabase, $FamiliesTable> {
  $$FamiliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scientific =>
      $composableBuilder(column: $table.scientific, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  Expression<T> speciesTableRefs<T extends Object>(
    Expression<T> Function($$SpeciesTableTableAnnotationComposer a) f,
  ) {
    final $$SpeciesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.familyId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FamiliesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $FamiliesTable,
          FamilyRow,
          $$FamiliesTableFilterComposer,
          $$FamiliesTableOrderingComposer,
          $$FamiliesTableAnnotationComposer,
          $$FamiliesTableCreateCompanionBuilder,
          $$FamiliesTableUpdateCompanionBuilder,
          (FamilyRow, $$FamiliesTableReferences),
          FamilyRow,
          PrefetchHooks Function({bool speciesTableRefs})
        > {
  $$FamiliesTableTableManager(_$ReferenceDatabase db, $FamiliesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FamiliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FamiliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamiliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scientific = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
              }) => FamiliesCompanion(id: id, scientific: scientific, nameKey: nameKey),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scientific,
                required String nameKey,
              }) => FamiliesCompanion.insert(id: id, scientific: scientific, nameKey: nameKey),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$FamiliesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({speciesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (speciesTableRefs) db.speciesTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (speciesTableRefs)
                    await $_getPrefetchedData<FamilyRow, $FamiliesTable, SpeciesRow>(
                      currentTable: table,
                      referencedTable: $$FamiliesTableReferences._speciesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FamiliesTableReferences(db, table, p0).speciesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.familyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FamiliesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $FamiliesTable,
      FamilyRow,
      $$FamiliesTableFilterComposer,
      $$FamiliesTableOrderingComposer,
      $$FamiliesTableAnnotationComposer,
      $$FamiliesTableCreateCompanionBuilder,
      $$FamiliesTableUpdateCompanionBuilder,
      (FamilyRow, $$FamiliesTableReferences),
      FamilyRow,
      PrefetchHooks Function({bool speciesTableRefs})
    >;
typedef $$SpeciesTableTableCreateCompanionBuilder =
    SpeciesTableCompanion Function({
      Value<int> id,
      required String scientificName,
      Value<String?> colId,
      required int familyId,
      required String taxonGroup,
      required String silhouetteAsset,
      Value<String?> plateAsset,
    });
typedef $$SpeciesTableTableUpdateCompanionBuilder =
    SpeciesTableCompanion Function({
      Value<int> id,
      Value<String> scientificName,
      Value<String?> colId,
      Value<int> familyId,
      Value<String> taxonGroup,
      Value<String> silhouetteAsset,
      Value<String?> plateAsset,
    });

final class $$SpeciesTableTableReferences
    extends BaseReferences<_$ReferenceDatabase, $SpeciesTableTable, SpeciesRow> {
  $$SpeciesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FamiliesTable _familyIdTable(_$ReferenceDatabase db) =>
      db.families.createAlias('species__family_id__family__id');

  $$FamiliesTableProcessedTableManager get familyId {
    final $_column = $_itemColumn<int>('family_id')!;

    final manager = $$FamiliesTableTableManager(
      $_db,
      $_db.families,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_familyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SpeciesNamesTable, List<SpeciesNameRow>> _speciesNamesRefsTable(
    _$ReferenceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.speciesNames,
    aliasName: 'species__id__species_name__species_id',
  );

  $$SpeciesNamesTableProcessedTableManager get speciesNamesRefs {
    final manager = $$SpeciesNamesTableTableManager(
      $_db,
      $_db.speciesNames,
    ).filter((f) => f.speciesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_speciesNamesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SpeciesTableTableFilterComposer extends Composer<_$ReferenceDatabase, $SpeciesTableTable> {
  $$SpeciesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scientificName =>
      $composableBuilder(column: $table.scientificName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colId =>
      $composableBuilder(column: $table.colId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonGroup =>
      $composableBuilder(column: $table.taxonGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get silhouetteAsset => $composableBuilder(
    column: $table.silhouetteAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plateAsset =>
      $composableBuilder(column: $table.plateAsset, builder: (column) => ColumnFilters(column));

  $$FamiliesTableFilterComposer get familyId {
    final $$FamiliesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FamiliesTableFilterComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> speciesNamesRefs(
    Expression<bool> Function($$SpeciesNamesTableFilterComposer f) f,
  ) {
    final $$SpeciesNamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.speciesNames,
      getReferencedColumn: (t) => t.speciesId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesNamesTableFilterComposer(
            $db: $db,
            $table: $db.speciesNames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SpeciesTableTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $SpeciesTableTable> {
  $$SpeciesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scientificName => $composableBuilder(
    column: $table.scientificName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colId =>
      $composableBuilder(column: $table.colId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonGroup =>
      $composableBuilder(column: $table.taxonGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get silhouetteAsset => $composableBuilder(
    column: $table.silhouetteAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plateAsset =>
      $composableBuilder(column: $table.plateAsset, builder: (column) => ColumnOrderings(column));

  $$FamiliesTableOrderingComposer get familyId {
    final $$FamiliesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FamiliesTableOrderingComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeciesTableTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $SpeciesTableTable> {
  $$SpeciesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scientificName =>
      $composableBuilder(column: $table.scientificName, builder: (column) => column);

  GeneratedColumn<String> get colId =>
      $composableBuilder(column: $table.colId, builder: (column) => column);

  GeneratedColumn<String> get taxonGroup =>
      $composableBuilder(column: $table.taxonGroup, builder: (column) => column);

  GeneratedColumn<String> get silhouetteAsset =>
      $composableBuilder(column: $table.silhouetteAsset, builder: (column) => column);

  GeneratedColumn<String> get plateAsset =>
      $composableBuilder(column: $table.plateAsset, builder: (column) => column);

  $$FamiliesTableAnnotationComposer get familyId {
    final $$FamiliesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.familyId,
      referencedTable: $db.families,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FamiliesTableAnnotationComposer(
            $db: $db,
            $table: $db.families,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> speciesNamesRefs<T extends Object>(
    Expression<T> Function($$SpeciesNamesTableAnnotationComposer a) f,
  ) {
    final $$SpeciesNamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.speciesNames,
      getReferencedColumn: (t) => t.speciesId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesNamesTableAnnotationComposer(
            $db: $db,
            $table: $db.speciesNames,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SpeciesTableTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $SpeciesTableTable,
          SpeciesRow,
          $$SpeciesTableTableFilterComposer,
          $$SpeciesTableTableOrderingComposer,
          $$SpeciesTableTableAnnotationComposer,
          $$SpeciesTableTableCreateCompanionBuilder,
          $$SpeciesTableTableUpdateCompanionBuilder,
          (SpeciesRow, $$SpeciesTableTableReferences),
          SpeciesRow,
          PrefetchHooks Function({bool familyId, bool speciesNamesRefs})
        > {
  $$SpeciesTableTableTableManager(_$ReferenceDatabase db, $SpeciesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SpeciesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SpeciesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> scientificName = const Value.absent(),
                Value<String?> colId = const Value.absent(),
                Value<int> familyId = const Value.absent(),
                Value<String> taxonGroup = const Value.absent(),
                Value<String> silhouetteAsset = const Value.absent(),
                Value<String?> plateAsset = const Value.absent(),
              }) => SpeciesTableCompanion(
                id: id,
                scientificName: scientificName,
                colId: colId,
                familyId: familyId,
                taxonGroup: taxonGroup,
                silhouetteAsset: silhouetteAsset,
                plateAsset: plateAsset,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String scientificName,
                Value<String?> colId = const Value.absent(),
                required int familyId,
                required String taxonGroup,
                required String silhouetteAsset,
                Value<String?> plateAsset = const Value.absent(),
              }) => SpeciesTableCompanion.insert(
                id: id,
                scientificName: scientificName,
                colId: colId,
                familyId: familyId,
                taxonGroup: taxonGroup,
                silhouetteAsset: silhouetteAsset,
                plateAsset: plateAsset,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$SpeciesTableTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({familyId = false, speciesNamesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (speciesNamesRefs) db.speciesNames],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (familyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.familyId,
                                referencedTable: $$SpeciesTableTableReferences._familyIdTable(db),
                                referencedColumn: $$SpeciesTableTableReferences
                                    ._familyIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (speciesNamesRefs)
                    await $_getPrefetchedData<SpeciesRow, $SpeciesTableTable, SpeciesNameRow>(
                      currentTable: table,
                      referencedTable: $$SpeciesTableTableReferences._speciesNamesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SpeciesTableTableReferences(db, table, p0).speciesNamesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.speciesId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SpeciesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $SpeciesTableTable,
      SpeciesRow,
      $$SpeciesTableTableFilterComposer,
      $$SpeciesTableTableOrderingComposer,
      $$SpeciesTableTableAnnotationComposer,
      $$SpeciesTableTableCreateCompanionBuilder,
      $$SpeciesTableTableUpdateCompanionBuilder,
      (SpeciesRow, $$SpeciesTableTableReferences),
      SpeciesRow,
      PrefetchHooks Function({bool familyId, bool speciesNamesRefs})
    >;
typedef $$SpeciesNamesTableCreateCompanionBuilder =
    SpeciesNamesCompanion Function({
      Value<int> id,
      required int speciesId,
      required String locale,
      required String name,
      required String searchNorm,
      Value<String?> gender,
      Value<bool> isPrimary,
      Value<String?> regionHint,
    });
typedef $$SpeciesNamesTableUpdateCompanionBuilder =
    SpeciesNamesCompanion Function({
      Value<int> id,
      Value<int> speciesId,
      Value<String> locale,
      Value<String> name,
      Value<String> searchNorm,
      Value<String?> gender,
      Value<bool> isPrimary,
      Value<String?> regionHint,
    });

final class $$SpeciesNamesTableReferences
    extends BaseReferences<_$ReferenceDatabase, $SpeciesNamesTable, SpeciesNameRow> {
  $$SpeciesNamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpeciesTableTable _speciesIdTable(_$ReferenceDatabase db) =>
      db.speciesTable.createAlias('species_name__species_id__species__id');

  $$SpeciesTableTableProcessedTableManager get speciesId {
    final $_column = $_itemColumn<int>('species_id')!;

    final manager = $$SpeciesTableTableTableManager(
      $_db,
      $_db.speciesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_speciesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SpeciesNamesTableFilterComposer extends Composer<_$ReferenceDatabase, $SpeciesNamesTable> {
  $$SpeciesNamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get searchNorm =>
      $composableBuilder(column: $table.searchNorm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get regionHint =>
      $composableBuilder(column: $table.regionHint, builder: (column) => ColumnFilters(column));

  $$SpeciesTableTableFilterComposer get speciesId {
    final $$SpeciesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableFilterComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeciesNamesTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $SpeciesNamesTable> {
  $$SpeciesNamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get searchNorm =>
      $composableBuilder(column: $table.searchNorm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get regionHint =>
      $composableBuilder(column: $table.regionHint, builder: (column) => ColumnOrderings(column));

  $$SpeciesTableTableOrderingComposer get speciesId {
    final $$SpeciesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableOrderingComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeciesNamesTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $SpeciesNamesTable> {
  $$SpeciesNamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get searchNorm =>
      $composableBuilder(column: $table.searchNorm, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<String> get regionHint =>
      $composableBuilder(column: $table.regionHint, builder: (column) => column);

  $$SpeciesTableTableAnnotationComposer get speciesId {
    final $$SpeciesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SpeciesNamesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $SpeciesNamesTable,
          SpeciesNameRow,
          $$SpeciesNamesTableFilterComposer,
          $$SpeciesNamesTableOrderingComposer,
          $$SpeciesNamesTableAnnotationComposer,
          $$SpeciesNamesTableCreateCompanionBuilder,
          $$SpeciesNamesTableUpdateCompanionBuilder,
          (SpeciesNameRow, $$SpeciesNamesTableReferences),
          SpeciesNameRow,
          PrefetchHooks Function({bool speciesId})
        > {
  $$SpeciesNamesTableTableManager(_$ReferenceDatabase db, $SpeciesNamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SpeciesNamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SpeciesNamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SpeciesNamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> searchNorm = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<String?> regionHint = const Value.absent(),
              }) => SpeciesNamesCompanion(
                id: id,
                speciesId: speciesId,
                locale: locale,
                name: name,
                searchNorm: searchNorm,
                gender: gender,
                isPrimary: isPrimary,
                regionHint: regionHint,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int speciesId,
                required String locale,
                required String name,
                required String searchNorm,
                Value<String?> gender = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<String?> regionHint = const Value.absent(),
              }) => SpeciesNamesCompanion.insert(
                id: id,
                speciesId: speciesId,
                locale: locale,
                name: name,
                searchNorm: searchNorm,
                gender: gender,
                isPrimary: isPrimary,
                regionHint: regionHint,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$SpeciesNamesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({speciesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (speciesId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.speciesId,
                                referencedTable: $$SpeciesNamesTableReferences._speciesIdTable(db),
                                referencedColumn: $$SpeciesNamesTableReferences
                                    ._speciesIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SpeciesNamesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $SpeciesNamesTable,
      SpeciesNameRow,
      $$SpeciesNamesTableFilterComposer,
      $$SpeciesNamesTableOrderingComposer,
      $$SpeciesNamesTableAnnotationComposer,
      $$SpeciesNamesTableCreateCompanionBuilder,
      $$SpeciesNamesTableUpdateCompanionBuilder,
      (SpeciesNameRow, $$SpeciesNamesTableReferences),
      SpeciesNameRow,
      PrefetchHooks Function({bool speciesId})
    >;
typedef $$MeasurementMethodsTableCreateCompanionBuilder =
    MeasurementMethodsCompanion Function({
      Value<int> id,
      required String code,
      required String nameKey,
      required String definitionKey,
      required String diagramAsset,
    });
typedef $$MeasurementMethodsTableUpdateCompanionBuilder =
    MeasurementMethodsCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> nameKey,
      Value<String> definitionKey,
      Value<String> diagramAsset,
    });

class $$MeasurementMethodsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $MeasurementMethodsTable> {
  $$MeasurementMethodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get definitionKey =>
      $composableBuilder(column: $table.definitionKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagramAsset =>
      $composableBuilder(column: $table.diagramAsset, builder: (column) => ColumnFilters(column));
}

class $$MeasurementMethodsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $MeasurementMethodsTable> {
  $$MeasurementMethodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get definitionKey => $composableBuilder(
    column: $table.definitionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diagramAsset =>
      $composableBuilder(column: $table.diagramAsset, builder: (column) => ColumnOrderings(column));
}

class $$MeasurementMethodsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $MeasurementMethodsTable> {
  $$MeasurementMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get definitionKey =>
      $composableBuilder(column: $table.definitionKey, builder: (column) => column);

  GeneratedColumn<String> get diagramAsset =>
      $composableBuilder(column: $table.diagramAsset, builder: (column) => column);
}

class $$MeasurementMethodsTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $MeasurementMethodsTable,
          MeasurementMethodRow,
          $$MeasurementMethodsTableFilterComposer,
          $$MeasurementMethodsTableOrderingComposer,
          $$MeasurementMethodsTableAnnotationComposer,
          $$MeasurementMethodsTableCreateCompanionBuilder,
          $$MeasurementMethodsTableUpdateCompanionBuilder,
          (
            MeasurementMethodRow,
            BaseReferences<_$ReferenceDatabase, $MeasurementMethodsTable, MeasurementMethodRow>,
          ),
          MeasurementMethodRow,
          PrefetchHooks Function()
        > {
  $$MeasurementMethodsTableTableManager(_$ReferenceDatabase db, $MeasurementMethodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementMethodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementMethodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementMethodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> definitionKey = const Value.absent(),
                Value<String> diagramAsset = const Value.absent(),
              }) => MeasurementMethodsCompanion(
                id: id,
                code: code,
                nameKey: nameKey,
                definitionKey: definitionKey,
                diagramAsset: diagramAsset,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String nameKey,
                required String definitionKey,
                required String diagramAsset,
              }) => MeasurementMethodsCompanion.insert(
                id: id,
                code: code,
                nameKey: nameKey,
                definitionKey: definitionKey,
                diagramAsset: diagramAsset,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeasurementMethodsTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $MeasurementMethodsTable,
      MeasurementMethodRow,
      $$MeasurementMethodsTableFilterComposer,
      $$MeasurementMethodsTableOrderingComposer,
      $$MeasurementMethodsTableAnnotationComposer,
      $$MeasurementMethodsTableCreateCompanionBuilder,
      $$MeasurementMethodsTableUpdateCompanionBuilder,
      (
        MeasurementMethodRow,
        BaseReferences<_$ReferenceDatabase, $MeasurementMethodsTable, MeasurementMethodRow>,
      ),
      MeasurementMethodRow,
      PrefetchHooks Function()
    >;
typedef $$CitationsTableCreateCompanionBuilder =
    CitationsCompanion Function({
      Value<int> id,
      required int jurisdictionId,
      required String instrumentTypeKey,
      required String instrumentRef,
      Value<String?> articleRef,
      required String publishedOn,
      Value<String?> sourceUrl,
      required String retrievedOn,
    });
typedef $$CitationsTableUpdateCompanionBuilder =
    CitationsCompanion Function({
      Value<int> id,
      Value<int> jurisdictionId,
      Value<String> instrumentTypeKey,
      Value<String> instrumentRef,
      Value<String?> articleRef,
      Value<String> publishedOn,
      Value<String?> sourceUrl,
      Value<String> retrievedOn,
    });

class $$CitationsTableFilterComposer extends Composer<_$ReferenceDatabase, $CitationsTable> {
  $$CitationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instrumentTypeKey => $composableBuilder(
    column: $table.instrumentTypeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instrumentRef =>
      $composableBuilder(column: $table.instrumentRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get articleRef =>
      $composableBuilder(column: $table.articleRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get publishedOn =>
      $composableBuilder(column: $table.publishedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get retrievedOn =>
      $composableBuilder(column: $table.retrievedOn, builder: (column) => ColumnFilters(column));
}

class $$CitationsTableOrderingComposer extends Composer<_$ReferenceDatabase, $CitationsTable> {
  $$CitationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentTypeKey => $composableBuilder(
    column: $table.instrumentTypeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instrumentRef => $composableBuilder(
    column: $table.instrumentRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get articleRef =>
      $composableBuilder(column: $table.articleRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get publishedOn =>
      $composableBuilder(column: $table.publishedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get retrievedOn =>
      $composableBuilder(column: $table.retrievedOn, builder: (column) => ColumnOrderings(column));
}

class $$CitationsTableAnnotationComposer extends Composer<_$ReferenceDatabase, $CitationsTable> {
  $$CitationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => column);

  GeneratedColumn<String> get instrumentTypeKey =>
      $composableBuilder(column: $table.instrumentTypeKey, builder: (column) => column);

  GeneratedColumn<String> get instrumentRef =>
      $composableBuilder(column: $table.instrumentRef, builder: (column) => column);

  GeneratedColumn<String> get articleRef =>
      $composableBuilder(column: $table.articleRef, builder: (column) => column);

  GeneratedColumn<String> get publishedOn =>
      $composableBuilder(column: $table.publishedOn, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get retrievedOn =>
      $composableBuilder(column: $table.retrievedOn, builder: (column) => column);
}

class $$CitationsTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $CitationsTable,
          CitationRow,
          $$CitationsTableFilterComposer,
          $$CitationsTableOrderingComposer,
          $$CitationsTableAnnotationComposer,
          $$CitationsTableCreateCompanionBuilder,
          $$CitationsTableUpdateCompanionBuilder,
          (CitationRow, BaseReferences<_$ReferenceDatabase, $CitationsTable, CitationRow>),
          CitationRow,
          PrefetchHooks Function()
        > {
  $$CitationsTableTableManager(_$ReferenceDatabase db, $CitationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$CitationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$CitationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CitationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jurisdictionId = const Value.absent(),
                Value<String> instrumentTypeKey = const Value.absent(),
                Value<String> instrumentRef = const Value.absent(),
                Value<String?> articleRef = const Value.absent(),
                Value<String> publishedOn = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<String> retrievedOn = const Value.absent(),
              }) => CitationsCompanion(
                id: id,
                jurisdictionId: jurisdictionId,
                instrumentTypeKey: instrumentTypeKey,
                instrumentRef: instrumentRef,
                articleRef: articleRef,
                publishedOn: publishedOn,
                sourceUrl: sourceUrl,
                retrievedOn: retrievedOn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jurisdictionId,
                required String instrumentTypeKey,
                required String instrumentRef,
                Value<String?> articleRef = const Value.absent(),
                required String publishedOn,
                Value<String?> sourceUrl = const Value.absent(),
                required String retrievedOn,
              }) => CitationsCompanion.insert(
                id: id,
                jurisdictionId: jurisdictionId,
                instrumentTypeKey: instrumentTypeKey,
                instrumentRef: instrumentRef,
                articleRef: articleRef,
                publishedOn: publishedOn,
                sourceUrl: sourceUrl,
                retrievedOn: retrievedOn,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CitationsTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $CitationsTable,
      CitationRow,
      $$CitationsTableFilterComposer,
      $$CitationsTableOrderingComposer,
      $$CitationsTableAnnotationComposer,
      $$CitationsTableCreateCompanionBuilder,
      $$CitationsTableUpdateCompanionBuilder,
      (CitationRow, BaseReferences<_$ReferenceDatabase, $CitationsTable, CitationRow>),
      CitationRow,
      PrefetchHooks Function()
    >;
typedef $$RulesTableCreateCompanionBuilder =
    RulesCompanion Function({
      Value<int> id,
      required int jurisdictionId,
      Value<int?> zoneId,
      required int speciesId,
      required String waterType,
      Value<int?> minSizeMm,
      Value<int?> maxSizeMm,
      Value<int?> measurementMethodId,
      Value<int?> bagLimit,
      Value<String?> bagLimitUnit,
      Value<String?> bagLimitPeriod,
      Value<int?> vesselLimit,
      Value<bool> isProtected,
      Value<int?> licenceTypeId,
      Value<String?> notesKey,
      required int citationId,
      required String validFrom,
      Value<String?> validTo,
      Value<int> specificity,
    });
typedef $$RulesTableUpdateCompanionBuilder =
    RulesCompanion Function({
      Value<int> id,
      Value<int> jurisdictionId,
      Value<int?> zoneId,
      Value<int> speciesId,
      Value<String> waterType,
      Value<int?> minSizeMm,
      Value<int?> maxSizeMm,
      Value<int?> measurementMethodId,
      Value<int?> bagLimit,
      Value<String?> bagLimitUnit,
      Value<String?> bagLimitPeriod,
      Value<int?> vesselLimit,
      Value<bool> isProtected,
      Value<int?> licenceTypeId,
      Value<String?> notesKey,
      Value<int> citationId,
      Value<String> validFrom,
      Value<String?> validTo,
      Value<int> specificity,
    });

final class $$RulesTableReferences
    extends BaseReferences<_$ReferenceDatabase, $RulesTable, RuleRow> {
  $$RulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClosedSeasonsTable, List<ClosedSeasonRow>> _closedSeasonsRefsTable(
    _$ReferenceDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.closedSeasons,
    aliasName: 'rule__id__closed_season__rule_id',
  );

  $$ClosedSeasonsTableProcessedTableManager get closedSeasonsRefs {
    final manager = $$ClosedSeasonsTableTableManager(
      $_db,
      $_db.closedSeasons,
    ).filter((f) => f.ruleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_closedSeasonsRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RulesTableFilterComposer extends Composer<_$ReferenceDatabase, $RulesTable> {
  $$RulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get waterType =>
      $composableBuilder(column: $table.waterType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minSizeMm =>
      $composableBuilder(column: $table.minSizeMm, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxSizeMm =>
      $composableBuilder(column: $table.maxSizeMm, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get measurementMethodId => $composableBuilder(
    column: $table.measurementMethodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bagLimit =>
      $composableBuilder(column: $table.bagLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bagLimitUnit =>
      $composableBuilder(column: $table.bagLimitUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bagLimitPeriod =>
      $composableBuilder(column: $table.bagLimitPeriod, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get vesselLimit =>
      $composableBuilder(column: $table.vesselLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isProtected =>
      $composableBuilder(column: $table.isProtected, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get licenceTypeId =>
      $composableBuilder(column: $table.licenceTypeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notesKey =>
      $composableBuilder(column: $table.notesKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get validFrom =>
      $composableBuilder(column: $table.validFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get validTo =>
      $composableBuilder(column: $table.validTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get specificity =>
      $composableBuilder(column: $table.specificity, builder: (column) => ColumnFilters(column));

  Expression<bool> closedSeasonsRefs(
    Expression<bool> Function($$ClosedSeasonsTableFilterComposer f) f,
  ) {
    final $$ClosedSeasonsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.closedSeasons,
      getReferencedColumn: (t) => t.ruleId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ClosedSeasonsTableFilterComposer(
            $db: $db,
            $table: $db.closedSeasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableOrderingComposer extends Composer<_$ReferenceDatabase, $RulesTable> {
  $$RulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get waterType =>
      $composableBuilder(column: $table.waterType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minSizeMm =>
      $composableBuilder(column: $table.minSizeMm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxSizeMm =>
      $composableBuilder(column: $table.maxSizeMm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get measurementMethodId => $composableBuilder(
    column: $table.measurementMethodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bagLimit =>
      $composableBuilder(column: $table.bagLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bagLimitUnit =>
      $composableBuilder(column: $table.bagLimitUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bagLimitPeriod => $composableBuilder(
    column: $table.bagLimitPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vesselLimit =>
      $composableBuilder(column: $table.vesselLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isProtected =>
      $composableBuilder(column: $table.isProtected, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get licenceTypeId => $composableBuilder(
    column: $table.licenceTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notesKey =>
      $composableBuilder(column: $table.notesKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get validFrom =>
      $composableBuilder(column: $table.validFrom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get validTo =>
      $composableBuilder(column: $table.validTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get specificity =>
      $composableBuilder(column: $table.specificity, builder: (column) => ColumnOrderings(column));
}

class $$RulesTableAnnotationComposer extends Composer<_$ReferenceDatabase, $RulesTable> {
  $$RulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => column);

  GeneratedColumn<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get waterType =>
      $composableBuilder(column: $table.waterType, builder: (column) => column);

  GeneratedColumn<int> get minSizeMm =>
      $composableBuilder(column: $table.minSizeMm, builder: (column) => column);

  GeneratedColumn<int> get maxSizeMm =>
      $composableBuilder(column: $table.maxSizeMm, builder: (column) => column);

  GeneratedColumn<int> get measurementMethodId =>
      $composableBuilder(column: $table.measurementMethodId, builder: (column) => column);

  GeneratedColumn<int> get bagLimit =>
      $composableBuilder(column: $table.bagLimit, builder: (column) => column);

  GeneratedColumn<String> get bagLimitUnit =>
      $composableBuilder(column: $table.bagLimitUnit, builder: (column) => column);

  GeneratedColumn<String> get bagLimitPeriod =>
      $composableBuilder(column: $table.bagLimitPeriod, builder: (column) => column);

  GeneratedColumn<int> get vesselLimit =>
      $composableBuilder(column: $table.vesselLimit, builder: (column) => column);

  GeneratedColumn<bool> get isProtected =>
      $composableBuilder(column: $table.isProtected, builder: (column) => column);

  GeneratedColumn<int> get licenceTypeId =>
      $composableBuilder(column: $table.licenceTypeId, builder: (column) => column);

  GeneratedColumn<String> get notesKey =>
      $composableBuilder(column: $table.notesKey, builder: (column) => column);

  GeneratedColumn<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => column);

  GeneratedColumn<String> get validFrom =>
      $composableBuilder(column: $table.validFrom, builder: (column) => column);

  GeneratedColumn<String> get validTo =>
      $composableBuilder(column: $table.validTo, builder: (column) => column);

  GeneratedColumn<int> get specificity =>
      $composableBuilder(column: $table.specificity, builder: (column) => column);

  Expression<T> closedSeasonsRefs<T extends Object>(
    Expression<T> Function($$ClosedSeasonsTableAnnotationComposer a) f,
  ) {
    final $$ClosedSeasonsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.closedSeasons,
      getReferencedColumn: (t) => t.ruleId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ClosedSeasonsTableAnnotationComposer(
            $db: $db,
            $table: $db.closedSeasons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RulesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $RulesTable,
          RuleRow,
          $$RulesTableFilterComposer,
          $$RulesTableOrderingComposer,
          $$RulesTableAnnotationComposer,
          $$RulesTableCreateCompanionBuilder,
          $$RulesTableUpdateCompanionBuilder,
          (RuleRow, $$RulesTableReferences),
          RuleRow,
          PrefetchHooks Function({bool closedSeasonsRefs})
        > {
  $$RulesTableTableManager(_$ReferenceDatabase db, $RulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$RulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$RulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$RulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jurisdictionId = const Value.absent(),
                Value<int?> zoneId = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<String> waterType = const Value.absent(),
                Value<int?> minSizeMm = const Value.absent(),
                Value<int?> maxSizeMm = const Value.absent(),
                Value<int?> measurementMethodId = const Value.absent(),
                Value<int?> bagLimit = const Value.absent(),
                Value<String?> bagLimitUnit = const Value.absent(),
                Value<String?> bagLimitPeriod = const Value.absent(),
                Value<int?> vesselLimit = const Value.absent(),
                Value<bool> isProtected = const Value.absent(),
                Value<int?> licenceTypeId = const Value.absent(),
                Value<String?> notesKey = const Value.absent(),
                Value<int> citationId = const Value.absent(),
                Value<String> validFrom = const Value.absent(),
                Value<String?> validTo = const Value.absent(),
                Value<int> specificity = const Value.absent(),
              }) => RulesCompanion(
                id: id,
                jurisdictionId: jurisdictionId,
                zoneId: zoneId,
                speciesId: speciesId,
                waterType: waterType,
                minSizeMm: minSizeMm,
                maxSizeMm: maxSizeMm,
                measurementMethodId: measurementMethodId,
                bagLimit: bagLimit,
                bagLimitUnit: bagLimitUnit,
                bagLimitPeriod: bagLimitPeriod,
                vesselLimit: vesselLimit,
                isProtected: isProtected,
                licenceTypeId: licenceTypeId,
                notesKey: notesKey,
                citationId: citationId,
                validFrom: validFrom,
                validTo: validTo,
                specificity: specificity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jurisdictionId,
                Value<int?> zoneId = const Value.absent(),
                required int speciesId,
                required String waterType,
                Value<int?> minSizeMm = const Value.absent(),
                Value<int?> maxSizeMm = const Value.absent(),
                Value<int?> measurementMethodId = const Value.absent(),
                Value<int?> bagLimit = const Value.absent(),
                Value<String?> bagLimitUnit = const Value.absent(),
                Value<String?> bagLimitPeriod = const Value.absent(),
                Value<int?> vesselLimit = const Value.absent(),
                Value<bool> isProtected = const Value.absent(),
                Value<int?> licenceTypeId = const Value.absent(),
                Value<String?> notesKey = const Value.absent(),
                required int citationId,
                required String validFrom,
                Value<String?> validTo = const Value.absent(),
                Value<int> specificity = const Value.absent(),
              }) => RulesCompanion.insert(
                id: id,
                jurisdictionId: jurisdictionId,
                zoneId: zoneId,
                speciesId: speciesId,
                waterType: waterType,
                minSizeMm: minSizeMm,
                maxSizeMm: maxSizeMm,
                measurementMethodId: measurementMethodId,
                bagLimit: bagLimit,
                bagLimitUnit: bagLimitUnit,
                bagLimitPeriod: bagLimitPeriod,
                vesselLimit: vesselLimit,
                isProtected: isProtected,
                licenceTypeId: licenceTypeId,
                notesKey: notesKey,
                citationId: citationId,
                validFrom: validFrom,
                validTo: validTo,
                specificity: specificity,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$RulesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({closedSeasonsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (closedSeasonsRefs) db.closedSeasons],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (closedSeasonsRefs)
                    await $_getPrefetchedData<RuleRow, $RulesTable, ClosedSeasonRow>(
                      currentTable: table,
                      referencedTable: $$RulesTableReferences._closedSeasonsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$RulesTableReferences(db, table, p0).closedSeasonsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.ruleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RulesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $RulesTable,
      RuleRow,
      $$RulesTableFilterComposer,
      $$RulesTableOrderingComposer,
      $$RulesTableAnnotationComposer,
      $$RulesTableCreateCompanionBuilder,
      $$RulesTableUpdateCompanionBuilder,
      (RuleRow, $$RulesTableReferences),
      RuleRow,
      PrefetchHooks Function({bool closedSeasonsRefs})
    >;
typedef $$ClosedSeasonsTableCreateCompanionBuilder =
    ClosedSeasonsCompanion Function({
      Value<int> id,
      required int ruleId,
      required String recurrence,
      Value<int?> startMonth,
      Value<int?> startDay,
      Value<int?> endMonth,
      Value<int?> endDay,
      Value<String?> startDate,
      Value<String?> endDate,
      Value<String?> notesKey,
      Value<int?> citationId,
    });
typedef $$ClosedSeasonsTableUpdateCompanionBuilder =
    ClosedSeasonsCompanion Function({
      Value<int> id,
      Value<int> ruleId,
      Value<String> recurrence,
      Value<int?> startMonth,
      Value<int?> startDay,
      Value<int?> endMonth,
      Value<int?> endDay,
      Value<String?> startDate,
      Value<String?> endDate,
      Value<String?> notesKey,
      Value<int?> citationId,
    });

final class $$ClosedSeasonsTableReferences
    extends BaseReferences<_$ReferenceDatabase, $ClosedSeasonsTable, ClosedSeasonRow> {
  $$ClosedSeasonsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RulesTable _ruleIdTable(_$ReferenceDatabase db) =>
      db.rules.createAlias('closed_season__rule_id__rule__id');

  $$RulesTableProcessedTableManager get ruleId {
    final $_column = $_itemColumn<int>('rule_id')!;

    final manager = $$RulesTableTableManager(
      $_db,
      $_db.rules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ruleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ClosedSeasonsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $ClosedSeasonsTable> {
  $$ClosedSeasonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrence =>
      $composableBuilder(column: $table.recurrence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startMonth =>
      $composableBuilder(column: $table.startMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endMonth =>
      $composableBuilder(column: $table.endMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notesKey =>
      $composableBuilder(column: $table.notesKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnFilters(column));

  $$RulesTableFilterComposer get ruleId {
    final $$RulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RulesTableFilterComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClosedSeasonsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $ClosedSeasonsTable> {
  $$ClosedSeasonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrence =>
      $composableBuilder(column: $table.recurrence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startMonth =>
      $composableBuilder(column: $table.startMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endMonth =>
      $composableBuilder(column: $table.endMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notesKey =>
      $composableBuilder(column: $table.notesKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnOrderings(column));

  $$RulesTableOrderingComposer get ruleId {
    final $$RulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RulesTableOrderingComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClosedSeasonsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $ClosedSeasonsTable> {
  $$ClosedSeasonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get recurrence =>
      $composableBuilder(column: $table.recurrence, builder: (column) => column);

  GeneratedColumn<int> get startMonth =>
      $composableBuilder(column: $table.startMonth, builder: (column) => column);

  GeneratedColumn<int> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);

  GeneratedColumn<int> get endMonth =>
      $composableBuilder(column: $table.endMonth, builder: (column) => column);

  GeneratedColumn<int> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get notesKey =>
      $composableBuilder(column: $table.notesKey, builder: (column) => column);

  GeneratedColumn<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => column);

  $$RulesTableAnnotationComposer get ruleId {
    final $$RulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ruleId,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$RulesTableAnnotationComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClosedSeasonsTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $ClosedSeasonsTable,
          ClosedSeasonRow,
          $$ClosedSeasonsTableFilterComposer,
          $$ClosedSeasonsTableOrderingComposer,
          $$ClosedSeasonsTableAnnotationComposer,
          $$ClosedSeasonsTableCreateCompanionBuilder,
          $$ClosedSeasonsTableUpdateCompanionBuilder,
          (ClosedSeasonRow, $$ClosedSeasonsTableReferences),
          ClosedSeasonRow,
          PrefetchHooks Function({bool ruleId})
        > {
  $$ClosedSeasonsTableTableManager(_$ReferenceDatabase db, $ClosedSeasonsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ClosedSeasonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClosedSeasonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClosedSeasonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ruleId = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<int?> startMonth = const Value.absent(),
                Value<int?> startDay = const Value.absent(),
                Value<int?> endMonth = const Value.absent(),
                Value<int?> endDay = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<String?> notesKey = const Value.absent(),
                Value<int?> citationId = const Value.absent(),
              }) => ClosedSeasonsCompanion(
                id: id,
                ruleId: ruleId,
                recurrence: recurrence,
                startMonth: startMonth,
                startDay: startDay,
                endMonth: endMonth,
                endDay: endDay,
                startDate: startDate,
                endDate: endDate,
                notesKey: notesKey,
                citationId: citationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ruleId,
                required String recurrence,
                Value<int?> startMonth = const Value.absent(),
                Value<int?> startDay = const Value.absent(),
                Value<int?> endMonth = const Value.absent(),
                Value<int?> endDay = const Value.absent(),
                Value<String?> startDate = const Value.absent(),
                Value<String?> endDate = const Value.absent(),
                Value<String?> notesKey = const Value.absent(),
                Value<int?> citationId = const Value.absent(),
              }) => ClosedSeasonsCompanion.insert(
                id: id,
                ruleId: ruleId,
                recurrence: recurrence,
                startMonth: startMonth,
                startDay: startDay,
                endMonth: endMonth,
                endDay: endDay,
                startDate: startDate,
                endDate: endDate,
                notesKey: notesKey,
                citationId: citationId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$ClosedSeasonsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({ruleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (ruleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.ruleId,
                                referencedTable: $$ClosedSeasonsTableReferences._ruleIdTable(db),
                                referencedColumn: $$ClosedSeasonsTableReferences
                                    ._ruleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClosedSeasonsTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $ClosedSeasonsTable,
      ClosedSeasonRow,
      $$ClosedSeasonsTableFilterComposer,
      $$ClosedSeasonsTableOrderingComposer,
      $$ClosedSeasonsTableAnnotationComposer,
      $$ClosedSeasonsTableCreateCompanionBuilder,
      $$ClosedSeasonsTableUpdateCompanionBuilder,
      (ClosedSeasonRow, $$ClosedSeasonsTableReferences),
      ClosedSeasonRow,
      PrefetchHooks Function({bool ruleId})
    >;
typedef $$LicenceTypesTableCreateCompanionBuilder =
    LicenceTypesCompanion Function({
      Value<int> id,
      required int jurisdictionId,
      Value<int?> zoneId,
      required String waterType,
      required String code,
      required String nameKey,
      required String descriptionKey,
      required int citationId,
    });
typedef $$LicenceTypesTableUpdateCompanionBuilder =
    LicenceTypesCompanion Function({
      Value<int> id,
      Value<int> jurisdictionId,
      Value<int?> zoneId,
      Value<String> waterType,
      Value<String> code,
      Value<String> nameKey,
      Value<String> descriptionKey,
      Value<int> citationId,
    });

class $$LicenceTypesTableFilterComposer extends Composer<_$ReferenceDatabase, $LicenceTypesTable> {
  $$LicenceTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get waterType =>
      $composableBuilder(column: $table.waterType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get descriptionKey =>
      $composableBuilder(column: $table.descriptionKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnFilters(column));
}

class $$LicenceTypesTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $LicenceTypesTable> {
  $$LicenceTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get waterType =>
      $composableBuilder(column: $table.waterType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get descriptionKey => $composableBuilder(
    column: $table.descriptionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnOrderings(column));
}

class $$LicenceTypesTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $LicenceTypesTable> {
  $$LicenceTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => column);

  GeneratedColumn<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<String> get waterType =>
      $composableBuilder(column: $table.waterType, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get descriptionKey =>
      $composableBuilder(column: $table.descriptionKey, builder: (column) => column);

  GeneratedColumn<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => column);
}

class $$LicenceTypesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $LicenceTypesTable,
          LicenceTypeRow,
          $$LicenceTypesTableFilterComposer,
          $$LicenceTypesTableOrderingComposer,
          $$LicenceTypesTableAnnotationComposer,
          $$LicenceTypesTableCreateCompanionBuilder,
          $$LicenceTypesTableUpdateCompanionBuilder,
          (LicenceTypeRow, BaseReferences<_$ReferenceDatabase, $LicenceTypesTable, LicenceTypeRow>),
          LicenceTypeRow,
          PrefetchHooks Function()
        > {
  $$LicenceTypesTableTableManager(_$ReferenceDatabase db, $LicenceTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LicenceTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LicenceTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LicenceTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jurisdictionId = const Value.absent(),
                Value<int?> zoneId = const Value.absent(),
                Value<String> waterType = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> descriptionKey = const Value.absent(),
                Value<int> citationId = const Value.absent(),
              }) => LicenceTypesCompanion(
                id: id,
                jurisdictionId: jurisdictionId,
                zoneId: zoneId,
                waterType: waterType,
                code: code,
                nameKey: nameKey,
                descriptionKey: descriptionKey,
                citationId: citationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jurisdictionId,
                Value<int?> zoneId = const Value.absent(),
                required String waterType,
                required String code,
                required String nameKey,
                required String descriptionKey,
                required int citationId,
              }) => LicenceTypesCompanion.insert(
                id: id,
                jurisdictionId: jurisdictionId,
                zoneId: zoneId,
                waterType: waterType,
                code: code,
                nameKey: nameKey,
                descriptionKey: descriptionKey,
                citationId: citationId,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LicenceTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $LicenceTypesTable,
      LicenceTypeRow,
      $$LicenceTypesTableFilterComposer,
      $$LicenceTypesTableOrderingComposer,
      $$LicenceTypesTableAnnotationComposer,
      $$LicenceTypesTableCreateCompanionBuilder,
      $$LicenceTypesTableUpdateCompanionBuilder,
      (LicenceTypeRow, BaseReferences<_$ReferenceDatabase, $LicenceTypesTable, LicenceTypeRow>),
      LicenceTypeRow,
      PrefetchHooks Function()
    >;
typedef $$GearRulesTableCreateCompanionBuilder =
    GearRulesCompanion Function({
      Value<int> id,
      required int jurisdictionId,
      Value<int?> zoneId,
      Value<int?> speciesId,
      required String gearCode,
      required String gearNameKey,
      required bool isAllowed,
      Value<String?> constraintKey,
      required int citationId,
    });
typedef $$GearRulesTableUpdateCompanionBuilder =
    GearRulesCompanion Function({
      Value<int> id,
      Value<int> jurisdictionId,
      Value<int?> zoneId,
      Value<int?> speciesId,
      Value<String> gearCode,
      Value<String> gearNameKey,
      Value<bool> isAllowed,
      Value<String?> constraintKey,
      Value<int> citationId,
    });

class $$GearRulesTableFilterComposer extends Composer<_$ReferenceDatabase, $GearRulesTable> {
  $$GearRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gearCode =>
      $composableBuilder(column: $table.gearCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gearNameKey =>
      $composableBuilder(column: $table.gearNameKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAllowed =>
      $composableBuilder(column: $table.isAllowed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get constraintKey =>
      $composableBuilder(column: $table.constraintKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnFilters(column));
}

class $$GearRulesTableOrderingComposer extends Composer<_$ReferenceDatabase, $GearRulesTable> {
  $$GearRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gearCode =>
      $composableBuilder(column: $table.gearCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gearNameKey =>
      $composableBuilder(column: $table.gearNameKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAllowed =>
      $composableBuilder(column: $table.isAllowed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get constraintKey => $composableBuilder(
    column: $table.constraintKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnOrderings(column));
}

class $$GearRulesTableAnnotationComposer extends Composer<_$ReferenceDatabase, $GearRulesTable> {
  $$GearRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => column);

  GeneratedColumn<int> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<String> get gearCode =>
      $composableBuilder(column: $table.gearCode, builder: (column) => column);

  GeneratedColumn<String> get gearNameKey =>
      $composableBuilder(column: $table.gearNameKey, builder: (column) => column);

  GeneratedColumn<bool> get isAllowed =>
      $composableBuilder(column: $table.isAllowed, builder: (column) => column);

  GeneratedColumn<String> get constraintKey =>
      $composableBuilder(column: $table.constraintKey, builder: (column) => column);

  GeneratedColumn<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => column);
}

class $$GearRulesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $GearRulesTable,
          GearRuleRow,
          $$GearRulesTableFilterComposer,
          $$GearRulesTableOrderingComposer,
          $$GearRulesTableAnnotationComposer,
          $$GearRulesTableCreateCompanionBuilder,
          $$GearRulesTableUpdateCompanionBuilder,
          (GearRuleRow, BaseReferences<_$ReferenceDatabase, $GearRulesTable, GearRuleRow>),
          GearRuleRow,
          PrefetchHooks Function()
        > {
  $$GearRulesTableTableManager(_$ReferenceDatabase db, $GearRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GearRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GearRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GearRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jurisdictionId = const Value.absent(),
                Value<int?> zoneId = const Value.absent(),
                Value<int?> speciesId = const Value.absent(),
                Value<String> gearCode = const Value.absent(),
                Value<String> gearNameKey = const Value.absent(),
                Value<bool> isAllowed = const Value.absent(),
                Value<String?> constraintKey = const Value.absent(),
                Value<int> citationId = const Value.absent(),
              }) => GearRulesCompanion(
                id: id,
                jurisdictionId: jurisdictionId,
                zoneId: zoneId,
                speciesId: speciesId,
                gearCode: gearCode,
                gearNameKey: gearNameKey,
                isAllowed: isAllowed,
                constraintKey: constraintKey,
                citationId: citationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jurisdictionId,
                Value<int?> zoneId = const Value.absent(),
                Value<int?> speciesId = const Value.absent(),
                required String gearCode,
                required String gearNameKey,
                required bool isAllowed,
                Value<String?> constraintKey = const Value.absent(),
                required int citationId,
              }) => GearRulesCompanion.insert(
                id: id,
                jurisdictionId: jurisdictionId,
                zoneId: zoneId,
                speciesId: speciesId,
                gearCode: gearCode,
                gearNameKey: gearNameKey,
                isAllowed: isAllowed,
                constraintKey: constraintKey,
                citationId: citationId,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GearRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $GearRulesTable,
      GearRuleRow,
      $$GearRulesTableFilterComposer,
      $$GearRulesTableOrderingComposer,
      $$GearRulesTableAnnotationComposer,
      $$GearRulesTableCreateCompanionBuilder,
      $$GearRulesTableUpdateCompanionBuilder,
      (GearRuleRow, BaseReferences<_$ReferenceDatabase, $GearRulesTable, GearRuleRow>),
      GearRuleRow,
      PrefetchHooks Function()
    >;
typedef $$PenaltiesTableCreateCompanionBuilder =
    PenaltiesCompanion Function({
      Value<int> id,
      required int jurisdictionId,
      required String offenceKey,
      Value<int> occurrence,
      Value<int?> amountMin,
      Value<int?> amountMax,
      Value<String?> currency,
      Value<String?> secondaryKey,
      required int citationId,
    });
typedef $$PenaltiesTableUpdateCompanionBuilder =
    PenaltiesCompanion Function({
      Value<int> id,
      Value<int> jurisdictionId,
      Value<String> offenceKey,
      Value<int> occurrence,
      Value<int?> amountMin,
      Value<int?> amountMax,
      Value<String?> currency,
      Value<String?> secondaryKey,
      Value<int> citationId,
    });

class $$PenaltiesTableFilterComposer extends Composer<_$ReferenceDatabase, $PenaltiesTable> {
  $$PenaltiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get offenceKey =>
      $composableBuilder(column: $table.offenceKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get occurrence =>
      $composableBuilder(column: $table.occurrence, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMin =>
      $composableBuilder(column: $table.amountMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMax =>
      $composableBuilder(column: $table.amountMax, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get secondaryKey =>
      $composableBuilder(column: $table.secondaryKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnFilters(column));
}

class $$PenaltiesTableOrderingComposer extends Composer<_$ReferenceDatabase, $PenaltiesTable> {
  $$PenaltiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get offenceKey =>
      $composableBuilder(column: $table.offenceKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get occurrence =>
      $composableBuilder(column: $table.occurrence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMin =>
      $composableBuilder(column: $table.amountMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMax =>
      $composableBuilder(column: $table.amountMax, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get secondaryKey =>
      $composableBuilder(column: $table.secondaryKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnOrderings(column));
}

class $$PenaltiesTableAnnotationComposer extends Composer<_$ReferenceDatabase, $PenaltiesTable> {
  $$PenaltiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => column);

  GeneratedColumn<String> get offenceKey =>
      $composableBuilder(column: $table.offenceKey, builder: (column) => column);

  GeneratedColumn<int> get occurrence =>
      $composableBuilder(column: $table.occurrence, builder: (column) => column);

  GeneratedColumn<int> get amountMin =>
      $composableBuilder(column: $table.amountMin, builder: (column) => column);

  GeneratedColumn<int> get amountMax =>
      $composableBuilder(column: $table.amountMax, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get secondaryKey =>
      $composableBuilder(column: $table.secondaryKey, builder: (column) => column);

  GeneratedColumn<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => column);
}

class $$PenaltiesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $PenaltiesTable,
          PenaltyRow,
          $$PenaltiesTableFilterComposer,
          $$PenaltiesTableOrderingComposer,
          $$PenaltiesTableAnnotationComposer,
          $$PenaltiesTableCreateCompanionBuilder,
          $$PenaltiesTableUpdateCompanionBuilder,
          (PenaltyRow, BaseReferences<_$ReferenceDatabase, $PenaltiesTable, PenaltyRow>),
          PenaltyRow,
          PrefetchHooks Function()
        > {
  $$PenaltiesTableTableManager(_$ReferenceDatabase db, $PenaltiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$PenaltiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$PenaltiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PenaltiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jurisdictionId = const Value.absent(),
                Value<String> offenceKey = const Value.absent(),
                Value<int> occurrence = const Value.absent(),
                Value<int?> amountMin = const Value.absent(),
                Value<int?> amountMax = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> secondaryKey = const Value.absent(),
                Value<int> citationId = const Value.absent(),
              }) => PenaltiesCompanion(
                id: id,
                jurisdictionId: jurisdictionId,
                offenceKey: offenceKey,
                occurrence: occurrence,
                amountMin: amountMin,
                amountMax: amountMax,
                currency: currency,
                secondaryKey: secondaryKey,
                citationId: citationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jurisdictionId,
                required String offenceKey,
                Value<int> occurrence = const Value.absent(),
                Value<int?> amountMin = const Value.absent(),
                Value<int?> amountMax = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<String?> secondaryKey = const Value.absent(),
                required int citationId,
              }) => PenaltiesCompanion.insert(
                id: id,
                jurisdictionId: jurisdictionId,
                offenceKey: offenceKey,
                occurrence: occurrence,
                amountMin: amountMin,
                amountMax: amountMax,
                currency: currency,
                secondaryKey: secondaryKey,
                citationId: citationId,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PenaltiesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $PenaltiesTable,
      PenaltyRow,
      $$PenaltiesTableFilterComposer,
      $$PenaltiesTableOrderingComposer,
      $$PenaltiesTableAnnotationComposer,
      $$PenaltiesTableCreateCompanionBuilder,
      $$PenaltiesTableUpdateCompanionBuilder,
      (PenaltyRow, BaseReferences<_$ReferenceDatabase, $PenaltiesTable, PenaltyRow>),
      PenaltyRow,
      PrefetchHooks Function()
    >;
typedef $$LookalikesTableCreateCompanionBuilder =
    LookalikesCompanion Function({
      Value<int> id,
      required int speciesId,
      required int confusedWith,
      required String differenceKey,
    });
typedef $$LookalikesTableUpdateCompanionBuilder =
    LookalikesCompanion Function({
      Value<int> id,
      Value<int> speciesId,
      Value<int> confusedWith,
      Value<String> differenceKey,
    });

final class $$LookalikesTableReferences
    extends BaseReferences<_$ReferenceDatabase, $LookalikesTable, LookalikeRow> {
  $$LookalikesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SpeciesTableTable _speciesIdTable(_$ReferenceDatabase db) =>
      db.speciesTable.createAlias('lookalike__species_id__species__id');

  $$SpeciesTableTableProcessedTableManager get speciesId {
    final $_column = $_itemColumn<int>('species_id')!;

    final manager = $$SpeciesTableTableTableManager(
      $_db,
      $_db.speciesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_speciesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SpeciesTableTable _confusedWithTable(_$ReferenceDatabase db) =>
      db.speciesTable.createAlias('lookalike__confused_with__species__id');

  $$SpeciesTableTableProcessedTableManager get confusedWith {
    final $_column = $_itemColumn<int>('confused_with')!;

    final manager = $$SpeciesTableTableTableManager(
      $_db,
      $_db.speciesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_confusedWithTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LookalikesTableFilterComposer extends Composer<_$ReferenceDatabase, $LookalikesTable> {
  $$LookalikesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get differenceKey =>
      $composableBuilder(column: $table.differenceKey, builder: (column) => ColumnFilters(column));

  $$SpeciesTableTableFilterComposer get speciesId {
    final $$SpeciesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableFilterComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpeciesTableTableFilterComposer get confusedWith {
    final $$SpeciesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.confusedWith,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableFilterComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LookalikesTableOrderingComposer extends Composer<_$ReferenceDatabase, $LookalikesTable> {
  $$LookalikesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get differenceKey => $composableBuilder(
    column: $table.differenceKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$SpeciesTableTableOrderingComposer get speciesId {
    final $$SpeciesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableOrderingComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpeciesTableTableOrderingComposer get confusedWith {
    final $$SpeciesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.confusedWith,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableOrderingComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LookalikesTableAnnotationComposer extends Composer<_$ReferenceDatabase, $LookalikesTable> {
  $$LookalikesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get differenceKey =>
      $composableBuilder(column: $table.differenceKey, builder: (column) => column);

  $$SpeciesTableTableAnnotationComposer get speciesId {
    final $$SpeciesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.speciesId,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SpeciesTableTableAnnotationComposer get confusedWith {
    final $$SpeciesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.confusedWith,
      referencedTable: $db.speciesTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$SpeciesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.speciesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LookalikesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $LookalikesTable,
          LookalikeRow,
          $$LookalikesTableFilterComposer,
          $$LookalikesTableOrderingComposer,
          $$LookalikesTableAnnotationComposer,
          $$LookalikesTableCreateCompanionBuilder,
          $$LookalikesTableUpdateCompanionBuilder,
          (LookalikeRow, $$LookalikesTableReferences),
          LookalikeRow,
          PrefetchHooks Function({bool speciesId, bool confusedWith})
        > {
  $$LookalikesTableTableManager(_$ReferenceDatabase db, $LookalikesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LookalikesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LookalikesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LookalikesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<int> confusedWith = const Value.absent(),
                Value<String> differenceKey = const Value.absent(),
              }) => LookalikesCompanion(
                id: id,
                speciesId: speciesId,
                confusedWith: confusedWith,
                differenceKey: differenceKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int speciesId,
                required int confusedWith,
                required String differenceKey,
              }) => LookalikesCompanion.insert(
                id: id,
                speciesId: speciesId,
                confusedWith: confusedWith,
                differenceKey: differenceKey,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$LookalikesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({speciesId = false, confusedWith = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (speciesId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.speciesId,
                                referencedTable: $$LookalikesTableReferences._speciesIdTable(db),
                                referencedColumn: $$LookalikesTableReferences
                                    ._speciesIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (confusedWith) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.confusedWith,
                                referencedTable: $$LookalikesTableReferences._confusedWithTable(db),
                                referencedColumn: $$LookalikesTableReferences
                                    ._confusedWithTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LookalikesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $LookalikesTable,
      LookalikeRow,
      $$LookalikesTableFilterComposer,
      $$LookalikesTableOrderingComposer,
      $$LookalikesTableAnnotationComposer,
      $$LookalikesTableCreateCompanionBuilder,
      $$LookalikesTableUpdateCompanionBuilder,
      (LookalikeRow, $$LookalikesTableReferences),
      LookalikeRow,
      PrefetchHooks Function({bool speciesId, bool confusedWith})
    >;
typedef $$GlossaryTermsTableCreateCompanionBuilder =
    GlossaryTermsCompanion Function({
      Value<int> id,
      Value<int?> jurisdictionId,
      required String termKey,
      required String definitionKey,
      Value<int> sortOrder,
    });
typedef $$GlossaryTermsTableUpdateCompanionBuilder =
    GlossaryTermsCompanion Function({
      Value<int> id,
      Value<int?> jurisdictionId,
      Value<String> termKey,
      Value<String> definitionKey,
      Value<int> sortOrder,
    });

class $$GlossaryTermsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $GlossaryTermsTable> {
  $$GlossaryTermsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termKey =>
      $composableBuilder(column: $table.termKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get definitionKey =>
      $composableBuilder(column: $table.definitionKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$GlossaryTermsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $GlossaryTermsTable> {
  $$GlossaryTermsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termKey =>
      $composableBuilder(column: $table.termKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get definitionKey => $composableBuilder(
    column: $table.definitionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$GlossaryTermsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $GlossaryTermsTable> {
  $$GlossaryTermsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => column);

  GeneratedColumn<String> get termKey =>
      $composableBuilder(column: $table.termKey, builder: (column) => column);

  GeneratedColumn<String> get definitionKey =>
      $composableBuilder(column: $table.definitionKey, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$GlossaryTermsTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $GlossaryTermsTable,
          GlossaryTermRow,
          $$GlossaryTermsTableFilterComposer,
          $$GlossaryTermsTableOrderingComposer,
          $$GlossaryTermsTableAnnotationComposer,
          $$GlossaryTermsTableCreateCompanionBuilder,
          $$GlossaryTermsTableUpdateCompanionBuilder,
          (
            GlossaryTermRow,
            BaseReferences<_$ReferenceDatabase, $GlossaryTermsTable, GlossaryTermRow>,
          ),
          GlossaryTermRow,
          PrefetchHooks Function()
        > {
  $$GlossaryTermsTableTableManager(_$ReferenceDatabase db, $GlossaryTermsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GlossaryTermsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlossaryTermsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlossaryTermsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> jurisdictionId = const Value.absent(),
                Value<String> termKey = const Value.absent(),
                Value<String> definitionKey = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => GlossaryTermsCompanion(
                id: id,
                jurisdictionId: jurisdictionId,
                termKey: termKey,
                definitionKey: definitionKey,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> jurisdictionId = const Value.absent(),
                required String termKey,
                required String definitionKey,
                Value<int> sortOrder = const Value.absent(),
              }) => GlossaryTermsCompanion.insert(
                id: id,
                jurisdictionId: jurisdictionId,
                termKey: termKey,
                definitionKey: definitionKey,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GlossaryTermsTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $GlossaryTermsTable,
      GlossaryTermRow,
      $$GlossaryTermsTableFilterComposer,
      $$GlossaryTermsTableOrderingComposer,
      $$GlossaryTermsTableAnnotationComposer,
      $$GlossaryTermsTableCreateCompanionBuilder,
      $$GlossaryTermsTableUpdateCompanionBuilder,
      (GlossaryTermRow, BaseReferences<_$ReferenceDatabase, $GlossaryTermsTable, GlossaryTermRow>),
      GlossaryTermRow,
      PrefetchHooks Function()
    >;
typedef $$ContentChangesTableCreateCompanionBuilder =
    ContentChangesCompanion Function({
      Value<int> id,
      required int jurisdictionId,
      required String fromVersion,
      required String toVersion,
      required String summaryKey,
      Value<String?> detailKey,
      required String changedOn,
    });
typedef $$ContentChangesTableUpdateCompanionBuilder =
    ContentChangesCompanion Function({
      Value<int> id,
      Value<int> jurisdictionId,
      Value<String> fromVersion,
      Value<String> toVersion,
      Value<String> summaryKey,
      Value<String?> detailKey,
      Value<String> changedOn,
    });

class $$ContentChangesTableFilterComposer
    extends Composer<_$ReferenceDatabase, $ContentChangesTable> {
  $$ContentChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fromVersion =>
      $composableBuilder(column: $table.fromVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toVersion =>
      $composableBuilder(column: $table.toVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summaryKey =>
      $composableBuilder(column: $table.summaryKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detailKey =>
      $composableBuilder(column: $table.detailKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get changedOn =>
      $composableBuilder(column: $table.changedOn, builder: (column) => ColumnFilters(column));
}

class $$ContentChangesTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $ContentChangesTable> {
  $$ContentChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromVersion =>
      $composableBuilder(column: $table.fromVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toVersion =>
      $composableBuilder(column: $table.toVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summaryKey =>
      $composableBuilder(column: $table.summaryKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detailKey =>
      $composableBuilder(column: $table.detailKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get changedOn =>
      $composableBuilder(column: $table.changedOn, builder: (column) => ColumnOrderings(column));
}

class $$ContentChangesTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $ContentChangesTable> {
  $$ContentChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => column);

  GeneratedColumn<String> get fromVersion =>
      $composableBuilder(column: $table.fromVersion, builder: (column) => column);

  GeneratedColumn<String> get toVersion =>
      $composableBuilder(column: $table.toVersion, builder: (column) => column);

  GeneratedColumn<String> get summaryKey =>
      $composableBuilder(column: $table.summaryKey, builder: (column) => column);

  GeneratedColumn<String> get detailKey =>
      $composableBuilder(column: $table.detailKey, builder: (column) => column);

  GeneratedColumn<String> get changedOn =>
      $composableBuilder(column: $table.changedOn, builder: (column) => column);
}

class $$ContentChangesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $ContentChangesTable,
          ContentChangeRow,
          $$ContentChangesTableFilterComposer,
          $$ContentChangesTableOrderingComposer,
          $$ContentChangesTableAnnotationComposer,
          $$ContentChangesTableCreateCompanionBuilder,
          $$ContentChangesTableUpdateCompanionBuilder,
          (
            ContentChangeRow,
            BaseReferences<_$ReferenceDatabase, $ContentChangesTable, ContentChangeRow>,
          ),
          ContentChangeRow,
          PrefetchHooks Function()
        > {
  $$ContentChangesTableTableManager(_$ReferenceDatabase db, $ContentChangesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jurisdictionId = const Value.absent(),
                Value<String> fromVersion = const Value.absent(),
                Value<String> toVersion = const Value.absent(),
                Value<String> summaryKey = const Value.absent(),
                Value<String?> detailKey = const Value.absent(),
                Value<String> changedOn = const Value.absent(),
              }) => ContentChangesCompanion(
                id: id,
                jurisdictionId: jurisdictionId,
                fromVersion: fromVersion,
                toVersion: toVersion,
                summaryKey: summaryKey,
                detailKey: detailKey,
                changedOn: changedOn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jurisdictionId,
                required String fromVersion,
                required String toVersion,
                required String summaryKey,
                Value<String?> detailKey = const Value.absent(),
                required String changedOn,
              }) => ContentChangesCompanion.insert(
                id: id,
                jurisdictionId: jurisdictionId,
                fromVersion: fromVersion,
                toVersion: toVersion,
                summaryKey: summaryKey,
                detailKey: detailKey,
                changedOn: changedOn,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $ContentChangesTable,
      ContentChangeRow,
      $$ContentChangesTableFilterComposer,
      $$ContentChangesTableOrderingComposer,
      $$ContentChangesTableAnnotationComposer,
      $$ContentChangesTableCreateCompanionBuilder,
      $$ContentChangesTableUpdateCompanionBuilder,
      (
        ContentChangeRow,
        BaseReferences<_$ReferenceDatabase, $ContentChangesTable, ContentChangeRow>,
      ),
      ContentChangeRow,
      PrefetchHooks Function()
    >;
typedef $$KeyNodesTableCreateCompanionBuilder =
    KeyNodesCompanion Function({
      Value<int> id,
      required String taxonGroup,
      Value<int?> parentNodeId,
      Value<String?> questionKey,
    });
typedef $$KeyNodesTableUpdateCompanionBuilder =
    KeyNodesCompanion Function({
      Value<int> id,
      Value<String> taxonGroup,
      Value<int?> parentNodeId,
      Value<String?> questionKey,
    });

final class $$KeyNodesTableReferences
    extends BaseReferences<_$ReferenceDatabase, $KeyNodesTable, KeyNodeRow> {
  $$KeyNodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$KeyLeafSpeciesTable, List<KeyLeafSpeciesRow>>
  _keyLeafSpeciesRefsTable(_$ReferenceDatabase db) => MultiTypedResultKey.fromTable(
    db.keyLeafSpecies,
    aliasName: 'key_node__id__key_leaf_species__node_id',
  );

  $$KeyLeafSpeciesTableProcessedTableManager get keyLeafSpeciesRefs {
    final manager = $$KeyLeafSpeciesTableTableManager(
      $_db,
      $_db.keyLeafSpecies,
    ).filter((f) => f.nodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_keyLeafSpeciesRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$KeyNodesTableFilterComposer extends Composer<_$ReferenceDatabase, $KeyNodesTable> {
  $$KeyNodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taxonGroup =>
      $composableBuilder(column: $table.taxonGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get parentNodeId =>
      $composableBuilder(column: $table.parentNodeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionKey =>
      $composableBuilder(column: $table.questionKey, builder: (column) => ColumnFilters(column));

  Expression<bool> keyLeafSpeciesRefs(
    Expression<bool> Function($$KeyLeafSpeciesTableFilterComposer f) f,
  ) {
    final $$KeyLeafSpeciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.keyLeafSpecies,
      getReferencedColumn: (t) => t.nodeId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyLeafSpeciesTableFilterComposer(
            $db: $db,
            $table: $db.keyLeafSpecies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KeyNodesTableOrderingComposer extends Composer<_$ReferenceDatabase, $KeyNodesTable> {
  $$KeyNodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taxonGroup =>
      $composableBuilder(column: $table.taxonGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get parentNodeId =>
      $composableBuilder(column: $table.parentNodeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionKey =>
      $composableBuilder(column: $table.questionKey, builder: (column) => ColumnOrderings(column));
}

class $$KeyNodesTableAnnotationComposer extends Composer<_$ReferenceDatabase, $KeyNodesTable> {
  $$KeyNodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taxonGroup =>
      $composableBuilder(column: $table.taxonGroup, builder: (column) => column);

  GeneratedColumn<int> get parentNodeId =>
      $composableBuilder(column: $table.parentNodeId, builder: (column) => column);

  GeneratedColumn<String> get questionKey =>
      $composableBuilder(column: $table.questionKey, builder: (column) => column);

  Expression<T> keyLeafSpeciesRefs<T extends Object>(
    Expression<T> Function($$KeyLeafSpeciesTableAnnotationComposer a) f,
  ) {
    final $$KeyLeafSpeciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.keyLeafSpecies,
      getReferencedColumn: (t) => t.nodeId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyLeafSpeciesTableAnnotationComposer(
            $db: $db,
            $table: $db.keyLeafSpecies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KeyNodesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $KeyNodesTable,
          KeyNodeRow,
          $$KeyNodesTableFilterComposer,
          $$KeyNodesTableOrderingComposer,
          $$KeyNodesTableAnnotationComposer,
          $$KeyNodesTableCreateCompanionBuilder,
          $$KeyNodesTableUpdateCompanionBuilder,
          (KeyNodeRow, $$KeyNodesTableReferences),
          KeyNodeRow,
          PrefetchHooks Function({bool keyLeafSpeciesRefs})
        > {
  $$KeyNodesTableTableManager(_$ReferenceDatabase db, $KeyNodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$KeyNodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KeyNodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyNodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> taxonGroup = const Value.absent(),
                Value<int?> parentNodeId = const Value.absent(),
                Value<String?> questionKey = const Value.absent(),
              }) => KeyNodesCompanion(
                id: id,
                taxonGroup: taxonGroup,
                parentNodeId: parentNodeId,
                questionKey: questionKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String taxonGroup,
                Value<int?> parentNodeId = const Value.absent(),
                Value<String?> questionKey = const Value.absent(),
              }) => KeyNodesCompanion.insert(
                id: id,
                taxonGroup: taxonGroup,
                parentNodeId: parentNodeId,
                questionKey: questionKey,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$KeyNodesTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({keyLeafSpeciesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (keyLeafSpeciesRefs) db.keyLeafSpecies],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (keyLeafSpeciesRefs)
                    await $_getPrefetchedData<KeyNodeRow, $KeyNodesTable, KeyLeafSpeciesRow>(
                      currentTable: table,
                      referencedTable: $$KeyNodesTableReferences._keyLeafSpeciesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$KeyNodesTableReferences(db, table, p0).keyLeafSpeciesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.nodeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$KeyNodesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $KeyNodesTable,
      KeyNodeRow,
      $$KeyNodesTableFilterComposer,
      $$KeyNodesTableOrderingComposer,
      $$KeyNodesTableAnnotationComposer,
      $$KeyNodesTableCreateCompanionBuilder,
      $$KeyNodesTableUpdateCompanionBuilder,
      (KeyNodeRow, $$KeyNodesTableReferences),
      KeyNodeRow,
      PrefetchHooks Function({bool keyLeafSpeciesRefs})
    >;
typedef $$KeyLeafSpeciesTableCreateCompanionBuilder =
    KeyLeafSpeciesCompanion Function({
      required int nodeId,
      required int speciesId,
      Value<int> rank,
    });
typedef $$KeyLeafSpeciesTableUpdateCompanionBuilder =
    KeyLeafSpeciesCompanion Function({Value<int> nodeId, Value<int> speciesId, Value<int> rank});

final class $$KeyLeafSpeciesTableReferences
    extends BaseReferences<_$ReferenceDatabase, $KeyLeafSpeciesTable, KeyLeafSpeciesRow> {
  $$KeyLeafSpeciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KeyNodesTable _nodeIdTable(_$ReferenceDatabase db) =>
      db.keyNodes.createAlias('key_leaf_species__node_id__key_node__id');

  $$KeyNodesTableProcessedTableManager get nodeId {
    final $_column = $_itemColumn<int>('node_id')!;

    final manager = $$KeyNodesTableTableManager(
      $_db,
      $_db.keyNodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_nodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$KeyLeafSpeciesTableFilterComposer
    extends Composer<_$ReferenceDatabase, $KeyLeafSpeciesTable> {
  $$KeyLeafSpeciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => ColumnFilters(column));

  $$KeyNodesTableFilterComposer get nodeId {
    final $$KeyNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.keyNodes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyNodesTableFilterComposer(
            $db: $db,
            $table: $db.keyNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KeyLeafSpeciesTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $KeyLeafSpeciesTable> {
  $$KeyLeafSpeciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => ColumnOrderings(column));

  $$KeyNodesTableOrderingComposer get nodeId {
    final $$KeyNodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.keyNodes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyNodesTableOrderingComposer(
            $db: $db,
            $table: $db.keyNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KeyLeafSpeciesTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $KeyLeafSpeciesTable> {
  $$KeyLeafSpeciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get speciesId =>
      $composableBuilder(column: $table.speciesId, builder: (column) => column);

  GeneratedColumn<int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  $$KeyNodesTableAnnotationComposer get nodeId {
    final $$KeyNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.keyNodes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.keyNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KeyLeafSpeciesTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $KeyLeafSpeciesTable,
          KeyLeafSpeciesRow,
          $$KeyLeafSpeciesTableFilterComposer,
          $$KeyLeafSpeciesTableOrderingComposer,
          $$KeyLeafSpeciesTableAnnotationComposer,
          $$KeyLeafSpeciesTableCreateCompanionBuilder,
          $$KeyLeafSpeciesTableUpdateCompanionBuilder,
          (KeyLeafSpeciesRow, $$KeyLeafSpeciesTableReferences),
          KeyLeafSpeciesRow,
          PrefetchHooks Function({bool nodeId})
        > {
  $$KeyLeafSpeciesTableTableManager(_$ReferenceDatabase db, $KeyLeafSpeciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KeyLeafSpeciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KeyLeafSpeciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyLeafSpeciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> nodeId = const Value.absent(),
                Value<int> speciesId = const Value.absent(),
                Value<int> rank = const Value.absent(),
              }) => KeyLeafSpeciesCompanion(nodeId: nodeId, speciesId: speciesId, rank: rank),
          createCompanionCallback:
              ({
                required int nodeId,
                required int speciesId,
                Value<int> rank = const Value.absent(),
              }) =>
                  KeyLeafSpeciesCompanion.insert(nodeId: nodeId, speciesId: speciesId, rank: rank),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$KeyLeafSpeciesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({nodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (nodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.nodeId,
                                referencedTable: $$KeyLeafSpeciesTableReferences._nodeIdTable(db),
                                referencedColumn: $$KeyLeafSpeciesTableReferences
                                    ._nodeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$KeyLeafSpeciesTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $KeyLeafSpeciesTable,
      KeyLeafSpeciesRow,
      $$KeyLeafSpeciesTableFilterComposer,
      $$KeyLeafSpeciesTableOrderingComposer,
      $$KeyLeafSpeciesTableAnnotationComposer,
      $$KeyLeafSpeciesTableCreateCompanionBuilder,
      $$KeyLeafSpeciesTableUpdateCompanionBuilder,
      (KeyLeafSpeciesRow, $$KeyLeafSpeciesTableReferences),
      KeyLeafSpeciesRow,
      PrefetchHooks Function({bool nodeId})
    >;
typedef $$KeyOptionsTableCreateCompanionBuilder =
    KeyOptionsCompanion Function({
      Value<int> id,
      required int nodeId,
      required int optionIndex,
      required String labelKey,
      Value<String?> figureAsset,
      Value<int?> nextNodeId,
    });
typedef $$KeyOptionsTableUpdateCompanionBuilder =
    KeyOptionsCompanion Function({
      Value<int> id,
      Value<int> nodeId,
      Value<int> optionIndex,
      Value<String> labelKey,
      Value<String?> figureAsset,
      Value<int?> nextNodeId,
    });

final class $$KeyOptionsTableReferences
    extends BaseReferences<_$ReferenceDatabase, $KeyOptionsTable, KeyOptionRow> {
  $$KeyOptionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $KeyNodesTable _nodeIdTable(_$ReferenceDatabase db) =>
      db.keyNodes.createAlias('key_option__node_id__key_node__id');

  $$KeyNodesTableProcessedTableManager get nodeId {
    final $_column = $_itemColumn<int>('node_id')!;

    final manager = $$KeyNodesTableTableManager(
      $_db,
      $_db.keyNodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_nodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $KeyNodesTable _nextNodeIdTable(_$ReferenceDatabase db) =>
      db.keyNodes.createAlias('key_option__next_node_id__key_node__id');

  $$KeyNodesTableProcessedTableManager? get nextNodeId {
    final $_column = $_itemColumn<int>('next_node_id');
    if ($_column == null) return null;
    final manager = $$KeyNodesTableTableManager(
      $_db,
      $_db.keyNodes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_nextNodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$KeyOptionsTableFilterComposer extends Composer<_$ReferenceDatabase, $KeyOptionsTable> {
  $$KeyOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get optionIndex =>
      $composableBuilder(column: $table.optionIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get labelKey =>
      $composableBuilder(column: $table.labelKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get figureAsset =>
      $composableBuilder(column: $table.figureAsset, builder: (column) => ColumnFilters(column));

  $$KeyNodesTableFilterComposer get nodeId {
    final $$KeyNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.keyNodes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyNodesTableFilterComposer(
            $db: $db,
            $table: $db.keyNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$KeyNodesTableFilterComposer get nextNodeId {
    final $$KeyNodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nextNodeId,
      referencedTable: $db.keyNodes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyNodesTableFilterComposer(
            $db: $db,
            $table: $db.keyNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KeyOptionsTableOrderingComposer extends Composer<_$ReferenceDatabase, $KeyOptionsTable> {
  $$KeyOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get optionIndex =>
      $composableBuilder(column: $table.optionIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get labelKey =>
      $composableBuilder(column: $table.labelKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get figureAsset =>
      $composableBuilder(column: $table.figureAsset, builder: (column) => ColumnOrderings(column));

  $$KeyNodesTableOrderingComposer get nodeId {
    final $$KeyNodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.keyNodes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyNodesTableOrderingComposer(
            $db: $db,
            $table: $db.keyNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$KeyNodesTableOrderingComposer get nextNodeId {
    final $$KeyNodesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nextNodeId,
      referencedTable: $db.keyNodes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyNodesTableOrderingComposer(
            $db: $db,
            $table: $db.keyNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KeyOptionsTableAnnotationComposer extends Composer<_$ReferenceDatabase, $KeyOptionsTable> {
  $$KeyOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get optionIndex =>
      $composableBuilder(column: $table.optionIndex, builder: (column) => column);

  GeneratedColumn<String> get labelKey =>
      $composableBuilder(column: $table.labelKey, builder: (column) => column);

  GeneratedColumn<String> get figureAsset =>
      $composableBuilder(column: $table.figureAsset, builder: (column) => column);

  $$KeyNodesTableAnnotationComposer get nodeId {
    final $$KeyNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.keyNodes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.keyNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$KeyNodesTableAnnotationComposer get nextNodeId {
    final $$KeyNodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nextNodeId,
      referencedTable: $db.keyNodes,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$KeyNodesTableAnnotationComposer(
            $db: $db,
            $table: $db.keyNodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KeyOptionsTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $KeyOptionsTable,
          KeyOptionRow,
          $$KeyOptionsTableFilterComposer,
          $$KeyOptionsTableOrderingComposer,
          $$KeyOptionsTableAnnotationComposer,
          $$KeyOptionsTableCreateCompanionBuilder,
          $$KeyOptionsTableUpdateCompanionBuilder,
          (KeyOptionRow, $$KeyOptionsTableReferences),
          KeyOptionRow,
          PrefetchHooks Function({bool nodeId, bool nextNodeId})
        > {
  $$KeyOptionsTableTableManager(_$ReferenceDatabase db, $KeyOptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$KeyOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$KeyOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KeyOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> nodeId = const Value.absent(),
                Value<int> optionIndex = const Value.absent(),
                Value<String> labelKey = const Value.absent(),
                Value<String?> figureAsset = const Value.absent(),
                Value<int?> nextNodeId = const Value.absent(),
              }) => KeyOptionsCompanion(
                id: id,
                nodeId: nodeId,
                optionIndex: optionIndex,
                labelKey: labelKey,
                figureAsset: figureAsset,
                nextNodeId: nextNodeId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int nodeId,
                required int optionIndex,
                required String labelKey,
                Value<String?> figureAsset = const Value.absent(),
                Value<int?> nextNodeId = const Value.absent(),
              }) => KeyOptionsCompanion.insert(
                id: id,
                nodeId: nodeId,
                optionIndex: optionIndex,
                labelKey: labelKey,
                figureAsset: figureAsset,
                nextNodeId: nextNodeId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), $$KeyOptionsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({nodeId = false, nextNodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (nodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.nodeId,
                                referencedTable: $$KeyOptionsTableReferences._nodeIdTable(db),
                                referencedColumn: $$KeyOptionsTableReferences._nodeIdTable(db).id,
                              )
                              as T;
                    }
                    if (nextNodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.nextNodeId,
                                referencedTable: $$KeyOptionsTableReferences._nextNodeIdTable(db),
                                referencedColumn: $$KeyOptionsTableReferences
                                    ._nextNodeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$KeyOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $KeyOptionsTable,
      KeyOptionRow,
      $$KeyOptionsTableFilterComposer,
      $$KeyOptionsTableOrderingComposer,
      $$KeyOptionsTableAnnotationComposer,
      $$KeyOptionsTableCreateCompanionBuilder,
      $$KeyOptionsTableUpdateCompanionBuilder,
      (KeyOptionRow, $$KeyOptionsTableReferences),
      KeyOptionRow,
      PrefetchHooks Function({bool nodeId, bool nextNodeId})
    >;
typedef $$ContentStringsTableCreateCompanionBuilder =
    ContentStringsCompanion Function({
      required String key,
      required String locale,
      required String value,
    });
typedef $$ContentStringsTableUpdateCompanionBuilder =
    ContentStringsCompanion Function({
      Value<String> key,
      Value<String> locale,
      Value<String> value,
    });

class $$ContentStringsTableFilterComposer
    extends Composer<_$ReferenceDatabase, $ContentStringsTable> {
  $$ContentStringsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$ContentStringsTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $ContentStringsTable> {
  $$ContentStringsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$ContentStringsTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $ContentStringsTable> {
  $$ContentStringsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$ContentStringsTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $ContentStringsTable,
          ContentStringRow,
          $$ContentStringsTableFilterComposer,
          $$ContentStringsTableOrderingComposer,
          $$ContentStringsTableAnnotationComposer,
          $$ContentStringsTableCreateCompanionBuilder,
          $$ContentStringsTableUpdateCompanionBuilder,
          (
            ContentStringRow,
            BaseReferences<_$ReferenceDatabase, $ContentStringsTable, ContentStringRow>,
          ),
          ContentStringRow,
          PrefetchHooks Function()
        > {
  $$ContentStringsTableTableManager(_$ReferenceDatabase db, $ContentStringsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentStringsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentStringsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentStringsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> value = const Value.absent(),
              }) => ContentStringsCompanion(key: key, locale: locale, value: value),
          createCompanionCallback:
              ({required String key, required String locale, required String value}) =>
                  ContentStringsCompanion.insert(key: key, locale: locale, value: value),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentStringsTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $ContentStringsTable,
      ContentStringRow,
      $$ContentStringsTableFilterComposer,
      $$ContentStringsTableOrderingComposer,
      $$ContentStringsTableAnnotationComposer,
      $$ContentStringsTableCreateCompanionBuilder,
      $$ContentStringsTableUpdateCompanionBuilder,
      (
        ContentStringRow,
        BaseReferences<_$ReferenceDatabase, $ContentStringsTable, ContentStringRow>,
      ),
      ContentStringRow,
      PrefetchHooks Function()
    >;
typedef $$LegalTextsTableCreateCompanionBuilder =
    LegalTextsCompanion Function({
      Value<int> id,
      required int jurisdictionId,
      required int citationId,
      required String locale,
      Value<String?> articleRef,
      required String body,
      required String bodyNorm,
      required int sortOrder,
    });
typedef $$LegalTextsTableUpdateCompanionBuilder =
    LegalTextsCompanion Function({
      Value<int> id,
      Value<int> jurisdictionId,
      Value<int> citationId,
      Value<String> locale,
      Value<String?> articleRef,
      Value<String> body,
      Value<String> bodyNorm,
      Value<int> sortOrder,
    });

class $$LegalTextsTableFilterComposer extends Composer<_$ReferenceDatabase, $LegalTextsTable> {
  $$LegalTextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get articleRef =>
      $composableBuilder(column: $table.articleRef, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyNorm =>
      $composableBuilder(column: $table.bodyNorm, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));
}

class $$LegalTextsTableOrderingComposer extends Composer<_$ReferenceDatabase, $LegalTextsTable> {
  $$LegalTextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get jurisdictionId => $composableBuilder(
    column: $table.jurisdictionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get articleRef =>
      $composableBuilder(column: $table.articleRef, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyNorm =>
      $composableBuilder(column: $table.bodyNorm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$LegalTextsTableAnnotationComposer extends Composer<_$ReferenceDatabase, $LegalTextsTable> {
  $$LegalTextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get jurisdictionId =>
      $composableBuilder(column: $table.jurisdictionId, builder: (column) => column);

  GeneratedColumn<int> get citationId =>
      $composableBuilder(column: $table.citationId, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get articleRef =>
      $composableBuilder(column: $table.articleRef, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get bodyNorm =>
      $composableBuilder(column: $table.bodyNorm, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$LegalTextsTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $LegalTextsTable,
          LegalTextRow,
          $$LegalTextsTableFilterComposer,
          $$LegalTextsTableOrderingComposer,
          $$LegalTextsTableAnnotationComposer,
          $$LegalTextsTableCreateCompanionBuilder,
          $$LegalTextsTableUpdateCompanionBuilder,
          (LegalTextRow, BaseReferences<_$ReferenceDatabase, $LegalTextsTable, LegalTextRow>),
          LegalTextRow,
          PrefetchHooks Function()
        > {
  $$LegalTextsTableTableManager(_$ReferenceDatabase db, $LegalTextsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LegalTextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$LegalTextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LegalTextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> jurisdictionId = const Value.absent(),
                Value<int> citationId = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String?> articleRef = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> bodyNorm = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => LegalTextsCompanion(
                id: id,
                jurisdictionId: jurisdictionId,
                citationId: citationId,
                locale: locale,
                articleRef: articleRef,
                body: body,
                bodyNorm: bodyNorm,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int jurisdictionId,
                required int citationId,
                required String locale,
                Value<String?> articleRef = const Value.absent(),
                required String body,
                required String bodyNorm,
                required int sortOrder,
              }) => LegalTextsCompanion.insert(
                id: id,
                jurisdictionId: jurisdictionId,
                citationId: citationId,
                locale: locale,
                articleRef: articleRef,
                body: body,
                bodyNorm: bodyNorm,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LegalTextsTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $LegalTextsTable,
      LegalTextRow,
      $$LegalTextsTableFilterComposer,
      $$LegalTextsTableOrderingComposer,
      $$LegalTextsTableAnnotationComposer,
      $$LegalTextsTableCreateCompanionBuilder,
      $$LegalTextsTableUpdateCompanionBuilder,
      (LegalTextRow, BaseReferences<_$ReferenceDatabase, $LegalTextsTable, LegalTextRow>),
      LegalTextRow,
      PrefetchHooks Function()
    >;
typedef $$ContentMetasTableCreateCompanionBuilder =
    ContentMetasCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$ContentMetasTableUpdateCompanionBuilder =
    ContentMetasCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$ContentMetasTableFilterComposer extends Composer<_$ReferenceDatabase, $ContentMetasTable> {
  $$ContentMetasTableFilterComposer({
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

class $$ContentMetasTableOrderingComposer
    extends Composer<_$ReferenceDatabase, $ContentMetasTable> {
  $$ContentMetasTableOrderingComposer({
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

class $$ContentMetasTableAnnotationComposer
    extends Composer<_$ReferenceDatabase, $ContentMetasTable> {
  $$ContentMetasTableAnnotationComposer({
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

class $$ContentMetasTableTableManager
    extends
        RootTableManager<
          _$ReferenceDatabase,
          $ContentMetasTable,
          ContentMetaRow,
          $$ContentMetasTableFilterComposer,
          $$ContentMetasTableOrderingComposer,
          $$ContentMetasTableAnnotationComposer,
          $$ContentMetasTableCreateCompanionBuilder,
          $$ContentMetasTableUpdateCompanionBuilder,
          (ContentMetaRow, BaseReferences<_$ReferenceDatabase, $ContentMetasTable, ContentMetaRow>),
          ContentMetaRow,
          PrefetchHooks Function()
        > {
  $$ContentMetasTableTableManager(_$ReferenceDatabase db, $ContentMetasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ContentMetasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ContentMetasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentMetasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentMetasCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => ContentMetasCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContentMetasTableProcessedTableManager =
    ProcessedTableManager<
      _$ReferenceDatabase,
      $ContentMetasTable,
      ContentMetaRow,
      $$ContentMetasTableFilterComposer,
      $$ContentMetasTableOrderingComposer,
      $$ContentMetasTableAnnotationComposer,
      $$ContentMetasTableCreateCompanionBuilder,
      $$ContentMetasTableUpdateCompanionBuilder,
      (ContentMetaRow, BaseReferences<_$ReferenceDatabase, $ContentMetasTable, ContentMetaRow>),
      ContentMetaRow,
      PrefetchHooks Function()
    >;

class $ReferenceDatabaseManager {
  final _$ReferenceDatabase _db;
  $ReferenceDatabaseManager(this._db);
  $$JurisdictionsTableTableManager get jurisdictions =>
      $$JurisdictionsTableTableManager(_db, _db.jurisdictions);
  $$ZonesTableTableManager get zones => $$ZonesTableTableManager(_db, _db.zones);
  $$ZoneRingsTableTableManager get zoneRings => $$ZoneRingsTableTableManager(_db, _db.zoneRings);
  $$FamiliesTableTableManager get families => $$FamiliesTableTableManager(_db, _db.families);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db, _db.speciesTable);
  $$SpeciesNamesTableTableManager get speciesNames =>
      $$SpeciesNamesTableTableManager(_db, _db.speciesNames);
  $$MeasurementMethodsTableTableManager get measurementMethods =>
      $$MeasurementMethodsTableTableManager(_db, _db.measurementMethods);
  $$CitationsTableTableManager get citations => $$CitationsTableTableManager(_db, _db.citations);
  $$RulesTableTableManager get rules => $$RulesTableTableManager(_db, _db.rules);
  $$ClosedSeasonsTableTableManager get closedSeasons =>
      $$ClosedSeasonsTableTableManager(_db, _db.closedSeasons);
  $$LicenceTypesTableTableManager get licenceTypes =>
      $$LicenceTypesTableTableManager(_db, _db.licenceTypes);
  $$GearRulesTableTableManager get gearRules => $$GearRulesTableTableManager(_db, _db.gearRules);
  $$PenaltiesTableTableManager get penalties => $$PenaltiesTableTableManager(_db, _db.penalties);
  $$LookalikesTableTableManager get lookalikes =>
      $$LookalikesTableTableManager(_db, _db.lookalikes);
  $$GlossaryTermsTableTableManager get glossaryTerms =>
      $$GlossaryTermsTableTableManager(_db, _db.glossaryTerms);
  $$ContentChangesTableTableManager get contentChanges =>
      $$ContentChangesTableTableManager(_db, _db.contentChanges);
  $$KeyNodesTableTableManager get keyNodes => $$KeyNodesTableTableManager(_db, _db.keyNodes);
  $$KeyLeafSpeciesTableTableManager get keyLeafSpecies =>
      $$KeyLeafSpeciesTableTableManager(_db, _db.keyLeafSpecies);
  $$KeyOptionsTableTableManager get keyOptions =>
      $$KeyOptionsTableTableManager(_db, _db.keyOptions);
  $$ContentStringsTableTableManager get contentStrings =>
      $$ContentStringsTableTableManager(_db, _db.contentStrings);
  $$LegalTextsTableTableManager get legalTexts =>
      $$LegalTextsTableTableManager(_db, _db.legalTexts);
  $$ContentMetasTableTableManager get contentMetas =>
      $$ContentMetasTableTableManager(_db, _db.contentMetas);
}
