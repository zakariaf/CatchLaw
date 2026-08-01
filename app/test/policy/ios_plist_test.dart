import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'repo_root.dart';

/// D-3, in the Apple spelling: pt-BR.lproj, never pt_BR.lproj and never pt.lproj.
const shippedLocales = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt-BR'];

const usageKeys = <String>['NSCameraUsageDescription', 'NSLocationWhenInUseUsageDescription'];

String plist() => repoFile('app/ios/Runner/Info.plist').readAsStringSync();

bool declaresKey(String key) => RegExp('<key>$key</key>').hasMatch(plist());

String pbxproj() => repoFile('app/ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();

String strings(String locale) =>
    repoFile('app/ios/Runner/$locale.lproj/InfoPlist.strings').readAsStringSync();

void main() {
  for (final String key in usageKeys) {
    test('Info.plist declares $key', () {
      expect(declaresKey(key), isTrue);
    });
  }

  test('Info.plist does not declare NSLocationAlwaysAndWhenInUseUsageDescription', () {
    expect(
      declaresKey('NSLocationAlwaysAndWhenInUseUsageDescription'),
      isFalse,
      reason:
          'the zone suggestion is a single-shot, user-initiated fix (SPEC.md §10) — '
          'asking for always-on location is a capability the product does not use',
    );
  });

  test('Info.plist does not declare NSPhotoLibraryUsageDescription', () {
    expect(
      declaresKey('NSPhotoLibraryUsageDescription'),
      isFalse,
      reason:
          'SPEC.md §10 rejects image_picker so photos never enter the shared camera '
          'roll; this string is what appears when that rejection is undone',
    );
  });

  test('Info.plist declares no NSAppTransportSecurity key', () {
    expect(
      declaresKey('NSAppTransportSecurity'),
      isFalse,
      reason:
          'SPEC.md §14: no ATS exceptions. The strict default is stronger than any '
          'dict we could write, and an exception is only added inside one that exists',
    );
  });

  test('Info.plist lists exactly the six shipped locales in CFBundleLocalizations', () {
    final RegExpMatch? block = RegExp(
      r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist());
    expect(block, isNotNull);
    final Set<String> listed = RegExp(
      r'<string>([^<]+)</string>',
    ).allMatches(block![1]!).map((m) => m[1]!).toSet();
    expect(listed, shippedLocales.toSet(), reason: 'D-3: Catalan ships, Urdu does not');
  });

  for (final String locale in shippedLocales) {
    test('InfoPlist.strings exists for $locale', () {
      expect(repoFile('app/ios/Runner/$locale.lproj/InfoPlist.strings').existsSync(), isTrue);
    });

    test('$locale InfoPlist.strings defines both usage-string keys', () {
      final List<String> missing = usageKeys.where((k) => !strings(locale).contains(k)).toList();
      expect(
        missing,
        isEmpty,
        reason:
            'a missing key falls back to the base language inside a permission '
            'dialog, which is where a fisher decides whether to trust the app:\n$missing',
      );
    });
  }

  test('No lproj directory names a locale outside the six', () {
    final Set<String> found = repoDir('app/ios/Runner')
        .listSync()
        .whereType<Directory>()
        .map((d) => d.path.split('/').last)
        .where((n) => n.endsWith('.lproj'))
        .map((n) => n.substring(0, n.length - '.lproj'.length))
        .where((n) => n != 'Base')
        .toSet();
    expect(
      found.difference(shippedLocales.toSet()),
      isEmpty,
      reason: 'D-3, in the Apple spelling: pt-BR, never pt_BR and never pt',
    );
  });

  test('Info.plist sets MinimumOSVersion to 13.0', () {
    expect(plist(), matches(RegExp(r'<key>MinimumOSVersion</key>\s*<string>13\.0</string>')));
  });

  test('Podfile pins the iOS platform to 13.0', () {
    expect(repoFile('app/ios/Podfile').readAsStringSync(), contains("platform :ios, '13.0'"));
  });

  test('Info.plist records that iOS provides no permission-level network block', () {
    expect(
      plist(),
      contains('no permission-level network opt-out'),
      reason:
          'a plist with no note invites the next person to add ATS and call it a '
          'guarantee — which is exactly what the first draft did',
    );
  });

  // These two exist because the twelve rows above ALL PASSED while the six
  // .lproj bundles were absent from the built Runner.app: creating the
  // directories on disk is not what ships them. Xcode ships a localisation only
  // if the project registers it, so that is what these assert. Caught by
  // building on a Mac and reading the bundle, which is why the task asks for it.
  for (final String locale in shippedLocales) {
    test('Xcode project lists $locale in knownRegions', () {
      final RegExpMatch? block = RegExp(
        r'knownRegions = \((.*?)\);',
        dotAll: true,
      ).firstMatch(pbxproj());
      expect(block, isNotNull);
      expect(
        block![1]!.replaceAll('"', ''),
        contains(locale),
        reason:
            'a locale missing from knownRegions is silently dropped from the '
            'bundle, and the permission dialog falls back to English',
      );
    });
  }

  test('Xcode project ships InfoPlist.strings through the Resources build phase', () {
    expect(
      pbxproj(),
      contains('InfoPlist.strings in Resources'),
      reason:
          'without the build-file entry the variant group is visible in Xcode '
          'and absent from Runner.app — which is exactly what happened here',
    );
    final List<String> missing = shippedLocales
        .where((l) => !pbxproj().contains('$l.lproj/InfoPlist.strings'))
        .toList();
    expect(missing, isEmpty, reason: 'not referenced by the project:\n$missing');
  });
}
