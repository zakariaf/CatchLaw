import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/reference/widgets/reference_entry.dart';
import 'package:flutter/material.dart';

/// A section of the reference this release does not print.
///
/// **It states the fact instead of failing.** The alternative shapes are both
/// worse: a contents entry that does nothing when tapped reads as a broken
/// control, and a missing route reads as a crash. This page names the section
/// the reader asked for, says it is not printed in this copy, and says what
/// this version does contain — the same register `DestinationPlaceholder` uses
/// for a whole branch, one rung down.
///
/// It does not apologise, does not promise a date and does not tell the reader
/// to do anything. E15 deletes this file along with the key it prints.
class ReferenceSectionScreen extends StatelessWidget {
  /// Names [entry] and states that it is not set here.
  const ReferenceSectionScreen({required this.entry, super.key});

  /// Which contents entry was opened.
  final ReferenceEntry entry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      appBar: LonjaScreenBar(
        title: entry.title(l10n),
        sup: entry.numeral,
        onBack: navigator.canPop() ? navigator.pop : null,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.all(tokens.density.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                entry.note(l10n),
                style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: LonjaSpace.s4),
              const LonjaRule.row(),
              const SizedBox(height: LonjaSpace.s4),
              // Serif and unclamped: it is a statement about what this copy
              // contains, and nothing on this page is truncated.
              Text(l10n.referenceSectionNotPrinted, style: type.legal, textAlign: TextAlign.start),
            ],
          ),
        ),
      ),
    );
  }
}
