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
/// This is the one barrel in the repository (`FLUTTER_GUIDE.md` Part 2.6).
library;

export 'src/search/normalise.dart';
