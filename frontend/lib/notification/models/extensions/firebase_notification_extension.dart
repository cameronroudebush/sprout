import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sprout/api/api.dart';

/// Helper functions for  firebase notifications from the backend
extension FirebaseNotificationExtension on FirebaseNotificationDTO {
  Importance get importanceTyped {
    switch (importance) {
      case FirebaseNotificationDTOImportanceEnum.max:
        return Importance.max;
      case FirebaseNotificationDTOImportanceEnum.high:
        return Importance.high;
      case FirebaseNotificationDTOImportanceEnum.low:
        return Importance.low;
      case FirebaseNotificationDTOImportanceEnum.default_:
      default:
        return Importance.defaultImportance;
    }
  }
}
