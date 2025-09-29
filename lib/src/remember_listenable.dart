import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    show
        LifecycleObserverRegistryCacnellable,
        ListenableCancellable,
        CancellableValueNotifier;
import 'package:anlifecycle/anlifecycle.dart';
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember.dart';

extension RememberListenableExt on BuildContext {
  /// 快速生成一个可重用的 Listenable
  /// * 调用顺序、[T]和 [key] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [value]， [factory]， [factory2] 确定如何初始化的创建一个 ValueNotifier 必须有一个不能为空 不作为更新key
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  /// * [onCreate] 创建完成时的处理
  /// * [onDispose] 定义销毁时如何处理，晚于[context]的[dispose],**非常注意：不可使用[context]相关内容**
  /// * **[Listenable]没有[dispose]，不会主动调用，如需自动管理使用其相关子类的remember**
  T rememberListenable<T extends Listenable>({
    T? value,
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    void Function(Lifecycle, T)? onCreate,
    FutureOr<void> Function(T)? onDispose,
    bool listen = false,
    Object? key,
  }) =>
      remember<T>(
        factory: value == null ? factory : () => value,
        factory2: factory2,
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
          onCreate?.call(l, v);
        },
        onDispose: onDispose,
        key: key,
      );
}

extension RememberChangeNotifierExt on BuildContext {
  /// 快速生成一个可重用的 ChangeNotifier
  /// * 调用顺序、[T]和 [key] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [factory]， [factory2] 确定如何初始化的创建一个 ValueNotifier 必须有一个不能为空 不作为更新key
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  /// * [onCreate] 创建完成时的处理
  /// * [onDispose] 定义销毁时如何处理,已自动调用[dispose]，晚于[context]的[dispose],**非常注意：不可使用[context]相关内容**
  T rememberChangeNotifier<T extends ChangeNotifier>({
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    void Function(Lifecycle, T)? onCreate,
    FutureOr<void> Function(T)? onDispose,
    bool listen = false,
    Object? key,
  }) =>
      rememberListenable(
          factory: factory,
          factory2: factory2,
          onCreate: onCreate,
          onDispose: (d) {
            d.dispose();
            onDispose?.call(d);
          },
          listen: listen,
          key: key);
}

extension RememberValueNotifierExt on BuildContext {
  /// 快速生成一个可重用的 ValueNotifier
  /// * 调用顺序、[T]和 [key] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [value]， [factory]， [factory2] 确定如何初始化的创建一个 ValueNotifier 必须有一个不能为空 不作为更新key
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<T> rememberValueNotifier<T>({
    T? value,
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    void Function(Lifecycle, ValueNotifier<T>)? onCreate,
    FutureOr<void> Function(ValueNotifier<T>)? onDispose,
    bool listen = false,
    Object? key,
  }) =>
      rememberChangeNotifier<ValueNotifier<T>>(
        factory2: (l) {
          assert(
            value != null || factory != null || factory2 != null,
            'value and factory and factory2 cannot be null at the same time',
          );
          value ??= factory?.call();
          value ??= factory2?.call(l);
          return CancellableValueNotifier(value as T, l.makeLiveCancellable());
        },
        onCreate: onCreate,
        onDispose: onDispose,
        listen: listen,
        key: key,
      );
}
