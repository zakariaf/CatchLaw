import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_search_field.dart';
import 'package:catchlaw/ui/result/view_models/flag_rule_viewmodel.dart';
import 'package:flutter/material.dart';

/// Records the reader's doubt about a rule, inline and without a modal.
///
/// **No dialog.** Writing a note is not a decision the app cannot proceed
/// without, and a modal would spend the ten-second budget on something nobody
/// is waiting for. The panel opens in place, under the rule it is about.
///
/// **The save label names the effect and its whole extent.** The note stays on
/// this device: there is no network, nothing is transmitted, and no review is
/// promised. A label reading "Report" or "Send" would describe an act the app
/// cannot perform.
///
/// Flagging changes nothing above it. The stamp, the table and the citation say
/// exactly what they said before — the flag records a disagreement with the
/// transcription, not a correction to the instrument.
class ResultFlagPanel extends StatefulWidget {
  /// Flags [ruleId], cited [citationRef], through [viewModel].
  const ResultFlagPanel({
    required this.ruleId,
    required this.viewModel,
    required this.now,
    this.citationRef,
    super.key,
  });

  /// The action that reveals the field.
  static const Key openKey = Key('result-flag-open');

  /// The save target.
  static const Key saveKey = Key('result-flag-save');

  /// The note field.
  static const Key noteKey = Key('result-flag-note');

  /// Which rule the reader disputes.
  final int ruleId;

  /// The citation as text, so the note survives a renumbering.
  final String? citationRef;

  /// Validates and writes.
  final FlagRuleViewModel viewModel;

  /// The instant to stamp, ISO-8601, injected rather than read from a clock.
  final String now;

  @override
  State<ResultFlagPanel> createState() => _ResultFlagPanelState();
}

class _ResultFlagPanelState extends State<ResultFlagPanel> {
  final TextEditingController _note = TextEditingController();
  bool _open = false;
  FlagOutcome? _outcome;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final FlagOutcome outcome = await widget.viewModel.save(
      ruleId: widget.ruleId,
      note: _note.text,
      now: widget.now,
      citationRef: widget.citationRef,
    );
    if (!mounted) return;
    setState(() => _outcome = outcome);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        LonjaButton.secondary(
          key: ResultFlagPanel.openKey,
          label: l10n.flagRuleAction,
          onPressed: () => setState(() => _open = true),
        ),
        if (_open) ...<Widget>[
          const SizedBox(height: LonjaSpace.s3),
          LonjaSearchField(
            key: ResultFlagPanel.noteKey,
            controller: _note,
            hint: l10n.flagRuleNoteLabel,
            semanticLabel: l10n.flagRuleNoteLabel,
            // Nothing happens per keystroke: the note is read when the reader
            // saves it, and a rebuild per character on a wet screen is work
            // nobody asked for.
            onChanged: (String _) {},
          ),
          const SizedBox(height: LonjaSpace.s2),
          LonjaButton.secondary(
            key: ResultFlagPanel.saveKey,
            label: l10n.flagRuleSaveAction,
            onPressed: _save,
          ),
        ],
        if (_outcome case final FlagOutcome outcome) ...<Widget>[
          const SizedBox(height: LonjaSpace.s2),
          Text(
            // A receipt for something already committed, in the past tense. It
            // promises no review, no reply and no upload.
            switch (outcome) {
              FlagOutcome.recorded => l10n.flagRuleRecorded,
              FlagOutcome.emptyNote => l10n.flagRuleEmptyNote,
              FlagOutcome.failed => l10n.flagRuleEmptyNote,
            },
            style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ],
      ],
    );
  }
}
