import 'package:flutter/material.dart';
import 'package:mvp_one/screens/profile/search_profile.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/connection.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:mvp_one/utils/payloads/response/users_res.dart';

class UserSearch extends StatefulWidget {
  const UserSearch({Key? key}) : super(key: key);

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  String newQuery = "";
  int listLen = 0;
  late Users users;

  @override
  Widget build(BuildContext context) {
    var itemCount = listLen;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Find your friends',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SizedBox(
              height: 40.0,
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 10.0),
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: _updateSearchQuery,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: itemCount + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == itemCount) {
                  // Display "Suggested friends" text
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Suggested friends',
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  );
                } else {
                  // Display list item
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // const SizedBox(width: 14.0),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: SizedBox(
                              width: 50.0,
                              height: 50.0,
                              child: Image.network(
                                  users.users[index]['profileImage'],
                                  fit: BoxFit.fill),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          SizedBox(
                            width: 120,
                            child: Text(
                              users.users[index]['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 15),
                            ),
                          ),
                          Expanded(child: Container()),
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: _isStatusButtonEnabled(
                                      users.users[index]["friendship_status"])
                                  ? () async {
                                      // Connect button action
                                      users.users[index]["friendship_status"] =
                                          "requested";
                                      String senderId =
                                          await CredentialStorageService()
                                              .getUserId();
                                      String receiverId =
                                          users.users[index]["id"];
                                      ConnectionService.sendConnectionRequest(
                                          senderId, receiverId);
                                      setState(() {});
                                    }
                                  : null,
                              style: _getStatusButtonStyle(
                                  users.users[index]["friendship_status"]),
                              child: Text(
                                _getStatusButtonText(
                                        users.users[index]["friendship_status"])
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 13.0), // Set the button text size
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () async {
                        // Go to User's profile page
                        String receiverUserName =
                            users.users[index]["username"];
                        String receiverFullName = users.users[index]["name"];
                        String receiverProfileImg =
                            users.users[index]["profileImage"];
                        String receiverConnectionStatus =
                            users.users[index]["friendship_status"];
                        String receiverId = users.users[index]["id"];
                        int receiverNConnections =
                            (await ConnectionService.getConnections(
                                    receiverId))!
                                .length;

                        if (context.mounted) {
                          // get connection result from previous page
                          users.users[index]["friendship_status"] =
                              await Navigator.of(context).push(StaticPageRoute(
                                      child: SearchProfile(
                                          id: receiverId,
                                          userName: receiverUserName,
                                          fullName: receiverFullName,
                                          profileImage: receiverProfileImg,
                                          connectionStatus:
                                              receiverConnectionStatus,
                                          nConnections:
                                              receiverNConnections))) ??
                                  receiverConnectionStatus;
                          setState(() {});
                        }
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _getStatusButtonStyle(String status) {
    BorderSide borderSide;
    Color bgColor;
    Color fgColor = Colors.white;
    switch (status) {
      case "unconnect":
        borderSide = BorderSide.none;
        bgColor = const Color.fromRGBO(255, 58, 11, 1.0);
        break;

      case "declined":
        bgColor = const Color.fromRGBO(237, 28, 28, 1.0);
        borderSide = BorderSide.none;
        break;

      case "requested":
        bgColor = Colors.transparent;
        borderSide = const BorderSide(color: Color.fromRGBO(255, 58, 11, 1.0));
        fgColor = const Color.fromRGBO(255, 58, 11, 1.0);

      case "connect":
        bgColor = Colors.black;
        borderSide = const BorderSide();

      default:
        borderSide = const BorderSide();
        bgColor = const Color.fromRGBO(255, 58, 11, 1.0);
        break;
    }

    return ElevatedButton.styleFrom(
      disabledForegroundColor: fgColor,
      disabledBackgroundColor: bgColor,
      foregroundColor: Colors.white,
      backgroundColor: bgColor, // Set the button text color
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      minimumSize: const Size(50.0, 10.0), // Set the minimum button size
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(19.0), // Set the button roundness
        side: borderSide,
      ),
    );
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
    if (status == "unconnect") {
      return true;
    }
    return false;
  }

  void _updateSearchQuery(String query) async {
    newQuery = query;

    if (query.isNotEmpty) {
      final tmp = await UserService.getUsersBySearch(query);
      if (newQuery == query) {
        users = tmp;
        listLen = users.users.length;
      }
    } else {
      users = const Users(users: []);
      listLen = 0;
    }
    setState(() {});
  }
}
