import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    show FlexibleKey;
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember_listenable.dart';

extension RememeberFocusNodeExt on BuildContext {
  /// 快速生成一个可重用的 FocusNode
  /// * 调用顺序、[key]、[debugLabel]、[skipTraversal]、[canRequestFocus]、[descendantsAreFocusable]、[descendantsAreTraversable] 确定是否为同一个对象 如果发生了变化则重新创建
  FocusNode rememberFocusNode({
    String? debugLabel,
    FocusOnKeyEventCallback? onKeyEvent,
    bool skipTraversal = false,
    bool canRequestFocus = true,
    bool descendantsAreFocusable = true,
    bool descendantsAreTraversable = true,
    Object? key,
  }) {
    return rememberChangeNotifier<FocusNode>(
      factory: () => FocusNode(
        debugLabel: debugLabel,
        onKeyEvent: onKeyEvent,
        skipTraversal: skipTraversal,
        canRequestFocus: canRequestFocus,
        descendantsAreFocusable: descendantsAreFocusable,
        descendantsAreTraversable: descendantsAreTraversable,
      ),
      onDispose: (t) => t.dispose(),
      key: FlexibleKey(debugLabel, skipTraversal, canRequestFocus,
          descendantsAreFocusable, descendantsAreTraversable, key),
    );
  }

  /// 快速生成一个可重用的 FocusScopeNode
  /// * 调用顺序、[key]、[debugLabel]、[skipTraversal]、[canRequestFocus]、[traversalEdgeBehavior] 确定是否为同一个对象 如果发生了变化则重新创建
  FocusScopeNode rememberFocusScopeNode({
    String? debugLabel,
    FocusOnKeyEventCallback? onKeyEvent,
    bool skipTraversal = false,
    bool canRequestFocus = true,
    TraversalEdgeBehavior traversalEdgeBehavior =
        TraversalEdgeBehavior.closedLoop,
    Object? key,
  }) {
    return rememberChangeNotifier<FocusScopeNode>(
      factory: () => FocusScopeNode(
        debugLabel: debugLabel,
        onKeyEvent: onKeyEvent,
        skipTraversal: skipTraversal,
        canRequestFocus: canRequestFocus,
        traversalEdgeBehavior: traversalEdgeBehavior,
      ),
      onDispose: (t) => t.dispose(),
      key: FlexibleKey(debugLabel, skipTraversal, canRequestFocus,
          traversalEdgeBehavior, key),
    );
  }
}
