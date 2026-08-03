# Releases

`epics/README.md` is the build order. **This file is the release order**, and where the two disagree
this one wins (D-22).

Ten epics are merged and there is no application. `flutter run` today opens a window containing a
`SizedBox.shrink()`: the theme, the six locales, the rule engine, the reference database, the species
screens, the ruler and the whole result surface are all built, all tested and all unreachable. Nothing
routes to them, nothing evaluates a rule, and the shipped pack carries one species and **zero rule
rows**.

That is the gap v1 closes, and it is much smaller than the ninety tasks left implies.

---

## v1 — one jurisdiction, one question, answered offline

**The claim v1 makes:** a fisher in Galicia opens the app, picks his zone once, finds a species,
measures it, and reads a cited verdict. Offline, in six languages, with the instrument named under it.

**The claim v1 does not make:** that it covers the Gulf or Brazil, that it remembers his catch, that
it identifies a fish from a photograph or a key, that it exports anything, or that the accessibility
and RTL work has been *proved* rather than *written*.

### The thirteen tasks

**Built in three branches, in this order**, because `CONVENTIONS.md` gives one branch per epic and
E12 cannot pick a zone until E11 has one:

```
epic/11-zones            E11/T04, T05, T08, T07
epic/12-check-home       E12/T08 first, then T01, T05, T02, T04, T06, T07
epic/22-content-galicia  E22/T01, T10
```

The `Order` column below is the order the tasks are BUILT within that. E12/T08 is first inside its
epic and not first overall: it is the keystone, and it is also the one E12 task that needs nothing
from the rest of E12 — so it lands before the screens that consume it, which is what "first" was
protecting.

| Order | Task | Why it is in v1 |
|---|---|---|
| 1 | E11/T04 — S9 country · region · subzone | The fisher has to say where he is before anything can be evaluated |
| 2 | E11/T05 — no polygons, no subzone level | The shipped pack sets `has_zone_polygons: false`; this is the path it takes |
| 3 | E11/T08 — water type belongs to the zone | A freshwater rule answered for a sea zone is a wrong verdict |
| 4 | E11/T07 — saved zones and instant re-evaluation | §4.4: switching zone re-answers without a round trip |
| 5 | **E12/T08** — the evaluation seam ⭑ new | The keystone nobody owned. Without it there is no app, only screens |
| 6 | E12/T01 — bottom navigation | The front door. `home:` stops being an empty box |
| 7 | E12/T05 — no jurisdiction set | The first-launch state, which is every fisher's first ten seconds |
| 8 | E12/T02 — the Check screen | S1: search, recents, the three entry points |
| 9 | E12/T04 — empty state and keyboard | The state a new install sits in |
| 10 | E12/T06 — cold-start budget | §13's < 1.2 s, measured rather than hoped for |
| 11 | E12/T07 — the five-second core loop | The acceptance test. If this passes, v1 is real |
| 12 | E22/T01 — authoring guide and reviewer protocol | The protocol the first real rules are authored under |
| 13 | **E22/T10** — Galicia rule rows and verbatim text ⭑ new | Without a rule row every answer is "no rule recorded" — true, and useless |

Two of the thirteen are new files written by this change; the other eleven already exist and are
unedited.

### What v1 ships without, deliberately

| Absent | Why it costs nothing yet |
|---|---|
| the catch log | a bag-limit finding prints *"Nothing recorded for this period"*, which is already implemented, already tested, and already true |
| plates and silhouettes | E08 treats a null plate as the NORMAL case, because a plate ships only when its illustrator died in 1945 or earlier |
| the About screen | nothing is bundled that needs attributing until the plates are |
| Settings | the locale follows the device, and the ruler carries its own calibration |
| GPS | §11 makes it a suggestion whose denial must cost nothing; its absence costs the same |
| the identification key | S5's search and S6's shapes are both shipped, and §4.3 requires three entry points of which two exist |
| polygons | there are no coordinate lists in the pack to test against. Rules apply jurisdiction-wide, which is what `SPEC.md` §8 says to do when no coordinate list is printed |

---

## v2 — everything else, in the order it stops hurting

Seventy-nine tasks. The order below is by what v1 shipping will make you want first, not by epic
number.

| Group | Epics | What it adds |
|---|---|---|
| **The second jurisdiction** | E22 T02–T09 | The Gulf, then Brazil. The product's own headline case is Khalid in Ras Al Khaimah, and v1 does not serve him |
| **Proving what v1 asserts** | E19, E20, E21 | The greyscale golden, the six-locale matrix, the packet capture, the clock-forward run. v1 *writes* these guarantees; v2 *proves* them |
| **The second surfaces** | E13, E14, E15, E16, E17, E18 | Catch log, identification key, reference, settings, export, about |
| **The rest of place** | E11 T01, T02, T03, T06 · E12/T03 | Polygons, the 100 ms budget, GPS, the tally bar — each waiting on data or on a surface v1 does not have |

---

## The rule for moving a task between releases

The same shape as the amendment rule, for the same reason: a plan that changes quietly is a plan
nobody can rely on.

1. **Change the row here first.** This file is the release order.
2. **Say what it costs.** A task pulled into v1 delays v1; a task pushed to v2 removes a claim v1 was
   making. Name the claim.
3. **Update the task file's `Release:` line and its epic's**, in the same change.
4. **A v2 task in a v1 epic is not a failure of that epic.** The epic merges when its v1 tasks are
   done; the deferred ones land later, on their own branch, and the epic's row in `README.md` records
   which.

## What did NOT change, and why

**No epic and no task was renumbered.** `E10/T01` appears in commit trailers, in `DECISIONS.md`, in
skill files and in twenty task files, and an identifier that means one thing in the history and
another in the tree is worse than an ugly order. Two tasks were **added** with the next free numbers —
`E12/T08` and `E22/T10` — and both say in their own headers that they are built first in their epic.
Numbers here are names, not an order.
