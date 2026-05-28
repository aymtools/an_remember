part of 'remember.dart';

/// Remember的Created回调
typedef RememberEntryCreatedCallback = void Function(
    Object value,
    BuildContext context,
    Lifecycle hostLifecycle,
    Cancellable disposable,
    int slot,
    Object? key,
    Type type);

/// Remember的全局回调
/// - **注意**
/// - 任何注册的会回调内容都是以非try{}catch(e){}的方式运行，注意代码安全，
/// - 传递的参数注意内存引用会阻止回收
class RememberCallbacks {
  RememberCallbacks._();

  static final RememberCallbacks _instance = RememberCallbacks._();

  static RememberCallbacks get instance => _instance;

  final Set<RememberEntryCreatedCallback> _onEntryCreatedCallbacks = {};

  /// 注册一个创建回调
  void addRememberEntryCreatedCallback(RememberEntryCreatedCallback callback) {
    _onEntryCreatedCallbacks.add(callback);
  }

  /// 移除一个创建回调
  void removeRememberEntryCreatedCallback(
      RememberEntryCreatedCallback callback) {
    _onEntryCreatedCallbacks.remove(callback);
  }

  void _notifyEntryCreated(
      Object value,
      BuildContext context,
      Lifecycle hostLifecycle,
      Cancellable disposable,
      int slot,
      Object? key,
      Type type) {
    if (_onEntryCreatedCallbacks.isEmpty) {
      return;
    }
    final callbacks =
        Set<RememberEntryCreatedCallback>.of(_onEntryCreatedCallbacks);
    for (var c in callbacks) {
      c(value, context, hostLifecycle, disposable, slot, key, type);
    }
  }
}
