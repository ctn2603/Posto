import 'package:flutter/material.dart';
import 'package:mvp_one/screens/square/feed.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/global.dart';

class Square extends StatefulWidget {
  const Square({super.key});

  @override
  State<Square> createState() => _SquareState();
}

class _SquareState extends State<Square> with AutomaticKeepAliveClientMixin {
  bool _ackSquare = true;

  @override
  bool get wantKeepAlive =>
      true; // Prevent tab content GUI from rebuilding itself

  @override
  void initState() {
    super.initState();
    _hasAcknowledgedSquare().then((value) {
      if (value == null) {
        _ackSquare = false;
      } else {
        _ackSquare = value;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Navigator(
      key: Global.getSquareNavigatorKey(),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'Square'),
            builder: (context) {
              return SizedBox(
                  child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (!_ackSquare) _buildAckSection(context),
                  const SizedBox(height: 10),
                  const Expanded(child: Feed())
                ],
              ));
            });
      },
    );
  }

  Widget _buildAckSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 10.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 20.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 3.0),
            borderRadius: BorderRadius.circular(25.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
                child: DefaultTextStyle(
              style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: "IBMPlexSans"),
              child: Text(
                "SQUARE",
              ),
            )),
            const SizedBox(height: 15),
            const DefaultTextStyle(
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontFamily: "IBMPlexSans"),
              child: Text(
                "The space for your connections. See what your friends are up to, but don’t be lazy. You need first to show up by posting.",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 180,
              height: 40,
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFFF04914), width: 2.0),
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  onPressed: () async {
                    String userId =
                        await CredentialStorageService().getUserId();
                    UserService.acknowledgedSquare(userId);
                    setState(() {
                      _ackSquare = true;
                    });
                  },
                  child: const Center(
                    child: DefaultTextStyle(
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF04914),
                          fontFamily: "IBMPlexSans"),
                      child: Text(
                        "GOT IT",
                      ),
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Future<bool?> _hasAcknowledgedSquare() async {
    String userId = await CredentialStorageService().getUserId();
    return UserService.hasAcknowledgedSquare(userId);
  }
}
