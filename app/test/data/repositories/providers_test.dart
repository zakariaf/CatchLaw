// Providers are dependency injection and nothing else.

import 'dart:io';

import 'package:catchlaw/data/bootstrap_data.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/data/services/app_directories.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every data provider throws until it is overridden', () {
    // A forgotten wiring must fail loudly at first read. The alternative — a
    // provider that constructs a live database on demand — makes every widget
    // test open SQLite and hides the missing override until production.
    final container = ProviderContainer();
    addTearDown(container.dispose);

    for (final ProviderBase<Object?> provider in kDataSeams) {
      // Riverpod 3 wraps a provider's own throw in a ProviderException. The
      // assertion reaches through it: what matters is that the placeholder
      // threw, not the envelope Riverpod put it in.
      expect(
        () => container.read(provider),
        throwsA(
          isA<ProviderException>().having(
            (ProviderException e) => e.exception,
            'exception',
            isA<UnimplementedError>(),
          ),
        ),
        reason: '$provider',
      );
    }
  });

  test('dataOverrides covers every data seam', () {
    // The list and the overrides are two descriptions of one wiring, and a seam
    // added to only one of them is a throw on a screen five epics from here.
    final Set<Override> overridden = dataOverrides(
      directories: _NeverCalledDirectories(),
    ).map((Override o) => o.origin).toSet();

    expect(overridden, containsAll(kDataSeams));
  });

  test('dataOverrides constructs every database without opening a file', () {
    // Rule 8 in executable form. LazyDatabase defers the open to the first
    // query, so this returns having touched no filesystem at all — and an
    // AppDirectories that throws on call is how that is proved rather than
    // asserted.
    final Directory temp = Directory.systemTemp.createTempSync('catchlaw_bootstrap_');
    addTearDown(() => temp.deleteSync(recursive: true));

    expect(() => dataOverrides(directories: _NeverCalledDirectories()), returnsNormally);
    expect(temp.listSync(), isEmpty);
  });
}

/// An [AppDirectories] whose methods are a test failure if they are reached.
///
/// `dataOverrides` is synchronous, so it cannot have awaited either of these —
/// and if a later change makes it await one, this fails rather than quietly
/// adding a platform channel to the path before the first frame.
final class _NeverCalledDirectories implements AppDirectories {
  @override
  Future<Directory> reference() async => fail('dataOverrides resolved a directory eagerly');

  @override
  Future<Directory> user() async => fail('dataOverrides resolved a directory eagerly');
}
