import 'package:flutter/material.dart';

class Connections extends StatelessWidget {
  const Connections({super.key});

  @override
  Widget build(BuildContext context) {
    // CredentialStorageService credentialStorage =
    //     CredentialStorageService(); //accesses _storage to get user information

    return Column(
      children: [
        Container(
            alignment: Alignment.center,
            padding:
                const EdgeInsets.only(top: 20, bottom: 0, left: 0, right: 0),
            child: const DefaultTextStyle(
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w300,
                    fontFamily: "IBMPlexSans"),
                child: Text("Connections"))),

        // display all notifications here

        const ConnectionsHandle(name: "Ayush Goel"), // test
        const ConnectionsHandle(name: "Simerus Maheshhhhh"), // test
        const ConnectionsHandle(name: "Simerus Mahesh"), // test
        const ConnectionsHandle(name: "Sar") // test
      ],
    );
  }
}

class ConnectionsHandle extends StatelessWidget {
  // TODO: ADD ADDITIONAL REQUIRED FIELDS THAT WILL BE PASSED
  final String name;

  const ConnectionsHandle({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 9, bottom: 9, left: 22, right: 22),
      child: Row(children: [
        // profile picture
        Image.asset('assets/images/IMG_4785 1.png', height: 60, width: 60),

        // information texts
        Container(
            padding:
                const EdgeInsets.only(top: 0, bottom: 0, left: 15, right: 0),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name text
                DefaultTextStyle(
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w600,
                        fontFamily: "IBMPlexSans"),
                    child: Text(name)),

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

        // TODO: CREATE CONTAINER THAT FIXES POSITION OF CONNECT AND DELETE BUTTON
        Expanded(child: Container()),

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
            onPressed: () {},
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
    );
  }
}
