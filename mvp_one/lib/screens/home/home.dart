import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp_one/providers/connection_requests_load.dart';
import 'package:mvp_one/providers/post_providers/square_posts_load/other_square_posts_load.dart';
import 'package:mvp_one/providers/post_providers/square_posts_load/user_square_posts_load.dart';
import 'package:mvp_one/screens/campus/campus.dart';
import 'package:mvp_one/screens/home/count_down_timer.dart';
import 'package:mvp_one/screens/home/notification_button.dart';
import 'package:mvp_one/screens/notifications/notifications.dart';
import 'package:mvp_one/screens/playground/playground.dart';
import 'package:mvp_one/screens/profile/profile.dart';
import 'package:mvp_one/screens/search/user_search.dart';
import 'package:mvp_one/screens/square/square.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  static StaticPageRoute route() {
    return StaticPageRoute(
        settings: const RouteSettings(name: '/home'), child: const Home());
  }

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final int _notificationBtnIdx = 0;
  final int _userSearchBtnIdx = 1;
  final int _profileBtnIdx = 2;
  int _activeButtonIndex = -1;
  bool _onboardPageSeen = false;
  bool _isOnboard = false;

  late final Timer _timerForFilteringPosts;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset:
              false, // Stop photo from shrinking when pull up a keyboard
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(30),
            child: AppBar(
              systemOverlayStyle: SystemUiOverlayStyle
                  .dark, // set status bar icon colors to dark mode, if not, it's hard to see icons like wifi, battery
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Posto logo
                  Expanded(
                      child: Container(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/posto.png',
                      fit: BoxFit.contain,
                      height: 38,
                    ),
                  )),
                  // Count down timer
                  const CountDownTimer(),
                  // Search and Setting
                  Expanded(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      NotificationButton(
                        isActive: _activeButtonIndex == 0,
                        notificationHandler: () {
                          CredentialStorageService().getUserId().then((userId) {
                            Provider.of<ConnectionRequestsLoad>(context,
                                    listen: false)
                                .loadConnectionRequests(userId);
                          });

                          _goto(const Notifications(), _notificationBtnIdx);
                        },
                      ),
                      IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.search_outlined,
                            color: _activeButtonIndex == 1
                                ? const Color(0xFFF04914)
                                : Colors.black,
                            size: 30,
                          ),
                          tooltip: 'Search',
                          onPressed: () {
                            _goto(const UserSearch(), _userSearchBtnIdx);
                          }),
                      Center(
                        child: IconButton(
                            padding: const EdgeInsets.only(right: 5, bottom: 5),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.person,
                              color: _activeButtonIndex == 2
                                  ? const Color(0xFFF04914)
                                  : Colors.black,
                              size: 30,
                            ),
                            tooltip: 'User',
                            onPressed: () async {
                              _goto(const Profile(), _profileBtnIdx);
                            }),
                      ),
                    ],
                  ))
                ],
              ),
              backgroundColor:
                  Colors.transparent, // Disable appbar background color
              elevation: 0,
            ),
          ),
          body: Navigator(
            key: Global.getMainNavigatorKey(),
            onGenerateRoute: (RouteSettings settings) {
              return MaterialPageRoute(
                  settings: const RouteSettings(name: 'Main'),
                  builder: (context) {
                    return PageView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return DefaultTabController(
                            length:
                                3, // There 3 tabs: square, campus, playground
                            child: Scaffold(
                              resizeToAvoidBottomInset:
                                  false, // Stop photo from shrinking when pull up a keyboard

                              // Tabs section
                              bottomNavigationBar: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                            width: 1,
                                            color:
                                                Colors.grey.withOpacity(0.2)))),
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 30, left: 30, right: 30),
                                child: TabBar(
                                    onTap: (value) {
                                      if (_activeButtonIndex != -1) {
                                        Navigator.of(Global.getSCPTabContext())
                                            .popUntil((route) => route.isFirst);
                                      }
                                      _setActiveButton(-1);
                                    },
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal:
                                            0), // Adjust the horizontal padding
                                    indicator: const BoxDecoration(
                                      color: Colors
                                          .transparent, // Set the background color of the indicator
                                    ),
                                    tabs: ["SQUARE", "CAMPUS", "PLAYGROUND"]
                                        .asMap()
                                        .entries
                                        .map((entry) => Tab(
                                            height: 30,
                                            child: Builder(
                                              builder: (context) {
                                                bool isActive =
                                                    DefaultTabController.of(
                                                                    context)
                                                                .index ==
                                                            entry.key &&
                                                        _activeButtonIndex ==
                                                            -1;
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 0),
                                                  child: Text(
                                                    entry.value,
                                                    style: isActive
                                                        ? const TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFFF04914),
                                                            fontWeight:
                                                                FontWeight.bold)
                                                        : const TextStyle(
                                                            fontSize: 15,
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                );
                                              },
                                            )))
                                        .toList()),
                              ),
                              body: Padding(
                                padding: const EdgeInsets.all(0),
                                child: Navigator(
                                  key: Global.getSCPTabNavigatorKey(),
                                  onGenerateRoute: (RouteSettings settings) {
                                    return MaterialPageRoute(
                                        settings:
                                            const RouteSettings(name: 'SCPTab'),
                                        builder: (context) {
                                          return PageView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return IndexedStack(
                                                  index:
                                                      DefaultTabController.of(
                                                              context)
                                                          .index,
                                                  children: const [
                                                    Square(),
                                                    Campus(),
                                                    Playground()
                                                  ],
                                                );
                                              });
                                        });
                                  },
                                ),
                              ),
                            ),
                          );
                        });
                  });
            },
          ),
        ),
        _buildOverlayIntroduction()
      ],
    );
  }

  @override
  void dispose() {
    _timerForFilteringPosts.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getOnboardStatus().then((value) {
      if (value != null) {
        setState(() {
          _isOnboard = value;
        });
      }
    });

    // The code below carries out filtering of posts frequently to ensure
    // The user only sees an updated screen based on the change of time.

    _timerForFilteringPosts = Timer.periodic(const Duration(minutes: 1), (_) {
      Provider.of<UserSquarePostsLoad>(
        context,
        listen: false,
      ).filterAndUpdatePosts();
      Provider.of<OtherSquarePostsLoad>(
        context,
        listen: false,
      ).filterAndUpdatePosts();
    });
  }

  Widget _buildOverlayIntroduction() {
    return Visibility(
        visible: _isOnboard && !_onboardPageSeen,
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Padding(
                    padding: const EdgeInsets.only(left: 38.0, right: 38.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 160),
                        const DefaultTextStyle(
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: "IBMPlexSans"),
                          child: Text(
                            "Glad to see you!",
                          ),
                        ),
                        const SizedBox(height: 30),
                        const DefaultTextStyle(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontFamily: "IBMPlexSans"),
                          child: Text(
                            "Nah, we ain't not just another social app. We're here to solve a problem. We all know how toxic socials can be. But, we don't want to be another dull digital detox app or the extra social app bugging you to post daily (cool anyway). We love social media, we believe it has many upsides. Our goal? To provide a high-quality, balanced experience. You're part of a movement now.",
                          ),
                        ),
                        const SizedBox(height: 30),
                        const DefaultTextStyle(
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontFamily: "IBMPlexSans"),
                          child: Text(
                            "Take control, be a real life lover.",
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                            width: 100,
                            child: Image.asset('assets/images/posto.png',
                                color: Colors.white)),
                        const SizedBox(height: 100),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(
                                30), // Adjust the radius as needed
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      30), // Match the parent ClipRRect's borderRadius
                                  color:
                                      const Color.fromARGB(30, 255, 240, 230),
                                  border: Border.all(
                                      color: Colors.white, width: 1)),
                              child: SizedBox(
                                height: 32,
                                width: 150,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _onboardPageSeen = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                  ),
                                  // Play text
                                  child: const DefaultTextStyle(
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "IBMPlexSans"),
                                      child: Text("LET'S START")),
                                ),
                              ),
                            )),
                        const SizedBox(height: 25)
                      ],
                    )))));
  }

  Future<bool?> _getOnboardStatus() async {
    String userId = await CredentialStorageService().getUserId();
    bool? isOnboard = await UserService.isOnboard(userId);
    if (isOnboard == true) {
      await UserService.onboarded(userId);
    }
    return isOnboard;
  }

  void _goto(final Widget screen, final int activeButtonIdx) {
    if (_activeButtonIndex == -1) {
      Navigator.of(Global.getMainContext())
          .popUntil((route) => route.settings.name == "Main");
      Navigator.of(Global.getSCPTabContext()).push(StaticPageRoute(
        child: screen,
      ));
      _setActiveButton(activeButtonIdx);
    }

    if (_activeButtonIndex != activeButtonIdx) {
      Navigator.of(Global.getSCPTabContext()).pushReplacement(StaticPageRoute(
        child: screen,
      ));
      _setActiveButton(activeButtonIdx);
    }
  }

  void _setActiveButton(int index) {
    setState(() {
      _activeButtonIndex = index;
    });
  }
}
