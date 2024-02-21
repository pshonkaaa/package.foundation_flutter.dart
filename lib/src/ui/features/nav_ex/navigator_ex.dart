import 'package:flutter/widgets.dart';
import 'package:pshondation/library.dart';
import 'package:pshondation_flutter/src/typedef.dart';

import 'internal/NavigatorExStateImpl.dart';

typedef void OnChangeContextFunction(BuildContext context, NavigatorExState state);

class NavigatorEx extends StatefulWidget {
  final bool canPopLast;
  final PopPageCallback onPopPage;
  final VoidCallback? onCloseApp;
  final OnChangeContextFunction? onChangeContext;
  final Page initialPage;
  const NavigatorEx({
    Key? key,
    this.canPopLast = true,
    required this.onPopPage,
    this.onCloseApp,
    required this.onChangeContext,
    required this.initialPage,
  }) : super(key: key);

  @override
  NavigatorExStateImpl createState() => NavigatorExStateImpl();


  static NavigatorExState? of(BuildContext context) {
    if(context is StatefulElement && context.state is NavigatorExStateImpl)
      return context.state as NavigatorExStateImpl;
    return context.findAncestorStateOfType<NavigatorExStateImpl>();
  }

  // static Route<dynamic> getLastRoute(BuildContext context) {
  //   Route<dynamic> route;
  //   Navigator.of(context).popUntil((r) {
  //     route = r;
  //     return true;
  //   });
  //   return route;
  // }
}

abstract class NavigatorExState {
  BuildContext get context;

  bool canPopLast = false;

  /// Pages count
  int get count;

  Iterable<Page> get pages;
  
  INotifier<Iterable<Page>> get pagesState;

  NavigatorState? get debugNavigator;

  


  bool contains<T extends Page>({
    bool singleMatch = true,
    bool throughTree = false,
    PagePredicate? predicate,
  });
  
  Page? get<T extends Page>({
    bool singleMatch = true,
    bool throughTree = false,
    PagePredicate? predicate,
  });

  Future<RESULT?> push<RESULT>(Page page);

  Future<RESULT?> pushReplacement<RESULT>(
    Page page, {
      bool replaceAll = false,
  });

  Future<RESULT?> pushReplacementConcrete<T extends Page, RESULT>(
    Page page, {
      bool throughTree = false,
      PagePredicate? predicate,
  });

  Future<void> pop<RESULT>({
    RESULT? result,
    bool onlySurface = true,
  });

  Future<RESULT?> popConcrete<T extends Page, RESULT>({
    RESULT? result,
    bool singleMatch = true,
    bool throughTree = false,
    PagePredicate? predicate,
  });

  // TODO
  // bool didPop();
}