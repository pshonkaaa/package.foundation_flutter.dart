import 'package:flutter/foundation.dart';
import 'package:true_core/library.dart';

extension ListenableExtension<T> on ValueListenable<T> {
  void addTo(NotifierStorage storage, NotifierCallback<T> callback) {
    final listener = this;
    final func = () => callback(listener.value);
    listener.addListener(func);
    storage.add(_NotifierSubscriptionListenable<T>(
      listener: listener,
      callback: callback,
      function: func,
    ));
  }
}

class _NotifierSubscriptionListenable<T> implements NotifierSubscription<T> {
  final ValueListenable<T> listener;
  final NotifierCallback<T> callback;
  VoidCallback? function;
  _NotifierSubscriptionListenable({
    required this.listener,
    required this.callback,
    required this.function,
  });

  @override
  NotifierSubscription<T> addTo(NotifierStorage storage) {
    final func = () => callback(listener.value);
    listener.addListener(func);
    storage.add(this);
    return this;    
  }

  @override
  void cancel() {
    if(function != null) {
      listener.removeListener(function!);
      function = null;
    }
  }

}