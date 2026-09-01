import 'dart:async';

import 'package:an_async_data/an_async_data.dart';
import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember_listenable.dart';
import 'package:remember/src/remember_v_async_notifier.dart';
import 'package:remember/src/tools/run_on_error.dart';

extension RememberValueNotifierAdvancedAsyncTransformExt on BuildContext {
  /// [cancelPreviousOnSourceChange]
  ///  [null] (默认): **并发模式**。立即执行新转换，谁先完成谁先赋值，结果可能与源顺序不一致。
  ///  [true]: **重启模式**。立即取消当前正在运行的转换或抛弃其结果，并启动一个新的转换。
  ///  [false]: **排队模式**。允许当前转换继续完成，完成后再启动下一个新的转换。
  ValueNotifier<AsyncData<R>> rememberAsyncNotifierAsyncTransform<R, S>(
      {R? initialData,
      bool initialAllowNull = false,
      required ValueNotifier<S> source,
      required FutureOr<R> Function(S, Cancellable) transformer,
      bool listen = false,
      bool notifyWhenEquals = false,
      bool? cancelPreviousOnSourceChange,
      Object? key}) {
    return rememberAsyncNotifier<R>(
      initialData: initialData,
      initialAllowNull: initialAllowNull,
      onCreate: (d, l, c) {
        Cancellable transforming = c.makeCancellable();

        void Function() startTransformer;

        Future<void> runTransformer() async {
          await Future.value(transformer(source.value, transforming))
              .bindCancellable(transforming)
              .then(d.toValue, onError: d.toError);
        }

        if (cancelPreviousOnSourceChange == null) {
          startTransformer = runTransformer;
        } else if (cancelPreviousOnSourceChange) {
          startTransformer = () {
            transforming.cancel();
            transforming = c.makeCancellable();
            runTransformer();
          };
        } else {
          // 初始化一个已完成的 Future 作为起点
          Future<void> sequence = Future.value();
          startTransformer = () {
            sequence = sequence.then((_) async {
              await runTransformer();
            });
          };
        }

        source.addCListener(c, startTransformer);
        startTransformer();
      },
      listen: listen,
      notifyWhenEquals: notifyWhenEquals,
      key: FlexibleKey('rememberAsyncNotifierAsyncTransform', source, key),
    );
  }

  /// [cancelPreviousOnSourceChange]
  ///  [null] (默认): **并发模式**。立即执行新转换，谁先完成谁先赋值，结果可能与源顺序不一致。
  ///  [true]: **重启模式**。立即取消当前正在运行的转换或抛弃其结果，并启动一个新的转换。
  ///  [false]: **排队模式**。允许当前转换继续完成，完成后再启动下一个新的转换。
  ValueNotifier<R> rememberValueNotifierAsyncTransform<R, S>(
      {required R initialData,
      required ValueNotifier<S> source,
      required FutureOr<R> Function(S, Cancellable) transformer,
      bool listen = false,
      bool notifyWhenEquals = false,
      bool? cancelPreviousOnSourceChange,
      Function? onError,
      R Function(ValueNotifier<R>, Object error, StackTrace stackTrace)?
          returnOnError,
      Object? key}) {
    return rememberValueNotifier<R>(
      value: initialData,
      onCreate: (d, l, c) {
        Cancellable transforming = c.makeCancellable();

        void Function() startTransformer;
        Future<void> runTransformer() async {
          await Future.value(transformer(source.value, transforming))
              .bindCancellable(transforming)
              .then<void>((v) => d.value = v,
                  onError: (Object error, StackTrace stackTrace) {
            if (returnOnError != null) {
              d.value = returnOnError(d, error, stackTrace);
            } else {
              runOnErrorSetValue<R>(d, onError, error, stackTrace);
            }
          });
        }

        if (cancelPreviousOnSourceChange == null) {
          startTransformer = runTransformer;
        } else if (cancelPreviousOnSourceChange) {
          startTransformer = () {
            transforming.cancel();
            transforming = c.makeCancellable();
            runTransformer();
          };
        } else {
          // 初始化一个已完成的 Future 作为起点
          Future<void> sequence = Future.value();
          startTransformer = () {
            sequence = sequence.then((_) async {
              await runTransformer();
            });
          };
        }

        source.addCListener(c, startTransformer);
        startTransformer();
      },
      listen: listen,
      notifyWhenEquals: notifyWhenEquals,
      key: FlexibleKey('rememberValueNotifierAsyncTransform', source, key),
    );
  }
}
