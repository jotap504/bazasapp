// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matches_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$matchesRepositoryHash() => r'b1c58ac3621f229555bf95aab09f2df98e55b99d';

/// See also [matchesRepository].
@ProviderFor(matchesRepository)
final matchesRepositoryProvider =
    AutoDisposeProvider<MatchesRepository>.internal(
  matchesRepository,
  name: r'matchesRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$matchesRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MatchesRepositoryRef = AutoDisposeProviderRef<MatchesRepository>;
String _$groupMatchesHash() => r'fab7ac9bf2b5c15a458559579818661dbc641982';

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

/// See also [groupMatches].
@ProviderFor(groupMatches)
const groupMatchesProvider = GroupMatchesFamily();

/// See also [groupMatches].
class GroupMatchesFamily extends Family<AsyncValue<List<MatchModel>>> {
  /// See also [groupMatches].
  const GroupMatchesFamily();

  /// See also [groupMatches].
  GroupMatchesProvider call(
    String groupId,
  ) {
    return GroupMatchesProvider(
      groupId,
    );
  }

  @override
  GroupMatchesProvider getProviderOverride(
    covariant GroupMatchesProvider provider,
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
  String? get name => r'groupMatchesProvider';
}

/// See also [groupMatches].
class GroupMatchesProvider extends AutoDisposeFutureProvider<List<MatchModel>> {
  /// See also [groupMatches].
  GroupMatchesProvider(
    String groupId,
  ) : this._internal(
          (ref) => groupMatches(
            ref as GroupMatchesRef,
            groupId,
          ),
          from: groupMatchesProvider,
          name: r'groupMatchesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupMatchesHash,
          dependencies: GroupMatchesFamily._dependencies,
          allTransitiveDependencies:
              GroupMatchesFamily._allTransitiveDependencies,
          groupId: groupId,
        );

  GroupMatchesProvider._internal(
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
    FutureOr<List<MatchModel>> Function(GroupMatchesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupMatchesProvider._internal(
        (ref) => create(ref as GroupMatchesRef),
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
  AutoDisposeFutureProviderElement<List<MatchModel>> createElement() {
    return _GroupMatchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupMatchesProvider && other.groupId == groupId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, groupId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupMatchesRef on AutoDisposeFutureProviderRef<List<MatchModel>> {
  /// The parameter `groupId` of this provider.
  String get groupId;
}

class _GroupMatchesProviderElement
    extends AutoDisposeFutureProviderElement<List<MatchModel>>
    with GroupMatchesRef {
  _GroupMatchesProviderElement(super.provider);

  @override
  String get groupId => (origin as GroupMatchesProvider).groupId;
}

String _$matchResultsHash() => r'8824ed8d42b14f6234a57c2fae6c7a118cf0b15b';

/// See also [matchResults].
@ProviderFor(matchResults)
const matchResultsProvider = MatchResultsFamily();

/// See also [matchResults].
class MatchResultsFamily extends Family<AsyncValue<List<MatchResultModel>>> {
  /// See also [matchResults].
  const MatchResultsFamily();

  /// See also [matchResults].
  MatchResultsProvider call(
    String matchId,
  ) {
    return MatchResultsProvider(
      matchId,
    );
  }

  @override
  MatchResultsProvider getProviderOverride(
    covariant MatchResultsProvider provider,
  ) {
    return call(
      provider.matchId,
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
  String? get name => r'matchResultsProvider';
}

/// See also [matchResults].
class MatchResultsProvider
    extends AutoDisposeFutureProvider<List<MatchResultModel>> {
  /// See also [matchResults].
  MatchResultsProvider(
    String matchId,
  ) : this._internal(
          (ref) => matchResults(
            ref as MatchResultsRef,
            matchId,
          ),
          from: matchResultsProvider,
          name: r'matchResultsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$matchResultsHash,
          dependencies: MatchResultsFamily._dependencies,
          allTransitiveDependencies:
              MatchResultsFamily._allTransitiveDependencies,
          matchId: matchId,
        );

  MatchResultsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.matchId,
  }) : super.internal();

  final String matchId;

  @override
  Override overrideWith(
    FutureOr<List<MatchResultModel>> Function(MatchResultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchResultsProvider._internal(
        (ref) => create(ref as MatchResultsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        matchId: matchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MatchResultModel>> createElement() {
    return _MatchResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchResultsProvider && other.matchId == matchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, matchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MatchResultsRef on AutoDisposeFutureProviderRef<List<MatchResultModel>> {
  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _MatchResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<MatchResultModel>>
    with MatchResultsRef {
  _MatchResultsProviderElement(super.provider);

  @override
  String get matchId => (origin as MatchResultsProvider).matchId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
