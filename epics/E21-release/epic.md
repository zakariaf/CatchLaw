# E21 — Offline verification and release readiness

| | |
|---|---|
| **Branch** | `epic/21-release` |
| **Release** | **v2** — `epics/RELEASES.md`, D-22 |
| **After** | E20 merged |
| **Tasks** | 8 |
| **Spec** | `SPEC.md` §14 in full (5 static + 16 dynamic), §5.3, §11 (both platforms), §15 step 20, §13 |
| **Guide** | `FLUTTER_GUIDE.md` Part 4.6 (four layers), Part 9.3 (the Android manifest) |
| **Packages** | `app/`, plus `tools/gates/`, `docs/release/`, `store/` |

## What this epic achieves

The offline guarantee stops being a claim and becomes a file. Every one of the 21 checkboxes in
`SPEC.md` §14 is either running in CI against the artefact that will actually be uploaded, or has been
executed on a named physical device by a named person on a named date, with its evidence checked in.
At the end of this epic a stranger can open `docs/release/<version>/RELEASE-CHECKLIST.md`, read who ran
the packet capture on which handset, open the `.pcap` beside it, and see zero packets — without asking
anybody anything. The store listings exist in all six locales with per-locale display names, and the
Play data-safety form and the iOS privacy label can both honestly say that nothing is collected and
nothing is shared, because §11's release manifest makes it structurally true on Android and T02's
capture makes it observably true on iOS.

## Where we are now

E01 built the **static** half of §14: `check_no_network.sh` over `app/lib`, the source-level API grep,
the banned-package list in `app/pubspec.yaml`, `depend_on_referenced_packages: error`, and the
`tools/gates/` directory (D-8 put `no_directional_geometry.sh` there). E06 added the ARB-completeness
and Arabic-plural-category checks. E01/T08 proved every gate is scanning a non-empty tree.

What does not exist:

- Nothing has ever inspected a **built** artefact. Every existing check reads source. A source grep
  cannot see `android.permission.INTERNET` merged in by a plugin's own AAR manifest, which is exactly
  the case `tools:node="remove"` exists to defeat and exactly the case nobody has verified.
- No `.pcap` has ever been taken. No per-uid byte counter has ever been read.
- The device clock has never been moved. The expiry path (invariant 5) is unit-tested by E03 and
  widget-tested by E10, but has never been exercised against a real system clock on real hardware.
- Nothing has ever been reinstalled. `allowBackup="false"` is a line in a manifest that nobody has
  watched behave.
- `store/` does not exist. There is no listing, no screenshot plan and no data-safety answer.
- There is no artefact that records who checked what. The knowledge is in whoever last did it.

E17 shipped export and import, E13 shipped the catch log, E05 shipped the two databases and the
first-launch extraction, E20 shipped the six-locale golden matrix. All of them are inputs here.

## Why this epic exists here in the order

It runs after E20 because §14's dynamic block walks **every** screen S1–S23 and every dialog D1–D5, and
runs the whole loop in `ar` with RTL. Until E20 merged, the last screens did not exist and the RTL lane
was not green, so a walkthrough would have been a walkthrough of a partial app — and a partial
walkthrough is worse than none, because it produces a signed checklist that means less than it appears
to. It runs before nothing: E22 is content, cut from E04 and running in parallel, and adding a
jurisdiction does not re-open the network question.

It cannot move earlier for a second reason. The packet capture is taken against the **release** build
of the artefact that ships. There is no release artefact to capture until the app is complete.

## The tasks

| # | Task | File | Size | Depends on |
|---|---|---|---|---|
| T01 | The static block, automated | `T01-static-block-automated.md` | M | — |
| T02 | Packet capture, and what counts as evidence | `T02-packet-capture-evidence.md` | L | T01 |
| T03 | TrafficStats, and a delta of exactly zero | `T03-trafficstats-zero-delta.md` | M | T02 |
| T04 | The clock moved forward past `valid_to` | `T04-clock-forward-past-valid-to.md` | M | T02 |
| T05 | The clock moved backwards two years | `T05-clock-backwards-two-years.md` | S | T04 |
| T06 | Reinstall, and restore from an export | `T06-reinstall-and-restore.md` | M | T01, T02 |
| T07 | Store listings in six locales, and the data-safety form | `T07-store-listings-and-data-safety.md` | L | T01 |
| T08 | The release checklist, signed off | `T08-release-checklist-signed-off.md` | M | T01–T07 |

## `SPEC.md` §14 — every checkbox has an owner

Five static, sixteen dynamic, twenty-one in total. A checkbox with no owner is how a release ships
unverified, so the mapping is published here and asserted by a test in T01 and again in T08.

| # | §14 checkbox | Block | Owner |
|---|---|---|---|
| 1 | Direct-dependency allowlist diff (`http` from exactly `printing` and `flutter_svg`; `url_launcher_platform_interface` from `share_plus`) | static | T01 |
| 2 | The API grep over `lib/` returns nothing | static | E01 (wired), T01 (asserts it is a required check) |
| 3 | Built release `AndroidManifest.xml` via `aapt2 dump xmltree` on the AAB — no `INTERNET`, no background location | static | T01 |
| 4 | `Info.plist` declares no ATS exceptions and no `NSLocationAlwaysAndWhenInUse` | static | T01 |
| 5 | Every ARB key in all six locales; every `ar` plural has all six categories | static | E06 (wired), T01 (asserts it is a required check) |
| 6 | Cold first launch, fresh install, airplane mode on before the install completes; extraction under 6 s with a determinate bar | dynamic | T02 |
| 7 | Force-quit during first-launch extraction; relaunch; no corrupt DB left behind | dynamic | T02 |
| 8 | Full core loop with airplane mode on, Wi-Fi off, cellular off; then again with manual length entry before ever calibrating | dynamic | T02 |
| 9 | Every screen S1–S23 and every dialog D1–D5 reachable; S7 from S1, from S5's empty state and from S6 | dynamic | T02 |
| 10 | Arabic full-text search hits on `هامور` and on `الهامور` | dynamic | T02 |
| 11 | Citation tap expands S13 and copies to clipboard; no browser opens | dynamic | T02 |
| 12 | Export produces all four artefacts, share sheet appears, PDF renders Arabic with the bundled font | dynamic | T02 |
| 13 | Import of a previously exported zip succeeds | dynamic | T02 |
| 14 | Location denied: S9 stays usable and states why nothing was suggested | dynamic | T02 |
| 15 | Camera denied: catches still recordable without a photo | dynamic | T02 |
| 16 | Expiry test — bar **and** an intact finding | dynamic | T04 |
| 17 | Clock backwards two years — seasonal rules evaluate, date used is displayed | dynamic | T05 |
| 18 | Reinstall: catch log gone; a pre-taken export restores it completely | dynamic | T06 |
| 19 | Packet capture, not a proxy; zero packets from the app uid | dynamic | T02 |
| 20 | `TrafficStats` per-uid byte counters — delta exactly zero | dynamic | T03 |
| 21 | The whole loop in `ar` with RTL: ruler LTR, resolved numeral system, no overflow | dynamic | T02 |

`SPEC.md` §15 step 20 (store presence) is T07. §5.3's honest iOS sentence is carried verbatim by T02
and T07. §13's first-launch budget (< 6 s) and cold-start budget (< 1.2 s) are measured on device
inside T02's walkthrough and recorded on T08's checklist.

## Definition of done for the epic

Every task's own definition of done, plus what only closes at the epic level:

- [ ] All 8 tasks committed, one commit each, every `Task:` trailer present.
- [ ] All 21 §14 checkboxes have a result in `docs/release/<version>/RELEASE-CHECKLIST.md`; none reads
      `TBD`, none reads `n/a` on a dynamic row.
- [ ] `.github/workflows/release-gates.yml` is green on the branch and its jobs are required checks.
- [ ] An Android `.pcap` and an iOS `.pcap` exist under `docs/release/<version>/evidence/`, each taken
      against the **release** build with connectivity **up**, each showing zero packets from the app.
- [ ] The `TrafficStats` rx and tx deltas across the full walkthrough are both exactly `0` — not "near
      zero", not `-1`.
- [ ] The device clock has been moved forward past a named rule's `valid_to` and backwards two years on
      a physical device, and both results are recorded with the rule id used.
- [ ] A reinstall has been performed on Android and the catch log was empty afterwards; the pre-taken
      export restored every trip, catch and flag.
- [ ] `store/listings/` holds exactly the six D-3 locales — `ar`, `en`, `es`, `gl`, `ca`, `pt_BR` — with
      no `ur` directory and no locale-less `pt`.
- [ ] Screenshots exist for `ar` and for `gl`, shot on device rather than composited.
- [ ] `.claude/skills/catchlaw-offline-guarantee/scripts/check_no_network.sh app/lib` clean.
- [ ] `.claude/skills/catchlaw-conventions-index/scripts/check_app_invariants.sh app/lib` clean.
- [ ] `app/lib` contains no `TrafficStats`, no `MethodChannel` and no test-harness symbol — the
      measurement apparatus did not leak into the shipped app.
- [ ] PR checks all SUCCESS; PR merged with `--squash --admin`; branch deleted.

## Risks and the things that will bite

**Two physical devices are a hard precondition, and one of them must be an iPhone.** §14's dynamic
block is not runnable on an emulator: `rvictl` requires a real device over USB, and a simulator's
network stack is the Mac's. `SPEC.md` §13 names a Snapdragon 665 as the low-end Android reference for
the < 6 s and < 1.2 s budgets. *Resolves it:* name both devices (model and OS version) in the checklist
header before T02 starts. If no iPhone is available the epic cannot close honestly — say so on the PR
rather than marking row 19 passed on Android alone, because §5.3 puts the entire iOS guarantee on that
capture.

**A clean Android capture can be clean for the wrong reason.**
`references/verification-ritual.md` failure triage: the kernel refuses the socket when `INTERNET` is
absent, so an Android capture proves the OS is working, not that the Dart code is silent. *Resolves
it:* T03's profile-build run, which retains `INTERNET` by design, is the diagnostic where a real call
would produce bytes. An iOS capture that is dirty while Android is clean is a genuine defect and must
be triaged as one.

**`aapt2` may not be on the CI runner at a version we can name.** It ships inside Android SDK
build-tools; the GitHub-hosted image's resolved build-tools version is not something this plan can
assert. *Resolves it:* T01 resolves `aapt2` from `$ANDROID_HOME/build-tools/*/aapt2`, exits 2 when it
finds none, and logs the resolved absolute path so the checklist can record which binary produced the
dump.

**`TrafficStats.getUidRxBytes` can return `UNSUPPORTED` (`-1`).** It is supported for the caller's own
uid, and minSdk is 24, but OEM behaviour is not something this plan can assert. *Resolves it:* T03
treats any `-1` as INVALID rather than as zero, records the raw values, and falls back to a cross-check
with `adb shell dumpsys netstats detail` so a single instrument is never the only witness.

**A reinstall reassigns the app uid.** `TrafficStats` counters are per-uid and cumulative since boot,
so the two reads in T03 are only comparable across a single install. *Resolves it:* T03 records
`Process.myUid()` at both reads and fails the run when they differ, rather than silently comparing two
different apps' counters.

**Moving a device clock has side effects beyond the app.** Certificates expire, some system services
wedge, and Google Play services on Android may re-sync aggressively when time is restored — noise that
would contaminate a capture. *Resolves it:* T04 and T05 run on a dedicated test device, automatic time
is restored immediately afterwards, and the clock tests never share a session with the packet capture.

**App Store Connect may not offer Galician as a listing localisation.** Play supports `gl-ES`; the
App Store's storefront-localisation list is shorter and this plan cannot assert its contents.
*Resolves it:* open App Store Connect → App Information → Add Language and read the list before T07
writes the iOS half. If `gl` is absent, `store/listings/gl/` still ships for Play, and
`store/README.md` records the platform gap as a fact rather than dropping the locale.

**`PrivacyInfo.xcprivacy` reason codes cannot be guessed.** Apple's required-reason API list changes and
each plugin ships its own privacy manifest. *Resolves it:* T07 derives `NSPrivacyAccessedAPITypes` by
reading the bundled manifest of every plugin in `app/pubspec.yaml` and records the source of each entry;
it never invents a code.

**A skill text disagrees with `SPEC.md` about `url_launcher`, and this epic does not settle it.**
`catchlaw-conventions-index/references/product-invariants.md` §1 permits `url_launcher` for `mailto:`
and `tel:` on the about screen. `SPEC.md` §10 bans the package outright and §5.3 grep-bans `launchUrl`;
`catchlaw-offline-guarantee/references/four-layers.md` lists it as banned. This epic follows `SPEC.md`:
no `url_launcher` at any depth, and the only allowlisted edge is `url_launcher_platform_interface` from
`share_plus` (§14 static row 1). This is a gap in the skill text, not a decision to make here — it is
recorded for a follow-up correction alongside the E01/T09 skill fixes, and no task in this epic invents
a local convention around it.

**A second skill text disagrees with `SPEC.md`, this time about `dataExtractionRules`.**
`catchlaw-reference-database/references/two-database-contract.md` prescribes excluding
`files/reference/` from backup with `android:dataExtractionRules` or `android:fullBackupContent`;
`SPEC.md` §11 declares `android:allowBackup="false"` and no `dataExtractionRules` at all. They are not
contradictory so much as layered — with backup off there is nothing to exclude — but a builder reading
the skill will add an attribute §14 row 18's gate then rejects. T06 follows `SPEC.md` and bans both
attributes. *Resolves it:* one clarifying sentence in the skill reference, alongside the E01/T09
corrections. Not settled inside a task file.

**The integration tests in this epic do not replace the manual pass.** `testing-strategy`'s
`references/coverage-and-budget.md` is explicit that a green test which appears to cover a
structurally-untestable path stops anyone checking by hand. The walkthrough test exists to make the
walk reproducible and to give T03 a deterministic exercise between two counter reads. Every §14 dynamic
row is still ticked by a human on hardware. Any task file that starts to read as though the automation
discharges the manual row is wrong and must be corrected before the commit.

## PR description

### What changed

- `.github/workflows/release-gates.yml` builds the release AAB and inspects it: `aapt2 dump xmltree` on
  `base/manifest/AndroidManifest.xml` for `INTERNET`, background location, `allowBackup` and
  `dataExtractionRules`; `Info.plist` for ATS exceptions and `NSLocationAlwaysAndWhenInUse`; and
  `flutter pub deps` diffed against `docs/deps-allowlist.txt`.
- `docs/offline-exercise.md` — the reproducible S1–S23 / D1–D5 exercise script, with export, import,
  GPS, camera, PDF render and SVG load called out as their own steps.
- `docs/release/packet-capture.md`, `traffic-stats.md`, `clock-tests.md`, `reinstall-and-restore.md` —
  four procedures, each naming the tool, the build type and the pass criterion.
- `app/integration_test/` — the driven walkthrough plus the clock-forward, clock-backward and
  reinstall-restore cases.
- `app/android/app/src/androidTest/` — a JUnit rule that brackets the walkthrough with per-uid
  `TrafficStats` reads. It exists only in the `androidTest` source set and never ships.
- `store/` — six localised listings, per-locale display names for both platforms, the screenshot plan
  shot in `ar` and `gl`, and the data-safety answers.
- `docs/release/<version>/RELEASE-CHECKLIST.md` — 21 rows, each signed with a person, a device and a
  date, each pointing at its evidence file; plus the gate that refuses an unfilled one.

### Why

`SPEC.md` §5.3 puts the iOS offline guarantee entirely on the dependency allowlist, the API grep and a
device packet capture. Two of those three were already automated; the third had never been performed.
§14's dynamic block was a list nobody had executed against the finished app. This epic executes it and
turns the result into an artefact, so the next release starts from evidence rather than from memory.

### How it was verified

Static rows in CI on this branch. Dynamic rows on the two devices named in the checklist header, on the
release build, by the person named on each row. The two `.pcap` files, the `aapt2` dump, the `pub deps`
snapshot and the `TrafficStats` log are attached under `docs/release/<version>/evidence/`.

### Product invariants touched

Invariant 1 (no network code path) is the subject of T01, T02 and T03 and is strengthened, never
weakened. Invariant 5 (a stale ruleset is still evaluated and still shown) is the subject of T04, which
asserts the finding survives expiry rather than asserting only that a bar appeared. Invariants 2, 3 and
4 are re-checked in passing by the walkthrough and by T07's listing gate — a store description is the
one place a verdict-shaped sentence can escape the app.

### Follow-ups deliberately not in this PR

- The `url_launcher` discrepancy in `product-invariants.md` §1 (see Risks) — a skill correction, not an
  app change.
- Promoting the layer-4 guard test to an `analysis_server_plugin` (`FLUTTER_GUIDE.md` §4.6 suggests it):
  a real improvement, but it changes an IDE experience and not the release evidence.
- Any second release's checklist. This epic ships the template and the first filled instance.

## The epic loop

Full ritual in `CONVENTIONS.md` §1. In short: branch from a current `main`; one commit per task;
`gh pr create`; `gh pr checks --watch`; merge only on all-green with
`gh pr merge --squash --admin --delete-branch`; then and only then start the next epic.
