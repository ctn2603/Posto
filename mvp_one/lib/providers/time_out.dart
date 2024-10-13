import 'package:flutter/material.dart';

// TimeOut Feed Notifier
class TimeOut extends ChangeNotifier {
  bool _timeUp = false;

  bool isTimeUp() {
    return _timeUp == true;
  }

  bool isTimeNotUp() {
    return _timeUp == false;
  }

  void timeUp() {
    _timeUp = true;
    notifyListeners();
  }

  void timeNotUp() {
    _timeUp = false;
    notifyListeners();
  }
}
