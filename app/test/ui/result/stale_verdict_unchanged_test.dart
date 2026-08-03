import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/ui/result/view_models/result_context.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/view_models/verdict_presenter.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/models/result_fixtures.dart';

/// Invariant 5, as arithmetic rather than as a promise: the same resolution,
/// fresh and expired, must differ in the bar and in nothing else.
void main() {
  final en = VerdictPresenter(
    l10n: lookupAppLocalizations(const Locale('en')),
    content: kContentEn,
    locale: const Locale('en'),
  );
  const cambados = ResultContext(
    authorityKey: 'jurisdiction.es_ga.authority',
    packId: 'ES-GA v2026.08.0',
    packExpiredOn: '2026-06-30',
  );

  test('VerdictPresenter.present states the same sentence with the ruleset expired', () {
    final ResultDisplay fresh = en.present(kResolutionAmeixaBelowMinimum, cambados);
    final ResultDisplay stale = en.present(kResolutionAmeixaExpired, cambados);

    expect(stale.stamp!.headline, fresh.stamp!.headline);
    expect(stale.stamp!.subLine, fresh.stamp!.subLine);
    expect(stale.stamp!.category, fresh.stamp!.category);
  });

  test('VerdictPresenter.present keeps every rule-fact value with the ruleset expired', () {
    final ResultDisplay fresh = en.present(kResolutionAmeixaBelowMinimum, cambados);
    final ResultDisplay stale = en.present(kResolutionAmeixaExpired, cambados);

    // "With its numbers intact" means every number, not only the headline.
    expect(
      stale.findings.first.facts.map((RuleFact f) => f.value).toList(),
      fresh.findings.first.facts.map((RuleFact f) => f.value).toList(),
    );
  });

  test('VerdictPresenter.present keeps the citation with the ruleset expired', () {
    final ResultDisplay stale = en.present(kResolutionAmeixaExpired, cambados);

    expect(stale.stamp!.citation.instrument, isNotEmpty);
    expect(stale.stamp!.citation.checkedOn, '2026-08-12');
  });

  test('VerdictPresenter.present renders no absence state with the ruleset expired', () {
    final ResultDisplay stale = en.present(kResolutionAmeixaExpired, cambados);

    // The exact regression §7.3 records from the first draft: an expired pack
    // rendered as "no rule recorded" turns a stale rule into a permission.
    expect(stale.note, isNull);
    expect(stale.stamp, isNotNull);
  });

  test('VerdictPresenter.present names the pack and its date in the provenance', () {
    final ResultDisplay stale = en.present(kResolutionAmeixaExpired, cambados);

    expect(stale.stale!.provenance, contains('ES-GA v2026.08.0'));
    expect(stale.stale!.provenance, contains('2026-06-30'));
    expect(stale.stale!.sentence, contains('2026-06-30'));
  });

  test('VerdictPresenter.present raises no bar when the ruleset is current', () {
    expect(en.present(kResolutionAmeixaBelowMinimum, cambados).stale, isNull);
  });

  test('VerdictPresenter.present states the expiry without a date when the pack records none', () {
    const dateless = ResultContext(
      authorityKey: 'jurisdiction.es_ga.authority',
      packId: 'ES-GA v2026.08.0',
    );

    // Stating a day the pack never recorded would be the app inventing a fact
    // about an instrument.
    expect(en.present(kResolutionAmeixaExpired, dateless).stale!.sentence, isNot(contains('2026')));
  });
}
