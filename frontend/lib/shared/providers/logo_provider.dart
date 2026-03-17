import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/api/base_api.dart';

part 'logo_provider.g.dart';

/// Riverpod to cache and load the given image with the given data considering an authenticated API
@riverpod
Future<Uint8List> logoImage(Ref ref, {String? faviconUrl, String? fullUrl}) async {
  final client = await ref.read(baseAuthenticatedClientProvider.future);
  final api = CoreApi(client);

  final response = await api.imageProxyControllerHandleImageProxyWithHttpInfo(
    faviconImageUrl: faviconUrl,
    fullImageUrl: fullUrl,
  );

  if (response.statusCode == 200) {
    return response.bodyBytes;
  } else {
    throw Exception('Failed to load image');
  }
}
