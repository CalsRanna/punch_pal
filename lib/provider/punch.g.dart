// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'punch.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$punchNotifierHash() => r'392faa67aa1ecee22dd0bd7ce190779676f74ae6';

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
String _$punchesNotifierHash() => r'ec0ec54411c3a360acc32f224b2178abc9a6a89a';

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

abstract class _$PunchesNotifier
    extends BuildlessAutoDisposeAsyncNotifier<List<Punch>> {
  late final int year;
  late final int month;
  late final int? day;

  FutureOr<List<Punch>> build(
    int year,
    int month, [
    int? day,
  ]);
}

/// See also [PunchesNotifier].
@ProviderFor(PunchesNotifier)
const punchesNotifierProvider = PunchesNotifierFamily();

/// See also [PunchesNotifier].
class PunchesNotifierFamily extends Family<AsyncValue<List<Punch>>> {
  /// See also [PunchesNotifier].
  const PunchesNotifierFamily();

  /// See also [PunchesNotifier].
  PunchesNotifierProvider call(
    int year,
    int month, [
    int? day,
  ]) {
    return PunchesNotifierProvider(
      year,
      month,
      day,
    );
  }

  @override
  PunchesNotifierProvider getProviderOverride(
    covariant PunchesNotifierProvider provider,
  ) {
    return call(
      provider.year,
      provider.month,
      provider.day,
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
  String? get name => r'punchesNotifierProvider';
}

/// See also [PunchesNotifier].
class PunchesNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PunchesNotifier, List<Punch>> {
  /// See also [PunchesNotifier].
  PunchesNotifierProvider(
    int year,
    int month, [
    int? day,
  ]) : this._internal(
          () => PunchesNotifier()
            ..year = year
            ..month = month
            ..day = day,
          from: punchesNotifierProvider,
          name: r'punchesNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$punchesNotifierHash,
          dependencies: PunchesNotifierFamily._dependencies,
          allTransitiveDependencies:
              PunchesNotifierFamily._allTransitiveDependencies,
          year: year,
          month: month,
          day: day,
        );

  PunchesNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.year,
    required this.month,
    required this.day,
  }) : super.internal();

  final int year;
  final int month;
  final int? day;

  @override
  FutureOr<List<Punch>> runNotifierBuild(
    covariant PunchesNotifier notifier,
  ) {
    return notifier.build(
      year,
      month,
      day,
    );
  }

  @override
  Override overrideWith(PunchesNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PunchesNotifierProvider._internal(
        () => create()
          ..year = year
          ..month = month
          ..day = day,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        year: year,
        month: month,
        day: day,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PunchesNotifier, List<Punch>>
      createElement() {
    return _PunchesNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PunchesNotifierProvider &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);
    hash = _SystemHash.combine(hash, day.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PunchesNotifierRef on AutoDisposeAsyncNotifierProviderRef<List<Punch>> {
  /// The parameter `year` of this provider.
  int get year;

  /// The parameter `month` of this provider.
  int get month;

  /// The parameter `day` of this provider.
  int? get day;
}

class _PunchesNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PunchesNotifier,
        List<Punch>> with PunchesNotifierRef {
  _PunchesNotifierProviderElement(super.provider);

  @override
  int get year => (origin as PunchesNotifierProvider).year;
  @override
  int get month => (origin as PunchesNotifierProvider).month;
  @override
  int? get day => (origin as PunchesNotifierProvider).day;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
