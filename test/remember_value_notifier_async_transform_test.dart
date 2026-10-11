import 'dart:async';

import 'package:an_async_data/an_async_data.dart';
import 'package:anlifecycle/anlifecycle.dart';
import 'package:cancellable/cancellable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember/remember.dart';

import 'tools.dart';

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

  group('rememberAsyncNotifierAsyncTransform', () {
    // 测试：基本转换功能以及源 (source) 数据更新时的自动转换
    testWidgets('basic transform and source update', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(1);
      ValueNotifier<AsyncData<String>>? notifier;
      final completer = Completer<String>();

      final page = Builder(builder: (context) {
        notifier = context.rememberAsyncNotifierAsyncTransform<String, int>(
          source: source,
          transformer: (val, cancellable) {
            if (val == 1) return completer.future;
            return Future.value('transformed_$val');
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      // 校验初始状态为 loading
      expect(notifier, isNotNull);
      expect(notifier!.value.isLoading, isTrue);

      // 完成第一个异步转换
      completer.complete('transformed_1');
      await tester.pumpAndSettle();
      expect(notifier!.value.data, equals('transformed_1'));

      // 改变 source 的值，验证转换结果自动更新
      source.value = 2;
      await tester.pumpAndSettle();
      expect(notifier!.value.data, equals('transformed_2'));
    });

    // 测试：cancelPreviousOnSourceChange = true（重启模式）
    // 当源数据改变时，立即取消上一次正在进行的转换并重新启动新转换
    testWidgets('cancelPreviousOnSourceChange = true (Restart mode)',
        (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(1);
      ValueNotifier<AsyncData<String>>? notifier;
      final completers = <int, Completer<String>>{};
      final cancelledInputs = <int>[];

      final page = Builder(builder: (context) {
        notifier = context.rememberAsyncNotifierAsyncTransform<String, int>(
          source: source,
          cancelPreviousOnSourceChange: true,
          transformer: (val, cancellable) {
            cancellable.onCancel.then((_) {
              cancelledInputs.add(val);
            });
            final completer = Completer<String>();
            completers[val] = completer;
            return completer.future;
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      expect(completers.containsKey(1), isTrue);

      // 在第一个转换完成前改变 source 的值触发重新转换
      source.value = 2;
      await tester.pump();

      // 验证第1个转换的 cancellable 已收到取消通知
      expect(cancelledInputs, contains(1));
      expect(completers.containsKey(2), isTrue);

      // 完成第2个转换
      completers[2]!.complete('res_2');
      await tester.pumpAndSettle();
      expect(notifier!.value.data, equals('res_2'));

      // 即使旧的第1个转换随后完成，其结果也不应该覆盖最新的转换结果
      completers[1]!.complete('res_1');
      await tester.pumpAndSettle();
      expect(notifier!.value.data, equals('res_2'));
    });

    // 测试：cancelPreviousOnSourceChange = false（排队/顺序模式）
    // 当源数据改变时，允许当前转换继续完成，完成后再依次启动下一个转换
    testWidgets('cancelPreviousOnSourceChange = false (Queue mode)',
        (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(1);
      ValueNotifier<AsyncData<String>>? notifier;
      final completers = <int, Completer<String>>{};
      final executionOrder = <int>[];

      final page = Builder(builder: (context) {
        notifier = context.rememberAsyncNotifierAsyncTransform<String, int>(
          source: source,
          cancelPreviousOnSourceChange: false,
          transformer: (val, cancellable) {
            executionOrder.add(val);
            final completer = Completer<String>();
            completers[val] = completer;
            return completer.future;
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      expect(executionOrder, equals([1]));

      // 更改 source 的值为 2
      source.value = 2;
      await tester.pump();

      // 由于第1个转换尚未完成，第2个转换不应立即启动
      expect(executionOrder, equals([1]));

      // 完成第1个转换
      completers[1]!.complete('res_1');
      await tester.pump();
      await tester.pumpAndSettle();

      // 第1个转换完成后，第2个转换按顺序被启动
      expect(executionOrder, equals([1, 2]));

      completers[2]!.complete('res_2');
      await tester.pumpAndSettle();
      expect(notifier!.value.data, equals('res_2'));
    });

    // 测试：自定义父级 cancellable 参数
    // 验证取消传入的父级 Cancellable 时，转换器内部接收到的 Cancellable 也会同步取消
    testWidgets('custom father cancellable parameter', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(1);
      final fatherCancellable = Cancellable();
      bool transformerCancelled = false;

      final page = Builder(builder: (context) {
        context.rememberAsyncNotifierAsyncTransform<String, int>(
          source: source,
          cancellable: fatherCancellable,
          transformer: (val, cancellable) {
            cancellable.onCancel.then((_) {
              transformerCancelled = true;
            });
            return Completer<String>().future;
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      expect(transformerCancelled, isFalse);

      // 取消父级 cancellable，验证转换任务的 cancellable 收到取消回调
      fatherCancellable.cancel();
      await tester.pump();

      expect(transformerCancelled, isTrue);
    });

    // 测试：转换器 (transformer) 抛出异常时的错误处理
    // 验证发生的异常被正确捕获并转换为 AsyncData 的 error 状态
    testWidgets('error handling in transformer', (tester) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        final source = ValueNotifier<int>(1);
        ValueNotifier<AsyncData<Object?>>? notifier;
        final completer = Completer<Object?>();

        final page = Builder(builder: (context) {
          notifier =
              context.rememberAsyncNotifierAsyncTransform<Object?, int>(
            source: source,
            transformer: (val, cancellable) async {
              final err = await completer.future;
              if (err != null) throw err;
              return 'res';
            },
          );
          return const PageTester();
        });

        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pump();

        completer.complete(Exception('Transform error'));
        await tester.pumpAndSettle();

        expect(notifier, isNotNull);
        expect(notifier!.value.isError, isTrue);
        expect(notifier!.value.error, isA<Exception>());
      }, (e, s) {});
    });

    // 测试：页面销毁 (pop) 时的生命周期自动清理
    testWidgets('dispose on route pop', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(1);
      bool cancellableDisposed = false;

      final page = Builder(builder: (context) {
        context.rememberAsyncNotifierAsyncTransform<String, int>(
          source: source,
          transformer: (val, cancellable) {
            cancellable.onCancel.then((_) {
              cancellableDisposed = true;
            });
            return Completer<String>().future;
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      expect(cancellableDisposed, isFalse);

      // 退出路由页面，触发 dispose
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();

      // 验证生命周期结束时转换器关联的 Cancellable 被自动取消释放
      expect(cancellableDisposed, isTrue);
    });
  });

  group('rememberValueNotifierAsyncTransform', () {
    // 测试：rememberValueNotifierAsyncTransform 的基本转换与 source 更新
    testWidgets('basic transform and source update', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(10);
      ValueNotifier<String>? notifier;
      final completer = Completer<String>();

      final page = Builder(builder: (context) {
        notifier = context.rememberValueNotifierAsyncTransform<String, int>(
          initialData: 'initial',
          source: source,
          transformer: (val, cancellable) {
            if (val == 10) return completer.future;
            return Future.value('value_$val');
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      // 验证在转换完成前为初始值 initial
      expect(notifier, isNotNull);
      expect(notifier!.value, equals('initial'));

      // 转换完成后更新为新值
      completer.complete('value_10');
      await tester.pumpAndSettle();
      expect(notifier!.value, equals('value_10'));

      // 更新 source 触发新一轮转换
      source.value = 20;
      await tester.pumpAndSettle();
      expect(notifier!.value, equals('value_20'));
    });

    // 测试：cancelPreviousOnSourceChange = true（重启模式）
    testWidgets('cancelPreviousOnSourceChange = true (Restart mode)',
        (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(1);
      ValueNotifier<String>? notifier;
      final completers = <int, Completer<String>>{};
      final cancelledInputs = <int>[];

      final page = Builder(builder: (context) {
        notifier = context.rememberValueNotifierAsyncTransform<String, int>(
          initialData: 'init',
          source: source,
          cancelPreviousOnSourceChange: true,
          transformer: (val, cancellable) {
            cancellable.onCancel.then((_) {
              cancelledInputs.add(val);
            });
            final completer = Completer<String>();
            completers[val] = completer;
            return completer.future;
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      source.value = 2;
      await tester.pump();

      // 验证第1次转换被取消
      expect(cancelledInputs, contains(1));

      completers[2]!.complete('res_2');
      await tester.pumpAndSettle();
      expect(notifier!.value, equals('res_2'));

      // 旧的转换完成后不影响新结果
      completers[1]!.complete('res_1');
      await tester.pumpAndSettle();
      expect(notifier!.value, equals('res_2'));
    });

    // 测试：cancelPreviousOnSourceChange = false（排队/顺序模式）
    testWidgets('cancelPreviousOnSourceChange = false (Queue mode)',
        (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(1);
      ValueNotifier<String>? notifier;
      final completers = <int, Completer<String>>{};
      final executionOrder = <int>[];

      final page = Builder(builder: (context) {
        notifier = context.rememberValueNotifierAsyncTransform<String, int>(
          initialData: 'init',
          source: source,
          cancelPreviousOnSourceChange: false,
          transformer: (val, cancellable) {
            executionOrder.add(val);
            final completer = Completer<String>();
            completers[val] = completer;
            return completer.future;
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      expect(executionOrder, equals([1]));

      source.value = 2;
      await tester.pump();
      expect(executionOrder, equals([1]));

      completers[1]!.complete('res_1');
      await tester.pump();
      await tester.pumpAndSettle();

      // 第1个完成后启动第2个转换
      expect(executionOrder, equals([1, 2]));

      completers[2]!.complete('res_2');
      await tester.pumpAndSettle();
      expect(notifier!.value, equals('res_2'));
    });

    // 测试：自定义父级 cancellable 参数
    testWidgets('custom father cancellable parameter', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(1);
      final fatherCancellable = Cancellable();
      bool transformerCancelled = false;

      final page = Builder(builder: (context) {
        context.rememberValueNotifierAsyncTransform<String, int>(
          initialData: 'init',
          source: source,
          cancellable: fatherCancellable,
          transformer: (val, cancellable) {
            cancellable.onCancel.then((_) {
              transformerCancelled = true;
            });
            return Completer<String>().future;
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      expect(transformerCancelled, isFalse);

      fatherCancellable.cancel();
      await tester.pump();

      expect(transformerCancelled, isTrue);
    });

    // 测试：发生错误时通过 returnOnError 设置降级返回值
    testWidgets('error handling with returnOnError', (tester) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        final source = ValueNotifier<int>(1);
        ValueNotifier<Object?>? notifier;
        final completer = Completer<Object?>();

        final page = Builder(builder: (context) {
          notifier =
              context.rememberValueNotifierAsyncTransform<Object?, int>(
            initialData: 'init',
            source: source,
            transformer: (val, cancellable) async {
              final err = await completer.future;
              if (err != null) throw err;
              return 'res';
            },
            returnOnError: (d, error, stackTrace) => 'fallback_value',
          );
          return const PageTester();
        });

        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pump();

        completer.complete(Exception('Error occurred'));
        await tester.pumpAndSettle();

        // 验证 returnOnError 返回的值成功赋予 notifier
        expect(notifier, isNotNull);
        expect(notifier!.value, equals('fallback_value'));
      }, (e, s) {});
    });

    // 测试：发生错误时触发 onError 监听回调
    testWidgets('error handling with onError', (tester) async {
      await runZonedGuarded(() async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        final source = ValueNotifier<int>(1);
        Object? capturedError;
        final completer = Completer<Object?>();

        final page = Builder(builder: (context) {
          context.rememberValueNotifierAsyncTransform<Object?, int>(
            initialData: 'init',
            source: source,
            transformer: (val, cancellable) async {
              final err = await completer.future;
              if (err != null) throw err;
              return 'res';
            },
            onError: (Object error, StackTrace stackTrace) {
              capturedError = error;
            },
          );
          return const PageTester();
        });

        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pump();

        completer.complete(Exception('Error for onError'));
        await tester.pumpAndSettle();

        // 验证 onError 捕获到了转换抛出的异常
        expect(capturedError, isA<Exception>());
      }, (e, s) {});
    });

    // 测试：页面销毁 (pop) 时生命周期资源回收
    testWidgets('dispose on route pop', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      final source = ValueNotifier<int>(1);
      bool cancellableDisposed = false;

      final page = Builder(builder: (context) {
        context.rememberValueNotifierAsyncTransform<String, int>(
          initialData: 'init',
          source: source,
          transformer: (val, cancellable) {
            cancellable.onCancel.then((_) {
              cancellableDisposed = true;
            });
            return Completer<String>().future;
          },
        );
        return const PageTester();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pump();

      expect(cancellableDisposed, isFalse);

      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();

      expect(cancellableDisposed, isTrue);
    });
  });
}
