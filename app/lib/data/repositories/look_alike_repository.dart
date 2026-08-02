import 'package:catchlaw/domain/models/look_alike.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// The species one species is mistaken for.
abstract interface class LookAlikeRepository {
  /// Every look-alike of [speciesId], in both directions.
  @useResult
  Future<Result<List<LookAlike>>> forSpecies(int speciesId, {required String locale});
}
