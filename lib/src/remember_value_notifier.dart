import 'package:an_lifecycle_cancellable/an_lifecycle_cancellable.dart'
    show ValueNotifierCancellable, ListenableCancellable, FlexibleKey;
import 'package:flutter/widgets.dart';
import 'package:remember/src/remember_listenable.dart';

extension RememberValueNotifierAdvancedExt on BuildContext {
  /// 快速转换一个可重用的 ValueNotifier
  /// * 调用顺序,[R],[key],[source] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<R> rememberValueNotifierTransform<R, S>(
      {required ValueNotifier<S> source,
      required R Function(S) transformer,
      bool listen = false,
      Object? key}) {
    return rememberValueNotifier(
      factory: () => transformer(source.value),
      onCreate: (d, l, c) {
        source.addCVListener(c, (v) {
          d.value = transformer(v);
        });
      },
      listen: listen,
      key: FlexibleKey('rememberValueNotifierTransform', source, key),
    );
  }

  /// 快速合并成一个可重用的 ValueNotifier
  /// * 调用顺序,[R],[key],[s1],[s2],...,[sn] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<R> rememberValueNotifierMerge<R, S1, S2>(
      {required ValueNotifier<S1> s1,
      required ValueNotifier<S2> s2,
      required R Function(S1, S2) merger,
      bool listen = false,
      Object? key}) {
    return rememberValueNotifier(
      factory: () => merger(s1.value, s2.value),
      onCreate: (d, l, c) {
        void listener() {
          d.value = merger(s1.value, s2.value);
        }

        s1.addCListener(c, listener);
        s2.addCListener(c, listener);
      },
      listen: listen,
      key: FlexibleKey(s1, s2, 'rememberValueNotifierMerge', s1, s2, key),
    );
  }

  /// 快速合并成一个可重用的 ValueNotifier
  /// * 调用顺序,[R],[key],[s1],[s2],...,[sn] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<R> rememberValueNotifierMerge3<R, S1, S2, S3>(
      {required ValueNotifier<S1> s1,
      required ValueNotifier<S2> s2,
      required ValueNotifier<S3> s3,
      required R Function(S1, S2, S3) merger,
      bool listen = false,
      Object? key}) {
    return rememberValueNotifier(
      factory: () => merger(s1.value, s2.value, s3.value),
      onCreate: (d, l, c) {
        void listener() {
          d.value = merger(s1.value, s2.value, s3.value);
        }

        s1.addCListener(c, listener);
        s2.addCListener(c, listener);
        s3.addCListener(c, listener);
      },
      listen: listen,
      key: FlexibleKey('rememberValueNotifierMerge3', s1, s2, s3, key),
    );
  }

  /// 快速合并成一个可重用的 ValueNotifier
  /// * 调用顺序,[R],[key],[s1],[s2],...,[sn] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<R> rememberValueNotifierMerge4<R, S1, S2, S3, S4>(
      {required ValueNotifier<S1> s1,
      required ValueNotifier<S2> s2,
      required ValueNotifier<S3> s3,
      required ValueNotifier<S4> s4,
      required R Function(S1, S2, S3, S4) merger,
      bool listen = false,
      Object? key}) {
    return rememberValueNotifier(
      factory: () => merger(s1.value, s2.value, s3.value, s4.value),
      onCreate: (d, l, c) {
        void listener() {
          d.value = merger(s1.value, s2.value, s3.value, s4.value);
        }

        s1.addCListener(c, listener);
        s2.addCListener(c, listener);
        s3.addCListener(c, listener);
        s4.addCListener(c, listener);
      },
      listen: listen,
      key: FlexibleKey('rememberValueNotifierMerge4', s1, s2, s3, s4, key),
    );
  }

  /// 快速合并成一个可重用的 ValueNotifier
  /// * 调用顺序,[R],[key],[s1],[s2],...,[sn] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<R> rememberValueNotifierMerge5<R, S1, S2, S3, S4, S5>(
      {required ValueNotifier<S1> s1,
      required ValueNotifier<S2> s2,
      required ValueNotifier<S3> s3,
      required ValueNotifier<S4> s4,
      required ValueNotifier<S5> s5,
      required R Function(S1, S2, S3, S4, S5) merger,
      bool listen = false,
      Object? key}) {
    return rememberValueNotifier(
      factory: () => merger(s1.value, s2.value, s3.value, s4.value, s5.value),
      onCreate: (d, l, c) {
        void listener() {
          d.value = merger(s1.value, s2.value, s3.value, s4.value, s5.value);
        }

        s1.addCListener(c, listener);
        s2.addCListener(c, listener);
        s3.addCListener(c, listener);
        s4.addCListener(c, listener);
        s5.addCListener(c, listener);
      },
      listen: listen,
      key: FlexibleKey('rememberValueNotifierMerge5', s1, s2, s3, s4, s5, key),
    );
  }

  /// 快速合并成一个可重用的 ValueNotifier
  /// * 调用顺序,[R],[key],[s1],[s2],...,[sn] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<R> rememberValueNotifierMerge6<R, S1, S2, S3, S4, S5, S6>(
      {required ValueNotifier<S1> s1,
      required ValueNotifier<S2> s2,
      required ValueNotifier<S3> s3,
      required ValueNotifier<S4> s4,
      required ValueNotifier<S5> s5,
      required ValueNotifier<S6> s6,
      required R Function(S1, S2, S3, S4, S5, S6) merger,
      bool listen = false,
      Object? key}) {
    return rememberValueNotifier(
      factory: () =>
          merger(s1.value, s2.value, s3.value, s4.value, s5.value, s6.value),
      onCreate: (d, l, c) {
        void listener() {
          d.value = merger(
              s1.value, s2.value, s3.value, s4.value, s5.value, s6.value);
        }

        s1.addCListener(c, listener);
        s2.addCListener(c, listener);
        s3.addCListener(c, listener);
        s4.addCListener(c, listener);
        s5.addCListener(c, listener);
        s6.addCListener(c, listener);
      },
      listen: listen,
      key: FlexibleKey(
          'rememberValueNotifierMerge6', s1, s2, s3, s4, s5, s6, key),
    );
  }

  /// 快速合并成一个可重用的 ValueNotifier
  /// * 调用顺序,[R],[key],[s1],[s2],...,[sn] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<R> rememberValueNotifierMerge7<R, S1, S2, S3, S4, S5, S6, S7>(
      {required ValueNotifier<S1> s1,
      required ValueNotifier<S2> s2,
      required ValueNotifier<S3> s3,
      required ValueNotifier<S4> s4,
      required ValueNotifier<S5> s5,
      required ValueNotifier<S6> s6,
      required ValueNotifier<S7> s7,
      required R Function(S1, S2, S3, S4, S5, S6, S7) merger,
      bool listen = false,
      Object? key}) {
    return rememberValueNotifier(
      factory: () => merger(
          s1.value, s2.value, s3.value, s4.value, s5.value, s6.value, s7.value),
      onCreate: (d, l, c) {
        void listener() {
          d.value = merger(s1.value, s2.value, s3.value, s4.value, s5.value,
              s6.value, s7.value);
        }

        s1.addCListener(c, listener);
        s2.addCListener(c, listener);
        s3.addCListener(c, listener);
        s4.addCListener(c, listener);
        s5.addCListener(c, listener);
        s6.addCListener(c, listener);
        s7.addCListener(c, listener);
      },
      listen: listen,
      key: FlexibleKey(
          'rememberValueNotifierMerge7', s1, s2, s3, s4, s5, s6, s7, key),
    );
  }

  /// 快速合并成一个可重用的 ValueNotifier
  /// * 调用顺序,[R],[key],[s1],[s2],...,[sn] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<R>
      rememberValueNotifierMerge8<R, S1, S2, S3, S4, S5, S6, S7, S8>(
          {required ValueNotifier<S1> s1,
          required ValueNotifier<S2> s2,
          required ValueNotifier<S3> s3,
          required ValueNotifier<S4> s4,
          required ValueNotifier<S5> s5,
          required ValueNotifier<S6> s6,
          required ValueNotifier<S7> s7,
          required ValueNotifier<S8> s8,
          required R Function(S1, S2, S3, S4, S5, S6, S7, S8) merger,
          bool listen = false,
          Object? key}) {
    return rememberValueNotifier(
      factory: () => merger(s1.value, s2.value, s3.value, s4.value, s5.value,
          s6.value, s7.value, s8.value),
      onCreate: (d, l, c) {
        void listener() {
          d.value = merger(s1.value, s2.value, s3.value, s4.value, s5.value,
              s6.value, s7.value, s8.value);
        }

        s1.addCListener(c, listener);
        s2.addCListener(c, listener);
        s3.addCListener(c, listener);
        s4.addCListener(c, listener);
        s5.addCListener(c, listener);
        s6.addCListener(c, listener);
        s7.addCListener(c, listener);
        s8.addCListener(c, listener);
      },
      listen: listen,
      key: FlexibleKey(
          'rememberValueNotifierMerge8', s1, s2, s3, s4, s5, s6, s7, s8, key),
    );
  }

  /// 快速合并成一个可重用的 ValueNotifier
  /// * 调用顺序,[R],[key],[s1],[s2],...,[sn] 确定是否为同一个对象 如果发生了变化则重新创建
  /// * [listen] 当前的 Context 自动监听生成的 ValueNotifier 只有首次有效 后续变化无效
  ValueNotifier<R>
      rememberValueNotifierMerge9<R, S1, S2, S3, S4, S5, S6, S7, S8, S9>(
          {required ValueNotifier<S1> s1,
          required ValueNotifier<S2> s2,
          required ValueNotifier<S3> s3,
          required ValueNotifier<S4> s4,
          required ValueNotifier<S5> s5,
          required ValueNotifier<S6> s6,
          required ValueNotifier<S7> s7,
          required ValueNotifier<S8> s8,
          required ValueNotifier<S9> s9,
          required R Function(S1, S2, S3, S4, S5, S6, S7, S8, S9) merger,
          bool listen = false,
          Object? key}) {
    return rememberValueNotifier(
      factory: () => merger(s1.value, s2.value, s3.value, s4.value, s5.value,
          s6.value, s7.value, s8.value, s9.value),
      onCreate: (d, l, c) {
        void listener() {
          d.value = merger(s1.value, s2.value, s3.value, s4.value, s5.value,
              s6.value, s7.value, s8.value, s9.value);
        }

        s1.addCListener(c, listener);
        s2.addCListener(c, listener);
        s3.addCListener(c, listener);
        s4.addCListener(c, listener);
        s5.addCListener(c, listener);
        s6.addCListener(c, listener);
        s7.addCListener(c, listener);
        s8.addCListener(c, listener);
        s9.addCListener(c, listener);
      },
      listen: listen,
      key: FlexibleKey('rememberValueNotifierMerge9', s1, s2, s3, s4, s5, s6,
          s7, s8, s9, key),
    );
  }
}

extension RememberValueNotifierListenExt on BuildContext {
  /// 自动listen 一个由其他方式产生的ValueNotifier 不建议listen由remember产生的ValueNotifier
  T listenValueNotifier<T>(ValueNotifier<T> source) {
    return rememberListenable<ValueNotifier<T>>(
            factory: () => source,
            listen: true,
            key: FlexibleKey('listenValueNotifier', source))
        .value;
  }
}
