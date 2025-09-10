import 'dart:math';

import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    hide BuildContextLifecycleRememberExt;
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
    /// 会自动按调用的顺序记录槽位 所以可以支持同类型多次调用

    // 记住一个 ValueNotifier<int> listen:并且自动刷新当前context
    final counter = context.rememberValueNotifier(value: 0, listen: true);

    final taped = context.rememberValueNotifier(value: false);

    final tapTimes = context.rememberValueNotifier(factory: () => 0);

    final bgRGB = context.rememberValueNotifier(
      factory: () => _int2RGB(tapTimes.value),
      onCreate: (l, d) {
        tapTimes.addCVListener(
            l.makeLiveCancellable(), (value) => d.value = _int2RGB(value));
      },
      listen: true,
    );

    final resetTapTimes = context.rememberValueNotifier(
      value: 0,
      onCreate: (l, d) {
        tapTimes.addCVListener(l.makeLiveCancellable(), (v) {
          if (v == 0) {
            d.value++;
          }
        });
      },
      listen: true,
    );

    final resetBgRGB = context.rememberValueNotifier(
      factory: () => _int2RGB(Random().nextInt(3)),
      listen: true,
      onDispose: (d) => print('resetBgRGB  dispose ${resetTapTimes.value}'),
      key: resetTapTimes.value,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You have pushed the button this many times: ${counter.value}',
            ),
            SizedBox(height: 12),
            Container(
              color: bgRGB.value,
              child: GestureDetector(
                onTap: () {
                  taped.value = true;
                  tapTimes.value++;
                },
                child: taped.Builder(
                  builder: (context, value, child) => value
                      ? child
                      : Text(
                          'no tap',
                        ),
                  child: tapTimes.Builder(
                    builder: (_, value, __) => Text(
                      'tap times $value',
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              color: resetBgRGB.value,
              child: GestureDetector(
                onTap: () {
                  taped.value = false;
                  tapTimes.value = 0;
                },
                child: Text('reset taped'),
              ),
            ),
          ],
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

Color _int2RGB(int value) {
  final rgbIndex = value % 3;
  return rgbIndex == 0
      ? Colors.red
      : rgbIndex == 1
          ? Colors.green
          : Colors.blue;
}
