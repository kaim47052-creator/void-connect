class LaunchableApp {
  const LaunchableApp({required this.id, required this.name});

  /// Platform identifier: a package name on Android or a Start Menu shortcut
  /// path on Windows.
  final String id;
  final String name;
}
