import 'package:flutter/material.dart';
import 'package:mvp_one/screens/playground/feed.dart';
import 'package:mvp_one/services/credential_storage.service.dart';
import 'package:mvp_one/services/rest/user_services/user.service.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:url_launcher/url_launcher.dart';

class Playground extends StatefulWidget {
  const Playground({super.key});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground>
    with AutomaticKeepAliveClientMixin {
  bool _ackPlayground = true;

  @override
  bool get wantKeepAlive =>
      true; // Prevent tab content GUI from rebuilding itself

  @override
  void initState() {
    super.initState();
    _hasAcknowledgedPlayground().then((value) {
      if (value == null) {
        _ackPlayground = false;
      } else {
        _ackPlayground = value;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Navigator(
      key: Global.getPlaygroundNavigatorKey(),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            settings: const RouteSettings(name: 'Playground'),
            builder: (context) {
              return SizedBox(
                  child: Column(
                children: [
                  const SizedBox(height: 10),
                  if (!_ackPlayground) _buildAckSection(context),
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
                "PLAYGROUND",
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
                        "Playground is the feed dedicated to entertainment in all its shades. Anyone can post their public content and go viral soon.",
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
                    UserService.acknowledgedPlayground(userId);
                    setState(() {
                      _ackPlayground = true;
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

  Future<bool?> _hasAcknowledgedPlayground() async {
    String userId = await CredentialStorageService().getUserId();
    return UserService.hasAcknowledgedPlayground(userId);
  }

  Future<void> _launchURL(String uri) async {
    final Uri url = Uri.parse('https://$uri');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
