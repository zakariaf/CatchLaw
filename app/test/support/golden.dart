/// The golden harness — about sixty lines, hand-written, no package.
///
/// A helper, deliberately not named `_test.dart`: a helper with that suffix is
/// executed as a suite of zero tests and fails the run (`CONVENTIONS.md` §6).
///
/// `FLUTTER_GUIDE.md` §6.3 settled the tooling by reading the packages.
/// `golden_toolkit` is discontinued with an SDK constraint that cannot resolve
/// on Dart 3. `alchemist` is a **bad fit for Arabic goldens** specifically:
/// its CI mode replaces glyphs with coloured blocks, which is exactly the
/// failure this harness exists to prevent. So: built-in `matchesGoldenFile`,
/// plus what is here.
library;

import 'package:catchlaw/app.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A screen size and its pixel ratio.
class Device {
  /// Names a surface.
  const Device(this.name, this.logicalSize, this.dpr);

  /// What the golden filename says.
  final String name;

  /// Logical pixels — what the widget tree lays out in.
  final Size logicalSize;

  /// Physical pixels per logical pixel.
  final double dpr;

  /// A small modern handset, which is the constrained end of `SPEC.md` §13.
  static const Device small = Device('small_360', Size(360, 800), 3.0);
}

/// Loads the two bundled faces into the test binding.
///
/// Without this, `flutter test` runs with a test font whose every glyph is an
/// identical box and which has **no Arabic coverage at all**. An `ar` golden
/// taken under it is byte-identical to the `en` golden of the same widget: the
/// test passes, keeps passing through any amount of broken Arabic shaping, and
/// is worthless (`FLUTTER_GUIDE.md` §6.4 point 1).
Future<void> loadCatchlawFonts() async {
  const families = <String, String>{
    'NotoSans': 'assets/fonts/NotoSans-Regular.ttf',
    'NotoNaskhArabic': 'assets/fonts/NotoNaskhArabic-Regular.ttf',
  };
  for (final MapEntry<String, String> family in families.entries) {
    final loader = FontLoader(family.key)..addFont(rootBundle.load(family.value));
    await loader.load();
  }
}

/// Device sizing and locale pumping, on the tester itself.
extension GoldenHarness on WidgetTester {
  /// Sizes the surface for [device].
  ///
  /// `physicalSize` is in **physical** pixels, so it is the logical size times
  /// the ratio. `Size(360, 800)` assigned directly at DPR 3.0 gives a 120×267
  /// logical surface — everything overflows, or nothing does, and either way
  /// the test stops being about the widget.
  void useDevice(Device device) {
    view.devicePixelRatio = device.dpr;
    view.physicalSize = device.logicalSize * device.dpr;
    // One call, so nothing is forgotten. A leaked view size poisons every later
    // test in the file and the failure lands somewhere nobody edited.
    addTearDown(view.reset);
  }

  /// Pumps [child] inside the real app root at [locale].
  ///
  /// The real root, so the direction under test is the one
  /// `GlobalWidgetsLocalizations` produces rather than one the harness chose.
  /// The `ProviderScope` is bare: the data seams throw by name, the notifiers
  /// land in `AsyncError`, and the pinned locale is what decides — which is the
  /// point.
  ///
  /// One `pump()`, never `pumpAndSettle`: it carries a ten-minute timeout,
  /// truncates its stack trace, and hangs forever on an indefinite indicator.
  Future<void> pumpLocalised(Widget child, Locale locale) async {
    await pumpWidget(
      ProviderScope(
        child: CatchlawApp(
          locale: locale,
          home: RepaintBoundary(child: Center(child: child)),
        ),
      ),
    );
    await pump();
  }
}

/// `ar`, `pt_BR` — what a golden filename is suffixed with.
String localeTag(Locale locale) => locale.countryCode == null || locale.countryCode!.isEmpty
    ? locale.languageCode
    : '${locale.languageCode}_${locale.countryCode}';
