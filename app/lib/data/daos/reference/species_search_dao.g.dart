// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_search_dao.dart';

// ignore_for_file: type=lint
mixin _$SpeciesSearchDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  $SpeciesNamesTable get speciesNames => attachedDatabase.speciesNames;
  SpeciesSearchDaoManager get managers => SpeciesSearchDaoManager(this);
}

class SpeciesSearchDaoManager {
  final _$SpeciesSearchDaoMixin _db;
  SpeciesSearchDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
  $$SpeciesNamesTableTableManager get speciesNames =>
      $$SpeciesNamesTableTableManager(_db.attachedDatabase, _db.speciesNames);
}
