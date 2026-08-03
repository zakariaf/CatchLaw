import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:flutter/material.dart';

/// The serif note that stands where a stamp would, and never beside one.
///
/// **Four states reach it and none of them may be stamped.** Nothing was
/// transcribed; the instrument was read and records no limit; the species is
/// not in this jurisdiction at all; or a rule was found and could not be
/// evaluated on the facts to hand. Stamping any of the four would be a claim
/// the sources do not support — and stamping the first would turn a gap in the
/// reference database into a permission, which is the failure the whole no-rule
/// wording exists to prevent.
///
/// It takes the ordinary ink. An adverse colour would make an absence look like
/// a finding, and a verdant one would make it look like a pass.
class ResultNote extends StatelessWidget {
  /// States [note].
  const ResultNote({required this.note, super.key});

  /// The sentence and the instruments consulted.
  final NoteDisplay note;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Semantics(
      header: true,
      liveRegion: true,
      label: note.sentence,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(
          start: LonjaSpace.s4,
          end: LonjaSpace.s4,
          top: LonjaSpace.s7,
        ),
        child: Text(
          note.sentence,
          // The serif, at the legal measure: this is a statement about what the
          // sources say, and it is read in the same voice as the rules.
          style: type.legal.copyWith(color: tokens.onSurface),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}
