import 'package:flutter/widgets.dart';

@Deprecated("Need to review; maintainState")
class TransparentRoute<T> extends PageRoute<T> {
  TransparentRoute({
    required this.builder,
    this.maintainState = true,
    RouteSettings? settings,
  }) : super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  final bool maintainState; //TODO true

  @override
  Duration get transitionDuration => Duration(milliseconds: 350);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final result = builder(context);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }
}





class TransparentPage<T> extends Page<T> {
  static const Duration defaultTransition = Duration(milliseconds: 350);

  const TransparentPage({
    required this.child,
    this.maintainState = false,
    this.fullscreenDialog = false,
    this.transitionDuration = defaultTransition,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) : super(key: key, name: name, arguments: arguments, restorationId: restorationId);

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  final Duration transitionDuration;

  @override
  Route<T> createRoute(BuildContext context) {
    return _PageBasedTransparentPageRoute<T>(page: this);
  }
}


class _PageBasedTransparentPageRoute<T> extends PageRoute<T> {
  _PageBasedTransparentPageRoute({
    required TransparentPage<T> page,
  }) : super(settings: page);

  TransparentPage<T> get _page => settings as TransparentPage<T>;

  @override
  bool get opaque => false;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final result =  _page.child;
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(animation),
      child: Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: result,
      ),
    );
  }

  @override
  Duration get transitionDuration => _page.transitionDuration;
}
