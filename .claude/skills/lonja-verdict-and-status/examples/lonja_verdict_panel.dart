// Demonstrates the whole CatchLaw result surface in printed order: the non-blocking ochre stale bar,
// the engraved species plate, the stamp struck between double rules 48dp below it, the four verdict
// categories as glyph + word + a structural third, the citation set as a printed footnote, and the
// permanent non-dismissable disclaimer. Real Lonja values inlined; in the app the colours come from
// the LonjaColors ThemeExtension and every string from ARB via gen-l10n.

import 'package:flutter/material.dart';

const _paper = Color(0xFFE6E4DC), _paperSunk = Color(0xFFDEDBD1), _rule = Color(0xFFC2C5BB);
const _ink = Color(0xFF16201C), _inkMuted = Color(0xFF3D4A44), _inkFaint = Color(0xFF6C7871);
const _verdant = Color(0xFF2E5E3A), _oxblood = Color(0xFF7A2320), _ochre = Color(0xFF8A6A16),
    _ochreTint = Color(0xFFE8E0C6);
const _head = TextStyle(fontFamily: 'serif', fontSize: 26, height: 1.02, fontWeight: FontWeight.w700);
const _sub = TextStyle(fontFamily: 'serif', fontSize: 15.5, height: 1.35, color: _ink);
const _meta = TextStyle(fontFamily: 'sans', fontSize: 10.5, letterSpacing: 1.5);
const _note = TextStyle(fontFamily: 'serif', fontSize: 12, height: 1.5, color: _inkMuted);
const _small = TextStyle(fontFamily: 'sans', fontSize: 11.5, height: 1.45, color: _inkMuted);
const _fixed = TextStyle(fontFamily: 'mono', fontSize: 8.5, letterSpacing: 1.2, color: _inkFaint);

enum VerdictCategory { meets, belowMinimum, closedSeason, protected }
typedef Citation = ({String jurisdiction, String instrument, String article, String published, String checked});
/// Glyph, word, ink and the structural third ([measured]) as ONE value, so they cannot drift apart.
typedef VerdictSignals = ({IconData glyph, String headline, String meta, bool measured, Color ink});
const kSignals = <VerdictCategory, VerdictSignals>{
  VerdictCategory.meets: (glyph: Icons.check, headline: 'Meets the minimum',
      meta: 'Size rule satisfied · season open · within bag limit', measured: true, ink: _verdant),
  VerdictCategory.belowMinimum: (glyph: Icons.close, headline: 'Below the minimum',
      meta: 'Short by 7 cm · rule fails on size only', measured: true, ink: _oxblood),
  VerdictCategory.closedSeason: (glyph: Icons.event_busy, meta: 'Closure · not a size rule',
      headline: 'Closed season — 1 March to 30 April', measured: false, ink: _ochre),
  VerdictCategory.protected: (glyph: Icons.block, headline: 'Protected species — taking prohibited',
      meta: 'Protection · no size or season applies', measured: false,
      ink: _oxblood), // same ink as belowMinimum: the mark and the words carry the distinction
};

class LonjaVerdictPanel extends StatelessWidget {
  const LonjaVerdictPanel({required this.category, required this.citation, required this.plate,
      required this.table, this.subLine, this.expiredOn, super.key});
  final VerdictCategory category; // handed down by the engine, never re-derived from a measurement
  final Citation citation; // required and non-null: never `Citation?`, never `?? Citation.unknown()`
  final Widget plate, table;
  final String? subLine, expiredOn; // '38 cm measured · minimum 45 cm …' / '2026-06-30'
  @override
  Widget build(BuildContext context) {
    final signals = kSignals[category]!;
    return ColoredBox(color: _paper, child: ListView(padding: EdgeInsets.zero, children: [
      if (expiredOn != null) StaleRuleBar(expiredOn: expiredOn!), // states, never gates
      plate, // identification before judgement
      _VerdictStamp(signals: signals, subLine: signals.measured ? subLine : null),
      Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 0), child: table),
      CitationFootnote(citation: citation), // LAST printed block, never behind a tap
      const LonjaDisclaimer(), // no if, no Visibility, no dismiss callback
    ]));
  }
}

class EngravedPlate extends StatelessWidget { // frame + caption; the engraving is a CustomPainter
  const EngravedPlate({required this.engraving, required this.vernacular, required this.latin, super.key});
  final Widget engraving;
  final String vernacular, latin; // 'هامور Hamour · Orange-spotted grouper' / 'Epinephelus coioides'
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DecoratedBox(decoration: BoxDecoration(color: _paperSunk, border: Border.all(color: _ink)),
            child: SizedBox(height: 132, width: double.infinity, child: engraving)),
        Padding(padding: const EdgeInsets.only(top: 8), child: Text(vernacular,
            style: const TextStyle(fontFamily: 'serif', fontSize: 15, color: _ink))),
        Text(latin, style: _note), // the scientific name is never set in a semantic ink
      ]));
}

class _VerdictStamp extends StatelessWidget {
  const _VerdictStamp({required this.signals, this.subLine});
  final VerdictSignals signals;
  final String? subLine;
  @override
  Widget build(BuildContext context) => MergeSemantics(
      child: Semantics(header: true, // ONE node: category word first, then number, then unit
          label: [signals.headline, if (subLine != null) subLine!].join('. '),
          child: Padding(padding: const EdgeInsets.fromLTRB(16, 48, 16, 0), // 48dp plate to stamp
              child: Transform.rotate(angle: -0.0096, // -0.55 deg; the press is never quite square
                  child: DefaultTextStyle.merge(style: TextStyle(color: signals.ink), // currentColor
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const _DoubleRule(),
                        Padding(padding: const EdgeInsets.only(top: 16), child: Row(children: [
                          ExcludeSemantics(child: Icon(signals.glyph, size: 30, color: signals.ink)),
                          const SizedBox(width: 11),
                          Expanded(child: Text(signals.headline.toUpperCase(), style: _head)),
                        ])),
                        if (subLine != null) // absent for .closedSeason and .protected
                          Padding(padding: const EdgeInsets.only(top: 8), child: Text(subLine!, style: _sub)),
                        Padding(padding: const EdgeInsets.fromLTRB(0, 7, 0, 10),
                            child: Text(signals.meta.toUpperCase(), style: _meta)),
                        const _DoubleRule(),
                      ]))))));
}

class _DoubleRule extends StatelessWidget { // 1dp + 1.5dp gap + 1dp, in the inherited colour
  const _DoubleRule();
  @override
  Widget build(BuildContext context) {
    final r = Container(height: 1, color: DefaultTextStyle.of(context).style.color ?? _ink);
    return Column(children: [r, const SizedBox(height: 1.5), r]);
  }
}

class StaleRuleBar extends StatelessWidget {
  const StaleRuleBar({required this.expiredOn, super.key});
  final String expiredOn;
  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(color: _ochreTint,
          border: Border.symmetric(horizontal: BorderSide(color: _ochre))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.warning_amber, size: 17, color: _ochre), const SizedBox(width: 9),
        Expanded(child: Text('Rule data expired $expiredOn — still shown, verify before relying '
            'on it.', style: _small)),
      ]));
}

class CitationFootnote extends StatelessWidget {
  const CitationFootnote({required this.citation, super.key});
  final Citation citation;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FractionallySizedBox(widthFactor: 0.44, alignment: AlignmentDirectional.centerStart,
            child: Container(height: 1, color: _ink.withValues(alpha: 0.85))), // the footnote rule
        Padding(padding: const EdgeInsets.only(top: 9), child: Text(
            '¹ ${citation.jurisdiction} — ${citation.instrument}, ${citation.article} · '
            'published ${citation.published} · checked ${citation.checked}.', style: _note)),
      ]));
}

class LonjaDisclaimer extends StatelessWidget {
  const LonjaDisclaimer({super.key});
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: const BoxDecoration(color: _paperSunk,
          border: Border(top: BorderSide(color: _ink, width: 2), bottom: BorderSide(color: _rule))),
      child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.info_outline, size: 15, color: _inkMuted), SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Reference only — not legal advice. Verify with the Ministry of Climate Change '
              'and Environment.', style: _small),
          SizedBox(height: 5), // the line below is contractual: it makes absence legible
          Text('SHOWN ON EVERY RESULT · CANNOT BE DISMISSED', style: _fixed),
        ])),
      ]));
}

// Worked call site — Hamour, 38 cm, Ras Al Khaimah, on an expired RAK-GULF pack: category
//   .belowMinimum, expiredOn '2026-06-30', subLine '38 cm measured · minimum 45 cm · total length',
//   citation (jurisdiction 'United Arab Emirates', instrument 'Ministerial Decision 580/2015',
//   article 'Art. 3', published '2015-11-03', checked '2026-07-14').
