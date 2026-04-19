import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cookie_provider.g.dart';

/// Generic cookie jar to persist across app restarts for usage in mobile
@Riverpod(keepAlive: true)
Future<CookieJar> cookieJar(Ref ref, bool persist) async {
  if (kIsWeb || !persist) {
    return CookieJar();
  } else {
    return PersistCookieJar(
      storage: SecureCookieStorage(),
      ignoreExpires: false,
      persistSession: true,
    );
  }
}

/// Generic cookie storage class that allows us to just use the FlutterSecureStorage
///   for auto encryption.
class SecureCookieStorage implements Storage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _prefix = 'cookie_jar_';

  String _getSecureKey(String key) => '$_prefix$key';

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<String?> read(String key) async {
    return await _storage.read(key: _getSecureKey(key));
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: _getSecureKey(key), value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: _getSecureKey(key));
  }

  @override
  Future<void> deleteAll(List<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }
}
