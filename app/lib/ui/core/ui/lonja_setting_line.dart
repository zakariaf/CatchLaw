import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/widgets.dart';

/// One line of the settings ledger: what the setting is, and what it says now.
///
/// **A ledger line, not a form field.** The whole of S14 is a column of these,
/// full-bleed to both margins with a hairline between them, because that is
/// what the page it replaces looks like: a printed table of what this copy of
/// the book is set to. A stacked label-then-control form turns four settings
/// into a screen the fisher has to scroll, and the value he came to read moves
/// off the line that names it.
///
/// The anatomy is fixed and every row keeps it. [label] is the serif key,
/// [note] the sans line under it that says what the setting reaches, and the
/// end of the line carries the answer: [value] set in the mono figure step,
/// then [trailing] — the control, when the row is worked in place rather than
/// opened — then the [chevron] that says this row leads somewhere.
///
/// [below] is the one exception, and it is a control that could not hang at the
/// end of the line: a three-cell segmented control with a word in one of its
/// cells needs the full measure, and ellipsising that word is worse than
/// dropping it under the key it belongs to.
class LonjaSettingLine extends StatelessWidget {
  /// A row naming [label], reading [value], opened through [onTap].
  const LonjaSettingLine({
    required this.label,
    this.note,
    this.value,
    this.trailing,
    this.below,
    this.chevron = false,
    this.onTap,
    super.key,
  });

  /// What the setting is. Already localised.
  final String label;

  /// One line under it, saying what the setting reaches. Already localised.
  final String? note;

  /// What it is set to, as a figure or a name. Already localised.
  final String? value;

  /// The control worked in place — a switch, or a mark.
  final Widget? trailing;

  /// A control too wide for the end of the line, set under the key.
  final Widget? below;

  /// Whether the row opens a screen of its own.
  ///
  /// Separate from [onTap] because not every tappable row leads away: the ruler
  /// row opens the calibration screen and prints its scale, and a chevron there
  /// would compete with the figure that is the reason to look at it.
  final bool chevron;

  /// Opens what the row leads to, or absent when the row is read-only or
  /// worked through [trailing].
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final String? sub = note;
    final String? reading = value;
    final Widget? control = trailing;
    final Widget? stacked = below;

    final Widget head = Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: tokens.density.gutter,
        vertical: LonjaSpace.s3,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(label, style: type.legalSmall, textAlign: TextAlign.start),
                if (sub != null) ...<Widget>[
                  const SizedBox(height: LonjaSpace.s1),
                  Text(
                    sub,
                    style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                    textAlign: TextAlign.start,
                  ),
                ],
              ],
            ),
          ),
          if (reading != null) ...<Widget>[
            const SizedBox(width: LonjaSpace.s4),
            // The mono figure step, because this is the thing being compared —
            // against another phone, against a printed pack, against what the
            // fisher set it to last time. Flexible and wrapping rather than
            // truncated: a reading with its last digits cut off is worse than
            // one on two lines.
            Flexible(
              child: Text(
                reading,
                style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
                textAlign: TextAlign.end,
              ),
            ),
          ],
          if (control != null) ...<Widget>[const SizedBox(width: LonjaSpace.s3), control],
          if (chevron) ...<Widget>[
            const SizedBox(width: LonjaSpace.s2),
            // Excluded rather than labelled: the key beside it already names
            // where the row goes, and a screen reader that announced the
            // chevron as well would read every row twice.
            ExcludeSemantics(
              child: LonjaIcon(
                LonjaIcons.forward,
                size: LonjaIconSize.caption,
                color: tokens.onSurfaceMuted,
              ),
            ),
          ],
        ],
      ),
    );

    final Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ConstrainedBox(
          // The row's own floor, so a gloved thumb finds the line and not the
          // one under it.
          constraints: BoxConstraints(minHeight: tokens.density.rowHeight),
          child: head,
        ),
        if (stacked != null)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: tokens.density.gutter,
              end: tokens.density.gutter,
              bottom: LonjaSpace.s3,
            ),
            child: stacked,
          ),
      ],
    );

    final VoidCallback? open = onTap;
    // Merged, so the key, its note and its reading arrive as one announcement
    // rather than as three nodes a switch-control user has to step through.
    return MergeSemantics(
      child: Semantics(
        button: open != null,
        child: open == null
            ? body
            : GestureDetector(behavior: HitTestBehavior.opaque, onTap: open, child: body),
      ),
    );
  }
}
