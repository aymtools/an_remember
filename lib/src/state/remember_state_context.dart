part of 'remember_state.dart';

/// 提供给[rememberState]的[computed]计算时 来获取当前的Lifecycle对象
Lifecycle get computedLifecycle {
  final curr = _currentState;
  if (curr == null) throw StateError('Only can be called in rememberState');
  final lifecycle = curr.lifecycle?.target;
  if (lifecycle == null) {
    throw StateError('State lifecycle is no longer available');
  }
  return lifecycle;
}

/// 提供给[rememberState]的[computed]计算时 来获取当前的Cancellable对象
Cancellable get computedDisposable {
  final curr = _currentState;
  if (curr == null) throw StateError('Only can be called in rememberState');
  return curr.disposable.makeCancellable(weakRef: false);
}

extension RememberStateExt on BuildContext {
  /// 自动记住和计算新的状态信息 只能使用有其他的 [rememberState] 的内容 不可以与 [rememberListenable] 系列联动
  /// 只可以由计算器对值进行修改，使用处无权修改
  RememberState<T> rememberState<T>({
    required RememberStateComputed<T> computed,
    String? debugLabel,
    bool lazyCompute = true,
    bool listen = true,
  }) {
    return remember<RememberState<T>>(
      factory3: mutableState<T>(
        computed: computed,
        lazyCompute: lazyCompute,
        debugLabel: debugLabel,
        context: listen ? this : null,
      ),
      key: 'rememberState',
    );
  }

  /// 可以在使用处和计算器双方都可以进行赋值修改
  RememberMutableState<T> rememberMutableState<T>({
    required RememberStateComputed<T> computed,
    String? debugLabel,
    bool lazyCompute = true,
    bool listen = true,
  }) {
    return remember<RememberMutableState<T>>(
      factory3: mutableState<T>(
        computed: computed,
        lazyCompute: lazyCompute,
        debugLabel: debugLabel,
        context: listen ? this : null,
      ),
      key: 'rememberMutableState',
    );
  }
}

typedef RememberStateCreator<T> = RememberState<T> Function(
    Lifecycle, Cancellable);
typedef RememberMutableStateCreator<T> = RememberMutableState<T> Function(
    Lifecycle, Cancellable);
typedef RememberStateEquality<T> = bool Function(T, T);

typedef RememberStateComputed<T> = T Function();

RememberMutableStateCreator<T> mutableState<T>({
  required RememberStateComputed<T> computed,
  bool lazyCompute = false,
  String? debugLabel,
  BuildContext? context,
}) =>
    (l, c) {
      final state = _RememberState<T>(l, c, computed, debugLabel: debugLabel);
      if (!lazyCompute) {
        state._firstComputeValue();
      }
      if (context is Element) {
        state.addListener(
            safeMarkNeedsBuildVoidListener(context, cancellable: c),
            cancellable: c);
      }
      return state;
    };

/// 只会触发首次计算，首次计算完成后，后续不会再次触发计算。永久性的不会恢复。
RememberStateComputed<T> expensiveComputation<T>(
    {required RememberStateComputed<T> computed}) {
  bool computed0 = false;
  T? value;
  return () {
    if (computed0) return value as T;
    value = computed();
    computed0 = true;
    return value as T;
  };
}

/// 固定返回值，切上游任何变化不会重新计算
RememberStateComputed<T> stateOf<T>(T value) =>
    expensiveComputation(computed: () => value);

RememberStateComputed<List<T>> stateListOf<T>(List<T> value) =>
    expensiveComputation(computed: () => value);

RememberStateComputed<Map<K, V>> stateMapOf<K, V>(Map<K, V> value) =>
    expensiveComputation(computed: () => value);

RememberStateComputed<Set<E>> stateSetOf<E>(Set<E> value) =>
    expensiveComputation(computed: () => value);

class _UntrackedRememberState extends _RememberState<void> {
  final _RememberState<dynamic> last;

  static void _computed() {}

  @override
  Cancellable get listenerCancellable => Cancellable.cancelled();

  _UntrackedRememberState(this.last)
      : super(last.lifecycle!.target!, last.disposable, _computed);

  @override
  void addListener(void Function() listener, {Cancellable? cancellable}) {}
}

/// 只读取状态的值而不建立依赖关系。 会向内部持续传染。范围域是当前[computed] 以及 [computed]内部的
RememberStateComputed<T> untracked<T>(
        {required RememberStateComputed<T> computed}) =>
    () {
      final last = _currentState;
      _currentState = null;
      final value = computed();
      _currentState = last;
      return value;
    };

/// 在当前作用域内建立一个求值器，对内部的computed求值器的依赖关系进行收集。 范围域是当前[computed] 以及 [computed]内部的
T effect<T>({required RememberStateComputed<T> computed}) {
  return computed();
}

class _ComputedBatchNotifier extends _ComputedNotifier {
  final Set<void Function()> _notifiers = {};

  @override
  void notify(void Function() notifier) {
    _notifiers.add(notifier);
  }

  void notifyAll() {
    final notifiers = _notifiers.toList();
    _notifiers.clear();
    for (final notifier in notifiers) {
      notifier();
    }
  }
}

/// 尽可能压缩变化的通知 在[computed]执行完毕后才通知所有需要通知的内容  如果通知发送后触发了再次计算的依然会触发新的计算
RememberStateComputed<T> batch<T>(
    {required RememberStateComputed<T> computed}) {
  return () {
    final tmpNotifier = _currentNotifier;
    final curr = _ComputedBatchNotifier();
    _currentNotifier = curr;
    final value = computed();
    curr.notifyAll();
    _currentNotifier = tmpNotifier;
    return value;
  };
}

RememberStateComputed<T> stateOfValueNotifier<T>({
  required ValueNotifier<T> valueNotifier,
  bool lazyCompute = false,
  String? debugLabel,
  BuildContext? context,
}) {
  return () {
    expensiveComputation(
      computed: () {
        final curr = _currentState;
        if (curr != null && curr.disposable.isAvailable) {
          valueNotifier.addCListener(curr.disposable, curr.notifyListeners);
        }
      },
    );
    return valueNotifier.value;
  };
}
