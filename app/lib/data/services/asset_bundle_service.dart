import 'package:flutter/services.dart' show rootBundle;

/// Reads a bundled asset as a byte stream.
///
/// A port, because `rootBundle` needs a widget binding: an installer that
/// touched it directly would make every one of its tests a widget test and the
/// force-quit case untestable.
abstract interface class AssetBundleService {
  /// The bytes of [key], streamed rather than loaded whole.
  ///
  /// Streamed because the payload is ~10 MB compressed and `SPEC.md` §13's
  /// low-end device has 2 GB of RAM: holding the decompressed file in memory to
  /// write it is the shortest correct-looking implementation and the one the
  /// skill names as an anti-pattern twice.
  Stream<List<int>> openRead(String key);
}

/// The real bundle. **The only file in `app/lib/` that names `rootBundle`.**
final class RootBundleAssetService implements AssetBundleService {
  /// Reads from Flutter's asset bundle.
  const RootBundleAssetService();

  @override
  Stream<List<int>> openRead(String key) async* {
    // `load` returns a ByteData; the streaming shape is the port's, so the
    // installer's write loop and its progress callback are identical against
    // the real bundle and against a fake.
    final Object bytes = (await rootBundle.load(key)).buffer.asUint8List();
    yield bytes as List<int>;
  }
}
