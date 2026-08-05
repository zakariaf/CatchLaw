import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';

/// The one raw `TextField` in the app.
///
/// A **ruled entry box** and not a Material input decoration. The whole surface
/// is a document, and a filled or rounded box with its own radius reads as a
/// form control pasted onto it — `check_lonja_controls.sh` fails both, and this
/// widget is why every screen can compose instead of reaching for one.
///
/// The frame is drawn by a `DecoratedBox`, so it takes a Lonja weight and a
/// Lonja slot: `ruleBearing` at rest — a rule that *identifies* a control and
/// therefore clears the 3:1 floor — and `accent` at [LonjaRules.strong] on
/// focus, because the state change is a doubling of the rule, not a colour
/// nobody outdoors can see. Four sides and not one, on the sunk ground: this is
/// the one place on the page where a fisher writes, and a single underline is
/// indistinguishable from the section rules ruling the sheet around it.
///
/// The glass at the leading edge says what the box reads without a label above
/// it; the cross at the trailing edge appears only once there is something to
/// take away.
class LonjaSearchField extends StatefulWidget {
  /// A ruled entry box.
  const LonjaSearchField({
    required this.hint,
    required this.onChanged,
    this.controller,
    this.semanticLabel,
    super.key,
  });

  /// Illustrative examples, already localised.
  final String hint;

  /// Fires on every keystroke. The §13 budget is per keystroke.
  final ValueChanged<String> onChanged;

  /// Optional external control of the text.
  final TextEditingController? controller;

  /// What a screen reader announces the field as.
  final String? semanticLabel;

  @override
  State<LonjaSearchField> createState() => _LonjaSearchFieldState();
}

class _LonjaSearchFieldState extends State<LonjaSearchField> {
  final FocusNode _focus = FocusNode();

  /// Whether the box currently holds anything to take away.
  ///
  /// Tracked here rather than read off the controller, because the controller
  /// is optional: a screen that lets the `TextField` own its text still gets
  /// the cross, and one that owns the text gets it cleared through the same
  /// path the keystrokes come down.
  bool _written = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
    _written = widget.controller?.text.isNotEmpty ?? false;
  }

  void _onFocusChanged() => setState(() {});

  void _onChanged(String value) {
    final bool written = value.isNotEmpty;
    if (written != _written) setState(() => _written = written);
    widget.onChanged(value);
  }

  void _clear() {
    widget.controller?.clear();
    setState(() => _written = false);
    // The same callback a keystroke takes: the screen above has one path from
    // the entry line to its results, and a cross that emptied the box without
    // walking it would leave the old matches under an empty field.
    widget.onChanged('');
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final bool focused = _focus.hasFocus;

    return Semantics(
      textField: true,
      label: widget.semanticLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tokens.density.tapMin),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.surfaceSunk,
            border: Border.all(
              color: focused ? tokens.accent : tokens.ruleBearing,
              width: focused ? LonjaRules.strong : LonjaRules.rule,
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: LonjaSpace.s3,
              vertical: LonjaSpace.s2,
            ),
            child: Row(
              children: <Widget>[
                // Excluded rather than labelled: the field beside it is already
                // announced as a text field with its own name, and a glass that
                // spoke would say the same thing twice.
                ExcludeSemantics(child: LonjaIcon(LonjaIcons.search, color: tokens.onSurface)),
                const SizedBox(width: LonjaSpace.s3),
                Expanded(
                  child: TextField(
                    // **Never on launch.** An auto-raised keyboard covers the
                    // recents strip, which is the one-tap path to a verdict for
                    // a fisher who has been here before — and §3's five seconds
                    // get spent dismissing it. He taps the field when he wants
                    // to type.
                    autofocus: false,
                    controller: widget.controller,
                    focusNode: _focus,
                    onChanged: _onChanged,
                    style: type.legal,
                    textAlign: TextAlign.start,
                    // No border of its own: the frame around this row is the
                    // control's, and two frames is a box inside a box.
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: type.legal.copyWith(color: tokens.onSurfaceFaint),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_written)
                  IconButton(
                    tooltip: l10n.speciesSearchClear,
                    icon: LonjaIcon(
                      LonjaIcons.cross,
                      size: LonjaIconSize.caption,
                      color: tokens.onSurfaceMuted,
                      semanticLabel: l10n.speciesSearchClear,
                    ),
                    onPressed: _clear,
                    constraints: BoxConstraints(
                      minWidth: tokens.density.tapMin,
                      minHeight: tokens.density.tapMin,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
