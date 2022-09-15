import 'package:flutter/widgets.dart';
import 'package:true_core/library.dart';

typedef BuilderFunction<T>    = Widget Function(BuildContext context, T value);
typedef ConditionFunction<T>  = bool Function(T value);

// TODO REWRITE
class NotifierBuilder<T> extends StatefulWidget {
  /// Widget builder
  final BuilderFunction<T> builder;

  /// Condition for builder. If condition() returns true, then it would call builder()
  final ConditionFunction<T>? condition;
  final INotifier<T> notifier;

  NotifierBuilder({
    required this.notifier,
    this.condition,
    required this.builder,
  });

  @override
  State<NotifierBuilder<T>> createState() => _NotifierBuilderState<T>();
}

class _NotifierBuilderState<T> extends State<NotifierBuilder<T>> {
  final storage = NotifierStorage();

  INotifier<T>          get   notifier    => widget.notifier;
  ConditionFunction<T>? get   condition   => widget.condition;
  BuilderFunction<T>    get   builder     => widget.builder;

  late T lastValue;
  
  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(NotifierBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != notifier ||
        oldWidget.condition != condition || 
        oldWidget.builder != builder) {
      _unsubscribe(); 
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => builder(context, lastValue);
  
  // @override
  // Widget build(BuildContext context) {
  //   // bool bRebuild = true;
  //   // if(condition != null)
  //   //   bRebuild = condition(notifier.value()) ?? true;

  //   // if(bRebuild)
  //   return builder(context, lastValue);
  // }

  void _subscribe() {
    notifier.bind((value) {
      bool bRebuild = condition != null ? condition!(value) : true;

      // if(lastValue == value)
      //   return;

      if(bRebuild) {
        WidgetsBinding.instance.endOfFrame.then((v) {
          if(mounted)
            setState(() { lastValue = value; });
        });
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        // });
      }
    }).addTo(storage);
    lastValue = notifier.value;
  }


  void _unsubscribe() {
    storage.clear();
  }

  @override
  void dispose() {
    super.dispose();
    storage.dispose();
  }
}