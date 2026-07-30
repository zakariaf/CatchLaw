# Verification Ritual

Scope: how to PROVE, per release, that CatchLaw emitted no packet — why an HTTP proxy is not
evidence, the Android and iOS capture procedures, the pass criteria, the release checklist, what
evidence to keep and how to triage a hit. The invariants themselves live in
`references/four-layers.md`.

## Why a proxy is not evidence

The instinct is Charles, Proxyman or mitmproxy. All three are worthless here.

| Tool | What it observes | Why it cannot prove absence |
|---|---|---|
| Charles / Proxyman / mitmproxy | traffic routed through the system proxy | Dart's `HttpClient` IGNORES the system proxy unless `findProxy` is set; a Dart request never appears |
| Android "private DNS off" screens | DNS only | a request to a literal IP resolves nothing and is invisible |
| Store network-usage reports | aggregated, delayed, sampled | arrives weeks after the release it would have condemned |
| **Packet capture (tcpdump / PCAPdroid / rvictl)** | **every packet on the interface** | **nothing to bypass — this is the evidence** |

A clean proxy session is the classic false pass: it looks like the strongest possible test and is
structurally incapable of failing. Never attach one to a release tag.

## Android — PCAPdroid, no root

1. Build and install the RELEASE artefact, not debug: `flutter build apk --release` then
   `adb install -r build/app/outputs/flutter-apk/app-release.apk`.
2. Install PCAPdroid. Set the capture target to the CatchLaw app only, mode "PCAP file".
3. Put the device in AIRPLANE MODE OFF with wifi on — a capture with no connectivity proves nothing,
   because the app must have had the opportunity to call out.
4. Start capture, then exercise for five minutes: cold start, first-launch extraction, species
   search for هامور, measurement 38 cm TL, verdict, citation view, PDF export, locale switch to
   Arabic, background and resume.
5. Stop, export the `.pcap`, and confirm zero packets attributed to the CatchLaw UID.

## Android — adb and tcpdump, rooted or emulator

```
adb shell "su -c 'tcpdump -i any -s 0 -w /sdcard/catchlaw.pcap'" &
# exercise the app for five minutes
adb pull /sdcard/catchlaw.pcap
# app UID:
adb shell dumpsys package <applicationId> | grep userId
```

Filter in Wireshark or `tshark`; correlate with `adb shell cat /proc/net/tcp6` if a UID mapping is
needed. Any packet on the app UID is a FAIL. Packets from Google Play services, the launcher or the
OS are expected and are not yours.

## iOS — rvictl plus Wireshark

iOS has no layer-2 protection, so this capture is the release gate rather than a formality.

```
# device attached over USB, UDID from `xcrun xctrace list devices`
rvictl -s <UDID>          # creates rvi0
sudo tcpdump -i rvi0 -s 0 -w catchlaw-ios.pcap
# exercise the app for five minutes
rvictl -x <UDID>
```

`rvi0` carries the whole device, so quiesce it first: close other apps, disable iCloud sync and
Background App Refresh for everything else. Then attribute what remains by timestamp against the
exercise script — a burst that lines up with the PDF export is a finding.

## Pass criteria

| Observation | Verdict |
|---|---|
| Zero packets on the app UID (Android) | PASS |
| DNS query for any host, during the exercise window, attributable to CatchLaw | FAIL |
| TLS ClientHello from the app | FAIL |
| Traffic from Play services / iOS system daemons | pass, not ours — note it in the report |
| mDNS or the Dart VM service on a DEBUG build | pass, and re-run against the RELEASE build |
| Nothing captured because the device had no connectivity | INVALID — repeat with the network up |

## The release checklist

| # | Step | Command or artefact | Blocks release |
|---|---|---|---|
| 1 | Banned packages absent | `scripts/check_no_network.sh` | yes |
| 2 | Guard test green | `flutter test test/no_network_test.dart` | yes |
| 3 | Analyzer clean with the promoted lint | `flutter analyze` | yes |
| 4 | Dependency graph diffed | `flutter pub deps --style=compact` vs the allowlist table | yes |
| 5 | Android permission absent | `apkanalyzer manifest permissions app-release.apk` | yes |
| 6 | Merger report reviewed | `manifest-merger-release-report.txt` | no, but attach it |
| 7 | Android capture | PCAPdroid `.pcap`, five-minute exercise | yes |
| 8 | iOS capture | rvictl `.pcap`, five-minute exercise | yes |
| 9 | Store answers still accurate | privacy questionnaire vs the wording in `four-layers.md` | yes |

Steps 1 to 5 run in CI on every PR (`ci-pipeline-and-gates`). Steps 6 to 9 run once per release,
by a human, against the artefact that will actually be uploaded.

## Evidence retention

| Artefact | Where | Keep for |
|---|---|---|
| `catchlaw-android-<version>.pcap` | release tag attachment | life of the release plus 2 years |
| `catchlaw-ios-<version>.pcap` | release tag attachment | life of the release plus 2 years |
| `apkanalyzer` permission dump (text) | release notes body | forever, it is one line |
| `flutter pub deps` snapshot | committed as `docs/deps-<version>.txt` | forever |
| Exercise script used | `docs/offline-exercise.md` | forever, so a re-run is comparable |

Two years is the practical window for an enforcement query about a verdict a fisher relied on, and
the capture is what turns "we do not collect location" from an assertion into a record.

## Failure triage

| Hit | First suspicion | Confirm with |
|---|---|---|
| DNS for `fonts.gstatic.com` | `google_fonts`, or `PdfGoogleFonts` in the export path | `grep -rn PdfGoogleFonts lib/` |
| TLS to a CDN during first paint | `Image.network` or `NetworkImage` on a species plate | `scripts/check_no_network.sh` |
| Traffic only on the PDF export | `printing` reaching its `http` edge | `flutter pub deps` path to `http` |
| Traffic only on the citation tap | `launchUrl` handing off to the browser | `grep -rn launchUrl lib/` |
| Traffic on cold start, before any tap | a plugin's own initializer (analytics, crash) | `manifest-merger-release-report.txt` |
| Android capture clean, iOS capture dirty | layer 2 was masking a real call all along | re-run Android with `tools:node="remove"` temporarily reverted |

That last row is the important one: a clean Android capture can be clean because the kernel refused
the socket, not because nothing tried. If iOS shows traffic that Android does not, the Dart code IS
calling out and layer 2 has been silently absorbing the bug — fix the call, do not celebrate.

## Cadence

- Every PR: steps 1 to 5, automatically.
- Every dependency bump: step 4, and re-derive the allowlist table in `references/four-layers.md`.
- Every release: the full checklist, both captures, both artefacts attached to the tag.
- Every Flutter SDK upgrade: re-run both captures even with no app change — the engine is new code.
