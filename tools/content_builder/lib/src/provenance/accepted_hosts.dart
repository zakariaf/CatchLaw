import 'package:meta/meta.dart';

/// What a jurisdiction's law may be sourced from, and whether its licence basis
/// has been confirmed.
///
/// Transcribed from
/// `catchlaw-content-pipeline/references/licence-provenance.md` §"Sourcing: the
/// gazette, and nothing else" and the `SPEC.md` §8 bundled-data table.
@immutable
class JurisdictionProvenance {
  /// The hosts and the verification state of one jurisdiction.
  const JurisdictionProvenance({required this.hosts, required this.verified, required this.basis});

  /// The `source_url` hosts a citation may point at.
  ///
  /// Matched by suffix, so `www.xunta.gal` and `xunta.gal` both pass and
  /// `xunta.gal.example.com` does not.
  final Set<String> hosts;

  /// Whether the copyright provision that lets this jurisdiction's law be
  /// bundled has been independently confirmed.
  ///
  /// `SPEC.md` §8 marks the Gulf basis "cited but not independently verified in
  /// this session" and says it must be confirmed **before that state's content
  /// ships**. Encoding it here makes that a gate on the data rather than a memo:
  /// a `false` entry fails A9 for every citation in the jurisdiction.
  final bool verified;

  /// The provision relied on, quoted well enough to be looked up.
  final String basis;
}

/// Every jurisdiction whose law may be bundled, by `SPEC.md` §7.1 code.
///
/// A jurisdiction with **no entry here fails A9**. Silence is not permission: an
/// unlisted jurisdiction is one nobody has checked the copyright position for,
/// and the failure mode of guessing is an infringement claim against a
/// fisheries-safety app.
///
/// E22 adds a jurisdiction and its hosts in one place, and adding it forces the
/// `verified` decision rather than allowing it to be deferred.
const Map<String, JurisdictionProvenance> kAcceptedHosts = <String, JurisdictionProvenance>{
  'ES-GA': JurisdictionProvenance(
    hosts: <String>{'boe.es', 'xunta.gal'},
    verified: true,
    basis:
        'Art. 13 TRLPI — disposiciones legales o reglamentarias are not objects '
        'of intellectual property; verified at boe.es (BOE-A-1996-8930)',
  ),
  'BR-SP': JurisdictionProvenance(
    hosts: <String>{'in.gov.br', 'imprensaoficial.com.br'},
    verified: true,
    basis:
        'Lei 9.610/1998 art. 8, IV — os textos de leis, decretos, regulamentos '
        'and demais atos oficiais; verified at planalto.gov.br',
  ),
  'AE-RK': JurisdictionProvenance(
    hosts: <String>{'elaws.moj.gov.ae', 'uaelegislation.gov.ae'},
    // SPEC.md §8: cited but NOT independently verified. Federal Decree-Law 38
    // of 2021 Art. 3 must be confirmed, and an equivalent provision quoted for
    // each additional Gulf state, before that state's content ships. Flipping
    // this to true is a decision with a name on it, not a build fix.
    verified: false,
    basis:
        'UAE Federal Decree-Law 38 of 2021 Art. 3 — official documents '
        'including the texts of laws, regulations, resolutions and decisions; '
        'CITED BUT NOT INDEPENDENTLY VERIFIED (SPEC.md §8)',
  ),
};

/// Whether [host] is [accepted] or a subdomain of it.
///
/// Suffix-matched on a label boundary: `www.xunta.gal` passes for `xunta.gal`
/// and `xunta.gal.example.com` does not, which is the whole point — a
/// lookalike domain is exactly how a third-party copy of a gazette gets cited.
bool hostMatches(String host, String accepted) => host == accepted || host.endsWith('.$accepted');
