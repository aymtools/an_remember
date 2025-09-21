import 'package:anlifecycle/anlifecycle.dart';
import 'package:flutter/material.dart';

class LifecycleAppTester extends StatelessWidget {
  final LifecycleNavigatorObserver? navigatorObserver;
  final Widget? home;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;

  const LifecycleAppTester(
      {super.key,
      this.navigatorObserver,
      this.home,
      this.initialRoute,
      this.onGenerateRoute});

  @override
  Widget build(BuildContext context) {
    return LifecycleAppOwner(
      child: MaterialApp(
        navigatorObservers: [
          navigatorObserver ?? LifecycleNavigatorObserver.hookMode()
        ],
        home: home,
        initialRoute: initialRoute,
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}

class PageTester extends StatelessWidget {
  const PageTester({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('title'),
      ),
      body: const Center(
        child: Text('body'),
      ),
    );
  }
}

class ChangeNotifierTester extends ChangeNotifier {
  int value = 0;

  bool isDisposed = false;

  void increment() {
    value++;
    notifyListeners();
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }

  static bool assertIsDisposed(ChangeNotifier notifier) {
    bool assertDisposed = false;
    try {
      assertDisposed = ChangeNotifier.debugAssertNotDisposed(notifier);
    } catch (_) {}
    return !assertDisposed;
  }
}
