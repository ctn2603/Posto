import 'package:flutter/material.dart';

class Global {
  static final GlobalKey<NavigatorState> _globalNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _mainNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _scpTabNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _squareNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _campusNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _playgroundNavigatorKey =
      GlobalKey<NavigatorState>();

  static BuildContext getGlobalContext() {
    return _globalNavigatorKey.currentContext!;
  }

  static GlobalKey<NavigatorState> getGlobalNavigatorKey() {
    return _globalNavigatorKey;
  }

  static GlobalKey<NavigatorState> getMainNavigatorKey() {
    return _mainNavigatorKey;
  }

  static BuildContext getMainContext() {
    return _mainNavigatorKey.currentContext!;
  }

  // SCP: square, campus, playground
  static BuildContext getSCPTabContext() {
    return _scpTabNavigatorKey.currentContext!;
  }

  // SCP: square, campus, playground
  static GlobalKey<NavigatorState> getSCPTabNavigatorKey() {
    return _scpTabNavigatorKey;
  }

  static GlobalKey<NavigatorState> getSquareNavigatorKey() {
    return _squareNavigatorKey;
  }

  static BuildContext getSquareContext() {
    return _squareNavigatorKey.currentContext!;
  }

  static GlobalKey<NavigatorState> getCampusNavigatorKey() {
    return _campusNavigatorKey;
  }

  static GlobalKey<NavigatorState> getPlaygroundNavigatorKey() {
    return _playgroundNavigatorKey;
  }
}
