// A12 — every authored date is one a human could have established.
//
// A4 already holds the citation pair: `retrieved_on` must parse, must not
// precede `published_on`, and must not follow the build date. Every OTHER
// authored date had no check at all, and the corpus shipped proving it —
// `jurisdiction.checked_on: '2026-08-12'` against an 2026-08-03 build, a claim
// that a human read the Orde nine days from now.
//
// That date is not decorative. `checked_on` is what the Check screen prints
// under the place ("checked 2026-08-12"), and it is the fisher's only handle on
// whether the rule book is current. A future date there says the book was
// verified more recently than it can have been, which is the one direction the
// error must never point: it reads as fresher than it is.
//
// Two classes of date, deliberately treated differently. A date recording a
// HUMAN ACT — checked, changed, published — cannot be in the future, because
// the act has not happened. A date stating an INSTRUMENT'S REACH — valid_from,
// valid_to — routinely is: a closure authored in July that bites in September is
// correct data, and A5 of the ruler would be the wrong place to reject it. So
// the future check applies to the first class only, and the second gets order
// and format instead.

import 'dart:io';

import 'package:content_builder/src/assert/a12_authored_dates.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:test/test.dart';

const String kJurisdictionPath = 'content/es-ga/jurisdiction.yaml';
const String kChangesPath = 'content/es-ga/changes.yaml';
const String kRulesPath = 'content/es-ga/rules.yaml';

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

List<Failure> a12(Map<String, String> files, {DateTime? buildDate}) =>
    const AuthoredDateAssertion().run(corpusOf(files, buildDate: buildDate)).toList();

/// A jurisdiction block carrying [published] and [checked].
///
/// The `*_key` values carry the gate's own escape hatch, the way
/// `yaml_fixtures.dart` does: `check_content_pipeline.sh` reads every `*_key` in
/// the tree and demands a matching `content_string` row, which a single-file
/// fixture deliberately does not ship. A2 is what proves those keys resolve, and
/// it proves it over the real corpus rather than over a date fixture.
String jurisdictionDated({String published = '2012-07-27', String checked = '2026-08-01'}) =>
    '''
jurisdiction:
  - id: ES-GA
    country_iso2: ES
    name_key: jurisdiction.es_ga.name  # content-pipeline-ok
    published_on: '$published'
    checked_on: '$checked'
''';

/// A change entry stamped [changedOn].
String changeDated(String changedOn) =>
    '''
changes:
  - id: es-ga-ch-1
    jurisdiction_id: ES-GA
    from_version: ''
    to_version: '2026.08.0'
    summary_key: change.es_ga.first_pack  # content-pipeline-ok
    changed_on: '$changedOn'
''';

/// A rule row whose window runs [from] to [to].
String ruleDated({String from = '2012-11-27', String? to}) =>
    '''
rules:
  - id: es-ga-r1
    jurisdiction_id: ES-GA
    species_id: venerupis-corrugata
    water_type: salt
    citation_id: es-ga-orde-2012-art6
    valid_from: '$from'
${to == null ? '' : "    valid_to: '$to'\n"}''';

void main() {
  group('AuthoredDateAssertion', () {
    test('reports A12 when checked_on follows the build date', () {
      // The shipped defect. The Check screen prints this value under the place,
      // so a future date claims the book is fresher than it can be.
      final List<Failure> failures = a12(<String, String>{
        kJurisdictionPath: jurisdictionDated(checked: '2026-08-22'),
      });

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A12');
      expect(failures.single.path, kJurisdictionPath);
      expect(failures.single.message, contains('checked_on'));
      expect(failures.single.message, contains('2026-08-22'));
    });

    test('accepts checked_on on the build date itself', () {
      // A pack built the same day it was checked is the normal case, not an
      // edge one. An exclusive comparison would fail every same-day build.
      expect(
        a12(<String, String>{kJurisdictionPath: jurisdictionDated(checked: '2026-08-14')}),
        isEmpty,
      );
    });

    test('reports A12 when checked_on precedes published_on', () {
      // You cannot have read the text before it existed. A transposed pair,
      // always — and it survives the future check because both dates are past.
      final List<Failure> failures = a12(<String, String>{
        kJurisdictionPath: jurisdictionDated(published: '2012-07-27', checked: '2011-01-05'),
      });

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('precedes'));
    });

    test('reports A12 when published_on follows the build date', () {
      // An instrument published in the future is a typo in a year, and it is the
      // typo that puts a repealed order back in force.
      final List<Failure> failures = a12(<String, String>{
        kJurisdictionPath: jurisdictionDated(published: '2027-01-01', checked: '2026-08-01'),
      });

      expect(failures.map((Failure f) => f.message), anyElement(contains('published_on')));
    });

    test('reports A12 when changed_on follows the build date', () {
      // The changelog's stamp is what §4.7 shows as "what changed and when". A
      // future entry sorts to the top of a list the fisher reads as history.
      final List<Failure> failures = a12(<String, String>{kChangesPath: changeDated('2026-09-01')});

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('changed_on'));
    });

    test('accepts valid_from in the future', () {
      // The deliberate exemption. A closure authored in July that bites in
      // September is correct data; rejecting it would make the corpus unable to
      // state a season before it starts, which is the whole point of a season.
      expect(a12(<String, String>{kRulesPath: ruleDated(from: '2027-03-01')}), isEmpty);
    });

    test('accepts valid_to in the future', () {
      expect(
        a12(<String, String>{kRulesPath: ruleDated(from: '2026-01-01', to: '2030-12-31')}),
        isEmpty,
      );
    });

    test('reports A12 when valid_to precedes valid_from', () {
      // A window that closes before it opens matches no date at all, so the rule
      // is silently never evaluated — an absence that reads as "no rule
      // recorded", which is a permission the instrument never gave.
      final List<Failure> failures = a12(<String, String>{
        kRulesPath: ruleDated(from: '2026-06-01', to: '2026-01-01'),
      });

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('valid_to'));
    });

    test('reports A12 when an authored date is not an ISO date', () {
      // '27/07/2012' is the format the DOG prints, and it is the format an
      // author copies. Parsed as ISO it is not a date at all.
      final List<Failure> failures = a12(<String, String>{
        kJurisdictionPath: jurisdictionDated(checked: '12/08/2026'),
      });

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('not an ISO date'));
    });

    test('reports every violating date rather than the first', () {
      // Rule: no early return. One build round-trip tells the author everything
      // wrong with the corpus, because the second round-trip is the one nobody
      // runs before the release.
      final List<Failure> failures = a12(<String, String>{
        kJurisdictionPath: jurisdictionDated(published: '2027-01-01', checked: '2027-06-01'),
        kChangesPath: changeDated('2026-09-01'),
      });

      expect(failures.length, greaterThanOrEqualTo(3));
    });

    test('reports nothing for a corpus whose dates are all past and ordered', () {
      expect(
        a12(<String, String>{
          kJurisdictionPath: jurisdictionDated(),
          kChangesPath: changeDated('2026-08-01'),
          kRulesPath: ruleDated(),
        }),
        isEmpty,
      );
    });

    test('reports nothing when a date is absent', () {
      // Presence is A1's job, not A12's. Two assertions firing on one missing
      // field makes the failure list twice as long and no more informative.
      expect(a12(<String, String>{kJurisdictionPath: 'jurisdiction:\n  - id: ES-GA\n'}), isEmpty);
    });
  });
}
