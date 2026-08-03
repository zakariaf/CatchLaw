import 'package:catchlaw/domain/models/rule_flag.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// The fisher's disputes with the transcription, in `user.db`.
///
/// The only writable database (D-6). Nothing here touches `reference.db`: the
/// shipped file is opened read-only, and a write to it would break every later
/// integrity check on a digest the build recorded.
abstract interface class RuleFlagRepository {
  /// Records [draft].
  @useResult
  Future<Result<void>> flag(RuleFlagDraft draft);

  /// Every flag, newest first, re-emitted whenever one is added.
  ///
  /// A stream because E17 exports from it, and an export built from a snapshot
  /// taken before the last write is an export missing the row the reader just
  /// added — which is the one he is exporting for.
  Stream<List<RuleFlag>> watchAll();
}
