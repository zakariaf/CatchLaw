import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// One species' originated line art, on recessed stock.
///
/// **A silhouette is not a plate.** A plate is a historical engraving and ships
/// only when its illustrator's death year clears the longest term among the four
/// bundled jurisdictions — which today is none of them, so
/// `content/shared/plates.yaml` is `plates: []` and every `plate_asset` is null.
/// The silhouette is SVG line art drawn for this app: no illustrator, no term,
/// no ledger row, and `species.silhouette_asset` is NOT NULL because A5 requires
/// one for every species carrying a rule.
///
/// **The empty frame was worse than no frame.** Both call sites used to reserve
/// a 160-high box and draw `SizedBox.expand()` inside it, waiting on a resolver
/// nobody had built. On a real device that reads as a photograph that failed to
/// load, on a screen whose entire claim is that it is a printed reference — and
/// it hid the fact that `assets/sil/` was never listed in `pubspec.yaml` at all,
/// so the art shipped nowhere. Neither half had a test, because no test loaded
/// an asset through the real bundle.
///
/// **Black on stock, and never tinted.** The art carries its own strokes and is
/// authored to read at arm's length on a wet screen. `colorFilter` is
/// deliberately not applied: recolouring line art to a theme slot is how a
/// drawing whose whole job is to be recognisable becomes a silhouette of a
/// silhouette.
class LonjaSilhouette extends StatelessWidget {
  /// Draws the art at [assetKey], labelled [semanticsLabel] for a screen reader.
  ///
  /// [assetKey] is `species.silhouette_asset` as authored — `sil/<id>.svg`,
  /// relative to the bundle's `assets/` root, which [assetPath] completes.
  const LonjaSilhouette({
    required this.assetKey,
    required this.semanticsLabel,
    this.height,
    super.key,
  });

  /// The pack's own value, e.g. `sil/venerupis-corrugata.svg`.
  final String assetKey;

  /// What a screen reader says instead of the drawing. Already localised.
  final String semanticsLabel;

  /// A fixed height, or null to fill the space the parent gives.
  final double? height;

  /// [assetKey] as a bundle path.
  ///
  /// The pack stores the key without the `assets/` prefix so the same value can
  /// address a file on disk in the content tree and a bundle entry in the app;
  /// joining it here keeps the prefix in one place rather than at each call.
  String get assetPath => 'assets/$assetKey';

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: tokens.surface),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(LonjaSpace.s3),
        child: SvgPicture.asset(
          assetPath,
          height: height,
          semanticsLabel: semanticsLabel,
          // From the bundle, and there is no other constructor this app may
          // reach for: the fetching one is grep-banned by
          // catchlaw-offline-guarantee, and the http edge flutter_svg declares
          // exists for exactly that banned entry point (D-21).
          fit: BoxFit.contain,
          // A missing file is a content defect, not a crash on a wet phone at
          // 05:40. The frame stays, so the layout the rest of the screen was
          // measured against does not move, and the species name — which is the
          // thing he actually needs — is still where it was.
          //
          // Bounded, never `SizedBox.expand()`: the detail panel sits in a
          // scroll view, so an expanding placeholder is an unbounded-height
          // assertion the moment the asset is absent — which is every widget
          // test, none of which loads a real bundle.
          placeholderBuilder: (BuildContext _) => SizedBox(height: height),
        ),
      ),
    );
  }
}
