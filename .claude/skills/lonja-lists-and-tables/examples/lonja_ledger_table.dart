// Demonstrates the CatchLaw ledger table: a Table with fixed column classes, an uppercase
// tracked header over a 1.5px ink rule, dotted hairlines between body rows and NO zebra
// fill, mono tabular figures end-aligned so they mirror in Arabic, semantic tone on a
// numeric cell only, the compact label/value pair table used for trip totals, and the
// horizontal-scroll escape for a ledger wider than the screen.
// Tokens are flattened to constants here; in the app tree they are ThemeExtension slots
// owned by `lonja-design-tokens`. Conceptually compiles against flutter.

import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class L {
  static const paper = Color(0xFFE6E4DC), ink = Color(0xFF16201C),
      inkMuted = Color(0xFF3D4A44), inkFaint = Color(0xFF6C7871),
      rule = Color(0xFFC2C5BB), oxblood = Color(0xFF7A2320);

  static const hairline = BorderSide(color: rule, width: 1);
  static const ledgerHead = BorderSide(color: ink, width: 1.5);

  static const head = TextStyle(
      fontFamily: 'sans-serif', fontSize: 9.5, letterSpacing: 1.33, // ≈ .14em at 9.5sp
      fontWeight: FontWeight.w600, color: inkFaint);
  static const prose = TextStyle(fontFamily: 'serif', fontSize: 14, color: inkMuted);
  static const numeric = TextStyle(
      fontFamily: 'monospace', fontSize: 14, color: ink,
      // EVERY figure column, in every locale and numbering system.
      fontFeatures: [FontFeature.tabularFigures()]);
}

@immutable
class Penalty {
  const Penalty(this.offence, this.fine, this.licence);
  final String offence, fine, licence;
}

const penalties = <Penalty>[
  Penalty('First offence', 'AED 3,000', 'Suspension for 6 months'),
  Penalty('Second offence', 'AED 5,000', 'Revocation'),
];

/// (key, value, isFailing) — tone is semantic, never emphasis.
const totals = <(String, String, bool)>[
  ('Trips', '12', false),
  ('Fish recorded', '132', false),
  ('Landed weight', '402 kg', false),
  ('Checks failing a rule', '9 · 6.8%', true),
  ('Bycatch notes', '3', false),
];

/// One cell for both roles. `numeric` decides the type role AND the alignment:
/// start for labels, end for figures — never TextAlign.left / .right.
class LedgerCell extends StatelessWidget {
  const LedgerCell(this.text, {this.numeric = false, this.head = false, this.tone, super.key});
  final String text;
  final bool numeric, head;
  final Color? tone;
  @override
  Widget build(BuildContext context) {
    final base = head ? L.head : (numeric ? L.numeric : L.prose);
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, head ? 8 : 11, 8, head ? 8 : 11),
      child: Text(
        head ? text.toUpperCase() : text,
        style: tone == null ? base : base.copyWith(color: tone, fontWeight: FontWeight.w600),
        textAlign: numeric ? TextAlign.end : TextAlign.start,
      ),
    );
  }
}

class LonjaLedgerTable extends StatelessWidget {
  const LonjaLedgerTable({super.key});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        // A ledger wider than the screen SCROLLS: no wrap, no shrink, no ellipsis.
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(34), // label
              1: FlexColumnWidth(33), // numeric
              2: FlexColumnWidth(33), // prose
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.top,
            children: [
              const TableRow(
                decoration: BoxDecoration(border: Border(bottom: L.ledgerHead)),
                children: [
                  LedgerCell('Offence', head: true),
                  LedgerCell('Fine', head: true, numeric: true),
                  LedgerCell('Licence', head: true, numeric: true),
                ],
              ),
              // No alternating fill anywhere: separation is a hairline, never a colour.
              for (final p in penalties)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: L.hairline)),
                  children: [
                    LedgerCell(p.offence),
                    LedgerCell(p.fine, numeric: true, tone: L.oxblood),
                    LedgerCell(p.licence, numeric: true),
                  ],
                ),
            ],
          ),
        ),
      );
}

/// The compact pair table: uppercase tracked key on the start edge, figure on the end.
class LonjaPairTable extends StatelessWidget {
  const LonjaPairTable({required this.rows, super.key});
  final List<(String, String, bool)> rows;
  @override
  Widget build(BuildContext context) => Table(
        columnWidths: const {0: FlexColumnWidth(44), 1: FlexColumnWidth(56)},
        children: [
          for (var i = 0; i < rows.length; i++)
            TableRow(
              decoration: BoxDecoration(
                border: Border(
                  // The group opens on a solid ink rule; every row closes on a hairline.
                  top: i == 0 ? const BorderSide(color: L.ink) : BorderSide.none,
                  bottom: L.hairline,
                ),
              ),
              children: [
                LedgerCell(rows[i].$1, head: true),
                LedgerCell(rows[i].$2, numeric: true, tone: rows[i].$3 ? L.oxblood : null),
              ],
            ),
        ],
      );
}

class PenaltiesSection extends StatelessWidget {
  const PenaltiesSection({super.key});
  @override
  Widget build(BuildContext context) => const ColoredBox(
        color: L.paper,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            LonjaLedgerTable(),
            SizedBox(height: 24),
            LonjaPairTable(rows: totals),
            SizedBox(height: 16),
            // The citation is a design feature, not fine print.
            Text(
              'Ministerial Decision 580/2015, Art. 3 · published 2015-11-03 · checked 2026-07-14',
              style: TextStyle(fontFamily: 'serif', fontSize: 12, color: L.inkMuted),
            ),
          ]),
        ),
      );
}
