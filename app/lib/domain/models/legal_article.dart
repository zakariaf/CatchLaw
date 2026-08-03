import 'package:meta/meta.dart';

/// One article of an instrument, verbatim, in the language it was published in.
///
/// **Single-locale by construction** (`SPEC.md` §9.6). There is no `translate`
/// here and no fallback chain: an unofficial translation of a penal instrument
/// is a liability, and the §9.2 chain applies to `content_string` alone. What
/// the app does when the reader's locale is not [locale] is render a
/// language-availability notice, which E15 owns.
@immutable
class LegalArticle {
  /// Records [body] as published.
  const LegalArticle({
    required this.locale,
    required this.body,
    required this.sortOrder,
    this.articleRef,
  });

  /// The language the authority published in — `ar` for the UAE, `gl` for
  /// Galicia.
  final String locale;

  /// The text itself, exactly as transcribed. Never summarised here.
  final String body;

  /// Reading order within the instrument.
  final int sortOrder;

  /// The article number, where the instrument gives one.
  final String? articleRef;
}
