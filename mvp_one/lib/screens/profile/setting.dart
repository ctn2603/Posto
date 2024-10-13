// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mvp_one/screens/signin/sign_in.dart';
import 'package:mvp_one/services/authentication/authentication.service.dart';
import 'package:mvp_one/utils/global.dart';
import 'package:mvp_one/utils/page_routes/static_page_route.dart';

class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);

  Future<void> signOut(BuildContext context) async {
    await AuthenticationService.signOut();
    Navigator.pushAndRemoveUntil(
      Global.getGlobalContext(),
      StaticPageRoute(child: const SignIn()),
      (route) => false, // Remove all routes from the stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0E6),
      ),
      child: Column(
        children: [
          // added padding for space over the back buttons
          const SizedBox(
            height: 10.0,
          ),

          // container holding the back button and profile text
          Container(
            alignment: Alignment.centerLeft,
            padding:
                const EdgeInsets.only(top: 1, bottom: 1, left: 30, right: 0),
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  IconButton(
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Image.asset(
                        'assets/icons/settings_button_back.png'), // back icon
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black, // color of text
                      textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontFamily: "IBMPlexSans"),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Profile",
                    ),
                  ),
                ],
              ),
            ),
          ),

          // padding between back button area and setting functionalities
          const SizedBox(
            height: 40.0,
          ),
          const DefaultTextStyle(
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w600,
                  fontFamily: "IBMPlexSans"),
              child: Text("Setting")),

          // setting buttons container
          Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 0, left: 30, right: 30),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.only(
                  left: 7, top: 10, right: 10, bottom: 10),
              child: Column(children: [
                // privacy button
                const SmallButton(settingOption: "Privacy"),

                // terms of service button
                const SmallButton(settingOption: "Terms of Service"),

                // community rules button
                const SmallButton(settingOption: "Community Rules"),

                // report a problem button
                const SmallButton(settingOption: "Report a problem"),

                // become a pioneer button
                const SmallButton(settingOption: "Become a Pioneer"),

                // log out button
                SmallButton(
                  settingOption: "Log out",
                  onPressed: () {
                    signOut(context);
                  },
                ),

                // manage account button
                const SmallButton(settingOption: "Manage account")
              ]),
            ),
          ),

          // rate the app button
          Padding(
            padding:
                const EdgeInsets.only(top: 15, bottom: 0, left: 30, right: 30),
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(25)),
              child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    foregroundColor: Colors.black, // color of text
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: "IBMPlexSans"),
                  ),
                  onPressed: () => {}, // NO FUNCTIONALITY
                  child: const Text("Rate the app")),
            ),
          ),

          // buy us a coffee button
          Padding(
            padding:
                const EdgeInsets.only(top: 15, bottom: 0, left: 30, right: 30),
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(25)),
              child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    foregroundColor: Colors.black, // color of text
                    textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: "IBMPlexSans"),
                  ),
                  onPressed: () => {}, // NO FUNCTIONALITY
                  child: const Text("Buy us a coffee")),
            ),
          ),
        ],
      ),
    );
  }
}

// small button class for the various setting button options
class SmallButton extends StatelessWidget {
  final String settingOption;
  final VoidCallback? onPressed;
  const SmallButton({super.key, required this.settingOption, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
          width: 300.0,
          child: GestureDetector(
            onTap: onPressed,
            child: ListTile(
                dense: true,
                visualDensity: const VisualDensity(
                    horizontal: -4, vertical: -4), // removes default padding
                // NO FUNCTIONALITY, pass in the route
                title: Text(settingOption,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: "IBMPlexSans")),
                leading: Image.asset(
                    'assets/icons/settings_button_list.png'), // plus icon beside text
                minLeadingWidth: 30),
          )),
    );
  }
}
