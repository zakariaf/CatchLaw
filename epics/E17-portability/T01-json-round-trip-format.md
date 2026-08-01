# E17/T01 — The JSON round-trip format

| | |
|---|---|
| **Epic** | E17 — Export and import |
| **Branch** | `epic/17-portability` (shared) |
| **Commit** | `feat(export): serialise the whole user dataset to a versioned JSON envelope` |
| **Depends on** | — (E13 merged: `trip`, `catch`, `rule_flag`, `saved_zone`, `user_profile` all exist) |
| **Size** | L |
| **Spec** | `SPEC.md` §12 export item 1, §7.2 (`user.db` schema), §7.4 (schema version refusal), §4.7 (flags are in every export) |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-conventions-index` | Rule 6, the one-way layer map — this codec lives in the app, above `packages/rule_engine/`, and `references/product-invariants.md` is where invariant 2 and invariant 3 are stated in the form this task must not break |
| `catchlaw-offline-guarantee` | The envelope is the *only* representation of user data that ever leaves the device; rule 11 forbids anything in it that implies a sync, a server id or a device identifier |
| `catchlaw-verdict-contract` | `catch.outcome_detail` is a user-visible sentence being copied into a file. Rules 1 and 2 apply to it in the export exactly as on screen — the codec copies, it never re-words |
| `error-handling-typed-results` | `decode` returns `Result`/`Failure`, never throws. This is where the failure taxonomy T08 extends is first shaped |
| `persistence-drift` | The repository reads every table in one consistent read; drift row classes must not escape `data/` |
| `dart3-idioms-and-coding-standards` | Sealed failures, records for the header, pattern matching over `is` chains |
| `naming-conventions` | The class, file and test names below |
| `testing-strategy` | Pure unit level — no widget binding, no drift, the codec is tested against in-memory models |

## Reference files

| File | Section | Take from it |
|---|---|---|
| `SPEC.md` | §12, export item 1 | The exact header fields: `app_version`, `user_db_schema_version`, per-jurisdiction `content_versions`, `exported_at`. And the sentence "The round-trip format" — this is the artefact import reads |
| `SPEC.md` | §7.2 | Every column of `user_profile`, `saved_zone`, `trip`, `catch` and `rule_flag`, including which are nullable and which carry `CHECK` constraints |
| `SPEC.md` | §7.2, the "Why `catch` denormalises" note | Why `scientific_name`, `rule_citation_ref` and `content_version` travel on the catch row — history is immutable, so the export must carry them too |
| `SPEC.md` | §4.7, "Flag a wrong rule" | Flags are included in **every** export, because the app composes nothing and sends nothing |
| `SPEC.md` | §7.4, last bullet | The app refuses a `user.db` whose schema version is higher than it understands. The header field exists so a *file* can be refused the same way (T08) |
| `FLUTTER_GUIDE.md` | §1.6 | The `Result` type, renamed `Failure`; point 2 — the error channel is `Exception`, and a `TypeError` from a bad cast escapes it entirely |
| `FLUTTER_GUIDE.md` | §1.4, §1.5 | Where a codec sits: a Service isolates data that lives outside Dart; the abstract repository plus a fake |
| `FLUTTER_GUIDE.md` | §2.5, rule 6 | Drift row classes never escape `data/` — the envelope is built from domain models |
| `.claude/skills/catchlaw-conventions-index/references/product-invariants.md` | §2, §3 | The banned lexicon and the citation quadruple, both of which are being written to a file here |
| `.claude/skills/catchlaw-offline-guarantee/references/four-layers.md` | "The API grep list" | `Uri.parse` is **not** banned — the reference database stores instrument identifiers as URIs and they are printed, never fetched. The envelope may carry `citation.source_url` as a string |
| `epics/DECISIONS.md` | D-1, D-7 | App at `app/`; the engine holds no user-visible sentence, so `outcome_detail` is an app-side string and the codec is app-side code |

## What this delivers

- `app/lib/domain/models/portability/export_envelope.dart` — `ExportEnvelope` and `ExportHeader`,
  immutable, `const` constructors, value equality. `ExportHeader` fields: `appVersion` (String),
  `userDbSchemaVersion` (int), `contentVersions` (`Map<String, String>`, jurisdiction code →
  content version), `exportedAt` (`DateTime`, UTC).
- `app/lib/domain/models/portability/exported_records.dart` — the five payload shapes
  (`ExportedProfile`, `ExportedSavedZone`, `ExportedTrip`, `ExportedCatch`, `ExportedRuleFlag`), one
  field per §7.2 column, nullability matching the schema exactly.
- `app/lib/data/services/portability/export_json_codec.dart` — `ExportJsonCodec` with
  `String encode(ExportEnvelope)` and `Failure<ExportEnvelope> decode(String)`. Pure: no `dart:io`,
  no drift, no `BuildContext`.
- `app/lib/data/services/portability/portability_failure.dart` — the sealed failure family,
  opened here with `MalformedJson`, `MissingField`, `WrongType` and `EmptyPayload`. T08 adds
  `NewerSchema`, `UnsupportedSchema` and the archive cases to the same sealed type.
- `app/lib/data/repositories/portability_repository.dart` (abstract) and
  `portability_repository_drift.dart` — `Future<Failure<UserDataSnapshot>> readAll()`, one
  consistent read of all five tables.
- `app/lib/domain/use_cases/export_user_data.dart` — `ExportUserData`, which joins the user snapshot
  with the per-jurisdiction content versions from `ReferenceRepository`. The join lives in a use case
  because `FLUTTER_GUIDE.md` §2.5 rule 3 forbids the two repositories referencing each other.
- `app/testing/models/portability_fixtures.dart` — `kEnvelopeGaliciaTwoTrips`,
  `kEnvelopeEmpty`, `kCatchHamourExpiredRule`, `kCatchNoLength`.
- `app/testing/fakes/fake_portability_repository.dart`.
- Tests: `app/test/data/services/portability/export_json_codec_test.dart`,
  `app/test/domain/use_cases/export_user_data_test.dart`.

## Why it is built this way

**The envelope is a published contract, so it is decoded by hand.** `json_serializable` was rejected,
and not on taste. A generated `fromJson` reads `json['length_mm'] as int?`; when the file says
`"forty"` that is a `TypeError`, and `FLUTTER_GUIDE.md` §1.6 point 2 records the consequence
precisely: `Result`'s error channel is `Exception`, and a `TypeError` escapes Result-based control
flow entirely. T08 has to name the specific failure — `catches[3].length_mm: expected integer, found
string` — and a generated decoder cannot produce that sentence. The hand-written decoder reads every
field through one `_int`, `_str`, `_intOrNull` helper set that records the JSON path, so the failure
message is a by-product of the decode rather than a thing bolted on later.

**Keys are the §7.2 column names, verbatim, in snake_case.** `created_at`, `length_mm`,
`rule_citation_ref`. A user who opens the JSON in a text editor sees the same names as the SQLite
file S14 shows him the path of (§12's manual escape hatch), so the two escape hatches describe one
dataset. Rejected: camelCase keys matching the Dart field names, which would make the file a third
vocabulary nobody asked for.

**The header is refused before the payload is parsed.** `user_db_schema_version` sits at the top of
the object so a newer file can be rejected in T08 without decoding 8,000 catch rows first, and
without any risk of a partial application. This mirrors §7.4's last bullet, which already refuses a
`user.db` at a higher schema version rather than corrupting it — the file gets the same rule.

**`content_versions` is a map, not a string.** A trip can span jurisdictions and the catch row
carries its own `content_version` (§7.2). The header records what each jurisdiction was at, at the
moment of export, so an importer or a human reader can tell whether the finding on a catch came from
the same ruleset the exporting app was carrying.

**Reference data is not exported.** Rejected: bundling species names, rules and citations into the
envelope so the file is self-describing. `reference.db` is shipped whole and is disposable (D-6), and
§7.2 already denormalises `scientific_name`, `rule_citation_ref` and `content_version` onto the catch
row for exactly this reason — history is immutable without carrying the whole reference database.
Including it would multiply an 8,000-row export (§13: `< 4 MB` of user data) by the ~10 MB reference
asset for no gain.

**`species_recent` is not exported.** It is a usage cache that drives the Recents strip on S1
(`SPEC.md` §6). §12's list is "profile, saved zones, trips, catches, rule flags" and does not include
it. Restoring another device's recents would reorder the Check screen against the fisher's own habit,
which is a regression dressed as fidelity.

**`outcome_detail` is copied byte for byte.** It is the factual finding text as it was shown
(§7.2), and it is a user-visible sentence, so `catchlaw-verdict-contract` rules 1 and 2 bind it. The
codec has no branch that rewrites, truncates, translates or re-generates it. Rejected: re-deriving
the sentence at export time from `species_id` + `length_mm` + the current ruleset — that would
silently restate a three-year-old catch in today's law, which is the exact failure §7.2's
denormalisation note exists to prevent.

**Times are ISO 8601 with an explicit offset; `exported_at` is UTC.** `created_at` and `started_at`
are stored as TEXT (§7.2) and are copied through untouched. `exported_at` is generated here and is
written as UTC with a `Z`, because it is the one timestamp compared across devices.

## Tests first

Write every row before touching `export_json_codec.dart`. Run them. **They must fail.**

| # | Test name | Input | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `ExportJsonCodec.encode writes app_version, user_db_schema_version, content_versions and exported_at in the header` | `kEnvelopeGaliciaTwoTrips` | all four keys present at the top level of `header` | The four fields §12 names by name; anything missing is a spec violation, not a nit |
| 2 | `ExportJsonCodec round-trips an envelope unchanged` | `decode(encode(kEnvelopeGaliciaTwoTrips))` | equals the input | §12 calls this "the round-trip format" — this single row is the task's headline claim |
| 3 | `ExportJsonCodec round-trips an empty dataset` | `kEnvelopeEmpty` | equals the input, five empty lists | A first-launch user exporting before recording anything must get a valid file, not a crash |
| 4 | `ExportJsonCodec.encode uses the user.db column names as keys` | `kEnvelopeGaliciaTwoTrips` | catch object has `length_mm`, `rule_citation_ref`, `created_at`; has no `lengthMm` | The file and the SQLite escape hatch must describe one dataset in one vocabulary |
| 5 | `ExportJsonCodec.encode preserves a null length_mm` | `kCatchNoLength` | `"length_mm": null`, key present | A catch recorded from the tally with no measurement is legal (§7.2 `length_mm` is nullable); dropping the key makes it indistinguishable from a corrupt row |
| 6 | `ExportJsonCodec.encode copies outcome_detail verbatim` | catch whose detail is `Below the minimum — 38 cm measured, minimum 45 cm (total length)` | identical string in the JSON | Invariant 2: the export composes no sentence. A test here is what stops a future "shorten for CSV" helper being reused on the JSON |
| 7 | `ExportJsonCodec.encode includes every rule flag` | envelope with 3 flags | `rule_flags` has 3 entries with `rule_id`, `citation_ref`, `note`, `created_at` | §4.7 — flags in every export is the *only* route by which a wrong rule is reported |
| 8 | `ExportJsonCodec.encode writes exported_at as UTC with a Z suffix` | envelope exported at a known instant | string ends in `Z` and parses back to the same instant | The one timestamp compared across devices; a local-offset value makes two exports uncomparable |
| 9 | `ExportJsonCodec.encode writes content_versions keyed by jurisdiction code` | `{'ES-GA': '2026.2'}` | `"content_versions": {"ES-GA": "2026.2"}` | A trip can span jurisdictions; a flat string could not say which ruleset produced which finding |
| 10 | `ExportJsonCodec.decode returns MalformedJson when the text is not JSON` | `'{oops'` | `Failure` holding `MalformedJson` with a character offset | The first failure a user will hit — a truncated file from a full disk — and T08 needs it named |
| 11 | `ExportJsonCodec.decode returns MissingField naming the path when header.app_version is absent` | header without `app_version` | `MissingField('header.app_version')` | "names the specific failure" (§12) is a testable claim, and the path is the message |
| 12 | `ExportJsonCodec.decode returns WrongType naming the path when length_mm is a string` | `"length_mm": "forty"` | `WrongType('catches[3].length_mm', expected: 'int', actual: 'String')` | The exact case a generated `fromJson` would turn into an uncatchable `TypeError` (`FLUTTER_GUIDE.md` §1.6 point 2) |
| 13 | `ExportJsonCodec.decode throws no exception on any malformed input in the corpus` | 12 hand-broken files | every call returns a `Failure`, none throws | The contract that lets T08 be transactional: decode cannot blow past the `Result` boundary |
| 14 | `ExportJsonCodec.decode rejects an outcome outside the CHECK constraint` | `"outcome": "maybe"` | `WrongType('catches[0].outcome', …)` | §7.2 constrains `outcome` to four values; drift would reject the insert *inside* the transaction, which is a rollback instead of a named error |
| 15 | `ar - ExportJsonCodec round-trips an Arabic note and species name` | note `شبكة خاطئة`, name `هامور` | equal after round trip, no escaping to `\u06…` | `dart:convert` escapes non-ASCII by default in some configurations; a mojibake export is worthless to the primary persona |
| 16 | `ExportUserData.call joins content versions from the reference repository` | fake repos, 1 jurisdiction | header `content_versions` has that jurisdiction's version | `FLUTTER_GUIDE.md` §2.5 rule 3 — the join is a use case, and this test is what makes the rule visible |
| 17 | `ExportUserData.call returns a Failure when the user database read fails` | fake repo returning a failure | `Failure`, no partial envelope | An export that half-succeeds is worse than one that does not: the fisher would keep it |
| 18 | `ExportJsonCodec.decode preserves ordering of catches` | 17 catches | same order out | Merge (T06) remaps `trip_id` by index-independent keys, but a reordered file makes every failure message point at the wrong row |

```dart
// app/test/data/services/portability/export_json_codec_test.dart
import 'dart:convert';

import 'package:catchlaw/data/services/portability/export_json_codec.dart';
import 'package:catchlaw/data/services/portability/portability_failure.dart';
import 'package:catchlaw/utils/failure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../testing/models/portability_fixtures.dart';

void main() {
  const codec = ExportJsonCodec();

  group('ExportJsonCodec', () {
    test('.encode writes app_version, user_db_schema_version, content_versions '
        'and exported_at in the header', () {
      final header =
          (jsonDecode(codec.encode(kEnvelopeGaliciaTwoTrips)) as Map<String, Object?>)['header']!
              as Map<String, Object?>;
      expect(header.keys, containsAll(<String>[
        'app_version',
        'user_db_schema_version',
        'content_versions',
        'exported_at',
      ]));
    });

    test('round-trips an envelope unchanged', () {
      final result = codec.decode(codec.encode(kEnvelopeGaliciaTwoTrips));
      switch (result) {
        case Ok<ExportEnvelope>():
          expect(result.value, kEnvelopeGaliciaTwoTrips);
        case Err<ExportEnvelope>():
          fail('round trip failed: ${result.failure}');
      }
    });

    test('.encode uses the user.db column names as keys', () {
      final first = ((jsonDecode(codec.encode(kEnvelopeGaliciaTwoTrips))
              as Map<String, Object?>)['catches']! as List<Object?>)
          .first! as Map<String, Object?>;
      expect(first.keys, containsAll(<String>['length_mm', 'rule_citation_ref', 'created_at']));
      expect(first.containsKey('lengthMm'), isFalse);
    });

    test('.decode returns WrongType naming the path when length_mm is a string', () {
      final broken = kExportJsonWithStringLength; // catches[3].length_mm == "forty"
      final result = codec.decode(broken);
      expect(result, isA<Err<ExportEnvelope>>());
      final failure = (result as Err<ExportEnvelope>).failure;
      expect(failure, isA<WrongType>());
      expect((failure as WrongType).path, 'catches[3].length_mm');
      expect(failure.expected, 'int');
      expect(failure.actual, 'String');
    });

    test('.decode throws no exception on any malformed input in the corpus', () {
      for (final MapEntry(key: label, value: text) in kMalformedExportCorpus.entries) {
        expect(
          () => codec.decode(text),
          returnsNormally,
          reason: 'decode threw on the "$label" corpus entry',
        );
        expect(codec.decode(text), isA<Err<ExportEnvelope>>(), reason: label);
      }
    });

    test('ar - round-trips an Arabic note and species name', () {
      final result = codec.decode(codec.encode(kEnvelopeArabicNote));
      expect((result as Ok<ExportEnvelope>).value, kEnvelopeArabicNote);
    });

    // … one test per row in the table above, one behaviour each
  });
}
```

**Run:** `cd app && flutter test test/data/services/portability/` → 18 failures. If any passes now,
the test is wrong: `export_json_codec.dart` does not exist yet, so a green result means the test is
asserting against a fixture rather than against the codec.

## Implementation outline

1. Write `portability_failure.dart` first: `sealed class PortabilityFailure` with `MalformedJson`,
   `MissingField`, `WrongType`, `EmptyPayload`. Each carries the JSON path as a `String`, not an
   index — a path survives being nested; an index does not.
2. Write the domain models. One field per §7.2 column, nullability copied from the schema, `const`
   constructors, `operator ==` and `hashCode` (needed by row 2, which compares whole envelopes).
3. Write `ExportJsonCodec.encode`: build `Map<String, Object?>` with the section order
   `header`, `profile`, `saved_zones`, `trips`, `catches`, `rule_flags`, then `jsonEncode`. Header
   first so T08 can refuse on schema version cheaply.
4. Write the read helpers — `_str(map, path)`, `_int`, `_intOrNull`, `_list`, `_map` — each taking
   the accumulated path and returning a `Failure` rather than throwing. No `as` cast survives this
   file: `as` is what produces the `TypeError` row 12 exists to prevent.
5. Write `decode` on top of those helpers, in the same section order. Validate `outcome` against the
   §7.2 `CHECK` set here, not at insert time.
6. Write `PortabilityRepositoryDrift.readAll()` — one drift `transaction()` around five selects, so
   the snapshot is internally consistent even if the tally screen writes mid-export.
7. Write `ExportUserData`: read the snapshot, ask `ReferenceRepository` for the content version of
   every jurisdiction code that appears in the snapshot's trips and catches, build the header, return
   the envelope.
8. Re-run the suite. All 18 green, and every E13 catch-log test still green.

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All 18 tests pass, and each failed first.
- [ ] `export_json_codec.dart` contains zero `as` casts and zero `throw`; every exit is a `Failure`.
- [ ] Line coverage on `export_json_codec.dart` is ≥ 95%.
- [ ] `app/lib/data/services/portability/` imports nothing from `app/lib/ui/`.
- [ ] No drift row class appears in a `domain/` or `ui/` signature (`FLUTTER_GUIDE.md` §2.5 rule 6).
- [ ] Every §7.2 column of the five exported tables appears in the JSON, and `species_recent` does
      not.
- [ ] `outcome_detail` is copied with no transformation — grep the file for `replaceAll`,
      `substring`, `toLowerCase` and `trim` applied to it and find nothing.
- [ ] `ExportHeader.userDbSchemaVersion` reads `UserDatabase.schemaVersion` (E05) and is not a
      literal.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh        app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh    app/lib
.claude/skills/catchlaw-verdict-contract/scripts/check_verdict_contract.sh   app/lib
```

## Then

```
/simplify        → act on it
/code-review     → act on it
git add -A && git commit
```

## Commit

```
feat(export): serialise the whole user dataset to a versioned JSON envelope

There is no cloud, so this file is the only thing that survives a lost phone
and the only route by which a flagged rule reaches the authority that
published it. The header carries app_version, user_db_schema_version, the
per-jurisdiction content versions and exported_at so a newer file can be
refused before a single row is decoded, rather than half applied.

Decoded by hand rather than by json_serializable: a generated fromJson turns
"length_mm": "forty" into a TypeError, which is not an Exception and escapes
the Result boundary entirely. The hand-written readers carry the JSON path,
so "catches[3].length_mm: expected int, found String" falls out of the decode
instead of being reconstructed afterwards.

Task: E17/T01
Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
```
