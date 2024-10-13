import 'package:flutter/material.dart';

class StaticPageRoute extends PageRouteBuilder {
  final Widget child;

  StaticPageRoute({required this.child, RouteSettings? settings})
      : super(
            settings: settings,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (context, animation, secondaryAnimation) => child);
}
