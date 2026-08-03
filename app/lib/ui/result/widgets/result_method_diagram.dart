import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Where on the fish the instrument's threshold is measured from.
///
/// **The drawing comes from the rule row, never from the species.** `SPEC.md`
/// §4.2 is unambiguous and the schema encodes it: `measurement_method_id` is a
/// column on `rule`, not on `species`, because the same species is measured
/// differently in two countries. A diagram sourced from the species would show
/// a total-length arrow to a fisher whose instrument states fork length, and he
/// would measure to the wrong point while reading a verdict that says he did
/// not — roughly 6 cm of Kanaad, which is the whole margin.
class ResultMethodDiagram extends StatelessWidget {
  /// Draws [assetPath], captioned [methodName].
  const ResultMethodDiagram({required this.assetPath, required this.methodName, super.key});

  /// The bundled asset named on the active jurisdiction's rule row, or `null`
  /// when that row states no method.
  final String? assetPath;

  /// The method, spelled out in words, from `content_string`.
  final String methodName;

  @override
  Widget build(BuildContext context) {
    final String? assetPath = this.assetPath;
    // Absent rather than an empty frame: a blank ruled box reads as an
    // illustration that failed to load.
    if (assetPath == null) return const SizedBox.shrink();

    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.surfaceSunk,
            border: Border.all(color: tokens.hairline, width: LonjaRules.rule),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(LonjaSpace.s3),
            // `SPEC.md` §9.3's second exception, beside the ruler: the drawing
            // is an instrument, and a mirrored fork-length arrow points at the
            // snout. The subtree is pinned LTR and the caption below is NOT,
            // because the exception is the drawing rather than the words about
            // it.
            // catchlaw-directional-ok
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SvgPicture.asset(
                assetPath,
                semanticsLabel: methodName,
                // From the bundle, and there is no other constructor this app
                // may reach for: the fetching one is grep-banned by
                // catchlaw-offline-guarantee, and the http edge flutter_svg
                // declares exists for exactly that banned entry point (D-21).
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: LonjaSpace.s1),
        Text(
          methodName,
          style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
