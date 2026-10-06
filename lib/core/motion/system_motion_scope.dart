import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Windows' Flutter embedder does not expose the OS animation preference.
// Android uses Flutter's existing accessibility feature flag.
class SystemMotionScope extends StatefulWidget {
  const SystemMotionScope({required this.child, super.key});

  final Widget child;

  @override
  State<SystemMotionScope> createState() => _SystemMotionScopeState();
}

class _SystemMotionScopeState extends State<SystemMotionScope>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('void_connect/motion');
  final _isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;
  bool _reduceMotion = true;

  @override
  void initState() {
    super.initState();
    if (_isWindows) {
      WidgetsBinding.instance.addObserver(this);
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'motionChanged' &&
            call.arguments is bool &&
            mounted) {
          setState(() => _reduceMotion = call.arguments as bool);
        }
      });
      _readPreference();
    }
  }

  Future<void> _readPreference() async {
    bool value;
    try {
      value = await _channel.invokeMethod<bool>('getReduceMotion') ?? true;
    } on PlatformException {
      value = true;
    } on MissingPluginException {
      value = true;
    }
    if (mounted) setState(() => _reduceMotion = value);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _readPreference();
  }

  @override
  void dispose() {
    if (_isWindows) {
      WidgetsBinding.instance.removeObserver(this);
      _channel.setMethodCallHandler(null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(
        disableAnimations:
            data.disableAnimations || (_isWindows && _reduceMotion),
      ),
      child: widget.child,
    );
  }
}
