import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvp_one/flavors.dart';
import 'package:mvp_one/providers/post_providers/campus_posts_load.dart';
import 'package:mvp_one/providers/connection_requests_load.dart';
import 'package:mvp_one/providers/load_profile_picture.dart';
import 'package:mvp_one/providers/post_providers/create_square_post.dart';
import 'package:mvp_one/providers/post_providers/playground_posts_load.dart';
import 'package:mvp_one/providers/post_providers/square_posts_load/other_square_posts_load.dart';
import 'package:mvp_one/providers/time_out.dart';
import 'package:mvp_one/providers/user_post_status.dart';
import 'package:mvp_one/providers/post_providers/square_posts_load/user_square_posts_load.dart';
import 'package:mvp_one/screens/home/home.dart';
import 'package:mvp_one/screens/signin/sign_in.dart';
import 'package:mvp_one/services/authentication/apple_auth.service.dart';
import 'package:mvp_one/services/authentication/authentication.service.dart';
import 'package:mvp_one/services/authentication/google_auth.service.dart';
import 'package:mvp_one/services/push_notification.service.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:mvp_one/utils/network.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.initialize();

  if (F.appFlavor == Flavor.dev) {
    await Network
        .initialize(); // TODO: Enable this line after adding dev environment
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstAppStartUp = prefs.getBool('first_app_start_up') ?? true;

  if (isFirstAppStartUp) {
    await FirebaseAuth.instance.signOut();
    prefs.setBool('first_app_start_up', false);
  }
  // await FirebaseAuth.instance.signOut();
  // await GoogleAuthService().signOut();
  // await AppleAuthService().signOut();
  runApp(const PostoSocial());
}

class PostoSocial extends StatefulWidget {
  const PostoSocial({Key? key}) : super(key: key);

  @override
  State<PostoSocial> createState() => _PostoSocialState();
}

class _PostoSocialState extends State<PostoSocial> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TimeOut>(
          create: (_) => TimeOut(),
        ),
        ChangeNotifierProvider<OtherSquarePostsLoad>(
          create: (_) => OtherSquarePostsLoad(),
        ),
        ChangeNotifierProvider<CampusPostsLoad>(
          create: (_) => CampusPostsLoad(),
        ),
        ChangeNotifierProvider<PlaygroundPostsLoad>(
          create: (_) => PlaygroundPostsLoad(),
        ),
        ChangeNotifierProvider<UserPostStatus>(
          create: (_) => UserPostStatus(),
        ),
        ChangeNotifierProvider<ConnectionRequestsLoad>(
          create: (_) => ConnectionRequestsLoad(),
        ),
        ChangeNotifierProvider<ProfilePicLoad>(
          create: (_) => ProfilePicLoad(),
        ),
        ChangeNotifierProvider<UserSquarePostsLoad>(
          create: (_) => UserSquarePostsLoad(),
        ),
        ChangeNotifierProvider<CreateSquarePost>(
          create: (_) => CreateSquarePost(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFFFF0E6),
          fontFamily: "IBMPlexSans",
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        navigatorKey: Global.getGlobalNavigatorKey(),
        home: AuthenticationService.isUserSignedIn()
            ? const Home()
            : const SignIn(),
      ),
    );
  }
}
