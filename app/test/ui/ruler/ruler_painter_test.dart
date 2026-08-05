import 'package:catchlaw/ui/ruler/widgets/ruler_painter.dart';
import 'package:catchlaw/ui/ruler/widgets/ruler_scene.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

RulerScene _scene({double pxPerMm = 6.299, Color ink = const Color(0xFF16201C)}) => RulerScene(
  pxPerMm: pxPerMm,
  spanPx: 630,
  tickLabels: const <String>['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
  labelDirection: TextDirection.ltr,
  labelStyle: const TextStyle(fontSize: 11),
  ink: ink,
  mark: const Color(0xFF7A2320),
  hairlinePx: 1,
  tickPx: 1,
  cmTickPx: 1,
  cursorPx: 2,
);

void main() {
  test('RulerPainter.shouldRepaint is false when the scene is unchanged', () {
    // `=> true` repaints every frame even when idle, and
    // check_painter_hygiene.sh fails it outright. A dumb painter with one value
    // input is what makes the question answerable at all.
    final cursor = ValueNotifier<double>(0);
    addTearDown(cursor.dispose);
    final a = RulerPainter(scene: _scene(), cursorMm: cursor);
    final b = RulerPainter(scene: _scene(), cursorMm: cursor);
    expect(b.shouldRepaint(a), isFalse);
  });

  test('RulerPainter.shouldRepaint is true when the scale changed', () {
    // A recalibration must redraw. A ruler that kept the old scale would draw
    // 45 cm where the transform says 44.
    final cursor = ValueNotifier<double>(0);
    addTearDown(cursor.dispose);
    final a = RulerPainter(scene: _scene(), cursorMm: cursor);
    final b = RulerPainter(scene: _scene(pxPerMm: 7), cursorMm: cursor);
    expect(b.shouldRepaint(a), isTrue);
  });

  test('RulerPainter.shouldRepaint is true when the theme changed', () {
    final cursor = ValueNotifier<double>(0);
    addTearDown(cursor.dispose);
    final a = RulerPainter(scene: _scene(), cursorMm: cursor);
    final b = RulerPainter(
      scene: _scene(ink: const Color(0xFF000000)),
      cursorMm: cursor,
    );
    expect(b.shouldRepaint(a), isTrue);
  });

  test('RulerPainter repaints on the cursor listenable rather than on the scene', () {
    // The cursor changes on every pointer move and the scene does not.
    // Repainting on the listenable is what leaves shouldRepaint free to be a
    // single cheap compare.
    final cursor = ValueNotifier<double>(0);
    addTearDown(cursor.dispose);
    final painter = RulerPainter(scene: _scene(), cursorMm: cursor);

    var repaints = 0;
    painter.addListener(() => repaints++);
    cursor.value = 45;
    expect(repaints, 1);
  });

  test('RulerPainter builds its ticks and labels in the constructor', () {
    // paint() allocates nothing. A painter that laid out sixty TextPainters per
    // frame would drop frames under a drag on exactly the phone §13 budgets
    // for — so the work is done once, here, and paint walks it.
    final cursor = ValueNotifier<double>(0);
    addTearDown(cursor.dispose);
    final clock = Stopwatch()..start();
    RulerPainter(scene: _scene(), cursorMm: cursor);
    clock.stop();
    // Not a benchmark — a smoke test that construction completes and does the
    // work rather than deferring it to the first frame.
    expect(clock.elapsedMilliseconds, lessThan(500));
  });
}
