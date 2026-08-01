// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_dao.dart';

// ignore_for_file: type=lint
mixin _$UserProfileDaoMixin on DatabaseAccessor<UserDatabase> {
  $UserProfilesTable get userProfiles => attachedDatabase.userProfiles;
  UserProfileDaoManager get managers => UserProfileDaoManager(this);
}

class UserProfileDaoManager {
  final _$UserProfileDaoMixin _db;
  UserProfileDaoManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db.attachedDatabase, _db.userProfiles);
}

mixin _$SavedZoneDaoMixin on DatabaseAccessor<UserDatabase> {
  $SavedZonesTable get savedZones => attachedDatabase.savedZones;
  SavedZoneDaoManager get managers => SavedZoneDaoManager(this);
}

class SavedZoneDaoManager {
  final _$SavedZoneDaoMixin _db;
  SavedZoneDaoManager(this._db);
  $$SavedZonesTableTableManager get savedZones =>
      $$SavedZonesTableTableManager(_db.attachedDatabase, _db.savedZones);
}

mixin _$SpeciesRecentDaoMixin on DatabaseAccessor<UserDatabase> {
  $SpeciesRecentsTable get speciesRecents => attachedDatabase.speciesRecents;
  SpeciesRecentDaoManager get managers => SpeciesRecentDaoManager(this);
}

class SpeciesRecentDaoManager {
  final _$SpeciesRecentDaoMixin _db;
  SpeciesRecentDaoManager(this._db);
  $$SpeciesRecentsTableTableManager get speciesRecents =>
      $$SpeciesRecentsTableTableManager(_db.attachedDatabase, _db.speciesRecents);
}

mixin _$RuleFlagDaoMixin on DatabaseAccessor<UserDatabase> {
  $RuleFlagsTable get ruleFlags => attachedDatabase.ruleFlags;
  RuleFlagDaoManager get managers => RuleFlagDaoManager(this);
}

class RuleFlagDaoManager {
  final _$RuleFlagDaoMixin _db;
  RuleFlagDaoManager(this._db);
  $$RuleFlagsTableTableManager get ruleFlags =>
      $$RuleFlagsTableTableManager(_db.attachedDatabase, _db.ruleFlags);
}

mixin _$AppMetaDaoMixin on DatabaseAccessor<UserDatabase> {
  $AppMetasTable get appMetas => attachedDatabase.appMetas;
  AppMetaDaoManager get managers => AppMetaDaoManager(this);
}

class AppMetaDaoManager {
  final _$AppMetaDaoMixin _db;
  AppMetaDaoManager(this._db);
  $$AppMetasTableTableManager get appMetas =>
      $$AppMetasTableTableManager(_db.attachedDatabase, _db.appMetas);
}
