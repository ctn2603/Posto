import 'package:flutter/material.dart';

class FadeRoute extends PageRouteBuilder {
  final Widget child;

  FadeRoute({required this.child, RouteSettings? settings})
      : super(
            settings: settings,
            transitionDuration: const Duration(milliseconds: 50),
            pageBuilder: (context, animation, secondaryAnimation) => child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
