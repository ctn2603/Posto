import 'package:flutter/material.dart';
import 'package:mvp_one/screens/campus/feed.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:url_launcher/url_launcher.dart';

class Campus extends StatefulWidget {
  const Campus({super.key});

  @override
  State<Campus> createState() => _CampusState();
}

class _CampusState extends State<Campus> with AutomaticKeepAliveClientMixin {
  bool _ackCampus = true;

  @override
  bool get wantKeepAlive =>
      true; // Prevent tab content GUI from rebuilding itself

  @override
  void initState() {
    super.initState();
    _hasAcknowledgedCampus().then((value) {
      if (value == null) {
        _ackCampus = false;
      } else {
        _ackCampus = value;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Navigator(
      key: Global.getCampusNavigatorKey(),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'Campus'),
            builder: (context) {
              return SizedBox(
                  child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (!_ackCampus) _buildAckSection(context),
                  const Expanded(child: Feed())
                ],
              ));
            });
      },
    );
  }

  Widget _buildAckSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 20.0),
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
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  fontFamily: "IBMPlexSans"),
              child: Text(
                "CAMPUS",
              ),
            )),
            const SizedBox(height: 10),
            SizedBox(
                width: 282,
                height: 118,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const DefaultTextStyle(
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                          fontFamily: "IBMPlexSans"),
                      child: Text(
                        "Space dedicated to educational and informational content. In this feed, we select creators that have an impact on your life.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _launchURL('www.postosocial.com/creators');
                      },
                      child: const DefaultTextStyle(
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: "IBMPlexSans",
                            decoration: TextDecoration.underline),
                        child: Text(
                          "Find out more.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 10),
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
                    UserService.acknowledgedCampus(userId);
                    setState(() {
                      _ackCampus = true;
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

  Future<bool?> _hasAcknowledgedCampus() async {
    String userId = await CredentialStorageService().getUserId();
    return UserService.hasAcknowledgedCampus(userId);
  }

  Future<void> _launchURL(String uri) async {
    final Uri url = Uri.parse('https://$uri');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
