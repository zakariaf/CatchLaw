# E05/T12 — A measurement method is resolved by its code, never by its row id

| | |
|---|---|
| **Epic** | E05 — Data layer: two drift databases |
| **Branch** | `fix/v1-device-defects` |
| **Commit** | `fix(data): resolve the measurement method by code, not by row id` |
| **Depends on** | T10 (mappers), E04 (the builder assigns the ids) |
| **Size** | S |
| **Spec** | `SPEC.md` §7.2; `catchlaw-measurement-ruler` |
| **Found by** | Running v1 on an iOS simulator against the real Galicia pack. No test caught it |

## Skills to load

| Skill | Why this task needs it |
|---|---|
| `catchlaw-measurement-ruler` | TL, FL, CW and SHL are four different lengths on the same animal; the method is the number's unit, not a label beside it |
| `catchlaw-content-pipeline` | Rule 3 — the method is authored, never inferred — and why the builder's ids are insertion order and therefore pack-specific |
| `catchlaw-reference-database` | The `measurement_method` lookup table and where a code-keyed read belongs |
| `testing-strategy` | Rule 4: a fixture that numbers its rows the way the code assumes proves nothing |

## What went wrong

Two call sites turned a `measurement_method_id` into a `MeasurementMethod` by indexing the enum's
declaration order:

```dart
engine.MeasurementMethod.values.elementAtOrNull(row.measurementMethodId! - 1)
```

**The builder assigns those ids by insertion order**, per pack. The Galicia pack declares shell length
and gives it id 1; the enum declares total length first. So the one shipped size rule — 38 mm along the
anteroposterior axis of *Venerupis corrugata*, cited to the Orde do 27 de xullo de 2012 — reached the
screen as a **total-length** threshold. On device it surfaced as `ContentStringMissing:
measurement.tl.name`, but a missing string is the lucky failure: had the pack happened to carry a
`measurement.tl.*` row, the app would have stated the wrong measurement, with the right number, under
the right instrument, and said it calmly.

This is `catchlaw-measurement-ruler`'s central failure, and the reason the enum has four members rather
than a comment. A clam measured the wrong way is a fine or a false acquittal.

**Why no test caught it.** Every fixture in the suite seeded `measurement_method` in the enum's own
declaration order, so the broken map and the correct map agreed on every row we had ever written. The
disagreement needed a pack authored by somebody who did not know the enum — which is exactly what the
content pipeline is, and exactly what shipped.

## What this delivers

- `app/lib/data/model/enum_codecs.dart` — `measurementMethodOfId` is deleted; `measurementMethodOfCode`
  replaces it, with the shipped defect written into its dartdoc so the next reader does not re-derive it.
- `app/lib/data/model/mappers.dart` — `toRule` takes `required MeasurementMethod? method` instead of
  reading the id. The caller must have resolved it; the mapper cannot guess.
- `app/lib/data/daos/reference/citation_dao.dart` — `ReferenceMetaDao.methodCodes()`, one read of the
  lookup table returning `Map<int, String>`.
- `app/lib/data/repositories/reference_repository_drift.dart` and
  `species_facts_repository_drift.dart` — load the map once per query and resolve through it.
- `app/testing/fixtures/rules_fixture.dart` — seeds ids that deliberately **disagree** with the enum's
  declaration order (1 = SHL, 2 = FL, 3 = TL), so no fixture can silently agree with a broken map again.

## Why it is built this way

**The `code` column is the stable identity; the id is a local surrogate.** `TL`, `FL`, `CW` and `SHL`
are authored text and mean the same thing in every pack ever built. The integer means whatever the last
build happened to assign. Anything that crosses the pack boundary must key on the code.

**The map is loaded once per query, not per row.** Four rows, read once, resolved in memory — a per-row
lookup would put a query inside the rule loop on the cold-start path.

**`toRule` demands the method rather than deriving it.** Making it a required parameter moves the
resolution to the one place that holds the codes and makes the old shortcut unwritable, instead of
leaving a correct call and an incorrect call both available.

**The fixture disagrees on purpose.** A fixture that mirrors the enum is a fixture that can only confirm
the bug. The new ids are wrong-on-purpose, and `shipped_pack_test.dart` asserts the same property
against the artefact that actually ships.

## Tests first

| # | Test name | Setup | Expected | Why this case exists |
|---|---|---|---|---|
| 1 | `the shipped pack resolves its measurement method by code, not by row id` | the built `reference.db` | every sized rule's method equals the `code` its row joins to | The shipped defect, asserted against the real artefact |
| 2 | `toRule carries the measurement method it is given` | id order ≠ enum order | SHL in, SHL out | The mapper must not re-derive |
| 3 | `species facts state the method the instrument names` | fixture with disagreeing ids | the hint names shell length | The second call site, which had the same bug |

## Definition of done

`CONVENTIONS.md` §8 applies in full, plus:

- [ ] All tests pass, and each failed first against the id-index lookup.
- [ ] No `MeasurementMethod.values.elementAt*` survives anywhere in `app/lib`.
- [ ] Every fixture seeding `measurement_method` uses ids that differ from the enum's order.
- [ ] `check_measurement.sh` is green over `app/lib`.

## Gates

```bash
cd app && dart format --set-exit-if-changed . && flutter analyze && flutter test
.claude/skills/catchlaw-measurement-ruler/scripts/check_measurement.sh     app/lib
.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh  app/lib
```
