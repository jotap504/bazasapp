// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groups_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupsRepositoryHash() => r'a74ad0856fd54b73f7838f5f7ffb8f4f87e648f5';

/// See also [groupsRepository].
@ProviderFor(groupsRepository)
final groupsRepositoryProvider = AutoDisposeProvider<GroupsRepository>.internal(
  groupsRepository,
  name: r'groupsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GroupsRepositoryRef = AutoDisposeProviderRef<GroupsRepository>;
String _$myGroupsHash() => r'39de62af51b508aea939f913d635ee1f54ddd470';

/// See also [myGroups].
@ProviderFor(myGroups)
final myGroupsProvider = AutoDisposeFutureProvider<List<GroupModel>>.internal(
  myGroups,
  name: r'myGroupsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$myGroupsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MyGroupsRef = AutoDisposeFutureProviderRef<List<GroupModel>>;
String _$groupByIdHash() => r'ce04823d77c6f57f456d975d009cf6d812db1221';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [groupById].
@ProviderFor(groupById)
const groupByIdProvider = GroupByIdFamily();

/// See also [groupById].
class GroupByIdFamily extends Family<AsyncValue<GroupModel>> {
  /// See also [groupById].
  const GroupByIdFamily();

  /// See also [groupById].
  GroupByIdProvider call(
    String groupId,
  ) {
    return GroupByIdProvider(
      groupId,
    );
  }

  @override
  GroupByIdProvider getProviderOverride(
    covariant GroupByIdProvider provider,
  ) {
    return call(
      provider.groupId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupByIdProvider';
}

/// See also [groupById].
class GroupByIdProvider extends AutoDisposeFutureProvider<GroupModel> {
  /// See also [groupById].
  GroupByIdProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupById(
            ref as GroupByIdRef,
            groupId,
          ),
          from: groupByIdProvider,
          name: r'groupByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupByIdHash,
          dependencies: GroupByIdFamily._dependencies,
          allTransitiveDependencies: GroupByIdFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<GroupModel> Function(GroupByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupByIdProvider._internal(
        (ref) => create(ref as GroupByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<GroupModel> createElement() {
    return _GroupByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupByIdProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupByIdRef on AutoDisposeFutureProviderRef<GroupModel> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupByIdProviderElement
    extends AutoDisposeFutureProviderElement<GroupModel> with GroupByIdRef {
  _GroupByIdProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupByIdProvider).groupId;
}

String _$groupMembersHash() => r'07a5f3cc7f7e6b7f65f4809328ee7f928cade70a';

/// See also [groupMembers].
@ProviderFor(groupMembers)
const groupMembersProvider = GroupMembersFamily();

/// See also [groupMembers].
class GroupMembersFamily extends Family<AsyncValue<List<GroupMemberModel>>> {
  /// See also [groupMembers].
  const GroupMembersFamily();

  /// See also [groupMembers].
  GroupMembersProvider call(
    String groupId,
  ) {
    return GroupMembersProvider(
      groupId,
    );
  }

  @override
  GroupMembersProvider getProviderOverride(
    covariant GroupMembersProvider provider,
  ) {
    return call(
      provider.groupId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupMembersProvider';
}

/// See also [groupMembers].
class GroupMembersProvider
    extends AutoDisposeFutureProvider<List<GroupMemberModel>> {
  /// See also [groupMembers].
  GroupMembersProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupMembers(
            ref as GroupMembersRef,
            groupId,
          ),
          from: groupMembersProvider,
          name: r'groupMembersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupMembersHash,
          dependencies: GroupMembersFamily._dependencies,
          allTransitiveDependencies:
              GroupMembersFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    FutureOr<List<GroupMemberModel>> Function(GroupMembersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupMembersProvider._internal(
        (ref) => create(ref as GroupMembersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GroupMemberModel>> createElement() {
    return _GroupMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMembersProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupMembersRef on AutoDisposeFutureProviderRef<List<GroupMemberModel>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupMembersProviderElement
    extends AutoDisposeFutureProviderElement<List<GroupMemberModel>>
    with GroupMembersRef {
  _GroupMembersProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupMembersProvider).groupId;
}

String _$groupRankingStreamHash() =>
    r'8fce7bb11fcb81bea3a1c4cea11915f9a93d12a2';

/// See also [groupRankingStream].
@ProviderFor(groupRankingStream)
const groupRankingStreamProvider = GroupRankingStreamFamily();

/// See also [groupRankingStream].
class GroupRankingStreamFamily
    extends Family<AsyncValue<List<GroupMemberModel>>> {
  /// See also [groupRankingStream].
  const GroupRankingStreamFamily();

  /// See also [groupRankingStream].
  GroupRankingStreamProvider call(
    String groupId,
  ) {
    return GroupRankingStreamProvider(
      groupId,
    );
  }

  @override
  GroupRankingStreamProvider getProviderOverride(
    covariant GroupRankingStreamProvider provider,
  ) {
    return call(
      provider.groupId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupRankingStreamProvider';
}

/// See also [groupRankingStream].
class GroupRankingStreamProvider
    extends AutoDisposeStreamProvider<List<GroupMemberModel>> {
  /// See also [groupRankingStream].
  GroupRankingStreamProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupRankingStream(
            ref as GroupRankingStreamRef,
            groupId,
          ),
          from: groupRankingStreamProvider,
          name: r'groupRankingStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupRankingStreamHash,
          dependencies: GroupRankingStreamFamily._dependencies,
          allTransitiveDependencies:
              GroupRankingStreamFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupRankingStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.groupId,
  }) : super.internal();

  final String groupId;

  @override
  Override overrideWith(
    Stream<List<GroupMemberModel>> Function(GroupRankingStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupRankingStreamProvider._internal(
        (ref) => create(ref as GroupRankingStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        groupId: groupId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<GroupMemberModel>> createElement() {
    return _GroupRankingStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupRankingStreamProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupRankingStreamRef
    on AutoDisposeStreamProviderRef<List<GroupMemberModel>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupRankingStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<GroupMemberModel>>
    with GroupRankingStreamRef {
  _GroupRankingStreamProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupRankingStreamProvider).groupId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
