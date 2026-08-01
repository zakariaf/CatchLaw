#!/usr/bin/env python3
"""Regenerate the large dependency fixtures from the real resolved graph.

    dart pub deps --json | tools/gates/testdata/regenerate_deps.py

Four fixtures in `deps/` are checked against the LIVE allowlist, so every one of
them goes stale the moment a real dependency lands — E02/T02 adding `unorm_dart`
turned three of them red at once. Hand-patching a 71-package JSON file four
times per dependency is how a fixture quietly stops describing the thing it is
supposed to describe, so the derivation is written down here instead.

`deps_clean.json` is a snapshot of the real graph. The other three are that
snapshot plus ONE deliberate mutation each, and the mutation is the whole test:

    deps_extra_direct    catchlaw gains some_new_package   nobody reviewed it
    deps_missing_direct  catchlaw loses yaml               the allowlist is stale
    deps_direct_http     catchlaw gains http               SPEC.md §14, directly

The small hand-written fixtures — deps_dev_only_http, deps_two_http_edges,
deps_third_http_edge, deps_bad_url_launcher_edge — are NOT touched. They run
against their own fixture allowlists in `testdata/allowlist/` and describe a
dependency set CatchLaw does not reach until E08 and E17. Nor is
deps_truncated.json, which is deliberately invalid JSON and must stay that way.

The graph is written VERBATIM, every field pub emits. The fixtures it replaces
had been hand-trimmed to the three keys the gate reads, which made them small and
readable and also made them a shape pub never actually produces — so a gate that
broke on the real output would have kept a green test suite. E01's own Risk 5
says it: the schema is not ours. Regenerating restored `version`, `source`,
`directDependencies` and `devDependencies`, and the gate was re-run against all
four before this script was committed.

After running this, re-read `git diff` before committing. The point of the
fixtures is that a human saw the graph change.
"""

from __future__ import annotations

import json
import os
import sys

HERE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "deps")

# Each mutation is (filename, package-to-edit, packages-to-add, deps-to-remove).
MUTATIONS = [
    ("deps_extra_direct.json", "catchlaw", ["some_new_package"], []),
    ("deps_missing_direct.json", "catchlaw", [], ["yaml"]),
    ("deps_direct_http.json", "catchlaw", ["http"], []),
]


def write(path: str, doc: dict) -> None:
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(doc, fh, indent=2)
        fh.write("\n")


def main() -> int:
    raw = sys.stdin.read()
    try:
        clean = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"regenerate_deps: stdin is not the JSON graph ({e}).", file=sys.stderr)
        print("Usage: dart pub deps --json | tools/gates/testdata/regenerate_deps.py",
              file=sys.stderr)
        return 2
    if "packages" not in clean:
        print("regenerate_deps: no `packages` key — refusing to write a fixture "
              "from a graph that was never walked.", file=sys.stderr)
        return 2

    write(os.path.join(HERE, "deps_clean.json"), clean)
    print(f"deps_clean.json          {len(clean['packages'])} packages")

    for name, target, add, remove in MUTATIONS:
        doc = json.loads(json.dumps(clean))  # deep copy
        by_name = {p["name"]: p for p in doc["packages"]}
        if target not in by_name:
            print(f"regenerate_deps: {name} edits {target!r}, which is not in the "
                  f"graph. The workspace was renamed; fix MUTATIONS.", file=sys.stderr)
            return 2
        deps = by_name[target].setdefault("dependencies", [])
        for pkg in add:
            deps.append(pkg)
            if pkg not in by_name:
                doc["packages"].append(
                    {"name": pkg, "kind": "transitive", "dependencies": []})
        for pkg in remove:
            if pkg not in deps:
                print(f"regenerate_deps: {name} removes {pkg!r} from {target}, which "
                      f"no longer depends on it. The mutation is a no-op and the "
                      f"fixture would prove nothing.", file=sys.stderr)
                return 2
            deps.remove(pkg)
        write(os.path.join(HERE, name), doc)
        print(f"{name:24} {'+' + ','.join(add) if add else ''}"
              f"{'-' + ','.join(remove) if remove else ''}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
