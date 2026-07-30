# The Four States

The non-happy states every CatchLaw list must author — empty, loading, error and stale — with their
precedence, geometry, copy rules and golden coverage.

## Precedence

Three states are exclusive bodies. One is not.

| Order | State | Replaces the list? | Trigger |
|---|---|---|---|
| 1 | `error` | yes | the read failed — a corrupt asset DB, a failed open |
| 2 | `loading` | yes | first frame of an `AsyncValue` before data arrives |
| 3 | `empty` | yes | the query succeeded and returned zero rows |
| 4 | `data` | — | one or more rows |
| — | `stale` | **no** | `pack.checkedAt` is older than the freshness window |

`stale` is ORTHOGONAL. It composes with `data` and with `empty`; it never composes with `error` or
`loading` because there is nothing yet to qualify. A list whose rule pack has expired still renders
every row it has — a stale rule beats no rule at sea.

```
if (error)   -> LonjaErrorState
else         -> Column([ if (stale) LonjaStaleBar, (loading | empty | data) ])
```

Never collapse `empty` into `loading`. A list that shows a skeleton forever when the answer is
genuinely "nothing here" is the most common way this contract is broken.

## Empty

The single mandatory state. A list that can return zero rows and does not author this is a defect and
fails `scripts/check_lonja_lists.sh`.

| Part | Rule |
|---|---|
| Plate | engraved line art, `ink` on `paper`, 96–140dp tall; never a 3-D or coloured illustration |
| Headline | serif 21sp, states the absence as a fact: "No trips recorded on this device" |
| Body | serif 15sp `ink-muted`, one or two lines: why it is empty, or what is held instead |
| Action | exactly ONE `LonjaButton.primary`; two competing actions is a defect |
| Colour | no semantic colour — an empty list is not a verdict |

Authored empty copy, per surface:

| Surface | Headline | Body | Action |
|---|---|---|---|
| Trips | No trips recorded on this device | Trips are kept here only. Nothing is uploaded, and nothing is fetched. | Start a trip |
| Today | No fish recorded on this trip yet | Checks are kept whether or not the fish was retained. | Record a check |
| Search | No species matches "قباب" | 3,180 entries are held for Ras Al Khaimah. Try the Arabic name, the English name, or browse by shape. | Browse by shape |
| Zone species | No species listed for this zone | The rule pack for Represa de Jurumirim holds 214 entries; none is filtered by your current chips. | Clear filters |
| Bookmarks | Nothing saved yet | Saved species open first when there is no signal — which is always. | Browse the reference |

Never: "Oops", "Nothing to see here", an exclamation mark, an emoji, or an imperative aimed at the
fish. The empty state is a printed notice, not a mascot.

## Loading skeleton

CatchLaw reads two local SQLite files. A read is fast, but a cold asset-DB open on a five-year-old
Android is not free, so the skeleton is real — it just must never look like a network.

| Rule | Detail |
|---|---|
| Shape | a ruled skeleton of the REAL row: 52 x 30 silhouette block, two text bars, one hairline |
| Fill | `paper-sunk` #DEDBD1 blocks on `paper`; in sunlight mode, hairline outlines with no fill |
| Count | exactly 6 skeleton rows; never a count derived from the pending query |
| Motion | a 900ms opacity pulse, 0.55 → 1.0; `Duration.zero` under reduced motion |
| Banned | `CircularProgressIndicator`, `LinearProgressIndicator`, any spinner, any percentage |
| Banned copy | "Loading…", "Fetching…", "Syncing…", "Downloading…", "Connecting…" |

Determinate progress IS allowed in exactly one place: the one-time first-launch seed of the asset DB,
where a real count exists ("about 4 seconds remaining"). That bar belongs to
`catchlaw-offline-guarantee`, not here.

## Error

A list error in CatchLaw is always local: a corrupt asset DB, a failed `openDatabase`, a schema
mismatch. It is never a network error, because there is no network.

| Part | Rule |
|---|---|
| Tone | `oxblood` #7A2320 for the glyph and the rule above the headline only — never a filled panel |
| Headline | states the fact: "The rule pack could not be opened" |
| Body | names the consequence in the fisher's terms and what still works |
| Action | one retry, plus a secondary route to what still works offline |
| Diagnostic | a mono 10sp line with the failure code, e.g. `RULEPACK_OPEN_FAILED · v2026.2` |
| Banned copy | "Check your connection", "Try again later", "Server error", any cloud glyph |

Typed failures come from `Result<T, F extends Failure>` — owned by `error-handling-typed-results`.
This skill binds only how the failure is drawn.

## Stale

The Lonja-specific state, and the one most often got wrong. The bundled rule pack carries a
`checkedAt` date; when it is older than the freshness window, everything still works and the fisher is
told the paper is old.

| Part | Value |
|---|---|
| Placement | directly under the app bar, above the list; `flex: none`, never floating |
| Ground | `ochre-t` #E8E0C6 |
| Rules | 1px `ochre` #8A6A16 top AND bottom |
| Glyph | warn, 17 x 17, `ochre` |
| Label | sans 11.5sp: "Rule data expired" |
| Detail | mono: "Ministerial Decision 580/2015 · checked 2026-07-14" |
| Row marker | `LonjaPill` `STALE DATA` in ochre on any affected row |
| Dismissable | no — it persists for as long as the condition holds |
| Blocking | no — it never covers, dims or disables the list |

**Ochre is not oxblood.** Oxblood means the fish fails the rule. Ochre means the paper is old. A stale
pack rendered in oxblood tells Khalid he has committed an offence when he has not, and the cost of
that confusion is that he stops trusting the colour at all.

Every stale surface also carries its citation — instrument, article, publication date, checked date —
because a stale rule the fisher can date is still usable and an undated one is not.

## Golden coverage matrix

Per list screen, the minimum lane set. `widget-golden-and-a11y-testing` owns the harness.

| Lane | Theme | Density | Locale | State |
|---|---|---|---|---|
| 1 | paper | default | `en` | data |
| 2 | paper | default | `ar` | data |
| 3 | paper | glove | `ar` | data |
| 4 | night | default | `en` | data |
| 5 | sunlight | default | `en` | data |
| 6 | paper | default | `en` | empty |
| 7 | paper | default | `ar` | empty |
| 8 | paper | default | `en` | loading (reduced motion, so the pulse is frozen) |
| 9 | paper | default | `en` | error |
| 10 | paper | default | `ar` | stale + data |
| 11 | sunlight | glove | `ar` | stale + data |

Lane 6 and lane 7 are the ones reviewers skip and the ones that catch the defect: an empty state that
was never authored renders as a blank frame, and a blank golden passes review far too easily. Assert
on the headline text, not only on the pixels.
