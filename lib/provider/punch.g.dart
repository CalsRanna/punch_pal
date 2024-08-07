// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'punch.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$overTimeHash() => r'f90f4599353482b40e6513968bd51f714123065e';

/// See also [overTime].
@ProviderFor(overTime)
final overTimeProvider = AutoDisposeFutureProvider<double>.internal(
  overTime,
  name: r'overTimeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$overTimeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef OverTimeRef = AutoDisposeFutureProviderRef<double>;
String _$punchesNotifierHash() => r'a1fc50610eaaad30d7853a521a40c0c772a4183d';

/// See also [PunchesNotifier].
@ProviderFor(PunchesNotifier)
final punchesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PunchesNotifier, List<Punch>>.internal(
  PunchesNotifier.new,
  name: r'punchesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$punchesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PunchesNotifier = AutoDisposeAsyncNotifier<List<Punch>>;
String _$punchNotifierHash() => r'de75d611485fa94b62ff5cb2877f3567b1fb3eea';

/// See also [PunchNotifier].
@ProviderFor(PunchNotifier)
final punchNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PunchNotifier, Punch>.internal(
  PunchNotifier.new,
  name: r'punchNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$punchNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PunchNotifier = AutoDisposeAsyncNotifier<Punch>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
