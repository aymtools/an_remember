import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    hide BuildContextLifecycleRememberExt;
import 'package:flutter/material.dart';
import 'package:remember/src/remember.dart';

extension BuildContextLifecycleRememberControllersExt on BuildContext {
  /// 获取可用的TabController
  TabController rememberTabController({
    int initialIndex = 0,
    Duration? animationDuration,
    required int length,
    FutureOr<void> Function(TabController)? onDispose,
    Object? key,
  }) =>
      remember<TabController>(
        factory2: (l) => TabController(
          initialIndex: initialIndex,
          length: length,
          vsync: l.tickerProvider,
        ),
        onDispose: (c) {
          c.dispose();
          onDispose?.call(c);
        },
        key: FlexibleKey(initialIndex, animationDuration, length, key),
      );

  /// 动画控制器
  AnimationController rememberAnimationController({
    double? value,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
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
      onDispose: (c) {
        c.dispose();
        onDispose?.call(c);
      },
      key: FlexibleKey(value, duration, reverseDuration, lowerBound, upperBound,
          animationBehavior, key),
    );
  }

  /// 动画控制器
  AnimationController rememberAnimationControllerUnbounded({
    double value = 0.0,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
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
      onDispose: (c) {
        c.dispose();
        onDispose?.call(c);
      },
      key: FlexibleKey('Unbounded', value, duration, reverseDuration,
          animationBehavior, key),
    );
  }

  /// 滚动控制器
  ScrollController rememberScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
    FutureOr<void> Function(ScrollController)? onDispose,
    Object? key,
  }) =>
      remember<ScrollController>(
        factory: () => ScrollController(
          initialScrollOffset: initialScrollOffset,
          keepScrollOffset: keepScrollOffset,
          debugLabel: debugLabel,
        ),
        onDispose: (c) {
          c.dispose();
          onDispose?.call(c);
        },
        key:
            FlexibleKey(initialScrollOffset, keepScrollOffset, debugLabel, key),
      );

  /// PageView
  PageController rememberPageController({
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    FutureOr<void> Function(PageController)? onDispose,
    Object? key,
  }) =>
      remember<PageController>(
        factory: () => PageController(
          initialPage: initialPage,
          keepPage: keepPage,
          viewportFraction: viewportFraction,
        ),
        onDispose: (c) {
          c.dispose();
          onDispose?.call(c);
        },
        key: FlexibleKey(initialPage, keepPage, viewportFraction, key),
      );
}
