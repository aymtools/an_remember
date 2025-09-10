import 'dart:async';
import 'dart:collection';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    hide BuildContextLifecycleRememberExt;
import 'package:anlifecycle/anlifecycle.dart';
import 'package:flutter/material.dart';
import 'package:remember/src/tools.dart';
import 'package:weak_collections/weak_collections.dart';

class _RememberEntry<T> {
  final T value;
  final Object? key;
  FutureOr<void> Function(T)? onDispose;

  bool checkKey<E>(Object? key) {
    return E == T && this.key == key;
  }

  Type get _type => T;

  _RememberEntry(this.value, this.key, this.onDispose);

  void _safeInvokeOnDispose() {
    if (onDispose != null) {
      try {
        onDispose!(value);
      } catch (exception, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'an_lifecycle_cancellable',
            context: ErrorDescription('remember $T run onDispose error'),
          ),
        );
      }
    }
  }
}

final Finalizer<_RememberDisposeObserver> _finalizer =
    Finalizer<_RememberDisposeObserver>((observer) {
  observer._safeCallDisposer(callDetach: false);
});

abstract class RememberComposer {
  final _values = HashMap<int, _RememberEntry<dynamic>>.identity();

  int _currentKey = 0;
  RememberComposer? _last;

  int get _currKey => ++_currentKey;

  void _resetKey() {
    _currentKey = 0;
  }

  void _reset() {
    _resetKey();
    _last?._reset();
    _last = null;
  }
}

class _RememberDisposeObserver extends RememberComposer
    with LifecycleStateChangeObserver {
  final WeakReference<Lifecycle> _lifecycle;
  final WeakReference<BuildContext> _context;
  bool _isDisposed = false;

  _RememberDisposeObserver._(BuildContext context, Lifecycle lifecycle)
      : _context = WeakReference(context),
        _lifecycle = WeakReference(lifecycle) {
    lifecycle.addLifecycleObserver(this);
    _finalizer.attach(context, this, detach: _context);
  }

  @override
  void onStateChange(LifecycleOwner owner, LifecycleState state) {
    if (state == LifecycleState.destroyed) {
      _safeCallDisposer();
    } else if (state > LifecycleState.initialized &&
        _context.target?.mounted != true) {
      owner.removeLifecycleObserver(this, fullCycle: false);
      _safeCallDisposer();
    }
  }

  void _safeCallDisposer({bool callDetach = true}) async {
    if (_isDisposed) return;
    _isDisposed = true;

    final entries = [..._values.values];
    _values.clear();

    if (callDetach) {
      _finalizer.detach(_context);
    } else {
      _lifecycle.target?.removeLifecycleObserver(this, fullCycle: false);
    }

    for (var disposable in entries) {
      disposable._safeInvokeOnDispose();
    }
  }

  T _create<T extends Object>(
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    void Function(Lifecycle, T)? onCreate,
  ) {
    final lifecycle = _lifecycle.target!;
    var data = factory?.call() ?? factory2?.call(lifecycle);
    if (data == null) {
      throw 'factory and factory2 cannot be null at the same time';
    }

    final Object? debugCheckForReturnedFuture =
        onCreate?.call(lifecycle, data) as dynamic;
    assert(() {
      if (debugCheckForReturnedFuture is Future) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'remember<$T> onCreate() returned a Future.',
          ),
          ErrorDescription(
            'remember<$T> onCreate() must be a void method without an `async` keyword.',
          ),
          ErrorHint(
            'Rather than awaiting on asynchronous work directly inside of onCreate, '
            'call a separate method to do this work without awaiting it.',
          ),
        ]);
      }
      return true;
    }());
    return data;
  }

  T getOrCreate<T extends Object>(
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    void Function(Lifecycle, T)? onCreate,
    FutureOr<void> Function(T)? onDispose,
    Object? key,
  ) {
    if (_isDisposed) {
      throw 'RememberDisposeObserver has been disposed';
    }

    final currKey = _currKey;
    final entity = _values[currKey];
    if (entity != null && entity.checkKey<T>(key)) {
      (entity as _RememberEntry<T>).onDispose = onDispose;
      return entity.value;
    } else {
      final newEntry = _RememberEntry<T>(
          _create(factory, factory2, onCreate), key, onDispose);
      entity?._safeInvokeOnDispose();
      _values[currKey] = newEntry;
      return newEntry.value;
    }
  }
}

final _keyRemember = Object();

RememberComposer? _composer;

void _resetComposer() {
  _needReset = true;
  _composer?._reset();
  _composer = null;
}

bool _needReset = true;

set _currComposer(RememberComposer value) {
  if (identical(_composer, value)) return;

  assert(() {
    var composer = _composer;
    while (composer != null && composer._last != null) {
      if (identical(composer._last, value)) {
        //检测到循环引用
        throw Exception("Can only be used in the build function.");
      }
      composer = composer._last;
    }
    value._last = _composer;
    return true;
  }());

  value._resetKey();
  _composer = value;
  if (_needReset) {
    _needReset = false;
    scheduleMicrotask(_resetComposer);
  }
}

extension on _RememberDisposeObserver {
  T _remember<T extends Object>(
      T Function()? factory,
      T Function(Lifecycle)? factory2,
      void Function(Lifecycle, T)? onCreate,
      FutureOr<void> Function(T)? onDispose,
      Object? key) {
    _currComposer = this;
    return getOrCreate<T>(factory, factory2, onCreate, onDispose, key);
  }
}

extension BuildContextLifecycleRememberExt on BuildContext {
  /// 以当前[context] 记住该对象，并且以后将再次返回该对象
  /// * 调用顺序、[T]和 [key] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [factory] 和 [factory2] 如何构建这个对象，不能同时为空, [factory] 优先级高于 [factory2]
  /// * [onCreate] 创建完成时的处理
  /// * [onDispose] 定义销毁时如何处理，晚于[context]的[dispose],**非常注意：不可使用[context]相关内容**
  T remember<T extends Object>(
      {T Function()? factory,
      T Function(Lifecycle)? factory2,
      void Function(Lifecycle, T)? onCreate,
      FutureOr<void> Function(T)? onDispose,
      Object? key}) {
    if (factory == null && factory2 == null) {
      throw 'factory and factory2 cannot be null at the same time';
    }

    final lifecycle = Lifecycle.of(this);
    final managers =
        lifecycle.extData.getOrPut<Map<BuildContext, _RememberDisposeObserver>>(
      key: _keyRemember,
      ifAbsent: (l) {
        final result =
            WeakHashMap<BuildContext, _RememberDisposeObserver>.identity();

        /// 不持有 Map，防止内存泄漏
        lifecycle.addLifecycleObserver(MapAutoClearObserver(result));
        return result;
      },
    );

    final manager = managers.putIfAbsent(
      this,
      () => _RememberDisposeObserver._(this, lifecycle),
    );

    return manager._remember<T>(factory, factory2, onCreate, onDispose, key);
  }
}
