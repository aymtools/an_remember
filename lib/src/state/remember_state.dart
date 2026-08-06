import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart';
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember.dart';
import 'package:remember/src/tools/element_safe.dart';

part 'remember_state_context.dart';

/// 只读的状态，只允许通过计算器自动赋值
abstract class RememberState<T> {
  String? get debugLabel;

  T get value;

  void addListener(void Function() listener, {Cancellable? cancellable});

  void removeListener(void Function() listener);
}

/// 多种状态，允许通过计算器自动赋值和直接赋值
abstract class RememberMutableState<T> extends RememberState<T> {
  set value(T newValue);
}

class _RememberState<T> extends RememberMutableState<T> {
  WeakReference<Lifecycle>? lifecycle;
  final Cancellable disposable;

  RememberStateComputed<T>? computed;
  final RememberStateEquality<T> _equality;

  @override
  final String? debugLabel;

  /// 不可以使用.identity
  /// ** 提取一个对象的方法（例如 obj.myMethod）时，Dart 会在后台创建一个新的闭包对象（这个过程叫 Tear-off）。
  /// ** 在 Dart 中，对同一个实例方法进行多次 tear-off，每次都会生成一个新的闭包对象（不同的内存地址）。
  /// ** 即使是同一个对象，多次添加它的同一个实例方法，Set.identity() 也会认为它们是不同的，从而保留 多个。
  final _listeners = <void Function()>{};

  late Cancellable listenerCancellable;

  static bool _defEquality(dynamic a, dynamic b) => a == b;

  _RememberState(Lifecycle lifecycle, this.disposable, this.computed,
      {RememberStateEquality<T>? equality, this.debugLabel})
      : lifecycle = WeakReference(lifecycle),
        _equality = equality ?? _defEquality {
    listenerCancellable = disposable.makeCancellable();
    disposable.whenCancel.then((_) {
      this.lifecycle = null;
      this.computed = null;
      _listeners.clear();
    });
  }

  late T _value;

  bool _firstCompute = true;
  bool _needCompute = true;

  @override
  set value(T newValue) {
    final notifierFlag = !_equality(_value, newValue);
    _value = newValue;
    if (notifierFlag) {
      notifyListeners();
    }
  }

  @override
  T get value {
    if (disposable.isAvailable) {
      final curr = _currentState;
      if (curr != null && curr != this) {
        addRememberStateListener(curr);
      }
      _computeValue();
    }
    return _value;
  }

  void _firstComputeValue() {
    if (_firstCompute) {
      _computeValue();
      _firstCompute = false;
    }
  }

  void _computeValue() {
    if (disposable.isUnavailable) return;
    final computed = this.computed;
    if (_needCompute && computed != null) {
      bool notifierFlag = false;

      final tmp = _currentState;
      _currentState = this;
      if (_firstCompute) {
        _value = computed();
        _firstCompute = false;
      } else {
        final tmpValue = _value;
        _value = computed();
        notifierFlag = !_equality(tmpValue, _value);
      }
      _needCompute = false;
      _currentState = tmp;

      if (notifierFlag) {
        notifyListeners();
      }
    }
  }

  void _clearComputed() => computed = null;

  void _markNeedCompute() {
    if (disposable.isUnavailable) return;
    _needCompute = true;
    listenerCancellable.cancel();
    listenerCancellable = disposable.makeCancellable();
  }

  void addRememberStateListener(_RememberState<dynamic> state) {
    addListener(state._markNeedCompute, cancellable: state.listenerCancellable);
  }

  void notifyListeners() {
    if (disposable.isUnavailable || _listeners.isEmpty) return;
    _currentNotifier.notify(_runNotifyListeners);
  }

  void _runNotifyListeners() {
    if (disposable.isUnavailable || _listeners.isEmpty) return;
    final listeners = [..._listeners];
    for (final listener in listeners) {
      listener();
    }
  }

  bool get hasListeners => _listeners.isNotEmpty;

  void dispose() {
    disposable.cancel();
  }

  @override
  void addListener(void Function() listener, {Cancellable? cancellable}) {
    if (disposable.isUnavailable || cancellable?.isUnavailable == true) return;
    _listeners.add(listener);
    cancellable?.onCancel.then((_) => _listeners.remove(listener));
  }

  @override
  void removeListener(void Function() listener) {
    if (disposable.isUnavailable) return;
    _listeners.remove(listener);
  }
}

_RememberState<dynamic>? _currentState;
_ComputedNotifier _currentNotifier = _ComputedNotifier();

class _ComputedNode {
  _ComputedNode? parent;
}

class _ComputedContext {}

class _ComputedNotifier {
  void notify(void Function() notifier) {
    notifier();
  }
}
