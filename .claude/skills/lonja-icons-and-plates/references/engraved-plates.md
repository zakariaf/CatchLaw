# Engraved Species Plates — deep dive

The illustration half of the skill: what separates a plate from a silhouette, when each is allowed,
how a plate is drawn and framed, and what provenance every plate must carry.

## Silhouette versus plate

| | Silhouette | Plate |
|---|---|---|
| Grid | 140 × 64 | 300 × 124 |
| Content | Outline plus the eye. No hatching, no fin rays, no markings. | Outline, hatching, fin-ray detail, diagnostic markings, lateral line. |
| Subpaths | ≤ 8 | 20–60 |
| Frame | none | 1 px `rule-strong` `#A9AC9F` border with a 3 px inset inner `rule` `#C2C5BB` hairline |
| Number | none | `PL. XVII · fig. 1`, mono 10.5, `.14em` tracking, top-inline-start of the frame |
| Caption | the name only, in the row | Arabic Naskh 27 / serif 19 semibold / serif 15 English / serif italic 13.5 binomial |
| Rendered at | 44 px in list rows and search results | Full column width, 48 above the verdict stamp |
| What it claims | "this is roughly the shape you have" | "these are the characters that identify this specimen" |
| Legal weight | none | the identification the verdict rests on |

A silhouette is never enlarged into a plate slot and a plate is never shrunk into a row. They are
different drawings, generated from different authored files.

## When a plate is REQUIRED

| Surface | Species class | Required art |
|---|---|---|
| Result screen (the verdict) | any | PLATE |
| Species account | any | PLATE |
| Search result row | protected | PLATE (inline, at column width) |
| Search result row | look-alike pair member | PLATE |
| Search result row | ordinary | silhouette |
| Today / catch log row | any | silhouette |
| Zone browse list | any | silhouette |
| Empty state | n/a | NO art — one 44 px icon glyph at most (rule 10) |

The guard is an `assert` in the art resolver plus a widget test asserting that every species where
`isProtected || lookAlikeOf != null` resolves to `LonjaPlate` on every surface in the first column.

## Look-alike pairs

Both members of a pair carry a plate and a `lookAlikeOf` back-reference, so the plate can print the
distinguishing character in its caption.

| Pair | Distinguishing character to draw |
|---|---|
| `lethrinus_nebulosus` vs `lethrinus_lentjan` | Blue spangles on the scale centres and the cheek stripe pattern; `lentjan` has a red opercular margin. |
| `epinephelus_coioides` vs `epinephelus_malabaricus` | Orange spot density and the shape of the caudal blotch field. |
| `scomberomorus_commerson` vs `scomberomorus_guttatus` | Vertical bar count and continuity along the flank versus discrete spots. |
| `venerupis_corrugata` vs `ruditapes_decussatus` | Concentric versus crossed sculpture on the shell; siphon separation. |

The pairing DATA lives in the read-only reference database and is owned by
`catchlaw-reference-database`; this skill only binds what must be DRAWN when a pair exists.

## Plate anatomy and ink weights

| Element | `PlateInk` | Paper / night | Sunlight | Opacity |
|---|---|---|---|---|
| Body and fin outline | `outline` | 1.60 | 2.10 | 100% |
| Diagnostic markings, spots, bars | `outline` | 1.60 | 2.10 | 100% |
| Shading hatch (flank, belly) | `hatch` | 0.70 | 1.00 | 50% → 100% in sunlight |
| Structural hatch (fin rays, gill cover) | `hatchStrong` | 1.10 | 1.45 | 70% → 100% in sunlight |
| Frame border | drawn by `LonjaPlate` | 1.00 `rule-strong` | 2.00 `sun-ink` | 100% |
| Inner hairline, 3 px inset | drawn by `LonjaPlate` | 1.00 `rule` | 0 (deleted) | 100% |

In sunlight the inner hairline is DELETED rather than thickened — sunlight removes every grey, and a
second rule at full contrast would compete with the specimen.

Plates never carry colour. The species is `ink` `#16201C` on `paper` `#E6E4DC`, or `sun-ink`
`#000000` on `sun-paper` `#FFFFFF`. The only colour on a result screen is the verdict semantic.

## Provenance record

```dart
final class PlateProvenance {
  const PlateProvenance({
    required this.illustrator,
    required this.illustratorDeathYear,
    required this.sourceWork,
    required this.sourceYear,
    required this.licence,
  });
  final String illustrator;       // 'Francis Day' — a person, never 'unknown', never a studio alias
  final int illustratorDeathYear; // 1889 — the field that makes the PD claim checkable
  final String sourceWork;        // 'The Fishes of India'
  final int sourceYear;           // 1878
  final String licence;           // 'public-domain' | 'cc-by-4.0' | 'commissioned-work-for-hire'
}
```

| Field | Non-negotiable because |
|---|---|
| `illustrator` | An attribution obligation cannot be met by a plate that does not know who drew it. |
| `illustratorDeathYear` | The public-domain term is measured from it; without the year the claim is unverifiable and the plate is a liability. |
| `sourceWork` / `sourceYear` | Lets a reviewer find the original and confirm the plate was not traced from a modern field guide. |
| `licence` | Drives the attribution line rendered in Settings → Sources, and the CI licence report. |

For a commissioned plate, `illustrator` is the contracted artist, `illustratorDeathYear` is
`9999` as a sentinel, and `licence` is `commissioned-work-for-hire` with the contract reference in
the content manifest. Whether a given work is actually public domain in the UAE, Spain and Brazil is
DECIDED by `catchlaw-content-pipeline` — this skill only enforces that the record exists and is
complete.

## Generation pipeline

1. The illustrator delivers an SVG on the 300 × 124 grid, stroke-only, `stroke="currentColor"`, no
   `<style>`, no `<image>`, no embedded raster, no gradients, no `transform` on the root.
2. `catchlaw-content-pipeline` validates the SVG shape, extracts every `d` attribute in document
   order, tags each with its `PlateInk` from the authoring layer name (`outline` / `hatch` /
   `hatch-strong`), and emits `lib/design/plates/plate_specs.g.dart`.
3. The generator refuses to emit a `PlateSpec` whose provenance is incomplete or whose key is not a
   lower_snake_case binomial matching a row in the read-only reference database.
4. `plate_specs.g.dart` is committed, is never hand-edited, and is skipped by every gate script.

## Semantics and the caption

The plate takes one `semanticLabel` describing the DRAWING — "Engraved plate of an orange-spotted
grouper" — and the caption text is read separately as ordinary text. The plate number
(`PL. XVII · fig. 1`) is inside `ExcludeSemantics`: it is a printed-document affordance, not
information a screen reader needs before the species name. Label wording rules are owned by
`accessibility-as-code`; the Arabic caption line and its Naskh face are owned by `lonja-typography`.

## What a plate must never be

- A photograph, or a traced photograph.
- Coloured, tinted, or given a semantic verdict colour.
- Animated, parallaxed, or given a hero transition — it is a printed figure.
- Reused across two species because "they look the same" — that is precisely the look-alike case
  that requires two distinct plates.
- Mirrored in RTL. A specimen faces the way it was engraved.
- Cropped to a square avatar. The 300 × 124 aspect is the plate.
