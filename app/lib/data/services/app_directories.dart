import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Where the two databases live.
///
/// A port, because `path_provider` needs a platform channel.
abstract interface class AppDirectories {
  /// Where the extracted rule book goes.
  Future<Directory> reference();

  /// Where the fisher's log goes.
  Future<Directory> user();
}

/// Both under `getApplicationSupportDirectory()`.
///
/// **Not documents**, which is user-visible on iOS — the fisher can delete the
/// rule book by tidying up. **Not temporary or cache**, which the OS reclaims
/// under storage pressure without the app running: the single worst place for
/// the file whose entire value is answering with no signal.
final class PathProviderDirectories implements AppDirectories {
  /// Resolves both directories under application support.
  const PathProviderDirectories();

  @override
  Future<Directory> reference() async => _under('db');

  @override
  Future<Directory> user() async => _under('db');

  static Future<Directory> _under(String segment) async {
    final Directory support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, segment)).create(recursive: true);
  }
}
