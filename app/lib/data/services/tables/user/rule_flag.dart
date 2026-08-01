import 'package:drift/drift.dart';

/// `SPEC.md` §7.2 `rule_flag` — "this looks wrong to me".
///
/// Local only. It is a note the fisher can export (§12), never a report the app
/// sends: there is no network code path to send it down.
@DataClassName('RuleFlagRow')
class RuleFlags extends Table {
  @override
  String get tableName => 'rule_flag';

  IntColumn get id => integer().autoIncrement()();

  /// A soft reference into the pack that was installed at the time.
  IntColumn get ruleId => integer().named('rule_id')();

  TextColumn get citationRef => text().named('citation_ref').nullable()();

  TextColumn get note => text()();

  TextColumn get createdAt => text().named('created_at')();

  @override
  bool get isStrict => true;
}
