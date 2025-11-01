A utility similar to Compose’s remember, which leverages anlifecycle to let Flutter’s BuildContext
remember an instance and provide corresponding management functions.

## Usage

#### 1.1 Prepare the lifecycle environment.

```dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use LifecycleApp to wrap the default App
    return LifecycleApp(
      child: MaterialApp(
        title: 'Remember Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorObservers: [
          //Use LifecycleNavigatorObserver.hookMode() to register routing event changes
          LifecycleNavigatorObserver.hookMode(),
        ],
        home: const HomeRememberDemo(title: 'Remember Home Page'),
      ),
    );
  }
}
```

The current usage of PageView and TabBarViewPageView should be replaced with LifecyclePageView and
LifecycleTabBarView. Alternatively, you can wrap the items with LifecyclePageViewItem. You can refer
to [anlifecycle](https://pub.dev/packages/anlifecycle) for guidance.

#### 1.2 Use remember to let the context retain an object.

```dart
class HomeRememberDemo extends StatelessWidget {
  final String title;

  const HomeRememberDemo({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // 记住一个 ValueNotifier<int> listen:并且自动刷新当前context
    final counter = context.rememberValueNotifier(value: 0, listen: true);
    // 新增计步器
    final step = context.rememberValueNotifier(value: 1);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'You have pushed the button this many times: ${counter.value}',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counter.value += step.value;
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Description

```
  /// Remembers the object with the current [context], and will return
  /// the same object in the future.
  /// * The call order, [T], and [key] determine whether it is the same
  ///   object. If any of them change, a new object will be created.
  /// * [factory] and [factory2] define how to construct this object.
  ///   They cannot both be null. [factory] has higher priority than [factory2].
  /// * [onCreate] defines the handling logic after the object is created.
  /// * [onDispose] defines how to handle cleanup when the object is disposed.
  ///   It runs after [context]'s [dispose]. **Important: Do NOT use
  ///   [context]-related content here.**
  T remember<T extends Object>(
      {T Function()? factory,
      T Function(Lifecycle)? factory2,
      void Function(Lifecycle, T)? onCreate,
      FutureOr<void> Function(T)? onDispose,
      Object? key})
      
  /// Quickly creates a reusable [TabController].
  /// * The call order, [key], [initialIndex], [animationDuration],
  ///   and [length] determine whether it is considered the same object.
  ///   If any of these change, a new object will be created.
  TabController rememberTabController({
    int initialIndex = 0,
    Duration? animationDuration,
    required int length,
    void Function(Lifecycle, TabController)? onCreate,
    FutureOr<void> Function(TabController)? onDispose,
    Object? key,
  })
  
  /// Quickly creates a reusable [AnimationController].
  /// * The call order, [key], [value], [duration], [reverseDuration],
  ///   [debugLabel], [lowerBound], [upperBound], and [animationBehavior]
  ///   determine whether it is considered the same object.
  ///   If any of these change, a new object will be created.
  AnimationController rememberAnimationController({
    double? value,
    Duration? duration,
    Duration? reverseDuration,
    String? debugLabel,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    AnimationBehavior animationBehavior = AnimationBehavior.normal,
    void Function(Lifecycle, AnimationController)? onCreate,
    FutureOr<void> Function(AnimationController)? onDispose,
    Object? key,
  })
  
  /// Quickly creates a reusable [ScrollController].
  /// * The call order, [key], [initialScrollOffset], [keepScrollOffset],
  ///   and [debugLabel] determine whether it is considered the same object.
  ///   If any of these change, a new object will be created.
  ScrollController rememberScrollController({
    double initialScrollOffset = 0.0,
    bool keepScrollOffset = true,
    String? debugLabel,
    void Function(Lifecycle, ScrollController)? onCreate,
    FutureOr<void> Function(ScrollController)? onDispose,
    Object? key,
  })
  
  /// Quickly creates a reusable [ValueNotifier].
  /// * The call order, [T], and [key] determine whether it is considered
  ///   the same object. If any of these change, a new object will be created.
  /// * [value], [factory], and [factory2] define how to initialize the
  ///   [ValueNotifier]. At least one must be non-null. These are not used
  ///   as keys for updates.
  /// * [listen] enables the current [context] to automatically listen to
  ///   the created [ValueNotifier]. This is only effective on the first
  ///   creation; subsequent changes have no effect.
  ValueNotifier<T> rememberValueNotifier<T>({
    T? value,
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    void Function(Lifecycle, ValueNotifier<T>)? onCreate,
    FutureOr<void> Function(ValueNotifier<T>)? onDispose,
    bool listen = false,
    Object? key,
  })
  
  /// Quickly creates a reusable [TextEditingController].
  TextEditingController rememberTextEditingController({
    TextEditingValue? value,
    String? text,
    void Function(Lifecycle, TextEditingController)? onCreate,
    FutureOr<void> Function(TextEditingController)? onDispose,
    bool listen = false,
    Object? key,
  })
  
  /// Quickly creates a reusable [ChangeNotifier].
  T rememberChangeNotifier<T extends ChangeNotifier>({
    T Function()? factory,
    T Function(Lifecycle)? factory2,
    void Function(Lifecycle, T)? onCreate,
    FutureOr<void> Function(T)? onDispose,
    bool listen = false,
    Object? key,
  })
  
  /// Quickly creates a reusable [FocusNode].
  FocusNode rememberFocusNode({
    String? debugLabel,
    FocusOnKeyEventCallback? onKeyEvent,
    bool skipTraversal = false,
    bool canRequestFocus = true,
    bool descendantsAreFocusable = true,
    bool descendantsAreTraversable = true,
    Object? key,
  })
  
  /// Quickly creates a reusable [FocusScopeNode].
  FocusScopeNode rememberFocusScopeNode({
    String? debugLabel,
    FocusOnKeyEventCallback? onKeyEvent,
    bool skipTraversal = false,
    bool canRequestFocus = true,
    TraversalEdgeBehavior traversalEdgeBehavior =
        TraversalEdgeBehavior.closedLoop,
    Object? key,
  })
  
  /// Quickly creates a reusable [Stream<T>].
  Stream<T> rememberStream<T>({
    Stream<T> Function()? factory,
    Stream<T> Function(Lifecycle)? factory2,
    LifecycleState state = LifecycleState.created,
    bool repeatLastOnStateAtLeast = false,
    bool closeWhenCancel = false,
    bool? cancelOnError,
    Object? key,
  })
  
  /// Quickly creates a reusable [Stream<T>].
  Stream<T> rememberStreamXXX({})
  
  /// Quickly creates a reusable [Timer].
  Timer rememberTimer({
    required Duration duration,
    required void Function() callback,
    Object? key,
  })
```

## Additional information

See [anlifecycle](https://pub.dev/packages/anlifecycle)

See [cancelable](https://pub.dev/packages/cancellable)

See [an_lifecycle_cancellable](https://pub.dev/packages/an_lifecycle_cancellable)

See [an_viewmodel](https://pub.dev/packages/an_viewmodel)
