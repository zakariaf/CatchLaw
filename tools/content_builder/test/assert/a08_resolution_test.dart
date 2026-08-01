// A8 — the shipped engine resolves the authored grid before it ships.
//
// A1 through A7 each look at one row. Two rows that each validate perfectly can
// still say 380 mm and 400 mm about the same clam on the same bank in the same
// month, and catchlaw-content-pipeline rule 10 states the consequence: the tie
// is broken at sea, offline, in favour of whichever row the query returned
// first.
//
// Two cases here are the ones a naive implementation gets right by accident and
// a careful one gets wrong: an expired rule must PASS (invariant 5), and two
// minima measured by different methods must PASS (they are incomparable, not
// contradictory).

import 'package:content_builder/src/assert/a08_resolution.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/load/yaml_source.dart';
import 'package:content_builder/src/resolve/resolution_grid.dart';
import 'package:content_builder/src/resolve/rule_set_adapter.dart';
import 'package:rule_engine/rule_engine.dart' show Rule, Species, WaterType, Zone;
import 'package:test/test.dart';

final DateTime kOn = DateTime.utc(2026, 8, 14);

/// A daily bag limit, appended to a rule block.
const String kDailyBagLimit =
    '    bag_limit: 5\n    bag_limit_unit: count\n    bag_limit_period: day\n';

/// One authored rule, as a `rules.yaml` block.
String ruleBlock(
  String id, {
  String species = 'venerupis-corrugata',
  String? zone,
  int? minSizeMm,
  String? method,
  bool protected = false,
  String validFrom = '2012-08-01',
  String? validTo,
  String? supersedes,
  String? ackWith,
  bool ackReason = true,
  String citation = 'es-ga-c-001',
}) {
  final b = StringBuffer()
    ..writeln('  - id: $id')
    ..writeln('    jurisdiction_id: ES-GA')
    ..writeln('    species_id: $species')
    ..writeln('    water_type: salt')
    ..writeln('    citation_id: $citation')
    ..writeln("    valid_from: '$validFrom'");
  if (zone != null) b.writeln('    zone_id: $zone');
  if (minSizeMm != null) b.writeln('    min_size_mm: $minSizeMm');
  if (method != null) b.writeln('    measurement_method_id: $method');
  if (protected) b.writeln('    is_protected: true');
  if (validTo != null) b.writeln("    valid_to: '$validTo'");
  if (supersedes != null) b.writeln('    supersedes: $supersedes');
  if (ackWith != null) {
    b
      ..writeln('    ambiguity_ack:')
      ..writeln('      with: $ackWith');
    // Gate check 1 scans *.dart for a *_key reference with no matching
    // content_string definition and finds this one inside a Dart string. A
    // fixture is not shipped content; an ARB value or a real content/ row never
    // carries this token.
    if (ackReason) {
      b.writeln('      reason_key: ambiguity.es_ga.rival_minima'); // content-pipeline-ok
    }
  }
  return b.toString();
}

/// A corpus: one jurisdiction, [zones] zones, [species] species, and [rules].
ContentSource corpus({
  required List<String> rules,
  int species = 1,
  List<({String id, String kind, String? parent})> zones =
      const <({String id, String kind, String? parent})>[
        (id: 'es-ga-rias-baixas', kind: 'region', parent: null),
      ],
  bool freshwater = false,
}) {
  final speciesYaml = StringBuffer('species:\n');
  for (var i = 0; i < species; i++) {
    speciesYaml
      ..writeln('  - id: ${i == 0 ? 'venerupis-corrugata' : 'sp-$i'}')
      ..writeln('    scientific_name: Species $i')
      ..writeln('    family_id: veneridae')
      ..writeln('    taxon_group: bivalve')
      ..writeln('    silhouette_asset: sil/$i.svg');
  }

  final zonesYaml = StringBuffer('zones:\n');
  for (final z in zones) {
    zonesYaml
      ..writeln('  - id: ${z.id}')
      ..writeln('    jurisdiction_id: ES-GA')
      ..writeln('    code: ${z.id}')
      ..writeln('    water_type: salt')
      ..writeln('    zone_kind: ${z.kind}');
    if (z.parent != null) zonesYaml.writeln('    parent_zone_id: ${z.parent}');
  }

  return ContentSource(
    sources: <YamlSource>[
      YamlSource.fromString(
        'jurisdiction:\n  - id: ES-GA\n    code: ES-GA\n    country_iso2: ES\n'
        '    has_saltwater: true\n    has_freshwater: $freshwater\n'
        '    default_locale: gl\n',
        displayPath: 'content/es-ga/jurisdiction.yaml',
      ),
      YamlSource.fromString(speciesYaml.toString(), displayPath: 'content/shared/species.yaml'),
      YamlSource.fromString(zonesYaml.toString(), displayPath: 'content/es-ga/zones.yaml'),
      YamlSource.fromString(
        'citations:\n  - id: es-ga-c-001\n    jurisdiction: ES-GA\n'
        '    instrument: Orde do 27 de xullo de 2012\n    article: Anexo II\n'
        '    published_on: 2012-08-06\n    retrieved_on: 2026-08-12\n'
        '  - id: es-ga-c-002\n    jurisdiction: ES-GA\n'
        '    instrument: Orde do 15 de xuño de 2018\n    article: Anexo I\n'
        '    published_on: 2018-06-20\n    retrieved_on: 2026-08-12\n',
        displayPath: 'content/es-ga/citations.yaml',
      ),
      YamlSource.fromString('rules:\n${rules.join()}', displayPath: 'content/es-ga/rules.yaml'),
    ],
    failures: const <Failure>[],
  );
}

List<Failure> a8(ContentSource source) => ResolutionAssertion(on: kOn).run(source).toList();

void main() {
  group('ResolutionGrid', () {
    test('generates one cell per species, zone, month and water type', () {
      // Two species, two zones plus the jurisdiction as a whole, twelve months,
      // one water type. An off-by-one in the month loop hides a whole closure.
      final ContentSource source = corpus(
        rules: <String>[ruleBlock('r-001')],
        species: 2,
        zones: const <({String id, String kind, String? parent})>[
          (id: 'z-1', kind: 'region', parent: null),
          (id: 'z-2', kind: 'bank', parent: 'z-1'),
        ],
      );
      final Map<({Species species, WaterType waterType}), List<GridCell>> grid = ResolutionGrid.of(
        source,
        RuleSetAdapter.of(source),
      );

      expect(grid.values.expand((List<GridCell> c) => c), hasLength(2 * 3 * 12));
    });

    test('includes only the water types the jurisdiction declares', () {
      // Galicia declares saltwater. Generating freshwater cells would report
      // NoRuleFound for every one of them and bury the real failures.
      final ContentSource source = corpus(rules: <String>[ruleBlock('r-001')]);
      final Map<({Species species, WaterType waterType}), List<GridCell>> grid = ResolutionGrid.of(
        source,
        RuleSetAdapter.of(source),
      );

      expect(
        grid.keys.map((({Species species, WaterType waterType}) k) => k.waterType),
        <WaterType>[WaterType.salt],
      );
    });

    test('includes fresh cells when the jurisdiction declares fresh water', () {
      final ContentSource source = corpus(rules: <String>[ruleBlock('r-001')], freshwater: true);
      final Map<({Species species, WaterType waterType}), List<GridCell>> grid = ResolutionGrid.of(
        source,
        RuleSetAdapter.of(source),
      );

      expect(
        grid.keys.map((({Species species, WaterType waterType}) k) => k.waterType),
        <WaterType>[WaterType.salt, WaterType.fresh],
      );
    });

    test('materialises a zone path through its parent chain', () {
      final ContentSource source = corpus(
        rules: <String>[ruleBlock('r-001')],
        zones: const <({String id, String kind, String? parent})>[
          (id: 'z-1', kind: 'region', parent: null),
          (id: 'z-2', kind: 'bank', parent: 'z-1'),
        ],
      );
      final adapter = RuleSetAdapter.of(source);

      expect(adapter.zonePathOf('z-2').map((Zone z) => z.code), <String>['z-2', 'z-1']);
    });
  });

  group('ResolutionAssertion', () {
    test('reports A8 when two rules at equal specificity disagree', () {
      // The headline contradiction class.
      final List<Failure> failures = a8(
        corpus(
          rules: <String>[
            ruleBlock('r-001', minSizeMm: 380, method: 'SHL', citation: 'es-ga-c-001'),
            ruleBlock('r-002', minSizeMm: 400, method: 'SHL', citation: 'es-ga-c-002'),
          ],
        ),
      );

      expect(failures, hasLength(1));
      expect(failures.single.id, 'A8');
      expect(failures.single.message, allOf(contains('r-001'), contains('r-002')));
    });

    test('accepts an ambiguity carrying ambiguity_ack on both rules', () {
      // D4 must remain reachable: §7.3 step 4 requires both instruments to be
      // renderable when they genuinely disagree.
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock(
                'r-001',
                minSizeMm: 380,
                method: 'SHL',
                citation: 'es-ga-c-001',
                ackWith: 'r-002',
              ),
              ruleBlock(
                'r-002',
                minSizeMm: 400,
                method: 'SHL',
                citation: 'es-ga-c-002',
                ackWith: 'r-001',
              ),
            ],
          ),
        ),
        isEmpty,
      );
    });

    test('reports A8 when ambiguity_ack names only one of the pair', () {
      // A half-acknowledged pair is an author who stopped halfway, and D4 would
      // render one citation where the law offers two.
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock(
                'r-001',
                minSizeMm: 380,
                method: 'SHL',
                citation: 'es-ga-c-001',
                ackWith: 'r-002',
              ),
              ruleBlock('r-002', minSizeMm: 400, method: 'SHL', citation: 'es-ga-c-002'),
            ],
          ),
        ),
        hasLength(1),
      );
    });

    test('accepts a superseded pair', () {
      // build-assertions.md's prescribed fix must actually work. It is
      // implemented as a shared citation lineage, so §7.3's own collapse
      // resolves it rather than a second precedence rule here.
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock('r-001', minSizeMm: 380, method: 'SHL', citation: 'es-ga-c-001'),
              ruleBlock(
                'r-002',
                minSizeMm: 400,
                method: 'SHL',
                citation: 'es-ga-c-002',
                validFrom: '2018-06-20',
                supersedes: 'r-001',
              ),
            ],
          ),
        ),
        isEmpty,
      );
    });

    test('accepts two rules at different specificity', () {
      // The ladder resolves it. A check that flagged this would fail every real
      // jurisdiction, because that is what a bank-level exception IS.
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock('r-001', minSizeMm: 380, method: 'SHL', zone: 'z-1'),
              ruleBlock(
                'r-002',
                minSizeMm: 400,
                method: 'SHL',
                zone: 'z-2',
                citation: 'es-ga-c-002',
              ),
            ],
            zones: const <({String id, String kind, String? parent})>[
              (id: 'z-1', kind: 'region', parent: null),
              (id: 'z-2', kind: 'bank', parent: 'z-1'),
            ],
          ),
        ),
        isEmpty,
      );
    });

    test('accepts a rule whose valid_to is in the past', () {
      // INVARIANT 5, and the Galician orde de vedas hazard verbatim: the order
      // is reissued annually and typically lapses on 30 April. A build that
      // failed here would make the corpus unshippable until somebody deleted
      // the rows.
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock('r-001', minSizeMm: 380, method: 'SHL', validTo: '2026-04-30'),
            ],
          ),
        ),
        isEmpty,
      );
    });

    test('accepts two minima measured by different methods', () {
      // Legal and incomparable: both must be shown. This is exactly the shape a
      // naive contradiction check flags.
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock('r-001', minSizeMm: 450, method: 'TL', citation: 'es-ga-c-001'),
              ruleBlock('r-002', minSizeMm: 400, method: 'FL', citation: 'es-ga-c-002'),
            ],
          ),
        ),
        isEmpty,
      );
    });

    test('reports A8 when a rule zone_id is in no jurisdiction', () {
      // The rule is unreachable, and the species reports "no rule recorded" in
      // the field.
      final List<Failure> failures = a8(
        corpus(
          rules: <String>[ruleBlock('r-001', minSizeMm: 380, method: 'SHL', zone: 'z-ghost')],
        ),
      );

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('r-001'));
      expect(failures.single.path, 'content/es-ga/rules.yaml');
    });

    test('reports A8 when an authored rule never resolves in any cell', () {
      // A rule nobody can reach is indistinguishable from a rule nobody wrote.
      final List<Failure> failures = a8(
        corpus(
          rules: <String>[
            ruleBlock('r-001', minSizeMm: 380, method: 'SHL'),
            ruleBlock('r-002', minSizeMm: 400, method: 'SHL', validFrom: '2099-01-01'),
          ],
        ),
      );

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('r-002'));
    });

    test('accepts a corpus with no rules at all', () {
      expect(a8(corpus(rules: const <String>[])), isEmpty);
    });

    test('collects candidate rows once per species and water type', () {
      // The structural budget. §13's per-evaluation cost must not be multiplied
      // by the whole grid, and a timing test on CI is a flake — a flake in a
      // fatal assertion gets disabled.
      final ContentSource source = corpus(
        rules: <String>[
          ruleBlock('r-001', minSizeMm: 380, method: 'SHL'),
          ruleBlock('r-002', species: 'sp-1', minSizeMm: 380, method: 'SHL'),
          ruleBlock('r-003', species: 'sp-2', minSizeMm: 380, method: 'SHL'),
        ],
        species: 3,
        zones: <({String id, String kind, String? parent})>[
          for (var i = 0; i < 20; i++) (id: 'z-$i', kind: 'region', parent: null),
        ],
      );
      final counting = RuleSetAdapter.of(source);

      for (final MapEntry<({Species species, WaterType waterType}), List<GridCell>> group
          in ResolutionGrid.of(source, counting).entries) {
        counting.collect(group.key.species.id, group.key.waterType);
      }

      expect(counting.collectCalls, 3);
    });

    test('reports the resolved cell count', () {
      // The number is measured and printed, never claimed.
      a8(corpus(rules: <String>[ruleBlock('r-001', minSizeMm: 380, method: 'SHL')]));

      expect(
        ResolutionAssertion.lastReport?.cells,
        2 * 12,
        reason: 'one zone plus jurisdiction-wide',
      );
      expect(ResolutionAssertion.lastReport?.rules, 1);
    });

    test('reports A8 when there is no date to resolve at', () {
      final List<Failure> failures = const ResolutionAssertion()
          .run(corpus(rules: <String>[ruleBlock('r-001')]))
          .toList();

      expect(failures, hasLength(1));
      expect(failures.single.message, contains('--build-date'));
    });

    test('takes the date from the corpus when none was given', () {
      final source = ContentSource(
        sources: corpus(rules: <String>[ruleBlock('r-001', minSizeMm: 380, method: 'SHL')]).sources,
        failures: const <Failure>[],
        buildDate: kOn,
      );

      expect(const ResolutionAssertion().run(source), isEmpty);
    });

    test('reports A8 when a protected species also carries a size rule', () {
      // Protected admits no threshold. The ladder headlines `protected`, the
      // size would never be read, and its number is uncheckable. Two rows that
      // each pass A1 can still say this between them.
      final List<Failure> failures = a8(
        corpus(
          rules: <String>[
            ruleBlock('r-001', protected: true),
            ruleBlock('r-002', minSizeMm: 380, method: 'SHL', zone: 'z-2', citation: 'es-ga-c-002'),
          ],
          zones: const <({String id, String kind, String? parent})>[
            (id: 'z-1', kind: 'region', parent: null),
            (id: 'z-2', kind: 'bank', parent: 'z-1'),
          ],
        ),
      );

      expect(failures.where((Failure f) => f.message.contains('protects')), isNotEmpty);
    });

    test('skips a species that no rule mentions', () {
      // Two species, one rule. The second species has no candidates at all and
      // its cells are not worth resolving.
      expect(
        a8(corpus(rules: <String>[ruleBlock('r-001', minSizeMm: 380, method: 'SHL')], species: 2)),
        isEmpty,
      );
    });

    test('reports A8 once when the engine rejects a malformed rule', () {
      // A measurement method with nothing to measure. It reaches the engine as
      // a Result error, and reporting it per cell would print it 24 times.
      final List<Failure> failures = a8(corpus(rules: <String>[ruleBlock('r-001', method: 'SHL')]));

      expect(failures.where((Failure f) => f.message.contains('MalformedRule')), hasLength(1));
    });

    test('reports A8 for two rules whose methods differ and whose limits also differ', () {
      // Different methods are not a licence for a second disagreement. The
      // incomparable-minima exemption is narrow on purpose.
      final List<Failure> failures = a8(
        corpus(
          rules: <String>[
            ruleBlock('r-001', minSizeMm: 450, method: 'TL', citation: 'es-ga-c-001') +
                kDailyBagLimit,
            ruleBlock('r-002', minSizeMm: 400, method: 'FL', citation: 'es-ga-c-002'),
          ],
        ),
      );

      expect(failures, hasLength(1));
    });

    test('reports A8 for two rules that share a measurement method', () {
      // Same method, different minima: a contradiction, not two measurements.
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock('r-001', minSizeMm: 450, method: 'TL', citation: 'es-ga-c-001'),
              ruleBlock('r-002', minSizeMm: 400, method: 'TL', citation: 'es-ga-c-002'),
            ],
          ),
        ),
        hasLength(1),
      );
    });

    test('reports A8 when a rule acknowledges itself', () {
      // A self-acknowledgement satisfies "both rules carry one" and says
      // nothing about the disagreement.
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock(
                'r-001',
                minSizeMm: 380,
                method: 'SHL',
                citation: 'es-ga-c-001',
                ackWith: 'r-001',
              ),
              ruleBlock(
                'r-002',
                minSizeMm: 400,
                method: 'SHL',
                citation: 'es-ga-c-002',
                ackWith: 'r-001',
              ),
            ],
          ),
        ),
        hasLength(1),
      );
    });

    test('reports A8 when a rule acknowledges one outside the conflicting pair', () {
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock(
                'r-001',
                minSizeMm: 380,
                method: 'SHL',
                citation: 'es-ga-c-001',
                ackWith: 'r-099',
              ),
              ruleBlock(
                'r-002',
                minSizeMm: 400,
                method: 'SHL',
                citation: 'es-ga-c-002',
                ackWith: 'r-001',
              ),
            ],
          ),
        ),
        hasLength(1),
      );
    });

    test('reports A8 when an acknowledgement carries no reason key', () {
      // The reason key is what D4 renders. Without it the fisher sees two
      // citations and a blank line between them.
      expect(
        a8(
          corpus(
            rules: <String>[
              ruleBlock(
                'r-001',
                minSizeMm: 380,
                method: 'SHL',
                citation: 'es-ga-c-001',
                ackWith: 'r-002',
                ackReason: false,
              ),
              ruleBlock(
                'r-002',
                minSizeMm: 400,
                method: 'SHL',
                citation: 'es-ga-c-002',
                ackWith: 'r-001',
              ),
            ],
          ),
        ),
        hasLength(1),
      );
    });

    test('.id is A8', () {
      expect(const ResolutionAssertion().id, 'A8');
    });
  });

  group('RuleSetAdapter', () {
    test('passes plain Dart records to the engine', () {
      // The engine must stay constructible from a fixture without opening a
      // database. Nothing here may carry a SQLite or drift type.
      final adapter = RuleSetAdapter.of(
        corpus(rules: <String>[ruleBlock('r-001', minSizeMm: 380, method: 'SHL')]),
      );

      expect(adapter.rules.single, isA<Rule>());
      expect(adapter.rules.single.minSizeMm, 380);
      expect(adapter.ruleIdOf[adapter.rules.single.id], 'r-001');
    });

    test('numbers ids by sorted authored id, so two runs agree', () {
      // A hash-order id would make the grid, its failure messages and T10's
      // rebuild all non-reproducible.
      final ContentSource source = corpus(rules: <String>[ruleBlock('r-002'), ruleBlock('r-001')]);

      expect(RuleSetAdapter.of(source).ruleIdOf, <int, String>{1: 'r-001', 2: 'r-002'});
    });
  });
}
