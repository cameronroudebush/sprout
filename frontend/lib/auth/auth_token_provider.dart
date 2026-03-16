import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';

part 'auth_token_provider.g.dart';

class SproutTokens {
  final String? idToken;
  final String? accessToken;
  final String? refreshToken;

  SproutTokens({this.idToken, this.accessToken, this.refreshToken});
}

/// Defines a riverpod that tracks all of our relevant tokens
@Riverpod(keepAlive: true)
class AuthTokens extends _$AuthTokens {
  @override
  Future<SproutTokens> build() async {
    // Initial load from storage on app start
    final id = await SecureStorageProvider.getValue(SecureStorageProvider.idToken);
    final access = await SecureStorageProvider.getValue(SecureStorageProvider.accessToken);
    final refresh = await SecureStorageProvider.getValue(SecureStorageProvider.refreshToken);

    return SproutTokens(idToken: id, accessToken: access, refreshToken: refresh);
  }

  Future<void> updateTokens({String? idToken, String? accessToken, String? refreshToken}) async {
    if (!kIsWeb) {
      if (idToken != null) await SecureStorageProvider.saveValue(SecureStorageProvider.idToken, idToken);
      if (accessToken != null) await SecureStorageProvider.saveValue(SecureStorageProvider.accessToken, accessToken);
      if (refreshToken != null) await SecureStorageProvider.saveValue(SecureStorageProvider.refreshToken, refreshToken);
    }

    // Update state to trigger authenticatedClient rebuild
    state = AsyncData(
      SproutTokens(
        idToken: idToken ?? state.value?.idToken,
        accessToken: accessToken ?? state.value?.accessToken,
        refreshToken: refreshToken ?? state.value?.refreshToken,
      ),
    );
  }

  Future<void> clear() async {
    await SecureStorageProvider.saveValue(SecureStorageProvider.idToken, null);
    await SecureStorageProvider.saveValue(SecureStorageProvider.accessToken, null);
    await SecureStorageProvider.saveValue(SecureStorageProvider.refreshToken, null);
    state = AsyncData(SproutTokens());
  }
}
