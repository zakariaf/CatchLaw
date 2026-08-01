// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legal_text_dao.dart';

// ignore_for_file: type=lint
mixin _$LegalTextDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $LegalTextsTable get legalTexts => attachedDatabase.legalTexts;
  LegalTextDaoManager get managers => LegalTextDaoManager(this);
}

class LegalTextDaoManager {
  final _$LegalTextDaoMixin _db;
  LegalTextDaoManager(this._db);
  $$LegalTextsTableTableManager get legalTexts =>
      $$LegalTextsTableTableManager(_db.attachedDatabase, _db.legalTexts);
}
