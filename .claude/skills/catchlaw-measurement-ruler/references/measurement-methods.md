# Measurement Methods

Scope: the six measurement methods, where the method is stored, how a length is held, rounded and
printed, the comparison contract against a rule row, and the edge cases that arrive with a real fish.

## The six methods

`MeasurementMethod` is a closed enum in `lib/domain/measurement/measurement_method.dart`. Adding a
seventh is a reviewed change with a content migration, never a local addition.

| Code | Enum | English | Arabic | Taken from → to | Typical subject |
|---|---|---|---|---|---|
| TL | `tl` | total length | الطول الكلي | snout tip → tip of the longer caudal lobe, lobes squeezed, fish flat | most finfish |
| FL | `fl` | fork length | الطول الشوكي | snout tip → the fork of the caudal fin | forked-tail pelagics |
| SL | `sl` | standard length | الطول القياسي | snout tip → hypural plate, caudal fin excluded | scientific rows |
| CW | `cw` | carapace width | عرض الدرع | widest points across the carapace | crabs |
| SHL | `shl` | shell length | طول الصدفة | longest axis of the closed shell | bivalves |
| ML | `ml` | mantle length | طول العباءة | dorsal mantle, anterior edge → posterior tip | squid, cuttlefish |

TL and FL differ by the whole caudal fork: on *Scomberomorus commerson* the ratio is roughly
TL ≈ 1.09 × FL, and it varies by individual. That ratio is documented here as a reason NOT to
convert, never as a conversion table shipped in code.

## The method is a column of the rule row

`rules.measurement_method TEXT NOT NULL` in the read-only reference DB. `species` has no method
column, and adding one is the defect this whole reference exists to prevent.

| Species | Jurisdiction | Zone | Limit | Method | Instrument |
|---|---|---|---|---|---|
| هامور Hamour · *Epinephelus coioides* | AE | Ras Al Khaimah | min 450 mm | `tl` | Ministerial Decision 580/2015, Art. 3 |
| كنعد Kanaad · *Scomberomorus commerson* | AE | Ras Al Khaimah | min 650 mm | `fl` | Ministerial Decision 580/2015, Art. 3 |
| شعري Sha'ri · *Lethrinus nebulosus* | AE | Ras Al Khaimah | closed 1 Mar – 30 Apr | — | Ministerial Decision 580/2015, Art. 3 |
| Ameixa babosa · *Venerupis corrugata* | ES-GA | Rias Baixas - Banco de Cambados | min 38 mm | `shl` | orden de vedas, current annual |
| *Scomberomorus commerson* | BR | Represa de Jurumirim | piracema closure | — | portaria, current season |

A closed-season row carries no limit and no method; a size row without a method fails the content
build in `catchlaw-content-pipeline`, before it can ever reach a device.

## Storage

| Layer | Declaration | Unit | Hamour minimum | Ameixa babosa minimum |
|---|---|---|---|---|
| Domain | `final int lengthMm` | mm | `450` | `38` |
| Drift (reference) | `IntColumn get minLengthMm => integer()()` | mm | `450` | `38` |
| Drift (user) | `IntColumn get lengthMm => integer()()` | mm | reading | reading |
| Content JSON | `"min_length_mm": 450` | mm | `450` | `38` |
| Display | `formatMeasurement(...)` | cm or mm | `45.0 cm total length (TL)` | `38 mm shell length (SHL)` |

`RealColumn` and `TextColumn` are never correct for a length. `pxPerMm` is the ONLY double in the
subsystem: it is a scale factor, stored in the user DB, and it is not a length.

## Rounding and comparison

One rounding, at capture: `lengthMm = (px / pxPerMm).round()`. Nothing rounds again.

| Raw px | pxPerMm | Raw mm | Stored | Printed |
|---|---|---|---|---|
| 2834.6 | 6.299 | 449.99 | `450` | 45.0 cm |
| 2828.3 | 6.299 | 448.99 | `449` | 44.9 cm |
| 239.4 | 6.299 | 38.01 | `38` | 38 mm |

The comparison itself belongs to `catchlaw-rule-engine`; it is inclusive — `lengthMm >= minLengthMm`
means a fish measured at exactly 450 mm MEETS the 45 cm minimum. This skill guarantees only that the
integer handed over was rounded once and carries its method.

Display rule: below 100 mm print millimetres with no decimal (shellfish, `38 mm`); at or above
100 mm print centimetres with one decimal (`45.0 cm`). The threshold is a display convention; the
stored value never changes shape.

## Display formatting

Numerals, decimal separator and direction come from `i18n-rtl-l10n`. What is non-negotiable here is
that the method label is present in every locale.

| Locale | 450 mm `tl` | 38 mm `shl` |
|---|---|---|
| en | `45.0 cm total length (TL)` | `38 mm shell length (SHL)` |
| ar | `٤٥٫٠ سم الطول الكلي` | `٣٨ ملم طول الصدفة` |
| es | `45,0 cm longitud total (TL)` | `38 mm longitud de la concha (SHL)` |
| pt | `45,0 cm comprimento total (TL)` | `38 mm comprimento da concha (SHL)` |

The Arabic form drops the parenthesised Latin code because the Arabic name is already unambiguous;
it never drops the method itself. Codes TL/FL/SL/CW/SHL/ML are rendered in the mono face with
tabular figures so a column of readings aligns.

## Method mismatch matrix

| Reading method | Rule method | Outcome |
|---|---|---|
| `tl` | `tl` | compare |
| `fl` | `fl` | compare |
| `fl` | `tl` | `MethodMismatch` — re-measure prompt naming total length |
| `tl` | `fl` | `MethodMismatch` — re-measure prompt naming fork length |
| `sl` | `tl` | `MethodMismatch` — never scale by a species factor |
| `cw` | `shl` | `MethodMismatch` — different taxon shape entirely |
| any | `null` (closed-season row) | no size comparison runs at all |

A mismatch is a statement of fact too: "This reading is a fork length; the rule states total length."
Never "Measure it again properly", never an instruction. See `catchlaw-verdict-contract`.

## Edge cases

- **Damaged caudal fin.** TL and FL are not takeable; SL is NOT a substitute and no factor converts
  it. The app records no reading and states which method the rule requires.
- **Two rules, two methods, one zone.** The engine returns `Ambiguous`; the capture screen keeps both
  readings in the draft rather than picking one method to satisfy.
- **Zero, negative or absurd manual entry.** Accept `1..3000` mm; outside the band the field is in
  error state and nothing is stored. A 3 m fish is a typo, not a catch.
- **Unit habit mismatch.** A Galician user typing `3.8` for 38 mm: the manual keypad is labelled in
  millimetres for `shl`/`cw` rules and centimetres for `tl`/`fl`/`sl`/`ml`, matching the instrument.
- **Reading imported from a previous session.** The stored row carries its own method; it is never
  re-interpreted under whichever rule is on screen now.
- **Content revision changes the method.** The content build treats a method change as a new
  `citation_lineage_id` row; old readings keep the method they were taken with.
