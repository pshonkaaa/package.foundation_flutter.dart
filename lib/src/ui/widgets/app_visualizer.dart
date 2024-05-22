import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foundation_flutter/library.dart';
import 'package:pshondation/library.dart';

typedef _ButtonBuilder = Widget Function({
  required Notifier<bool> menuShowedState,
  required INotifier<bool> buttonHiddenState,
});

abstract class AppVisualizer {
  static Widget floatButton({
    _ButtonBuilder? buttonBuilder,
    Widget? page,
    Notifier<bool>? menuShowedState,
    Notifier<bool>? buttonHiddenState,
    BoxConstraints? pageConstraints,
  }) {
    return _FloatButtonVisualizer(
      button: buttonBuilder,
      page: page,
      menuShowedState: menuShowedState,
      buttonHiddenState: buttonHiddenState,
      pageConstraints: pageConstraints,
    );
  }
}

class _FloatButtonVisualizer extends StatefulWidget {
  _FloatButtonVisualizer({
    required this.button,
    required this.page,
    required this.menuShowedState,
    required this.buttonHiddenState,
    required this.pageConstraints,
  });

  final _ButtonBuilder? button;

  final Widget? page;
  
  final Notifier<bool>? menuShowedState;

  final Notifier<bool>? buttonHiddenState;

  final BoxConstraints? pageConstraints;

  @override
  State<_FloatButtonVisualizer> createState() => _FloatButtonVisualizerState();
}

class _FloatButtonVisualizerState extends State<_FloatButtonVisualizer> {

  late final Notifier<bool> menuShowedState;
  
  late final Notifier<bool> buttonHiddenState;

  late final BoxConstraints pageConstraints;

  final storage = NotifierStorage();

  @override
  void initState() {
    super.initState();

    if(widget.menuShowedState == null) {
      menuShowedState = Notifier(value: false);
      storage.addNotifier(menuShowedState);
    } else {
      menuShowedState = widget.menuShowedState!;
    }

    if(widget.buttonHiddenState == null) {
      buttonHiddenState = Notifier(value: false);
      storage.addNotifier(buttonHiddenState);
    } else {
      buttonHiddenState = widget.buttonHiddenState!;
    }


    pageConstraints = widget.pageConstraints ?? BoxConstraints(
      maxWidth: 280,
      maxHeight: 500,
    );

    menuShowedState.bind((value) {
      setState(() {
        
      });
    }).addTo(storage);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget button, page;

    if(widget.button != null) {
      button = widget.button!(
        menuShowedState: menuShowedState,
        buttonHiddenState: buttonHiddenState,
      );
    } else {
      button = DefaultFloatButton(
        icon: Icon(
          CupertinoIcons.settings,
          color: CupertinoColors.systemGrey5,
        ),
        iconSize: 24,
        menuShowedState: menuShowedState,
        buttonHiddenState: buttonHiddenState,
      );
    }


    if(widget.page != null) {
      page = widget.page!;
    } else {
      page = CupertinoPageScaffold(
        backgroundColor: CupertinoColors.white.darken(0.9),
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'NO DATA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            button,
            
            Flexible(
              child: floatScreen(page),
            ),
          ],
        );
      }
    );
  }


  Widget floatScreen(Widget page) {
    return Container(
      child: AnimatedClipRect(
        open: menuShowedState.value,
        horizontalAnimation: true,
        verticalAnimation: false,
        alignment: Alignment.centerLeft,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
        child: Container(
          constraints: pageConstraints,
          child: page,
        ),
      ),
    );
  }

}

class DefaultFloatButton extends StatefulWidget {
  const DefaultFloatButton({
    required this.icon,
    required this.iconSize,
    required this.menuShowedState,
    required this.buttonHiddenState,
  });

  final Widget icon;
  
  final double iconSize;

  final Notifier<bool> menuShowedState;

  final INotifier<bool> buttonHiddenState;

  @override
  State<DefaultFloatButton> createState() => _DefaultFloatButtonState();
}

class _DefaultFloatButtonState extends State<DefaultFloatButton> {
  bool _isHovered = false;

  bool get isHidden => buttonHiddenState.value;

  Notifier<bool> get menuShowedState => widget.menuShowedState;

  INotifier<bool> get buttonHiddenState => widget.buttonHiddenState;

  final storage = NotifierStorage();

  @override
  void initState() {
    super.initState();

    buttonHiddenState.bind((value) {
      setState(() {
        
      });
    }).addTo(storage);
  }

  @override
  void dispose() {
    storage.dispose();
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if(isHidden) {
      return SizedBox();
    }
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        bottomLeft: Radius.circular(15),
      ),
      child: MouseRegion(
        onEnter: (_) {
          _isHovered = true;
          // _setState();
        },
        onExit: (_) {
          _isHovered = false;
          // _setState();
        },
        child: Material(
          color: CupertinoColors.systemGrey,
          child: IconButton(
            onPressed: () {
              menuShowedState.value = !menuShowedState.value;
            },
            hoverColor: CupertinoColors.systemGrey.darken(0.1),
            icon: SizedBox(
              width: widget.iconSize,
              height: widget.iconSize,
              child: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}