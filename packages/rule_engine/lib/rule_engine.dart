/// Rule resolution for CatchLaw: the pure-Dart core shared by the app and the
/// content builder.
///
/// This library takes plain values — a species, a jurisdiction, a landing date,
/// a measurement — and returns sealed result types carrying numbers, enums and
/// a required citation. It contains no user-visible sentence, in any language:
/// wording belongs to `app/lib/ui/` and to the bundled content (D-7).
///
/// The package declares no `flutter` dependency, so importing
/// `flutter/material.dart` here is `Target of URI doesn't exist` — a compile
/// error rather than a lint, a grep or a code review (`FLUTTER_GUIDE.md` §4.6
/// layer 1).
///
/// It has two consumers and they must agree byte for byte: the app, and
/// `tools/content_builder/`, which imports this package rather than
/// reimplementing it (`SPEC.md` §8). The ORDER of the normalisation steps is
/// part of that shared contract, not an implementation detail — a different
/// order in the two places produces a database whose keys the app cannot
/// reproduce, and a search that silently returns nothing.
///
/// This is the one barrel in the repository (`FLUTTER_GUIDE.md` Part 2.6).
library;

export 'src/date.dart';
export 'src/engine_exception.dart';
export 'src/failure.dart';
export 'src/findings/finding.dart';
export 'src/findings/precedence.dart';
export 'src/models/catch_tally.dart';
export 'src/models/citation.dart';
export 'src/models/closed_season.dart';
export 'src/models/landing.dart';
export 'src/models/measurement_method.dart';
export 'src/models/rule.dart';
export 'src/models/species.dart';
export 'src/models/zone.dart';
export 'src/resolve/candidate.dart';
export 'src/resolve/candidate_selection.dart';
export 'src/resolve/conflict.dart';
export 'src/resolve/evaluation_request.dart';
export 'src/resolve/zone_match.dart';
export 'src/search/normalise.dart';
export 'src/season/season_window.dart';
