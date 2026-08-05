import 'package:catchlaw/data/services/reference_install_progress.dart';

/// [bytes] as whole kilobytes.
///
/// **Display only, and rounded.** The bar carries the precision; a manifest of
/// four raw byte counts is four numbers nobody can hold in their head, and the
/// figure a fisher compares against another device is the round one.
int kilobytesOf(int bytes) => (bytes / 1024).round();

/// How far along the stream a stage is.
///
/// **Three states, not a bool.** *Being written* and *not reached yet* are
/// different facts about the same file, and a manifest that printed them alike
/// would be claiming work that has not begun.
enum FirstRunStageState {
  /// The stream has not reached this stage.
  pending,

  /// The bytes for this stage are being written now.
  running,

  /// Every byte in this stage's share is on disk.
  done,
}

/// What the one-time extraction is writing, as four contiguous shares.
///
/// **These are quarters of ONE gzip stream, not four files.** `reference.db`
/// arrives as a single decompressed byte stream, so the only thing the
/// installer can honestly report is how much of it has landed; the four names
/// say what that file is made of, in the order SQLite laid the tables down.
/// The figure printed beside each is a byte count and nothing else — no stage
/// claims a row count it has not read, and none of them says anything about
/// what the law contains.
///
/// Splitting a byte figure across four labels rather than printing one number
/// four times is the whole point of a manifest: a fisher watching a bar with no
/// itemisation cannot tell a slow install from a stalled one.
enum FirstRunStage {
  /// The rule rows themselves.
  rulePack,

  /// The verbatim articles as published.
  legalText,

  /// The line art, one file per species.
  speciesPlates,

  /// The glossary and the identification key.
  glossary;

  /// The fraction of the stream at which this stage begins.
  double get beginsAt => index / values.length;

  /// The fraction at which this stage is fully written.
  double get completesAt => (index + 1) / values.length;

  /// This stage's share of [totalBytes].
  int shareOf(int totalBytes) => (totalBytes / values.length).round();

  /// Where [progress] leaves this stage.
  FirstRunStageState stateIn(ReferenceInstallProgress progress) {
    final double fraction = progress.fraction;
    if (fraction >= completesAt) return FirstRunStageState.done;
    // `>` and not `>=`: at exactly 0.0 nothing is running, and a manifest whose
    // first line said `In progress…` before a byte had landed would be the
    // spinner this screen exists to avoid.
    if (fraction > beginsAt) return FirstRunStageState.running;
    return FirstRunStageState.pending;
  }
}
