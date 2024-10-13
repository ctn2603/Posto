import 'package:flutter/material.dart';

class ScaleRoute extends PageRouteBuilder {
  final Widget child;

  ScaleRoute({required this.child})
      : super(
            transitionDuration: const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) => child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}
