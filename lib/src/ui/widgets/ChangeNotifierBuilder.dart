import 'package:flutter/widgets.dart';

typedef ChangeNotifierFunction<T extends ChangeNotifier> = Widget Function(BuildContext context, T notifer);

class ChangeNotifierBuilder<T extends ChangeNotifier> extends StatefulWidget {
  final T notifier;
  final ChangeNotifierFunction<T> builder;
  ChangeNotifierBuilder({
    required this.notifier,
    required this.builder,
    Key? key,
  }) : super(key: key);

  @override
  State<ChangeNotifierBuilder<T>> createState() => _State<T>();
}

class _State<T extends ChangeNotifier> extends State<ChangeNotifierBuilder<T>> {
  @override
  void initState() {
    super.initState();

    widget.notifier.addListener(onChange);
  }

  void onChange() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.notifier.removeListener(onChange);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.notifier);
  }
}