import 'package:flutter/rendering.dart';
import 'dart:html' as html;

import 'package:flutter/widgets.dart';

typedef OnChangeFocus = void Function(bool hasFocus);
typedef FocusDeterminant = bool Function(BoxHitTestResult result);
typedef _OnHitTest = void Function(BoxHitTestResult result);

class DomMouseEventsConnector extends StatefulWidget {
  const DomMouseEventsConnector({
    required this.domElement,
    this.onChangeFocus,
    this.focusDeterminant = defaultFocusDeterminant,
    required this.child,
  });

  final html.Element domElement;
  final OnChangeFocus? onChangeFocus;
  final FocusDeterminant focusDeterminant;
  final Widget child;

  static bool defaultFocusDeterminant(BoxHitTestResult result) {
    bool hasFocus = false;

    hasFocus = result.path.isNotEmpty;

    return hasFocus;

    // // int totalListeners = 0;

    // if(result.path.isNotEmpty) {
    //   totalListeners = result.path.map((e) => e.target).toList().reversed.skipWhile((e) => e is! _CustomRenderPointerListener).whereType<RenderPointerListener>().length;
    //   print('hitTest = ${result.path.length}');
    //   print('amount = $totalListeners');
    //   html.window.console.log(result.path.toList());
    //   // value = totalListeners - widget.skipListeners > 0;
    //   hasFocus = true;
    // }
  }

  @override
  State<DomMouseEventsConnector> createState() => _State();
}

class _State extends State<DomMouseEventsConnector> {
  bool hasFocus = true;
  
  @override
  Widget build(BuildContext context) {
    return _CustomListener(
      onHitTest: (result) {
        final value = widget.focusDeterminant(result);
        if(value != hasFocus) {
          hasFocus = value;

          if(widget.onChangeFocus != null) {
            widget.onChangeFocus!(hasFocus);
          }

          widget.domElement.style.pointerEvents = hasFocus ? 'auto' : 'none';
        }
      },
      child: widget.child,
    );
  }
}

class _CustomListener extends SingleChildRenderObjectWidget {
  const _CustomListener({
    required this.onHitTest,
    super.child,
  });

  final _OnHitTest onHitTest;

  @override
  _CustomRenderPointerListener createRenderObject(BuildContext context) {
    return _CustomRenderPointerListener(
      onHitTest: onHitTest,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _CustomRenderPointerListener renderObject) {
    renderObject;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}


class _CustomRenderPointerListener extends RenderProxyBoxWithHitTestBehavior {
  _CustomRenderPointerListener({
    required this.onHitTest,
  });

  final _OnHitTest onHitTest;

  @override
  Size computeSizeForNoChild(BoxConstraints constraints) {
    return constraints.biggest;
  }

  @override
  bool hitTest(BoxHitTestResult result, {
    required Offset position,
  }) {
    final out = super.hitTest(
      result,
      position: position,
    );
    onHitTest(result);
    return out;
  }

  @override
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    // print('handleEvent');
    // html.window.console.log(event);
    // html.window.console.log(entry);
    assert(debugHandleEvent(event, entry));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}