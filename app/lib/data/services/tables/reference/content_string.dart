import 'package:drift/drift.dart';

/// `SPEC.md` §7.1 `content_string` — tier two of §9.2.
///
/// Every piece of **bundled content** text. UI chrome lives in ARB files.
/// `WITHOUT ROWID` because §7.1 says so, and because it is the difference
/// between one page read and two on every localised string.
///
/// No row here may key a `legal_text.*` id: an unofficial translation of a penal
/// instrument is a liability and falls outside Spain's Art. 13 LPI carve-out,
/// which covers *official* translations only.
@DataClassName('ContentStringRow')
class ContentStrings extends Table {
  @override
  String get tableName => 'content_string';

  TextColumn get key => text()();

  TextColumn get locale => text()();

  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key, locale};

  @override
  bool get withoutRowId => true;
}
