import 'package:catchlaw/data/providers.dart';
import 'package:catchlaw/domain/models/content_strings.dart';
import 'package:catchlaw/domain/use_cases/content_string_resolver.dart';
import 'package:catchlaw/domain/use_cases/evaluate_catch_use_case.dart';
import 'package:catchlaw/l10n/gen/app_localizations.dart';
import 'package:catchlaw/l10n/locale_codec.dart';
import 'package:catchlaw/l10n/numeral_system_notifier.dart';
import 'package:catchlaw/ui/result/view_models/result_context.dart';
import 'package:catchlaw/ui/result/view_models/result_display.dart';
import 'package:catchlaw/ui/result/view_models/verdict_presenter.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rule_engine/rule_engine.dart'
    show Failure, MeasurementMethod, Ok, Resolution, Result;

/// Every `content_string` key a verdict sentence can reach for.
///
/// Resolved in one pass rather than one lookup per finding: the presenter is
/// synchronous by design, and a screen carrying four findings would otherwise
/// be four round trips into `reference.db` between the fish and the answer.
/// The set is small and fixed — nine measurement methods and one authority —
/// which is what makes resolving all of it cheaper than deciding which parts to.
final List<String> kVerdictContentKeys = <String>[
  for (final MeasurementMethod method in MeasurementMethod.values) contentKeyForMethod(method),
];

/// The tier-two words for one place, in one language.
///
/// Asynchronous because they live in `reference.db`, which is also why the
/// presenter does not take the resolver itself: a verdict sentence is assembled
/// synchronously so six locales cost six calls rather than six widget pumps.
final resultContentStringsProvider = FutureProvider.autoDispose
    .family<ContentStrings, ResultRequest>((Ref ref, ResultRequest request) async {
      final resolver = ContentStringResolver(ref.watch(contentStringRepositoryProvider));
      final keys = <String>[...kVerdictContentKeys, request.context.authorityKey];
      // Concurrently, not in sequence. Each key is its own statement against
      // `reference.db`, and ten in a row is ten round trips between the fish and
      // the answer — on the phone `SPEC.md` §13 budgets for.
      final List<String> values = await Future.wait(<Future<String>>[
        for (final String key in keys)
          resolver.resolve(
            key,
            requestedLocale: request.locale,
            defaultLocale: request.context.defaultLocale,
          ),
      ]);
      return ContentStrings(<String, String>{
        for (var i = 0; i < keys.length; i++) keys[i]: values[i],
      });
    });

/// The presenter for one place, in one language.
///
/// A `FutureProvider` rather than the plain one, because tier two is a table in
/// `reference.db` and the presenter may not exist half-resolved: a fallback
/// value for a missing key is the string that ships.
///
/// It reads the locale from the family key rather than from a `BuildContext`,
/// so a sentence can be asserted in six languages with no widget tree at all.
///
/// The numeral setting is watched, and what that buys is the REBUILD rather
/// than a fresh formatter: the presenter builds one at each use, so its digits
/// are already current — but a screen holding a `ResultDisplay` built before
/// the lever moved would go on drawing the old digits until something asked it
/// to draw again.
final verdictPresenterProvider = FutureProvider.autoDispose.family<VerdictPresenter, ResultRequest>(
  (Ref ref, ResultRequest request) async {
    ref.watch(numeralSystemProvider);
    final ContentStrings content = await ref.watch(resultContentStringsProvider(request).future);
    // Decoded rather than carried as a `Locale`: `Locale('pt_BR')` constructs a
    // language code containing an underscore, which matches nothing and looks
    // right (`locale_codec.dart`).
    final Locale locale = decodeLocale(request.locale) ?? const Locale('en');
    return VerdictPresenter(l10n: lookupAppLocalizations(locale), content: content, locale: locale);
  },
);

/// The engine's answer for one question.
///
/// The provider E10/T01 deliberately did not build, because the thing it would
/// have watched did not exist. `CatchQuestion` compares by value, so a ruler
/// drag that does not move the millimetre re-reads nothing.
final resolutionProvider = FutureProvider.autoDispose.family<Resolution, CatchQuestion>((
  Ref ref,
  CatchQuestion question,
) async {
  final Result<Resolution> result = await EvaluateCatchUseCase(
    reference: ref.watch(referenceRepositoryProvider),
  )(question);
  return switch (result) {
    Ok<Resolution>(:final Resolution value) => value,
    // Surfaced as an error, never as an absence: the screen says the pack could
    // not be read, and does not say the law is silent.
    Failure<Resolution>(:final Exception exception) => throw exception,
  };
});

/// The answer, in words, for one question in one place.
///
/// The join the whole epic was for: E03's numbers, E05's rows and E10's six
/// languages, in one value a widget can draw.
final resultDisplayProvider = FutureProvider.autoDispose
    .family<ResultDisplay, ({CatchQuestion question, ResultRequest request})>((
      Ref ref,
      ({CatchQuestion question, ResultRequest request}) arg,
    ) async {
      final Resolution resolution = await ref.watch(resolutionProvider(arg.question).future);
      final VerdictPresenter presenter = await ref.watch(
        verdictPresenterProvider(arg.request).future,
      );
      return presenter.present(resolution, arg.request.context);
    });
