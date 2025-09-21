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

  group('Controllers', () {
    group('ScrollController', () {
      testWidgets('create', (tester) async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        ScrollController? a;

        final page = Builder(builder: (context) {
          a = context.rememberScrollController();
          return const PageTester();
        });

        expect(a, isNull);
        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pumpAndSettle();
        expect(a, isNotNull);

        expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);
        navigatorObserver.navigator?.pop();
        await tester.pumpAndSettle();
        expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
      });

      testWidgets('initialScrollOffset changed', (tester) async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        ScrollController? a;
        ScrollController? b;
        Element? element;

        final page = Builder(builder: (context) {
          element = context as Element;
          final a1 = context.rememberScrollController(
              initialScrollOffset: a == null ? 0 : 1);
          if (a == null) {
            a = a1;
          } else {
            b = a1;
          }
          return const PageTester();
        });

        expect(a, isNull);
        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pumpAndSettle();
        expect(a, isNotNull);
        expect(a?.initialScrollOffset, 0);
        expect(b, isNull);
        expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);

        element?.markNeedsBuild();
        await tester.pumpAndSettle();
        expect(b, isNotNull);
        expect(b?.initialScrollOffset, 1);
        expect(a, isNot(equals(b)));

        expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
        expect(ChangeNotifierTester.assertIsDisposed(b!), isFalse);
        navigatorObserver.navigator?.pop();
        await tester.pumpAndSettle();
        expect(ChangeNotifierTester.assertIsDisposed(b!), isTrue);
      });

      testWidgets('keepScrollOffset changed', (tester) async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        ScrollController? a;
        ScrollController? b;
        Element? element;

        final page = Builder(builder: (context) {
          element = context as Element;
          final a1 =
              context.rememberScrollController(keepScrollOffset: a == null);
          if (a == null) {
            a = a1;
          } else {
            b = a1;
          }
          return const PageTester();
        });

        expect(a, isNull);
        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pumpAndSettle();
        expect(a, isNotNull);
        expect(a?.keepScrollOffset, isTrue);
        expect(b, isNull);
        expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);

        element?.markNeedsBuild();
        await tester.pumpAndSettle();
        expect(b, isNotNull);
        expect(b?.keepScrollOffset, isFalse);
        expect(a, isNot(equals(b)));

        expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
        expect(ChangeNotifierTester.assertIsDisposed(b!), isFalse);
        navigatorObserver.navigator?.pop();
        await tester.pumpAndSettle();
        expect(ChangeNotifierTester.assertIsDisposed(b!), isTrue);
      });
    });

    group('TabController', () {
      testWidgets('create', (tester) async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        TabController? a;
        Element? element;

        final page = Builder(builder: (context) {
          element = context as Element;
          a = context.rememberTabController(length: 2);
          return const PageTester();
        });

        expect(a, isNull);
        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pumpAndSettle();
        expect(a, isNotNull);
        expect(a?.length, 2);
        expect(a?.index, 0);

        a?.animateTo(1);
        element?.markNeedsBuild();
        await tester.pumpAndSettle();
        expect(a?.length, 2);
        expect(a?.index, 1);

        expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);
        navigatorObserver.navigator?.pop();
        await tester.pumpAndSettle();
        expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
      });

      testWidgets('initialIndex changed', (tester) async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        TabController? a;
        TabController? b;
        Element? element;

        final page = Builder(builder: (context) {
          element = context as Element;
          final a1 = context.rememberTabController(
              length: 2, initialIndex: a == null ? 0 : 1);
          if (a == null) {
            a = a1;
          } else {
            b = a1;
          }
          return const PageTester();
        });

        expect(a, isNull);
        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pumpAndSettle();
        expect(a, isNotNull);
        expect(a?.length, 2);
        expect(a?.index, 0);
        expect(b, isNull);

        element?.markNeedsBuild();
        await tester.pumpAndSettle();
        expect(b, isNotNull);
        expect(b?.length, 2);
        expect(b?.index, 1);
        expect(a, isNot(equals(b)));

        expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
        expect(ChangeNotifierTester.assertIsDisposed(b!), isFalse);
        navigatorObserver.navigator?.pop();
        await tester.pumpAndSettle();
        expect(ChangeNotifierTester.assertIsDisposed(b!), isTrue);
      });

      testWidgets('duration changed', (tester) async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        TabController? a;
        TabController? b;
        Element? element;

        final page = Builder(builder: (context) {
          element = context as Element;
          final duration = Duration(seconds: a == null ? 1 : 2);
          final a1 = context.rememberTabController(
              length: 2, animationDuration: duration);
          if (a == null) {
            a = a1;
          } else {
            b = a1;
          }
          return const PageTester();
        });

        expect(a, isNull);
        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pumpAndSettle();
        expect(a, isNotNull);
        expect(a?.length, 2);
        expect(a?.index, 0);
        expect(a?.animationDuration, equals(Duration(seconds: 1)));
        expect(b, isNull);

        a?.animateTo(1);
        element?.markNeedsBuild();
        await tester.pumpAndSettle();
        expect(b, isNotNull);
        expect(b?.length, 2);
        expect(b?.index, 0);
        expect(b?.animationDuration, equals(Duration(seconds: 2)));
        expect(a, isNot(equals(b)));
      });

      testWidgets('length changed', (tester) async {
        await tester.pumpWidget(app);
        await tester.pumpAndSettle();

        TabController? a;
        Element? element;

        final page = Builder(builder: (context) {
          element = context as Element;
          a = context.rememberTabController(length: a == null ? 2 : 3);
          return const PageTester();
        });

        expect(a, isNull);
        navigatorObserver.navigator
            ?.push(MaterialPageRoute(builder: (_) => page));
        await tester.pumpAndSettle();
        expect(a, isNotNull);
        expect(a?.length, 2);
        expect(a?.index, 0);

        a?.animateTo(1);
        element?.markNeedsBuild();
        await tester.pumpAndSettle();
        expect(a?.length, 3);
        expect(a?.index, 0);
      });
    });
  });
  testWidgets('AnimationController', (tester) async {
    await tester.pumpWidget(app);
    await tester.pumpAndSettle();

    AnimationController? a;
    Element? element;
    final page = Builder(builder: (context) {
      element = context as Element;
      a = context.rememberAnimationController();
      return const PageTester();
    });

    expect(a, isNull);
    navigatorObserver.navigator?.push(MaterialPageRoute(builder: (_) => page));
    await tester.pumpAndSettle();
    expect(a, isNotNull);
    expect(a?.value, 0.0);
    expect(a?.duration, isNull);

    element?.markNeedsBuild();
    await tester.pumpAndSettle();
    expect(a?.value, 0.0);
    expect(a?.duration, isNull);
  });

  group('TextEditingController', () {
    testWidgets('create', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      TextEditingController? a;
      Element? element;
      final page = Builder(builder: (context) {
        element = context as Element;
        a = context.rememberTextEditingController();
        return const PageTester();
      });

      expect(a, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(a?.value.text, equals(''));
      expect(a?.value.selection, equals(TextSelection.collapsed(offset: -1)));
      expect(a?.value.composing, equals(TextRange.empty));

      element?.markNeedsBuild();
      await tester.pumpAndSettle();
      expect(a?.value.text, equals(''));

      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
    });

    testWidgets('create text not empty', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      TextEditingController? a;
      Element? element;
      final page = Builder(builder: (context) {
        element = context as Element;
        a = context.rememberTextEditingController(text: 'aaa');
        return const PageTester();
      });

      expect(a, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(a?.value.text, equals('aaa'));
      expect(a?.value.selection, equals(TextSelection.collapsed(offset: -1)));
      expect(a?.value.composing, equals(TextRange.empty));

      element?.markNeedsBuild();
      await tester.pumpAndSettle();
      expect(a?.value.text, equals('aaa'));

      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
    });

    testWidgets('create by value', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      TextEditingController? a;
      Element? element;
      TextSelection selection = TextSelection.collapsed(offset: 1);
      TextEditingValue value = TextEditingValue(
        text: 'aaa',
        selection: selection,
        composing: TextRange.empty,
      );
      final page = Builder(builder: (context) {
        element = context as Element;
        a = context.rememberTextEditingController(value: value);
        return const PageTester();
      });

      expect(a, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(a?.value.text, equals('aaa'));
      expect(a?.value.selection, equals(selection));
      expect(a?.value.composing, equals(TextRange.empty));

      element?.markNeedsBuild();
      await tester.pumpAndSettle();
      expect(a?.value.text, equals('aaa'));

      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);
    });

    testWidgets(' text change', (tester) async {
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      TextEditingController? a;
      TextEditingController? b;
      Element? element;
      final page = Builder(builder: (context) {
        element = context as Element;
        final a1 = context.rememberTextEditingController(
            text: a == null ? 'aaa' : 'bbb');
        if (a == null) {
          a = a1;
        } else {
          b = a1;
        }
        return const PageTester();
      });

      expect(a, isNull);
      navigatorObserver.navigator
          ?.push(MaterialPageRoute(builder: (_) => page));
      await tester.pumpAndSettle();
      expect(a, isNotNull);
      expect(a?.value.text, equals('aaa'));
      expect(a?.value.selection, equals(TextSelection.collapsed(offset: -1)));
      expect(a?.value.composing, equals(TextRange.empty));
      expect(ChangeNotifierTester.assertIsDisposed(a!), isFalse);

      element?.markNeedsBuild();
      await tester.pumpAndSettle();
      expect(a?.value.text, equals('aaa'));
      expect(b?.value.text, equals('bbb'));

      expect(ChangeNotifierTester.assertIsDisposed(a!), isTrue);

      expect(ChangeNotifierTester.assertIsDisposed(b!), isFalse);
      navigatorObserver.navigator?.pop();
      await tester.pumpAndSettle();
      expect(ChangeNotifierTester.assertIsDisposed(b!), isTrue);
    });
  });
}
