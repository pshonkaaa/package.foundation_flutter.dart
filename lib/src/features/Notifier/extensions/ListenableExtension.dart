import 'package:flutter/foundation.dart';
import 'package:pshondation/library.dart';

extension ListenableExtension<T> on ValueListenable<T> {
  void addTo(NotifierStorage storage, NotifierCallback<T> callback) {
    final listener = this;
    final func = () => callback(listener.value);
    listener.addListener(func);
    storage.add(_ListenableSubscription<T>(
      listener: listener,
      callback: callback,
      function: func,
    ));
  }
}

extension StorageExtension on NotifierStorage {
  void addChangeNotifier<T extends ChangeNotifier>(T listener, NotifierCallback<T> callback) {
    final func = () => callback(listener);
    listener.addListener(func);
    add(_ChangeNotifierSubscription<T>(
      listener: listener,
      callback: callback,
      function: func,
    ));
  }
}

// extension ChangeNotifierExtension on ChangeNotifier {
//   void addTo<T extends ChangeNotifier>(NotifierStorage storage, NotifierCallback<T> callback) {
//     final listener = this as T;
//     final func = () => callback(listener);
//     listener.addListener(func);
//     storage.add(_ChangeNotifierSubscription<T>(
//       listener: listener,
//       callback: callback,
//       function: func,
//     ));
//   }
// }

class _ListenableSubscription<T> implements NotifierSubscription<T> {
  final ValueListenable<T> listener;
  final NotifierCallback<T> callback;
  VoidCallback? function;
  _ListenableSubscription({
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
  NotifierSubscription<T> execute() {
    callback(listener.value);
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

class _ChangeNotifierSubscription<T extends ChangeNotifier> implements NotifierSubscription<T> {
  final T listener;
  final NotifierCallback<T> callback;
  VoidCallback? function;
  _ChangeNotifierSubscription({
    required this.listener,
    required this.callback,
    required this.function,
  });

  @override
  NotifierSubscription<T> addTo(NotifierStorage storage) {
    final func = () => callback(listener);
    listener.addListener(func);
    storage.add(this);
    return this;    
  }

  @override
  NotifierSubscription<T> execute() {
    callback(listener);
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