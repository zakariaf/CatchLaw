// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_browse_dao.dart';

// ignore_for_file: type=lint
mixin _$SpeciesBrowseDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  $SpeciesNamesTable get speciesNames => attachedDatabase.speciesNames;
  $RulesTable get rules => attachedDatabase.rules;
  SpeciesBrowseDaoManager get managers => SpeciesBrowseDaoManager(this);
}

class SpeciesBrowseDaoManager {
  final _$SpeciesBrowseDaoMixin _db;
  SpeciesBrowseDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
  $$SpeciesNamesTableTableManager get speciesNames =>
      $$SpeciesNamesTableTableManager(_db.attachedDatabase, _db.speciesNames);
  $$RulesTableTableManager get rules => $$RulesTableTableManager(_db.attachedDatabase, _db.rules);
}
