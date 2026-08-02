import 'package:catchlaw/l10n/numeral_system.dart';
import 'package:flutter/widgets.dart';

/// The i18n primitive this epic goldens: digits, in one locale, at one size.
///
/// A specimen and not a screen. `golden-two-lanes.md`: golden the primitives
/// exhaustively and *sample* representative screens — and there are no screens
/// yet, so fabricating one to golden would create a widget whose only consumer
/// is a test. E08 onward builds the screens and E20 owns their matrix.
///
/// It renders through [numberFormatFor], the same factory the whole app uses,
/// so a regression in the numeral lever shows up here in pixels rather than
/// only in a string comparison.
class NumeralSpecimen extends StatelessWidget {
  /// Renders the specimen.
  const NumeralSpecimen({super.key});

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String digits = numberFormatFor(locale).format(1234567);
    final String decimal = numberFormatFor(locale).format(45.5);

    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFFFFFFF)),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              digits,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 28, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            Text(
              decimal,
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 28, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            // Script coverage, not chrome. Under the default test font this
            // line is a row of identical boxes in every locale, which is
            // exactly the state the font-coverage row exists to catch.
            Text(
              locale.languageCode == 'ar' ? 'هامور كنعد' : 'Mero Ameixa',
              textAlign: TextAlign.start,
              style: const TextStyle(fontSize: 24, color: Color(0xFF1A1A1A)),
            ),
          ],
        ),
      ),
    );
  }
}
