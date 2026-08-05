import 'package:catchlaw/domain/models/content_strings.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/view_models/verdict_presenter.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:rule_engine/rule_engine.dart';

import '../../../testing/models/result_fixtures.dart';

VerdictPresenter _presenterFor(Locale locale, ContentStrings content) =>
    VerdictPresenter(l10n: lookupAppLocalizations(locale), content: content, locale: locale);

void main() {
  late VerdictPresenter en;

  setUp(() {
    en = _presenterFor(const Locale('en'), kContentEn);
  });

  group('VerdictPresenter', () {
    test('.present states the shortfall with both numbers and the method', () {
      final ResultDisplay display = en.present(kResolutionHamourBelowMinimum, kContextRasAlKhaimah);

      // Three registers, and every fact the one sentence used to carry is still
      // on the stamp: the state, then both numbers with the method beside them.
      expect(display.stamp!.headline, 'Below the minimum');
      expect(display.stamp!.detail, '38 cm measured · minimum 45 cm · Total length');
      expect(display.stamp!.meta, 'Short of the minimum by 7 cm');
      // The whole sentence survives on the finding the table and the screen
      // reader read from — the split is a change to the STAMP, not to the law.
      expect(
        display.findings.first.sentence,
        'Below the minimum — 38 cm measured, minimum 45 cm (Total length)',
      );
    });

    test('.present keeps the numbers off the stamp headline', () {
      final ResultDisplay display = en.present(kResolutionHamourBelowMinimum, kContextRasAlKhaimah);

      // A headline carrying two numbers and a method cannot be set at a size
      // that reads at arm's length; it wrapped to four lines and pushed the
      // facts table off the screen.
      expect(display.stamp!.headline, isNot(contains('38')));
      expect(display.stamp!.headline, isNot(contains('45')));
      expect(display.stamp!.headline, isNot(contains('Total length')));
    });

    test('.present names the method for a fork-length rule', () {
      final ResultDisplay display = en.present(kResolutionKanaadMeetsMinimum, kContextRasAlKhaimah);

      expect(display.stamp!.detail, contains('Fork length'));
      expect(display.stamp!.detail, isNot(contains('Total length')));
    });

    test('.present keeps the instrument unit with a millimetre rule', () {
      final ResultDisplay display = en.present(kResolutionAmeixaBelowMinimum, kContextCambados);

      expect(display.stamp!.detail, contains('34 mm measured · minimum 38 mm'));
      expect(display.stamp!.detail, contains('Shell length'));
    });

    test('.present echoes the measured value unchanged', () {
      final ResultDisplay display = en.present(kResolutionHamourMeasured386, kContextRasAlKhaimah);

      expect(display.stamp!.detail, contains('38.6 cm'));
      expect(display.stamp!.detail, isNot(contains('39 cm')));
    });

    test('.present states the maximum for a maxSize failure', () {
      final ResultDisplay display = en.present(kResolutionAboveMaximum, kContextRasAlKhaimah);

      expect(display.stamp!.headline, 'Above the maximum');
      expect(display.stamp!.kind, FindingKind.maxSize);
      expect(display.stamp!.category, VerdictCategory.belowMinimum);
    });

    test('.present prints no measurement sub-line when the category is protected', () {
      final ResultDisplay display = en.present(kResolutionSawfishProtected, kContextRasAlKhaimah);

      expect(display.stamp!.category, VerdictCategory.protected);
      expect(display.stamp!.detail, isNull);
      expect(display.stamp!.meta, isNull);
    });

    test('.present prints no measurement sub-line when the category is closedSeason', () {
      final ResultDisplay display = en.present(kResolutionShariClosedSeason, kContextRasAlKhaimah);

      expect(display.stamp!.category, VerdictCategory.closedSeason);
      expect(display.stamp!.meta, isNull);
      // The closure keeps its OWN figures — which day of the window today is —
      // and drops only the measurement margin.
      expect(display.stamp!.detail, contains('day 14 of 61'));
    });

    test('.present headlines the protected finding when a size rule also fails', () {
      final ResultDisplay display = en.present(kResolutionProtectedAndShort, kContextRasAlKhaimah);

      expect(display.stamp!.kind, FindingKind.protected);
      expect(
        display.findings.skip(1).map((FindingDisplay f) => f.kind),
        contains(FindingKind.minSize),
      );
    });

    test('.present keeps the engine ranked order', () {
      final ResultDisplay display = en.present(kResolutionShariClosedSeason, kContextRasAlKhaimah);

      expect(display.findings.map((FindingDisplay f) => f.kind).toList(), <FindingKind>[
        FindingKind.closedSeason,
        FindingKind.minSize,
        FindingKind.bagLimit,
      ]);
    });

    test('.present emits both sentences of the no-rule wording', () {
      final ResultDisplay display = en.present(kResolutionNoRuleFound, kContextRasAlKhaimah);

      expect(display.note!.sentence, contains('This does not mean it is legal.'));
      expect(display.note!.citations.single.instrument, 'Ministerial Decision 580/2015');
      expect(display.stamp, isNull);
    });

    test('.present distinguishes a silent instrument from an absent rule', () {
      final ResultDisplay silent = en.present(kResolutionNoLimitInInstrument, kContextRasAlKhaimah);
      final ResultDisplay absent = en.present(kResolutionNoRuleFound, kContextRasAlKhaimah);

      expect(silent.note!.kind, NoteKind.noLimitInInstrument);
      expect(absent.note!.kind, NoteKind.noRuleRecorded);
      expect(silent.note!.sentence, isNot(absent.note!.sentence));
      expect(silent.note!.citations, isNotEmpty);
      expect(silent.stamp, isNull);
    });

    test('.present emits no stamp for an ambiguous resolution', () {
      final ResultDisplay display = en.present(kResolutionAmbiguousBank, kContextCambados);

      expect(display.stamp, isNull);
      expect(display.ambiguity!.rules.length, 2);
      expect(
        display.ambiguity!.rules.map((AmbiguousRuleDisplay r) => r.facts.first.value).toList(),
        <String>['38 mm (Shell length)', '40 mm (Shell length)'],
      );
    });

    test('.present carries isExpired without altering the finding text', () {
      final ResultDisplay fresh = en.present(kResolutionAmeixaBelowMinimum, kContextCambados);
      final ResultDisplay stale = en.present(kResolutionAmeixaExpired, kContextCambados);

      expect(stale.stamp!.headline, fresh.stamp!.headline);
      expect(stale.stale, isNotNull);
      expect(fresh.stale, isNull);
    });

    test('.present marks a size finding indeterminate when the reading is null', () {
      final ResultDisplay display = en.present(kResolutionHamourUnmeasured, kContextRasAlKhaimah);

      expect(display.findings.single.outcome, FindingOutcome.indeterminate);
      expect(display.stamp, isNull);
      expect(display.note!.kind, NoteKind.openQuestion);
      expect(display.note!.sentence, 'Not measured — the minimum is 45 cm (Total length)');
    });

    test('.present reports a method mismatch without comparing the numbers', () {
      final ResultDisplay display = en.present(kResolutionMethodMismatch, kContextRasAlKhaimah);

      expect(display.findings.single.outcome, FindingOutcome.indeterminate);
      expect(display.note!.sentence, contains('No comparison is made.'));
      expect(display.note!.sentence, isNot(contains('Below the minimum')));
      expect(display.note!.sentence, isNot(contains('Meets the minimum')));
    });

    test('.present builds a citation display with all four fields', () {
      final ResultDisplay display = en.present(kResolutionHamourBelowMinimum, kContextRasAlKhaimah);
      final CitationDisplay citation = display.stamp!.citation;

      expect(citation.instrument, 'Ministerial Decision 580/2015');
      expect(citation.article, 'Art. 3');
      expect(citation.publishedOn, '2015-11-03');
      expect(citation.checkedOn, '2026-07-14');
    });

    test('.present prints the closed-season dates as day and month', () {
      final ResultDisplay display = en.present(kResolutionShariClosedSeason, kContextRasAlKhaimah);

      expect(display.stamp!.headline, contains('1 March'));
      expect(display.stamp!.headline, contains('30 April'));
      expect(display.stamp!.headline, isNot(contains('2026-03-01')));
      expect(display.stamp!.headline, 'Closed season — 1 March to 30 April');
    });

    test('.present resolves the method name through content_string', () {
      final ResultDisplay display = _presenterFor(
        const Locale('en'),
        const ContentStrings(<String, String>{
          'measurement.tl.name': 'Longitud total',
          'jurisdiction.ae_rak.authority': 'Ministry of Climate Change and Environment',
        }),
      ).present(kResolutionHamourBelowMinimum, kContextRasAlKhaimah);

      expect(display.stamp!.detail, contains('Longitud total'));
    });

    test('.present names the authority from the active jurisdiction', () {
      final ResultDisplay display = en.present(kResolutionAmeixaBelowMinimum, kContextCambados);

      expect(display.disclaimer, contains('Xunta de Galicia — Department of the Sea'));
      expect(display.disclaimer, contains('not legal advice'));
    });

    test('ar - .present builds the below-minimum sentence in the indicative', () {
      final String headline = _presenterFor(
        const Locale('ar'),
        kContentAr,
      ).present(kResolutionHamourBelowMinimum, kContextRasAlKhaimah).stamp!.headline;

      expect(headline, 'أقل من الحد الأدنى');
      for (final banned in const <String>['احتفظ', 'أعِدْه', 'يمكنك']) {
        expect(headline.contains(banned), isFalse, reason: 'imperative in an ar verdict');
      }
    });
  });
}
