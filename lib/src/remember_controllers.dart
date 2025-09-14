import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    hide BuildContextLifecycleRememberExt;
import 'package:anlifecycle/anlifecycle.dart';
import 'package:flutter/material.dart';
import 'package:remember/src/remember.dart';

extension BuildContextLifecycleRememberControllersExt on BuildContext {
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
    Object? key,
  }) =>
      remember<TabController>(
        factory2: (l) => TabController(
          initialIndex: initialIndex,
          length: length,
          vsync: l.tickerProvider,
        ),
        onCreate: onCreate,
        onDispose: (c) {
          c.dispose();
          onDispose?.call(c);
        },
        key: FlexibleKey(initialIndex, animationDuration, length, key),
      );

  /// 快速生成一个可重用的 AnimationController
  /// * 调用顺序、[T]、[key]、[value]、[duration]、[reverseDuration]、[debugLabel]、
  /// [lowerBound]、[upperBound]、[animationBehavior] 确定是否为同一个对象 如果发生了变化则重新创建
  /// 与[rememberAnimationControllerUnbounded]的重用不同
  AnimationController rememberAnimationController({
    double? value,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    void Function(Lifecycle, AnimationController)? onCreate,
    FutureOr<void> Function(AnimationController)? onDispose,
    Object? key,
  }) {
    return remember<AnimationController>(
      factory2: (l) => AnimationController(
        value: value,
        duration: duration,
        reverseDuration: reverseDuration,
        debugLabel: debugLabel,
        lowerBound: lowerBound,
        upperBound: upperBound,
        animationBehavior: animationBehavior,
        vsync: l.tickerProvider,
      ),
      onCreate: onCreate,
      onDispose: (c) {
        c.dispose();
        onDispose?.call(c);
      },
      key: FlexibleKey(value, duration, reverseDuration, lowerBound, upperBound,
          animationBehavior, key),
    );
  }

  /// 快速生成一个可重用的 AnimationController
  /// * 调用顺序、[T]、[key]、[value]、[duration]、[reverseDuration]、[debugLabel]、[animationBehavior]
  /// 确定是否为同一个对象 如果发生了变化则重新创建
  /// 与[rememberAnimationController]的重用不同
  AnimationController rememberAnimationControllerUnbounded({
    double value = 0.0,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    void Function(Lifecycle, AnimationController)? onCreate,
    FutureOr<void> Function(AnimationController)? onDispose,
    Object? key,
  }) {
    return remember<AnimationController>(
      factory2: (l) => AnimationController.unbounded(
        value: value,
        duration: duration,
        reverseDuration: reverseDuration,
        debugLabel: debugLabel,
        animationBehavior: animationBehavior,
        vsync: l.tickerProvider,
      ),
      onCreate: onCreate,
      onDispose: (c) {
        c.dispose();
        onDispose?.call(c);
      },
      key: FlexibleKey('Unbounded', value, duration, reverseDuration,
          animationBehavior, key),
    );
  }

  /// 快速生成一个可重用的 ScrollController
  /// * 调用顺序、[T]、[key]、[initialScrollOffset]、[keepScrollOffset]、[debugLabel]
  /// 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [initialScrollOffset] 初始偏移量
  /// * [keepScrollOffset] 是否保持偏移量
  /// * [debugLabel] 调试标签
  /// * [onDispose] 定义销毁时如何处理，晚于[context]的[dispose],**非常注意：不可使用[context]相关内容**
  ScrollController rememberScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
    void Function(Lifecycle, ScrollController)? onCreate,
    FutureOr<void> Function(ScrollController)? onDispose,
    Object? key,
  }) =>
      remember<ScrollController>(
        factory: () => ScrollController(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        ),
        onCreate: onCreate,
        onDispose: (c) {
          c.dispose();
          onDispose?.call(c);
        },
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
    Object? key,
  }) =>
      remember<PageController>(
        factory: () => PageController(
          initialPage: initialPage,
          keepPage: keepPage,
          viewportFraction: viewportFraction,
        ),
        onCreate: onCreate,
        onDispose: (c) {
          c.dispose();
          onDispose?.call(c);
        },
        key: FlexibleKey(initialPage, keepPage, viewportFraction, key),
      );
}
