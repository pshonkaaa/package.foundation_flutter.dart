import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:true_core_flutter/src/typedef.dart';
import 'package:true_core_flutter/src/ui/features/NavigatorEx/NavigatorEx.dart';

class NavigatorExStateImpl extends State<NavigatorEx> implements NavigatorExState {

  // EXTERNAL
  //==========================================================================\\
  @override
  late BuildContext context;

  @override
  bool allowedPopLast = false;

  @override
  int get count => pages.length;

  @override
  NavigatorState? get debugNavigator => key.currentState;
  //==========================================================================\\


  // INTERNAL
  //==========================================================================\\
  final GlobalKey<NavigatorState> key = new GlobalKey();
  final List<_PageEntry> pages = [];
  late Navigator navigator;
  bool bNavigatorChanged = true;
  //==========================================================================\\


  @override
  void initState() {
    super.initState();
    pages.add(new _PageEntry(widget.initialPage));
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  bool contains<T extends Page>({
    bool singleMatch = true,
    bool throughTree = false,
    PagePredicate? predicate,
  }) => get<T>(
    singleMatch: singleMatch,
    throughTree: throughTree,
    predicate: predicate,
  ) != null;

  @override
  Page? get<T extends Page>({
    bool singleMatch = true,
    bool throughTree = false,
    PagePredicate? predicate,
  }) {
    int i = pages.length;
    while(i != 0) {
      var entry = pages[--i];
      if(predicate != null) {
        if(predicate(entry.page))
          return entry.page;
      } else {
        if(entry.page is T)
          return entry.page;
      } if(!throughTree)
        break;
    } return null;
  }

  @override
  Future<dynamic> push(Page page) {
    final entry = new _PageEntry(page);
    pages.add(entry);
    _onChangePagesHistory(() {});
    return entry.completer.future;
  }

  @override
  Future<dynamic> pushReplacement(
    Page page, {
      bool replaceAll = false,
  }) {
    int i = 0;
    while(replaceAll && pages.length > 1 && i++ > 10)
      pop(onlySurface: true);

    final entry = new _PageEntry(page);
    final List<_PageEntry> toDelete = [];
    if(replaceAll) {
      toDelete.addAll(pages);
      pages.clear();
    } else {
      toDelete.add(pages.last);
      pages.removeLast();
    } pages.add(entry);
    _onChangePagesHistory(() {
      for(var entry in toDelete)
        //TODO
        entry.completer.complete(null);
    });
    return entry.completer.future;
  }

  @override
  Future<dynamic> pushReplacementConcrete<T extends Page>(
    Page page, {
      bool throughTree = false,
      PagePredicate? predicate,
  }) {
    final entry = new _PageEntry(page);
    int i = pages.length;
    while(i != 0) {
      var oldEntry = pages[--i];
      if(predicate != null) {
        if(predicate(oldEntry.page)) {
          pages[i] = entry;
          _onChangePagesHistory(() {
            //TODO
            oldEntry.completer.complete(null);
          });
          break;
        }
      } else {
        if(oldEntry.page is T) {
          pages[i] = entry;
          _onChangePagesHistory(() {
            //TODO
            oldEntry.completer.complete(null);
          });
          break;
        }
      } if(!throughTree)
        break;
    } return entry.completer.future;
  }

  @override
  Future<dynamic> pop({
    bool onlySurface = true,
  }) {
    //TODO NON-REALIZED
    if(onlySurface)
      return Future.value();
    if(pages.length == 0)
      return Future.value();
    if(!allowedPopLast && pages.length == 1)
      return Future.value();
    // var toPop = <_PageEntry>[];
    // var needle = pages.last;
    // var page = history.lastWhere((e) => e.page == needle);
    // var start = history.indexOf(page);
    // if(onlySurface)
    //   start++;
    // toPop.addAll(history.getRange(min(start, history.length), history.length));
    // for(int i = 0; i < toPop.length; i++)
    //   key.currentState.pop();
    final entry = pages.last;
    pages.remove(entry);
    _onChangePagesHistory(() {
      //TODO
      entry.completer.complete(null);
    });
    return entry.completer.future;
  }

  @override
  Future<dynamic> popConcrete<T extends Page>({
    bool singleMatch = true,
    bool throughTree = false,
    PagePredicate? predicate,
  }) {
    Future<dynamic>? future;
    int i = pages.length;
    while(i != 0) {
      var entry = pages[--i];
      if(predicate != null) {
        if(predicate(entry.page)) {
          pages.remove(entry);
          _onChangePagesHistory(() {
            //TODO
            entry.completer.complete(null);
          });
          future = entry.completer.future;
          if(singleMatch)
            break;
        }
      } else {
        if(entry.page is T) {
          pages.remove(entry);
          _onChangePagesHistory(() {
            //TODO
            entry.completer.complete(null);
          });
          if(singleMatch)
            break;
        }
      } if(!throughTree)
        break;
    }
    return future ?? Future.value();
  }



  // TODO
  // @override
  // bool didPop() {
  //   if(pages.length == 0)
  //     return false;
  //   if(!allowedPopLast && pages.length == 1)
  //     return false;
  //   // Route route = history.last.route;
  //   // Page page = route.settings as Page;
  //   // if(page != pages.last) {
  //   //   key.currentState.pop();
  //   //   return true;
  //   // } if(!allowedPopLast && pages.length == 1)
  //   //   return false;
  //   // key.currentState.pop();
  //   _onChangePagesHistory(() {
  //     pages.removeLast();
  //   });
  //   return true;
  // }


  void _onChangePagesHistory(Function callback) {
    if(WidgetsBinding.instance!.schedulerPhase == SchedulerPhase.idle) {
      setState(() {
        bNavigatorChanged = true;
        callback();
      });
    } else {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if(!mounted) {
          throw(new Exception("UNHANDLED CODE EXECUTION"));
          // return;
        }
        setState(() {
          bNavigatorChanged = true;
          callback();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    if(bNavigatorChanged) {
      navigator = Navigator(
        key: key,
        pages: pages.map((e) => e.page).toList(),
        onPopPage: (route, result) => _onPopPage(route, result),
        observers: [
          new _Observer(this),
        ],
        reportsRouteUpdateToEngine: true,
      );
      ServicesBinding.instance!.addPostFrameCallback((timeStamp) {
        widget.onChangeContext?.call(key.currentContext!, this);
      });
      bNavigatorChanged = false;
    }

    return WillPopScope(
      child: navigator,
      onWillPop: _onPressBackButton,
    );
  }

  bool _onPopPage(Route route, dynamic result) {
    var popped = route.didPop(result);
    if(popped) {
      _onChangePagesHistory(() {
        //TODO
        pages.last.completer.complete(null);
        pages.removeLast();
      });
    } return popped;
  }

  Future<bool> _onPressBackButton() async {
    bool closing = pages.isEmpty || pages.length == 1;
    if(!closing) {
      _onChangePagesHistory(() {
        //TODO
        pages.last.completer.complete(null);
        pages.removeLast();
      });
    } return closing;
  }
}



























enum _PageType {
  mine,
  // custom,
}

class _PageEntry {
  final Page<dynamic> page;
  final Completer<dynamic> completer = new Completer();
  // Route<dynamic>? route;
  _PageEntry(this.page);
}


class _Observer extends NavigatorObserver {
  final NavigatorExStateImpl that;
  _Observer(this.that);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // _assertCheck(previousRoute);
    _assertCheck(route);
    
    // var newEntry = _createPage(_PageType.mine, route);
    // var prevEntry = _extractPage(previousRoute);

    // if(previousRoute == null) {
    //   that.history.add(newEntry);
    // } else {
    //   that.history.insert(that.history.indexOf(prevEntry) + 1, newEntry);
    // } //debugger();
    // print(123);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    // debugger();
    _assertCheck(oldRoute);
    _assertCheck(newRoute);
    // var oldEntry = _extractPage(oldRoute);
    // var newEntry = _extractPage(newRoute);
    // var index = that.history.indexOf(oldEntry);
    // that.history[index] = newEntry;
    // debugger();
    // print(123);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // _assertCheck(route);
    // _assertCheck(previousRoute);
    // var page = that.pages.singleWhere((e) => e == route.settings, orElse: () => null);
    // if(page != null) {
    //   that.pages.remove(page);
    // } that.history.removeWhere((e) => e.route == route);
  }

  
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {

  }

  @override
  void didStartUserGesture(Route<dynamic> route, Route<dynamic>? previousRoute) { 
  
  }

  @override
  void didStopUserGesture() {

  }

  void _assertCheck(Route? route) {
    if(route == null)
      return;
    // Page? page;
    // if(route.settings is Page)
    //   page = that.pages.trySingleWhere((p) => p == route.settings);
    // assert(
    //   page != null && that.pages.contains(page),
    //   "A page-based route should not be added using the imperative api. "
    //   "Provide a new list with the corresponding Page to NavigatorEx.push instead."
    // );
  }

  // _PageEntry _extractPage(Route<dynamic> route) {
  //   if(route == null)
  //     return null;
  //   _PageEntry entry;
  //   if(route.settings is Page)
  //     entry = that.history.singleWhere((e) => e.page == route.settings, orElse: () => null);
  //   // if(entry == null)
  //   //   entry = that.history.singleWhere((e) => e.route == route, orElse: () => null);
  //   return entry;
  // }

  // _PageEntry _createPage(_PageType type, Route<dynamic> route) {
  //   Page entry;
  //   if(route.settings is Page)
  //     entry = route.settings as Page;
  //   var p = new _PageEntry(type, entry);
  //   p.route = route;
  //   return p;
  // }
}