import 'package:flutter/material.dart';

class SlideUpRoute extends PageRouteBuilder {
  final Widget child;

  SlideUpRoute({required this.child})
      : super(
            transitionDuration: const Duration(milliseconds: 100),
            pageBuilder: (context, animation, secondaryAnimation) => child);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end);
    final offsetAnimation = animation.drive(tween);

    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}
