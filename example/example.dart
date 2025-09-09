import 'package:anlifecycle/anlifecycle.dart';
import 'package:flutter/material.dart';
import 'package:remember/remember.dart';

void main() {
  // Coming soon.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LifecycleApp(
      child: MaterialApp(
        title: 'Remember Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorObservers: [
          LifecycleNavigatorObserver.hookMode(),
        ],
        home: const HomeRememberDemo(title: 'Remember Demo Home Page'),
      ),
    );
  }
}

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
