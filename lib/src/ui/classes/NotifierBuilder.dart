import 'package:flutter/widgets.dart';
import 'package:true_core/library.dart';

typedef BuilderFunction<T>    = Widget Function(BuildContext context, T value);
typedef ConditionFunction<T>  = bool Function(T value);

class NotifierBuilder<T> extends StatefulWidget {
  /// Widget builder
  final BuilderFunction<T>    builder;
  /// Condition for builder. If condition() returns true, then it would call builder()
  final ConditionFunction<T>? condition;
  final INotifier<T>          notifier;

  NotifierBuilder({
    required  this.notifier,
    this.condition,
    required  this.builder,
  });

  @override
  State<NotifierBuilder<T>> createState() => _NotifierBuilderState<T>();
}

class _NotifierBuilderState<T> extends State<NotifierBuilder<T>> {
  final NotifierStorage storage = new NotifierStorage();

  BuilderFunction<T>    get   builder     => widget.builder;
  ConditionFunction<T>? get   condition   => widget.condition;
  INotifier<T>          get   notifier    => widget.notifier;

  late T lastValue;
  
  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(NotifierBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifier != notifier) {
      _unsubscribe(); 
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    // bool bRebuild = true;
    // if(condition != null)
    //   bRebuild = condition(notifier.value()) ?? true;

    // if(bRebuild)
    return builder(context, lastValue);
    // return Container();
  }

  void _subscribe() {
    notifier.bind((value) {
      bool bRebuild = condition != null ? condition!(value) : true;

      // if(lastValue == value)
      //   return;

      if(bRebuild) {
        WidgetsBinding.instance!.endOfFrame.then((v) {
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