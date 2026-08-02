import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_panel.dart';
import 'package:flutter/material.dart';

/// What a confirmation returned.
///
/// **Three values, because dismissal is not refusal.** A system-back pop or a
/// barrier tap means the fisher never answered; folding that into `declined`
/// tells the caller a decision was made when none was, and the caller that
/// believes it is the one that quietly does nothing and shows no reason why.
enum LonjaConfirmOutcome {
  /// The destructive action was confirmed.
  confirmed,

  /// The cancel rung was chosen.
  declined,

  /// The sheet went away without an answer.
  dismissed,
}

/// Asks before something irreversible happens.
///
/// [cancelLabel] is **required and carries no default**. The obvious default is
/// the one `lonja-dialogs-and-surfaces` rule 3 prescribes — a cancel that names
/// the preservation — and every wording it tables opens with a verb that
/// `check_app_invariants.sh` check 3 fails in Dart and in every ARB file, with
/// no exemption anywhere. Invariant 2 bans that lexicon outright. E07 therefore
/// ships the mechanism and no copy; the screens that own real confirmations are
/// E13, E16 and E17, and the epic's risk 2 records the unreconciled rule.
///
/// `barrierDismissible: false`: a stray tap outside the sheet must not read as
/// an answer to a question about deleting the fisher's catch log.
Future<LonjaConfirmOutcome> showLonjaConfirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  // Captured before the route opens and restored after it pops, so a keyboard
  // or switch user lands back where they were rather than at the top of the
  // screen.
  final FocusNode? restoreTo = FocusManager.instance.primaryFocus;

  final LonjaConfirmOutcome? answer = await showDialog<LonjaConfirmOutcome>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final LonjaTypeScale type = LonjaType.of(context);
      return AlertDialog(
        content: LonjaPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: type.title, textAlign: TextAlign.start),
              const SizedBox(height: LonjaSpace.s3),
              Text(body, style: type.legal, textAlign: TextAlign.start),
              const SizedBox(height: LonjaSpace.s5),
              LonjaButton.secondary(
                label: cancelLabel,
                onPressed: () => Navigator.of(context).pop(LonjaConfirmOutcome.declined),
              ),
              const SizedBox(height: LonjaSpace.s2),
              LonjaButton.destructive(
                label: confirmLabel,
                onConfirmed: () async => Navigator.of(context).pop(LonjaConfirmOutcome.confirmed),
              ),
            ],
          ),
        ),
      );
    },
  );

  restoreTo?.requestFocus();
  // A null result is a pop nobody chose — the system back button, or a route
  // torn down underneath us.
  return answer ?? LonjaConfirmOutcome.dismissed;
}
