import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:true_core_flutter/library.dart';

typedef void OnWidgetSizeChangeFunction(Size size);

class MeasureSizeWidget extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChangeFunction onChange;

  const MeasureSizeWidget({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChangeFunction onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}