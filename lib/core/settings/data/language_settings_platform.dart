import 'package:flutter/services.dart';

class LanguageSettingsPlatform {
  const LanguageSettingsPlatform();

  static const _channel = MethodChannel('void_connect/settings');

  Future<String?> getLanguage() => _channel.invokeMethod<String>('getLanguage');

  Future<void> setLanguage(String languageCode) => _channel.invokeMethod<void>(
    'setLanguage',
    {'languageCode': languageCode},
  );
}
