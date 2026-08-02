import 'package:catchlaw/data/repositories/species_recent_repository.dart';
import 'package:catchlaw/data/repositories/species_recent_repository_drift.dart';
import 'package:catchlaw/data/services/reference_database_service.dart';
import 'package:catchlaw/data/services/user_database_service.dart';
import 'package:catchlaw/domain/models/recent_species_entry.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart' show Ok;

import '../../../testing/fixtures/rules_fixture.dart';

void main() {
  late UserDatabase userDb;
  late ReferenceDatabase referenceDb;
  late SpeciesRecentRepository repo;

  setUp(() async {
    userDb = UserDatabase(NativeDatabase.memory());
    addTearDown(userDb.close);
    referenceDb = await buildRulesFixture();
    addTearDown(referenceDb.close);
    repo = DriftSpeciesRecentRepository(userDb: userDb, referenceDb: referenceDb);
  });

  Future<void> use(int id, {String at = '2026-08-01T05:40:00Z'}) async {
    expect(
      await repo.recordUse(id, jurisdictionCode: 'ES-GA', zoneCode: 'CAMBADOS', at: at),
      isA<Ok<void>>(),
    );
  }

  Future<List<RecentSpeciesEntry>> strip() =>
      repo.watchRecents(jurisdictionCode: 'ES-GA', zoneCode: 'CAMBADOS').first;

  test('DriftSpeciesRecentRepository.recordUse creates a row on first use', () async {
    await use(1);
    final List<RecentSpeciesEntry> entries = await strip();
    expect(entries, hasLength(1));
    expect(entries.single.useCount, 1);
  });

  test('DriftSpeciesRecentRepository.recordUse increments rather than replacing', () async {
    // An upsert and not a read-modify-write: two taps a frame apart on a wet
    // screen would otherwise both read 3 and both write 4, and the species the
    // fisher actually catches most would drift down the strip.
    await use(1);
    await use(1, at: '2026-08-01T05:41:00Z');
    await use(1, at: '2026-08-01T05:42:00Z');
    expect((await strip()).single.useCount, 3);
  });

  test('DriftSpeciesRecentRepository orders by frequency before recency', () async {
    // The six species a fisher actually catches stay at the top. A strip
    // ordered only by recency is reshuffled by the one unusual fish he looked
    // up last week.
    await use(1, at: '2026-08-01T05:00:00Z');
    await use(1, at: '2026-08-01T05:01:00Z');
    await use(2, at: '2026-08-01T09:00:00Z');

    final List<RecentSpeciesEntry> entries = await strip();
    expect(entries.map((RecentSpeciesEntry e) => e.speciesId), <int>[1, 2]);
  });

  test('DriftSpeciesRecentRepository breaks a frequency tie by recency', () async {
    await use(1, at: '2026-08-01T05:00:00Z');
    await use(2, at: '2026-08-01T09:00:00Z');
    expect((await strip()).first.speciesId, 2);
  });

  test('DriftSpeciesRecentRepository keeps zones apart', () async {
    // Recents are per zone: the six species of the Ría de Arousa are not the
    // six of Ras Al Khaimah, and a strip that mixed them would put a fish that
    // does not live here at the top of the screen.
    await use(1);
    expect(await repo.watchRecents(jurisdictionCode: 'ES-GA', zoneCode: 'AROUSA').first, isEmpty);
  });

  test('DriftSpeciesRecentRepository drops a retired species from the strip', () async {
    // species_id is a SOFT reference into a file a content update replaces
    // wholesale, so a retired species must not appear as a nameless tile.
    await use(9999);
    expect(await strip(), isEmpty);
  });

  test('DriftSpeciesRecentRepository joins the art from the other database', () async {
    // The one place the two databases meet, and they meet in Dart: ATTACH is
    // banned because a content swap leaves a statement spanning both files
    // pointing at an unlinked inode.
    await use(1);
    expect((await strip()).single.silhouetteAsset, isNotEmpty);
  });
}
