import 'package:flutter/material.dart';
import 'package:mvp_one/providers/connection_requests_load.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/connection.service.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';
import 'package:mvp_one/utils/payloads/response/friend_res.dart' as res;
import 'package:provider/provider.dart';
import 'package:mvp_one/screens/profile/search_profile.dart';
import 'package:mvp_one/utils/payloads/response/user.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  void initState() {
    super.initState();
    CredentialStorageService().getUserId().then((userId) {
      Provider.of<ConnectionRequestsLoad>(context, listen: false)
          .loadConnectionRequests(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<res.FriendRequestsReceivedRes> requests =
        context.watch<ConnectionRequestsLoad>().requests;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Padding(
                padding: const EdgeInsets.all(5),
                child: NotificationHandle(
                    name: request.name ?? "",
                    profileImage: request.profileImage ?? "",
                    senderId: request.senderId ?? "",
                    onRemove: () {
                      setState(() {
                        requests.removeAt(index);
                      });
                    }));
          }),
    );
  }
}

class NotificationHandle extends StatelessWidget {
  // TODO: ADD ADDITIONAL REQUIRED FIELDS THAT WILL BE PASSED
  final String name;
  final String profileImage;
  final String senderId;
  final VoidCallback onRemove;

  const NotificationHandle(
      {super.key,
      required this.name,
      required this.profileImage,
      required this.senderId,
      required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () async {
          User? user = await UserService.getUserById(senderId);
          String? userName = user?.username;
          int nConnections =
              (await ConnectionService.getConnections(senderId))!.length;
          await Navigator.of(context).push(StaticPageRoute(
              child: SearchProfile(
                  id: senderId,
                  userName: userName ?? "",
                  fullName: name,
                  profileImage: profileImage,
                  connectionStatus: "requested",
                  nConnections: nConnections)));
        },
        child: Container(
          padding: const EdgeInsets.only(top: 9, bottom: 9, left: 7, right: 7),
          child: Row(children: [
            // profile picture
            Image.network(profileImage, height: 40, width: 40),

            // information texts
            Container(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, left: 15, right: 0),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // name text
                    DefaultTextStyle(
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w600,
                            fontFamily: "IBMPlexSans"),
                        child: Text(name, overflow: TextOverflow.ellipsis)),

                    // wants to connect text
                    const DefaultTextStyle(
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w200,
                            fontFamily: "IBMPlexSans"),
                        child: Text("wants to connect"))
                  ],
                )),

            Expanded(child: Container()),
            // connect button
            SizedBox(
              width: 81,
              height: 20,
              child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFFF04914)), // background color
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    // Remove the item from the list
                    onRemove();

                    // Update database
                    String receiverId =
                        await CredentialStorageService().getUserId();
                    await ConnectionService.acceptConnectionRequest(
                        senderId, receiverId);
                  },
                  child: const Text(
                    "CONNECT",
                    style: TextStyle(fontSize: 10),
                  )),
            ),

            const SizedBox(width: 5),
            // delete button
            SizedBox(
              width: 81,
              height: 20,
              child: OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  side: MaterialStateProperty.all<BorderSide>(
                    const BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                onPressed: () async {
                  // Remove the item from the list
                  onRemove();

                  // Update database
                  String receiverId =
                      await CredentialStorageService().getUserId();
                  await ConnectionService.deleteConnectionRequest(
                      senderId, receiverId);
                },
                child: const Text(
                  "DELETE",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            )
          ]),
        ));
  }
}
