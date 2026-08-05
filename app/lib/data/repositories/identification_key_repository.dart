import 'package:catchlaw/domain/models/key_step.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// S7's dichotomous key, one couplet at a time.
abstract interface class IdentificationKeyRepository {
  /// Where the key starts, or `null` when this pack carries no key.
  ///
  /// **`null` and a failure are two different answers.** A pack with no key is
  /// a fact about the transcription and the screen states it; a pack that could
  /// not be read is a fact about the device, and merging the two would have the
  /// app claim a jurisdiction has no key when the file was simply unreadable.
  @useResult
  Future<Result<KeyStep?>> firstStep({required String locale});

  /// The couplet at [nodeId], or `null` when the pack does not carry it.
  @useResult
  Future<Result<KeyStep?>> stepAt(int nodeId, {required String locale});
}
