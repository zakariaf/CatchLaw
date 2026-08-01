import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/model/regulation.dart';
import 'package:content_builder/src/provenance/accepted_hosts.dart';
import 'package:rule_engine/rule_engine.dart' show parseIsoDate;

/// A4 and A9 — every citation resolves, carries both dates, and came from the
/// gazette.
///
/// **A4 is what makes invariant 3 representable.** `CONVENTIONS.md` §9
/// invariant 3 and `catchlaw-rule-engine` rule 9 require a non-nullable
/// `Citation` on every finding. The engine cannot enforce that against data — it
/// can only refuse to compile a `Citation?`. Without A4 the emit step writes a
/// foreign key SQLite happily accepts, and the first uncited finding is
/// discovered by an inspector.
///
/// **`retrieved_on` is authored, and the tool must never be able to supply it.**
/// The footnote on the result screen claims a human opened the gazette on that
/// date. `DateTime.now()` records when a machine ran. Two further checks make
/// the date mean something: it may not precede `published_on` — you cannot have
/// read it before it existed — and may not follow `--build-date`.
///
/// **A9 ships here because the two fail together.** A third-party abstract is
/// copyrighted, paraphrased, and out of date the moment the gazette amends the
/// article; a paraphrased minimum size is a wrong number that looks entirely
/// plausible in review.
final class CitationAssertion implements Assertion {
  /// The A4 assertion, which also carries A9.
  const CitationAssertion();

  @override
  String get id => 'A4';

  /// Every `SPEC.md` §7.1 section carrying a `citation_id` column.
  ///
  /// Six of them. A check covering only `rules` ships five uncited surfaces.
  static const List<String> referencingSections = <String>[
    'rules',
    'closed_seasons',
    'licence_types',
    'gear_rules',
    'penalties',
    'legal_texts',
  ];

  @override
  Iterable<Failure> run(ContentSource source) sync* {
    final citations = <String, CitationRow>{
      for (final CitationRow c in source.typedRows.whereType<CitationRow>()) c.id: c,
    };

    for (final CitationRow citation in citations.values) {
      yield* _complete(citation, source.buildDate);
      yield* _provenance(citation);
    }

    for (final String section in referencingSections) {
      for (final YamlRow row in source.section(section)) {
        final String? id = row.string('citation_id');
        if (id == null) continue; // a required column is A1's, not A4's
        if (!citations.containsKey(id)) {
          // At the REFERENCING row: the citation the author meant may not exist
          // anywhere to point at.
          yield Failure(_a4, row.path, row.line, "citation '$id' does not resolve");
        }
      }
    }
  }

  Iterable<Failure> _complete(CitationRow citation, DateTime? buildDate) sync* {
    if (citation.publishedOn == null) {
      // The footnote prints both dates; one of them is not optional.
      yield Failure(_a4, citation.path, citation.line, "'${citation.id}' has no published_on");
    }
    if (citation.retrievedOn == null) {
      yield Failure(_a4, citation.path, citation.line, "'${citation.id}' has no retrieved_on");
      return;
    }

    final DateTime? retrieved = _date(citation.retrievedOn!);
    if (retrieved == null) {
      yield Failure(
        _a4,
        citation.path,
        citation.line,
        "'${citation.id}' retrieved_on '${citation.retrievedOn}' is not an ISO date",
      );
      return;
    }

    final DateTime? published = citation.publishedOn == null ? null : _date(citation.publishedOn!);
    if (published != null && retrieved.isBefore(published)) {
      // A transposed pair, always.
      yield Failure(
        _a4,
        citation.path,
        citation.line,
        "'${citation.id}' was retrieved ${citation.retrievedOn}, before it was "
        'published ${citation.publishedOn}',
      );
    }

    if (buildDate != null && retrieved.isAfter(buildDate)) {
      // A future retrieval date is a typo or a copied template.
      yield Failure(
        _a4,
        citation.path,
        citation.line,
        "'${citation.id}' was retrieved ${citation.retrievedOn}, after the build "
        'date ${_iso(buildDate)}',
      );
    }
  }

  Iterable<Failure> _provenance(CitationRow citation) sync* {
    final String jurisdiction = citation.jurisdictionId ?? '';
    final JurisdictionProvenance? provenance = kAcceptedHosts[jurisdiction];

    if (provenance == null) {
      // Silence is not permission. An unlisted jurisdiction is one nobody has
      // checked the copyright position for.
      yield Failure(
        _a9,
        citation.path,
        citation.line,
        "jurisdiction '$jurisdiction' has no recorded licence basis",
      );
      return;
    }

    if (!provenance.verified) {
      // SPEC.md §8 forbids shipping a state whose provision is unconfirmed. The
      // gate is the data, not a memo.
      yield Failure(
        _a9,
        citation.path,
        citation.line,
        "'$jurisdiction' licence basis is cited but not independently verified: ${provenance.basis}",
      );
    }

    if (citation.sha256 == null) {
      // The digest is what makes "we read this document" checkable later.
      yield Failure(_a9, citation.path, citation.line, "'${citation.id}' has no sha256");
    }

    if (citation.sourceUrl == null) {
      yield Failure(_a9, citation.path, citation.line, "'${citation.id}' has no source_url");
      return;
    }

    final String host = Uri.tryParse(citation.sourceUrl!)?.host ?? '';
    if (!provenance.hosts.any((String accepted) => hostMatches(host, accepted))) {
      yield Failure(
        _a9,
        citation.path,
        citation.line,
        "source_url host '$host' is not an official gazette for $jurisdiction "
        '(${provenance.hosts.join(', ')})',
      );
    }
  }

  static DateTime? _date(String value) {
    try {
      return parseIsoDate(value);
    } on FormatException {
      return null;
    }
  }

  static String _iso(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static const String _a4 = 'A4';
  static const String _a9 = 'A9';
}
