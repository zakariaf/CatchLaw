import 'package:catchlaw/l10n/locale_codec.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in const <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('gl'),
    Locale('ca'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ]) {
    final String tag = encodeLocale(locale)!;
    test('encodeLocale round-trips $tag', () {
      expect(decodeLocale(tag), locale);
    });
  }

  test('encodeLocale returns null for the follow-the-device state', () {
    // SQL NULL already means "unset", in SQL and in Dart. A sentinel string
    // would put a fourth, non-locale value into a column whose other values are
    // locale tags, and every reader would need to know the secret.
    expect(encodeLocale(null), isNull);
  });

  test('decodeLocale returns null for null and for the empty string', () {
    expect(decodeLocale(null), isNull);
    expect(decodeLocale(''), isNull);
  });

  test('decodeLocale reads pt_BR as language pt with country BR', () {
    // `Locale('pt_BR')` is a language code containing an underscore. It matches
    // nothing, and it looks right.
    final Locale? decoded = decodeLocale('pt_BR');
    expect(decoded?.languageCode, 'pt');
    expect(decoded?.countryCode, 'BR');
  });
}
