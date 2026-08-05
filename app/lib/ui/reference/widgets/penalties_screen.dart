import 'package:catchlaw/domain/models/penalty_schedule.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/locale_codec.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/format/bidi_isolate.dart';
import 'package:catchlaw/ui/core/format/penalty_amount_format.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_panel.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/reference/view_models/penalties_view_model.dart';
import 'package:catchlaw/ui/reference/widgets/penalties_ledger.dart';
import 'package:catchlaw/ui/result/widgets/result_disclaimer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart' show Citation;

/// S20 — what a breach of the recorded rules carries, in one jurisdiction.
///
/// **The back cover of the booklet, not a verdict.** Nothing on this page is
/// evaluated against a fish, a length or a date: it is the printed schedule,
/// read the way the ruler on the back cover is read. That is why it hangs off
/// the Reference branch and not off Check.
///
/// **Every figure on it came out of the pack, and an empty pack says so.** No
/// jurisdiction shipped today carries a transcribed `penalty` row, so the
/// screen a fisher reaches right now is the empty state — which is the correct
/// screen. A fine invented to fill a table is the worst sentence this product
/// could print, and a plausible one is worse than an obvious one.
class PenaltiesScreen extends ConsumerWidget {
  /// Opens the schedule [jurisdictionCode] publishes.
  const PenaltiesScreen({required this.jurisdictionCode, super.key});

  /// The ledger's own scroll view, for tests that drive it.
  static const Key scrollKey = Key('penalties-scroll');

  /// `ES-GA`, `AE-RK`. A code and never a row id: `reference.db` is replaced
  /// wholesale and the ids do not survive the replacement.
  final String jurisdictionCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final Locale locale = Localizations.localeOf(context);
    final AsyncValue<PenaltySchedule> schedule = ref.watch(
      penaltyScheduleProvider((
        jurisdictionCode: jurisdictionCode,
        locale: encodeLocale(locale) ?? 'en',
      )),
    );

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.penaltiesTitle,
        // Which jurisdiction's schedule this is. A page of amounts with no
        // place stamped on it is a page of amounts for somewhere else.
        sup: jurisdictionCode,
        onBack: navigator.canPop() ? navigator.pop : null,
      ),
      body: SafeArea(
        // The bar has already taken the status bar; taking it twice prints the
        // lede a band lower than the rule it opens under.
        top: false,
        child: schedule.when(
          loading: () => const LonjaListSkeleton(rows: 3),
          // The raw failure and NOT the empty state. "Nothing was transcribed"
          // is a claim about the law, and making it when the device could not
          // read the file is the app inventing the absence of a penalty —
          // which is the same defect as inventing one.
          error: (Object error, StackTrace _) => Padding(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Text('$error', textAlign: TextAlign.start),
          ),
          data: (PenaltySchedule value) => _PenaltiesSheet(schedule: value, locale: locale),
        ),
      ),
    );
  }
}

/// The page itself, once the pack has answered.
class _PenaltiesSheet extends StatelessWidget {
  const _PenaltiesSheet({required this.schedule, required this.locale});

  final PenaltySchedule schedule;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    // Constructed at the point of use and never retained: a `NumberFormat`
    // held in a field captures its symbols at construction and survives every
    // later `applyNumeralSystem` call, so a fisher who switches the numeral
    // lever would see the ledger keep the digits it was built with.
    String fineOf(PenaltyTier tier) => formatPenaltyAmount(
      amountMin: tier.amountMin,
      amountMax: tier.amountMax,
      currency: tier.currency,
      numbers: numberFormatFor(locale),
      patterns: (
        amount: l10n.penaltiesFineAmount,
        range: l10n.penaltiesFineRange,
        notRecorded: l10n.penaltiesFineNotRecorded,
      ),
    );

    final List<PenaltyTier> tiers = schedule.tiers;

    // A scrolling COLUMN and not a lazy list: this page is a fixed handful of
    // blocks and a schedule of a few printed lines, not a list that grows. The
    // one thing that repeats is bounded by what a jurisdiction transcribes,
    // and `check_lonja_lists.sh` fails an eager list constructor because a
    // LIST is the thing that grows.
    return SingleChildScrollView(
      key: PenaltiesScreen.scrollKey,
      padding: EdgeInsetsDirectional.all(tokens.density.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.penaltiesLede(schedule.jurisdictionName),
            style: type.legal.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: LonjaSpace.s5),
          if (tiers.isEmpty)
            // The state every shipped pack is in today, and it is authored
            // rather than blank: a blank frame is indistinguishable from a
            // crash, and on this screen it would read as a jurisdiction with
            // nothing to lose.
            LonjaEmptyState(
              headline: l10n.penaltiesNoneRecordedHeadline,
              body: l10n.penaltiesNoneRecordedBody(schedule.jurisdictionName),
              primary: const SizedBox.shrink(),
            )
          else ...<Widget>[
            PenaltiesLedger(tiers: tiers, fineOf: fineOf),
            const SizedBox(height: LonjaSpace.s6),
            LonjaSectionLabel(
              // Cased at the call site, never authored upper: the transform is
              // a silent no-op on Arabic, and the label's hierarchy comes from
              // the tracked step and the rule running to the margin.
              text: l10n.penaltiesOffenceListLabel.toUpperCase(), // lonja-type: ok
            ),
            const SizedBox(height: LonjaSpace.s3),
            PenaltiesOffenceList(offences: schedule.offencesCited),
            const SizedBox(height: LonjaSpace.s5),
            _WorkedExample(
              tier: tiers.first,
              jurisdiction: schedule.jurisdictionName,
              fine: fineOf,
            ),
          ],
          const SizedBox(height: LonjaSpace.s6),
          _CitationNotes(schedule: schedule),
          const SizedBox(height: LonjaSpace.s6),
          // The standing notice, and the same one the verdict surface carries.
          // Structural, unconditional and with no way to put it away: a
          // disclaimer the reader can dismiss is, in the record of what he was
          // shown, one that was never shown.
          ResultDisclaimer(authority: schedule.authority),
        ],
      ),
    );
  }
}

/// The first line of the ledger, restated as one sentence.
///
/// **Composed only of values the pack carries.** The mockup's example names a
/// fish, a length and a market price; §7.1's `penalty` row carries none of the
/// three, and writing them would be inventing the case the sentence is about.
/// What it does instead is make the figure in the table read as a fact about an
/// occurrence rather than as a number in a grid — which is the whole reason the
/// panel is on the page.
class _WorkedExample extends StatelessWidget {
  const _WorkedExample({required this.tier, required this.jurisdiction, required this.fine});

  final PenaltyTier tier;
  final String jurisdiction;
  final String Function(PenaltyTier tier) fine;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final String amount = fine(tier);

    final String sentence = switch (tier.occurrence) {
      1 => l10n.penaltiesWorkedExampleFirst(tier.offence, jurisdiction, amount),
      2 => l10n.penaltiesWorkedExampleSecond(tier.offence, jurisdiction, amount),
      _ => l10n.penaltiesWorkedExampleSubsequent(tier.offence, jurisdiction, amount),
    };
    final String? consequence = tier.consequence;

    return LonjaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.penaltiesWorkedExampleLabel.toUpperCase(), // lonja-type: ok
            style: type.microLabel.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: LonjaSpace.s1),
          Text(
            sentence,
            style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
          if (consequence != null) ...<Widget>[
            const SizedBox(height: LonjaSpace.s1),
            Text(
              l10n.penaltiesWorkedExampleConsequence(consequence),
              style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }
}

/// The apparatus: which instruments these amounts came from, and what the
/// schedule does not exhaust.
///
/// **Printed, and not a control.** The result surface's footnote is also a
/// button onto the verbatim article; this one is not, because there is nothing
/// on the other side of the tap for a penalty row — and a tappable block that
/// does nothing is worse than a printed one.
class _CitationNotes extends StatelessWidget {
  const _CitationNotes({required this.schedule});

  final PenaltySchedule schedule;

  /// The short rule that opens the apparatus block.
  static const Key ruleKey = Key('penalties-footnote-rule');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    // One footnote per distinct instrument. Two rows quoting one order gave two
    // identical footnotes, which reads as two documents consulted rather than
    // one schedule resting on one article.
    final instruments = <String, Citation>{};
    for (final PenaltyTier tier in schedule.tiers) {
      instruments.putIfAbsent(
        '${tier.citation.instrument}|${tier.citation.article}',
        () => tier.citation,
      );
    }

    var marker = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Struck in ink rather than in the hairline slot: a footnote rule that
        // cannot be seen on a wet screen in sunlight is a page with no seam
        // between the schedule and the apparatus under it.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: 0.44,
            child: SizedBox(
              key: ruleKey,
              height: LonjaRules.rule,
              child: ColoredBox(color: tokens.onSurface),
            ),
          ),
        ),
        const SizedBox(height: LonjaSpace.s2),
        for (final Citation citation in instruments.values) ...<Widget>[
          _Footnote(
            marker: ++marker,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  schedule.jurisdictionName,
                  style: type.eyebrow.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
                Text(
                  isolateLtr('${citation.instrument}, ${citation.article}'),
                  style: type.citation.copyWith(color: tokens.onSurface),
                  textAlign: TextAlign.start,
                ),
                Text(
                  // ISO, unlocalised, Western digits in every locale: the same
                  // string in six languages, comparable by eye against the
                  // printed instrument.
                  l10n.penaltiesCitationDates(citation.publishedOn, citation.checkedOn),
                  style: type.citation.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          const SizedBox(height: LonjaSpace.s2),
        ],
        // The caveat is a footnote of its own and is printed whether or not the
        // pack carries a single row: it says what kind of thing the schedule is,
        // and that is true of an empty one.
        _Footnote(
          marker: ++marker,
          child: Text(
            l10n.penaltiesPackCaveat,
            style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}

/// A numbered note.
class _Footnote extends StatelessWidget {
  const _Footnote({required this.marker, required this.child});

  final int marker;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: LonjaSpace.s1),
          child: Text(
            '$marker',
            style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
