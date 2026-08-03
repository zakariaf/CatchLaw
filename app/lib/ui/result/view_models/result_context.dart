import 'package:meta/meta.dart';

/// What the result screen knows about the place, rather than about the fish.
///
/// It exists so the presenter needs no clock, no repository and no
/// `BuildContext`: every fact that varies by jurisdiction rather than by
/// resolution arrives here, and the same resolution rendered for two
/// jurisdictions differs only in what this carries.
@immutable
class ResultContext {
  /// Describes the active jurisdiction.
  const ResultContext({required this.authorityKey, this.defaultLocale = 'en'});

  /// The `content_string` key for the authority named in the disclaimer.
  ///
  /// A key rather than the name itself, so the disclaimer is per-jurisdiction
  /// in all six locales through one tier-two lookup. A generic authority is a
  /// shrug, and a shrug at the top of a legal quotation is what makes the
  /// quotation unbelievable.
  final String authorityKey;

  /// The language this jurisdiction publishes in — `SPEC.md` §9.2 step 2.
  ///
  /// Step two of the fallback chain rather than a preference: a Galician rule
  /// written in Galician is closer to the source than an English gloss of it,
  /// so a word missing from the reader's own locale falls to the publication
  /// language before it falls to `en`.
  final String defaultLocale;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultContext &&
          other.authorityKey == authorityKey &&
          other.defaultLocale == defaultLocale;

  @override
  int get hashCode => Object.hash(authorityKey, defaultLocale);
}

/// One result screen worth of question: which place, and in which language.
///
/// A value type rather than a record, because it is a Riverpod family key and
/// a family key with no `==` re-creates its provider on every rebuild — which
/// for this family means re-reading `reference.db` on every frame.
@immutable
class ResultRequest {
  /// Asks for [context] in [locale].
  const ResultRequest({required this.locale, required this.context});

  /// The locale the screen resolved to, as a tag: `ar`, `gl`, `pt_BR`.
  final String locale;

  /// The jurisdiction the answer is about.
  final ResultContext context;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultRequest && other.locale == locale && other.context == context;

  @override
  int get hashCode => Object.hash(locale, context);
}
