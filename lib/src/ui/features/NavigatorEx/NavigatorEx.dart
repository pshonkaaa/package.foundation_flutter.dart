import 'package:flutter/widgets.dart';
import 'package:true_core_flutter/src/typedef.dart';

import 'internal/NavigatorExStateImpl.dart';

typedef void OnChangeContextFunction(BuildContext context, NavigatorExState state);

@Deprecated("Need to review; final result = await navigator.pop();")
class NavigatorEx extends StatefulWidget {
  final PopPageCallback onPopPage;
  final OnChangeContextFunction? onChangeContext;
  final Page initialPage;
  const NavigatorEx({
    Key? key,
    required this.onPopPage,
    required this.onChangeContext,
    required this.initialPage,
  }) : super(key: key);

  @override
  NavigatorState createState() => NavigatorState();


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

  bool allowedPopLast = false;

  BuildContext get context;

  /// Pages count
  int get count;

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

  Future<dynamic> push(Page page);

  Future<dynamic> pushReplacement(
    Page page, {
      bool replaceAll = false,
  });

  Future<dynamic> pushReplacementConcrete<T extends Page>(
    Page page, {
      bool throughTree = false,
      PagePredicate? predicate,
  });

  Future<dynamic> pop({
    bool onlySurface = true,
  });

  Future<dynamic> popConcrete<T extends Page>({
    bool singleMatch = true,
    bool throughTree = false,
    PagePredicate? predicate,
  });

  // TODO
  // bool didPop();
}