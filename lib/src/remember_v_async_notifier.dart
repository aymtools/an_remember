import 'dart:async';

import 'package:an_async_data/an_async_data.dart';
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember_listenable.dart';
import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    show FlexibleKey;

extension RememberAsyncValueNotifierAdvancedExt on BuildContext {
  /// 快速生成一个可重用的 ValueNotifier 类型为 AsyncData
  /// * 调用顺序,[T],[key],[initialData],[error],[stackTrace],[future],[stream],[cancelOnError] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<AsyncData<T>> rememberAsyncNotifier<T extends Object>({
    T? initialData,
    Object? error,
    StackTrace? stackTrace,
    Future<T>? future,
    Stream<T>? stream,
    bool? cancelOnError,
    void Function(ValueNotifier<AsyncData<T>>, Lifecycle, Cancellable)?
        onCreate,
    FutureOr<void> Function(ValueNotifier<AsyncData<T>>)? onDispose,
    bool listen = false,
    Object? key,
  }) {
    return rememberValueNotifier(
      factory: () {
        assert(future == null || stream == null,
            'future and stream cannot both be non-null');
        if (initialData != null) {
          return AsyncData<T>.value(initialData);
        } else if (error != null) {
          return AsyncData<T>.error(error, stackTrace);
        } else {
          return AsyncData<T>.loading();
        }
      },
      onCreate: (notifier, lifecycle, cancellable) {
        if (future != null) {
          future
              .bindCancellable(cancellable)
              .then(notifier.toValue)
              .catchError(notifier.toError);
        } else if (stream != null) {
          stream.bindCancellable(cancellable, closeWhenCancel: true).listen(
              notifier.toValue,
              onError: notifier.toError,
              cancelOnError: cancelOnError);
        }
        onCreate?.call(notifier, lifecycle, cancellable);
      },
      onDispose: onDispose,
      listen: listen,
      key: FlexibleKey('rememberAsyncNotifier', initialData, error, stackTrace,
          future, stream, cancelOnError, key),
    );
  }

  /// 快速生成一个可重用的 ValueNotifier
  /// * 调用顺序,[T],[key],[initialData],[future],[stream],[cancelOnError] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<T> rememberValueNotifierAsync<T>({
    required T initialData,
    Future<T>? future,
    Stream<T>? stream,
    bool? cancelOnError,
    Function? onError,
    T Function(ValueNotifier<T>, Object error, StackTrace stackTrace)?
        returnOnError,
    void Function(ValueNotifier<T>, Lifecycle, Cancellable)? onCreate,
    FutureOr<void> Function(ValueNotifier<T>)? onDispose,
    bool listen = false,
    Object? key,
  }) {
    return rememberValueNotifier(
      factory: () => initialData,
      onCreate: (notifier, lifecycle, cancellable) {
        if (future != null) {
          future.bindCancellable(cancellable).then((value) {
            notifier.value = value;
          }).catchError((Object error, StackTrace stackTrace) {
            if (returnOnError != null) {
              notifier.value = returnOnError(notifier, error, stackTrace);
            }
            onError?.call(error, stackTrace);
          });
        } else if (stream != null) {
          stream.bindCancellable(cancellable, closeWhenCancel: true).listen(
            (value) {
              notifier.value = value;
            },
            onError: (Object error, StackTrace stackTrace) {
              if (returnOnError != null) {
                notifier.value = returnOnError(notifier, error, stackTrace);
              }
              if (onError != null) {
                if (onError is dynamic Function(Object, StackTrace)) {
                  onError(error, stackTrace);
                } else if (onError is dynamic Function(Object)) {
                  onError(error);
                } else {
                  throw ArgumentError.value(
                      onError,
                      "onError",
                      "Error handler must accept one Object or one Object and a StackTrace"
                          " as arguments, and return a value of the returned type");
                }
              }
            },
            cancelOnError: cancelOnError,
          );
        }
        onCreate?.call(notifier, lifecycle, cancellable);
      },
      onDispose: onDispose,
      listen: listen,
      key: FlexibleKey('rememberValueNotifierAsync', initialData, future,
          stream, cancelOnError, key),
    );
  }
}
