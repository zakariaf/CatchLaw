import 'package:meta/meta.dart';

/// One line of build output: `<assertion-id> <file>:<line> <message>`.
///
/// The format is fixed by
/// `catchlaw-content-pipeline/references/build-assertions.md` "Failure format".
/// It carries a location because the alternative — naming the row's `id` —
/// is not a location, and the row that fails an assertion most often is the one
/// whose id was mistyped.
///
/// Never a stack trace, never a partial database, never exit 0.
@immutable
class Failure {
  /// A failure of assertion [id] at [path] line [line].
  const Failure(this.id, this.path, this.line, this.message);

  /// The stable assertion id — `A1` … `A10`, or [kLoadFailureId] for a defect
  /// found while reading the corpus, before any assertion has run.
  final String id;

  /// The corpus-relative path of the offending file, e.g. `es-ga/rules.yaml`.
  ///
  /// Relative, never absolute: two machines must print the same line for the
  /// same defect.
  final String path;

  /// The 1-based line the defect sits on.
  final int line;

  /// What is wrong, in the author's vocabulary rather than the loader's.
  final String message;

  /// The one line this failure prints on stderr.
  String render() => '$id $path:$line $message';

  @override
  String toString() => render();
}

/// The id carried by a failure found while loading, before assertion A1 runs.
///
/// A malformed document, an unknown section and a duplicate row id are not
/// assertion failures — they are the reason the assertions cannot run at all —
/// and giving them `A1` would tell an author to consult a matrix that says
/// nothing about their problem.
const String kLoadFailureId = 'A0';

/// [failures] ordered by path then line, per "Failure format".
///
/// One build round-trip must read top to bottom the way the corpus does. Sorting
/// by insertion order instead groups by assertion, which is the order the tool
/// finds them in and not the order anybody fixes them in.
List<Failure> sortedFailures(Iterable<Failure> failures) =>
    failures.toList()..sort((Failure a, Failure b) {
      final int byPath = a.path.compareTo(b.path);
      if (byPath != 0) return byPath;
      final int byLine = a.line.compareTo(b.line);
      return byLine != 0 ? byLine : a.id.compareTo(b.id);
    });
