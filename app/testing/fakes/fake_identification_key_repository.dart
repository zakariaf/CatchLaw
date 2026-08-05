import 'package:catchlaw/data/repositories/identification_key_repository.dart';
import 'package:catchlaw/domain/models/key_step.dart';
import 'package:rule_engine/rule_engine.dart' show Result;

/// An in-memory [IdentificationKeyRepository].
///
/// Serves a key held as a node map, so a test states the tree it wants rather
/// than the sequence of calls the screen will make.
final class FakeIdentificationKeyRepository implements IdentificationKeyRepository {
  /// Serves [nodes], entered at [rootNodeId], or fails every call with
  /// [failure].
  FakeIdentificationKeyRepository({
    this.nodes = const <int, KeyStep>{},
    this.rootNodeId,
    this.failure,
  });

  /// Every node this key carries, by id.
  final Map<int, KeyStep> nodes;

  /// Where the key starts, or null for a pack that carries no key.
  final int? rootNodeId;

  /// What every call fails with, when the test is about a broken store.
  final Exception? failure;

  /// Every node this repository was asked for, in order.
  final List<int> asked = <int>[];

  @override
  Future<Result<KeyStep?>> firstStep({required String locale}) async {
    if (failure != null) return Result<KeyStep?>.error(failure!);
    final int? root = rootNodeId;
    if (root == null) return const Result<KeyStep?>.ok(null);
    asked.add(root);
    return Result<KeyStep?>.ok(nodes[root]);
  }

  @override
  Future<Result<KeyStep?>> stepAt(int nodeId, {required String locale}) async {
    if (failure != null) return Result<KeyStep?>.error(failure!);
    asked.add(nodeId);
    return Result<KeyStep?>.ok(nodes[nodeId]);
  }
}
