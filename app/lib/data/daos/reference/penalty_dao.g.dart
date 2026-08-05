// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penalty_dao.dart';

// ignore_for_file: type=lint
mixin _$PenaltyDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $PenaltiesTable get penalties => attachedDatabase.penalties;
  PenaltyDaoManager get managers => PenaltyDaoManager(this);
}

class PenaltyDaoManager {
  final _$PenaltyDaoMixin _db;
  PenaltyDaoManager(this._db);
  $$PenaltiesTableTableManager get penalties =>
      $$PenaltiesTableTableManager(_db.attachedDatabase, _db.penalties);
}
