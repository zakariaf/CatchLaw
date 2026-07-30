// Demonstrates the Lonja plate system: a const PlateSpec with mandatory PlateProvenance,
// per-theme stroke resolution, the framed and numbered LonjaPlate, the labelled-or-excluded
// semantics branch, and the guard that forces a plate for protected and look-alike species.
// Every path string and every number is a REAL Lonja value from the approved mockup.
// Conceptually compiles against flutter + path_drawing; in the app tree the plate data is
// generated into lib/design/plates/plate_specs.g.dart and is never hand-edited.

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

enum PlateInk { outline, hatch, hatchStrong }

enum ArtSurface { listRow, result, account }

final class PlateStroke {
  const PlateStroke(this.d, this.ink);
  final String d;
  final PlateInk ink;
}

/// Non-nullable on every field: a plate that cannot name its illustrator does not compile.
/// Whether the work is actually public domain is decided by `catchlaw-content-pipeline`.
final class PlateProvenance {
  const PlateProvenance(
      this.illustrator, this.illustratorDeathYear, this.sourceWork, this.sourceYear, this.licence);
  final String illustrator, sourceWork, licence;
  final int illustratorDeathYear, sourceYear;
}

final class PlateSpec {
  const PlateSpec(
      {required this.key, // lower_snake_case binomial — never a common name
      required this.plateNo,
      required this.figureNo,
      required this.strokes,
      required this.provenance});
  final String key, plateNo;
  final int figureNo;
  final List<PlateStroke> strokes;
  final PlateProvenance provenance;
}

/// PL. XVII · fig. 1 — هامور · Hamour · Orange-spotted grouper · Epinephelus coioides.
const hamourPlate = PlateSpec(
  key: 'epinephelus_coioides',
  plateNo: 'PL. XVII',
  figureNo: 1,
  strokes: [
    PlateStroke('M10 33c5-14 25-24 52-24 21 0 39 9 47 23-8 14-26 24-47 24Z', PlateInk.outline),
    PlateStroke('M110 32c8-8 17-12 26-13-5 8-5 18 0 26-9-1-18-5-26-13Z', PlateInk.outline),
    PlateStroke('M48 11c3-6 9-9 17-9 7 0 12 3 16 8', PlateInk.hatchStrong),
    PlateStroke('M78 22c-2 10-2 20 0 30M92 20c-2 11-2 22 0 33', PlateInk.hatch),
  ],
  provenance: PlateProvenance('Francis Day', 1889, 'The Fishes of India', 1878, 'public-domain'),
);

/// The per-theme ink weights. In the app this is a ThemeExtension attached to all three
/// ThemeData objects; extension mechanics are owned by `design-system-structure`.
@immutable
final class PlateInkTheme {
  const PlateInkTheme(this.outline, this.hatch, this.hatchStrong, this.hatchOpacity, this.ink);

  static const paper = PlateInkTheme(1.60, 0.70, 1.10, 0.5, Color(0xFF16201C));
  static const sunlight = PlateInkTheme(2.10, 1.00, 1.45, 1.0, Color(0xFF000000));
  final double outline, hatch, hatchStrong, hatchOpacity;
  final Color ink;

  double widthFor(PlateInk i) => switch (i) {
        PlateInk.outline => outline,
        PlateInk.hatch => hatch,
        PlateInk.hatchStrong => hatchStrong
      };
}

class LonjaPlatePainter extends CustomPainter {
  const LonjaPlatePainter(this.spec, this.inks);

  static final _cache = <String, Path>{};
  final PlateSpec spec;
  final PlateInkTheme inks;
  static Path _path(String d) => _cache.putIfAbsent(d, () => parseSvgPathData(d));

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 300.0; // the plate grid is 300 x 124
    final m = Matrix4.diagonal3Values(k, k, 1).storage;
    // Allocation discipline inside paint() is owned by `custom-canvas-and-gestures`.
    final burin = Paint()
      ..style = PaintingStyle.stroke // never PaintingStyle.fill
      ..strokeCap = StrokeCap.butt // an engraved line ends square
      ..strokeJoin = StrokeJoin.miter;
    for (final s in spec.strokes) {
      burin
        // NOT scaled by k — the PATH is transformed, not the canvas (rule 3).
        ..strokeWidth = inks.widthFor(s.ink)
        ..color = inks.ink.withValues(alpha: s.ink == PlateInk.outline ? 1.0 : inks.hatchOpacity);
      canvas.drawPath(_path(s.d).transform(m), burin);
    }
  }

  @override
  bool shouldRepaint(LonjaPlatePainter old) => old.spec != spec || old.inks != inks;
}

class LonjaPlate extends StatelessWidget {
  const LonjaPlate(this.spec, {required this.semanticLabel, super.key});

  final PlateSpec spec;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    const inks = PlateInkTheme.paper; // in the app: LonjaIconTheme.of(context).plateInk
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Stack(children: [
        Container(
          padding: const EdgeInsets.all(3), // the 3 px inset before the inner hairline
          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFA9AC9F))),
          child: DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC2C5BB))),
            child: AspectRatio(
                aspectRatio: 300 / 124,
                child: CustomPaint(painter: LonjaPlatePainter(spec, inks))),
          ),
        ),
        // The plate number is a printed-document affordance, not screen-reader content.
        PositionedDirectional(
          top: 8,
          start: 10,
          child: ExcludeSemantics(
            child: Text('${spec.plateNo} · fig. ${spec.figureNo}',
                style: const TextStyle(
                    fontFamily: 'ui-monospace',
                    fontSize: 10.5,
                    letterSpacing: 1.47, // .14em at 10.5
                    color: Color(0xFF6C7871))),
          ),
        ),
      ]),
    );
  }
}

/// The guard: protected species and look-alike-pair members never get a silhouette.
Widget speciesArt(
    {required String scientificName,
    required bool isProtected,
    required String? lookAlikeOf, // e.g. 'lethrinus_lentjan'
    required ArtSurface surface,
    required String plateLabel}) {
  final needsPlate = isProtected || lookAlikeOf != null;
  assert(!(needsPlate && surface == ArtSurface.listRow),
      'plate required for $scientificName: protected or look-alike');
  return switch (surface) {
    ArtSurface.listRow when !needsPlate => const SizedBox.square(dimension: 44), // LonjaSilhouette
    _ => LonjaPlate(hamourPlate, semanticLabel: plateLabel),
  };
}
