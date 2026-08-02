import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_panel.dart';
import 'package:catchlaw/ui/core/ui/lonja_plate.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';

/// Everything E07 ships, on one sheet.
///
/// Built **only** from what this epic delivers. It renders no verdict widget,
/// no citation footnote and no stale bar — those are E10's, and a specimen that
/// invented them would freeze a design nobody has reviewed into a golden.
class LonjaSpecimenSheet extends StatelessWidget {
  /// Renders the sheet.
  const LonjaSpecimenSheet({this.arabic = false, super.key});

  /// Whether to set the sample content in Arabic.
  final bool arabic;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final heading = arabic ? 'هامور' : 'Hamour';
    final article = arabic
        ? 'الحد الأدنى للطول ٤٥ سم، الطول الكلي.'
        : '38 cm, minimum 45 cm (total length)';

    return ColoredBox(
      color: tokens.surface,
      child: Padding(
        padding: EdgeInsetsDirectional.all(tokens.density.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(heading, style: type.display, textAlign: TextAlign.start),
            const LonjaRule.section(),
            const SizedBox(height: LonjaSpace.s2),
            Text(article, style: type.legal, textAlign: TextAlign.start),
            const LonjaRule.row(),
            Text('Epinephelus coioides', style: type.binomial, textAlign: TextAlign.start),
            const SizedBox(height: LonjaSpace.s2),
            LonjaPanel(
              child: Text('min 45 cm total length', style: type.datum, textAlign: TextAlign.start),
            ),
            const SizedBox(height: LonjaSpace.s3),
            LonjaPlateSurface(
              child: Text(
                'Ministerial Decision 580/2015, Art. 3',
                style: type.citation,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: LonjaSpace.s4),
            const LonjaRule.bearing(),
            const SizedBox(height: LonjaSpace.s3),
            LonjaButton.primary(
              label: arabic ? 'قياس مرة أخرى' : 'Measure again',
              onPressed: () {},
            ),
            SizedBox(height: tokens.density.tapGap),
            LonjaButton.secondary(label: arabic ? 'خطوة للخلف' : 'Back one step', onPressed: () {}),
            SizedBox(height: tokens.density.tapGap),
            LonjaButton.destructive(
              label: arabic ? 'استبدال السجل' : 'Replace the log',
              onConfirmed: () async {},
            ),
            SizedBox(height: tokens.density.tapGap),
            const LonjaButton.primary(
              label: 'Measure again',
              onPressed: null,
              disabledReason: 'No zone is chosen',
            ),
          ],
        ),
      ),
    );
  }
}
