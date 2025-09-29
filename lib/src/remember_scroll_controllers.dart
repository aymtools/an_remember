import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    show FlexibleKey, LifecycleTickerProviderExt;
import 'package:anlifecycle/anlifecycle.dart';
import 'package:flutter/material.dart';
import 'package:remember/src/remember_listenable.dart';

extension RememberScrollControllersExt on BuildContext {
  /// 快速生成一个可重用的 TabController
  /// * 调用顺序,[T],[key],[initialIndex],[animationDuration],[length] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [initialIndex] 初始索引
  /// * [animationDuration] 动画时长
  /// * [length] Tab的数量
  /// * [onCreate] 创建完成时的处理
  /// * [onDispose] 定义销毁时如何处理，晚于[context]的[dispose],**非常注意：不可使用[context]相关内容**
  TabController rememberTabController({
    int initialIndex = 0,
    Duration? animationDuration,
    required int length,
    void Function(Lifecycle, TabController)? onCreate,
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

  /// 快速生成一个可重用的 ScrollController
  /// * 调用顺序、[T]、[key]、[initialScrollOffset]、[keepScrollOffset]、[debugLabel]
  /// 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [initialScrollOffset] 初始偏移量
  /// * [keepScrollOffset] 是否保持偏移量
  /// * [debugLabel] 调试标签
  /// * [onDispose] 定义销毁时如何处理，晚于[context]的[dispose],**非常注意：不可使用[context]相关内容**
  /// * onAttach onDetach 需要flutter 3.19.0 以上的版本
  ScrollController rememberScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
    void Function(Lifecycle, ScrollController)? onCreate,
    FutureOr<void> Function(ScrollController)? onDispose,
    bool listen = false,
    Object? key,
  }) =>
      rememberChangeNotifier<ScrollController>(
        factory: () => ScrollController(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        ),
        onCreate: onCreate,
        onDispose: onDispose,
        listen: listen,
        key:
            FlexibleKey(initialScrollOffset, keepScrollOffset, debugLabel, key),
      );

  /// 快速生成一个可重用的 PageController
  /// * 调用顺序、[T]、[key]、[initialPage]、[keepPage]、[viewportFraction]
  /// 确定是否为同一个对象 如果发生了变化则重新创建
  PageController rememberPageController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    void Function(Lifecycle, PageController)? onCreate,
    FutureOr<void> Function(PageController)? onDispose,
    bool listen = false,
    Object? key,
  }) =>
      rememberChangeNotifier<PageController>(
        factory: () => PageController(
          initialPage: initialPage,
          keepPage: keepPage,
          viewportFraction: viewportFraction,
        ),
        onCreate: onCreate,
        onDispose: onDispose,
        listen: listen,
        key: FlexibleKey(initialPage, keepPage, viewportFraction, key),
      );
}
