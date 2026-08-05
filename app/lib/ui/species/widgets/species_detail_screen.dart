import 'package:catchlaw/data/model/enum_codecs.dart';
import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/catch_record.dart';
import 'package:catchlaw/domain/models/evaluation_scope.dart';
import 'package:catchlaw/domain/models/species.dart';
import 'package:catchlaw/domain/models/species_account.dart';
import 'package:catchlaw/domain/models/trip.dart';
import 'package:catchlaw/domain/use_cases/evaluate_catch_use_case.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/locale_codec.dart';
import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:catchlaw/theme/lonja_icon.dart';
import 'package:catchlaw/theme/lonja_icons.dart';
import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:catchlaw/theme/lonja_typography.dart';
import 'package:catchlaw/ui/core/ui/lonja_button.dart';
import 'package:catchlaw/ui/core/ui/lonja_plate.dart';
import 'package:catchlaw/ui/core/ui/lonja_screen_bar.dart';
import 'package:catchlaw/ui/core/ui/lonja_silhouette.dart';
import 'package:catchlaw/ui/core/ui/lonja_stale_bar.dart';
import 'package:catchlaw/ui/log/view_models/catch_log_providers.dart';
import 'package:catchlaw/ui/reference/widgets/rule_text_screen.dart';
import 'package:catchlaw/ui/result/view_models/result_context.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/view_models/result_providers.dart';
import 'package:catchlaw/ui/ruler/widgets/measure_screen.dart';
import 'package:catchlaw/ui/species/view_models/species_detail_view_model.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_placeholders.dart';
import 'package:catchlaw/ui/zones/view_models/zone_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart' show Ok, Result;

/// S2 — the species account and the verdict struck under it.
///
/// **The page is a plate with a caption, then a stamp, then the numbers.** It
/// used to be a heading, a picture, a list of names, a button and a verdict
/// somewhere below the fold. The order is the argument the screen makes: the
/// engraving identifies the fish, the caption names it in every word the reader
/// might know it by, the stamp answers, and the ruled table states what the
/// answer rests on. A screen that reorders that is a different argument.
///
/// **The names caption the art rather than heading it.** Khalid does not read
/// Latin, so the local name is first and the binomial last — but a name printed
/// above a picture is a title, and a name printed under one is an
/// identification, which is what this page is for. The other-locale names run
/// on the same baseline, because a fisher working a Spanish market off a
/// Galician boat needs both words and neither is a footnote to the other.
class SpeciesDetailScreen extends ConsumerStatefulWidget {
  /// Opens the account for [speciesId].
  const SpeciesDetailScreen({required this.speciesId, super.key});

  /// Which species.
  final int speciesId;

  @override
  ConsumerState<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends ConsumerState<SpeciesDetailScreen> {
  /// What the ruler last returned, or null before a measurement.
  ///
  /// **Held here and not in the ruler**, because the reading is an input to the
  /// VERDICT and the verdict lives on this page. Kept out of `user.db` too: a
  /// length is a fact about one fish in one hand, not a setting, and persisting
  /// it would mean the next fish inherits the last one's measurement.
  int? _measuredMm;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<SpeciesAccount> account = ref.watch(speciesAccountProvider(widget.speciesId));
    final AppLocalizations l10n = AppLocalizations.of(context);
    final LonjaTokens tokens = LonjaTokens.of(context);
    final EvaluationScope? scope = ref.watch(evaluationScopeProvider).value;
    final NavigatorState navigator = Navigator.of(context);

    return Scaffold(
      // The band a pushed route carries, and the second half of the question a
      // verdict turns on: the species name answers "which fish", and the zone
      // stamped beside it answers "checked against what". Without it this page
      // was a full-screen takeover with no way back but the system gesture.
      appBar: LonjaScreenBar(
        // The name, once it has been read. The page label stands in until then
        // rather than an empty band, which reads as chrome that failed to draw.
        title: account.value?.primaryName ?? l10n.speciesSearchLabel,
        sup: scope?.zoneCode,
        // Absent on a route with nothing under it: a dead chevron reads as a
        // broken control.
        onBack: navigator.canPop() ? navigator.pop : null,
      ),
      body: SafeArea(
        top: false,
        child: account.when(
          loading: () => const LonjaListSkeleton(rows: 3),
          error: (Object error, StackTrace _) => Padding(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Text('$error', textAlign: TextAlign.start),
          ),
          // A scrolling COLUMN and not a ListView: this page is a fixed handful
          // of blocks, not a list, and `check_lonja_lists.sh` fails an eager
          // list constructor because a list is the thing that grows. The one
          // repeating part — the other-locale names — is bounded by the six
          // shipped locales.
          data: (SpeciesAccount value) => SingleChildScrollView(
            padding: EdgeInsetsDirectional.all(tokens.density.gutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SpeciesArtPanel(account: value),
                const SizedBox(height: LonjaSpace.s3),
                _PlateCaption(account: value),
                // Fed, at last. The slot has been on this page since E08 and
                // empty since E08: E12/T08 is the seam that gives it something
                // to draw. Struck DIRECTLY under the caption, with nothing
                // between it and the fish it is about.
                SpeciesVerdict(speciesId: widget.speciesId, lengthMm: _measuredMm),
                const SizedBox(height: LonjaSpace.s6),
                // Both actions in one row at the foot, the way the mockup ends
                // its pages. The ruler stays reachable from here because this
                // is the only route to it in the app — the mockup's S2 arrives
                // already measured, and this one does not.
                _MeasureSlot(
                  measuredMm: _measuredMm,
                  onMeasured: (int mm) => setState(() => _measuredMm = mm),
                ),
                const SizedBox(height: LonjaSpace.s3),
                _RecordCatchAction(
                  speciesId: widget.speciesId,
                  scientificName: value.scientificName,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The engraved plate's caption: every name this fish answers to, under it.
///
/// **One baseline, not a heading and a list.** The local name, then every other
/// name the pack carries, run on together the way a plate caption runs on —
/// `هامور · Hamour · Orange-spotted grouper` — because they are the same fact
/// stated in the reader's several languages, and a separate *Other names*
/// section printed them as an afterthought two blocks away from the fish.
///
/// The binomial and the family close it on their own line, in the app's only
/// italic: they are the one pair of names that is the same everywhere and the
/// one pair a reader cannot check.
class _PlateCaption extends StatelessWidget {
  const _PlateCaption({required this.account});

  final SpeciesAccount account;

  @override
  Widget build(BuildContext context) {
    final LonjaTokens tokens = LonjaTokens.of(context);
    final LonjaTypeScale type = LonjaType.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // A `Wrap` and not a `Row`: six names on one line overflow a phone, and
        // a caption that clipped would drop exactly the word the reader who
        // needed it was looking for.
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: LonjaSpace.s2,
          runSpacing: LonjaSpace.s1,
          children: <Widget>[
            Text(account.primaryName, style: type.subtitle, textAlign: TextAlign.start),
            for (final SpeciesName name in account.otherNames)
              Text(
                name.regionHint == null ? name.name : '${name.name} (${name.regionHint})',
                style: type.legalSmall.copyWith(color: tokens.onSurfaceMuted),
                textAlign: TextAlign.start,
              ),
          ],
        ),
        const SizedBox(height: LonjaSpace.s1),
        // Last, and in the app's only italic. The binomial is the one name
        // that is the same everywhere and the one a reader cannot check; the
        // family rides on the same line rather than taking a labelled one of
        // its own.
        Text(
          l10n.speciesBinomialFamily(account.scientificName, account.familyName),
          style: type.binomial.copyWith(color: tokens.onSurfaceMuted),
          textAlign: TextAlign.start,
        ),
        if (account.isProtectedAnywhere) ...<Widget>[
          const SizedBox(height: LonjaSpace.s2),
          // A statement about where a protection exists, not a verdict about
          // this catch: the page is reached before a zone is known, so it says
          // SOMEWHERE. E10's finding is what states the rule with its citation.
          Text(
            l10n.speciesProtectedAnywhere,
            style: type.datum.copyWith(color: tokens.onSurface),
            textAlign: TextAlign.start,
          ),
        ],
      ],
    );
  }
}

/// The plate, or the silhouette when no plate cleared.
class _SpeciesArtPanel extends StatelessWidget {
  const _SpeciesArtPanel({required this.account});

  final SpeciesAccount account;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // `null` is the NORMAL case: a plate ships only when its illustrator died
    // long enough ago to clear the longest term among the four jurisdictions
    // this app bundles, and an unattributable plate is dropped rather than
    // bundled pending.
    // A plate when one cleared, the originated silhouette otherwise. The
    // silhouette is NOT a fallback for a missing plate: `silhouette_asset` is
    // NOT NULL and A5 requires one for every species carrying a rule, so this
    // panel always has something to draw. It drew nothing for one release
    // because the resolver was never built and `assets/sil/` was never bundled,
    // and an empty framed box on a printed-reference screen reads as a
    // photograph that failed to load.
    final String art = account.plateAsset ?? account.silhouetteAsset;
    return Semantics(
      image: true,
      label: account.plateAsset == null
          ? l10n.speciesSilhouetteSemanticLabel
          : l10n.speciesPlateSemanticLabel,
      child: LonjaPlateSurface(
        child: LonjaSilhouette(
          assetKey: art,
          semanticsLabel: account.plateAsset == null
              ? l10n.speciesSilhouetteSemanticLabel
              : l10n.speciesPlateSemanticLabel,
          height: 160,
        ),
      ),
    );
  }
}

/// The verdict for one species, in the place the fisher last confirmed.
///
/// A widget of its own so the slot's asynchrony does not put the whole account
/// page behind a loading state: the plate, the names and the family are already
/// on screen and are true whatever the rules say.
///
/// **The reading arrives from S3.** `CatchQuestion` has carried `lengthMm`
/// since E12/T08 and every caller passed null, so the only verdict this screen
/// could ever state was "not measured" — the ruler was unrouted and the seam
/// that would have fed it was therefore never exercised. With a measurement the
/// note
/// says so — which is exactly what an unmeasured fish deserves and is never a
/// pass.
class SpeciesVerdict extends ConsumerWidget {
  /// Answers for [speciesId].
  const SpeciesVerdict({required this.speciesId, this.lengthMm, super.key});

  /// Which fish.
  final int speciesId;

  /// The measured length, or null when nothing has been measured.
  final int? lengthMm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EvaluationScope? scope = ref.watch(evaluationScopeProvider).value;
    // No place, no verdict. He is asked where he is rather than answered
    // against a jurisdiction nobody chose.
    if (scope == null) return const SizedBox.shrink();

    final String locale = encodeLocale(Localizations.localeOf(context)) ?? 'en';
    final request = ResultRequest(
      locale: locale,
      context: ResultContext(
        authorityKey: scope.authorityKey,
        defaultLocale: scope.defaultLocale,
        packId: scope.packVersion,
        packExpiredOn: scope.packValidUntil,
      ),
    );
    final AsyncValue<ResultDisplay> display = ref.watch(
      resultDisplayProvider((
        question: CatchQuestion(
          scope: scope,
          speciesId: speciesId,
          on: scope.checkedOn,
          // The reading, at last. CatchQuestion has carried lengthMm since
          // E12/T08 and every caller passed null, so the only verdict this
          // screen could ever state was "not measured".
          lengthMm: lengthMm,
        ),
        request: request,
      )),
    );

    return display.when(
      loading: () => const LonjaListSkeleton(rows: 2),
      // Said, not swallowed. A pack that would not read is a different fact
      // from a species with no rule, and only one of them is about the law.
      error: (Object error, StackTrace _) => Text('$error', textAlign: TextAlign.start),
      data: (ResultDisplay value) => SpeciesVerdictSlot(
        display: value,
        jurisdiction: value.authority,
        // S13, at last. `SPEC.md` §14's device checklist requires tapping a
        // citation to reach the bundled text, and every caller passed a
        // no-op — a footnote announced to TalkBack as a button and wired to
        // nothing. Pushed onto the navigator this screen already sits in, so
        // the article page keeps the ledger strip and has somewhere to pop to.
        onOpenRuleText: (int citationId, CitationDisplay citation) =>
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => RuleTextRoute(
                  citationId: citationId,
                  citation: citation,
                  authority: value.authority,
                ),
              ),
            ),
      ),
    );
  }
}

/// Writes what he just read into the private log.
///
/// **On the species page and not on a screen of its own**, because the moment a
/// fisher records a catch is the moment he has just read the verdict for it —
/// and a log that costs a navigation is a log nobody keeps at 05:40 with wet
/// hands.
///
/// **It records the outcome, never a judgement of its own.** The row stores
/// `CatchOutcome.unknown` here: this build has the species and the place but no
/// measured length, and the honest value for "what did the rules say about THIS
/// fish" is that nothing was measured. `unknown` is explicitly not permission —
/// the vocabulary keeps the three absences apart precisely so a log entry
/// cannot be read later as a rule that passed. E13 fills in the measured
/// outcome when the ruler feeds this seam.
///
/// **Nothing leaves the phone.** No submit, no share, no export. The label says
/// "record" for that reason: SPEC 5 refuses presenting the log as satisfying a
/// declaration duty, and a verb like "report" or "declare" would do exactly
/// that in one word.
class _RecordCatchAction extends ConsumerStatefulWidget {
  const _RecordCatchAction({required this.speciesId, required this.scientificName});

  final int speciesId;
  final String scientificName;

  @override
  ConsumerState<_RecordCatchAction> createState() => _RecordCatchActionState();
}

class _RecordCatchActionState extends ConsumerState<_RecordCatchAction> {
  /// Latched after a successful write.
  ///
  /// A double tap on a wet screen is one fish, not two. The latch is local and
  /// resets when the page is left, which is the right scope: recording the same
  /// species twice on one tide is legitimate, recording it twice in one second
  /// is a slip.
  bool _recorded = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final EvaluationScope? scope = ref.watch(evaluationScopeProvider).value;
    if (scope == null) return const SizedBox.shrink();

    // THE primary of this screen, and the only one — `.btn.pri` in the
    // mockup's terminal `.btn-row`. It was an outlined box indistinguishable
    // from the ruler beside it, on a page that ends in exactly one thing the
    // reader does. The measure slot above stays secondary, so the ladder still
    // has one filled box (`lonja-buttons` rule 1).
    return LonjaButton.primary(
      label: _recorded ? l10n.catchRecorded : l10n.catchRecord,
      // Excluded rather than labelled: the button's own label already names
      // exactly what happens, and a second node reads the action twice.
      leading: const ExcludeSemantics(child: LonjaIcon(LonjaIcons.plus, size: LonjaIconSize.ui)),
      onPressed: _recorded ? null : () => _record(scope),
    );
  }

  Future<void> _record(EvaluationScope scope) async {
    final Trip? open = ref.read(openTripProvider).value;
    final Result<int> written = await ref
        .read(catchLogRepositoryProvider)
        .record(
          CatchDraft(
            tripId: open?.id,
            jurisdictionCode: scope.jurisdictionCode,
            zoneCode: scope.zoneCode,
            speciesId: widget.speciesId,
            scientificName: widget.scientificName,
            outcome: CatchOutcome.unknown,
            contentVersion: scope.packVersion,
            createdAt: DateTime.now().toIso8601String(),
          ),
        );

    // The write crossed an await and this State may be gone — a setState on a
    // disposed element is an exception on a wet phone at 05:40.
    if (!mounted) return;
    if (written is Ok<int>) setState(() => _recorded = true);
  }
}

/// The route to S3, in the slot that has held a placeholder since E08.
///
/// The ruler, its painter, its calibration flow and its manual keypad have all
/// existed since E09 and were reachable from nowhere — so "how do I measure a
/// fish" had no answer, on a product whose stated job is to replace a booklet
/// with a ruler on the back cover.
class _MeasureSlot extends StatelessWidget {
  const _MeasureSlot({required this.measuredMm, required this.onMeasured});

  /// The last reading, or null.
  final int? measuredMm;

  /// Called with a new reading in millimetres.
  final ValueChanged<int> onMeasured;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return LonjaButton.secondary(
      // The reading becomes the label once there is one, so the page states
      // what it is about to answer against rather than making him remember.
      label: measuredMm == null
          ? l10n.measureTitle
          : l10n.measureManualReading(
              numberFormatFor(Localizations.localeOf(context)).format(measuredMm!),
            ),
      onPressed: () async {
        final int? mm = await Navigator.of(context).push<int>(
          MaterialPageRoute<int>(builder: (BuildContext context) => const MeasureScreen()),
        );
        if (mm != null) onMeasured(mm);
      },
    );
  }
}
