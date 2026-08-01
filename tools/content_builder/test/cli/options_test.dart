// The CLI contract, and the three flag names that are rejected rather than
// merely unknown.
//
// catchlaw-content-pipeline rule 2: every assertion is fatal and there is no
// warning tier. The flag that exists is the flag CI uses at 18:00 on a Friday to
// unblock a release, so --force, --skip-assertions and --allow-missing-locale
// are declared, hidden from --help, and answered by name. Somebody will
// eventually paste one from a stale note; an explanation is cheaper than an
// argument.

import 'package:content_builder/src/cli/options.dart';
import 'package:content_builder/src/cli/usage_failure.dart';
import 'package:test/test.dart';

const List<String> kArgs = <String>[
  '--in',
  'content/',
  '--out',
  'app/assets/db/reference.db',
  '--build-date',
  '2026-08-14',
  '--generator-commit',
  '4f2c1ab',
];

List<String> without(String option) {
  final int i = kArgs.indexOf(option);
  return <String>[...kArgs.sublist(0, i), ...kArgs.sublist(i + 2)];
}

Matcher usageMentioning(String flag) => throwsA(
  isA<UsageFailure>()
      .having((UsageFailure f) => f.exitCode, 'exitCode', 2)
      .having((UsageFailure f) => f.message, 'message', contains(flag)),
);

void main() {
  group('ContentBuildOptions', () {
    test('.parse accepts the four required options', () {
      final ContentBuildOptions opts = ContentBuildOptions.parse(kArgs);

      expect(opts.inDir.path, 'content/');
      expect(opts.outFile.path, 'app/assets/db/reference.db');
      expect(opts.buildDate, DateTime.utc(2026, 8, 14));
      expect(opts.generatorCommit, '4f2c1ab');
    });

    test('.parse exits 2 when --in is missing', () {
      // A missing input directory must not read as an empty corpus. Every
      // assertion passes over nothing, and the build would emit a database with
      // no rules in it and exit 0.
      expect(() => ContentBuildOptions.parse(without('--in')), usageMentioning('--in'));
    });

    test('.parse exits 2 when --out is missing', () {
      // No default output path. A default is how a stray invocation from the
      // wrong directory overwrites the shipped asset with a partial corpus.
      expect(() => ContentBuildOptions.parse(without('--out')), usageMentioning('--out'));
    });

    test('.parse exits 2 when --build-date is missing', () {
      // T10 requires two builds of identical input to be byte-identical, so
      // DateTime.now() may not appear in the emitter. A defaulted build date
      // puts it back and makes determinism untestable.
      expect(
        () => ContentBuildOptions.parse(without('--build-date')),
        usageMentioning('--build-date'),
      );
    });

    test('.parse exits 2 when --generator-commit is missing', () {
      // content_meta.generator_commit is how a stale reference.db is traced back
      // to the tree that wrote it.
      expect(
        () => ContentBuildOptions.parse(without('--generator-commit')),
        usageMentioning('--generator-commit'),
      );
    });

    test('.parse rejects --force by name', () {
      expect(
        () => ContentBuildOptions.parse(<String>[...kArgs, '--force']),
        usageMentioning('--force'),
      );
    });

    test('.parse explains that --force will not be added', () {
      // The exit code is not the point; the sentence is. An unknown-option error
      // reads as a version skew and invites somebody to add the flag.
      expect(
        () => ContentBuildOptions.parse(<String>[...kArgs, '--force']),
        throwsA(
          isA<UsageFailure>().having(
            (UsageFailure f) => f.message,
            'message',
            allOf(contains('will not be added'), contains('every assertion is fatal')),
          ),
        ),
      );
    });

    test('.parse rejects --skip-assertions by name', () {
      expect(
        () => ContentBuildOptions.parse(<String>[...kArgs, '--skip-assertions']),
        usageMentioning('--skip-assertions'),
      );
    });

    test('.parse rejects --allow-missing-locale by name', () {
      // The third name, and the one D-3's six locales make tempting: five
      // locales resolved and one missing is exactly when somebody reaches for it.
      expect(
        () => ContentBuildOptions.parse(<String>[...kArgs, '--allow-missing-locale']),
        usageMentioning('--allow-missing-locale'),
      );
    });

    test('.parse exits 2 when --build-date is not an ISO date', () {
      // The value reaches content_meta verbatim. A locale-formatted date there
      // is unparseable for the life of the file.
      final args = <String>[...without('--build-date'), '--build-date', '14/08/2026'];

      expect(() => ContentBuildOptions.parse(args), usageMentioning('14/08/2026'));
    });

    test('.parse exits 2 when --build-date is not a real calendar date', () {
      final args = <String>[...without('--build-date'), '--build-date', '2026-02-30'];

      expect(() => ContentBuildOptions.parse(args), usageMentioning('2026-02-30'));
    });

    test('.parse derives the changelog directory from --in', () {
      // A10 writes one .md per jurisdiction beside the corpus it diffed. A
      // separate flag would let the two drift apart.
      expect(ContentBuildOptions.parse(kArgs).changelogDir.path, 'content/CHANGELOG');
    });

    test('.usage lists the four required options', () {
      expect(
        ContentBuildOptions.usage,
        allOf(
          contains('--in'),
          contains('--out'),
          contains('--build-date'),
          contains('--generator-commit'),
        ),
      );
    });

    test('.usage lists no flag that weakens an assertion', () {
      // The three rejected names are declared so they can be answered, and
      // hidden so nothing advertises them.
      expect(
        ContentBuildOptions.usage,
        isNot(
          anyOf(
            contains('--force'),
            contains('--skip-assertions'),
            contains('--allow-missing-locale'),
          ),
        ),
      );
    });
  });
}
