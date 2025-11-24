import 'dart:async';

import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/widgets.dart';
import 'package:weak_collections/weak_collections.dart';

class _RememberEntry<T> {
  final Cancellable _disposable;
  final T value;
  final Object? key;
  FutureOr<void> Function(T)? onDispose;
  bool _isDisposed = false;

  bool checkKey<E>(Object? key) {
    return E == T && this.key == key;
  }

  // Type get _type => T;

  _RememberEntry(this.value, this.key, this._disposable, this.onDispose) {
    _disposable.whenCancel.then((_) => _safeInvokeOnDispose());
  }

  void _safeInvokeOnDispose() {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;
    _disposable.cancel();

    if (onDispose != null) {
      try {
        onDispose!(value);
      } catch (exception, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: exception,
            stack: stack,
            library: 'remember',
            context: ErrorDescription('remember $T run onDispose error'),
          ),
        );
      }
    }
  }
}

final Finalizer<_RememberComposer> _finalizer =
    Finalizer<_RememberComposer>((observer) {
  observer._safeCallDisposer(callDetach: false);
});

final _empty = List.filled(0, null);

abstract class RememberComposer {
  static const initLength = 8;
  static const maxLength = 1 << 30;
  var _length = initLength;
  late var _values = List<_RememberEntry?>.filled(_length, null);

  BuildContext? get _host;

  int _currentKey = 0;
  RememberComposer? _last;

  int get _currKey {
    final r = ++_currentKey;
    if (r < _length) {
      return r;
    }
    if (r >= maxLength) {
      throw Exception(
          "There are too many slots. Please adjust the usage plan.");
    }

    /// 每次填充满的时候增长一倍
    _length = _length << 1;
    final list = List<_RememberEntry?>.filled(_length, null);
    for (int i = 0; i < r; i++) {
      list[i] = _values[i];
    }
    _values = list;
    return r;
  }

  void _resetKey() {
    _currentKey = 0;
  }

  void _reset() {
    _resetKey();
    _last?._reset();
    _last = null;
  }

  T _getOrCreate<T extends Object>(
      T Function()? factory,
      T Function(Lifecycle)? factory2,
      T Function(Lifecycle, Cancellable)? factory3,
      void Function(T, Lifecycle, Cancellable)? onCreate,
      FutureOr<void> Function(T)? onDispose,
      Object? key);
}

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

class _RememberComposer extends RememberComposer {
  final WeakReference<Lifecycle> _lifecycle;
  final WeakReference<BuildContext> _context;
  bool _isDisposed = false;

  @override
  BuildContext? get _host => _context.target;

  _RememberComposer._(BuildContext context, Lifecycle lifecycle)
      : _context = WeakReference(context),
        _lifecycle = WeakReference(lifecycle) {
    _finalizer.attach(context, this, detach: _context);
  }

  void _safeCallDisposer({bool callDetach = true}) async {
    if (_isDisposed) return;
    _isDisposed = true;

    final entries = [..._values];
    _values = _empty;

    if (callDetach) {
      _finalizer.detach(_context);
    }

    for (var disposable in entries) {
      disposable?._safeInvokeOnDispose();
    }
  }

  _RememberEntry<T> _createEntry<T extends Object>(
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    T Function(Lifecycle, Cancellable)? factory3,
    void Function(T, Lifecycle, Cancellable)? onCreate,
    FutureOr<void> Function(T)? onDispose,
    Object? key,
  ) {
    final lifecycle = _lifecycle.target!;
    if (lifecycle.currentLifecycleState == LifecycleState.destroyed) {
      throw Exception('Cannot create remember<$T> when lifecycle is destroyed');
    }

    final disposable = Cancellable();
    var data = factory?.call() ??
        factory2?.call(lifecycle) ??
        factory3?.call(lifecycle, disposable);
    if (data == null) {
      throw Exception(
          'factory and factory2 and factory3 cannot be null at the same time');
    }
    final result = _RememberEntry<T>(data, key, disposable, onDispose);

    final Object? debugCheckForReturnedFuture =
        onCreate?.call(data, lifecycle, disposable) as dynamic;
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
    return result;
  }

  @override
  T _getOrCreate<T extends Object>(
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    T Function(Lifecycle, Cancellable)? factory3,
    void Function(T, Lifecycle, Cancellable)? onCreate,
    FutureOr<void> Function(T)? onDispose,
    Object? key,
  ) {
    if (_isDisposed) {
      throw 'RememberDisposeObserver has been disposed';
    }

    final currKey = _currKey;
    final entity = _values[currKey];
    if (entity != null &&
        entity.checkKey<T>(key) &&
        entity._disposable.isAvailable) {
      (entity as _RememberEntry<T>).onDispose = onDispose;
      return entity.value;
    } else {
      final newEntry =
          _createEntry(factory, factory2, factory3, onCreate, onDispose, key);

      entity?._disposable.cancel();

      if (newEntry._disposable.isAvailable) {
        /// 创建过程中被取消了 不进行保存
        _values[currKey] = newEntry;
      }
      return newEntry.value;
    }
  }
}

final Map<LifecycleOwner, _RememberComposerObserver> _rememberComposers =
    WeakHashMap.identity();

class _RememberComposerObserver with LifecycleEventObserver {
  final WeakReference<Lifecycle> _lifecycle;
  final WeakHashMap<BuildContext, _RememberComposer> _managers =
      WeakHashMap.identity();

  _RememberComposerObserver(Lifecycle lifecycle)
      : _lifecycle = WeakReference(lifecycle) {
    lifecycle.addLifecycleObserver(this);
  }

  @override
  void onDestroy(LifecycleOwner owner) {
    super.onDestroy(owner);
    final values = [..._managers.values];
    _managers.clear();
    for (var value in values) {
      value._safeCallDisposer();
    }
    _rememberComposers.remove(owner);
  }

  _RememberComposer getComposer(BuildContext context) {
    return _managers.putIfAbsent(
        context, () => _RememberComposer._(context, _lifecycle.target!));
  }
}

extension BuildContextLifecycleRememberExt on BuildContext {
  /// 以当前[context] 记住该对象，并且以后将再次返回该对象
  /// * 调用顺序、[T]和 [key] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [factory],[factory2],[factory3]如何构建这个对象，不能同时为空, [factory] 优先级高于 [factory2] 优先于 [factory3]
  /// * [bindLifecycle] 已过时请使用[factory3] 绑定到生命周期并使用返回的结果内容，参数[Cancellable]是当前[remember]的销毁状态, 调用时机优先于[onCreate]
  /// * [onCreate] 创建完成时的处理
  /// * [onDispose] 定义销毁时如何处理，晚于[context]的[dispose],**非常注意：不可使用[context]相关内容**
  T remember<T extends Object>(
      {T Function()? factory,
      T Function(Lifecycle)? factory2,
      T Function(Lifecycle, Cancellable)? factory3,
      @Deprecated('use factory3')
      T Function(T, Lifecycle, Cancellable)? bindLifecycle,
      void Function(T, Lifecycle, Cancellable)? onCreate,
      FutureOr<void> Function(T)? onDispose,
      Object? key}) {
    if (factory == null && factory2 == null && factory3 == null) {
      throw Exception(
          'factory and factory2 and factory3 cannot be null at the same time');
    }

    if (!mounted) {
      throw Exception('context has not been mounted');
    }

    /// 兼容旧版 bindLifecycle 参数
    if (bindLifecycle != null) {
      final f3 = factory3;
      factory3 = (l, c) {
        var r = factory?.call() ?? factory2?.call(l) ?? f3?.call(l, c);
        r = r as T;
        r = bindLifecycle(r, l, c);
        return r;
      };
    }

    RememberComposer? composer;
    if (identical(this, _composer?._host)) {
      composer = _composer!;
    }
    if (composer == null) {
      final lifecycle = Lifecycle.of(this);
      final managers = _rememberComposers.putIfAbsent(
          lifecycle.owner, () => _RememberComposerObserver(lifecycle));
      composer = managers.getComposer(this);
      _currComposer = composer;
    }
    return composer._getOrCreate<T>(
        factory, factory2, factory3, onCreate, onDispose, key);
  }
}
