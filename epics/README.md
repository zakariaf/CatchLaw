# Epics — building CATCHLAW

The complete application, decomposed into 22 epics and 181 tasks. Derived from `SPEC.md` §15 (build
order), constrained by `FLUTTER_GUIDE.md` (how the code is written) and `.claude/skills/` (what the
gates enforce).

**This is an implementation sequence, not a release plan.** `SPEC.md` describes a finished product with
no v2; the epics are the order in which it becomes true. Nothing here is a phase that can be dropped.

---

## Read these three first

| File | Why |
|---|---|
| **`CONVENTIONS.md`** | The epic loop, the task loop, commit format, test naming, gate scripts, the definition of done under every task. |
| **`DECISIONS.md`** | Nine conflicts between the spec, the guide and the skills, settled. Task files cite these as `D-1`…`D-9` and never re-argue them. |
| **`../SPEC.md`** | The product. Every task cites the section it implements. |

---

## The epic order

Dependencies are hard: an epic may not start until every epic in its **After** column is merged.

| # | Epic | Branch | Tasks | After | Delivers |
|---|---|---|---|---|---|
| **E01** | Foundation, workspace and the offline gates | `epic/01-foundation` | 9 | — | A workspace that builds, and every §14 static check failing loudly from commit one |
| **E02** | Rule engine — text normalisation | `epic/02-normalisation` | 8 | E01 | `هامور`, `هامورة`, `الهامور`, `hamour` and `Epinephelus` reach one species id |
| **E03** | Rule engine — resolution, findings, verdicts | `epic/03-rule-engine` | 11 | E02 | The §7.3 algorithm, expiry semantics, D4 ambiguity, sealed verdicts |
| **E04** | Content builder and the Galicia seed | `epic/04-content-build` | 11 | E03 | `reference.db` built from authored YAML, with every §8 assertion |
| **E05** | Data layer — two drift databases | `epic/05-data-layer` | 10 | E04 | Read-only reference, writable `user.db`, atomic first-launch extraction |
| **E06** | Localisation infrastructure | `epic/06-localisation` | 8 | E05 | Six locales, the fallback chain, the numeral-system lever, RTL harness |
| **E07** | Lonja design system foundation | `epic/07-lonja-theme` | 8 | E06 | Three themes, glove density, the type ramp, tokens gate green |
| **E08** | Species — search, browse, detail (static) | `epic/08-species` | 8 | E07 | S5, S6, and the static half of S2 |
| **E09** | Ruler and calibration | `epic/09-ruler` | 8 | E07 | S3, S4, step-and-mark, manual entry before calibration |
| **E10** | Result screen | `epic/10-result` | 10 | E08, E09 | S2 complete: verdict, findings, citation, stale bar, flag, disclaimer |
| **E11** | Zones and point-in-polygon | `epic/11-zones` | 8 | E05 | S9, bbox prefilter, ray casting, GPS as suggestion only |
| **E12** | Check home and navigation shell | `epic/12-check-home` | 7 | E10, E11 | S1 and the bottom nav — the first point the 5-second target is testable |
| **E13** | Catch log | `epic/13-catch-log` | 8 | E12 | S8, S10, S11: trips, catches, tally, in-app camera |
| **E14** | Identification key | `epic/14-identify` | 7 | E08 | S7, multi-candidate results, dead ends, three entry points |
| **E15** | Reference section | `epic/15-reference` | 9 | E06 | S12, S13 with Arabic FTS, S18–S23 |
| **E16** | Settings | `epic/16-settings` | 7 | E09, E13 | S14, including storage usage and bulk photo purge |
| **E17** | Export and import | `epic/17-portability` | 8 | E13 | S15, S16: JSON, CSV, PDF, zip, transactional import |
| **E18** | About and attributions | `epic/18-about` | 6 | E15 | S17, `ATTRIBUTIONS.md` in full, every plate's illustrator |
| **E19** | Accessibility, sunlight and glove | `epic/19-accessibility` | 7 | all UI | Semantics, 200% scale, contrast, greyscale proof, haptics |
| **E20** | RTL and locale hardening | `epic/20-rtl-hardening` | 6 | E19 | The golden matrix in six locales, Arabic plurals, numerals end-to-end |
| **E21** | Offline verification and release readiness | `epic/21-release` | 8 | E20 | §14 executed on device, packet capture, store presence |
| **E22** | Content authoring at scale | `epic/22-content` | 9 | E04 | The remaining jurisdictions. **Runs in parallel from E04 onward — the long pole** |

**E22 is the exception to the sequence.** `SPEC.md` §15 step 19 says content authoring "runs in
parallel from step 3 onward and is the long pole", and §8 puts it plainly: *the code is a fortnight;
the content is the moat*. Its branch is cut after E04 merges and lives alongside the others. Every
other epic is strictly sequential.

---

## Status

**E01 through E06 are merged.** Every epic below them is `not started`.

| Epic | Branch | PR | Checks | Merged |
|---|---|---|---|---|
| E01 | `epic/01-foundation` | [#1](https://github.com/zakariaf/CatchLaw/pull/1) | all green | ☑ |
| E02 | `epic/02-normalisation` | [#3](https://github.com/zakariaf/CatchLaw/pull/3) | all green | ☑ |
| E03 | `epic/03-rule-engine` | [#4](https://github.com/zakariaf/CatchLaw/pull/4) | all green | ☑ |
| E04 | `epic/04-content-build` | [#5](https://github.com/zakariaf/CatchLaw/pull/5) | all green | ☑ |
| E05 | `epic/05-data-layer` | [#6](https://github.com/zakariaf/CatchLaw/pull/6) | all green | ☑ |
| E06 | `epic/06-localisation` | [#8](https://github.com/zakariaf/CatchLaw/pull/8) | all green | ☑ |
| E07 | — | — | — | ☐ |
| E08 | — | — | — | ☐ |
| E09 | — | — | — | ☐ |
| E10 | — | — | — | ☐ |
| E11 | — | — | — | ☐ |
| E12 | — | — | — | ☐ |
| E13 | — | — | — | ☐ |
| E14 | — | — | — | ☐ |
| E15 | — | — | — | ☐ |
| E16 | — | — | — | ☐ |
| E17 | — | — | — | ☐ |
| E18 | — | — | — | ☐ |
| E19 | — | — | — | ☐ |
| E20 | — | — | — | ☐ |
| E21 | — | — | — | ☐ |
| E22 | — | — | — | ☐ |

---

## Traceability — every spec section has an owner

| `SPEC.md` | Owned by |
|---|---|
| §4.1 rule evaluation | E03, E10 |
| §4.2 measurement | E09 |
| §4.3 identification | E14 |
| §4.4 jurisdiction and zone | E11 |
| §4.5 catch log | E13 |
| §4.6 reference | E15 |
| §4.7 trust and currency | E10, E15 |
| §4.9 accessibility | E19 |
| §5.1 the legal-advice carve-out | E03, E10 |
| §5.3 the offline guarantee | E01, E21 |
| §6 screens S1–S23, D1–D5 | E08–E18 |
| §7.1 `reference.db` | E04, E05 |
| §7.2 `user.db` | E05, E13 |
| §7.3 rule resolution | E03 |
| §7.4 migration | E05 |
| §8 bundled data and the pipeline | E04, E22 |
| §9 localisation | E06, E20 |
| §10 tech stack | E01 |
| §11 platform specifics | E01 |
| §12 data portability | E17 |
| §13 non-functional targets | E12 (start-up), E15 (FTS), E11 (polygon), E03 (evaluation) |
| §14 offline verification | E01 (static), E21 (dynamic) |
| §16 R1 Gulf texts | E22 |
| §16 R3 ruler accuracy | E09 |

Four `SPEC.md` items deliberately have **no** epic: §16 R2 (the demand test — it is field work, not
code), §17 (validation plan, likewise), §1 audience sizing, and §5's exclusion list, which is a
boundary rather than a deliverable.
