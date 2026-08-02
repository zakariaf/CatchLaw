import 'package:meta/meta.dart';

/// Which language a verbatim instrument exists in, and whether the reader has
/// to be told.
///
/// **The `SPEC.md` §9.2 fallback chain stops at this door.** That chain has
/// four steps and ends in a scientific name; §9.6 says it applies to
/// `content_string` **only** and never substitutes a different language of law.
/// Those two sentences live three files apart, and the way they get reconciled
/// wrongly is obvious: somebody writes one "resolve any localised string"
/// helper, points it at `legal_text`, and a Galician fisher is quietly shown
/// the Spanish version of a Galician order.
///
/// The reason is not tidiness. §9.6: an unofficial translation of a penal
/// instrument is a liability, and in Spain it falls outside the Art. 13 LPI
/// carve-out, which covers *official* translations only. §8 attaches each
/// jurisdiction's licence basis to the text as published. A translated law is a
/// different work with a different licence position and a different legal
/// status, and this app's whole posture (§5.1) is that it quotes law rather
/// than interpreting it.
@immutable
final class LegalTextAvailability {
  /// Records that the text exists in [textLocale], and whether that needs
  /// saying.
  const LegalTextAvailability({required this.textLocale, required this.hasNotice});

  /// The language tag the instrument was published in — `ar`, `gl`, `pt_BR`.
  ///
  /// A **tag**, not a `Locale`. `Locale` lives in `dart:ui`, and nothing under
  /// `app/lib/domain/` may import Flutter — `check_rule_engine.sh` enforces it
  /// and this type is not the place to make an exception. The column stores a
  /// tag anyway (`SPEC.md` §7.1), so the conversion belongs where the widget
  /// is, through `l10n/locale_codec.dart`.
  final String textLocale;

  /// Whether the reader's locale is absent from `legal_text_locales`.
  ///
  /// `true` does **not** mean the text is withheld. A fisher who cannot read
  /// Arabic can still show the article to an inspector who can, and §14's
  /// dynamic checklist requires the citation to expand into S13 and copy to the
  /// clipboard. Hiding it would repeat the invariant-5 mistake — stale or
  /// foreign beats absent.
  final bool hasNotice;

  /// Which published language to show, given what the jurisdiction has.
  ///
  /// [legalTextLocales] is `jurisdiction.legal_text_locales` — a CSV such as
  /// `'ar'` or `'gl,es'` (`SPEC.md` §7.1).
  ///
  /// Two branches, and there is no third:
  ///
  /// * [requested] is in the list → that language, no notice.
  /// * otherwise → [defaultLocale] if it is in the list, else the **first CSV
  ///   entry**, with a notice.
  ///
  /// §9.6 states when a notice appears but not which text to show when the CSV
  /// holds two, and `'gl,es'` is a real Galicia value. This is that tie-break.
  /// It is deterministic, it is content-authored rather than alphabetical, and
  /// the lever for changing it is the CSV order in the authored YAML — no code
  /// change. Alphabetical order was rejected because it makes `es` beat `gl` in
  /// Galicia, which inverts §9.1's reason for shipping Galician at all.
  ///
  /// There is deliberately **no `en` branch**. English is a language no bundled
  /// instrument is published in (§9.2 point 2), so there is no English legal
  /// text to fall back to.
  ///
  /// Throws an [ArgumentError] on an empty list. The column is `NOT NULL`
  /// (§7.1) and E04's build asserts the content is complete (§8), so an empty
  /// value means a database this project did not build — and the graceful path
  /// would be exactly the silent substitution §9.6 forbids.
  static LegalTextAvailability resolve({
    required String legalTextLocales,
    required String defaultLocale,
    required String requested,
  }) {
    final List<String> published = legalTextLocales
        .split(',')
        .map((String s) => s.trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    if (published.isEmpty) {
      throw ArgumentError.value(
        legalTextLocales,
        'legalTextLocales',
        'no published language recorded — SPEC.md §7.1 declares this NOT NULL',
      );
    }

    if (published.contains(requested)) {
      return LegalTextAvailability(textLocale: requested, hasNotice: false);
    }
    final String chosen = published.contains(defaultLocale) ? defaultLocale : published.first;
    return LegalTextAvailability(textLocale: chosen, hasNotice: true);
  }
}
