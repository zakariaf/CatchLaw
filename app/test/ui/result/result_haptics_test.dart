import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/widgets/result_haptics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add('${call.arguments}');
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  group('ResultHaptics', () {
    test('.announce fires one light impact for a met rule', () async {
      await ResultHaptics.announce(VerdictCategory.meets);

      expect(calls, <String>['HapticFeedbackType.lightImpact']);
    });

    test('.announce fires two heavy impacts below a minimum', () async {
      await ResultHaptics.announce(VerdictCategory.belowMinimum);

      // Count and weight, not duration: a single long buzz is indistinguishable
      // from a notification through a wet glove.
      expect(calls, <String>['HapticFeedbackType.heavyImpact', 'HapticFeedbackType.heavyImpact']);
    });

    test('.announce fires two heavy impacts for a prohibition', () async {
      await ResultHaptics.announce(VerdictCategory.protected);

      expect(calls, hasLength(2));
      expect(calls.toSet(), <String>{'HapticFeedbackType.heavyImpact'});
    });

    test('.announce separates the two adverse impacts', () async {
      expect(ResultHaptics.betweenImpacts, const Duration(milliseconds: 120));
    });
  });
}
