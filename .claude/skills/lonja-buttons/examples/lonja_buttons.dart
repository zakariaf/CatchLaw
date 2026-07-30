// Demonstrates the Lonja action component itself: four named LonjaButton constructors for
// the ladder, a shadow-free ButtonStyle whose six states resolve through WidgetStateProperty,
// glove-mode sizing, a busy latch drawn as a printed rule rather than a spinner, and an icon
// button whose semanticLabel is a required parameter.
// The call site — one primary per screen, the latched handler, the disabled reason and the
// destructive hand-off — is in examples/result_actions.dart.
// LIMITS: the Color constants below stand in for ThemeExtension slots owned by
// `lonja-design-tokens` — only the paper theme is shown, and in the app tree this widget
// file holds ZERO hex. Icons stand in for the plate set owned by `lonja-icons-and-plates`.
// Conceptually compiles against flutter.

import 'package:flutter/material.dart';

/// Density switch plus the token slots this file reads. Glove mode is orthogonal to theme
/// and is never inferred from screen width.
class Lonja extends InheritedWidget {
  const Lonja({required this.isGlove, required super.child, super.key});

  final bool isGlove;

  static Lonja of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Lonja>()!;

  @override
  bool updateShouldNotify(Lonja oldWidget) => oldWidget.isGlove != isGlove;

  static const ink = Color(0xFF16201C), inkMuted = Color(0xFF3D4A44), inkFaint = Color(0xFF6C7871);
  static const rule = Color(0xFFC2C5BB), paperSunk = Color(0xFFDEDBD1);
  static const harbour = Color(0xFF1B4D5E), onHarbour = Color(0xFFEFF1EC);
  static const oxblood = Color(0xFF7A2320), onOxblood = Color(0xFFE9DCD6);
}

enum LonjaButtonVariant {
  primary, secondary, quiet, destructive;

  bool get isFilled => this == primary || this == destructive;
}

class LonjaButton extends StatelessWidget {
  const LonjaButton.primary({required this.label, required this.onPressed, this.icon, this.busy = false, super.key})
      : variant = LonjaButtonVariant.primary, compact = false;
  const LonjaButton.secondary({required this.label, required this.onPressed, this.icon, this.compact = false, super.key})
      : variant = LonjaButtonVariant.secondary, busy = false;
  const LonjaButton.quiet({required this.label, required this.onPressed, this.icon, this.compact = false, super.key})
      : variant = LonjaButtonVariant.quiet, busy = false;
  const LonjaButton.destructive({required this.label, required this.onPressed, this.icon, super.key})
      : variant = LonjaButtonVariant.destructive, compact = false, busy = false;

  final String label;
  final IconData? icon;
  final LonjaButtonVariant variant;
  final bool compact;
  final bool busy;

  /// null disables the button — and rule 9 requires adjacent prose saying why.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final glove = Lonja.of(context).isGlove;
    final (Color field, Color text, Color edge) = switch (variant) {
      LonjaButtonVariant.primary => (Lonja.harbour, Lonja.onHarbour, Lonja.harbour),
      LonjaButtonVariant.secondary => (Colors.transparent, Lonja.ink, Lonja.ink),
      LonjaButtonVariant.quiet => (Colors.transparent, Lonja.inkMuted, Lonja.rule),
      LonjaButtonVariant.destructive => (Lonja.oxblood, Lonja.onOxblood, Lonja.oxblood),
    };

    // TextButton is only the unstyled base; every pixel below is authored here.
    final stamp = TextButton(
      onPressed: busy ? null : onPressed,
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory, // paper does not ripple
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
        minimumSize: WidgetStatePropertyAll(Size.fromHeight(glove ? 66 : (compact ? 46 : 56))),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
        textStyle: WidgetStatePropertyAll(TextStyle(
          fontSize: glove ? 16.5 : (compact ? 13.5 : 15), letterSpacing: 0.45,
          fontWeight: variant == LonjaButtonVariant.quiet ? FontWeight.w500 : FontWeight.w600,
        )),
        backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? Lonja.paperSunk : field),
        foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? Lonja.inkFaint : text),
        side: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.disabled)) return const BorderSide(color: Lonja.rule, width: 1.5);
          // Focus is a printed registration mark: heavier rule, identical box.
          if (s.contains(WidgetState.focused)) {
            return BorderSide(color: variant.isFilled ? Lonja.ink : Lonja.harbour, width: 3);
          }
          return BorderSide(color: edge, width: 1.5);
        }),
        overlayColor: WidgetStateProperty.resolveWith((s) {
          if (s.contains(WidgetState.pressed)) return Lonja.ink.withValues(alpha: 0.10);
          if (s.contains(WidgetState.hovered)) return Lonja.ink.withValues(alpha: 0.04);
          return Colors.transparent;
        }),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          if (icon != null) Icon(icon, size: glove ? 22 : 20),
          Flexible(child: Text(label, textAlign: TextAlign.center)), // wraps, never ellipses
        ],
      ),
    );

    if (!busy) return stamp;
    // Busy is a latch plus a 1.5dp printed rule. NEVER a CircularProgressIndicator: there is
    // no network here and every query is local SQLite that finishes inside a frame.
    return Stack(children: [
      stamp,
      const PositionedDirectional(
        bottom: 0, start: 0, end: 0,
        child: ColoredBox(color: Lonja.harbour, child: SizedBox(height: 1.5)),
      ),
    ]);
  }
}

class LonjaIconButton extends StatelessWidget {
  const LonjaIconButton({
    required this.icon,
    required this.semanticLabel, // required: an unlabelled glyph is silent to TalkBack
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final glove = Lonja.of(context).isGlove;
    final box = glove ? 56.0 : 44.0;
    return IconButton(
      onPressed: onPressed,
      tooltip: semanticLabel, // IconButton wires tooltip into its own Semantics node
      icon: Icon(icon, size: glove ? 24 : 22),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(width: box, height: box),
      style: IconButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        splashFactory: NoSplash.splashFactory,
      ),
    );
  }
}
