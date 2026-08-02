import 'dart:math';

import 'package:catchlaw/domain/models/content_string_missing.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes/fake_content_string_repository.dart';

ContentStringResolver _resolverOver(Map<String, Map<String, String>> rows) =>
    ContentStringResolver(FakeContentStringRepository(rows));

void main() {
  test('ContentStringResolver.resolve returns the requested-locale value when it exists', () async {
    final ContentStringResolver resolver = _resolverOver(<String, Map<String, String>>{
      'species.hamour.name': <String, String>{'gl': 'Mero', 'en': 'Orange-spotted grouper'},
    });

    expect(
      await resolver.resolve('species.hamour.name', requestedLocale: 'gl', defaultLocale: 'es'),
      'Mero',
    );
  });

  test('ContentStringResolver.resolve falls back to the jurisdiction default_locale when the '
      'requested locale has no row', () async {
    final ContentStringResolver resolver = _resolverOver(<String, Map<String, String>>{
      'species.hamour.name': <String, String>{'gl': 'Mero', 'en': 'Orange-spotted grouper'},
    });

    expect(
      await resolver.resolve('species.hamour.name', requestedLocale: 'ca', defaultLocale: 'gl'),
      'Mero',
    );
  });

  test('ContentStringResolver.resolve falls back to en when neither the requested locale nor '
      'default_locale has a row', () async {
    final ContentStringResolver resolver = _resolverOver(<String, Map<String, String>>{
      'species.hamour.name': <String, String>{'en': 'Orange-spotted grouper'},
    });

    expect(
      await resolver.resolve('species.hamour.name', requestedLocale: 'ca', defaultLocale: 'gl'),
      'Orange-spotted grouper',
    );
  });

  test(
    'ContentStringResolver.resolve returns the scientific name when no locale has a row',
    () async {
      final ContentStringResolver resolver = _resolverOver(const <String, Map<String, String>>{});

      expect(
        await resolver.resolve(
          'species.hamour.name',
          requestedLocale: 'ar',
          defaultLocale: 'ar',
          scientificName: 'Epinephelus coioides',
        ),
        'Epinephelus coioides',
      );
    },
  );

  test('ContentStringResolver.resolve throws ContentStringMissing when no locale has a row and no '
      'scientific name is supplied', () async {
    final ContentStringResolver resolver = _resolverOver(const <String, Map<String, String>>{});

    await expectLater(
      resolver.resolve('gear.trammel_net.name', requestedLocale: 'ar', defaultLocale: 'ar'),
      throwsA(
        isA<ContentStringMissing>().having(
          (ContentStringMissing e) => e.key,
          'key',
          'gear.trammel_net.name',
        ),
      ),
    );
  });

  test('ContentStringMissing names the key it could not resolve', () {
    // No network and no crash upload (CONVENTIONS.md §9.1), so the thrown
    // message is the only diagnostic anybody will ever get.
    const missing = ContentStringMissing('gear.trammel_net.name');
    expect(missing.toString(), contains('gear.trammel_net.name'));
  });

  test(
    'ContentStringResolver.resolve prefers the requested locale over default_locale when both exist',
    () async {
      // A Map iteration that happened to start at `en` would pass every row
      // above and fail this one.
      final ContentStringResolver resolver = _resolverOver(<String, Map<String, String>>{
        'species.hamour.name': <String, String>{'ar': 'هامور', 'en': 'Orange-spotted grouper'},
      });

      expect(
        await resolver.resolve('species.hamour.name', requestedLocale: 'ar', defaultLocale: 'en'),
        'هامور',
      );
    },
  );

  test('ContentStringResolver.resolve treats pt_BR as distinct from pt', () async {
    // D-3: the region travels because the content is Brazilian. A prefix match
    // here would ship Iberian wording to Brazil.
    final ContentStringResolver resolver = _resolverOver(<String, Map<String, String>>{
      'gear.rede.name': <String, String>{'pt': 'Rede de emalhar', 'en': 'Gillnet'},
    });

    expect(
      await resolver.resolve('gear.rede.name', requestedLocale: 'pt_BR', defaultLocale: 'pt_BR'),
      'Gillnet',
    );
  });

  test('ContentStringResolver.resolve queries the repository once per key', () async {
    final repo = FakeContentStringRepository(<String, Map<String, String>>{
      'gear.rede.name': <String, String>{'en': 'Gillnet'},
    });

    await ContentStringResolver(
      repo,
    ).resolve('gear.rede.name', requestedLocale: 'ar', defaultLocale: 'es');

    expect(repo.callCount, 1, reason: 'S5 renders 40 rows; a query per chain step is 160 of them');
  });

  // A universal claim, so a seeded fuzz rather than an example
  // (`testing-strategy` rule 3). The generated input is its own repro.
  test('ContentStringResolver.resolve never returns the key itself', () async {
    final rng = Random(0xCA7C41);
    const locales = <String>['ar', 'en', 'es', 'gl', 'ca', 'pt_BR'];
    for (var seed = 0; seed < 200; seed++) {
      final key = 'k$seed.${rng.nextInt(1 << 20)}';
      final present = <String, String>{
        for (final l in locales)
          if (rng.nextBool()) l: '$l value $seed',
      };
      final ContentStringResolver resolver = _resolverOver(<String, Map<String, String>>{
        key: present,
      });
      final String requested = locales[rng.nextInt(locales.length)];
      final String fallback = locales[rng.nextInt(locales.length)];
      try {
        final String value = await resolver.resolve(
          key,
          requestedLocale: requested,
          defaultLocale: fallback,
          scientificName: 'Epinephelus coioides',
        );
        expect(
          value,
          isNot(key),
          reason: 'seed=$seed present=${present.keys} requested=$requested default=$fallback',
        );
        expect(value, isNotEmpty, reason: 'seed=$seed — §9.2 forbids the empty string too');
      } on ContentStringMissing {
        fail('seed=$seed threw with a scientific name available');
      }
    }
  });

  test(
    'ContentStringResolver.resolve returns the gl value for a gl request on a jurisdiction whose '
    'default_locale is es',
    () async {
      // The §9.1 headline: a Galician mariscadora is not handed the Spanish
      // translation of a Galician instrument.
      final ContentStringResolver resolver = _resolverOver(<String, Map<String, String>>{
        'zone.rias_baixas.name': <String, String>{
          'gl': 'Rías Baixas',
          'es': 'Rías Bajas',
          'en': 'Rias Baixas',
        },
      });

      expect(
        await resolver.resolve('zone.rias_baixas.name', requestedLocale: 'gl', defaultLocale: 'es'),
        'Rías Baixas',
      );
    },
  );

  test(
    'ContentStringResolver.resolve rethrows a storage failure rather than reporting it missing',
    () async {
      // Absent and broken are two different states, and this project does not
      // merge two states into one word. A store that could not be read has not
      // told us the key is missing.
      final repo = FakeContentStringRepository(
        const <String, Map<String, String>>{},
        failure: const FormatException('reference.db is unreadable'),
      );

      await expectLater(
        ContentStringResolver(
          repo,
        ).resolve('species.hamour.name', requestedLocale: 'ar', defaultLocale: 'ar'),
        throwsA(isA<FormatException>()),
      );
    },
  );
}
