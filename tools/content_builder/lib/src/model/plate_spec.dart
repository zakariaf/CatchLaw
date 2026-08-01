import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/content_row.dart';

/// Where a plate came from, and therefore which test clears it.
enum PlateOrigin {
  /// Out of copyright everywhere the app ships, tested on the illustrator's
  /// death year.
  publicDomain('public_domain'),

  /// Commissioned for this app. There is no death year to test, and the ledger
  /// row is still mandatory — S17 renders the whole ledger.
  originated('originated');

  const PlateOrigin(this.sql);

  /// The spelling `plates.yaml` authors.
  final String sql;

  /// The origin spelt [value], or `null`.
  static PlateOrigin? fromSql(String? value) {
    for (final PlateOrigin origin in values) {
      if (origin.sql == value) return origin;
    }
    return null;
  }
}

/// One block of `content/shared/plates.yaml`: the licence ledger behind
/// `species.plate_asset`.
///
/// **Not a `SPEC.md` §7.1 table.** It is the evidence A6 tests and E18 renders
/// in S17, and it stays out of the database because a licence claim belongs in
/// the attribution page rather than in a column nobody reads.
///
/// Every field is nullable at parse time so A6 can report *which* one is
/// missing. A throwing constructor would report the first and hide the other
/// five, and the author is going to fix all six.
class PlateSpec extends ContentRow {
  /// A plate read from [path] at [line].
  const PlateSpec({
    required super.path,
    required super.line,
    required super.id,
    required this.speciesId,
    required this.asset,
    this.origin,
    this.illustrator,
    this.illustratorDeathYear,
    this.sourceWork,
    this.sourceYear,
    this.sourceUrl,
    this.licence,
    this.clearedOn,
    this.clearedBy,
  });

  /// Reads a plate from [row].
  factory PlateSpec.fromRow(YamlRow row) => PlateSpec(
    path: row.path,
    line: row.line,
    id: row.id,
    speciesId: row.string('species_id'),
    asset: row.string('asset'),
    origin: row.string('origin'),
    illustrator: row.string('illustrator'),
    illustratorDeathYear: row.integer('illustrator_death_year'),
    sourceWork: row.string('source_work'),
    sourceYear: row.integer('source_year'),
    sourceUrl: row.string('source_url'),
    licence: row.string('licence'),
    clearedOn: row.string('cleared_on'),
    clearedBy: row.string('cleared_by'),
  );

  /// The species the plate depicts.
  final String? speciesId;

  /// The bundled asset path.
  final String? asset;

  /// `public_domain` or `originated`, as authored.
  final String? origin;

  /// The artist.
  ///
  /// A6 drops a plate with no identified illustrator — not `licence: unknown`,
  /// not `review: later`. A pending state ships.
  final String? illustrator;

  /// The year the artist died.
  ///
  /// The test counts from this and never from the publication year. An unknown
  /// death year is not an early one, so its absence is a drop rather than a
  /// pass.
  final int? illustratorDeathYear;

  /// The work the plate was scanned from.
  final String? sourceWork;

  /// The year that work was published.
  ///
  /// **Evidence about the artist, never the test.** "Published before 1930,
  /// therefore public domain" is the US rule and clears nothing in Spain,
  /// Brazil or the UAE.
  final int? sourceYear;

  /// Where the scan came from.
  final String? sourceUrl;

  /// The licence relied on, or the work-for-hire agreement id for originated
  /// art.
  final String? licence;

  /// When the clearance was made.
  final String? clearedOn;

  /// Who made it. S17 renders it, so an anonymous clearance is not a clearance.
  final String? clearedBy;

  /// The parsed [origin], or `null` when it is absent or unrecognised.
  PlateOrigin? get plateOrigin => PlateOrigin.fromSql(origin);

  @override
  Map<String, String?> get keyColumns => const <String, String?>{};
}

/// The copyright term that applies to a work by an author who died in
/// [deathYear], in years.
///
/// The longest among the jurisdictions in the bundle. Spain's TRLPI
/// transitional regime gives **80 years** *post mortem auctoris* to authors who
/// died before 7 December 1987, which outlives the EU's and Brazil's 70 and the
/// UAE's 50.
int termFor(int deathYear) => deathYear <= 1987 ? 80 : 70;

/// Whether [plate] may be bundled in a build made in [buildYear].
///
/// For a 2026 build the illustrator must have died in **1945 or earlier**:
/// 1945 + 80 = 2025 and 2026 > 2025 clears, while 1946 + 80 = 2026 and
/// 2026 > 2026 does not. The comparison is strictly greater, and a `>=` here
/// would ship every plate a year early.
///
/// It ratchets: a 2027 build clears 1946 with no code change, because the year
/// is input rather than a clock reading.
bool clearToBundle(PlateSpec plate, int buildYear) =>
    plate.illustrator != null &&
    !kUnidentified.contains(plate.illustrator!.toLowerCase()) &&
    plate.illustratorDeathYear != null &&
    buildYear > plate.illustratorDeathYear! + termFor(plate.illustratorDeathYear!);

/// The literal strings that mean "nobody knows who drew this".
///
/// The same three `check_content_pipeline.sh` check 3 looks for, so the build is
/// never laxer than the grep.
const Set<String> kUnidentified = <String>{'unknown', 'unidentified', 'tbd'};
