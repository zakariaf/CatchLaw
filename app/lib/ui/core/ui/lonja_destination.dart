import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icons.dart';

/// The five places the bottom strip goes, and there is no sixth.
///
/// `SPEC.md` §6 enumerates them, and the enum is the enumeration: a destination
/// added here fails to compile in the label switch and in the glyph switch
/// until somebody decides what it is called and what it looks like, rather than
/// appearing as an unlabelled cell.
enum LonjaDestination {
  /// S1 — the question the whole product exists to answer.
  check,

  /// S8 — what has been taken today.
  today,

  /// S10 — the trips it was taken on.
  trips,

  /// S12 — the bundled reference.
  reference,

  /// S14 — the settings.
  settings;

  /// The branches this release puts in the strip.
  ///
  /// **`today` is built and deliberately not shown.** S8 works — it tallies,
  /// counts kept and removes one — and it is held back to v2 rather than
  /// deleted, so restoring it is this list and nothing else. The enum keeps its
  /// member, its label, its glyph and its route, which means none of that can
  /// rot while it is out of sight.
  ///
  /// Iterated by the strip and by the shell's `IndexedStack` TOGETHER, because
  /// the strip's index is the stack's index: hiding a cell from one and not the
  /// other selects the wrong branch, silently.
  static const List<LonjaDestination> shipped = <LonjaDestination>[
    check,
    trips,
    reference,
    settings,
  ];

  /// The label, already localised.
  ///
  /// Exhaustive, with no `default:`: the same word §6 uses for that screen, and
  /// a sixth destination is a compile error rather than a blank cell.
  String label(AppLocalizations l10n) => switch (this) {
    LonjaDestination.check => l10n.navCheck,
    LonjaDestination.today => l10n.navToday,
    LonjaDestination.trips => l10n.navTrips,
    LonjaDestination.reference => l10n.navReference,
    LonjaDestination.settings => l10n.navSettings,
  };

  /// The mark beside it.
  ///
  /// A glyph AND a word on every cell. §4.9 and invariant 4: a strip whose
  /// destinations differ only by icon is unreadable to a reader who does not
  /// know the icons yet, which is every reader on the first launch.
  LonjaGlyph get glyph => switch (this) {
    LonjaDestination.check => LonjaIcons.fish,
    LonjaDestination.today => LonjaIcons.tally,
    LonjaDestination.trips => LonjaIcons.boat,
    LonjaDestination.reference => LonjaIcons.book,
    LonjaDestination.settings => LonjaIcons.adjust,
  };

  /// The route this branch is named by.
  ///
  /// A plain string, so the v2 task that adopts a router has names to bind
  /// rather than paths to invent (D-23).
  String get path => switch (this) {
    LonjaDestination.check => '/check',
    LonjaDestination.today => '/today',
    LonjaDestination.trips => '/trips',
    LonjaDestination.reference => '/reference',
    LonjaDestination.settings => '/settings',
  };
}
