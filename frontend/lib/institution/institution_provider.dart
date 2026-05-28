import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/notification/notification_provider.dart';
import 'package:sprout/shared/api/base_api.dart';

part 'institution_provider.g.dart';

/// Returns the authenticated API client instance for institutions
@Riverpod(keepAlive: true)
Future<InstitutionApi> institutionApi(Ref ref) async {
  final client = await ref.watch(baseAuthenticatedClientProvider.future);
  return InstitutionApi(client);
}

@Riverpod(keepAlive: true)
class Institutions extends _$Institutions {
  @override
  void build() {
    return;
  }

  /// Patches an institution's logo style preference via the backend API
  Future<Institution?> updateIconType(String id, InstitutionIconType type) async {
    final notifications = ref.read(notificationsProvider.notifier);
    try {
      final api = await ref.read(institutionApiProvider.future);
      return await api.institutionControllerUpdate(
        id,
        UpdateInstitutionRequest(iconType: type),
      );
    } catch (e) {
      notifications.openWithAPIException(e);
      rethrow;
    }
  }
}
