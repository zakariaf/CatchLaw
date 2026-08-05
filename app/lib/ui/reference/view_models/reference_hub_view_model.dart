import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/jurisdiction.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:catchlaw/l10n/locale_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// One bundled jurisdiction's content, named and dated.
///
/// **A pack, not a source.** The vocabulary allows exactly one word for a
/// bundled jurisdiction's versioned content, and "source" is the word this
/// project does not use for anything: nothing here is fetched and nothing is a
/// link. What the hub prints for each pack is what a fisher comparing two
/// devices at the quay actually reads — who published it, which printing this
/// device holds, and the day a human last read the published text.
@immutable
class HeldPack {
  /// One bundled jurisdiction.
  const HeldPack({
    required this.code,
    required this.name,
    required this.packVersion,
    required this.checkedOn,
    this.authority,
  });

  /// `ES-GA`, `AE-RK` — printed as authored, because it is the string on the
  /// printed pack and the same in all six locales.
  final String code;

  /// The jurisdiction's name in the reader's language, or its code when the
  /// pack carries no name for it.
  final String name;

  /// The body that published the instruments, or absent when the pack carries
  /// no name for it — an authority nobody can check is a line worth omitting.
  final String? authority;

  /// Which printing of the rules this device holds.
  final String packVersion;

  /// When a human last verified this jurisdiction's transcription, ISO-8601.
  final String checkedOn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeldPack &&
          other.code == code &&
          other.name == name &&
          other.authority == authority &&
          other.packVersion == packVersion &&
          other.checkedOn == checkedOn;

  @override
  int get hashCode => Object.hash(code, name, authority, packVersion, checkedOn);
}

/// Every pack this copy holds, in the order the rule book lists them.
///
/// **A failed read is an error and never an empty list.** A hub printing no
/// packs because a file was locked would state that this copy holds no
/// jurisdiction, which is a claim about the product rather than about the disk
/// — the same distinction S9's picker is built on.
///
/// The names are resolved through `SPEC.md` §9.2's chain rather than read off
/// the row, because `jurisdiction.name_key` is a key and not a name: a Galician
/// reader gets *Galicia* in Galician, and a locale the pack has no row for
/// falls back to the language the authority publishes in before it falls back
/// to English.
final FutureProvider<List<HeldPack>> heldPacksProvider = FutureProvider<List<HeldPack>>((
  Ref ref,
) async {
  final Result<List<Jurisdiction>> read = await ref
      .watch(referenceRepositoryProvider)
      .jurisdictions();
  final List<Jurisdiction> all = switch (read) {
    Ok<List<Jurisdiction>>(:final List<Jurisdiction> value) => value,
    Failure<List<Jurisdiction>>(:final Exception exception) => throw exception,
  };

  final resolver = ContentStringResolver(ref.watch(contentStringRepositoryProvider));
  final String requested = ref.watch(localeNotifierProvider).value?.languageCode ?? 'en';

  Future<String?> resolve(String key, String defaultLocale) async {
    try {
      return await resolver.resolve(key, requestedLocale: requested, defaultLocale: defaultLocale);
    } on Exception {
      // A key the pack carries no row for is dropped rather than printed as
      // itself: `jurisdiction.es_ga.authority` on the screen is a defect
      // wearing the clothes of a fact.
      return null;
    }
  }

  return <HeldPack>[
    for (final Jurisdiction j in all)
      HeldPack(
        code: j.code,
        // The code is the fallback because it is what the printed pack carries:
        // a block with no heading at all would leave the dates attached to
        // nothing.
        name: await resolve(j.nameKey, j.defaultLocale) ?? j.code,
        authority: await resolve(j.authorityKey, j.defaultLocale),
        packVersion: j.contentVersion,
        checkedOn: j.checkedOn,
      ),
  ];
});
