import 'package:flutter/services.dart';

import '../domain/launchable_app.dart';

class AppLibraryPlatform {
  const AppLibraryPlatform({this._channel = _defaultChannel});

  static const _defaultChannel = MethodChannel('void_connect/app_library');
  final MethodChannel _channel;

  Future<List<LaunchableApp>> listAvailableApps() async {
    final result = await _channel.invokeListMethod<Map<Object?, Object?>>(
      'listApps',
    );
    return [
      for (final item in result ?? const [])
        LaunchableApp(id: item['id']! as String, name: item['name']! as String),
    ];
  }

  Future<List<String>> getSavedAppIds() async =>
      await _channel.invokeListMethod<String>('getSavedApps') ?? const [];

  Future<void> addApp(String id) =>
      _channel.invokeMethod<void>('addApp', {'id': id});

  Future<void> removeApp(String id) =>
      _channel.invokeMethod<void>('removeApp', {'id': id});

  Future<bool> launchApp(String id) async =>
      await _channel.invokeMethod<bool>('launchApp', {'id': id}) ?? false;
}
