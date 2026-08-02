/// The ISO/IEC 7810 ID-1 card, and the bounds a calibration must fall inside.
///
/// **The scale is measured, never derived.** Flutter cannot tell you a panel's
/// physical DPI: `devicePixelRatio` is a logical-to-physical ratio and no
/// arithmetic on it yields millimetres. A constant scale is a saved 40% error —
/// `check_measurement.sh` check 5 fails one — so the fisher lays a card he
/// already carries on the glass and drags to its edge, and the app divides.
///
/// ID-1 is the right card because he already has one: a bank card, a driving
/// licence and an Emirates ID are all ID-1, to a tolerance far tighter than a
/// fish measurement needs.
library;

/// 85.60 mm — ISO/IEC 7810 ID-1 width.
const double kId1WidthMm = 85.60;

/// 53.98 mm — ISO/IEC 7810 ID-1 height.
const double kId1HeightMm = 53.98;

/// 3.18 mm — ISO/IEC 7810 ID-1 corner radius.
///
/// Drawn on the calibration outline so the fisher can see the card is seated
/// square rather than merely overlapping.
const double kId1CornerRadiusMm = 3.18;

/// 6.299 px/mm — a 160 dpi reference panel.
///
/// A **starting position** for the drag handle and nothing else. It is never
/// stored, never used to measure, and never a fallback: a length computed from
/// a nominal scale is a number nobody measured presented as one somebody did.
///
/// It carries `check_measurement.sh`'s documented hatch, and the hatch is only
/// honest because `no_nominal_scale_test.dart` asserts the claim above — that
/// no file which divides by a scale can see this constant at all.
const double kNominalPxPerMm = 6.299; // measurement-ok: a handle position, never a scale

/// 4.50 px/mm — below this, the card was dragged too small.
///
/// The window is deliberately wide. It exists to catch a drag that clearly did
/// not trace a card — a handle nudged to the screen edge, a double-tap that
/// collapsed it — and not to second-guess a fisher whose phone is unusual.
const double kMinPxPerMm = 4.50; // measurement-ok: a validity bound, never a scale

/// 9.00 px/mm — above this, the card was dragged too large.
const double kMaxPxPerMm = 9.00; // measurement-ok: a validity bound, never a scale

/// Whether [pxPerMm] could plausibly have come from tracing an ID-1 card.
bool isPlausiblePxPerMm(double pxPerMm) => pxPerMm >= kMinPxPerMm && pxPerMm <= kMaxPxPerMm;
