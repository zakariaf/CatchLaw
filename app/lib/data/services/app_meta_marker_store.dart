import 'package:catchlaw/data/services/reference_installer.dart';
import 'package:catchlaw/data/services/user_database_service.dart';

/// The extraction completion marker, in `user.db`'s `app_meta`.
///
/// D-6 merged `SPEC.md` §7.4's marker with the skill's mechanics and put it
/// here rather than in an `INSTALLED` stamp file. Two markers would be one too
/// many, and the one that is not written last is the one that lies.
///
/// **This does not couple the two databases.** It holds a [UserDatabase] and
/// nothing else; the installer holds a `MarkerStore` and nothing else. There is
/// no `ATTACH`, no shared `QueryExecutor` and no SQL spanning both files — the
/// two connections are opened by two separate `LazyDatabase` callbacks, and
/// neither knows the other exists.
///
/// A failure to write the marker is **harmless**: the next launch sees a
/// mismatch and re-extracts a file that is already correct. The reverse
/// ordering is not harmless, which is why E05/T02 asserts the rename comes
/// first.
final class AppMetaMarkerStore implements MarkerStore {
  /// Reads and writes the marker in [db].
  const AppMetaMarkerStore(this.db);

  /// The fisher's log. The only database this store touches.
  final UserDatabase db;

  /// The `app_meta` key D-6 names.
  static const String key = 'content_build_date';

  @override
  Future<String?> read() async {
    final AppMetaRow? row = await (db.select(
      db.appMetas,
    )..where(($AppMetasTable t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> write(String buildDate) => db
      .into(db.appMetas)
      .insertOnConflictUpdate(AppMetasCompanion.insert(key: key, value: buildDate));

  @override
  Future<void> clear() =>
      (db.delete(db.appMetas)..where(($AppMetasTable t) => t.key.equals(key))).go();
}
