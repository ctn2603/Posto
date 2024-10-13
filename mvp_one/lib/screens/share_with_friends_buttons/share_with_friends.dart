import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareWithFriendsSection extends StatefulWidget {
  const ShareWithFriendsSection({super.key});

  @override
  State<ShareWithFriendsSection> createState() =>
      _ShareWithFriendsSectionState();
}

class _ShareWithFriendsSectionState extends State<ShareWithFriendsSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 20),
        child: Column(children: [
          SizedBox(
            height: 40,
            child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF04914),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    fixedSize: const Size.fromHeight(30.0)),
                onPressed: () {
                  Share.share('I\'m inviting you to Posto', subject: "Posto");
                },
                child: const Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFF0E6),
                        fontFamily: "IBMPlexSans"),
                    child: Text(
                      "INVITE FRIENDS",
                    ),
                  ),
                )),
          ),
          // const SizedBox(height: 10),
          // TODO: Temporarily ignore as the feature is not available
          // SizedBox(
          //   height: 40,
          //   child: OutlinedButton(
          //       style: OutlinedButton.styleFrom(
          //         side: const BorderSide(color: Color(0xFFF04914), width: 2.0),
          //         backgroundColor: Colors.transparent,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(40),
          //         ),
          //       ),
          //       onPressed: () {},
          //       child: const Center(
          //         child: DefaultTextStyle(
          //           style: TextStyle(
          //               fontSize: 15,
          //               fontWeight: FontWeight.w600,
          //               color: Color(0xFFF04914),
          //               fontFamily: "IBMPlexSans"),
          //           child: Text(
          //             "SHARE YOUR CONTENT",
          //           ),
          //         ),
          //       )),
          // )
        ]));
  }
}
