import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:flutter/material.dart';

/// The one raw `TextField` in the app.
///
/// A **ruled entry line** and not a Material input decoration. The whole
/// surface is a document, and a filled or outlined box with its own radius
/// reads as a form control pasted onto it — `check_lonja_controls.sh` fails
/// both, and this widget is why every screen can compose instead of reaching
/// for one.
///
/// The rule is drawn by a `DecoratedBox`, so it takes a Lonja weight and a
/// Lonja slot: `ruleBearing` at rest — a rule that *identifies* a control and
/// therefore clears the 3:1 floor — and `accent` at [LonjaRules.strong] on
/// focus, because the state change is a doubling of the rule, not a colour
/// nobody outdoors can see.
class LonjaSearchField extends StatefulWidget {
  /// A ruled entry line.
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

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            border: BorderDirectional(
              bottom: BorderSide(
                color: focused ? tokens.accent : tokens.ruleBearing,
                width: focused ? LonjaRules.strong : LonjaRules.rule,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s2),
            child: TextField(
              // **Never on launch.** An auto-raised keyboard covers the recents
              // strip, which is the one-tap path to a verdict for a fisher who
              // has been here before — and §3's five seconds get spent
              // dismissing it. He taps the field when he wants to type.
              autofocus: false,
              controller: widget.controller,
              focusNode: _focus,
              onChanged: widget.onChanged,
              style: type.legal,
              textAlign: TextAlign.start,
              // No border of its own: the rule above is the control's frame,
              // and two frames is a box.
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
        ),
      ),
    );
  }
}
