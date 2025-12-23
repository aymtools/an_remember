import 'package:cancellable/cancellable.dart';
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember.dart';

extension RememeberCancellableExt on BuildContext {
  /// 快速生成一个可重用的 Cancellable
  /// * 调用顺序、[key] 确定是否为同一个对象 如果发生了变化则重新创建
  Cancellable rememberLiveCancellable({
    Cancellable? father,
    bool weakRef = true,
    Object? key,
  }) {
    return remember<Cancellable>(
      factory3: (l, c) => c.makeCancellable(father: father, weakRef: weakRef),
      key: key,
    );
  }
}
