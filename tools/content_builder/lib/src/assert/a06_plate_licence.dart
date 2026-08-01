import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/model/plate_spec.dart';
import 'package:content_builder/src/model/taxon.dart';

/// A6 — every bundled plate passes the illustrator death-year test.
///
/// `SPEC.md` §8 corrects the first draft in one line: *"pre-1930 = public
/// domain" is the US rule and is the wrong test for every market this app ships
/// to.* Publication date is irrelevant. The term is the longest in the bundle —
/// Spain's TRLPI transitional regime, 80 years *pma* for authors who died before
/// 7 December 1987, which outlives the EU's and Brazil's 70 and the UAE's 50.
///
/// **The build year is input, not `DateTime.now().year`.** A plate that
/// re-clears itself at midnight on 1 January produces a different database from
/// the same corpus with no diff to show for it, and T10 requires a
/// byte-identical rebuild. The audit property `licence-provenance.md` wants — an
/// old `.db` can be checked against the year it was made — survives, because the
/// build date is recorded in `content_meta`.
///
/// **An unattributable plate is deleted, not flagged.** `licence: unknown` and
/// `review: later` are states that ship, and an infringement claim against a
/// fisheries-safety app is the story that ends the project rather than the
/// sprint.
final class PlateLicenceAssertion implements Assertion {
  /// The A6 assertion, testing against [buildYear].
  ///
  /// [buildYear] overrides the corpus's own `--build-date`; when neither is
  /// present A6 **fails** rather than skipping. A licence check that silently
  /// does nothing is worse than one that is not there, because it reports green.
  const PlateLicenceAssertion({this.buildYear});

  /// The year to test against, or `null` to take it from the corpus.
  final int? buildYear;

  @override
  String get id => 'A6';

  @override
  Iterable<Failure> run(ContentSource source) sync* {
    final List<PlateSpec> plates = source.typedRows.whereType<PlateSpec>().toList();
    final int? year = buildYear ?? source.buildDate?.year;

    for (final plate in plates) {
      // Ledger completeness first: a block missing six fields reports six
      // failures, because the author is going to fix all six.
      yield* _ledger(plate);
      if (year == null) {
        yield Failure(
          _id,
          plate.path,
          plate.line,
          'no build year to clear against; pass --build-date',
        );
        continue;
      }
      yield* _clearance(plate, year);
    }

    yield* _speciesReferences(source, plates, year);
  }

  Iterable<Failure> _ledger(PlateSpec plate) sync* {
    // The eleven fields licence-provenance.md requires, less the two the
    // clearance checks own — illustrator and illustrator_death_year — which
    // carry their own messages.
    final missing = <String, Object?>{
      'species_id': plate.speciesId,
      'asset': plate.asset,
      'source_work': plate.sourceWork,
      'source_year': plate.sourceYear,
      'source_url': plate.sourceUrl,
      'licence': plate.licence,
      'cleared_on': plate.clearedOn,
      'cleared_by': plate.clearedBy,
    };
    for (final MapEntry<String, Object?> field in missing.entries) {
      if (field.value == null) {
        yield Failure(_id, plate.path, plate.line, "'${plate.id}' has no ${field.key}");
      }
    }

    if (plate.plateOrigin == null) {
      yield Failure(
        _id,
        plate.path,
        plate.line,
        "'${plate.id}' origin '${plate.origin}' is neither "
        '${PlateOrigin.publicDomain.sql} nor ${PlateOrigin.originated.sql}',
      );
    }
  }

  Iterable<Failure> _clearance(PlateSpec plate, int buildYear) sync* {
    if (plate.illustrator == null || kUnidentified.contains(plate.illustrator!.toLowerCase())) {
      // The message is the instruction. An unidentifiable artist can never be
      // cleared, so there is nothing to wait for.
      yield Failure(_id, plate.path, plate.line, 'illustrator unidentified — DROP the plate');
      return;
    }

    // Commissioned art has no death year to test. The ledger row is still
    // mandatory and _ledger has already checked it.
    if (plate.plateOrigin != PlateOrigin.publicDomain) return;

    if (plate.illustratorDeathYear == null) {
      // An unknown death year is not an early one.
      yield Failure(
        _id,
        plate.path,
        plate.line,
        "'${plate.id}' has an identified illustrator and no death year — DROP the plate",
      );
      return;
    }

    if (!clearToBundle(plate, buildYear)) {
      final int death = plate.illustratorDeathYear!;
      yield Failure(
        _id,
        plate.path,
        plate.line,
        'illustrator d.$death is in term until ${death + termFor(death)} — DROP',
      );
    }
  }

  /// A dropped plate leaves a dangling `species.plate_asset` behind.
  Iterable<Failure> _speciesReferences(
    ContentSource source,
    List<PlateSpec> plates,
    int? buildYear,
  ) sync* {
    final bundled = <String>{
      for (final PlateSpec p in plates)
        if (p.asset != null &&
            (p.plateOrigin == PlateOrigin.originated ||
                (buildYear != null && clearToBundle(p, buildYear))))
          p.asset!,
    };

    for (final SpeciesRow species in source.typedRows.whereType<SpeciesRow>()) {
      final String? asset = species.plateAsset;
      if (asset == null || bundled.contains(asset)) continue;
      yield Failure(
        _id,
        species.path,
        species.line,
        "'${species.id}' names plate_asset '$asset' with no cleared ledger block",
      );
    }
  }

  static const String _id = 'A6';
}

/// `content/ATTRIBUTIONS/plates.md`, generated from the ledger.
///
/// `SPEC.md` §8: every plate's illustrator and death year is recorded and
/// rendered in S17. Generated rather than hand-kept so it cannot drift from the
/// data it describes. E18 assembles the full `ATTRIBUTIONS.md`; this is its
/// plate section.
///
/// Sorted by species then plate id, so two renders of one corpus are
/// byte-identical — the ledger is part of what T10's rebuild produces.
String renderPlateLedger(ContentSource source) {
  final List<PlateSpec> plates = source.typedRows.whereType<PlateSpec>().toList()
    ..sort((PlateSpec a, PlateSpec b) {
      final int bySpecies = (a.speciesId ?? '').compareTo(b.speciesId ?? '');
      return bySpecies != 0 ? bySpecies : a.id.compareTo(b.id);
    });

  final buffer = StringBuffer()
    ..writeln('# Bundled plates')
    ..writeln()
    ..writeln('Generated by `dart run content_builder:build`. Do not edit by hand.')
    ..writeln()
    ..writeln(
      'Every plate is cleared on its illustrator\'s **death year**, against the longest term '
      'among the jurisdictions this app ships into — Spain\'s 80 years *post mortem auctoris* '
      'for authors who died before 7 December 1987. Publication year is evidence about the '
      'artist and is never the test.',
    )
    ..writeln();

  if (plates.isEmpty) {
    buffer.writeln('No plates are bundled.');
    return buffer.toString();
  }

  buffer
    ..writeln('| Plate | Species | Illustrator | Died | Source work | Year | Licence | Cleared |')
    ..writeln('|---|---|---|---|---|---|---|---|');
  for (final p in plates) {
    buffer.writeln(
      '| ${p.id} | ${p.speciesId} | ${p.illustrator} | ${p.illustratorDeathYear ?? '—'} '
      '| ${p.sourceWork} | ${p.sourceYear ?? '—'} | ${p.licence} '
      '| ${p.clearedOn} by ${p.clearedBy} |',
    );
  }
  return buffer.toString();
}
