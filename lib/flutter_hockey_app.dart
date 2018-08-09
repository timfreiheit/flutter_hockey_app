import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:stack_trace/stack_trace.dart';


class HockeyAppClient {
  static const MethodChannel _channel = const MethodChannel(
      'flutter_hockey_app'
  );

  static bool get isInDebugMode {
    // Assume we're in production mode
    bool inDebugMode = false;

    // Assert expressions are only evaluated during development. They are ignored
    // in production. Therefore, this code will only turn `inDebugMode` to true
    // in our development environments!
    assert(inDebugMode = true);

    return inDebugMode;
  }

  //
  // optional if the HockeyApp SDK is already initialized in platform specific code
  //
  static void init({String appId, bool updateEnabled = false}) {
    if (isInDebugMode) {
      return;
    }

    _channel.invokeMethod("init", {
      "appId": appId,
      "updateEnabled": updateEnabled
    });

    final oldHandler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (!isInDebugMode) {
        captureException(
            exception: details.exception, stackTrace: details.stack);
      }
      oldHandler(details);
    };
  }

  static void runInZone<R>(R body(), {bool crashReportingEnabled = true}) {
    runZoned(
        body,
        onError: (error, stackTrace) {
          if (crashReportingEnabled && !isInDebugMode) {
            captureException(exception: error, stackTrace: stackTrace);
          }
        }
    );
  }

  static Future<Null> captureException({
    @required dynamic exception,
    dynamic stackTrace,
  }) async {
    stackTrace ??= "";

    await _channel.invokeMethod("captureException", {
      "exception": {
        "type": "${exception.runtimeType}",
        "value": "$exception"
      },
      "stacktrace": _encodeStackTrace(stackTrace)
    });
  }

}

String _encodeStackTrace(dynamic stackTrace) {
  assert(stackTrace is String || stackTrace is StackTrace);
  final Chain chain = stackTrace is StackTrace
      ? new Chain.forTrace(stackTrace)
      : new Chain.parse(stackTrace);

  return chain.toString();
}