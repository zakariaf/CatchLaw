# analysis_defaults

The one place `flutter_lints` is declared, so that
`include: package:flutter_lints/flutter.yaml` in the root `analysis_options.yaml`
resolves for every workspace member. Each other member dev-depends on this
package; that edge is the visible record of why the include resolves.

It holds no Dart, deliberately — the lint payload is YAML at the repository root,
not code here. It therefore has **no test suite**, which is why E01/T03's workflow
lists it in the explicit `no-suite` set rather than letting a member with no tests
look the same as a member whose CI line was deleted.
