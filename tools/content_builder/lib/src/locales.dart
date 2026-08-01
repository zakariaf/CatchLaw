/// The locales CatchLaw ships, and the only list of them in this package.
///
/// **D-3 settles the set.** `catchlaw-content-pipeline` rule 4 and
/// `references/build-assertions.md` both list `ur`; Urdu appears nowhere in
/// `SPEC.md`, has no bundled instrument and no RTL lane of its own. Catalan
/// ships because Catalonia, Valencia and the Balearics publish their fishing
/// orders in Catalan — the test for a locale is that it is the **official
/// publication language of an instrument being bundled**, and `ca` passes it
/// while `ur` does not.
///
/// Declared once. Six copies of a locale list is how one of them keeps `ur`
/// after the correction lands.
library;

/// The six shipped locales, sorted.
///
/// Sorted so that a missing-locale failure message — `missing for ar, ca, es,
/// gl, pt_BR` — reads identically on every machine and in every run.
const List<String> kShippedLocales = <String>['ar', 'ca', 'en', 'es', 'gl', 'pt_BR'];

/// The five locales that mark grammatical gender on a name.
///
/// `en` is the only one that may omit it. "la mero" instead of "el mero" reads
/// as machine translation, and a document that reads machine-translated is not
/// believed when it states a prohibition.
const Set<String> kGenderedLocales = <String>{'ar', 'ca', 'es', 'gl', 'pt_BR'};
