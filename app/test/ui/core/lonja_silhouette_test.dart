// The species art, loaded through the REAL bundle.
//
// Two independent defects shipped together and neither had a test. The resolver
// was never built — both call sites drew `SizedBox.expand()` inside a framed box
// and waited on an owner — and `assets/sil/` was never listed in `pubspec.yaml`,
// so the art shipped nowhere. On a device that reads as a photograph that failed
// to load, on a screen whose entire claim is that it is a printed reference.
//
// Every other widget test in this suite passes a fake or a stub, which is why
// none of them saw it. This one asserts against `rootBundle`: the asset key the
// pack stores must resolve to bytes the app can actually load. That is the only
// assertion that can fail when a content update adds a species and forgets the
// art, which is the failure that will happen again.

import 'package:catchlaw/ui/core/ui/lonja_silhouette.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

/// The one species the Galicia seed carries, as `species.silhouette_asset`
/// stores it — no `assets/` prefix, because the same value addresses a file in
/// the content tree and an entry in the bundle.
const String kSeedAssetKey = 'sil/venerupis-corrugata.svg';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LonjaSilhouette prefixes the pack asset key with the bundle root', () {
    const art = LonjaSilhouette(assetKey: kSeedAssetKey, semanticsLabel: 'Line drawing');

    expect(art.assetPath, 'assets/$kSeedAssetKey');
  });

  test('the shipped silhouette loads from the bundle', () async {
    // The assertion that fails when `assets/sil/` drops out of pubspec.yaml.
    // rootBundle in a test reads the same asset manifest the app does, so a
    // directory that is not declared throws here exactly as it does on a phone.
    final String svg = await rootBundle.loadString('assets/$kSeedAssetKey');

    expect(svg, contains('<svg'));
  });

  test('the shipped silhouette is line art rather than an embedded image', () async {
    // SPEC.md §8: originated SVG, drawn for this app. A base64 <image> would be
    // a raster pasted into an SVG wrapper — which carries whatever copyright the
    // raster carried, and defeats the whole reason a silhouette is not a plate.
    final String svg = await rootBundle.loadString('assets/$kSeedAssetKey');

    expect(svg, isNot(contains('<image')));
    expect(svg, isNot(contains('base64')));
  });

  test('the shipped silhouette declares a viewBox so it scales to any tile', () async {
    // Without one, flutter_svg falls back to the intrinsic size and the drawing
    // renders at whatever the authoring tool wrote — which on the browse grid is
    // a clam the size of a full stop.
    final String svg = await rootBundle.loadString('assets/$kSeedAssetKey');

    expect(svg, contains('viewBox'));
  });
}
