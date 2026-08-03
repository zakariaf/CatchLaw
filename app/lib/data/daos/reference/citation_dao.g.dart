// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citation_dao.dart';

// ignore_for_file: type=lint
mixin _$CitationDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $CitationsTable get citations => attachedDatabase.citations;
  CitationDaoManager get managers => CitationDaoManager(this);
}

class CitationDaoManager {
  final _$CitationDaoMixin _db;
  CitationDaoManager(this._db);
  $$CitationsTableTableManager get citations =>
      $$CitationsTableTableManager(_db.attachedDatabase, _db.citations);
}

mixin _$ReferenceMetaDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $ContentMetasTable get contentMetas => attachedDatabase.contentMetas;
  $JurisdictionsTable get jurisdictions => attachedDatabase.jurisdictions;
  $MeasurementMethodsTable get measurementMethods => attachedDatabase.measurementMethods;
  ReferenceMetaDaoManager get managers => ReferenceMetaDaoManager(this);
}

class ReferenceMetaDaoManager {
  final _$ReferenceMetaDaoMixin _db;
  ReferenceMetaDaoManager(this._db);
  $$ContentMetasTableTableManager get contentMetas =>
      $$ContentMetasTableTableManager(_db.attachedDatabase, _db.contentMetas);
  $$JurisdictionsTableTableManager get jurisdictions =>
      $$JurisdictionsTableTableManager(_db.attachedDatabase, _db.jurisdictions);
  $$MeasurementMethodsTableTableManager get measurementMethods =>
      $$MeasurementMethodsTableTableManager(_db.attachedDatabase, _db.measurementMethods);
}
