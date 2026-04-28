import 'dart:io';
import 'package:flutter/services.dart';

class PlatformUtil {
  static const _channel = MethodChannel('com.roadbook/platform');
  static bool? _isSimulatorCached;

  static Future<bool> get isSimulator async {
    if (_isSimulatorCached != null) return _isSimulatorCached!;
    if (!Platform.isIOS) {
      _isSimulatorCached = false;
      return false;
    }
    try {
      _isSimulatorCached =
          await _channel.invokeMethod<bool>('isSimulator') ?? false;
    } on PlatformException {
      _isSimulatorCached = false;
    }
    return _isSimulatorCached!;
  }
}
