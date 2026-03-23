// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  runZonedGuarded(() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      // ignore: avoid_print
      print('FLUTTER_ERROR: ${details.exceptionAsString()}');
      // ignore: avoid_print
      print(details.stack);
    };
    runApp(const ProviderScope(child: RoadbookApp()));
  }, (error, stack) {
    // ignore: avoid_print
    print('ZONE_ERROR: $error');
    // ignore: avoid_print
    print(stack);
  });
}
