// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catch_dao.dart';

// ignore_for_file: type=lint
mixin _$CatchDaoMixin on DatabaseAccessor<UserDatabase> {
  $CatchesTable get catches => attachedDatabase.catches;
  $SpeciesRecentsTable get speciesRecents => attachedDatabase.speciesRecents;
  CatchDaoManager get managers => CatchDaoManager(this);
}

class CatchDaoManager {
  final _$CatchDaoMixin _db;
  CatchDaoManager(this._db);
  $$CatchesTableTableManager get catches =>
      $$CatchesTableTableManager(_db.attachedDatabase, _db.catches);
  $$SpeciesRecentsTableTableManager get speciesRecents =>
      $$SpeciesRecentsTableTableManager(_db.attachedDatabase, _db.speciesRecents);
}
