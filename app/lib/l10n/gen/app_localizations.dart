import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_gl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('ca'),
    Locale('en'),
    Locale('es'),
    Locale('gl'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// The application name, shown by the OS task switcher. The one key that is legitimately identical in all six locales: it is a product name, not a sentence.
  ///
  /// In en, this message translates to:
  /// **'CatchLaw'**
  String get appTitle;

  /// Count of species matching the S5 search term. The list is capped at 40 (SPEC.md §13), so the number is always small — but the plural categories are the locale's, not the number's.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} match} other{{count} matches}}'**
  String searchResultCount(int count);

  /// Settings label: settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// The null-override state: no language has been pinned, so the device decides. Phrased as a noun, not as `Follow the device` — every string in this app states what is, and never tells the reader to do something.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get settingsLanguageSystemDefault;

  /// S14's label for the numeral-system control. Not `numbers`: what the fisher picks is which digit shapes render, not whether numbers appear.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get settingsNumeralSystem;

  /// The `auto` value of user_profile.numeral_system: defer to whatever CLDR says for the resolved locale. Phrased as a statement about where the value comes from, never as an instruction.
  ///
  /// In en, this message translates to:
  /// **'Device language default'**
  String get settingsNumeralSystemAuto;

  /// The `latn` value: Western digits always, regardless of locale. The sample digits are part of the label so the choice is visible without applying it.
  ///
  /// In en, this message translates to:
  /// **'Western — 0 1 2 3'**
  String get settingsNumeralSystemLatn;

  /// The `arab` value: Arabic-Indic digits (U+0660-U+0669) always. Distinct from the Persian block U+06F0-U+06F9, which this app does not offer.
  ///
  /// In en, this message translates to:
  /// **'Arabic-Indic — ٠ ١ ٢ ٣'**
  String get settingsNumeralSystemArab;

  /// Shown beside a verbatim legal text when the reader's locale is not among the jurisdiction's legal_text_locales. A STATEMENT ABOUT THE DATA, never an instruction: it must not tell the reader to switch language, change a setting, or do anything at all. SPEC.md §9.6 — we do not translate legal text, because an unofficial translation of a penal instrument is a liability.
  ///
  /// In en, this message translates to:
  /// **'The verbatim text of this instrument exists only in {language}.'**
  String legalTextLanguageNotice(String language);

  /// The name of one shipped language, IN THE READER'S OWN LANGUAGE — Galician named in Arabic, Arabic named in Galician. A select rather than six keys so the 36 cells stay under the ARB parity gate. The `other` branch exists only because ICU requires one; every shipped code has its own branch.
  ///
  /// In en, this message translates to:
  /// **'{code, select, ar{Arabic} en{English} es{Spanish} gl{Galician} ca{Catalan} ptBR{Brazilian Portuguese} other{English}}'**
  String languageName(String code);

  /// S5's persistent field label. A noun, above the rule, never a placeholder that vanishes on focus.
  ///
  /// In en, this message translates to:
  /// **'Species'**
  String get speciesSearchLabel;

  /// Illustrative examples inside the empty field, chosen to show that a LOCAL name works — not only a scientific one.
  ///
  /// In en, this message translates to:
  /// **'hamour, mero, Epinephelus'**
  String get speciesSearchHint;

  /// The first result group. Shown first because it is the answer to the question actually being asked.
  ///
  /// In en, this message translates to:
  /// **'In your zone'**
  String get speciesGroupInYourZone;

  /// The second result group. Never hidden: a fisher who picked the wrong zone must be able to see that his fish exists, rather than being told it does not.
  ///
  /// In en, this message translates to:
  /// **'Elsewhere in this jurisdiction'**
  String get speciesGroupElsewhere;

  /// One-word row hint. A STATEMENT about the species' status under an instrument, never an instruction: no imperative, no advice about what to do with the fish. The banned lexicon is product-invariants.md §2, and it is not quoted here — check_lonja_verdict reads this file and cannot tell a prohibition from an example of one, and ARB values are never exempt.
  ///
  /// In en, this message translates to:
  /// **'protected'**
  String get speciesHintProtected;

  /// One-word row hint: a closure covers today. A statement of fact, never an instruction.
  ///
  /// In en, this message translates to:
  /// **'closed'**
  String get speciesHintClosed;

  /// S5's empty state. States what happened; the two actions beside it are the way onward.
  ///
  /// In en, this message translates to:
  /// **'No species by that name'**
  String get speciesNoMatchHeadline;

  /// Why a name might not match, without blaming the reader and without promising the species is absent. Never an instruction.
  ///
  /// In en, this message translates to:
  /// **'The name may be spelled differently here, or the species may not be transcribed yet.'**
  String get speciesNoMatchBody;

  /// The primary way onward from an empty search — S7's key. One of the three entry points §4.3 requires.
  ///
  /// In en, this message translates to:
  /// **'Identify this fish'**
  String get identifyThisFish;

  /// The secondary way onward from an empty search — S6.
  ///
  /// In en, this message translates to:
  /// **'Browse by shape'**
  String get browseByShape;

  /// The ochre stale bar. A STATEMENT that the data passed its end date and is shown as published. It must not tell the reader to update, check elsewhere, or do anything at all — invariant 5 shows the finding anyway.
  ///
  /// In en, this message translates to:
  /// **'These rules passed their stated end date. They are shown as published.'**
  String get rulePackExpired;

  /// How many species matched, out of how many the jurisdiction carries. The second number is what makes the empty state's claim honest.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} of {total}} other{{count} of {total}}}'**
  String speciesSearchResultCount(int count, int total);

  /// The label over S5's results: how many species the typed name matched. A sentence in the eyebrow step beside a rule, not a ratio.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} matching result} other{{count} matching results}}'**
  String speciesSearchMatchCount(int count);

  /// The accessible name of the affordance that empties S5's entry line. Names exactly what taking it does.
  ///
  /// In en, this message translates to:
  /// **'Clear the search'**
  String get speciesSearchClear;

  /// S6's screen heading.
  ///
  /// In en, this message translates to:
  /// **'Browse by shape'**
  String get browseByShapeTitle;

  /// S6 when the pack carries no species at all. States what is, without blaming the reader.
  ///
  /// In en, this message translates to:
  /// **'No species in this pack'**
  String get browseNoSpeciesHeadline;

  /// Why the grid is empty. A statement about the pack, never an instruction to the reader.
  ///
  /// In en, this message translates to:
  /// **'This jurisdiction has no species transcribed yet.'**
  String get browseNoSpeciesBody;

  /// S6's bar stamp: how many species this pack draws in the grid below. A count of what is on the page, not a claim about the jurisdiction.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} species} other{{count} species}}'**
  String browseSpeciesCount(int count);

  /// A family heading in S6's grid: the family name in the reader's own language, then how many species sit under it. A format rather than a sentence, so the separator is the same mark in every locale.
  ///
  /// In en, this message translates to:
  /// **'{family} · {count}'**
  String browseFamilyHeading(String family, int count);

  /// The figure on S6's overflow cell — how many species of this family the grid is not showing yet. Set in the mono step so it reads as a count.
  ///
  /// In en, this message translates to:
  /// **'+{count}'**
  String browseMoreCount(int count);

  /// The words under the overflow cell's figure, naming the family the hidden species belong to. Taking the cell opens them in place; nothing is unreachable.
  ///
  /// In en, this message translates to:
  /// **'more in {family}'**
  String browseMoreInFamily(String family);

  /// S2's block of names in the other shipped locales. Set small and after the reader's own name.
  ///
  /// In en, this message translates to:
  /// **'Other names'**
  String get speciesOtherNames;

  /// The binomial's label. It comes LAST on the header, because a reader who does not read Latin cannot check it.
  ///
  /// In en, this message translates to:
  /// **'Scientific name'**
  String get speciesScientificName;

  /// The family label on S2.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get speciesFamilyLabel;

  /// What a screen reader announces the engraved plate as.
  ///
  /// In en, this message translates to:
  /// **'Engraved plate'**
  String get speciesPlateSemanticLabel;

  /// What a screen reader announces the species line art as. A STATEMENT OF FACT naming what the drawing is — originated line art, not a photograph and not an engraved plate — so a fisher who cannot see it knows what he is missing rather than assuming an image failed to load.
  ///
  /// In en, this message translates to:
  /// **'Line drawing'**
  String get speciesSilhouetteSemanticLabel;

  /// S2's protection mark. A STATEMENT about where a protection exists, not a verdict about this catch and not an instruction — E10's finding is what states the rule with its citation. It says SOMEWHERE on purpose: the account page is reached before a zone is known.
  ///
  /// In en, this message translates to:
  /// **'Protected somewhere in this jurisdiction'**
  String get speciesProtectedAnywhere;

  /// The look-alike block's heading on S2. States that a confusion exists — it does not warn, advise or instruct.
  ///
  /// In en, this message translates to:
  /// **'Easily confused with'**
  String get lookAlikeSectionLabel;

  /// The label above the difference sentence. `What differentiates them`, not `how to avoid the mistake`: the sentence beneath describes a physical character, and the reader decides what that means.
  ///
  /// In en, this message translates to:
  /// **'How to tell them apart'**
  String get lookAlikeConfusedWith;

  /// The recents strip's heading. HERE, because recents are per zone: the six species of the Ría de Arousa are not the six of Ras Al Khaimah.
  ///
  /// In en, this message translates to:
  /// **'Recent here'**
  String get recentsStripLabel;

  /// Shown when the strip is empty. States what will fill it — a description of the mechanism, not an instruction to go and use it.
  ///
  /// In en, this message translates to:
  /// **'Species you open in this zone appear here.'**
  String get recentsEmptyBody;

  /// S4's heading.
  ///
  /// In en, this message translates to:
  /// **'Measure your screen'**
  String get calibrationTitle;

  /// What to do with the card. This is one of the very few places the app addresses an action, and it is about the DEVICE rather than about a fish — no rule, no verdict, nothing about what to keep.
  ///
  /// In en, this message translates to:
  /// **'Lay any bank card, licence or ID on the glass and drag the edge to match it.'**
  String get calibrationCardExplainer;

  /// What a screen reader announces the drag handle as.
  ///
  /// In en, this message translates to:
  /// **'Card edge'**
  String get calibrationHandleLabel;

  /// The second step. A fit step alone measures whatever was dragged to, including a handle nudged by a palm; this asks the reader to check a bar of known length against the same card. The length is a placeholder so it is authored once in Dart rather than typed into six translations.
  ///
  /// In en, this message translates to:
  /// **'This bar is {measurement}. Check it against the short side of the same card.'**
  String calibrationVerifyExplainer(String measurement);

  /// The verify bar's own length, beside it. A placeholder only — the number and its unit are assembled by LengthDisplay and the unit key, glued with a non-breaking space. It is a pre-formatted STRING and not an int, because it carries a unit word in the locale's own digits; check_measurement check 1's `int lengthMm` rule is about a STORED length, and nothing here is stored.
  ///
  /// In en, this message translates to:
  /// **'{measurement}'**
  String calibrationVerifyBarLabel(String measurement);

  /// Stores the measured scale.
  ///
  /// In en, this message translates to:
  /// **'Save this measurement'**
  String get calibrationSaveAction;

  /// Returns to the fit step. From the approved corpus in button-anatomy.md — it names the step rather than a preservation, because the preservation wordings all open with a verb invariant 2 bans.
  ///
  /// In en, this message translates to:
  /// **'Back one step'**
  String get calibrationCancelAction;

  /// A screen narrower than a card cannot be calibrated by this method. States the fact and names the path that still works — manual entry, which never depends on a calibration.
  ///
  /// In en, this message translates to:
  /// **'This screen is narrower than a card. Manual entry is available.'**
  String get calibrationTooSmallScreen;

  /// Shown when a drag did not trace a card. It states WHAT WAS MEASURED, because a fisher who dragged to something absurd can see it — a bare refusal leaves him looking at the same handle with no idea why nothing happened.
  ///
  /// In en, this message translates to:
  /// **'That drag measured {measurement} across the screen, which is not a card.'**
  String calibrationImplausible(String measurement);

  /// The millimetre unit word, glued to its number with a non-breaking space at the call site. Its own key so a number and its unit are never concatenated in Dart, where the order is wrong in Arabic.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get unitMillimetres;

  /// The centimetre unit word. Same rule.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get unitCentimetres;

  /// What a screen reader announces the ruler as. The canvas itself is excluded from semantics — a hundred tick marks is not a reading — so this sibling node carries the number. It STATES the reading and never says what it means.
  ///
  /// In en, this message translates to:
  /// **'Ruler. Reading {measurement}.'**
  String rulerSemanticLabel(String measurement);

  /// The zero mark, in the locale's own digits. Its own key because the numeral system is a user setting and the zero is the one label that is always visible.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get rulerZeroLabel;

  /// A measurement and the method it was taken by. The method is NOT optional: TL and FL differ by 6-9 cm on a Kanaad, so a number on its own is one the reader cannot act on. The two are separate placeholders because they sit on different sides of the sentence in different languages, and the unit is glued to its value with a non-breaking space rather than concatenated in Dart.
  ///
  /// In en, this message translates to:
  /// **'{value} cm ({method})'**
  String measurementCm(String value, String method);

  /// A measurement and the method it was taken by. The method is NOT optional: TL and FL differ by 6-9 cm on a Kanaad, so a number on its own is one the reader cannot act on. The two are separate placeholders because they sit on different sides of the sentence in different languages, and the unit is glued to its value with a non-breaking space rather than concatenated in Dart.
  ///
  /// In en, this message translates to:
  /// **'{value} mm ({method})'**
  String measurementMm(String value, String method);

  /// A measurement and the method it was taken by. The method is NOT optional: TL and FL differ by 6-9 cm on a Kanaad, so a number on its own is one the reader cannot act on. The two are separate placeholders because they sit on different sides of the sentence in different languages, and the unit is glued to its value with a non-breaking space rather than concatenated in Dart.
  ///
  /// In en, this message translates to:
  /// **'{value} in ({method})'**
  String measurementInch(String value, String method);

  /// A mass in kilograms, for a bag limit an instrument states by weight.
  ///
  /// In en, this message translates to:
  /// **'{value} kg'**
  String massKg(String value);

  /// The period a bag limit is stated over. A noun, used inside a verdict sentence.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get limitPeriodDay;

  /// The period a bag limit is stated over. A noun, used inside a verdict sentence.
  ///
  /// In en, this message translates to:
  /// **'trip'**
  String get limitPeriodTrip;

  /// The period a bag limit is stated over. A noun, used inside a verdict sentence.
  ///
  /// In en, this message translates to:
  /// **'season'**
  String get limitPeriodSeason;

  /// The month names, selected by number. Season boundaries print as day and month, never as an ISO date: an ISO date in prose is unreadable to the man holding the fish.
  ///
  /// In en, this message translates to:
  /// **'{month, select, 1{January} 2{February} 3{March} 4{April} 5{May} 6{June} 7{July} 8{August} 9{September} 10{October} 11{November} 12{December} other{{month}}}'**
  String monthName(String month);

  /// A day and a month, composed per locale. Spanish, Galician, Catalan and Portuguese need a preposition English does not, and Catalan elides it before a vowel.
  ///
  /// In en, this message translates to:
  /// **'{day} {month}'**
  String dateDayMonth(String day, String month);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Both numbers are mandatory and so is the method: a threshold with no method is a number the reader cannot act on, because total length and fork length differ by 6-9 cm on the same fish. Word order may change; no slot may be dropped. The unit is a placeholder and follows the INSTRUMENT, never the reader locale and never the ruler setting: a Galician shell length stays in mm on an Arabic phone.
  ///
  /// In en, this message translates to:
  /// **'Meets the minimum — {measured} {unit} measured, minimum {threshold} {unit} ({method})'**
  String verdictMeetsMinimum(String measured, String unit, String threshold, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The headline sentence of the whole product. Both numbers and the method are mandatory. It states what the instrument requires and what was measured, and says nothing about what to do with the fish. The unit is a placeholder and follows the INSTRUMENT, never the reader locale and never the ruler setting: a Galician shell length stays in mm on an Arabic phone.
  ///
  /// In en, this message translates to:
  /// **'Below the minimum — {measured} {unit} measured, minimum {threshold} {unit} ({method})'**
  String verdictBelowMinimum(String measured, String unit, String threshold, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. A slot rule read from the other end. Both numbers and the method are mandatory. The unit is a placeholder and follows the INSTRUMENT, never the reader locale and never the ruler setting: a Galician shell length stays in mm on an Arabic phone.
  ///
  /// In en, this message translates to:
  /// **'Within the maximum — {measured} {unit} measured, maximum {threshold} {unit} ({method})'**
  String verdictWithinMaximum(String measured, String unit, String threshold, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. A maximum, not a minimum: this is a legally distinct statement from the below-minimum one and may never be merged with it. Both numbers and the method are mandatory. The unit is a placeholder and follows the INSTRUMENT, never the reader locale and never the ruler setting: a Galician shell length stays in mm on an Arabic phone.
  ///
  /// In en, this message translates to:
  /// **'Above the maximum — {measured} {unit} measured, maximum {threshold} {unit} ({method})'**
  String verdictAboveMaximum(String measured, String unit, String threshold, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Nothing has been measured, so nothing has been compared. This is an OPEN QUESTION and never a pass: an unmeasured fish has not met the minimum, nobody has checked. The unit is a placeholder and follows the INSTRUMENT, never the reader locale and never the ruler setting: a Galician shell length stays in mm on an Arabic phone.
  ///
  /// In en, this message translates to:
  /// **'Not measured — the minimum is {threshold} {unit} ({method})'**
  String verdictMinimumNotMeasured(String threshold, String unit, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Nothing has been measured, so nothing has been compared. An OPEN QUESTION, never a pass. The unit is a placeholder and follows the INSTRUMENT, never the reader locale and never the ruler setting: a Galician shell length stays in mm on an Arabic phone.
  ///
  /// In en, this message translates to:
  /// **'Not measured — the maximum is {threshold} {unit} ({method})'**
  String verdictMaximumNotMeasured(String threshold, String unit, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The reading and the instrument use different methods, so the two numbers are stated side by side and NO comparison is drawn. A conversion factor here would manufacture a pass at the centimetre that costs AED 3,000. The unit is a placeholder and follows the INSTRUMENT, never the reader locale and never the ruler setting: a Galician shell length stays in mm on an Arabic phone.
  ///
  /// In en, this message translates to:
  /// **'Measured by {measuredMethod} — the instrument states {threshold} {unit} ({method}). No comparison is made.'**
  String verdictSizeMethodMismatch(
    String measuredMethod,
    String threshold,
    String unit,
    String method,
  );

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The numeric margin under the stamp. It restates the gap the headline already carries; it never advises.
  ///
  /// In en, this message translates to:
  /// **'Short of the minimum by {margin} {unit}'**
  String verdictMarginShortOfMinimum(String margin, String unit);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The numeric margin under the stamp, for an individual that meets the minimum.
  ///
  /// In en, this message translates to:
  /// **'Over the minimum by {margin} {unit}'**
  String verdictMarginOverMinimum(String margin, String unit);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The numeric margin under the stamp, for an individual above the maximum.
  ///
  /// In en, this message translates to:
  /// **'Over the maximum by {margin} {unit}'**
  String verdictMarginOverMaximum(String margin, String unit);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The numeric margin under the stamp, for an individual within the maximum.
  ///
  /// In en, this message translates to:
  /// **'Under the maximum by {margin} {unit}'**
  String verdictMarginUnderMaximum(String margin, String unit);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Both dates and the position inside the window are mandatory. Never a countdown: days-remaining invites planning, and this app states what the instrument says today.
  ///
  /// In en, this message translates to:
  /// **'Closed season — {starts} to {ends}. In force today, day {day} of {total}.'**
  String verdictClosedSeasonInForce(String starts, String ends, String day, String total);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The closure exists and is not in force today. It is stated rather than hidden, because the fisher is entitled to see the whole picture.
  ///
  /// In en, this message translates to:
  /// **'Closed season — {starts} to {ends}. Not in force today.'**
  String verdictClosedSeasonNotInForce(String starts, String ends);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. No measurement slot at all: a measurement beside a prohibition implies a threshold that does not exist, and a reader who sees one looks for a bigger individual of a species that may never be taken.
  ///
  /// In en, this message translates to:
  /// **'Protected species — taking prohibited.'**
  String get verdictProtected;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The stamp headline alone — the state, with no numbers. The figures are printed beneath it by verdictDetailMinimum, which is mandatory beside this: the headline never travels without its detail line.
  ///
  /// In en, this message translates to:
  /// **'Meets the minimum'**
  String get verdictStampMeetsMinimum;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The stamp headline alone. It states what the instrument found and says nothing about what to do with the fish; the numbers are carried by verdictDetailMinimum directly beneath it.
  ///
  /// In en, this message translates to:
  /// **'Below the minimum'**
  String get verdictStampBelowMinimum;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The stamp headline alone, for an individual under a maximum. The numbers are carried by verdictDetailMaximum beneath it.
  ///
  /// In en, this message translates to:
  /// **'Within the maximum'**
  String get verdictStampWithinMaximum;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The stamp headline alone, for an individual over a maximum. A maximum is a legally distinct rule from a minimum and never shares its wording.
  ///
  /// In en, this message translates to:
  /// **'Above the maximum'**
  String get verdictStampAboveMaximum;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The stamp headline where no reading has been taken. It is not a pass: nobody has checked, and the threshold beneath it states what would be compared.
  ///
  /// In en, this message translates to:
  /// **'Not measured'**
  String get verdictStampNotMeasured;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The stamp headline where the reading was taken by one method and the instrument states another. No comparison is made, and no conversion factor is applied.
  ///
  /// In en, this message translates to:
  /// **'Measured by another method'**
  String get verdictStampMethodMismatch;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The stamp headline for a closure. The window is part of the headline because a closure with no dates is not checkable against the instrument.
  ///
  /// In en, this message translates to:
  /// **'Closed season — {starts} to {ends}'**
  String verdictStampClosedSeason(String starts, String ends);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The figures line struck under the stamp headline. Both numbers are mandatory and so is the method: a threshold with no method is a number the reader cannot act on, because total length and fork length differ by 6-9 cm on the same fish. The unit follows the INSTRUMENT, never the reader locale and never the ruler setting.
  ///
  /// In en, this message translates to:
  /// **'{measured} {unit} measured · minimum {threshold} {unit} · {method}'**
  String verdictDetailMinimum(String measured, String unit, String threshold, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The figures line struck under the stamp headline, for a maximum. Both numbers and the method are mandatory. The unit follows the INSTRUMENT.
  ///
  /// In en, this message translates to:
  /// **'{measured} {unit} measured · maximum {threshold} {unit} · {method}'**
  String verdictDetailMaximum(String measured, String unit, String threshold, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The figures line where no reading exists. It states the threshold and the absence of a reading; it never softens the absence into a pass.
  ///
  /// In en, this message translates to:
  /// **'Nothing measured · minimum {threshold} {unit} · {method}'**
  String verdictDetailMinimumUnmeasured(String threshold, String unit, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The figures line where no reading exists, for a maximum.
  ///
  /// In en, this message translates to:
  /// **'Nothing measured · maximum {threshold} {unit} · {method}'**
  String verdictDetailMaximumUnmeasured(String threshold, String unit, String method);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The figures line under a closure headline. It states where today sits in the window and never how many days remain: a countdown invites planning, and this app states what the instrument says today. The size clause is stated because a closure that printed a measurement would suggest some size escapes it.
  ///
  /// In en, this message translates to:
  /// **'In force today, day {day} of {total} · applies at every size'**
  String verdictDetailClosedSeasonInForce(String day, String total);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The figures line under a closure that exists and is not in force today. The closure is still stated rather than hidden, because the fisher is entitled to see the whole picture.
  ///
  /// In en, this message translates to:
  /// **'Not in force today'**
  String get verdictDetailClosedSeasonNotInForce;

  /// The engraved plate's caption line: the scientific binomial and the family it sits in, set in one italic run under the names. Both are Latin in every locale and neither is translated; only the separator may change.
  ///
  /// In en, this message translates to:
  /// **'{binomial} — {family}'**
  String speciesBinomialFamily(String binomial, String family);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. What has been recorded and what the instrument permits. The period is mandatory: a season quota compared against one day passes on every day of a season it has already exhausted.
  ///
  /// In en, this message translates to:
  /// **'Within the bag limit — {recorded} recorded, limit {limit} per {period}'**
  String verdictWithinBagLimit(String recorded, String limit, String period);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. What has been recorded and what the instrument permits, with the period it is stated over.
  ///
  /// In en, this message translates to:
  /// **'Above the bag limit — {recorded} recorded, limit {limit} per {period}'**
  String verdictAboveBagLimit(String recorded, String limit, String period);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The catch log is opt-in, so nothing recorded is the common case. An OPEN QUESTION, never a pass.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded for this period — the bag limit is {limit} per {period}'**
  String verdictBagLimitNotRecorded(String limit, String period);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. A per-hull count. It carries no period, because the instrument gives it none and the app may not state one it was not given.
  ///
  /// In en, this message translates to:
  /// **'Within the vessel limit — {recorded} recorded, limit {limit}'**
  String verdictWithinVesselLimit(String recorded, String limit);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. A per-hull count, exceeded. No period, for the same reason.
  ///
  /// In en, this message translates to:
  /// **'Above the vessel limit — {recorded} recorded, limit {limit}'**
  String verdictAboveVesselLimit(String recorded, String limit);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Nothing recorded against this hull. An OPEN QUESTION, never a pass.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded for this vessel — the limit is {limit}'**
  String verdictVesselLimitNotRecorded(String limit);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. TWO sentences are mandatory: the second one prevents the absence of a rule from being read as permission. Do not merge, shorten or soften it.
  ///
  /// In en, this message translates to:
  /// **'No rule recorded for this species here. This does not mean it is legal.'**
  String get verdictNoRuleRecorded;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Legally miles from the no-rule sentence and never merged with it: here the instrument WAS read and positively records no limit, and it is cited. There it was silent.
  ///
  /// In en, this message translates to:
  /// **'The instrument was read and records no limit for this species here.'**
  String get verdictNoLimitInInstrument;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The species is not in this jurisdiction reference at all — a different state from a species with no rule. TWO sentences, and the second may not be softened.
  ///
  /// In en, this message translates to:
  /// **'This species is not recorded for this jurisdiction. This does not mean it is legal.'**
  String get verdictUnknownSpecies;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Two instruments of equal standing disagree and the app chooses neither. It states the disagreement and ranks nothing; picking one would be advice.
  ///
  /// In en, this message translates to:
  /// **'Two rules of equal standing apply here.'**
  String get verdictAmbiguous;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Row label in the rule table. A noun, not a sentence.
  ///
  /// In en, this message translates to:
  /// **'Measured'**
  String get findingFactMeasured;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Row label in the rule table. A noun, not a sentence.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get findingFactMinimum;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Row label in the rule table. A noun, not a sentence.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get findingFactMaximum;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Row label in the rule table, for the two dates of a closure.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get findingFactDates;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Row label in the rule table, for where today sits inside a closure.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get findingFactToday;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Row label in the rule table, for what the catch log holds.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get findingFactRecorded;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Row label in the rule table, for what the instrument permits.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get findingFactLimit;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Row label in the rule table, for the period a limit is stated over.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get findingFactPeriod;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Where today sits inside a closure. Not a countdown.
  ///
  /// In en, this message translates to:
  /// **'day {day} of {total}'**
  String findingDayOfWindow(String day, String total);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The two dates of a closure, as day and month.
  ///
  /// In en, this message translates to:
  /// **'{starts} to {ends}'**
  String findingWindowRange(String starts, String ends);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Unconditional and never dismissible. The authority is per jurisdiction: a generic one is a shrug. The wording is fixed by catchlaw-verdict-contract and may not be shortened.
  ///
  /// In en, this message translates to:
  /// **'CatchLaw quotes published instruments. It is not legal advice and does not authorise any catch. Verify with {authority} before relying on it.'**
  String disclaimerVerdict(String authority);

  /// The accessible name of the copy control on the citation footnote. It copies the CITATION LINE — instrument, article and both dates — and never the verdict sentence: a verdict on the clipboard is a statement about one fish detached from the source that supports it.
  ///
  /// In en, this message translates to:
  /// **'Copy the citation'**
  String get citationCopyAction;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The ochre bar, with the date the pack stated as its end. It must not tell the reader to update, to check elsewhere, or to do anything at all: invariant 5 shows the finding anyway, and there is no network to recover from. The date is ISO and unlocalised, like every citation date.
  ///
  /// In en, this message translates to:
  /// **'These rules passed their stated end date on {date}. They are shown as published.'**
  String rulePackExpiredOn(String date);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The second citation footnote on an expired pack. It states which pack and when it lapsed, and says nothing about what the reader should do with that.
  ///
  /// In en, this message translates to:
  /// **'Bundled rule pack {pack} passed its validity date on {date}. The text above is the last verified wording.'**
  String rulePackProvenance(String pack, String date);

  /// The control that puts the stale-pack EXPLANATION away for this app session. It closes the note, never the bar: the bar is the invariant and only the paragraph under it can be put away. It is not persisted, so a reader returning in September sees it again.
  ///
  /// In en, this message translates to:
  /// **'Close this note'**
  String get staleDetailClose;

  /// Opens the note field. It records a doubt about the TRANSCRIPTION and changes no number and no verdict — the label must not suggest the app will act on it, and there is nowhere for it to be sent.
  ///
  /// In en, this message translates to:
  /// **'Flag this rule'**
  String get flagRuleAction;

  /// The field label. It asks what the INSTRUMENT says, not what the reader wants the answer to be.
  ///
  /// In en, this message translates to:
  /// **'What the instrument says'**
  String get flagRuleNoteLabel;

  /// The save target. Its label names the effect and its whole extent: the note stays on this device, because there is no network and nothing is transmitted.
  ///
  /// In en, this message translates to:
  /// **'Save this note on this device'**
  String get flagRuleSaveAction;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The receipt for something already committed, in the past tense. It promises no review, no reply and no upload.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device.'**
  String get flagRuleRecorded;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. States why nothing was written.
  ///
  /// In en, this message translates to:
  /// **'The note is empty.'**
  String get flagRuleEmptyNote;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The mono line under the disclaimer, which makes the disclaimer’s absence legible in a screenshot: a reader looking at a screen grab can tell whether the sentence above was ever there. It states a property of the screen, never an instruction.
  ///
  /// In en, this message translates to:
  /// **'It cannot be dismissed.'**
  String get disclaimerNotDismissable;

  /// S9’s question. It asks where he IS, not where he wants the rules to come from — the place decides which instrument applies, and he is not choosing a jurisdiction the way one chooses a setting.
  ///
  /// In en, this message translates to:
  /// **'Where are you fishing?'**
  String get zonePickerTitle;

  /// Level label. A noun.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get zoneLevelCountry;

  /// Level label. The authority that publishes, which §7.1 calls a jurisdiction and a fisher calls a region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get zoneLevelRegion;

  /// The subline under the Trips heading. States where the ledger lives, as a fact about this build: nothing is uploaded, so nothing has to be claimed about a server.
  ///
  /// In en, this message translates to:
  /// **'Kept on this device only'**
  String get tripsKeptHere;

  /// The stamp at the trailing edge of the Trips bar — how many outings the ledger holds. Not an ICU plural on purpose: it heads a column the way a printed ledger does, and the six shipped languages each need every CLDR category for a plural message that says nothing the figure does not.
  ///
  /// In en, this message translates to:
  /// **'{count} trips'**
  String tripsCountStamp(int count);

  /// The detail line of one closed trip row: where it was, and the clock times it ran between.
  ///
  /// In en, this message translates to:
  /// **'{zone} · {started} — {ended}'**
  String tripsRowSpan(String zone, String started, String ended);

  /// The detail line of the trip still running. The open end is a word rather than a blank, because a blank reads as a time that failed to load.
  ///
  /// In en, this message translates to:
  /// **'{zone} · {started} — now'**
  String tripsRowSpanOpen(String zone, String started);

  /// The quiet inline marker beside the date of the trip still running. It repeats what the stamp at the end of the row says, because the open trip is marked twice and neither mark is a colour.
  ///
  /// In en, this message translates to:
  /// **'· open'**
  String get tripsOpenMark;

  /// The ruled stamp at the end of the row of the trip still running. A word inside a frame, so it survives greyscale and glare.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get tripsOpenStamp;

  /// How long a closed trip ran, set in the mono step at the end of its row.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String tripsDuration(int hours, int minutes);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. A read that failed, said plainly, in place of the exception object this screen used to print at the fisher.
  ///
  /// In en, this message translates to:
  /// **'The trips on this device could not be read.'**
  String get tripsLoadFailed;

  /// Level label. Offered only where the pack printed coordinates.
  ///
  /// In en, this message translates to:
  /// **'Sub-zone'**
  String get zoneLevelSubZone;

  /// Water choice. Offered only where the authority publishes both sea and inland rules.
  ///
  /// In en, this message translates to:
  /// **'Sea'**
  String get zoneWaterSalt;

  /// Water choice. Offered only where the authority publishes both sea and inland rules.
  ///
  /// In en, this message translates to:
  /// **'Inland water'**
  String get zoneWaterFresh;

  /// Names the effect: the place is remembered and the next launch opens already knowing it.
  ///
  /// In en, this message translates to:
  /// **'Use this place'**
  String get zonePickerConfirm;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. A country with no bundled jurisdiction. It states what this BUILD carries, never what the country regulates.
  ///
  /// In en, this message translates to:
  /// **'No rules bundled for this country'**
  String get zonePickerEmptyHeadline;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The second sentence is mandatory and may not be softened or merged: an absence in the pack is not an absence of law, and a reader who takes it as one is exactly the failure the no-rule wording exists to prevent.
  ///
  /// In en, this message translates to:
  /// **'This build carries no transcribed instrument for it. That does not mean there are none.'**
  String get zonePickerEmptyBody;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. A read that failed, said plainly. It must not be rendered as an empty list: a picker showing no countries because a file was locked reads as a claim that the app ships nowhere.
  ///
  /// In en, this message translates to:
  /// **'The bundled rule pack could not be read.'**
  String get zonePickerLoadFailed;

  /// The shipped country names, selected by ISO code. `other` falls through to the code itself rather than to a guess: an unrecognised country is a pack this build did not produce, and a wrong country name on a legal screen is worse than a bare code.
  ///
  /// In en, this message translates to:
  /// **'{code, select, ES{Spain} AE{United Arab Emirates} BR{Brazil} other{{code}}}'**
  String countryName(String code);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Why the sub-zone level is absent. It states what the AUTHORITY publishes, never what the app could not load: SPEC.md §8 ends that row with four words — we do not invent boundaries — and an administrative boundary borrowed from a public dataset would render beautifully and attribute a rule to a zone the decision never mentions. The second sentence is mandatory: without it the absence reads as a gap rather than as the scope the instrument actually has.
  ///
  /// In en, this message translates to:
  /// **'{authority} publishes no coordinate boundaries. The rules recorded here apply across the whole jurisdiction.'**
  String zoneNoPublishedBoundaries(String authority);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. Why the place cannot be confirmed yet. The authority publishes rules for both waters and they are different rules, so a place that has not said which one answers with the wrong instrument — this states the condition, not an instruction to the reader.
  ///
  /// In en, this message translates to:
  /// **'Sea or inland water has to be chosen before this place can answer.'**
  String get zoneWaterChoiceRequired;

  /// Bottom navigation label. A noun, and the same word §6 uses for that screen.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get navCheck;

  /// Shown on the four navigation branches this release does not build. A STATEMENT OF FACT about what this version contains — it does not apologise, does not promise a date, and does not tell the reader to do anything. A branch that renders only its own name reads as a broken screen rather than as one that is not built.
  ///
  /// In en, this message translates to:
  /// **'This version answers one question: whether a fish meets the rules in the place it was landed. This part is not built yet.'**
  String get destinationNotBuiltYet;

  /// Settings label: settingsLanguageDevice.
  ///
  /// In en, this message translates to:
  /// **'Follow the device'**
  String get settingsLanguageDevice;

  /// Settings label: settingsDigits.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get settingsDigits;

  /// Settings label: settingsDigitsAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get settingsDigitsAuto;

  /// Settings label: settingsDigitsLatn.
  ///
  /// In en, this message translates to:
  /// **'0123'**
  String get settingsDigitsLatn;

  /// Settings label: settingsDigitsArab.
  ///
  /// In en, this message translates to:
  /// **'٠١٢٣'**
  String get settingsDigitsArab;

  /// A length unit abbreviation on the Settings unit control, written in the reader's own script. Arabic abbreviates in Arabic letters rather than borrowing the Latin form.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get settingsUnitCm;

  /// A length unit abbreviation on the Settings unit control, written in the reader's own script. Arabic abbreviates in Arabic letters rather than borrowing the Latin form.
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get settingsUnitMm;

  /// A length unit abbreviation on the Settings unit control, written in the reader's own script. Arabic abbreviates in Arabic letters rather than borrowing the Latin form.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get settingsUnitIn;

  /// Settings label: settingsLengthUnit.
  ///
  /// In en, this message translates to:
  /// **'Length shown in'**
  String get settingsLengthUnit;

  /// Settings label: settingsSunlightMode.
  ///
  /// In en, this message translates to:
  /// **'Sunlight mode'**
  String get settingsSunlightMode;

  /// Settings label: settingsSunlightNote.
  ///
  /// In en, this message translates to:
  /// **'Maximum contrast, for a wet screen in glare.'**
  String get settingsSunlightNote;

  /// Settings label: settingsGloveMode.
  ///
  /// In en, this message translates to:
  /// **'Glove mode'**
  String get settingsGloveMode;

  /// Settings label: settingsGloveNote.
  ///
  /// In en, this message translates to:
  /// **'Larger targets and wider spacing.'**
  String get settingsGloveNote;

  /// Heading over the first group of settings rows on S14 — language, digits and unit. A noun phrase naming what the rows below it govern.
  ///
  /// In en, this message translates to:
  /// **'Language and figures'**
  String get settingsGroupLanguage;

  /// Heading over the second group of settings rows on S14 — zone, ruler calibration and coordinate capture.
  ///
  /// In en, this message translates to:
  /// **'Where you fish'**
  String get settingsGroupPlace;

  /// Heading over the third group of settings rows on S14 — sunlight mode and glove mode.
  ///
  /// In en, this message translates to:
  /// **'Reading conditions'**
  String get settingsGroupReading;

  /// The line under the Digits key on S14, naming what the two digit systems are. A STATEMENT OF FACT about what the control changes.
  ///
  /// In en, this message translates to:
  /// **'Western or Arabic-Indic digits'**
  String get settingsDigitsNote;

  /// The line under the length-unit key on S14. Storage is always millimetres; this control changes display only.
  ///
  /// In en, this message translates to:
  /// **'Lengths on rules and readings'**
  String get settingsLengthUnitNote;

  /// Settings key naming the place every answer in the app is evaluated against.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get settingsZone;

  /// The line under the Zone key on S14. A STATEMENT OF FACT about what the setting reaches — it gives no instruction and makes no claim about the law itself.
  ///
  /// In en, this message translates to:
  /// **'Rules, species list and limits follow this'**
  String get settingsZoneNote;

  /// The Zone row's reading when no jurisdiction and zone have been stored yet. States the absence and nothing more.
  ///
  /// In en, this message translates to:
  /// **'No place chosen'**
  String get settingsZoneUnset;

  /// The ruler row's reading on S14: the measured scale of this screen, in pixels per ten millimetres. Set in the mono figure step so it can be compared character by character against another device.
  ///
  /// In en, this message translates to:
  /// **'{px} px / 10 millimetres'**
  String settingsRulerScale(String px);

  /// Settings key for the opt-in that lets a recorded catch carry the coordinates it was landed at.
  ///
  /// In en, this message translates to:
  /// **'Coordinate capture'**
  String get settingsCoordinates;

  /// The line under the coordinate-capture key on S14. A STATEMENT OF FACT about where the coordinates go — the app has no network code, so nothing leaves the phone.
  ///
  /// In en, this message translates to:
  /// **'Held on this device only, never transmitted'**
  String get settingsCoordinatesNote;

  /// Settings label: settingsRuler.
  ///
  /// In en, this message translates to:
  /// **'Ruler'**
  String get settingsRuler;

  /// Settings label: settingsRulerUncalibrated.
  ///
  /// In en, this message translates to:
  /// **'Not calibrated'**
  String get settingsRulerUncalibrated;

  /// The ruler's state on Settings. A STATEMENT OF FACT with the date calibration happened; it does not tell the reader to recalibrate.
  ///
  /// In en, this message translates to:
  /// **'Calibrated {on}'**
  String settingsRulerCalibrated(String on);

  /// Settings label: settingsAboutPack.
  ///
  /// In en, this message translates to:
  /// **'Rule book'**
  String get settingsAboutPack;

  /// The offline note at the foot of Settings. A STATEMENT OF FACT about what the app contains, in the reader's own interest — it makes no promise about the law and gives no instruction.
  ///
  /// In en, this message translates to:
  /// **'CatchLaw holds everything it needs on this phone. It has no account and no network code.'**
  String get settingsOfflineNote;

  /// Catch log copy: todayHeadline.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayHeadline;

  /// Catch log copy: todayNothingRecorded.
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded today'**
  String get todayNothingRecorded;

  /// The empty state on S8. A STATEMENT OF FACT about where records come from — it does not instruct the reader to record anything.
  ///
  /// In en, this message translates to:
  /// **'A species you record from its page appears here, with the count for this place.'**
  String get todayNothingBody;

  /// Catch log copy: todayNoPlace.
  ///
  /// In en, this message translates to:
  /// **'No place set'**
  String get todayNoPlace;

  /// Catch log copy: todayCountKept.
  ///
  /// In en, this message translates to:
  /// **'{count} recorded · {kept} kept'**
  String todayCountKept(int count, int kept);

  /// Catch log copy: tripsHeadline.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get tripsHeadline;

  /// Catch log copy: tripsNone.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get tripsNone;

  /// The empty state on S9. States what a trip does and that nothing leaves the phone. No instruction, no promise about the law.
  ///
  /// In en, this message translates to:
  /// **'Starting a trip groups what you record into one outing. Everything stays on this phone.'**
  String get tripsNoneBody;

  /// Catch log copy: tripsStart.
  ///
  /// In en, this message translates to:
  /// **'Start a trip'**
  String get tripsStart;

  /// Catch log copy: tripsEnd.
  ///
  /// In en, this message translates to:
  /// **'End this trip'**
  String get tripsEnd;

  /// Catch log copy: tripsRunning.
  ///
  /// In en, this message translates to:
  /// **'Running since {since}'**
  String tripsRunning(String since);

  /// Catch log copy: tripsEnded.
  ///
  /// In en, this message translates to:
  /// **'{started} — {ended}'**
  String tripsEnded(String started, String ended);

  /// The action that writes one catch to the private log. A neutral verb naming exactly what happens: it records, it does not submit, declare or report — SPEC 5 refuses presenting the log as satisfying any declaration duty.
  ///
  /// In en, this message translates to:
  /// **'Record this catch'**
  String get catchRecord;

  /// Catch log copy: catchRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get catchRecorded;

  /// Ruler and calibration copy: measureTitle.
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get measureTitle;

  /// Ruler and calibration copy: measureUncalibrated.
  ///
  /// In en, this message translates to:
  /// **'This screen is not calibrated'**
  String get measureUncalibrated;

  /// Why calibration exists, on S3. A STATEMENT OF FACT about the device — a phone has no millimetre, so an uncalibrated ruler would draw a guessed scale. It also states that manual entry works regardless, because rule 6 requires it.
  ///
  /// In en, this message translates to:
  /// **'A phone reports pixels, not millimetres, and the ratio differs by model. Until the screen is calibrated it cannot draw a ruler at true size. Typing a length works either way.'**
  String get measureUncalibratedBody;

  /// Ruler and calibration copy: measureManualLabel.
  ///
  /// In en, this message translates to:
  /// **'Or type the length'**
  String get measureManualLabel;

  /// Ruler and calibration copy: measureUse.
  ///
  /// In en, this message translates to:
  /// **'Use this length'**
  String get measureUse;

  /// Ruler and calibration copy: calibrateAction.
  ///
  /// In en, this message translates to:
  /// **'Calibrate the screen'**
  String get calibrateAction;

  /// Ruler and calibration copy: calibrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Calibrate'**
  String get calibrateTitle;

  /// Ruler and calibration copy: calibrateFitBody.
  ///
  /// In en, this message translates to:
  /// **'Lay a bank card flat on the screen, left edge against the left edge of the box, and drag the black line to its right edge.'**
  String get calibrateFitBody;

  /// Ruler and calibration copy: calibrateVerifyBody.
  ///
  /// In en, this message translates to:
  /// **'Check the line against the card once more. If it sits on the edge, save.'**
  String get calibrateVerifyBody;

  /// Ruler and calibration copy: calibrateVerifyAction.
  ///
  /// In en, this message translates to:
  /// **'Check it'**
  String get calibrateVerifyAction;

  /// Ruler and calibration copy: calibrateSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save the calibration'**
  String get calibrateSaveAction;

  /// Ruler and calibration copy: calibrateCardWidth.
  ///
  /// In en, this message translates to:
  /// **'A bank card is {mm} millimetres wide (ISO/IEC 7810 ID-1).'**
  String calibrateCardWidth(String mm);

  /// Shown when the plausibility band rejects a scale. States what happened to the measurement, not what the reader did wrong: a scale outside the band is a drag that slipped.
  ///
  /// In en, this message translates to:
  /// **'That scale is outside the plausible range for a phone screen, so it was not saved.'**
  String get calibrateImplausible;

  /// Ruler and calibration copy: todayRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get todayRemove;

  /// A per-species action on the day tally. Kept is authored by the fisher and never inferred from a verdict: a legal fish put back is still a legal fish.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get todayMarkKept;

  /// A per-species action on the day tally. Kept is authored by the fisher and never inferred from a verdict: a legal fish put back is still a legal fish.
  ///
  /// In en, this message translates to:
  /// **'Remove one'**
  String get todayUndoOne;

  /// The trailing stamp on the ruler screen's bar. Names the instrument the screen is, so a pushed screen read two hours from home says what it is as well as which fish it is about.
  ///
  /// In en, this message translates to:
  /// **'Ruler'**
  String get measureSup;

  /// The provenance line under the tick band. A scale drawn on glass is only as good as the calibration behind it, so the ruler states when it was measured and what it measured — both figures in mono, both comparable against the same line on another device.
  ///
  /// In en, this message translates to:
  /// **'Calibrated {on} · {pxPer10mm} pixels per centimetre'**
  String measureCalibrationProvenance(String on, String pxPer10mm);

  /// The step-and-mark section heading and the primary action that adds one segment. One key for both, because they name the same act: a fish longer than the phone is measured in segments.
  ///
  /// In en, this message translates to:
  /// **'Step and mark'**
  String get measureStepAndMark;

  /// The unit phrase beside the running total, set in serif next to the mono figure. It says SO FAR because the number is a running sum of the marks, not a finished measurement — and a total presented as final is one a fisher would read against a limit before he had finished measuring.
  ///
  /// In en, this message translates to:
  /// **'cm so far'**
  String get measureRunningTotalUnit;

  /// The stamp beside the running total, counting the marks made. There is no total to count towards: how many segments a fish takes is not knowable before it is measured.
  ///
  /// In en, this message translates to:
  /// **'Step {count}'**
  String measureStepPill(String count);

  /// How the instrument is worked. An instruction about operating the ruler, never about the fish or a rule.
  ///
  /// In en, this message translates to:
  /// **'Lay the screen edge at the snout, mark, slide the phone along the fish and mark again.'**
  String get measureStepNote;

  /// Opens manual length entry. Manual entry works before any calibration exists and is never a fallback — a fisher with a tape in his hand and no bank card in his pocket takes this path by choice.
  ///
  /// In en, this message translates to:
  /// **'Type instead'**
  String get measureTypeInstead;

  /// Reopens calibration from the ruler. A calibration measured once on a cracked screen or a different device is a scale nobody can correct without this.
  ///
  /// In en, this message translates to:
  /// **'Re-calibrate with a card'**
  String get measureRecalibrate;

  /// The closing note on the ruler. States what the screen does not do: measuring is not photographing and not locating, and the one exception is named with the setting that governs it.
  ///
  /// In en, this message translates to:
  /// **'Fish on the board, phone on the fish. No photograph is taken and no coordinate is read unless coordinate capture is switched on in Settings.'**
  String get measurePrivacyNote;

  /// The manual-entry screen's own title. A separate key from the label on the ruler, because a heading that opened with 'Or' would read as half a sentence.
  ///
  /// In en, this message translates to:
  /// **'Type the length'**
  String get measureManualTitle;

  /// The trailing stamp on the calibration bar. States how often this is done, so the screen does not read as a step in the measuring loop.
  ///
  /// In en, this message translates to:
  /// **'Once per device'**
  String get calibrateSup;

  /// The premise of the whole screen, stated above the drawing rather than captioned under the control: the reference object is a published physical constant, and both of its dimensions are quoted from the standard that fixes them.
  ///
  /// In en, this message translates to:
  /// **'Every card of this format is identical: ISO/IEC 7810 ID-1 — {width} × {height} millimetres'**
  String calibrateCardConstant(String width, String height);

  /// One dimension label on the card drawing, in mono. A figure of the CARD, not of a fish: it carries no measurement method because the object being measured is a rectangle whose size is published.
  ///
  /// In en, this message translates to:
  /// **'{mm} millimetres'**
  String calibrateDimension(String mm);

  /// Names which of the five corner marks is the control. Four are registration marks and one moves; a drawing that did not say so would be dragged from the wrong corner.
  ///
  /// In en, this message translates to:
  /// **'Drag the filled handle.'**
  String get calibrateDragHandleNote;

  /// The section heading over the table of what the current fit produced.
  ///
  /// In en, this message translates to:
  /// **'Resulting scale'**
  String get calibrateScaleLabel;

  /// Table row label: the measured scale itself, quoted over a centimetre rather than a millimetre so the figure carries a digit a reader can compare.
  ///
  /// In en, this message translates to:
  /// **'Pixels per centimetre'**
  String get calibrateRowScale;

  /// Table row label: what the device reports about itself. Stated beside the measured scale precisely because it does NOT produce it — no arithmetic on a density yields a millimetre.
  ///
  /// In en, this message translates to:
  /// **'Screen density'**
  String get calibrateRowDensity;

  /// Table row label: how far out a length can be if the fit was one pixel off. The screen's own honesty about its instrument.
  ///
  /// In en, this message translates to:
  /// **'Expected error'**
  String get calibrateRowError;

  /// Table row label: when the stored scale was measured, so an old calibration is visible rather than silently reused.
  ///
  /// In en, this message translates to:
  /// **'Last calibrated'**
  String get calibrateRowLastCalibrated;

  /// The screen density value: logical width and the logical-to-physical ratio, both as the device reports them.
  ///
  /// In en, this message translates to:
  /// **'{dp} dp · {ratio}×'**
  String calibrateDensityValue(String dp, String ratio);

  /// The expected error band and the span it applies over. Both figures belong to the SCREEN and not to a fish, so no measurement method attaches to them.
  ///
  /// In en, this message translates to:
  /// **'± {mm} millimetres over 30 centimetres'**
  String calibrateErrorValue(String mm);

  /// The last-calibrated value before any calibration exists. A stated absence rather than a blank cell, which would read as a figure that failed to load.
  ///
  /// In en, this message translates to:
  /// **'Not yet calibrated'**
  String get calibrateNotYet;

  /// Returns the handle to its starting position. Names what it restores — a starting position for the drag, which is never itself a scale and never measures anything.
  ///
  /// In en, this message translates to:
  /// **'Reset to screen default'**
  String get calibrateReset;

  /// The closing note on calibration. Answers the question every fisher asks before he trusts the number, and answers it with the physical reason rather than with reassurance.
  ///
  /// In en, this message translates to:
  /// **'A case or a screen protector changes nothing — the card sits on the glass and the glass is what is being measured.'**
  String get calibrateGlassNote;

  /// The keypad's delete key on S3. A word rather than a glyph: an arrow from an icon font is one missing family away from a tofu box on the one control that undoes a mistyped length.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get measureBackspace;

  /// The back affordance on a pushed screen's bar, read aloud by a screen reader. A direction of travel through the app, and never a word about the fish: the only thing this control does is return the reader to the screen the current one was pushed from.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get navBack;

  /// Bottom navigation label. A noun, and the same word §6 uses for that screen.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// Bottom navigation label. A noun, and the same word §6 uses for that screen.
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get navTrips;

  /// Bottom navigation label. A noun, and the same word §6 uses for that screen.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get navReference;

  /// Bottom navigation label. A noun, and the same word §6 uses for that screen.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// The masthead label above the active place. It says what the app is answering FOR, because a verdict read without knowing which jurisdiction produced it is a verdict about nowhere.
  ///
  /// In en, this message translates to:
  /// **'Answering for'**
  String get checkPlaceLabel;

  /// Reopens S9. The place is asked once and remembered, and this is the way back to it.
  ///
  /// In en, this message translates to:
  /// **'Change place'**
  String get checkChangePlace;

  /// Heading over the species he has opened here before. "Here" is load-bearing: recency is per zone, so the one unusual fish he looked up in another place does not reshuffle this one.
  ///
  /// In en, this message translates to:
  /// **'Recent here'**
  String get checkRecentsLabel;

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. When a human last verified this jurisdiction transcription. ISO and unlocalised, like every other date quoted from an instrument, so it can be compared against the gazette by eye.
  ///
  /// In en, this message translates to:
  /// **'checked {date}'**
  String checkPackChecked(String date);

  /// STATEMENT OF FACT. No imperative mood, no second person, no permission verb. The first-launch state of the recents strip. It states what this DEVICE has done, never what the reader should do.
  ///
  /// In en, this message translates to:
  /// **'Nothing checked here yet'**
  String get checkNoRecentsHeadline;

  /// What the strip will hold once it holds anything. It explains the mechanism rather than instructing: the fisher is not being asked to look anything up, he is being told what happens when he does.
  ///
  /// In en, this message translates to:
  /// **'Species you look up in this place appear here, so the next one is one tap.'**
  String get checkNoRecentsBody;

  /// The typed length on S3, before any rule is applied. Spelled out rather than abbreviated because check_measurement.sh bans a bare unit token — and the ban is right: this number carries no measurement method yet, so it is a quantity the fisher typed, not a stated measurement against an instrument.
  ///
  /// In en, this message translates to:
  /// **'{mm} millimetres'**
  String measureManualReading(String mm);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'ca', 'en', 'es', 'gl', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'gl':
      return AppLocalizationsGl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
