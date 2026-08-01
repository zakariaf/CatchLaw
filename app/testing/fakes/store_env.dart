/// The worlds a fake store can be put in.
///
/// **A named case, not a boolean.** `testing-strategy`'s point is that "what
/// happens when the write fails" has to be a value a test can loop over, or it
/// is a case nobody writes: the happy path gets six tests and the disk-full
/// path gets none, and the disk-full path is the one that loses a fisher's
/// record.
library;

import 'package:catchlaw/data/repositories/data_failure.dart';

/// What the store does when it is used.
enum StoreEnv {
  /// Reads answer, writes persist.
  healthy,

  /// Reads answer with nothing. Writes still persist.
  ///
  /// A first launch, and the state a search must render as "no rule recorded"
  /// rather than as an empty screen that looks like a bug.
  empty,

  /// Reads answer; every write fails with [DataConstraintViolated].
  writeFails,

  /// Nothing works. The database could not be opened at all.
  storeUnavailable,

  /// **Writes report `Ok` and store nothing.**
  ///
  /// The honest one. No test in this suite can tell this world from
  /// [healthy] — that is what makes it worth naming rather than leaving out:
  /// it is the failure the automated suite structurally cannot catch, and it is
  /// why E21 keeps a manual pass on a real device with the app force-killed
  /// between the write and the read.
  ///
  /// Excluded from [detectable] for exactly that reason. Adding it there would
  /// not find the bug; it would only make the suite red and teach somebody to
  /// weaken the assertion.
  corruptButReportsOk;

  /// The worlds a test can hold a store to.
  ///
  /// Everything except [corruptButReportsOk].
  static const Set<StoreEnv> detectable = <StoreEnv>{healthy, empty, writeFails, storeUnavailable};

  /// The failure this world produces on a write, or `null` if it produces none.
  DataFailure? get writeFailure => switch (this) {
    StoreEnv.healthy || StoreEnv.empty || StoreEnv.corruptButReportsOk => null,
    StoreEnv.writeFails => const DataConstraintViolated(field: 'outcome'),
    StoreEnv.storeUnavailable => const DataStoreUnavailable(),
  };

  /// The failure this world produces on a read, or `null`.
  DataFailure? get readFailure =>
      this == StoreEnv.storeUnavailable ? const DataStoreUnavailable() : null;

  /// Whether a write in this world actually stores anything.
  bool get writePersists => this == StoreEnv.healthy || this == StoreEnv.empty;
}
