// Demonstrates the CatchLaw species row and the states around it: one whole-row tap target,
// the fixed slot order (silhouette, local name, italic binomial, rule line, mono end slot), a
// dotted hairline the row draws itself instead of a card gap, a confirmed and undoable swipe,
// an authored empty state, and the ochre stale bar riding above data. Tokens are flattened
// here; in the app tree they are ThemeExtension slots owned by `lonja-design-tokens`.
// Conceptually compiles against flutter.

import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

class L {
  static const paper = Color(0xFFE6E4DC), ink = Color(0xFF16201C),
      inkMuted = Color(0xFF3D4A44), inkFaint = Color(0xFF6C7871),
      rule = Color(0xFFC2C5BB), ochre = Color(0xFF8A6A16),
      ochreTint = Color(0xFFE8E0C6), oxblood = Color(0xFF7A2320);
  static const rowMinHeight = 64.0; // 76.0 under glove mode — same slots, taller box.
  static const hairline = BorderSide(color: rule, width: 1); // between sibling rows
  static const groupOpen = BorderSide(color: ink, width: 1); // above a row group
  static const name = TextStyle(fontFamily: 'serif', fontSize: 16, height: 1.25, color: ink);
  static const binomial =
      TextStyle(fontFamily: 'serif', fontSize: 12.5, fontStyle: FontStyle.italic, color: inkFaint);
  static const detail = TextStyle(fontFamily: 'sans-serif', fontSize: 11.5, color: inkMuted);
  static const mono = TextStyle(fontFamily: 'monospace', fontSize: 12, color: inkMuted, fontFeatures: [FontFeature.tabularFigures()]);
  static const headline = TextStyle(fontFamily: 'serif', fontSize: 21, color: ink);
  static const body = TextStyle(fontFamily: 'serif', fontSize: 15, height: 1.5, color: inkMuted);
}

/// Slot order; a real entry: ('hamour', 'هامور Hamour', 'Epinephelus coioides', 'min 45 cm total length', '2 of 5 remaining').
@immutable
class SpeciesSummary {
  const SpeciesSummary(this.id, this.localName, this.binomial, this.ruleLine, this.endSlot);
  final String id, localName, binomial, ruleLine, endSlot;
}

/// Confirmation surfaces are owned by `lonja-dialogs-and-surfaces`; stubbed here.
Future<bool> showLonjaConfirm(BuildContext c, {required String headline}) async =>
    await showDialog<bool>(context: c, builder: (_) => const SizedBox.shrink()) ?? false;

/// The whole rect is the tap target; a chevron would be inert decoration inside it.
class LonjaSpeciesRow extends StatelessWidget {
  const LonjaSpeciesRow({required this.species, required this.onTap, super.key});
  final SpeciesSummary species;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: L.rowMinHeight),
          padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
          decoration: const BoxDecoration(border: BorderDirectional(bottom: L.hairline)),
          child: Row(children: [
            const SizedBox(width: 52, height: 30, child: ColoredBox(color: L.rule)), // plate art
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(species.localName, style: L.name),
                      Text(species.binomial, style: L.binomial),
                      Text(species.ruleLine, style: L.detail)
                    ])),
            const SizedBox(width: 12),
            // .end not .right — .right is the START edge in Arabic.
            Text(species.endSlot, textAlign: TextAlign.end, style: L.mono)
          ]),
        ),
      );
}

/// Every dismiss is confirmed, soft and undoable — this device holds the only copy.
class LonjaDismissibleRow extends StatelessWidget {
  const LonjaDismissibleRow({required this.species, required this.onRemove, super.key});
  final SpeciesSummary species;
  final Future<void> Function() onRemove;
  @override
  Widget build(BuildContext context) => Dismissible(
        key: ValueKey(species.id),
        direction: DismissDirection.endToStart, // mirrors under Directionality
        background: const ColoredBox(color: L.oxblood), // + glyph and the WORD in app
        confirmDismiss: (_) =>
            showLonjaConfirm(context, headline: 'Remove this check from the trip?'),
        onDismissed: (_) async {
          await onRemove(); // soft delete, so the undo can restore it
          ScaffoldMessenger.of(context) // LonjaUndoBar in the app
              .showSnackBar(const SnackBar(content: Text('Check removed')));
        },
        child: LonjaSpeciesRow(species: species, onTap: () {}),
      );
}

/// Ochre not oxblood: the paper is old, the fish has not failed. Glyph AND word AND colour.
class LonjaStaleBar extends StatelessWidget {
  const LonjaStaleBar({required this.label, required this.detail, super.key});
  final String label, detail;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
        decoration: const BoxDecoration(color: L.ochreTint,
            border: Border.symmetric(horizontal: BorderSide(color: L.ochre))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.warning_amber_outlined, size: 17, color: L.ochre),
          const SizedBox(width: 9),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: L.detail),
            Text(detail, style: L.mono)
          ])),
        ]),
      );
}

/// Names the absence, says why, offers exactly ONE next move. Never SizedBox.shrink().
class LonjaEmptyState extends StatelessWidget {
  const LonjaEmptyState({required this.headline, required this.body, super.key});
  final String headline, body;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.inbox_outlined, size: 96, color: L.rule), // engraved plate in app
          const SizedBox(height: 20),
          Text(headline, textAlign: TextAlign.center, style: L.headline),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: L.body),
          const SizedBox(height: 24),
          OutlinedButton(onPressed: () {}, child: const Text('Clear filters'))  // one next move
        ]),
      );
}

/// Stale is orthogonal and composes with data; empty replaces the body.
class LonjaSpeciesList extends StatelessWidget {
  const LonjaSpeciesList({required this.species, required this.packIsStale, super.key});
  final List<SpeciesSummary> species;
  final bool packIsStale;
  @override
  Widget build(BuildContext context) => ColoredBox(
        color: L.paper,
        child: Column(children: [
          if (packIsStale)
            const LonjaStaleBar(
                label: 'Rule data expired',
                detail: 'Ministerial Decision 580/2015, Art. 3 · checked 2026-07-14'),
          Expanded(
              child: species.isEmpty
                  ? const LonjaEmptyState(
                      headline: 'No species listed for this zone',
                      body: 'The rule pack for Ras Al Khaimah holds 3,180 entries; '
                          'none matches your current filters.')
                  : DecoratedBox(
                      decoration: const BoxDecoration(border: BorderDirectional(top: L.groupOpen)),
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: species.length,
                          itemBuilder: (context, i) => LonjaSpeciesRow(
                              key: ValueKey(species[i].id), species: species[i], onTap: () {})))),
        ]),
      );
}
