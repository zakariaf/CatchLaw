/// The command line itself is wrong: exit 2, before a byte of the corpus is
/// read.
///
/// Distinct from a `Failure` on purpose. Exit 1 means "the content is wrong and
/// here is where"; exit 2 means "the invocation is wrong and no content was
/// examined". A build script that treats the two the same reports a mistyped
/// flag as a content defect, and somebody edits `rules.yaml` looking for it.
class UsageFailure implements Exception {
  /// A usage error explained by [message].
  const UsageFailure(this.message);

  /// What is wrong with the invocation, and — for the three rejected flags —
  /// why the flag will not be added.
  final String message;

  /// Always 2. Never 1: see the class doc.
  int get exitCode => 2;

  @override
  String toString() => 'content_builder: $message';
}
