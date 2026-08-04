import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/widgets.dart';

/// One choice from a short, fixed set — as a row of ruled cells.
///
/// **Not a Material `SegmentedButton` (rules 1 and 2).** That widget is a
/// stadium: rounded ends, a filled `secondaryContainer` ground and a checkmark
/// that appears on selection and reflows every other label when it does. Lonja's
/// authority comes from looking like the printed instrument it quotes, so a
/// choice is a row of square cells divided by rules.
///
/// **Selected is fill AND weight AND a rule above (rule 8).** Never `accent`
/// alone: invariant 4 forbids colour as the only signal anywhere in this app,
/// and this control is read in glare with a wet screen. The three signals are
/// independent, so a greyscale proof still shows which cell is chosen.
///
/// For two to four options. More than that is a list, not a segmented control,
/// and a five-cell row on a small phone truncates every label to an initial.
class LonjaSegmented<T> extends StatelessWidget {
  /// Chooses among [options], with [value] selected, through [onChanged].
  const LonjaSegmented({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The choices, in the order they are shown. Labels are already localised.
  final List<LonjaSegment<T>> options;

  /// Which one is chosen.
  final T value;

  /// Called with the chosen value.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tokens.onSurface, width: LonjaRules.rule),
      ),
      child: Row(
        children: <Widget>[
          for (final (int i, LonjaSegment<T> option) in options.indexed)
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: BorderDirectional(
                    // A divider between cells and no outer double rule: the box
                    // above already draws the outside.
                    start: i == 0
                        ? BorderSide.none
                        : BorderSide(color: tokens.onSurface, width: LonjaRules.rule),
                  ),
                ),
                child: _Cell<T>(
                  option: option,
                  selected: option.value == value,
                  onTap: () => onChanged(option.value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One option in a [LonjaSegmented].
class LonjaSegment<T> {
  /// [label] stands for [value].
  const LonjaSegment({required this.value, required this.label});

  /// What choosing this cell means.
  final T value;

  /// What the cell says. Already localised.
  final String label;
}

class _Cell<T> extends StatelessWidget {
  const _Cell({required this.option, required this.selected, required this.onTap});

  final LonjaSegment<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Semantics(
      button: true,
      selected: selected,
      label: option.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: tokens.density.tapMin),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? tokens.onSurface : tokens.surface,
            border: BorderDirectional(
              top: selected
                  ? BorderSide(color: tokens.onSurface, width: LonjaRules.stamp)
                  : BorderSide.none,
            ),
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LonjaSpace.s2,
            vertical: LonjaSpace.s2,
          ),
          child: Text(
            option.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: selected
                ? type.ui.copyWith(color: tokens.surface, fontWeight: FontWeight.w700)
                : type.ui.copyWith(color: tokens.onSurface),
          ),
        ),
      ),
    );
  }
}
