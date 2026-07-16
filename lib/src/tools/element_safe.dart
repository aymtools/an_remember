import 'package:cancellable/cancellable.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

void elementSafeMarkNeedsBuild(WeakReference<Element> rElement,
    {Cancellable? cancellable}) async {
  final element = rElement.target;

  if (element == null ||
      !element.mounted ||
      element.dirty ||
      cancellable?.isUnavailable == true) return;

  if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
    await SchedulerBinding.instance.endOfFrame;
    if (!element.mounted ||
        element.dirty ||
        cancellable?.isUnavailable == true) {
      return;
    }
  }
  element.markNeedsBuild();
}

void Function() safeMarkNeedsBuildVoidListener(BuildContext context,
    {Cancellable? cancellable}) {
  if (context is! Element || cancellable?.isUnavailable == true) return () {};
  final rElement = WeakReference(context);
  return () {
    elementSafeMarkNeedsBuild(rElement, cancellable: cancellable);
  };
}
