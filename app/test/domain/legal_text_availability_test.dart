import 'dart:io';

import 'package:catchlaw/domain/models/legal_text_availability.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes/fake_content_string_repository.dart';

LegalTextAvailability _resolve(
  String csv, {
  required String defaultLocale,
  required String requested,
}) => LegalTextAvailability.resolve(
  legalTextLocales: csv,
  defaultLocale: defaultLocale,
  requested: requested,
);

void main() {
  test(
    'LegalTextAvailability.resolve returns ar with no notice when the requested locale is ar',
    () {
      final LegalTextAvailability r = _resolve('ar', defaultLocale: 'ar', requested: 'ar');
      expect(r.textLocale, 'ar');
      expect(r.hasNotice, isFalse);
    },
  );

  test(
    'LegalTextAvailability.resolve returns ar with a notice when the requested locale is en',
    () {
      // The expat angler in Ras Al Khaimah (SPEC.md §9.1's `en` row). The text is
      // still SHOWN — withholding it would repeat the invariant-5 mistake in a
      // new place, and he can hand the article to an inspector who reads it.
      final LegalTextAvailability r = _resolve('ar', defaultLocale: 'ar', requested: 'en');
      expect(r.textLocale, 'ar');
      expect(r.hasNotice, isTrue);
    },
  );

  test(
    'LegalTextAvailability.resolve returns gl with no notice when the requested locale is gl',
    () {
      final LegalTextAvailability r = _resolve('gl,es', defaultLocale: 'gl', requested: 'gl');
      expect(r.textLocale, 'gl');
      expect(r.hasNotice, isFalse);
    },
  );

  test(
    'LegalTextAvailability.resolve returns es with no notice when the requested locale is es',
    () {
      // Both are official publication languages here, so neither is a
      // substitution and neither earns a notice.
      final LegalTextAvailability r = _resolve('gl,es', defaultLocale: 'gl', requested: 'es');
      expect(r.textLocale, 'es');
      expect(r.hasNotice, isFalse);
    },
  );

  test(
    'LegalTextAvailability.resolve returns the default_locale when the requested locale is absent '
    'and default_locale is in the list',
    () {
      // SPEC.md §9.6 gives no tie-break for a two-entry CSV. This is it.
      // Alphabetical order would pick `es` in Galicia and invert §9.1's whole
      // argument for shipping Galician.
      final LegalTextAvailability r = _resolve('gl,es', defaultLocale: 'gl', requested: 'ar');
      expect(r.textLocale, 'gl');
      expect(r.hasNotice, isTrue);
    },
  );

  test(
    'LegalTextAvailability.resolve returns the first CSV entry when default_locale is not in the list',
    () {
      // The lever for changing this is the authored CSV order, not code.
      final LegalTextAvailability r = _resolve('gl,es', defaultLocale: 'en', requested: 'ca');
      expect(r.textLocale, 'gl');
      expect(r.hasNotice, isTrue);
    },
  );

  test('LegalTextAvailability.resolve never returns en unless en is in legal_text_locales', () {
    // §9.6's headline, asserted as a universal rather than an example. English
    // is a language no bundled instrument is published in (§9.2 point 2), so
    // there is no English legal text to fall back to.
    const csvs = <String>['ar', 'gl,es', 'ca', 'pt_BR', 'es'];
    const requested = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR'];
    for (final csv in csvs) {
      for (final locale in requested) {
        final LegalTextAvailability r = _resolve(
          csv,
          defaultLocale: csv.split(',').first,
          requested: locale,
        );
        expect(r.textLocale, isNot('en'), reason: 'csv=$csv requested=$locale');
      }
    }
  });

  test('LegalTextAvailability.resolve tolerates whitespace in the CSV', () {
    // The column is hand-authored YAML upstream (§8). A space is not a content
    // error and must not become an unknown locale.
    expect(_resolve('gl, es', defaultLocale: 'gl', requested: 'gl').textLocale, 'gl');
  });

  test('LegalTextAvailability.resolve throws when legal_text_locales is empty', () {
    // NOT NULL in §7.1 and asserted by the §8 build, so an empty value means a
    // database this project did not build. The graceful path would be exactly
    // the silent substitution §9.6 forbids.
    expect(() => _resolve('', defaultLocale: 'gl', requested: 'gl'), throwsArgumentError);
    expect(() => _resolve('  ,  ', defaultLocale: 'gl', requested: 'gl'), throwsArgumentError);
  });

  test('LegalTextAvailability.resolve reads pt_BR as a whole tag rather than as pt', () {
    // The region travels (D-3). A CSV entry of `pt_BR` is not satisfied by a
    // reader whose locale is a bare `pt`.
    final LegalTextAvailability whole = LegalTextAvailability.resolve(
      legalTextLocales: 'pt_BR',
      defaultLocale: 'pt_BR',
      requested: 'pt_BR',
    );
    expect(whole.textLocale, 'pt_BR');
    expect(whole.hasNotice, isFalse);

    final LegalTextAvailability bare = LegalTextAvailability.resolve(
      legalTextLocales: 'pt_BR',
      defaultLocale: 'pt_BR',
      requested: 'pt',
    );
    expect(bare.textLocale, 'pt_BR');
    expect(bare.hasNotice, isTrue, reason: 'a bare pt reader is not a pt_BR publication');
  });

  test('ContentStringResolver is not consulted when a legal text is resolved', () {
    // The boundary between §9.2 and §9.6, asserted rather than assumed. The
    // way these get reconciled wrongly is obvious: someone writes one "resolve
    // any localised string" helper, points it at legal_text, and a Galician
    // fisher is shown the Spanish version of a Galician order.
    final spy = FakeContentStringRepository(const <String, Map<String, String>>{});
    _resolve('gl,es', defaultLocale: 'gl', requested: 'ar');
    expect(spy.callCount, 0);
  });

  test('legal_text_availability.dart names no content-string resolver', () {
    // The stronger half of the row above: `resolve` takes no repository, so a
    // call counter can only ever read zero. What actually keeps the boundary is
    // that this file cannot reach the chain at all.
    final String source = File('lib/domain/models/legal_text_availability.dart').readAsStringSync();
    expect(source, isNot(contains('ContentStringResolver')));
    expect(source, isNot(contains('ContentStringRepository')));
  });
}
