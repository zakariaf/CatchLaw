import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/family_group.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// S6's grid.
///
/// The locale is a parameter rather than read from a `BuildContext`, because a
/// view model that reached for a context could not be driven headlessly — and
/// every row in its suite would need a pump for a question about data.
class SpeciesBrowseViewModel extends AsyncNotifier<List<FamilyGroup>> {
  @override
  Future<List<FamilyGroup>> build() => load(locale: 'en');

  /// Loads the grid for [locale].
  ///
  /// A failed read becomes an `AsyncError` rather than an empty grid: an empty
  /// grid is a statement about the pack — "this jurisdiction has no species
  /// transcribed" — and saying that when the device could not read the file is
  /// the app lying about the rule book.
  Future<List<FamilyGroup>> load({required String locale}) async {
    final Result<List<FamilyGroup>> groups = await ref
        .read(speciesBrowseRepositoryProvider)
        .browseByFamily(locale: locale);
    return switch (groups) {
      Ok<List<FamilyGroup>>(:final List<FamilyGroup> value) => value,
      Failure<List<FamilyGroup>>(:final Exception exception) => throw exception,
    };
  }
}

/// S6's grid.
final AsyncNotifierProvider<SpeciesBrowseViewModel, List<FamilyGroup>>
speciesBrowseViewModelProvider = AsyncNotifierProvider<SpeciesBrowseViewModel, List<FamilyGroup>>(
  SpeciesBrowseViewModel.new,
  isAutoDispose: true,
);
