import 'dart:async';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    show FlexibleKey;
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember.dart';

extension RememeberTimerExt on BuildContext {
  /// 快速生成一个可重用的 Timer
  /// * 调用顺序、[key]、[duration] 确定是否为同一个对象 如果发生了变化则重新创建
  Timer rememberTimer({
    required Duration duration,
    required void Function() callback,
    Object? key,
  }) {
    return remember<Timer>(
      factory: () => Timer(duration, callback),
      onDispose: (t) => t.cancel(),
      key: FlexibleKey(duration, key),
    );
  }

  /// 快速生成一个可重用的 Timer.periodic
  /// * 调用顺序、[key]、[duration] 确定是否为同一个对象 如果发生了变化则重新创建
  Timer rememberTimerPeriodic({
    required Duration duration,
    required void Function(Timer) callback,
    Object? key,
  }) {
    return remember<Timer>(
      factory: () => Timer.periodic(duration, callback),
      onDispose: (t) => t.cancel(),
      key: FlexibleKey('periodic', duration, key),
    );
  }
}
