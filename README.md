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
          counter.value++;
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Additional information

See [anlifecycle](https://pub.dev/packages/anlifecycle)

See [cancelable](https://pub.dev/packages/cancellable)

See [an_lifecycle_cancellable](https://pub.dev/packages/an_lifecycle_cancellable)
