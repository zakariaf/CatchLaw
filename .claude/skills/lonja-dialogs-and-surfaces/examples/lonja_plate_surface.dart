// Demonstrates the Lonja transient-surface treatment that is NOT a dialog: the ruled inset
// LonjaPanel, the full LonjaPlate with its always-visible citation band, and the squared snackbar
// slab whose destructive write is DEFERRED until the 8-second undo window closes. Every surface is
// flat — zero elevation, zero radius, zero shadow, zero gradient. Paper-theme token values.

import 'package:flutter/material.dart';

const Color kPaperSunk = Color(0xFFDEDBD1);
const Color kInk = Color(0xFF16201C);
const Color kInkFaint = Color(0xFF6C7871);
const Color kRule = Color(0xFFC2C5BB);
const Color kRuleStrong = Color(0xFFA9AC9F);
const Color kHarbour = Color(0xFF1B4D5E);

const TextStyle kMono = TextStyle(fontFamily: 'SF Mono', color: kInk,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()]);

// --- Panel: a field ruled onto the page, 1 px hairline all round. ------------------------------

class LonjaPanel extends StatelessWidget {
  const LonjaPanel({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: const BoxDecoration(color: kPaperSunk, border: Border.fromBorderSide(
          BorderSide(color: kRule))), // no boxShadow, no borderRadius, ever
      child: Padding(padding: const EdgeInsetsDirectional.all(16), child: child));
}

// --- Plate: the panel plus a 2 px structural top rule and a citation band. ---------------------

class LonjaPlate extends StatelessWidget {
  const LonjaPlate({
    required this.vernacular,
    required this.scientific,
    required this.statement,
    required this.citation,
    required this.published,
    required this.checked,
    super.key,
  });

  static const BoxDecoration _inset = BoxDecoration(
      color: kPaperSunk,
      border: Border(
          top: BorderSide(color: kRuleStrong, width: 2), left: BorderSide(color: kRule),
          right: BorderSide(color: kRule), bottom: BorderSide(color: kRule)));

  final String vernacular, scientific, statement, citation, published, checked;

  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: _inset,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text(vernacular,
              style: const TextStyle(fontFamily: 'Iowan Old Style', fontSize: 18, color: kInk)),
          Text(scientific,
              style: const TextStyle(fontFamily: 'Iowan Old Style', fontSize: 14,
                  fontStyle: FontStyle.italic, color: kInkFaint)),
          const SizedBox(height: 12),
          // Measurements are mono with tabular figures so digits align down the column.
          Text(statement, style: kMono.copyWith(fontSize: 17)),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: kRule),
          const SizedBox(height: 8),
          // The citation is a design FEATURE: full opacity, own band, never collapsed or 40% alpha.
          Text('$citation · published $published · checked $checked',
              style: kMono.copyWith(fontSize: 12, height: 1.4, color: kInkFaint)),
        ]),
      ));
}

// --- Snackbar slab: informational, one optional Undo, deferred destructive write. ---------------

void removeCatchEntry(
  BuildContext context, {
  required String entryId,
  required Future<void> Function(String id) commitDelete,
}) {
  var undone = false;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar() // never stack slabs
    ..showSnackBar(SnackBar(
      duration: const Duration(seconds: 8), // the undo window
      behavior: SnackBarBehavior.fixed, // squared, full-bleed, no float, no margin, no radius
      elevation: 0,
      backgroundColor: kPaperSunk,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, side: BorderSide(color: kRuleStrong, width: 2)),
      content: const Text('كنعد Kanaad entry removed',
          style: TextStyle(fontSize: 15, height: 1.4, color: kInk)),
      action: SnackBarAction(
        label: 'Undo', // the ONLY action a slab may carry, and it is optional
        textColor: kHarbour,
        onPressed: () => undone = true,
      ),
    ))
        .closed
        .then((SnackBarClosedReason reason) async {
      // Write LAST. A crash inside the window leaves the entry intact rather than silently gone.
      if (!undone && reason != SnackBarClosedReason.action) await commitDelete(entryId);
    });
}

// --- Assembled: a stale-data panel above a plate. ----------------------------------------------

class RuleSurfaceDemo extends StatelessWidget {
  const RuleSurfaceDemo({super.key});

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        const LonjaPanel(
          // Glyph plus word plus colour — colour is never the only signal.
          child: Text('⚠ Stale — rule data last checked 2026-07-14',
              style: TextStyle(fontSize: 15, color: Color(0xFF8A6A16))), // ochre
        ),
        const SizedBox(height: 16),
        const LonjaPlate(
          vernacular: 'شعري Sha\'ri · Spangled emperor',
          scientific: 'Lethrinus nebulosus',
          statement: 'closed 1 Mar – 30 Apr',
          citation: 'Ministerial Decision 580/2015, Art. 3',
          published: '2015-11-03',
          checked: '2026-07-14',
        ),
      ]);
}
