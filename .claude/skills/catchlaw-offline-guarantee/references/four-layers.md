# The Four Layers

Scope: the exact artefacts that make "CatchLaw sends nothing, ever" checkable — the banned package
table, the Android manifest and its merger rules, the iOS gap and its honest wording, the `dart:io`
split, the transitive allowlist and the API grep list. Verification procedure lives in
`references/verification-ritual.md`.

## The strength ladder

Layers are ordered by what defeats them. Always add the strongest layer that applies; never let a
weaker layer stand in for a stronger one that was skipped.

| # | Layer | Enforced by | Fails at | Who can verify | Defeated by |
|---|---|---|---|---|---|
| 1 | Package not in `pubspec.yaml` | Dart compiler | compile | anyone with source | editing `pubspec.yaml` in a reviewed diff |
| 2 | No `android.permission.INTERNET` | Linux kernel / Android | `socket()` returns EPERM | **anyone with the APK** | editing a manifest in a reviewed diff |
| 3 | iOS ATS | CFNetwork, cleartext only | runtime, TLS unaffected | nobody, meaningfully | nothing — it never applied |
| 4 | `test/no_network_test.dart` | CI | `flutter test` | anyone with source | deleting or skipping the test |

Layer 2 is the only one a regulator, a store reviewer or a journalist can check without trusting
you. That is why it is worth more than the three source-side layers combined.

## Layer 1 — the banned package table

Never in `dependencies`, never in `dev_dependencies`, never in the app package. The content-build
CLI is a SEPARATE workspace package (`catchlaw-content-pipeline`) and may depend on whatever it
likes, because it never ships.

| Banned | Why it is reachable | What CatchLaw does instead |
|---|---|---|
| `http`, `dio`, `chopper`, `retrofit` | direct HTTP client | nothing — there is no server |
| `web_socket_channel`, `grpc` | streaming sockets | nothing |
| `firebase_core` and every `firebase_*` | analytics, crash, config, all networked | no telemetry at all |
| `connectivity_plus`, `internet_connection_checker` | probes the network to render a banner | no banner; state the pack's age |
| `url_launcher` | hands a URL to the browser | citation printed as text |
| `webview_flutter`, `flutter_inappwebview` | a full networked renderer | rule text rendered as widgets |
| `google_fonts` | fetches TTF over HTTPS on first paint | `assets/fonts/*.ttf` in `pubspec.yaml` |
| `cached_network_image` | HTTP image cache | `assets/plates/*.webp` |
| `googleapis`, `googleapis_auth`, `supabase_flutter` | backend SDKs | there is no backend |
| `sentry_flutter`, `posthog_flutter`, `amplitude_flutter` | uploads crash and usage data | local-only diagnostics file |
| `package_info_plus` (network-free, but pulls plugin channels) | allowed — listed only to stop the reflex ban | — |

`analysis_options.yaml` must promote the transitive escape route to an error:

```yaml
analyzer:
  errors:
    depend_on_referenced_packages: error
```

Without the promotion, `import 'package:http/http.dart';` inside `lib/` compiles fine as long as
`printing` put `http` in `.dart_tool/package_config.json`. With it, the analyzer fails the build.

## Layer 2 — the Android manifest and the merger

Four source sets exist. Only two ship.

| Source set | INTERNET | Reason |
|---|---|---|
| `android/app/src/main/AndroidManifest.xml` | `tools:node="remove"` | base for every build; strips library-merged grants |
| `android/app/src/release/AndroidManifest.xml` | `tools:node="remove"` | the manifest an auditor diffs; belt and braces |
| `android/app/src/debug/AndroidManifest.xml` | **granted** | Dart VM service, hot reload — Flutter's own template |
| `android/app/src/profile/AndroidManifest.xml` | **granted** | DevTools attach during profiling |

Merger rules that matter:

- `xmlns:tools="http://schemas.android.com/tools"` MUST be on the `manifest` element. Without it the
  merger raises an unresolved-prefix error and the build fails — this is a hard failure, not a
  warning, which is exactly why the missing xmlns gets "fixed" by deleting the whole line.
- `tools:` markers act on manifests of LOWER priority. Build-type manifests (`debug/`, `release/`)
  outrank `main/`, which outranks library manifests. So a `remove` in `main/` strips a grant merged
  in by a plugin AAR, and does not strip the deliberate grant in `debug/`.
- The Gradle plugin never adds INTERNET on its own. Any appearance in the merged output comes from a
  library manifest, and `app/build/outputs/logs/manifest-merger-release-report.txt` names it.

Proof from the artefact, no source required:

```
apkanalyzer manifest permissions build/app/outputs/flutter-apk/app-release.apk
# expected output: no line containing android.permission.INTERNET
aapt2 dump permissions build/app/outputs/flutter-apk/app-release.apk
```

For an AAB, unpack `base/manifest/AndroidManifest.xml` with `bundletool dump manifest`.

## Layer 3 — iOS, and the sentence to write

| Claim | True? | Why |
|---|---|---|
| "ATS prevents the app going online" | **no** | ATS constrains cleartext HTTP; every TLS request is permitted |
| "`NSAllowsArbitraryLoads: false` is an offline switch" | **no** | it is the default, and it only tightens cleartext policy |
| "the binary links no Network.framework, so it cannot connect" | **no** | Foundation/CFNetwork are linked by the Flutter engine regardless |
| "there is an iOS entitlement to deny outbound networking" | **no** | the sandbox has no such deny entitlement for iOS apps |
| "on iOS the guarantee is source-side plus a capture" | **yes** | layers 1 and 4, verified per release with rvictl |

Wording approved for the store listing and privacy questionnaire — use verbatim, do not improve:

> CatchLaw performs no network requests. It declares no networking dependency and, on Android, ships
> without the INTERNET permission, so the operating system refuses any connection attempt. iOS
> provides no equivalent permission-level control; on iOS the guarantee is enforced in source and
> verified before each release with a packet capture.

## Layer 4 — the `dart:io` split

`dart:io` is imported by `lib/` deliberately. Ban by SYMBOL, not by library.

| Banned symbol | Why | Allowed symbol | Needed for |
|---|---|---|---|
| `HttpClient`, `HttpClientRequest`, `HttpServer` | HTTP | `File` | asset extraction, PDF write, diagnostics |
| `Socket`, `RawSocket`, `SecureSocket`, `ServerSocket` | TCP | `Directory` | `getApplicationSupportDirectory` layout |
| `WebSocket`, `WebSocketTransformer` | WS | `Platform` | `isAndroid` / `isIOS` extraction path |
| `InternetAddress`, `NetworkInterface` | DNS, interfaces | `FileSystemEntity` | existence checks before extraction |
| `RawDatagramSocket`, `Datagram` | UDP | `FileMode` | `writeAsBytes` for the export |
| `HttpOverrides`, `SecurityContext` | client plumbing | `IOSink` | streaming the PDF to disk |

Escape hatch: a trailing `// no-network-ok` on the line, allowed ONLY for a false-positive
identifier (`socketPathLabel`, a doc comment naming `HttpClient` in prose). Never for a real call,
and never on an `import`.

## The transitive allowlist

An `http` edge below a shipped package is an ALLOWLISTED FACT with a named, grep-banned entry point.
Re-derive this table from `flutter pub deps --style=compact` at every dependency bump.

| Package | Edge | Reachable only through | Banned by grep | Status |
|---|---|---|---|---|
| `printing` | `printing → http` | `PdfGoogleFonts.*` | yes | allowlisted; fonts come from `assets/fonts/` |
| `flutter_svg` | `flutter_svg → http` (older majors) | `SvgPicture.network` | yes | allowlisted; all SVG from `assets/` |
| `flutter` (framework) | `NetworkAssetBundle`, `Image.network` | `NetworkImage`, `Image.network` | yes | unavoidable in the SDK; entry points banned |

The framework row is why layer 2 exists: `Image.network` compiles in any Flutter app, forever, and
no `pubspec.yaml` edit can remove it. Only the kernel can.

## The API grep list

Every one of these is a `scripts/check_no_network.sh` failure inside `lib/`:

`Image.network` · `NetworkImage` · `FadeInImage.assetNetwork` · `NetworkAssetBundle` ·
`CachedNetworkImage` · `SvgPicture.network` · `PdfGoogleFonts` · `launchUrl` · `launchUrlString` ·
`canLaunchUrl` · `WebViewController.loadRequest` · `Connectivity()` · `ConnectivityResult` ·
`http.get` · `http.post` · `Dio(` · `HttpClient(` · `Socket.connect` · `WebSocket.connect` ·
`InternetAddress.lookup` · `Uri.https` · `Uri.http`

`Uri.parse` is NOT banned — the reference database stores instrument identifiers as URIs and they
are printed, never fetched.

## Edge cases

| Situation | Ruling |
|---|---|
| A plugin needs INTERNET in its own manifest | keep the `tools:node="remove"` in `main/`; check the merger report to confirm it was stripped |
| A test needs a local socket | tests live outside `lib/`; the guard scans `lib/` only |
| The content-build CLI fetches ministry PDFs | correct and expected — separate workspace package, never a dependency of the app package (`catchlaw-content-pipeline`) |
| A golden test loads a font from the network | forbidden; goldens load `assets/fonts/*.ttf` through `FontLoader` |
| Someone wants deep links into the app | inbound intents are not outbound traffic and are permitted, but nothing may call out in response |
| `flutter run` fails after a manifest edit | you stripped INTERNET from `debug/`; restore it (rule 4) |
