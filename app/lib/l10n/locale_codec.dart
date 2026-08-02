/// The one place a locale becomes a `user_profile.locale_override` value, and
/// back.
///
/// `Locale('pt_BR')` constructs a *language code* containing an underscore. It
/// matches nothing, and it looks right — so the conversion lives in one file
/// with its own rows rather than being open-coded at each call site.
library;

import 'package:flutter/widgets.dart' show Locale;

/// [locale] as the tag stored in `user_profile.locale_override`, or `null`.
///
/// `null` in, `null` out: `SPEC.md` §7.2 declares the column nullable with no
/// default, and SQL `NULL` already means "unset". A sentinel like `'auto'`
/// would put a fourth, non-locale value into a column whose other values are
/// locale tags, and every reader would have to know it.
String? encodeLocale(Locale? locale) {
  if (locale == null) return null;
  final String? country = locale.countryCode;
  return country == null || country.isEmpty
      ? locale.languageCode
      : '${locale.languageCode}_$country';
}

/// [tag] as a `Locale`, or `null` for the follow-the-device state.
///
/// An empty string decodes to `null` too: an export round trip can turn a SQL
/// `NULL` into `''`, and a `Locale('')` matches nothing while looking like a
/// pinned language.
Locale? decodeLocale(String? tag) {
  if (tag == null || tag.isEmpty) return null;
  final List<String> parts = tag.split('_');
  return parts.length == 1 ? Locale(parts.first) : Locale(parts.first, parts[1]);
}
