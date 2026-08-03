import 'package:flutter/widgets.dart';

/// Pins its child left-to-right, whatever the resolved locale says.
///
/// **This is `SPEC.md` §9.3's one documented exception, and it lives here so a
/// reviewer meets it once.** Everything else in this app mirrors —
/// `EdgeInsetsDirectional`, `AlignmentDirectional`, the adaptive glyph set, and a
/// grep gate (D-8) that rejects a physical `left` anywhere in `app/lib`.
///
/// The ruler does not mirror, because it is not a layout: it is an
/// **instrument**. A physical measuring scale runs from a physical edge, and
/// mirroring it puts zero at the tail of a real fish while the fisher's hand is
/// at the snout — so the Arabic build would read every fish backwards, and
/// every reading would be wrong by the length of the fish. The measurement
/// diagrams go through the same pin, so a fork-length arrow points at the
/// actual fork in `ar`.
///
/// The chrome **around** the instrument still mirrors, because it is chrome:
/// the pin wraps the canvas and nothing else, and the labels, buttons and
/// headings outside it lay out in the reader's own direction. That is why this
/// is a wrapper rather than a flag on the painter — a `Directionality` at the
/// root would make every physical-side bug in the app look correct.
///
/// `no_directional_geometry.sh` bans a constructed `Directionality` outright.
/// This is the sanctioned use, carrying the gate's documented hatch on the one
/// line, because there is exactly one of them.
class LtrInstrument extends StatelessWidget {
  /// Pins [child] left-to-right.
  const LtrInstrument({required this.child, super.key});

  /// The instrument. A canvas, or a diagram — never a screen.
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      // SPEC.md §9.3's one exception: the ruler is an instrument, and a
      // mirrored scale puts zero at the tail of the fish.
      // catchlaw-directional-ok
      Directionality(textDirection: TextDirection.ltr, child: child);
}
