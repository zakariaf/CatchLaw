// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_dao.dart';

// ignore_for_file: type=lint
mixin _$SpeciesDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  $SpeciesNamesTable get speciesNames => attachedDatabase.speciesNames;
  $LookalikesTable get lookalikes => attachedDatabase.lookalikes;
  SpeciesDaoManager get managers => SpeciesDaoManager(this);
}

class SpeciesDaoManager {
  final _$SpeciesDaoMixin _db;
  SpeciesDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
  $$SpeciesNamesTableTableManager get speciesNames =>
      $$SpeciesNamesTableTableManager(_db.attachedDatabase, _db.speciesNames);
  $$LookalikesTableTableManager get lookalikes =>
      $$LookalikesTableTableManager(_db.attachedDatabase, _db.lookalikes);
}
