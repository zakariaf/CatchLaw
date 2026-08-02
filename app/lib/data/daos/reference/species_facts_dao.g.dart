// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_facts_dao.dart';

// ignore_for_file: type=lint
mixin _$SpeciesFactsDaoMixin on DatabaseAccessor<ReferenceDatabase> {
  $RulesTable get rules => attachedDatabase.rules;
  $ClosedSeasonsTable get closedSeasons => attachedDatabase.closedSeasons;
  $ZonesTable get zones => attachedDatabase.zones;
  SpeciesFactsDaoManager get managers => SpeciesFactsDaoManager(this);
}

class SpeciesFactsDaoManager {
  final _$SpeciesFactsDaoMixin _db;
  SpeciesFactsDaoManager(this._db);
  $$RulesTableTableManager get rules => $$RulesTableTableManager(_db.attachedDatabase, _db.rules);
  $$ClosedSeasonsTableTableManager get closedSeasons =>
      $$ClosedSeasonsTableTableManager(_db.attachedDatabase, _db.closedSeasons);
  $$ZonesTableTableManager get zones => $$ZonesTableTableManager(_db.attachedDatabase, _db.zones);
}
