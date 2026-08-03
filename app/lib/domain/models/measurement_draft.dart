import 'dart:collection';

import 'package:meta/meta.dart';

/// A measurement in progress: the segments marked so far, and the last length
/// that was actually accepted.
///
/// A fish longer than the phone is measured in **segments** — mark at the tail,
/// slide the fish, mark again — so the draft is a list rather than a number.
@immutable
class MeasurementDraft {
  /// A draft with [segmentsMm] marked, over a [committedMm] already accepted.
  MeasurementDraft({List<int> segmentsMm = const <int>[], this.committedMm})
    : segmentsMm = UnmodifiableListView<int>(segmentsMm);

  /// Each marked run, in millimetres.
  final UnmodifiableListView<int> segmentsMm;

  /// The last length the fisher accepted, or `null` before any.
  final int? committedMm;

  /// The segments so far.
  int get totalMm => segmentsMm.fold(0, (int sum, int mm) => sum + mm);

  /// Whether anything is marked.
  bool get isEmpty => segmentsMm.isEmpty;

  /// Adds [segmentMm] to the run.
  MeasurementDraft mark(int segmentMm) =>
      MeasurementDraft(segmentsMm: <int>[...segmentsMm, segmentMm], committedMm: committedMm);

  /// Removes the last segment.
  ///
  /// Undo on an empty draft is a no-op rather than an error: a fisher tapping
  /// undo twice with wet hands has not done anything wrong.
  MeasurementDraft undo() => segmentsMm.isEmpty
      ? this
      : MeasurementDraft(
          segmentsMm: segmentsMm.sublist(0, segmentsMm.length - 1),
          committedMm: committedMm,
        );

  /// Abandons the marks in progress.
  ///
  /// **Restores; it does not clear.** [committedMm] is carried through
  /// unchanged — never zero, never null. Wet hands hit cancel by accident, and
  /// a cancel that wiped an accepted 380 mm would cost a measurement that
  /// cannot be retaken once the fish is in the bin.
  MeasurementDraft cancel() => MeasurementDraft(committedMm: committedMm);

  /// Commits the current total.
  ///
  /// Accepting an empty draft leaves the previous commitment alone, for the
  /// same reason cancel does: a stray tap must not turn a real measurement into
  /// zero, which would read as a fish of no length rather than as no
  /// measurement at all.
  MeasurementDraft accept() => segmentsMm.isEmpty ? this : MeasurementDraft(committedMm: totalMm);

  @override
  bool operator ==(Object other) =>
      other is MeasurementDraft &&
      other.committedMm == committedMm &&
      _sameSegments(other.segmentsMm);

  /// Compared by hand rather than with `listEquals`.
  ///
  /// That helper lives in `package:flutter/foundation.dart`, and nothing under
  /// `app/lib/domain/` may import Flutter — `check_rule_engine.sh`, which
  /// `check_app_invariants` fans out over `app/lib`, rejects it. A domain type
  /// that needed the framework to compare two ints would not be a domain type.
  bool _sameSegments(List<int> other) {
    if (other.length != segmentsMm.length) return false;
    for (var i = 0; i < other.length; i++) {
      if (other[i] != segmentsMm[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(committedMm, Object.hashAll(segmentsMm));

  @override
  String toString() => 'MeasurementDraft($segmentsMm -> $totalMm, committed: $committedMm)';
}
