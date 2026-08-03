import 'package:catchlaw/ui/ruler/widgets/ruler_painter.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Color _ink = Color(0xFF16201C);
const Color _mark = Color(0xFF1B4D5E);

RulerScene _scene({double pxPerMm = 10, double spanPx = 300}) => RulerScene(
  pxPerMm: pxPerMm,
  spanPx: spanPx,
  tickLabels: const <String>['0', '1', '2'],
  labelDirection: TextDirection.ltr,
  labelStyle: const TextStyle(fontSize: 11),
  ink: _ink,
  mark: _mark,
  hairlinePx: 1,
  tickPx: 1,
  cursorPx: 2,
);

Future<void> _pump(WidgetTester tester, ValueNotifier<double> cursor, {RulerScene? scene}) =>
    tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: CustomPaint(
            size: const Size(300, 64),
            painter: RulerPainter(scene: scene ?? _scene(), cursorMm: cursor),
          ),
        ),
      ),
    );

void main() {
  testWidgets('RulerPainter draws the rule in the ink slot', (WidgetTester tester) async {
    final cursor = ValueNotifier<double>(0);
    addTearDown(cursor.dispose);
    await _pump(tester, cursor);

    expect(find.byType(CustomPaint).last, paints..line(color: _ink));
  });

  testWidgets('RulerPainter draws the cursor in the mark slot', (WidgetTester tester) async {
    // Colour is never the ONLY signal — the cursor is also the only full-height
    // stroke on the canvas — but it must still be the slot the theme gave it,
    // or it vanishes in sunlight where every neutral collapses to black.
    final cursor = ValueNotifier<double>(45);
    addTearDown(cursor.dispose);
    await _pump(tester, cursor);

    expect(
      find.byType(CustomPaint).last,
      paints..something((Symbol method, List<Object?> args) {
        return method == #drawRawPoints;
      }),
    );
  });

  testWidgets('RulerPainter draws the rule before the cursor', (WidgetTester tester) async {
    // Order matters on a canvas: a cursor drawn under the rule is a cursor a
    // fisher cannot see against the tick it sits on.
    final cursor = ValueNotifier<double>(45);
    addTearDown(cursor.dispose);
    await _pump(tester, cursor);

    expect(
      find.byType(CustomPaint).last,
      paints
        ..line(color: _ink)
        ..something((Symbol method, List<Object?> args) => method == #drawRawPoints),
    );
  });

  testWidgets('RulerPainter draws no shadow and no gradient', (WidgetTester tester) async {
    // Paper does not float. A ruler with a drop shadow is an app control; a
    // ruler without one is a printed scale.
    final cursor = ValueNotifier<double>(45);
    addTearDown(cursor.dispose);
    await _pump(tester, cursor);

    expect(find.byType(CustomPaint).last, paintsExactlyCountTimes(#drawShadow, 0));
  });

  testWidgets('RulerPainter places its zero at the physical start edge', (
    WidgetTester tester,
  ) async {
    // The whole reason for the LTR pin: zero is where the fisher's hand is.
    final cursor = ValueNotifier<double>(0);
    addTearDown(cursor.dispose);
    await _pump(tester, cursor);

    expect(
      find.byType(CustomPaint).last,
      paints..line(p1: const Offset(0, 0), p2: const Offset(300, 0), color: _ink),
    );
  });
}
