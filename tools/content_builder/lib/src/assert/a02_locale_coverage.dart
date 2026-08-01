import 'package:content_builder/src/assert/assertion.dart';
import 'package:content_builder/src/cli/failure.dart';
import 'package:content_builder/src/load/content_source.dart';
import 'package:content_builder/src/locales.dart';
import 'package:content_builder/src/model/key_reference.dart';
import 'package:content_builder/src/model/text.dart';

/// A2 — every `*_key` resolves in every shipped locale.
///
/// There is **no build-time fallback**, and that does not contradict the runtime
/// chain in `SPEC.md` §9.2. The chain — requested locale, jurisdiction
/// `default_locale`, `en`, scientific name — exists for locale *selection*, not
/// for gaps in the corpus. If the build let `en` stand in for `ca`, a Catalan
/// speaker would be served Spanish law in English and nobody would ever see a
/// defect. §9.2 says so itself: *a missing Tier-2 string never renders a raw key
/// or an empty string, because the build fails first.*
///
/// The second half of A2 is the `legal_text.` ban. §9.6 and
/// `licence-provenance.md` agree: verbatim law is bundled in the language the
/// authority published it in, and an unofficial translation of a penal
/// instrument is a liability that also falls outside Spain's Art. 13 LPI
/// carve-out, which covers *official* translations only.
final class LocaleCoverageAssertion implements Assertion {
  /// The A2 assertion. Stateless: the corpus is the argument.
  const LocaleCoverageAssertion();

  @override
  String get id => 'A2';

  @override
  Iterable<Failure> run(ContentSource source) sync* {
    final defined = <String, ContentStringRow>{};

    for (final ContentStringRow block in source.contentStrings) {
      final ContentStringRow? first = defined[block.key];
      if (first != null) {
        // Two definitions means the winner depends on directory walk order,
        // which is not a translation decision anybody made.
        yield Failure(
          _id,
          block.path,
          block.line,
          "key '${block.key}' is defined twice; also at ${first.path}:${first.line}",
        );
        continue;
      }
      defined[block.key] = block;

      if (block.key.startsWith(kLegalTextPrefix)) {
        yield Failure(
          _id,
          block.path,
          block.line,
          "key '${block.key}' is legal_text; verbatim law is bundled single-locale, never translated",
        );
      }

      yield* _values(block);
    }

    for (final KeyReference reference in source.keyReferences) {
      final ContentStringRow? block = defined[reference.key];
      if (block == null) {
        // At the REFERENCING row, not at strings.yaml: the author fixes the
        // reference or adds the key, and needs to see which row asked.
        yield Failure(
          _id,
          reference.path,
          reference.line,
          "${reference.column} '${reference.key}' resolves to no content_string",
        );
        continue;
      }

      final missing = <String>[
        for (final String locale in kShippedLocales)
          if (!block.values.containsKey(locale)) locale,
      ];
      if (missing.isNotEmpty) {
        // One failure listing every missing locale. Five failures for one key
        // buries the twenty other keys.
        yield Failure(
          _id,
          reference.path,
          reference.line,
          "key '${reference.key}' missing for ${missing.join(', ')}",
        );
      }
    }
  }

  /// The value checks: a placeholder is a missing string wearing a disguise.
  Iterable<Failure> _values(ContentStringRow block) sync* {
    for (final MapEntry<String, String> value in block.values.entries) {
      if (!kShippedLocales.contains(value.key)) {
        // D-3 removed Urdu. A leftover `ur` block would sit in the corpus
        // looking translated and be served to nobody.
        yield Failure(
          _id,
          block.path,
          block.line,
          "key '${block.key}' carries locale '${value.key}', which is not shipped",
        );
        continue;
      }
      if (value.value.trim().isEmpty) {
        // An empty value resolves, renders, and puts a blank line under the
        // verdict stamp. Blank is not a verdict.
        yield Failure(_id, block.path, block.line, "key '${block.key}' is empty for ${value.key}");
      } else if (value.value == block.key) {
        // The placeholder that looks like a translation: `ca: gear.trawl`
        // resolves, renders, and reads as a Catalan gear name to a build.
        yield Failure(
          _id,
          block.path,
          block.line,
          "key '${block.key}' is its own key for ${value.key}",
        );
      }
    }
  }

  static const String _id = 'A2';
}

/// The prefix no `content_string` key may carry.
const String kLegalTextPrefix = 'legal_text.';

/// The defined keys nothing references, sorted.
///
/// Counted and printed with the build summary; **never** a failure. Shared
/// glossary and family strings are authored ahead of the rows that use them, and
/// failing here would force E22 to author a rule and its strings in one commit —
/// the opposite of the parallel authoring `SPEC.md` §15 step 19 asks for.
List<String> unreferencedKeys(ContentSource source) {
  final referenced = <String>{for (final KeyReference r in source.keyReferences) r.key};
  return <String>[
    for (final ContentStringRow block in source.contentStrings)
      if (!referenced.contains(block.key)) block.key,
  ]..sort();
}
