import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../policy/repo_root.dart';

/// §13's cold start, asserted as facts about the tree rather than as a stopwatch.
///
/// **A number measured on a CI runner is a fiction.** §13 budgets < 1.2 s on a
/// low-end Android device, and GitHub's runners are not that device; an emulator
/// figure would be precise and meaningless. What can be asserted here is the
/// structure that makes the budget reachable, and every one of these is a thing
/// that has silently cost a second in some other app.
void main() {
  String source(String path) => File(repoFile(path).path).readAsStringSync();

  test('main does not await before runApp', () {
    // The strongest of the four. An await here is a black screen on a dark
    // boat, and a black screen is indistinguishable from a crashed app.
    // Comments are stripped first, and deliberately: main.dart EXPLAINS why it
    // awaits nothing, and a scan that cannot tell a prohibition from its own
    // rationale forces the rationale out of the file.
    final String main = _withoutComments(source('app/lib/main.dart'));
    expect(main, isNot(contains(RegExp(r'(void|Future<void>)\s+main\(\)\s+async'))));
    expect(main, isNot(contains('await ')));
  });

  test('both databases open lazily', () {
    // `LazyDatabase` opens nothing until the first query, so the first frame
    // resolves no directory, touches no file and calls no platform channel.
    final String bootstrap = source('app/lib/data/bootstrap_data.dart');
    expect(bootstrap, contains('referenceExecutorAt'));
    expect(bootstrap, contains('guardedUserExecutorAt'));
  });

  test('the shell reaches its first frame without reading a database', () {
    // The Check branch decides between S9 and the search from a STREAM, so the
    // first frame is drawn on `loading` and the read happens behind it. A
    // FutureBuilder awaited before the tree would put the whole app behind the
    // slowest thing in it.
    final String check = source('app/lib/ui/check/check_screen.dart');
    expect(check, contains('evaluationScopeProvider'));
    expect(check, contains('loading:'));
  });

  test('nothing on the launch path is a splash, a login or a what is new', () {
    // §13 and §3: the app opens on Check. Every screen between the pocket and
    // the verdict spends the five seconds.
    final String app = source('app/lib/app.dart');
    for (final banned in const <String>['Splash', 'Onboarding', 'WhatsNew', 'Login']) {
      expect(app, isNot(contains(banned)), reason: banned);
    }
  });
}

/// [source] with its `//` comments removed.
String _withoutComments(String source) => source
    .split('\n')
    .map((String line) {
      final int at = line.indexOf('//');
      return at == -1 ? line : line.substring(0, at);
    })
    .join('\n');
