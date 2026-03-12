import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    show FlexibleKey, StreamLifecycleExt, StreamToolsExt;
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember.dart';

extension RememeberStreamExt on BuildContext {
  /// 快速生成一个可重用的 Stream
  /// * 调用顺序、[T]、[key]、[state]、[repeatLastOnStateAtLeast]、[closeWhenCancel]、
  /// [cancelOnError]、[repeatLatest]、[repeatLatestError] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [converter] 转换器将[factory] 产出的 stream 进行最终变换
  Stream<T> rememberStream<T>({
    Stream<T> Function()? factory,
    Stream<T> Function(Lifecycle)? factory2,
    Stream<T> Function(Stream<T>, Lifecycle, Cancellable)? converter,
    LifecycleState state = LifecycleState.created,
    bool repeatLastOnStateAtLeast = false,
    bool closeWhenCancel = true,
    bool? cancelOnError,
    bool repeatLatest = false,
    bool repeatLatestError = false,
    Object? key,
  }) {
    return remember<Stream<T>>(
      factory3: (l, c) {
        Stream<T> stream = factory != null
            ? factory()
            : (factory2 != null ? factory2(l) : Stream<T>.empty());

        var result = stream;
        result = stream.bindCancellable(c, closeWhenCancel: closeWhenCancel);
        if (state > LifecycleState.created) {
          result = stream.bindLifecycle(l,
              state: state,
              repeatLastOnStateAtLeast: repeatLastOnStateAtLeast,
              closeWhenCancel: closeWhenCancel,
              cancelOnError: cancelOnError);
        }
        if (repeatLatest) {
          result = result.repeatLatest(repeatError: repeatLatestError);
        }

        if (converter != null) {
          result = converter(result, l, c);
        }
        return result;
      },
      key: FlexibleKey(state, repeatLastOnStateAtLeast, closeWhenCancel,
          cancelOnError, repeatLatest, repeatLatestError, key),
    );
  }

  /// 快速生成一个可重用的 Stream
  /// * 调用顺序、[T]、[key]、[value]、[error]、[stackTrace]、[future]、[futures]、
  /// [elements]、[state]、[repeatLastOnStateAtLeast]、[closeWhenCancel]、
  /// [cancelOnError]、[repeatLatest]、[repeatLatestError] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [converter] 转换器将  产出的 stream 进行最终变换
  Stream<T> rememberStreamForm<T>({
    T? value,
    Object? error,
    StackTrace? stackTrace,
    Future<T>? future,
    Iterable<Future<T>>? futures,
    Iterable<T>? elements,
    Stream<T> Function(Stream<T>, Lifecycle, Cancellable)? converter,
    LifecycleState state = LifecycleState.created,
    bool repeatLastOnStateAtLeast = false,
    bool closeWhenCancel = true,
    bool? cancelOnError,
    bool repeatLatest = false,
    bool repeatLatestError = false,
    Object? key,
  }) {
    return rememberStream<T>(
      factory2: (l) {
        Stream<T> stream;
        if (value != null) {
          stream = Stream<T>.value(value);
        } else if (error != null) {
          stream = Stream<T>.error(error, stackTrace);
        } else if (future != null) {
          stream = Stream<T>.fromFuture(future);
        } else if (futures != null) {
          stream = Stream<T>.fromFutures(futures);
        } else if (elements != null) {
          stream = Stream<T>.fromIterable(elements);
        } else if (null is T) {
          stream = Stream<T>.value(null as T);
        } else {
          stream = Stream<T>.empty();
        }
        return stream;
      },
      converter: converter,
      state: state,
      repeatLastOnStateAtLeast: repeatLastOnStateAtLeast,
      closeWhenCancel: closeWhenCancel,
      cancelOnError: cancelOnError,
      repeatLatest: repeatLatest,
      repeatLatestError: repeatLatestError,
      key: FlexibleKey(
          'form', value, error, stackTrace, future, futures, elements, key),
    );
  }

  /// 快速生成一个可重用的 Stream.periodic
  /// * 调用顺序、[T]、[key]、[period]、 [state]、[repeatLastOnStateAtLeast]、
  /// [closeWhenCancel]、[cancelOnError]、[repeatLatest]、[repeatLatestError]
  /// 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [converter] 转换器将  产出的 stream 进行最终变换
  Stream<T> rememberStreamPeriodic<T>({
    required Duration period,
    T Function(int computationCount)? computation,
    Stream<T> Function(Stream<T>, Lifecycle, Cancellable)? converter,
    LifecycleState state = LifecycleState.created,
    bool repeatLastOnStateAtLeast = false,
    bool closeWhenCancel = true,
    bool? cancelOnError,
    bool repeatLatest = false,
    bool repeatLatestError = false,
    Object? key,
  }) {
    return rememberStream<T>(
      factory: () => Stream.periodic(period, computation),
      converter: converter,
      state: state,
      repeatLastOnStateAtLeast: repeatLastOnStateAtLeast,
      closeWhenCancel: closeWhenCancel,
      cancelOnError: cancelOnError,
      repeatLatest: repeatLatest,
      repeatLatestError: repeatLatestError,
      key: FlexibleKey('periodic', period, key),
    );
  }

  /// 快速生成一个可重用的 Stream.eventTransformed
  /// * 调用顺序、[T]、[key]、[source]、[state]、[repeatLastOnStateAtLeast]、
  /// [closeWhenCancel]、[cancelOnError]、[repeatLatest]、[repeatLatestError]
  /// 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [converter] 转换器将  产出的 stream 进行最终变换
  Stream<T> rememberStreamEventTransformed<T>({
    required Stream<dynamic> source,
    required EventSink<dynamic> Function(EventSink<T> sink) mapSink,
    Stream<T> Function(Stream<T>, Lifecycle, Cancellable)? converter,
    LifecycleState state = LifecycleState.created,
    bool repeatLastOnStateAtLeast = false,
    bool closeWhenCancel = true,
    bool? cancelOnError,
    bool repeatLatest = false,
    bool repeatLatestError = false,
    Object? key,
  }) {
    return rememberStream<T>(
      factory: () => Stream.eventTransformed(source, mapSink),
      converter: converter,
      state: state,
      repeatLastOnStateAtLeast: repeatLastOnStateAtLeast,
      closeWhenCancel: closeWhenCancel,
      cancelOnError: cancelOnError,
      repeatLatest: repeatLatest,
      repeatLatestError: repeatLatestError,
      key: FlexibleKey('eventTransformed', source, key),
    );
  }

  /// 快速生成一个可重用的 StreamController
  /// * 调用顺序、[T]、[key]、 [sync] 确定是否为同一个对象 如果发生了变化则重新创建
  StreamController<T> rememberStreamController<T>({
    void Function()? onListen,
    void Function()? onPause,
    void Function()? onResume,
    FutureOr<void> Function()? onCancel,
    bool sync = false,
    Object? key,
  }) {
    return remember<StreamController<T>>(
      factory: () => StreamController<T>(
          onListen: onListen,
          onPause: onPause,
          onResume: onResume,
          onCancel: onCancel,
          sync: sync),
      onDispose: (s) => s.close(),
      key: FlexibleKey(sync, key),
    );
  }

  /// 快速生成一个可重用的 StreamController.broadcast
  /// * 调用顺序、[T]、[key]、 [sync] 确定是否为同一个对象 如果发生了变化则重新创建
  StreamController<T> rememberStreamControllerBroadcast<T>({
    void Function()? onListen,
    FutureOr<void> Function()? onCancel,
    bool sync = false,
    Object? key,
  }) {
    return remember<StreamController<T>>(
      factory: () => StreamController<T>.broadcast(
          onListen: onListen, onCancel: onCancel, sync: sync),
      onDispose: (s) => s.close(),
      key: FlexibleKey('broadcast', sync, key),
    );
  }

  /// 快速生成一个可重用的 StreamSubscription 一般用来自动取消
  /// * 调用顺序、[T]、[key]、 确定是否为同一个对象 如果发生了变化则重新创建
  StreamSubscription<T> rememberStreamSubscription<T>({
    StreamSubscription<T> Function()? factory,
    StreamSubscription<T> Function(Lifecycle)? factory2,
    Object? key,
  }) {
    return remember<StreamSubscription<T>>(
      factory: factory,
      factory2: factory2,
      onDispose: (s) => s.cancel(),
      key: key,
    );
  }
}
