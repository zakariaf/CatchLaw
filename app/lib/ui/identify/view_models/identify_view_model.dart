import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/key_step.dart';
import 'package:catchlaw/l10n/locale_notifier.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:rule_engine/rule_engine.dart' show Failure, Ok, Result;

/// One couplet already answered, on the way down the key.
@immutable
final class KeyAnswer {
  /// The answer taken at [nodeId].
  const KeyAnswer({required this.nodeId, required this.label});

  /// The node the answer was given at, so stepping back returns to it.
  final int nodeId;

  /// The character as the key states it, already resolved.
  final String label;
}

/// How far down the key this walk has got.
@immutable
final class IdentifySession {
  /// A walk standing at [step], having answered [trail].
  const IdentifySession({
    required this.step,
    this.trail = const <KeyAnswer>[],
    this.stopped = false,
  });

  /// Where the walk stands, or `null` when the pack carries no key at all.
  final KeyStep? step;

  /// Every answer given, in the order it was given.
  final List<KeyAnswer> trail;

  /// Whether the walk stopped here rather than asking another question.
  final bool stopped;

  /// Which couplet is open, counting from one, as a printed key numbers them.
  int get couplet => trail.length + 1;

  /// Whether the screen is showing candidates rather than a question.
  ///
  /// Three ways to arrive and one rendering: the key ran out of questions, an
  /// answer had nothing under it, or the reader could not see the character and
  /// stopped. The list is the same list in all three — what the answers so far
  /// still allow.
  bool get isListing => stopped || (step?.isLeaf ?? false);
}

/// S7's walk down the dichotomous key.
///
/// **The trail lives here and not in the pack.** A key node knows its parent,
/// but the parent alone cannot say which answer was taken to reach the child —
/// and the breadcrumb over the couplet is exactly that sequence of answers. A
/// walk is session state, so it is held by the notifier and lost with the
/// screen, which is correct: which fish a reader was squinting at is not
/// something this product writes to `user.db`.
class IdentifyViewModel extends AsyncNotifier<IdentifySession> {
  @override
  Future<IdentifySession> build() async {
    // Watched, not read: a locale change re-resolves every question and every
    // lead in the key, and a walk left half in Galician would be a screen
    // printing two languages at once.
    ref.watch(localeNotifierProvider);
    final Result<KeyStep?> first = await ref
        .read(identificationKeyRepositoryProvider)
        .firstStep(locale: _locale);
    return IdentifySession(step: _orThrow(first));
  }

  /// Takes [lead], and stands at whatever it reaches.
  ///
  /// A lead with no node under it is the key's terminal state (§7.1), so the
  /// walk stops on the standing node and lists what that answer allows rather
  /// than reading a node that does not exist.
  Future<void> take(KeyLead lead) async {
    final IdentifySession? current = state.value;
    final KeyStep? standing = current?.step;
    if (current == null || standing == null) return;

    final trail = <KeyAnswer>[
      ...current.trail,
      KeyAnswer(nodeId: standing.nodeId, label: lead.label),
    ];

    final int? next = lead.nextNodeId;
    if (next == null) {
      state = AsyncValue<IdentifySession>.data(
        IdentifySession(
          step: KeyStep(
            nodeId: standing.nodeId,
            question: null,
            leads: const <KeyLead>[],
            candidates: lead.candidates,
          ),
          trail: trail,
          stopped: true,
        ),
      );
      return;
    }

    state = const AsyncValue<IdentifySession>.loading();
    state = await AsyncValue.guard(() => _at(next, trail));
  }

  /// Stops the key at this couplet and lists what it still allows.
  ///
  /// The alternate route a printed key offers when a character is damaged or
  /// missing. Nothing is invented: the candidate set of the standing node is
  /// what the answers so far already establish, and it is drawn and named
  /// instead of being asked about again.
  void stopHere() {
    final IdentifySession? current = state.value;
    if (current == null || current.step == null) return;
    state = AsyncValue<IdentifySession>.data(
      IdentifySession(step: current.step, trail: current.trail, stopped: true),
    );
  }

  /// Returns to the couplet before this one.
  ///
  /// Undoing a stop restores the standing node's question rather than climbing
  /// past it: a reader who could not see the tail and then could is not sent a
  /// couplet further up than he came from.
  Future<void> stepBack() async {
    final IdentifySession? current = state.value;
    final KeyStep? standing = current?.step;
    if (current == null || standing == null) return;

    if (current.stopped) {
      // A stop reached by answering a dead-end lead carries that answer on the
      // trail; a stop taken by the skip does not. Popping only the first is
      // what makes one tap of back undo exactly one action.
      final bool answeredHere =
          current.trail.isNotEmpty && current.trail.last.nodeId == standing.nodeId;
      final List<KeyAnswer> trail = answeredHere
          ? current.trail.sublist(0, current.trail.length - 1)
          : current.trail;
      state = const AsyncValue<IdentifySession>.loading();
      state = await AsyncValue.guard(() => _at(standing.nodeId, trail));
      return;
    }

    if (current.trail.isEmpty) return;
    final KeyAnswer last = current.trail.last;
    state = const AsyncValue<IdentifySession>.loading();
    state = await AsyncValue.guard(
      () => _at(last.nodeId, current.trail.sublist(0, current.trail.length - 1)),
    );
  }

  /// The session standing at [nodeId] with [trail] behind it.
  Future<IdentifySession> _at(int nodeId, List<KeyAnswer> trail) async {
    final Result<KeyStep?> step = await ref
        .read(identificationKeyRepositoryProvider)
        .stepAt(nodeId, locale: _locale);
    return IdentifySession(step: _orThrow(step), trail: trail);
  }

  /// The content locale, region and all.
  ///
  /// `pt_BR` is not `pt` (D-3): the content is Brazilian, and dropping the
  /// region here would ship Iberian wording to Brazil through the resolver's
  /// exact-match chain.
  String get _locale {
    final Locale? locale = ref.read(localeNotifierProvider).value;
    if (locale == null) return 'en';
    final String? region = locale.countryCode;
    return region == null || region.isEmpty
        ? locale.languageCode
        : '${locale.languageCode}_$region';
  }

  /// A failed read is an error, never an empty key.
  ///
  /// "This pack carries no key" is a statement about the transcription. Saying
  /// it when the device could not read the file is the app lying about the rule
  /// book, so the two states never merge.
  KeyStep? _orThrow(Result<KeyStep?> result) => switch (result) {
    Ok<KeyStep?>(:final KeyStep? value) => value,
    Failure<KeyStep?>(:final Exception exception) => throw exception,
  };
}

/// S7's walk.
final AsyncNotifierProvider<IdentifyViewModel, IdentifySession> identifyViewModelProvider =
    AsyncNotifierProvider<IdentifyViewModel, IdentifySession>(
      IdentifyViewModel.new,
      isAutoDispose: true,
    );
