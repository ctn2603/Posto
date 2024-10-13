import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mvp_one/providers/connection_requests_load.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/payloads/response/friend_res.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('readNotifications', false);
}

class NotificationButton extends StatefulWidget {
  final bool isActive;
  final void Function() notificationHandler;

  const NotificationButton(
      {super.key, required this.isActive, required this.notificationHandler});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    List<FriendRequestsReceivedRes> connectionRequests =
        Provider.of<ConnectionRequestsLoad>(context).requests;

    return Center(
      child: IconButton(
          padding: const EdgeInsets.only(right: 5, bottom: 5),
          constraints: const BoxConstraints(),
          icon: FutureBuilder(
            future: UserService.doesReadNotifications(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                bool isRead = snapshot.data!;

                if (isRead) {
                  return Icon(
                    Icons.bolt,
                    color: widget.isActive
                        ? const Color(0xFFF04914)
                        : Colors.black,
                    size: 30,
                  );
                } else {
                  return Stack(
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: Colors.black,
                        size: 30,
                      ),
                      if (connectionRequests.isNotEmpty)
                        Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF04914),
                          ),
                          child: Center(
                            child: Text(
                              connectionRequests.length > 99
                                  ? "99+"
                                  : connectionRequests.length.toString(),
                              style: const TextStyle(fontSize: 8),
                            ),
                          ),
                        )
                    ],
                  );
                }
              }
              return const Icon(
                Icons.bolt,
                color: Colors.black,
                size: 30,
              );
            },
          ),
          tooltip: 'Notifications',
          onPressed: () {
            UserService.saveNotificationsStatus(true);
            setState(() {});
            widget.notificationHandler();
          }),
    );
  }

  @override
  void initState() {
    super.initState();

    // Add the observer to the widget binding
    WidgetsBinding.instance.addObserver(this);

    // Handle the scenario when the app is closed or running in the background,
    // and the user clicks on a notification to open the app.
    FirebaseMessaging.onMessageOpenedApp.listen(_messageOpenedAppHandler);

    // Handle notifications when the app is in the background or terminated, and a new FCM message arrives
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Handle notifications when the app is in the foreground, and a new FCM message arrives
    FirebaseMessaging.onMessage.listen(_messageHandler);

    _loadNotifications();
  }

  Future<void> _messageHandler(RemoteMessage message) async {
    final String type = message.data["type"];
    if (type == 'connection_notification') {
      await UserService.saveNotificationsStatus(false);
      _loadNotifications();
    }
  }

  Future<void> _messageOpenedAppHandler(RemoteMessage message) async {
    throw "Not implemented";
  }

  void _loadNotifications() async {
    String userId = await CredentialStorageService().getUserId();
    if (mounted) {
      Provider.of<ConnectionRequestsLoad>(context, listen: false)
          .loadConnectionRequests(userId);
    }
  }

  @override
  void dispose() {
    // Remove the observer when the app is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Implement the callbacks for WidgetsBindingObserver
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      bool? read = prefs.getBool('readNotifications');
      if (read != null && !read) {
        await UserService.saveNotificationsStatus(false);
        _loadNotifications();
      }
    }
  }
}
