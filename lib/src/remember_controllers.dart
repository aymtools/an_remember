import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    show FlexibleKey, LifecycleTickerProviderExt;
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember_listenable.dart';

extension RememberControllersExt on BuildContext {
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
    void Function(AnimationController, Lifecycle, Cancellable)? onCreate,
    FutureOr<void> Function(AnimationController)? onDispose,
    bool listen = false,
    Object? key,
  }) {
    return rememberListenable<AnimationController>(
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
      listen: listen,
      key: FlexibleKey(value, duration, reverseDuration, debugLabel, lowerBound,
          upperBound, animationBehavior, key),
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
    void Function(AnimationController, Lifecycle, Cancellable)? onCreate,
    FutureOr<void> Function(AnimationController)? onDispose,
    bool listen = false,
    Object? key,
  }) {
    return rememberListenable<AnimationController>(
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
      listen: listen,
      key: FlexibleKey('Unbounded', value, duration, reverseDuration,
          debugLabel, animationBehavior, key),
    );
  }

  /// 快速生成一个可重用的 TextEditingController
  /// * 调用顺序、[T]、[key]、[text]、[value]、[onCreate]、[onDispose]
  /// 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [value] 初始值,优先级高于[text]
  /// * [text] 初始文本
  TextEditingController rememberTextEditingController({
    TextEditingValue? value,
    String? text,
    void Function(TextEditingController, Lifecycle, Cancellable)? onCreate,
    FutureOr<void> Function(TextEditingController)? onDispose,
    bool listen = false,
    Object? key,
  }) =>
      rememberChangeNotifier<TextEditingController>(
        factory: () => value == null
            ? TextEditingController(text: text)
            : TextEditingController.fromValue(value),
        onCreate: onCreate,
        onDispose: onDispose,
        listen: listen,
        key: FlexibleKey(text, value, key),
      );
}
