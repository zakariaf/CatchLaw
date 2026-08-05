import 'package:catchlaw/ui/ruler/widgets/ruler_scene.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

RulerScene _scene({
  double pxPerMm = 6.299,
  double spanPx = 630,
  List<String> labels = const <String>['0', '1', '2'],
  TextDirection direction = TextDirection.ltr,
  Color ink = const Color(0xFF16201C),
  Color mark = const Color(0xFF7A2320),
  double hairlinePx = 1,
  double tickPx = 1,
  double cmTickPx = 1,
  double cursorPx = 2,
}) => RulerScene(
  pxPerMm: pxPerMm,
  spanPx: spanPx,
  tickLabels: labels,
  labelDirection: direction,
  labelStyle: const TextStyle(fontSize: 11),
  ink: ink,
  mark: mark,
  hairlinePx: hairlinePx,
  tickPx: tickPx,
  cmTickPx: cmTickPx,
  cursorPx: cursorPx,
);

void main() {
  // A field missing from == is a ruler that keeps painting paper hairlines
  // after the user taps into sunlight, or one that keeps the old scale after a
  // recalibration. The loop makes the missing field name itself.
  final mutations = <String, RulerScene>{
    'pxPerMm': _scene(pxPerMm: 7),
    'spanPx': _scene(spanPx: 640),
    'tickLabels': _scene(labels: const <String>['0', '1', '3']),
    'labelDirection': _scene(direction: TextDirection.rtl),
    'ink': _scene(ink: const Color(0xFF000000)),
    'mark': _scene(mark: const Color(0xFF000000)),
    'hairlinePx': _scene(hairlinePx: 2),
    'tickPx': _scene(tickPx: 2),
    'cmTickPx': _scene(cmTickPx: 2),
    'cursorPx': _scene(cursorPx: 3),
  };
  mutations.forEach((String field, RulerScene changed) {
    test('RulerScene == returns false when $field alone differs', () {
      expect(_scene(), isNot(changed));
    });
  });

  test('RulerScene == returns true for two identical scenes', () {
    // Value equality, not identity: the scene is rebuilt every frame by the
    // widget above, and a scene that compared unequal to itself would repaint
    // the ruler on every tick while a wet hand holds the phone still.
    expect(_scene(), _scene());
    expect(_scene().hashCode, _scene().hashCode);
  });

  test('RulerScene carries a label direction of its own', () {
    // The ruler does NOT mirror — SPEC.md §9.3's one documented exception — so
    // the direction the LABELS read is carried explicitly rather than inherited
    // from an ambient Directionality that would flip the scale itself.
    expect(_scene(direction: TextDirection.rtl).labelDirection, TextDirection.rtl);
  });
}
