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

  group('remember create', () {
    testWidgets('and dispose', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      Object? a;
      Object? b;
      bool aCallCreate = false;
      bool bCallCreate = false;

      bool aCallDispose = false;
      bool bCallDispose = false;

      final page = Builder(builder: (context) {
        a = context.remember(
          factory: () => Object(),
          onCreate: (_, __, ___) => aCallCreate = true,
          onDispose: (_) => aCallDispose = true,
        );
        b = context.remember(
          factory: () => Object(),
          onCreate: (_, __, ___) => bCallCreate = true,
          onDispose: (_) => bCallDispose = true,
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

      expect(a, isNot(equals(b)));
      await tester.pumpAndSettle();

      expect(a, isNotNull);
      expect(b, isNotNull);

      expect(aCallDispose, isFalse);
      expect(bCallDispose, isFalse);

      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(aCallDispose, isTrue);
      expect(bCallDispose, isTrue);
    });

    testWidgets('index is the slot', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      Object? a;
      Object? b;
      Object? c;
      Object? d;
      bool aCallCreate = false;
      bool bCallCreate = false;

      bool aCallDispose = false;
      bool bCallDispose = false;

      final page = Builder(builder: (context) {
        a = context.remember(
          factory: () => Object(),
          onCreate: (_, __, ___) => aCallCreate = true,
          onDispose: (_) => aCallDispose = true,
        );
        b = context.remember(
          factory: () => Object(),
          onCreate: (_, __, ___) => bCallCreate = true,
          onDispose: (_) => bCallDispose = true,
        );
        c = context.remember(factory: () => Object());
        d = context.remember(factory: () => Object());
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
      expect(c, isNotNull);
      expect(d, isNotNull);

      expect(aCallCreate, isTrue);
      expect(bCallCreate, isTrue);

      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
      await tester.pumpAndSettle();

      expect(a, isNotNull);
      expect(b, isNotNull);

      expect(aCallDispose, isFalse);
      expect(bCallDispose, isFalse);

      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(aCallDispose, isTrue);
      expect(bCallDispose, isTrue);
    });

    testWidgets('Reuse during rebuild', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      Object? a;
      Object? b;
      int aCallCreate = 0;
      int bCallCreate = 0;

      int aCallDispose = 0;
      int bCallDispose = 0;

      Element? element;

      Object? c;
      Object? d;

      final page = Builder(builder: (context) {
        final a1 = context.remember(
          factory: () => Object(),
          onCreate: (_, __, ___) => aCallCreate++,
          onDispose: (_) => aCallDispose++,
        );
        final b1 = context.remember(
          factory: () => Object(),
          onCreate: (_, __, ___) => bCallCreate++,
          onDispose: (_) => bCallDispose++,
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

      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(aCallDispose, 1);
      expect(bCallDispose, 1);
    });

    testWidgets('Multiple contexts', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      Object? a;
      Object? b;
      Object? c;
      Object? d;

      final page = Builder(builder: (context) {
        a = context.remember(
          factory: () => Object(),
        );
        b = context.remember(
          factory: () => Object(),
        );

        return Builder(builder: (context) {
          c = context.remember(factory: () => Object());
          d = context.remember(factory: () => Object());
          return const PageTester();
        });
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(c, isNotNull);
      expect(d, isNotNull);
      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
      expect(b, isNot(equals(c)));
      expect(b, isNot(equals(d)));
      expect(c, isNot(equals(d)));
    });

    testWidgets('Rebuild key changed', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      Object? a;
      Object? b;
      Object? c;
      Object? d;
      Element? element;

      Object key = Object();

      final page = Builder(builder: (context) {
        final a1 = context.remember(
          factory: () => Object(),
        );
        final b1 = context.remember(
          factory: () => Object(),
          key: key,
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

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(c, isNull);
      expect(d, isNull);
      expect(a, isNot(equals(b)));
      expect(element, isNotNull);

      key = Object();
      element?.markNeedsBuild();
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(c, isNotNull);
      expect(d, isNotNull);
      expect(a, isNot(equals(b)));
      expect(c, isNot(equals(d)));
      expect(a, equals(c));
      expect(b, isNot(equals(d)));
    });

    testWidgets('Rebuild child context changed', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      Object? a;
      Object? b;
      int index = 0;
      Element? element;

      final page = Builder(builder: (context) {
        element = context as Element;
        if (index == 0) {
          return Builder(
            key: ValueKey(0),
            builder: (context) {
              a = context.remember(factory: () => Object());
              return const SizedBox.shrink();
            },
          );
        } else {
          return Builder(
            key: ValueKey(1),
            builder: (context) {
              b = context.remember(factory: () => Object());
              return const SizedBox.shrink();
            },
          );
        }
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      expect(a, isNotNull);
      expect(b, isNull);
      expect(element, isNotNull);
      index = 1;
      element?.markNeedsBuild();
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(b, isNotNull);
      expect(a, isNot(equals(b)));
    });

    // testWidgets('dispose by gc (Context gc)', (tester) async {
    //  flutter 没找到如何触发gc的方法
    //   await tester.pumpWidget(app);
    //   await tester.pumpAndSettle();
    //
    //   Object? a;
    //   Object? b;
    //   int index = 0;
    //   Element? element;
    //   WeakReference? refA;
    //   bool aCallDispose = false;
    //
    //   final page = Builder(builder: (context) {
    //     element = context as Element;
    //     if (index == 0) {
    //       return Builder(
    //         key: ValueKey(0),
    //         builder: (context) {
    //           a = context.remember(factory: () => Object(), onDispose: (_) => aCallDispose = true);
    //           refA = WeakReference(context);
    //           return const SizedBox.shrink();
    //         },
    //       );
    //     } else {
    //       return Builder(
    //         key: ValueKey(1),
    //         builder: (context) {
    //           b = context.remember(factory: () => Object());
    //           return const SizedBox.shrink();
    //         },
    //       );
    //     }
    //   });
    //
    //   navigatorObserver.navigator?.push(MaterialPageRoute(builder: (_) => page));
    //   await tester.pumpAndSettle();
    //
    //   expect(a, isNotNull);
    //   expect(b, isNull);
    //   expect(element, isNotNull);
    //
    //   expect(aCallDispose, isFalse);
    //   expect(refA, isNotNull);
    //
    //   index = 1;
    //   element?.markNeedsBuild();
    //   await tester.pumpAndSettle();
    //   expect(a, isNotNull);
    //   expect(b, isNotNull);
    //   expect(a, isNot(equals(b)));
    //
    //
    //   // await waitGC(refA!, tester);
    //   bool gcEd = false;
    //   waitVMGC().then((_) => gcEd = true);
    //   while (!gcEd) {
    //     await tester.pump(const Duration(milliseconds: 100));
    //   }
    //
    //   element?.markNeedsBuild();
    //   await tester.pumpAndSettle();
    //
    //   expect(aCallDispose, isTrue);
    // });

    testWidgets('Many slots', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      List remembered = [];
      Element? element;

      final page = Builder(builder: (context) {
        remembered.clear();
        final a = context.remember(factory: () => Object());
        final b = context.remember(factory: () => Object());
        final c = context.remember(factory: () => Object());
        final d = context.remember(factory: () => Object());
        final e = context.remember(factory: () => Object());
        final f = context.remember(factory: () => Object());
        final g = context.remember(factory: () => Object());
        final h = context.remember(factory: () => Object());
        final i = context.remember(factory: () => Object());
        final j = context.remember(factory: () => Object());
        final k = context.remember(factory: () => Object());
        final l = context.remember(factory: () => Object());
        final m = context.remember(factory: () => Object());
        final n = context.remember(factory: () => Object());
        final o = context.remember(factory: () => Object());
        final p = context.remember(factory: () => Object());
        final q = context.remember(factory: () => Object());
        final r = context.remember(factory: () => Object());
        final s = context.remember(factory: () => Object());
        final t = context.remember(factory: () => Object());
        final u = context.remember(factory: () => Object());
        final v = context.remember(factory: () => Object());
        final w = context.remember(factory: () => Object());
        final x = context.remember(factory: () => Object());
        final y = context.remember(factory: () => Object());
        final z = context.remember(factory: () => Object());

        remembered.addAll([
          a,
          b,
          c,
          d,
          e,
          f,
          g,
          h,
          i,
          j,
          k,
          l,
          m,
          n,
          o,
          p,
          q,
          r,
          s,
          t,
          u,
          v,
          w,
          x,
          y,
          z
        ]);

        element = context as Element;
        return const SizedBox.shrink();
      });

      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();

      expect(remembered.length, 26);
      final set = Set.from(remembered);
      expect(set.length, 26);

      element?.markNeedsBuild();
      await tester.pumpAndSettle();
      expect(set.length, 26);
    });
  });
}
