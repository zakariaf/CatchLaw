import 'package:catchlaw/data/services/asset_bundle_service.dart';
import 'package:flutter/foundation.dart' show FlutterError;

/// The environments the bundle can be in.
///
/// An enum rather than a set of booleans, so each failure environment is a named
/// case and adding one is a compile error at every `switch` — including the
/// absence-of-a-failure-class test, which loops over [detectable].
enum AssetEnv {
  /// The asset is present and complete.
  healthy,

  /// `pubspec.yaml` never listed it, or listed it under a different key.
  missing,

  /// The read stops half-way. `SPEC.md` §14's force-quit case, and the shape it
  /// actually takes: a truncated gzip stream, which the decoder rejects.
  diesMidStream,

  /// The bytes arrive intact and are not the bytes the build produced.
  corrupt;

  /// The environments a healthy installer must either survive or name.
  ///
  /// All of them. There is no environment where losing silently is acceptable:
  /// a rule book that half-installed and reported nothing is a confident wrong
  /// answer, which is the one outcome this product cannot ship.
  static List<AssetEnv> get detectable => values;
}

/// A bundle whose behaviour is chosen by an [AssetEnv].
///
/// Bare `implements`, no `noSuchMethod` superclass: a method added to the port
/// must be a compile error here rather than a runtime `NoSuchMethodError` in
/// whichever test happens to reach it first.
final class FakeAssetBundleService implements AssetBundleService {
  /// A bundle behaving as [env] over [payload].
  FakeAssetBundleService(this.env, {required this.payload, this.corruptPayload = const <int>[]});

  /// Which environment this bundle is in. Mutable, so a test can install
  /// healthily after a failure and prove extraction restarts cleanly.
  AssetEnv env;

  /// The gzipped bytes a healthy read returns.
  final List<int> payload;

  /// A second valid gzip carrying different bytes: the digest must catch what
  /// the decompressor cannot.
  final List<int> corruptPayload;

  /// How many times [openRead] has been called. The retry ladder is counted,
  /// not assumed.
  int opens = 0;

  @override
  Stream<List<int>> openRead(String key) async* {
    opens++;
    switch (env) {
      case AssetEnv.missing:
        throw FlutterError('Unable to load asset: $key');
      case AssetEnv.healthy:
        yield* _chunked(payload);
      case AssetEnv.corrupt:
        yield* _chunked(corruptPayload);
      case AssetEnv.diesMidStream:
        // Half a gzip stream and then end-of-stream. No exception is thrown:
        // this is what a killed write actually leaves, and the decoder is what
        // notices.
        yield* _chunked(payload.sublist(0, payload.length ~/ 2));
    }
  }

  static Stream<List<int>> _chunked(List<int> bytes) async* {
    const int chunk = 8 * 1024;
    for (var i = 0; i < bytes.length; i += chunk) {
      yield bytes.sublist(i, i + chunk > bytes.length ? bytes.length : i + chunk);
    }
  }
}
