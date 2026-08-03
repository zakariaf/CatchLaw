import 'package:content_builder/src/assert/a01_row_schema.dart';
import 'package:content_builder/src/assert/a02_locale_coverage.dart';
import 'package:content_builder/src/assert/a03_gender.dart';
import 'package:content_builder/src/assert/a04_citations.dart';
import 'package:content_builder/src/assert/a05_species_assets.dart';
import 'package:content_builder/src/assert/a06_plate_licence.dart';
import 'package:content_builder/src/assert/a08_resolution.dart';
import 'package:content_builder/src/assert/a10_changelog.dart';
import 'package:content_builder/src/assert/a12_authored_dates.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';

/// One of the build assertions.
///
/// Every one of them is fatal. `catchlaw-content-pipeline` rule 2: a non-empty
/// failure list means exit 1 and no `.db` at all — there is no warning tier, no
/// `--force` and no partial emit, because a warning is a broken row that ships
/// and the flag that exists is the flag CI uses at 18:00 on a Friday.
abstract interface class Assertion {
  /// The stable id from
  /// `catchlaw-content-pipeline/references/build-assertions.md`, `A1` … `A12`.
  /// `A11` is reserved by E18/T01 and is not registered here yet.
  String get id;

  /// Every violation in [source], one yield per violation.
  ///
  /// No early return: a row with two problems reports two failures, so one build
  /// round-trip tells the author everything wrong with the corpus.
  Iterable<Failure> run(ContentSource source);
}

/// The assertions this build runs, in the order E04 lands them.
///
/// Each of T02 through T09 adds its own entry, and the epic's definition of
/// done is that all of them are here and all of them are fatal. A12 joined after
/// v1 shipped a `checked_on` nine days in the future; A11 belongs to E18/T01 and
/// lands with the About screen.
const List<Assertion> kAssertions = <Assertion>[
  RowSchemaAssertion(),
  LocaleCoverageAssertion(),
  GenderAssertion(),
  CitationAssertion(),
  SpeciesAssetAssertion(),
  PlateLicenceAssertion(),
  ResolutionAssertion(),
  ChangelogAssertion(),
  AuthoredDateAssertion(),
];

/// Every failure the registered assertions find, sorted by path then line.
List<Failure> runAllAssertions(ContentSource source) =>
    sortedFailures(source.assertions.expand((Assertion a) => a.run(source)));
