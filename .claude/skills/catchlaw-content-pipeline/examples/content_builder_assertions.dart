// Demonstrates the CatchLaw content build's assertion pass: a Failure carrying a stable A-id,
// the required-when check that binds min_size to measurement_method, locale coverage across all
// six locales with no fallback, the gendered-locale gender check, the citation retrieved_on
// check, the illustrator DEATH-YEAR test (not the US publication-date test), normalisation
// parity against the shared normalise(), the contradiction pass that runs the SHIPPED rule
// engine over the authored grid, and a main() that writes NOTHING when anything failed.
//
// Conceptually compiles against package:catchlaw_shared and package:catchlaw_rule_engine, pub
// workspace siblings of tools/content_builder. normalise() is IMPORTED, never redefined.

import 'dart:io';
import 'package:catchlaw_rule_engine/rule_engine.dart';
import 'package:catchlaw_shared/text/normalise.dart' show normalise;
import 'package:meta/meta.dart';

/// The six shipped locales. There is no fallback chain to `en`.
const kShippedLocales = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR'];

/// Every locale except `en` marks grammatical gender on a species name.
const kGenderedLocales = <String>{'ar', 'es', 'gl', 'ca', 'pt_BR'};

/// One line of build output. `id` is the stable assertion id from build-assertions.md.
@immutable
class Failure {
  const Failure(this.id, this.file, this.line, this.message);
  final String id, file, message;
  final int line;
  String render() => '$id $file:$line $message';
}

/// A1 — a nullable method is how a 65 cm FORK-length Kanaad becomes a 65 cm TOTAL-length one.
Iterable<Failure> assertSizeHasMethod(YamlDoc rules) sync* {
  for (final row in rows(rules)) {
    final hasSize = row.has('min_size') || row.has('max_size');
    if (hasSize && !row.has('measurement_method')) {
      yield Failure('A1', rules.path, row.line, 'min_size without measurement_method');
    }
    if (row.value('kind') == 'protected' && hasSize) {
      yield Failure('A1', rules.path, row.line, 'protected row carries a size threshold');
    }
  }
}

/// A2 — every `*_key` resolves for EVERY locale; a blank line under the stamp is not a verdict.
Iterable<Failure> assertLocaleCoverage(ContentSource src) sync* {
  for (final ref in src.keyReferences) {
    final missing = kShippedLocales.where((l) => !src.hasString(ref.key, l)).toList();
    if (missing.isNotEmpty) {
      yield Failure('A2', ref.file, ref.line, "key '${ref.key}' missing for ${missing.join(', ')}");
    }
  }
}

/// A3 — "la mero" instead of "el mero" is how a printed instrument stops being believed.
Iterable<Failure> assertGender(ContentSource src) sync* {
  for (final name in src.speciesNames) {
    if (kGenderedLocales.contains(name.locale) && name.gender == null) {
      yield Failure('A3', name.file, name.line, 'gender null for locale ${name.locale}');
    }
  }
}

/// A4 — retrieved_on claims a HUMAN opened the gazette that day. Authored, never DateTime.now().
Iterable<Failure> assertCitations(ContentSource src) sync* {
  for (final rule in src.rules) {
    final citation = src.citation(rule.citationId);
    if (citation == null) {
      yield Failure('A4', rule.file, rule.line, "citation '${rule.citationId}' does not resolve");
    } else if (citation.retrievedOn == null) {
      yield Failure('A4', citation.file, citation.line,
          "'${citation.id}' has no retrieved_on"); // e.g. ae-md-580-2015-art3
    }
  }
}

/// A6 — the illustrator death-year test. "Pre-1930 is public domain" is the US rule and clears
/// nothing in Spain (80 pma for pre-1987 deaths), Brazil (life+70) or the UAE (life+50).
int termFor(int deathYear) => deathYear <= 1987 ? 80 : 70;
bool clearToBundle(PlateSpec p, int buildYear) =>
    p.illustrator != null &&
    p.illustratorDeathYear != null &&
    buildYear > p.illustratorDeathYear! + termFor(p.illustratorDeathYear!);

Iterable<Failure> assertPlates(ContentSource src, int buildYear) sync* {
  for (final p in src.plates) {
    if (p.origin == PlateOrigin.originated) continue; // commissioned; ledger row still required
    if (p.illustrator == null || p.illustratorDeathYear == null) { // never 'pending'
      yield Failure('A6', p.file, p.line, 'illustrator unidentified — DROP the plate');
    } else if (!clearToBundle(p, buildYear)) {
      // Build year 2026: the artist must have died in 1945 or earlier.
      yield Failure('A6', p.file, p.line,
          'illustrator d.${p.illustratorDeathYear} still in term in ES/BR — DROP');
    }
  }
}

/// A7 — the persisted index must be byte-identical to the app's own normalise(). One extra
/// folded diacritic and 'كنعد' typed at 05:40 with wet hands matches nothing at all.
Iterable<Failure> assertNormParity(EmittedDb db) sync* {
  const pairs = <String, String>{
    'species.search_norm': 'species.scientific_name',
    'vernacular.search_norm': 'vernacular.name',
    'content_string.body_norm': 'content_string.value',
  };
  for (final MapEntry(key: normCol, value: srcCol) in pairs.entries) {
    for (final (rowId, stored, source) in db.readPair(normCol, srcCol)) {
      if (stored != normalise(source)) {
        yield Failure('A7', normCol, rowId, 'differs from shared normalise()');
      }
    }
  }
}

/// A8 — row assertions cannot see contradictions. Resolve every authored cell with the SHIPPED
/// engine, so a precedence change in catchlaw-rule-engine re-runs here for free.
Iterable<Failure> assertNoContradictions(ContentSource src) sync* {
  final engine = RuleEngine(src.asRuleSet());
  for (final cell in src.resolutionGrid()) { // species x zone x month, ~40k cells
    switch (engine.evaluate(cell)) {
      case ResolutionConflict(:final ruleIds):
        yield Failure('A8', 'content/rules.yaml', 0, '$cell two rules bite: $ruleIds');
      case ResolutionMissingCitation(:final ruleId):
        yield Failure('A8', 'content/rules.yaml', 0, '$cell rule $ruleId has no citation');
      default: // resolved cleanly
    }
  }
}

/// The gate. A non-empty failure list writes NOTHING: no partial database, no warning tier,
/// no --force. The flag that exists is the flag a release uses on a Friday.
Future<void> main(List<String> args) async {
  final opts = ContentBuildOptions.parse(args); // --in content/ --out app/assets/db/reference.db
  final src = await ContentSource.load(opts.inDir);
  final buildYear = DateTime.now().toUtc().year;
  final failures = <Failure>[
    ...assertSizeHasMethod(src.rulesDoc),
    ...assertLocaleCoverage(src),
    ...assertGender(src),
    ...assertCitations(src),
    ...assertPlates(src, buildYear),
    ...assertNoContradictions(src),
  ]..sort((a, b) => (a.file + a.line.toString()).compareTo(b.file + b.line.toString()));
  if (failures.isNotEmpty) {
    for (final f in failures) stderr.writeln(f.render());
    stderr.writeln('content_builder: ${failures.length} failures; ${opts.outFile} not written');
    exitCode = 1;
    return;
  }

  final db = await emitReferenceDb(src, opts.outFile, buildYear: buildYear);
  final parity = assertNormParity(db).toList(); // A7 runs against the EMITTED bytes
  if (parity.isNotEmpty) {
    for (final f in parity) stderr.writeln(f.render());
    await File(opts.outFile).delete(); // an unindexed database is worse than none
    exitCode = 1;
    return;
  }
  await emitChangelogs(src, opts.changelogDir); // A10: one .md per jurisdiction, as a diff
  stdout.writeln('content_builder: OK — ${src.rules.length} rules, ${src.plates.length} plates');
}
