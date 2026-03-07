// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the notification api future considering the authenticated client

@ProviderFor(notificationApi)
const notificationApiProvider = NotificationApiProvider._();

/// Returns the notification api future considering the authenticated client

final class NotificationApiProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationApi>,
          NotificationApi,
          FutureOr<NotificationApi>
        >
    with $FutureModifier<NotificationApi>, $FutureProvider<NotificationApi> {
  /// Returns the notification api future considering the authenticated client
  const NotificationApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationApiHash();

  @$internal
  @override
  $FutureProviderElement<NotificationApi> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<NotificationApi> create(Ref ref) {
    return notificationApi(ref);
  }
}

String _$notificationApiHash() => r'fbb4318f1b2790372a3cc94235395ab600e61580';

/// Describes the riverpod state for our notifications set

@ProviderFor(Notifications)
const notificationsProvider = NotificationsProvider._();

/// Describes the riverpod state for our notifications set
final class NotificationsProvider
    extends $AsyncNotifierProvider<Notifications, List<Notification>> {
  /// Describes the riverpod state for our notifications set
  const NotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @$internal
  @override
  Notifications create() => Notifications();
}

String _$notificationsHash() => r'009aa224d9066bd82a5c3b155cfa571da2386b84';

/// Describes the riverpod state for our notifications set

abstract class _$Notifications extends $AsyncNotifier<List<Notification>> {
  FutureOr<List<Notification>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<Notification>>, List<Notification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Notification>>, List<Notification>>,
              AsyncValue<List<Notification>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
