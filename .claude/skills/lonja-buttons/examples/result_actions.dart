// Demonstrates the call site of the Lonja ladder: exactly ONE primary action per screen, a
// busy latch that makes a wet double tap idempotent against the writable user database, a
// disabled action that states its reason in adjacent prose rather than dying silently, and a
// destructive action routed through a confirmation whose accept button repeats the verb.
// Real screen: the CatchLaw result row after measuring a Hamour (Epinephelus coioides) at
// 38 cm against a 45 cm total-length minimum in Ras Al Khaimah.
// LIMITS: LonjaButton and Lonja come from lonja_buttons.dart; confirmDestructive is owned by
// `lonja-dialogs-and-surfaces`. Labels are inlined for readability but ship through ARB
// (`i18n-rtl-l10n`). Conceptually compiles against flutter.

import 'dart:async';

import 'package:flutter/material.dart';

import 'lonja_buttons.dart';

/// The action row under "Below the minimum — 38 cm, minimum 45 cm (total length)".
/// The verdict states the fact; these buttons only offer what the APP can do. There is no
/// 'Keep' and no 'Return' here, in any locale.
class ResultActions extends StatefulWidget {
  const ResultActions({
    required this.onRecord,
    required this.onIdentify,
    required this.onDeleteTrip,
    this.zone,
    super.key,
  });

  final Future<void> Function() onRecord;
  final VoidCallback onIdentify;
  final Future<bool> Function(String verb) onDeleteTrip;

  /// e.g. 'Ras Al Khaimah'. Null means no zone chosen yet, which disables recording.
  final String? zone;

  @override
  State<ResultActions> createState() => _ResultActionsState();
}

class _ResultActionsState extends State<ResultActions> {
  bool _busy = false;

  Future<void> _record() async {
    if (_busy) return; // the second half of a wet double tap is dropped on the floor
    setState(() => _busy = true);
    try {
      await widget.onRecord(); // exactly one INSERT into the writable user DB
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteTrip() async {
    // The confirmation surface is owned by lonja-dialogs-and-surfaces; its accept button
    // carries the same verb as the button that opened it, never 'Yes'.
    await widget.onDeleteTrip('Delete this trip');
  }

  @override
  Widget build(BuildContext context) {
    final glove = Lonja.of(context).isGlove;
    final canRecord = widget.zone != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: glove ? 12 : 8,
        children: [
          // ONE primary. Everything else steps down the ladder.
          LonjaButton.primary(
            label: 'Record another',
            icon: Icons.check,
            busy: _busy,
            onPressed: canRecord ? () => unawaited(_record()) : null,
          ),
          // A disabled action always carries its reason in adjacent prose (rule 9).
          if (!canRecord)
            const Text(
              'Select a zone first — the rules differ by zone.',
              style: TextStyle(color: Lonja.inkMuted, fontSize: 13),
            ),
          LonjaButton.secondary(label: 'Identify this fish', onPressed: widget.onIdentify),
          LonjaButton.quiet(label: 'Export as CSV to this phone', compact: true, onPressed: () {}),
          LonjaButton.destructive(
            label: 'Delete this trip',
            icon: Icons.close,
            onPressed: () => unawaited(_deleteTrip()),
          ),
        ],
      ),
    );
  }
}
