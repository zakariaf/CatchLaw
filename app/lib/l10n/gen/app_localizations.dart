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

  /// S14's label for the language control. Its value differs per locale, which is what lets a test prove the ar bundle loaded rather than silently falling back to this template.
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
