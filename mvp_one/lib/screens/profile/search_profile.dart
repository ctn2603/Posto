import 'package:flutter/material.dart';
import 'package:mvp_one/screens/profile/connections.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/connection.service.dart';
import 'package:mvp_one/utils/global.dart';

List<Map<String, String>> suggestedUsers = [
  {"username": "Ayush", "profile_pic": "assets/images/IMG_4785 1.png"},
  {"username": "Charles", "profile_pic": "assets/images/IMG_4785 2.png"},
  {"username": "Ladislas", "profile_pic": "assets/images/IMG_4785 3.png"},
  {"username": "Raphael", "profile_pic": "assets/images/IMG_4785 4.png"},
];

class SearchProfile extends StatefulWidget {
  final String id;
  final String userName;
  final String fullName;
  final String profileImage;
  final String connectionStatus; //Connected, request pending etc
  final int nConnections;

  const SearchProfile(
      {super.key,
      required this.id,
      required this.userName,
      required this.fullName,
      required this.profileImage,
      required this.connectionStatus,
      required this.nConnections});

  @override
  State<SearchProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<SearchProfile> {
  late String buttonStatusText;
  late bool isButtonStatusEnabled;
  late ButtonStyle buttonStatusStyle;
  late String currConnectionStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFFFF0E6)),
      child: Center(
        child: Column(
          children: [
            // space between top of phone and rest of content
            const SizedBox(
              height: 10.0,
            ),

            // container holding the back button and search text
            Container(
              alignment: Alignment.centerLeft,
              padding:
                  const EdgeInsets.only(top: 1, bottom: 1, left: 30, right: 0),
              child: Material(
                color: Colors.transparent,
                child: Row(
                  children: [
                    IconButton(
                      iconSize: 13,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Image.asset(
                          'assets/icons/settings_button_back.png'), // back icon
                      onPressed: () {
                        Navigator.pop(
                            Global.getSCPTabContext(), currConnectionStatus);
                      },
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black, // color of text
                        textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontFamily: "IBMPlexSans"),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Navigator.pop(context);
                      },
                      child: const Text(
                        "Search",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // extra space
            const SizedBox(
              height: 30.0,
            ),

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
                        child: Image.network(
                          widget.profileImage,
                          fit: BoxFit.contain,
                          width: 140,
                          height: 140,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        width: 140,
                        height: 30,
                        child: ElevatedButton(
                          style: buttonStatusStyle,
                          onPressed: isButtonStatusEnabled
                              ? () async {
                                  String senderId =
                                      await CredentialStorageService()
                                          .getUserId();
                                  ConnectionService.sendConnectionRequest(
                                      senderId, widget.id);
                                  setState(() {
                                    isButtonStatusEnabled = false;
                                    currConnectionStatus = "requested";
                                    buttonStatusText =
                                        currConnectionStatus.toUpperCase();
                                    buttonStatusStyle = _getStatusButtonStyle(
                                        isButtonStatusEnabled);
                                  });
                                }
                              : null,
                          child: Text(
                            buttonStatusText,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: "IBMPlexSans"),
                          ),
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

                      // name text
                      DefaultTextStyle(
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "IBMPlexSans"),
                          child: Text(
                            widget.fullName,
                          )),

                      // account username text
                      DefaultTextStyle(
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            // fontWeight: FontWeight.w500,
                            fontFamily: "IBMPlexSans"),
                        child: Text(
                          '@${widget.userName}',
                        ),
                      ),

                      Expanded(child: Container()),

                      Expanded(flex: 2, child: Container()),
                      SizedBox(
                          width: 140,
                          height: 30,
                          child: OutlinedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<OutlinedBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              side: MaterialStateProperty.all<BorderSide>(
                                const BorderSide(
                                    color: Colors.black, width: 1.5),
                              ),
                            ),
                            onPressed: () {
                              const Connections();
                            },
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                  // check the number of connections for grammar
                                  widget.nConnections > 1
                                      ? "${widget.nConnections} connections"
                                      : "${widget.nConnections} connection",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: "IBMPlexSans"),
                                )),
                          )),
                    ],
                  ),
                ],
              ),
            ),

            // space between content

            // suggested friends text
            MaterialButton(
              onPressed: () {},
              child: Image.asset(
                'assets/icons/no_posts_user_search_profile.png',
                width: 300,
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    currConnectionStatus = widget.connectionStatus;
    buttonStatusText =
        _getStatusButtonText(widget.connectionStatus).toUpperCase();
    isButtonStatusEnabled = _isStatusButtonEnabled(widget.connectionStatus);
    buttonStatusStyle = _getStatusButtonStyle(isButtonStatusEnabled);
  }

  ButtonStyle _getStatusButtonStyle(bool isEnabled) {
    BorderSide borderSide;
    if (isEnabled) {
      borderSide = BorderSide.none;
    } else {
      borderSide = const BorderSide(color: Colors.black, width: 1.5);
    }

    return ElevatedButton.styleFrom(
        disabledForegroundColor: Colors.black,
        disabledBackgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        backgroundColor:
            const Color.fromRGBO(255, 58, 11, 1.0), // Set the button text color
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
        minimumSize: const Size(50.0, 10.0), // Set the minimum button size
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Set the button roundness
          side: borderSide,
        ));
  }

  String _getStatusButtonText(String originalStatus) {
    switch (originalStatus) {
      case "connect":
        return "connected";
      case "unconnect":
        return "connect";
      case "declined":
        return "declined";
      case "requested":
        return "requested";
      case "received":
      default:
        return "connect";
    }
  }

  bool _isStatusButtonEnabled(String status) {
    if (status == "unconnect" || status == "received") {
      return true;
    }
    return false;
  }
}
