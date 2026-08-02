import 'dart:ui' show FontFeature;

/// The four face stacks, declared once.
///
/// **System stacks, resolved offline, on device, every time.** The app bundles
/// two Noto faces for the golden lane's Arabic coverage (E06/T08) and fetches
/// nothing: the runtime-webfont package downloads at first paint, which // lonja-type: ok
/// invariant 1 forbids and
/// two separate gates grep for.
///
/// Each list is a `fontFamilyFallback`, so a device missing the first entry
/// walks down rather than tofuing.
abstract final class LonjaFaces {
  /// Anything that quotes the law, and every heading. The booklet's face.
  static const List<String> serif = <String>[
    'Iowan Old Style',
    'Palatino Linotype',
    'Palatino',
    'Book Antiqua',
    'Georgia',
    'Times New Roman',
    'serif',
  ];

  /// Chrome: buttons, navigation labels, chips.
  static const List<String> sans = <String>[
    'ui-sans-serif',
    '-apple-system',
    'Helvetica Neue',
    'Segoe UI',
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  /// Every comparable numeral. Tabular figures are what make a column of
  /// lengths readable at a glance.
  static const List<String> mono = <String>[
    'ui-monospace',
    'SF Mono',
    'Menlo',
    'Consolas',
    'DejaVu Sans Mono',
    'monospace',
  ];

  /// What every [mono] step must carry.
  ///
  /// Declared here rather than beside the ramp so the stack and the feature
  /// that makes it usable cannot be separated: a monospace face without
  /// tabular figures is a column of lengths whose digits do not line up, and
  /// `check_lonja_type.sh` check 8 fails a file that declares one without the
  /// other for exactly that reason.
  ///
  /// It is a no-op on Arabic-Indic digits, which have no tabular coverage in
  /// any mono stack — which is why an `ar` numeral column is pinned by layout
  /// rather than by figure widths (`lonja-typography`).
  static const List<FontFeature> tabular = <FontFeature>[FontFeature.tabularFigures()];

  /// Naskh forms. The Latin serif has no Arabic coverage at all.
  static const List<String> arabic = <String>[
    'Geeza Pro',
    'Al Bayan',
    'Damascus',
    'Noto Naskh Arabic',
    'Traditional Arabic',
    'serif',
  ];
}
