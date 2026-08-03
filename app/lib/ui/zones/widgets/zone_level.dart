import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:flutter/material.dart';

/// One line of one level of the picker.
///
/// `ZoneLine` and not `ZoneRow`: `layering_test.dart` bans every `*Row`
/// identifier outside `lib/data`, because drift names its generated row classes
/// that way and a boundary that has to tell a real one from a lookalike is not
/// a boundary.
///
/// The whole rect is the target, at the density's own minimum — not the text,
/// and not a trailing chevron. A fisher with wet gloves taps a row, and a row
/// whose hit area is its label is a row he misses.
class ZoneLine extends StatelessWidget {
  /// A pickable place.
  const ZoneLine({required this.label, required this.selected, required this.onTap, super.key});

  /// Already localised.
  final String label;

  /// Whether this is the current choice.
  final bool selected;

  /// Picks it.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: tokens.density.rowHeight),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: tokens.hairline, width: LonjaRules.hair),
            ),
          ),
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: LonjaSpace.s4,
            vertical: LonjaSpace.s2,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  // Selection is carried by weight and by the mark beside it,
                  // never by colour alone: this list is read in sunlight, where
                  // a tint is the first thing to go.
                  style: selected
                      ? type.uiLarge.copyWith(color: tokens.onSurface)
                      : type.ui.copyWith(color: tokens.onSurface),
                  textAlign: TextAlign.start,
                ),
              ),
              if (selected)
                Text(
                  '·',
                  style: type.uiLarge.copyWith(color: tokens.onSurface),
                  textAlign: TextAlign.end,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A labelled level: a heading and its rows.
///
/// A `Column` rather than a builder. Countries, jurisdictions and sub-zones are
/// each a handful of rows in a bundled pack, and a nested viewport inside the
/// picker's own scroll buys nothing.
class ZoneLevel extends StatelessWidget {
  /// The [label] heading and its [children].
  const ZoneLevel({required this.label, required this.children, super.key});

  /// Already localised.
  final String label;

  /// The rows.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      LonjaSectionLabel(text: label),
      ...children,
      const SizedBox(height: LonjaSpace.s5),
    ],
  );
}
