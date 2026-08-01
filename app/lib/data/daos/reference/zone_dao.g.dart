// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zone_dao.dart';

// ignore_for_file: type=lint
mixin _$ZoneDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $ZonesTable get zones => attachedDatabase.zones;
  $ZoneRingsTable get zoneRings => attachedDatabase.zoneRings;
  ZoneDaoManager get managers => ZoneDaoManager(this);
}

class ZoneDaoManager {
  final _$ZoneDaoMixin _db;
  ZoneDaoManager(this._db);
  $$ZonesTableTableManager get zones => $$ZonesTableTableManager(_db.attachedDatabase, _db.zones);
  $$ZoneRingsTableTableManager get zoneRings =>
      $$ZoneRingsTableTableManager(_db.attachedDatabase, _db.zoneRings);
}
