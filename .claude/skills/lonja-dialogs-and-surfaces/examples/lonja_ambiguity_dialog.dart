// Demonstrates the CATCHLAW ambiguity modal end to end: a squared, ruled, zero-elevation dialog
// shell that prints BOTH conflicting instruments at equal weight, refuses to recommend either,
// disables barrier dismissal, captures and restores focus, and returns a typed sealed
// AmbiguityChoice rather than a bare bool. Plate and snackbar surfaces: lonja_plate_surface.dart.

import 'package:flutter/material.dart';

const Color kPaper = Color(0xFFE6E4DC);
const Color kPaperSunk = Color(0xFFDEDBD1);
const Color kInk = Color(0xFF16201C);
const Color kRule = Color(0xFFC2C5BB);
const Color kRuleStrong = Color(0xFFA9AC9F);

typedef Instrument = ({String id, String statement, String citation, String checked});

// --- Typed result: never `bool`. Dismissal is its own exhaustive case. -------------------------

sealed class AmbiguityChoice {
  const AmbiguityChoice();
}

final class AppliedInstrument extends AmbiguityChoice {
  const AppliedInstrument(this.instrumentId);
  final String instrumentId;
}

final class DeferredToBoth extends AmbiguityChoice {
  const DeferredToBoth();
}

// --- Opening it: focus captured before the barrier, restored after it drops. -------------------

Future<AmbiguityChoice?> showAmbiguityDialog(BuildContext context,
    {required List<Instrument> candidates, required String speciesLine}) async {
  assert(candidates.length >= 2, 'ambiguity needs two or more equally specific rules');
  final opener = FocusManager.instance.primaryFocus;
  final choice = await showDialog<AmbiguityChoice>(
    context: context,
    barrierDismissible: false, // legal weight: a stray wet-hand tap must not resolve this
    barrierColor: kInk.withValues(alpha: 0.62), // flat wash, never a gradient or blur
    builder: (_) => LonjaAmbiguityDialog(candidates: candidates, speciesLine: speciesLine),
  );
  opener?.requestFocus();
  return choice;
}

// --- The dialog shell: a pasted slip of paper, squared off. ------------------------------------

class LonjaAmbiguityDialog extends StatelessWidget {
  const LonjaAmbiguityDialog({required this.candidates, required this.speciesLine, super.key});

  static const TextStyle _serif = TextStyle(fontFamily: 'Iowan Old Style', color: kInk);
  static const TextStyle _mono = TextStyle(fontFamily: 'SF Mono', fontSize: 15, height: 1.5,
      color: kInk, fontFeatures: <FontFeature>[FontFeature.tabularFigures()]);
  static const BoxDecoration _plate = BoxDecoration(
      color: kPaperSunk, // inset, not elevated: no shadow, no radius, no gradient
      border: Border(
          top: BorderSide(color: kRuleStrong, width: 2), left: BorderSide(color: kRule),
          right: BorderSide(color: kRule), bottom: BorderSide(color: kRule)));

  final List<Instrument> candidates;
  final String speciesLine;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: kPaper,
      insetPadding: const EdgeInsets.all(24),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, side: BorderSide(color: kRuleStrong, width: 3)),
      child: FocusScope(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Two rules of equal standing apply here.', // a fact, not a question
                    style: _serif.copyWith(fontSize: 20, height: 1.3, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(speciesLine, style: _serif.copyWith(fontSize: 16)),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: kRule),
                // Both instruments, source order, identical weight. Full plate anatomy lives in
                // lonja_plate_surface.dart; the citation is always visible, never fine print.
                for (final Instrument i in candidates) ...<Widget>[
                  const SizedBox(height: 16),
                  DecoratedBox(
                      decoration: _plate,
                      child: Padding(
                          padding: const EdgeInsetsDirectional.all(16),
                          child: Text('${i.statement}\n${i.citation} · checked ${i.checked}',
                              style: _mono))),
                ],
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: kRule),
                // Equal-weight actions: no primary, no autofocus, no 'recommended' badge.
                for (final Instrument i in candidates)
                  EqualAction('Apply ${i.statement} — ${i.citation}',
                      () => Navigator.of(context).pop(AppliedInstrument(i.id))),
                EqualAction('Show both — decide on the water',
                    () => Navigator.of(context).pop(const DeferredToBoth())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EqualAction extends StatelessWidget {
  const EqualAction(this.label, this.onPressed, {super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsetsDirectional.only(top: 8),
      child: SizedBox(
          width: double.infinity,
          height: 56, // glove-mode floor; >= 8 dp separation from the padding above
          child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                  foregroundColor: kInk,
                  side: const BorderSide(color: kRuleStrong, width: 2),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(label, style: const TextStyle(fontSize: 16))))));
}

// --- Call site: every case handled, including the null tear-down. ------------------------------

Future<void> onAmbiguousVerdict(BuildContext context) async {
  final choice = await showAmbiguityDialog(context,
      speciesLine: 'هامور Hamour · Orange-spotted grouper · Epinephelus coioides · measured 46 cm',
      candidates: const <Instrument>[
        (id: 'ae-md-580-2015-art3', statement: 'min 45 cm total length',
            citation: 'Ministerial Decision 580/2015, Art. 3', checked: '2026-07-14'),
        (id: 'rak-local-2019-art7', statement: 'min 50 cm total length',
            citation: 'Ras Al Khaimah Local Order 4/2019, Art. 7', checked: '2026-07-14'),
      ]);
  if (!context.mounted) return; // see async-safety
  switch (choice) {
    case AppliedInstrument(:final instrumentId):
      debugPrint('user applied $instrumentId');
    case DeferredToBoth():
      debugPrint('both rules remain on screen');
    case null:
      debugPrint('torn down by a route pop — no state change, never a write');
  }
}
