// The harness's own rows. Deliberately outside test/l10n/golden/ and untagged:
// they render nothing that depends on font rasterisation, and a harness bug
// should fail on every machine rather than only on the Linux lane.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../l10n/golden/numeral_specimen.dart';
import 'golden.dart';

void main() {
  testWidgets('pumpLocalised resolves TextDirection.rtl for ar', (WidgetTester tester) async {
    // The harness itself must be right, or every golden taken through it is
    // measuring the wrong tree.
    late TextDirection observed;
    tester.useDevice(Device.small);
    await tester.pumpLocalised(
      Builder(
        builder: (BuildContext context) {
          observed = Directionality.of(context);
          return const SizedBox.shrink();
        },
      ),
      const Locale('ar'),
    );
    expect(observed, TextDirection.rtl);
  });

  testWidgets('useDevice sets physicalSize to the logical size multiplied by the device pixel '
      'ratio', (WidgetTester tester) async {
    // physicalSize is in PHYSICAL pixels. Assigning Size(360, 800) directly at
    // DPR 3.0 gives a 120x267 logical surface — a documented trap that makes
    // everything overflow, or nothing, and either way stops the test being
    // about the widget.
    tester.useDevice(Device.small);
    expect(tester.view.physicalSize, const Size(1080, 2400));
    expect(tester.view.devicePixelRatio, 3.0);
  });

  testWidgets('useDevice restores the view after the test', (WidgetTester tester) async {
    // Guarded by addTearDown inside useDevice. This row is the proof that the
    // guard is wired, taken from a test that never called useDevice at all: a
    // leaked view size poisons every later test in the file and the failure
    // lands somewhere nobody edited.
    expect(tester.view.physicalSize, isNot(const Size(1080, 2400)));
  });

  testWidgets('NumeralSpecimen renders the resolved locale digits', (WidgetTester tester) async {
    tester.useDevice(Device.small);
    await tester.pumpLocalised(const NumeralSpecimen(), const Locale('es'));
    expect(find.text('1.234.567'), findsOneWidget);
    expect(find.text('45,5'), findsOneWidget);
  });
}
