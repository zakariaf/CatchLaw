# Product Invariants

The five things that are true of CatchLaw on every screen, in every locale, in every build — what
each one forbids, how it is proved, and the failure it exists to prevent. Structure and routing live
in `routing-table.md`; wording lives in `catchlaw-verdict-contract`.

## The five, at a glance

| # | Invariant | Forbids | Proved by | Failure if broken |
|---|---|---|---|---|
| 1 | 100% offline, no network code path | http, dio, sockets, connectivity, Firebase, analytics, auth | `check_app_invariants.sh` check 1 + `pubspec.yaml` audit | indefinite spinner at 05:40 with no signal |
| 2 | Verdicts state facts, never instruct | Keep / Return / Release / Throw it back, in Dart and in ARB | check 2 + `check_lonja_verdict.sh` | advice becomes our liability, not the rule's |
| 3 | Every result carries its citation | nullable `Citation`, verdict widgets with no citation slot | check 3 | an uncited verdict is an opinion |
| 4 | Colour is never the only signal | category-to-`Color` maps with no glyph | check 4 + greyscale golden | unreadable in sunlight and to 8% of readers |
| 5 | Stale rules are shown, not withheld | expiry returning early, gating, disabling or erroring | check 5 | no rule at all, with no way to refresh |

## 1 — No network code path

Not "offline-first". Not "cached". There is no code that could reach a network if it wanted to.

Banned in `pubspec.yaml` and `lib/`: `http`, `dio`, `chopper`, `retrofit`, `web_socket_channel`,
`grpc`, `connectivity_plus`, `internet_connection_checker`, `firebase_*`, `sentry_flutter`,
`amplitude_flutter`, `posthog_flutter`, `package_info_plus` phoning home, any auth SDK.
Banned symbols: `HttpClient`, `Socket.connect`, `WebSocket.connect`, `Uri.https`, `Uri.http`,
`RawDatagramSocket`, `NetworkAssetBundle`, `Image.network`, `InternetAddress.lookup`.

Allowed: `rootBundle`, `getApplicationSupportDirectory()`, `getApplicationDocumentsDirectory()`,
`Share.shareXFiles` for a user-initiated export, `url_launcher` ONLY for `mailto:` and `tel:` on the
about screen — never `https:` to fetch data.

Consequences that follow, and are not negotiable: no remote config, no feature flags fetched at
runtime, no OTA rule updates, no crash upload, no A/B test, no consent dialog (there is nothing to
consent to). Rule data changes only when a new build ships a new asset pack.

## 2 — Statement of fact, never an instruction

| Situation | WRONG (instruction) | RIGHT (statement) |
|---|---|---|
| 38 cm Hamour | "Throw it back" | "Below the minimum — 38 cm, minimum 45 cm (total length)" |
| 47 cm Hamour | "You can keep this" | "Meets the minimum — 47 cm, minimum 45 cm (total length)" |
| Sha'ri on 12 Mar | "Do not fish for this now" | "Closed season — 1 March to 30 April. In force today, day 12 of 61." |
| 70 cm Kanaad | "Keep it" | "Meets the minimum — 70 cm, minimum 65 cm (fork length)" |
| Protected species | "Release immediately" | "Protected species — taking prohibited. All sizes, all seasons, all gear." |

The banned lexicon (Dart string literals and every ARB value): keep, return, release, discard,
throw it back, put it back, toss, retain, land it, you can, you must, do not keep, safe to keep.
There is no exemption for a "friendly" hint, an onboarding screen, a tooltip or a share caption.

## 3 — The citation contract

`Citation` is a value type on the engine side, required and non-nullable on every verdict:

| Field | Example | Notes |
|---|---|---|
| `instrument` | `Ministerial Decision 580/2015` | as printed, never abbreviated to "MD 580" |
| `article` | `Art. 3` | the specific article, not the whole instrument |
| `publishedOn` | `2015-11-03` | ISO in data, locale-formatted on screen |
| `checkedOn` | `2026-07-14` | when a human last verified the wording |
| `packId` | `RAK-GULF v2026.2` | which shipped pack the text came from |

Rendered footnote: `Ministerial Decision 580/2015, Art. 3 · published 2015-11-03 · checked
2026-07-14`. Digits stay Western in every locale including `ar` and `ur`, because they are quoted
from a printed instrument (`lonja-typography`). Legal basis for reproducing the text at all: UAE
Federal Decree-Law 38/2021 Art. 3, Spain Art. 13 LPI, Brazil Lei 9.610/1998 art. 8 IV — official
texts are not protected works; `catchlaw-content-pipeline` records the per-jurisdiction basis.

## 4 — Colour is never the only signal

Three signals per state, at most one of which may be hue:

| State | Hue | Glyph | Word |
|---|---|---|---|
| meets | verdant `#2E5E3A` | check | "Meets the minimum" |
| below minimum | oxblood `#7A2320` | close | "Below the minimum" |
| closed season | ochre `#8A6A16` | event_busy | "Closed season" |
| protected | oxblood `#7A2320` | block | "Protected species" |
| stale data | ochre `#8A6A16` | warning | "Rule data expired 2026-06-30" |

Note that oxblood carries two different states: hue therefore distinguishes NOTHING between
below-minimum and protected, and the glyph plus wording plus table shape must. Proof is a greyscale
golden in `widget-golden-and-a11y-testing`, not an eyeball.

## 5 — Stale beats absent

| | Fresh pack | Expired pack |
|---|---|---|
| Evaluation | runs | runs, identically |
| Verdict stamp | shown | shown, unchanged wording and colour |
| Citation | shown | shown, plus a pack-validity footnote |
| Extra chrome | none | ochre `StaleRuleBar` under the app bar |
| Blocking | none | none — no modal, no disabled control, no empty state |
| Dismissable | — | no; it is a fact about the data, not a notice |

Bar copy: `Rule data expired 2026-06-30. The text below is the last verified wording.` The bar is a
statement of fact about the pack, so rule 2 applies to it as well — never "Update the app".

Edge cases:
- A pack with no `validUntil` is treated as valid, never as expired.
- A device clock behind the pack's `publishedOn` is a clock problem, not an expiry: still evaluate,
  still no block. Do not attempt to "correct" the clock; there is no time server.
- Two packs for one zone: the higher `packId` wins; both being expired changes nothing.

## Review checklist

1. Does any new dependency open a socket, even transitively? If unsure, it does — check `pubspec.lock`.
2. Does any new string tell the fisher to do something, in any of the six locales?
3. Can a verdict be constructed without a `Citation`? Make the field required, not asserted.
4. Print the screen in greyscale: does every state still read?
5. Set the device clock past `validUntil`: does the verdict still appear, with the bar and nothing else?
