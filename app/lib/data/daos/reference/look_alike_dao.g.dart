// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'look_alike_dao.dart';

// ignore_for_file: type=lint
mixin _$LookAlikeDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $FamiliesTable get families => attachedDatabase.families;
  $SpeciesTableTable get speciesTable => attachedDatabase.speciesTable;
  $LookalikesTable get lookalikes => attachedDatabase.lookalikes;
  LookAlikeDaoManager get managers => LookAlikeDaoManager(this);
}

class LookAlikeDaoManager {
  final _$LookAlikeDaoMixin _db;
  LookAlikeDaoManager(this._db);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db.attachedDatabase, _db.families);
  $$SpeciesTableTableTableManager get speciesTable =>
      $$SpeciesTableTableTableManager(_db.attachedDatabase, _db.speciesTable);
  $$LookalikesTableTableManager get lookalikes =>
      $$LookalikesTableTableManager(_db.attachedDatabase, _db.lookalikes);
}
