import 'package:meta/meta.dart';

/// One species the key still allows.
///
/// The same three facts S6's grid carries, and for the same reason: a candidate
/// list a fisher cannot recognise by shape is a list he has to read name by
/// name, which is the work the key exists to save.
@immutable
final class KeyCandidate {
  /// A candidate, drawn and named.
  const KeyCandidate({
    required this.speciesId,
    required this.displayName,
    required this.scientificName,
    required this.silhouetteAsset,
  });

  /// The species this candidate is.
  final int speciesId;

  /// The name in the reader's own language, already resolved.
  final String displayName;

  /// The binomial — the one name that is the same in every port.
  final String scientificName;

  /// `species.silhouette_asset`, as authored.
  final String silhouetteAsset;

  @override
  bool operator ==(Object other) =>
      other is KeyCandidate &&
      other.speciesId == speciesId &&
      other.displayName == displayName &&
      other.scientificName == scientificName &&
      other.silhouetteAsset == silhouetteAsset;

  @override
  int get hashCode => Object.hash(speciesId, displayName, scientificName, silhouetteAsset);
}

/// One answer to a couplet's question.
///
/// **`nextNodeId` may be null and that is a transcribed answer, not a fault.**
/// `SPEC.md` §7.1 records a null `next_node_id` as the key's terminal state, so
/// a lead with nothing under it is drawn like any other and says what it
/// reaches.
@immutable
final class KeyLead {
  /// One answer, with what taking it still allows.
  const KeyLead({
    required this.optionId,
    required this.mark,
    required this.label,
    required this.figureAsset,
    required this.nextNodeId,
    required this.candidates,
  });

  /// `key_option.id`.
  final int optionId;

  /// Which answer of the couplet this is, counting from one.
  final int mark;

  /// The character as the key states it, already resolved into the locale.
  final String label;

  /// The figure beside it, or `null` when the pack draws none.
  final String? figureAsset;

  /// Where this answer leads, or `null` where the key ends.
  final int? nextNodeId;

  /// What is still possible after taking it.
  final List<KeyCandidate> candidates;

  @override
  bool operator ==(Object other) =>
      other is KeyLead &&
      other.optionId == optionId &&
      other.mark == mark &&
      other.label == label &&
      other.figureAsset == figureAsset &&
      other.nextNodeId == nextNodeId;

  @override
  int get hashCode => Object.hash(optionId, mark, label, figureAsset, nextNodeId);
}

/// One step of the key: a couplet, or the place the key stops.
///
/// A single type for both, because the screen renders both from the same node:
/// [leads] empty is a leaf, and [candidates] is what remains either way.
@immutable
final class KeyStep {
  /// The node, its question and its answers.
  const KeyStep({
    required this.nodeId,
    required this.question,
    required this.leads,
    required this.candidates,
  });

  /// `key_node.id`.
  final int nodeId;

  /// The question, already resolved, or `null` at a leaf.
  final String? question;

  /// The answers, in the key's own order. Empty at a leaf.
  final List<KeyLead> leads;

  /// Every species this node still allows.
  final List<KeyCandidate> candidates;

  /// Whether the key stops here.
  bool get isLeaf => leads.isEmpty;
}
