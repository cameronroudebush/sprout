// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(categoryApi)
const categoryApiProvider = CategoryApiProvider._();

final class CategoryApiProvider
    extends
        $FunctionalProvider<
          AsyncValue<CategoryApi>,
          CategoryApi,
          FutureOr<CategoryApi>
        >
    with $FutureModifier<CategoryApi>, $FutureProvider<CategoryApi> {
  const CategoryApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryApiHash();

  @$internal
  @override
  $FutureProviderElement<CategoryApi> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CategoryApi> create(Ref ref) {
    return categoryApi(ref);
  }
}

String _$categoryApiHash() => r'e91826b9e39ef37c3567625243b0e73bd61f0571';

@ProviderFor(Categories)
const categoriesProvider = CategoriesProvider._();

final class CategoriesProvider
    extends $AsyncNotifierProvider<Categories, List<Category>> {
  const CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  Categories create() => Categories();
}

String _$categoriesHash() => r'b427437fb31a61b5d4c3994a97a1fe8dc19de290';

abstract class _$Categories extends $AsyncNotifier<List<Category>> {
  FutureOr<List<Category>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Category>>, List<Category>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Category>>, List<Category>>,
              AsyncValue<List<Category>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Tracks the state for the unknown category count

@ProviderFor(UnknownCategoryCount)
const unknownCategoryCountProvider = UnknownCategoryCountFamily._();

/// Tracks the state for the unknown category count
final class UnknownCategoryCountProvider
    extends $AsyncNotifierProvider<UnknownCategoryCount, int> {
  /// Tracks the state for the unknown category count
  const UnknownCategoryCountProvider._({
    required UnknownCategoryCountFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'unknownCategoryCountProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$unknownCategoryCountHash();

  @override
  String toString() {
    return r'unknownCategoryCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UnknownCategoryCount create() => UnknownCategoryCount();

  @override
  bool operator ==(Object other) {
    return other is UnknownCategoryCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unknownCategoryCountHash() =>
    r'869f2703a8d746f0fcb0dad8dfa344dd4a3b629b';

/// Tracks the state for the unknown category count

final class UnknownCategoryCountFamily extends $Family
    with
        $ClassFamilyOverride<
          UnknownCategoryCount,
          AsyncValue<int>,
          int,
          FutureOr<int>,
          String?
        > {
  const UnknownCategoryCountFamily._()
    : super(
        retry: null,
        name: r'unknownCategoryCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Tracks the state for the unknown category count

  UnknownCategoryCountProvider call([String? accountId]) =>
      UnknownCategoryCountProvider._(argument: accountId, from: this);

  @override
  String toString() => r'unknownCategoryCountProvider';
}

/// Tracks the state for the unknown category count

abstract class _$UnknownCategoryCount extends $AsyncNotifier<int> {
  late final _$args = ref.$arg as String?;
  String? get accountId => _$args;

  FutureOr<int> build([String? accountId]);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
