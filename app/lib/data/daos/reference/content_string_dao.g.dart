// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_string_dao.dart';

// ignore_for_file: type=lint
mixin _$ContentStringDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $ContentStringsTable get contentStrings => attachedDatabase.contentStrings;
  ContentStringDaoManager get managers => ContentStringDaoManager(this);
}

class ContentStringDaoManager {
  final _$ContentStringDaoMixin _db;
  ContentStringDaoManager(this._db);
  $$ContentStringsTableTableManager get contentStrings =>
      $$ContentStringsTableTableManager(_db.attachedDatabase, _db.contentStrings);
}
