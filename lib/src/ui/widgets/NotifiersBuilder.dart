import 'package:flutter/widgets.dart';
import 'package:foundation/library.dart';

class NotifiersBuilder<T> extends StatefulWidget {
  /// Widget builder
  final WidgetBuilder builder;
  
  final List<INotifier<T>> notifiers;

  NotifiersBuilder({
    required this.notifiers,
    required this.builder,
  });

  @override
  State<NotifiersBuilder<T>> createState() => _NotifiersBuilderState<T>();
}

class _NotifiersBuilderState<T> extends State<NotifiersBuilder<T>> {
  final storage = new NotifierStorage();

  List<INotifier<T>>    get   notifiers   => widget.notifiers;
  WidgetBuilder         get   builder     => widget.builder;
  
  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void didUpdateWidget(NotifiersBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notifiers != notifiers ||
        oldWidget.builder != builder) {
      _unsubscribe(); 
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) => builder(context);

  void _subscribe() {
    for(final notifier in notifiers) {
      notifier.bind((_) {
        WidgetsBinding.instance.endOfFrame.then((v) {
          if(mounted)
            setState(() {});
        });
      }).addTo(storage);
    }
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