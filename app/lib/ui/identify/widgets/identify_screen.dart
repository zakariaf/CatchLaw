import 'package:catchlaw/domain/models/key_step.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_empty_state.dart';
import 'package:catchlaw/ui/core/ui/lonja_rule.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_section_label.dart';
import 'package:catchlaw/ui/core/ui/lonja_silhouette.dart';
import 'package:catchlaw/ui/core/ui/lonja_species_line.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/identify/view_models/identify_view_model.dart';
import 'package:catchlaw/ui/identify/widgets/key_lead_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// S7 — identify, one couplet at a time.
///
/// **A printed key, walked.** The reader is asked about exactly one character,
/// shown both answers drawn, and told what each still allows. Nothing is
/// photographed, nothing is inferred and nothing is guessed at: `SPEC.md` §5.2
/// argues the photo-AI refusal in full, and this screen is the affordance that
/// replaces it.
///
/// **Every terminus goes somewhere.** A pack with no key, an answer that
/// reaches nothing, a read that failed — each states what is true and offers
/// the species search, because a dead end is the thing this screen exists to
/// prevent and the reason §4.3 wants three entry points into a species rather
/// than one.
class IdentifyScreen extends ConsumerWidget {
  /// Opens the key.
  const IdentifyScreen({required this.onSpeciesChosen, super.key});

  /// Where a chosen candidate goes — S2.
  final void Function(int speciesId) onSpeciesChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<IdentifySession> session = ref.watch(identifyViewModelProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final IdentifySession? walk = session.value;
    // The stamp names which couplet is open, and is absent until there is one:
    // a bar reading "couplet 1" while the first read is still in flight states
    // something about a key nothing has yet looked at.
    final String? stamp = walk == null || walk.step == null
        ? null
        : l10n.identifyKeyStamp(walk.couplet);

    return Scaffold(
      appBar: LonjaScreenBar(
        title: l10n.identifyThisFish,
        sup: stamp,
        onBack: navigator.canPop() ? navigator.pop : null,
      ),
      body: SafeArea(
        // The bar has already taken the status bar; taking it twice prints the
        // first couplet a band lower than the page it heads.
        top: false,
        child: session.when(
          // A skeleton and not a spinner: a spinner says "something is
          // happening", a skeleton says "a page is coming, and it will be this
          // shape".
          loading: () => const LonjaListSkeleton(rows: 4),
          // A read that failed and a pack with no key are two different facts,
          // and the words differ even though the shape does not.
          error: (Object _, StackTrace _) => _KeyDeadEnd(
            headline: l10n.identifyKeyUnreadableHeadline,
            body: l10n.identifyKeyUnreadableBody,
          ),
          data: (IdentifySession state) => _Walk(state: state, onSpeciesChosen: onSpeciesChosen),
        ),
      ),
    );
  }
}

/// The key, wherever the walk currently stands.
class _Walk extends ConsumerWidget {
  const _Walk({required this.state, required this.onSpeciesChosen});

  final IdentifySession state;
  final void Function(int speciesId) onSpeciesChosen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final KeyStep? step = state.step;

    if (step == null) {
      return _KeyDeadEnd(headline: l10n.identifyNoKeyHeadline, body: l10n.identifyNoKeyBody);
    }
    if (state.isListing && step.candidates.isEmpty) {
      return _KeyDeadEnd(
        headline: l10n.identifyNoCandidatesHeadline,
        body: l10n.identifyNoCandidatesBody,
      );
    }

    final IdentifyViewModel walk = ref.read(identifyViewModelProvider.notifier);
    final bool canStepBack = state.stopped || state.trail.isNotEmpty;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(child: _Trail(trail: state.trail)),
        if (state.isListing)
          ..._listing(context, l10n, step)
        else
          ..._couplet(context, l10n, state, step, walk),
        if (canStepBack)
          SliverToBoxAdapter(
            child: _Gutter(
              top: LonjaSpace.s5,
              child: LonjaButton.secondary(
                label: l10n.identifyBackOneStep,
                leading: LonjaIcon(
                  LonjaIcons.back,
                  size: LonjaIconSize.caption,
                  semanticLabel: l10n.identifyBackOneStep,
                ),
                onPressed: () => walk.stepBack(),
              ),
            ),
          ),
        // The closing note: what this screen is, and what it does not do.
        // Invariant 1 said in words, on the one screen a reader would expect a
        // camera on.
        SliverToBoxAdapter(
          child: _Gutter(
            top: LonjaSpace.s6,
            bottom: LonjaSpace.s6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const LonjaRule.block(),
                const SizedBox(height: LonjaSpace.s3),
                _Note(text: l10n.identifyProvenanceNote),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The couplet: its number, what is still possible, the question, the answers
  /// and the way past a character that cannot be read.
  List<Widget> _couplet(
    BuildContext context,
    AppLocalizations l10n,
    IdentifySession state,
    KeyStep step,
    IdentifyViewModel walk,
  ) {
    final LonjaTypeScale type = LonjaType.of(context);
    final String? question = step.question;

    return <Widget>[
      SliverToBoxAdapter(
        child: _Gutter(
          top: LonjaSpace.s4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // The heavy rule that opens a couplet — the 2 pt section weight,
              // not the hairline that separates two rows of a table.
              const LonjaRule.section(),
              const SizedBox(height: LonjaSpace.s3),
              _CoupletHead(couplet: state.couplet, remaining: step.candidates.length),
              const SizedBox(height: LonjaSpace.s2),
              if (question != null) Text(question, style: type.title, textAlign: TextAlign.start),
            ],
          ),
        ),
      ),
      // Built lazily, and authored empty above: a couplet with no answers
      // cannot be walked, and `check_lonja_lists.sh` fails an eager list
      // constructor for the reason a long key would prove on a cold phone.
      SliverList.builder(
        itemCount: step.leads.length,
        itemBuilder: (BuildContext context, int index) => _Gutter(
          top: index == 0 ? LonjaSpace.s4 : LonjaSpace.s3,
          child: KeyLeadTile(lead: step.leads[index], couplet: state.couplet, onTaken: walk.take),
        ),
      ),
      SliverToBoxAdapter(
        child: _Gutter(
          top: LonjaSpace.s6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LonjaSectionLabel(text: l10n.identifyDamagedHeading),
              const SizedBox(height: LonjaSpace.s3),
              _Note(text: l10n.identifyDamagedNote),
              const SizedBox(height: LonjaSpace.s3),
              LonjaButton.secondary(label: l10n.identifyListWhatRemains, onPressed: walk.stopHere),
            ],
          ),
        ),
      ),
    ];
  }

  /// What the answers so far still allow, drawn and named.
  List<Widget> _listing(BuildContext context, AppLocalizations l10n, KeyStep step) => <Widget>[
    SliverToBoxAdapter(
      child: _Gutter(
        top: LonjaSpace.s4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const LonjaRule.section(),
            const SizedBox(height: LonjaSpace.s3),
            LonjaSectionLabel(text: l10n.identifyRemainingHeading),
            const SizedBox(height: LonjaSpace.s2),
            _CandidateCount(remaining: step.candidates.length),
          ],
        ),
      ),
    ),
    SliverList.builder(
      itemCount: step.candidates.length,
      itemBuilder: (BuildContext context, int index) {
        final KeyCandidate candidate = step.candidates[index];
        return LonjaSpeciesLine(
          name: candidate.displayName,
          scientificName: candidate.scientificName,
          art: LonjaSilhouette(
            assetKey: candidate.silhouetteAsset,
            semanticsLabel: l10n.speciesSilhouetteSemanticLabel,
            height: LonjaSpace.s6,
          ),
          onTap: () => onSpeciesChosen(candidate.speciesId),
        );
      },
    ),
  ];
}

/// The answers already given, in the order they were given.
///
/// Absent before the first answer: an eyebrow over nothing reads as a trail
/// that failed to load. The separator is the forward chevron, which mirrors
/// under `Directionality` — an `>` authored as text would point out of the
/// reading order in Arabic.
class _Trail extends StatelessWidget {
  const _Trail({required this.trail});

  final List<KeyAnswer> trail;

  @override
  Widget build(BuildContext context) {
    if (trail.isEmpty) return const SizedBox.shrink();
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return _Gutter(
      top: LonjaSpace.s4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LonjaSectionLabel(text: l10n.identifyAnswersSoFar),
          const SizedBox(height: LonjaSpace.s2),
          Wrap(
            spacing: LonjaSpace.s2,
            runSpacing: LonjaSpace.s1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              for (final (int index, KeyAnswer answer) in trail.indexed) ...<Widget>[
                if (index > 0)
                  ExcludeSemantics(
                    child: LonjaIcon(
                      LonjaIcons.forward,
                      size: LonjaIconSize.caption,
                      color: tokens.onSurfaceFaint,
                    ),
                  ),
                Text(
                  answer.label,
                  style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
                  textAlign: TextAlign.start,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// The couplet's number at the start of the line, and what remains at the end.
class _CoupletHead extends StatelessWidget {
  const _CoupletHead({required this.couplet, required this.remaining});

  final int couplet;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Text(
            l10n.identifyCoupletLabel(couplet),
            style: type.articleNumber.copyWith(color: tokens.onSurfaceMuted),
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: LonjaSpace.s3),
        _CandidateCount(remaining: remaining),
      ],
    );
  }
}

/// How many species the answers so far still allow.
///
/// Framed rather than filled, and set in the mono step: it is a figure read
/// against the couplet number beside it, not a status. Nothing on this screen
/// is a verdict, so nothing here carries a verdict pigment.
class _CandidateCount extends StatelessWidget {
  const _CandidateCount({required this.remaining});

  final int remaining;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: tokens.accent, width: LonjaRules.rule)),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: LonjaSpace.s2,
          vertical: LonjaSpace.s1,
        ),
        child: Text(
          l10n.identifySpeciesRemain(remaining),
          style: type.articleNumber.copyWith(color: tokens.accent),
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}

/// A quiet paragraph about the mechanism.
class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    return Text(
      text,
      style: type.uiSmall.copyWith(color: tokens.onSurfaceMuted),
      textAlign: TextAlign.start,
    );
  }
}

/// The screen gutter, applied once rather than at every call site.
class _Gutter extends StatelessWidget {
  const _Gutter({required this.child, this.top = 0, this.bottom = 0});

  final Widget child;
  final double top;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: tokens.density.gutter,
        end: tokens.density.gutter,
        top: top,
        bottom: bottom,
      ),
      child: child,
    );
  }
}

/// Where the key stops, and the one way onward from it.
///
/// One widget for all three termini, so the shape of "the key has nothing for
/// you here" cannot drift between them while the words stay honestly
/// different — and so this file carries exactly one primary action, which is
/// the rule the ladder is built on.
class _KeyDeadEnd extends StatelessWidget {
  const _KeyDeadEnd({required this.headline, required this.body});

  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final NavigatorState navigator = Navigator.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LonjaEmptyState(
            headline: headline,
            body: body,
            primary: LonjaButton.primary(
              label: l10n.identifySearchByName,
              // Back to the screen this one was pushed from, which is the
              // search. A terminus with no way out is the dead end §4.3
              // records — the reason three entry points exist rather than one.
              onPressed: navigator.canPop() ? navigator.pop : null,
            ),
          ),
          _Gutter(
            bottom: LonjaSpace.s6,
            child: _Note(text: l10n.identifyProvenanceNote),
          ),
        ],
      ),
    );
  }
}
