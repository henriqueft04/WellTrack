import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState? get navigator => navigatorKey.currentState;

  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return navigator!.pushNamed<T>(routeName, arguments: arguments);
  }

  Future<T?> push<T extends Object?>(Route<T> route) {
    return navigator!.push<T>(route);
  }

  void pop<T extends Object?>([T? result]) {
    return navigator!.pop<T>(result);
  }

  bool canPop() {
    return navigator!.canPop();
  }

  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Route<T> newRoute,
    RoutePredicate predicate,
  ) {
    return navigator!.pushAndRemoveUntil<T>(newRoute, predicate);
  }

  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    Route<T> newRoute, {
    TO? result,
  }) {
    return navigator!.pushReplacement<T, TO>(newRoute, result: result);
  }
} 