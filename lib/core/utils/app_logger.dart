import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void d(String tag, String message, [Object? data]) {
    if (!kDebugMode) return;
    final payload = data != null ? ' | data=$data' : '';
    dev.log('[$tag] $message$payload', name: 'GMG.DEBUG', level: 700);
  }

  static void i(String tag, String message, [Object? data]) {
    if (!kDebugMode) return;
    final payload = data != null ? ' | data=$data' : '';
    dev.log('[$tag] $message$payload', name: 'GMG.INFO', level: 800);
  }

  static void w(String tag, String message, [Object? data]) {
    if (!kDebugMode) return;
    final payload = data != null ? ' | data=$data' : '';
    dev.log('[$tag] WARN: $message$payload', name: 'GMG.WARN', level: 900);
  }

  static void e(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    dev.log('[$tag] ERROR: $message',
        name: 'GMG.ERROR', level: 1000, error: error, stackTrace: stackTrace);
  }

  static void net(String tag, String operation, [Object? params]) {
    if (!kDebugMode) return;
    final payload = params != null ? ' params=$params' : '';
    dev.log('[$tag] $operation$payload', name: 'GMG.NET', level: 700);
  }
}
