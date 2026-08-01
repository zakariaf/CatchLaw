// Not a test file. CONVENTIONS.md §6: a helper must not end in _test.dart.
import 'dart:io';

/// The workspace root, found by walking up from the current directory until a
/// `pubspec.yaml` declaring `name: catchlaw_workspace` is reached.
///
/// `flutter test` sets the working directory to the package root (`app/`), so a
/// repository-level policy test cannot use a relative literal, and
/// `policy-grep-gate.md` forbids building a path from `Platform.script`.
/// Memoised: every [repoFile] call would otherwise re-walk and re-read a
/// pubspec per lookup, and one policy test makes fifteen of them.
Directory? _cachedRoot;

Directory repoRoot() {
  final cached = _cachedRoot;
  if (cached != null) return cached;
  var dir = Directory.current.absolute;
  while (true) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('name: catchlaw_workspace')) {
      return _cachedRoot = dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
        'no catchlaw_workspace pubspec.yaml above ${Directory.current.path}',
      );
    }
    dir = parent;
  }
}

/// The file at [relative], resolved against [repoRoot].
File repoFile(String relative) => File('${repoRoot().path}/$relative');

/// The directory at [relative], resolved against [repoRoot].
Directory repoDir(String relative) => Directory('${repoRoot().path}/$relative');
