import 'package:catchlaw/l10n/gen/app_localizations.dart';

/// The eight entries of the reference contents, in the order they are set.
///
/// **An enum and not a list of records**, for the reason the destination enum
/// is one: a ninth entry fails to compile in the title switch and in the note
/// switch until somebody has decided what it is called and what it holds,
/// rather than appearing as an untitled line with a numeral in front of it.
///
/// Seven of the eight are `SPEC.md` §6's own sections and this release prints
/// none of them; the eighth is S6, which has been complete since E08. That
/// asymmetry is the point of the screen: the book states which of its sections
/// are set in this copy instead of offering eight identical lines, seven of
/// which lead nowhere.
enum ReferenceEntry {
  /// I — the instruments, verbatim (E15).
  ruleText,

  /// II — the protected list, with plates (E15).
  protectedSpecies,

  /// III — gear and methods (E15).
  gear,

  /// IV — S20's penalties (E15).
  penalties,

  /// V — licences (E15).
  licences,

  /// VI — the glossary of methods and local terms (E15).
  glossary,

  /// VII — what each pack changed (E15).
  changelog,

  /// VIII — S6, the silhouette plates, and the one entry this release prints.
  plates;

  /// The entry's title, already localised.
  String title(AppLocalizations l10n) => switch (this) {
    ReferenceEntry.ruleText => l10n.referenceEntryRuleText,
    ReferenceEntry.protectedSpecies => l10n.referenceEntryProtected,
    ReferenceEntry.gear => l10n.referenceEntryGear,
    ReferenceEntry.penalties => l10n.referenceEntryPenalties,
    ReferenceEntry.licences => l10n.referenceEntryLicences,
    ReferenceEntry.glossary => l10n.referenceEntryGlossary,
    ReferenceEntry.changelog => l10n.referenceEntryChangelog,
    ReferenceEntry.plates => l10n.referenceEntryPlates,
  };

  /// What that section holds, already localised.
  String note(AppLocalizations l10n) => switch (this) {
    ReferenceEntry.ruleText => l10n.referenceEntryRuleTextNote,
    ReferenceEntry.protectedSpecies => l10n.referenceEntryProtectedNote,
    ReferenceEntry.gear => l10n.referenceEntryGearNote,
    ReferenceEntry.penalties => l10n.referenceEntryPenaltiesNote,
    ReferenceEntry.licences => l10n.referenceEntryLicencesNote,
    ReferenceEntry.glossary => l10n.referenceEntryGlossaryNote,
    ReferenceEntry.changelog => l10n.referenceEntryChangelogNote,
    ReferenceEntry.plates => l10n.referenceEntryPlatesNote,
  };

  /// Whether this release sets the section behind the entry.
  ///
  /// The line is drawn once, here, so the contents list, the count slot and the
  /// tap all read the same fact — three places that disagreed would be an entry
  /// that says it is printed and opens a page saying it is not.
  bool get isPrinted => this == ReferenceEntry.plates;

  /// The numeral in the margin gutter.
  ///
  /// **Authored, and the same characters in every locale**, like the zone code
  /// and the pack version beside it: a contents numeral is an ordinal mark on a
  /// printed page rather than a sentence, and a reader comparing this list
  /// against the printed booklet is comparing marks.
  String get numeral => switch (this) {
    ReferenceEntry.ruleText => 'I',
    ReferenceEntry.protectedSpecies => 'II',
    ReferenceEntry.gear => 'III',
    ReferenceEntry.penalties => 'IV',
    ReferenceEntry.licences => 'V',
    ReferenceEntry.glossary => 'VI',
    ReferenceEntry.changelog => 'VII',
    ReferenceEntry.plates => 'VIII',
  };
}
