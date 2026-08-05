import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/widgets.dart';

/// A two-state setting, as a ruled cell with a marked box.
///
/// **Not a Material `Switch`, and the reason is rule 1.** A switch is a pill,
/// and `lonja-forms-and-controls` puts the largest radius the system tolerates
/// at 2 — because Lonja's whole authority is that it looks like the printed
/// regulation it quotes, and a rounded sliding track reads as generic app
/// chrome. This is a box that is either ruled-and-empty or filled-and-marked.
///
/// **Fill AND mark AND weight, never colour alone (rule 8).** The mark is drawn,
/// the box is filled, and the label goes to full weight when on. In sunlight on
/// a wet screen the fill alone is not reliably visible, and invariant 4 makes
/// colour-only signalling a defect everywhere in this app, not just on a verdict.
///
/// The whole row is the target, sized by `density.rowHeight`, so a gloved thumb
/// does not have to find a 20 px box.
class LonjaSwitch extends StatelessWidget {
  /// A setting [label] that is [value], changed through [onChanged].
  const LonjaSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
    this.note,
    super.key,
  });

  /// What the setting is. Already localised.
  final String label;

  /// One line under the label, or null. Already localised.
  final String? note;

  /// Whether it is on.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Semantics(
      toggled: value,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.density.rowHeight),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s2),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // The serif key step, the same one every other line of
                      // the settings ledger sets its key in: a sans label
                      // between two serif ones reads as a control borrowed
                      // from somewhere else.
                      Text(
                        label,
                        style: value
                            ? type.legalSmall.copyWith(fontWeight: FontWeight.w700)
                            : type.legalSmall,
                      ),
                      if (note != null) ...<Widget>[
                        const SizedBox(height: LonjaSpace.s1),
                        Text(note!, style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: LonjaSpace.s3),
                _MarkBox(on: value),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The box: ruled when off, filled and marked when on.
class _MarkBox extends StatelessWidget {
  const _MarkBox({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return SizedBox(
      width: LonjaSpace.s5,
      height: LonjaSpace.s5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: on ? tokens.onSurface : tokens.surface,
          border: Border.all(color: tokens.onSurface, width: LonjaRules.strong),
        ),
        child: on
            ? Center(
                child: CustomPaint(
                  size: const Size(LonjaSpace.s3, LonjaSpace.s3),
                  painter: _CheckPainter(colour: tokens.surface),
                ),
              )
            : null,
      ),
    );
  }
}

/// A drawn mark rather than a glyph.
///
/// A tick from an icon font is one bundled family away from a tofu box, and this
/// is the only thing distinguishing on from off at a glance.
class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.colour});

  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = colour
      ..strokeWidth = LonjaRules.strong
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width * 0.38, size.height * 0.92)
      ..lineTo(size.width, size.height * 0.12);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.colour != colour;
}
