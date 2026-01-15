import 'package:flutter/widgets.dart';
import 'package:remember/src/remember.dart';

extension RememeberGlobalKeyExt on BuildContext {
  /// 快速生成一个可重用的 GlobalKey
  /// * 调用顺序、[key] 确定是否为同一个对象 如果发生了变化则重新创建
  GlobalKey<T> rememberGlobalKey<T extends State<StatefulWidget>>({
    String? debugLabel,
    Object? key,
  }) {
    return remember<GlobalKey<T>>(
        factory: () => GlobalKey<T>(debugLabel: debugLabel), key: key);
  }
}
