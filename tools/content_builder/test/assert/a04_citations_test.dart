// A4 and A9 — every citation resolves, carries both dates, and came from the
// gazette.
//
// A4 is the data half of invariant 3. The engine cannot enforce "every result
// carries a citation" against data — it can only refuse to compile a
// `Citation?`. Without A4 the emit step writes a foreign key SQLite happily
// accepts, and the first uncited finding is discovered by an inspector.
//
// retrieved_on is the footnote's claim that a HUMAN opened the gazette that day.
// DateTime.now() records when a machine ran, which is not what the footnote
// says, so the tool must never be able to supply it.

import 'dart:io';

import 'package:content_builder/src/assert/a04_citations.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/provenance/accepted_hosts.dart';
import 'package:test/test.dart';

import '../../testing/fixtures/yaml_fixtures.dart';

const String kCitationsPath = 'content/es-ga/citations.yaml';
final DateTime kBuildDate = DateTime.utc(2026, 8, 14);

ContentSource corpusOf(Map<String, String> files, {DateTime? buildDate}) => ContentSource(
  sources: <YamlSource>[
    for (final MapEntry<String, String> e in files.entries)
      YamlSource.fromString(e.value, displayPath: e.key),
  ],
  failures: const <Failure>[],
  buildDate: buildDate ?? kBuildDate,
  assetsRoot: Directory('app/assets'),
);

List<Failure> a4(Map<String, String> files, {DateTime? buildDate}) =>
    const CitationAssertion().run(corpusOf(files, buildDate: buildDate)).toList();

/// A corpus whose one rule cites the citation block [citations] defines.
List<Failure> a4Citing(String citations, {DateTime? buildDate}) => a4(<String, String>{
  kCitationsPath: citations,
  'content/es-ga/rules.yaml': ruleCiting(),
}, buildDate: buildDate);

void main() {
  group('CitationAssertion', () {
    test("reports A4 when a rule's citation_id resolves to nothing", () {
      // At the RULE's line: the rule row is where the author looks, and the
      // citation they meant may not exist anywhere to point at.
      final List<Failure> failures = a4(<String, String>{
        kCitationsPath: citationsYaml(),
        'content/es-ga/rules.yaml': ruleCiting(citationId: 'es-ga-ghost'),
      });

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A4');
      expect(failures.single.path, 'content/es-ga/rules.yaml');
      expect(failures.single.message, contains('es-ga-ghost'));
    });

    test('reports A4 when a citation has no retrieved_on', () {
      final List<Failure> failures = a4Citing(citationsYaml(retrievedOn: null));

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A4');
      expect(failures.single.path, kCitationsPath);
      expect(failures.single.message, "'$kGaliciaCitationId' has no retrieved_on");
    });

    test('reports A4 when a citation has no published_on', () {
      // The footnote prints both dates; one of them is not optional.
      expect(a4Citing(citationsYaml(publishedOn: null)), hasLength(1));
    });

    test('reports A4 when retrieved_on precedes published_on', () {
      // Nobody read it before it existed. Catches a transposed pair.
      final List<Failure> failures = a4Citing(citationsYaml(retrievedOn: '2011-01-04'));

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('before'));
    });

    test('reports A4 when retrieved_on is after the build date', () {
      // A future retrieval date is a typo or a copied template.
      final List<Failure> failures = a4Citing(citationsYaml(retrievedOn: '2027-01-04'));

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('2026-08-14'));
    });

    test('accepts a retrieved_on on the build date itself', () {
      expect(a4Citing(citationsYaml(retrievedOn: '2026-08-14')), isEmpty);
    });

    test('accepts a complete citation', () {
      expect(a4Citing(citationsYaml()), isEmpty);
    });

    for (final table in const <String>[
      'rule',
      'closed_season',
      'licence_type',
      'gear_rule',
      'penalty',
      'legal_text',
    ]) {
      test('checks citation_id on every referencing table ($table)', () {
        // Six tables carry a citation_id. A check covering only `rule` ships
        // five uncited surfaces.
        final ({String path, String yaml}) row = referencingCitation(table, 'es-ga-ghost');
        final List<Failure> failures = a4(<String, String>{
          kCitationsPath: citationsYaml(),
          row.path: row.yaml,
        });

        expect(failures, hasLength(1), reason: table);
        expect(failures.single.path, row.path);
      });
    }

    for (final table in const <String>[
      'rule',
      'closed_season',
      'licence_type',
      'gear_rule',
      'penalty',
      'legal_text',
    ]) {
      test('accepts a resolved citation_id on $table', () {
        final ({String path, String yaml}) row = referencingCitation(table, kGaliciaCitationId);

        expect(
          a4(<String, String>{kCitationsPath: citationsYaml(), row.path: row.yaml}),
          isEmpty,
          reason: table,
        );
      });
    }

    test('reports A9 when the source_url host is outside the allowlist', () {
      // A third-party abstract is copyrighted, paraphrased, and out of date the
      // moment the gazette amends the article. A paraphrased minimum size is a
      // wrong number that looks entirely plausible in review.
      final List<Failure> failures = a4Citing(
        citationsYaml(sourceUrl: 'https://www.example-ngo.org/galicia-shellfish'),
      );

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A9');
      expect(failures.single.message, contains('example-ngo.org'));
    });

    for (final host in const <String>['xunta.gal', 'www.xunta.gal', 'boe.es']) {
      test('accepts $host for ES-GA', () {
        expect(a4Citing(citationsYaml(sourceUrl: 'https://$host/doc')), isEmpty, reason: host);
      });
    }

    test('reports A9 for a host that merely ends with an accepted name', () {
      // `xunta.gal.example.com` is exactly how a third-party copy of a gazette
      // gets cited, so the match is on a label boundary.
      expect(a4Citing(citationsYaml(sourceUrl: 'https://xunta.gal.example.com/doc')), hasLength(1));
    });

    test("reports A9 when the jurisdiction's licence basis is unverified", () {
      // SPEC.md §8 forbids shipping a state whose provision is unconfirmed. The
      // gate is the data, not a memo.
      final List<Failure> failures = a4(<String, String>{
        'content/ae-rk/citations.yaml': citationsYaml(
          jurisdiction: 'AE-RK',
          sourceUrl: 'https://elaws.moj.gov.ae/md-580-2015',
        ),
      });

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A9');
      expect(failures.single.message, contains('not independently verified'));
    });

    test('reports A9 for a jurisdiction with no allowlist entry at all', () {
      // Silence is not permission. An unlisted jurisdiction is one nobody has
      // checked the copyright position for.
      final List<Failure> failures = a4(<String, String>{
        'content/pt-al/citations.yaml': citationsYaml(
          jurisdiction: 'PT-AL',
          sourceUrl: 'https://dre.pt/doc',
        ),
      });

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('PT-AL'));
    });

    test('reports A9 when a citation has no sha256', () {
      // The digest is what makes "we read this document" checkable later.
      final List<Failure> failures = a4Citing(citationsYaml(sha256: null));

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A9');
      expect(failures.single.message, contains('sha256'));
    });

    test('reports A9 when a citation has no source_url', () {
      expect(a4Citing(citationsYaml(sourceUrl: null)), hasLength(1));
    });

    test('reports A4 and A9 separately on a citation that fails both', () {
      // No early return: an author fixing one defect must not have to run the
      // build again to discover the other.
      final List<Failure> failures = a4Citing(citationsYaml(retrievedOn: null, sha256: null));

      expect(failures.map((Failure f) => f.id), containsAll(<String>['A4', 'A9']));
    });

    test('reports A4 when retrieved_on is not an ISO date', () {
      // The value reaches content_meta and the footnote verbatim. A
      // locale-formatted date there is unparseable for the life of the file.
      final List<Failure> failures = a4Citing(citationsYaml(retrievedOn: '12/08/2026'));

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('12/08/2026'));
    });

    test('ignores a referencing row that carries no citation_id at all', () {
      // A required column missing is A1's failure, at A1's message. Reporting it
      // twice sends the author to the same line for two different reasons.
      expect(
        a4(<String, String>{
          kCitationsPath: citationsYaml(),
          'content/es-ga/rules.yaml': kRuleWithoutCitationYaml,
        }),
        isEmpty,
      );
    });

    test('.id is A4', () {
      expect(const CitationAssertion().id, 'A4');
    });
  });

  group('kAcceptedHosts', () {
    test('marks the UAE licence basis unverified', () {
      // SPEC.md §8: cited but NOT independently verified in this session. It
      // must be confirmed, and an equivalent provision quoted for each further
      // Gulf state, before that state's content ships.
      expect(kAcceptedHosts['AE-RK']!.verified, isFalse);
    });

    test('marks Galicia verified against Art. 13 TRLPI', () {
      expect(kAcceptedHosts['ES-GA']!.verified, isTrue);
      expect(kAcceptedHosts['ES-GA']!.basis, contains('Art. 13'));
    });

    test('accepts a subdomain of an allowed host but not a lookalike', () {
      expect(hostMatches('www.xunta.gal', 'xunta.gal'), isTrue);
      expect(hostMatches('xunta.gal', 'xunta.gal'), isTrue);
      expect(hostMatches('xunta.gal.example.com', 'xunta.gal'), isFalse);
      expect(hostMatches('notxunta.gal', 'xunta.gal'), isFalse);
    });
  });
}
