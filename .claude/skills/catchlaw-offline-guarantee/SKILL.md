---
name: catchlaw-offline-guarantee
description: >-
  Enforces CatchLaw's zero-network claim as four layers of proof — no http, dio, firebase_core or
  connectivity_plus in pubspec.yaml so an import is an unresolved-URI compile error,
  depend_on_referenced_packages promoted to error, android.permission.INTERNET stripped from the
  main and release AndroidManifest.xml with tools:node="remove", iOS resting on layers 1 and 4
  since ATS blocks only cleartext, a no_network_test.dart guard banning HttpClient, Socket,
  WebSocket and InternetAddress while File, Directory and Platform stay for drift, an allowlist for
  transitive http edges under printing and flutter_svg, and a tcpdump capture, never an HTTP proxy.
  Use when adding a dependency to pubspec.yaml, editing AndroidManifest.xml, writing
  no_network_test.dart, reviewing Image.network, NetworkImage, PdfGoogleFonts or launchUrl in a
  diff, auditing a transitive package edge, running the release packet capture, or wiring
  check_no_network.sh into CI.
---

# Catchlaw Offline Guarantee

"100% offline" is printed on the store listing and said to a regulator, so it is held up by the
compiler and the operating system, never by discipline. This skill owns the four layers that make
the claim VERIFIABLE — the undeclared dependency, the stripped Android permission, the honest iOS
gap, and the `dart:io` guard test — plus the banned-package list and the packet-capture ritual. It
does not own durability, migrations or failure typing.

Read the reference for the task at hand:
- `references/four-layers.md` — layer strength ladder, banned package table, manifest snippets and
  merger rules, the iOS gap, the `dart:io` split, transitive allowlist, API grep list.
- `references/verification-ritual.md` — why proxies lie, PCAPdroid, adb tcpdump, rvictl plus
  Wireshark, pass criteria, release checklist, evidence retention, failure triage.

Run `scripts/check_no_network.sh` before a PR.

Durability, DAOs and transactions belong to `persistence-drift`; forward-only schema changes to
`run-migration`; `Result` and failure types to `error-handling-typed-results`. This skill only ever
asserts that no code path can reach a socket, and that the asset databases are the whole world.

## Non-negotiable rules

1. **The networking package is never declared, at any depth.** `pubspec.yaml` carries no `http`,
   `dio`, `web_socket_channel`, `grpc`, `firebase_core`, `connectivity_plus`, `url_launcher`,
   `googleapis` or `google_fonts` — not in `dependencies`, not in `dev_dependencies`. An import is
   then `Target of URI doesn't exist`, at compile time. **WHY:** a compile error is the only layer
   nobody can forget to run; every other layer is a habit.

2. **`depend_on_referenced_packages` is promoted to ERROR.** In `analysis_options.yaml` under
   `analyzer: errors:`, so `http` reached transitively through `printing` cannot be imported from
   `lib/` until it appears in `pubspec.yaml`, where a reviewer sees it in the diff. **WHY:** at
   warning level the rule is noise in a 400-line analyzer log and ships in the release the same day.

3. **`android.permission.INTERNET` is absent from main AND release.** Declared with
   `tools:node="remove"` in `android/app/src/main/AndroidManifest.xml` and again in
   `android/app/src/release/AndroidManifest.xml`, with `xmlns:tools` on the `manifest` element —
   omit the xmlns and the merge FAILS the build. **WHY:** without the permission the kernel refuses
   every socket whatever Dart does, and it is the only layer a third party can check from the APK.

4. **Debug and profile manifests KEEP internet, and that is correct.** `android/app/src/debug/` and
   `.../profile/AndroidManifest.xml` declare `android.permission.INTERNET` for the Dart VM service
   and hot reload; the guard test and `scripts/check_no_network.sh` skip exactly those two source
   sets. **WHY:** a guard that breaks `flutter run` is a guard someone deletes before lunch.

5. **iOS has NO equivalent opt-out — write that down, never fake it.** ATS blocks cleartext HTTP and
   permits every TLS request, `NSAllowsArbitraryLoads: false` is not an offline guarantee, and
   CFNetwork is linked by the Flutter engine regardless, so "links no Network.framework" is not a
   test. iOS rests on layers 1 and 4. **WHY:** a false claim in a privacy submission is a worse
   liability than a documented, mitigated gap.

6. **Ban the networking HALF of `dart:io`, never `dart:io` itself.** `HttpClient`, `HttpServer`,
   `Socket`, `RawSocket`, `SecureSocket`, `ServerSocket`, `WebSocket`, `InternetAddress`,
   `RawDatagramSocket` and `HttpOverrides` are banned under `lib/`; `File`, `Directory` and
   `Platform` stay — `NativeDatabase.createInBackground` and the PDF export need them. **WHY:** a
   wholesale ban is unenforceable, gets waived in week two, and then guards nothing at all.

7. **The guard is a TEST that reads source, not a lint.** `test/no_network_test.dart` walks `lib/`,
   skips `*.g.dart`, `*.freezed.dart` and `*.drift.dart`, and reports file, line and symbol. The
   Flutter team hand-writes source scanners in `dev/bots` for precisely this class of invariant.
   **WHY:** no analyzer rule can express "this repository, forever, including next year's plugin".

8. **A transitive http edge is an ALLOWLIST ENTRY, never a shrug.** `printing` and `flutter_svg`
   pull `http` transitively; each is listed in `references/four-layers.md` with the unreachable
   entry point named — `PdfGoogleFonts`, `SvgPicture.network` — and `flutter pub deps` output is
   diffed at release. **WHY:** an undocumented edge and a live leak look identical during an audit.

9. **No URL is opened, launched, rendered or fetched.** No `launchUrl`, `url_launcher`,
   `webview_flutter`, `InAppWebView`, `NetworkImage`, `Image.network`, `FadeInImage.assetNetwork`
   or `CachedNetworkImage`. A citation prints as text — "Ministerial Decision 580/2015, Art. 3 ·
   published 2015-11-03" — never as a tappable link. **WHY:** handing off to the browser is a
   network request that merely wears someone else's user agent.

10. **Fonts, plates and both databases ship as ASSETS.** `assets/db/reference_v2026_2.sqlite`,
    `assets/fonts/*.ttf` and every species plate are declared in `pubspec.yaml` and extracted once
    behind the determinate first-launch bar; never `google_fonts`, never a CDN. **WHY:** at 05:40
    off Ras Al Khaimah a remotely-fetched font renders the verdict as blank boxes.

11. **The UI offers NO refresh, sync, retry or connectivity state.** No `ConnectivityResult`, no
    "you are offline" banner, no "check for updates", no pull-to-refresh on the species list. An
    expired ruleset is evaluated and shown under the ochre `StaleRuleBar`. **WHY:** an affordance
    that cannot work teaches Khalid the app is broken at the exact moment it is working as designed.

12. **Release evidence is a PACKET CAPTURE, not a proxy session.** PCAPdroid or `adb` + `tcpdump`
    on Android, `rvictl -s` plus Wireshark on iOS, over a five-minute exercise of scan, measure,
    verdict and PDF export. Dart's `HttpClient` ignores the system proxy unless `findProxy` is set,
    so a clean Charles trace proves nothing. **WHY:** the easiest proof to reach for is the one
    incapable of failing.

## Layer 1 — the dependency that does not exist

The strongest layer is an absence. Nothing in `pubspec.yaml` that speaks TCP, and the analyzer set
so a transitive package cannot be imported without first being declared where review can see it.

```yaml
# pubspec.yaml
dependencies:
  flutter: {sdk: flutter}
  drift: ^2.28.0
  sqlite3_flutter_libs: ^0.5.40
  printing: ^5.14.2        # transitive http — allowlisted, see references/four-layers.md
  # WRONG — one line and every layer below it is decoration:
  # http: ^1.5.0
  # connectivity_plus: ^7.0.0
  # google_fonts: ^6.3.2   # fetches at runtime; bundle the .ttf instead

# analysis_options.yaml — RIGHT: a transitive import is a compile-blocking error, not a hint.
analyzer:
  errors:
    depend_on_referenced_packages: error
```

Banned list and rationale per package: `references/four-layers.md`.

## Layer 2 — the manifest the kernel enforces

The `xmlns:tools` declaration is mandatory; without it the manifest merger fails the build rather
than ignoring the marker. The `remove` node also strips an INTERNET permission merged in by any
future library manifest, which is the case a grep over your own source can never catch.

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          xmlns:tools="http://schemas.android.com/tools">

    <!-- WRONG — this single line hands every socket back to the process.
    <uses-permission android:name="android.permission.INTERNET" />
    -->

    <!-- RIGHT — never granted here, and actively stripped if a library merges it in. -->
    <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />

    <application android:label="CatchLaw" android:icon="@mipmap/ic_launcher">
```

Repeat the same element in `android/app/src/release/AndroidManifest.xml`. Leave
`android/app/src/debug/AndroidManifest.xml` alone — it grants INTERNET for the VM service (rule 4).
Merger rules and the `apkanalyzer` proof: `references/four-layers.md`.

## Layer 3 — iOS, stated honestly

There is no iOS counterpart to a missing INTERNET permission. Write the gap into the repo instead of
implying a guarantee that does not exist; the honest sentence is what survives an audit.

```xml
<!-- ios/Runner/Info.plist -->
<!-- WRONG — ATS is not an offline switch. This blocks cleartext and permits every TLS
     request in the process, so it proves nothing about whether CatchLaw talks to a server.
<key>NSAppTransportSecurity</key>
<dict><key>NSAllowsArbitraryLoads</key><false/></dict>
-->

<!-- RIGHT — keep ATS at its strict default, and document what it does and does not mean.
     iOS has no permission-level network opt-out. CFNetwork is linked by the Flutter engine
     whether or not we call it, so "links no Network.framework" is not a test. On iOS the
     offline guarantee rests on layer 1 (no networking package resolves) and layer 4
     (no_network_test.dart), verified at release by rvictl + Wireshark. -->
```

The exact wording for the store listing and privacy questionnaire: `references/four-layers.md`.

## Layer 4 — the guard test over `lib/`

`dart:io` cannot be banned wholesale: drift opens the two databases through `File` and `Directory`,
and `Platform` picks the extraction path. So the test bans the networking symbols by name and leaves
the filesystem alone — the split is the whole point.

```dart
// WRONG — bans the import the databases depend on; gets waived within a week.
expect(source.contains("import 'dart:io'"), isFalse);

// RIGHT — ban the networking half by symbol, keep File / Directory / Platform.
const bannedIo = <String, String>{
  r'\bHttpClient\b': 'no HTTP client may exist in lib/',
  r'\bWebSocket\b': 'no socket of any kind may exist in lib/',
  r'\bInternetAddress\b': 'no name resolution may exist in lib/',
  r'\b(Raw|Secure|Server)?Socket\b': 'no socket of any kind may exist in lib/',
};
// File, Directory, Platform are DELIBERATELY absent: NativeDatabase.createInBackground
// and the assets/db/reference_v2026_2.sqlite extraction require them.
```

Full worked file: `examples/no_network_test.dart`.

## The transitive allowlist and the API grep list

`printing` and `flutter_svg` depend on `http`. That is not a violation — it is an edge whose entry
points are grep-banned and written down. What turns it into a violation is calling the entry point.

```dart
// WRONG — PdfGoogleFonts fetches a TTF over the wire the first time an export runs.
final doc = pw.Document();
doc.addPage(pw.Page(build: (_) => pw.Text(
      'Epinephelus coioides · 38 cm',
      style: pw.TextStyle(font: await PdfGoogleFonts.notoSansArabicRegular()),
    )));

// RIGHT — the same face, loaded from the bundle; the http edge stays unreachable.
final arabic = pw.Font.ttf(await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf'));
doc.addPage(pw.Page(build: (_) => pw.Text(
      'Epinephelus coioides · 38 cm',
      style: pw.TextStyle(font: arabic),
    )));
// Also banned by grep: SvgPicture.network, Image.network, NetworkImage, launchUrl.
```

Full worked file: `examples/no_network_test.dart`.

## Offline as a surface, not just an absence

Offline is not an error state to be announced; it is the only state. The app never asks whether
there is a connection, because the answer could not change a single pixel.

```dart
// WRONG — a connectivity check, a banner, and a retry that can never succeed.
final status = await Connectivity().checkConnectivity();
if (status == ConnectivityResult.none) {
  return const OfflineBanner(onRetry: _refreshRules); // teaches him the app is broken
}

// RIGHT — evaluate against the bundled pack, and state its age instead of its reachability.
final pack = ref.watch(rulePackProvider); // assets/db/reference_v2026_2.sqlite, opened lazily
final verdict = engine.evaluate(species: hamour, lengthCm: 38, method: MeasurementMethod.tl);
return Column(children: [
  if (pack.isExpired) StaleRuleBar(expiredOn: pack.validUntil), // ochre, non-blocking
  VerdictPanel(verdict: verdict, citation: pack.citation),      // "Below the minimum — 38 cm…"
]);
```

Full worked file: `examples/no_network_test.dart`.

## Anti-patterns

- **`http: ^1.5.0` "just for the content build tool"** — the CLI lives in its own workspace package;
  adding it to the app's `pubspec.yaml` demolishes layer 1 for the entire binary.
- **`connectivity_plus` to show an offline banner** — declares a networking dependency in order to
  render a message about a state that is permanent and needs no message.
- **`google_fonts: ^6.3.2`** — resolves fonts over HTTPS on first paint; a cold cache at sea renders
  the verdict as blank boxes, which reads as a broken app in the ten seconds that matter.
- **`launchUrl(Uri.parse('https://elaws.moj.gov.ae/...'))` on the citation** — a network request in
  a browser wearing a different user agent, and dead weight offline anyway.
- **`Image.network(species.plateUrl)`** — a species plate that only appears in the office, on wifi,
  during the demo, and is a blank box in the bin at 05:40.
- **`tools:node="remove"` without `xmlns:tools` on `manifest`** — the merger fails the build with an
  unresolved-prefix error, someone reverts the whole line, and the permission comes back.
- **Stripping INTERNET from `android/app/src/debug/AndroidManifest.xml`** — kills the VM service and
  hot reload, so the next engineer deletes the guard entirely rather than debug it.
- **`expect(source.contains("import 'dart:io'"), isFalse)`** — bans the import drift needs; the test
  is disabled the day someone opens the reference database.
- **Charles or mitmproxy as release evidence** — `HttpClient` ignores the system proxy unless
  `findProxy` is set, so the trace is clean whether or not the app called out.
- **A `// no-network-ok` on a line that actually opens a socket** — the escape hatch exists for a
  false-positive identifier such as `socketPathLabel`, never for a real call.
- **Silently upgrading a transitive `http` edge in `pubspec.lock`** — moves the allowlist without
  moving `references/four-layers.md`, and the audit finds the discrepancy instead of you.

## Definition of done

- [ ] `scripts/check_no_network.sh` is clean over `lib/`.
- [ ] `pubspec.yaml` declares no package from the banned list, and `depend_on_referenced_packages`
      is `error` in `analysis_options.yaml` (rules 1, 2).
- [ ] `apkanalyzer manifest permissions app-release.apk` prints no `android.permission.INTERNET`,
      while `flutter run` still hot-reloads (rules 3, 4).
- [ ] The iOS gap is written verbatim in `ios/Runner/Info.plist` comments and in the store privacy
      answers — no wording implies a permission-level iOS block (rule 5).
- [ ] `flutter test test/no_network_test.dart` passes and fails loudly when a `HttpClient` line is
      pasted into `lib/` on purpose (rules 6, 7).
- [ ] Every transitive `http` edge in `flutter pub deps` appears in the allowlist table in
      `references/four-layers.md` with its banned entry point named (rule 8).
- [ ] No `launchUrl`, `NetworkImage`, `Image.network`, `SvgPicture.network` or `PdfGoogleFonts`
      exists in `lib/`, and every font and both databases resolve from `assets/` (rules 9, 10).
- [ ] No `ConnectivityResult`, offline banner, refresh, sync or retry affordance exists; an expired
      pack still evaluates and shows the ochre `StaleRuleBar` (rule 11).
- [ ] A five-minute release-build packet capture is attached to the release tag showing zero
      outbound packets from the app UID (rule 12).

## Related skills

- See `catchlaw-reference-database` for the read-only asset database, its lazy open and the
  first-launch extraction this guarantee assumes is the only source of truth.
- See `catchlaw-content-pipeline` for the CLI workspace package that legitimately does fetch, and
  why it can never be a dependency of the app package.
- See `catchlaw-verdict-contract` for the citation block printed as text instead of a link, and the
  statement-of-fact wording it must keep.
- See `lonja-verdict-and-status` for the ochre `StaleRuleBar` that replaces every refresh, sync and
  connectivity affordance this skill forbids.
- See `persistence-drift` for `LazyDatabase`, `NativeDatabase.createInBackground`, DAOs and the
  transactions that make the `File` and `Directory` exemption necessary.
- See `dependency-hygiene` for version pinning, `pubspec.lock` review and the upgrade cadence this
  skill's banned list and allowlist ride on top of.
- See `ci-pipeline-and-gates` for wiring `scripts/check_no_network.sh` and the guard test into the
  required checks so a violation cannot merge.
- See `error-handling-typed-results` for `Result` and the failure taxonomy — note that no failure
  type may ever mean "network unavailable".

## References

- Dart — package dependencies and pubspec: https://dart.dev/tools/pub/dependencies
- Dart lint — depend_on_referenced_packages: https://dart.dev/tools/linter-rules/depend_on_referenced_packages
- Dart API — dart:io library: https://api.dart.dev/stable/dart-io/dart-io-library.html
- Android — merge multiple manifest files: https://developer.android.com/build/manage-manifests
- Android — INTERNET permission: https://developer.android.com/reference/android/Manifest.permission#INTERNET
- Android — apkanalyzer command line: https://developer.android.com/tools/apkanalyzer
- Apple — preventing insecure network connections (ATS): https://developer.apple.com/documentation/security/preventing-insecure-network-connections
- Flutter — adding assets and images: https://docs.flutter.dev/ui/assets/assets-and-images
