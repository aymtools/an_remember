import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    show FlexibleKey, LifecycleTickerProviderExt;
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:remember/src/remember_listenable.dart';

@Deprecated('use package:an_lifecycle_material_ext, will remove v2.8.2')
extension RememberMaterialSupportsExt on BuildContext {
  /// 快速生成一个可重用的 TabController
  /// * 调用顺序,[key],[initialIndex],[animationDuration],[length] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [initialIndex] 初始索引
  /// * [animationDuration] 动画时长
  /// * [length] Tab的数量
  /// * [onCreate] 创建完成时的处理
  /// * [onDispose] 定义销毁时如何处理，晚于[context]的[dispose],**非常注意：不可使用[context]相关内容**
  @Deprecated('use package:an_lifecycle_material_ext, will remove v2.8.2')
  TabController rememberTabController({
    int initialIndex = 0,
    Duration? animationDuration,
    required int length,
    void Function(TabController, Lifecycle, Cancellable)? onCreate,
    FutureOr<void> Function(TabController)? onDispose,
    bool listen = false,
    Object? key,
  }) =>
      rememberChangeNotifier<TabController>(
        factory2: (l) => TabController(
          initialIndex: initialIndex,
          animationDuration: animationDuration,
          length: length,
          vsync: l.tickerProvider,
        ),
        onCreate: onCreate,
        onDispose: onDispose,
        listen: listen,
        key: FlexibleKey(initialIndex, animationDuration, length, key),
      );
}
