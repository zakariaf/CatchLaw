import 'package:catchlaw/data/repositories/species_browse_repository.dart';
import 'package:catchlaw/domain/models/family_group.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// An in-memory [SpeciesBrowseRepository].
final class FakeSpeciesBrowseRepository implements SpeciesBrowseRepository {
  /// Serves [groups], or fails every call with [failure].
  FakeSpeciesBrowseRepository(this.groups, {this.failure});

  /// The grid.
  final List<FamilyGroup> groups;

  /// What every call fails with, when the test is about a broken store.
  final Exception? failure;

  /// Every locale this repository was asked for, in order.
  final List<String> locales = <String>[];

  @override
  Future<Result<List<FamilyGroup>>> browseByFamily({required String locale}) async {
    locales.add(locale);
    if (failure != null) return Result<List<FamilyGroup>>.error(failure!);
    return Result<List<FamilyGroup>>.ok(groups);
  }
}
