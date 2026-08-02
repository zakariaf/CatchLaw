### What changed

`app/lib/theme/` in full, and the first four Lonja components.

- `lonja_primitives.dart` — 25 pigments, each named for its measured CIE L\*, read by nothing
  outside `lib/theme/`.
- `lonja_tokens.dart` — the 4 pt spine, the four rule weights, the radius ceiling of 2, the motion
  durations, `LonjaDensity`, and the `LonjaTokens` `ThemeExtension`: thirteen semantic slots plus
  density, value equality over every field, an asserting `of(context)`, a `copyWith` **narrowed to
  density**, and a `lerp` in which density snaps rather than interpolating.
- `lonja_theme.dart` — `LonjaPalettes.paper`, `.night`, `.sunlight`, each with all thirteen slots
  written out; the three builders, `LonjaSkin`, and `resolveLonjaTheme(skin:, gloved:)`.
- `lonja_faces.dart`, `lonja_typography.dart` — four system stacks, sixteen named steps, tabular
  figures on every mono step, and the `ar` variant resolved at `of(context)` time.
- `lonja_button_style.dart`, and `app/lib/ui/core/ui/`: **`LonjaRule`, `LonjaPanel`,
  `LonjaPlateSurface`, `LonjaButton` and `showLonjaConfirm`** — four components, named by path here
  because E08's epic file states none exist after E07 and will otherwise re-author them.
- `app/testing/theme/` — the transcribed pigment, palette, contrast and ramp tables, the CIE
  arithmetic the proofs use, the `pumpLonja` harness, and the specimen sheet the goldens render.

### Why

`SPEC.md` §11 "Both" makes sunlight a third theme and not a variant; §4.9 makes glove mode a target
size requirement and colour independence a correctness requirement; §13 puts numbers on both. D-2
puts the palette at `app/lib/theme/` because every `lonja-*` gate exempts token constructs by the
path fragment `/theme/`.

Two decisions carry the epic. **Sunlight is authored, not derived** — the tempting
`paper.copyWith(...)` leaves `onSurfaceFaint` at 4.60:1 and `hairline` at 1.75:1, both of which are a
measured pass on a bench and a failure in the hand. At ~100,000 lux the *middle* of the tonal range
disappears first, so sunlight deletes the middle rather than compressing it, and what survives is the
verdict. **And the action ladder is graded by field, outline and rule weight, never by hue** — in
greyscale the primary and destructive fields are 2.3 L\* apart, which is visually the same box.

### How it was verified

- CIE L\* computed from every hex and compared with the tabled decimal (±0.05) and with the integer
  in the pigment's own name (±0.6). The proof was shown to discriminate by nudging `ink11` one hex
  digit and watching the ARGB row fail.
- All 33 published contrast ratios re-derived from the WCAG formula and compared to two decimal
  places, then checked against their own floors — which are deliberately **not** flattened:
  `onSurfaceFaint` at 3.62:1 and `ochre47` at 3.97:1 are asserted as documented sub-floor values.
- 39 binding assertions, one per slot per palette; sunlight proved authored by sharing **exactly two**
  slot values with paper, where a `copyWith` sunlight would share six neutrals and both hairlines.
- All sixteen type steps compared against the transcribed ramp; every Arabic step proved to be ×1.12
  at zero tracking on the Naskh stack, with `binomial` the one step that keeps the Latin serif.
- Eight golden lanes plus four greyscale assertions, and a row proving each gate target is non-empty
  before any green is read.
- Every gate clean with an explicit target directory, checked by exit code rather than through a pipe.

### Product invariants touched

None weakened.

1. **No network path** — the four faces are system stacks; nothing is fetched, and two gates grep for
   the runtime-webfont package.
2. **A verdict states a fact** — no verdict wording ships here. `showLonjaConfirm` requires its
   `cancelLabel` and supplies no default precisely because every wording
   `lonja-dialogs-and-surfaces` rule 3 tables opens with a verb `check_app_invariants.sh` check 3
   fails (epic risk 2).
3. **Citation required** — untouched.
4. **Colour is never the only signal** — this is the epic that makes it enforceable, and T08 is where
   it stops being a slogan.
5. **An expired ruleset is still shown** — untouched; the ochre bar is E10's.

### Known gaps, deliberately visible

- The committed golden PNGs were blessed on macOS and are placeholders; no Linux host is available
  here. The pixel rows **skip out loud** off Linux, and the follow-up commit on this branch replaces
  them with the bytes the Linux lane produces.
- Epic risks 1, 2, 3 and 5 are unreconciled skill-file disagreements. Each is resolved in this epic
  by taking `lonja-design-tokens` as the owner of values (the routing table's own rule) and is
  recorded rather than re-argued; none is edited here, because they are outside this epic's files.
