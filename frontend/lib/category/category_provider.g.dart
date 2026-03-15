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

String _$categoriesHash() => r'f5594818e4cd4712270896dce0b698f3a31ad1d1';

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
    r'0b9e674259cff58752149d10a91034e4840e7b5f';

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

/// Riverpod to get specific category stats given the query

@ProviderFor(categoryStats)
const categoryStatsProvider = CategoryStatsFamily._();

/// Riverpod to get specific category stats given the query

final class CategoryStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CategoryStats?>,
          CategoryStats?,
          FutureOr<CategoryStats?>
        >
    with $FutureModifier<CategoryStats?>, $FutureProvider<CategoryStats?> {
  /// Riverpod to get specific category stats given the query
  const CategoryStatsProvider._({
    required CategoryStatsFamily super.from,
    required ({int year, int? month, int? day, String? accountId})
    super.argument,
  }) : super(
         retry: null,
         name: r'categoryStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryStatsHash();

  @override
  String toString() {
    return r'categoryStatsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<CategoryStats?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CategoryStats?> create(Ref ref) {
    final argument =
        this.argument as ({int year, int? month, int? day, String? accountId});
    return categoryStats(
      ref,
      year: argument.year,
      month: argument.month,
      day: argument.day,
      accountId: argument.accountId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryStatsHash() => r'd4168268c7a8a757fde97154da28ff0c6097ce97';

/// Riverpod to get specific category stats given the query

final class CategoryStatsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<CategoryStats?>,
          ({int year, int? month, int? day, String? accountId})
        > {
  const CategoryStatsFamily._()
    : super(
        retry: null,
        name: r'categoryStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod to get specific category stats given the query

  CategoryStatsProvider call({
    required int year,
    int? month,
    int? day,
    String? accountId,
  }) => CategoryStatsProvider._(
    argument: (year: year, month: month, day: day, accountId: accountId),
    from: this,
  );

  @override
  String toString() => r'categoryStatsProvider';
}
