import 'dart:io';

import 'package:catchlaw/data/services/app_directories.dart';
import 'package:catchlaw/data/services/reference_installer.dart';

/// An in-memory completion marker that records the ORDER of its writes.
///
/// The order is the point: D-6 puts the marker write after the rename, and a
/// marker written first is a claim about a file that does not exist.
final class FakeMarkerStore implements MarkerStore {
  /// A marker holding [installed], or nothing.
  FakeMarkerStore([this.installed]);

  /// The build date currently recorded.
  String? installed;

  /// Every call, in order: `clear`, `write:<date>` or `read`.
  final List<String> calls = <String>[];

  @override
  Future<String?> read() async {
    calls.add('read');
    return installed;
  }

  @override
  Future<void> write(String buildDate) async {
    calls.add('write:$buildDate');
    installed = buildDate;
  }

  @override
  Future<void> clear() async {
    calls.add('clear');
    installed = null;
  }
}

/// [AppDirectories] pointing at a directory a test controls.
///
/// Both databases resolve to the same directory here; the real implementation
/// puts them under application support, which needs a platform channel.
final class FixedDirectories implements AppDirectories {
  /// Both databases under [directory].
  const FixedDirectories(this.directory);

  /// Where both files go.
  final Directory directory;

  @override
  Future<Directory> reference() async => directory;

  @override
  Future<Directory> user() async => directory;
}
