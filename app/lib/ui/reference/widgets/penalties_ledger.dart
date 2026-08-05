import 'dart:math' as math;

import 'package:catchlaw/domain/models/penalty_schedule.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/format/bidi_isolate.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:flutter/material.dart';
import 'package:rule_engine/rule_engine.dart' show Citation;

/// How the three columns of the ledger divide the measure.
///
/// 34 against 33 and 33, the mockup's own proportion: the offence column is
/// wide enough that *Second offence* sets on one line, and the figure keeps the
/// outer margin.
const int _offenceFlex = 34;
const int _fineFlex = 33;
const int _licenceFlex = 33;

/// The narrowest the three-column ledger is ever set, before text scale.
///
/// Below this the fine and the licence consequence would each be three words
/// deep and the table would stop being readable as columns. The sheet scrolls
/// sideways instead of wrapping, which is what a printed schedule too wide for
/// the page does.
const double _minLedgerWidth = LonjaSpace.s8 * 8;

/// The penalty schedule, as a ruled three-column sheet.
///
/// **A `Column` and not a `DataTable`.** The Material table brings physical,
/// non-directional padding, a fixed line height that breaks at 200% text scale
/// and a scroll behaviour of its own; `lonja-lists-and-tables` bans it for
/// exactly that. The rows are a printed schedule of a handful of lines and not
/// a list that grows, which is why they are built eagerly — the same call the
/// species account makes about its blocks.
///
/// Every figure on this sheet came out of the pack. Nothing is computed, summed
/// or converted, and a row the pack left blank says so in words.
class PenaltiesLedger extends StatelessWidget {
  /// Sets [tiers] as the ledger.
  const PenaltiesLedger({required this.tiers, required this.fineOf, super.key});

  /// The recorded tiers, in ledger order.
  final List<PenaltyTier> tiers;

  /// The already-localised, already-formatted fine for one tier.
  ///
  /// Passed in rather than formatted here, because the figure needs the
  /// locale's `NumberFormat` and the numeral lever, and a table that reached
  /// for both would be untestable without a container.
  final String Function(PenaltyTier tier) fineOf;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    // The one place the sheet's own width is decided. Scaled with the reader's
    // text setting rather than clamped against it: at 200% the columns need
    // twice the room, and the honest answer is a wider sheet that scrolls, not
    // smaller type.
    final double floor = MediaQuery.textScalerOf(context).scale(_minLedgerWidth);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: math.max(constraints.maxWidth, floor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _LedgerHead(
                // Cased here and never in the ARB: the same three words are
                // sentence-case labels elsewhere, and the ARB holds one wording
                // per key. On Arabic the transform is a no-op, which is why the
                // column heads also carry the tracked micro step and the rule
                // under them.
                offence: l10n.penaltiesColumnOffence.toUpperCase(), // lonja-type: ok
                fine: l10n.penaltiesColumnFine.toUpperCase(), // lonja-type: ok
                licence: l10n.penaltiesColumnLicence.toUpperCase(), // lonja-type: ok
              ),
              // A 2 pt rule under the heads and hairlines between the entries:
              // one uniform weight made the first entry read as a fourth
              // column head.
              const LonjaRule.section(),
              for (final PenaltyTier tier in tiers) ...<Widget>[
                _LedgerLine(tier: tier, fine: fineOf(tier)),
                const LonjaRule.row(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The three column heads.
class _LedgerHead extends StatelessWidget {
  const _LedgerHead({required this.offence, required this.fine, required this.licence});

  final String offence;
  final String fine;
  final String licence;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final TextStyle style = type.microLabel.copyWith(color: tokens.onSurfaceMuted);

    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: LonjaSpace.s2, top: LonjaSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: _offenceFlex,
            child: Text(offence, style: style, textAlign: TextAlign.start),
          ),
          const SizedBox(width: LonjaSpace.s2),
          Expanded(
            flex: _fineFlex,
            child: Text(fine, style: style, textAlign: TextAlign.start),
          ),
          const SizedBox(width: LonjaSpace.s2),
          Expanded(
            flex: _licenceFlex,
            child: Text(licence, style: style, textAlign: TextAlign.start),
          ),
        ],
      ),
    );
  }
}

/// One recorded tier: which breach, what it costs, and what it does to a licence.
class _LedgerLine extends StatelessWidget {
  const _LedgerLine({required this.tier, required this.fine});

  final PenaltyTier tier;
  final String fine;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: _offenceFlex,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  tier.offence,
                  style: type.microLabel.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
                Text(
                  occurrenceLabel(l10n, tier.occurrence),
                  style: type.legal,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          const SizedBox(width: LonjaSpace.s2),
          Expanded(
            flex: _fineFlex,
            child: Text(
              fine,
              // Oxblood and mono, with the word *First offence* beside it and
              // the FINE head above it carrying the same information: three
              // signals, so the cell survives greyscale, glare and a reader who
              // sees no red at all (invariant 4).
              style: type.datum.copyWith(color: tokens.verdictFail, fontWeight: FontWeight.w600),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: LonjaSpace.s2),
          Expanded(
            flex: _licenceFlex,
            child: Text(
              tier.consequence ?? l10n.penaltiesConsequenceNotRecorded,
              style: type.legal.copyWith(
                color: tier.consequence == null ? tokens.onSurfaceMuted : tokens.onSurface,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

/// What the instrument calls this rung of its own scale.
///
/// Three labels and not an ordinal per row: instruments stop counting after the
/// second, and a generated *fourth offence* would be a distinction this app
/// invented.
String occurrenceLabel(AppLocalizations l10n, int occurrence) => switch (occurrence) {
  1 => l10n.penaltiesOccurrenceFirst,
  2 => l10n.penaltiesOccurrenceSecond,
  _ => l10n.penaltiesOccurrenceSubsequent,
};

/// What the pack records a penalty against, and the instrument that records it.
///
/// The second half of the answer, and the reason it is a table rather than a
/// list of words: naming an offence is a claim about the law, and invariant 3
/// does not stop applying because the claim is short.
class PenaltiesOffenceList extends StatelessWidget {
  /// Lists [offences], each with its instrument.
  const PenaltiesOffenceList({required this.offences, super.key});

  /// Distinct offences, in ledger order.
  final List<({String offence, Citation citation})> offences;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      // The sheet opens on the heavier rule, the way the mockup closes the
      // first row against the eyebrow above it.
      const LonjaRule.block(),
      for (final ({String offence, Citation citation}) entry in offences) ...<Widget>[
        _OffenceLine(offence: entry.offence, citation: entry.citation),
        const LonjaRule.row(),
      ],
    ],
  );
}

/// One offence, and the instrument it is recorded in.
class _OffenceLine extends StatelessWidget {
  const _OffenceLine({required this.offence, required this.citation});

  final String offence;
  final Citation citation;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: LonjaSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 44,
            child: Text(
              offence,
              style: type.microLabel.copyWith(color: tokens.onSurfaceMuted),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(width: LonjaSpace.s2),
          Expanded(
            flex: 56,
            child: Text(
              // Latin script that is never translated, isolated so an Arabic
              // line cannot put the article number at the wrong end of the run
              // the reader is checking against a printed page.
              isolateLtr('${citation.instrument}, ${citation.article}'),
              style: type.citation.copyWith(color: tokens.onSurface),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
