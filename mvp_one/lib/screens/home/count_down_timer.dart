import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvp_one/configs/app_config.dart';
import 'package:mvp_one/providers/time_out.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountDownTimer extends StatefulWidget {
  const CountDownTimer({super.key});

  @override
  State<CountDownTimer> createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with WidgetsBindingObserver {
  int? _remainingSeconds;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    if (_remainingSeconds == null) {
      return Container();
    }
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 10, top: 2, right: 10, bottom: 2),
        child: Text(
          _formatTime(_remainingSeconds!),
          style: (_remainingSeconds! > 0)
              ? const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.black)
              : const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14, color: Colors.red),
          textAlign: TextAlign.center,
        ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Handle app lifecycle state changes
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground, start the timer
      _startTimer();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // App is in the background or inactive, pause the timer
      _pauseTimer();
      _saveTimer();
    }
  }

  /// Free resources
  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _startTimer();

    // Add the observer to listen to app lifecycle events
    WidgetsBinding.instance.addObserver(this);
  }

  /// Format the displayed time
  ///
  /// Takes in the [remainingSeconds] and return in the MM:SS format
  String _formatTime(int remainingSeconds) {
    int seconds = remainingSeconds % 60;
    int minutes = (remainingSeconds % 3600) ~/ 60;
    int hours = remainingSeconds ~/ 3600;
    String formattedSeconds =
        seconds.toString().length <= 1 ? "0$seconds" : "$seconds";
    String formattedMinutes =
        minutes.toString().length <= 1 ? "0$minutes" : "$minutes";
    String formattedHours = hours.toString().length <= 1 ? "0$hours" : "$hours";
    if (hours == 0) {
      return "$formattedMinutes:$formattedSeconds";
    } else {
      return "$formattedHours:$formattedMinutes:$formattedSeconds";
    }
  }

  void _pauseTimer() {
    // Pause the timer by cancelling it
    _timer?.cancel();
  }

  void _saveTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('timer_value', _remainingSeconds!);
    prefs.setInt('day', DateTime.now().day);
  }

  /// Start the timer
  void _startTimer() async {
    // kill old timer
    if (_timer != null && _timer!.isActive) {
      _pauseTimer();
    }

    if (mounted) {
      // Load stored day and timer value
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int storedDay = prefs.getInt("day") ?? DateTime.now().day;
      _remainingSeconds = prefs.getInt('timer_value') ?? viewTimeOut;

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        int currentDay = DateTime.now().day;

        if (storedDay != currentDay) {
          storedDay = currentDay;
          setState(() {
            // Update displayed timer
            _remainingSeconds = viewTimeOut;
          });
          Provider.of<TimeOut>(context, listen: false).timeNotUp();
        } else if (_remainingSeconds == 0) {
          setState(() {}); // Force count down timer to display 00:00:00
          // Send the timeup signal
          Provider.of<TimeOut>(context, listen: false).timeUp();
        } else {
          setState(() {
            // Update displayed timer
            _remainingSeconds = _remainingSeconds! - 1;
          });
        }
      });
    }
  }
}
