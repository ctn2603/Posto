import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mvp_one/screens/signin/sign_in_buttons/apple_sign_in_button.dart';
import 'package:mvp_one/screens/signin/sign_in_buttons/google_sign_in_button.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
              'assets/images/sign_in_image.png', // Replace with your image path
              fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 50.0, right: 50.0, bottom: 50.0, top: 20.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Posto logo section
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(top: 0.0),
                            child: SizedBox(
                                width: 200,
                                child: Image.asset('assets/images/posto.png',
                                    color: Colors.white))),
                        const SizedBox(
                          height: 20,
                        ),
                        // Mission Statement
                        const Text(
                          "Healthy and fair social network for people who love real life.",
                          style: TextStyle(
                              fontFamily: "IBM Plex Sans",
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: Container()),
                        // Terms and Conditions
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, bottom: 20.0),
                            child: Align(
                              alignment: Alignment.center,
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(children: [
                                    TextSpan(
                                      text:
                                          "By tapping ‘Sign in with Google’ / 'Sign in with Apple', you agree to our Terms of Service. Learn how we process your data in our ",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "IBM Plex Sans",
                                          fontSize: 10,
                                          fontWeight: FontWeight.normal),
                                    ),
                                    TextSpan(
                                        text:
                                            "Privacy Policy and Cookies Policy",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "IBM Plex Sans",
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold))
                                  ])),
                            )),
                        // Google Sign-in Button
                        const GoogleSignInButton(),
                        const SizedBox(
                          height: 5,
                        ),
                        if (Platform.isIOS)
                          // Apple Sign-in Button
                          const AppleSignInButton(),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        )
      ]),
    );
  }
}
