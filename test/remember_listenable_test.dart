import 'package:anlifecycle/anlifecycle.dart';
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
      home: PageTester(),
    );
  });

  group('Listenable', () {
    testWidgets('create and dispose', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      ChangeNotifierTester? a;
      ChangeNotifierTester? b;
      bool aCallCreate = false;
      bool bCallCreate = false;

      final page = Builder(builder: (context) {
        a = context.rememberListenable(
          factory: ChangeNotifierTester.new,
          onCreate: (_, __, ___) => aCallCreate = true,
          onDispose: (v) => v.dispose(),
        );
        b = context.rememberListenable(
          factory: ChangeNotifierTester.new,
          onCreate: (_, __, ___) => bCallCreate = true,
          onDispose: (v) => v.dispose(),
        );
        return const PageTester();
      });

      expect(a, isNull);
      expect(b, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));

      expect(a, isNull);
      expect(b, isNull);
      expect(aCallCreate, isFalse);
      expect(bCallCreate, isFalse);

      await tester.pump();

      expect(a, isNotNull);
      expect(b, isNotNull);

      expect(aCallCreate, isTrue);
      expect(bCallCreate, isTrue);
      expect(a?.isDisposed, isFalse);

      expect(a, isNot(equals(b)));
      await tester.pumpAndSettle();

      expect(a, isNotNull);
      expect(b, isNotNull);

      expect(a?.isDisposed, isFalse);
      expect(b?.isDisposed, isFalse);
      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);

      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(a?.isDisposed, isTrue);
      expect(b?.isDisposed, isTrue);

      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
    });
  });

  group('Listenable', () {
    testWidgets('create and dispose', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      ChangeNotifierTester? a;
      ChangeNotifierTester? b;
      bool aCallCreate = false;
      bool bCallCreate = false;

      final page = Builder(builder: (context) {
        a = context.rememberListenable(
          factory: ChangeNotifierTester.new,
          onCreate: (_, __, ___) => aCallCreate = true,
          onDispose: (v) => v.dispose(),
        );
        b = context.rememberListenable(
          factory: ChangeNotifierTester.new,
          onCreate: (_, __, ___) => bCallCreate = true,
          onDispose: (v) => v.dispose(),
        );
        return const PageTester();
      });

      expect(a, isNull);
      expect(b, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));

      expect(a, isNull);
      expect(b, isNull);
      expect(aCallCreate, isFalse);
      expect(bCallCreate, isFalse);

      await tester.pump();

      expect(a, isNotNull);
      expect(b, isNotNull);

      expect(aCallCreate, isTrue);
      expect(bCallCreate, isTrue);
      expect(a?.isDisposed, isFalse);

      expect(a, isNot(equals(b)));
      await tester.pumpAndSettle();

      expect(a, isNotNull);
      expect(b, isNotNull);

      expect(a?.isDisposed, isFalse);
      expect(b?.isDisposed, isFalse);
      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);

      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(a?.isDisposed, isTrue);
      expect(b?.isDisposed, isTrue);

      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
    });

    testWidgets('Reuse during rebuild', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      ChangeNotifierTester? a;
      ChangeNotifierTester? b;
      int aCallCreate = 0;
      int bCallCreate = 0;

      int aCallDispose = 0;
      int bCallDispose = 0;

      Element? element;

      ChangeNotifierTester? c;
      ChangeNotifierTester? d;

      final page = Builder(builder: (context) {
        final a1 = context.rememberListenable(
          factory: ChangeNotifierTester.new,
          onCreate: (_, __, ___) => aCallCreate++,
          onDispose: (v) {
            v.dispose();
            aCallDispose++;
          },
        );
        final b1 = context.rememberListenable(
          factory: ChangeNotifierTester.new,
          onCreate: (_, __, ___) => bCallCreate++,
          onDispose: (v) {
            v.dispose();
            bCallDispose++;
          },
        );
        if (element == null) {
          a = a1;
          b = b1;
          element = context as Element;
        } else {
          c = a1;
          d = b1;
        }

        return const PageTester();
      });

      expect(a, isNull);
      expect(b, isNull);
      expect(c, isNull);
      expect(d, isNull);

      expect(aCallCreate, 0);
      expect(bCallCreate, 0);

      expect(element, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));

      await tester.pump();

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(c, isNull);
      expect(d, isNull);
      expect(aCallCreate, 1);
      expect(bCallCreate, 1);

      expect(a, isNot(equals(b)));

      expect(element, isNotNull);
      element?.markNeedsBuild();
      await tester.pumpAndSettle();

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(c, isNotNull);
      expect(d, isNotNull);

      expect(aCallCreate, 1);
      expect(bCallCreate, 1);

      expect(a, isNot(equals(b)));
      expect(c, isNot(equals(d)));

      expect(a, equals(c));
      expect(b, equals(d));

      expect(aCallDispose, 0);
      expect(bCallDispose, 0);
      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);

      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(aCallDispose, 1);
      expect(bCallDispose, 1);
      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
    });

    testWidgets('listened', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      ChangeNotifierTester? a;
      int buildTimes = 0;

      final page = Builder(builder: (context) {
        buildTimes++;
        a = context.rememberListenable(
          factory: ChangeNotifierTester.new,
          onDispose: (v) => v.dispose(),
          listen: true,
        );
        return const PageTester();
      });

      expect(a, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(buildTimes, 1);
      a?.increment();
      await tester.pumpAndSettle();
      expect(buildTimes, 2);
      a?.increment();
      await tester.pumpAndSettle();
      expect(buildTimes, 3);

      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
    });
  });

  group('ChangeNotifier', () {
    testWidgets('Reuse during rebuild', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      ChangeNotifierTester? a;
      ChangeNotifierTester? b;
      int aCallCreate = 0;
      int bCallCreate = 0;

      int aCallDispose = 0;
      int bCallDispose = 0;

      Element? element;

      ChangeNotifierTester? c;
      ChangeNotifierTester? d;

      final page = Builder(builder: (context) {
        final a1 = context.rememberChangeNotifier(
          factory: ChangeNotifierTester.new,
          onCreate: (_, __, ___) => aCallCreate++,
          onDispose: (v) => aCallDispose++,
        );
        final b1 = context.rememberListenable(
          factory: ChangeNotifierTester.new,
          onCreate: (_, __, ___) => bCallCreate++,
          onDispose: (v) => bCallDispose++,
        );
        if (element == null) {
          a = a1;
          b = b1;
          element = context as Element;
        } else {
          c = a1;
          d = b1;
        }

        return const PageTester();
      });

      expect(a, isNull);
      expect(b, isNull);
      expect(c, isNull);
      expect(d, isNull);

      expect(aCallCreate, 0);
      expect(bCallCreate, 0);

      expect(element, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));

      await tester.pump();

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(c, isNull);
      expect(d, isNull);
      expect(aCallCreate, 1);
      expect(bCallCreate, 1);

      expect(a, isNot(equals(b)));

      expect(element, isNotNull);
      element?.markNeedsBuild();
      await tester.pumpAndSettle();

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(c, isNotNull);
      expect(d, isNotNull);

      expect(aCallCreate, 1);
      expect(bCallCreate, 1);

      expect(a, isNot(equals(b)));
      expect(c, isNot(equals(d)));

      expect(a, equals(c));
      expect(b, equals(d));

      expect(aCallDispose, 0);
      expect(bCallDispose, 0);
      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);

      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(aCallDispose, 1);
      expect(bCallDispose, 1);
      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
    });

    testWidgets('listened', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      ChangeNotifierTester? a;
      int buildTimes = 0;

      final page = Builder(builder: (context) {
        buildTimes++;
        a = context.rememberChangeNotifier(
          factory: ChangeNotifierTester.new,
          listen: true,
        );
        return const PageTester();
      });

      expect(a, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(buildTimes, 1);
      a?.increment();
      await tester.pumpAndSettle();
      expect(buildTimes, 2);
      a?.increment();
      await tester.pumpAndSettle();
      expect(buildTimes, 3);

      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
    });

    testWidgets('key changed', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      ChangeNotifierTester? a;
      ChangeNotifierTester? b;
      Element? element;

      final page = Builder(builder: (context) {
        final a1 = context.rememberChangeNotifier(
          factory: ChangeNotifierTester.new,
          key: a == null ? 1 : 0,
        );
        if (a == null) {
          a = a1;
        } else {
          b = a1;
        }
        element = context as Element;
        return const PageTester();
      });

      expect(a, isNull);
      expect(b, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(b, isNull);
      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);

      element?.markNeedsBuild();
      await tester.pumpAndSettle();

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);

      expect(ChangeNotifierTester.assertIsDisposed(b!), isFalse);
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(ChangeNotifierTester.assertIsDisposed(b!), isTrue);
    });
  });

  testWidgets('ValueNotifier', (tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    ValueNotifier<int>? a;
    int buildTimes = 0;

    final page = Builder(builder: (context) {
      buildTimes++;
      a = context.rememberValueNotifier(
        value: 1,
        listen: true,
      );
      return const PageTester();
    });

    expect(a, isNull);
    navigatorObserver.navigator?.push(MaterialPageRoute(builder: (_) => page));
    await tester.pumpAndSettle();
    expect(a, isNotNull);
    expect(buildTimes, 1);
    a?.value = 5;
    await tester.pumpAndSettle();
    expect(buildTimes, 2);
    a?.value = 5;
    await tester.pumpAndSettle();
    expect(buildTimes, 2);

    expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);
    navigatorObserver.navigator?.pop();
    await tester.pumpAndSettle();
    expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
  });
}
