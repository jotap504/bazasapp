// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authRepositoryHash() => r'411f653aa33a93f954b2020c8a37f43b291a64d3';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepository>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepository>;
String _$currentUserHash() => r'f812fc12dce991ed694aeb3a8286dabdbeafb366';

/// Provider del usuario actual
///
/// Copied from [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$authStateChangesHash() => r'e8ccd76a465bfccd6693e67dd2dc95d627bbac61';

/// Stream de cambios de autenticación para redirigir con GoRouter
///
/// Copied from [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = AutoDisposeStreamProvider<AuthState>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthStateChangesRef = AutoDisposeStreamProviderRef<AuthState>;
String _$profileHash() => r'424ee8a3aca37f2d153a84d58fa9df588985a70d';

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

/// See also [profile].
@ProviderFor(profile)
const profileProvider = ProfileFamily();

/// See also [profile].
class ProfileFamily extends Family<AsyncValue<ProfileModel>> {
  /// See also [profile].
  const ProfileFamily();

  /// See also [profile].
  ProfileProvider call(
    String userId,
  ) {
    return ProfileProvider(
      userId,
    );
  }

  @override
  ProfileProvider getProviderOverride(
    covariant ProfileProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'profileProvider';
}

/// See also [profile].
class ProfileProvider extends AutoDisposeFutureProvider<ProfileModel> {
  /// See also [profile].
  ProfileProvider(
    String userId,
  ) : this._internal(
          (ref) => profile(
            ref as ProfileRef,
            userId,
          ),
          from: profileProvider,
          name: r'profileProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$profileHash,
          dependencies: ProfileFamily._dependencies,
          allTransitiveDependencies: ProfileFamily._allTransitiveDependencies,
          userId: userId,
        );

  ProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<ProfileModel> Function(ProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileProvider._internal(
        (ref) => create(ref as ProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ProfileModel> createElement() {
    return _ProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProfileRef on AutoDisposeFutureProviderRef<ProfileModel> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _ProfileProviderElement
    extends AutoDisposeFutureProviderElement<ProfileModel> with ProfileRef {
  _ProfileProviderElement(super.provider);

  @override
  String get userId => (origin as ProfileProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
