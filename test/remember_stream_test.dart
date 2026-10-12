import 'dart:async';

import 'package:anlifecycle/anlifecycle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember/remember.dart';

import 'tools.dart';

class _CustomMappedEventSink implements EventSink<int> {
  final EventSink<String> _outputSink;

  _CustomMappedEventSink(this._outputSink);

  @override
  void add(int event) {
    _outputSink.add('event_$event');
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _outputSink.addError(error, stackTrace);
  }

  @override
  void close() {
    _outputSink.close();
  }
}

void main() {
  late TestWidgetsFlutterBinding binding;
  late LifecycleNavigatorObserver navigatorObserver;
  late Widget app;

  setUp(() {
    binding = TestWidgetsFlutterBinding.ensureInitialized();
    navigatorObserver = LifecycleNavigatorObserver.hookMode();
    app = LifecycleAppTester(
      navigatorObserver: navigatorObserver,
      home: const PageTester(),
    );
  });

  group('rememberStream', () {
    // 测试：rememberStream 基本函数创建与数据流接收
    testWidgets('basic stream creation and listen', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      Stream<int>? stream;
      final controller = StreamController<int>();

      final page = Builder(builder: (context) {
        stream = context.rememberStream<int>(
          factory: () => controller.stream,
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      expect(stream, isNotNull);

      final received = <int>[];
      final sub = stream!.listen((data) => received.add(data));

      controller.add(42);
      await tester.pumpAndSettle();

      expect(received, equals([42]));
      unawaited(sub.cancel());
      unawaited(controller.close());
    });

    // 测试：rememberStreamForm 传入单个 value、future 以及 elements 的场景
    testWidgets('rememberStreamForm factory constructors', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      Stream<int>? streamFromValue;
      Stream<String>? streamFromFuture;

      final page = Builder(builder: (context) {
        streamFromValue = context.rememberStreamForm<int>(
          value: 100,
          key: 'value_key',
        );
        streamFromFuture = context.rememberStreamForm<String>(
          future: Future.value('async_data'),
          key: 'future_key',
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      final listValue = <int>[];
      final listFuture = <String>[];

      final sub1 = streamFromValue!.listen((v) => listValue.add(v));
      final sub2 = streamFromFuture!.listen((v) => listFuture.add(v));

      await tester.pumpAndSettle();

      expect(listValue, equals([100]));
      expect(listFuture, equals(['async_data']));

      unawaited(sub1.cancel());
      unawaited(sub2.cancel());
    });

    // 测试：rememberStreamPeriodic 周期性 Stream 触发
    testWidgets('rememberStreamPeriodic execution', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      Stream<int>? periodicStream;

      final page = Builder(builder: (context) {
        periodicStream = context.rememberStreamPeriodic<int>(
          period: const Duration(milliseconds: 100),
          computation: (count) => count + 1,
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      expect(periodicStream, isNotNull);

      final results = <int>[];
      final sub = periodicStream!.listen((val) => results.add(val));

      await tester.pump(const Duration(milliseconds: 350));
      unawaited(sub.cancel());

      expect(results, containsAll([1, 2, 3]));
    });

    // 测试：rememberStreamEventTransformed 流事件转换
    testWidgets('rememberStreamEventTransformed', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final controller = StreamController<int>();
      Stream<String>? transformedStream;

      final page = Builder(builder: (context) {
        transformedStream = context.rememberStreamEventTransformed<String>(
          source: controller.stream,
          mapSink: (sink) => _CustomMappedEventSink(sink),
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      final list = <String>[];
      final sub = transformedStream!.listen((val) => list.add(val));

      controller.add(1);
      controller.add(2);
      await tester.pumpAndSettle();

      expect(list, equals(['event_1', 'event_2']));

      unawaited(sub.cancel());
      unawaited(controller.close());
    });

    // 测试：rememberStreamController 及自动销毁关闭
    testWidgets('rememberStreamController lifecycle auto close',
        (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      StreamController<int>? streamController;

      final page = Builder(builder: (context) {
        streamController = context.rememberStreamController<int>();
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      expect(streamController, isNotNull);
      expect(streamController!.isClosed, isFalse);

      // 退出页面，触发路由 pop 卸载
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();

      // 验证 StreamController 随着 Widget 生命周期自动关闭
      expect(streamController!.isClosed, isTrue);
    });

    // 测试：rememberStreamControllerBroadcast 广播控制器
    testWidgets('rememberStreamControllerBroadcast', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      StreamController<String>? broadcastController;

      final page = Builder(builder: (context) {
        broadcastController =
            context.rememberStreamControllerBroadcast<String>();
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      expect(broadcastController, isNotNull);

      final list1 = <String>[];
      final list2 = <String>[];

      final sub1 = broadcastController!.stream.listen((v) => list1.add(v));
      final sub2 = broadcastController!.stream.listen((v) => list2.add(v));

      broadcastController!.add('hello');
      await tester.pumpAndSettle();

      expect(list1, equals(['hello']));
      expect(list2, equals(['hello']));

      unawaited(sub1.cancel());
      unawaited(sub2.cancel());
    });

    // 测试：rememberStreamSubscription 自动订阅取消
    testWidgets('rememberStreamSubscription auto cancel on dispose',
        (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final controller = StreamController<int>.broadcast();

      final page = Builder(builder: (context) {
        context.rememberStreamSubscription<int>(
          factory: () {
            final sub = controller.stream.listen((_) {});
            return sub;
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      // 退出路由页面，触发 dispose
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();

      unawaited(controller.close());
    });
  });
}
