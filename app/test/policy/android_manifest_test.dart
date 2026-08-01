import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'repo_root.dart';

final _xmlComment = RegExp(r'<!--.*?-->', dotAll: true);

/// Manifest text with comments removed. The manifests explain the INTERNET ban
/// in a comment that contains the banned string; without this the rule's own
/// explanation fails the rule (policy-grep-gate.md).
String xmlOf(String sourceSet) => repoFile(
  'app/android/app/src/$sourceSet/AndroidManifest.xml',
).readAsStringSync().replaceAll(_xmlComment, '');

const shipping = <String>['main', 'release'];
const devOnly = <String>['debug', 'profile'];

final _internetElement = RegExp(
  r'<uses-permission[^>]*android:name="android\.permission\.INTERNET"[^>]*>',
);

void main() {
  test('Release manifest removes android.permission.INTERNET', () {
    final RegExpMatch? match = _internetElement.firstMatch(xmlOf('release'));
    expect(match, isNotNull);
    expect(match![0], contains('tools:node="remove"'));
  });

  test('Release manifest declares the tools namespace', () {
    expect(
      xmlOf('release'),
      contains('xmlns:tools="http://schemas.android.com/tools"'),
      reason:
          'the merger raises an unresolved-prefix error without it, and the fix '
          'somebody reaches for is deleting the whole uses-permission line',
    );
  });

  test('Main manifest removes android.permission.INTERNET', () {
    final RegExpMatch? match = _internetElement.firstMatch(xmlOf('main'));
    expect(match, isNotNull);
    expect(
      match![0],
      contains('tools:node="remove"'),
      reason:
          'this is what strips a grant merged in by a plugin AAR — a case no grep '
          'over our own source can reach',
    );
  });

  for (final String sourceSet in devOnly) {
    test('${sourceSet[0].toUpperCase()}${sourceSet.substring(1)} manifest grants '
        'android.permission.INTERNET', () {
      final RegExpMatch? match = _internetElement.firstMatch(xmlOf(sourceSet));
      expect(
        match,
        isNotNull,
        reason:
            'the Dart VM service needs it; a guard that breaks flutter run is a '
            'guard someone deletes before lunch',
      );
      expect(match![0], isNot(contains('tools:node="remove"')));
    });
  }

  test('Main manifest sets android:allowBackup to false', () {
    expect(
      xmlOf('main'),
      contains('android:allowBackup="false"'),
      reason:
          'the attribute defaults to TRUE — left alone the OS uploads the catch '
          'log to a cloud backup the user never chose (SPEC.md §11)',
    );
  });

  test('No manifest declares dataExtractionRules or fullBackupContent', () {
    final offenders = <String>[
      for (final s in <String>[...shipping, ...devOnly])
        if (xmlOf(s).contains('dataExtractionRules') || xmlOf(s).contains('fullBackupContent')) s,
    ];
    expect(offenders, isEmpty, reason: 'the API-31 way to re-enable backup:\n$offenders');
  });

  test('No manifest declares ACCESS_BACKGROUND_LOCATION', () {
    final offenders = <String>[
      for (final s in <String>[...shipping, ...devOnly])
        if (xmlOf(s).contains('ACCESS_BACKGROUND_LOCATION')) s,
    ];
    expect(
      offenders,
      isEmpty,
      reason:
          'the zone suggestion is a single-shot fix; SPEC.md §14 names this '
          'permission as a release blocker:\n$offenders',
    );
  });

  test('build.gradle.kts sets minSdk to 24', () {
    expect(
      repoFile('app/android/app/build.gradle.kts').readAsStringSync(),
      contains('minSdk = 24'),
    );
  });

  test('No shipping manifest grants INTERNET without the remove marker', () {
    final offenders = <String>[
      for (final dir in repoDir('app/android/app/src').listSync().whereType<Directory>())
        if (!devOnly.contains(dir.path.split('/').last) &&
            File('${dir.path}/AndroidManifest.xml').existsSync())
          for (final m in _internetElement.allMatches(
            File('${dir.path}/AndroidManifest.xml').readAsStringSync().replaceAll(_xmlComment, ''),
          ))
            if (!m[0]!.contains('tools:node="remove"')) dir.path,
    ];
    expect(offenders, isEmpty, reason: 'layer 2 breached:\n${offenders.join('\n')}');
  });
}
