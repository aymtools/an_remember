import 'package:flutter/widgets.dart';

void runOnErrorSetValue<T>(ValueNotifier<T> notifier, Function? onError, Object error, StackTrace stackTrace) {
  if (onError != null) {
    dynamic errResult;
    if (onError is dynamic Function(Object, StackTrace)) {
      errResult = onError(error, stackTrace);
    } else if (onError is dynamic Function(Object)) {
      errResult = onError(error);
    } else {
      throw ArgumentError.value(
          onError,
          "onError",
          "Error handler must accept one Object or one Object and a StackTrace"
              " as arguments");
    }
    if (errResult is T) {
      notifier.value = errResult;
    }
  }
}