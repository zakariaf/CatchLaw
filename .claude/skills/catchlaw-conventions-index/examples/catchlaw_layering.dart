// Demonstrates the CatchLaw layer map end to end in one file: (1) the pure-Dart rule_engine layer
// with zero Flutter and zero drift imports, returning a sealed Verdict that always carries a
// Citation; (2) the lib/data/ layer opening the extracted read-only reference database and the
// writable user database lazily, so nothing is awaited before runApp; (3) the lib/ui/ layer
// rendering the verdict and keeping an expired rule pack visible behind a non-blocking ochre bar.
// In the real repo parts 1, 2 and 3 live in packages/rule_engine/, lib/data/ and lib/ui/.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// ---------------------------------------------------------------------------
// 1. packages/rule_engine/ — pure Dart. No package:flutter, no package:drift.
// ---------------------------------------------------------------------------

enum MeasurementMethod { totalLength, forkLength, carapaceWidth, shellLength }

/// Instrument, article and both dates travel with every verdict; never nullable.
class Citation {
  const Citation({
    required this.instrument, required this.article,
    required this.publishedOn, required this.checkedOn, required this.packId,
  });
  final String instrument; // 'Ministerial Decision 580/2015'
  final String article; // 'Art. 3'
  final DateTime publishedOn; // 2015-11-03
  final DateTime checkedOn; // 2026-07-14
  final String packId; // 'RAK-GULF v2026.2'
}

class SizeRule {
  const SizeRule({
    required this.scientificName, required this.minimumCm,
    required this.method, required this.citation,
  });
  final String scientificName; // 'Epinephelus coioides'
  final double minimumCm; // 45.0
  final MeasurementMethod method; // MeasurementMethod.totalLength
  final Citation citation;
}

sealed class Verdict {
  const Verdict({required this.citation});
  final Citation citation;
}

final class Meets extends Verdict {
  const Meets({required this.measuredCm, required super.citation});
  final double measuredCm;
}

final class BelowMinimum extends Verdict {
  const BelowMinimum({
    required this.measuredCm, required this.minimumCm,
    required this.method, required super.citation,
  });
  final double measuredCm; // 38.0
  final double minimumCm; // 45.0
  final MeasurementMethod method;
}

/// Pure function: the app and the content_build CLI both call this one.
Verdict evaluateSize(SizeRule rule, double measuredCm) => measuredCm < rule.minimumCm
    ? BelowMinimum(
        measuredCm: measuredCm, minimumCm: rule.minimumCm,
        method: rule.method, citation: rule.citation)
    : Meets(measuredCm: measuredCm, citation: rule.citation);

// ---------------------------------------------------------------------------
// 2. lib/data/ — three files, two databases, nothing awaited before runApp.
// ---------------------------------------------------------------------------

/// The shipped asset is extracted once, then opened read-only for the app's life.
LazyDatabase referenceExecutor() => LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'reference', 'reference.db'));
      if (!file.existsSync()) {
        // First launch only, behind a determinate progress bar, under 6 s.
        await extractReferenceAsset('assets/db/reference.db.gz', file);
      }
      return NativeDatabase.createInBackground(file, readOnly: true);
    });

/// The only writable database on the device. It never leaves it.
LazyDatabase userExecutor() => LazyDatabase(() async {
      final dir = await getApplicationSupportDirectory();
      final file = File(p.join(dir.path, 'user', 'user.db'));
      return NativeDatabase.createInBackground(file); // catchlaw-db-ok — writable by design
    });

/// Gunzip out of the bundle, temp file, atomic rename, sha256 — catchlaw-reference-database.
Future<void> extractReferenceAsset(String assetKey, File target) async =>
    throw UnimplementedError('see catchlaw-reference-database');

class RulePack {
  const RulePack({required this.id, required this.validUntil});
  final String id; // 'RAK-GULF v2026.2'
  final DateTime validUntil; // 2026-06-30
  bool isStaleOn(DateTime today) => validUntil.isBefore(today);
}

final rulePackProvider = Provider<RulePack>(
  (ref) => RulePack(id: 'RAK-GULF v2026.2', validUntil: DateTime.utc(2026, 6, 30)),
);

// ---------------------------------------------------------------------------
// 3. lib/ui/ — first frame immediately; stale packs are shown, never withheld.
// ---------------------------------------------------------------------------

void main() => runApp(const ProviderScope(child: CatchlawApp()));

class CatchlawApp extends StatelessWidget {
  const CatchlawApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: ResultScreen());
}

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(rulePackProvider);
    final rule = SizeRule(
      scientificName: 'Epinephelus coioides',
      minimumCm: 45,
      method: MeasurementMethod.totalLength,
      citation: Citation(
        instrument: 'Ministerial Decision 580/2015',
        article: 'Art. 3',
        publishedOn: DateTime.utc(2015, 11, 3),
        checkedOn: DateTime.utc(2026, 7, 14),
        packId: 'RAK-GULF v2026.2',
      ),
    );

    // The same evaluation runs whether the pack is fresh or expired.
    final verdict = evaluateSize(rule, 38);

    // StaleRuleBar, VerdictPanel, CitationFootnote and LonjaDisclaimer are owned by
    // lonja-verdict-and-status; the ORDER and the absence of any gate are owned here.
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pack.isStaleOn(DateTime.now()))
            StaleRuleBar(expiredOn: pack.validUntil), // ochre 8A6A16, non-blocking
          VerdictPanel(verdict: verdict), // 'Below the minimum — 38 cm, minimum 45 cm'
          CitationFootnote(citation: verdict.citation), // required, never null
          const LonjaDisclaimer(), // unconditional: no flag, no ternary, no dismiss
        ],
      ),
    );
  }
}
