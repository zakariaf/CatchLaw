import 'package:catchlaw/ui/species/widgets/species_browse_screen.dart';
import 'package:catchlaw/ui/species/widgets/species_detail_screen.dart';
import 'package:flutter/material.dart';

/// The rule book, browsed rather than asked.
///
/// **This screen builds nothing.** `SpeciesBrowseScreen` is S6 and has been
/// complete, tested and unreachable since E08: a plate of silhouettes grouped
/// by family, headed by its own ruled bar. The Reference branch renders a
/// placeholder for a release because nothing routed to it — not because the
/// screen did not exist.
///
/// **Check asks a question; Reference answers browsing.** `SPEC.md` §4.3 wants
/// three ways into a species and the difference is the entry, not the content:
/// Check starts from a name the fisher already has, Reference starts from a
/// shape he does not. Both land on the same S2, which is why this file adds a
/// route and no second copy of the detail screen.
class ReferenceScreen extends StatelessWidget {
  /// Opens the browse grid.
  const ReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void open(int speciesId) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => SpeciesDetailScreen(speciesId: speciesId),
        ),
      );
    }

    // No second title over it. `SpeciesBrowseScreen` heads itself with the
    // ruled bar the branch is read from — "Browse by shape", stamped with what
    // the pack carries — and a "Reference" heading above that is two screen
    // titles stacked, one of which names a branch the nav strip already has
    // lit. The page is one page and it says so once.
    return SpeciesBrowseScreen(onSpeciesChosen: open);
  }
}
