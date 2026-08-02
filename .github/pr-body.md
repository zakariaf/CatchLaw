### What changed

Six-locale localisation infrastructure, end to end, with no screen work.

- `app/lib/l10n/` — **seven** ARB files for six languages, `l10n.yaml`, `gen-l10n` output committed
  to git (`FLUTTER_GUIDE.md` §7.4), `MaterialApp` wired with `supportedLocales` and the `Global*`
  delegates. The seventh file is **D-18**, raised in this PR: `gen-l10n` on the Flutter D-5 pins
  throws before it generates a line when a region locale has no base beside it, so `app_pt_BR.arb`
  cannot ship alone. D-3's substance is untouched.
- CI now fails on a missing ARB key, a mismatched placeholder, or an `ar` plural message missing one
  of the six ICU categories (`SPEC.md` §14, static row 5).
- `ContentStringResolver` implements the §9.2 fallback chain: requested locale → jurisdiction
  `default_locale` → `en` → scientific name. A missing string throws with its key; it never renders
  one.
- `applyNumeralSystem` swaps `numberFormatSymbols['ar']`, driven by `user_profile.numeral_system` —
  not by a `-u-nu-` locale extension, which `intl` accepts as a string and discards.
- `tools/gates/no_directional_geometry.sh` bans physical-side geometry across `app/lib` (D-8).
- `LocaleNotifier` persists the S14 override in `user_profile.locale_override`, independently of the
  system locale (`SPEC.md` §11).
- `LegalTextAvailability` states which language a verbatim instrument exists in and never substitutes
  another (`SPEC.md` §9.6).
- `app/test/flutter_test_config.dart` loads Noto Naskh Arabic via `FontLoader` and guards the numeral
  symbol map; the golden lane is tagged and pinned to Linux CI.

### Why

`SPEC.md` §15 step 5 puts this fifth on purpose. Directional geometry, plural categories and a numeral
lever are all cheap to establish and expensive to retrofit, and each of them fails in exactly one locale
out of six — the one nobody develops in.

Two findings drove the shape of the work. `FLUTTER_GUIDE.md` Part 9.1: `intl` has **no**
numbering-system API, its `number_symbols_data.dart` carries only `ar`, `ar_DZ` and `ar_EG`, so `ar_AE`
silently falls back to `ar` and renders Latin digits — which CLDR 48 says is **correct** for Khalid, and
which the first draft of the spec asserted backwards. `SPEC.md` §9.5: `es`, `ca` and `pt` each carry a
CLDR `many` category. Both corrections are now assertions in the suite rather than sentences in a
document, checked against `Intl.plural` itself rather than against the table.

### How it was verified

- `flutter test` across `app/` — 497 rows, run twice and once under a random seed, because a leaked
  process-wide symbol map is order-dependent by nature.
- `check_arb_parity.sh app/lib/l10n`, `check_i18n_bans.sh app/lib`, `check_app_invariants.sh app/lib`,
  `no_directional_geometry.sh app/lib`, and all seventeen skill-gate invocations, each with an explicit
  target directory (D-1: they exit 2 on a missing directory).
- Both new gates were **watched failing** before being trusted: `app_es.arb` lost its `many` branch and
  `app_ar.arb` lost a key, and each gate named the file and the key. The directional gate is tested
  over fourteen fixtures.
- The font-coverage row was watched failing with `loadCatchlawFonts()` disabled: the Naskh string and
  the fallback string lay out at exactly 240.0 pixels each, which is the worthless-`ar`-golden state
  `FLUTTER_GUIDE.md` §6.4 warns about.

### Product invariants touched

None weakened. `CONVENTIONS.md` §9:

1. **No network path** — nothing added opens a socket; `google_fonts` is banned by two gates and the
   fonts are bundled assets. The two new dependencies are `flutter_localizations` (SDK) and `intl`,
   whose only children are `clock`, `meta` and `path`.
2. **A verdict states a fact** — T07's language-availability notice is a statement about the data
   ("this text exists only in Arabic"), checked against the banned-imperative lexicon in every locale.
   `settingsLanguageSystemDefault` reads "Device language" rather than "Follow the device" for the same
   reason.
3. **Citation required** — untouched. Citation dates are ISO strings, not `NumberFormat` output, so no
   symbol swap can reach them. E10 owns the assertion; this epic owns not breaking it.
4. **Colour is never the only signal** — untouched.
5. **An expired ruleset is still evaluated** — untouched. An unresolvable `content_string` is **absent**,
   not stale, and the two are kept as separate words here as everywhere.

### Known gap, deliberately visible

The committed golden PNGs were blessed on macOS and are placeholders — no Linux host or container is
available in this environment. The pixel rows **skip out loud** off Linux rather than reporting a green
tick for bytes nobody verified, and the golden job uploads the actual images on failure. The follow-up
commit on this branch replaces them with the bytes that job produces.

### Follow-ups deliberately not in this PR

- **E07** — the Lonja type ramp, the Naskh optical uplift and the font subset. This epic lands the faces
  the goldens need; the ramp that consumes them is E07's.
- **E16** — S14's language and numeral-system controls, and D5's first-run language dialog. T04 and T06
  land the state and the persistence; the screens are E16's and E12's.
- **E15** — S13's rule-text reader. T07 lands the availability rule and its notice string.
- **E20** — the full golden matrix across screens, and the §9.4 acceptance test on real content.
- **E22** — native-speaker review of every ARB value. The gates enforce **structure** — key parity,
  plural categories, no imperative — never wording quality.
