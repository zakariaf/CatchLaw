import 'package:catchlaw/domain/models/family_group.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// S6's grid: every species the pack carries, grouped by family.
abstract interface class SpeciesBrowseRepository {
  /// Every family with at least one species, names resolved into [locale].
  ///
  /// A family with no species is omitted rather than shown empty: a heading
  /// over nothing reads as content that failed to load.
  @useResult
  Future<Result<List<FamilyGroup>>> browseByFamily({required String locale});
}
