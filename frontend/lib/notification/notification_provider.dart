import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/notification/firebase.dart';

/// Class that provides the store of current net worth information
class NotificationProvider extends BaseProvider<NotificationApi> {
  List<Notification> _notifications = [];

  /// Public getters
  List<Notification> get notifications => _notifications;

  NotificationProvider(super.api);

  /// Populates notifications into our base notification provider
  Future<List<Notification>> _populateNotifications() async {
    await populateAndSetIfChanged(
      api.notificationControllerGetNotifications,
      _notifications,
      (newValue) => _notifications = newValue ?? [],
    );
    notifyListeners();
    return _notifications;
  }

  @override
  Future<void> postLogin() async {
    // Update the firebase config
    await FirebaseNotificationProvider.configure(api);
    await _populateNotifications();
  }

  @override
  Future<void> onSSE(SSEData data) async {
    await super.onSSE(data);
    if (data.event == SSEDataEventEnum.notification) {
      _populateNotifications();
    }
  }
}
