// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'key_dao.dart';

// ignore_for_file: type=lint
mixin _$KeyDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $KeyNodesTable get keyNodes => attachedDatabase.keyNodes;
  $KeyOptionsTable get keyOptions => attachedDatabase.keyOptions;
  $KeyLeafSpeciesTable get keyLeafSpecies => attachedDatabase.keyLeafSpecies;
  $FamiliesTable get families => attachedDatabase.families;
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  KeyDaoManager get managers => KeyDaoManager(this);
}

class KeyDaoManager {
  final _$KeyDaoMixin _db;
  KeyDaoManager(this._db);
  $$KeyNodesTableTableManager get keyNodes =>
      $$KeyNodesTableTableManager(_db.attachedDatabase, _db.keyNodes);
  $$KeyOptionsTableTableManager get keyOptions =>
      $$KeyOptionsTableTableManager(_db.attachedDatabase, _db.keyOptions);
  $$KeyLeafSpeciesTableTableManager get keyLeafSpecies =>
      $$KeyLeafSpeciesTableTableManager(_db.attachedDatabase, _db.keyLeafSpecies);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
}
