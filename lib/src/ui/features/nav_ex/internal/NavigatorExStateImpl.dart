import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:foundation/library.dart';
import 'package:foundation_flutter/src/typedef.dart';
import 'package:foundation_flutter/src/ui/features/nav_ex/navigator_ex.dart';

class NavigatorExStateImpl extends State<NavigatorEx> implements NavigatorExState {
  @override
  void initState() {
    super.initState();

    this.canPopLast = widget.canPopLast;

    _pages.add(new _PageEntry(widget.initialPage));
    _onChangePagesHistory(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext ctx) {
    context = ctx;
    if(bNavigatorChanged) {
      navigator = Navigator(
        key: key,
        pages: _pages.map((e) => e.page).toList(),
        onPopPage: (route, result) => _onPopPage(route, result),
        observers: [
          new _Observer(this),
        ],
        reportsRouteUpdateToEngine: true,
      );
      ServicesBinding.instance.addPostFrameCallback((timeStamp) {
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
    final popped = route.didPop(result);
    if(popped) {
      _onChangePagesHistory(() {
        final entry = _pages.tryFirstWhere((e) => e.page == route.settings);
        if(entry == null)
          return;
        entry.completer.complete(null);
        _pages.remove(entry);
      });
    } return popped;
  }

  Future<bool> _onPressBackButton() async {
    bool isClosing = _pages.isEmpty || _pages.length == 1;
    if(!isClosing) {
      _onChangePagesHistory(() {
        _pages.last.completer.complete(null);
        _pages.removeLast();
      });
    } else {
      if(!canPopLast)
        return false;
      widget.onCloseApp?.call();
    }
    return isClosing;
  }


  // EXTERNAL
  //==========================================================================\\
  @override
  late BuildContext context;

  @override
  bool canPopLast = false;

  @override
  int get count => _pages.length;

  @override
  Iterable<Page> get pages => _pages.map((e) => e.page).toList();

  @override
  final Notifier<Iterable<Page>> pagesState = Notifier(value: []);

  @override
  NavigatorState? get debugNavigator => key.currentState;
  //==========================================================================\\


  // INTERNAL
  //==========================================================================\\
  final GlobalKey<NavigatorState> key = new GlobalKey();
  final List<_PageEntry> _pages = [];
  late Navigator navigator;
  bool bNavigatorChanged = true;
  //==========================================================================\\

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
    int i = _pages.length;
    while(i != 0) {
      final entry = _pages[--i];
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
  Future<RESULT?> push<RESULT>(Page page) async {
    final entry = new _PageEntry(page);
    _onChangePagesHistory(() {
      _pages.add(entry);
    });
    return await entry.completer.future as RESULT?;
  }

  @override
  Future<RESULT?> pushReplacement<RESULT>(
    Page page, {
      bool replaceAll = false,
  }) async {
    int i = 0;
    while(replaceAll && _pages.length > 1 && i++ > 10)
      pop(onlySurface: true);

    final entry = new _PageEntry(page);

    _onChangePagesHistory(() {
      final List<_PageEntry> toDelete = [];
      if(replaceAll) {
        toDelete.addAll(_pages);
        _pages.clear();
      } else {
        toDelete.add(_pages.last);
        _pages.removeLast();
      }
    
      _pages.add(entry);

      for(final entry in toDelete)
        entry.completer.complete(null);
    });
    return await entry.completer.future as RESULT?;
  }

  @override
  Future<RESULT?> pushReplacementConcrete<T extends Page, RESULT>(
    Page page, {
      bool throughTree = false,
      PagePredicate? predicate,
  }) async {
    final entry = new _PageEntry(page);
    int i = _pages.length;
    while(i != 0) {
      final oldEntry = _pages[--i];
      if(predicate != null) {
        if(predicate(oldEntry.page)) {
          _pages[i] = entry;
          _onChangePagesHistory(() {
            oldEntry.completer.complete(null);
          });
          break;
        }
      } else {
        if(oldEntry.page is T) {
          _pages[i] = entry;
          _onChangePagesHistory(() {
            oldEntry.completer.complete(null);
          });
          break;
        }
      } if(!throughTree)
        break;
    } return await entry.completer.future as RESULT?;
  }

  @override
  Future<void> pop<RESULT>({
    RESULT? result,
    bool onlySurface = true,
  }) async {
    //TODO NON-REALIZED
    if(onlySurface)
      return Future.value();
    if(_pages.length == 0)
      return Future.value();
    if(!canPopLast && _pages.length == 1)
      return Future.value();

    // CUT-OUT
    //--------------------------------------------------------------------------
    // final toPop = <_PageEntry>[];
    // final needle = pages.last;
    // final page = history.lastWhere((e) => e.page == needle);
    // final start = history.indexOf(page);
    // if(onlySurface)
    //   start++;
    // toPop.addAll(history.getRange(min(start, history.length), history.length));
    // for(int i = 0; i < toPop.length; i++)
    //   key.currentState.pop();
    //--------------------------------------------------------------------------
    // CUT-OUT

    final entry = _pages.last;
    _onChangePagesHistory(() {
      _pages.remove(entry);
      entry.completer.complete(result);
    });
    return await entry.completer.future;
  }

  @override
  Future<RESULT?> popConcrete<T extends Page, RESULT>({
    RESULT? result,
    bool singleMatch = true,
    bool throughTree = false,
    PagePredicate? predicate,
  }) async {
    Future? future;
    int i = _pages.length;
    while(i != 0) {
      final entry = _pages[--i];
      if(predicate != null) {
        if(predicate(entry.page)) {
          _onChangePagesHistory(() {
            _pages.remove(entry);
            entry.completer.complete(result);
          });
          future = entry.completer.future;
          if(singleMatch)
            break;
        }
      } else {
        if(entry.page is T) {
          _onChangePagesHistory(() {
            _pages.remove(entry);
            entry.completer.complete(result);
          });
          if(singleMatch)
            break;
        }
      } if(!throughTree)
        break;
    }
    return await future as RESULT?;
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


  Future<void> _onChangePagesHistory(Function callback) async {
    callback();

    final completer = Completer();
    if(WidgetsBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(!mounted) {
          throw(new Exception("UNHANDLED CODE EXECUTION"));
          // return;
        } completer.complete();
      });
    } else completer.complete();

    await completer.future;

    setState(() {
      bNavigatorChanged = true;
      pagesState.value = _pages.map((e) => e.page).toList();
    });
  }

}























class _PageEntry {
  final Page<dynamic> page;
  final Completer completer = new Completer();
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
    
    // final newEntry = _createPage(_PageType.mine, route);
    // final prevEntry = _extractPage(previousRoute);

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
    // final oldEntry = _extractPage(oldRoute);
    // final newEntry = _extractPage(newRoute);
    // final index = that.history.indexOf(oldEntry);
    // that.history[index] = newEntry;
    // debugger();
    // print(123);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // _assertCheck(route);
    // _assertCheck(previousRoute);
    // final page = that.pages.singleWhere((e) => e == route.settings, orElse: () => null);
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
  //   final p = new _PageEntry(type, entry);
  //   p.route = route;
  //   return p;
  // }
}