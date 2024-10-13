import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvp_one/providers/load_profile_picture.dart';
import 'package:mvp_one/screens/profile/connections.dart';
import 'package:mvp_one/screens/profile/edit_profile.dart';
import 'package:mvp_one/screens/share_with_friends_buttons/share_with_friends.dart';
import 'package:mvp_one/screens/signin/sign_in.dart';
import 'package:mvp_one/services/authentication/authentication.service.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/connection.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:mvp_one/utils/payloads/response/friend_res.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({
    super.key,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Future<String?> _getProfileImage() async {
    return CredentialStorageService().getUserProfileImage();
  }

  Future<String?> _getName() async {
    return CredentialStorageService().getName();
  }

  Future<String?> _getUsername() async {
    return CredentialStorageService().getUsername();
  }

  Future<int> _getNConnections() async {
    String userId = await CredentialStorageService().getUserId();
    List<FriendRes>? nConnections =
        await ConnectionService.getConnections(userId);

    if (nConnections == null) {
      return 0;
    }
    return nConnections.length;
  }

  Future<void> _launchURL(String uri) async {
    final Uri url = Uri.parse('https://$uri');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> signOut() async {
    await AuthenticationService.signOut();
    Navigator.pushAndRemoveUntil(
      Global.getGlobalContext(),
      StaticPageRoute(child: const SignIn()),
      (route) => false, // Remove all routes from the stack
    );
  }

  Future<void> _navigateToEditProfile(String profileImage) async {
    Navigator.of(context).push(StaticPageRoute(
      child: EditPfp(
        profileImage: profileImage, // Pass the newProfileImage here
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ProfilePicLoad>().profilePic;
    // nConnections = context.watch<ConnectionRequestsLoad>().connections.length;

    return Scaffold(
      body: Stack(children: [
        Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                              child: GestureDetector(
                                  child: Stack(
                                children: [
                                  FutureBuilder<String?>(
                                      future: _getProfileImage(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String?> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          // While the future is still loading
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          // If an error occurred during fetching
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          return Image.network(snapshot.data!,
                                              fit: BoxFit.fill,
                                              width: 140,
                                              height: 140);
                                        }
                                      }),
                                ],
                              )),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            SizedBox(
                              width: 170,
                              height: 30,
                              child: OutlinedButton(
                                style: ButtonStyle(
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  side: MaterialStateProperty.all<BorderSide>(
                                    const BorderSide(
                                        color: Colors.black, width: 2.0),
                                  ),
                                ),
                                onPressed: () async {
                                  String? profileImage =
                                      await _getProfileImage();
                                  if (mounted) {
                                    _navigateToEditProfile(profileImage!);
                                  }
                                },
                                child: const Text('EDIT PROFILE',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    )),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(child: Container()),
                            FutureBuilder<String?>(
                                future: _getName(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String?> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    // While the future is still loading
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    // If an error occurred during fetching
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Text(
                                      snapshot.data!,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                }),
                            FutureBuilder<String?>(
                                future: _getUsername(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String?> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    // While the future is still loading
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    // If an error occurred during fetching
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Text(
                                      "@${snapshot.data!}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                      ),
                                    );
                                  }
                                }),
                            Expanded(child: Container()),
                            SizedBox(
                              width: 170,
                              height: 30,
                              child: OutlinedButton(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    side: MaterialStateProperty.all<BorderSide>(
                                      const BorderSide(
                                          color: Colors.black, width: 2.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    const Connections();
                                  },
                                  child: FutureBuilder<int>(
                                      future: _getNConnections(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<int> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          // While the future is still loading
                                          return const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          // If an error occurred during fetching
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          int nConnections = snapshot.data!;
                                          return Text(
                                            nConnections > 1
                                                ? "$nConnections connections"
                                                : "$nConnections connection",
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          );
                                        }
                                      })),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  const ShareWithFriendsSection(),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .black, // Set your button's background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25.0), // Set the border radius
                            side: const BorderSide(
                                color: Colors.black), // Set the border color
                          )),
                      onPressed: () {
                        _launchURL('rvhw0oirs87.typeform.com/to/TtQjVr66');
                      },
                      child: const Center(
                        child: Text(
                          "SHARE FEEDBACK",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: "IBMPlexSans",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .black, // Set your button's background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25.0), // Set the border radius
                            side: const BorderSide(
                                color: Colors.black), // Set the border color
                          )),
                      onPressed: () {
                        _launchURL('www.postosocial.com/pioneers');
                      },
                      child: const Center(
                        child: Text(
                          "BECOME PIONEER",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: "IBMPlexSans",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .black, // Set your button's background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25.0), // Set the border radius
                            side: const BorderSide(
                                color: Colors.black), // Set the border color
                          )),
                      onPressed: () {
                        signOut();
                      },
                      child: const Center(
                        child: Text(
                          "LOG OUT",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: "IBMPlexSans",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors
                              .black, // Set your button's background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                25.0), // Set the border radius
                            side: const BorderSide(
                                color: Colors.black), // Set the border color
                          )),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: const Text(
                                  'Are you sure you want to delete the account?'),
                              content:
                                  const Text('This action is irreversible'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () async {
                                    // Close "Delete Account" dialog
                                    Navigator.of(context).pop();

                                    // Another dialog showing deleting account
                                    showDialog(
                                      context: context,
                                      barrierDismissible:
                                          false, // Prevent dialog from being dismissed by tapping outside
                                      builder: (BuildContext context) {
                                        return const CupertinoAlertDialog(
                                          content: Column(
                                            children: [
                                              Text('Deleting account ...',
                                                  style:
                                                      TextStyle(fontSize: 16)),
                                              SizedBox(height: 16),
                                              CupertinoActivityIndicator(), // Spinning indicator
                                            ],
                                          ),
                                        );
                                      },
                                    );

                                    // Delete the account in the background and auto sign out
                                    await UserService.deleteUserAccount();
                                    await signOut();
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }, // Add your functionality here
                      child: const Center(
                        child: Text(
                          "DELETE ACCOUNT",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: "IBMPlexSans",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          _launchURL(
                              'postosocial.notion.site/Privacy-policy-621ce14f73694697a79fc5c91dc70bce?pvs=4');
                        },
                        child: const Text(
                          'PRIVACY POLICY',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle button 2 click here
                          _launchURL(
                              'postosocial.notion.site/Terms-of-use-8b08fe821b8a46f385e38bdd85d98b2d?pvs=4');
                        },
                        child: const Text(
                          'TERMS OF USE',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )),
      ]),
    );
  }
}
