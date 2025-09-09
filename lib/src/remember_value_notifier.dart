import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    hide BuildContextLifecycleRememberExt;
import 'package:anlifecycle/anlifecycle.dart';
import 'package:flutter/material.dart';
import 'package:remember/src/remember.dart';

extension BuildContextLifecycleRememberValueNotifierExt on BuildContext {
  /// 快速生成一个可用的类型 ValueNotifier
  /// * [value]， [factory]， [factory2] 确定如何初始化的创建一个 ValueNotifier 必须有一个不能为空 不作为更新key
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<T> rememberValueNotifier<T>({
    T? value,
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    FutureOr<void> Function(ValueNotifier<T>)? onDispose,
    bool listen = false,
    Object? key,
  }) =>
      remember<ValueNotifier<T>>(
        factory2: (l) {
          assert(
            value != null || factory != null || factory2 != null,
            'value and factory and factory2 cannot be null at the same time',
          );
          value ??= factory?.call();
          value ??= factory2?.call(l);
          return CancellableValueNotifier(value as T, l.makeLiveCancellable());
        },
        onCreate: (l, v) {
          if (listen && this is Element) {
            final rContext = WeakReference(this);
            v.addCListener(l.makeLiveCancellable(), () {
              final element = rContext.target as Element?;
              if (element != null) {
                element.markNeedsBuild();
              }
            });
          }
        },
        onDispose: (d) {
          d.dispose();
          onDispose?.call(d);
        },
      );
}
